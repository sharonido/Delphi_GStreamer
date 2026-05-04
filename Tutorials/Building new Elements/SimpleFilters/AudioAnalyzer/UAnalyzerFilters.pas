unit UAnalyzerFilters;

interface

uses
  System.SysUtils, System.SyncObjs, System.Math,
  G2D.Glib.Types,
  G2D.Gst.Types,
  G2D.GstFramework,
  G2D.CustomSimpleAudioElement,
  G2D.GstFFT.API;

const
  EQ_BANDS = 8;
  WAVEFORM_POINTS = 1024;
  FFT_SIZE = 1024;
  FFT_BINS = FFT_SIZE div 2;

  EQ_FREQ: array[0..EQ_BANDS-1] of Double = (
    100, 250, 500, 1000, 2000, 4000, 8000, 16000);
  EQ_Q: array[0..EQ_BANDS-1] of Double = (
    1.0, 1.0, 1.2, 1.2, 1.4, 1.4, 1.4, 1.4);

type
  TWaveformSnapshot = array[0..WAVEFORM_POINTS - 1] of Single;
  TFFTSnapshot = array[0..FFT_BINS - 1] of Single;
  TFFTInputBuffer = array[0..FFT_SIZE - 1] of Single;
  TFFTComplexBuffer = array[0..FFT_BINS] of GstFFTF32Complex;
  TSingleArray = array[0..MaxInt div SizeOf(Single) - 1] of Single;
  PSingleArray = ^TSingleArray;

  TBiquadCoeffs = record
    b0, b1, b2 : Double;
    a1, a2     : Double;
  end;

  TBiquadState = record
    x1, x2 : Double;
    y1, y2 : Double;
  end;

  TEQBand = record
    Coeffs   : TBiquadCoeffs;
    State    : array[0..7] of TBiquadState;
    GainDB   : Double;
  end;
  TBands = array[0..EQ_BANDS-1] of TEQBand;

  TEqualizerFilter = class(TGstAudioSimpleFilter)
  private
    FLockBands : TCriticalSection;
    FBands     : TBands;
    FEnabled   : Boolean;
    FSampleRate: Integer;
    procedure CalcPeakingEQ(var ACoeffs: TBiquadCoeffs;
      AFreq, AGainDB, AQ: Double; ASampleRate: Integer);
    function ProcessBiquad(var AState: TBiquadState;
      const ACoeffs: TBiquadCoeffs; AInput: Double): Double; inline;
  protected
    function GetSinkCaps: string; override;
    procedure OnAudioInfoChanged(const AInfo: GstAudioInfo); override;
    function ProcessAudio(const AMapIn: GstMapInfo;
      var AMapOut: GstMapInfo;
      const AInfo: GstAudioInfo): Boolean; override;
  public
    constructor Create(AFramework: TGstFramework);
    destructor Destroy; override;
    procedure SetBandGain(ABand: Integer; AGainDB: Double);
    procedure SetEnabled(AEnabled: Boolean);
  end;

  TAnalyzerTapFilter = class(TGstAudioSimpleFilter)
  protected
    function GetSinkCaps: string; override;
    function ProcessAudio(const AMapIn: GstMapInfo;
      var AMapOut: GstMapInfo;
      const AInfo: GstAudioInfo): Boolean; override;
  end;

  TWaveformTapFilter = class(TAnalyzerTapFilter)
  private
    FLock     : TCriticalSection;
    FRingBuf  : TWaveformSnapshot;
    FWritePos : Integer;
  protected
    function ProcessAudio(const AMapIn: GstMapInfo;
      var AMapOut: GstMapInfo;
      const AInfo: GstAudioInfo): Boolean; override;
  public
    constructor Create(AFramework: TGstFramework);
    destructor Destroy; override;
    procedure GetSnapshot(out ASnapshot: TWaveformSnapshot);
  end;

  TFFTAnalyzerFilter = class(TAnalyzerTapFilter)
  private
    FLock      : TCriticalSection;
    FFFT       : PGstFFTF32;
    FTimeData  : TFFTInputBuffer;
    FFreqData  : TFFTComplexBuffer;
    FSpectrum  : TFFTSnapshot;
    FFillPos   : Integer;
    FSampleRate: Integer;
    procedure ComputeFFT;
  protected
    procedure OnAudioInfoChanged(const AInfo: GstAudioInfo); override;
    function ProcessAudio(const AMapIn: GstMapInfo;
      var AMapOut: GstMapInfo;
      const AInfo: GstAudioInfo): Boolean; override;
  public
    constructor Create(AFramework: TGstFramework);
    destructor Destroy; override;
    procedure GetSnapshot(out ASnapshot: TFFTSnapshot);
  end;

implementation

constructor TEqualizerFilter.Create(AFramework: TGstFramework);
var
  I: Integer;
begin
  inherited Create(AFramework);
  FLockBands  := TCriticalSection.Create;
  FEnabled    := True;
  FSampleRate := 44100;

  for I := 0 to EQ_BANDS - 1 do
  begin
    FBands[I].GainDB := 0.0;
    FillChar(FBands[I].State, SizeOf(FBands[I].State), 0);
    CalcPeakingEQ(FBands[I].Coeffs,
      EQ_FREQ[I], 0.0, EQ_Q[I], FSampleRate);
  end;
end;

destructor TEqualizerFilter.Destroy;
begin
  FreeAndNil(FLockBands);
  inherited;
end;

function TEqualizerFilter.GetSinkCaps: string;
begin
  Result := 'audio/x-raw,format=F32LE,layout=interleaved';
end;

procedure TEqualizerFilter.OnAudioInfoChanged(const AInfo: GstAudioInfo);
var
  I: Integer;
begin
  FLockBands.Acquire;
  try
    FSampleRate := AInfo.rate;
    for I := 0 to EQ_BANDS - 1 do
      CalcPeakingEQ(FBands[I].Coeffs,
        EQ_FREQ[I], FBands[I].GainDB, EQ_Q[I], FSampleRate);
    for I := 0 to EQ_BANDS - 1 do
      FillChar(FBands[I].State, SizeOf(FBands[I].State), 0);
  finally
    FLockBands.Release;
  end;
end;

procedure TEqualizerFilter.SetBandGain(ABand: Integer; AGainDB: Double);
begin
  if (ABand < 0) or (ABand >= EQ_BANDS) then Exit;
  FLockBands.Acquire;
  try
    FBands[ABand].GainDB := AGainDB;
    CalcPeakingEQ(FBands[ABand].Coeffs,
      EQ_FREQ[ABand], AGainDB, EQ_Q[ABand], FSampleRate);
    FillChar(FBands[ABand].State, SizeOf(FBands[ABand].State), 0);
  finally
    FLockBands.Release;
  end;
end;

procedure TEqualizerFilter.SetEnabled(AEnabled: Boolean);
begin
  FLockBands.Acquire;
  try
    FEnabled := AEnabled;
  finally
    FLockBands.Release;
  end;
end;

procedure TEqualizerFilter.CalcPeakingEQ(var ACoeffs: TBiquadCoeffs;
  AFreq, AGainDB, AQ: Double; ASampleRate: Integer);
var
  A, W0, Alpha, CosW0, a0: Double;
begin
  A     := Power(10.0, AGainDB / 40.0);
  W0    := 2.0 * Pi * AFreq / ASampleRate;
  Alpha := Sin(W0) / (2.0 * AQ);
  CosW0 := Cos(W0);
  a0 := 1.0 + Alpha / A;

  ACoeffs.b0 := (1.0 + Alpha * A) / a0;
  ACoeffs.b1 := (-2.0 * CosW0)    / a0;
  ACoeffs.b2 := (1.0 - Alpha * A) / a0;
  ACoeffs.a1 := (-2.0 * CosW0)    / a0;
  ACoeffs.a2 := (1.0 - Alpha / A) / a0;
end;

function TEqualizerFilter.ProcessBiquad(var AState: TBiquadState;
  const ACoeffs: TBiquadCoeffs; AInput: Double): Double;
var
  Y: Double;
begin
  Y := ACoeffs.b0 * AInput
     + ACoeffs.b1 * AState.x1
     + ACoeffs.b2 * AState.x2
     - ACoeffs.a1 * AState.y1
     - ACoeffs.a2 * AState.y2;

  AState.x2 := AState.x1;
  AState.x1 := AInput;
  AState.y2 := AState.y1;
  AState.y1 := Y;

  Result := Y;
end;

function TEqualizerFilter.ProcessAudio(const AMapIn: GstMapInfo;
  var AMapOut: GstMapInfo; const AInfo: GstAudioInfo): Boolean;
var
  PSrc      : PSingleArray;
  PDst      : PSingleArray;
  LTotal    : Integer;
  I, LBand  : Integer;
  LCh       : Integer;
  LSample   : Double;
  LEnabled  : Boolean;
  LBands    : TBands;
begin
  Result := True;

  if (AInfo.channels <= 0) or (AInfo.channels > Length(FBands[0].State)) then
  begin
    Move(AMapIn.data^, AMapOut.data^, AMapIn.size);
    Exit;
  end;

  PSrc   := PSingleArray(AMapIn.data);
  PDst   := PSingleArray(AMapOut.data);
  LTotal := Integer(AMapIn.size) div SizeOf(Single);

  FLockBands.Acquire;
  try
    LEnabled := FEnabled;
    if LEnabled then
      LBands := FBands;
  finally
    FLockBands.Release;
  end;

  if not LEnabled then
  begin
    Move(AMapIn.data^, AMapOut.data^, AMapIn.size);
    Exit;
  end;

  for I := 0 to LTotal - 1 do
  begin
    LCh := I mod AInfo.channels;
    LSample := PSrc[I];
    for LBand := 0 to EQ_BANDS - 1 do
      LSample := ProcessBiquad(LBands[LBand].State[LCh],
        LBands[LBand].Coeffs, LSample);
    PDst[I] := Single(Max(-1.0, Min(1.0, LSample)));
  end;

  FLockBands.Acquire;
  try
    if FEnabled then
      FBands := LBands;
  finally
    FLockBands.Release;
  end;
end;

function TAnalyzerTapFilter.GetSinkCaps: string;
begin
  Result := 'audio/x-raw,format=F32LE,layout=interleaved';
end;

function TAnalyzerTapFilter.ProcessAudio(const AMapIn: GstMapInfo;
  var AMapOut: GstMapInfo; const AInfo: GstAudioInfo): Boolean;
begin
  Result := (AMapIn.data <> nil) and (AMapOut.data <> nil) and
    (AMapOut.size >= AMapIn.size);
  if Result then
    Move(AMapIn.data^, AMapOut.data^, AMapIn.size);
end;

constructor TWaveformTapFilter.Create(AFramework: TGstFramework);
begin
  inherited Create(AFramework);
  FLock := TCriticalSection.Create;
  FWritePos := 0;
  FillChar(FRingBuf, SizeOf(FRingBuf), 0);
end;

destructor TWaveformTapFilter.Destroy;
begin
  FreeAndNil(FLock);
  inherited;
end;

function TWaveformTapFilter.ProcessAudio(const AMapIn: GstMapInfo;
  var AMapOut: GstMapInfo; const AInfo: GstAudioInfo): Boolean;
var
  PSrc     : PSingleArray;
  LFrames  : Integer;
  LFrame   : Integer;
  LChannels: Integer;
begin
  Result := inherited ProcessAudio(AMapIn, AMapOut, AInfo);
  if not Result then
    Exit;

  if (AMapIn.data = nil) or (AInfo.channels <= 0) then
    Exit;

  LChannels := AInfo.channels;
  LFrames := Integer(AMapIn.size) div SizeOf(Single) div LChannels;
  if LFrames <= 0 then
    Exit;

  PSrc := PSingleArray(AMapIn.data);
  FLock.Acquire;
  try
    for LFrame := 0 to LFrames - 1 do
    begin
      FRingBuf[FWritePos] := PSrc[LFrame * LChannels];
      FWritePos := (FWritePos + 1) mod WAVEFORM_POINTS;
    end;
  finally
    FLock.Release;
  end;
end;

procedure TWaveformTapFilter.GetSnapshot(out ASnapshot: TWaveformSnapshot);
var
  LStart : Integer;
  I      : Integer;
begin
  FLock.Acquire;
  try
    LStart := FWritePos;
    for I := 0 to WAVEFORM_POINTS - 1 do
      ASnapshot[I] := FRingBuf[(LStart + I) mod WAVEFORM_POINTS];
  finally
    FLock.Release;
  end;
end;

constructor TFFTAnalyzerFilter.Create(AFramework: TGstFramework);
begin
  inherited Create(AFramework);
  FLock := TCriticalSection.Create;
  FFillPos := 0;
  FSampleRate := 44100;
  FillChar(FTimeData, SizeOf(FTimeData), 0);
  FillChar(FFreqData, SizeOf(FFreqData), 0);
  FillChar(FSpectrum, SizeOf(FSpectrum), 0);

  if G2D_LoadGstFFT then
    FFFT := _gst_fft_f32_new(FFT_SIZE, GFALSE)
  else
  begin
    FFFT := nil;
    LogWriteln('Failed to load gstfft-1.0-0.dll; FFT analyzer disabled');
  end;
end;

destructor TFFTAnalyzerFilter.Destroy;
begin
  Shutdown;
  if Assigned(FFFT) then
  begin
    _gst_fft_f32_free(FFFT);
    FFFT := nil;
  end;
  FreeAndNil(FLock);
  inherited;
end;

procedure TFFTAnalyzerFilter.OnAudioInfoChanged(const AInfo: GstAudioInfo);
begin
  inherited OnAudioInfoChanged(AInfo);
  if AInfo.rate > 0 then
    FSampleRate := AInfo.rate;
end;

procedure TFFTAnalyzerFilter.ComputeFFT;
var
  I      : Integer;
  LMag   : Double;
  LDB    : Double;
  LLocal : TFFTSnapshot;
begin
  if not Assigned(FFFT) then
    Exit;

  _gst_fft_f32_window(FFFT, @FTimeData[0], GST_FFT_WINDOW_HANN);
  _gst_fft_f32_fft(FFFT, @FTimeData[0], @FFreqData[0]);

  for I := 0 to FFT_BINS - 1 do
  begin
    LMag := Sqrt(Sqr(FFreqData[I].r) + Sqr(FFreqData[I].i)) / FFT_SIZE;
    if LMag < 0.000001 then
      LDB := -120.0
    else
      LDB := 20.0 * Log10(LMag);
    LLocal[I] := Single(Max(-120.0, Min(0.0, LDB)));
  end;

  FLock.Acquire;
  try
    FSpectrum := LLocal;
  finally
    FLock.Release;
  end;
end;

function TFFTAnalyzerFilter.ProcessAudio(const AMapIn: GstMapInfo;
  var AMapOut: GstMapInfo; const AInfo: GstAudioInfo): Boolean;
var
  PSrc     : PSingleArray;
  LFrames  : Integer;
  LFrame   : Integer;
  LChannels: Integer;
begin
  Result := inherited ProcessAudio(AMapIn, AMapOut, AInfo);
  if not Result then
    Exit;

  if (AMapIn.data = nil) or (AInfo.channels <= 0) then
    Exit;

  LChannels := AInfo.channels;
  LFrames := Integer(AMapIn.size) div SizeOf(Single) div LChannels;
  if LFrames <= 0 then
    Exit;

  PSrc := PSingleArray(AMapIn.data);
  for LFrame := 0 to LFrames - 1 do
  begin
    FTimeData[FFillPos] := PSrc[LFrame * LChannels];
    Inc(FFillPos);
    if FFillPos >= FFT_SIZE then
    begin
      ComputeFFT;
      FFillPos := 0;
    end;
  end;
end;

procedure TFFTAnalyzerFilter.GetSnapshot(out ASnapshot: TFFTSnapshot);
begin
  FLock.Acquire;
  try
    ASnapshot := FSpectrum;
  finally
    FLock.Release;
  end;
end;

end.

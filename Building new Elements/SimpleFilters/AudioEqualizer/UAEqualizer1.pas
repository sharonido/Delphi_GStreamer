unit UAEqualizer1;

{------------------------------------------------------------------------------
  PG2DExampleAudioEqualizer
  8-band audio equalizer using biquad IIR filters via TGstAudioSimple.

  Pipeline:
    uridecodebin --> audioconvert --> audioresample -->
    appsink --> [ProcessAudio/EQ] --> appsrc -->
    audioconvert --> autoaudiosink

  Each of the 8 bands uses a peaking EQ biquad filter:
    Band 1:  100 Hz
    Band 2:  250 Hz
    Band 3:  500 Hz
    Band 4: 1000 Hz
    Band 5: 2000 Hz
    Band 6: 4000 Hz
    Band 7: 8000 Hz
    Band 8: 16000 Hz

  Gain range: -10dB to +10dB per band.
  Format: F32LE (32-bit float, interleaved) for clean floating-point DSP.
  ToggleSwitch1 (starts On) bypasses the EQ when Off.
------------------------------------------------------------------------------}

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.SyncObjs,
  System.Math,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.WinXCtrls,
  g2d.Glib.Types,
  G2D.Gst.Types,
  G2D.GstFramework,
  G2D.GstElement.DOO,
  G2D.CustomSimpleAudioElement,
  G2D.Gst.API,
  Vcl.Mask;

const
  EQ_BANDS = 8;
  { Centre frequencies for each band in Hz }
  EQ_FREQ: array[0..EQ_BANDS-1] of Double = (
    100, 250, 500, 1000, 2000, 4000, 8000, 16000);
  { Bandwidth (Q factor) for each band - wider at low freqs }
  EQ_Q: array[0..EQ_BANDS-1] of Double = (
    1.0, 1.0, 1.2, 1.2, 1.4, 1.4, 1.4, 1.4);

type

{------------------------------------------------------------------------------
  TBiquadCoeffs
  Coefficients for a single biquad IIR filter section.
  Direct Form I: y[n] = b0*x[n] + b1*x[n-1] + b2*x[n-2]
                       - a1*y[n-1] - a2*y[n-2]
------------------------------------------------------------------------------}
  TBiquadCoeffs = record
    b0, b1, b2 : Double;
    a1, a2     : Double;
  end;

{------------------------------------------------------------------------------
  TBiquadState
  Per-channel delay state for one biquad section.
------------------------------------------------------------------------------}
  TBiquadState = record
    x1, x2 : Double;  { input  delays }
    y1, y2 : Double;  { output delays }
  end;

{------------------------------------------------------------------------------
  TEQBand
  One EQ band: coefficients (shared across channels) + per-channel state.
------------------------------------------------------------------------------}
  TEQBand = record
    Coeffs   : TBiquadCoeffs;
    State    : array[0..7] of TBiquadState;  { up to 8 channels }
    GainDB   : Double;
  end;
  TBands      = array[0..EQ_BANDS-1] of TEQBand;
  TSingleArray = array[0..MaxInt div SizeOf(Single) - 1] of Single;
  PSingleArray = ^TSingleArray;
{------------------------------------------------------------------------------
  TEqualizerFilter
  8-band peaking EQ audio filter. Thread-safe gain updates via FLockBands.
------------------------------------------------------------------------------}
  TEqualizerFilter = class(TGstAudioSimple)
  private
    FLockBands : TCriticalSection;
    FBands     : TBands;
    FEnabled   : Boolean;
    FSampleRate: Integer;

    { Compute peaking EQ biquad coefficients for given params }
    procedure CalcPeakingEQ(var ACoeffs: TBiquadCoeffs;
      AFreq, AGainDB, AQ: Double; ASampleRate: Integer);

    { Process one sample through one biquad section }
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

    { Call from main thread to update band gain and recompute coefficients }
    procedure SetBandGain(ABand: Integer; AGainDB: Double);
    procedure SetEnabled(AEnabled: Boolean);
  end;

{------------------------------------------------------------------------------
  TForm1
------------------------------------------------------------------------------}
  TForm1 = class(TForm)
    Panel4        : TPanel;
    Panel5        : TPanel;
    Panel6        : TPanel;
    Label3        : TLabel;
    Panel8        : TPanel;
    Label4        : TLabel;
    Label5        : TLabel;
    TrackBar1     : TTrackBar;
    Panel9        : TPanel;
    Label6        : TLabel;
    Label7        : TLabel;
    TrackBar2     : TTrackBar;
    Panel10       : TPanel;
    Label8        : TLabel;
    Label9        : TLabel;
    TrackBar3     : TTrackBar;
    Panel11       : TPanel;
    Label10       : TLabel;
    Label11       : TLabel;
    TrackBar4     : TTrackBar;
    Panel12       : TPanel;
    Label12       : TLabel;
    Label13       : TLabel;
    TrackBar5     : TTrackBar;
    Panel13       : TPanel;
    Label14       : TLabel;
    Label15       : TLabel;
    TrackBar6     : TTrackBar;
    Panel14       : TPanel;
    Label16       : TLabel;
    Label17       : TLabel;
    TrackBar7     : TTrackBar;
    Panel16       : TPanel;
    Label18       : TLabel;
    Label19       : TLabel;
    TrackBar8     : TTrackBar;
    Panel1        : TPanel;
    Splitter2     : TSplitter;
    Panel2        : TPanel;
    Label1        : TLabel;
    RichEdit1     : TRichEdit;
    Panel3        : TPanel;
    logger        : TRichEdit;
    Panel7        : TPanel;
    Panel15       : TPanel;
    Label2        : TLabel;
    LabeledEdit1  : TLabeledEdit;
    Button1       : TButton;
    ToggleSwitch1 : TToggleSwitch;
    Button2       : TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure TrackBarChange(Sender: TObject);
    procedure ToggleSwitch1Click(Sender: TObject);
  private
    FGStreamer   : TGstFramework;
    FFilter      : TEqualizerFilter;
    FOpenDialog  : TOpenDialog;

    { Map trackbar index (0..7) to its dB label }
    function GetDBLabel(AIndex: Integer): TLabel;
    { Map trackbar index (0..7) to its TrackBar }
    function GetTrackBar(AIndex: Integer): TTrackBar;
    procedure InitTrackBars;
    procedure BuildPipeline(const AURI: string);
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  System.StrUtils;

{ ============================================================================
  TEqualizerFilter
  ============================================================================ }

constructor TEqualizerFilter.Create(AFramework: TGstFramework);
var
  I: Integer;
begin
  inherited Create(AFramework);
  FLockBands  := TCriticalSection.Create;
  FEnabled    := True;
  FSampleRate := 44100;  { default until OnAudioInfoChanged fires }

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
  { F32LE: 32-bit float, interleaved, stereo, 44100Hz
    Float arithmetic avoids integer overflow in the biquad math. }
  Result := 'audio/x-raw,format=F32LE,rate=44100,channels=2,layout=interleaved';
end;

procedure TEqualizerFilter.OnAudioInfoChanged(const AInfo: GstAudioInfo);
var
  I: Integer;
begin
  FLockBands.Acquire;
  try
    FSampleRate := AInfo.rate;
    { Recompute all coefficients for the new sample rate }
    for I := 0 to EQ_BANDS - 1 do
      CalcPeakingEQ(FBands[I].Coeffs,
        EQ_FREQ[I], FBands[I].GainDB, EQ_Q[I], FSampleRate);
    { Reset all delay states to avoid transients }
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
    { Reset delay state for this band to avoid transient on gain change }
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
  A, W0, Alpha, CosW0: Double;
begin
  { Peaking EQ biquad coefficients - Audio EQ Cookbook (R. Bristow-Johnson) }
  A     := Power(10.0, AGainDB / 40.0);
  W0    := 2.0 * Pi * AFreq / ASampleRate;
  Alpha := Sin(W0) / (2.0 * AQ);
  CosW0 := Cos(W0);

  { Normalise by a0 = 1 + alpha/A }
  var a0 := 1.0 + Alpha / A;

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

  PSrc   := PSingleArray(AMapIn.data);
  PDst   := PSingleArray(AMapOut.data);
  LTotal := Integer(AMapIn.size) div SizeOf(Single);

  { Snapshot bands and enabled flag under lock }
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
    { Bypass: copy input unchanged }
    Move(AMapIn.data^, AMapOut.data^, AMapIn.size);
    Exit;
  end;

  { Process each sample through all 8 bands in series.
    Samples are interleaved: [L0, R0, L1, R1, ...]
    Channel index = sample_index mod channels }
  for I := 0 to LTotal - 1 do
  begin
    LCh     := I mod AInfo.channels;
    LSample := PSrc[I];

    for LBand := 0 to EQ_BANDS - 1 do
      LSample := ProcessBiquad(LBands[LBand].State[LCh],
                               LBands[LBand].Coeffs, LSample);

    { Clamp to [-1, 1] to prevent clipping }
    PDst[I] := Single(Max(-1.0, Min(1.0, LSample)));
  end;

  { Write back updated state under lock }
  FLockBands.Acquire;
  try
    if FEnabled then
      FBands := LBands;
  finally
    FLockBands.Release;
  end;
end;

{ ============================================================================
  TForm1
  ============================================================================ }

function TForm1.GetDBLabel(AIndex: Integer): TLabel;
begin
  { Map band index (0=100Hz..7=16KHz) to its dB label
    Visual order: TB1(100) TB7(250) TB6(500) TB5(1K) TB4(2K) TB3(4K) TB8(8K) TB2(8K+) }
  case AIndex of
    0: Result := Label5;
    1: Result := Label17;
    2: Result := Label15;
    3: Result := Label13;
    4: Result := Label11;
    5: Result := Label9;
    6: Result := Label19;
    7: Result := Label7;
  else
    Result := nil;
  end;
end;

function TForm1.GetTrackBar(AIndex: Integer): TTrackBar;
begin
  case AIndex of
    0: Result := TrackBar1;
    1: Result := TrackBar7;
    2: Result := TrackBar6;
    3: Result := TrackBar5;
    4: Result := TrackBar4;
    5: Result := TrackBar3;
    6: Result := TrackBar8;
    7: Result := TrackBar2;
  else
    Result := nil;
  end;
end;

procedure TForm1.InitTrackBars;
var
  I  : Integer;
  LB : TLabel;
begin
  for I := 0 to EQ_BANDS - 1 do
  begin
    { Wire OnChange to shared handler }
    GetTrackBar(I).OnChange := TrackBarChange;
    GetTrackBar(I).Tag      := I;
    GetTrackBar(I).Position := 0;

    LB := GetDBLabel(I);
    if Assigned(LB) then
      LB.Caption := '  0 dB';
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FGStreamer := TGstFramework.Create(True);
  FGStreamer.StringsLogger := logger.Lines;

  FOpenDialog := TOpenDialog.Create(Self);
  FOpenDialog.Filter :=
    'Audio files|*.mp3;*.wav;*.ogg;*.flac;*.aac;*.m4a;*.webm|All files|*.*';

  InitTrackBars;

  if not FGStreamer.Started then
  begin
    LogWriteln('GStreamer failed to start');
    Exit;
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FFilter);
  FreeAndNil(FGStreamer);
end;

procedure TForm1.BuildPipeline(const AURI: string);
var
  I: Integer;
begin
  { Tear down any existing pipeline }
  if Assigned(FFilter) then
    FreeAndNil(FFilter);
  FGStreamer.Null;
  FGStreamer.Close;

  if not FGStreamer.NewPipeline('eq1') then
  begin
    LogWriteln('Failed to create pipeline');
    Exit;
  end;

  { STEP 2 - filter inserted as passthrough (EQ disabled) }
  FGStreamer.MakeElements(
    'uridecodebin name=source !' +
    'audioconvert name=convert !' +
    'audioresample name=resample !' +
    'audioconvert name=convert2 !' +
    'autoaudiosink name=sink');

  FGStreamer.SetElementPropertyString('source', 'uri', AURI);

  FFilter := TEqualizerFilter.Create(FGStreamer);
  { Partial caps on appsrc - format only, no rate/channels.
    convert2 negotiates rate/channels with autoaudiosink at runtime. }
  FFilter.SrcElement.SetCaps(
    _gst_caps_from_string(Pgchar(pansichar('audio/x-raw,format=F32LE,layout=interleaved'))));
  FFilter.SetEnabled(False);  { passthrough for now }

  FGStreamer.AddElements(['source', 'convert', 'resample', 'convert2', 'sink']);

  if not FGStreamer.LinkElements('convert', 'resample') then
  begin
    LogWriteln('Failed to link convert -> resample');
    Exit;
  end;

  FFilter.AddAndLink('resample', 'convert2');

  if not FGStreamer.LinkElements('convert2', 'sink') then
  begin
    LogWriteln('Failed to link convert2 -> sink');
    Exit;
  end;

  if not FGStreamer.ConnectDynamicPad('source', 'convert', 'sink') then
  begin
    LogWriteln('Failed to connect dynamic pad');
    Exit;
  end;

  { Apply current trackbar gains }
  for I := 0 to EQ_BANDS - 1 do
    FFilter.SetBandGain(I, GetTrackBar(I).Position);

  if not FGStreamer.Play then
    LogWriteln('Failed to set pipeline to PLAYING');
end;
procedure TForm1.Button1Click(Sender: TObject);
begin
  if FOpenDialog.Execute then
    LabeledEdit1.Text := FOpenDialog.FileName;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  LURI: string;
begin
  LURI := Trim(LabeledEdit1.Text);
  if LURI = '' then
  begin
    LogWriteln('No source specified');
    Exit;
  end;

  { Convert local file path to URI }
  if not LURI.StartsWith('http') and not LURI.StartsWith('file://') then
    LURI := 'file:///' +
      StringReplace(ExpandFileName(LURI), '\', '/', [rfReplaceAll]);

  BuildPipeline(LURI);
end;

procedure TForm1.TrackBarChange(Sender: TObject);
var
  LTB    : TTrackBar;
  LBand  : Integer;
  LGain  : Integer;
  LLabel : TLabel;
begin
  LTB   := Sender as TTrackBar;
  LBand := LTB.Tag;
  LGain := LTB.Position;

  LLabel := GetDBLabel(LBand);
  if Assigned(LLabel) then
    LLabel.Caption := Format('%+3d dB', [LGain]);

  if Assigned(FFilter) then
    FFilter.SetBandGain(LBand, LGain);
end;

procedure TForm1.ToggleSwitch1Click(Sender: TObject);
begin
  if Assigned(FFilter) then
    FFilter.SetEnabled(ToggleSwitch1.State = tssOn);
end;

end.

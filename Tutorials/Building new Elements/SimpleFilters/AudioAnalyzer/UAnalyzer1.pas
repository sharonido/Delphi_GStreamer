unit UAnalyzer1;

{------------------------------------------------------------------------------
  PG2DExampleAudioEqualizer
  8-band audio equalizer using biquad IIR filters via TGstAudioSimpleFilter.

  Pipeline:
    uridecodebin --> TGstAudioSimpleFilter --> autoaudiosink

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
  Winapi.Windows, System.SysUtils, System.Classes, System.Math,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.WinXCtrls, Vcl.Graphics,
  VCLTee.Chart, VCLTee.Series, VCLTee.TeEngine, VCLTee.TeeProcs, Vcl.Mask,
  G2D.GstFramework,
  UAnalyzerFilters;


type
{------------------------------------------------------------------------------
  TForm1
------------------------------------------------------------------------------}
  TForm1 = class(TForm)
    Panel4        : TPanel;
    Panel5        : TPanel;
    Panel6        : TPanel;
    Chart1        : TChart;
    Series1       : TFastLineSeries;
    Chart2        : TChart;
    Series2       : TBarSeries;
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
    Splitter3     : TSplitter;
    Panel2        : TPanel;
    Label1        : TLabel;
    RichEdit1     : TRichEdit;
    Panel3        : TPanel;
    logger        : TRichEdit;
    Panel15       : TPanel;
    Label2        : TLabel;
    LabeledEdit1  : TLabeledEdit;
    Button1       : TButton;
    ToggleSwitch1 : TToggleSwitch;
    Button2       : TButton;
    Splitter1: TSplitter;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure TrackBarChange(Sender: TObject);
    procedure ToggleSwitch1Click(Sender: TObject);
  private
    FGStreamer   : TGstFramework;
    FEQFilter    : TEqualizerFilter;
    FWaveFilter  : TWaveformTapFilter;
    FFFTFilter   : TFFTAnalyzerFilter;
    FOpenDialog  : TOpenDialog;
    FWaveTimer   : TTimer;

    { Map trackbar index (0..7) to its dB label }
    function GetDBLabel(AIndex: Integer): TLabel;
    { Map trackbar index (0..7) to its TrackBar }
    function GetTrackBar(AIndex: Integer): TTrackBar;
    procedure InitTrackBars;
    procedure BuildPipeline(const AURI: string);
    procedure ShutdownFilters;
    procedure WaveTimerTick(Sender: TObject);
    procedure StartDefaultMedia;
    function FFTBinToKHz(ABin: Integer): Double;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  System.StrUtils;

function TForm1.FFTBinToKHz(ABin: Integer): Double;
begin
  Result := ABin * 44.1 / FFT_SIZE;
  if Assigned(FFFTFilter) and (FFFTFilter.AudioInfo.rate > 0) then
    Result := ABin * FFFTFilter.AudioInfo.rate / FFT_SIZE / 1000.0;
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
  LogWriteln(FGStreamer.Version);

  FOpenDialog := TOpenDialog.Create(Self);
  FOpenDialog.Filter :=
    'Audio files|*.mp3;*.wav;*.ogg;*.flac;*.aac;*.m4a;*.webm|All files|*.*';

  Chart1.View3D := False;
  Chart1.Legend.Visible := False;
  Chart1.LeftAxis.SetMinMax(-1, 1);
  Chart2.View3D := False;
  Chart2.Legend.Visible := False;
  Chart2.LeftAxis.SetMinMax(-120, 0);
  Series2.SeriesColor := clLime;
  Series2.UseYOrigin := True;
  Series2.YOrigin := -120;
  Series2.Pen.Visible := False;

  FWaveTimer := TTimer.Create(Self);
  FWaveTimer.Interval := 50;
  FWaveTimer.OnTimer  := WaveTimerTick;
  FWaveTimer.Enabled  := False;

  InitTrackBars;

  if not FGStreamer.Started then
  begin
    LogWriteln('GStreamer failed to start');
    Exit;
  end;

  StartDefaultMedia;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  TGstFramework.StringsLogger := nil;
  ShutdownFilters;
  if Assigned(FGStreamer) then
    FGStreamer.Close;
  { App shutdown can still race a final streaming callback. Let process exit
    reclaim the filter wrappers instead of freeing them synchronously here. }
  FFFTFilter := nil;
  FWaveFilter := nil;
  FEQFilter := nil;
  FreeAndNil(FGStreamer);
end;

procedure TForm1.BuildPipeline(const AURI: string);
begin
  FWaveTimer.Enabled := False;
  Series1.Clear;
  ShutdownFilters;
  FreeAndNil(FFFTFilter);
  FreeAndNil(FWaveFilter);
  FreeAndNil(FEQFilter);
  FGStreamer.Close;

  if not FGStreamer.NewPipeline('analyzer1') then
  begin
    LogWriteln('Failed to create pipeline');
    Exit;
  end;

  FGStreamer.PipeLine.MakeElements(
    'uridecodebin name=source !' +
    'autoaudiosink name=sink');

  FGStreamer.SetElementPropertyString('source', 'uri', AURI);

  FEQFilter := TEqualizerFilter.Create(FGStreamer);
  FEQFilter.SetEnabled(ToggleSwitch1.State = tssOn);
  FEQFilter.AddToPipeline;

  FWaveFilter := TWaveformTapFilter.Create(FGStreamer);
  FWaveFilter.AddToPipeline;

  FFFTFilter := TFFTAnalyzerFilter.Create(FGStreamer);
  FFFTFilter.AddToPipeline;

  FGStreamer.AddElements(['source', 'sink']);

  if not FGStreamer.LinkElements(FEQFilter.BinName, FWaveFilter.BinName) then
  begin
    LogWriteln('Failed to link equalizer -> waveform filter');
    Exit;
  end;

  if not FGStreamer.LinkElements(FWaveFilter.BinName, FFFTFilter.BinName) then
  begin
    LogWriteln('Failed to link waveform filter -> FFT analyzer');
    Exit;
  end;

  if not FGStreamer.LinkElements(FFFTFilter.BinName, 'sink') then
  begin
    LogWriteln('Failed to link FFT analyzer -> autoaudiosink');
    Exit;
  end;
  LogWriteln('equalizer -> waveform filter -> FFT analyzer -> autoaudiosink linked');

  if not FGStreamer.ConnectDynamicPad('source', FEQFilter.BinName, 'sink') then
  begin
    LogWriteln('Failed to connect dynamic pad to equalizer');
    Exit;
  end;

  if not FGStreamer.Play then
    LogWriteln('Failed to set pipeline to PLAYING');

  FWaveTimer.Enabled := True;
end;

procedure TForm1.ShutdownFilters;
begin
  { Step 1: stop all appsink callbacks and unblock any appsrc push.
    Must happen before pipeline Null or push_buffer can deadlock. }
  if Assigned(FEQFilter) then
    FEQFilter.Shutdown;
  if Assigned(FWaveFilter) then
    FWaveFilter.Shutdown;
  if Assigned(FFFTFilter) then
    FFFTFilter.Shutdown;

  { Step 2: now it is safe to stop the pipeline }
  if Assigned(FGStreamer) then
    FGStreamer.Null;
  FWaveTimer.Enabled := False;
end;

procedure TForm1.WaveTimerTick(Sender: TObject);
var
  LSnapshot : TWaveformSnapshot;
  LFFT      : TFFTSnapshot;
  I         : Integer;
  LVal      : Double;
begin
  if not Assigned(FWaveFilter) then
    Exit;

  FWaveFilter.GetSnapshot(LSnapshot);

  Series1.BeginUpdate;
  try
    Series1.Clear;
    for I := 0 to WAVEFORM_POINTS - 1 do
    begin
      LVal := LSnapshot[I];
      { Guard against NaN/Infinity which crash TChart axis scaling }
      if IsNan(LVal) or IsInfinite(LVal) then
        LVal := 0.0;
      Series1.AddXY(I, LVal);
    end;
  finally
    Series1.EndUpdate;
  end;

  if not Assigned(FFFTFilter) then
    Exit;

  FFFTFilter.GetSnapshot(LFFT);

  Series2.BeginUpdate;
  try
    Series2.Clear;
    for I := 0 to FFT_BINS - 1 do
    begin
      LVal := LFFT[I];
      if IsNan(LVal) or IsInfinite(LVal) then
        LVal := -120.0;
      if LVal > -15.0 then
        Series2.AddXY(FFTBinToKHz(I), LVal, '', clRed)
      else
        Series2.AddXY(FFTBinToKHz(I), LVal, '', clLime);
    end;
  finally
    Series2.EndUpdate;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if FOpenDialog.Execute then
    LabeledEdit1.Text := FOpenDialog.FileName;
end;

procedure TForm1.StartDefaultMedia;
var
  LPath: string;
begin
  LPath := ExpandFileName(ExtractFilePath(ParamStr(0)) +
    '..\..\..\..\..\MediaFiles\test.mp3');
  if not FileExists(LPath) then
    Exit;

  LabeledEdit1.Text := LPath;
  BuildPipeline('file:///' + StringReplace(LPath, '\', '/', [rfReplaceAll]));
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
  LGain := -LTB.Position;

  LLabel := GetDBLabel(LBand);
  if Assigned(LLabel) then
    LLabel.Caption := Format('%3d dB', [LGain]);

  if Assigned(FEQFilter) then
    FEQFilter.SetBandGain(LBand, LGain);
end;

procedure TForm1.ToggleSwitch1Click(Sender: TObject);
begin
  if Assigned(FEQFilter) then
    FEQFilter.SetEnabled(ToggleSwitch1.State = tssOn);
end;

end.

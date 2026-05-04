unit UAudioEqualizerDemo;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  Vcl.WinXCtrls,
  G2D.GstFramework,
  G2D.GstElement.DOO;

type
  TForm1 = class(TForm)
    Panel4: TPanel;
    Panel6: TPanel;
    Label3: TLabel;
    Panel8: TPanel;
    Label4: TLabel;
    Label5: TLabel;
    TrackBar1: TTrackBar;
    Panel9: TPanel;
    Label6: TLabel;
    Label7: TLabel;
    TrackBar2: TTrackBar;
    Panel10: TPanel;
    Label8: TLabel;
    Label9: TLabel;
    TrackBar3: TTrackBar;
    Panel11: TPanel;
    Label10: TLabel;
    Label11: TLabel;
    TrackBar4: TTrackBar;
    Panel12: TPanel;
    Label12: TLabel;
    Label13: TLabel;
    TrackBar5: TTrackBar;
    Panel13: TPanel;
    Label14: TLabel;
    Label15: TLabel;
    TrackBar6: TTrackBar;
    Panel14: TPanel;
    Label16: TLabel;
    Label17: TLabel;
    TrackBar7: TTrackBar;
    Panel16: TPanel;
    Label18: TLabel;
    Label19: TLabel;
    TrackBar8: TTrackBar;
    Panel1: TPanel;
    Splitter2: TSplitter;
    Panel2: TPanel;
    Label1: TLabel;
    RichEdit1: TRichEdit;
    Panel3: TPanel;
    logger: TRichEdit;
    Panel7: TPanel;
    Panel15: TPanel;
    Label2: TLabel;
    LabeledEdit1: TLabeledEdit;
    Button1: TButton;
    ToggleSwitch1: TToggleSwitch;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure TrackBarChange(Sender: TObject);
    procedure ToggleSwitch1Click(Sender: TObject);
  private
    FGStreamer: TGstFramework;
    FEqualizer: TGstElementRef;
    FOpenDialog: TOpenDialog;
    function GetDBLabel(AIndex: Integer): TLabel;
    function GetTrackBar(AIndex: Integer): TTrackBar;
    procedure AddLocalPluginPath;
    procedure InitTrackBars;
    procedure BuildPipeline(const AURI: string);
    procedure StartDefaultMedia;
    procedure SetBandGain(ABand: Integer; AGain: Integer);
    procedure SetFilterEnabled(AEnabled: Boolean);
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

const
  EQ_BANDS = 8;

procedure TForm1.AddLocalPluginPath;
var
  LExePath: string;
  LWin64Path: string;
  LReleasePath: string;
  LPluginPath: string;
  LOldPath: string;
  procedure AddPath(const APath: string);
  begin
    if not DirectoryExists(APath) then
      Exit;

    if LOldPath = '' then
      LOldPath := APath
    else if Pos(UpperCase(APath), UpperCase(LOldPath)) = 0 then
      LOldPath := APath + ';' + LOldPath;
  end;
begin
  LExePath := ExcludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
  LWin64Path := ExcludeTrailingPathDelimiter(ExtractFilePath(LExePath));
  LReleasePath := IncludeTrailingPathDelimiter(LWin64Path) + 'Release';
  LPluginPath := ExcludeTrailingPathDelimiter(ExtractFilePath(LWin64Path));
  LOldPath := GetEnvironmentVariable('GST_PLUGIN_PATH');

  AddPath(LExePath);
  AddPath(LReleasePath);
  AddPath(LPluginPath);

  SetEnvironmentVariable('GST_PLUGIN_PATH', PChar(LOldPath));
end;

function TForm1.GetDBLabel(AIndex: Integer): TLabel;
begin
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
  I: Integer;
  LTrackBar: TTrackBar;
begin
  for I := 0 to EQ_BANDS - 1 do
  begin
    LTrackBar := GetTrackBar(I);
    if LTrackBar = nil then
      Continue;

    LTrackBar.OnChange := TrackBarChange;
    LTrackBar.Tag := I;
    LTrackBar.Min := -30;
    LTrackBar.Max := 30;
    LTrackBar.Position := 0;
    SetBandGain(I, 0);
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  AddLocalPluginPath;

  FGStreamer := TGstFramework.Create(True);
  FGStreamer.StringsLogger := logger.Lines;
  LogWriteln(FGStreamer.Version);
  LogWriteln('AudioEqualizer plugin demo');

  RichEdit1.Lines.Text :=
    'This is part of G2D GStreamer to Delphi (Pascal) project' + sLineBreak +
    'This demo uses the real g2dequalizer plugin DLL.' + sLineBreak +
    'The VCL code only sets GObject properties: band0..band7 and filter.';

  FOpenDialog := TOpenDialog.Create(Self);
  FOpenDialog.Filter :=
    'Audio files|*.mp3;*.wav;*.ogg;*.flac;*.aac;*.m4a;*.webm|All files|*.*';

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
  FreeAndNil(FEqualizer);
  FreeAndNil(FGStreamer);
end;

procedure TForm1.BuildPipeline(const AURI: string);
var
  I: Integer;
begin
  FreeAndNil(FEqualizer);
  FGStreamer.Close;

  if not FGStreamer.NativeBuildAndPlay(
    'uridecodebin name=source uri="' + AURI + '" ! ' +
    'audioconvert ! audioresample ! ' +
    'audio/x-raw,format=F32LE,layout=interleaved ! ' +
    'g2dequalizer name=eq ! audioconvert ! autoaudiosink name=sink') then
  begin
    LogWriteln('Failed to build audio equalizer pipeline');
    Exit;
  end;

  FEqualizer := FGStreamer.FindElement('eq');
  if FEqualizer = nil then
  begin
    LogWriteln('Failed to find g2dequalizer element');
    Exit;
  end;

  SetFilterEnabled(ToggleSwitch1.State = tssOn);
  for I := 0 to EQ_BANDS - 1 do
    SetBandGain(I, -GetTrackBar(I).Position);
end;

procedure TForm1.StartDefaultMedia;
var
  LPath: string;
begin
  LPath := ExpandFileName(ExtractFilePath(ParamStr(0)) +
    '..\..\..\..\..\MediaFiles\test.mp3');
  if not FileExists(LPath) then
  begin
    LogWriteln('Default media not found: ' + LPath);
    Exit;
  end;

  LabeledEdit1.Text := LPath;
  BuildPipeline('file:///' + StringReplace(LPath, '\', '/', [rfReplaceAll]));
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

  if not LURI.StartsWith('http') and not LURI.StartsWith('file://') then
    LURI := 'file:///' +
      StringReplace(ExpandFileName(LURI), '\', '/', [rfReplaceAll]);

  BuildPipeline(LURI);
end;

procedure TForm1.SetBandGain(ABand: Integer; AGain: Integer);
var
  LLabel: TLabel;
begin
  LLabel := GetDBLabel(ABand);
  if LLabel <> nil then
    LLabel.Caption := Format('%3d dB', [AGain]);

  if FEqualizer <> nil then
    FEqualizer.SetPropertyInt(Format('band%d', [ABand]), AGain);
end;

procedure TForm1.SetFilterEnabled(AEnabled: Boolean);
begin
  if FEqualizer <> nil then
    FEqualizer.SetPropertyBool('filter', AEnabled);

  if AEnabled then
    LogWriteln('g2dequalizer filter enabled')
  else
    LogWriteln('g2dequalizer filter bypassed');
end;

procedure TForm1.TrackBarChange(Sender: TObject);
var
  LTrackBar: TTrackBar;
begin
  LTrackBar := Sender as TTrackBar;
  SetBandGain(LTrackBar.Tag, -LTrackBar.Position);
end;

procedure TForm1.ToggleSwitch1Click(Sender: TObject);
begin
  SetFilterEnabled(ToggleSwitch1.State = tssOn);
end;

end.

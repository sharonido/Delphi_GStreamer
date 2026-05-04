unit UVideoRotateDemo;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls,
  Vcl.WinXCtrls, Vcl.Dialogs, Vcl.Graphics,
  G2D.GstFramework,
  G2D.GstElement.DOO;

type
  TForm1 = class(TForm)
    Panel4       : TPanel;
    VideoPanel   : TPanel;
    GroupBox1    : TGroupBox;
    RadioButton1 : TRadioButton;
    RadioButton2 : TRadioButton;
    RadioButton3 : TRadioButton;
    RadioButton4 : TRadioButton;
    RadioButton5 : TRadioButton;
    RadioButton6 : TRadioButton;
    RadioButton7 : TRadioButton;
    RadioButton8 : TRadioButton;
    RadioButton9 : TRadioButton;
    RadioButton10: TRadioButton;
    Panel5       : TPanel;
    LDegree      : TLabel;
    TrackBar1    : TTrackBar;
    Panel1       : TPanel;
    Splitter1    : TSplitter;
    Panel2       : TPanel;
    Label1       : TLabel;
    RichEdit1    : TRichEdit;
    Splitter2    : TSplitter;
    Panel3       : TPanel;
    Label2       : TLabel;
    logger       : TRichEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure RadioButtonClick(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
  private
    FGStreamer: TGstFramework;
    FSrc: TGstElementRef;
    FRotate: TGstElementRef;
    procedure AddLocalPluginPath;
    procedure SetRotateAngle(AAngle: Integer);
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

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

procedure TForm1.SetRotateAngle(AAngle: Integer);
begin
  LDegree.Caption := Format('%4d', [AAngle]) + #176;
  if FRotate <> nil then
    FRotate.SetPropertyInt('rotateangle', AAngle);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  AddLocalPluginPath;

  FGStreamer := TGstFramework.Create(True);
  FGStreamer.StringsLogger := logger.Lines;
  LogWriteln(FGStreamer.Version);
  LogWriteln('VideoRotate plugin demo');

  if not FGStreamer.Started then
  begin
    LogWriteln('GStreamer failed to start');
    Exit;
  end;

  if not FGStreamer.NativeBuildAndPlay(
    'videotestsrc name=src ! videoconvert ! video/x-raw,format=BGRx ! ' +
    'g2drotate name=rotate rotateangle=0 ! videoconvert ! ' +
    'd3d11videosink name=video_sink async=false') then
  begin
    LogWriteln('Failed to build pipeline');
    Exit;
  end;

  FSrc := FGStreamer.FindElement('src');
  if FSrc = nil then
    LogWriteln('Failed to find source element');

  FRotate := FGStreamer.FindElement('rotate');
  if FRotate = nil then
    LogWriteln('Failed to find rotate element');

  FGStreamer.SetVisualWindow('video_sink', VideoPanel.Handle);
  SetRotateAngle(TrackBar1.Position);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FRotate);
  FreeAndNil(FSrc);
  FreeAndNil(FGStreamer);
end;

procedure TForm1.RadioButtonClick(Sender: TObject);
begin
  if FSrc <> nil then
    FSrc.SetPropertyEnum('pattern', (Sender as TRadioButton).Tag);
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
  SetRotateAngle(TrackBar1.Position);
end;

end.

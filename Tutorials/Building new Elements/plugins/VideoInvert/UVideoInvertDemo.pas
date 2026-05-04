unit UVideoInvertDemo;

interface
{$APPTYPE CONSOLE} //use the console for loging events

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  G2D.GstFramework, G2D.Gst.API, G2D.GstElement.DOO,
  Vcl.StdCtrls, Vcl.WinXCtrls;

type
  TForm1 = class(TForm)
    VideoPanel: TPanel;
    Label1: TLabel;
    GroupBox1: TGroupBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    RadioButton5: TRadioButton;
    RadioButton6: TRadioButton;
    RadioButton7: TRadioButton;
    RadioButton8: TRadioButton;
    RadioButton9: TRadioButton;
    RadioButton10: TRadioButton;
    filtertoggle: TToggleSwitch;
    procedure FormCreate(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure filtertoggleClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    procedure AddLocalPluginPath;
  public
    GStreamer: TGstFrameWork;
  end;

var
  Form1: TForm1;
  Src: TGstElementRef;

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

procedure TForm1.FormCreate(Sender: TObject);
begin
AddLocalPluginPath;
GStreamer:=TGstFrameWork.Create(true); //no parameters needed here
LogWriteln(DGstVersionString);
LogWriteln('VideoInvert VCL demo');
LogWriteln(
'This is part of G2D GStreamer to delphi project'+sLineBreak+
'This is a demo using a video filter plugin that inverts colors.'+sLineBreak+
'The video filter plugin code source is in:'+sLineBreak+
'* G2D.Plugin.VideoInvert.pas -> the filter action'+sLineBreak+
'* gstG2Dvideoinvert.dpr -> The regisration of the plugin as a dll');
if GStreamer.Started then
  //build a video test src, the g2dinvert plugin filter, and a video sink
  if not GStreamer.NativeBuildAndPlay(
  'videotestsrc name=src ! videoconvert ! video/x-raw,format=RGB ! ' +
  'g2dinvert filter=true name=invert ! videoconvert ! d3d11videosink name=video_sink')
    then logwriteln('error in the program (BuildAndPlay function)')

    //set the Form1.VideoPanel(vcl TPanel) as a render pallet for the video sink
    else if not GStreamer.SetVisualWindow('video_sink',VideoPanel.Handle)
    then logwriteln('error in the program (SetVisualWindow function)');
    Src := GStreamer.FindElement('src');
    If Src=nil
    then logwriteln('error in the program (FindElement function)');
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
GStreamer.Free;
end;

procedure TForm1.RadioButton1Click(Sender: TObject);
begin
If Src<>nil then
  Src.SetPropertyEnum('pattern', (Sender as TRadioButton).Tag);
end;

procedure TForm1.filtertoggleClick(Sender: TObject);
var
  LInvert: TGstElementRef;
  LEnabled: Boolean;
begin
  if (GStreamer = nil) or not GStreamer.Started then
    Exit;

  LEnabled := filtertoggle.State = tssOn;
  LInvert := GStreamer.FindElement('invert');
  try
    if LInvert = nil then
    begin
      LogWriteln('error in the program (FindElement invert function)');
      Exit;
    end;

    LInvert.SetPropertyBool('filter', LEnabled);
    if LEnabled then
      LogWriteln('g2dinvert filter enabled')
    else
      LogWriteln('g2dinvert filter bypassed');
  finally
    LInvert.Free;
  end;
end;
end.

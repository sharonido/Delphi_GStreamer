unit Uex7Wmp3;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  G2D,G2DCallDll,G2DTypes,WinConsoleFunction, Vcl.Buttons;

type

  TForm1 = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Splitter1: TSplitter;
    Memo1: TMemo;
    Label1: TLabel;
    PanelVideo: TPanel;
    Panel4: TPanel;
    Label2: TLabel;
    BLoad: TBitBtn;
    Edit1: TEdit;
    OpenDialog1: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure BLoadClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    SrcPlug:TGPlugIn
  end;

var
  Form1: TForm1;
  GStreamer:TGstFrameWork;
implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
var
AudioChain,VideoChain,SrcChain:string;
begin
Edit1.Text:=GetFullPathToParentFile('\MediaFiles\Baby.mp3')+'MediaFiles\Baby.mp3';
GStreamer.MemoLog:=Memo1;      //reroute log from console to window memo
GStreamer:=TGstFrameWork.Create(0,nil); //no parameters needed here

SrcChain:='filesrc ! mpegaudioparse ! mpg123audiodec ! audioconvert name=audio_src ! tee';
AudioChain:= 'queue name=audio_queue ! audioconvert ! audioresample ! autoaudiosink name=audio_sink';
VideoChain:= 'queue name=video_queue ! wavescope name=visual shader=0 style=1 !'+
             ' videoconvert name=video_convert ! d3d11videosink name=video_sink';

if not GStreamer.BuildPlugInsInPipeLine (SrcChain+'!'+AudioChain+'!'+VideoChain)
//build the plugins in the pipe but
//do not link them - it is not a simple link (it has branches)
  then exit;


If GStreamer.link(SrcChain) and
  GStreamer.link(AudioChain) and
  GStreamer.link(VideoChain) and
  GStreamer.setTeeChain('tee','audio_queue') and
  GStreamer.setTeeChain('tee','video_queue')
  then
  begin
  GStreamer.SetVisualWindow('video_sink',PanelVideo);{
  Plug:=GStreamer.PipeLine.GetPlugByName('video_sink'); //SinkPlugin
  _Gst_video_overlay_set_window_handle(Plug.RealObject,self.PanelVideo.Handle);}
  SrcPlug:=GStreamer.PipeLine.GetPlugByName('filesrc'); //Src Plugin
  SrcPlug.SetAParam('location',Edit1.Text);
  if not GStreamer.PipeLine.ChangeState(GST_STATE_PLAYING)  //change pipe state to play
    then WriteOutLn ('error in change pipeline state');
  end;
end;
//--------------
procedure TForm1.BLoadClick(Sender: TObject);
begin
if OpenDialog1.Execute then
  if OpenDialog1.FileName<>Edit1.Text then
  begin
  Edit1.Text:=OpenDialog1.FileName;
  if not GStreamer.PipeLine.ChangeState(GST_STATE_READY)
    then WriteOutLn ('error in change pipeline state to pause')
    else
    begin
    while GStreamer.State<> GST_STATE_READY do
      GStreamer.CheckMsgAndRunFor(100*GST_MSECOND);
    SrcPlug.SetAParam('location',Edit1.Text);
    if not GStreamer.PipeLine.ChangeState(GST_STATE_PLAYING)  //change pipe state to play
      then WriteOutLn ('error in change pipeline state to play');
    end;
  end;
end;

end.

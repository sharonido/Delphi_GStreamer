unit Uex7W;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  UTrackBarFrame, Vcl.ComCtrls,
  G2D,G2DCallDll,G2DTypes;

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
    TrackBar1: TTrackBar;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  GStreamer:GstFrameWork;
implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
var
AudioChain,VideoChain,SrcChain:string;
begin
GstFrameWork.MemoLog:=Memo1;
GStreamer:=GstFrameWork.Create(0,nil); //no parameters needed here
SrcChain:='audiotestsrc name=audio_source ! tee ';
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
  TrackBar1.Position:=422;  //gives like a standing sinus in the video scope
  GStreamer.SetVisualWindow('video_sink',PanelVideo);
  if not GStreamer.PipeLine.ChangeState(GST_STATE_PLAYING)  //change pipe state to play
    then WriteOutLn ('error in change pipeline state');
  end;
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
_G_object_set_float(GStreamer.PipeLine.GetPlugByName('audio_source').RealObject,
  pansichar('freq'),TrackBar1.position);
Label2.Caption:= 'Frequency='+TrackBar1.position.ToString+'Hz'
end;

end.

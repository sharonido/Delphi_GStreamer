unit Uex7Wmp3;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  UTrackBarFrame, Vcl.ComCtrls,
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
    SrcPlug:GPlugIn
  end;

var
  Form1: TForm1;
  GStreamer:GstFrameWork;
implementation

{$R *.dfm}

function setTeeChain(TeeName, ChainName:string):string;
var
Plug:GPlugIn;
PadSrc,PadSink:GPad;
begin
Result:='';
plug:=GStreamer.PipeLine.GetPlugByName(TeeName); //the tee plugin
PadSrc:=GPad.CreateReqested(Plug, 'src_%u');     //'src_%u' is the generic name for "tee" src pads
WriteOutLn('The '+plug.Name+' requested src pad obtained as '+PadSrc.Name);
  //Get queue PadSink by static
plug:=GStreamer.PipeLine.GetPlugByName(ChainName); //the audio_queue plugin
PadSink:=GPad.CreateStatic(Plug, 'sink');
WriteOutLn('The '+Plug.Name+' requested sink pad obtained as '+PadSink.Name);
  // link tee_audio_PadSrc to queue_audio_PadSink
if GST_PAD_LINK_OK<>PadSrc.LinkToSink(PadSink)
  then Result:='Error in link '+PadSrc.Name+' to '+PadSink.Name
  else
  begin
  WriteOutLn('Pads were linked');
  PadSink.Free;// Release extra sink pad
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
Plug:GPlugIn;
res:string;
begin
Edit1.Text:=GetFullPathToParentFile('\MediaFiles\Baby.mp3')+'MediaFiles\Baby.mp3';
GstFrameWork.MemoLog:=Memo1;      //reroute log from console to window memo
GStreamer:=GstFrameWork.Create(0,nil); //no parameters needed here
//src:='filesrc ! mpegaudioparse ! mpg123audiodec ! audioconvert name=audio_src ! tee';
if GStreamer.BuildPlugInsInPipeLine  //build the plugins in the pipe but
                 //do not link them - it is not a simple link (it has branches)
  ('filesrc ! mpegaudioparse ! mpg123audiodec ! audioconvert name=audio_src ! tee'+
  '! queue name=audio_queue ! audioconvert ! audioresample ! autoaudiosink name=audio_sink '+
  '!queue name=video_queue !wavescope name=visual shader=0 style=1!videoconvert name=video_convert!d3d11videosink name=video_sink')
  then
  begin
  //link the filesrc (holding the mp3 file) to the T)
  Res:=D_element_link_many_by_name(GStreamer.PipeLine,'filesrc, mpegaudioparse, mpg123audiodec, audio_src, tee');
  if Res<>'' then WriteOutLn(Res)
    else  //link Ok
    begin
    //link the audio branch (from the audio queue to audio sink
    Res:=D_element_link_many_by_name(GStreamer.PipeLine,'audio_queue, audioconvert, audioresample, audio_sink');
    if Res<>'' then WriteOutLn(Res)
      else //link Ok
      begin
      //Link the video branch from the video queue to the video sink
      Res:=D_element_link_many_by_name(GStreamer.PipeLine,'video_queue, visual, video_convert, video_sink');
      if Res<>'' then WriteOutLn(Res)
        else //link Ok
        begin
        // create the pads for the audio branch (tee src0 as src and audio_queue as sink) and link them
        res:=setTeeChain('tee','audio_queue');
        if Res<>'' then WriteOutLn(Res) //err
          else
          begin
          res:=setTeeChain('tee','video_queue');
          // create the pads for the video branch (tee src1 as src and video_queue as sink) and link them
          if Res<>'' then WriteOutLn(Res) //err
            else
            begin
            Plug:=GStreamer.PipeLine.GetPlugByName('video_sink'); //SinkPlugin
            _Gst_video_overlay_set_window_handle(Plug.RealObject,self.PanelVideo.Handle);
            SrcPlug:=GStreamer.PipeLine.GetPlugByName('filesrc'); //Src Plugin
            SrcPlug.SetAParam('location',Edit1.Text);
            if not GStreamer.PipeLine.ChangeState(GST_STATE_PLAYING)  //change pipe state to play
              then WriteOutLn ('error in change pipeline state');
            end;
          end;
        end;
      end;
    end
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

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
GstFrameWork.MemoLog:=Memo1;
GStreamer:=GstFrameWork.Create(0,nil); //no parameters needed here
if GStreamer.BuildPlugInsInPipeLine  //build the plugins in the pipe but
                 //do not link them - it is not a simple link (it has branches)
       ('audiotestsrc name=audio_source ! tee '+   //freq=800.0
        '! queue name=audio_queue ! audioconvert ! audioresample ! autoaudiosink name=audio_sink '+
        '! queue name=video_queue ! wavescope name=visual shader=0 style=1 ! videoconvert name=video_convert '+
        '! d3d11videosink name=video_sink'+        //d3d11videosink knows to work with video_overlay_set_window_handle
        ' ')
  then
  begin

  //link the audio src to the tee
  if not D_element_link(GStreamer.PipeLine,'audio_source','tee')
    then WriteOutLn('Error in linking audio_source & tee')
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
          // create the pads for the audio branch (tee src1 as src and video_queue as sink) and link them
          if Res<>'' then WriteOutLn(Res) //err
            else
            begin
            TrackBar1.Position:=800;
            Plug:=GStreamer.PipeLine.GetPlugByName('video_sink'); //SinkPlugin
            _Gst_video_overlay_set_window_handle(Plug.RealObject,self.PanelVideo.Handle);
            if not GStreamer.PipeLine.ChangeState(GST_STATE_PLAYING)  //change pipe state to play
              then WriteOutLn ('error in change pipeline state');
            end;
          end;
        end;
      end;
    end
  end;
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
_G_object_set_float(GStreamer.PipeLine.GetPlugByName('audio_source').RealObject,
  pansichar('freq'),TrackBar1.position);
Label2.Caption:= 'Frequency='+TrackBar1.position.ToString+'Hz'
end;

end.

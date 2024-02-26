unit Uex8a;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls,
  G2D,G2DCallDll,G2DTypes;

const
CHUNK_SIZE = 1024;         //* Amount of bytes we are sending in each buffer */
SAMPLE_RATE = 44100;       //* Samples per second we are sending */

type
int16Arr=array[0..(CHUNK_SIZE div 2)-1] of int16;
Pint16Arr=^int16Arr;

  TForm1 = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Splitter1: TSplitter;
    Memo1: TMemo;
    Label1: TLabel;
    PanelVideo: TPanel;
    GroupBox1: TGroupBox;
    RBStart: TRadioButton;
    RadioButton2: TRadioButton;
    GroupBox2: TGroupBox;
    RBpsych: TRadioButton;
    RBSaw: TRadioButton;
    RBClear: TRadioButton;
    procedure FormCreate(Sender: TObject);
    procedure RBStartClick(Sender: TObject);
  private
    { Private declarations }
    feeding:boolean;
    num_samples :uint64; //* Number of samples generated so far (for timestamp generation) */
    xa, xb, xc, xd :single;   //* For waveform generation */
    SawMax:integer;           //* For waveform generation */
    procedure push_data;
    procedure Psych(data:Pint16Arr;num_chunk_samples:integer);
    procedure Saw(data:Pint16Arr;num_chunk_samples:integer);
    procedure Clear(data:Pint16Arr;num_chunk_samples:integer);
  public
    app_source:PGstElement;
    { Public declarations }
  end;

//callback function when audio src needs data
procedure start_feed (source :PGstElement;  size:integer; data:pointer); cdecl;
//callback function when audio src has all the data (and can not process moer)
procedure stop_feed (source :PGstElement; data:pointer); cdecl;

var
  Form1: TForm1;
  GStreamer:GstFrameWork;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
var
info:_GstAudioInfo;
audio_caps :PGstCaps;
AudioChain,VideoChain,SrcChain:string;
//res:string;
begin
xb := 1;                   //* For waveform generation */
xd := 1;                   //* For waveform generation */
SawMax :=30000;            //* For waveform generation */
GstFrameWork.MemoLog:=Memo1;
GStreamer:=GstFrameWork.Create(0,nil); //no parameters needed here


SrcChain:='appsrc name=audio_source ! tee ';
AudioChain:= 'queue name=audio_queue ! audioconvert name=audio_c1 !'+
             ' audioresample ! autoaudiosink name=audio_sink';
VideoChain:= 'queue name=video_queue ! audioconvert name=audio_c2 !'+
              ' wavescope name=visual shader=0 style=1 !'+
             ' videoconvert name=video_convert ! d3d11videosink name=video_sink';
            // ' videoconvert name=video_convert ! autovideosink name=video_sink';

if not GStreamer.BuildPlugInsInPipeLine (SrcChain+'!'+AudioChain+'!'+VideoChain)
//build the plugins in the pipe but
//do not link them - it is not a simple link (it has branches)
  then exit;


//* Configure appsrc */
_Gst_audio_info_set_format (@info, GST_AUDIO_FORMAT_S16, SAMPLE_RATE, 1, nil);
audio_caps := _Gst_audio_info_to_caps (@info);
app_source:=GStreamer.PipeLine.GetPlugByName('audio_source').RealObject;
_G_object_set_int(app_source,pansichar('caps'),uint64(audio_caps));
_G_object_set_int(app_source,pansichar('format'),3); //integer(GST_FORMAT_TIME));
_G_signal_connect(app_source, 'need-data', @start_feed, nil);
_G_signal_connect(app_source, 'enough-data', @stop_feed, nil);

If GStreamer.link(SrcChain) and
  GStreamer.link(AudioChain) and
  GStreamer.link(VideoChain) and
  GStreamer.setTeeChain('tee','audio_queue') and
  GStreamer.setTeeChain('tee','video_queue')
  then
  begin
  GStreamer.SetVisualWindow('video_sink',PanelVideo);
  if not GStreamer.PipeLine.ChangeState(GST_STATE_PLAYING)  //change pipe state to play
    then WriteOutLn ('Error in change pipeline state');
  end;

 
end;

//******************************************


procedure TForm1.Psych(data:Pint16Arr;num_chunk_samples:integer);
var
i:integer;
freq    :single;  //gfloat freq;}
begin
xc:=xc+xd;                                    //data->c += data->d;
xd:=xd-xc/1000;                               //data->d -= data->c / 1000;
freq := 1100 + 1000 * xd;                     //freq = 1100 + 1000 * data->d;
for i:=0 to num_chunk_samples-1 do            //for (i = 0; i < num_samples; i++)
  begin
  xa:= xa+xb;                                 //  data->a += data->b;
  xb:= xb-xa/freq;                            //  data->b -= data->a / freq;
  data[i]:=round(500*xa);             //  raw[i] = (gint16) (500 * data->a);
  end;
end;

//****************************
procedure TForm1.Saw(data: Pint16Arr; num_chunk_samples: integer);
var
i,
step    :integer;
begin
step := 2*SawMax div 256;
Data[0]:=SawMax;
for i:=1 to num_chunk_samples-1 do            //for (i = 0; i < num_samples; i++)
  begin
  Data[i]:=Data[i-1]+step;
  If Data[I] > SawMax then Data[I]:=-SawMax;
  end;
end;

//****************************
procedure TForm1.Clear(data: Pint16Arr; num_chunk_samples: integer);
var  i:integer;
begin
for i:=0 to num_chunk_samples-1 do Data[i]:=0    //for (i = 0; i < num_samples; i++)
end;
//****************************
procedure TForm1.push_data;
var
buffer  :PGstBuffer;
ret     :GstFlowReturn;
i       :integer; // int i;
map     :GstMapInfo;  // GstMapInfo map;
SmallIntArr :Pint16Arr;  //gint16 *raw;
num_chunk_samples :uint64;  //gint num_samples = CHUNK_SIZE / 2;    /* Because each sample is 16 bits */
freq    :single;  //gfloat freq;}
begin
while GStreamer.State<GST_STATE_READY do
  Application.ProcessMessages;

num_chunk_samples := CHUNK_SIZE div 2; //* Because each sample is 16 bits (2 bytes)*/
feeding:=true;
WriteOutln('Start feeding');
while feeding do //feeding is changed in another thread by stop_feed
  begin
  buffer := _Gst_buffer_new_and_alloc (CHUNK_SIZE);
  buffer.pts := num_samples*uint64(GST_SECOND) div SAMPLE_RATE; //time from start to now in nano sec
  buffer.duration := num_chunk_samples*uint64(GST_SECOND) div SAMPLE_RATE; //buffer duration in nano sec
  _Gst_buffer_map(buffer, @map, GST_MAP_WRITE); //couple the map to the buffer
  SmallIntArr := Pint16Arr(map.data);           //Set pointer to ->map.data that now points to the raw buffer
  if RBpsych.Checked
    then Psych(SmallIntArr,num_chunk_samples)
    else if RBSaw.Checked
    then Saw(SmallIntArr,num_chunk_samples)
    else Clear(SmallIntArr,num_chunk_samples);

  _Gst_buffer_unmap(buffer,@map);
  num_samples:=num_samples+num_chunk_samples;
  //* Push the buffer into the appsrc */
  _G_signal_emit_by_name_pointer(app_source, PAnsiChar('push-buffer'), buffer, @ret);
  //* Free the buffer now that we are done with it */
  _Gst_mini_object_unref(buffer);
  if (ret <> GST_FLOW_OK)
    then break;
  end;
end;

procedure TForm1.RBStartClick(Sender: TObject);
begin
if RBStart.Checked
  then GStreamer.MemoLog:=Memo1
  else GStreamer.MemoLog:=nil;
end;

//******************************************************************************
procedure start_feed (source :PGstElement;  size:integer; data:pointer); cdecl;
begin
System.Classes.TThread.Synchronize(nil,
procedure
  begin
   Form1.push_data;
  end);
end;

//******************************************
procedure stop_feed (source :PGstElement; data:pointer); cdecl;
begin
System.Classes.TThread.Synchronize(nil, procedure
  begin
    WriteOutln('Stop feeding');
  end);
Form1.feeding:=false;
end;


end.

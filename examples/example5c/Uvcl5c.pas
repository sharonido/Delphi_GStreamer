unit Uvcl5c;

interface

uses
  System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Winapi.Windows, Winapi.Messages,
  G2D,
  G2DCallDll,
  G2DTypes,
  WinConsoleFunction,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons, UFPlayPauseBtn,
  Vcl.ComCtrls;

type
  TFormVideoWin = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Splitter1: TSplitter;
    Panel4: TPanel;
    PanelVideo: TPanel;
    Panel3: TPanel;
    Label1: TLabel;
    Mlog: TMemo;
    Label2: TLabel;
    FPlayPauseBtns1: TFPlayPauseBtns;
    PanelDuration: TPanel;
    PosSlider: TTrackBar;
    Label3: TLabel;
    LPosition: TLabel;
    Label4: TLabel;
    LDuration: TLabel;
    CBSrc: TComboBox;
    DialogSrc: TOpenDialog;
    BLoad: TBitBtn;
    Panel5: TPanel;
    Splitter2: TSplitter;
    CBVideo: TComboBox;
    LblVideoCn: TLabel;
    CBAudio: TComboBox;
    lblAudioCn: TLabel;
    lblSubs: TLabel;
    CBText: TComboBox;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure PosSliderChange(Sender: TObject);
    procedure CBSrcChange(Sender: TObject);
    procedure BLoadClick(Sender: TObject);
    procedure PanelVideoClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure CBAudioSelect(Sender: TObject);
  private
    { Private declarations }
    playbin:GPlugIn;
    NoSeek,NoPos:Boolean;
    Procedure ActButton(Btn:TBtnPressed;Status:TBtnsStatus);
    procedure ActPosition(NewPos:Int64);
    Procedure ActDuration(NewDuration:Int64);
    Procedure ActStreamData(app:Int64);
  public
    { Public declarations }
  end;

//callback function when tags are changed in stream(playbin)
procedure tags_cb (playbin :PGstElement;  stream:integer; data:pointer); cdecl;

var
  FormVideoWin: TFormVideoWin;
  GStreamer:GstFrameWork;
implementation

{$R *.dfm}
//writing to log in memo
procedure writeLog(st:string);
begin
if st.EndsWith(sLineBreak) then st:=st.Remove(st.Length-1);//lines.add inserts slineBreak
FormVideoWin.Mlog.Lines.Add(st);
end;


//this procedure initializes the GStreamer & the form(window)
procedure TFormVideoWin.FormCreate(Sender: TObject);
var
srcStr:string;
begin
WriteOut:=writeLog; //re-route activity log to the memo instead of console
//find full path of Ocean.mp4 file and add it to CBSrc (To let user easly choose)
srcStr:= GetFullPathToParentFile('\Delphi\Ocean.mp4');
if (srcStr <> '')
  then CBSrc.Items.Add(srcStr+'\Delphi\Ocean.mp4');
//button play/pause/stop init
FPlayPauseBtns1.OnBtnPressed:=ActButton; //set callback for action on button click
FPlayPauseBtns1.Status:=bsPaused;
FPlayPauseBtns1.sbPlay.Down:=false;
FPlayPauseBtns1.sbStop.Enabled:=false;
//visual stuff
PanelDuration.Visible:=false;
PanelVideo.Caption:='Wait for stream';

//GStreamer start
GStreamer:=GstFrameWork.Create(0,nil); //no parameters needed here
if GStreamer.Started then
  begin
  GStreamer.OnDuration:=ActDuration;      //set callback for stream duration function.
  GStreamer.OnPosition:=ActPosition;      //set callback for stream duration function.
  GStreamer.OnApplication:=ActStreamData; //set callback for Stream data function.
  srcStr:=CBSrc.Text;
  if not srcStr.StartsWith('https:') then srcStr:='file:///'+srcStr;
  //Build the pipe line with "playbin" plugin
  if not GStreamer.SimpleBuildLink('playbin uri='+srcStr)
      then writeOutln('Error in Build & Link Pipeline');
  //get the playbin plugin
  playbin:=GStreamer.PipeLine.GetPlugByName('playbin');
  //set the window handle that playbin will render the video on
  _Gst_video_overlay_set_window_handle(playbin.RealObject ,self.PanelVideo.Handle);
  //Set callback for tags
  _G_signal_connect (playbin.RealObject,pansichar('video-tags-changed'),@tags_cb, nil);
  _G_signal_connect (playbin.RealObject,pansichar('audio-tags-changed'),@tags_cb, nil);
  _G_signal_connect (playbin.RealObject,pansichar('text-tags-changed'),@tags_cb, nil);
  //get ready to play, and move to the pause state
  GStreamer.PipeLine.ChangeState(GST_STATE_PAUSED);
  end;
end;

//callback function when tags are changed in stream(playbin)
procedure tags_cb (playbin :PGstElement;  stream:integer; data:pointer); cdecl;
begin
//We are called here by playbin plugin thread that might not be main thread.
//To change GUI we must be in main thread.
//So "Synchronize" and call ActStreamData in main
//You can also call by posting an application message - but we do not use here
System.Classes.TThread.Synchronize(nil,
procedure
  begin
    FormVideoWin.ActStreamData(0);
  end);
end;

//callback function when bottons are pressed
Procedure TFormVideoWin.ActButton(Btn:TBtnPressed;Status:TBtnsStatus);
begin
  case status of
    TBtnsStatus.bsPlaying:
    begin
    writeoutln('Start play cmd');
    GStreamer.PipeLine.ChangeState(GST_STATE_PLAYING);
    end;
    TBtnsStatus.bsPaused:
    begin
    writeoutln('Pause cmd');
    GStreamer.PipeLine.ChangeState(GST_STATE_PAUSED);
    end;
    TBtnsStatus.bsStoped:
    begin
    writeoutln('Stop cmd');
    GStreamer.PipeLine.ChangeState(GST_STATE_READY);
    PanelDuration.Visible:=false;
    end;
    else writeoutln('Btn press Error');
  end
end;

//callback function when stream has a new position
procedure TFormVideoWin.ActPosition(NewPos:Int64);
begin
if (NewPos>=0) and not NoPos then
  begin
  LPosition.Caption:=NanoToSecStr(NewPos);
  NewPos:=NewPos div GST_100MSEC;
  NoSeek:=true;
  PosSlider.Position:=NewPos;
  NoSeek:=false;
  end;
end;

//callback function when stream has meta data (analyze_streams meta data)
procedure TFormVideoWin.ActStreamData(app: Int64);
var
I, n_video, n_audio, n_text:integer;
BR:UInt;
tags: PGstMiniObject;// GstTagList *tags;
pcstr:pansichar;
total_str:string;
begin
// Set label numbers
_G_object_get(playbin.RealObject,pansichar('n-video'),@n_video);
LblVideoCn.Caption:='Numer of Video in stream is: '+n_video.ToString;
_G_object_get(playbin.RealObject,pansichar('n-audio'),@n_audio);
LblAudioCn.Caption:='Numer of Audio chanels  in stream is: '+n_audio.ToString;
_G_object_get(playbin.RealObject,pansichar('n-text'),@n_text);
lblSubs.Caption :='Numer of Subtitle chanels  in stream is: '+n_text.ToString;

//set video options
CBVideo.Items.Clear;
CBVideo.Text:='None';
If n_video>0
  then PanelVideo.Caption:='Wait for video'
  else if n_audio>0 then PanelVideo.Caption:='This is an audio stream';
for I := 0 to n_video-1 do
  begin
  pcstr:=nil;
  tags:=nil;
  _G_signal_emit_by_name(playbin.RealObject,pansichar('get-video-tags'),I,@tags);
  if Assigned(tags) then
    begin
    if _Gst_tag_list_get_string(tags,pansichar('video-codec'),@pcstr) and Assigned(pcstr)
      then total_str:='codec: '+string(pcstr)
      else total_str:='codec: unknown';
    BR:=0;
    if _Gst_tag_list_get_uint(tags,pansichar('bitrate'),@BR) and (BR<>0)
      then total_str:=total_str+';  Bitrate='+(BR div 1000).ToString+'K';
    end
    else total_str:='codec: not in list';
  if CBVideo.Items.Count>I
    then begin
         CBVideo.Items.Insert(I,total_str);
         CBVideo.Items.Delete(I+1);
         end
    else CBVideo.Items.Add(total_str);
  CBVideo.Text:=total_str;
  CBVideo.ItemIndex:=0;
  end;
//set audio options
CBAudio.Items.Clear;
CBAudio.Text:='None';
for I := 0 to n_audio-1 do
  begin
  pcstr:=nil;
  tags:=nil;
  _G_signal_emit_by_name(playbin.RealObject,pansichar('get-audio-tags'),I,@tags);
  if Assigned(tags) then
    begin
    if _Gst_tag_list_get_string(tags,pansichar('audio-codec'),@pcstr) and Assigned(pcstr)
      then total_str:='codec: '+string(pcstr)
      else total_str:='codec: unknown';
    pcstr:=nil;
    if _Gst_tag_list_get_string(tags,pansichar('language-code'),@pcstr) and Assigned(pcstr)
      then total_str:=total_str+'; Language:'+string(pcstr);
    BR:=0;
    if _Gst_tag_list_get_uint(tags,pansichar('bitrate'),@BR) and (BR<>0)
      then total_str:=total_str+'; Bitrate='+(BR div 1000).ToString+'K';
    end
    else total_str:='codec: not in list';
  if CBAudio.Items.Count>I
    then begin
         CBAudio.Items.Insert(I,total_str);
         CBAudio.Items.Delete(I+1);
         end
    else CBAudio.Items.Add(total_str);
  CBAudio.Text:=total_str;
  CBAudio.ItemIndex:=0;
  end;
//set subtext
CBText.Items.Clear;
CBText.Text:='None';
for I := 0 to n_text-1 do
  begin
  pcstr:=nil;
  tags:=nil;
  _G_signal_emit_by_name(playbin.RealObject,pansichar('get-text-tags'),I,@tags);
  if Assigned(tags) then
    begin
    if _Gst_tag_list_get_string(tags,pansichar('language-code'),@pcstr) and Assigned(pcstr)
      then total_str:='Language:'+string(pcstr)
      else total_str:='Language: unknown';
    end
    else total_str:='Language: not in list';
  if CBText.Items.Count>I
    then begin
         CBText.Items.Insert(I,total_str);
         CBText.Items.Delete(I+1);
         end
    else CBVideo.Items.Add(total_str);
  CBText.Text:=total_str;
  CBText.ItemIndex:=0;
  end;
end;

//Callback from the stream to say it has a duriation
Procedure TFormVideoWin.ActDuration(NewDuration:Int64);
begin
LDuration.Caption:=NanoToSecStr(NewDuration);
if NewDuration>0 then
  begin
  PosSlider.Max:=NewDuration div GST_100MSEC;
  PosSlider.Frequency:=PosSlider.Max div 10;
  PanelDuration.Visible:=true;
  end;
end;


//--------------------  PosSliderChange &  Timer1Timer ------------------------
//the PosSliderChange & Timer1Timer are capled -to overcome a bug in vcl
procedure TFormVideoWin.PosSliderChange(Sender: TObject);
begin
if not NoSeek then //check if the movment of the slider was done by user
  begin
  NoPos:=true;   //disable the position update of the slider
  Timer1.Enabled:=false; //reset timer
  Timer1.Enabled:=true;  //timer will call the seek
  end;
end;

procedure TFormVideoWin.Timer1Timer(Sender: TObject);
begin
Timer1.Enabled:=false; //close the timer
//we must not seek before the prev seek finished so we delay (with timer)
D_query_stream_seek(GStreamer.PipeLine, PosSlider.Position*GST_100MSEC);
NoPos:=false;  //disable the position update of the slider
end;
//-end of  PosSliderChange &  Timer1Timer ------------------------------------


procedure TFormVideoWin.CBSrcChange(Sender: TObject);
var srcStr:string;
begin  //stream source has been changed by user
//set the buttons
FPlayPauseBtns1.sbStop.Enabled:=false;
FPlayPauseBtns1.sbPlay.down:=false;
ActButton(TBtnPressed.bpStop,TBtnsStatus.bsStoped);
//get & set user src
srcStr:=CBSrc.Text;
if not srcStr.StartsWith('https:') then srcStr:='file:///'+srcStr;
_G_object_set_pchar(playbin.RealObject,ansistring('uri'),ansistring(srcStr));
//go to pause state (ready for streaming)
GStreamer.PipeLine.ChangeState(GST_STATE_PAUSED);
end;

//load a new
procedure TFormVideoWin.BLoadClick(Sender: TObject);
begin //load a file as a stream source
if DialogSrc.Execute then
  CBSrc.Text:=DialogSrc.FileName;
  CBSrcChange(nil);
end;

procedure TFormVideoWin.PanelVideoClick(Sender: TObject);
begin //click on the video is as a click on play/pause button
FPlayPauseBtns1.sbPlayClick(nil);
end;

//This enables selecting an audio chanel as in:
//https://gstreamer.freedesktop.org/documentation/tutorials/playback/playbin-usage.html?gi-language=c
procedure TFormVideoWin.CBAudioSelect(Sender: TObject);
begin
_G_object_set_int (playbin.RealObject,pansichar('current-audio'), CBAudio.ItemIndex);
end;

end.


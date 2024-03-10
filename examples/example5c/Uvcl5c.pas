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
    Panel6: TPanel;
    Label3: TLabel;
    LPosition: TLabel;
    Panel7: TPanel;
    Label4: TLabel;
    LDuration: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure PosSliderChange(Sender: TObject);
    procedure CBSrcChange(Sender: TObject);
    procedure BLoadClick(Sender: TObject);
    procedure PanelVideoClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure CBAudioSelect(Sender: TObject);
  private
    { Private declarations }
    playbin:TGPlugIn;
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
  GStreamer:TGstFrameWork;
implementation

{$R *.dfm}

//this procedure initializes the GStreamer & the form(window)
procedure TFormVideoWin.FormCreate(Sender: TObject);
var
srcStr:string;
begin
//find full path of Ocean.mp4 file and add it to CBSrc (To let user easly choose)
srcStr:= GetFullPathToParentFile('\MediaFiles\Ocean.mp4');
if (srcStr <> '')
  then
  begin
  CBSrc.Items.Add(srcStr+'\MediaFiles\Ocean.mp4');
  CBSrc.Items.Add(srcStr+'\MediaFiles\Baby.mp3');
  end;
//button play/pause/stop init
FPlayPauseBtns1.OnBtnPressed:=ActButton; //set callback for action on button click
FPlayPauseBtns1.Status:=bsPaused;
FPlayPauseBtns1.sbPlay.Down:=false;
FPlayPauseBtns1.sbStop.Enabled:=false;
//visual stuff
PanelDuration.Visible:=false;
PanelVideo.Caption:='Wait for stream';

//GStreamer start
GStreamer.MemoLog:=Mlog;  //re-route activity log to the memo instead of console
GStreamer:=TGstFrameWork.Create(0,nil); //no parameters needed here
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
  GStreamer.SetVisualWindow('playbin',PanelVideo);
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
var vstrs,astrs,tstrs:TArray<string>;
begin
vstrs:=GStreamer.VideoStrInStream;
astrs:=GStreamer.AudioStrInStream;
tstrs:=GStreamer.TextStrInStream;
// Set label numbers
LblVideoCn.Caption:='Numer of Video in stream is: '+Length(vstrs).ToString;
LblAudioCn.Caption:='Numer of Audio chanels  in stream is: '+Length(astrs).ToString;
lblSubs.Caption :='Numer of Subtitle chanels  in stream is: '+Length(tstrs).ToString;
//set PanelVideo.Caption
If Length(vstrs)>0
  then
  PanelVideo.Caption:='Wait for video'
  else if Length(astrs)>0 then PanelVideo.Caption:='This is an audio stream'
  else PanelVideo.Caption:='Unknown stream type';
//set video options
CBVideo.Items.Clear;
if Length(vstrs)=0 then CBVideo.Items.Add('None')
                   else CBVideo.Items.AddStrings(vstrs);
CBVideo.ItemIndex:=0;
//set audio options
CBAudio.Items.Clear;
if Length(astrs)=0 then CBAudio.Items.Add('None')
                   else CBAudio.Items.AddStrings(astrs);
CBAudio.ItemIndex:=0;
//set subtext
CBText.Items.Clear;
if Length(tstrs)=0 then CBText.Items.Add('None')
                   else CBText.Items.AddStrings(tstrs);
CBText.ItemIndex:=0;
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
PlayBin.SetAParam('uri',srcStr);
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
playbin.setAParam('current-audio',CBAudio.ItemIndex.ToString );
end;

end.


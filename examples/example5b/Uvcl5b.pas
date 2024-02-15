unit Uvcl5b;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
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
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure PosSliderChange(Sender: TObject);
    procedure CBSrcChange(Sender: TObject);
    procedure BLoadClick(Sender: TObject);
    procedure PanelVideoClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    playbin:GPlugIn;
    NoSeek,NoPos:Boolean;
    procedure ActPosition(NewPos:Int64);
    Procedure ActButton(Btn:TBtnPressed;Status:TBtnsStatus);
    Procedure ActDuration(NewDuration:Int64);
  public
    { Public declarations }
  end;

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
  then CBSrc.Items.Add(srcStr+'\Delphi\Ocean.mp4');//add Ocean.mp4 to the combx box for easy user selection
//button play/pause/stop init
FPlayPauseBtns1.OnBtnPressed:=ActButton; //set callback for action on button click
FPlayPauseBtns1.Status:=bsPaused;
FPlayPauseBtns1.sbPlay.Down:=false;
FPlayPauseBtns1.sbStop.Enabled:=false;
PanelDuration.Visible:=false;        //visual stuff

//GStreamer start
GStreamer:=GstFrameWork.Create(0,nil); //no parameters needed here
if GStreamer.Started then
  begin
  GStreamer.OnDuration:=ActDuration;  //set callback for stream duration function.
  GStreamer.OnPosition:=ActPosition;  //set callback for stream duration function.
  srcStr:=CBSrc.Text;
  if not srcStr.StartsWith('https:') then srcStr:='file:///'+srcStr;
  //Build the pipe line with "playbin" plugin
  if not GStreamer.SimpleBuildLink('playbin uri='+srcStr)
      then writeOutln('Error in Build & Link Pipeline');
  //get the playbin plugin
  playbin:=GStreamer.PipeLine.GetPlugByName('playbin');
  //set the window handle that playbin will render the video on
  _Gst_video_overlay_set_window_handle(playbin.RealObject ,self.PanelVideo.Handle);
  //get ready to play, and move to the pause state
  PanelVideo.Caption:='Wait for video';
  GStreamer.PipeLine.ChangeState(GST_STATE_PAUSED);
  end;
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

//This is a callback from the stream to say it has a new position
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

//This is a callback from the stream to say it has a duriation
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
 { TODO : make a cleaner fix by adding a frame with a trackbar that has a mouse up after change }
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

//to load a new video file
procedure TFormVideoWin.BLoadClick(Sender: TObject);
begin //load a file as a stream source
if DialogSrc.Execute then
  CBSrc.Text:=DialogSrc.FileName;
  CBSrcChange(nil);
end;

//click on the video panel=click on start/pause (like in most video apps)
procedure TFormVideoWin.PanelVideoClick(Sender: TObject);
begin  //click on the video is as a click on play/pause button
FPlayPauseBtns1.sbPlayClick(nil);
end;

end.

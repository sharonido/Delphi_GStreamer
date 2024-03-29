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
    FPlayPauseBtns1: TFPlayPauseBtns;
    procedure FormCreate(Sender: TObject);
    procedure PosSliderChange(Sender: TObject);
    procedure CBSrcChange(Sender: TObject);
    procedure BLoadClick(Sender: TObject);
    procedure PanelVideoClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    playbin:TGPlugIn;
    NoSeek,NoPos:Boolean;
    procedure ActPosition(NewPos:Int64);
    Procedure ActButton(Btn:TBtnPressed;Status:TBtnsStatus);
    Procedure ActDuration(NewDuration:Int64);
    Procedure GStateChanged(State: TGstState);
  public
    { Public declarations }
  end;

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
  then CBSrc.Items.Add(srcStr+'\MediaFiles\Ocean.mp4');//add Ocean.mp4 to the combx box for easy user selection
//button play/pause/stop init
FPlayPauseBtns1.OnBtnPressed:=ActButton; //set callback for action on button click
FPlayPauseBtns1.Enabled:=false;
PanelDuration.Visible:=false;        //visual stuff

//GStreamer start
GStreamer.MemoLog:=Mlog;  //re-route activity log to the memo instead of console
GStreamer:=TGstFrameWork.Create(0,nil); //no parameters needed here
if GStreamer.Started then
  begin
  GStreamer.OnChangeStatus:=GStateChanged; //set callback for state change
  GStreamer.OnDuration:=ActDuration;  //set callback for stream duration function.
  GStreamer.OnPosition:=ActPosition;  //set callback for stream duration function.
  srcStr:=CBSrc.Text;
  if not srcStr.StartsWith('https:') then srcStr:='file:///'+srcStr;
  //Build the pipe line with "playbin" plugin
  if not GStreamer.SimpleBuildLink('playbin uri='+srcStr)
      then writeOutln('Error in Build & Link Pipeline');
  PlayBin:=GStreamer.PipeLine.GetPlugByName('playbin');
  //render the PanelVideo for the video display
  GStreamer.SetVisualWindow('playbin',PanelVideo);
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
    FPlayPauseBtns1.Enabled:=false;
    GStreamer.PipeLine.ChangeState(GST_STATE_READY);
    GStreamer.PipeLine.ChangeState(GST_STATE_PAUSED);
    PanelDuration.Visible:=false;
    end;
    else writeoutln('Btn press Error');
  end
end;

//This is a callback from the stream to say it has a new State
procedure TFormVideoWin.GStateChanged(State: TGstState);
begin
If state=TGstState.GST_STATE_PAUSED then
  begin
  FPlayPauseBtns1.Enabled:=true;
  FPlayPauseBtns1.sbStop.Enabled:=false;
  end;
end;

//This is a callback from the stream to say it has a new position
procedure TFormVideoWin.ActPosition(NewPos:Int64);
begin
if (NewPos>=0) and not NoPos then
  begin
  LPosition.Caption:=NanoToSec100Str(NewPos);
  NewPos:=NewPos div GST_10MSEC;
  NoSeek:=true;
  PosSlider.Position:=NewPos;
  NoSeek:=false;
  end;
end;

//This is a callback from the stream to say it has a duriation
Procedure TFormVideoWin.ActDuration(NewDuration:Int64);
begin
LDuration.Caption:=NanoToSec100Str(NewDuration);
if NewDuration>0 then
  begin
  PosSlider.Max:=NewDuration div GST_10MSEC;
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
D_query_stream_seek(GStreamer.PipeLine, PosSlider.Position*GST_10MSEC);
NoPos:=false;  //disable the position update of the slider
end;
//-end of  PosSliderChange &  Timer1Timer ------------------------------------

procedure TFormVideoWin.CBSrcChange(Sender: TObject);
var srcStr:string;
begin  //stream source has been changed by user
GStreamer.PipeLine.ChangeState(GST_STATE_READY);//stop the current stream
//set the buttons
FPlayPauseBtns1.sbPlay.Down:=false;
FPlayPauseBtns1.Enabled:=false;
//get & set user src
srcStr:=CBSrc.Text;
if not srcStr.StartsWith('https:') then srcStr:='file:///'+srcStr;
PlayBin.SetAParam('uri',srcStr);
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
FPlayPauseBtns1.sbPlay.down:=not FPlayPauseBtns1.sbPlay.down;
FPlayPauseBtns1.sbPlayClick(nil);
end;

end.

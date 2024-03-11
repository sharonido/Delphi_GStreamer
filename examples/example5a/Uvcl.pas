unit Uvcl;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  G2D,
  G2DCallDll,
  G2DTypes, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons, UFPlayPauseBtn;

type
  TFormVideoWin = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Splitter1: TSplitter;
    Panel4: TPanel;
    PanelVideo: TPanel;
    Panel3: TPanel;
    Label1: TLabel;
    ESrc: TEdit;
    Mlog: TMemo;
    Label2: TLabel;
    FPlayPauseBtns1: TFPlayPauseBtns;
    procedure FormCreate(Sender: TObject);
    procedure PanelVideoClick(Sender: TObject);
    Procedure ActButton(Btn:TBtnPressed;Status:TBtnsStatus);
    Procedure GStateChanged(State: TGstState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormVideoWin: TFormVideoWin;
  GStreamer:TGstFrameWork;
implementation

{$R *.dfm}

procedure TFormVideoWin.FormCreate(Sender: TObject);
var
srcStr:string;
begin
//botton play stop init
FPlayPauseBtns1.OnBtnPressed:=ActButton; //set callback for action on button click
FPlayPauseBtns1.Enabled:=false;
//GStreamer start
GStreamer.MemoLog:=Mlog;//redirect log - is before start, cause the log change is a static class
GStreamer:=TGstFrameWork.Create(0,nil); //no parameters needed here
if GStreamer.Started then
  begin
  GStreamer.OnChangeStatus:=GStateChanged; //set callback for state change
  srcStr:=ESrc.Text;
  if not srcStr.StartsWith('https:') then srcStr:='file:///'+srcStr;

  if not GStreamer.SimpleBuildLink('playbin uri='+srcStr)
    then writeOutln('error in the prog');

  GStreamer.SetVisualWindow('playbin',PanelVideo);  //render the video on PanelVideo
  PanelVideo.Caption:='Wait for video';
  GStreamer.PipeLine.ChangeState(GST_STATE_PAUSED); //run
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
    end;
    else writeoutln('Btn press Error');
  end
end;
//callback function when state has changed
procedure TFormVideoWin.GStateChanged(State: TGstState);
begin
If state=TGstState.GST_STATE_PAUSED then
  begin
  FPlayPauseBtns1.Enabled:=true;
  FPlayPauseBtns1.sbStop.Enabled:=false;
  end;
end;


procedure TFormVideoWin.PanelVideoClick(Sender: TObject);
begin
FPlayPauseBtns1.sbPlayClick(nil);
end;

end.

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
  private
    { Private declarations }
  public
    { Public declarations }
    Procedure ActButton(Btn:TBtnPressed;Status:TBtnsStatus);
  end;

var
  FormVideoWin: TFormVideoWin;
  GStreamer:GstFrameWork;
implementation

{$R *.dfm}

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
    end;
    else writeoutln('Btn press Error');
  end
end;

procedure TFormVideoWin.FormCreate(Sender: TObject);
var
srcStr:string;
begin
//botton play stop init
FPlayPauseBtns1.OnBtnPressed:=ActButton; //set callback for action on button click
FPlayPauseBtns1.Status:=bsPaused;
FPlayPauseBtns1.sbPlay.Down:=false;
FPlayPauseBtns1.sbStop.Enabled:=false;

//GStreamer start
GStreamer.MemoLog:=Mlog;//redirect log - is before start, cause the log change is a static class
GStreamer:=GstFrameWork.Create(0,nil); //no parameters needed here
if GStreamer.Started then
  begin
  srcStr:=ESrc.Text;
  if not srcStr.StartsWith('https:') then srcStr:='file:///'+srcStr;

  if not GStreamer.SimpleBuildLink('playbin uri='+srcStr)
     //('playbin uri=https://www.freedesktop.org/software/gstreamer-sdk/data/media/sintel_trailer-480p.webm')
     //('playbin uri=file:///C:\temp\demo5.mp4')
     // DoForEver)
      then writeOutln('error in the prog');

  GStreamer.SetVisualWindow('playbin',PanelVideo);
  PanelVideo.Caption:='Wait for video';
  GStreamer.PipeLine.ChangeState(GST_STATE_PAUSED);
  end;
end;

procedure TFormVideoWin.PanelVideoClick(Sender: TObject);
begin
FPlayPauseBtns1.sbPlayClick(nil);
end;

end.

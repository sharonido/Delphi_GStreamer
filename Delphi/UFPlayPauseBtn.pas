unit UFPlayPauseBtn;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ToolWin,
  Vcl.Buttons;

type

TBtnsStatus=(bsReady,bsPlaying,bsPaused,bsStoped);
TBtnPressed=(bpPlay,bpPause,bpStop,bpNext,bpPrev,bpStep,bpBack,bpRecord,bpEject);

TBtnPlayProc=Procedure(Btn:TBtnPressed;Status:TBtnsStatus) of object;

  TFPlayPauseBtns = class(TFrame)
    ToolBar1: TToolBar;
    sbStop: TSpeedButton;
    sbPlay: TSpeedButton;
    sbNext: TSpeedButton;
    sbPrev: TSpeedButton;
    sbStep: TSpeedButton;
    sbBack: TSpeedButton;
    procedure sbPlayClick(Sender: TObject);
    procedure sbPauseClick(Sender: TObject);
    procedure sbStopClick(Sender: TObject);
    procedure sbNextClick(Sender: TObject);
    procedure sbPrevClick(Sender: TObject);
    procedure sbStepClick(Sender: TObject);
    procedure sbBackClick(Sender: TObject);
  private
    { Private declarations }
    FStatus:TBtnsStatus;
    FOnBtnPressed:TBtnPlayProc;
    Procedure EnableAll;
  Protected
    function GetEnabled:boolean;  override;
    procedure SetEnabled(value:boolean); override;
    procedure SetStatus(value:TBtnsStatus);
  public
    { Public declarations }
  property Enabled:boolean read getEnabled write setEnabled;
  property Status:TBtnsStatus read FStatus write setStatus;
  property OnBtnPressed:TBtnPlayProc write FOnBtnPressed;
  end;

implementation

{$R *.dfm}

Procedure TFPlayPauseBtns.EnableAll;
var i: Integer;
begin
with ToolBar1 do For i:= 0 to controlCount -1 do if (controls[i]is TSpeedButton)
  then  (controls[i] as TSpeedButton).Enabled:=true;
end;
//==================================================================
procedure TFPlayPauseBtns.SetStatus(value:TBtnsStatus);
begin
if value=FStatus
  then begin if Value=TBtnsStatus.bsReady then EnableAll; end
  else
  begin
  FStatus:=Value;
  EnableAll;
    case FStatus of
     bsReady: sbPlay.Down:=false;
     bsPlaying:sbPlay.Down:=true ;
     bsPaused:sbPlay.Down:=true ;
     bsStoped:
       begin
       sbStop.Down:=false;
       sbStop.Enabled:=false;
       end ;
    end;
  end;
end;
//==================================================================
function TFPlayPauseBtns.getEnabled:boolean;
begin
result:=inherited;
end;
//------------------------------------
procedure TFPlayPauseBtns.setEnabled(value:boolean);
var I:Integer;
begin
Inherited SetEnabled(Value);
with self.ToolBar1 do  For i:= 0 to controlCount -1 do if (controls[i]is TSpeedButton)
      then (controls[i] as TSpeedButton).Enabled:=value;
end;
//==================================================================


procedure TFPlayPauseBtns.sbPlayClick(Sender: TObject);
begin
if (Status=TBtnsStatus.bsPaused) or (Status=TBtnsStatus.bsStoped)//sbPlay.down
  then Status:=TBtnsStatus.bsPlaying
  else
  begin
  Status:=TBtnsStatus.bsPaused;
  sbPlay.Down:=false;
  end;
if assigned (FOnBtnPressed) then FOnBtnPressed(bpPlay,Status);
end;

procedure TFPlayPauseBtns.sbPauseClick(Sender: TObject);
begin
if Status<>TBtnsStatus.bsPlaying
  then Status:=TBtnsStatus.bsPlaying   //this will cause play to be pressed
  else Status:=TBtnsStatus.bsPaused;
if assigned (FOnBtnPressed) then FOnBtnPressed(bpPause,Status);
end;

procedure TFPlayPauseBtns.sbStopClick(Sender: TObject);
begin
Status:=TBtnsStatus.bsStoped;
if assigned (FOnBtnPressed) then FOnBtnPressed(bpStop,Status);
end;

procedure TFPlayPauseBtns.sbNextClick(Sender: TObject);
begin
Status:=TBtnsStatus.bsPaused;
if assigned (FOnBtnPressed) then FOnBtnPressed(bpNext,Status);
end;

procedure TFPlayPauseBtns.sbPrevClick(Sender: TObject);
begin
Status:=TBtnsStatus.bsPaused;
if assigned (FOnBtnPressed) then FOnBtnPressed(bpPrev,Status);
end;

procedure TFPlayPauseBtns.sbStepClick(Sender: TObject);
begin
Status:=TBtnsStatus.bsPaused;
if assigned (FOnBtnPressed) then FOnBtnPressed(bpStep,Status);
end;

procedure TFPlayPauseBtns.sbBackClick(Sender: TObject);
begin
Status:=TBtnsStatus.bsPaused;
if assigned (FOnBtnPressed) then FOnBtnPressed(bpBack,Status);
end;


end.

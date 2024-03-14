unit UFPlayPauseBtn;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ToolWin,
  Vcl.Buttons;

type

TBtnsStatus=(bsReady,bsPlaying,bsPaused,bsStoped,bsFF,bsFB,bsStep,bsBack,bsNext,bsPrev,bsRecord,bsEject);
TBtnPressed=(bpPlay,bpPause,bpStop,bpFF,bpFB,bpStep,bpBack,bpNext,bpPrev,bpRecord,bpEject);

TBtnPlayProc=Procedure(Btn:TBtnPressed;Status:TBtnsStatus) of object;

  TFPlayPauseBtns = class(TFrame)
    ToolBar1: TToolBar;
    sbStop: TSpeedButton;
    sbPlay: TSpeedButton;
    sbNext: TSpeedButton;
    sbPrev: TSpeedButton;
    sbStep: TSpeedButton;
    sbBack: TSpeedButton;
    sbFF: TSpeedButton;
    sbFB: TSpeedButton;
    procedure sbPlayClick(Sender: TObject);
    procedure sbPauseClick(Sender: TObject);
    procedure sbStopClick(Sender: TObject);
    procedure sbNextClick(Sender: TObject);
    procedure sbPrevClick(Sender: TObject);
    procedure sbStepClick(Sender: TObject);
    procedure sbBackClick(Sender: TObject);
    procedure sbFFClick(Sender: TObject);
    procedure sbFBClick(Sender: TObject);
  private
    { Private declarations }
    FStatus:TBtnsStatus;
    FOnBtnPressed:TBtnPlayProc;
  Protected
    function GetEnabled:boolean;  override;
    procedure SetEnabled(value:boolean); override;
    procedure SetStatus(value:TBtnsStatus);
    function GetStatusName:string;
  public
    { Public declarations }
  property Enabled:boolean read getEnabled write setEnabled;
  property Status:TBtnsStatus read FStatus write setStatus;
  property StatusName:string read GetStatusName;
  property OnBtnPressed:TBtnPlayProc write FOnBtnPressed;
  end;

implementation

{$R *.dfm}
//==================================================================
procedure TFPlayPauseBtns.SetStatus(value:TBtnsStatus);
begin
Enabled:=true;
FStatus:=Value;
  case FStatus of
   bsReady: sbPlay.Down:=false;
   bsPlaying:if not sbPlay.Down then Fstatus:=bsPaused ;
   bsPaused:sbPlay.Down:=false;
   bsStoped:
     begin
     sbStop.Down:=false;
     //sbStop.Enabled:=false;
     end ;
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
Status:=TBtnsStatus.bsPlaying;
if assigned (FOnBtnPressed) then FOnBtnPressed(bpPlay,Status);
end;

procedure TFPlayPauseBtns.sbStopClick(Sender: TObject);
begin
Status:=TBtnsStatus.bsStoped;
if assigned (FOnBtnPressed) then FOnBtnPressed(bpStop,Status);
end;

procedure TFPlayPauseBtns.sbNextClick(Sender: TObject);
begin
Status:=TBtnsStatus.bsNext;
if assigned (FOnBtnPressed) then FOnBtnPressed(bpNext,Status);
end;

procedure TFPlayPauseBtns.sbPrevClick(Sender: TObject);
begin
Status:=TBtnsStatus.bsPrev;
if assigned (FOnBtnPressed) then FOnBtnPressed(bpPrev,Status);
end;

procedure TFPlayPauseBtns.sbStepClick(Sender: TObject);
begin
Status:=TBtnsStatus.bsStep;
if assigned (FOnBtnPressed) then FOnBtnPressed(bpStep,Status);
end;

procedure TFPlayPauseBtns.sbBackClick(Sender: TObject);
begin
Status:=TBtnsStatus.bsBack;
if assigned (FOnBtnPressed) then FOnBtnPressed(bpBack,Status);
end;


procedure TFPlayPauseBtns.sbFBClick(Sender: TObject);
begin
Status:=TBtnsStatus.bsFB;
if assigned (FOnBtnPressed) then FOnBtnPressed(bpFB,Status);
end;

procedure TFPlayPauseBtns.sbFFClick(Sender: TObject);
begin
Status:=TBtnsStatus.bsFF;
if assigned (FOnBtnPressed) then FOnBtnPressed(bpFF,Status);
end;

procedure TFPlayPauseBtns.sbPauseClick(Sender: TObject);
begin //never used !!! (no pause btn - if pause btn added then use)
if Status<>TBtnsStatus.bsPlaying
  then Status:=TBtnsStatus.bsPlaying   //this will cause play to be pressed
  else Status:=TBtnsStatus.bsPaused;
if assigned (FOnBtnPressed) then FOnBtnPressed(bpPause,Status);
end;
//-------------------------------------------------------------

function TFPlayPauseBtns.GetStatusName: string;
begin
  case fStatus of
  bsReady   :Result:='Ready';
  bsPlaying :Result:='Playing';
  bsPaused  :Result:='Paused';
  bsStoped  :Result:='Stoped';
  bsFF      :Result:='FF';
  bsFB      :Result:='Reverse';
  bsStep    :Result:='Step';
  bsBack    :Result:='Step back';
  bsNext    :Result:='next';
  bsPrev    :Result:='Prev';
  bsRecord  :Result:='Record';
  bsEject   :Result:='Eject';
  end;
end;
end.

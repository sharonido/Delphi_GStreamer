unit FRate;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TFrameRate = class(TFrame)
    Label1: TLabel;
    LRate: TLabel;
  private
    { Private declarations }
    findex:integer;
    Arr:Array[-3..4] of double;
    Procedure Loaded;override;
    function GetRate:double;
    procedure SetRate(v:double);
    procedure ShowRate;
  public
    { Public declarations }
    property rate:double read GetRate write SetRate;
    procedure Up;
    procedure Dn;
  end;

implementation

{$R *.dfm}

{ TFrame1 }

procedure TFrameRate.Loaded;
begin
inherited;
Arr[-3]:=-4;
Arr[-2]:=-2;
Arr[-1]:=-1.5;
Arr[0]:= -1;
Arr[1]:= 1;
Arr[2]:= 1.5;
Arr[3]:= 2;
Arr[4]:= 4;
findex:= 1;
ShowRate;
end;


procedure TFrameRate.ShowRate;
begin
LRate.Caption:=Arr[findex].ToString;{
  case findex of
  -3:LRate.Caption:='-4';
  -2:LRate.Caption:='-2';
  -1:LRate.Caption:='-1.5';
   0:LRate.Caption:='-1';
   1:LRate.Caption:='1';
   2:LRate.Caption:='1.5';
   3:LRate.Caption:='2';
   4:LRate.Caption:='4';
  end;        }
end;

procedure TFrameRate.Up;
begin
if findex<4 then inc(findex);
ShowRate;
end;

procedure TFrameRate.Dn;
begin
if findex>-3 then dec(findex);
ShowRate;
end;

function TFrameRate.GetRate: double;
begin
Result:=Arr[findex];
end;

procedure TFrameRate.SetRate(v: double);
var i:integer;
begin
for i := -3 to 4 do  if v=arr[i] then     break;
if i=5 then findex:=1
       else findex:=i;
ShowRate;
end;

end.

unit WinConsoleFunction;

interface
uses
System.SysUtils,
{$ifdef mswindows}
WinAPI.Windows;

const
VK_ESCAPE=WinAPI.Windows.VK_ESCAPE;
VK_RETURN=WinAPI.Windows.VK_RETURN;
{$endif}  { TODO -oIdo -cos : add compile condition that will work when os is not mswindows }

function KeyPressed(var key:char):Boolean;
function StrEnter(var TheInString:String; WriteKey:boolean=true):boolean;
function GetFullPathToParentFile(filename:string):string;
implementation


//function KeyPressed returns true if keboard was pressed from last call
//and then, the Key will be the char pressed by user.
function KeyPressed(var key:char):Boolean;
var lpNumberOfEvents: uint;
    lpBuffer: TInputRecord;
    lpNumberOfEventsRead : uint;
    nStdHandle: THandle;
begin
result := false;
key:=#0;
nStdHandle := GetStdHandle(STD_INPUT_HANDLE);
lpNumberOfEvents := 0;
GetNumberOfConsoleInputEvents(nStdHandle,lpNumberOfEvents);
if lpNumberOfEvents<>0 then   //there were events from last call
  begin
  PeekConsoleInput(nStdHandle,lpBuffer,1,lpNumberOfEventsRead);
  if (lpNumberOfEventsRead<>0) and         //there were read events from last call
     (lpBuffer.EventType=KEY_EVENT) and    //keyboard event
      lpBuffer.Event.KeyEvent.bKeyDown then//key down event
    begin
    result := true;
    key:=lpBuffer.Event.KeyEvent.UnicodeChar;
    end;
  FlushConsoleInputBuffer(nStdHandle);
  end;
end;
//------------------------------------------------------------------------
//function StrEnter returns true only after Enter was pressed
//and then TheInString is the string that was entered
function StrEnter(var TheInString:String; WriteKey:boolean=true):boolean;
var c:char;
begin
result:= KeyPressed(c) and ((ord(c)=VK_ESCAPE) or (ord(c)=VK_RETURN));
  case ord(c) of
  VK_ESCAPE:TheInString:=char(VK_ESCAPE);
  VK_RETURN:;
  else if c<>#0 then
    begin
    TheInString:=TheInString+c;
    if writeKey then write(c);
    end;
  end;
end;

function GetFullPathToParentFile(filename:string):string;
begin
Result:=GetCurrentDir;
while (Result <> '') and not fileExists(Result+filename) do
  begin   // Move to the parent directory
  Result := ExcludeTrailingPathDelimiter(Result);
  Result := ExtractFilePath(Result);
  if Result.EndsWith(':') then Result:='';
  end;
end;
end.

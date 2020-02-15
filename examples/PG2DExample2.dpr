{* copyright (c) 2020 I. Sharon Ltd.
 *
 * This file is part of GStreamer 2 Delphi bridge (G2D).
 *
 * G2D is free software; You can redistribute it and modify it. It is licensed
 * under the GNU Lesser General Public License as published by the Free Software
 * Foundation. Either version 2.1 of the License, or any later version.

for info on G2D goto
https://github.com/sharonido/Delphi_GStreamer
}
program PG2DExample1;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  WinAPI.Windows,
  G2D in '..\Delphi\G2D.pas',
  G2DCallDll in '..\Delphi\G2DCallDll.pas';

{---  readme.txt ---------------------------------------------------------------
This program is like the previous "PG2DExample" but adds 3 features:
1.	The program does not wait for the stream in the pipeline to stop. Instead it
    loops until GstFrameWork.MsgResult<>GST_MESSAGE_UNKNOWN and when it gets out
    of the loop, it writes why it got out.
2.	The program reads parameters for the plugin, in this case “pattern=18”. And
    builds the videotestsrc plugin accordingly.(A moving ball)
3.	While stream is running, you are asked to set the pattern with different
    numbers. You can see the change on screen. (When changing to 0 you get
    the screen of the previous example)
------------------------------------------------------------------------------}

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
//and then TheInString is string that was entered
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

//main -------------------------------------------------------------------------
Var
GStreamer:GstFrameWork;
patternNum:integer;
PatternStr:string;
begin
writeln;
Writeln('Mouse click on this window to focuse it, so keyboard will be read');
writeln;
  try
  GStreamer:=GstFrameWork.Create(0,nil); //no parameters needed here
    try
    //launch the gstreamer pipeline but do not wait
    if GStreamer.LaunchSimlpePipelineDoNotWait('videotestsrc pattern=18 ! autovideosink')
      then                                 //pattern=? is the parameter for videotestsrc
      begin
      writeln('GStreamer running');
      PatternStr:='';
      write('Enter esc to exit or a number [0..24] as Pattern ');
      while true  do  //loop forever until break (esc or error in stream);
        begin
        while not StrEnter(PatternStr) and (GstFrameWork.MsgResult=GST_MESSAGE_UNKNOWN)
          do sleep(50); //wait for keypress (Enter) or GstFrameWork.MsgResult
                        //slee[ so not to burn cpu
        if PatternStr=chr(VK_ESCAPE) then  break;
        if (GstFrameWork.MsgResult<>GST_MESSAGE_UNKNOWN) then
          begin
          writeln;
          writeln('GStreamer had ran until '+DateToIso(Now));
            //write why stream ended (closing the stream window is error in stream)
            case GstFrameWork.MsgResult of
            GST_MESSAGE_EOS   : writeln('Gst message: End Of Stream');
            GST_MESSAGE_ERROR : writeln('Gst message: Error in stream');
            else writeln('Should never be here???');
            end;
          write('press enter to exit ');    readln;
          break;
          end;
        Writeln;
        patternNum:=-1;
        if TryStrToInt(PatternStr,patternNum)
           and (PatternNum>=0) and  (PatternNum<=24)
           then D_object_set_int(GStreamer.PipeLine.PlugIns[0],'pattern',patternNum)
                            //GStreamer.PipeLine.PlugIns[0] is "videotestsrc"
           else writeln ('pattern must be 0-24');
        write('Enter esc to exit or a number [0..24] as Pattern ');
        PatternStr:='';
        end;
      end
      else
      begin
      writeln('error in the prog'); readln;
      end;
    finally
    //check the static var "started", cause GStreamer may not have started
    if (GStreamer<>nil) and GstFrameWork.Started
      then GStreamer.DisposeOf;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.

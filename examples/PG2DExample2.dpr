{* copyright (c) 2020 I. Sharon Ltd.
 *
 * This file is part of GStreamer 2 Delphi bridge (G2D).
 *
 * G2D is free software; You can redistribute it and modify it. It is licensed
 * under the GNU Lesser General Public License as published by the Free Software
 * Foundation. Either version 2.1 of the License, or any later version.

for info on G2D download:
https://github.com/sharonido/Delphi_GStreamer/blob/master/G2D.docx
for full G2D source and bin dpwnload from:
https://github.com/sharonido/Delphi_GStreamer
  or clone by:
git clone https://github.com/sharonido/Delphi_GStreamer.git
}
program PG2DExample2;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  G2D in '..\Delphi\G2D.pas',
  G2DCallDll in '..\Delphi\G2DCallDll.pas',
  WinConsoleFunction in '..\Delphi\WinConsoleFunction.pas';

{---  readme.txt ---------------------------------------------------------------
This program is like the previous "PG2DExample1" but adds 3 features:
1.	The program does not wait for the stream in the pipeline to stop. Instead it
    loops until GstFrameWork.MsgResult<>GST_MESSAGE_UNKNOWN and when it gets out
    of the loop, it writes why it got out.
2.	The program reads parameters for the plugin, in this case “pattern=18”. And
    builds the videotestsrc plugin accordingly.(A moving ball)
3.	While stream is running, you are asked to set the pattern with different
    numbers. You can see the change on screen. (When changing to 0 you get
    the screen of the previous example1)
------------------------------------------------------------------------------}

//main -------------------------------------------------------------------------
Var
GStreamer:GstFrameWork;
patternNum:integer;
EnterStr:string;
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
      EnterStr:='';
      write('Enter esc to exit or a number [0..24] as Pattern ');
      while true  do  //loop forever until break (esc or error in stream);
        begin
        while not StrEnter(EnterStr) and (GstFrameWork.MsgResult=GST_MESSAGE_UNKNOWN)
          do sleep(50); //wait for keypress (Enter) or GstFrameWork.MsgResult
                        //sleep so not to burn cpu
        // check what happend (why did we leave the forever sleep 50
        if EnterStr=chr(VK_ESCAPE) then  break;
        if (GstFrameWork.MsgResult<>GST_MESSAGE_UNKNOWN) then
          begin
          writeln;
          writeln('GStreamer had ran until '+DateToIso(Now));
          write('press enter to exit ');    readln;
          break;
          end;
        //Check for the changed input
        Writeln;
        patternNum:=-1;
        if TryStrToInt(EnterStr,patternNum)
           and (PatternNum>=0) and  (PatternNum<=24)
           then D_object_set_int(GStreamer.PipeLine.PlugIns[0],'pattern',patternNum)
                            //GStreamer.PipeLine.PlugIns[0] is "videotestsrc"
           else writeln ('pattern must be 0-24');
        write('Enter esc to exit or a number [0..24] as Pattern ');
        EnterStr:='';
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

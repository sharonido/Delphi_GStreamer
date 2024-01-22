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
program PG2DExample2A;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  G2D in '..\..\Delphi\G2D.pas',
  G2DCallDll in '..\..\Delphi\G2DCallDll.pas',
  G2DTypes in '..\..\Delphi\G2DTypes.pas',
  WinConsoleFunction in '..\..\Delphi\WinConsoleFunction.pas';

{---  readme.txt ---------------------------------------------------------------

This is a Basic tutorial 2A program for G2D (Gstreamer bridge to Delphi)
This follows the Basic tutorial 2 in Gsteramer Docs in:
https://gstreamer.freedesktop.org/documentation/tutorials/basic/concepts.html?gi-language=c
but uses an object oriented framework of Delphi
-----------
This program is like the previous "PG2DExample2" but adds building & linking
the plugins & making the pipeline & runing the stream manuely :
1.	Creating the Src & Sink Pluin classes
2.	Adding the plugins to the pipe line
3.  link of src->sink
4.  change pipeline state to "play"
5.  check for msg
While stream is running, you are asked to set the pattern with different
numbers. You can see the change on screen. (When changing to 18 you get
moving ball - try also other patterns)
------------------------------------------------------------------------------}

//main -------------------------------------------------------------------------
Var
GStreamer:GstFrameWork;
Src,Sink :GPlugin;
patternNum:integer;
EnterStr:string='';
DoOnce:boolean=true;
begin
  try
  GStreamer:=GstFrameWork.Create(0,nil); //no parameters needed here
    try
    //Creating the Src & Sink Pluin classes & Adding the plugins to the pipe line
    Src:=GPlugIn.Create('videotestsrc','A video test source plugin');
    GStreamer.PipeLine.AddPlugIn(Src);
    Sink:=GPlugIn.Create('autovideosink','A video sink plugin');
    GStreamer.PipeLine.AddPlugIn(Sink);
    if not GStreamer.PipeLine.SimpleLinkAll then   //link of src->sink
      begin
      Writeln('Error '+Src.Name+' did not link to '+Sink.Name);
      readln;
      exit;
      end;
    if not GStreamer.PipeLine.ChangeState(GST_STATE_PLAYING)  then //change pipeline stste to "play"
      begin
      Writeln('Error PipeLine did not change state to play');
      readln;
      exit;
      end;
    writeln;
    Writeln('Mouse click on this window to focuse it, so keyboard will be read');
    writeln;
      Repeat  //loop forever until break (esc or error in stream);
      GStreamer.CheckMsgAndRunFor(100*GST_MSECOND);
      if GStreamer.State=GST_STATE_PLAYING then //wait until stream is running
        begin
        if DoOnce then
          begin
          DoOnce:=false;
          write('Enter esc to exit or a number [0..24] as Pattern ');
          end;
        if StrEnter(EnterStr) then //if keypressed is Enter
          begin
          writeln;
          if EnterStr=chr(VK_ESCAPE) then  break;
          Writeln;
          patternNum:=-1;
          if TryStrToInt(EnterStr,patternNum)
             and (PatternNum>=0) and  (PatternNum<=24)
             // BE AWARE D_object... is not Dg_object...
             then D_object_set_int(GStreamer.PipeLine.PlugIns[0],'pattern',patternNum)
                              //GStreamer.PipeLine.PlugIns[0] is "videotestsrc"
             else writeln ('pattern must be 0-24');
          write('Enter esc to exit or a number [0..24] as Pattern ');
          EnterStr:='';
          end;
        end;
      until GStreamer.G2DTerminate;
    finally
      GStreamer.Free;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
Write('Press Enter to exit');
readln;
end.

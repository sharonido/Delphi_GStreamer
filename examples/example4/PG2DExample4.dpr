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
program PG2DExample4;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  G2D in '..\..\Delphi\G2D.pas',
  G2DCallDll in '..\..\Delphi\G2DCallDll.pas',
  G2DTypes in '..\..\Delphi\G2DTypes.pas',
  WinConsoleFunction in '..\..\Delphi\WinConsoleFunction.pas';

{---  readme.txt --------------------------------------------------------------

This is a Basic tutorial 4 program for G2D (Gstreamer bridge to Delphi)
This follows the Basic tutorial 4 in Gsteramer Docs in:
https://gstreamer.freedesktop.org/documentation/tutorials/basic/concepts.html?gi-language=c
but uses an object oriented framework of Delphi
-----------
This program runs a video clip from the internet,
while the video is playing you can do 3 things:
1.	press 'd' -> that will print the duration of the clip in seconds.
2.	press 'p' -> that will print the current position of the clip in seconds.
3.  press 's' -> that will jump (seek) to second 30 of the clip.
}


//main -------------------------------------------------------------------------
Var
GStreamer:GstFrameWork;
playbin :GPlugin;
StreamPos, StreamDuration:Int64;//can be -1
key:char;
begin
{$IfDef VER360}
WriteOutln('''
This is a Basic tutorial 4 program for G2D (Gstreamer bridge to Delphi)
This follows the Basic tutorial 4 in Gsteramer Docs in:
https://gstreamer.freedesktop.org/documentation/tutorials/basic/concepts.html?gi-language=c
but uses an object oriented framework of Delphi
-----------
This program runs a video clip from the internet,
while the video is playing you can do 3 things:
1.	press 'd' -> that will print the duration of the clip in seconds.
2.	press 'p' -> that will print the current position of the clip in seconds.
3.  press 's' -> that will jump (seek) to second 30 of the clip.
program consul output:
''');
{$Endif}
  try
  GStreamer:=GstFrameWork.Create(0,nil); //no parameters needed here
  if GStreamer.Started then
    try
    //Creating the Src & Sink Pluin classes & Adding the plugins to the pipe line
    playbin:=GPlugIn.Create('playbin'+
      ' uri=https://www.freedesktop.org/software/gstreamer-sdk/data/media/sintel_trailer-480p.webm',
      'An Internet video  plugin');
    GStreamer.PipeLine.AddPlugIn(playbin);

    if not GStreamer.PipeLine.ChangeState(GST_STATE_PLAYING)  then //change pipeline state to "play"
      begin
      Writeln('Error PipeLine did not change state to play');
      readln;
      exit;
      end;
    //GStreamer.WaitForPlay(10); //wait (for up to 10 sec) for stream to start running
    //if GStreamer.Running then writeln('GStreamer running');
    writeln;
    Writeln('Mouse click on this window to focuse it, so keyboard will be read');
    writeln;
    if not GStreamer.WaitForPlay(10) then exit
      else
      begin
      writeln('Enter esc to exit or');
      writeln('p for stream position, or d for stream duriation,');
      write(' or s to skeep to place of 30 sec in stream ');
        Repeat  //loop forever until break (esc or error in stream);
        GStreamer.CheckMsgAndRunFor(100*GST_MSECOND);
        if KeyPressed(key) then //if keypressed is Enter
          begin
          writeln(key);
          if key=chr(VK_ESCAPE) then  break;
            case key of
              'p','P':
              begin
              if D_query_stream_position(playbin,StreamPos)
                then writeln('Position is '+(int64(StreamPos) div GST_SECOND).ToString+' Sec')
                else writeln('Position is not supported here');
              end;
              'd','D':
              begin
              if D_query_stream_duration(playbin,StreamDuration)
                then writeln('Stream duration is '+(int64(StreamDuration) div GST_SECOND).ToString+' Sec')
                else writeln('Stream duration is not supported here');
              end;
              's','S':
              begin
              if D_query_stream_seek(playbin,30*GST_SECOND)
                then writeln('Stream position moved to 30 seconds')
                else writeln('Stream seek is not supported here');
              end;
              else writeln('This is not a valid option');
            end;
          writeln('Enter esc to exit or');
          writeln('p for stream position, or d for stream duriation,');
          write(' or s to skeep 10 sec in stream ');
          end;
        until GStreamer.G2DTerminate;
      end;
    finally
      GStreamer.Free;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
write('Press Enter to exit');
readln;
end.

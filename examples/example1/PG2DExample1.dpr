{* copyright (c) 2020 I. Sharon Ltd.
 *
 * This file is part of GStreamer 2 Delphi bridge (G2D).
 *
 * G2D is free software; You can redistribute it and modify it. It is licensed
 * under the GNU Lesser General Public License as published by the Free Software
 * Foundation. Either version 2.1 of the License, or any later version.

for info on G2D download:
https://github.com/sharonido/Delphi_GStreamer/blob/master/G2D.docx
for full G2D source and bin download from:
https://github.com/sharonido/Delphi_GStreamer
  or clone by:
git clone https://github.com/sharonido/Delphi_GStreamer.git
}

program PG2DExample1;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  G2D in '..\..\Delphi\G2D.pas',
  G2DCallDll in '..\..\Delphi\G2DCallDll.pas',
  G2DTypes in '..\..\Delphi\G2DTypes.pas';

//main -------------------------------------------------------------------------
Var
GStreamer:GstFrameWork;
begin
{$IfDef VER360}
WriteOutln('''
This is example 1. It is a "Hellow world" program for G2D a
(Gstreamer bridge to Delphi). This program follows the example1 in Gsteramer Docs in:
https://gstreamer.freedesktop.org/documentation/tutorials/basic/hello-world.html?gi-language=c
but uses an object oriented framework of Delphi
-----------
This grogram uses gstreamer as in gst-launch-1.0.exe
That is, you can get a similar effect as using from command line:
gst-launch-1.0 playbin uri=https://www.freedesktop.org/software/gstreamer-sdk/data/media/sintel_trailer-480p.webm

If running "launch-1.0" as in a cmdline,
you only need this example and example 1A
program consul output:
''');
{$Endif}
  try
  GStreamer:=GstFrameWork.Create(0,nil); //no parameters needed here
  if GStreamer.Started then
    try
    //launch the gstreamer pipeline
    if not GStreamer.SimpleBuildLinkPlay
     ('playbin uri=https://www.freedesktop.org/software/gstreamer-sdk/data/media/sintel_trailer-480p.webm',
     //('playbin uri=file:///C:\temp\demo5.mp4',  //if you have a mp4 file...
      DoForEver)
      then writeln('error in the prog');
    finally
      GStreamer.Free;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
write('press enter to exit');
readln;
end.

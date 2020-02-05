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

program PG2DExample;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  G2D in '..\Delphi\G2D.pas',
  G2DCallDll in '..\Delphi\G2DCallDll.pas';

{---  readme.txt ---------------------------------------------------------------
This program launches a gstreamer pipeline.
The pipeline is constructed just with two standard known plugins. a source (src) linked to a sink.
The src is "videotestsrc" that generates an endless video test signal.
The sink is "autovideosink that displays a video in a window on the screen (desktop).
------------------------------------------------------------------------------}

//main -------------------------------------------------------------------------
Var
GStreamer:GstFrameWork;
begin
  try
  GStreamer:=GstFrameWork.Create(0,nil); //no parameters needed here
    try
    //launch the gstreamer pipeline
    if GStreamer.LaunchSimlpePipelineAndWaitEos('videotestsrc ! autovideosink')        // autovideosink   dshowvideosink
      then writeln('GStreamer had ran until '+DateToIso(Now))
      else writeln('error in the prog');
    finally
    //check the static var "started", cause GStreamer may not have started
    if (GStreamer<>nil) and GstFrameWork.Started
      then GStreamer.DisposeOf;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
write('press enter to exit');    readln;
end.

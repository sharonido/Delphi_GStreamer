program PG2DExample;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  G2D;   // in 'G2D.pas';
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

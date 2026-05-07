
program PG2DExample3;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  G2D.Glib.API in '..\..\G_API\G2D.Glib.API.pas',
  G2D.Gobject.API in '..\..\G_API\G2D.Gobject.API.pas',
  G2D.Gst.API in '..\..\G_API\G2D.Gst.API.pas',
  G2D.Gobject.DOO in '..\..\G_DBase\G2D.Gobject.DOO.pas',
  G2D.GstBin.DOO in '..\..\G_DBase\G2D.GstBin.DOO.pas',
  G2D.GstBus.DOO in '..\..\G_DBase\G2D.GstBus.DOO.pas',
  G2D.GstElement.DOO in '..\..\G_DBase\G2D.GstElement.DOO.pas',
  G2D.GstMessage.DOO in '..\..\G_DBase\G2D.GstMessage.DOO.pas',
  G2D.GstObject.DOO in '..\..\G_DBase\G2D.GstObject.DOO.pas',
  G2D.GstPad.DOO in '..\..\G_DBase\G2D.GstPad.DOO.pas',
  G2D.GstPipeline.DOO in '..\..\G_DBase\G2D.GstPipeline.DOO.pas',
  G2D.Glib.Types in '..\..\G_Types\G2D.Glib.Types.pas',
  G2D.Gobject.Types in '..\..\G_Types\G2D.Gobject.Types.pas',
  G2D.Gst.Types in '..\..\G_Types\G2D.Gst.Types.pas',
  G2D.GstFramework in '..\..\G_DUnits\G2D.GstFramework.pas',
  WinConsoleFunction in '..\WinConsoleFunction.pas',
  G2D.API.Loader in '..\..\G_API\G2D.API.Loader.pas';

var
  GStreamer: TGstFramework;
  UriParameter :String;
begin
  // UriParameter: if your Internet connection is not good you can play an *.mp4
  // file by "C:/somefile.mp4" (path+filename)
  //in the program cmd line
  UriParameter:= ReadParameter('uri');
  if (UriParameter='') or not FileExists(UriParameter)
    then UriParameter:='https://www.freedesktop.org/'+
          'software/gstreamer-sdk/data/media/sintel_trailer-480p.webm'
    else UriParameter:='file:///'+StringReplace(ExpandFileName(UriParameter), '\', '/', [rfReplaceAll]);
  //Example 3
  GStreamer := TGstFramework.Create(True);
  try
    LogWriteln(GStreamer.Version);
    LogWriteln('Example 3');
    if NormalGstSearch then
      begin
      GStreamer.Build('uridecodebin name=source ! audioconvert name=convert !'+
                  ' audioresample name=resample ! autoaudiosink name=audio_sink');

      if not GStreamer.LinkMany(['convert', 'resample', 'audio_sink']) then
        raise Exception.Create('Failed to link static elements');

      if not GStreamer.ConnectDynamicPad('source', 'convert', 'sink') then
        raise Exception.Create('Failed to connect dynamic pad');

      GStreamer.SetElementPropertyString('source', 'uri', UriParameter);
      if not GStreamer.Play then
        raise Exception.Create('Failed to play pipeline');

      logWriteLn('Playing '+ UriParameter);
      while GStreamer.RunFor(GST_CLOCK_TIME_NONE) do; //run until End of stream
      end
      else LogWriteln(GStreamer.NotNormalGstSearchMes);

  finally
    GStreamer.Free;
  end;
write('press Enter to exit:');
readln;

end.

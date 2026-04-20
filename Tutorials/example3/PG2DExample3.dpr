
program PG2DExample3;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  G2D.GstFramework,
  G2D.Gst.Types,
  G2D.Glib.API,
  WinConsoleFunction in '..\WinConsoleFunction.pas';

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

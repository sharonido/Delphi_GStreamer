
program PG2DExample3;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  G2D.GstFramework,
  G2D.Gst.Types,
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
    if not GStreamer.NewPipeline('test-pipeline') then
      raise Exception.Create('Failed to create pipeline');

    if GStreamer.MakeElement('uridecodebin', 'source') = nil then
      raise Exception.Create('Failed to create source');

    if GStreamer.MakeElement('audioconvert', 'convert') = nil then
      raise Exception.Create('Failed to create convert');

    if GStreamer.MakeElement('audioresample', 'resample') = nil then
      raise Exception.Create('Failed to create resample');

    if GStreamer.MakeElement('autoaudiosink', 'sink') = nil then
      raise Exception.Create('Failed to create sink');

      writeln(ParamStr(1));
    GStreamer.SetElementPropertyString('source', 'uri', UriParameter);

    if not GStreamer.AddElements(['source', 'convert', 'resample', 'sink']) then
      raise Exception.Create('Failed to add elements');

    if not GStreamer.LinkMany(['convert', 'resample', 'sink']) then
      raise Exception.Create('Failed to link static elements');

    if not GStreamer.ConnectDynamicPad('source', 'convert', 'sink') then
      raise Exception.Create('Failed to connect dynamic pad');

    if not GStreamer.Play then
      raise Exception.Create('Failed to play pipeline');

    while GStreamer.RunFor(GST_CLOCK_TIME_NONE) do
    begin
    end;

  finally
    GStreamer.Free;
  end;
write('press Enter to exit:');
readln;

end.

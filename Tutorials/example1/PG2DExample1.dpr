program PG2DExample1;

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
  WinConsoleFunction in '..\WinConsoleFunction.pas';

var
  GStreamer: TGstFramework;
  UriParameter:string;

begin
  // UriParameter: if your Internet connection is not good you can play an *.mp4
  // file by "C:/somefile.mp4" (path+filename)
  //in the program cmd line
  UriParameter:= ReadParameter('uri');
  if (UriParameter='') or not FileExists(UriParameter)
    then UriParameter:='https://www.freedesktop.org/'+
          'software/gstreamer-sdk/data/media/sintel_trailer-480p.webm'
    else UriParameter:='file:///'+StringReplace(ExpandFileName(UriParameter), '\', '/', [rfReplaceAll]);

  //Example 1
  try
    GStreamer := TGstFramework.Create(true);
    try
    logWriteln('Example 1');
    if NormalGstSearch then
      begin
      if GStreamer.Started then
        begin
        if not GStreamer.SimpleNativeBuildAndPlay('playbin uri='+UriParameter,
          DoForEver) then
          logWriteln('error in the prog');
        end;
      end
      else
      LogWriteln('This example works only if the full GStreamer Framework is downloaded from:'+sLineBreak+
                  'https://gstreamer.freedesktop.org/data/pkg/windows/1.28.2/msvc/gstreamer-1.0-msvc-x86_64-1.28.2.exe'+sLineBreak+
                  'or you can go to the next example (all other examples should work with the G2D repository)'+sLineBreak+
                  'It is provided only to be fully compatible with:' + sLineBreak+
                  'https://gstreamer.freedesktop.org/documentation/tutorials/' );

    finally
      GStreamer.Free;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

  Write('press Enter to exit');
  Readln;
end.

program PG2DExample4;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Windows,
  G2D.Glib.API in '..\..\G_API\G2D.Glib.API.pas',
  G2D.Gobject.API in '..\..\G_API\G2D.Gobject.API.pas',
  G2D.Gst.API in '..\..\G_API\G2D.Gst.API.pas',
  WinConsoleFunction in '..\WinConsoleFunction.pas',
  G2D.Gobject.DOO in '..\..\G_DBase\G2D.Gobject.DOO.pas',
  G2D.GstBin.DOO in '..\..\G_DBase\G2D.GstBin.DOO.pas',
  G2D.GstBus.DOO in '..\..\G_DBase\G2D.GstBus.DOO.pas',
  G2D.GstElement.DOO in '..\..\G_DBase\G2D.GstElement.DOO.pas',
  G2D.GstMessage.DOO in '..\..\G_DBase\G2D.GstMessage.DOO.pas',
  G2D.GstObject.DOO in '..\..\G_DBase\G2D.GstObject.DOO.pas',
  G2D.GstPad.DOO in '..\..\G_DBase\G2D.GstPad.DOO.pas',
  G2D.GstPipeline.DOO in '..\..\G_DBase\G2D.GstPipeline.DOO.pas',
  G2D.GstFramework in '..\..\G_DUnits\G2D.GstFramework.pas',
  G2D.Glib.Types in '..\..\G_Types\G2D.Glib.Types.pas',
  G2D.Gobject.Types in '..\..\G_Types\G2D.Gobject.Types.pas',
  G2D.Gst.Types in '..\..\G_Types\G2D.Gst.Types.pas';

var
  GStreamer: TGstFramework;
  Duration: gint64;
  Position: gint64;
  once:boolean=true;
  key:char;
  UriParameter:string;
  HTerminal: HWND;

begin
  // UriParameter: if your Internet connection is not good you can play an *.mp4
// file by "C:/somefile.mp4" (path+filename)
//in the program cmd line
UriParameter:= ReadParameter('uri');
if (UriParameter='') or not FileExists(UriParameter)
  then UriParameter:='https://www.freedesktop.org/'+
        'software/gstreamer-sdk/data/media/sintel_trailer-480p.webm'
  else UriParameter:='file:///'+StringReplace(ExpandFileName(UriParameter), '\', '/', [rfReplaceAll]);

  HTerminal:=GetConsoleWindow;
// example 4
  GStreamer := TGstFramework.Create;
  try

    if not GStreamer.BuildAndPlay('playbin uri=' + UriParameter) then
      raise Exception.Create('Failed to build pipeline');
    while GStreamer.RunFor(100*GST_MSECOND) do
    begin
      if once and (GStreamer.State = GST_STATE_PLAYING) then
        begin
        once:=false;
        Writeln('Enter ''p''-for Position, or ''d''-for Duration or'+
            ' ''s''-Seek to 20 sec or Esc to stop');
        if (HTerminal<>0) then SetForegroundWindow(HTerminal);
        end;

      if KeyPressed(Key) then
        begin
        Write(key);
          case key of
            'p','P': // Position
                if GStreamer.QueryPosition(Position) then
                  Writeln(' Position: ', Position div gint(GST_SECOND), ' sec');
            'd','D': // Duration
                if GStreamer.QueryDuration(Duration) then
                  Writeln(' Duration: ', Duration div gint(GST_SECOND), ' sec');
            's','S':// Seek
            if GStreamer.SeekSimple(20 * GST_SECOND,
               GST_FORMAT_TIME,
               GST_SEEK_FLAG_FLUSH or GST_SEEK_FLAG_KEY_UNIT
             ) then
                  Writeln(' Seek to 20 sec position succeeded')
                else
                  Writeln(' Seek failed');
            chr(VK_ESCAPE)://stop
              break;
            else  Writeln(key+
              ' Must enter ''p''-for Position, or ''d''-for Duration or'+
              ' ''s''-Seek to 20 sec or Esc to stop');
          end;
        end;
    end;

  finally
    GStreamer.Free;
  end;
write('ppress Enter to exit:');
readln;
end.

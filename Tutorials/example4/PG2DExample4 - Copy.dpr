program PG2DExample4;

{$APPTYPE CONSOLE}

uses
  System.SysUtils, Windows,
  G2D.GstFramework,
  G2D.Gst.Types,
  G2D.Glib.Types;

var
  GStreamer: TGstFramework;
  Duration: guint64;
  Position: gint64;
  SeekDone: Boolean;
  StartTick: Cardinal;

begin
  GStreamer := TGstFramework.Create(True);
  try
    if ParamCount < 1 then
    begin
      Writeln('Usage: PG2DExample4 <URI>');
      Exit;
    end;

    if not GStreamer.BuildAndPlay(
      'playbin uri=' + ParamStr(1)
    ) then
      raise Exception.Create('Failed to build pipeline');

    SeekDone := False;
    StartTick := GetTickCount;

    while GStreamer.RunFor(GST_SECOND) do
    begin
      // Position
      if GStreamer.QueryPosition(Position) then
        Writeln('Position: ', Position div GST_SECOND, ' sec');

      // Duration
      if GStreamer.QueryDuration(Duration) then
        Writeln('Duration: ', Duration div GST_SECOND, ' sec');

      // Seek אחרי ~5 שניות
      if (not SeekDone) and (GetTickCount - StartTick > 5000) then
      begin
        Writeln('Attempting seek to 30 sec...');

        if GStreamer.SeekSimple(
             30 * GST_SECOND,
             GST_FORMAT_TIME,
             GST_SEEK_FLAG_FLUSH or GST_SEEK_FLAG_KEY_UNIT
           ) then
        begin
          Writeln('Seek succeeded');
          SeekDone := True;
        end
        else
        begin
          Writeln('Seek failed');
        end;
      end;
    end;

  finally
    GStreamer.Free;
  end;
write('press Enter to exit:');
readln;
end.

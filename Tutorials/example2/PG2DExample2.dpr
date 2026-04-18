program PG2DExample2;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Winapi.Windows,
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
  Src: TGstElementRef;
  PatternNum: Integer;
  EStr: string;
  DoOnce: Boolean;

begin
  //Example 2
  try
    GStreamer := TGstFramework.Create;
    LogWriteln('Example 2');
    try
      if GStreamer.Started then
      begin
        if not GStreamer.NativeBuildAndPlay(
          'videotestsrc name=src ! d3d11videosink'
          //'videotestsrc name=src pattern=0 ! autovideosink'
         // 'videotestsrc name=src ! videoconvert ! d3d11videosink async=false'
        ) then
          Writeln('error in the prog')
        else
        begin
          Src := nil;
          EStr := '';
          DoOnce := True;

          try
            Src := GStreamer.FindElement('src');
            if Src = nil then
              raise Exception.Create('Could not find element "src"');

            Writeln;
            Writeln('To see the Video window move this terminal window');
            Writeln('Mouse click on this window to focus it, so keyboard will be read');
            Writeln;
            repeat
              GStreamer.RunFor(100 * GST_MSECOND);

              if GStreamer.HasError then
                Break;

              if GStreamer.HasEOS then
                Break;

              if GStreamer.State = GST_STATE_PLAYING then
              begin
                if DoOnce then
                begin
                  DoOnce := False;
                  Write('Enter esc to exit or a number [0..24] as Pattern ');
                end;

                if StrEnter(EStr) then
                begin
                  Writeln;

                  if EStr = #27 then
                    Break;

                  PatternNum := -1;

                  if TryStrToInt(EStr, PatternNum) and
                     (PatternNum >= 0) and
                     (PatternNum <= 24) then
                  begin
                    Src.SetPropertyEnum('pattern', PatternNum);
                  end
                  else
                    Writeln('pattern must be 0..24');

                  Write('Enter esc to exit or a number [0..24] as Pattern ');
                  EStr := '';
                end;
              end;

            until False;

            if GStreamer.HasError then
            begin
              Writeln;
              Writeln('Framework reported error: ', GStreamer.LastErrorText);
              if GStreamer.LastDebugText <> '' then
                Writeln('Debug: ', GStreamer.LastDebugText);
            end
            else if GStreamer.HasEOS then
            begin
              Writeln;
              Writeln('End-Of-Stream reached');
            end;

          finally
            Src.Free;
          end;
        end;
      end;
    finally
      GStreamer.Free;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.

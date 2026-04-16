program PG2DFrameworkTest;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Winapi.Windows,
  G2D.Glib.API       in '..\..\G_API\G2D.Glib.API.pas',
  G2D.Gobject.API    in '..\..\G_API\G2D.Gobject.API.pas',
  G2D.Gst.API        in '..\..\G_API\G2D.Gst.API.pas',
  G2D.Gobject.DOO    in '..\..\G_DBase\G2D.Gobject.DOO.pas',
  G2D.GstBin.DOO     in '..\..\G_DBase\G2D.GstBin.DOO.pas',
  G2D.GstBus.DOO     in '..\..\G_DBase\G2D.GstBus.DOO.pas',
  G2D.GstElement.DOO in '..\..\G_DBase\G2D.GstElement.DOO.pas',
  G2D.GstMessage.DOO in '..\..\G_DBase\G2D.GstMessage.DOO.pas',
  G2D.GstObject.DOO  in '..\..\G_DBase\G2D.GstObject.DOO.pas',
  G2D.GstPad.DOO     in '..\..\G_DBase\G2D.GstPad.DOO.pas',
  G2D.GstPipeline.DOO in '..\..\G_DBase\G2D.GstPipeline.DOO.pas',
  G2D.GstFramework   in '..\..\G_DUnits\G2D.GstFramework.pas',
  G2D.Glib.Types     in '..\..\G_Types\G2D.Glib.Types.pas',
  G2D.Gobject.Types  in '..\..\G_Types\G2D.Gobject.Types.pas',
  G2D.Gst.Types      in '..\..\G_Types\G2D.Gst.Types.pas';

{ ------------------------------------------------------------------ }
{ Helpers                                                             }
{ ------------------------------------------------------------------ }

procedure Pass(const AMsg: string);
begin
  Writeln('  [PASS] ', AMsg);
end;

procedure Fail(const AMsg: string);
begin
  Writeln('  [FAIL] ', AMsg);
end;

procedure Section(const ATitle: string);
begin
  Writeln;
  Writeln('=== ', ATitle, ' ===');
end;

{ ------------------------------------------------------------------ }
{ Test 1 — SimpleBuildAndPlay  (runs to EOS, no interaction)         }
{                                                                     }
{ Uses: audiotestsrc ! autoaudiosink                                  }
{ Exercises: Create, BuildAndPlay->RunFor loop inside                 }
{            SimpleBuildAndPlay, HasEOS, State,                       }
{            GstClockTimeToStr, Stop/Destroy                          }
{ ------------------------------------------------------------------ }
procedure Test1_SimpleBuildAndPlay;
var
  FW: TGstFramework;
begin
  Section('Test 1 — SimpleBuildAndPlay (audiotestsrc, 2 sec)');

  FW := TGstFramework.Create(True {WriteStateChange});
  try
    // audiotestsrc produces exactly num-buffers * buffer-size audio.
    // num-buffers=200 at 100 buf/sec  =>  ~2 seconds then EOS.
    if FW.SimpleBuildAndPlay(
         'audiotestsrc num-buffers=200 ! autoaudiosink',
         DoForEver)
    then
      Pass('SimpleBuildAndPlay returned True (clean EOS)')
    else
    begin
      if FW.HasEOS then
        Pass('EOS reached (SimpleBuildAndPlay returned False=no error)')
      else
        Fail('Error: ' + FW.LastErrorText);
    end;

    if FW.HasEOS then
      Pass('HasEOS = True after playback')
    else
      Fail('HasEOS should be True after EOS');

    if FW.LastErrorText = '' then
      Pass('No error text')
    else
      Fail('Unexpected error: ' + FW.LastErrorText);

  finally
    FW.Free;
  end;
end;

{ ------------------------------------------------------------------ }
{ Test 2 — BuildAndPlay + manual RunFor loop                         }
{                                                                     }
{ Uses: playbin with a local file or the Sintel trailer               }
{ Exercises: BuildAndPlay, RunFor, QueryPosition, QueryDuration,      }
{            SeekSimple, State, GstClockTimeToStr                     }
{ ------------------------------------------------------------------ }
procedure Test2_BuildAndPlayWithSeek(const AURI: string);
var
  FW: TGstFramework;
  Position, Duration: gint64;
  DidSeek, GotPos, GotDur: Boolean;
  LoopCount: Integer;
begin
  Section('Test 2 — BuildAndPlay + RunFor loop + Seek (' + AURI + ')');

  FW := TGstFramework.Create(True);
  try
    if not FW.BuildAndPlay('playbin uri=' + AURI) then
    begin
      Fail('BuildAndPlay failed');
      Exit;
    end;
    Pass('BuildAndPlay succeeded');

    DidSeek  := False;
    GotPos   := False;
    GotDur   := False;
    LoopCount := 0;

    while FW.RunFor(100 * GST_MSECOND) do
    begin
      Inc(LoopCount);

      { -- query position once we are playing -- }
      if (FW.State = GST_STATE_PLAYING) and not GotPos then
      begin
        if FW.QueryPosition(Position) then
        begin
          GotPos := True;
          Writeln('  Position at first query: ', GstClockTimeToStr(Position));
          Pass('QueryPosition returned data');
        end;
      end;

      { -- query duration (may take a few buffers to become available) -- }
      if (FW.State = GST_STATE_PLAYING) and not GotDur then
      begin
        if FW.QueryDuration(Duration) then
        begin
          GotDur := True;
          Writeln('  Duration: ', GstClockTimeToStr(Duration));
          Pass('QueryDuration returned data');
        end;
      end;

      { -- seek to 10 s once we have a duration -- }
      if GotDur and not DidSeek then
      begin
        DidSeek := True;
        if FW.SeekSimple(
             10 * gint64(GST_SECOND),
             GST_FORMAT_TIME,
             GST_SEEK_FLAG_FLUSH or GST_SEEK_FLAG_KEY_UNIT)
        then
          Pass('SeekSimple to 10 s succeeded')
        else
          Fail('SeekSimple failed');
      end;

      { -- stop after ~5 s of wall time (50 loop iterations × 100 ms) -- }
      if LoopCount >= 50 then
      begin
        Writeln('  (stopping after 5 s wall time)');
        Break;
      end;
    end;

    if FW.HasError then
      Fail('Pipeline error: ' + FW.LastErrorText)
    else
      Pass('No pipeline error during playback');

    if not GotPos then Fail('QueryPosition never succeeded');
    if not GotDur then Fail('QueryDuration never succeeded');
    if not DidSeek then Fail('Seek was never attempted');

  finally
    FW.Free;
  end;
end;

{ ------------------------------------------------------------------ }
{ Test 3 — Manual pipeline construction via framework API            }
{                                                                     }
{ Pipeline:  uridecodebin  --[dynamic pad]--> audioconvert            }
{                ! audioresample ! autoaudiosink                      }
{ Exercises: NewPipeline, MakeElement, AddElements, ConnectDynamicPad,}
{            LinkMany, PlayPipeline, RunFor, Stop                     }
{ ------------------------------------------------------------------ }
procedure Test3_ManualPipelineWithDynamicPad(const AURI: string);
var
  FW: TGstFramework;
  LoopCount: Integer;
begin
  Section('Test 3 — Manual pipeline: uridecodebin + dynamic pad (' + AURI + ')');

  FW := TGstFramework.Create(True);
  try
    { 1. Create the named pipeline }
    if not FW.NewPipeline('test3-pipeline') then
    begin
      Fail('NewPipeline failed');
      Exit;
    end;
    Pass('NewPipeline OK');

    { 2. Instantiate elements }
    if FW.MakeElement('uridecodebin', 'source')   = nil then begin Fail('MakeElement uridecodebin'); Exit; end;
    if FW.MakeElement('audioconvert', 'convert')  = nil then begin Fail('MakeElement audioconvert'); Exit; end;
    if FW.MakeElement('audioresample', 'resample') = nil then begin Fail('MakeElement audioresample'); Exit; end;
    if FW.MakeElement('autoaudiosink', 'sink')     = nil then begin Fail('MakeElement autoaudiosink'); Exit; end;
    Pass('All elements created');

    { 3. Add all elements to the pipeline }
    if not FW.AddElements(['source', 'convert', 'resample', 'sink']) then
    begin
      Fail('AddElements failed');
      Exit;
    end;
    Pass('AddElements OK');

    { 4. Set the URI on the source }
    FW.SetElementPropertyString('source', 'uri', AURI);
    Pass('URI property set');

    { 5. Register the dynamic-pad link: source -> convert:sink }
    if not FW.ConnectDynamicPad('source', 'convert') then
    begin
      Fail('ConnectDynamicPad failed');
      Exit;
    end;
    Pass('ConnectDynamicPad registered');

    { 6. Link the static chain: convert -> resample -> sink }
    if not FW.LinkMany(['convert', 'resample', 'sink']) then
    begin
      Fail('LinkMany failed');
      Exit;
    end;
    Pass('LinkMany OK');

    { 7. Start playing }
    if not FW.PlayPipeline then
    begin
      Fail('PlayPipeline failed');
      Exit;
    end;
    Pass('PlayPipeline OK');

    { 8. Pump the bus for up to 5 s }
    LoopCount := 0;
    while FW.RunFor(100 * GST_MSECOND) do
    begin
      Inc(LoopCount);
      if LoopCount >= 50 then
      begin
        Writeln('  (stopping after 5 s wall time)');
        Break;
      end;
    end;

    if FW.HasError then
      Fail('Pipeline error: ' + FW.LastErrorText)
    else
      Pass('No pipeline error during playback');

  finally
    FW.Free;   { calls Stop -> ClearPipeline internally }
  end;
end;

{ ------------------------------------------------------------------ }
{ Test 4 — Error handling: bad pipeline description                  }
{ Exercises: BuildAndPlay raising EG2DGstFrameworkError,             }
{            HasError, LastErrorText                                  }
{ ------------------------------------------------------------------ }
procedure Test4_ErrorHandling;
var
  FW: TGstFramework;
begin
  Section('Test 4 — Error handling (bad pipeline)');

  FW := TGstFramework.Create;
  try
    try
      FW.BuildAndPlay('nosuchelement name=x ! autoaudiosink');
      { BuildAndPlay raises on parse failure, but if it somehow
        returns False that is also acceptable }
      Fail('Expected exception was NOT raised for bad pipeline');
    except
      on E: EG2DGstFrameworkError do
        Pass('EG2DGstFrameworkError raised as expected: ' + E.Message);
      on E: Exception do
        Pass('Exception raised: ' + E.ClassName + ' — ' + E.Message);
    end;

    { After an exception the framework must still be in a clean state }
    if not FW.Started then
      Fail('FW.Started should still be True after error')
    else
      Pass('Framework still usable after error (Started=True)');

  finally
    FW.Free;
  end;
end;

{ ------------------------------------------------------------------ }
{ Main                                                                }
{ ------------------------------------------------------------------ }
var
  SintelURI: string;
begin
  Writeln('G2D TGstFramework — Console Test Suite');
  Writeln('========================================');

  SintelURI :=
    'https://www.freedesktop.org/software/gstreamer-sdk/' +
    'data/media/sintel_trailer-480p.webm';

  try
    Test1_SimpleBuildAndPlay;
    Test2_BuildAndPlayWithSeek(SintelURI);
    Test3_ManualPipelineWithDynamicPad(SintelURI);
    Test4_ErrorHandling;
  except
    on E: Exception do
      Writeln('UNEXPECTED EXCEPTION: ', E.ClassName, ': ', E.Message);
  end;

  Writeln;
  Writeln('========================================');
  Writeln('All tests finished. Press Enter to exit.');
  Readln;
end.

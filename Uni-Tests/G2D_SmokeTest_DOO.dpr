program G2D_SmokeTest_DOO;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Winapi.Windows,
  G2D.Glib.Types in '..\Types\G2D.Glib.Types.pas',
  G2D.Gobject.Types in '..\Types\G2D.Gobject.Types.pas',
  G2D.Gst.Types in '..\Types\G2D.Gst.Types.pas',
  G2D.Glib.API in '..\G_API\G2D.Glib.API.pas',
  G2D.Gobject.API in '..\G_API\G2D.Gobject.API.pas',
  G2D.Gst.API in '..\G_API\G2D.Gst.API.pas',
  G2D.Gobject.DOO in '..\DOObase\G2D.Gobject.DOO.pas',
  G2D.GstElement.DOO in '..\DOObase\G2D.GstElement.DOO.pas',
  G2D.GstBus.DOO in '..\DOObase\G2D.GstBus.DOO.pas',
  G2D.GstObject.DOO in '..\DOObase\G2D.GstObject.DOO.pas',
  G2D.GstMessage.DOO in '..\DOObase\G2D.GstMessage.DOO.pas';

procedure AssertTrue(ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create('ASSERT FAILED: ' + AMessage);
end;

function Utf8Pgchar(const S: string): Pgchar;
begin
  Result := Pgchar(PAnsiChar(UTF8String(S)));
end;

procedure Test_GObject_DOO;
var
  T1: GType;
  H1: PGObject;
  O1: TGObjectRef;
  V1: gint;
  P1: Pointer;
begin
  Writeln('Test_GObject_DOO...');

  AssertTrue(G2D_LoadGlib, 'GLib load failed');
  AssertTrue(G2D_LoadGobject, 'GObject load failed');

  T1 := _g_type_from_name(Utf8Pgchar('GObject'));
  AssertTrue(T1 <> 0, 'GObject type not found');

  H1 := PGObject(_g_object_new(T1, nil));
  AssertTrue(H1 <> nil, 'g_object_new returned nil');

  O1 := TGObjectRef.Wrap(H1, False, True);

  try
    Writeln('  Handle assigned');

    Writeln('  IsFloating before RefSink = ', Ord(O1.IsFloating));

    O1.RefSink;

    Writeln('  IsFloating after RefSink  = ', Ord(O1.IsFloating));

    V1 := 123456;

    O1.SetData('my-int', @V1);
    P1 := O1.GetData('my-int');

    AssertTrue(P1 <> nil, 'GetData returned nil');
    AssertTrue(Pgint(P1)^ = 123456, 'GetData returned wrong value');

    Writeln('  Stored value = ', Pgint(P1)^);
    Writeln('  OK');

  finally
    O1.Free;
  end;
end;

procedure Test_Gst_DOO;
var
  P1: TGstElementRef;
  Ret: GstStateChangeReturn;
begin
  Writeln('Test_Gst_DOO...');

  AssertTrue(G2D_LoadGst, 'GStreamer load failed');

  _gst_init(nil, nil);

  AssertTrue(_gst_is_initialized() <> 0, 'GStreamer failed to initialize');

  P1 := TGstElementRef.Parse('videotestsrc ! autovideosink');

  try
    Writeln('  Parsed pipeline');
    Writeln('  Name = "', P1.GetName, '"');

    Ret := P1.Play;

    AssertTrue(
      Ret <> GST_STATE_CHANGE_FAILURE,
      'Play failed'
    );

    Writeln('  Pipeline running for 3 seconds...');
    Sleep(3000);

    Ret := P1.Null;

    AssertTrue(
      Ret <> GST_STATE_CHANGE_FAILURE,
      'Null failed'
    );

    Writeln('  Pipeline returned to NULL');
    Writeln('  OK');

  finally
    P1.Free;
  end;
end;

procedure Test_Gst_FactoryMake;
var
  Src  : TGstElementRef;
  Sink : TGstElementRef;
  Ret  : GstStateChangeReturn;
begin
  Writeln('Test_Gst_FactoryMake...');

  Src  := TGstElementRef.FactoryMake('videotestsrc','src');
  Sink := TGstElementRef.FactoryMake('fakesink','sink');

  try
    AssertTrue(Src <> nil,  'FactoryMake videotestsrc failed');
    AssertTrue(Sink <> nil, 'FactoryMake fakesink failed');

    Writeln('  Elements created');

    AssertTrue(Src.Link(Sink),'Link failed');

    Writeln('  Elements linked');

    Ret := Src.Play;

    AssertTrue(
      Ret <> GST_STATE_CHANGE_FAILURE,
      'Play failed'
    );

    Writeln('  Running for 2 seconds...');
    Sleep(2000);

    Src.Null;

    Writeln('  OK');

  finally
    Src.Free;
    Sink.Free;
  end;
end;
procedure Test_Gst_Pipeline3;
var
  Pipeline: TGstElementRef;
  Src     : TGstElementRef;
  Conv    : TGstElementRef;
  Sink    : TGstElementRef;
  Ret     : GstStateChangeReturn;
begin
  Writeln('Test_Gst_Pipeline3...');

  Pipeline := TGstElementRef.Wrap(
                _gst_pipeline_new(Utf8Pgchar('doo-pipeline')),
                False,
                True
              );
  AssertTrue(Pipeline <> nil, 'Pipeline creation failed');

  Src  := TGstElementRef.FactoryMake('videotestsrc',  'src');
  Conv := TGstElementRef.FactoryMake('videoconvert',  'conv');
  Sink := TGstElementRef.FactoryMake('autovideosink', 'sink');

  try
    Writeln('  Elements created');

    AssertTrue(
      _gst_bin_add(gpointer(Pipeline.ElementHandle), Src.ElementHandle) <> 0,
      'Add src failed'
    );

    AssertTrue(
      _gst_bin_add(gpointer(Pipeline.ElementHandle), Conv.ElementHandle) <> 0,
      'Add conv failed'
    );

    AssertTrue(
      _gst_bin_add(gpointer(Pipeline.ElementHandle), Sink.ElementHandle) <> 0,
      'Add sink failed'
    );

    Writeln('  Elements added to pipeline');

    AssertTrue(Src.Link(Conv),  'Link src->conv failed');
    AssertTrue(Conv.Link(Sink), 'Link conv->sink failed');

    Writeln('  Elements linked');

    Ret := Pipeline.Play;

    AssertTrue(
      Ret <> GST_STATE_CHANGE_FAILURE,
      'Play failed'
    );

    Writeln('  Running pipeline for 3 seconds...');
    Sleep(3000);

    Ret := Pipeline.Null;

    AssertTrue(
      Ret <> GST_STATE_CHANGE_FAILURE,
      'Null failed'
    );

    Writeln('  Pipeline returned to NULL');
    Writeln('  OK');

  finally
    Sink.OwnsRef := False;
    Conv.OwnsRef := False;
    Src.OwnsRef := False;

    Sink.Free;
    Conv.Free;
    Src.Free;
    Pipeline.Free;
  end;
end;

procedure Test_GstBus;
var
  Pipeline : TGstElementRef;
  Bus      : TGstBusRef;
  Msg      : PGstMessage;
begin
  Writeln('Test_GstBus...');

  Pipeline := TGstElementRef.Parse(
                'videotestsrc num-buffers=50 ! autovideosink'
              );

  try
    Bus := Pipeline.GetBus;

    Pipeline.Play;

    Msg := Bus.TimedPopFiltered(
             GST_CLOCK_TIME_NONE,
             GST_MESSAGE_EOS or GST_MESSAGE_ERROR
           );

    AssertTrue(Msg <> nil, 'No message received');

    Writeln('  Message type: ', TGstBusRef.MessageTypeName(Msg));

    _gst_mini_object_unref(PGstMiniObject(Msg));

    Pipeline.Null;

    Writeln('  OK');

  finally
    Bus.Free;
    Pipeline.Free;
  end;
end;

procedure Test_GstBus_Message_DOO;
var
  Pipeline : TGstElementRef;
  Bus      : TGstBusRef;
  Msg      : TGstMessageRef;
  Done     : Boolean;
begin
  Writeln('Test_GstBus_Message_DOO...');

  Pipeline := TGstElementRef.Parse(
                'videotestsrc num-buffers=30 ! videoconvert ! autovideosink'
              );

  try
    AssertTrue(Pipeline <> nil, 'Pipeline creation failed');

    Bus := Pipeline.GetBus;
    AssertTrue(Bus <> nil, 'GetBus failed');

    Pipeline.Play;

    Done := False;

    while not Done do
    begin
      Msg := Bus.TimedPopMessage(
               GST_CLOCK_TIME_NONE,
               GST_MESSAGE_STATE_CHANGED or
               GST_MESSAGE_ERROR or
               GST_MESSAGE_EOS
             );

      AssertTrue(Msg <> nil, 'TimedPopMessage returned nil');

      Writeln('  Message: ', Msg.MessageTypeName);

      if Msg.IsStateChanged then
        Writeln('   ', Msg.StateChangedToText);

      if Msg.IsEOS then
      begin
        Writeln('  EOS received');
        Done := True;
      end;

      if Msg.IsError then
      begin
        Writeln('  ERROR message received');
        AssertTrue(False, 'Unexpected ERROR message');
      end;

      Msg.Free;
    end;

    Pipeline.Null;

    Writeln('  OK');

  finally
    Bus.Free;
    Pipeline.Free;
  end;
end;

begin
  try
    Writeln('=== GObject / Gst DOO SmokeTest ===');

    Test_GObject_DOO;
    Test_Gst_DOO;
    Test_Gst_FactoryMake;
    Test_Gst_Pipeline3;
    Test_GstBus;
    Test_GstBus_Message_DOO;

    Writeln('=== ALL TESTS PASSED ===');

  except
    on E: Exception do
    begin
      Writeln;
      Writeln('TEST FAILED');
      Writeln(E.ClassName + ': ' + E.Message);
      ExitCode := 1;
    end;
  end;

  Readln;
end.

program G2D_SmokeTest_Gobject_DOO_n1;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Winapi.Windows,
  G2D.Glib.Types,
  G2D.Gobject.Types,
  G2D.Gst.Types,
  G2D.Glib.API,
  G2D.Gobject.API,
  G2D.Gst.API,
  G2D.Gobject.DOO,
  G2D.GstObject.DOO,
  G2D.GstElement.DOO,
  G2D.GstBus.DOO,
  G2D.GstMessage.DOO,
  G2D.GstBin.DOO,
  G2D.GstPipeline.DOO,
  G2D.GstPad.DOO,
  G2D.GstFramework;

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
  T1 := _g_type_from_name(Utf8Pgchar('GObject'));
  AssertTrue(T1 <> 0, 'GObject type not found');

  H1 := PGObject(_g_object_new(T1, nil));
  AssertTrue(H1 <> nil, 'g_object_new returned nil');

  O1 := nil;
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

procedure Test_GObject_Properties_DOO;
var
  Src: TGstElementRef;
  I: Integer;
  B: Boolean;
  S: string;
begin
  Writeln('Test_GObject_Properties_DOO...');

  Src := nil;

  Src := TGstElementRef.FactoryMake('videotestsrc', 'prop-src');

  try
    AssertTrue(Src <> nil, 'FactoryMake videotestsrc failed');

    Src.SetPropertyInt('num-buffers', 17);
    I := Src.GetPropertyInt('num-buffers');
    AssertTrue(I = 17, 'num-buffers property mismatch');

    Writeln('  num-buffers = ', I);

    Src.SetPropertyBool('is-live', True);
    B := Src.GetPropertyBool('is-live');
    AssertTrue(B = True, 'is-live property mismatch');

    Writeln('  is-live = ', Ord(B));

    Src.SetPropertyString('name', 'prop-src-renamed');
    S := Src.GetPropertyString('name');
    AssertTrue(S = 'prop-src-renamed', 'name property mismatch');

    Writeln('  name = "', S, '"');
    Writeln('  OK');
  finally
    Src.Free;
  end;
end;

procedure Test_Gst_DOO;
var
  P1: TGstElementRef;
  Ret: GstStateChangeReturn;
begin
  Writeln('Test_Gst_DOO...');

  P1 := nil;
  P1 := TGstElementRef.Parse('videotestsrc ! autovideosink');

  try
    AssertTrue(P1 <> nil, 'Parse returned nil');

    Writeln('  Parsed pipeline');
    Writeln('  Name = "', P1.GetName, '"');

    Ret := P1.Play;
    AssertTrue(Ret <> GST_STATE_CHANGE_FAILURE, 'Play failed');

    Writeln('  Pipeline running for 3 seconds...');
    Sleep(3000);

    Ret := P1.Null;
    AssertTrue(Ret <> GST_STATE_CHANGE_FAILURE, 'Null failed');

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

  Src := nil;
  Sink := nil;

  Src  := TGstElementRef.FactoryMake('videotestsrc', 'src');
  Sink := TGstElementRef.FactoryMake('autovideosink', 'sink');

  try
    AssertTrue(Src <> nil,  'FactoryMake videotestsrc failed');
    AssertTrue(Sink <> nil, 'FactoryMake autovideosink failed');

    Writeln('  Elements created');

    AssertTrue(Src.Link(Sink), 'Link failed');

    Writeln('  Elements linked');

    Ret := Src.Play;
    AssertTrue(Ret <> GST_STATE_CHANGE_FAILURE, 'Play failed');

    Writeln('  Running for 2 seconds...');
    Sleep(2000);

    Src.Null;

    Writeln('  OK');
  finally
    Src.Free;
    Sink.Free;
  end;
end;

procedure Test_GstPipeline_DOO;
var
  Pipeline : TGstPipelineRef;
  Src      : TGstElementRef;
  Conv     : TGstElementRef;
  Sink     : TGstElementRef;
  Ret      : GstStateChangeReturn;
begin
  Writeln('Test_GstPipeline_DOO...');

  Pipeline := nil;
  Src := nil;
  Conv := nil;
  Sink := nil;

  Pipeline := TGstPipelineRef.CreateNamed('doo-pipeline');
  AssertTrue(Pipeline <> nil, 'Pipeline creation failed');

  Src  := TGstElementRef.FactoryMake('videotestsrc',  'src');
  Conv := TGstElementRef.FactoryMake('videoconvert',  'conv');
  Sink := TGstElementRef.FactoryMake('autovideosink', 'sink');

  try
    AssertTrue(Src <> nil,  'FactoryMake videotestsrc failed');
    AssertTrue(Conv <> nil, 'FactoryMake videoconvert failed');
    AssertTrue(Sink <> nil, 'FactoryMake autovideosink failed');

    Writeln('  Elements created');

    AssertTrue(Pipeline.Add(Src),  'Add src failed');
    AssertTrue(Pipeline.Add(Conv), 'Add conv failed');
    AssertTrue(Pipeline.Add(Sink), 'Add sink failed');

    Writeln('  Elements added to pipeline');

    AssertTrue(Src.Link(Conv),  'Link src->conv failed');
    AssertTrue(Conv.Link(Sink), 'Link conv->sink failed');

    Writeln('  Elements linked');

    AssertTrue(Pipeline.HasElement('src'),  'Pipeline.HasElement(src) failed');
    AssertTrue(Pipeline.HasElement('conv'), 'Pipeline.HasElement(conv) failed');
    AssertTrue(Pipeline.HasElement('sink'), 'Pipeline.HasElement(sink) failed');

    Writeln('  Pipeline element lookup OK');

    Ret := Pipeline.Play;
    AssertTrue(Ret <> GST_STATE_CHANGE_FAILURE, 'Play failed');

    Writeln('  Running pipeline for 3 seconds...');
    Sleep(3000);

    Ret := Pipeline.Null;
    AssertTrue(Ret <> GST_STATE_CHANGE_FAILURE, 'Null failed');

    Writeln('  Pipeline returned to NULL');
    Writeln('  OK');
  finally
    if Sink <> nil then
      Sink.OwnsRef := False;
    if Conv <> nil then
      Conv.OwnsRef := False;
    if Src <> nil then
      Src.OwnsRef := False;

    Sink.Free;
    Conv.Free;
    Src.Free;
    Pipeline.Free;
  end;
end;

procedure Test_GstBin_DOO;
var
  Pipeline : TGstPipelineRef;
  Src      : TGstElementRef;
  Conv     : TGstElementRef;
  Sink     : TGstElementRef;
  Found    : TGstElementRef;
  Missing  : TGstElementRef;
  Ret      : GstStateChangeReturn;
begin
  Writeln('Test_GstBin_DOO...');

  Pipeline := nil;
  Src := nil;
  Conv := nil;
  Sink := nil;
  Found := nil;
  Missing := nil;

  Pipeline := TGstPipelineRef.CreateNamed('bin-test-pipeline');
  AssertTrue(Pipeline <> nil, 'Pipeline creation failed');

  Src  := TGstElementRef.FactoryMake('videotestsrc',  'src');
  Conv := TGstElementRef.FactoryMake('videoconvert',  'conv');
  Sink := TGstElementRef.FactoryMake('autovideosink', 'sink');

  try
    AssertTrue(Src <> nil,  'FactoryMake videotestsrc failed');
    AssertTrue(Conv <> nil, 'FactoryMake videoconvert failed');
    AssertTrue(Sink <> nil, 'FactoryMake autovideosink failed');

    AssertTrue(Pipeline.Add(Src),  'Add src failed');
    AssertTrue(Pipeline.Add(Conv), 'Add conv failed');
    AssertTrue(Pipeline.Add(Sink), 'Add sink failed');

    Writeln('  Elements added');

    AssertTrue(Pipeline.HasElement('src'),  'HasElement(src) failed');
    AssertTrue(Pipeline.HasElement('conv'), 'HasElement(conv) failed');
    AssertTrue(Pipeline.HasElement('sink'), 'HasElement(sink) failed');

    Found := Pipeline.GetByName('conv');
    AssertTrue(Found <> nil, 'GetByName(conv) returned nil');
    AssertTrue(Found.GetName = 'conv', 'GetByName(conv) returned wrong element');

    Writeln('  GetByName("conv") OK');

    Missing := Pipeline.GetByName('no-such-element');
    AssertTrue(Missing = nil, 'GetByName(no-such-element) should return nil');

    Writeln('  Missing-name lookup OK');

    Ret := Pipeline.Play;
    AssertTrue(Ret <> GST_STATE_CHANGE_FAILURE, 'Play failed');

    Writeln('  Running pipeline for 3 seconds...');
    Sleep(3000);

    Ret := Pipeline.Null;
    AssertTrue(Ret <> GST_STATE_CHANGE_FAILURE, 'Null failed');

    Writeln('  Visual run OK');

    AssertTrue(Pipeline.Remove(Conv), 'Remove conv failed');

    Writeln('  Remove(conv) OK');

    AssertTrue(not Pipeline.HasElement('conv'), 'conv still found after Remove');
    AssertTrue(Pipeline.HasElement('src'), 'src should still exist after conv Remove');
    AssertTrue(Pipeline.HasElement('sink'), 'sink should still exist after conv Remove');

    Writeln('  Post-remove checks OK');
    Writeln('  OK');
  finally
    Found.Free;
    Missing.Free;

    if Sink <> nil then
      Sink.OwnsRef := False;
    if Conv <> nil then
      Conv.OwnsRef := False;
    if Src <> nil then
      Src.OwnsRef := False;

    Sink.Free;
    Conv.Free;
    Src.Free;
    Pipeline.Free;
  end;
end;

procedure Test_GstPad_DOO;
var
  Src     : TGstElementRef;
  Conv    : TGstElementRef;
  SrcPad  : TGstPadRef;
  SinkPad : TGstPadRef;
  ParentE : TGstElementRef;
  R       : GstPadLinkReturn;
begin
  Writeln('Test_GstPad_DOO...');

  Src := nil;
  Conv := nil;
  SrcPad := nil;
  SinkPad := nil;
  ParentE := nil;

  Src  := TGstElementRef.FactoryMake('videotestsrc', 'pad-src');
  Conv := TGstElementRef.FactoryMake('videoconvert', 'pad-conv');

  try
    AssertTrue(Src <> nil, 'FactoryMake videotestsrc failed');
    AssertTrue(Conv <> nil, 'FactoryMake videoconvert failed');

    SrcPad := TGstPadRef.Wrap(Src.GetStaticPad('src'), False, True);
    SinkPad := TGstPadRef.Wrap(Conv.GetStaticPad('sink'), False, True);

    AssertTrue(SrcPad <> nil, 'GetStaticPad(src) returned nil');
    AssertTrue(SinkPad <> nil, 'GetStaticPad(sink) returned nil');

    Writeln('  SrcPad name  = "', SrcPad.GetName, '"');
    Writeln('  SinkPad name = "', SinkPad.GetName, '"');

    AssertTrue(not SrcPad.IsLinked, 'SrcPad should not be linked yet');
    AssertTrue(not SinkPad.IsLinked, 'SinkPad should not be linked yet');

    ParentE := SinkPad.GetParentElement;
    AssertTrue(ParentE <> nil, 'GetParentElement returned nil');
    AssertTrue(ParentE.GetName = 'pad-conv', 'GetParentElement returned wrong element');

    Writeln('  Parent element of sink pad = "', ParentE.GetName, '"');

    R := SrcPad.LinkTo(SinkPad);
    AssertTrue(
      R = GST_PAD_LINK_OK,
      'Pad link failed: ' + TGstPadRef.LinkResultToString(R)
    );

    Writeln('  Link result = ', TGstPadRef.LinkResultToString(R));

    AssertTrue(SrcPad.IsLinked, 'SrcPad should be linked');
    AssertTrue(SinkPad.IsLinked, 'SinkPad should be linked');

    AssertTrue(SrcPad.UnlinkFrom(SinkPad), 'Pad unlink failed');

    Writeln('  Pads unlinked');

    AssertTrue(not SrcPad.IsLinked, 'SrcPad should not be linked after unlink');
    AssertTrue(not SinkPad.IsLinked, 'SinkPad should not be linked after unlink');

    Writeln('  OK');
  finally
    ParentE.Free;
    SinkPad.Free;
    SrcPad.Free;
    Conv.Free;
    Src.Free;
  end;
end;

procedure Test_GstBus;
var
  Pipeline : TGstPipelineRef;
  Src      : TGstElementRef;
  Conv     : TGstElementRef;
  Sink     : TGstElementRef;
  Bus      : TGstBusRef;
  Msg      : PGstMessage;
begin
  Writeln('Test_GstBus...');

  Pipeline := nil;
  Src := nil;
  Conv := nil;
  Sink := nil;
  Bus := nil;
  Msg := nil;

  Pipeline := TGstPipelineRef.CreateNamed('bus-test');
  AssertTrue(Pipeline <> nil, 'Pipeline creation failed');

  Src  := TGstElementRef.FactoryMake('videotestsrc', 'src');
  Conv := TGstElementRef.FactoryMake('videoconvert', 'conv');
  Sink := TGstElementRef.FactoryMake('autovideosink', 'sink');

  try
    AssertTrue(Src <> nil, 'FactoryMake videotestsrc failed');
    AssertTrue(Conv <> nil, 'FactoryMake videoconvert failed');
    AssertTrue(Sink <> nil, 'FactoryMake autovideosink failed');

    Src.SetPropertyInt('num-buffers', 50);

    AssertTrue(Pipeline.Add(Src), 'Add src failed');
    AssertTrue(Pipeline.Add(Conv), 'Add conv failed');
    AssertTrue(Pipeline.Add(Sink), 'Add sink failed');

    AssertTrue(Src.Link(Conv), 'Link src->conv failed');
    AssertTrue(Conv.Link(Sink), 'Link conv->sink failed');

    Bus := Pipeline.GetBusRef;
    AssertTrue(Bus <> nil, 'GetBusRef failed');

    Pipeline.Play;

    Msg := Bus.TimedPopFiltered(
             GST_CLOCK_TIME_NONE,
             GST_MESSAGE_EOS or GST_MESSAGE_ERROR
           );

    AssertTrue(Msg <> nil, 'No message received');

    Writeln('  Message type: ', TGstBusRef.MessageTypeName(Msg));

    _gst_mini_object_unref(PGstMiniObject(Msg));
    Msg := nil;

    Pipeline.Null;

    Writeln('  OK');
  finally
    if Sink <> nil then
      Sink.OwnsRef := False;
    if Conv <> nil then
      Conv.OwnsRef := False;
    if Src <> nil then
      Src.OwnsRef := False;

    Sink.Free;
    Conv.Free;
    Src.Free;
    Bus.Free;
    Pipeline.Free;
  end;
end;

procedure Test_GstBus_Message_DOO;
var
  Pipeline : TGstPipelineRef;
  Src      : TGstElementRef;
  Conv     : TGstElementRef;
  Sink     : TGstElementRef;
  Bus      : TGstBusRef;
  Msg      : TGstMessageRef;
  Done     : Boolean;
begin
  Writeln('Test_GstBus_Message_DOO...');

  Pipeline := nil;
  Src := nil;
  Conv := nil;
  Sink := nil;
  Bus := nil;
  Msg := nil;

  Pipeline := TGstPipelineRef.CreateNamed('bus-msg-test');
  AssertTrue(Pipeline <> nil, 'Pipeline creation failed');

  Src  := TGstElementRef.FactoryMake('videotestsrc', 'src');
  Conv := TGstElementRef.FactoryMake('videoconvert', 'conv');
  Sink := TGstElementRef.FactoryMake('autovideosink', 'sink');

  try
    AssertTrue(Src <> nil, 'FactoryMake videotestsrc failed');
    AssertTrue(Conv <> nil, 'FactoryMake videoconvert failed');
    AssertTrue(Sink <> nil, 'FactoryMake autovideosink failed');

    Src.SetPropertyInt('num-buffers', 30);

    AssertTrue(Pipeline.Add(Src), 'Add src failed');
    AssertTrue(Pipeline.Add(Conv), 'Add conv failed');
    AssertTrue(Pipeline.Add(Sink), 'Add sink failed');

    AssertTrue(Src.Link(Conv), 'Link src->conv failed');
    AssertTrue(Conv.Link(Sink), 'Link conv->sink failed');

    Bus := Pipeline.GetBusRef;
    AssertTrue(Bus <> nil, 'GetBusRef failed');

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
      Msg := nil;
    end;

    Pipeline.Null;

    Writeln('  OK');
  finally
    Msg.Free;

    if Sink <> nil then
      Sink.OwnsRef := False;
    if Conv <> nil then
      Conv.OwnsRef := False;
    if Src <> nil then
      Src.OwnsRef := False;

    Sink.Free;
    Conv.Free;
    Src.Free;
    Bus.Free;
    Pipeline.Free;
  end;
end;

begin
  try
    Writeln('=== GObject / Gst DOO SmokeTest ===');
    GstInit;
    Test_GObject_DOO;
    Test_GObject_Properties_DOO;
    //Test_Gst_DOO;
    //Test_Gst_FactoryMake;
    //Test_GstPipeline_DOO;
    //Test_GstBin_DOO;
    Test_GstPad_DOO;
    //Test_GstBus;
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

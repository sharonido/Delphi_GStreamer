program TestGetByName;
{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  G2D.Glib.API,
  G2D.Gobject.API,
  G2D.Gst.API,
  G2D.Gst.Types,
  G2D.GstPipeline.DOO,
  G2D.GstBin.DOO,
  G2D.GstElement.DOO;

procedure Test_GetByName_ReturnsCorrectElement;
var
  Pipeline: TGstPipelineRef;
  Elem1, Elem2: TGstElementRef;
begin
  Write('Test_GetByName_ReturnsCorrectElement ... ');

  Pipeline := TGstPipelineRef.New('test-pipe');
  try
    // Make and add a known element
    Pipeline.MakeElement('fakesrc', 'my-fakesrc');
    Pipeline.AddElement('my-fakesrc');

    // Now retrieve it by name
    Elem1 := Pipeline.GetByName('my-fakesrc');
    try
      if Elem1 = nil then
      begin
        Writeln('FAIL — GetByName returned nil');
        Exit;
      end;

      if Elem1.GetName <> 'my-fakesrc' then
      begin
        Writeln('FAIL — wrong name: ' + Elem1.GetName);
        Exit;
      end;
    finally
      Elem1.Free;
    end;

    // --- KEY TEST ---
    // After freeing the wrapper, the element must still be alive in the bin.
    // If GetByName does NOT addref and we free the wrapper, a second lookup
    // would return nil or crash if the element was prematurely destroyed.
    Elem2 := Pipeline.GetByName('my-fakesrc');
    try
      if Elem2 = nil then
      begin
        Writeln('FAIL — element was destroyed after wrapper Free (missing addref)');
        Exit;
      end;

      if Elem2.GetName <> 'my-fakesrc' then
      begin
        Writeln('FAIL — second lookup returned wrong element: ' + Elem2.GetName);
        Exit;
      end;
    finally
      Elem2.Free;
    end;

    Writeln('PASS');
  finally
    Pipeline.Free;
  end;
end;

procedure Test_GetByName_UnknownReturnsNil;
var
  Pipeline: TGstPipelineRef;
  Elem: TGstElementRef;
begin
  Write('Test_GetByName_UnknownReturnsNil ... ');

  Pipeline := TGstPipelineRef.New('test-pipe2');
  try
    Elem := Pipeline.GetByName('does-not-exist');
    if Elem <> nil then
    begin
      Elem.Free;
      Writeln('FAIL — expected nil for unknown name');
      Exit;
    end;
    Writeln('PASS');
  finally
    Pipeline.Free;
  end;
end;

procedure Test_GetByName_RefCountSafe;
var
  Pipeline: TGstPipelineRef;
  E1, E2, E3: TGstElementRef;
begin
  Write('Test_GetByName_RefCountSafe (triple lookup) ... ');

  Pipeline := TGstPipelineRef.New('test-pipe3');
  try
    Pipeline.MakeElement('fakesrc', 'src');
    Pipeline.AddElement('src');

    // Get the same element 3 times and free each wrapper —
    // the element must survive all of them
    E1 := Pipeline.GetByName('src');
    E1.Free;

    E2 := Pipeline.GetByName('src');
    E2.Free;

    E3 := Pipeline.GetByName('src');
    try
      if E3 = nil then
      begin
        Writeln('FAIL — element destroyed after repeated Get/Free cycles');
        Exit;
      end;
      Writeln('PASS');
    finally
      E3.Free;
    end;
  finally
    Pipeline.Free;
  end;
end;

procedure Test_GetByName_DirectFromBin;
var
  Pipeline: TGstPipelineRef;
  BinRef: TGstBinRef;
  Elem1, Elem2: TGstElementRef;
begin
  Write('Test_GetByName_DirectFromBin ... ');

  // Parse a pipeline string — elements are created by GStreamer internally,
  // NOT stored in FElements, so GetByName MUST go to gst_bin_get_by_name
  Pipeline := TGstPipelineRef.Parse('fakesrc name=my-src ! fakesink name=my-sink');
  try
    // Cast to TGstBinRef to call GetByName directly, bypassing
    // TGstPipelineRef.GetElement and its FElements cache entirely
    BinRef := TGstBinRef(Pipeline);

    // First lookup
    Elem1 := BinRef.GetByName('my-src');
    try
      if Elem1 = nil then
      begin
        Writeln('FAIL — first GetByName returned nil');
        Exit;
      end;
      if Elem1.GetName <> 'my-src' then
      begin
        Writeln('FAIL — wrong element name: ' + Elem1.GetName);
        Exit;
      end;
    finally
      Elem1.Free;
    end;

    // KEY TEST: after freeing the wrapper, element must still be alive in the bin
    Elem2 := BinRef.GetByName('my-src');
    try
      if Elem2 = nil then
      begin
        Writeln('FAIL — element destroyed after first wrapper Free (ref-count bug)');
        Exit;
      end;
    finally
      Elem2.Free;
    end;

    Writeln('PASS');
  finally
    Pipeline.Free;
  end;
end;

begin
  try
    G2D_LoadGlib;
    G2D_LoadGobject;
    G2D_LoadGst;
    _gst_init(nil, nil);

    Writeln('=== TGstBinRef.GetByName Tests ===');
    Writeln;

    Test_GetByName_ReturnsCorrectElement;
    Test_GetByName_UnknownReturnsNil;
    Test_GetByName_RefCountSafe;
    Test_GetByName_DirectFromBin;

    Writeln;
    Writeln('=== Done ===');
  except
    on E: Exception do
      Writeln('EXCEPTION: ', E.Message);
  end;

  Readln;
end.

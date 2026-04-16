unit G2D.GstApp.DOO;

interface

uses
  System.SysUtils,
  G2D.Glib.Types,
  G2D.Gobject.Types,
  G2D.Gst.Types,
  G2D.Gobject.DOO,
  G2D.GstObject.DOO,
  G2D.GstElement.DOO,
  G2D.Gobject.API,
  G2D.Gst.API;

type
  EG2DGstAppError = class(Exception);

  { Callback types for appsrc signals }
  TGstNeedDataCallback    = procedure(source: PGstElement; size: guint; data: gpointer); cdecl;
  TGstEnoughDataCallback  = procedure(source: PGstElement; data: gpointer); cdecl;

  { Callback type for appsink signal }
  TGstNewSampleCallback   = function(sink: PGstElement; data: gpointer): GstFlowReturn; cdecl;

{==============================================================================
  TGstAppSrcRef - wrapper for appsrc element
==============================================================================}

  TGstAppSrcRef = class(TGstElementRef)
  public
    constructor Create(AHandle: PGstElement; AAddRef: Boolean = False; AOwnsRef: Boolean = True);
    class function Wrap(AHandle: PGstElement; AAddRef: Boolean = False; AOwnsRef: Boolean = True): TGstAppSrcRef;
    class function Make(const AName: string): TGstAppSrcRef;

    { Configuration }
    procedure SetCaps(ACaps: PGstCaps);
    procedure SetFormat(AFormat: GstFormat);
    procedure SetIsLive(AValue: Boolean);
    procedure SetMinLatency(AValue: gint64);
    procedure SetMaxLatency(AValue: gint64);
    procedure SetMaxBytes(AValue: guint64);
    procedure SetBlockOnFull(AValue: Boolean);

    { Data injection }
    function PushBuffer(ABuffer: PGstBuffer): GstFlowReturn;
    function PushSample(ASample: gpointer): GstFlowReturn;
    function EndOfStream: GstFlowReturn;

    { Signal connections }
    function ConnectNeedData(ACallback: TGstNeedDataCallback; AUserData: gpointer = nil): gulong;
    function ConnectEnoughData(ACallback: TGstEnoughDataCallback; AUserData: gpointer = nil): gulong;
  end;

{==============================================================================
  TGstAppSinkRef - wrapper for appsink element
==============================================================================}

  TGstAppSinkRef = class(TGstElementRef)
  public
    constructor Create(AHandle: PGstElement; AAddRef: Boolean = False; AOwnsRef: Boolean = True);
    class function Wrap(AHandle: PGstElement; AAddRef: Boolean = False; AOwnsRef: Boolean = True): TGstAppSinkRef;
    class function Make(const AName: string): TGstAppSinkRef;

    { Configuration }
    procedure SetCaps(ACaps: PGstCaps);
    procedure SetEmitSignals(AValue: Boolean);
    procedure SetMaxBuffers(AValue: guint);
    procedure SetDrop(AValue: Boolean);
    procedure SetSync(AValue: Boolean);

    { Data extraction }
    // Returns a sample pointer - caller must call SampleUnref when done
    function PullSample: gpointer;
    procedure SampleUnref(ASample: gpointer);

    // Convenience: pull sample, copy buffer data to ADest, unref sample
    // Returns True if a sample was available and data was copied
    function PullSampleData(ADest: Pointer; AMaxSize: gsize; out ABytesRead: gsize): Boolean;

    { Signal connection }
    function ConnectNewSample(ACallback: TGstNewSampleCallback; AUserData: gpointer = nil): gulong;
  end;

{==============================================================================
  TGstSampleRef - thin owner wrapper for a GstSample
  Constructed with a raw sample pointer that is already owned by the caller
  (e.g. pulled from appsink). Destructor unrefs exactly once.
==============================================================================}

  TGstSampleRef = class
  private
    FHandle: gpointer;
  public
    constructor Create(AHandle: gpointer);
    destructor Destroy; override;

    { Accessors - returned pointers are valid only while this object lives }
    function GetBuffer: PGstBuffer;
    function GetCaps: PGstCaps;

    property Handle: gpointer read FHandle;
  end;

implementation

{==============================================================================
  TGstAppSrcRef implementation
==============================================================================}

constructor TGstAppSrcRef.Create(AHandle: PGstElement; AAddRef: Boolean; AOwnsRef: Boolean);
begin
  inherited Create(AHandle, AAddRef, AOwnsRef);
end;

class function TGstAppSrcRef.Wrap(AHandle: PGstElement; AAddRef: Boolean; AOwnsRef: Boolean): TGstAppSrcRef;
begin
  if AHandle = nil then
    Exit(nil);
  Result := TGstAppSrcRef.Create(AHandle, AAddRef, AOwnsRef);
end;

class function TGstAppSrcRef.Make(const AName: string): TGstAppSrcRef;
var
  LHandle: PGstElement;
  LFactory: UTF8String;
  LName: UTF8String;
begin
  LFactory := UTF8String('appsrc');
  LName    := UTF8String(AName);
  LHandle  := _gst_element_factory_make(
                Pgchar(PAnsiChar(LFactory)),
                Pgchar(PAnsiChar(LName))
              );
  if LHandle = nil then
    raise EG2DGstAppError.CreateFmt('Failed to create appsrc element: %s', [AName]);
  Result := TGstAppSrcRef.Create(LHandle, False, True);
end;

{ Configuration }

procedure TGstAppSrcRef.SetCaps(ACaps: PGstCaps);
begin
  { Use direct API function - more reliable than GObject property for appsrc }
  _gst_app_src_set_caps(ElementHandle, ACaps);
end;

procedure TGstAppSrcRef.SetFormat(AFormat: GstFormat);
begin
  SetPropertyInt('format', Integer(AFormat));
end;

procedure TGstAppSrcRef.SetIsLive(AValue: Boolean);
begin
  SetPropertyBool('is-live', AValue);
end;

procedure TGstAppSrcRef.SetMinLatency(AValue: gint64);
begin
  // min-latency is a int64 property
  SetPropertyInt('min-latency', AValue);
end;

procedure TGstAppSrcRef.SetMaxLatency(AValue: gint64);
begin
  SetPropertyInt('max-latency', AValue);
end;

procedure TGstAppSrcRef.SetMaxBytes(AValue: guint64);
begin
  SetPropertyInt('max-bytes', AValue);
end;

procedure TGstAppSrcRef.SetBlockOnFull(AValue: Boolean);
begin
  SetPropertyBool('block', AValue);
end;

{ Data injection }

function TGstAppSrcRef.PushBuffer(ABuffer: PGstBuffer): GstFlowReturn;
begin
  if ElementHandle = nil then
    raise EG2DGstAppError.Create('PushBuffer: element handle is nil');
  if ABuffer = nil then
    raise EG2DGstAppError.Create('PushBuffer: buffer is nil');

  Result := GST_FLOW_ERROR;
  _g_signal_emit_by_name(
    gpointer(ElementHandle),
    Pgchar(PAnsiChar(AnsiString('push-buffer'))),
    ABuffer,
    @Result
  );
end;

function TGstAppSrcRef.PushSample(ASample: gpointer): GstFlowReturn;
begin
  if ElementHandle = nil then
    raise EG2DGstAppError.Create('PushSample: element handle is nil');
  if ASample = nil then
    raise EG2DGstAppError.Create('PushSample: sample is nil');
  Result := _gst_app_src_push_sample(ElementHandle, ASample);
end;

function TGstAppSrcRef.EndOfStream: GstFlowReturn;
begin
  if ElementHandle = nil then
    raise EG2DGstAppError.Create('EndOfStream: element handle is nil');

  Result := GST_FLOW_ERROR;
  _g_signal_emit_by_name(
    gpointer(ElementHandle),
    Pgchar(PAnsiChar(AnsiString('end-of-stream'))),
    @Result
  );
end;

{ Signal connections }

function TGstAppSrcRef.ConnectNeedData(ACallback: TGstNeedDataCallback; AUserData: gpointer): gulong;
begin
  Result := ConnectSignal('need-data', Pointer(@ACallback), AUserData);
end;

function TGstAppSrcRef.ConnectEnoughData(ACallback: TGstEnoughDataCallback; AUserData: gpointer): gulong;
begin
  Result := ConnectSignal('enough-data', Pointer(@ACallback), AUserData);
end;

{==============================================================================
  TGstAppSinkRef implementation
==============================================================================}

constructor TGstAppSinkRef.Create(AHandle: PGstElement; AAddRef: Boolean; AOwnsRef: Boolean);
begin
  inherited Create(AHandle, AAddRef, AOwnsRef);
end;

class function TGstAppSinkRef.Wrap(AHandle: PGstElement; AAddRef: Boolean; AOwnsRef: Boolean): TGstAppSinkRef;
begin
  if AHandle = nil then
    Exit(nil);
  Result := TGstAppSinkRef.Create(AHandle, AAddRef, AOwnsRef);
end;

class function TGstAppSinkRef.Make(const AName: string): TGstAppSinkRef;
var
  LHandle: PGstElement;
  LFactory: UTF8String;
  LName: UTF8String;
begin
  LFactory := UTF8String('appsink');
  LName    := UTF8String(AName);
  LHandle  := _gst_element_factory_make(
                Pgchar(PAnsiChar(LFactory)),
                Pgchar(PAnsiChar(LName))
              );
  if LHandle = nil then
    raise EG2DGstAppError.CreateFmt('Failed to create appsink element: %s', [AName]);
  Result := TGstAppSinkRef.Create(LHandle, False, True);
end;

{ Configuration }

procedure TGstAppSinkRef.SetCaps(ACaps: PGstCaps);
begin
  SetPropertyCaps('caps', ACaps);
end;

procedure TGstAppSinkRef.SetEmitSignals(AValue: Boolean);
begin
  SetPropertyBool('emit-signals', AValue);
end;

procedure TGstAppSinkRef.SetMaxBuffers(AValue: guint);
begin
  SetPropertyInt('max-buffers', AValue);
end;

procedure TGstAppSinkRef.SetDrop(AValue: Boolean);
begin
  SetPropertyBool('drop', AValue);
end;

procedure TGstAppSinkRef.SetSync(AValue: Boolean);
begin
  SetPropertyBool('sync', AValue);
end;

{ Data extraction }

function TGstAppSinkRef.PullSample: gpointer;
begin
  if ElementHandle = nil then
    raise EG2DGstAppError.Create('PullSample: element handle is nil');

  Result := nil;
  _g_signal_emit_by_name(
    gpointer(ElementHandle),
    Pgchar(PAnsiChar(AnsiString('pull-sample'))),
    @Result
  );
end;

procedure TGstAppSinkRef.SampleUnref(ASample: gpointer);
begin
  if ASample <> nil then
    _gst_sample_unref(ASample);
end;

function TGstAppSinkRef.PullSampleData(ADest: Pointer; AMaxSize: gsize;
  out ABytesRead: gsize): Boolean;
var
  LSample : gpointer;
  LBuffer : PGstBuffer;
  LMap    : GstMapInfo;
  LSize   : gsize;
begin
  Result    := False;
  ABytesRead := 0;

  LSample := PullSample;
  if LSample = nil then
    Exit;

  try
    LBuffer := _gst_sample_get_buffer(LSample);
    if LBuffer = nil then
      Exit;

    if _gst_buffer_map(LBuffer, @LMap, GST_MAP_READ) = 0 then
      Exit;

    try
      LSize := LMap.size;
      if LSize > AMaxSize then LSize := AMaxSize;
      Move(LMap.data^, ADest^, LSize);
      ABytesRead := LSize;
      Result := True;
    finally
      _gst_buffer_unmap(LBuffer, @LMap);
    end;
  finally
    _gst_sample_unref(LSample);
  end;
end;

{ Signal connection }

function TGstAppSinkRef.ConnectNewSample(ACallback: TGstNewSampleCallback; AUserData: gpointer): gulong;
begin
  Result := ConnectSignal('new-sample', Pointer(@ACallback), AUserData);
end;

{==============================================================================
  TGstSampleRef implementation
==============================================================================}

constructor TGstSampleRef.Create(AHandle: gpointer);
begin
  inherited Create;
  FHandle := AHandle;
end;

destructor TGstSampleRef.Destroy;
begin
  if FHandle <> nil then
  begin
    _gst_sample_unref(FHandle);
    FHandle := nil;
  end;
  inherited;
end;

function TGstSampleRef.GetBuffer: PGstBuffer;
begin
  if FHandle = nil then
    Exit(nil);
  Result := _gst_sample_get_buffer(FHandle);
end;

function TGstSampleRef.GetCaps: PGstCaps;
begin
  if FHandle = nil then
    Exit(nil);
  Result := _gst_sample_get_caps(FHandle);
end;

end.

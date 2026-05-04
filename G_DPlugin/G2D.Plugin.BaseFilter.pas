unit G2D.Plugin.BaseFilter;

{------------------------------------------------------------------------------
  G2D.Plugin.BaseFilter

  First-stage reusable scaffold for simple chain-based filter elements:

    sink pad -> chain callback -> ProcessBuffer -> src pad

  This unit intentionally does not replace the hand-written g2dpassthrough
  element yet. It exists as the shared shape for the next filter element.
------------------------------------------------------------------------------}

interface

uses
  System.SysUtils,
  Winapi.Windows,
  G2D.Glib.Types,
  G2D.Gobject.Types,
  G2D.Gobject.API,
  G2D.Gst.Types,
  G2D.Gst.API,
  G2D.Plugin.Types,
  G2D.Plugin.Element;

const
  G2D_BASE_FILTER_PROP_DEBUG = 1;
  G2D_BASE_FILTER_PROP_DEBUGFILE = 2;
  G2D_BASE_FILTER_PROP_FILTER = 3;
  G2D_BASE_FILTER_DEBUG_MAX = 3;

type
  EG2DBaseFilterError = class(Exception);

  PG2DBaseFilterDefinition = ^TG2DBaseFilterDefinition;
  PG2DBaseFilterContext = ^TG2DBaseFilterContext;
  TG2DBaseFilter = class;
  TG2DBaseFilterClass = class of TG2DBaseFilter;

  TG2DBaseFilterSetupPadsFunc = procedure(
    AContext: PG2DBaseFilterContext
  ); cdecl;

  TG2DBaseFilterSetPropertyFunc = procedure(
    AContext: PG2DBaseFilterContext;
    property_id: guint;
    const value: PGValue;
    pspec: PGParamSpec
  ); cdecl;

  TG2DBaseFilterGetPropertyFunc = procedure(
    AContext: PG2DBaseFilterContext;
    property_id: guint;
    value: PGValue;
    pspec: PGParamSpec
  ); cdecl;

  TG2DBaseFilterEventFunc = function(
    AContext: PG2DBaseFilterContext;
    pad: PGstPad;
    parent: PGstObject;
    event: PGstEvent
  ): gboolean; cdecl;

  TG2DBaseFilterQueryFunc = function(
    AContext: PG2DBaseFilterContext;
    pad: PGstPad;
    parent: PGstObject;
    query: PGstQuery
  ): gboolean; cdecl;

  TG2DBaseFilterChainFunc = function(
    AContext: PG2DBaseFilterContext;
    pad: PGstPad;
    parent: PGstObject;
    buffer: PGstBuffer
  ): GstFlowReturn; cdecl;

  TG2DBaseFilterProcessBufferFunc = function(
    AContext: PG2DBaseFilterContext;
    buffer: PGstBuffer
  ): GstFlowReturn; cdecl;

  TG2DBaseFilterCallbacks = record
    SetupPads: TG2DBaseFilterSetupPadsFunc;
    SetProperty: TG2DBaseFilterSetPropertyFunc;
    GetProperty: TG2DBaseFilterGetPropertyFunc;
    SinkEvent: TG2DBaseFilterEventFunc;
    SinkQuery: TG2DBaseFilterQueryFunc;
    SrcQuery: TG2DBaseFilterQueryFunc;
    Chain: TG2DBaseFilterChainFunc;
    ProcessBuffer: TG2DBaseFilterProcessBufferFunc;
  end;

  TG2DBaseFilterDefinition = record
    ElementName: string;
    TypeName: string;
    Metadata: TG2DPluginMetadata;
    SinkPad: TG2DPadTemplateInfo;
    SrcPad: TG2DPadTemplateInfo;
    Rank: GstRank;
    FilterClass: TG2DBaseFilterClass;
    Callbacks: TG2DBaseFilterCallbacks;
  end;

  TG2DBaseFilterContext = record
    Definition: PG2DBaseFilterDefinition;
    Instance: PGstElement;
    SinkPad: PGstPad;
    SrcPad: PGstPad;
    Filter: TG2DBaseFilter;
    UserData: gpointer;
  end;

  TG2DBaseFilter = class
  private
    FContext: PG2DBaseFilterContext;
    FDebugLevel: gint;
    FDebugLevelSet: Boolean;
    FDebugFileName: string;
    FFilterEnabled: Boolean;
    function GetElement: PGstElement;
    function GetSinkPad: PGstPad;
    function GetSrcPad: PGstPad;
    function GetEffectiveDebugLevel: gint;
    function GetLogPrefix: string;
    procedure SetDebugLevel(AValue: gint);
    procedure SetDebugFileName(const AValue: string);
  public
    constructor Create(AContext: PG2DBaseFilterContext); virtual;
    destructor Destroy; override;

    property Context: PG2DBaseFilterContext read FContext;
    property Element: PGstElement read GetElement;
    property SinkPad: PGstPad read GetSinkPad;
    property SrcPad: PGstPad read GetSrcPad;
    property DebugLevel: gint read FDebugLevel write SetDebugLevel;
    property DebugFileName: string read FDebugFileName write SetDebugFileName;
    property EffectiveDebugLevel: gint read GetEffectiveDebugLevel;
    property FilterEnabled: Boolean read FFilterEnabled write FFilterEnabled;

    procedure SetupPads; virtual;
    procedure Log(ALevel: gint; const AMsg: string); virtual;
    procedure SetProperty(
      property_id: guint;
      const value: PGValue;
      pspec: PGParamSpec
    ); virtual;
    procedure GetProperty(
      property_id: guint;
      value: PGValue;
      pspec: PGParamSpec
    ); virtual;

    function SinkEvent(
      pad: PGstPad;
      parent: PGstObject;
      event: PGstEvent
    ): gboolean; virtual;

    function SinkQuery(
      pad: PGstPad;
      parent: PGstObject;
      query: PGstQuery
    ): gboolean; virtual;

    function SrcQuery(
      pad: PGstPad;
      parent: PGstObject;
      query: PGstQuery
    ): gboolean; virtual;

    function Chain(
      pad: PGstPad;
      parent: PGstObject;
      buffer: PGstBuffer
    ): GstFlowReturn; virtual;

    function ProcessBuffer(buffer: PGstBuffer): GstFlowReturn; virtual;
  end;

function G2DBaseFilterContextKey: Pgchar;
function G2DBaseFilterSinkPadKey: Pgchar;
function G2DBaseFilterSrcPadKey: Pgchar;

function G2DBaseFilterGetContext(AParent: PGstObject): PG2DBaseFilterContext;
procedure G2DBaseFilterSetContext(AObject: PGObject; AContext: PG2DBaseFilterContext);

procedure G2DBaseFilterFreeContext(data: gpointer); cdecl;

procedure G2DBaseFilterPreparePadTemplates(
  const ADefinition: TG2DBaseFilterDefinition;
  var ASinkTemplate: TG2DStaticPadTemplate;
  var ASrcTemplate: TG2DStaticPadTemplate
);

procedure G2DBaseFilterClassInit(
  AElementClass: PGstElementClass;
  const ADefinition: TG2DBaseFilterDefinition;
  var ASinkTemplate: TG2DStaticPadTemplate;
  var ASrcTemplate: TG2DStaticPadTemplate
);

procedure G2DBaseFilterInstallDebugProperties(AObjectClass: PGObjectClass);

function G2DBaseFilterCreateContext(
  ADefinition: PG2DBaseFilterDefinition;
  AInstance: PGstElement
): PG2DBaseFilterContext;

procedure G2DBaseFilterInitInstance(
  ADefinition: PG2DBaseFilterDefinition;
  AInstance: PGTypeInstance;
  var ASinkTemplate: TG2DStaticPadTemplate;
  var ASrcTemplate: TG2DStaticPadTemplate
);

procedure G2DBaseFilterSetProperty(
  D_object: PGObject;
  property_id: guint;
  const value: PGValue;
  pspec: PGParamSpec
); cdecl;

procedure G2DBaseFilterGetProperty(
  D_object: PGObject;
  property_id: guint;
  value: PGValue;
  pspec: PGParamSpec
); cdecl;

function G2DBaseFilterSinkEvent(
  pad: PGstPad;
  parent: PGstObject;
  event: PGstEvent
): gboolean; cdecl;

function G2DBaseFilterSinkQuery(
  pad: PGstPad;
  parent: PGstObject;
  query: PGstQuery
): gboolean; cdecl;

function G2DBaseFilterSrcQuery(
  pad: PGstPad;
  parent: PGstObject;
  query: PGstQuery
): gboolean; cdecl;

function G2DBaseFilterChain(
  pad: PGstPad;
  parent: PGstObject;
  buffer: PGstBuffer
): GstFlowReturn; cdecl;

function G2DBaseFilterProcessBuffer(
  AContext: PG2DBaseFilterContext;
  buffer: PGstBuffer
): GstFlowReturn; cdecl;

implementation

var
  G2DBaseFilterContextKeyUtf8: UTF8String = 'g2d-base-filter-context';
  G2DBaseFilterSinkPadKeyUtf8: UTF8String = 'g2d-base-filter-sink-pad';
  G2DBaseFilterSrcPadKeyUtf8: UTF8String = 'g2d-base-filter-src-pad';

function G2DBaseFilterClampDebugLevel(ADebug: gint): gint;
begin
  Result := ADebug;
  if Result < 0 then
    Result := 0;
  if Result > G2D_BASE_FILTER_DEBUG_MAX then
    Result := G2D_BASE_FILTER_DEBUG_MAX;
end;

procedure G2DBaseFilterWriteConsole(const AText: AnsiString);
var
  LHandle: THandle;
  LWritten: DWORD;
begin
  LHandle := GetStdHandle(STD_ERROR_HANDLE);
  if LHandle = INVALID_HANDLE_VALUE then
    Exit;

  if AText <> '' then
    WriteFile(LHandle, PAnsiChar(AText)^, Length(AText), LWritten, nil);
end;

function G2DBaseFilterWriteFile(const AFileName: string; const AText: AnsiString): Boolean;
var
  LHandle: THandle;
  LWritten: DWORD;
begin
  Result := False;
  if (AFileName = '') or (AText = '') then
    Exit;

  LHandle := CreateFile(
    PChar(AFileName),
    FILE_APPEND_DATA,
    FILE_SHARE_READ or FILE_SHARE_WRITE,
    nil,
    OPEN_ALWAYS,
    FILE_ATTRIBUTE_NORMAL,
    0);

  if LHandle = INVALID_HANDLE_VALUE then
    Exit;

  try
    Result := WriteFile(LHandle, PAnsiChar(AText)^, Length(AText), LWritten, nil);
  finally
    CloseHandle(LHandle);
  end;
end;

constructor TG2DBaseFilter.Create(AContext: PG2DBaseFilterContext);
begin
  inherited Create;
  if AContext = nil then
    raise EG2DBaseFilterError.Create('TG2DBaseFilter.Create: context is nil');
  FContext := AContext;
  FDebugLevel := 0;
  FDebugLevelSet := False;
  FDebugFileName := '';
  FFilterEnabled := True;
end;

destructor TG2DBaseFilter.Destroy;
begin
  inherited Destroy;
end;

function TG2DBaseFilter.GetElement: PGstElement;
begin
  Result := nil;
  if FContext <> nil then
    Result := FContext^.Instance;
end;

function TG2DBaseFilter.GetSinkPad: PGstPad;
begin
  Result := nil;
  if FContext <> nil then
    Result := FContext^.SinkPad;
end;

function TG2DBaseFilter.GetSrcPad: PGstPad;
begin
  Result := nil;
  if FContext <> nil then
    Result := FContext^.SrcPad;
end;

function TG2DBaseFilter.GetEffectiveDebugLevel: gint;
begin
  if FDebugLevelSet then
    Exit(FDebugLevel);

  if FDebugFileName <> '' then
    Exit(1);

  Result := 0;
end;

function TG2DBaseFilter.GetLogPrefix: string;
begin
  Result := 'g2dbasefilter';
  if (FContext <> nil) and
     (FContext^.Definition <> nil) and
     (FContext^.Definition^.ElementName <> '') then
    Result := FContext^.Definition^.ElementName;
end;

procedure TG2DBaseFilter.SetDebugLevel(AValue: gint);
begin
  FDebugLevel := G2DBaseFilterClampDebugLevel(AValue);
  FDebugLevelSet := True;
end;

procedure TG2DBaseFilter.SetDebugFileName(const AValue: string);
begin
  FDebugFileName := AValue;
end;

procedure TG2DBaseFilter.SetupPads;
begin
  Log(1, 'setup pads');
end;

procedure TG2DBaseFilter.Log(ALevel: gint; const AMsg: string);
var
  LText: AnsiString;
begin
  if EffectiveDebugLevel < ALevel then
    Exit;

  LText := AnsiString('[' + GetLogPrefix + '] ' + AMsg + sLineBreak);
  if FDebugFileName <> '' then
  begin
    if not G2DBaseFilterWriteFile(FDebugFileName, LText) then
      G2DBaseFilterWriteConsole(
        AnsiString('[' + GetLogPrefix + '] failed to write debugfile' + sLineBreak));
    Exit;
  end;

  G2DBaseFilterWriteConsole(LText);
end;

procedure TG2DBaseFilter.SetProperty(
  property_id: guint;
  const value: PGValue;
  pspec: PGParamSpec
);
var
  LValue: Pgchar;
begin
  case property_id of
    G2D_BASE_FILTER_PROP_DEBUG:
      SetDebugLevel(_g_value_get_int(value));
    G2D_BASE_FILTER_PROP_DEBUGFILE:
      begin
        LValue := _g_value_get_string(value);
        if LValue <> nil then
          SetDebugFileName(UTF8ToString(AnsiString(PAnsiChar(LValue))))
        else
          SetDebugFileName('');
      end;
    G2D_BASE_FILTER_PROP_FILTER:
      FFilterEnabled := _g_value_get_boolean(value) <> 0;
  end;
end;

procedure TG2DBaseFilter.GetProperty(
  property_id: guint;
  value: PGValue;
  pspec: PGParamSpec
);
var
  LValue: UTF8String;
begin
  case property_id of
    G2D_BASE_FILTER_PROP_DEBUG:
      _g_value_set_int(value, FDebugLevel);
    G2D_BASE_FILTER_PROP_DEBUGFILE:
      _g_value_set_string(value, G2DUtf8Pgchar(FDebugFileName, LValue));
    G2D_BASE_FILTER_PROP_FILTER:
      _g_value_set_boolean(value, Ord(FFilterEnabled));
  end;
end;

function TG2DBaseFilter.SinkEvent(
  pad: PGstPad;
  parent: PGstObject;
  event: PGstEvent
): gboolean;
begin
  Log(1, 'sink event');
  Result := G2DPushEvent(SrcPad, event);
end;

function TG2DBaseFilter.SinkQuery(
  pad: PGstPad;
  parent: PGstObject;
  query: PGstQuery
): gboolean;
begin
  Log(1, 'sink query');
  Result := G2DPeerQuery(SrcPad, query);
  if Result = 0 then
    Result := G2DQueryDefault(pad, parent, query);
end;

function TG2DBaseFilter.SrcQuery(
  pad: PGstPad;
  parent: PGstObject;
  query: PGstQuery
): gboolean;
begin
  Log(1, 'src query');
  Result := G2DPeerQuery(SinkPad, query);
  if Result = 0 then
    Result := G2DQueryDefault(pad, parent, query);
end;

function TG2DBaseFilter.Chain(
  pad: PGstPad;
  parent: PGstObject;
  buffer: PGstBuffer
): GstFlowReturn;
begin
  Log(1, 'chain buffer');
  if not FFilterEnabled then
  begin
    Log(1, 'filter disabled; buffer bypassed');
    Exit(G2DPushBuffer(SrcPad, buffer));
  end;

  Result := ProcessBuffer(buffer);
end;

function TG2DBaseFilter.ProcessBuffer(buffer: PGstBuffer): GstFlowReturn;
begin
  Log(2, 'process buffer');
  Result := G2DPushBuffer(SrcPad, buffer);
end;

function G2DBaseFilterContextKey: Pgchar;
begin
  Result := Pgchar(PAnsiChar(G2DBaseFilterContextKeyUtf8));
end;

function G2DBaseFilterSinkPadKey: Pgchar;
begin
  Result := Pgchar(PAnsiChar(G2DBaseFilterSinkPadKeyUtf8));
end;

function G2DBaseFilterSrcPadKey: Pgchar;
begin
  Result := Pgchar(PAnsiChar(G2DBaseFilterSrcPadKeyUtf8));
end;

function G2DBaseFilterGetContext(AParent: PGstObject): PG2DBaseFilterContext;
begin
  Result := nil;
  if AParent <> nil then
    Result := PG2DBaseFilterContext(
      _g_object_get_data(PGObject(AParent), G2DBaseFilterContextKey));
end;

procedure G2DBaseFilterSetContext(AObject: PGObject; AContext: PG2DBaseFilterContext);
begin
  if AObject = nil then
    Exit;

  _g_object_set_data_full(
    AObject,
    G2DBaseFilterContextKey,
    AContext,
    G2DBaseFilterFreeContext);
end;

procedure G2DBaseFilterFreeContext(data: gpointer); cdecl;
var
  LContext: PG2DBaseFilterContext;
begin
  if data <> nil then
  begin
    LContext := PG2DBaseFilterContext(data);
    LContext^.Filter.Free;
    LContext^.Filter := nil;
    Dispose(LContext);
  end;
end;

procedure G2DBaseFilterPreparePadTemplates(
  const ADefinition: TG2DBaseFilterDefinition;
  var ASinkTemplate: TG2DStaticPadTemplate;
  var ASrcTemplate: TG2DStaticPadTemplate
);
begin
  G2DPrepareStaticPadTemplate(
    ASinkTemplate,
    ADefinition.SinkPad.NameTemplate,
    ADefinition.SinkPad.Direction,
    ADefinition.SinkPad.Presence,
    ADefinition.SinkPad.Caps);

  G2DPrepareStaticPadTemplate(
    ASrcTemplate,
    ADefinition.SrcPad.NameTemplate,
    ADefinition.SrcPad.Direction,
    ADefinition.SrcPad.Presence,
    ADefinition.SrcPad.Caps);
end;

procedure G2DBaseFilterClassInit(
  AElementClass: PGstElementClass;
  const ADefinition: TG2DBaseFilterDefinition;
  var ASinkTemplate: TG2DStaticPadTemplate;
  var ASrcTemplate: TG2DStaticPadTemplate
);
var
  LObjectClass: PGObjectClass;
begin
  if AElementClass = nil then
    raise EG2DBaseFilterError.Create('G2DBaseFilterClassInit: element class is nil');

  LObjectClass := @AElementClass^.parent_class.parent_class.parent_class;
  LObjectClass^.set_property := G2DBaseFilterSetProperty;
  LObjectClass^.get_property := G2DBaseFilterGetProperty;
  G2DBaseFilterInstallDebugProperties(LObjectClass);

  G2DBaseFilterPreparePadTemplates(ADefinition, ASinkTemplate, ASrcTemplate);
  G2DSetElementMetadata(AElementClass, ADefinition.Metadata);
  G2DAddStaticPadTemplate(AElementClass, ASinkTemplate);
  G2DAddStaticPadTemplate(AElementClass, ASrcTemplate);
end;

procedure G2DBaseFilterInstallDebugProperties(AObjectClass: PGObjectClass);
var
  LName: UTF8String;
  LNick: UTF8String;
  LBlurb: UTF8String;
  LDebugFileName: UTF8String;
  LDebugFileNick: UTF8String;
  LDebugFileBlurb: UTF8String;
  LFilterName: UTF8String;
  LFilterNick: UTF8String;
  LFilterBlurb: UTF8String;
begin
  if AObjectClass = nil then
    raise EG2DBaseFilterError.Create('G2DBaseFilterInstallDebugProperties: object class is nil');

  _g_object_class_install_property(
    AObjectClass,
    G2D_BASE_FILTER_PROP_DEBUG,
    _g_param_spec_int(
      G2DUtf8Pgchar('debug', LName),
      G2DUtf8Pgchar('Debug', LNick),
      G2DUtf8Pgchar('Debug level: 0 off, 1 basic, 2 summary, 3 full', LBlurb),
      0,
      G2D_BASE_FILTER_DEBUG_MAX,
      0,
      G_PARAM_READWRITE));

  _g_object_class_install_property(
    AObjectClass,
    G2D_BASE_FILTER_PROP_DEBUGFILE,
    _g_param_spec_string(
      G2DUtf8Pgchar('debugfile', LDebugFileName),
      G2DUtf8Pgchar('Debug file', LDebugFileNick),
      G2DUtf8Pgchar('Write debug messages to this file', LDebugFileBlurb),
      nil,
      G_PARAM_READWRITE));

  _g_object_class_install_property(
    AObjectClass,
    G2D_BASE_FILTER_PROP_FILTER,
    _g_param_spec_boolean(
      G2DUtf8Pgchar('filter', LFilterName),
      G2DUtf8Pgchar('Filter', LFilterNick),
      G2DUtf8Pgchar('Enable filter processing; false bypasses buffers unchanged', LFilterBlurb),
      1,
      G_PARAM_READWRITE));
end;

function G2DBaseFilterCreateContext(
  ADefinition: PG2DBaseFilterDefinition;
  AInstance: PGstElement
): PG2DBaseFilterContext;
var
  LFilterClass: TG2DBaseFilterClass;
begin
  if ADefinition = nil then
    raise EG2DBaseFilterError.Create('G2DBaseFilterCreateContext: definition is nil');
  if AInstance = nil then
    raise EG2DBaseFilterError.Create('G2DBaseFilterCreateContext: instance is nil');

  New(Result);
  FillChar(Result^, SizeOf(Result^), 0);
  Result^.Definition := ADefinition;
  Result^.Instance := AInstance;

  LFilterClass := ADefinition^.FilterClass;
  if LFilterClass = nil then
    LFilterClass := TG2DBaseFilter;
  Result^.Filter := LFilterClass.Create(Result);
end;

procedure G2DBaseFilterInitInstance(
  ADefinition: PG2DBaseFilterDefinition;
  AInstance: PGTypeInstance;
  var ASinkTemplate: TG2DStaticPadTemplate;
  var ASrcTemplate: TG2DStaticPadTemplate
);
var
  LContext: PG2DBaseFilterContext;
  LPadName: UTF8String;
begin
  if ADefinition = nil then
    raise EG2DBaseFilterError.Create('G2DBaseFilterInitInstance: definition is nil');
  if AInstance = nil then
    raise EG2DBaseFilterError.Create('G2DBaseFilterInitInstance: instance is nil');

  LContext := G2DBaseFilterCreateContext(ADefinition, PGstElement(AInstance));
  try
    LContext^.SinkPad := G2DCreateChainPad(
      PGstElement(AInstance),
      ASinkTemplate,
      ADefinition^.SinkPad.NameTemplate,
      G2DBaseFilterChain);
    G2DSetPadEventFunction(LContext^.SinkPad, G2DBaseFilterSinkEvent);
    G2DSetPadQueryFunction(LContext^.SinkPad, G2DBaseFilterSinkQuery);
    _g_object_set_data(PGObject(AInstance), G2DBaseFilterSinkPadKey, LContext^.SinkPad);

    LContext^.SrcPad := _gst_pad_new_from_static_template(
      @ASrcTemplate.Template,
      G2DUtf8Pgchar(ADefinition^.SrcPad.NameTemplate, LPadName));
    if LContext^.SrcPad = nil then
      raise EG2DBaseFilterError.Create('G2DBaseFilterInitInstance: failed to create src pad');

    if _gst_element_add_pad(PGstElement(AInstance), LContext^.SrcPad) = 0 then
      raise EG2DBaseFilterError.Create('G2DBaseFilterInitInstance: failed to add src pad');

    G2DSetPadQueryFunction(LContext^.SrcPad, G2DBaseFilterSrcQuery);
    _g_object_set_data(PGObject(AInstance), G2DBaseFilterSrcPadKey, LContext^.SrcPad);

    G2DBaseFilterSetContext(PGObject(AInstance), LContext);
    if Assigned(ADefinition^.Callbacks.SetupPads) then
      ADefinition^.Callbacks.SetupPads(LContext)
    else if LContext^.Filter <> nil then
      LContext^.Filter.SetupPads;
  except
    G2DBaseFilterFreeContext(LContext);
    raise;
  end;
end;

procedure G2DBaseFilterSetProperty(
  D_object: PGObject;
  property_id: guint;
  const value: PGValue;
  pspec: PGParamSpec
); cdecl;
var
  LContext: PG2DBaseFilterContext;
begin
  LContext := G2DBaseFilterGetContext(PGstObject(D_object));
  if (LContext <> nil) and Assigned(LContext^.Definition^.Callbacks.SetProperty) then
    LContext^.Definition^.Callbacks.SetProperty(LContext, property_id, value, pspec)
  else if (LContext <> nil) and (LContext^.Filter <> nil) then
    LContext^.Filter.SetProperty(property_id, value, pspec);
end;

procedure G2DBaseFilterGetProperty(
  D_object: PGObject;
  property_id: guint;
  value: PGValue;
  pspec: PGParamSpec
); cdecl;
var
  LContext: PG2DBaseFilterContext;
begin
  LContext := G2DBaseFilterGetContext(PGstObject(D_object));
  if (LContext <> nil) and Assigned(LContext^.Definition^.Callbacks.GetProperty) then
    LContext^.Definition^.Callbacks.GetProperty(LContext, property_id, value, pspec)
  else if (LContext <> nil) and (LContext^.Filter <> nil) then
    LContext^.Filter.GetProperty(property_id, value, pspec);
end;

function G2DBaseFilterSinkEvent(
  pad: PGstPad;
  parent: PGstObject;
  event: PGstEvent
): gboolean; cdecl;
var
  LContext: PG2DBaseFilterContext;
begin
  LContext := G2DBaseFilterGetContext(parent);
  if (LContext <> nil) and Assigned(LContext^.Definition^.Callbacks.SinkEvent) then
    Exit(LContext^.Definition^.Callbacks.SinkEvent(LContext, pad, parent, event));

  if LContext = nil then
    Exit(0);

  if LContext^.Filter <> nil then
    Result := LContext^.Filter.SinkEvent(pad, parent, event)
  else
    Result := G2DPushEvent(LContext^.SrcPad, event);
end;

function G2DBaseFilterSinkQuery(
  pad: PGstPad;
  parent: PGstObject;
  query: PGstQuery
): gboolean; cdecl;
var
  LContext: PG2DBaseFilterContext;
begin
  LContext := G2DBaseFilterGetContext(parent);
  if (LContext <> nil) and Assigned(LContext^.Definition^.Callbacks.SinkQuery) then
    Exit(LContext^.Definition^.Callbacks.SinkQuery(LContext, pad, parent, query));

  if LContext = nil then
    Exit(0);

  if LContext^.Filter <> nil then
    Result := LContext^.Filter.SinkQuery(pad, parent, query)
  else
  begin
    Result := G2DPeerQuery(LContext^.SrcPad, query);
    if Result = 0 then
      Result := G2DQueryDefault(pad, parent, query);
  end;
end;

function G2DBaseFilterSrcQuery(
  pad: PGstPad;
  parent: PGstObject;
  query: PGstQuery
): gboolean; cdecl;
var
  LContext: PG2DBaseFilterContext;
begin
  LContext := G2DBaseFilterGetContext(parent);
  if (LContext <> nil) and Assigned(LContext^.Definition^.Callbacks.SrcQuery) then
    Exit(LContext^.Definition^.Callbacks.SrcQuery(LContext, pad, parent, query));

  if LContext = nil then
    Exit(0);

  if LContext^.Filter <> nil then
    Result := LContext^.Filter.SrcQuery(pad, parent, query)
  else
  begin
    Result := G2DPeerQuery(LContext^.SinkPad, query);
    if Result = 0 then
      Result := G2DQueryDefault(pad, parent, query);
  end;
end;

function G2DBaseFilterChain(
  pad: PGstPad;
  parent: PGstObject;
  buffer: PGstBuffer
): GstFlowReturn; cdecl;
var
  LContext: PG2DBaseFilterContext;
begin
  LContext := G2DBaseFilterGetContext(parent);
  if (LContext <> nil) and Assigned(LContext^.Definition^.Callbacks.Chain) then
    Exit(LContext^.Definition^.Callbacks.Chain(LContext, pad, parent, buffer));

  if LContext = nil then
    Exit(GST_FLOW_ERROR);

  if Assigned(LContext^.Definition^.Callbacks.ProcessBuffer) then
    Result := LContext^.Definition^.Callbacks.ProcessBuffer(LContext, buffer)
  else if LContext^.Filter <> nil then
    Result := LContext^.Filter.Chain(pad, parent, buffer)
  else
    Result := G2DBaseFilterProcessBuffer(LContext, buffer);
end;

function G2DBaseFilterProcessBuffer(
  AContext: PG2DBaseFilterContext;
  buffer: PGstBuffer
): GstFlowReturn; cdecl;
begin
  if AContext = nil then
    Exit(GST_FLOW_ERROR);

  if AContext^.Filter <> nil then
    Result := AContext^.Filter.ProcessBuffer(buffer)
  else
    Result := G2DPushBuffer(AContext^.SrcPad, buffer);
end;

end.

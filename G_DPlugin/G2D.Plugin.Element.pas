unit G2D.Plugin.Element;

{------------------------------------------------------------------------------
  G2D.Plugin.Element

  Small reusable helpers for implementing real GstElement plugin DLLs.
  The first target is a chain-based passthrough element.
------------------------------------------------------------------------------}

interface

uses
  System.SysUtils,
  G2D.Glib.Types,
  G2D.Gobject.Types,
  G2D.Gst.Types,
  G2D.Gst.API,
  G2D.Plugin.Types,
  G2D.Plugin.API;

type
  EG2DPluginElementError = class(Exception);

function G2DUtf8Pgchar(const S: string; var AStorage: UTF8String): Pgchar;

procedure G2DPrepareStaticPadTemplate(
  var AStorage: TG2DStaticPadTemplate;
  const ANameTemplate: string;
  ADirection: GstPadDirection;
  APresence: GstPadPresence;
  const ACaps: string
);

procedure G2DSetElementMetadata(
  AClass: PGstElementClass;
  const AMetadata: TG2DPluginMetadata
);

procedure G2DAddStaticPadTemplate(
  AClass: PGstElementClass;
  var ATemplate: TG2DStaticPadTemplate
);

function G2DRegisterElement(
  APlugin: PGstPlugin;
  const AName: string;
  ARank: GstRank;
  AType: GType
): gboolean;

function G2DCreateChainPad(
  AElement: PGstElement;
  var ATemplate: TG2DStaticPadTemplate;
  const AName: string;
  AChainFunction: TGstPadChainFunction
): PGstPad;

procedure G2DSetPadEventFunction(
  APad: PGstPad;
  AEventFunction: TGstPadEventFunction
);

procedure G2DSetPadQueryFunction(
  APad: PGstPad;
  AQueryFunction: TGstPadQueryFunction
);

procedure G2DSetPadProxyFlags(APad: PGstPad);

function G2DPushBuffer(ASrcPad: PGstPad; ABuffer: PGstBuffer): GstFlowReturn;
function G2DPushEvent(ASrcPad: PGstPad; AEvent: PGstEvent): gboolean;
function G2DPeerQuery(APad: PGstPad; AQuery: PGstQuery): gboolean;
function G2DQueryDefault(APad: PGstPad; AParent: PGstObject;
  AQuery: PGstQuery): gboolean;

implementation

function G2DUtf8Pgchar(const S: string; var AStorage: UTF8String): Pgchar;
begin
  AStorage := UTF8String(S);
  Result := Pgchar(PAnsiChar(AStorage));
end;

procedure G2DPrepareStaticPadTemplate(
  var AStorage: TG2DStaticPadTemplate;
  const ANameTemplate: string;
  ADirection: GstPadDirection;
  APresence: GstPadPresence;
  const ACaps: string
);
begin
  FillChar(AStorage.Template, SizeOf(AStorage.Template), 0);
  AStorage.Template.name_template :=
    G2DUtf8Pgchar(ANameTemplate, AStorage.NameTemplateUtf8);
  AStorage.Template.direction := ADirection;
  AStorage.Template.presence := APresence;
  AStorage.Template.static_caps.string_ :=
    G2DUtf8Pgchar(ACaps, AStorage.CapsUtf8);
end;

procedure G2DSetElementMetadata(
  AClass: PGstElementClass;
  const AMetadata: TG2DPluginMetadata
);
var
  LLongName: UTF8String;
  LClassification: UTF8String;
  LDescription: UTF8String;
  LAuthor: UTF8String;
begin
  G2D_RequirePluginAPI;
  if AClass = nil then
    raise EG2DPluginElementError.Create('G2DSetElementMetadata: element class is nil');

  _gst_element_class_set_static_metadata(
    AClass,
    G2DUtf8Pgchar(AMetadata.LongName, LLongName),
    G2DUtf8Pgchar(AMetadata.Classification, LClassification),
    G2DUtf8Pgchar(AMetadata.Description, LDescription),
    G2DUtf8Pgchar(AMetadata.Author, LAuthor));
end;

procedure G2DAddStaticPadTemplate(
  AClass: PGstElementClass;
  var ATemplate: TG2DStaticPadTemplate
);
begin
  G2D_RequirePluginAPI;
  if AClass = nil then
    raise EG2DPluginElementError.Create('G2DAddStaticPadTemplate: element class is nil');

  _gst_element_class_add_static_pad_template(AClass, @ATemplate.Template);
end;

function G2DRegisterElement(
  APlugin: PGstPlugin;
  const AName: string;
  ARank: GstRank;
  AType: GType
): gboolean;
var
  LName: UTF8String;
begin
  G2D_RequirePluginAPI;
  Result := _gst_element_register(
    APlugin, G2DUtf8Pgchar(AName, LName), ARank, AType);
end;

function G2DCreateChainPad(
  AElement: PGstElement;
  var ATemplate: TG2DStaticPadTemplate;
  const AName: string;
  AChainFunction: TGstPadChainFunction
): PGstPad;
var
  LName: UTF8String;
begin
  G2D_RequirePluginAPI;
  if AElement = nil then
    raise EG2DPluginElementError.Create('G2DCreateChainPad: element is nil');
  if not Assigned(AChainFunction) then
    raise EG2DPluginElementError.Create('G2DCreateChainPad: chain function is nil');

  Result := _gst_pad_new_from_static_template(
    @ATemplate.Template, G2DUtf8Pgchar(AName, LName));
  if Result = nil then
    raise EG2DPluginElementError.CreateFmt(
      'G2DCreateChainPad: failed to create pad "%s"', [AName]);

  _gst_pad_set_chain_function_full(Result, AChainFunction, nil, nil);
  if _gst_element_add_pad(AElement, Result) = 0 then
    raise EG2DPluginElementError.CreateFmt(
      'G2DCreateChainPad: failed to add pad "%s"', [AName]);
end;

procedure G2DSetPadEventFunction(
  APad: PGstPad;
  AEventFunction: TGstPadEventFunction
);
begin
  G2D_RequirePluginAPI;
  if APad = nil then
    raise EG2DPluginElementError.Create('G2DSetPadEventFunction: pad is nil');
  if not Assigned(AEventFunction) then
    raise EG2DPluginElementError.Create('G2DSetPadEventFunction: event function is nil');

  _gst_pad_set_event_function_full(APad, AEventFunction, nil, nil);
end;

procedure G2DSetPadQueryFunction(
  APad: PGstPad;
  AQueryFunction: TGstPadQueryFunction
);
begin
  G2D_RequirePluginAPI;
  if APad = nil then
    raise EG2DPluginElementError.Create('G2DSetPadQueryFunction: pad is nil');
  if not Assigned(AQueryFunction) then
    raise EG2DPluginElementError.Create('G2DSetPadQueryFunction: query function is nil');

  _gst_pad_set_query_function_full(APad, AQueryFunction, nil, nil);
end;

procedure G2DSetPadProxyFlags(APad: PGstPad);
const
  G2D_PAD_PROXY_FLAGS =
    GST_PAD_FLAG_PROXY_CAPS or
    GST_PAD_FLAG_PROXY_ALLOCATION or
    GST_PAD_FLAG_PROXY_SCHEDULING;
begin
  if APad = nil then
    raise EG2DPluginElementError.Create('G2DSetPadProxyFlags: pad is nil');

  APad^.D_object.flags := APad^.D_object.flags or G2D_PAD_PROXY_FLAGS;
end;

function G2DPushBuffer(ASrcPad: PGstPad; ABuffer: PGstBuffer): GstFlowReturn;
begin
  G2D_RequirePluginAPI;
  if ASrcPad = nil then
    Exit(GST_FLOW_ERROR);
  if ABuffer = nil then
    Exit(GST_FLOW_ERROR);

  Result := _gst_pad_push(ASrcPad, ABuffer);
end;

function G2DPushEvent(ASrcPad: PGstPad; AEvent: PGstEvent): gboolean;
begin
  G2D_RequirePluginAPI;
  if ASrcPad = nil then
    Exit(0);
  if AEvent = nil then
    Exit(0);

  Result := _gst_pad_push_event(ASrcPad, AEvent);
end;

function G2DPeerQuery(APad: PGstPad; AQuery: PGstQuery): gboolean;
begin
  G2D_RequirePluginAPI;
  if APad = nil then
    Exit(0);
  if AQuery = nil then
    Exit(0);

  Result := _gst_pad_peer_query(APad, AQuery);
end;

function G2DQueryDefault(APad: PGstPad; AParent: PGstObject;
  AQuery: PGstQuery): gboolean;
begin
  G2D_RequirePluginAPI;
  if APad = nil then
    Exit(0);
  if AQuery = nil then
    Exit(0);

  Result := _gst_pad_query_default(APad, AParent, AQuery);
end;

end.

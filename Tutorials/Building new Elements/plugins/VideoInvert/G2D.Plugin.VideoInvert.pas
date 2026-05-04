unit G2D.Plugin.VideoInvert;

{------------------------------------------------------------------------------
  G2D.Plugin.VideoInvert

  First real video filter example plugin element.

  Element name:
    g2dinvert

  Supported caps:
    video/x-raw,format=RGB

  This maps the incoming buffer writable, inverts each RGB byte, unmaps, and
  pushes the same buffer downstream.
------------------------------------------------------------------------------}

interface

uses
  System.SysUtils,
  G2D.Glib.Types,
  G2D.Gobject.Types,
  G2D.Gobject.API,
  G2D.Gst.Types,
  G2D.Gst.API,
  G2D.Plugin.Types,
  G2D.Plugin.API,
  G2D.Plugin.Element,
  G2D.Plugin.BaseFilter,
  G2D.Plugin.VideoFilter;

const
  G2D_VIDEO_INVERT_ELEMENT_NAME = 'g2dinvert';
  G2D_VIDEO_INVERT_TYPE_NAME    = 'G2DVideoInvert';

type
  PG2DVideoInvert = ^TG2DVideoInvert;
  TG2DVideoInvert = record
    Parent: GstElement;
  end;

  PG2DVideoInvertClass = ^TG2DVideoInvertClass;
  TG2DVideoInvertClass = record
    ParentClass: GstElementClass;
  end;

  TG2DVideoInvertFilter = class(TG2DVideoFilter)
  protected
    function ProcessVideoFrame(
      buffer: PGstBuffer;
      const AInfo: TG2DVideoInfo
    ): GstFlowReturn; override;
  end;

function G2DVideoInvertGetType: GType; cdecl;
function G2DRegisterVideoInvert(APlugin: PGstPlugin): gboolean; cdecl;

implementation

var
  G2DVideoInvertType: GType = 0;
  G2DVideoInvertDefinition: TG2DBaseFilterDefinition;
  G2DVideoInvertSinkTemplate: TG2DStaticPadTemplate;
  G2DVideoInvertSrcTemplate: TG2DStaticPadTemplate;

function TG2DVideoInvertFilter.ProcessVideoFrame(
  buffer: PGstBuffer;
  const AInfo: TG2DVideoInfo
): GstFlowReturn;
var
  LMapInfo: GstMapInfo;
  LData: Pguint8;
  I: NativeUInt;
begin
  if not SameText(AInfo.Format, 'RGB') then
  begin
    Log(1, 'g2dinvert unsupported format ' + AInfo.Format + '; passing unchanged');
    Exit(inherited ProcessVideoFrame(buffer, AInfo));
  end;

  FillChar(LMapInfo, SizeOf(LMapInfo), 0);
  if _gst_buffer_map(buffer, @LMapInfo, GST_MAP_READWRITE) = 0 then
  begin
    Log(1, 'g2dinvert failed to map buffer; passing unchanged');
    Exit(inherited ProcessVideoFrame(buffer, AInfo));
  end;

  try
    LData := LMapInfo.data;
    for I := 0 to NativeUInt(LMapInfo.size) - 1 do
    begin
      LData^ := guint8(255 - LData^);
      Inc(LData);
    end;

    Log(2, Format('g2dinvert inverted bytes=%d', [UInt64(LMapInfo.size)]));
  finally
    _gst_buffer_unmap(buffer, @LMapInfo);
  end;

  Result := inherited ProcessVideoFrame(buffer, AInfo);
end;

procedure G2DPrepareVideoInvertDefinition;
begin
  FillChar(G2DVideoInvertDefinition, SizeOf(G2DVideoInvertDefinition), 0);

  G2DVideoInvertDefinition.ElementName := G2D_VIDEO_INVERT_ELEMENT_NAME;
  G2DVideoInvertDefinition.TypeName := G2D_VIDEO_INVERT_TYPE_NAME;
  G2DVideoInvertDefinition.Rank := GST_RANK_NONE;
  G2DVideoInvertDefinition.FilterClass := TG2DVideoInvertFilter;

  G2DVideoInvertDefinition.Metadata.LongName := 'G2D Video Invert Filter';
  G2DVideoInvertDefinition.Metadata.Classification := 'Filter/Effect/Video';
  G2DVideoInvertDefinition.Metadata.Description :=
    'Inverts RGB video buffers in-place';
  G2DVideoInvertDefinition.Metadata.Author := 'G2D';

  G2DVideoInvertDefinition.SinkPad.NameTemplate := 'sink';
  G2DVideoInvertDefinition.SinkPad.Direction := GST_PAD_SINK;
  G2DVideoInvertDefinition.SinkPad.Presence := GST_PAD_ALWAYS;
  G2DVideoInvertDefinition.SinkPad.Caps := 'video/x-raw,format=RGB';

  G2DVideoInvertDefinition.SrcPad.NameTemplate := 'src';
  G2DVideoInvertDefinition.SrcPad.Direction := GST_PAD_SRC;
  G2DVideoInvertDefinition.SrcPad.Presence := GST_PAD_ALWAYS;
  G2DVideoInvertDefinition.SrcPad.Caps := 'video/x-raw,format=RGB';
end;

procedure G2DVideoInvertClassInit(g_class: gpointer; class_data: gpointer); cdecl;
begin
  G2DBaseFilterClassInit(
    PGstElementClass(g_class),
    G2DVideoInvertDefinition,
    G2DVideoInvertSinkTemplate,
    G2DVideoInvertSrcTemplate);
end;

procedure G2DVideoInvertInit(instance: PGTypeInstance; g_class: gpointer); cdecl;
begin
  G2DBaseFilterInitInstance(
    @G2DVideoInvertDefinition,
    instance,
    G2DVideoInvertSinkTemplate,
    G2DVideoInvertSrcTemplate);
end;

function G2DVideoInvertGetType: GType; cdecl;
var
  LTypeInfo: GTypeInfo;
  LParentQuery: GTypeQuery;
  LTypeName: UTF8String;
begin
  if G2DVideoInvertType <> G_TYPE_INVALID then
    Exit(G2DVideoInvertType);

  G2D_RequirePluginAPI;

  FillChar(LTypeInfo, SizeOf(LTypeInfo), 0);
  FillChar(LParentQuery, SizeOf(LParentQuery), 0);
  _g_type_query(_gst_element_get_type, @LParentQuery);

  LTypeInfo.class_size := SizeOf(TG2DVideoInvertClass);
  LTypeInfo.class_init := G2DVideoInvertClassInit;
  LTypeInfo.instance_size := LParentQuery.instance_size;
  LTypeInfo.instance_init := G2DVideoInvertInit;

  G2DVideoInvertType := _g_type_register_static(
    _gst_element_get_type,
    G2DUtf8Pgchar(G2D_VIDEO_INVERT_TYPE_NAME, LTypeName),
    @LTypeInfo,
    0);

  Result := G2DVideoInvertType;
end;

function G2DRegisterVideoInvert(APlugin: PGstPlugin): gboolean; cdecl;
begin
  Result := G2DRegisterElement(
    APlugin,
    G2D_VIDEO_INVERT_ELEMENT_NAME,
    G2DVideoInvertDefinition.Rank,
    G2DVideoInvertGetType);
end;

initialization
  G2DPrepareVideoInvertDefinition;

end.

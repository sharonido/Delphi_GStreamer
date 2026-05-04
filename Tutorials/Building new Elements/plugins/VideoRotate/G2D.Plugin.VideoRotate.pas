unit G2D.Plugin.VideoRotate;

{------------------------------------------------------------------------------
  G2D.Plugin.VideoRotate

  Standalone video rotation plugin element.

  Element name:
    g2drotate

  Supported caps:
    video/x-raw,format=BGRx

  The actual rotation is done by G2DOpenCV.dll through G2DCV_RotateFrame.
------------------------------------------------------------------------------}

interface

uses
  System.SysUtils,
  G2D.Glib.Types,
  G2D.Gobject.Types,
  G2D.Gobject.API,
  G2D.Gst.Types,
  G2D.Gst.API,
  G2D.OpenCV.API,
  G2D.Plugin.Types,
  G2D.Plugin.API,
  G2D.Plugin.Element,
  G2D.Plugin.BaseFilter,
  G2D.Plugin.VideoFilter;

const
  G2D_VIDEO_ROTATE_ELEMENT_NAME = 'g2drotate';
  G2D_VIDEO_ROTATE_TYPE_NAME    = 'G2DVideoRotate';
  G2D_VIDEO_ROTATE_PROP_ANGLE   = 100;

type
  PG2DVideoRotate = ^TG2DVideoRotate;
  TG2DVideoRotate = record
    Parent: GstElement;
  end;

  PG2DVideoRotateClass = ^TG2DVideoRotateClass;
  TG2DVideoRotateClass = record
    ParentClass: GstElementClass;
  end;

  TG2DVideoRotateFilter = class(TG2DVideoFilter)
  private
    FRotateAngle: gint;
    function ClampRotateAngle(AValue: gint): gint;
  protected
    function ProcessVideoFrame(
      buffer: PGstBuffer;
      const AInfo: TG2DVideoInfo
    ): GstFlowReturn; override;
  public
    constructor Create(AContext: PG2DBaseFilterContext); override;

    procedure SetProperty(
      property_id: guint;
      const value: PGValue;
      pspec: PGParamSpec
    ); override;

    procedure GetProperty(
      property_id: guint;
      value: PGValue;
      pspec: PGParamSpec
    ); override;

    property RotateAngle: gint read FRotateAngle write FRotateAngle;
  end;

function G2DVideoRotateGetType: GType; cdecl;
function G2DRegisterVideoRotate(APlugin: PGstPlugin): gboolean; cdecl;

implementation

var
  G2DVideoRotateType: GType = 0;
  G2DVideoRotateDefinition: TG2DBaseFilterDefinition;
  G2DVideoRotateSinkTemplate: TG2DStaticPadTemplate;
  G2DVideoRotateSrcTemplate: TG2DStaticPadTemplate;

constructor TG2DVideoRotateFilter.Create(AContext: PG2DBaseFilterContext);
begin
  inherited Create(AContext);
  FRotateAngle := 0;
end;

function TG2DVideoRotateFilter.ClampRotateAngle(AValue: gint): gint;
begin
  Result := AValue;
  if Result < -180 then
    Result := -180;
  if Result > 180 then
    Result := 180;
end;

procedure TG2DVideoRotateFilter.SetProperty(
  property_id: guint;
  const value: PGValue;
  pspec: PGParamSpec
);
begin
  case property_id of
    G2D_VIDEO_ROTATE_PROP_ANGLE:
      FRotateAngle := ClampRotateAngle(_g_value_get_int(value));
  else
    inherited SetProperty(property_id, value, pspec);
  end;
end;

procedure TG2DVideoRotateFilter.GetProperty(
  property_id: guint;
  value: PGValue;
  pspec: PGParamSpec
);
begin
  case property_id of
    G2D_VIDEO_ROTATE_PROP_ANGLE:
      _g_value_set_int(value, FRotateAngle);
  else
    inherited GetProperty(property_id, value, pspec);
  end;
end;

function TG2DVideoRotateFilter.ProcessVideoFrame(
  buffer: PGstBuffer;
  const AInfo: TG2DVideoInfo
): GstFlowReturn;
var
  LMapInfo: GstMapInfo;
  LStride: Integer;
begin
  try
    if not SameText(AInfo.Format, 'BGRx') then
    begin
      Log(1, 'g2drotate unsupported format ' + AInfo.Format + '; passing unchanged');
      Exit(inherited ProcessVideoFrame(buffer, AInfo));
    end;

    if FRotateAngle = 0 then
      Exit(inherited ProcessVideoFrame(buffer, AInfo));

    if not G2D_OpenCVLoadedOK then
      G2D_LoadOpenCV;

    FillChar(LMapInfo, SizeOf(LMapInfo), 0);
    if _gst_buffer_map(buffer, @LMapInfo, GST_MAP_READWRITE) = 0 then
    begin
      Log(1, 'g2drotate failed to map buffer; passing unchanged');
      Exit(inherited ProcessVideoFrame(buffer, AInfo));
    end;

    try
      if (AInfo.Height <= 0) or (LMapInfo.size = 0) then
        Exit(inherited ProcessVideoFrame(buffer, AInfo));

      LStride := Integer(LMapInfo.size div gsize(AInfo.Height));
      if LStride < (AInfo.Width * 4) then
      begin
        Log(1, 'g2drotate invalid stride; passing unchanged');
        Exit(inherited ProcessVideoFrame(buffer, AInfo));
      end;

      if not G2DCV_RotateFrame(
        PByte(LMapInfo.data),
        PByte(LMapInfo.data),
        AInfo.Width,
        AInfo.Height,
        LStride,
        FRotateAngle,
        0) then
        Log(1, 'g2drotate OpenCV rotate failed')
      else
        Log(2, Format('g2drotate angle=%d stride=%d bytes=%d',
          [FRotateAngle, LStride, UInt64(LMapInfo.size)]));
    finally
      _gst_buffer_unmap(buffer, @LMapInfo);
    end;
  except
    on E: Exception do
      Log(1, 'g2drotate exception: ' + E.ClassName + ': ' + E.Message);
  end;

  Result := inherited ProcessVideoFrame(buffer, AInfo);
end;

procedure G2DPrepareVideoRotateDefinition;
begin
  FillChar(G2DVideoRotateDefinition, SizeOf(G2DVideoRotateDefinition), 0);

  G2DVideoRotateDefinition.ElementName := G2D_VIDEO_ROTATE_ELEMENT_NAME;
  G2DVideoRotateDefinition.TypeName := G2D_VIDEO_ROTATE_TYPE_NAME;
  G2DVideoRotateDefinition.Rank := GST_RANK_NONE;
  G2DVideoRotateDefinition.FilterClass := TG2DVideoRotateFilter;

  G2DVideoRotateDefinition.Metadata.LongName := 'G2D Video Rotate Filter';
  G2DVideoRotateDefinition.Metadata.Classification := 'Filter/Effect/Video';
  G2DVideoRotateDefinition.Metadata.Description :=
    'Rotates BGRx video buffers using G2DOpenCV';
  G2DVideoRotateDefinition.Metadata.Author := 'G2D';

  G2DVideoRotateDefinition.SinkPad.NameTemplate := 'sink';
  G2DVideoRotateDefinition.SinkPad.Direction := GST_PAD_SINK;
  G2DVideoRotateDefinition.SinkPad.Presence := GST_PAD_ALWAYS;
  G2DVideoRotateDefinition.SinkPad.Caps := 'video/x-raw,format=BGRx';

  G2DVideoRotateDefinition.SrcPad.NameTemplate := 'src';
  G2DVideoRotateDefinition.SrcPad.Direction := GST_PAD_SRC;
  G2DVideoRotateDefinition.SrcPad.Presence := GST_PAD_ALWAYS;
  G2DVideoRotateDefinition.SrcPad.Caps := 'video/x-raw,format=BGRx';
end;

procedure G2DVideoRotateInstallProperties(AObjectClass: PGObjectClass);
var
  LName: UTF8String;
  LNick: UTF8String;
  LBlurb: UTF8String;
begin
  _g_object_class_install_property(
    AObjectClass,
    G2D_VIDEO_ROTATE_PROP_ANGLE,
    _g_param_spec_int(
      G2DUtf8Pgchar('rotateangle', LName),
      G2DUtf8Pgchar('Rotate angle', LNick),
      G2DUtf8Pgchar('Rotation angle in degrees from -180 to 180', LBlurb),
      -180,
      180,
      0,
      G_PARAM_READWRITE));
end;

procedure G2DVideoRotateClassInit(g_class: gpointer; class_data: gpointer); cdecl;
var
  LElementClass: PGstElementClass;
  LObjectClass: PGObjectClass;
begin
  LElementClass := PGstElementClass(g_class);
  G2DBaseFilterClassInit(
    LElementClass,
    G2DVideoRotateDefinition,
    G2DVideoRotateSinkTemplate,
    G2DVideoRotateSrcTemplate);

  LObjectClass := @LElementClass^.parent_class.parent_class.parent_class;
  G2DVideoRotateInstallProperties(LObjectClass);
end;

procedure G2DVideoRotateInit(instance: PGTypeInstance; g_class: gpointer); cdecl;
begin
  G2DBaseFilterInitInstance(
    @G2DVideoRotateDefinition,
    instance,
    G2DVideoRotateSinkTemplate,
    G2DVideoRotateSrcTemplate);
end;

function G2DVideoRotateGetType: GType; cdecl;
var
  LTypeInfo: GTypeInfo;
  LParentQuery: GTypeQuery;
  LTypeName: UTF8String;
begin
  if G2DVideoRotateType <> G_TYPE_INVALID then
    Exit(G2DVideoRotateType);

  G2D_RequirePluginAPI;

  FillChar(LTypeInfo, SizeOf(LTypeInfo), 0);
  FillChar(LParentQuery, SizeOf(LParentQuery), 0);
  _g_type_query(_gst_element_get_type, @LParentQuery);

  LTypeInfo.class_size := SizeOf(TG2DVideoRotateClass);
  LTypeInfo.class_init := G2DVideoRotateClassInit;
  LTypeInfo.instance_size := LParentQuery.instance_size;
  LTypeInfo.instance_init := G2DVideoRotateInit;

  G2DVideoRotateType := _g_type_register_static(
    _gst_element_get_type,
    G2DUtf8Pgchar(G2D_VIDEO_ROTATE_TYPE_NAME, LTypeName),
    @LTypeInfo,
    0);

  Result := G2DVideoRotateType;
end;

function G2DRegisterVideoRotate(APlugin: PGstPlugin): gboolean; cdecl;
begin
  Result := G2DRegisterElement(
    APlugin,
    G2D_VIDEO_ROTATE_ELEMENT_NAME,
    G2DVideoRotateDefinition.Rank,
    G2DVideoRotateGetType);
end;

initialization
  G2DPrepareVideoRotateDefinition;

end.

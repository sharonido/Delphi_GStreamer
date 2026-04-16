unit G2D.Gst.API;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  G2D.Glib.Types,
  G2D.Gobject.Types,
  G2D.Gst.Types,
  G2D.Glib.API,
  G2D.Gobject.API;

type
  EG2DGstError = class(Exception);

var
  G2D_GstHandle       : HMODULE = 0;
  G2D_GstVideoHandle  : HMODULE = 0;
  G2D_GstAudioHandle  : HMODULE = 0;
  G2D_GstAppHandle    : HMODULE = 0;
  G2D_GstLoaded: Boolean = False;

  { Core }
  _gst_init: procedure(argc: Pgint; argv: Pointer); cdecl = nil;
  _gst_deinit: procedure; cdecl = nil;
  _gst_is_initialized: function: gboolean; cdecl = nil;
  _gst_version_string: function: Pgchar; cdecl = nil;
  _gst_parse_launch: function(pipeline_description: Pgchar; error: PPGError): PGstElement; cdecl = nil;

  { MiniObject / Object }
  _gst_mini_object_ref: function(mini_object: PGstMiniObject): PGstMiniObject; cdecl = nil;
  _gst_mini_object_unref: procedure(mini_object: PGstMiniObject); cdecl = nil;

  _gst_object_ref: function(D_object: gpointer): gpointer; cdecl = nil;
  _gst_object_unref: procedure(D_object: gpointer); cdecl = nil;
  _gst_object_get_name: function(D_object: PGstObject): Pgchar; cdecl = nil;
  _gst_object_set_name: function(D_object: PGstObject; name: Pgchar): gboolean; cdecl = nil;

  { Element / Pipeline / Bin }
  _gst_pipeline_new: function(name: Pgchar): PGstElement; cdecl = nil;
  _gst_element_factory_make: function(factoryname: Pgchar; name: Pgchar): PGstElement; cdecl = nil;
  _gst_element_factory_find: function(name: Pgchar): PGstElementFactory; cdecl = nil;

  _gst_bin_add: function(bin: PGstBin; element: PGstElement): gboolean; cdecl = nil;
  _gst_bin_remove: function(bin: PGstBin; element: PGstElement): gboolean; cdecl = nil;
  _gst_bin_get_by_name: function(bin: PGstBin; name: Pgchar): PGstElement; cdecl = nil;
  _gst_bin_recalculate_latency: function(bin: PGstBin): gboolean; cdecl = nil;

  _gst_element_link: function(src, dest: PGstElement): gboolean; cdecl = nil;
  _gst_element_unlink: procedure(src, dest: PGstElement); cdecl = nil;

  _gst_element_set_state: function(element: PGstElement; state: GstState): GstStateChangeReturn; cdecl = nil;
  _gst_element_get_state: function(
    element: PGstElement;
    state: PGstState;
    pending: PGstState;
    timeout: GstClockTime
  ): GstStateChangeReturn; cdecl = nil;

  _gst_element_get_bus: function(element: PGstElement): PGstBus; cdecl = nil;
  _gst_element_get_static_pad: function(element: PGstElement; name: Pgchar): PGstPad; cdecl = nil;

  { Pad }
  _gst_pad_link: function(srcpad: PGstPad; sinkpad: PGstPad): GstPadLinkReturn; cdecl = nil;
  _gst_pad_unlink: function(srcpad: PGstPad; sinkpad: PGstPad): gboolean; cdecl = nil;
  _gst_pad_is_linked: function(pad: PGstPad): gboolean; cdecl = nil;
  _gst_pad_get_parent_element: function(pad: PGstPad): PGstElement; cdecl = nil;

  { Bus / Message }
  _gst_bus_timed_pop_filtered: function(
    bus: PGstBus;
    timeout: GstClockTime;
    types: GstMessageType
  ): PGstMessage; cdecl = nil;

  _gst_bus_pop: function(bus: PGstBus): PGstMessage; cdecl = nil;
  _gst_bus_have_pending: function(bus: PGstBus): gboolean; cdecl = nil;

  _gst_message_type_get_name: function(D_type: GstMessageType): Pgchar; cdecl = nil;
  _gst_message_parse_error: procedure(
    message: PGstMessage;
    gerror: PPGError;
    debug: PPgchar
  ); cdecl = nil;

  _gst_message_parse_warning: procedure(
    message: PGstMessage;
    gerror: PPGError;
    debug: PPgchar
  ); cdecl = nil;

  _gst_message_parse_state_changed: procedure(
    message: PGstMessage;
    oldstate: PGstState;
    newstate: PGstState;
    pending: PGstState
  ); cdecl = nil;

  { Names }
  _gst_element_state_get_name: function(state: GstState): Pgchar; cdecl = nil;
  _gst_pad_link_get_name: function(ret: GstPadLinkReturn): Pgchar; cdecl = nil;
  _gst_flow_get_name: function(ret: GstFlowReturn): Pgchar; cdecl = nil;

  { Video }
  _gst_video_overlay_set_window_handle: procedure(overlay: gpointer;
     handle: guintptr); cdecl = nil;
  _gst_video_overlay_expose: procedure(overlay: gpointer); cdecl = nil;

  { Video Info / Frame }
  _gst_video_info_init      : procedure(info: PGstVideoInfo); cdecl = nil;
  _gst_video_info_from_caps : function(info: PGstVideoInfo; caps: PGstCaps): gboolean; cdecl = nil;
  _gst_video_frame_map      : function(frame: PGstVideoFrame; info: PGstVideoInfo;
                                buffer: PGstBuffer; flags: GstMapFlags): gboolean; cdecl = nil;
  _gst_video_frame_unmap    : procedure(frame: PGstVideoFrame); cdecl = nil;
  _gst_caps_from_string     : function(str: Pgchar): PGstCaps; cdecl = nil;
  _gst_util_set_object_arg  : procedure(obj: gpointer; name: Pgchar;
    value: Pgchar); cdecl = nil;

  { Position }
  _gst_element_query_position: function(element: PGstElement; format: GstFormat;
      cur: Pgint64): gboolean; cdecl = nil;
  _gst_element_query_duration: function(element: PGstElement; format: GstFormat;
       duration: Pgint64): gboolean; cdecl = nil;
  _gst_element_seek_simple: function(element: PGstElement; format: GstFormat;
       seek_flags: GstSeekFlags; seek_pos: gint64): gboolean; cdecl = nil;

  { Tutorial 6 - Element Factory }
  _gst_element_factory_create: function(factory: PGstElementFactory; name: Pgchar): PGstElement; cdecl = nil;
  _gst_element_factory_get_static_pad_templates: function(factory: PGstElementFactory): PGList; cdecl = nil;
  _gst_element_factory_get_metadata: function(factory: PGstElementFactory; key: Pgchar): Pgchar; cdecl = nil;

  { Tutorial 6 - Pad Template }
  _gst_static_pad_template_get_caps: function(pad_template: PGstStaticPadTemplate): PGstCaps; cdecl = nil;
  _gst_pad_get_current_caps: function(pad: PGstPad): PGstCaps; cdecl = nil;
  _gst_pad_get_pad_template_caps: function(pad: PGstPad): PGstCaps; cdecl = nil;

  { Tutorial 6 - Caps }
  _gst_caps_is_any: function(caps: PGstCaps): gboolean; cdecl = nil;
  _gst_caps_is_empty: function(caps: PGstCaps): gboolean; cdecl = nil;
  _gst_caps_get_size: function(caps: PGstCaps): guint; cdecl = nil;
  _gst_caps_get_structure: function(caps: PGstCaps; index: guint): PGstStructure; cdecl = nil;
  _gst_caps_unref: procedure(caps: PGstCaps); cdecl = nil;
  _gst_caps_to_string: function(caps: PGstCaps): Pgchar; cdecl = nil;

  { Tutorial 6 - Structure }
  _gst_structure_get_name: function(structure: PGstStructure): Pgchar; cdecl = nil;
  _gst_structure_foreach: function(structure: PGstStructure; func: GstStructureForeachFunc; user_data: gpointer): gboolean; cdecl = nil;

  { Tutorial 6 - Value }
  _gst_value_serialize: function(value: PGValue): Pgchar; cdecl = nil;

  { Tutorial 7 - Request Pads }
  _gst_element_request_pad_simple: function(element: PGstElement; name: Pgchar): PGstPad; cdecl = nil;
  _gst_element_release_request_pad: procedure(element: PGstElement; pad: PGstPad); cdecl = nil;

  { Tutorial 8 - Buffer }
  _gst_buffer_new_allocate: function(allocator: gpointer; size: gsize; params: gpointer): PGstBuffer; cdecl = nil;
  _gst_buffer_map: function(buffer: PGstBuffer; info: PGstMapInfo; flags: GstMapFlags): gboolean; cdecl = nil;
  _gst_buffer_unmap: procedure(buffer: PGstBuffer; info: PGstMapInfo); cdecl = nil;
  _gst_buffer_unref: procedure(buffer: PGstBuffer); cdecl = nil;

  { Tutorial 8 - Sample }
  _gst_sample_get_buffer: function(sample: gpointer): PGstBuffer; cdecl = nil;
  _gst_sample_get_caps  : function(sample: gpointer): PGstCaps; cdecl = nil;
  _gst_sample_unref     : procedure(sample: gpointer); cdecl = nil;

  { Tutorial 8 - Audio Info / Caps }
  _gst_audio_info_set_format: procedure(info: PGstAudioInfo; format: GstAudioFormat;
    rate: gint; channels: gint; position: gpointer); cdecl = nil;
  _gst_audio_info_to_caps: function(info: PGstAudioInfo): PGstCaps; cdecl = nil;
  _gst_audio_info_init     : procedure(info: PGstAudioInfo); cdecl = nil;
  _gst_audio_info_from_caps: function(info: PGstAudioInfo;
    caps: PGstCaps): gboolean; cdecl = nil;

  { App - direct functions from gstapp-1.0-0.dll }
  _gst_app_sink_pull_sample : function(appsink: PGstElement): gpointer; cdecl = nil;
  _gst_app_src_push_sample  : function(appsrc: PGstElement;
    sample: gpointer): GstFlowReturn; cdecl = nil;
  _gst_app_src_push_buffer  : function(appsrc: PGstElement;
    buffer: PGstBuffer): GstFlowReturn; cdecl = nil;
  _gst_app_src_set_caps     : procedure(appsrc: PGstElement;
    caps: PGstCaps); cdecl = nil;

function G2D_LoadGst: Boolean;
procedure G2D_UnloadGst;
function G2D_GstLoadedOK: Boolean;
procedure GstInit;

{ D-wrapper helper functions }
function DGstValueSerialize(AValue: PGValue): string;
function DGstStaticPadTemplateGetCaps(ATemplate: PGstStaticPadTemplate): PGstCaps;
procedure DGstObjectUnref(AObject: gpointer);

implementation


procedure GstInit;
begin
if G2D_LoadGlib then
  if G2D_LoadGObject then G2D_LoadGst;
_gst_init(nil, nil);
if _gst_is_initialized() = 0 then
  raise Exception.Create('GStreamer failed to initialize');
end;

function _LoadProcGst(const AName: AnsiString): Pointer;
begin
  Result := GetProcAddress(G2D_GstHandle, PAnsiChar(AName));
  if Result = nil then
    raise EG2DGstError.CreateFmt(
      'GStreamer: required function not found: %s', [string(AName)]);
end;

function _LoadProcGstVideo(const AName: AnsiString): Pointer;
begin
  Result := GetProcAddress(G2D_GstVideoHandle, PAnsiChar(AName));
  if Result = nil then
    raise EG2DGstError.CreateFmt(
      'GStreamer: required Video function not found: %s',[string(AName)]);
end;

function _LoadProcGstAudio(const AName: AnsiString): Pointer;
begin
  Result := GetProcAddress(G2D_GstAudioHandle, PAnsiChar(AName));
  if Result = nil then
    raise EG2DGstError.CreateFmt(
      'GStreamer: required Audio function not found: %s',[string(AName)]);
end;

function _LoadProcGstApp(const AName: AnsiString): Pointer;
begin
  Result := GetProcAddress(G2D_GstAppHandle, PAnsiChar(AName));
  if Result = nil then
    raise EG2DGstError.CreateFmt(
      'GStreamer: required App function not found: %s', [string(AName)]);
end;

procedure _ResetGstPointers;
begin
  { Core }
  _gst_init := nil;
  _gst_deinit := nil;
  _gst_is_initialized := nil;
  _gst_version_string := nil;
  _gst_parse_launch := nil;

  { MiniObject / Object }
  _gst_mini_object_ref := nil;
  _gst_mini_object_unref := nil;

  _gst_object_ref := nil;
  _gst_object_unref := nil;
  _gst_object_get_name := nil;
  _gst_object_set_name := nil;

  { Element / Pipeline / Bin }
  _gst_pipeline_new := nil;
  _gst_element_factory_make := nil;
  _gst_element_factory_find := nil;

  _gst_bin_add := nil;
  _gst_bin_remove := nil;
  _gst_bin_get_by_name := nil;
  _gst_bin_recalculate_latency := nil;

  _gst_element_link := nil;
  _gst_element_unlink := nil;

  _gst_element_set_state := nil;
  _gst_element_get_state := nil;

  _gst_element_get_bus := nil;
  _gst_element_get_static_pad := nil;

  { Pad }
  _gst_pad_link := nil;
  _gst_pad_unlink := nil;
  _gst_pad_is_linked := nil;
  _gst_pad_get_parent_element := nil;

  { Bus / Message }
  _gst_bus_timed_pop_filtered := nil;
  _gst_bus_pop := nil;
  _gst_bus_have_pending := nil;

  _gst_message_type_get_name := nil;
  _gst_message_parse_error := nil;
  _gst_message_parse_warning := nil;
  _gst_message_parse_state_changed := nil;

  { Names }
  _gst_element_state_get_name := nil;
  _gst_pad_link_get_name := nil;
  _gst_flow_get_name := nil;

  { Video }
  _gst_video_overlay_set_window_handle := nil;
  _gst_video_overlay_expose := nil;

  { Video Info / Frame }
  _gst_video_info_init      := nil;
  _gst_video_info_from_caps := nil;
  _gst_video_frame_map      := nil;
  _gst_video_frame_unmap    := nil;
  _gst_caps_from_string     := nil;
  _gst_util_set_object_arg  := nil;

  { Position }
  _gst_element_query_position := nil;
  _gst_element_query_duration := nil;
  _gst_element_seek_simple := nil;

  { Tutorial 6 }
  _gst_element_factory_create := nil;
  _gst_element_factory_get_static_pad_templates := nil;
  _gst_element_factory_get_metadata := nil;

  _gst_static_pad_template_get_caps := nil;
  _gst_pad_get_current_caps := nil;
  _gst_pad_get_pad_template_caps := nil;

  _gst_caps_is_any := nil;
  _gst_caps_is_empty := nil;
  _gst_caps_get_size := nil;
  _gst_caps_get_structure := nil;
  _gst_caps_unref := nil;
  _gst_caps_to_string := nil;

  _gst_structure_get_name := nil;
  _gst_structure_foreach := nil;

  _gst_value_serialize := nil;

  { Tutorial 7 }
  _gst_element_request_pad_simple := nil;
  _gst_element_release_request_pad := nil;

  { Tutorial 8 }
  _gst_buffer_new_allocate := nil;
  _gst_buffer_map := nil;
  _gst_buffer_unmap := nil;
  _gst_buffer_unref := nil;

  _gst_sample_get_buffer := nil;
  _gst_sample_get_caps   := nil;
  _gst_sample_unref      := nil;

  _gst_audio_info_set_format := nil;
  _gst_audio_info_to_caps    := nil;
  _gst_audio_info_init       := nil;
  _gst_audio_info_from_caps  := nil;

  { App }
  _gst_app_sink_pull_sample := nil;
  _gst_app_src_push_sample  := nil;
  _gst_app_src_push_buffer  := nil;
  _gst_app_src_set_caps     := nil;
end;

procedure _BindGstFunctions;
begin
  { Core }
  @_gst_init := _LoadProcGst('gst_init');
  @_gst_deinit := _LoadProcGst('gst_deinit');
  @_gst_is_initialized := _LoadProcGst('gst_is_initialized');
  @_gst_version_string := _LoadProcGst('gst_version_string');
  @_gst_parse_launch := _LoadProcGst('gst_parse_launch');

  { MiniObject / Object }
  @_gst_mini_object_ref := _LoadProcGst('gst_mini_object_ref');
  @_gst_mini_object_unref := _LoadProcGst('gst_mini_object_unref');

  @_gst_object_ref := _LoadProcGst('gst_object_ref');
  @_gst_object_unref := _LoadProcGst('gst_object_unref');
  @_gst_object_get_name := _LoadProcGst('gst_object_get_name');
  @_gst_object_set_name := _LoadProcGst('gst_object_set_name');

  { Element / Pipeline / Bin }
  @_gst_pipeline_new := _LoadProcGst('gst_pipeline_new');
  @_gst_element_factory_make := _LoadProcGst('gst_element_factory_make');
  @_gst_element_factory_find := _LoadProcGst('gst_element_factory_find');

  @_gst_bin_add := _LoadProcGst('gst_bin_add');
  @_gst_bin_remove := _LoadProcGst('gst_bin_remove');
  @_gst_bin_get_by_name := _LoadProcGst('gst_bin_get_by_name');
  @_gst_bin_recalculate_latency := _LoadProcGst('gst_bin_recalculate_latency');

  @_gst_element_link := _LoadProcGst('gst_element_link');
  @_gst_element_unlink := _LoadProcGst('gst_element_unlink');

  @_gst_element_set_state := _LoadProcGst('gst_element_set_state');
  @_gst_element_get_state := _LoadProcGst('gst_element_get_state');

  @_gst_element_get_bus := _LoadProcGst('gst_element_get_bus');
  @_gst_element_get_static_pad := _LoadProcGst('gst_element_get_static_pad');

  { Pad }
  @_gst_pad_link := _LoadProcGst('gst_pad_link');
  @_gst_pad_unlink := _LoadProcGst('gst_pad_unlink');
  @_gst_pad_is_linked := _LoadProcGst('gst_pad_is_linked');
  @_gst_pad_get_parent_element := _LoadProcGst('gst_pad_get_parent_element');

  { Bus / Message }
  @_gst_bus_timed_pop_filtered := _LoadProcGst('gst_bus_timed_pop_filtered');
  @_gst_bus_pop := _LoadProcGst('gst_bus_pop');
  @_gst_bus_have_pending := _LoadProcGst('gst_bus_have_pending');

  @_gst_message_type_get_name := _LoadProcGst('gst_message_type_get_name');
  @_gst_message_parse_error := _LoadProcGst('gst_message_parse_error');
  @_gst_message_parse_warning := _LoadProcGst('gst_message_parse_warning');
  @_gst_message_parse_state_changed := _LoadProcGst('gst_message_parse_state_changed');

  { Names }
  @_gst_element_state_get_name := _LoadProcGst('gst_element_state_get_name');
  @_gst_pad_link_get_name := _LoadProcGst('gst_pad_link_get_name');
  @_gst_flow_get_name := _LoadProcGst('gst_flow_get_name');

  { Video }
  @_gst_video_overlay_set_window_handle := _LoadProcGstVideo('gst_video_overlay_set_window_handle');
  @_gst_video_overlay_expose := _LoadProcGstVideo('gst_video_overlay_expose');

  { Video Info / Frame }
  @_gst_video_info_init      := _LoadProcGstVideo('gst_video_info_init');
  @_gst_video_info_from_caps := _LoadProcGstVideo('gst_video_info_from_caps');
  @_gst_video_frame_map      := _LoadProcGstVideo('gst_video_frame_map');
  @_gst_video_frame_unmap    := _LoadProcGstVideo('gst_video_frame_unmap');
  @_gst_caps_from_string     := _LoadProcGst('gst_caps_from_string');
  @_gst_util_set_object_arg  := _LoadProcGst('gst_util_set_object_arg');

  { Position }
  @_gst_element_query_position := _LoadProcGst('gst_element_query_position');
  @_gst_element_query_duration := _LoadProcGst('gst_element_query_duration');
  @_gst_element_seek_simple := _LoadProcGst('gst_element_seek_simple');

  { Tutorial 6 - Element Factory }
  @_gst_element_factory_create := _LoadProcGst('gst_element_factory_create');
  @_gst_element_factory_get_static_pad_templates := _LoadProcGst('gst_element_factory_get_static_pad_templates');
  @_gst_element_factory_get_metadata := _LoadProcGst('gst_element_factory_get_metadata');

  { Tutorial 6 - Pad Template }
  @_gst_static_pad_template_get_caps := _LoadProcGst('gst_static_pad_template_get_caps');
  @_gst_pad_get_current_caps := _LoadProcGst('gst_pad_get_current_caps');
  @_gst_pad_get_pad_template_caps := _LoadProcGst('gst_pad_get_pad_template_caps');

  { Tutorial 6 - Caps }
  @_gst_caps_is_any := _LoadProcGst('gst_caps_is_any');
  @_gst_caps_is_empty := _LoadProcGst('gst_caps_is_empty');
  @_gst_caps_get_size := _LoadProcGst('gst_caps_get_size');
  @_gst_caps_get_structure := _LoadProcGst('gst_caps_get_structure');
  @_gst_caps_unref := _LoadProcGst('gst_caps_unref');
  @_gst_caps_to_string := _LoadProcGst('gst_caps_to_string');

  { Tutorial 6 - Structure }
  @_gst_structure_get_name := _LoadProcGst('gst_structure_get_name');
  @_gst_structure_foreach := _LoadProcGst('gst_structure_foreach');

  { Tutorial 6 - Value }
  @_gst_value_serialize := _LoadProcGst('gst_value_serialize');

  { Tutorial 7 - Request Pads }
  @_gst_element_request_pad_simple := _LoadProcGst('gst_element_request_pad_simple');
  @_gst_element_release_request_pad := _LoadProcGst('gst_element_release_request_pad');

  { Tutorial 8 - Buffer }
  @_gst_buffer_new_allocate := _LoadProcGst('gst_buffer_new_allocate');
  @_gst_buffer_map := _LoadProcGst('gst_buffer_map');
  @_gst_buffer_unmap := _LoadProcGst('gst_buffer_unmap');
  @_gst_buffer_unref := _LoadProcGst('gst_buffer_unref');

  { Tutorial 8 - Sample }
  @_gst_sample_get_buffer := _LoadProcGst('gst_sample_get_buffer');
  @_gst_sample_get_caps   := _LoadProcGst('gst_sample_get_caps');
  @_gst_sample_unref      := _LoadProcGst('gst_sample_unref');

  { Tutorial 8 - Audio Info / Caps }
  @_gst_audio_info_set_format := _LoadProcGstAudio('gst_audio_info_set_format');
  @_gst_audio_info_to_caps    := _LoadProcGstAudio('gst_audio_info_to_caps');
  @_gst_audio_info_init       := _LoadProcGstAudio('gst_audio_info_init');
  @_gst_audio_info_from_caps  := _LoadProcGstAudio('gst_audio_info_from_caps');

  { App - direct functions }
  @_gst_app_sink_pull_sample := _LoadProcGstApp('gst_app_sink_pull_sample');
  @_gst_app_src_push_sample  := _LoadProcGstApp('gst_app_src_push_sample');
  @_gst_app_src_push_buffer  := _LoadProcGstApp('gst_app_src_push_buffer');
  @_gst_app_src_set_caps     := _LoadProcGstApp('gst_app_src_set_caps');
end;

function G2D_LoadGst: Boolean;
begin
  if G2D_GstLoaded then
    Exit(True);

  if not G2D_GlibLoadedOK then
    raise EG2DGstError.Create('GLib must be loaded before GStreamer');

  if not G2D_GobjectLoadedOK then
    raise EG2DGstError.Create('GObject must be loaded before GStreamer');

  _ResetGstPointers;

  G2D_GstHandle := G2D_LoadDLLModule(PChar('gstreamer-1.0-0.dll'));
  if G2D_GstHandle = 0 then
    raise EG2DGstError.Create('Failed to load GStreamer DLL: gstreamer-1.0-0.dll');

  G2D_GstVideoHandle := G2D_LoadDLLModule(PChar('gstvideo-1.0-0.dll'));
  if G2D_GstVideoHandle = 0 then
    raise EG2DGstError.Create('Failed to load GStreamer DLL: gstvideo-1.0-0.dll');

  G2D_GstAudioHandle := G2D_LoadDLLModule(PChar('gstaudio-1.0-0.dll'));
  if G2D_GstAudioHandle = 0 then
    raise EG2DGstError.Create('Failed to load GStreamer DLL: gstaudio-1.0-0.dll');

  G2D_GstAppHandle := G2D_LoadDLLModule(PChar('gstapp-1.0-0.dll'));
  if G2D_GstAppHandle = 0 then
    raise EG2DGstError.Create('Failed to load GStreamer DLL: gstapp-1.0-0.dll');

  try
    _BindGstFunctions;
    G2D_GstLoaded := True;
    Result := True;
  except
    FreeLibrary(G2D_GstHandle);
    G2D_GstHandle := 0;
    FreeLibrary(G2D_GstVideoHandle);
    G2D_GstVideoHandle := 0;
    FreeLibrary(G2D_GstAudioHandle);
    G2D_GstAudioHandle := 0;
    FreeLibrary(G2D_GstAppHandle);
    G2D_GstAppHandle := 0;
    _ResetGstPointers;
    G2D_GstLoaded := False;
    raise;
  end;
end;

procedure G2D_UnloadGst;
begin
  if G2D_GstHandle <> 0 then
  begin
    FreeLibrary(G2D_GstHandle);
    G2D_GstHandle := 0;        { fixed: was wrongly zeroing G2D_GstVideoHandle }
  end;
  if G2D_GstVideoHandle <> 0 then
  begin
    FreeLibrary(G2D_GstVideoHandle);
    G2D_GstVideoHandle := 0;
  end;
  if G2D_GstAudioHandle <> 0 then
  begin
    FreeLibrary(G2D_GstAudioHandle);
    G2D_GstAudioHandle := 0;
  end;
  if G2D_GstAppHandle <> 0 then
  begin
    FreeLibrary(G2D_GstAppHandle);
    G2D_GstAppHandle := 0;
  end;

  _ResetGstPointers;
  G2D_GstLoaded := False;
end;

function G2D_GstLoadedOK: Boolean;
begin
  Result := G2D_GstLoaded and (G2D_GstHandle <> 0);
end;

{ D-wrapper helper functions }

function DGstValueSerialize(AValue: PGValue): string;
var
  P: Pgchar;
begin
  if AValue = nil then
    Exit('');

  P := _gst_value_serialize(AValue);
  if P = nil then
    Exit('');

  Result := string(UTF8String(AnsiString(P)));
  _g_free(P);
end;

function DGstStaticPadTemplateGetCaps(ATemplate: PGstStaticPadTemplate): PGstCaps;
begin
  if ATemplate = nil then
    Exit(nil);
  Result := _gst_static_pad_template_get_caps(ATemplate);
end;

procedure DGstObjectUnref(AObject: gpointer);
begin
  if AObject <> nil then
    _gst_object_unref(AObject);
end;

initialization
  _ResetGstPointers;

finalization
  G2D_UnloadGst;

end.

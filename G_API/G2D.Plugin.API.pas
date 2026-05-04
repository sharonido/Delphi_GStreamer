unit G2D.Plugin.API;

{------------------------------------------------------------------------------
  G2D.Plugin.API

  Facade/validation unit for GStreamer plugin-authoring symbols. The actual
  dynamic imports remain owned by G2D.Gst.API and G2D.Gobject.API.
------------------------------------------------------------------------------}

interface

uses
  System.SysUtils,
  G2D.Glib.API,
  G2D.Gobject.API,
  G2D.Gst.API;

type
  EG2DPluginAPIError = class(Exception);

function G2D_LoadPluginAPI: Boolean;
procedure G2D_RequirePluginAPI;
function G2D_PluginAPILoadedOK: Boolean;

implementation

function G2D_PluginAPILoadedOK: Boolean;
begin
  Result :=
    G2D_GlibLoadedOK and
    G2D_GobjectLoadedOK and
    G2D_GstLoadedOK and
    Assigned(_g_type_register_static) and
    Assigned(_g_object_class_install_property) and
    Assigned(_g_param_spec_boolean) and
    Assigned(_g_param_spec_int) and
    Assigned(_g_param_spec_string) and
    Assigned(_gst_element_get_type) and
    Assigned(_gst_element_register) and
    Assigned(_gst_element_class_set_static_metadata) and
    Assigned(_gst_element_class_add_static_pad_template) and
    Assigned(_gst_pad_new_from_static_template) and
    Assigned(_gst_pad_set_chain_function_full) and
    Assigned(_gst_pad_set_event_function_full) and
    Assigned(_gst_pad_set_query_function_full) and
    Assigned(_gst_element_add_pad) and
    Assigned(_gst_pad_push) and
    Assigned(_gst_buffer_get_size) and
    Assigned(_gst_pad_push_event) and
    Assigned(_gst_pad_peer_query) and
    Assigned(_gst_pad_query_default) and
    Assigned(_gst_event_parse_caps) and
    Assigned(_gst_query_parse_position) and
    Assigned(_gst_query_parse_duration) and
    Assigned(_gst_query_parse_latency) and
    Assigned(_gst_query_parse_allocation) and
    Assigned(_gst_query_parse_accept_caps) and
    Assigned(_gst_query_parse_accept_caps_result) and
    Assigned(_gst_query_parse_caps) and
    Assigned(_gst_query_parse_caps_result) and
    Assigned(_gst_format_get_name);
end;

function G2D_LoadPluginAPI: Boolean;
begin
  if not G2D_GlibLoadedOK then
    G2D_LoadGlib;
  if not G2D_GobjectLoadedOK then
    G2D_LoadGobject;
  if not G2D_GstLoadedOK then
    G2D_LoadGst;

  Result := G2D_PluginAPILoadedOK;
end;

procedure G2D_RequirePluginAPI;
begin
  if not G2D_LoadPluginAPI then
    raise EG2DPluginAPIError.Create(
      'GStreamer plugin API is not fully loaded. Required plugin-authoring symbols are missing.');
end;

end.

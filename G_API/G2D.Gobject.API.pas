unit G2D.Gobject.API;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  G2D.Glib.Types,
  G2D.Gobject.Types,
  G2D.Glib.API;

type
  EG2DGobjectError = class(Exception);

var
  G2D_GobjectHandle: HMODULE = 0;
  G2D_GobjectLoaded: Boolean = False;

  { GType }
  _g_type_from_name: function(name: Pgchar): GType; cdecl = nil;
  _g_type_name: function(D_type: GType): Pgchar; cdecl = nil;
  _g_type_is_a: function(D_type: GType; is_a_type: GType): gboolean; cdecl = nil;
  _g_type_parent: function(D_type: GType): GType; cdecl = nil;
  _g_type_query: procedure(D_type: GType; query: PGTypeQuery); cdecl = nil;
  _g_type_check_instance_is_a: function(instance: PGTypeInstance; iface_type: GType): gboolean; cdecl = nil;
  _g_type_check_instance_cast: function(instance: PGTypeInstance; iface_type: GType): PGTypeInstance; cdecl = nil;
  _g_type_class_ref: function(D_type: GType): PGTypeClass; cdecl = nil;
  _g_type_class_peek: function(D_type: GType): PGTypeClass; cdecl = nil;
  _g_type_class_unref: procedure(g_class: PGTypeClass); cdecl = nil;

  { GValue }
  _g_value_init: function(value: PGValue; g_type: GType): PGValue; cdecl = nil;
  _g_value_unset: procedure(value: PGValue); cdecl = nil;
  _g_value_reset: function(value: PGValue): PGValue; cdecl = nil;
  _g_value_copy: procedure(const src_value: PGValue; dest_value: PGValue); cdecl = nil;
  _g_value_type_compatible: function(src_type: GType; dest_type: GType): gboolean; cdecl = nil;
  _g_value_type_transformable: function(src_type: GType; dest_type: GType): gboolean; cdecl = nil;
  _g_value_transform: function(const src_value: PGValue; dest_value: PGValue): gboolean; cdecl = nil;

  _g_value_set_string: procedure(value: PGValue; const v_string: Pgchar); cdecl = nil;
  _g_value_get_string: function(const value: PGValue): Pgchar; cdecl = nil;

  _g_value_set_int: procedure(value: PGValue; v_int: gint); cdecl = nil;
  _g_value_get_int: function(const value: PGValue): gint; cdecl = nil;

  _g_value_set_uint: procedure(value: PGValue; v_uint: guint); cdecl = nil;
  _g_value_get_uint: function(const value: PGValue): guint; cdecl = nil;

  _g_value_set_boolean: procedure(value: PGValue; v_boolean: gboolean); cdecl = nil;
  _g_value_get_boolean: function(const value: PGValue): gboolean; cdecl = nil;

  _g_value_set_object: procedure(value: PGValue; v_object: gpointer); cdecl = nil;
  _g_value_get_object: function(const value: PGValue): gpointer; cdecl = nil;

  _g_value_set_pointer: procedure(value: PGValue; v_pointer: gpointer); cdecl = nil;
  _g_value_get_pointer: function(const value: PGValue): gpointer; cdecl = nil;

  _g_value_set_double: procedure(value: PGValue; v_double: gdouble); cdecl = nil;
  _g_value_get_double: function(const value: PGValue): gdouble; cdecl = nil;

  _g_value_set_float: procedure(value: PGValue; v_float: gfloat); cdecl = nil;
  _g_value_get_float: function(const value: PGValue): gfloat; cdecl = nil;

  _g_value_set_int64: procedure(value: PGValue; v_int64: gint64); cdecl = nil;
  _g_value_get_int64: function(const value: PGValue): gint64; cdecl = nil;

  _g_value_set_uint64: procedure(value: PGValue; v_uint64: guint64); cdecl = nil;
  _g_value_get_uint64: function(const value: PGValue): guint64; cdecl = nil;

  { GObject }
  _g_object_new: function(object_type: GType; first_property_name: Pgchar): gpointer; cdecl = nil;
  _g_object_new_with_properties: function(
    object_type: GType;
    n_properties: guint;
    names: PPgchar;
    values: PGValue
  ): gpointer; cdecl = nil;

  _g_object_ref: function(D_object: gpointer): gpointer; cdecl = nil;
  _g_object_unref: procedure(D_object: gpointer); cdecl = nil;
  _g_object_ref_sink: function(D_object: gpointer): gpointer; cdecl = nil;
  _g_object_is_floating: function(D_object: gpointer): gboolean; cdecl = nil;
  _g_object_force_floating: procedure(D_object: gpointer); cdecl = nil;

  _g_object_set_property: procedure(
    D_object: gpointer;
    property_name: Pgchar;
    value: PGValue
  ); cdecl = nil;

  { varargs version - used for setting caps and other complex properties }
  _g_object_set: procedure(D_object: gpointer; first_property_name: Pgchar); cdecl varargs = nil;

  _g_object_get_property: procedure(
    D_object: gpointer;
    property_name: Pgchar;
    value: PGValue
  ); cdecl = nil;

  _g_object_get_data: function(
    D_object: PGObject;
    key: Pgchar
  ): gpointer; cdecl = nil;

  _g_object_set_data: procedure(
    D_object: PGObject;
    key: Pgchar;
    data: gpointer
  ); cdecl = nil;

  _g_object_set_data_full: procedure(
    D_object: PGObject;
    key: Pgchar;
    data: gpointer;
    destroy: GDestroyNotify
  ); cdecl = nil;

  _g_object_class_find_property: function(
    oclass: PGObjectClass;
    property_name: Pgchar
  ): PGParamSpec; cdecl = nil;

  _g_object_notify: procedure(D_object: gpointer; property_name: Pgchar); cdecl = nil;
  _g_object_notify_by_pspec: procedure(D_object: gpointer; pspec: PGParamSpec); cdecl = nil;

  _g_object_weak_ref: procedure(
    D_object: PGObject;
    notify: GWeakNotify;
    data: gpointer
  ); cdecl = nil;

  _g_object_weak_unref: procedure(
    D_object: PGObject;
    notify: GWeakNotify;
    data: gpointer
  ); cdecl = nil;

  { Signals }
  _g_signal_connect_data: function(
    instance: gpointer;
    detailed_signal: Pgchar;
    c_handler: GCallback;
    data: gpointer;
    destroy_data: GClosureNotify;
    connect_flags: GConnectFlags
  ): gulong; cdecl = nil;

  _g_signal_handler_disconnect: procedure(
    instance: gpointer;
    handler_id: gulong
  ); cdecl = nil;

  _g_signal_handler_block: procedure(
    instance: gpointer;
    handler_id: gulong
  ); cdecl = nil;

  _g_signal_handler_unblock: procedure(
    instance: gpointer;
    handler_id: gulong
  ); cdecl = nil;

  _g_signal_lookup: function(
    name: Pgchar;
    itype: GType
  ): guint; cdecl = nil;

  _g_signal_name: function(signal_id: guint): Pgchar; cdecl = nil;

  { Tutorial 8 - emit by name (varargs - used for push-buffer / pull-sample) }
  _g_signal_emit_by_name: procedure(instance: gpointer; detailed_signal: Pgchar); cdecl varargs = nil;

function G2D_LoadGobject: Boolean;
procedure G2D_UnloadGobject;
function G2D_GobjectLoadedOK: Boolean;

implementation

function _LoadProc(const AName: AnsiString): Pointer;
begin
  Result := GetProcAddress(G2D_GobjectHandle, PAnsiChar(AName));
  if Result = nil then
    raise EG2DGobjectError.CreateFmt(
      'GObject: required function not found: %s',
      [string(AName)]
    );
end;

procedure _ResetGobjectPointers;
begin
  { GType }
  _g_type_from_name := nil;
  _g_type_name := nil;
  _g_type_is_a := nil;
  _g_type_parent := nil;
  _g_type_query := nil;
  _g_type_check_instance_is_a := nil;
  _g_type_check_instance_cast := nil;
  _g_type_class_ref := nil;
  _g_type_class_peek := nil;
  _g_type_class_unref := nil;

  { GValue }
  _g_value_init := nil;
  _g_value_unset := nil;
  _g_value_reset := nil;
  _g_value_copy := nil;
  _g_value_type_compatible := nil;
  _g_value_type_transformable := nil;
  _g_value_transform := nil;

  _g_value_set_string := nil;
  _g_value_get_string := nil;
  _g_value_set_int := nil;
  _g_value_get_int := nil;
  _g_value_set_uint := nil;
  _g_value_get_uint := nil;
  _g_value_set_boolean := nil;
  _g_value_get_boolean := nil;
  _g_value_set_object := nil;
  _g_value_get_object := nil;
  _g_value_set_pointer := nil;
  _g_value_get_pointer := nil;
  _g_value_set_double := nil;
  _g_value_get_double := nil;
  _g_value_set_float := nil;
  _g_value_get_float := nil;
  _g_value_set_int64 := nil;
  _g_value_get_int64 := nil;
  _g_value_set_uint64 := nil;
  _g_value_get_uint64 := nil;

  { GObject }
  _g_object_new := nil;
  _g_object_new_with_properties := nil;
  _g_object_ref := nil;
  _g_object_unref := nil;
  _g_object_ref_sink := nil;
  _g_object_is_floating := nil;
  _g_object_force_floating := nil;
  _g_object_set_property := nil;
  _g_object_set := nil;
  _g_object_get_property := nil;
  _g_object_get_data := nil;
  _g_object_set_data := nil;
  _g_object_set_data_full := nil;
  _g_object_class_find_property := nil;
  _g_object_notify := nil;
  _g_object_notify_by_pspec := nil;
  _g_object_weak_ref := nil;
  _g_object_weak_unref := nil;

  { Signals }
  _g_signal_connect_data := nil;
  _g_signal_handler_disconnect := nil;
  _g_signal_handler_block := nil;
  _g_signal_handler_unblock := nil;
  _g_signal_lookup := nil;
  _g_signal_name := nil;
  _g_signal_emit_by_name := nil;
end;

procedure _BindGobjectFunctions;
begin
  { GType }
  @_g_type_from_name := _LoadProc('g_type_from_name');
  @_g_type_name := _LoadProc('g_type_name');
  @_g_type_is_a := _LoadProc('g_type_is_a');
  @_g_type_parent := _LoadProc('g_type_parent');
  @_g_type_query := _LoadProc('g_type_query');
  @_g_type_check_instance_is_a := _LoadProc('g_type_check_instance_is_a');
  @_g_type_check_instance_cast := _LoadProc('g_type_check_instance_cast');
  @_g_type_class_ref := _LoadProc('g_type_class_ref');
  @_g_type_class_peek := _LoadProc('g_type_class_peek');
  @_g_type_class_unref := _LoadProc('g_type_class_unref');

  { GValue }
  @_g_value_init := _LoadProc('g_value_init');
  @_g_value_unset := _LoadProc('g_value_unset');
  @_g_value_reset := _LoadProc('g_value_reset');
  @_g_value_copy := _LoadProc('g_value_copy');
  @_g_value_type_compatible := _LoadProc('g_value_type_compatible');
  @_g_value_type_transformable := _LoadProc('g_value_type_transformable');
  @_g_value_transform := _LoadProc('g_value_transform');

  @_g_value_set_string := _LoadProc('g_value_set_string');
  @_g_value_get_string := _LoadProc('g_value_get_string');
  @_g_value_set_int := _LoadProc('g_value_set_int');
  @_g_value_get_int := _LoadProc('g_value_get_int');
  @_g_value_set_uint := _LoadProc('g_value_set_uint');
  @_g_value_get_uint := _LoadProc('g_value_get_uint');
  @_g_value_set_boolean := _LoadProc('g_value_set_boolean');
  @_g_value_get_boolean := _LoadProc('g_value_get_boolean');
  @_g_value_set_object := _LoadProc('g_value_set_object');
  @_g_value_get_object := _LoadProc('g_value_get_object');
  @_g_value_set_pointer := _LoadProc('g_value_set_pointer');
  @_g_value_get_pointer := _LoadProc('g_value_get_pointer');
  @_g_value_set_double := _LoadProc('g_value_set_double');
  @_g_value_get_double := _LoadProc('g_value_get_double');
  @_g_value_set_float := _LoadProc('g_value_set_float');
  @_g_value_get_float := _LoadProc('g_value_get_float');
  @_g_value_set_int64 := _LoadProc('g_value_set_int64');
  @_g_value_get_int64 := _LoadProc('g_value_get_int64');
  @_g_value_set_uint64 := _LoadProc('g_value_set_uint64');
  @_g_value_get_uint64 := _LoadProc('g_value_get_uint64');

  { GObject }
  @_g_object_new := _LoadProc('g_object_new');
  @_g_object_new_with_properties := _LoadProc('g_object_new_with_properties');
  @_g_object_ref := _LoadProc('g_object_ref');
  @_g_object_unref := _LoadProc('g_object_unref');
  @_g_object_ref_sink := _LoadProc('g_object_ref_sink');
  @_g_object_is_floating := _LoadProc('g_object_is_floating');
  @_g_object_force_floating := _LoadProc('g_object_force_floating');
  @_g_object_set_property := _LoadProc('g_object_set_property');
  @_g_object_set := _LoadProc('g_object_set');
  @_g_object_get_property := _LoadProc('g_object_get_property');
  @_g_object_get_data := _LoadProc('g_object_get_data');
  @_g_object_set_data := _LoadProc('g_object_set_data');
  @_g_object_set_data_full := _LoadProc('g_object_set_data_full');
  @_g_object_class_find_property := _LoadProc('g_object_class_find_property');
  @_g_object_notify := _LoadProc('g_object_notify');
  @_g_object_notify_by_pspec := _LoadProc('g_object_notify_by_pspec');
  @_g_object_weak_ref := _LoadProc('g_object_weak_ref');
  @_g_object_weak_unref := _LoadProc('g_object_weak_unref');

  { Signals }
  @_g_signal_connect_data := _LoadProc('g_signal_connect_data');
  @_g_signal_handler_disconnect := _LoadProc('g_signal_handler_disconnect');
  @_g_signal_handler_block := _LoadProc('g_signal_handler_block');
  @_g_signal_handler_unblock := _LoadProc('g_signal_handler_unblock');
  @_g_signal_lookup := _LoadProc('g_signal_lookup');
  @_g_signal_name := _LoadProc('g_signal_name');
  @_g_signal_emit_by_name := _LoadProc('g_signal_emit_by_name');
end;

function G2D_LoadGobject: Boolean;
begin
  if G2D_GobjectLoaded then
    Exit(True);

  if not G2D_GlibLoadedOK then
    raise EG2DGobjectError.Create('GLib must be loaded before GObject');

  _ResetGobjectPointers;

  G2D_GobjectHandle := G2D_LoadDLLModule(PChar('gobject-2.0-0.dll'));
  if G2D_GobjectHandle = 0 then
    raise EG2DGobjectError.Create('Failed to load GObject DLL: gobject-2.0-0.dll');

  try
    _BindGobjectFunctions;
    G2D_GobjectLoaded := True;
    Result := True;
  except
    FreeLibrary(G2D_GobjectHandle);
    G2D_GobjectHandle := 0;
    _ResetGobjectPointers;
    G2D_GobjectLoaded := False;
    raise;
  end;
end;

procedure G2D_UnloadGobject;
begin
  if G2D_GobjectHandle <> 0 then
  begin
    FreeLibrary(G2D_GobjectHandle);
    G2D_GobjectHandle := 0;
  end;

  _ResetGobjectPointers;
  G2D_GobjectLoaded := False;
end;

function G2D_GobjectLoadedOK: Boolean;
begin
  Result := G2D_GobjectLoaded and (G2D_GobjectHandle <> 0);
end;

initialization
  _ResetGobjectPointers;

finalization
  G2D_UnloadGobject;

end.

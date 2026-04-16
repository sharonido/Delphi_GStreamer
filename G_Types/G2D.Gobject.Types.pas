unit G2D.Gobject.Types;

interface

{$MINENUMSIZE 4}

uses
  G2D.Glib.Types;

type
{==============================================================================
  Opaque / forward types
==============================================================================}

  PGData = Pointer;
  PPGData = ^PGData;

  PGClosure = Pointer;
  PPGClosure = ^PGClosure;

  PGTypePlugin = Pointer;
  PPGTypePlugin = ^PGTypePlugin;

{==============================================================================
  Fundamental GType constants
==============================================================================}

const
  G_TYPE_FUNDAMENTAL_SHIFT = 2;

  G_TYPE_INVALID:   GType = 0 shl 2;
  G_TYPE_NONE:      GType = 1 shl 2;
  G_TYPE_INTERFACE: GType = 2 shl 2;
  G_TYPE_CHAR:      GType = 3 shl 2;
  G_TYPE_UCHAR:     GType = 4 shl 2;
  G_TYPE_BOOLEAN:   GType = 5 shl 2;
  G_TYPE_INT:       GType = 6 shl 2;
  G_TYPE_UINT:      GType = 7 shl 2;
  G_TYPE_LONG:      GType = 8 shl 2;
  G_TYPE_ULONG:     GType = 9 shl 2;
  G_TYPE_INT64:     GType = 10 shl 2;
  G_TYPE_UINT64:    GType = 11 shl 2;
  G_TYPE_ENUM:      GType = 12 shl 2;
  G_TYPE_FLAGS:     GType = 13 shl 2;
  G_TYPE_FLOAT:     GType = 14 shl 2;
  G_TYPE_DOUBLE:    GType = 15 shl 2;
  G_TYPE_STRING:    GType = 16 shl 2;
  G_TYPE_POINTER:   GType = 17 shl 2;
  G_TYPE_BOXED:     GType = 18 shl 2;
  G_TYPE_PARAM:     GType = 19 shl 2;
  G_TYPE_OBJECT:    GType = 20 shl 2;
  G_TYPE_VARIANT:   GType = 21 shl 2;

{==============================================================================
  GType flags / GParam flags / signal flags
==============================================================================}

type
  GTypeFundamentalFlags = guint;
  PGTypeFundamentalFlags = ^GTypeFundamentalFlags;
  PPGTypeFundamentalFlags = ^PGTypeFundamentalFlags;

  GTypeFlags = guint;
  PGTypeFlags = ^GTypeFlags;
  PPGTypeFlags = ^PGTypeFlags;

  GParamFlags = guint;
  PGParamFlags = ^GParamFlags;
  PPGParamFlags = ^PGParamFlags;

  GConnectFlags = guint;
  PGConnectFlags = ^GConnectFlags;
  PPGConnectFlags = ^PGConnectFlags;

  GSignalFlags = guint;
  PGSignalFlags = ^GSignalFlags;
  PPGSignalFlags = ^PGSignalFlags;

const
  G_TYPE_FLAG_CLASSED        : GTypeFundamentalFlags = 1 shl 0;
  G_TYPE_FLAG_INSTANTIATABLE : GTypeFundamentalFlags = 1 shl 1;
  G_TYPE_FLAG_DERIVABLE      : GTypeFundamentalFlags = 1 shl 2;
  G_TYPE_FLAG_DEEP_DERIVABLE : GTypeFundamentalFlags = 1 shl 3;

  G_TYPE_FLAG_ABSTRACT       : GTypeFlags = 1 shl 4;
  G_TYPE_FLAG_VALUE_ABSTRACT : GTypeFlags = 1 shl 5;

  G_PARAM_READABLE        : GParamFlags = 1 shl 0;
  G_PARAM_WRITABLE        : GParamFlags = 1 shl 1;
  G_PARAM_READWRITE       : GParamFlags = (1 shl 0) or (1 shl 1);
  G_PARAM_CONSTRUCT       : GParamFlags = 1 shl 2;
  G_PARAM_CONSTRUCT_ONLY  : GParamFlags = 1 shl 3;
  G_PARAM_LAX_VALIDATION  : GParamFlags = 1 shl 4;
  G_PARAM_STATIC_NAME     : GParamFlags = 1 shl 5;
  G_PARAM_PRIVATE         : GParamFlags = 1 shl 5;
  G_PARAM_STATIC_NICK     : GParamFlags = 1 shl 6;
  G_PARAM_STATIC_BLURB    : GParamFlags = 1 shl 7;
  G_PARAM_EXPLICIT_NOTIFY : GParamFlags = 1 shl 30;
  G_PARAM_DEPRECATED      : GParamFlags = guint($80000000);

  G_PARAM_STATIC_STRINGS  : GParamFlags = (1 shl 5) or (1 shl 6) or (1 shl 7);
  G_PARAM_MASK            : GParamFlags = $000000FF;
  G_PARAM_USER_SHIFT      = 8;

  G_CONNECT_AFTER         : GConnectFlags = 1 shl 0;
  G_CONNECT_SWAPPED       : GConnectFlags = 1 shl 1;

  G_SIGNAL_RUN_FIRST              : GSignalFlags = 1 shl 0;
  G_SIGNAL_RUN_LAST               : GSignalFlags = 1 shl 1;
  G_SIGNAL_RUN_CLEANUP            : GSignalFlags = 1 shl 2;
  G_SIGNAL_NO_RECURSE             : GSignalFlags = 1 shl 3;
  G_SIGNAL_DETAILED               : GSignalFlags = 1 shl 4;
  G_SIGNAL_ACTION                 : GSignalFlags = 1 shl 5;
  G_SIGNAL_NO_HOOKS               : GSignalFlags = 1 shl 6;
  G_SIGNAL_MUST_COLLECT           : GSignalFlags = 1 shl 7;
  G_SIGNAL_DEPRECATED             : GSignalFlags = 1 shl 8;
  G_SIGNAL_ACCUMULATOR_FIRST_RUN  : GSignalFlags = 1 shl 17;

{==============================================================================
  Core type system structures
==============================================================================}

type
  PGTypeClass = ^GTypeClass;
  PPGTypeClass = ^PGTypeClass;

  GTypeClass = record
    g_type: GType;
  end;

  PGTypeInstance = ^GTypeInstance;
  PPGTypeInstance = ^PGTypeInstance;

  GTypeInstance = record
    g_class: PGTypeClass;
  end;

  PGTypeInterface = ^GTypeInterface;
  PPGTypeInterface = ^PGTypeInterface;

  GTypeInterface = record
    g_type: GType;
    g_instance_type: GType;
  end;

  PGTypeQuery = ^GTypeQuery;
  PPGTypeQuery = ^PGTypeQuery;

  GTypeQuery = record
    D_type: GType;
    type_name: Pgchar;
    class_size: guint;
    instance_size: guint;
  end;

{==============================================================================
  Callback types used by the type system
==============================================================================}

  GBaseInitFunc = procedure(g_class: gpointer); cdecl;
  GBaseFinalizeFunc = procedure(g_class: gpointer); cdecl;

  GClassInitFunc = procedure(g_class: gpointer; class_data: gpointer); cdecl;
  GClassFinalizeFunc = procedure(g_class: gpointer; class_data: gpointer); cdecl;

  GInstanceInitFunc = procedure(instance: PGTypeInstance; g_class: gpointer); cdecl;

  GInterfaceInitFunc = procedure(g_iface: gpointer; iface_data: gpointer); cdecl;
  GInterfaceFinalizeFunc = procedure(g_iface: gpointer; iface_data: gpointer); cdecl;

  GTypeClassCacheFunc = function(cache_data: gpointer; g_class: PGTypeClass): gboolean; cdecl;
  GTypeInterfaceCheckFunc = procedure(check_data: gpointer; g_iface: gpointer); cdecl;

{==============================================================================
  GValue
==============================================================================}

type
  PGValue = ^GValue;
  PPGValue = ^PGValue;

  PGTypeCValue = ^GTypeCValue;
  PPGTypeCValue = ^PGTypeCValue;

  GTypeCValue = record
    case Integer of
      0: (v_int: gint);
      1: (v_long: glong);
      2: (v_int64: gint64);
      3: (v_double: gdouble);
      4: (v_pointer: gpointer);
  end;

  GValueData = record
    case Integer of
      0: (v_int: gint);
      1: (v_uint: guint);
      2: (v_long: glong);
      3: (v_ulong: gulong);
      4: (v_int64: gint64);
      5: (v_uint64: guint64);
      6: (v_float: gfloat);
      7: (v_double: gdouble);
      8: (v_pointer: gpointer);
  end;

  GValue = record
    g_type: GType;
    data: array[0..1] of GValueData;
  end;

  PGTypeValueTable = ^GTypeValueTable;
  PPGTypeValueTable = ^PGTypeValueTable;

  GTypeValueTable = record
    value_init: Pointer;
    value_free: Pointer;
    value_copy: Pointer;
    value_peek_pointer: Pointer;
    collect_format: Pgchar;
    collect_value: Pointer;
    lcopy_format: Pgchar;
    lcopy_value: Pointer;
  end;

{==============================================================================
  GType registration metadata
==============================================================================}

type
  PGTypeFundamentalInfo = ^GTypeFundamentalInfo;
  PPGTypeFundamentalInfo = ^PGTypeFundamentalInfo;

  GTypeFundamentalInfo = record
    type_flags: GTypeFundamentalFlags;
  end;

  PGTypeInfo = ^GTypeInfo;
  PPGTypeInfo = ^PGTypeInfo;

  GTypeInfo = record
    class_size: guint16;
    base_init: GBaseInitFunc;
    base_finalize: GBaseFinalizeFunc;
    class_init: GClassInitFunc;
    class_finalize: GClassFinalizeFunc;
    class_data: gpointer;
    instance_size: guint16;
    n_preallocs: guint16;
    instance_init: GInstanceInitFunc;
    value_table: PGTypeValueTable;
  end;

  PGInterfaceInfo = ^GInterfaceInfo;
  PPGInterfaceInfo = ^PGInterfaceInfo;

  GInterfaceInfo = record
    interface_init: GInterfaceInitFunc;
    interface_finalize: GInterfaceFinalizeFunc;
    interface_data: gpointer;
  end;

{==============================================================================
  GParamSpec
==============================================================================}

type
  PGParamSpec = ^GParamSpec;
  PPGParamSpec = ^PGParamSpec;

  GParamSpec = record
    g_type_instance: GTypeInstance;
    name: Pgchar;
    flags: GParamFlags;
    value_type: GType;
    owner_type: GType;
    _nick: Pgchar;
    _blurb: Pgchar;
    qdata: PGData;
    ref_count: guint;
    param_id: guint;
  end;

  PGParamSpecClass = ^GParamSpecClass;
  PPGParamSpecClass = ^PGParamSpecClass;

  GParamSpecClass = record
    g_type_class: GTypeClass;
    value_type: GType;

    finalize: procedure(pspec: PGParamSpec); cdecl;

    value_set_default: procedure(
      pspec: PGParamSpec;
      value: PGValue
    ); cdecl;

    value_validate: function(
      pspec: PGParamSpec;
      value: PGValue
    ): gboolean; cdecl;

    values_cmp: function(
      pspec: PGParamSpec;
      const value1, value2: PGValue
    ): gint; cdecl;

    dummy: array[0..3] of gpointer;
  end;

  PGParameter = ^GParameter;
  PPGParameter = ^PGParameter;

  GParameter = record
    name: Pgchar;
    value: GValue;
  end;

{==============================================================================
  GObject
==============================================================================}

type
  PGObject = ^GObject;
  PPGObject = ^PGObject;

  PGObjectClass = ^GObjectClass;
  PPGObjectClass = ^PGObjectClass;

  GWeakNotify = procedure(
    data: gpointer;
    where_the_object_was: PGObject
  ); cdecl;

  GToggleNotify = procedure(
    data: gpointer;
    D_object: PGObject;
    is_last_ref: gboolean
  ); cdecl;

  GClosureNotify = procedure(
    data: gpointer;
    closure: PGClosure
  ); cdecl;

  PGObjectConstructParam = ^GObjectConstructParam;
  PPGObjectConstructParam = ^PGObjectConstructParam;

  GObjectConstructParam = record
    pspec: PGParamSpec;
    value: PGValue;
  end;

  GObject = record
    g_type_instance: GTypeInstance;
    ref_count: guint;
    qdata: PGData;
  end;

  GObjectClass = record
    g_type_class: GTypeClass;

    construct_properties: PGSList;

    D_constructor: function(
      D_type: GType;
      n_construct_properties: guint;
      construct_properties: PGObjectConstructParam
    ): PGObject; cdecl;

    set_property: procedure(
      D_object: PGObject;
      property_id: guint;
      const value: PGValue;
      pspec: PGParamSpec
    ); cdecl;

    get_property: procedure(
      D_object: PGObject;
      property_id: guint;
      value: PGValue;
      pspec: PGParamSpec
    ); cdecl;

    dispose: procedure(D_object: PGObject); cdecl;
    D_finalize: procedure(D_object: PGObject); cdecl;

    dispatch_properties_changed: procedure(
      D_object: PGObject;
      n_pspecs: guint;
      pspecs: PPGParamSpec
    ); cdecl;

    notify: procedure(
      D_object: PGObject;
      pspec: PGParamSpec
    ); cdecl;

    constructed: procedure(
      D_object: PGObject
    ); cdecl;

    flags: gsize;
    n_construct_properties: gsize;
    pspecs: gpointer;
    n_pspecs: gsize;

    pdummy: array[0..2] of gpointer;
  end;

{==============================================================================
  GInitiallyUnowned
==============================================================================}

type
  PGInitiallyUnowned = ^GInitiallyUnowned;
  PPGInitiallyUnowned = ^PGInitiallyUnowned;

  PGInitiallyUnownedClass = ^GInitiallyUnownedClass;
  PPGInitiallyUnownedClass = ^PGInitiallyUnownedClass;

  GInitiallyUnowned = record
    parent_instance: GObject;
  end;

  GInitiallyUnownedClass = record
    parent_class: GObjectClass;
  end;

implementation

end.

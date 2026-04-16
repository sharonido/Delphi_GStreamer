unit G2D.Glib.Types;

interface

{$MINENUMSIZE 4}

type
{==============================================================================
  Basic scalar types
==============================================================================}

  gboolean  = LongInt;
  Pgboolean = ^gboolean;
  PPgboolean = ^Pgboolean;

  gchar   = AnsiChar;
  Pgchar  = ^gchar;
  PPgchar = ^Pgchar;
  PPPgchar = ^PPgchar;

  guchar   = Byte;
  Pguchar  = ^guchar;
  PPguchar = ^Pguchar;

  gint8   = ShortInt;
  Pgint8  = ^gint8;
  PPgint8 = ^Pgint8;

  guint8   = Byte;
  Pguint8  = ^guint8;
  PPguint8 = ^Pguint8;

  gint16   = SmallInt;
  Pgint16  = ^gint16;
  PPgint16 = ^Pgint16;

  guint16   = Word;
  Pguint16  = ^guint16;
  PPguint16 = ^Pguint16;

  gint32   = Integer;
  Pgint32  = ^gint32;
  PPgint32 = ^Pgint32;

  guint32   = Cardinal;
  Pguint32  = ^guint32;
  PPguint32 = ^Pguint32;

  gint64   = Int64;
  Pgint64  = ^gint64;
  PPgint64 = ^Pgint64;

  guint64   = UInt64;
  Pguint64  = ^guint64;
  PPguint64 = ^Pguint64;

  gint   = Integer;
  Pgint  = ^gint;
  PPgint = ^Pgint;

  guint   = Cardinal;
  Pguint  = ^guint;
  PPguint = ^Pguint;

  gshort   = SmallInt;
  Pgshort  = ^gshort;
  PPgshort = ^Pgshort;

  gushort   = Word;
  Pgushort  = ^gushort;
  PPgushort = ^Pgushort;

  glong   = LongInt;
  Pglong  = ^glong;
  PPglong = ^Pglong;

  gulong   = LongWord;
  Pgulong  = ^gulong;
  PPgulong = ^Pgulong;

  gfloat   = Single;
  Pgfloat  = ^gfloat;
  PPgfloat = ^Pgfloat;

  gdouble   = Double;
  Pgdouble  = ^gdouble;
  PPgdouble = ^Pgdouble;

  gsize   = NativeUInt;
  Pgsize  = ^gsize;
  PPgsize = ^Pgsize;

  gssize   = NativeInt;
  Pgssize  = ^gssize;
  PPgssize = ^Pgssize;

  gpointer   = Pointer;
  Pgpointer  = ^gpointer;
  PPgpointer = ^Pgpointer;

  guintptr = NativeUInt;
  Pguintptr = ^guintptr;
  PPguintptr = ^Pguintptr;

  gconstpointer = Pointer;

  gunichar   = guint32;
  Pgunichar  = ^gunichar;
  PPgunichar = ^Pgunichar;

  gunichar2   = guint16;
  Pgunichar2  = ^gunichar2;
  PPgunichar2 = ^Pgunichar2;

{==============================================================================
  Fundamental identifiers
==============================================================================}

type
  GType   = gsize;
  PGType  = ^GType;
  PPGType = ^PGType;

  GQuark   = guint32;
  PGQuark  = ^GQuark;
  PPGQuark = ^PGQuark;

{==============================================================================
  Boolean constants
==============================================================================}

const
  GFALSE: gboolean = 0;
  GTRUE:  gboolean = 1;

{==============================================================================
  Callback types
==============================================================================}

type
  GCompareFunc = function(a, b: gconstpointer): gint; cdecl;
  GCompareDataFunc = function(a, b, user_data: gconstpointer): gint; cdecl;
  GEqualFunc = function(a, b: gconstpointer): gboolean; cdecl;
  GHashFunc = function(key: gconstpointer): guint; cdecl;

  GFunc = procedure(data, user_data: gpointer); cdecl;
  GHFunc = procedure(key, value, user_data: gpointer); cdecl;

  GFreeFunc = procedure(data: gpointer); cdecl;
  GDestroyNotify = procedure(data: gpointer); cdecl;

  GCopyFunc = function(src, user_data: gconstpointer): gpointer; cdecl;

  GCallback = Pointer;

{==============================================================================
  Doubly linked list
==============================================================================}

type
  PGList = ^GList;
  PPGList = ^PGList;

  GList = record
    data: gpointer;
    next: PGList;
    prev: PGList;
  end;

{==============================================================================
  Singly linked list
==============================================================================}

type
  PGSList = ^GSList;
  PPGSList = ^PGSList;

  GSList = record
    data: gpointer;
    next: PGSList;
  end;

{==============================================================================
  Queue
==============================================================================}

type
  PGQueue = ^GQueue;
  PPGQueue = ^PGQueue;

  GQueue = record
    head: PGList;
    tail: PGList;
    length: guint;
  end;

{==============================================================================
  Error
==============================================================================}

type
  PGError = ^GError;
  PPGError = ^PGError;

  GError = record
    domain: GQuark;
    code: gint;
    message: Pgchar;
  end;

{==============================================================================
  Common container/layout structs used by upper layers
==============================================================================}

type
  PGString = ^GString;
  PPGString = ^PGString;

  GString = record
    str: Pgchar;
    len: gsize;
    allocated_len: gsize;
  end;

  PGArray = ^GArray;
  PPGArray = ^PGArray;

  GArray = record
    data: Pgchar;
    len: guint;
  end;

  PGByteArray = ^GByteArray;
  PPGByteArray = ^PGByteArray;

  GByteArray = record
    data: Pguchar;
    len: guint;
  end;

  PGPtrArray = ^GPtrArray;
  PPGPtrArray = ^PGPtrArray;

  GPtrArray = record
    pdata: Pgpointer;
    len: guint;
  end;

{==============================================================================
  Opaque GLib types commonly needed by GObject / GStreamer
==============================================================================}

type
  PGBytes = Pointer;
  PGHashTable = Pointer;
  PGTree = Pointer;
  PGMainLoop = Pointer;
  PGMainContext = Pointer;
  PGSource = Pointer;

{==============================================================================
  GLib synchronization primitives
==============================================================================}

type
  PGMutex = ^GMutex;
  PPGMutex = ^PGMutex;

  GMutex = record
    p: array[0..1] of gpointer;
  end;

  PGRecMutex = ^GRecMutex;
  PPGRecMutex = ^PGRecMutex;

  GRecMutex = record
    p: array[0..1] of gpointer;
  end;

  PGCond = ^GCond;
  PPGCond = ^PGCond;

  GCond = record
    p: array[0..1] of gpointer;
  end;

{==============================================================================
  GLib Hook system
==============================================================================}

type
  GHookFunc = procedure(data: gpointer); cdecl;
  GHookCheckFunc = function(data: gpointer): gboolean; cdecl;

  PGHook = ^GHook;
  PPGHook = ^PGHook;

  GHook = record
    data: gpointer;
    next: PGHook;
    prev: PGHook;
    ref_count: guint;
    hook_id: gulong;
    flags: guint;
    func: gpointer;
    destroy: GDestroyNotify;
  end;

  PGHookList = ^GHookList;
  PPGHookList = ^PGHookList;

  GHookList = record
    seq_id: gulong;
    hook_size: guint;
    is_setup: guint;
    hooks: PGHook;
    finalize_hook: gpointer;
  end;

implementation

end.

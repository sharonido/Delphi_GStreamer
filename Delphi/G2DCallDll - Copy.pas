{* copyright (c) 2020 I. Sharon Ltd.
 *
 * This file is part of GStreamer 2 Delphi bridge (G2D).
 *
 * G2D is free software; You can redistribute it and modify it. It is licensed
 * under the GNU Lesser General Public License as published by the Free Software
 * Foundation. Either version 2.1 of the License, or any later version.

for info on G2D download:
https://github.com/sharonido/Delphi_GStreamer/blob/master/G2D.docx
for full G2D source and bin dpwnload from:
https://github.com/sharonido/Delphi_GStreamer
  or clone by:
git clone https://github.com/sharonido/Delphi_GStreamer.git
}

unit G2DCallDll;

interface
uses
{$IFDEF MSWINDOWS}
Winapi.Windows,
{$ENDIF }
System.SysUtils;
// Types  & Const -------------------------------------------------------------
Type

PCharArr=Array of ansistring;
PArrPChar=^PCharArr;        //for C:->  char *argv[];

{$IfDef VER360}
//define an integer(4 byte) space for Enumerators.
//In c it is a Uint, so $ffffffff is here -1 etc'
{$MINENUMSIZE 4}
{$Else}
{$Z4}
{$Endif}
gsize =UInt64;

GstFormat = (
  GST_FORMAT_UNDEFINED  =  0,
  GST_FORMAT_DEFAULT    =  1,
  GST_FORMAT_BYTES      =  2,
  GST_FORMAT_TIME       =  3,
  GST_FORMAT_BUFFERS    =  4,
  GST_FORMAT_PERCENT    =  5);

GstStateChangeReturn=(
  GST_STATE_CHANGE_FAILURE             = 0,
  GST_STATE_CHANGE_SUCCESS             = 1,
  GST_STATE_CHANGE_ASYNC               = 2,
  GST_STATE_CHANGE_NO_PREROLL          = 3);

GstState=(
  GST_STATE_VOID_PENDING        = 0,
  GST_STATE_NULL                = 1,
  GST_STATE_READY               = 2,
  GST_STATE_PAUSED              = 3,
  GST_STATE_PLAYING             = 4);

GstPadLinkReturn=(
  GST_PAD_LINK_OK               =  0,
  GST_PAD_LINK_WRONG_HIERARCHY  = -1,
  GST_PAD_LINK_WAS_LINKED       = -2,
  GST_PAD_LINK_WRONG_DIRECTION  = -3,
  GST_PAD_LINK_NOFORMAT         = -4,
  GST_PAD_LINK_NOSCHED          = -5,
  GST_PAD_LINK_REFUSED          = -6 );
   //**************************
GstSeekFlags =(
  GST_SEEK_FLAG_NONE            = 0,
  GST_SEEK_FLAG_FLUSH           = (1 shl 0),
  GST_SEEK_FLAG_ACCURATE        = (1 shl 1),
  GST_SEEK_FLAG_KEY_UNIT        = (1 shl 2),
  GST_SEEK_FLAG_SEGMENT         = (1 shl 3),
  GST_SEEK_FLAG_TRICKMODE       = (1 shl 4),
  //* FIXME 2.0: Remove _SKIP flag,     * which was kept for backward compat when _TRICKMODE was added */
  GST_SEEK_FLAG_SKIP            = (1 shl 4),
  GST_SEEK_FLAG_SNAP_BEFORE     = (1 shl 5),
  GST_SEEK_FLAG_SNAP_AFTER      = (1 shl 6),
  GST_SEEK_FLAG_SNAP_NEAREST    = integer(GST_SEEK_FLAG_SNAP_BEFORE) or integer(GST_SEEK_FLAG_SNAP_AFTER),
  //* Careful to restart next flag with 1<<7 here */
  GST_SEEK_FLAG_TRICKMODE_KEY_UNITS = (1 shl 7),
  GST_SEEK_FLAG_TRICKMODE_NO_AUDIO  = (1 shl 8),
  GST_SEEK_FLAG_TRICKMODE_FORWARD_PREDICTED = (1 shl 9),
  GST_SEEK_FLAG_INSTANT_RATE_CHANGE = (1 shl 10));

  //*********************
GstMessageType=(
  GST_MESSAGE_UNKNOWN           = 0,
  GST_MESSAGE_EOS               = (1 shl 0),
  GST_MESSAGE_ERROR             = 2,//(1 shl 1),
  GST_MESSAGE_WARNING           = 4,//(1 shl 2),
  GST_MESSAGE_INFO              = 8,//(1 shl 3),
  GST_MESSAGE_TAG               = $10,//(1 shl 4),
  GST_MESSAGE_BUFFERING         = $20,//(1 shl 5),
  GST_MESSAGE_STATE_CHANGED     = $40,//(1 shl 6),
  GST_MESSAGE_STATE_DIRTY       = $80,//(1 shl 7),
  GST_MESSAGE_STEP_DONE         = $100,//(1 shl 8),
  GST_MESSAGE_CLOCK_PROVIDE     = $200,   //(1 shl 9),
  GST_MESSAGE_CLOCK_LOST        = $400,//(1 shl 10),
  GST_MESSAGE_NEW_CLOCK         = $800,//(1 shl 11),
  GST_MESSAGE_STRUCTURE_CHANGE  = $1000,//(1 shl 12),
  GST_MESSAGE_STREAM_STATUS     = $2000,//(1 shl 13),
  GST_MESSAGE_APPLICATION       = $4000,//(1 shl 14),
  GST_MESSAGE_ELEMENT           = $8000,//(1 shl 15),
  GST_MESSAGE_SEGMENT_START     = $10000,//(1 shl 16),
  GST_MESSAGE_SEGMENT_DONE      = $20000,//(1 shl 17),
  GST_MESSAGE_DURATION_CHANGED  = $40000,//(1 shl 18),
  GST_MESSAGE_LATENCY           = $80000,//(1 shl 19),
  GST_MESSAGE_ASYNC_START       = $100000,//(1 shl 20),
  GST_MESSAGE_ASYNC_DONE        = $200000,//(1 shl 21),
  GST_MESSAGE_REQUEST_STATE     = $400000,//(1 shl 22),
  GST_MESSAGE_STEP_START        = $800000,//(1 shl 23),
  GST_MESSAGE_QOS               = $1000000,//(1 shl 24),
  GST_MESSAGE_PROGRESS          = $2000000,//(1 shl 25),
  GST_MESSAGE_TOC               = $4000000,//(1 shl 26),
  GST_MESSAGE_RESET_TIME        = $8000000,//(1 shl 27),
  GST_MESSAGE_STREAM_START      = $10000000,//(1 shl 28),
  GST_MESSAGE_NEED_CONTEXT      = $20000000,//(1 shl 29),
  GST_MESSAGE_HAVE_CONTEXT      = $40000000,//(1 shl 30),
  GST_MESSAGE_EXTENDED          = -$80000000,//(1 shl 31),  bypass the error
  GST_MESSAGE_DEVICE_ADDED      = GST_MESSAGE_EXTENDED + 1,
  GST_MESSAGE_DEVICE_REMOVED    = GST_MESSAGE_EXTENDED + 2,
  GST_MESSAGE_PROPERTY_NOTIFY   = GST_MESSAGE_EXTENDED + 3,
  GST_MESSAGE_STREAM_COLLECTION = GST_MESSAGE_EXTENDED + 4,
  GST_MESSAGE_STREAMS_SELECTED  = GST_MESSAGE_EXTENDED + 5,
  GST_MESSAGE_REDIRECT          = GST_MESSAGE_EXTENDED + 6,
  GST_MESSAGE_DEVICE_CHANGED    = GST_MESSAGE_EXTENDED + 7,
  GST_MESSAGE_ANY               = -1); //$ffffffff);       bypass the error

UInt=Cardinal;  //UInt 32bit unsigned integer -In pascal winapi also defined

PGList=^GList;
GList=record  //an element in a chain
  data: pointer;
  next,
  prev: PGList;
  end;

GstPadDirection =(
  GST_PAD_UNKNOWN,
  GST_PAD_SRC,
  GST_PAD_SINK );

GstPadPresence  =(
  GST_PAD_ALWAYS,
  GST_PAD_SOMETIMES,
  GST_PAD_REQUEST);

_GstMiniObject= record
  //not packed record, cause will be difrent in 64/32 os and on android/ios
  GMiniObjectType:   uint64;

   refcount:integer;
   lockstate:integer;
   flags    :uint;

  copy:function():_GstMiniObject;
  dispose:function():boolean;
  free:procedure();

  priv_uint:integer;     //guint
  priv_pointer:pointer;  //gpointer
  end;

PGstCaps = ^GstCaps;
GstCaps = _GstMiniObject;

GstStaticCaps = record

  caps :^GstCaps;
  AString : Pansichar;

  //*< private >*/
  _gst_reserved :pointer;
  end;

_GstStaticPadTemplate =record
  name_template :PAnsiChar;
  direction     :GstPadDirection;
  presence      :GstPadPresence;
  static_caps   :GstStaticCaps;
  end;
GstStaticPadTemplate = _GstStaticPadTemplate;
PGstStaticPadTemplate =^GstStaticPadTemplate;
//----------  _Gst Object  --------------------------------------------------
_GObject= record
  g_type_instance :pointer; //GTypeInstance
  //*< private >*/
  ref_count :integer;  // guint  (atomic)
  qdata    :pointer //GData
  end;
GObject = _GObject;
PObject = ^GObject;

_GstObject= record
        //not packed record, cause will be difrent in 64/32 os and on android/ios

  _object : _GObject ;

  // < public >*/ /* with LOCK */
  lock  :pointer;           // object LOCK */
  name  :pansichar;        // object name */
  parent:^_GstObject;       //* this object's parent, weak ref */        // object name */
  flags : int32;            //guint32
  {
  //*< private >*/
  GList         *control_bindings;  /* List of GstControlBinding */
  guint64        control_rate;
  guint64        last_sync;
  gpointer _gst_reserved;  }
  end;


_GstElementFactory = record
  _object : _GObject ;
  {more fields}
  end;
PGstElementFactory = ^_GstElementFactory;
_GstCaps = record

  mini_object:_GstMiniObject;
  end;

GQuark = int32;

_GstStructure = record
  GstType :UInt64;
  name    :GQuark;  //integer
{
  GType type;

  /*< private >*/
  GQuark name;
  }
  end;
GstStructure = _GstStructure;

PGstStructure = ^GstStructure;

PGstPad = ^_GstPad;
_GstPad =record
_object   :_GstObject;
//this is only first elements of the pad record
end;
(*the full _GstPad
{
  GstObject                      object;

  /*< public >*/
  gpointer                       element_private;

  GstPadTemplate                *padtemplate;

  GstPadDirection                direction;

  /*< private >*/
  /* streaming rec_lock */
  GRecMutex		         stream_rec_lock;
  GstTask			*task;

  /* block cond, mutex is from the object */
  GCond				 block_cond;
  GHookList                      probes;

  GstPadMode		         mode;
  GstPadActivateFunction	 activatefunc;
  gpointer                       activatedata;
  GDestroyNotify                 activatenotify;
  GstPadActivateModeFunction	 activatemodefunc;
  gpointer                       activatemodedata;
  GDestroyNotify                 activatemodenotify;

  /* pad link */
  GstPad			*peer;
  GstPadLinkFunction		 linkfunc;
  gpointer                       linkdata;
  GDestroyNotify                 linknotify;
  GstPadUnlinkFunction		 unlinkfunc;
  gpointer                       unlinkdata;
  GDestroyNotify                 unlinknotify;

  /* data transport functions */
  GstPadChainFunction		 chainfunc;
  gpointer                       chaindata;
  GDestroyNotify                 chainnotify;
  GstPadChainListFunction        chainlistfunc;
  gpointer                       chainlistdata;
  GDestroyNotify                 chainlistnotify;
  GstPadGetRangeFunction	 getrangefunc;
  gpointer                       getrangedata;
  GDestroyNotify                 getrangenotify;
  GstPadEventFunction		 eventfunc;
  gpointer                       eventdata;
  GDestroyNotify                 eventnotify;

  /* pad offset */
  gint64                         offset;

  /* generic query method */
  GstPadQueryFunction		 queryfunc;
  gpointer                       querydata;
  GDestroyNotify                 querynotify;

  /* internal links */
  GstPadIterIntLinkFunction      iterintlinkfunc;
  gpointer                       iterintlinkdata;
  GDestroyNotify                 iterintlinknotify;

  /* counts number of probes attached. */
  gint				 num_probes;
  gint				 num_blocked;

  GstPadPrivate                 *priv;

  union {
    gpointer _gst_reserved[GST_PADDING];
    struct {
      GstFlowReturn last_flowret;
      GstPadEventFullFunction eventfullfunc;
    } abi;
  } ABI;
};
*)



//-----------------------------------------------------------
Gst_Mes=record
  RMiniObj:_GstMiniObject;
  MType:GstMessageType;
  timestamp: Uint64;
  src: pointer; //to gobject
  seqnum: Uint32;
  //GMutex          lock;                 /* lock and cond for async delivery */
  //GCond           cond;
end;

PGst_Mes=^Gst_Mes;
PGstState=^GstState;

GstStructureForeachFunc=function(const field_id:GQuark; const value:pointer;user_data:Pointer):boolean; cdecl ;

Tgst_funcPChars = function (const PlugNum:integer;const PlugNames:PArrPChar):integer; cdecl ;
Tgst_voidPChars = procedure (const PlugNum:integer;const PlugNames:PArrPChar); cdecl ;
Tgst_pipeline_new = function (const name:ansistring):pointer; cdecl ;
Tgst_element_get_bus = function (const Pipe:Pointer):pointer; cdecl ;
Tgst_object_unref = procedure (ref:pointer); cdecl ;
Tgst_mini_object_unref = procedure(mini_object:pointer) cdecl;
Tgst_element_factory_make = function (const factoryname,name:ansistring):pointer; cdecl ;
Tgst_bin_add = function (const Pipe,plug:pointer):boolean; cdecl;
Tgst_element_link =function (const plugA,plugB:pointer):boolean; cdecl; //like Tgst_bin_add but diffrent in dll
Tgst_element_set_state =function (const pipe:pointer;const state:GstState):GstStateChangeReturn; cdecl;
Tgst_bus_timed_pop_filtered = function (const Bus:pointer;const TimeOut:Int64;const MType:UInt):pointer; cdecl;
Tgst_message_unref = procedure (ref:pointer); cdecl ;
Tgst_element_get_request_pad =function (Const pad:pointer; const name:AnsiString):pointer; cdecl ;
Tgst_element_get_static_pad =function (Const pad:pointer; const name:AnsiString):pointer; cdecl ;
Tgst_pad_link =function (Const PadSrc,PadSink:pointer):GstPadLinkReturn;  cdecl ;
Tgst_element_release_request_pad =procedure( const Plug,Pad:pointer) cdecl ;
Tgst_message_parse_state_changed =
  procedure (const message :pointer; oldstate, newstate, pending :pointer); cdecl ;
Tgst_pad_is_linked =function(const Pad:pointer):boolean; cdecl;
Tgst_pad_get_current_caps =function(const Pad:pointer):pointer; cdecl;
Tgst_caps_get_structure =function(const caps :pointer; const index :integer):PGstStructure; cdecl;
Tgst_structure_get_name =function(const structure:pointer):PAnsiChar; cdecl;

//These are from GObject that is underlying framework of GStreamer  (called g_object...)
Tg_object_set_int =procedure (const plug:pointer; const param:ansistring; const val:integer); cdecl;
Tg_object_set_pchar =procedure (const plug:pointer; const param,val:ansistring); cdecl;
Tg_object_set_double =procedure (const plug:pointer; const param:ansistring; const val:double); cdecl;
Tgst_object_get_name =function (Const pad:pointer):Pansichar;  cdecl ;

Tg_signal_connect =procedure (const instance: pointer; const detailed_signal:ansistring;
  const c_handler , data: pointer); cdecl;

Tgst_element_query_position = function(const element:pointer; const format:GstFormat;
  const cur:PUInt64):boolean; cdecl;
Tgst_element_query_duration = function(const element:pointer; const format:GstFormat;
  const duration:PUInt64):boolean; cdecl;
Tgst_element_seek_simple =function (const element:pointer; const format:GstFormat;
  const seek_flags: GstSeekFlags; const seek_pos:UInt64):boolean; cdecl;

Tgst_element_factory_find =function(const name:ansistring):PGstElementFactory; cdecl;
Tgst_element_factory_get_metadata =function(const factory:PGstElementFactory; name:ansistring):pansichar; cdecl;
Tgst_element_factory_get_static_pad_templates =function(const factory:PGstElementFactory):PGList; cdecl;
Tgst_element_factory_get_num_pad_templates =function(const factory:PGstElementFactory):integer; cdecl;
Tgst_pad_query_caps = function(const pad:PGstPad; filter:PGstCaps):PGstCaps; cdecl;
Tgst_caps_get_size =function(const caps:PGstCaps):UInt;cdecl;
Tgst_caps_is_any = function(const caps: PGstCaps):Boolean;cdecl;
Tgst_caps_is_empty = function(const caps: PGstCaps):Boolean;cdecl;
Tgst_structure_foreach = function (const  structure:PGstStructure; func: GstStructureForeachFunc ; user_data:pointer):boolean;cdecl;
Tgst_value_serialize = function(const value:pointer):PAnsiChar;cdecl;
Tg_quark_to_string =function(quark:GQuark):PAnsiChar;cdecl;
Tgst_static_caps_get =function(static_caps: pointer):PGstCaps;cdecl;

Var

//The GST functions in G2D.dll
DSimpleRun                          :Tgst_funcPChars;
DgstInit                            :Tgst_voidPChars;
Dgst_pipeline_new                   :Tgst_pipeline_new;
Dgst_object_unref                   :Tgst_object_unref;
Dgst_mini_object_unref              :Tgst_mini_object_unref;
Dgst_element_get_bus                :Tgst_element_get_bus;
Dgst_element_factory_make           :Tgst_element_factory_make;
Dgst_bin_add                        :Tgst_bin_add;
Dgst_element_link                   :Tgst_element_link;
Dgst_element_set_state              :Tgst_element_set_state;
Dgst_bus_timed_pop_filtered         :Tgst_bus_timed_pop_filtered;
Dgst_message_unref                  :Tgst_message_unref;
Dgst_element_get_request_pad        :Tgst_element_get_request_pad;
Dgst_element_get_static_pad         :Tgst_element_get_static_pad;
Dgst_pad_link                       :Tgst_pad_link;
Dgst_element_release_request_pad    :Tgst_element_release_request_pad;
Dgst_message_parse_state_changed    :Tgst_message_parse_state_changed;
Dgst_pad_is_linked                  :Tgst_pad_is_linked;
Dgst_pad_get_current_caps           :Tgst_pad_get_current_caps;
Dgst_caps_get_structure             :Tgst_caps_get_structure;
Dgst_structure_get_name             :Tgst_structure_get_name;
Dgst_element_factory_find           :Tgst_element_factory_find;
Dgst_element_factory_get_metadata   :Tgst_element_factory_get_metadata;
Dgst_element_factory_get_static_pad_templates
                                    :Tgst_element_factory_get_static_pad_templates;
Dgst_element_factory_get_num_pad_templates
                                    :Tgst_element_factory_get_num_pad_templates;

//These are from GObject that is underlying framework of GStreamer  (called Dg_object...)
Dg_object_set_int             :Tg_object_set_int;
Dg_object_set_pchar           :Tg_object_set_pchar;
//never used Dg_object_set_double          :Tg_object_set_double;
Dgst_object_get_name          :Tgst_object_get_name;
Dg_signal_connect             :Tg_signal_connect;

Dgst_element_query_position   :Tgst_element_query_position;
Dgst_element_query_duration   :Tgst_element_query_duration;
Dgst_element_seek_simple      :Tgst_element_seek_simple;
Dgst_pad_query_caps           :Tgst_pad_query_caps;
Dgst_caps_get_size            :Tgst_caps_get_size;
Dgst_caps_is_any              :Tgst_caps_is_any;
Dgst_caps_is_empty            :Tgst_caps_is_empty;
Dgst_structure_foreach        :Tgst_structure_foreach;
Dgst_value_serialize          :Tgst_value_serialize;
Dg_quark_to_string            :Tg_quark_to_string;
Dgst_static_caps_get          :Tgst_static_caps_get;

DiTmp1,DiTmp2:Ppointer; //for debuging only

//
gst_root_envBin:string;
G2ddllpath:string;          //the Directory where the exe was loaded & run

const
GST_MSECOND=int64(1000000); //the GST_Clock runs in nano sec so msec is a milion nano
GST_SECOND=1000*GST_MSECOND; //the GST_Clock runs in nano sec so msec is a milion nano
GST_CLOCK_TIME_NONE=-1;
DoForEver=GST_CLOCK_TIME_NONE;

function G2dDllLoaded:Boolean;
function G2dDllLoad:boolean;

function DateToIso(DT:TDateTime):string;

function GstStateName(State:GstState):string;
function GstPadLinkReturnName(Ret:GstPadLinkReturn):string;

var
WriteOut :procedure(st:string);

WriteOutln :procedure(st:string);
implementation


procedure stdWriteOut(st:string);
begin
  write(st);
end;

procedure stdWriteOutln(st:string);
begin
  stdWriteOut(st+sLineBreak)
end;

//===========================================================================================
Var
G2dDllHnd:HMODULE=0;

function DateToIso(DT:TDateTime):string;
begin
DateTimeToString(Result,'dd-MM-yyyy"T"hh:nn:ss',DT);
end;

//------------------------------------------------------------------------------
function G2dDllLoaded:Boolean;
begin
Result:=G2dDllHnd<>0;
end;
//-----------------------------------------------------------------------------
function G2dDllLoad:boolean;
var
err:integer;
dllPath:string;
//const DllStr='C:\gstreamer\gst-docs-discontinued-for-monorepo\examples\tutorials\vs2010\x64\Debug\G2Ddll.dll';
    //for fast debug a default for the DLL
    //'C:\gstreamer\gst-docs-master\examples\tutorials\vs2010\x64\Debug\';
  function setProcFromDll(var ref:pointer;const name:ansistring):boolean;
  begin
  ref := GetProcAddress(G2dDllHnd, pansichar(name));
  Result:=Ref=nil;
  if Result then  WriteOutln('Error in '+pansichar(name)+' procedure not found in DLL');
  end;
begin
err:=0;//just for warning void
if not G2dDllLoaded then
  begin
  Result:=false;
    try
    //look for G2D.dll
    if FileExists(G2ddllpath)   //if dll file in default dir
      then dllPath:=G2ddllpath
      else if FileExists('G2D.dll') then dllPath:='G2D.dll'  //in current dir
      else if FileExists('..\G2D.dll') then dllPath:='..\G2D.dll';  //in current dir

    G2dDllHnd := LoadLibrary(PWidechar(dllPath));
    err:=GetLastError;
    finally
    if (err<>0) or (G2dDllHnd=0) then
      begin
      G2dDllHnd:=0;
      WriteOutln('Error Load Library-'+SysErrorMessage(err));
      end;
    end;
  if G2dDllHnd=0 then exit;

  setProcFromDll(pointer(DiTmp1),'iTmp1');   //for debuging
  setProcFromDll(pointer(DiTmp2),'iTmp2');   //for debuging

  // set procedures entery points in G2D.dll
  if //setProcFromDll(@DSimpleRun,'run_gst') or     //DSimpleRun is no longer a function in the dll
     //gst functions
     setProcFromDll(@Dgst_element_factory_make,'Dgst_element_factory_make') or
     setProcFromDll(@DgstInit,'Dgst_init') or
     setProcFromDll(@Dgst_pipeline_new,'Dgst_pipeline_new') or
     setProcFromDll(@Dgst_object_unref,'Dgst_object_unref') or
     setProcFromDll(@Dgst_mini_object_unref,'Dgst_mini_object_unref') or
     setProcFromDll(@Dgst_element_get_bus,'Dgst_element_get_bus') or
     setProcFromDll(@Dgst_bin_add,'Dgst_bin_add') or
     setProcFromDll(@Dgst_element_link,'Dgst_element_link') or
     setProcFromDll(@Dgst_element_set_state,'Dgst_element_set_state') or
     setProcFromDll(@Dgst_bus_timed_pop_filtered,'Dgst_bus_timed_pop_filtered') or
     setProcFromDll(@Dgst_message_unref,'Dgst_message_unref') or
     setProcFromDll(@Dgst_element_get_request_pad,'Dgst_element_get_request_pad') or
     setProcFromDll(@Dgst_element_get_static_pad,'Dgst_element_get_static_pad') or
     setProcFromDll(@Dgst_object_get_name,'Dgst_object_get_name') or
     setProcFromDll(@Dgst_pad_link,'Dgst_pad_link') or
     setProcFromDll(@Dgst_element_release_request_pad,'Dgst_element_release_request_pad') or
     setProcFromDll(@Dgst_message_parse_state_changed,'Dgst_message_parse_state_changed') or
     setProcFromDll(@Dgst_pad_is_linked,'Dgst_pad_is_linked') or
     setProcFromDll(@Dgst_pad_get_current_caps,'Dgst_pad_get_current_caps') or
     setProcFromDll(@Dgst_caps_get_structure,'Dgst_caps_get_structure') or
     setProcFromDll(@Dgst_structure_get_name,'Dgst_structure_get_name') or

     // Callback  for gobject
     setProcFromDll(@Dg_signal_connect,'Dg_signal_connect') or

     // set Gobject functions
     setProcFromDll(@Dg_object_set_int,'Dg_object_set_int') or
     setProcFromDll(@Dg_object_set_pchar,'Dg_object_set_pchar') or

     setProcFromDll(@Dgst_element_query_position,'Dgst_element_query_position') or
     setProcFromDll(@Dgst_element_query_duration,'Dgst_element_query_duration') or
     setProcFromDll(@Dgst_element_seek_simple,'Dgst_element_seek_simple') or
     setProcFromDll(@Dgst_element_factory_find,'Dgst_element_factory_find') or
     setProcFromDll(@Dgst_element_factory_get_metadata,'Dgst_element_factory_get_metadata') or
     setProcFromDll(@Dgst_element_factory_get_static_pad_templates,'Dgst_element_factory_get_static_pad_templates') or
     setProcFromDll(@Dgst_element_factory_get_num_pad_templates,'Dgst_element_factory_get_num_pad_templates') or
     setProcFromDll(@Dgst_pad_query_caps,'Dgst_pad_query_caps') or
     setProcFromDll(@Dgst_caps_get_size,'Dgst_caps_get_size') or
     setProcFromDll(@Dgst_caps_is_any,'Dgst_caps_is_any') or
     setProcFromDll(@Dgst_caps_is_empty,'Dgst_caps_is_empty') or
     setProcFromDll(@Dgst_structure_foreach,'Dgst_structure_foreach') or
     setProcFromDll(@Dgst_value_serialize,'Dgst_value_serialize') or
     setProcFromDll(@Dg_quark_to_string,'Dg_quark_to_string') or
     setProcFromDll(@Dgst_static_caps_get,'Dgst_static_caps_get')


     //never used or setProcFromDll(@Dg_object_set_double,'Dg_object_set_double')
       then exit;
  end;
Result:=true;
end;
//------------------------------------------------------------------------------

function GstStateName(State:GstState):string;
begin
case State of
  GST_STATE_VOID_PENDING: Result:='Pending';
  GST_STATE_NULL:         Result:='Null';
  GST_STATE_READY:        Result:='Ready';
  GST_STATE_PAUSED:       Result:='PAUSED';
  GST_STATE_PLAYING:      Result:='Playing';
  else Result:='UnKnown';
end;
end;
//-----------------------------------------------------------
function GstPadLinkReturnName(Ret:GstPadLinkReturn):string;
begin
  case Ret of
  GST_PAD_LINK_OK                :Result:='GST_PAD_LINK_OK';
  GST_PAD_LINK_WRONG_HIERARCHY   :Result:='GST_PAD_LINK_WRONG_HIERARCHY';
  GST_PAD_LINK_WAS_LINKED        :Result:='GST_PAD_LINK_WAS_LINKED';
  GST_PAD_LINK_WRONG_DIRECTION   :Result:='GST_PAD_LINK_WRONG_DIRECTION';
  GST_PAD_LINK_NOFORMAT          :Result:='GST_PAD_LINK_NOFORMAT';
  GST_PAD_LINK_NOSCHED           :Result:='GST_PAD_LINK_NOSCHED';
  GST_PAD_LINK_REFUSED           :Result:='GST_PAD_LINK_REFUSED';
  else Result:='Link not defined';
  end;
end;
//------------------------------------------------------------------------------
//--------------                initialization  --------------------------------
//------------------------------------------------------------------------------
function findG2Ddll:string;
var cur:string;
  procedure DeleteLastDirectory(var APath: string); //internal
  begin
  APath := ExcludeTrailingPathDelimiter(ExtractFilePath(APath)); // delete last directory
  end;
begin
Result:='';
cur:=GetCurrentDir;
while (not cur.EndsWith(':')) and (not FileExists(cur+'\bin\G2D.dll')) do
  DeleteLastDirectory(cur);
if not cur.EndsWith(':') then Result:=cur+'\bin\G2D.dll';
end;

initialization
G2ddllpath:=findG2Ddll; //find the G2D.dll (if it is on defult dir)

WriteOut := stdWriteOut;
WriteOutln := stdWriteOutln;
//check environment variable
gst_root_envBin:=GetEnvironmentVariable('GSTREAMER_1_0_ROOT_X86_64');
                                       //GSTREAMER_1_0_ROOT_X86_64
                                        // GSTREAMER_1_0_ROOT_MSVC_X86_64
if gst_root_envBin='' then
  begin
  WriteOutln('The GStreameer installation for 64bit has errors'+sLineBreak+
      'The GSTREAMER_1_0_ROOT_X86_64 window environment variable is not deffined');
  halt;
  end;
gst_root_envBin:=gst_root_envBin+'bin\';
//check bin dir
if not FileExists(gst_root_envBin+'libglib-2.0-0.dll') then
  begin
  WriteOutln('The GStreameer installation for 64bit has errors'+sLineBreak+
      gst_root_envBin+' does not have the needed DLLs, like libglib-2.0-0.dll');
  halt;
  end;

{if setCurrentDir(gst_root_envBin)
  then WriteOutln ('changed current dir to: '+gst_root_envBin)
  else
  begin
  WriteOutln('Fatal error-the program can not change current dir to: '+gst_root_envBin);
  halt;
  end;  }

//------------------------------------------
finalization
if G2dDllLoaded then
  FreeLibrary(G2dDllHnd);
end.

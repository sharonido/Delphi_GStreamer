{* copyright (c) 2024 I. Sharon Ltd.
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
unit G2DTypes;

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
  GST_MESSAGE_ERROR             = (1 shl 1),
  GST_MESSAGE_WARNING           = (1 shl 2),
  GST_MESSAGE_INFO              = (1 shl 3),
  GST_MESSAGE_TAG               = (1 shl 4),
  GST_MESSAGE_BUFFERING         = (1 shl 5),
  GST_MESSAGE_STATE_CHANGED     = (1 shl 6),
  GST_MESSAGE_STATE_DIRTY       = (1 shl 7),
  GST_MESSAGE_STEP_DONE         = (1 shl 8),
  GST_MESSAGE_CLOCK_PROVIDE     = (1 shl 9),
  GST_MESSAGE_CLOCK_LOST        = (1 shl 10),
  GST_MESSAGE_NEW_CLOCK         = (1 shl 11),
  GST_MESSAGE_STRUCTURE_CHANGE  = (1 shl 12),
  GST_MESSAGE_STREAM_STATUS     = (1 shl 13),
  GST_MESSAGE_APPLICATION       = (1 shl 14),
  GST_MESSAGE_ELEMENT           = (1 shl 15),
  GST_MESSAGE_SEGMENT_START     = (1 shl 16),
  GST_MESSAGE_SEGMENT_DONE      = (1 shl 17),
  GST_MESSAGE_DURATION_CHANGED  = (1 shl 18),
  GST_MESSAGE_LATENCY           = (1 shl 19),
  GST_MESSAGE_ASYNC_START       = (1 shl 20),
  GST_MESSAGE_ASYNC_DONE        = (1 shl 21),
  GST_MESSAGE_REQUEST_STATE     = (1 shl 22),
  GST_MESSAGE_STEP_START        = (1 shl 23),
  GST_MESSAGE_QOS               = (1 shl 24),
  GST_MESSAGE_PROGRESS          = (1 shl 25),
  GST_MESSAGE_TOC               = (1 shl 26),
  GST_MESSAGE_RESET_TIME        = (1 shl 27),
  GST_MESSAGE_STREAM_START      = (1 shl 28),
  GST_MESSAGE_NEED_CONTEXT      = (1 shl 29),
  GST_MESSAGE_HAVE_CONTEXT      = (1 shl 30),
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
PGstMiniObject=^_GstMiniObject;

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
PGObject = ^GObject;

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
PGstObject=^_GstObject;

_GstElementFactory = record
  _object : _GObject ;
  {more fields}
  end;
PGstElementFactory = ^_GstElementFactory;

_GRecMutex  =record
  p:pointer;
  i:array[0..1] of uint;
  end;

_GCond =record  //same as _GRecMutex
  p:pointer;
  i:array[0..1] of uint;
  end;

const
GST_PADDING	= 4;
Type
_GstBus  =record
  _object :_GstObject;
  //*< private >*/
  priv    : pointer; //GstBusPrivate;
  _gst_reserved :array[0..GST_PADDING-1] of pointer;//gpointer _gst_reserved[GST_PADDING];
end;

_GstClock = record
  _object: _GstObject;
  //*< private >*/
  priv :pointer;// GstClockPrivate *priv;
  _gst_reserved :array[0..GST_PADDING-1] of pointer;//gpointer _gst_reserved[GST_PADDING];
  end;


_GList = record
  data  :pointer;//gpointer data;
  next  :^_GList;//GList *next;
  prev  :^_GList;//GList *prev;
  end;

_GstElement =record
  //*< public >*/ /* with LOCK */
  _object :_GstObject;
  state_lock:_GRecMutex;

  //* element state */
  state_cond: _GCond;
  state_cookie  :uint;

  target_state,
  current_state,
  next_state,
  pending_state:GstState;
  last_return: GstStateChangeReturn;
  bus :_GstBus;

  //* allocated clock */
  clock :^_GstClock;
  base_time :int64; //GstClockTimeDiff; //* NULL/READY: 0 - PAUSED: current time - PLAYING: difference to clock */
  start_time:uint64;  //GstClockTime

  //* element pads, these lists can only be iterated while holding
  // * the LOCK or checking the cookie after each LOCK. */
  numpads :uint16;
  pads    :^_GList;     //  GList                *pads;
  numsrcpads  :uint16;  //guint16               numsrcpads;
  srcpads     :^_GList; //GList                *srcpads;
  numsinkpads :uint16;  //guint16               numsinkpads;
  sinkpads    :^_GList; //GList                *sinkpads;
  pads_cookie :uint32;//guint32               pads_cookie;

  //* with object LOCK */
  contexts    :^_GList;//GList                *contexts;

  //*< private >*/
  _gst_reserved :array[0..GST_PADDING-2] of pointer;//gpointer _gst_reserved[GST_PADDING-1]
  end;
PGstElement=^_GstElement;

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
_object       :_GstObject; //GstObject       object;
//*< public >*/
element_private:pointer;//gpointer       element_private;
padtemplate   :pointer;{ TODO : change pointer to GstPadTemplate }//GstPadTemplate  *padtemplate;
direction     :GstPadDirection;//GstPadDirection   direction;
//*< private >*/
//* streaming rec_lock */
stream_rec_lock : _GRecMutex; //GRecMutex		         stream_rec_lock;
task            :pointer; { TODO : change pointer to ^GstTask }//  GstTask			*task;
 { TODO : complet the record... }
//this is only first elements of the pad record
(*the "full" _GstPad
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
end;




//-----------------------------------------------------------
Gst_Mes=record
  RMiniObj:_GstMiniObject;
  MType:GstMessageType;
  timestamp: Uint64;
  src: pointer; //to gobject
  seqnum: Uint32;
  lock  : _GRecMutex;//GMutex          lock;                 /* lock and cond for async delivery */
  cond  : _GCond;//GCond           cond;
end;

PGst_Mes=^Gst_Mes;
PGstState=^GstState;


//--------------------------------
var
gst_root_envBin:string='';     //after init =>envirament var..
//------------------------------------------
const
GST_MSECOND=int64(1000000);  //the GST_Clock runs in nano sec so msec is a milion nano
GST_SECOND=1000*GST_MSECOND; //the GST_Clock runs in nano sec so msec is a milion nano
GST_CLOCK_TIME_NONE=-1;      //-1=>for ever
DoForEver=GST_CLOCK_TIME_NONE;

procedure WriteOutln(st:string);
procedure stdWriteOut(st:string);

function DateToIso(DT:TDateTime):string;

function GstStateName(State:GstState):string;
function GstPadLinkReturnName(Ret:GstPadLinkReturn):string;


var
WriteOut :procedure(st:string)=stdWriteOut;
//=============================================================================
implementation

procedure stdWriteOut(st:string);
begin
  write(st);
end;

procedure WriteOutln(st:string);
begin
  WriteOut(st+sLineBreak)
end;
//------------------------------------------------------------------------------
function DateToIso(DT:TDateTime):string;
begin
DateTimeToString(Result,'dd-MM-yyyy"T"hh:nn:ss',DT);
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
end.

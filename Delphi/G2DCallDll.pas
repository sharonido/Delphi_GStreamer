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
FMX.Dialogs,
System.SysUtils;
// Types  & Const -------------------------------------------------------------
Type

PCharArr=Array of ansistring;
PArrPChar=^PCharArr;        //for C:->  char *argv[];

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

{$WARNINGS OFF}
GstMessageType=(
  GST_MESSAGE_UNKNOWN           = 0,
  GST_MESSAGE_EOS               = 1,//(1 shl 0),
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
  GST_MESSAGE_EXTENDED          = $80000000,//(1 shl 31),
  GST_MESSAGE_DEVICE_ADDED      = GST_MESSAGE_EXTENDED + 1,
  GST_MESSAGE_DEVICE_REMOVED    = GST_MESSAGE_EXTENDED + 2,
  GST_MESSAGE_PROPERTY_NOTIFY   = GST_MESSAGE_EXTENDED + 3,
  GST_MESSAGE_STREAM_COLLECTION = GST_MESSAGE_EXTENDED + 4,
  GST_MESSAGE_STREAMS_SELECTED  = GST_MESSAGE_EXTENDED + 5,
  GST_MESSAGE_REDIRECT          = GST_MESSAGE_EXTENDED + 6,
  GST_MESSAGE_DEVICE_CHANGED    = GST_MESSAGE_EXTENDED + 7,
  GST_MESSAGE_ANY               = $ffffffff);

{$WARNINGS ON}
UInt=Cardinal;  //UInt 32bit unsigned integer -In pascal winapi also defined


//----------  _GstMiniObject  --------------------------------------------------
_GstMiniObject=
  record       //not packed record, cause will be difrent in 64/32 os and on android/ios
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

// GstPadTemplete  -----------------------------------------
GstPadDirection =(
  GST_PAD_UNKNOWN,
  GST_PAD_SRC,
  GST_PAD_SINK );

GstPadPresence  =(
  GST_PAD_ALWAYS,
  GST_PAD_SOMETIMES,
  GST_PAD_REQUEST);

GstCaps=char;


GstStaticCaps =record
  caps      :^_GstMiniObject;
  Astring   :ansistring;
  reserved  :pointer;
  end;

_GstStaticPadTemplate=record
  name_template  :ansistring;
  direction      :GstPadDirection;
  presence       :GstPadPresence;
  static_caps    :GstStaticCaps;
end;

//-----------------------------------------------------------
Gst_Mes=record
  RMiniObj:_GstMiniObject;
  MType:GstMessageType;
end;
PGst_Mes=^Gst_Mes;


Tgst_funcPChars = function (const PlugNum:integer;const PlugNames:PArrPChar):integer; cdecl ;
Tgst_voidPChars = procedure (const PlugNum:integer;const PlugNames:PArrPChar); cdecl ;
Tgst_pipeline_new = function (const name:ansistring):pointer; cdecl ;
Tgst_element_get_bus = function (const Pipe:Pointer):pointer; cdecl ;
Tgst_object_unref = procedure (ref:pointer); cdecl ;
Tgst_element_factory_make = function (const factoryname,name:ansistring):pointer; cdecl ;
Tgst_bin_add = function (const Pipe,plug:pointer):boolean; cdecl;
Tgst_element_link =function (const plugA,plugB:pointer):boolean; cdecl; //like Tgst_bin_add but diffrent in dll
Tgst_element_set_state =function (const pipe:pointer;const state:GstState):GstStateChangeReturn; cdecl;
Tgst_bus_timed_pop_filtered = function (const Bus:pointer;const TimeOut:Int64;const MType:UInt):pointer; cdecl;
Tgst_message_unref = procedure (ref:pointer); cdecl ;
Tgst_element_get_request_pad =function (Const pad:pointer; const name:AnsiString):pointer; cdecl ;
Tgst_element_get_static_pad =function (Const pad:pointer; const name:AnsiString):pointer; cdecl ;
Tgst_pad_get_name =function (Const pad:pointer):Pansichar;  cdecl ;
Tgst_pad_link =function (Const PadSrc,PadSink:pointer):GstPadLinkReturn;  cdecl ;
Tgst_element_release_request_pad =procedure( const Plug,Pad:pointer) cdecl ;

//These are from GObject that is underlying framework of GStreamer  (called g_object...)
Tg_object_set_int =procedure (const plug:pointer; const param:ansistring; const val:integer); cdecl;
Tg_object_set_pchar =procedure (const plug:pointer; const param,val:ansistring); cdecl;
Tg_object_set_double =procedure (const plug:pointer; const param:ansistring; const val:double); cdecl;


Var

//The GST functions in G2D.dll
DSimpleRun                          :Tgst_funcPChars;
DgstInit                            :Tgst_voidPChars;
Dgst_pipeline_new                   :Tgst_pipeline_new;
Dgst_object_unref                   :Tgst_object_unref;
Dgst_element_get_bus                :Tgst_element_get_bus;
Dgst_element_factory_make           :Tgst_element_factory_make;
Dgst_bin_add                        :Tgst_bin_add;
Dgst_element_link                   :Tgst_element_link;
Dgst_element_set_state              :Tgst_element_set_state;
Dgst_bus_timed_pop_filtered         :Tgst_bus_timed_pop_filtered;
Dgst_message_unref                  :Tgst_message_unref;
Dgst_element_get_request_pad        :Tgst_element_get_request_pad;
Dgst_element_get_static_pad         :Tgst_element_get_static_pad;
Dgst_pad_get_name                   :Tgst_pad_get_name;
Dgst_pad_link                       :Tgst_pad_link;
Dgst_element_release_request_pad    :Tgst_element_release_request_pad;

//These are from GObject that is underlying framework of GStreamer  (called Dg_object...)
Dg_object_set_int             :Tg_object_set_int;
Dg_object_set_pchar           :Tg_object_set_pchar;
Dg_object_set_double          :Tg_object_set_double;

DiTmp1,DiTmp2:Ppointer; //for debuging only

const
GST_MSECOND=int64(1000000); //the GST_Clock runs in nano sec so msec is a milion nano
GST_CLOCK_TIME_NONE=-1;

function G2dDllLoaded:Boolean;
function G2dDllLoad:boolean;

function DateToIso(DT:TDateTime):string;

function GstStateName(State:GstState):string;
function GstPadLinkReturnName(Ret:GstPadLinkReturn):string;

implementation
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
const DllStr= 'C:\gstreamer\gst-docs-master\examples\tutorials\vs2010\x64\Debug\';  //for fast debug a default for the DLL
  function setProcFromDll(var ref:pointer;const name:ansistring):boolean;
  begin
  ref := GetProcAddress(G2dDllHnd, pansichar(name));
  Result:=Ref=nil;
  if Result then  writeln('Error in'+ name+' procedure not found in DLL');
  end;
begin
err:=0;//just for warning void
if not G2dDllLoaded then
  begin
  Result:=false;
    try
    //look for G2D.dll
    if FileExists(DllStr+'G2D.dll')   //for fast debuging
      then dllPath:=DllStr+'G2D.dll'
      else if FileExists('G2D.dll') then dllPath:='G2D.dll'  //in exe dir
      else if FileExists('..\..\..\bin\G2D.dll') then dllPath:='..\..\..\bin\G2D.dll';  //in bin dir

    G2dDllHnd := LoadLibrary(PWidechar(dllPath));
    err:=GetLastError;
    finally
    if (err<>0) or (G2dDllHnd=0) then
      begin
      G2dDllHnd:=0;
      writeln('Error Load Library-'+SysErrorMessage(err));
      end;
    end;
  if G2dDllHnd=0 then exit;

  setProcFromDll(pointer(DiTmp1),'iTmp1');   //for debuging
  setProcFromDll(pointer(DiTmp2),'iTmp2');   //for debuging

  // set procedures entery points in G2D.dll
  if //setProcFromDll(@DSimpleRun,'run_gst') or     //DSimpleRun is no longer a function in the dll
     setProcFromDll(@Dgst_element_factory_make,'Dgst_element_factory_make') or
     setProcFromDll(@DgstInit,'Dgst_init') or
     setProcFromDll(@Dgst_pipeline_new,'Dgst_pipeline_new') or
     setProcFromDll(@Dgst_object_unref,'Dgst_object_unref') or
     setProcFromDll(@Dgst_element_get_bus,'Dgst_element_get_bus') or
     setProcFromDll(@Dgst_bin_add,'Dgst_bin_add') or
     setProcFromDll(@Dgst_element_link,'Dgst_element_link') or
     setProcFromDll(@Dgst_element_set_state,'Dgst_element_set_state') or
     setProcFromDll(@Dgst_bus_timed_pop_filtered,'Dgst_bus_timed_pop_filtered') or
     setProcFromDll(@Dgst_message_unref,'Dgst_message_unref') or
     setProcFromDll(@Dgst_element_get_request_pad,'Dgst_element_get_request_pad') or
     setProcFromDll(@Dgst_element_get_static_pad,'Dgst_element_get_static_pad') or
     setProcFromDll(@Dgst_pad_get_name,'Dgst_pad_get_name') or
     setProcFromDll(@Dgst_pad_link,'Dgst_pad_link') or
     setProcFromDll(@Dgst_element_release_request_pad,'Dgst_element_release_request_pad') or

     // set Gobject finctions (the above are gstreamer -GST)
     setProcFromDll(@Dg_object_set_int,'Dg_object_set_int') or
     setProcFromDll(@Dg_object_set_pchar,'Dg_object_set_pchar') or
     setProcFromDll(@Dg_object_set_double,'Dg_object_set_double')
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
var
gst_root_envBin:string;
initialization
//check environment variable
gst_root_envBin:=GetEnvironmentVariable('GSTREAMER_1_0_ROOT_X86_64');
if gst_root_envBin='' then
  begin
  showmessage('The GStreameer installation for 64bit has errors'+sLineBreak+
      'The GSTREAMER_1_0_ROOT_X86_64 window environment variable is not deffined');
  halt;
  end;
gst_root_envBin:=gst_root_envBin+'bin\';
//check bin dir
if not FileExists(gst_root_envBin+'libglib-2.0-0.dll') then
  begin
  showmessage('The GStreameer installation for 64bit has errors'+sLineBreak+
      gst_root_envBin+' does not have the needed DLLs, like libglib-2.0-0.dll');
  halt;
  end;
if setCurrentDir(gst_root_envBin)
  then writeln ('changed current dir to: '+gst_root_envBin)
  else
  begin
  showmessage('Fatal error-the program can not change current dir to: '+gst_root_envBin);
  halt;
  end;
//------------------------------------------
finalization
if G2dDllLoaded then
  FreeLibrary(G2dDllHnd);
end.

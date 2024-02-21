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
G2DTypes, G2D,
{$IFDEF MSWINDOWS}
Winapi.Windows,
{$ENDIF }
System.SysUtils;

Type

GstStructureForeachFunc=function(const field_id:GQuark; const value:pointer;user_data:Pointer):boolean; cdecl ;
  { TODO : check ansistyring vs pansichar on all }
// --- types of functions/procedures to find in G2D.dll ---
Tgst_init = procedure (const ParCount:integer;const ParStr:PArrPChar); cdecl ;
Tgst_pipeline_new = function (const name:ansistring):PGstElement; cdecl ;
Tgst_element_get_bus = function (const Pipe:Pointer):pointer; cdecl ;
Tgst_object_unref = procedure (ref:pointer); cdecl ;
Tgst_mini_object_unref = procedure(mini_object:pointer) cdecl;
Tgst_element_factory_make = function (const factoryname,name:ansistring):pointer; cdecl ;
Tgst_bin_add = function (const Pipe,plug:pointer):boolean; cdecl;
Tgst_element_link =function (const plugA,plugB:pointer):boolean; cdecl; //like Tgst_bin_add but diffrent in dll
Tgst_element_set_state =function (const pipe:pointer;const state:GstState):GstStateChangeReturn; cdecl;
Tgst_bus_timed_pop_filtered = function (const Bus:pointer;const TimeOut:Int64;const MType:UInt):pointer; cdecl;
Tgst_message_parse_error= procedure (mes :PGst_Mes; gerror:PPGError; debug:PPAnsiChar); cdecl ;
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
Tg_object_set_int =procedure (const plug:pointer; const param:ansistring; const val:int64); cdecl;
Tg_object_set_pchar =procedure (const plug:pointer; const param,val:ansistring); cdecl;
Tg_object_set_float =procedure (const plug:pointer; const param:ansistring; const val:single); cdecl;
Tg_object_get =procedure (const Gobject: pointer; const pKey,pVal: pointer ); cdecl;
Tgst_object_get_name =function (Const pad:pointer):Pansichar;  cdecl ;

Tg_signal_connect =procedure (const instance: pointer; const detailed_signal:ansistring;
  const c_handler , data: pointer); cdecl;

Tgst_element_query_position = function(const element:pointer; const format:GstFormat;
  const cur:PInt64):boolean; cdecl;
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
Tgst_bus_add_signal_watch =procedure(bus: pointer)cdecl;
Tgst_video_overlay_set_window_handle = procedure (plugbin : pointer {PGstElement};handle:UInt64 {guintptr});cdecl;
Tg_signal_emit_by_name = procedure (instance:pointer; detailed_signal:PAnsichar;index:integer;pval:pointer);cdecl;
TGst_tag_list_get_string = function (const list :PGstMiniObject; const tag:pansichar; value:PPAnsiChar):boolean;cdecl;
TGst_tag_list_get_uint = function (const list :PGstMiniObject; const tag:pansichar; value:PUInt):boolean;cdecl;
TGst_audio_info_set_format = procedure (info: PGstAudioInfo; format: GstAudioFormat; rate,channels:integer; const position :PGstAudioChannelPosition);cdecl;
TGst_audio_info_to_caps = function (const info:PGstAudioInfo): PGstCaps;cdecl;
// ---End of types of functions/procedures to find in G2D.dll ---


Var

//The GST functions that point to nil but will get the right address in G2D.dll by setProcFromDll in G2dDllLoad
//DSimpleRun                          :Tgst_funcPChars=nil;
//_Gst_Init                           :Tgst_init;
_Gst_object_unref                   :Tgst_object_unref;
_Gst_mini_object_unref              :Tgst_mini_object_unref;
_Gst_element_get_bus                :Tgst_element_get_bus;
_Gst_element_factory_make           :Tgst_element_factory_make;
_Gst_bin_add                        :Tgst_bin_add;
_Gst_element_link                   :Tgst_element_link;
_Gst_element_set_state              :Tgst_element_set_state;
_Gst_bus_timed_pop_filtered         :Tgst_bus_timed_pop_filtered;
_Gst_message_unref                  :Tgst_message_unref;
_Gst_element_get_request_pad        :Tgst_element_get_request_pad;
_Gst_element_get_static_pad         :Tgst_element_get_static_pad;
_Gst_pad_link                       :Tgst_pad_link;
_Gst_element_release_request_pad    :Tgst_element_release_request_pad;
_Gst_message_parse_state_changed    :Tgst_message_parse_state_changed;
_Gst_message_parse_error            :Tgst_message_parse_error;
_Gst_pad_is_linked                  :Tgst_pad_is_linked;
_Gst_pad_get_current_caps           :Tgst_pad_get_current_caps;
_Gst_caps_get_structure             :Tgst_caps_get_structure;
_Gst_structure_get_name             :Tgst_structure_get_name;
_Gst_element_factory_find           :Tgst_element_factory_find;
_Gst_element_factory_get_metadata   :Tgst_element_factory_get_metadata;
_Gst_element_factory_get_static_pad_templates
                                    :Tgst_element_factory_get_static_pad_templates;
_Gst_element_factory_get_num_pad_templates
                                    :Tgst_element_factory_get_num_pad_templates;

//These are from GObject that is underlying framework of GStreamer  (called _G_object...)
_G_object_set_int             :Tg_object_set_int;
_G_object_set_float           :Tg_object_set_float;
_G_object_set_pchar           :Tg_object_set_pchar;
_G_object_get                 :Tg_object_get;
//never used _G_object_set_double          :Tg_object_set_double;
_Gst_object_get_name          :Tgst_object_get_name;
_G_signal_connect             :Tg_signal_connect;
_G_signal_emit_by_name        :Tg_signal_emit_by_name;
_Gst_element_query_position   :Tgst_element_query_position;
_Gst_element_query_duration   :Tgst_element_query_duration;
_Gst_element_seek_simple      :Tgst_element_seek_simple;
_Gst_pad_query_caps           :Tgst_pad_query_caps;
_Gst_caps_get_size            :Tgst_caps_get_size;
_Gst_caps_is_any              :Tgst_caps_is_any;
_Gst_caps_is_empty            :Tgst_caps_is_empty;
_Gst_structure_foreach        :Tgst_structure_foreach;
_Gst_value_serialize          :Tgst_value_serialize;
_G_quark_to_string            :Tg_quark_to_string;
_Gst_static_caps_get          :Tgst_static_caps_get;
_Gst_bus_add_signal_watch     :Tgst_bus_add_signal_watch;
_Gst_video_overlay_set_window_handle  :Tgst_video_overlay_set_window_handle;
_Gst_tag_list_get_string      :TGst_tag_list_get_string;
_Gst_tag_list_get_uint        :TGst_tag_list_get_uint;
_Gst_audio_info_set_format    :TGst_audio_info_set_format;
_Gst_audio_info_to_caps       :TGst_audio_info_to_caps;
//End of The GST functions that point to nil but will get the right address in G2D.dll by setProcFromDll in G2dDllLoad

DiTmp1,DiTmp2:Ppointer; //for debuging only



function G2dDllLoad:boolean;
function G2DcheckEnvironment:boolean;



//function to translate Gstreamer c to delphi
procedure DGst_init(const ParCount:integer;const ParStr:PArrPChar);
function D_element_set_state(const Pipe:GPipeLine;State:GstState):GstStateChangeReturn;
function DGst_pipeline_new(name:string):PGstElement;

procedure D_object_set_int(obj:GObject;Param:string;val:int64);
procedure D_object_set_float(obj:GObject;Param:string;val:single);
procedure D_object_set_string(obj:GObject;Param,val:string);
//procedure D_object_set_double(plug:GPlugIn;Param :string; val:double);

function  D_element_link(PlugSrc,PlugSink:GPlugIn):boolean; overload;
function  D_element_link(Pipe:GPipeLine; PlugSrcName,PlugSinkName:string):boolean; overload;
function  D_element_link_many_by_name(Pipe:GPipeLine;PlugNamesStr:string):string; //PlugNamesStr=(plug names comma seperated) ->Ok=(result='') error=(result='name of broken link pads')

function D_query_stream_position(const Plug:TGstElement;var pos:Int64):boolean;
function D_query_stream_duration(const Plug:TGstElement;var duration:Int64):boolean;
function D_query_stream_seek(const Plug:TGstElement;const seek_pos:UInt64):boolean;

implementation
//===========================================================================================
Var
//Internal The GST functions that point to nil but will get the right address in G2D.dll by setProcFromDll in G2dDllLoad

_Gst_Init                           :Tgst_init;
_Gst_pipeline_new                   :Tgst_pipeline_new;

var
G2dDllHnd:HMODULE=0;

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
if not FileExists(Result)   //if dll file in default dir
      then if FileExists('G2D.dll') then Result:='G2D.dll'  //in current dir
      else if FileExists('..\G2D.dll') then Result:='..\G2D.dll'  //in parrent dir
      else result:='';
end;


//-----------------------------------------------------------------------------
function G2DcheckEnvironment:boolean;
begin
//check environment variable
Result:=false;
gst_root_envBin:=GetEnvironmentVariable('GSTREAMER_1_0_ROOT_X86_64');
                                       //GSTREAMER_1_0_ROOT_X86_64
                                        // GSTREAMER_1_0_ROOT_MSVC_X86_64
if gst_root_envBin='' then
  begin
  WriteOutln('The GStreameer installation for 64bit has errors.'+sLineBreak+
      'The "GSTREAMER_1_0_ROOT_X86_64" window environment" variable is not deffined');
  exit;
  end;
gst_root_envBin:=gst_root_envBin+'bin\';
//check bin dir
if not FileExists(gst_root_envBin+'libglib-2.0-0.dll') then
  begin
  WriteOutln('The GStreameer installation for 64bit has errors'+sLineBreak+
      gst_root_envBin+' does not have the needed DLLs, like libglib-2.0-0.dll');
  exit;
  end;
Result:=true;
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
  if Result then  WriteOutln('Error: '+pansichar(name)+' procedure not found in G2D.dll');
  end;
begin
err:=0;//just for warning void
if G2dDllHnd=0 then
  begin
  Result:=false;
    //look for G2D.dll
  dllPath:=findG2Ddll;
  if dllPath=''
    then
    begin
    WriteOutln('Error - G2D.dll was not found.');
{$IfDef VER360}
    WriteOutln('''
                You must have G2D.dll file and all its associated dll's
                in the defoult folder or in your current (exe) folder.
                look into:
                https://github.com/sharonido/Delphi_GStreamer/tree/master/bin
               ''');
{$Endif}
    exit;
    end
    else
    try
    G2dDllHnd := LoadLibrary(PWidechar(dllPath));
    err:=GetLastError;
    finally
    if (err<>0) or (G2dDllHnd=0) then
      begin
      G2dDllHnd:=0;
      WriteOutln('Error Loading G2D.dll Library-'+SysErrorMessage(err));
{$IfDef VER360}
      if SysErrorMessage(err).IndexOf('Win32')<>-1
        then WriteOutln('apllication must be compiled as 64bit')
        else
        WriteOutln('''
                Error - G2D.dll was not loaded.
                The G2D.dll loads other GStreamer dlls,
                that probably where not found.
                Common problem might be in the
                PC ‘path’ environment variable.
               ''');
      end;
{$Endif}
    end;
  if G2dDllHnd=0 then exit;

  setProcFromDll(pointer(DiTmp1),'iTmp1');   //for debuging
  setProcFromDll(pointer(DiTmp2),'iTmp2');   //for debuging

  // set procedures entery points in G2D.dll
  if //gst functions
     setProcFromDll(@_Gst_element_factory_make,'_Gst_element_factory_make') or
     setProcFromDll(@_Gst_Init,'_Gst_init') or
     setProcFromDll(@_Gst_pipeline_new,'_Gst_pipeline_new') or
     setProcFromDll(@_Gst_object_unref,'_Gst_object_unref') or
     setProcFromDll(@_Gst_mini_object_unref,'_Gst_mini_object_unref') or
     setProcFromDll(@_Gst_element_get_bus,'_Gst_element_get_bus') or
     setProcFromDll(@_Gst_bin_add,'_Gst_bin_add') or
     setProcFromDll(@_Gst_element_link,'_Gst_element_link') or
     setProcFromDll(@_Gst_element_set_state,'_Gst_element_set_state') or
     setProcFromDll(@_Gst_bus_timed_pop_filtered,'_Gst_bus_timed_pop_filtered') or
     setProcFromDll(@_Gst_message_unref,'_Gst_message_unref') or
     setProcFromDll(@_Gst_element_get_request_pad,'_Gst_element_get_request_pad') or
     setProcFromDll(@_Gst_element_get_static_pad,'_Gst_element_get_static_pad') or
     setProcFromDll(@_Gst_object_get_name,'_Gst_object_get_name') or
     setProcFromDll(@_Gst_pad_link,'_Gst_pad_link') or
     setProcFromDll(@_Gst_element_release_request_pad,'_Gst_element_release_request_pad') or
     setProcFromDll(@_Gst_message_parse_state_changed,'_Gst_message_parse_state_changed') or
     setProcFromDll(@_Gst_message_parse_error,'_Gst_message_parse_error') or
     setProcFromDll(@_Gst_pad_is_linked,'_Gst_pad_is_linked') or
     setProcFromDll(@_Gst_pad_get_current_caps,'_Gst_pad_get_current_caps') or
     setProcFromDll(@_Gst_caps_get_structure,'_Gst_caps_get_structure') or
     setProcFromDll(@_Gst_structure_get_name,'_Gst_structure_get_name') or

     // Callback  for gobject
     setProcFromDll(@_G_signal_connect,'_G_signal_connect') or

     // set Gobject functions
     setProcFromDll(@_G_object_set_int,'_G_object_set_int') or
     setProcFromDll(@_G_object_set_float,'_G_object_set_float') or
     setProcFromDll(@_G_object_set_pchar,'_G_object_set_pchar') or
     setProcFromDll(@_G_object_get,'_G_object_get') or

     setProcFromDll(@_Gst_element_query_position,'_Gst_element_query_position') or
     setProcFromDll(@_Gst_element_query_duration,'_Gst_element_query_duration') or
     setProcFromDll(@_Gst_element_seek_simple,'_Gst_element_seek_simple') or
     setProcFromDll(@_Gst_element_factory_find,'_Gst_element_factory_find') or
     setProcFromDll(@_Gst_element_factory_get_metadata,'_Gst_element_factory_get_metadata') or
     setProcFromDll(@_Gst_element_factory_get_static_pad_templates,'_Gst_element_factory_get_static_pad_templates') or
     setProcFromDll(@_Gst_element_factory_get_num_pad_templates,'_Gst_element_factory_get_num_pad_templates') or
     setProcFromDll(@_Gst_pad_query_caps,'_Gst_pad_query_caps') or
     setProcFromDll(@_Gst_caps_get_size,'_Gst_caps_get_size') or
     setProcFromDll(@_Gst_caps_is_any,'_Gst_caps_is_any') or
     setProcFromDll(@_Gst_caps_is_empty,'_Gst_caps_is_empty') or
     setProcFromDll(@_Gst_structure_foreach,'_Gst_structure_foreach') or
     setProcFromDll(@_Gst_value_serialize,'_Gst_value_serialize') or
     setProcFromDll(@_G_quark_to_string,'_G_quark_to_string') or
     setProcFromDll(@_Gst_static_caps_get,'_Gst_static_caps_get') or
     setProcFromDll(@_Gst_bus_add_signal_watch,'_Gst_bus_add_signal_watch')or
     setProcFromDll(@_Gst_video_overlay_set_window_handle,'_Gst_video_overlay_set_window_handle')or
     setProcFromDll(@_G_signal_emit_by_name,'_G_signal_emit_by_name')or
     setProcFromDll(@_Gst_tag_list_get_string,'_Gst_tag_list_get_string')or
     setProcFromDll(@_Gst_tag_list_get_uint,'_Gst_tag_list_get_uint')or
     setProcFromDll(@_Gst_audio_info_set_format,'_Gst_audio_info_set_format')or
     setProcFromDll(@_Gst_audio_info_to_caps,'_Gst_audio_info_to_caps')


     //never used or setProcFromDll(@_G_object_set_double,'_G_object_set_double')
       then exit;
  end;
Result:=true;
end;



//------------------------------------------
//function to translate Gstreamer c to delphi
//------------------------------------------

procedure DGst_init(const ParCount:integer;const ParStr:PArrPChar);
begin
_Gst_Init(ParCount,ParStr);
end;
(*Var
I:integer;
PArr:PCharArr;
begin
SetLength(PArr,ParamCount);
for I := 1 to ParamCount do PArr[i-1]:=ParamStr(I);
if ParamCount=0
  then _Gst_Init(ParamCount,nil)
  else _Gst_Init(ParamCount,@PArr);
end;
*)
function DGst_pipeline_new(name:string):PGstElement;
begin
  Result:=_Gst_pipeline_new(ansistring(name));
end;
//------------------------------------------
procedure D_object_set_int(obj:GObject;Param:string;val:int64);
begin
_G_object_set_int(obj.RealObject,ansistring(Param),val);
end;
//------------------------------------------
procedure D_object_set_float(obj:GObject;Param:string;val:single);
begin
_G_object_set_float(obj.RealObject,ansistring(Param),val);
end;
//------------------------------------------
procedure D_object_set_string(obj:GObject;Param,val:string);
begin
_G_object_set_pchar(obj.RealObject,ansistring(Param),ansistring(val));
end;
//------------------------------------------
function D_element_set_state(const Pipe:GPipeLine;State:GstState):GstStateChangeReturn;
begin
Result:=_Gst_element_set_state(pipe.RealObject,state);
end;
//------------------------------------------


function  D_element_link(PlugSrc,PlugSink:GPlugIn):boolean;
begin
if (PlugSrc=nil) or (PlugSink=nil)
  then Result:=false
  else Result:=_Gst_element_link(PlugSrc.RealObject,PlugSink.RealObject);
end;
//------------------------------------------

function  D_element_link(Pipe:GPipeLine; PlugSrcName,PlugSinkName:string):boolean;
begin
Result:=D_element_link(Pipe.GetPlugByName(PlugSrcName),Pipe.GetPlugByName(PlugSinkName));
end;
//------------------------------------------
//GPlugin
//function D_query_stream_position(const Plug:TGstElement;var pos:Int64):boolean;
function D_query_stream_position(const Plug:TGstElement;var pos:Int64):boolean;
begin
result:=_Gst_element_query_position(Plug.RealObject,GST_FORMAT_TIME,@pos) and (pos>=0);
end;
//------------------------------------------

function D_query_stream_duration(const Plug:TGstElement;var duration:Int64):boolean;
begin
result:=_Gst_element_query_duration(Plug.RealObject,GST_FORMAT_TIME,@duration)
  and (duration>=0);
end;
//------------------------------------------

function D_query_stream_seek(const Plug:TGstElement;const seek_pos:UInt64):boolean;
begin
result:=_Gst_element_seek_simple(Plug.RealObject,GST_FORMAT_TIME,
  GstSeekFlags( integer(GST_SEEK_FLAG_FLUSH) or integer(GST_SEEK_FLAG_KEY_UNIT)),
  seek_pos);
end;
//------------------------------------------

function  D_element_link_many_by_name(Pipe:GPipeLine;PlugNamesStr:string):string; //PlugNamesStr=(plug names comma seperated) ->Ok=(result='') error=(result='name of broken link pads')
Var
  I:Integer;
  NameArr:TArray<string>;
begin
Result:='';
NameArr:=PlugNamesStr.Split([',']);
if Length(NameArr)<2 then
  begin
  Result:='Error Less then 2 plugins can not be linked!?';
  exit;
  end;
for I := 0 to Length(NameArr)-2 do
  if not D_element_link(Pipe,Trim(NameArr[I]), Trim(NameArr[I+1])) then
    begin
    Result:='Error '+Trim(NameArr[I])+' & '+Trim(NameArr[I+1])+' not linked';
    exit;
    end;
end;
//------------------------------------------------------------------------------
//--------------                initialization  --------------------------------
//------------------------------------------------------------------------------

initialization
//------------------------------------------
finalization
if G2dDllHnd<>0 then
  FreeLibrary(G2dDllHnd);
end.

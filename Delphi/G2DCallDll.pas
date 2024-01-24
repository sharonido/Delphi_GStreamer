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
G2DTypes,
{$IFDEF MSWINDOWS}
Winapi.Windows,
{$ENDIF }
System.SysUtils;

Type

GstStructureForeachFunc=function(const field_id:GQuark; const value:pointer;user_data:Pointer):boolean; cdecl ;

// --- types of functions/procedures to find in G2D.dll ---
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
// ---End of types of functions/procedures to find in G2D.dll ---



Var

//The GST functions that point to nil but will get the right address in G2D.dll by setProcFromDll in G2dDllLoad
DSimpleRun                          :Tgst_funcPChars=nil;
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
//End of The GST functions that point to nil but will get the right address in G2D.dll by setProcFromDll in G2dDllLoad

DiTmp1,DiTmp2:Ppointer; //for debuging only



function G2dDllLoad:boolean;


implementation
//===========================================================================================
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
if G2dDllHnd=0 then
  begin
  Result:=false;
    //look for G2D.dll
  dllPath:=findG2Ddll;
  if dllPath=''
    then
    begin
    WriteOutln('''
                Error - G2D.dll was not found.
                You must have G2D.dll file and all its associated dll's
                in the defoult folder or in your current (exe) folder.
                look into:
                https://github.com/sharonido/Delphi_GStreamer/tree/master/bin
               ''');
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
      WriteOutln('''
                Error - G2D.dll was not loaded.
                The G2D.dll loads other GStreamer dlls,
                that probably where not found.
                Common problem might be in the
                PC ‘path’ environment variable.
               ''');
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
//--------------                initialization  --------------------------------
//------------------------------------------------------------------------------

initialization

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
if G2dDllHnd<>0 then
  FreeLibrary(G2dDllHnd);
end.

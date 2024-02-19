{* copyright (c) 2020 I. Sharon Ltd.
 *
 * This file is part of GStreamer 2 Delphi bridge (G2D).
 *
 * G2D is free software; You can redistribute it and modify it. It is licensed
 * under the GNU Lesser General Public License as published by the Free Software
 * Foundation. Either version 2.1 of the License, or any later version.

for info on G2D download:
https://github.com/sharonido/Delphi_GStreamer/blob/master/G2D.docx
for full G2D source and bin download from:
https://github.com/sharonido/Delphi_GStreamer
  or clone by:
git clone https://github.com/sharonido/Delphi_GStreamer.git
}

program PG2DExample6;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  G2D in '..\..\Delphi\G2D.pas',
  G2DCallDll in '..\..\Delphi\G2DCallDll.pas',
  G2DTypes in '..\..\Delphi\G2DTypes.pas';

procedure print_caps (const caps:PGstCaps;const pfx:string); forward;

//------------------------------------------------------------------------------
procedure printTemplatePlugCaps(const name:string);
var
TemplatePlugin:PGstElementFactory;
Plugname,PadName:string;
pads :PGList;
caps :PGstCaps;
padtemplate :^_GstStaticPadTemplate;
PadNum:integer;
begin
caps:=nil;
TemplatePlugin:=_Gst_element_factory_find(ansistring(name));
  try
  if not Assigned(TemplatePlugin) then WriteOutln(name+ 'Template Plugin '+Name+' Not found')
    else
    begin
    Plugname:=string((_Gst_element_factory_get_metadata(TemplatePlugin,ansistring('long-name'))));
    WriteOutln('Pad Templates for '+Plugname+':');
    PadNum:=_Gst_element_factory_get_num_pad_templates(TemplatePlugin);
    if PadNum<1 then WriteOutln('Plugin '+Plugname+' has no pads')
      else
      begin
      pads := _Gst_element_factory_get_static_pad_templates(TemplatePlugin);
      while pads<>nil do
        begin
        padtemplate := pads.data;
        pads:=pads.next;
        PadName:=string(padtemplate.name_template);
          case padtemplate.direction of
          GST_PAD_UNKNOWN :WriteOutln('   UNKNOWN template: '+PadName);
          GST_PAD_SRC     :WriteOutln('   SRC template: '+PadName);
          GST_PAD_SINK    :WriteOutln('   Sinc template: '+PadName);
          end;
          //-----
          case padtemplate.presence of
          GST_PAD_ALWAYS    :WriteOutln('   Availability: Always');
          GST_PAD_SOMETIMES :WriteOutln('   Availability: Sometimes');
          GST_PAD_REQUEST   :WriteOutln('   Availability: On request');
          end;
        if padtemplate.static_caps.AString<>nil
          then
          begin
          WriteOutln('---- Capabilities ----');
          caps:=_Gst_static_caps_get (@padtemplate.static_caps);
          print_caps (caps, #9);
          WriteOutln('----------------------');
          end;
        WriteOutln('------End of '+PadName+' capabilities----------------');
        end;
      end;
    end;
  finally
    _Gst_object_unref(@(TemplatePlugin._object));
    _Gst_mini_object_unref(caps);
  end;
end;

function print_field(const field:GQuark; const value:pointer;pfx:Pointer):boolean; cdecl ;
Var
st,qname:AnsiString;
begin
st:=AnsiString(_Gst_value_serialize (value));
qname:=AnsiString(_G_quark_to_string(field));
//k:=format(PAnsichar(pfx)+' %15s: %s',[qname,st]);
WriteOutln(format(PAnsichar(pfx)+' %15s: %s',[qname,st]));
Result:=true;
end;

procedure print_caps (const caps:PGstCaps;const pfx:string);
var
i,CapsSize:integer;
PStruct: PGstStructure;
//GstCapsStr:Pansichar;
begin
if (caps=nil) then WriteOutln('Warning: Caps are nil')
  else
  begin
  if _Gst_caps_is_any(caps) then WriteOutln(pfx+'Caps = "Any"')
    else
    begin
    if _Gst_caps_is_empty(caps) then WriteOutln(pfx+'Caps = "Empty"')
      else
      begin
      CapsSize:=_Gst_caps_get_size(caps);
      for i := 0 to CapsSize-1 do
        begin
        PStruct:=_Gst_caps_get_structure(caps,i);
        WriteOutln(pfx+string(_Gst_structure_get_name(PStruct)));
        _Gst_structure_foreach (PStruct, print_field, PAnsiChar(AnsiString(pfx)));
        end;

      end;
    end;
  end;
end;

procedure  print_pad_capabilities(Plug:GPlugin;PadName:string);
var
pad :GPad;
caps:PGstCaps;
begin
pad:=GPad.CreateStatic(Plug,PadName);
WriteOutln('Capabilities for '+PadName+' Pad:');
caps := _Gst_pad_get_current_caps(pad.RealObject);
If not Assigned(caps) then caps:=_Gst_pad_query_caps(pad.RealObject,nil);
print_caps(caps,#9);
pad.Free;
_Gst_mini_object_unref(caps);
end;

//main -------------------------------------------------------------------------
Var
GStreamer:GstFrameWork;
plug:GPlugin;
MR:GstMessageType;
begin
{$IfDef VER360}
WriteOutln('''
This is example6.
This follows the example6 in Gsteramer Docs in:
https://gstreamer.freedesktop.org/documentation/tutorials/basic/media-formats-and-pad-capabilities.html?gi-language=c
but uses an object oriented framework of Delphi
-----------
In this grogram we
1. show (print) the capabilities of a clean(Template) plugin ("audiotestsrc" and "autoaudiosink")
2. shows the sink capabilities in Null state
3. shows the sink parametrs after capabilities exchange in Ready, Pause & Play states

program consul output:
''');
{$Endif}
  try
  GStreamer:=GstFrameWork.Create(0,nil); //no parameters needed here
  if GStreamer.Started then
    try
    //---  print Template of Plugin Capabilities before plugin was created
    printTemplatePlugCaps('audiotestsrc');
    printTemplatePlugCaps('autoaudiosink');
    //-------
     if not GStreamer.SimpleBuildLink('audiotestsrc ! autoaudiosink')
      then writeOutln('error in the prog (link)')
      else
      begin
      WriteOutln('--- In Null State  ---');
      plug:=GStreamer.PipeLine.GetPlugByName('autoaudiosink');
      print_pad_capabilities(plug,'sink');
      if not GStreamer.PipeLine.ChangeState(GST_STATE_PLAYING) //Play
        then writeln('error in the prog (Play)')
        else
        repeat
        GStreamer.CheckMsgAndRunFor(100*GST_MSECOND);
        MR:=GStreamer.MsgResult;
        if MR=GST_MESSAGE_STATE_CHANGED then
          begin
          sleep(10);
          WriteOutln('State is '+GstStateName(GStreamer.State));
          print_pad_capabilities(plug,'sink');
          //use next line to change frequency from 800 to whatever
          //_G_object_set_float(GStreamer.PipeLine.GetPlugByName('audiotestsrc').RealObject, pchar('freq'),800.0);
          end;

        until (GStreamer.G2DTerminate);
      end;
    finally
      GStreamer.Free;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
write('press enter to exit');
readln;
end.

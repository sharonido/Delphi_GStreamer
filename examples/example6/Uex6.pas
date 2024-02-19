unit Uex6;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  G2DTypes, G2DCallDll, G2D;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Splitter1: TSplitter;
    Panel2: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Memo1: TMemo;
    Memo2: TMemo;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    plug:GPlugin;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  GStreamer:GstFrameWork;
//MR:GstMessageType;

implementation

{$R *.dfm}
{
//writing to log in memo
procedure writeLog(st:string);
begin
if st.EndsWith(sLineBreak) then st:=st.Remove(st.Length-1);//lines.add inserts slineBreak
Form1.Memo1.Lines.Add(st);
end;  }

procedure printTemplatePlugCaps(const name:string); forward;
procedure print_pad_capabilities(Plug:GPlugin;PadName:string);  forward;

procedure TForm1.FormCreate(Sender: TObject);
var
MR:GstMessageType;
begin
//GStreamer start
GstFrameWork.MemoLog:=Memo1; //can be before create because in class var
GStreamer:=GstFrameWork.Create(0,nil); //no parameters needed here
if GStreamer.Started then
  begin
  //---  print Template of Plugin Capabilities before plugin was created
  printTemplatePlugCaps('audiotestsrc');
  printTemplatePlugCaps('autoaudiosink');
  if not GStreamer.SimpleBuildLink('audiotestsrc ! autoaudiosink')
    then writeOutln('error in the prog (link)')
    else
    begin
    Memo2.Lines.Add('---- State is '+GstStateName(GStreamer.State));
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
        Memo2.Lines.Add('---- State is '+GstStateName(GStreamer.State));
        print_pad_capabilities(plug,'sink');
        //use next line to change frequency from 800 to whatever
        //_G_object_set_float(GStreamer.PipeLine.GetPlugByName('audiotestsrc').RealObject, pchar('freq'),800.0);
        end;

      until (GStreamer.State=GstState.GST_STATE_PLAYING);
    end;
  end;
end;

//--------------------------------------------------------------------------

function print_field(const field:GQuark; const value:pointer;pfx:Pointer):boolean; cdecl ;
Var
st,qname:AnsiString;
begin
st:=AnsiString(_Gst_value_serialize (value));
qname:=AnsiString(_G_quark_to_string(field));
//k:=format(PAnsichar(pfx)+' %15s: %s',[qname,st]);
Form1.Memo2.Lines.Add(format(PAnsichar(pfx)+' %15s: %s',[qname,st]));
Result:=true;
end;

//------------------------------------------
procedure print_caps (const caps:PGstCaps;const pfx:string);
var
i,CapsSize:integer;
PStruct: PGstStructure;
//GstCapsStr:Pansichar;
begin
if (caps=nil) then Form1.Memo2.Lines.Add('Warning: Caps are nil')
  else
  begin
  if _Gst_caps_is_any(caps) then Form1.Memo2.Lines.Add(pfx+'Caps = "Any"')
    else
    begin
    if _Gst_caps_is_empty(caps) then Form1.Memo2.Lines.Add(pfx+'Caps = "Empty"')
      else
      begin
      CapsSize:=_Gst_caps_get_size(caps);
      for i := 0 to CapsSize-1 do
        begin
        PStruct:=_Gst_caps_get_structure(caps,i);
        Form1.Memo2.Lines.Add(pfx+string(_Gst_structure_get_name(PStruct)));
        _Gst_structure_foreach (PStruct, print_field, PAnsiChar(AnsiString(pfx)));
        end;
      end;
    end;
  end;
end;

//------------------------------------------

procedure print_pad_capabilities(Plug:GPlugin;PadName:string);
var
pad :GPad;
caps:PGstCaps;
begin
pad:=GPad.CreateStatic(Plug,PadName);
Form1.Memo2.Lines.Add('Capabilities for '+PadName+' Pad:');
caps := _Gst_pad_get_current_caps(pad.RealObject);
If not Assigned(caps) then caps:=_Gst_pad_query_caps(pad.RealObject,nil);
print_caps(caps,#9);
pad.Free;
_Gst_mini_object_unref(caps);
end;
//---------------------------------------------

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
  if not Assigned(TemplatePlugin) then Form1.Memo2.Lines.Add(name+ 'Template Plugin '+Name+' Not found')
    else
    begin
    Plugname:=string((_Gst_element_factory_get_metadata(TemplatePlugin,ansistring('long-name'))));
    Form1.Memo2.Lines.Add('Pad Templates for '+Plugname+':');
    PadNum:=_Gst_element_factory_get_num_pad_templates(TemplatePlugin);
    if PadNum<1 then Form1.Memo2.Lines.Add('Plugin '+Plugname+' has no pads')
      else
      begin
      pads := _Gst_element_factory_get_static_pad_templates(TemplatePlugin);
      while pads<>nil do
        begin
        padtemplate := pads.data;
        pads:=pads.next;
        PadName:=string(padtemplate.name_template);
          case padtemplate.direction of
          GST_PAD_UNKNOWN :Form1.Memo2.Lines.Add('   UNKNOWN template: '+PadName);
          GST_PAD_SRC     :Form1.Memo2.Lines.Add('   SRC template: '+PadName);
          GST_PAD_SINK    :Form1.Memo2.Lines.Add('   Sinc template: '+PadName);
          end;
          //-----
          case padtemplate.presence of
          GST_PAD_ALWAYS    :Form1.Memo2.Lines.Add('   Availability: Always');
          GST_PAD_SOMETIMES :Form1.Memo2.Lines.Add('   Availability: Sometimes');
          GST_PAD_REQUEST   :Form1.Memo2.Lines.Add('   Availability: On request');
          end;
        if padtemplate.static_caps.AString<>nil
          then
          begin
          Form1.Memo2.Lines.Add('---- Capabilities ----');
          caps:=_Gst_static_caps_get (@padtemplate.static_caps);
          print_caps (caps, #9);
          Form1.Memo2.Lines.Add('----------------------');
          end;
        Form1.Memo2.Lines.Add('------End of '+PadName+' capabilities----------------');
        end;
      end;
    end;
  finally
    _Gst_object_unref(@(TemplatePlugin._object));
    _Gst_mini_object_unref(caps);
  end;
end;
end.

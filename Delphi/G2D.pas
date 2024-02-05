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

unit G2D;

interface
uses
//G2DCallDll,  //in implementation anti cyrculer calls
G2DTypes,
System.Classes, System.SysUtils, System.Generics.Collections;

// gst objects -----------------------------------------------------------------
Type
GPipeLine=Class;

GNoUnrefObject=class(tobject)  //object that will not un_ref its RObject
  protected
  RObject:pointer; //pointer to the real gst memory (psedu object)
  public
  function isCreated:boolean;
  property RealObject:pointer read RObject write RObject;
end;

GObject=class(GNoUnrefObject)
  protected
  function GetReal:PGObject;

  public
  Destructor Destroy; override;
  function GetName:string;
  Property Name:string read GetName;
  property RealObject:PGObject read GetReal;// write RObject;
end;

GstObject=class(GObject)
  protected
  function GetReal:PGstObject;
  public
  property RealObject:PGstObject read GetReal;// write RObject;
end;

GstElement=class(GstObject)
  protected
  function GetReal:PGstElement;
  public
  property RealObject:PGstElement read GetReal;// write RObject;
end;

GPlugin=Class(GstElement)
  private
  procedure SetParams;
  protected
  Ffactory_name,
  fname:ansistring;
  ParamList:TArray<String>;
  public
  function Name:string; inline;
  property factory_name:AnsiString read Ffactory_name;
  constructor Create(const Params:string; Aname:string = '');
end;



GPad=class(GObject)
  private
  PlugRequest: GPlugIn;
  public
  function LinkToSink(SinkPad:GPad):GstPadLinkReturn;
  constructor CreateReqested(plug:GPlugIn;name:string);
  constructor CreateStatic(plug:GPlugIn;name:string;Dummy:char=' ');//Dummyis for C++ Warning

  Destructor Destroy; override;
  end;

GBus=class(GObject)   //GBus<>GMes cause future will do diffrent properties
  public
  constructor Create(pipe:GPipeLine);
end;

GMsg=class(GObject)   //GMsg has its own unref
  protected
  RMsg:PGst_Mes;
  function GetReal:PGst_Mes;
  function ftype:GstMessageType;
  public
  property MsgType:GstMessageType read ftype;
  property RealObject:PGst_Mes read GetReal;// write RObject;
  constructor Create(const TimeOut:Int64;const MType:UInt );
  Destructor Destroy; override;
end;


GPipeLine=Class(GstElement)
  protected
  fname:ansistring;
  fPlugIns:TObjectList<GPlugIn>;
  public
  property PlugIns:TObjectList<GPlugIn> read fPlugIns;
  function Name:string; inline;
  function AddPlugIn(Plug:GPlugIn):boolean;
  function GetPlugByName(PlugName:String):GPlugIn;
  function SimpleLinkAll:Boolean; //if Ok PlugIn=nil else first PlugIn that did not link
  function ChangeState(NewState:GstState):boolean;
  constructor Create(Aname:string);
  Destructor Destroy; override;
End;

GstFrameWork=class(TObject)
  private
  class var fPipeline:GPipeLine;   //pipeline & Bus are created with framework cause they
  class var fBus:GBus;             //are used in most normal cases and take less the k mem
  class var fMsg:GMsg;
  class var fterminate:Boolean;
  class var frunning:Boolean;
  class var fMsgResult:GstMessageType;
  class var fStarted:boolean;
  class var fMsgUsed:boolean;
  class var fMsgAssigned:boolean;
  class var fState:GstState;
  class var fRunForEver:boolean;
  public
  class var MsgFilter:integer;
  class var MsgResult:GstMessageType;
  //class property MsgUsed:Boolean read fMsgUsed;
  class property Started:Boolean read fStarted;
  class Property PipeLine:GPipeLine read fPipeline;
  class Property Bus:GBus read fBus;
  class Property Msg:GMsg read fMsg write fMsg;
  //class Property Running:boolean read frunning;
  class Property State:GstState read fState;
  class Property G2DTerminate:Boolean read fterminate write fterminate;
  procedure SetPadAddedCallback(const SrcPad,SinkPad:GPlugin; const capabilityStr:string);
  function WaitForPlay(Sec:Integer):boolean; //wait sec seconds for play; if sec=-1 wait forever
  procedure CheckMsgAndRunFor(TimeInNanoSec:Int64);
  function BuildPlugInsinPipeLine(params:string):boolean;

  function SimpleBuildLink(params:string):boolean;

  function SimpleBuildLinkPlay(params:string;NanoSecWaitMsg:Int64):boolean;
  constructor Create(const ParamCn:integer; Params:PArrPChar);
  Destructor Destroy; override;

end;

implementation
uses
G2DCallDll;
//------------------------------------------------------------------------------
// Gst Delphi objects
//------------------------------------------------------------------------------
//----   GNoUnrefObject=class(tobject)  ----
function GNoUnrefObject.isCreated:boolean;
begin
Result:= RealObject<>nil;
end;


//----   GObject=class(GNoUnrefObject)  ----
Destructor GObject.Destroy;
begin
if RealObject<>nil
  then _Gst_object_unref(RealObject);
RObject:=nil; //just to be sure
inherited Destroy;
end;

function GObject.GetReal:PGObject;
begin
  Result:=PGObject(RObject);
end;

function GObject.GetName: string;
begin
if isCreated
  then Result:=String(_Gst_object_get_name(RealObject))
  else Result:='The object was not created';
end;
//------- GstObject -------------------

function GstObject.GetReal:PGstObject;
begin
  Result:=PGstObject(RObject);
end;

//------- GstElement=class(GstObject) ----
function GstElement.GetReal:PGstElement;
begin
  Result:=PGstElement(RObject);
end;
//-----  GPad=class(GObject)-------
constructor GPad.CreateReqested(plug:GPlugIn;name:string);
begin
inherited Create;
PlugRequest:=plug;
RObject:=_Gst_element_get_request_pad(plug.RealObject,ansistring(name));
end;
constructor GPad.CreateStatic(plug:GPlugIn;name:string;Dummy:char=' ');//Dummyis for C++ Warning
begin
inherited Create;
PlugRequest:=nil; //this pad is static - not requested
RObject:=_Gst_element_get_static_pad(plug.RealObject,ansistring(name));
end;

Destructor GPad.Destroy;
begin
if PlugRequest<>nil then
  _Gst_element_release_request_pad(PlugRequest.RealObject,RealObject);
inherited Destroy;
end;

function GPad.LinkToSink(SinkPad:GPad):GstPadLinkReturn;
begin
Result:=_Gst_pad_link(RealObject,SinkPad.RealObject);
end;

//---  GBus=class(GObject)  -----------------
constructor GBus.Create(pipe:GPipeLine);
begin
inherited Create;
RObject:=_Gst_element_get_bus(pipe.RealObject);
//DiTmp2^:= RObject;//debuging
end;

//---  GPlugIn=Class(GNoUnrefObject) --------
constructor GPlugIn.Create(const Params:string; Aname:string = '');
begin
inherited Create;
fname:=ansistring(Aname);
ParamList:=params.Trim.Split([' ',#9]);
if length(ParamList)<1 then
  WriteOutln('Error in GPlugIn.Create -no name');
Ffactory_name:=ansistring(ParamList[0]);
if AName='' then AName:=ParamList[0];
RObject:=_Gst_element_factory_make(ansistring(ParamList[0]),fname);
if RObject=nil
  then WriteOutLn ('Error '+AName+' was not created')
  else WriteOutLn (AName+' was created');
SetParams;
End;

function GPlugIn.Name:string;
begin
if fname=''
  then Result:=string(Ffactory_name)
  else Result:=string(fname);
end;

procedure GPlugIn.SetParams;
var
  I: Integer;
  par: TArray<string>;
  X: Integer;
begin
  for I := 1 to Length(ParamList) - 1 do
    if ParamList[i].Trim <> '' then
    begin
      par := ParamList[i].Split(['=']);
      if length(Par) = 2 then
      begin
      if Par[0].Trim='name' then fName:=ansistring(Par[1].Trim);
      if TryStrToInt(Par[1].Trim, X)
        then D_object_set_int(Self, Par[0].Trim, x)
        else D_object_set_string(Self,Par[0].Trim, Par[1]);
      end;
    end;
end;

//----   GPipeLine=class(GObject)  ---------
constructor GPipeLine.Create (Aname:string);
begin
inherited Create;
fPlugIns:=TObjectList<GPlugIn>.Create(true);
//plugins will be free but,
//not their RObject that is freed by the underlyng C Gsreamer framework
fName:=ansistring(Aname);
RObject:=_Gst_pipeline_new(AnsiString(name));

//DiTmp1^:= RObject;//debuging
end;

function GPipeLine.Name:string;
begin
Result:=string(fname);
end;

Destructor GPipeLine.Destroy;
Var Plug:GPlugin;
begin
    //plugins will be free but,
    //not their RObject - that is freed by the underlyng C Gsreamer framework
for plug in PlugIns do
  Plug.RObject:=nil;
PlugIns.Free;  //use dispose so it will also work in Android/ios arm
D_element_set_state(self,GstState.GST_STATE_NULL);
inherited Destroy;
end;

function GPipeLine.AddPlugIn(Plug:GPlugIn):boolean;
begin
PlugIns.Add(Plug);
result:=_Gst_bin_add(Self.RealObject,Plug.RealObject);
end;

function GPipeLine.GetPlugByName(PlugName:String):GPlugIn;
var  I: Integer;
begin
Result:=nil;
for I := 0 to PlugIns.Count-1 do
  if PlugIns[I].Name=PlugName.Trim then
  begin
  Result:=PlugIns[I];
  exit;
  end;
end;

function GPipeLine.SimpleLinkAll:Boolean; //if Ok PlugIn=nil else first PlugIn that did not link
var I:integer;
begin
result:=false;
for I := 0 to PlugIns.Count-2 do
  if not D_element_link(PlugIns[I],PlugIns[I+1])
    then
    begin
    WriteOutln('Error '+PlugIns[I].Name+' did not link to '+PlugIns[I+1].Name);
    exit;
    end;

if PlugIns.Count>1 then WriteOutln(PlugIns.Count.ToString+' plugins were successfully linked');
result:=true;
end;

function GPipeLine.ChangeState(NewState:GstState):boolean;
begin
Result:=false;
If D_element_set_state(self,NewState)=GST_STATE_CHANGE_FAILURE
  then WriteOutln('PipeLine '+Name+' could not change state to '+GstStateName(NewState))
  else
  begin
  WriteOutln('PipeLine '+Name+' started changing state to '+GstStateName(NewState)+' at '+DateToIso(now));
  Result:=true;
  end;
end;

//----   GMsg=class(GObject)  ----------------
constructor GMsg.Create(const TimeOut:Int64;const MType:UInt );
var old_state, new_state :GstState;
begin
inherited Create;
GstFrameWork.fRunForEver:=TimeOut=DoForEver;
GstFrameWork.fMsgUsed:=false;
GstFrameWork.fMsgAssigned:=false;
RObject:=_Gst_bus_timed_pop_filtered(GstFrameWork.Bus.RealObject,TimeOut,MType);
RMsg:=RealObject;
if (RMsg <> nil) then  // There is a msg
  begin
  GstFrameWork.MsgResult:=MsgType;
  GstFrameWork.fMsgAssigned:=true;
    case MsgType of  //* Parse message */
    GST_MESSAGE_ERROR:
      begin
      GstFrameWork.fMsgUsed:=true;
        {   GError *err;
            gchar *debug_info;
              case GST_MESSAGE_ERROR:
              gst_message_parse_error (msg, &err, &debug_info);
              g_printerr ("Error received from element %s: %s\n",
                  GST_OBJECT_NAME (msg->src), err->message);
              g_printerr ("Debugging information: %s\n",
                  debug_info ? debug_info : "none");
              g_clear_error (&err);
              g_free (debug_info);
              terminate = TRUE;
              break; }
      WriteOutln('');
      WriteOutln('Gst message: Error in stream');
      If GstFrameWork.State=GstState.GST_STATE_READY
        then WriteOutln('Probebly stream src not found');
      GstFrameWork.fterminate := TRUE;
      end;
    GST_MESSAGE_EOS:
      begin
      WriteOutln('');
      WriteOutln('End-Of-Stream reached.');
      GstFrameWork.fMsgUsed:=true;
      GstFrameWork.fterminate := TRUE;
      end;
    GST_MESSAGE_STATE_CHANGED:
      begin
      //* We are only interested in state-changed messages from the pipeline */
      if (RMsg.src = GstFrameWork.Pipeline.RealObject) then

        begin
        _Gst_message_parse_state_changed(RMsg , @old_state, @new_state, nil);
        WriteOutln('Pipeline changed state from ' +
                    GstStateName(old_state) +
                    ' to ' +GstStateName(new_state));
        GstFrameWork.fState:=new_state;
        GstFrameWork.fMsgUsed:=true;
        GstFrameWork.frunning:=(GstState(new_state)=GstState.GST_STATE_PLAYING);
        end;
      end;
    else WriteOutln('Internal error in - GMsg.Create');
    end;
  end;
end;

Destructor GMsg.Destroy;
begin
if RealObject<>nil
  then _Gst_message_unref(RealObject);
RObject:=nil;  //so it will not be unref as Gobject
inherited Destroy;
end;

function GMsg.GetReal:PGst_Mes;
begin
Result:=PGst_Mes(RObject);
end;

Function GMsg.ftype:GstMessageType;
begin
Result:=RMsg^.MType;
end;

//----   GstFrameWork=class(Tbject)  ----------------
constructor GstFrameWork.Create(const ParamCn:integer; Params:PArrPChar);
begin
if fStarted
  then WriteOutln('trying to create GstFrameWork twice')
  else
  begin
  inherited create;
  MsgFilter:=integer(GST_MESSAGE_ERROR) or integer(GST_MESSAGE_EOS) or integer(GST_MESSAGE_STATE_CHANGED);
  fterminate:=false;
  fMsgResult:=GstMessageType.GST_MESSAGE_UNKNOWN;
  if G2DcheckEnvironment and //check the GStreamer Enviroment on this machine
      G2dDllLoad then //check if G2D.dll was loaded, if not load it
    begin
    DGst_Init(ParamCn,Params);  //init the gst framework
    WriteOutln('Gst Framework started');
    // create a default pipeline
    fPipeLine:=GPipeLine.Create('DelphiPipeline'); //delphi pipeline -just a name
    if not PipeLine.isCreated then
      begin
      WriteOutln('Default Pipeline '+PipeLine.name+' was not created');
      exit;
      end;
    // create a default  bus for the pipeline, to check on stream
    fBus:=GBus.create(PipeLine);
    if not Bus.isCreated then
      begin
      writeoutln('Default Bus was not created');
      exit;
      end;
    fStarted:=true;
    end;
  end;
end;

Destructor GstFrameWork.Destroy;
begin
Bus.Free;
if assigned(Pipeline) and not Pipeline.Disposed
  then PipeLine.Free;
if fstate=GST_STATE_PLAYING then
  begin
  WriteOutln('');
  WriteOutln('Stream had ran until '+DateToIso(Now));
  end;
inherited Destroy;
end;

function GstFrameWork.BuildPluginsInPipeLine(params:string):boolean;
var
  PlugStrs:TArray<string>;
  Plug:GPlugIn;
  I:Integer;
begin
Result:=false;
if Started then //check if G2D.dll was loaded, if not load it
  begin
  PlugStrs:=params.Split(['!']); //split param to the diffrent plugins that were ordered
  // create the needed plugins and add them to
  //the pipeline (they are still not connected to one another)
  if length(PlugStrs)<1 then
    begin
    WriteOutln('Error no plugins where provided');
    exit;
    end;
  for I := 0 to length(PlugStrs)-1 do
    begin
    Plug:=GPlugIn.Create(PlugStrs[i]);
    if not Plug.isCreated then
      begin
      WriteOutln('Error - Plug in  '+Plug.name+' was not found and not created');
      PipeLine.Free;
      fPipeLine:=nil;
      exit;
      end;
    PipeLine.AddPlugIn(Plug);
    end;
  WriteOutln('pipeline was built successfully');
  Result:=true;
  end
  else WriteOutln('GStreamer framework did not start error');
end;
//****************************************************************************************************************

//****************************************************************************************************************
//This is the CallBack procedure -When a src pad is trying to connect to a new pad
Var PadCapabilityString:AnsiString;
Procedure pad_added_handler(src, new_pad, data:pointer); cdecl;
var
n1,n2:string;
sink_pad:^_GstPad;
GstCaps:^_GstCaps;
GstStruct: PGstStructure;
GstCapsStr:Pansichar;
begin
//Get & write names - just for user readabilty
n2:=string(_GstObject(src^).name);
n1:=string(_GstObject(new_pad^).name);
writeln('Received new pad '+n1+' from '+n2);
GstCaps:=nil;
//Sink pad is the pad that receives the stream
sink_pad := _Gst_element_get_static_pad (data{convert.RealObject}, 'sink');
if _Gst_pad_is_linked(sink_pad)
  then writeln('We are already linked. Ignoring.')
  else
  begin
  //get the string describing the capability of the sink pad
    GstCaps:=_Gst_pad_get_current_caps(new_pad);
  GstStruct:=_Gst_caps_get_structure(GstCaps, 0);
  GstCapsStr:=_Gst_structure_get_name(GstStruct);
  n1:=string(GstCapsStr);
  //check if these are the capabilities we need
  if not n1.Contains(string(PadCapabilityString))
    then writeln('This pad is of type '+n1+' which is not '+
                string(PadCapabilityString)+'. Ignoring.')
    else
    begin
    // do the actual pad Link needed
    if (_Gst_pad_link(new_pad, sink_pad)<>GstPadLinkReturn.GST_PAD_LINK_OK)
      then writeln('This pad is of type '+n1+' but link failed.')
      else writeln('Pad link  with (type '''+n1+''') succeeded.');
    end;
  end;
//free the objects we created here
if GstCaps<>nil then
  _Gst_mini_object_unref (@GstCaps.mini_object);
if sink_pad<>nil then
  _Gst_object_unref (sink_pad);
end;

//****************************************************************************************************************
procedure GstFrameWork.SetPadAddedCallback(const SrcPad,SinkPad:GPlugin; const capabilityStr:string);
begin
PadCapabilityString:=ansistring(capabilityStr);
_G_signal_connect (SrcPad.RealObject, ansistring('pad-added'), @pad_added_handler, SinkPad.RealObject);
end;

function GstFrameWork.WaitForPlay(Sec:Integer):boolean; //wait sec seconds for play; if sec=-1 wait forever
Var I:integer;
begin
I:=0;
Result:=true;
While ((Sec=-1) or (I<(Sec*100))) and not (State=GST_STATE_PLAYING) do
  begin
  Inc(I);
  CheckMsgAndRunFor(10*GST_MSECOND);
  end;
if State=GST_STATE_PLAYING
  then WriteOutln('Gstreamer is running')
  else
  begin
  Result:=false;
  WriteOutln('Error Gstreamer did not run');
  end;
end;

function GstFrameWork.SimpleBuildLink(params:string):boolean;
begin
Result:=BuildPlugInsInPipeLine(params);
if Result
  then Result:= PipeLine.SimpleLinkAll //link the plugins one to the other
end;


procedure GstFrameWork.CheckMsgAndRunFor(TimeInNanoSec:Int64);
begin
  repeat
  MsgResult:=GST_MESSAGE_UNKNOWN;
  Msg:=GMsg.Create(TimeInNanoSec,MsgFilter);  //wait upto NanoSec, for Msg in MsgFilter
  //if there was a msg in the time interval, MsgResult will change
  Msg.Free;
  sleep(0);
  until G2DTerminate or (not fMsgAssigned) or (fMsgUsed and (not fRunForEver))
  //(MsgResult=GST_MESSAGE_UNKNOWN);
end;


function GstFrameWork.SimpleBuildLinkPlay(params:string;NanoSecWaitMsg:Int64):boolean;
begin
Result:=SimpleBuildLink(Params); //Build & Link
if Result then
  begin
  Result:=PipeLine.ChangeState(GST_STATE_PLAYING); //Play
  CheckMsgAndRunFor(NanoSecWaitMsg);
  end;
end;

end.

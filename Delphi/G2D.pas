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
G2DCallDll,
FMX.Dialogs,
System.Classes, System.SysUtils, System.Generics.Collections, System.Threading;

// gst objects -----------------------------------------------------------------
Type
GPipeLine=Class;

GNoUnrefObject=class(tobject)  //object that will not un_ref its RObject
  protected
  RObject:pointer; //pointer to the real gst memory (psedu object)
  public
  function isCreated:boolean;
  property RealObject:pointer read RObject;
end;

GObject=class(GNoUnrefObject)
  public
  Destructor Destroy; override;
end;

GPlugIn=Class(GObject)
  private
  procedure SetParams;
  protected
  Ffactory_name, fname:ansistring;
  ParamList:TArray<String>;
  public
  function Name:string; inline;
  constructor Create(const Afactory_name,Aname:string); overload;
  constructor Create(const Params:string); overload;
  property factory_name:AnsiString read Ffactory_name;
end;

GPad=class(GObject)
  private
  PlugRequest: GPlugIn;
  function GetName:string;
  public
  Property Name:string read GetName;
  function LinkToSink(SinkPad:GPad):GstPadLinkReturn;
  constructor CreateReqested(plug:GPlugIn;name:string);
  constructor CreateStatic(plug:GPlugIn;name:string;Dummy:integer=0); //Dummy is added just to eliminate warning
  Destructor Destroy; override;
  end;

GBus=class(GObject)   //GBus<>GMes cause future will do diffrent properties
  public
  constructor Create(pipe:GPipeLine);
end;

GMsg=class(GObject)   //GMsg has its own unref
  protected
  RMes:PGst_Mes;
  function ftype:GstMessageType;
  public
  property MsgType:GstMessageType read ftype;
  constructor Create(const Bus:GBus;const TimeOut:Int64;const MType:UInt );
  Destructor Destroy; override;
end;


GPipeLine=Class(GObject)
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
  fPipeline:GPipeLine;   //pipeline & Bus are created with framework cause  they
  fBus:GBus;             //are used in most normal cases and take less the k mem
  fMsg:GMsg;
  class var fMsgResult:GstMessageType;
  class var fStarted:boolean;
  procedure ExitStream;
  function StartLaunchSimlpePipeline(params:string):boolean;
  public
  class property Started:Boolean read fStarted;
  class property MsgResult:GstMessageType read fMsgResult;
  Property PipeLine:GPipeLine read fPipeline;
  Property Bus:GBus read fBus;
  Property Msg:GMsg read fMsg write fMsg;
  procedure StreamRun(NanoSec:Int64;RetMessageType:Integer;Wait:boolean=true);
  function BuildPlugInsInPipeLine(params:string):boolean;
  function LaunchSimlpePipelineAndWaitEos(params:string):boolean;
  function LaunchSimlpePipelineDoNotWait(params:string):boolean;
  constructor Create(const ParamCn:integer; Params:PArrPChar);
  Destructor Destroy; override;

end;

function  D_element_set_state(const Pipe:GPipeLine;State:GstState):GstStateChangeReturn;

procedure D_object_set_int(plug:GPlugIn;Param:string;val:integer);
procedure D_object_set_string(plug:GPlugIn;Param,val:string);
procedure D_object_set_double(plug:GPlugIn;Param :string; val:double);

function  D_element_link(PlugSrc,PlugSink:GPlugIn):boolean; overload;
function  D_element_link(Pipe:GPipeLine; PlugSrcName,PlugSinkName:string):boolean; overload;
function  D_element_link_many_by_name(Pipe:GPipeLine;PlugNamesStr:string):string; //PlugNamesStr=(plug names comma seperated) ->Ok=(result='') error=(result='name of broken link pads')

implementation

//------------------------------------------------------------------------------
function StringArrToCPpChar(const StrArr:TArray<string>;var Params:PCharArr;Trim:Boolean=false):PArrPChar;
var
I:Integer;
begin
SetLength(Params,length(StrArr));
  for I := 0 to length(StrArr)-1 do
    if Trim then Params[i]:=Ansistring(StrArr[i].Trim)
            else Params[i]:=Ansistring(StrArr[i]);
Result:=@Params[0];
end;
//------------------------------------------
procedure D_object_set_int(plug:GPlugIn;Param:string;val:integer);
begin
Dg_object_set_int(plug.RealObject,ansistring(Param),val);
end;

//------------------------------------------
procedure D_object_set_string(plug:GPlugIn;Param,val:string);
begin
Dg_object_set_pchar(plug.RealObject,ansistring(Param),ansistring(val));
end;
//------------------------------------------
procedure D_object_set_double(plug:GPlugIn;Param :string;val:double);
begin
Dg_object_set_double(plug.RealObject,ansistring(Param),val);
end;
//------------------------------------------
function D_element_set_state(const Pipe:GPipeLine;State:GstState):GstStateChangeReturn;
begin
Result:=Dgst_element_set_state(pipe.RealObject,state);
end;
//------------------------------------------


function  D_element_link(PlugSrc,PlugSink:GPlugIn):boolean;
begin
if (PlugSrc=nil) or (PlugSink=nil)
  then Result:=false
  else Result:=Dgst_element_link(PlugSrc.RealObject,PlugSink.RealObject);
end;
//------------------------------------------

function  D_element_link(Pipe:GPipeLine; PlugSrcName,PlugSinkName:string):boolean;
begin
Result:=D_element_link(Pipe.GetPlugByName(PlugSrcName),Pipe.GetPlugByName(PlugSinkName));
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
  then Dgst_object_unref(RealObject);
RObject:=nil; //just to be sure
inherited Destroy;
end;
//-----  GPad=class(GObject)-------
constructor GPad.CreateReqested(plug:GPlugIn;name:string);
begin
inherited Create;
PlugRequest:=plug;
RObject:=Dgst_element_get_request_pad(plug.RealObject,ansistring(name));
end;

constructor GPad.CreateStatic(plug:GPlugIn;name:string;Dummy:integer=0);
begin
inherited Create;
PlugRequest:=nil; //this pad is static - not requested
RObject:=Dgst_element_get_static_pad(plug.RealObject,ansistring(name));
end;

Destructor GPad.Destroy;
begin
if PlugRequest<>nil then
  Dgst_element_release_request_pad(PlugRequest.RealObject,RealObject);
inherited Destroy;
end;

function GPad.LinkToSink(SinkPad:GPad):GstPadLinkReturn;
begin
Result:=Dgst_pad_link(RealObject,SinkPad.RealObject);
end;

function GPad.GetName:string;
begin
if isCreated
  then Result:=String(Dgst_pad_get_name(RealObject))
  else Result:='Pad was not created';
end;

//---  GBus=class(GObject)  -----------------
constructor GBus.Create(pipe:GPipeLine);
begin
inherited Create;
RObject:=Dgst_element_get_bus(pipe.RealObject);
//DiTmp2^:= RObject;//debuging
end;

//---  GPlugIn=Class(GNoUnrefObject) --------
constructor GPlugIn.Create(const Afactory_name,Aname:string);
begin
inherited Create;
fname:=ansistring(Aname);
Ffactory_name:=ansistring(Afactory_name);
RObject:=Dgst_element_factory_make(factory_name,fname);
End;

constructor GPlugIn.Create(const Params:string);
begin
Inherited Create;
ParamList:=params.Trim.Split([' ',#9]); 
if length(ParamList)<1 then
  begin
  showmessage('Error in GPlugIn.Create -no name');
  halt;
  end;
create(ParamList[0],ParamList[0]);
SetParams;
end;

function GPlugIn.Name:string;
begin
Result:=string(fname);
end;

procedure GPlugIn.SetParams;
var
  I: Integer;
  par: TArray<string>;
  X: Integer;
  D: Double;
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
        else if TryStrToFloat(Par[1].Trim, D)
        then D_object_set_double(Self, Par[0].Trim, D)
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
RObject:=Dgst_pipeline_new(AnsiString(name));

//DiTmp1^:= RObject;//debuging
end;

function GPipeLine.Name:string;
begin
Result:=string(fname);
end;

Destructor GPipeLine.Destroy;
Var Plug:GPlugIn;
begin
    //plugins will be free but,
    //not their RObject - that is freed by the underlyng C Gsreamer framework
for plug in PlugIns do Plug.RObject:=nil;
PlugIns.DisposeOf;  //use dispose so it will also work in Android/ios arm
D_element_set_state(self,GstState.GST_STATE_NULL);
inherited Destroy;
end;

function GPipeLine.AddPlugIn(Plug:GPlugIn):boolean;
begin
PlugIns.Add(Plug);
result:=Dgst_bin_add(Self.RealObject,Plug.RealObject);
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
  if not D_element_link(PlugIns[I],PlugIns[I+1]) then
    begin
    writeln('Error '+PlugIns[I].Name+' did not link to '+PlugIns[I+1].Name);
    exit;
    end;
if PlugIns.Count>1 then writeln(PlugIns.Count.ToString+' plugins were successfully linked');
result:=true;
end;

function GPipeLine.ChangeState(NewState:GstState):boolean;
begin
Result:=false;
If D_element_set_state(self,NewState)=GST_STATE_CHANGE_FAILURE
  then writeln('PipeLine '+Name+' could not change state to '+GstStateName(NewState))
  else
  begin
  writeln('PipeLine '+Name+' changed state to '+GstStateName(NewState)+' at '+DateToIso(now));
  Result:=true;
  end;
end;

//----   GMsg=class(GObject)  ----------------
constructor GMsg.Create(const Bus:GBus;const TimeOut:Int64;const MType:UInt );
begin
inherited Create;
RObject:=Dgst_bus_timed_pop_filtered(Bus.RealObject,TimeOut,MType);
RMes:=RealObject;
end;

Destructor GMsg.Destroy;
begin
if RealObject<>nil
  then Dgst_message_unref(RealObject);
RObject:=nil;  //so it will not be unref as Gobject
inherited Destroy;
end;

Function GMsg.ftype:GstMessageType;
begin
Result:=RMes^.MType;
end;

//----   GstFrameWork=class(Tbject)  ----------------
constructor GstFrameWork.Create(const ParamCn:integer; Params:PArrPChar);
begin
if fStarted
  then writeln('trying to create GstFrameWork twice')
  else
  begin
  inherited create;
  fMsgResult:=GstMessageType.GST_MESSAGE_UNKNOWN;
  if G2dDllLoad then //check if G2D.dll was loaded, if not load it
    begin
      try
      DgstInit(ParamCn,Params);  //init the gst framework
      writeln('Gst Framework started');
      finally
      fStarted:=true;
      end;
    // create a default pipeline
    fPipeLine:=GPipeLine.Create('Delphi'); //delphi pipeline -just a name
    if not PipeLine.isCreated then
      begin
      writeln('Default Pipeline '+PipeLine.name+' was not created');
      showmessage('Default Pipeline '+string(PipeLine.name)+' was not created');
      halt;
      end;

    // create a default  bus for the pipeline, to check on stream
    fBus:=GBus.create(PipeLine);
    if not Bus.isCreated then
      begin
      writeln('Default Bus was not created');
      showmessage('Default Bus was not created');
      halt;
      end;
    end;
  end;
end;

Destructor GstFrameWork.Destroy;
begin
//clean befor exit
fMsgResult:=GST_MESSAGE_ANY;
Bus.DisposeOf;
if assigned(Pipeline) and not Pipeline.Disposed
  then PipeLine.DisposeOf;
inherited Destroy;
end;

function GstFrameWork.BuildPlugInsInPipeLine(params:string):boolean;
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
    writeln('Error no plugins where provided');
    exit;
    end;
  for I := 0 to length(PlugStrs)-1 do
    begin
    Plug:=GPlugIn.Create(PlugStrs[i]);
    if not Plug.isCreated then
      begin
      writeln('Error - Plug in  '+Plug.name+' was not found and not created');
      PipeLine.DisposeOf;
      fPipeLine:=nil;
      exit;
      end;
    PipeLine.AddPlugIn(Plug);
    end;
  writeln('pipeline was built successfully');
  Result:=true;
  end
  else WriteLn('GStreamer framework did not start error');
end;

function GstFrameWork.StartLaunchSimlpePipeline(params:string):boolean;
begin
Result:=BuildPlugInsInPipeLine(params);
if Result then
  begin
  if not PipeLine.SimpleLinkAll //link the plugins one to the other
                                //(as a simple pipe - with no branches)
     or not PipeLine.ChangeState(GST_STATE_PLAYING)
    then
    begin
    Result:=false;
    PipeLine.DisposeOf;
    fPipeLine:=nil;
    exit;
    end;
  end;
end;

procedure GstFrameWork.ExitStream;
begin
writeln;
if Msg.isCreated then
  begin
  fMsgResult:=Msg.MsgType;  // check why stoped
    case MsgResult of
    GST_MESSAGE_EOS   : writeln('Gst message: End Of Stream');
    GST_MESSAGE_ERROR : writeln('Gst message: Error in stream');
    else writeln('Should never be here???');
    end;
  Msg.DisposeOf;
  end;
end;

procedure GstFrameWork.StreamRun(NanoSec:Int64;RetMessageType:Integer;Wait:boolean=true);
begin
if Wait then
  begin
  Msg:=GMsg.Create(Bus,NanoSec,RetMessageType);  //wait for error or EoS
  ExitStream;
  end
  else
  TTask.Run(procedure
      begin
      Msg:=GMsg.Create(Bus,1* GST_MSECOND,RetMessageType);
      while not Msg.isCreated and (MsgResult<>GST_MESSAGE_ANY) do
        Msg:=GMsg.Create(Bus,NanoSec,RetMessageType);
      ExitStream;  { TODO -oIdo -cthreads : unsafe should syncronize }
      end);
end;

function GstFrameWork.LaunchSimlpePipelineAndWaitEos(params:string):boolean;
begin
Result:=StartLaunchSimlpePipeline(Params);
if Result then
  StreamRun(GST_CLOCK_TIME_NONE,integer(GST_MESSAGE_ERROR) or integer(GST_MESSAGE_EOS))
end;


function GstFrameWork.LaunchSimlpePipelineDoNotWait(params:string):boolean;
begin
Result:=StartLaunchSimlpePipeline(Params); //wait for error or EoS
if Result then
  StreamRun(100*GST_MSECOND,integer(GST_MESSAGE_ERROR) or integer(GST_MESSAGE_EOS),false)
end;

end.

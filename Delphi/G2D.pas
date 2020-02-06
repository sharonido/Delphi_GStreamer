{* copyright (c) 2020 I. Sharon Ltd.
 *
 * This file is part of GStreamer 2 Delphi bridge (G2D).
 *
 * G2D is free software; You can redistribute it and modify it. It is licensed
 * under the GNU Lesser General Public License as published by the Free Software
 * Foundation. Either version 2.1 of the License, or any later version.

for info on G2D goto
https://github.com/sharonido/Delphi_GStreamer
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

GPlugIn=Class(GNoUnrefObject)
  private
  procedure SetParams;
  protected
  Ffactory_name, fname:ansistring;
  ParamList:TArray<String>;
  public
  constructor Create(const Afactory_name,Aname:string); overload;
  constructor Create(const Params:string); overload;
  Destructor Destroy; override;
  property factory_name:AnsiString read Ffactory_name;
  property Name:AnsiString read fname;
end;

GBus=class(GObject)   //GBus<>GMes cause future will do diffrent properties
  public
  constructor Create(pipe:GPipeLine);
end;

GMsg=class(GNoUnrefObject)   //GMsg has its own unref
  protected
  RMes:PGst_Mes;
  function ftype:GstMessageType;
  public
  property MsgType:GstMessageType read ftype;
  constructor Create(const Bus:GBus;const TimeOut:Int64;const MType:UInt );
  Destructor Destroy; override;
end;


GPipeLine=Class(GNoUnrefObject)
  protected
  fname:ansistring;
  fPlugIns:TObjectList<GPlugIn>;
  public
  property PlugIns:TObjectList<GPlugIn> read fPlugIns;
  property Name:AnsiString read fname;
  function AddPlugIn(Plug:GPlugIn):boolean;
  function SimpleLinkAll:GPlugIn; //if Ok PlugIn=nil else first PlugIn that did not link
  constructor Create(Aname:string);
  Destructor Destroy; override;
End;

GstFrameWork=class(TObject)
  private
  fPipeline:GPipeLine;   //pipeline & Bus are created with framework cause  they
  fBus:GBus;             //are used in most normal cases and take less the k mem
  class var fMsgResult:GstMessageType;
  class var fStarted:boolean;
  function StartLaunchSimlpePipeline(params:string):boolean;
  public
  class property Started:Boolean read fStarted;
  class property MsgResult:GstMessageType read fMsgResult;
  Property PipeLine:GPipeLine read fPipeline;
  Property Bus:GBus read fBus;
  function LaunchSimlpePipelineAndWaitEos(params:string):boolean;
  function LaunchSimlpePipelineDoNotWait(params:string):boolean;
  constructor Create(const ParamCn:integer; Params:PArrPChar);
  Destructor Destroy; override;

end;

function D_element_set_state(const Pipe:GPipeLine;State:GstState):GstStateChangeReturn;
procedure D_object_set_int(plug:GPlugIn;Param:string;val:integer);
procedure D_object_set_string(plug:GPlugIn;Param,val:string);
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
function D_element_set_state(const Pipe:GPipeLine;State:GstState):GstStateChangeReturn;
begin
Result:=Dgst_element_set_state(pipe.RealObject,state);
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
inherited Destroy;
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
fName:=ansistring(Aname);
Ffactory_name:=ansistring(Afactory_name);
RObject:=Dgst_element_factory_make(factory_name,Name);
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

Destructor GPlugIn.Destroy;
begin
inherited;
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
        if TryStrToInt(Par[1], X) then
          D_object_set_int(Self, Par[0], x);
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

Destructor GPipeLine.Destroy;
begin
//plugins will be free but,
//not their RObject - that is freed by the underlyng C Gsreamer framework
PlugIns.DisposeOf;  //use dispose so it will also work in Android/ios arm
D_element_set_state(self,GstState.GST_STATE_NULL);
inherited Destroy;
end;

function GPipeLine.AddPlugIn(Plug:GPlugIn):boolean;
begin
PlugIns.Add(Plug);
result:=Dgst_bin_add(Self.RealObject,Plug.RealObject);
end;

function GPipeLine.SimpleLinkAll:GPlugIn; //if Ok PlugIn=nil else first PlugIn that did not link
var I:integer;
begin
result:=nil;
for I := 0 to PlugIns.Count-2 do
  if not Dgst_element_link(PlugIns[I].RealObject,PlugIns[I+1].RealObject) then
    begin
    Result:=PlugIns[I];
    exit;
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
    fPipeLine:=GPipeLine.Create('Delphi PipeLine'); //delphi pipeline -just a name
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

function GstFrameWork.StartLaunchSimlpePipeline(params:string):boolean;
var
PlugStrs:TArray<string>;
Plug:GPlugIn;
I:Integer;
ret:GstStateChangeReturn;
begin
Result:=false;
if Started then //check if G2D.dll was loaded, if not load it
  begin
  PlugStrs:=params.Split(['!']); //split param to the diffrent plugins that were ordered
  // create the needed plugins and add them to
  //the pipeline (they are still not connected to one another)
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
  Plug:=PipeLine.SimpleLinkAll; //link the plugins one to the other
                                //(as a simple pipe - with no branches)
  if plug<>nil then             //plug is the first that didn't link
    begin
    writeln('Plug '+plug.Name+' was not able to link');
    PipeLine.DisposeOf;
    fPipeLine:=nil;
    exit;
    end;
  writeln(length(PlugStrs).ToString+' plugins were successfully linked');
   //start play
  ret:=D_element_set_state(PipeLine,GstState.GST_STATE_PLAYING);
  if ret=GST_STATE_CHANGE_FAILURE then
    begin
    writeln('Could not start playing');
    PipeLine.DisposeOf;
    fPipeLine:=nil;
    exit;
    end
    else; Writeln('GStreamer started play at '+DateToIso(now));
  result:=true; //exit with true
  end
  else WriteLn('GStreamer framework did not start error');
end;

function GstFrameWork.LaunchSimlpePipelineAndWaitEos(params:string):boolean;
var
Msg:GMsg;
begin
Result:=StartLaunchSimlpePipeline(Params); //wait for error or EoS
if Result then
  begin
  Msg:=GMsg.Create(Bus,GST_CLOCK_TIME_NONE,integer(GST_MESSAGE_ERROR) or integer(GST_MESSAGE_EOS));
  // check why stoped
  if Msg.isCreated then
    begin
    fMsgResult:=Msg.MsgType;
      case MsgResult of
      GST_MESSAGE_EOS   : writeln('Gst message: End Of Stream');
      GST_MESSAGE_ERROR : writeln('Gst message: Error in stream');
      else writeln('Should never be here???');
      Msg.DisposeOf;
      end;
    end;
  end;
end;

const
NanoToMsec=int64(1000000);

function GstFrameWork.LaunchSimlpePipelineDoNotWait(params:string):boolean;
var
Msg:GMsg;
begin
Result:=StartLaunchSimlpePipeline(Params); //wait for error or EoS
if Result then
  TTask.Run(procedure
      begin
      Msg:=GMsg.Create(Bus,1*NanoToMsec,integer(GST_MESSAGE_ERROR) or integer(GST_MESSAGE_EOS));
      while not Msg.isCreated and (MsgResult<>GST_MESSAGE_ANY) do
      Msg:=GMsg.Create(Bus,100*NanoToMsec,integer(GST_MESSAGE_ERROR) or integer(GST_MESSAGE_EOS));
      if Msg.isCreated then
        begin
        fMsgResult:=Msg.MsgType;
        Msg.DisposeOf;
        end;
      end);
end;

end.

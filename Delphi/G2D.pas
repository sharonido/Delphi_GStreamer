{
This is a GStreamer 2 Delphi bridge unit
writen by I. Sharon Ltd.
for info goto xxx
}
unit G2D;

interface
uses
{$IFDEF MSWINDOWS}
Winapi.Windows,
{$ENDIF }
FMX.Dialogs,
System.Classes,System.SysUtils,System.Generics.Collections,System.Threading;
type

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

const
GST_CLOCK_TIME_NONE=-1;
// gst objects -----------------------------------------------------------------
Type
GPipeLine=Class;

GNoUnrefObject=class(tobject)  //odject that will not un_ref its RObject
  protected
  RObject:pointer; //pointer to the real gst memory (psedu object)
  public
  function isCreated:boolean;
  property RealObject:pointer read RObject;
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
End;

GObject=class(GNoUnrefObject)
  public
  Destructor Destroy; override;
end;

GBus=class(GObject)   //GBus<>GMes cause future will do diffrent properties
  public
  constructor Create(pipe:GPipeLine);
end;


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





Gst_Mes=record
  RMiniObj:_GstMiniObject;
  MType:GstMessageType;
end;
PGst_Mes=^Gst_Mes;

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

PCharArr=Array of ansistring;
PArrPChar=^PCharArr;   //for C: char *argv[];

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
//function DRunSimpleGst(param:string):Boolean ;
function DateToIso(DT:TDateTime):string;
implementation
//===========================================================================================

function DateToIso(DT:TDateTime):string;
begin
DateTimeToString(Result,'dd-MM-yyyy"T"hh:nn:ss',DT);
end;

Type

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
Tg_object_set_int =procedure (const plug:pointer; const param:ansistring; const val:integer); cdecl;
Tg_object_set_pchar =procedure (const plug:pointer; const param,val:ansistring); cdecl;

// Tido_add = function (const a:integer; const b:integer):integer; cdecl ;

Var
G2dDllHnd:HMODULE=0;

//The GST functions in G2D.dll
DSimpleRun                    :Tgst_funcPChars;
DgstInit                      :Tgst_voidPChars;
Dgst_pipeline_new             :Tgst_pipeline_new;
Dgst_object_unref             :Tgst_object_unref;
Dgst_element_get_bus          :Tgst_element_get_bus;
Dgst_element_factory_make     :Tgst_element_factory_make;
Dgst_bin_add                  :Tgst_bin_add;
Dgst_element_link             :Tgst_element_link;
Dgst_element_set_state        :Tgst_element_set_state;
Dgst_bus_timed_pop_filtered   :Tgst_bus_timed_pop_filtered;
Dgst_message_unref            :Tgst_message_unref;
Dg_object_set_int             :Tg_object_set_int;
Dg_object_set_pchar           :Tg_object_set_pchar;

DiTmp1,DiTmp2:Ppointer;
//------------------------------------------------------------------------------
function G2dDllLoaded:Boolean; inline;
begin
Result:=G2dDllHnd<>0;
end;
//-----------------------------------------------------------------------------
function G2dDllLoad:boolean;
const DllStr= 'C:\gstreamer\gst-docs-master\examples\tutorials\vs2010\x64\Debug\';  //the default for the DLL
  function setProcFromDll(var ref:pointer;const name:ansistring):boolean;
  begin
  ref := GetProcAddress(G2dDllHnd, pansichar(name));
  Result:=Ref=nil;
  if Result then  writeln(name+' procedure not found in DLL');
  end;
var
err:integer;
dllPath:string;
begin
err:=0;//just for warning void
if not G2dDllLoaded then
  begin
  Result:=false;
    try
    if FileExists(DllStr+'G2D.dll')   //for fast debuging
      then dllPath:=DllStr+'G2D.dll'
      else dllPath:='G2D.dll';

    G2dDllHnd := LoadLibrary(PWidechar(dllPath));
    err:=GetLastError;
    finally
    if (err<>0) or (G2dDllHnd=0) then
      begin
      G2dDllHnd:=0;
      writeln('Load Library-'+SysErrorMessage(err));
      end;
    end;
  if G2dDllHnd=0 then exit;

  setProcFromDll(pointer(DiTmp1),'iTmp1');   //for debuging
  setProcFromDll(pointer(DiTmp2),'iTmp2');   //for debuging

  // set procedures entery points in G2D.dll
  if setProcFromDll(@DSimpleRun,'run_gst') or
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
     setProcFromDll(@Dg_object_set_int,'Dg_object_set_int') or
     setProcFromDll(@Dg_object_set_pchar,'Dg_object_set_pchar')
       then exit;
  end;
Result:=true;
end;

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
//                  DRunSimpleGst
//------------------------------------------------------------------------------
(*
function DRunSimpleGst(param:string):Boolean ;
var
PlugStrs:TArray<string>;
PipeLine:GPipeLine;
Plug:GPlugIn;
Bus:GBus;
Msg:GMsg;
I:Integer;
ret:GstStateChangeReturn;
begin
Result:=false;
if G2dDllLoad then //check if G2D.dll was loaded, if not load it
  begin
  DgstInit(0,nil);  //init the gst framework
  // create a pipeline
  PipeLine:=GPipeLine.Create('Delphi PipeLine'); //delphi pipeline -just a name
  if not PipeLine.isCreated then
    begin
    writeln('Pipeline '+PipeLine.name+' was not created');
    exit;
    end;
  PlugStrs:=param.Split(['!']); //split param to the diffrent plugins that were ordered
  // create the needed plugins and add them to
  //the pipeline (they are still not connected to one another)
  for I := 0 to length(PlugStrs)-1 do
    begin
    Plug:=GPlugIn.Create(PlugStrs[i].trim,PlugStrs[i].trim);
    if not Plug.isCreated then
      begin
      writeln('Plug in  '+Plug.name+' was not created');
      exit;
      end;
    PipeLine.AddPlugIn(Plug);
    end;
  writeln('pipeline was built successfully');
  Plug:=PipeLine.SimpleLinkAll; //link the plugins one to the other
                                //(as a simple pipe - with nn branches)
  if plug<>nil then             //plug is the first that didn't link
    begin
    writeln('Plug '+plug.Name+' was not able to link');
    exit;
    end;
  writeln(length(PlugStrs).ToString+' plugins were successfully linked');

   //start play
  ret:=D_element_set_state(PipeLine,GstState.GST_STATE_PLAYING);
  if ret=GST_STATE_CHANGE_FAILURE then
    begin
    writeln('Could not start playing');
    PipeLine.DisposeOf;
    exit;
    end;
  // build a bus for the pipe line to check if stream had stoped
  Bus:=GBus.create(PipeLine);
  Msg:=GMsg.Create(Bus,GST_CLOCK_TIME_NONE,integer(GST_MESSAGE_ERROR) or integer(GST_MESSAGE_EOS));

  if Msg.isCreated then
    case Msg.MsgType of
    GST_MESSAGE_EOS   : writeln('Gst message: End Of Stream');
    GST_MESSAGE_ERROR : writeln('Gst message: Error in stream');
    else writeln('Should never be here???');
    Msg.DisposeOf;
    end;
  Bus.DisposeOf;
  D_element_set_state(PipeLine,GstState.GST_STATE_NULL);
  PipeLine.DisposeOf;

  result:=true;//DSimpleRun(length(PlugStrs),StringArrToCPpChar(PlugStrs,PlugNames,true))=0;
  end;
end;
*)
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
  end;
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

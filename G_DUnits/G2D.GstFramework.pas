unit G2D.GstFramework;

interface

uses
  System.SysUtils, Winapi.Windows, System.Classes,
  Vcl.Forms, Vcl.AppEvnts, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.StdCtrls,

  G2D.Glib.API,
  G2D.Gobject.API,
  G2D.Gst.API,
  G2D.GstMessage.DOO,
  G2D.GstBin.DOO,

  G2D.Gst.Types,
  G2D.Glib.Types,
  G2D.Gobject.Types,
  G2D.GstElement.DOO,
  G2D.GstPipeline.DOO,
  G2D.GstBus.DOO;

type
  EG2DGstFrameWork = class(Exception);

  TGstRunMode = (DoOnce, DoForEver);

  EG2DGstFrameworkError = class(Exception);

  PG2DDynamicPadLinkData = ^TG2DDynamicPadLinkData;
  TG2DDynamicPadLinkData = record
    Framework: Pointer;
    TargetElementName: string;
    TargetPadName: string;
  end;

  TGstFramework = class
  private
    FStarted: Boolean;
    FState:GstState;
    FTimer:TTimer;
    FDuration:int64;
    FPosition:int64;
    FWriteStateChange: Boolean;
    FPipeline: TGstPipelineRef;
    FBus: TGstBusRef;
    FAppEvents: TApplicationEvents;       // replaces Application.OnIdle hook

    FLastMessageType: GstMessageType;
    FLastErrorText: string;
    FLastDebugText: string;
    FReachedEOS: Boolean;
    FDynamicPadLinks: array of TG2DDynamicPadLinkData;

    class var fStringsLogger:TStrings;

    class procedure SetStringsLogger(m:TStrings);static;
    procedure ClearDynamicPadLinks;
    function AddDynamicPadLink(const ATargetElementName, ATargetPadName: string): Pointer;
    function LinkIncomingPadToElement(ANewPad: PGstPad;
      const ATargetElementName: string; const ATargetPadName: string = 'sink'): Boolean;

    class procedure cb_pad_added(src: PGstElement; new_pad: PGstPad; user_data: gpointer); cdecl; static;
    procedure CheckStarted;
    procedure ClearPipeline;
    function GetState: GstState;

    procedure AppIdle(Sender: TObject; var Done: Boolean);
    procedure FTimer100mSecOnPlay(Sender:TObject);

  public
    constructor Create(WriteStateChange: Boolean = False);
    destructor Destroy; override;

    function NativeBuildAndPlay(const APipelineDescription: string): Boolean;
    function SimpleNativeBuildAndPlay(const APipelineDescription: string;
      ARunMode: TGstRunMode): Boolean;
    function BuildAndPlay(const APipelineDescription: string): Boolean;
    function SetVisualWindow(const AElementName: string; AWnd: HWnd): Boolean;

    function RunFor(ATimeout: GstClockTime): Boolean;
    function FindElement(const AName: string): TGstElementRef;

    function HasError: Boolean;
    function HasEOS: Boolean;

    { pipeline state control }
    function Play:  Boolean;   // GST_STATE_PLAYING
    function Pause: Boolean;   // GST_STATE_PAUSED
    function Ready: Boolean;   // GST_STATE_READY
    function Null:  Boolean;   // GST_STATE_NULL
    procedure Close;           // tears down & frees the pipeline

    { additions / delegation to TGstPipelineRef }
    function NewPipeline(const AName: string): Boolean;
    procedure MakeElements(const ADescription: string);
    function MakeElement(const AFactory, AName: string): TGstElementRef;
    function GetElement(const AName: string): TGstElementRef;
    function AddElement(const AName: string): Boolean;
    function AddElements(const ANames: array of string): Boolean;
    function LinkElements(const AFromName, AToName: string): Boolean;
    function LinkMany(const ANames: array of string): Boolean;
    procedure SetElementPropertyString(const AElementName, APropName, AValue: string);
    procedure SetElementPropertyInt(const AElementName, APropName: string; AValue: Integer);
    procedure SetElementPropertyBool(const AElementName, APropName: string; AValue: Boolean);
    procedure SetElementPropertyFloat(const AElementName, APropName: string; AValue: Single);  { Tutorial 7 }
    procedure SetElementPropertyCaps(const AElementName, APropName: string; ACaps: gpointer);  { Tutorial 8 }
    function ConnectElementSignal(const AElementName, ASignalName: string;
      ACallback: Pointer; AUserData: Pointer = nil): Boolean;
    function ConnectDynamicPad(const ASourceElementName, ATargetElementName: string;
      const ATargetPadName: string = 'sink'): Boolean;
    function QueryPosition(out APosition: gint64;
      AFormat: GstFormat = GST_FORMAT_TIME): Boolean;
    function QueryDuration(out ADuration: gint64;
      AFormat: GstFormat = GST_FORMAT_TIME): Boolean;
    function SeekSimple(ASeekPos: gint64;
      AFormat: GstFormat; ASeekFlags: GstSeekFlags): Boolean;

    property Started: Boolean read FStarted;
    property LastErrorText: string read FLastErrorText;
    property LastDebugText: string read FLastDebugText;
    property LastMessageType: GstMessageType read FLastMessageType;
    property ReachedEOS: Boolean read FReachedEOS;
    property State: GstState read FState;
    property PipeLine: TGstPipelineRef read FPipeLine;

    property Duration: int64 read FDuration;
    property Position: int64 read FPosition;

    class property StringsLogger: TStrings read fStringsLogger write SetStringsLogger;
  end;

function GstClockTimeToStr(ATime:int64):string;

procedure stdWrite(st:string);
procedure LogWriteln(st:string);

var
  LogWrite: procedure(st:string) = stdWrite;

//=============================================================================
implementation

procedure stdWrite(st:string);
begin   //needs to be called not only from main thread
TThread.Queue(nil,
    procedure
    begin
      write(st);
    end);
end;

procedure LogWriteln(st:string);
begin
  if Assigned(LogWrite) then
    LogWrite(st + sLineBreak);
end;

function GstClockTimeToStr(ATime: int64): string;
var
  TotalMs  : UInt64;
  Hours    : UInt64;
  Minutes  : UInt64;
  Seconds  : UInt64;
  Milisec  : UInt64;
begin
  if (ATime = GST_CLOCK_TIME_NONE) or (ATime < 0) then
    Exit('--:--:--.---');

  TotalMs := uint64(ATime) div GST_MSECOND;

  Milisec := TotalMs mod 1000;
  Seconds := (TotalMs div 1000) mod 60;
  Minutes := (TotalMs div 60000) mod 60;
  Hours   := (TotalMs div 3600000);

  Result := Format('%d:%.2d:%.2d.%.3d', [Hours, Minutes, Seconds, Milisec]);
end;

{help for finding GST_PLUGIN_PATH}
procedure ConfigureGStreamerPluginSearchPath;
var
  Dir, ParentDir, PluginDir: string;
begin
  Dir := ExcludeTrailingPathDelimiter(ExtractFilePath(GetModuleName(HInstance)));
  repeat
    PluginDir := Dir + '\DLLs\lib\gstreamer-1.0';
    if DirectoryExists(PluginDir) then
    begin
      SetEnvironmentVariable('GST_PLUGIN_PATH', PChar(PluginDir));
      Exit;
    end;
    ParentDir := ExcludeTrailingPathDelimiter(ExtractFilePath(Dir));
    if ParentDir = Dir then
      raise EG2DAPILoaderError.Create('GStreamer plugin path not found: lib\gstreamer-1.0 not found in any parent directory');
    Dir := ParentDir;
  until False;
end;
{ TGstFramework }

constructor TGstFramework.Create(WriteStateChange: Boolean = False);
begin
  inherited Create;
  FWriteStateChange := WriteStateChange;
  FStarted := False;
  FTimer := TTimer.Create(nil);
  FTimer.Interval := 100;
  FTimer.OnTimer := FTimer100mSecOnPlay;
  FTimer.Enabled := True;
  FDuration := -1;
  FState := GST_STATE_NULL;
  FPipeline := nil;
  FBus := nil;
  FAppEvents := nil;
  FLastMessageType := 0;
  FLastErrorText := '';
  FLastDebugText := '';
  FReachedEOS := False;

  if not G2D_LoadGlib then
    raise EG2DGstFrameworkError.Create('GLib load failed');

  if not G2D_LoadGobject then
    raise EG2DGstFrameworkError.Create('GObject load failed');

  if not G2D_LoadGst then
    raise EG2DGstFrameworkError.Create('GStreamer load failed');

  If not NormalGstSearch then
    ConfigureGStreamerPluginSearchPath;
  {debug
  SetEnvironmentVariable('GST_DEBUG', 'GST_PLUGIN_LOADING:5');
  SetEnvironmentVariable('GST_DEBUG_FILE', 'C:\Temp\gst_debug.log');
  {}

  _gst_init(nil, nil);

  if _gst_is_initialized() = 0 then
    raise EG2DGstFrameworkError.Create('GStreamer initialization failed');

  SetLength(FDynamicPadLinks, 0);

  // Hook into the VCL idle loop safely - TApplicationEvents chains with
  // any other OnIdle handlers already registered in the application.
  if Assigned(Application) then
  begin
    FAppEvents := TApplicationEvents.Create(nil);
    FAppEvents.OnIdle := AppIdle;
  end;

  FStarted := True;
end;

destructor TGstFramework.Destroy;
begin
  FreeAndNil(FAppEvents);
  FreeAndNil(FTimer);
  try
    Close;
  finally
    inherited;
  end;
end;

//writing to log in memo
procedure GstWriteLog(st: string);
begin
  with TGstFrameWork do
    if Assigned(fStringsLogger) then TThread.Queue(nil,
    //needs to be called not only from main thread
    procedure
    begin
      if fStringsLogger.Count = 0 then
        fStringsLogger.Add(st)
      else
        fStringsLogger[fStringsLogger.Count - 1] :=
          fStringsLogger[fStringsLogger.Count - 1] + st;
    end);
end;

procedure DoNullWrite(st: string);
begin
  // do nothing
end;

class procedure TGstFrameWork.SetStringsLogger(m: TStrings);
begin
  if Assigned(m) and Assigned(Application) then
  begin
    fStringsLogger := m;
    LogWrite := GstWriteLog; // re-route activity log to the memo instead of console
  end
  else if Assigned(Application) then
    LogWrite := DoNullWrite
  else
    LogWrite := stdWrite;
end;

var DCnt:integer=0;    { TODO : remove }
procedure TGstFramework.AppIdle(Sender: TObject; var Done: Boolean);
begin
Inc(DCnt);
  RunFor(0);
end;

function TGstFramework.NewPipeline(const AName: string): Boolean;
begin
  CheckStarted;
  ClearPipeline;

  FPipeline := TGstPipelineRef.New(AName);
  if FPipeline = nil then
    Exit(False);

  FBus := FPipeline.GetBus;
  Result := FBus <> nil;
end;

procedure TGstFramework.CheckStarted;
begin
  if not FStarted then
    raise EG2DGstFrameworkError.Create('Framework not started');
end;

procedure TGstFramework.ClearDynamicPadLinks;
begin
  SetLength(FDynamicPadLinks, 0);
end;

procedure TGstFramework.ClearPipeline;
begin
  if FBus <> nil then
  begin
    FBus.Free;
    FBus := nil;
  end;

  if FPipeline <> nil then
  begin
    try
      FPipeline.Null;
    except
    end;

    FPipeline.Free;
    FPipeline := nil;
  end;

  FLastMessageType := 0;
  FLastErrorText := '';
  FLastDebugText := '';
  FReachedEOS := False;
  ClearDynamicPadLinks;
end;

function TGstFramework.GetState: GstState;
begin
  Result := GST_STATE_NULL;
  if FPipeline = nil then
    Exit;
  Result := TGstElementRef(FPipeline).GetState;
  FState := Result;
end;

{ pipeline state control }

function TGstFramework.Play: Boolean;
begin
  Result := (FPipeline <> nil) and
            (FPipeline.Play <> GST_STATE_CHANGE_FAILURE);
end;

function TGstFramework.Pause: Boolean;
begin
  Result := (FPipeline <> nil) and (State<>GST_STATE_PAUSED) and
            (FPipeline.Pause <> GST_STATE_CHANGE_FAILURE);
end;

function TGstFramework.Ready: Boolean;
begin
  Result := (FPipeline <> nil) and
            (FPipeline.Ready <> GST_STATE_CHANGE_FAILURE);
end;

function TGstFramework.Null: Boolean;
begin
  Result := (FPipeline <> nil) and
            (FPipeline.Null <> GST_STATE_CHANGE_FAILURE);
end;

procedure TGstFramework.Close;
begin
  ClearPipeline;
end;

function TGstFramework.AddDynamicPadLink(const ATargetElementName,
  ATargetPadName: string): Pointer;
var
  L: Integer;
begin
  L := Length(FDynamicPadLinks);
  SetLength(FDynamicPadLinks, L + 1);

  FDynamicPadLinks[L].Framework := Self;
  FDynamicPadLinks[L].TargetElementName := ATargetElementName;
  FDynamicPadLinks[L].TargetPadName := ATargetPadName;

  Result := @FDynamicPadLinks[L];
end;

function TGstFramework.LinkIncomingPadToElement(ANewPad: PGstPad;
  const ATargetElementName: string; const ATargetPadName: string): Boolean;
var
  TargetElem: TGstElementRef;
  SinkPad: PGstPad;
  Ret: GstPadLinkReturn;
  LPadName: UTF8String;
begin
  Result := False;

  if ANewPad = nil then
    Exit;

  TargetElem := FindElement(ATargetElementName);
  try
    if TargetElem = nil then
      EG2DGstFrameWork.Create('Target element not found');

    LPadName := UTF8String(ATargetPadName);

    SinkPad := _gst_element_get_static_pad(
                 TargetElem.ElementHandle,
                 Pgchar(PAnsiChar(LPadName))
               );
    if SinkPad = nil then
      EG2DGstFrameWork.Create('Failed to get target sink pad');

    try
      if _gst_pad_is_linked(SinkPad) <> 0 then
      begin
        LogWriteln('Already linked. Ignoring.');
        Exit(True);
      end;

      Ret := _gst_pad_link(ANewPad, SinkPad);

      if Ret = GST_PAD_LINK_OK then
      begin
        LogWriteln('Pad link succeeded');
        Result := True;
      end
      else
      begin
        Result := False;
        EG2DGstFrameWork.Create('Pad link failed with Pad status: ' + GstPadLinkReturn2Str(Ret));
      end;
    finally
      _gst_object_unref(SinkPad);
    end;
  finally
    TargetElem.Free;
  end;
end;

class procedure TGstFramework.cb_pad_added(src: PGstElement; new_pad: PGstPad;
  user_data: gpointer);
var
  Data: PG2DDynamicPadLinkData;
  FW: TGstFramework;
begin
  if user_data = nil then
    Exit;

  Data := PG2DDynamicPadLinkData(user_data);
  FW := TGstFramework(Data^.Framework);

  if FW = nil then
    Exit;

  if FW.LinkIncomingPadToElement(new_pad, Data^.TargetElementName, Data^.TargetPadName) then
    LogWriteln(Data^.TargetElementName + ' Received new pad ');
end;

function TGstFramework.ConnectDynamicPad(const ASourceElementName,
  ATargetElementName: string; const ATargetPadName: string): Boolean;
var
  UserData: Pointer;
begin
  Result := False;

  if FPipeline = nil then
    Exit;

  UserData := AddDynamicPadLink(ATargetElementName, ATargetPadName);

  Result := ConnectElementSignal(
              ASourceElementName,
              'pad-added',
              @TGstFramework.cb_pad_added,
              UserData
            );
end;

function TGstFramework.BuildAndPlay(const APipelineDescription: string): Boolean;
var
  Pipeline: TGstPipelineRef;
  Bus: TGstBusRef;
  Ret: GstStateChangeReturn;
begin
  CheckStarted;
  ClearPipeline;
  //MakeElements(APipelineDescription);         { TODO : open and build }
  Result:=NativeBuildAndPlay(APipelineDescription);
end;
function TGstFramework.NativeBuildAndPlay(const APipelineDescription: string): Boolean;
var
  Pipeline: TGstPipelineRef;
  Bus: TGstBusRef;
  Ret: GstStateChangeReturn;
begin
  CheckStarted;
  ClearPipeline;

  Pipeline := TGstPipelineRef.Parse(APipelineDescription);
  if Pipeline = nil then
    raise EG2DGstFrameworkError.Create('Failed to build pipeline');

  Bus := Pipeline.GetBus;
  if Bus = nil then
  begin
    Pipeline.Free;
    raise EG2DGstFrameworkError.Create('Failed to get bus');
  end;

  FPipeline := Pipeline;
  FBus := Bus;

  Ret := Pipeline.Play;
  if Ret = GST_STATE_CHANGE_FAILURE then
    raise EG2DGstFrameworkError.Create('Failed to set PLAYING');

  Result := True;
end;

function TGstFramework.SetVisualWindow(const AElementName: string;
  AWnd: HWnd): Boolean;
var
  Elem: TGstElementRef;
begin
  Result := False;

  Elem := FindElement(AElementName);
  try
    if Elem = nil then
      Exit;

    Elem.SetWindowHandle(AWnd);
    Result := True;
  finally
    Elem.Free;
  end;
end;

function TGstFramework.SimpleNativeBuildAndPlay(
  const APipelineDescription: string;
  ARunMode: TGstRunMode
): Boolean;
begin
  Result := NativeBuildAndPlay(APipelineDescription);

  if not Result then
    raise EG2DGstFrameworkError.Create('Failed to NativeBuildAndPlay');

  if ARunMode = DoOnce then
    Exit(True);

  while RunFor(100 * GST_MSECOND) do;  // run until error or EOS

  Result := FLastErrorText = '';
end;

function TGstFramework.RunFor(ATimeout: GstClockTime): Boolean;
var
  Msg         : TGstMessageRef;
  ErrMsg      : string;
  DebugMsg    : string;
  LTimeout    : GstClockTime;
begin
  Result := True;

  if FBus = nil then
    Exit;

  { First pop uses the caller's timeout; subsequent pops are non-blocking
    (timeout=0) to drain all queued messages without extra waiting. }
  LTimeout := ATimeout;
  Msg := nil;
  while True do
  try
    Msg := FBus.TimedPopMessage(
             LTimeout,
             GST_MESSAGE_ERROR or
             GST_MESSAGE_EOS or
             GST_MESSAGE_STATE_CHANGED
           );
    LTimeout := 0;  { non-blocking for all subsequent iterations }

    if Msg = nil then
      Exit;
    { for debugging
    LogWriteln('Bus msg type: ' + IntToStr(Integer(Msg.MessageType)) +
       '  from: ' + string(UTF8String(AnsiString(
       _gst_object_get_name(Msg.MessageHandle.src)))));
     }
    FLastMessageType := Msg.MessageType;

    if Msg.IsStateChanged then
      if (Msg.MessageHandle.src = PGstObject(FPipeline.PipelineHandle)) then
      begin
        GetState;
        if FWriteStateChange then
          LogWriteln('Message: ' + Msg.MessageTypeName + '  ' + Msg.StateChangedToText);
      end;

    if Msg.IsError then
    begin
      Msg.ParseError(ErrMsg, DebugMsg);

      FLastErrorText := ErrMsg;
      FLastDebugText := DebugMsg;

      LogWriteln('=== ERROR ===');
      LogWriteln('Error : ' + ErrMsg);

      if DebugMsg <> '' then
        LogWriteln('Debug : ' + DebugMsg);

      Result := False;
      Exit;
    end;

    if Msg.IsEOS then
    begin
      FReachedEOS := True;
      Result := False;
      Exit;
    end;

  finally
    Msg.Free;
  end;
end;

function TGstFramework.FindElement(const AName: string): TGstElementRef;
begin
  if FPipeline = nil then
    Exit(nil);

  Result := FPipeline.GetByName(AName);
  if (Result = nil) and (PipeLine.GetName = AName) then
    Result := TGstElementRef.Wrap(PGstElement(FPipeline.PipelineHandle),
                True,   // addref - because caller will Free this wrapper
                True);
end;

var
  OnceDuration: Boolean = True;

procedure TGstFramework.FTimer100mSecOnPlay(Sender: TObject);
begin
  if State = GST_STATE_PLAYING then
  begin
    if OnceDuration and not QueryDuration(FDuration) then
      FDuration := -1;
    if FDuration <> -1 then
    begin
      OnceDuration := False;
      if not QueryPosition(FPosition) then
        FPosition := 0;
    end;
  end
  else
  begin
    OnceDuration := True;
    if State = GST_STATE_READY then
    begin
      FDuration := -1;
      FPosition := 0;
    end;
  end;
end;

function TGstFramework.HasError: Boolean;
begin
  Result := FLastErrorText <> '';
end;

function TGstFramework.HasEOS: Boolean;
begin
  Result := FReachedEOS;
end;

procedure TGstFramework.MakeElements(const ADescription: string);
begin
  if FPipeline <> nil then
    FPipeline.MakeElements(ADescription);
end;

function TGstFramework.MakeElement(const AFactory, AName: string): TGstElementRef;
begin
  if FPipeline = nil then
    Exit(nil);

  Result := FPipeline.MakeElement(AFactory, AName);
end;

function TGstFramework.GetElement(const AName: string): TGstElementRef;
begin
  if FPipeline = nil then
    Exit(nil);

  Result := FPipeline.GetElement(AName);
end;

function TGstFramework.AddElement(const AName: string): Boolean;
begin
  if FPipeline = nil then
    Exit(False);

  Result := FPipeline.AddElement(AName);
end;

function TGstFramework.AddElements(const ANames: array of string): Boolean;
begin
  if FPipeline = nil then
    Exit(False);

  Result := FPipeline.AddElements(ANames);
end;

function TGstFramework.LinkElements(const AFromName, AToName: string): Boolean;
begin
  if FPipeline = nil then
    Exit(False);

  Result := FPipeline.LinkElements(AFromName, AToName);
end;

function TGstFramework.LinkMany(const ANames: array of string): Boolean;
begin
  if FPipeline = nil then
    Exit(False);

  Result := FPipeline.LinkMany(ANames);
end;

procedure TGstFramework.SetElementPropertyString(const AElementName, APropName,
  AValue: string);
begin
  if FPipeline = nil then
    raise EG2DGstFrameworkError.Create('Pipeline is nil');

  FPipeline.SetPropertyString(AElementName, APropName, AValue);
end;

procedure TGstFramework.SetElementPropertyInt(const AElementName,
  APropName: string; AValue: Integer);
begin
  if FPipeline = nil then
    raise EG2DGstFrameworkError.Create('Pipeline is nil');

  FPipeline.SetPropertyInt(AElementName, APropName, AValue);
end;

procedure TGstFramework.SetElementPropertyBool(const AElementName,
  APropName: string; AValue: Boolean);
begin
  if FPipeline = nil then
    raise EG2DGstFrameworkError.Create('Pipeline is nil');

  FPipeline.SetPropertyBool(AElementName, APropName, AValue);
end;

procedure TGstFramework.SetElementPropertyFloat(const AElementName,
  APropName: string; AValue: Single);
begin
  if FPipeline = nil then
    raise EG2DGstFrameworkError.Create('Pipeline is nil');

  FPipeline.SetPropertyFloat(AElementName, APropName, AValue);
end;

procedure TGstFramework.SetElementPropertyCaps(const AElementName,
  APropName: string; ACaps: gpointer);
begin
  if FPipeline = nil then
    raise EG2DGstFrameworkError.Create('Pipeline is nil');

  FPipeline.SetPropertyCaps(AElementName, APropName, ACaps);
end;

function TGstFramework.ConnectElementSignal(const AElementName,
  ASignalName: string; ACallback: Pointer; AUserData: Pointer): Boolean;
begin
  if FPipeline = nil then
    Exit(False);

  Result := FPipeline.ConnectSignal(AElementName, ASignalName, ACallback, AUserData);
end;

function TGstFramework.QueryPosition(out APosition: gint64;
  AFormat: GstFormat): Boolean;
begin
  APosition := 0;

  if FPipeline = nil then
    Exit(False);

  Result := _gst_element_query_position(
              PGstElement(FPipeline.PipelineHandle),
              AFormat,
              @APosition
            ) <> 0;
end;

function TGstFramework.QueryDuration(out ADuration: gint64;
  AFormat: GstFormat): Boolean;
begin
  ADuration := 0;

  if FPipeline = nil then
    Exit(False);

  Result := _gst_element_query_duration(
              PGstElement(FPipeline.PipelineHandle),
              AFormat,
              @ADuration
            ) <> 0;
end;

function TGstFramework.SeekSimple(ASeekPos: gint64;
  AFormat: GstFormat; ASeekFlags: GstSeekFlags): Boolean;
begin
  if FPipeline = nil then
    Exit(False);

  Result := _gst_element_seek_simple(
              PGstElement(FPipeline.PipelineHandle),
              AFormat,
              ASeekFlags,
              ASeekPos
            ) <> 0;
end;

end.

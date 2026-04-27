unit G2D.CustomSimpleVideoElement;

{------------------------------------------------------------------------------
  G2D.VideoCustomSimpleElement
  Phase 1 video filter - derives from TGstSimpleBase and adds video geometry.

  Overrides ProcessBuffer internally to build GstVideoFrame wrappers and
  call ProcessFrame with friendly per-plane pixel access.

  Usage:
    1. Derive from TGstVideoSimple.
    2. Override GetSinkCaps to constrain the input format (optional).
    3. Override ProcessFrame to do your image processing.
    4. Optionally override OnCapsChanged to react to format changes.
    5. Call AddToPipeline then Play.
    6. FreeAndNil(FFilter) before FreeAndNil(FGStreamer) in FormDestroy.

  Threading:
    ProcessFrame fires on a GStreamer streaming thread, NOT the main thread.
    Do NOT access VCL controls directly. Use TThread.Queue for UI updates.
------------------------------------------------------------------------------}

interface

uses
  System.SysUtils,
  System.SyncObjs,
  G2D.Glib.Types,
  G2D.Gst.Types,
  G2D.Gst.API,
  G2D.GstElement.DOO,
  G2D.GstBin.DOO,
  G2D.GstFramework,
  G2D.CustomSimpleBaseElement;

type
  EG2DVideoSimpleError = class(Exception);
  TGetVideoSinkCapsEvent = function(Sender: TObject): string of object;
  TProcessVideoFrameEvent = function(Sender: TObject;
    const AIn: GstVideoFrame; const AInfo: GstVideoInfo;
    var AOut: GstVideoFrame): Boolean of object;

{==============================================================================
  TGstVideoSimple
  Video filter base class. Derives from TGstSimpleBase and adds:
  - Caps parsing into GstVideoInfo (width, height, format, stride, fps)
  - GstVideoFrame wrappers around the mapped buffers
  - ProcessFrame virtual with full video geometry available

  Override ProcessFrame to manipulate pixel data. AIn and AOut give you
  per-plane data pointers and the full GstVideoInfo for format details.
==============================================================================}
  TGstVideoSimple = class(TGstSimpleBase)
  private
    FVideoInfo    : GstVideoInfo;
    FHasVideoInfo : Boolean;
    FLastCaps     : PGstCaps;

    function UpdateVideoInfo(ACaps: PGstCaps): Boolean;

  protected
    { Called on the streaming thread when caps change (first frame or
      format change). AInfo contains width/height/format/fps/stride.
      Override to allocate format-specific resources. }
    procedure OnCapsChanged(ACaps: PGstCaps); override; final;
    procedure OnVideoInfoChanged(const AInfo: GstVideoInfo); virtual;

    { THE override point. Called on the streaming thread for every frame.
      AIn  : input  frame (GST_MAP_READ)  - read pixel data via AIn.data[0]
      AOut : output frame (GST_MAP_WRITE) - write pixel data via AOut.data[0]
      AInfo: video geometry (width, height, format, fps, stride)
      Return True to push AOut downstream; False to drop the frame.
      Default: memcopy passthrough. }
    function ProcessFrame(const AIn: GstVideoFrame;
      const AInfo: GstVideoInfo;
      var AOut: GstVideoFrame): Boolean; virtual;

    { Override of base ProcessBuffer - builds GstVideoFrames and calls
      ProcessFrame. Do NOT override this in video subclasses. }
    function ProcessBuffer(const AMapIn: GstMapInfo;
      var AMapOut: GstMapInfo): Boolean; override; final;

  public
    constructor Create(AFramework: TGstFramework);

    { Read-only access to current video geometry (valid after first frame) }
    property VideoInfo: GstVideoInfo read FVideoInfo;
    property HasVideoInfo: Boolean read FHasVideoInfo;
  end;

  TG2DVideoFilterRef = class(TGstVideoSimple)
  private
    FBin             : TGstBinRef;
    FPreConvert      : TGstElementRef;
    FPostConvert     : TGstElementRef;
    FBinName         : string;
    FAddedToPipeline : Boolean;
    FOnGetSinkCaps   : TGetVideoSinkCapsEvent;
    FOnProcessFrame  : TProcessVideoFrameEvent;
    procedure SetOnGetSinkCaps(const Value: TGetVideoSinkCapsEvent);
    procedure SetOnProcessFrame(const Value: TProcessVideoFrameEvent);

    class function NextFilterName: string; static;
    class function MakeManagedElement(const AFactory, AName: string): TGstElementRef; static;
    procedure BuildManagedChain;
    procedure CreateGhostPads;
    procedure ApplyManagedSinkCaps;

  protected
    function GetSinkCaps: string; override;
    function ProcessFrame(const AIn: GstVideoFrame;
      const AInfo: GstVideoInfo;
      var AOut: GstVideoFrame): Boolean; override;

  public
    constructor Create(AFramework: TGstFramework; const AName: string = '');
    destructor Destroy; override;

    procedure AddToPipeline; override;
    procedure AddAndLink(const AUpstream, ADownstream: string); override;
    procedure Shutdown; override;

    property BinName: string read FBinName;
    property OnGetSinkCaps: TGetVideoSinkCapsEvent read FOnGetSinkCaps write SetOnGetSinkCaps;
    property OnProcessFrame: TProcessVideoFrameEvent read FOnProcessFrame write SetOnProcessFrame;
  end;

  TGstVideoSimpleFilter = class(TG2DVideoFilterRef)
  end;

  TGstFrameworkVideoFilterHelper = class helper for TGstFramework
    function FindVideoFilter(const AName: string): TG2DVideoFilterRef;
  end;

implementation

var
  GVideoFilterCounter: Integer = -1;

function CreateManagedVideoFilter(AFramework: TGstFramework;
  const AName: string): TObject;
begin
  Result := TG2DVideoFilterRef.Create(AFramework, AName);
  TG2DVideoFilterRef(Result).AddToPipeline;
end;

{==============================================================================
  TGstVideoSimple
==============================================================================}

constructor TGstVideoSimple.Create(AFramework: TGstFramework);
begin
  inherited Create(AFramework);
  FHasVideoInfo := False;
  FLastCaps     := nil;
end;

{ Intercepts OnCapsChanged from base, parses GstVideoInfo, then calls
  OnVideoInfoChanged so the subclass gets a friendly typed notification. }
procedure TGstVideoSimple.OnCapsChanged(ACaps: PGstCaps);
begin
  if UpdateVideoInfo(ACaps) then
    OnVideoInfoChanged(FVideoInfo);
end;

procedure TGstVideoSimple.OnVideoInfoChanged(const AInfo: GstVideoInfo);
begin
  { Default: no-op. Subclass overrides to react to format changes. }
end;

function TGstVideoSimple.ProcessFrame(const AIn: GstVideoFrame;
  const AInfo: GstVideoInfo; var AOut: GstVideoFrame): Boolean;
begin
  { Default passthrough: copy entire frame in one Move. }
  if (AIn.map[0].data <> nil) and (AOut.map[0].data <> nil)
    and (AIn.map[0].size > 0) then
    Move(AIn.map[0].data^, AOut.map[0].data^, AIn.map[0].size);
  Result := True;
end;

function TGstVideoSimple.ProcessBuffer(const AMapIn: GstMapInfo;
  var AMapOut: GstMapInfo): Boolean;
var
  LInfo     : GstVideoInfo;
  LFrameIn  : GstVideoFrame;
  LFrameOut : GstVideoFrame;
begin
  Result := False;

  if not FHasVideoInfo then
    Exit;

  { Snapshot video info under lock is not needed here - UpdateVideoInfo
    is called from OnCapsChanged which fires before ProcessBuffer on the
    same streaming thread. A plain copy is safe. }
  LInfo := FVideoInfo;

  FillChar(LFrameIn,  SizeOf(LFrameIn),  0);
  FillChar(LFrameOut, SizeOf(LFrameOut), 0);

  LFrameIn.info    := LInfo;
  LFrameIn.data[0] := AMapIn.data;
  LFrameIn.map[0]  := AMapIn;

  LFrameOut.info    := LInfo;
  LFrameOut.data[0] := AMapOut.data;
  LFrameOut.map[0]  := AMapOut;

  Result := ProcessFrame(LFrameIn, LInfo, LFrameOut);
end;

{ --- Private ---------------------------------------------------------------- }

function TGstVideoSimple.UpdateVideoInfo(ACaps: PGstCaps): Boolean;
var
  LNewInfo : GstVideoInfo;
begin
  Result := False;
  if ACaps = nil then
    Exit;

  _gst_video_info_init(@LNewInfo);
  if _gst_video_info_from_caps(@LNewInfo, ACaps) = 0 then
    Exit;

  { Detect real change by comparing key fields }
  if FHasVideoInfo                          and
     (LNewInfo.width  = FVideoInfo.width)   and
     (LNewInfo.height = FVideoInfo.height)  and
     (LNewInfo.finfo  = FVideoInfo.finfo)   then
    Exit;

  FVideoInfo    := LNewInfo;
  FHasVideoInfo := True;
  Result        := True;
end;

{ TG2DVideoFilterRef }

class function TG2DVideoFilterRef.NextFilterName: string;
var
  LID: Integer;
begin
  LID := TInterlocked.Increment(GVideoFilterCounter);
  Result := Format('G2DVideoFilter%d', [LID]);
end;

class function TG2DVideoFilterRef.MakeManagedElement(const AFactory,
  AName: string): TGstElementRef;
begin
  Result := TGstElementRef.FactoryMake(AFactory, AName);
  if Result = nil then
    raise EG2DVideoSimpleError.CreateFmt(
      'Failed to create managed video filter element: %s (%s)',
      [AName, AFactory]);
end;

constructor TG2DVideoFilterRef.Create(AFramework: TGstFramework; const AName: string);
begin
  inherited Create(AFramework);
  if AName <> '' then
    FBinName := AName
  else
    FBinName := NextFilterName;
  BuildManagedChain;
end;

destructor TG2DVideoFilterRef.Destroy;
begin
  FreeAndNil(FPostConvert);
  FreeAndNil(FPreConvert);
  FreeAndNil(FBin);
  inherited;
end;

procedure TG2DVideoFilterRef.BuildManagedChain;
var
  LNameUtf8 : UTF8String;
  LBinHandle: PGstElement;
begin
  LNameUtf8  := UTF8String(FBinName);
  LBinHandle := _gst_bin_new(Pgchar(PAnsiChar(LNameUtf8)));
  if LBinHandle = nil then
    raise EG2DVideoSimpleError.CreateFmt(
      'Failed to create TGstVideoSimpleFilter bin: %s', [FBinName]);

  FBin := TGstBinRef.Wrap(PGstBin(LBinHandle), False, True);

  FPreConvert  := MakeManagedElement('videoconvert', FBinName + '_pre_convert');
  FPostConvert := MakeManagedElement('videoconvert', FBinName + '_post_convert');

  if not FBin.Add(FPreConvert) then
    raise EG2DVideoSimpleError.Create('Failed to add pre-convert to managed video filter bin');
  if not FBin.Add(FSink.ElementHandle) then
    raise EG2DVideoSimpleError.Create('Failed to add appsink to managed video filter bin');
  if not FBin.Add(FSrc.ElementHandle) then
    raise EG2DVideoSimpleError.Create('Failed to add appsrc to managed video filter bin');
  if not FBin.Add(FPostConvert) then
    raise EG2DVideoSimpleError.Create('Failed to add post-convert to managed video filter bin');

  if not FPreConvert.Link(FSink.ElementHandle) then
    raise EG2DVideoSimpleError.Create('Failed to link pre-convert -> appsink');
  if not FSrc.Link(FPostConvert) then
    raise EG2DVideoSimpleError.Create('Failed to link appsrc -> post-convert');

  CreateGhostPads;
end;

procedure TG2DVideoFilterRef.CreateGhostPads;
var
  LTargetPad : PGstPad;
  LGhostPad  : PGstPad;
  LPadName   : UTF8String;
begin
  LPadName := UTF8String('sink');
  LTargetPad := FPreConvert.GetStaticPad('sink');
  if LTargetPad = nil then
    raise EG2DVideoSimpleError.Create('Failed to get managed video filter sink pad');
  try
    LGhostPad := _gst_ghost_pad_new(Pgchar(PAnsiChar(LPadName)), LTargetPad);
    if LGhostPad = nil then
      raise EG2DVideoSimpleError.Create('Failed to create managed video filter ghost sink pad');
    if _gst_element_add_pad(FBin.ElementHandle, LGhostPad) = 0 then
      raise EG2DVideoSimpleError.Create('Failed to add managed video filter ghost sink pad');
  finally
    _gst_object_unref(gpointer(LTargetPad));
  end;

  LPadName := UTF8String('src');
  LTargetPad := FPostConvert.GetStaticPad('src');
  if LTargetPad = nil then
    raise EG2DVideoSimpleError.Create('Failed to get managed video filter src pad');
  try
    LGhostPad := _gst_ghost_pad_new(Pgchar(PAnsiChar(LPadName)), LTargetPad);
    if LGhostPad = nil then
      raise EG2DVideoSimpleError.Create('Failed to create managed video filter ghost src pad');
    if _gst_element_add_pad(FBin.ElementHandle, LGhostPad) = 0 then
      raise EG2DVideoSimpleError.Create('Failed to add managed video filter ghost src pad');
  finally
    _gst_object_unref(gpointer(LTargetPad));
  end;
end;

procedure TG2DVideoFilterRef.ApplyManagedSinkCaps;
var
  LCapsStr  : string;
  LCapsUtf8 : UTF8String;
  LCaps     : PGstCaps;
begin
  LCapsStr := GetSinkCaps;
  if LCapsStr = '' then
    Exit;

  LCapsUtf8 := UTF8String(LCapsStr);
  LCaps := _gst_caps_from_string(Pgchar(PAnsiChar(LCapsUtf8)));
  if LCaps = nil then
    Exit;
  try
    FSink.SetCaps(LCaps);
  finally
    _gst_caps_unref(LCaps);
  end;
end;

function TG2DVideoFilterRef.GetSinkCaps: string;
begin
  if Assigned(FOnGetSinkCaps) then
    Result := FOnGetSinkCaps(Self)
  else
    Result := inherited GetSinkCaps;
end;

function TG2DVideoFilterRef.ProcessFrame(const AIn: GstVideoFrame;
  const AInfo: GstVideoInfo; var AOut: GstVideoFrame): Boolean;
begin
  if Assigned(FOnProcessFrame) then
    Result := FOnProcessFrame(Self, AIn, AInfo, AOut)
  else
    Result := inherited ProcessFrame(AIn, AInfo, AOut);
end;

procedure TG2DVideoFilterRef.SetOnGetSinkCaps(
  const Value: TGetVideoSinkCapsEvent);
begin
  FOnGetSinkCaps := Value;
  ApplyManagedSinkCaps;
end;

procedure TG2DVideoFilterRef.SetOnProcessFrame(
  const Value: TProcessVideoFrameEvent);
begin
  FOnProcessFrame := Value;
end;

procedure TG2DVideoFilterRef.AddToPipeline;
var
  LPipelineBin : PGstBin;
  LCached      : TGstElementRef;
begin
  if FAddedToPipeline then
    Exit;

  ApplyManagedSinkCaps;

  if (Framework = nil) or (Framework.Pipeline = nil) then
    raise EG2DVideoSimpleError.Create(
      'TG2DVideoFilterRef.AddToPipeline: framework pipeline is nil');

  LPipelineBin := PGstBin(Framework.Pipeline.PipelineHandle);
  if _gst_bin_add(LPipelineBin, FBin.ElementHandle) = 0 then
    raise EG2DVideoSimpleError.CreateFmt(
      'TG2DVideoFilterRef.AddToPipeline: failed to add filter bin "%s"',
      [FBinName]);

  FAddedToPipeline := True;

  LCached := Framework.Pipeline.GetElement(FBinName);
  if LCached <> nil then
    LCached.Free;
end;

procedure TG2DVideoFilterRef.AddAndLink(const AUpstream, ADownstream: string);
begin
  AddToPipeline;

  if not Framework.LinkElements(AUpstream, FBinName) then
    raise EG2DVideoSimpleError.CreateFmt(
      'TG2DVideoFilterRef.AddAndLink: failed to link "%s" -> "%s"',
      [AUpstream, FBinName]);

  if not Framework.LinkElements(FBinName, ADownstream) then
    raise EG2DVideoSimpleError.CreateFmt(
      'TG2DVideoFilterRef.AddAndLink: failed to link "%s" -> "%s"',
      [FBinName, ADownstream]);
end;

procedure TG2DVideoFilterRef.Shutdown;
var
  LState   : GstState;
  LPending : GstState;
begin
  if Assigned(FBin) and (FBin.ElementHandle <> nil) then
  begin
    _gst_element_set_state(FBin.ElementHandle, GST_STATE_READY);
    _gst_element_get_state(FBin.ElementHandle, @LState, @LPending, GST_SECOND);
  end;
  inherited Shutdown;
end;

function TGstFrameworkVideoFilterHelper.FindVideoFilter(
  const AName: string): TG2DVideoFilterRef;
begin
  Result := TG2DVideoFilterRef(Self.FindManagedObject(AName));
  if (Result <> nil) and not (Result is TG2DVideoFilterRef) then
    Result := nil;
end;

initialization
  RegisterManagedFactory('G2DVideoFilter', CreateManagedVideoFilter);

finalization
  UnregisterManagedFactory('G2DVideoFilter');

end.

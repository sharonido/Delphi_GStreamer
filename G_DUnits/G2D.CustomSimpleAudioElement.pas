unit G2D.CustomSimpleAudioElement;

{------------------------------------------------------------------------------
  G2D.CustomSimpleAudioElement
  Audio filter base. Derives from TGstSimpleBase, adds GstAudioInfo parsing.

  appsrc uses is-live=True so it skips preroll. need-data is connected
  for diagnostics, but real audio flow is driven by HandleNewSample once
  appsink delivers the first decoded sample and caps are known.
------------------------------------------------------------------------------}

interface

uses
  System.SysUtils,
  System.SyncObjs,
  G2D.Glib.Types,
  G2D.Glib.API,
  G2D.Gobject.DOO,
  G2D.Gst.Types,
  G2D.Gst.API,
  G2D.GstApp.DOO,
  G2D.GstElement.DOO,
  G2D.GstBin.DOO,
  G2D.GstFramework,
  G2D.CustomSimpleBaseElement;

type
  EG2DAudioSimpleError = class(Exception);

  TGstAudioSimple = class(TGstSimpleBase)
  private
    FAudioInfo    : GstAudioInfo;
    FHasAudioInfo : Boolean;
    FNeedDataSeen : Boolean;
    FLockPreroll  : TCriticalSection;

    function UpdateAudioInfo(ACaps: PGstCaps): Boolean;

    class procedure NeedDataCallback(source: PGstElement; size: guint;
      data: gpointer); cdecl; static;

  protected
    procedure OnCapsChanged(ACaps: PGstCaps); override; final;
    procedure OnAudioInfoChanged(const AInfo: GstAudioInfo); virtual;

    function ProcessAudio(const AMapIn: GstMapInfo;
      var AMapOut: GstMapInfo;
      const AInfo: GstAudioInfo): Boolean; virtual;

    function ProcessBuffer(const AMapIn: GstMapInfo;
      var AMapOut: GstMapInfo): Boolean; override; final;

    procedure ConfigureSrc; override;

  public
    constructor Create(AFramework: TGstFramework);
    destructor Destroy; override;

    property AudioInfo: GstAudioInfo read FAudioInfo;
    property HasAudioInfo: Boolean read FHasAudioInfo;
  end;

  TGstAudioSimpleFilter = class(TGstAudioSimple)
  private
    FBin             : TGstBinRef;
    FPreConvert      : TGstElementRef;
    FPreResample     : TGstElementRef;
    FPostConvert     : TGstElementRef;
    FPostResample    : TGstElementRef;
    FBinName         : string;
    FAddedToPipeline : Boolean;

    class function NextFilterName: string; static;
    class function MakeManagedElement(const AFactory, AName: string): TGstElementRef; static;
    procedure BuildManagedChain;
    procedure CreateGhostPads;

  public
    constructor Create(AFramework: TGstFramework);
    destructor Destroy; override;

    procedure AddToPipeline; override;
    procedure AddAndLink(const AUpstream, ADownstream: string); override;
    procedure Shutdown; override;

    property BinName: string read FBinName;
  end;

implementation

function AudioCapsToDebugString(ACaps: PGstCaps): string;
var
  LCapsStr: Pgchar;
begin
  Result := 'nil';
  if ACaps = nil then
    Exit;

  LCapsStr := _gst_caps_to_string(ACaps);
  if LCapsStr = nil then
    Exit;
  try
    Result := PgcharToString(LCapsStr);
  finally
    _g_free(LCapsStr);
  end;
end;

var
  GAudioSimpleFilterCounter: Integer = 0;

constructor TGstAudioSimple.Create(AFramework: TGstFramework);
begin
  inherited Create(AFramework);
  FHasAudioInfo := False;
  FNeedDataSeen := False;
  FLockPreroll  := TCriticalSection.Create;
  FillChar(FAudioInfo, SizeOf(FAudioInfo), 0);
end;

destructor TGstAudioSimple.Destroy;
begin
  FreeAndNil(FLockPreroll);
  inherited;
end;

procedure TGstAudioSimple.ConfigureSrc;
begin
  { This bridge depends on the first decoded sample arriving from appsink
    before real downstream data can flow, so appsrc must act as a live source
    and skip preroll. Otherwise the pipeline can deadlock in READY/PAUSED
    waiting for appsrc preroll data that cannot exist yet. }
  FSrc.SetFormat(GST_FORMAT_TIME);
  FSrc.SetIsLive(True);
  FSrc.SetBlockOnFull(True);
  FSrc.SetPropertyInt('max-buffers', 1);
  FSrc.ConnectNeedData(NeedDataCallback, Self);
end;

class procedure TGstAudioSimple.NeedDataCallback(source: PGstElement;
  size: guint; data: gpointer); cdecl;
var
  LSelf        : TGstAudioSimple;
begin
  LSelf := TGstAudioSimple(data);

  LSelf.FLockPreroll.Acquire;
  try
    if LSelf.FNeedDataSeen then
      Exit;
    LSelf.FNeedDataSeen := True;
  finally
    LSelf.FLockPreroll.Release;
  end;

  if not LSelf.FHasAudioInfo then
    LogWriteln('TGstAudioSimple need-data before audio caps are known; waiting for first real sample')
  else
    LogWriteln(Format(
      'TGstAudioSimple need-data after caps: rate=%d channels=%d bpf=%d; waiting for first real sample',
      [LSelf.FAudioInfo.rate, LSelf.FAudioInfo.channels, LSelf.FAudioInfo.bpf]));
end;

procedure TGstAudioSimple.OnCapsChanged(ACaps: PGstCaps);
begin
  LogWriteln('TGstAudioSimple OnCapsChanged: ' + AudioCapsToDebugString(ACaps));
  if UpdateAudioInfo(ACaps) then
    OnAudioInfoChanged(FAudioInfo);
end;

procedure TGstAudioSimple.OnAudioInfoChanged(const AInfo: GstAudioInfo);
begin
  LogWriteln(Format('TGstAudioSimple audio-info: rate=%d channels=%d bpf=%d',
    [AInfo.rate, AInfo.channels, AInfo.bpf]));
end;

function TGstAudioSimple.ProcessAudio(const AMapIn: GstMapInfo;
  var AMapOut: GstMapInfo; const AInfo: GstAudioInfo): Boolean;
begin
  if (AMapIn.data <> nil) and (AMapOut.data <> nil) and (AMapIn.size > 0) then
    Move(AMapIn.data^, AMapOut.data^, AMapIn.size);
  Result := True;
end;

function TGstAudioSimple.ProcessBuffer(const AMapIn: GstMapInfo;
  var AMapOut: GstMapInfo): Boolean;
begin
  if not FHasAudioInfo then
  begin
    if (AMapIn.data <> nil) and (AMapOut.data <> nil) and (AMapIn.size > 0) then
      Move(AMapIn.data^, AMapOut.data^, AMapIn.size);
    Result := True;
    Exit;
  end;
  Result := ProcessAudio(AMapIn, AMapOut, FAudioInfo);
end;

function TGstAudioSimple.UpdateAudioInfo(ACaps: PGstCaps): Boolean;
var
  LNewInfo: GstAudioInfo;
begin
  Result := False;
  if ACaps = nil then Exit;
  _gst_audio_info_init(@LNewInfo);
  if _gst_audio_info_from_caps(@LNewInfo, ACaps) = 0 then Exit;
  if FHasAudioInfo                             and
     (LNewInfo.rate     = FAudioInfo.rate)     and
     (LNewInfo.channels = FAudioInfo.channels) and
     (LNewInfo.finfo    = FAudioInfo.finfo)    then Exit;
  FAudioInfo    := LNewInfo;
  FHasAudioInfo := True;
  Result        := True;
end;

{ TGstAudioSimpleFilter }

class function TGstAudioSimpleFilter.NextFilterName: string;
var
  LID: Integer;
begin
  LID := TInterlocked.Increment(GAudioSimpleFilterCounter);
  Result := Format('g2d_audio_filter_%d', [LID]);
end;

class function TGstAudioSimpleFilter.MakeManagedElement(const AFactory,
  AName: string): TGstElementRef;
begin
  Result := TGstElementRef.FactoryMake(AFactory, AName);
  if Result = nil then
    raise EG2DAudioSimpleError.CreateFmt(
      'Failed to create managed audio filter element: %s (%s)',
      [AName, AFactory]);
end;

constructor TGstAudioSimpleFilter.Create(AFramework: TGstFramework);
begin
  inherited Create(AFramework);
  FBinName := NextFilterName;
  BuildManagedChain;
end;

destructor TGstAudioSimpleFilter.Destroy;
begin
  FreeAndNil(FPostResample);
  FreeAndNil(FPostConvert);
  FreeAndNil(FPreResample);
  FreeAndNil(FPreConvert);
  FreeAndNil(FBin);
  inherited;
end;

procedure TGstAudioSimpleFilter.BuildManagedChain;
var
  LNameUtf8 : UTF8String;
  LBinHandle: PGstElement;
begin
  LNameUtf8  := UTF8String(FBinName);
  LBinHandle := _gst_bin_new(Pgchar(PAnsiChar(LNameUtf8)));
  if LBinHandle = nil then
    raise EG2DAudioSimpleError.CreateFmt(
      'Failed to create TGstAudioSimpleFilter bin: %s', [FBinName]);

  FBin := TGstBinRef.Wrap(PGstBin(LBinHandle), False, True);

  FPreConvert   := MakeManagedElement('audioconvert',  FBinName + '_pre_convert');
  FPreResample  := MakeManagedElement('audioresample', FBinName + '_pre_resample');
  FPostConvert  := MakeManagedElement('audioconvert',  FBinName + '_post_convert');
  FPostResample := MakeManagedElement('audioresample', FBinName + '_post_resample');

  if not FBin.Add(FPreConvert) then
    raise EG2DAudioSimpleError.Create('Failed to add pre-convert to managed audio filter bin');
  if not FBin.Add(FPreResample) then
    raise EG2DAudioSimpleError.Create('Failed to add pre-resample to managed audio filter bin');
  if not FBin.Add(FSink.ElementHandle) then
    raise EG2DAudioSimpleError.Create('Failed to add appsink to managed audio filter bin');
  if not FBin.Add(FSrc.ElementHandle) then
    raise EG2DAudioSimpleError.Create('Failed to add appsrc to managed audio filter bin');
  if not FBin.Add(FPostConvert) then
    raise EG2DAudioSimpleError.Create('Failed to add post-convert to managed audio filter bin');
  if not FBin.Add(FPostResample) then
    raise EG2DAudioSimpleError.Create('Failed to add post-resample to managed audio filter bin');

  if not FPreConvert.Link(FPreResample) then
    raise EG2DAudioSimpleError.Create('Failed to link pre-convert -> pre-resample');
  if not FPreResample.Link(FSink.ElementHandle) then
    raise EG2DAudioSimpleError.Create('Failed to link pre-resample -> appsink');
  if not FSrc.Link(FPostConvert) then
    raise EG2DAudioSimpleError.Create('Failed to link appsrc -> post-convert');
  if not FPostConvert.Link(FPostResample) then
    raise EG2DAudioSimpleError.Create('Failed to link post-convert -> post-resample');

  CreateGhostPads;
end;

procedure TGstAudioSimpleFilter.CreateGhostPads;
var
  LTargetPad : PGstPad;
  LGhostPad  : PGstPad;
  LPadName   : UTF8String;
begin
  LPadName := UTF8String('sink');
  LTargetPad := FPreConvert.GetStaticPad('sink');
  if LTargetPad = nil then
    raise EG2DAudioSimpleError.Create('Failed to get managed filter sink pad');
  try
    LGhostPad := _gst_ghost_pad_new(Pgchar(PAnsiChar(LPadName)), LTargetPad);
    if LGhostPad = nil then
      raise EG2DAudioSimpleError.Create('Failed to create managed filter ghost sink pad');
    if _gst_element_add_pad(FBin.ElementHandle, LGhostPad) = 0 then
      raise EG2DAudioSimpleError.Create('Failed to add managed filter ghost sink pad');
  finally
    _gst_object_unref(gpointer(LTargetPad));
  end;

  LPadName := UTF8String('src');
  LTargetPad := FPostResample.GetStaticPad('src');
  if LTargetPad = nil then
    raise EG2DAudioSimpleError.Create('Failed to get managed filter src pad');
  try
    LGhostPad := _gst_ghost_pad_new(Pgchar(PAnsiChar(LPadName)), LTargetPad);
    if LGhostPad = nil then
      raise EG2DAudioSimpleError.Create('Failed to create managed filter ghost src pad');
    if _gst_element_add_pad(FBin.ElementHandle, LGhostPad) = 0 then
      raise EG2DAudioSimpleError.Create('Failed to add managed filter ghost src pad');
  finally
    _gst_object_unref(gpointer(LTargetPad));
  end;
end;

procedure TGstAudioSimpleFilter.AddToPipeline;
var
  LPipelineBin : PGstBin;
  LCached      : TGstElementRef;
begin
  if FAddedToPipeline then
    Exit;

  if (Framework = nil) or (Framework.Pipeline = nil) then
    raise EG2DAudioSimpleError.Create(
      'TGstAudioSimpleFilter.AddToPipeline: framework pipeline is nil');

  LPipelineBin := PGstBin(Framework.Pipeline.PipelineHandle);
  if _gst_bin_add(LPipelineBin, FBin.ElementHandle) = 0 then
    raise EG2DAudioSimpleError.CreateFmt(
      'TGstAudioSimpleFilter.AddToPipeline: failed to add filter bin "%s"',
      [FBinName]);

  FAddedToPipeline := True;

  { Cache the bin by name in the pipeline element dictionary so framework
    helpers such as LinkElements can address it like a normal element. }
  LCached := Framework.Pipeline.GetElement(FBinName);
  if LCached <> nil then
    LCached.Free;
end;

procedure TGstAudioSimpleFilter.AddAndLink(const AUpstream, ADownstream: string);
begin
  AddToPipeline;

  if not Framework.LinkElements(AUpstream, FBinName) then
    raise EG2DAudioSimpleError.CreateFmt(
      'TGstAudioSimpleFilter.AddAndLink: failed to link "%s" -> "%s"',
      [AUpstream, FBinName]);

  if not Framework.LinkElements(FBinName, ADownstream) then
    raise EG2DAudioSimpleError.CreateFmt(
      'TGstAudioSimpleFilter.AddAndLink: failed to link "%s" -> "%s"',
      [FBinName, ADownstream]);
end;

procedure TGstAudioSimpleFilter.Shutdown;
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

end.

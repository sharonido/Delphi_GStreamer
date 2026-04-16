unit G2D.CustomSimpleBaseElement;

{------------------------------------------------------------------------------
  G2D.CustomSimpleBaseElement
  Phase 1 custom filter base class (appsink/appsrc delegation pattern).

  Pipeline segment owned by this class:
    upstream --> appsink --> [ProcessBuffer] --> appsrc --> downstream

  Usage:
    1. Derive from TGstSimpleBase.
    2. Override GetSinkCaps to constrain the input format (optional).
    3. Override ProcessBuffer to manipulate the raw buffer data.
    4. Call AddToPipeline then Play.
    5. FreeAndNil(FFilter) before FreeAndNil(FGStreamer) in FormDestroy.

  Threading:
    ProcessBuffer fires on a GStreamer streaming thread, NOT the main thread.
    Do NOT access VCL controls directly. Use TThread.Queue for UI updates.

  Memory / flow control:
    appsrc is configured with max-buffers=1 and block=True. This blocks the
    streaming thread until downstream consumes each buffer, creating natural
    backpressure at the source rate without a pipeline clock.
------------------------------------------------------------------------------}

interface

uses
  System.SysUtils,
  System.SyncObjs,
  G2D.Glib.Types,
  G2D.Gobject.Types,
  G2D.Gst.Types,
  G2D.Gst.API,
  G2D.GstApp.DOO,
  G2D.GstElement.DOO,
  G2D.GstFramework;

type
  EG2DSimpleBaseError = class(Exception);

{==============================================================================
  TGstSimpleBase
  Base class for a Delphi-side filter inserted into a GStreamer pipeline via
  an appsink -> [ProcessBuffer] -> appsrc segment.

  Subclass and override ProcessBuffer to manipulate raw buffer bytes.
  For video frame processing, use TGstVideoSimple (G2D.VideoCustomSimpleElement)
  which wraps the maps into GstVideoFrame and exposes ProcessFrame.
==============================================================================}
  TGstSimpleBase = class
  private
    FFramework  : TGstFramework;
    FSink       : TGstAppSinkRef;
    FSrc        : TGstAppSrcRef;
    FLock       : TCriticalSection;
    FInstanceID : Integer;
    FLastCaps   : PGstCaps;  { last seen caps pointer - detects format changes }

    class function NewSampleCallback(sink: PGstElement;
      data: gpointer): GstFlowReturn; cdecl; static;

    function HandleNewSample: GstFlowReturn;

  protected
    { Override to constrain the input format on appsink.
      Default: '' (accept whatever upstream produces).
      Example: 'audio/x-raw,format=S16LE,rate=44100' }
    function GetSinkCaps: string; virtual;

    { Called on the streaming thread when caps change (first buffer or
      format change). Override to allocate format-specific resources. }
    procedure OnCapsChanged(ACaps: PGstCaps); virtual;

    { THE override point. Called on the streaming thread for every buffer.
      AMapIn  : mapped input  buffer (GST_MAP_READ)  - read from AMapIn.data
      AMapOut : mapped output buffer (GST_MAP_WRITE) - write to AMapOut.data
      Return True to push AMapOut downstream; False to drop the buffer.
      Default implementation: memcopy (passthrough). }
    function ProcessBuffer(const AMapIn: GstMapInfo;
      var AMapOut: GstMapInfo): Boolean; virtual;

  public
    constructor Create(AFramework: TGstFramework);
    destructor Destroy; override;

    { Add both internal elements to the framework pipeline.
      Call this before setting the pipeline to PLAYING. }
    procedure AddToPipeline;

    { AddToPipeline + link upstream -> appsink and appsrc -> downstream
      in one call. AUpstream and ADownstream are element names already
      registered in the framework (via MakeElements/AddElements). }
    procedure AddAndLink(const AUpstream, ADownstream: string);

    { Unblocks the streaming thread and stops the elements.
      Called automatically from Destroy - no manual call needed. }
    procedure Shutdown;

    { Set fixed caps on both appsink and appsrc from a caps string. }
    procedure SetFixedCaps(const ACapsStr: string);

    { The appsink element - link your upstream element's src pad to this }
    property SinkElement: TGstAppSinkRef read FSink;

    { The appsrc element - link this to your downstream element's sink pad }
    property SrcElement: TGstAppSrcRef read FSrc;
  end;

implementation

var
  GInstanceCounter: Integer = 0;

{==============================================================================
  TGstSimpleBase
==============================================================================}

constructor TGstSimpleBase.Create(AFramework: TGstFramework);
var
  LSinkName    : string;
  LSrcName     : string;
  LSinkCapsStr : string;
  LCapsUtf8    : UTF8String;
  LCaps        : PGstCaps;
begin
  inherited Create;

  if AFramework = nil then
    raise EG2DSimpleBaseError.Create(
      'TGstSimpleBase.Create: AFramework must not be nil');

  FFramework  := AFramework;
  FLock       := TCriticalSection.Create;

  { Unique ID so multiple filters in the same pipeline get distinct names }
  FInstanceID := TInterlocked.Increment(GInstanceCounter);
  LSinkName   := Format('g2d_filter_sink_%d', [FInstanceID]);
  LSrcName    := Format('g2d_filter_src_%d',  [FInstanceID]);

  FSink := TGstAppSinkRef.Make(LSinkName);
  FSrc  := TGstAppSrcRef.Make(LSrcName);

  { Configure sink }
  FSink.SetEmitSignals(True);
  FSink.SetMaxBuffers(1);
  FSink.SetDrop(True);
  FSink.SetSync(False);
  FSink.SetPropertyBool('wait-on-eos', False);
  { async=False: appsink does not participate in preroll. Without this
    GStreamer waits for appsink's first buffer before PAUSED->PLAYING,
    but that buffer never comes until PLAYING - a deadlock. }
  FSink.SetPropertyBool('async', False);

  { Apply optional caps constraint from subclass }
  LSinkCapsStr := GetSinkCaps;
  if LSinkCapsStr <> '' then
  begin
    LCapsUtf8 := UTF8String(LSinkCapsStr);
    LCaps     := _gst_caps_from_string(Pgchar(PAnsiChar(LCapsUtf8)));
    if LCaps <> nil then
    begin
      FSink.SetCaps(LCaps);
      _gst_caps_unref(LCaps);
    end;
  end;

  { Configure src.
    is-live=True: appsrc behaves as a live source so it does not
    participate in preroll - prevents deadlock where appsrc blocks
    waiting for our callback which never fires until PLAYING.
    block=True + max-buffers=1: once PLAYING, push_buffer blocks until
    downstream consumes each buffer - natural backpressure, flat memory. }
  FSrc.SetFormat(GST_FORMAT_TIME);
  FSrc.SetIsLive(True);
  FSrc.SetBlockOnFull(True);
  FSrc.SetPropertyInt('max-buffers', 1);

  FLastCaps := nil;
  FSink.ConnectNewSample(NewSampleCallback, Self);
end;

destructor TGstSimpleBase.Destroy;
begin
  { Shutdown unblocks the streaming thread before the pipeline is stopped.
    Called here so FreeAndNil(FFilter) is all the user needs. }
  Shutdown;
  FreeAndNil(FSink);
  FreeAndNil(FSrc);
  FreeAndNil(FLock);
  inherited;
end;

procedure TGstSimpleBase.AddToPipeline;
var
  LPipelineBin: PGstBin;
begin
  if FFramework.Pipeline = nil then
    raise EG2DSimpleBaseError.Create('AddToPipeline: framework pipeline is nil');

  LPipelineBin := PGstBin(FFramework.Pipeline.PipelineHandle);

  if _gst_bin_add(LPipelineBin, FSink.ElementHandle) = 0 then
    raise EG2DSimpleBaseError.CreateFmt(
      'AddToPipeline: failed to add sink element "%s"',
      [Format('g2d_filter_sink_%d', [FInstanceID])]);

  if _gst_bin_add(LPipelineBin, FSrc.ElementHandle) = 0 then
    raise EG2DSimpleBaseError.CreateFmt(
      'AddToPipeline: failed to add src element "%s"',
      [Format('g2d_filter_src_%d', [FInstanceID])]);

  { Register elements in pipeline's FElements dictionary for LinkElements }
  FFramework.Pipeline.GetElement(
    Format('g2d_filter_sink_%d', [FInstanceID])).Free;
  FFramework.Pipeline.GetElement(
    Format('g2d_filter_src_%d',  [FInstanceID])).Free;
end;

procedure TGstSimpleBase.AddAndLink(const AUpstream, ADownstream: string);
begin
  AddToPipeline;
  if not FFramework.LinkElements(AUpstream, FSink.GetName) then
    raise EG2DSimpleBaseError.CreateFmt(
      'AddAndLink: failed to link "%s" -> "%s"', [AUpstream, FSink.GetName]);
  if not FFramework.LinkElements(FSrc.GetName, ADownstream) then
    raise EG2DSimpleBaseError.CreateFmt(
      'AddAndLink: failed to link "%s" -> "%s"', [FSrc.GetName, ADownstream]);
end;

procedure TGstSimpleBase.Shutdown;
begin
  if Assigned(FSink) and (FSink.ElementHandle <> nil) then
    FSink.SetEmitSignals(False);

  { Set appsrc to READY - flushes its queue and unblocks any thread
    blocked in gst_app_src_push_buffer immediately. }
  if Assigned(FSrc) and (FSrc.ElementHandle <> nil) then
    _gst_element_set_state(FSrc.ElementHandle, GST_STATE_READY);

  if Assigned(FSink) and (FSink.ElementHandle <> nil) then
    _gst_element_set_state(FSink.ElementHandle, GST_STATE_READY);
end;

procedure TGstSimpleBase.SetFixedCaps(const ACapsStr: string);
var
  LCapsUtf8 : UTF8String;
  LCaps     : PGstCaps;
begin
  if ACapsStr = '' then
    Exit;
  LCapsUtf8 := UTF8String(ACapsStr);
  LCaps     := _gst_caps_from_string(Pgchar(PAnsiChar(LCapsUtf8)));
  if LCaps = nil then
    Exit;
  try
    FSink.SetCaps(LCaps);
    FSrc.SetCaps(LCaps);
  finally
    _gst_caps_unref(LCaps);
  end;
end;

{ --- Protected virtuals ---------------------------------------------------- }

function TGstSimpleBase.GetSinkCaps: string;
begin
  Result := '';
end;

procedure TGstSimpleBase.OnCapsChanged(ACaps: PGstCaps);
begin
  { Default: no-op. }
end;

function TGstSimpleBase.ProcessBuffer(const AMapIn: GstMapInfo;
  var AMapOut: GstMapInfo): Boolean;
begin
  { Default passthrough: memcopy. }
  if (AMapIn.data <> nil) and (AMapOut.data <> nil) and (AMapIn.size > 0) then
    Move(AMapIn.data^, AMapOut.data^, AMapIn.size);
  Result := True;
end;

{ --- Private ---------------------------------------------------------------- }

class function TGstSimpleBase.NewSampleCallback(sink: PGstElement;
  data: gpointer): GstFlowReturn; cdecl;
begin
  Result := TGstSimpleBase(data).HandleNewSample;
end;

function TGstSimpleBase.HandleNewSample: GstFlowReturn;
var
  LRawSample : gpointer;
  LSample    : TGstSampleRef;
  LCaps      : PGstCaps;
  LBuffer    : PGstBuffer;
  LOutBuffer : PGstBuffer;
  LMapIn     : GstMapInfo;
  LMapOut    : GstMapInfo;
begin
  Result := GST_FLOW_OK;

  LRawSample := _gst_app_sink_pull_sample(FSink.ElementHandle);
  if LRawSample = nil then
    Exit;

  LSample := TGstSampleRef.Create(LRawSample);
  try
    { Notify subclass only when caps pointer changes (new format) }
    LCaps := LSample.GetCaps;
    if (LCaps <> nil) and (LCaps <> FLastCaps) then
    begin
      FLastCaps := LCaps;
      FSrc.SetCaps(LCaps);
      OnCapsChanged(LCaps);
    end;

    LBuffer := LSample.GetBuffer;
    if LBuffer = nil then
      Exit;

    if _gst_buffer_map(LBuffer, @LMapIn, GST_MAP_READ) = 0 then
    begin
      Result := GST_FLOW_ERROR;
      Exit;
    end;
    try
      LOutBuffer := _gst_buffer_new_allocate(nil, LMapIn.size, nil);
      if LOutBuffer = nil then
      begin
        Result := GST_FLOW_ERROR;
        Exit;
      end;
      try
        LOutBuffer^.pts      := LBuffer^.pts;
        LOutBuffer^.dts      := LBuffer^.dts;
        LOutBuffer^.duration := LBuffer^.duration;

        if _gst_buffer_map(LOutBuffer, @LMapOut, GST_MAP_WRITE) = 0 then
        begin
          Result := GST_FLOW_ERROR;
          Exit;
        end;
        try
          if ProcessBuffer(LMapIn, LMapOut) then
          begin
            _gst_buffer_unmap(LOutBuffer, @LMapOut);
            { gst_app_src_push_buffer takes ownership - do NOT unref }
            Result := _gst_app_src_push_buffer(FSrc.ElementHandle, LOutBuffer);
            LOutBuffer := nil;
            if Result = GST_FLOW_FLUSHING then
              Result := GST_FLOW_OK;
          end
          else
            _gst_buffer_unmap(LOutBuffer, @LMapOut);
        except
          _gst_buffer_unmap(LOutBuffer, @LMapOut);
          raise;
        end;
      finally
        if LOutBuffer <> nil then
          _gst_buffer_unref(LOutBuffer);
      end;
    finally
      _gst_buffer_unmap(LBuffer, @LMapIn);
    end;

  finally
    LSample.Free;
  end;
end;

end.

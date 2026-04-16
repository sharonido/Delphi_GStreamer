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
  G2D.Glib.Types,
  G2D.Gst.Types,
  G2D.Gst.API,
  G2D.GstFramework,
  G2D.CustomSimpleBaseElement;

type
  EG2DVideoSimpleError = class(Exception);

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

implementation

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

end.

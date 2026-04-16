unit G2D.CustomSimpleAudioElement;

{------------------------------------------------------------------------------
  G2D.CustomSimpleAudioElement
  Phase 1 audio filter - derives from TGstSimpleBase and adds audio geometry.

  Overrides ProcessBuffer internally to parse GstAudioInfo from caps and
  call ProcessAudio with friendly typed access to sample rate, channels
  and format.

  Usage:
    1. Derive from TGstAudioSimple.
    2. Override GetSinkCaps to pin the audio format (recommended).
       Example: 'audio/x-raw,format=S16LE,rate=44100,channels=2'
    3. Override ProcessAudio to manipulate audio samples.
    4. Optionally override OnAudioInfoChanged to react to format changes.
    5. Call AddToPipeline then Play.
    6. FreeAndNil(FFilter) before FreeAndNil(FGStreamer) in FormDestroy.

  Threading:
    ProcessAudio fires on a GStreamer streaming thread, NOT the main thread.
    Do NOT access VCL controls directly. Use TThread.Queue for UI updates.

  Format note:
    Pin to S16LE via GetSinkCaps for easy integer DSP (each sample is a
    SmallInt). Use F32LE if you prefer floating-point processing.
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
  EG2DAudioSimpleError = class(Exception);

{==============================================================================
  TGstAudioSimple
  Audio filter base class. Derives from TGstSimpleBase and adds:
  - Caps parsing into GstAudioInfo (rate, channels, format, bytes-per-sample)
  - ProcessAudio virtual with full audio geometry available

  Override ProcessAudio to manipulate audio samples. AMapIn/AMapOut give
  you the raw byte pointers; AInfo gives you rate, channels and format so
  you know how to interpret those bytes.
==============================================================================}
  TGstAudioSimple = class(TGstSimpleBase)
  private
    FAudioInfo    : GstAudioInfo;
    FHasAudioInfo : Boolean;

    function UpdateAudioInfo(ACaps: PGstCaps): Boolean;

  protected
    { Called on the streaming thread when caps change (first buffer or
      format change). AInfo contains rate/channels/format/bpf.
      Override to allocate format-specific resources (e.g. filter state). }
    procedure OnCapsChanged(ACaps: PGstCaps); override; final;
    procedure OnAudioInfoChanged(const AInfo: GstAudioInfo); virtual;

    { THE override point. Called on the streaming thread for every buffer.
      AMapIn  : input  buffer (GST_MAP_READ)  - read samples from AMapIn.data
      AMapOut : output buffer (GST_MAP_WRITE) - write samples to AMapOut.data
      AInfo   : audio geometry (rate, channels, format, bpf)
      Return True to push AMapOut downstream; False to drop the buffer.
      Default: memcopy passthrough. }
    function ProcessAudio(const AMapIn: GstMapInfo;
      var AMapOut: GstMapInfo;
      const AInfo: GstAudioInfo): Boolean; virtual;

    { Override of base ProcessBuffer - calls ProcessAudio with audio info.
      Do NOT override this in audio subclasses. }
    function ProcessBuffer(const AMapIn: GstMapInfo;
      var AMapOut: GstMapInfo): Boolean; override; final;

  public
    constructor Create(AFramework: TGstFramework);

    { Read-only access to current audio geometry (valid after first buffer) }
    property AudioInfo: GstAudioInfo read FAudioInfo;
    property HasAudioInfo: Boolean read FHasAudioInfo;
  end;

implementation

{==============================================================================
  TGstAudioSimple
==============================================================================}

constructor TGstAudioSimple.Create(AFramework: TGstFramework);
begin
  inherited Create(AFramework);
  FHasAudioInfo := False;
  FillChar(FAudioInfo, SizeOf(FAudioInfo), 0);
end;

procedure TGstAudioSimple.OnCapsChanged(ACaps: PGstCaps);
begin
  if UpdateAudioInfo(ACaps) then
    OnAudioInfoChanged(FAudioInfo);
end;

procedure TGstAudioSimple.OnAudioInfoChanged(const AInfo: GstAudioInfo);
begin
  { Default: no-op. Subclass overrides to react to format changes. }
end;

function TGstAudioSimple.ProcessAudio(const AMapIn: GstMapInfo;
  var AMapOut: GstMapInfo; const AInfo: GstAudioInfo): Boolean;
begin
  { Default passthrough: memcopy. }
  if (AMapIn.data <> nil) and (AMapOut.data <> nil) and (AMapIn.size > 0) then
    Move(AMapIn.data^, AMapOut.data^, AMapIn.size);
  Result := True;
end;

function TGstAudioSimple.ProcessBuffer(const AMapIn: GstMapInfo;
  var AMapOut: GstMapInfo): Boolean;
begin
  if not FHasAudioInfo then
  begin
    { No caps yet - passthrough until format is known }
    if (AMapIn.data <> nil) and (AMapOut.data <> nil) and (AMapIn.size > 0) then
      Move(AMapIn.data^, AMapOut.data^, AMapIn.size);
    Result := True;
    Exit;
  end;

  Result := ProcessAudio(AMapIn, AMapOut, FAudioInfo);
end;

{ --- Private ---------------------------------------------------------------- }

function TGstAudioSimple.UpdateAudioInfo(ACaps: PGstCaps): Boolean;
var
  LNewInfo : GstAudioInfo;
begin
  Result := False;
  if ACaps = nil then
    Exit;

  _gst_audio_info_init(@LNewInfo);
  if _gst_audio_info_from_caps(@LNewInfo, ACaps) = 0 then
    Exit;

  { Detect real change }
  if FHasAudioInfo                           and
     (LNewInfo.rate     = FAudioInfo.rate)   and
     (LNewInfo.channels = FAudioInfo.channels) and
     (LNewInfo.finfo    = FAudioInfo.finfo)  then
    Exit;

  FAudioInfo    := LNewInfo;
  FHasAudioInfo := True;
  Result        := True;
end;

end.

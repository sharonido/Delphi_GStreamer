unit G2D.Plugin.AudioFilter;

{------------------------------------------------------------------------------
  G2D.Plugin.AudioFilter

  First reusable audio-filter layer for Delphi GStreamer plugin elements.

  This class adds audio CAPS awareness on top of TG2DBaseFilter. The buffer
  handling is still passthrough unless a descendant overrides ProcessAudioFrame.
------------------------------------------------------------------------------}

interface

uses
  System.SysUtils,
  G2D.Glib.Types,
  G2D.Glib.API,
  G2D.Gobject.Types,
  G2D.Gst.Types,
  G2D.Gst.API,
  G2D.Plugin.BaseFilter;

type
  PG2DGstAudioFilterEventHead = ^TG2DGstAudioFilterEventHead;
  TG2DGstAudioFilterEventHead = record
    mini_object: GstMiniObject;
    etype: guint;
    timestamp: guint64;
    seqnum: guint32;
  end;

  PG2DAudioInfo = ^TG2DAudioInfo;
  TG2DAudioInfo = record
    Valid: Boolean;
    CapsText: string;
    MediaType: string;
    Format: string;
    Layout: string;
    Rate: Integer;
    Channels: Integer;
    BytesPerFrame: Integer;
    GstInfo: GstAudioInfo;
  end;

  TG2DAudioFilter = class(TG2DBaseFilter)
  private
    FCurrentCapsText: string;
    FAudioInfo: TG2DAudioInfo;
  protected
    function CapsToText(ACaps: PGstCaps): string; virtual;
    function BuildAudioInfo(ACaps: PGstCaps): TG2DAudioInfo; virtual;
    function AudioInfoToLogText(const AInfo: TG2DAudioInfo): string; virtual;
    function IsAudioCapsText(const ACapsText: string): Boolean; virtual;
    procedure SetCurrentCaps(ACaps: PGstCaps); virtual;
    function ProcessAudioFrame(
      buffer: PGstBuffer;
      const AInfo: TG2DAudioInfo
    ): GstFlowReturn; virtual;
  public
    property CurrentCapsText: string read FCurrentCapsText;
    property AudioInfo: TG2DAudioInfo read FAudioInfo;

    function SinkEvent(
      pad: PGstPad;
      parent: PGstObject;
      event: PGstEvent
    ): gboolean; override;

    function SinkQuery(
      pad: PGstPad;
      parent: PGstObject;
      query: PGstQuery
    ): gboolean; override;

    function ProcessBuffer(buffer: PGstBuffer): GstFlowReturn; override;
  end;

implementation

function G2DAudioLayoutToString(ALayout: GstAudioLayout): string;
begin
  if ALayout = GST_AUDIO_LAYOUT_INTERLEAVED then
    Result := 'interleaved'
  else if ALayout = GST_AUDIO_LAYOUT_NON_INTERLEAVED then
    Result := 'non-interleaved'
  else
    Result := Format('unknown(%d)', [Integer(ALayout)]);
end;

function TG2DAudioFilter.CapsToText(ACaps: PGstCaps): string;
var
  LText: Pgchar;
begin
  Result := '';
  if ACaps = nil then
    Exit;
  if not Assigned(_gst_caps_to_string) then
    Exit;

  LText := _gst_caps_to_string(ACaps);
  if LText = nil then
    Exit;

  try
    Result := UTF8ToString(AnsiString(PAnsiChar(LText)));
  finally
    if Assigned(_g_free) then
      _g_free(LText);
  end;
end;

function TG2DAudioFilter.BuildAudioInfo(ACaps: PGstCaps): TG2DAudioInfo;
var
  LStructure: PGstStructure;
  LName: Pgchar;
begin
  Result.Valid := False;
  Result.CapsText := CapsToText(ACaps);
  Result.MediaType := '';
  Result.Format := '';
  Result.Layout := '';
  Result.Rate := 0;
  Result.Channels := 0;
  Result.BytesPerFrame := 0;
  FillChar(Result.GstInfo, SizeOf(Result.GstInfo), 0);

  if (ACaps = nil) or
     not Assigned(_gst_caps_get_size) or
     not Assigned(_gst_caps_get_structure) or
     (_gst_caps_get_size(ACaps) = 0) then
    Exit;

  LStructure := _gst_caps_get_structure(ACaps, 0);
  if LStructure <> nil then
  begin
    if Assigned(_gst_structure_get_name) then
    begin
      LName := _gst_structure_get_name(LStructure);
      if LName <> nil then
        Result.MediaType := UTF8ToString(AnsiString(PAnsiChar(LName)));
    end;
  end;

  if not Assigned(_gst_audio_info_init) or
     not Assigned(_gst_audio_info_from_caps) then
    Exit;

  _gst_audio_info_init(@Result.GstInfo);
  if _gst_audio_info_from_caps(@Result.GstInfo, ACaps) = 0 then
    Exit;

  if Result.GstInfo.finfo <> nil then
  begin
    if Result.GstInfo.finfo^.name <> nil then
      Result.Format := UTF8ToString(AnsiString(PAnsiChar(Result.GstInfo.finfo^.name)));
  end;

  Result.Layout := G2DAudioLayoutToString(Result.GstInfo.layout);
  Result.Rate := Result.GstInfo.rate;
  Result.Channels := Result.GstInfo.channels;
  Result.BytesPerFrame := Result.GstInfo.bpf;
  Result.Valid :=
    (Result.MediaType <> '') and
    (Pos('audio/', LowerCase(Result.MediaType)) = 1) and
    (Result.Format <> '') and
    (Result.Rate > 0) and
    (Result.Channels > 0) and
    (Result.BytesPerFrame > 0);
end;

function TG2DAudioFilter.AudioInfoToLogText(const AInfo: TG2DAudioInfo): string;
begin
  Result := Format(
    'audio info valid=%s media=%s format=%s layout=%s rate=%d channels=%d bpf=%d',
    [
      BoolToStr(AInfo.Valid, True),
      AInfo.MediaType,
      AInfo.Format,
      AInfo.Layout,
      AInfo.Rate,
      AInfo.Channels,
      AInfo.BytesPerFrame
    ]);
end;

function TG2DAudioFilter.IsAudioCapsText(const ACapsText: string): Boolean;
begin
  Result := Pos('audio/', LowerCase(ACapsText)) > 0;
end;

procedure TG2DAudioFilter.SetCurrentCaps(ACaps: PGstCaps);
begin
  FAudioInfo := BuildAudioInfo(ACaps);
  FCurrentCapsText := FAudioInfo.CapsText;

  if FCurrentCapsText = '' then
    Log(1, 'audio caps empty')
  else if IsAudioCapsText(FCurrentCapsText) then
    Log(1, 'audio caps detected')
  else
    Log(1, 'caps are not audio');

  Log(2, 'caps ' + FCurrentCapsText);
  Log(2, AudioInfoToLogText(FAudioInfo));
end;

function TG2DAudioFilter.ProcessAudioFrame(
  buffer: PGstBuffer;
  const AInfo: TG2DAudioInfo
): GstFlowReturn;
begin
  Log(2, Format(
    'process audio frame format=%s layout=%s rate=%d channels=%d',
    [
      AInfo.Format,
      AInfo.Layout,
      AInfo.Rate,
      AInfo.Channels
    ]));
  Result := inherited ProcessBuffer(buffer);
end;

function TG2DAudioFilter.SinkEvent(
  pad: PGstPad;
  parent: PGstObject;
  event: PGstEvent
): gboolean;
var
  LCaps: PGstCaps;
begin
  if (event <> nil) and
     (GstEventType(PG2DGstAudioFilterEventHead(event)^.etype) = GST_EVENT_CAPS) then
  begin
    LCaps := nil;
    if Assigned(_gst_event_parse_caps) then
      _gst_event_parse_caps(event, @LCaps);
    SetCurrentCaps(LCaps);
  end;

  Result := inherited SinkEvent(pad, parent, event);
end;

function TG2DAudioFilter.SinkQuery(
  pad: PGstPad;
  parent: PGstObject;
  query: PGstQuery
): gboolean;
begin
  Log(2, 'audio sink query');
  Result := inherited SinkQuery(pad, parent, query);
end;

function TG2DAudioFilter.ProcessBuffer(buffer: PGstBuffer): GstFlowReturn;
begin
  if FAudioInfo.Valid then
    Result := ProcessAudioFrame(buffer, FAudioInfo)
  else
  begin
    Log(1, 'audio info not valid; passing buffer unchanged');
    Result := inherited ProcessBuffer(buffer);
  end;
end;

end.

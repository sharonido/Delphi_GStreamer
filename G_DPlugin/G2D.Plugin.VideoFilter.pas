unit G2D.Plugin.VideoFilter;

{------------------------------------------------------------------------------
  G2D.Plugin.VideoFilter

  First reusable video-filter layer for Delphi GStreamer plugin elements.

  This class is still a passthrough at the buffer level. It only adds
  video-oriented CAPS awareness on top of TG2DBaseFilter.
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
  PG2DGstVideoFilterEventHead = ^TG2DGstVideoFilterEventHead;
  TG2DGstVideoFilterEventHead = record
    mini_object: GstMiniObject;
    etype: guint;
    timestamp: guint64;
    seqnum: guint32;
  end;

  PG2DVideoInfo = ^TG2DVideoInfo;
  TG2DVideoInfo = record
    Valid: Boolean;
    CapsText: string;
    MediaType: string;
    Format: string;
    Width: Integer;
    Height: Integer;
    FrameRateNum: Integer;
    FrameRateDen: Integer;
  end;

  TG2DVideoFilter = class(TG2DBaseFilter)
  private
    FCurrentCapsText: string;
    FVideoInfo: TG2DVideoInfo;
  protected
    function CapsToText(ACaps: PGstCaps): string; virtual;
    function BuildVideoInfo(ACaps: PGstCaps): TG2DVideoInfo; virtual;
    function VideoInfoToLogText(const AInfo: TG2DVideoInfo): string; virtual;
    function IsVideoCapsText(const ACapsText: string): Boolean; virtual;
    procedure SetCurrentCaps(ACaps: PGstCaps); virtual;
    function ProcessVideoFrame(
      buffer: PGstBuffer;
      const AInfo: TG2DVideoInfo
    ): GstFlowReturn; virtual;
  public
    property CurrentCapsText: string read FCurrentCapsText;
    property VideoInfo: TG2DVideoInfo read FVideoInfo;

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

type
  PG2DVideoInfoBuildContext = ^TG2DVideoInfoBuildContext;
  TG2DVideoInfoBuildContext = record
    Info: PG2DVideoInfo;
  end;

function G2DVideoFilterTrimValue(const AValue: string): string;
begin
  Result := Trim(AValue);
  if (Length(Result) >= 2) and
     (Result[1] = '"') and
     (Result[Length(Result)] = '"') then
    Result := Copy(Result, 2, Length(Result) - 2);
end;

function G2DVideoFilterParseInteger(const AValue: string): Integer;
begin
  Result := StrToIntDef(G2DVideoFilterTrimValue(AValue), 0);
end;

procedure G2DVideoFilterParseFraction(
  const AValue: string;
  out ANumerator: Integer;
  out ADenominator: Integer
);
var
  LText: string;
  LPos: Integer;
begin
  ANumerator := 0;
  ADenominator := 1;

  LText := G2DVideoFilterTrimValue(AValue);
  LPos := Pos('/', LText);
  if LPos <= 0 then
  begin
    ANumerator := StrToIntDef(LText, 0);
    Exit;
  end;

  ANumerator := StrToIntDef(Copy(LText, 1, LPos - 1), 0);
  ADenominator := StrToIntDef(Copy(LText, LPos + 1, MaxInt), 1);
  if ADenominator = 0 then
    ADenominator := 1;
end;

function G2DVideoFilterStructureField(
  field_id: GQuark;
  value: PGValue;
  user_data: gpointer
): gboolean; cdecl;
var
  LContext: PG2DVideoInfoBuildContext;
  LFieldName: string;
  LValue: string;
begin
  Result := 1;
  if (user_data = nil) or (value = nil) then
    Exit;

  LContext := PG2DVideoInfoBuildContext(user_data);
  if LContext^.Info = nil then
    Exit;

  LFieldName := DGQuarkToString(field_id);
  LValue := DGstValueSerialize(value);

  if SameText(LFieldName, 'format') then
    LContext^.Info^.Format := G2DVideoFilterTrimValue(LValue)
  else if SameText(LFieldName, 'width') then
    LContext^.Info^.Width := G2DVideoFilterParseInteger(LValue)
  else if SameText(LFieldName, 'height') then
    LContext^.Info^.Height := G2DVideoFilterParseInteger(LValue)
  else if SameText(LFieldName, 'framerate') then
    G2DVideoFilterParseFraction(
      LValue,
      LContext^.Info^.FrameRateNum,
      LContext^.Info^.FrameRateDen);
end;

function TG2DVideoFilter.CapsToText(ACaps: PGstCaps): string;
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

function TG2DVideoFilter.BuildVideoInfo(ACaps: PGstCaps): TG2DVideoInfo;
var
  LStructure: PGstStructure;
  LName: Pgchar;
  LContext: TG2DVideoInfoBuildContext;
begin
  FillChar(Result, SizeOf(Result), 0);
  Result.FrameRateDen := 1;
  Result.CapsText := CapsToText(ACaps);

  if (ACaps = nil) or
     not Assigned(_gst_caps_get_size) or
     not Assigned(_gst_caps_get_structure) or
     (_gst_caps_get_size(ACaps) = 0) then
    Exit;

  LStructure := _gst_caps_get_structure(ACaps, 0);
  if LStructure = nil then
    Exit;

  if Assigned(_gst_structure_get_name) then
  begin
    LName := _gst_structure_get_name(LStructure);
    if LName <> nil then
      Result.MediaType := UTF8ToString(AnsiString(PAnsiChar(LName)));
  end;

  if Assigned(_gst_structure_foreach) then
  begin
    LContext.Info := @Result;
    _gst_structure_foreach(LStructure, G2DVideoFilterStructureField, @LContext);
  end;

  Result.Valid :=
    (Result.MediaType <> '') and
    (Pos('video/', LowerCase(Result.MediaType)) = 1) and
    (Result.Width > 0) and
    (Result.Height > 0);
end;

function TG2DVideoFilter.VideoInfoToLogText(const AInfo: TG2DVideoInfo): string;
var
  LFps: Double;
begin
  Result := Format(
    'video info valid=%s media=%s format=%s width=%d height=%d fps=%d/%d',
    [
      BoolToStr(AInfo.Valid, True),
      AInfo.MediaType,
      AInfo.Format,
      AInfo.Width,
      AInfo.Height,
      AInfo.FrameRateNum,
      AInfo.FrameRateDen
    ]);

  if AInfo.FrameRateDen <> 0 then
  begin
    LFps := AInfo.FrameRateNum / AInfo.FrameRateDen;
    Result := Result + Format(' (%.3f)', [LFps]);
  end;
end;

function TG2DVideoFilter.IsVideoCapsText(const ACapsText: string): Boolean;
begin
  Result := Pos('video/', LowerCase(ACapsText)) > 0;
end;

procedure TG2DVideoFilter.SetCurrentCaps(ACaps: PGstCaps);
begin
  FVideoInfo := BuildVideoInfo(ACaps);
  FCurrentCapsText := FVideoInfo.CapsText;

  if FCurrentCapsText = '' then
    Log(1, 'video caps empty')
  else if IsVideoCapsText(FCurrentCapsText) then
    Log(1, 'video caps detected')
  else
    Log(1, 'caps are not video');

  Log(2, 'caps ' + FCurrentCapsText);
  Log(2, VideoInfoToLogText(FVideoInfo));
end;

function TG2DVideoFilter.ProcessVideoFrame(
  buffer: PGstBuffer;
  const AInfo: TG2DVideoInfo
): GstFlowReturn;
begin
  Log(2, Format(
    'process video frame format=%s width=%d height=%d fps=%d/%d',
    [
      AInfo.Format,
      AInfo.Width,
      AInfo.Height,
      AInfo.FrameRateNum,
      AInfo.FrameRateDen
    ]));
  Result := inherited ProcessBuffer(buffer);
end;

function TG2DVideoFilter.SinkEvent(
  pad: PGstPad;
  parent: PGstObject;
  event: PGstEvent
): gboolean;
var
  LCaps: PGstCaps;
begin
  if (event <> nil) and
     (GstEventType(PG2DGstVideoFilterEventHead(event)^.etype) = GST_EVENT_CAPS) then
  begin
    LCaps := nil;
    if Assigned(_gst_event_parse_caps) then
      _gst_event_parse_caps(event, @LCaps);
    SetCurrentCaps(LCaps);
  end;

  Result := inherited SinkEvent(pad, parent, event);
end;

function TG2DVideoFilter.SinkQuery(
  pad: PGstPad;
  parent: PGstObject;
  query: PGstQuery
): gboolean;
begin
  Log(2, 'video sink query');
  Result := inherited SinkQuery(pad, parent, query);
end;

function TG2DVideoFilter.ProcessBuffer(buffer: PGstBuffer): GstFlowReturn;
begin
  if FVideoInfo.Valid then
    Result := ProcessVideoFrame(buffer, FVideoInfo)
  else
  begin
    Log(1, 'video info not valid; passing buffer unchanged');
    Result := inherited ProcessBuffer(buffer);
  end;
end;

end.

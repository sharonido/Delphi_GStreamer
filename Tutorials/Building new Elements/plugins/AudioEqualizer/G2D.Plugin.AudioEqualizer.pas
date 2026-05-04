unit G2D.Plugin.AudioEqualizer;

{------------------------------------------------------------------------------
  G2D.Plugin.AudioEqualizer

  First audio DSP plugin element example.

  Element name:
    g2dequalizer

  Supported caps:
    audio/x-raw,format=F32LE,layout=interleaved

  Properties:
    filter  : inherited bypass switch
    band0..band7 : integer gain in dB, range -30..30
------------------------------------------------------------------------------}

interface

uses
  System.SysUtils,
  System.Math,
  System.SyncObjs,
  G2D.Glib.Types,
  G2D.Gobject.Types,
  G2D.Gobject.API,
  G2D.Gst.Types,
  G2D.Gst.API,
  G2D.Plugin.Types,
  G2D.Plugin.API,
  G2D.Plugin.Element,
  G2D.Plugin.BaseFilter,
  G2D.Plugin.AudioFilter;

const
  G2D_AUDIO_EQUALIZER_ELEMENT_NAME = 'g2dequalizer';
  G2D_AUDIO_EQUALIZER_TYPE_NAME    = 'G2DAudioEqualizer';

  G2D_AUDIO_EQUALIZER_BANDS = 8;
  G2D_AUDIO_EQUALIZER_PROP_BAND0 = 100;
  G2D_AUDIO_EQUALIZER_GAIN_MIN = -30;
  G2D_AUDIO_EQUALIZER_GAIN_MAX = 30;

  G2D_AUDIO_EQUALIZER_FREQ: array[0..G2D_AUDIO_EQUALIZER_BANDS - 1] of Double = (
    100, 250, 500, 1000, 2000, 4000, 8000, 16000);
  G2D_AUDIO_EQUALIZER_Q: array[0..G2D_AUDIO_EQUALIZER_BANDS - 1] of Double = (
    1.0, 1.0, 1.2, 1.2, 1.4, 1.4, 1.4, 1.4);

type
  PG2DAudioEqualizer = ^TG2DAudioEqualizer;
  TG2DAudioEqualizer = record
    Parent: GstElement;
  end;

  PG2DAudioEqualizerClass = ^TG2DAudioEqualizerClass;
  TG2DAudioEqualizerClass = record
    ParentClass: GstElementClass;
  end;

  TG2DBiquadCoeffs = record
    b0: Double;
    b1: Double;
    b2: Double;
    a1: Double;
    a2: Double;
  end;

  TG2DBiquadState = record
    x1: Double;
    x2: Double;
    y1: Double;
    y2: Double;
  end;

  TG2DEqualizerBand = record
    Coeffs: TG2DBiquadCoeffs;
    State: array[0..7] of TG2DBiquadState;
    GainDB: gint;
  end;

  TG2DEqualizerBands = array[0..G2D_AUDIO_EQUALIZER_BANDS - 1] of TG2DEqualizerBand;
  TG2DSingleArray = array[0..MaxInt div SizeOf(Single) - 1] of Single;
  PG2DSingleArray = ^TG2DSingleArray;

  TG2DAudioEqualizerFilter = class(TG2DAudioFilter)
  private
    FLockBands: TCriticalSection;
    FBands: TG2DEqualizerBands;
    FSampleRate: gint;
    procedure CalcPeakingEQ(
      var ACoeffs: TG2DBiquadCoeffs;
      AFreq: Double;
      AGainDB: Double;
      AQ: Double;
      ASampleRate: Integer
    );
    function ProcessBiquad(
      var AState: TG2DBiquadState;
      const ACoeffs: TG2DBiquadCoeffs;
      AInput: Double
    ): Double; inline;
    procedure RebuildCoefficients(ASampleRate: gint; AResetState: Boolean);
    procedure SetBandGain(ABand: Integer; AGainDB: gint);
    function GetBandGain(ABand: Integer): gint;
  protected
    function ProcessAudioFrame(
      buffer: PGstBuffer;
      const AInfo: TG2DAudioInfo
    ): GstFlowReturn; override;
  public
    constructor Create(AContext: PG2DBaseFilterContext); override;
    destructor Destroy; override;

    procedure SetProperty(
      property_id: guint;
      const value: PGValue;
      pspec: PGParamSpec
    ); override;
    procedure GetProperty(
      property_id: guint;
      value: PGValue;
      pspec: PGParamSpec
    ); override;
  end;

function G2DAudioEqualizerGetType: GType; cdecl;
function G2DRegisterAudioEqualizer(APlugin: PGstPlugin): gboolean; cdecl;

implementation

var
  G2DAudioEqualizerType: GType = 0;
  G2DAudioEqualizerDefinition: TG2DBaseFilterDefinition;
  G2DAudioEqualizerSinkTemplate: TG2DStaticPadTemplate;
  G2DAudioEqualizerSrcTemplate: TG2DStaticPadTemplate;
  G2DAudioEqualizerLongNameUtf8: UTF8String = 'G2D Audio Equalizer';
  G2DAudioEqualizerClassificationUtf8: UTF8String = 'Filter/Effect/Audio';
  G2DAudioEqualizerDescriptionUtf8: UTF8String = '8-band F32LE audio equalizer';
  G2DAudioEqualizerAuthorUtf8: UTF8String = 'G2D';

function G2DAudioEqualizerPropertyToBand(APropertyID: guint): Integer;
begin
  Result := Integer(APropertyID) - G2D_AUDIO_EQUALIZER_PROP_BAND0;
end;

function G2DAudioEqualizerClampGain(AGainDB: gint): gint;
begin
  Result := AGainDB;
  if Result < G2D_AUDIO_EQUALIZER_GAIN_MIN then
    Result := G2D_AUDIO_EQUALIZER_GAIN_MIN;
  if Result > G2D_AUDIO_EQUALIZER_GAIN_MAX then
    Result := G2D_AUDIO_EQUALIZER_GAIN_MAX;
end;

constructor TG2DAudioEqualizerFilter.Create(AContext: PG2DBaseFilterContext);
var
  I: Integer;
begin
  inherited Create(AContext);
  FLockBands := TCriticalSection.Create;
  FSampleRate := 44100;

  for I := 0 to G2D_AUDIO_EQUALIZER_BANDS - 1 do
  begin
    FBands[I].GainDB := 0;
    FillChar(FBands[I].State, SizeOf(FBands[I].State), 0);
  end;
  RebuildCoefficients(FSampleRate, True);
end;

destructor TG2DAudioEqualizerFilter.Destroy;
begin
  FreeAndNil(FLockBands);
  inherited Destroy;
end;

procedure TG2DAudioEqualizerFilter.CalcPeakingEQ(
  var ACoeffs: TG2DBiquadCoeffs;
  AFreq: Double;
  AGainDB: Double;
  AQ: Double;
  ASampleRate: Integer
);
var
  A: Double;
  W0: Double;
  Alpha: Double;
  CosW0: Double;
  A0: Double;
begin
  if ASampleRate <= 0 then
    ASampleRate := 44100;

  A := Power(10.0, AGainDB / 40.0);
  W0 := 2.0 * Pi * AFreq / ASampleRate;
  Alpha := Sin(W0) / (2.0 * AQ);
  CosW0 := Cos(W0);

  A0 := 1.0 + Alpha / A;
  ACoeffs.b0 := (1.0 + Alpha * A) / A0;
  ACoeffs.b1 := (-2.0 * CosW0) / A0;
  ACoeffs.b2 := (1.0 - Alpha * A) / A0;
  ACoeffs.a1 := (-2.0 * CosW0) / A0;
  ACoeffs.a2 := (1.0 - Alpha / A) / A0;
end;

function TG2DAudioEqualizerFilter.ProcessBiquad(
  var AState: TG2DBiquadState;
  const ACoeffs: TG2DBiquadCoeffs;
  AInput: Double
): Double;
begin
  Result :=
    ACoeffs.b0 * AInput +
    ACoeffs.b1 * AState.x1 +
    ACoeffs.b2 * AState.x2 -
    ACoeffs.a1 * AState.y1 -
    ACoeffs.a2 * AState.y2;

  AState.x2 := AState.x1;
  AState.x1 := AInput;
  AState.y2 := AState.y1;
  AState.y1 := Result;
end;

procedure TG2DAudioEqualizerFilter.RebuildCoefficients(
  ASampleRate: gint;
  AResetState: Boolean
);
var
  I: Integer;
begin
  if ASampleRate <= 0 then
    ASampleRate := 44100;

  FSampleRate := ASampleRate;
  for I := 0 to G2D_AUDIO_EQUALIZER_BANDS - 1 do
  begin
    CalcPeakingEQ(
      FBands[I].Coeffs,
      G2D_AUDIO_EQUALIZER_FREQ[I],
      FBands[I].GainDB,
      G2D_AUDIO_EQUALIZER_Q[I],
      FSampleRate);
    if AResetState then
      FillChar(FBands[I].State, SizeOf(FBands[I].State), 0);
  end;
end;

procedure TG2DAudioEqualizerFilter.SetBandGain(ABand: Integer; AGainDB: gint);
begin
  if (ABand < 0) or (ABand >= G2D_AUDIO_EQUALIZER_BANDS) then
    Exit;

  FLockBands.Acquire;
  try
    FBands[ABand].GainDB := G2DAudioEqualizerClampGain(AGainDB);
    CalcPeakingEQ(
      FBands[ABand].Coeffs,
      G2D_AUDIO_EQUALIZER_FREQ[ABand],
      FBands[ABand].GainDB,
      G2D_AUDIO_EQUALIZER_Q[ABand],
      FSampleRate);
    FillChar(FBands[ABand].State, SizeOf(FBands[ABand].State), 0);
  finally
    FLockBands.Release;
  end;
end;

function TG2DAudioEqualizerFilter.GetBandGain(ABand: Integer): gint;
begin
  Result := 0;
  if (ABand < 0) or (ABand >= G2D_AUDIO_EQUALIZER_BANDS) then
    Exit;

  FLockBands.Acquire;
  try
    Result := FBands[ABand].GainDB;
  finally
    FLockBands.Release;
  end;
end;

function TG2DAudioEqualizerFilter.ProcessAudioFrame(
  buffer: PGstBuffer;
  const AInfo: TG2DAudioInfo
): GstFlowReturn;
var
  LMapInfo: GstMapInfo;
  LSamples: PG2DSingleArray;
  LBands: TG2DEqualizerBands;
  LTotal: Integer;
  I: Integer;
  LBand: Integer;
  LChannel: Integer;
  LSample: Double;
begin
  if not SameText(AInfo.Format, 'F32LE') then
  begin
    Log(1, 'g2dequalizer unsupported format ' + AInfo.Format + '; passing unchanged');
    Exit(inherited ProcessAudioFrame(buffer, AInfo));
  end;

  if not SameText(AInfo.Layout, 'interleaved') then
  begin
    Log(1, 'g2dequalizer unsupported layout ' + AInfo.Layout + '; passing unchanged');
    Exit(inherited ProcessAudioFrame(buffer, AInfo));
  end;

  if (AInfo.Channels <= 0) or (AInfo.Channels > Length(FBands[0].State)) then
  begin
    Log(1, Format(
      'g2dequalizer unsupported channel count %d; passing unchanged',
      [AInfo.Channels]));
    Exit(inherited ProcessAudioFrame(buffer, AInfo));
  end;

  FillChar(LMapInfo, SizeOf(LMapInfo), 0);
  if _gst_buffer_map(buffer, @LMapInfo, GST_MAP_READWRITE) = 0 then
  begin
    Log(1, 'g2dequalizer failed to map buffer; passing unchanged');
    Exit(inherited ProcessAudioFrame(buffer, AInfo));
  end;

  try
    FLockBands.Acquire;
    try
      if AInfo.Rate <> FSampleRate then
        RebuildCoefficients(AInfo.Rate, True);
      LBands := FBands;
    finally
      FLockBands.Release;
    end;

    LSamples := PG2DSingleArray(LMapInfo.data);
    LTotal := Integer(LMapInfo.size) div SizeOf(Single);

    for I := 0 to LTotal - 1 do
    begin
      LChannel := I mod AInfo.Channels;
      LSample := LSamples[I];

      for LBand := 0 to G2D_AUDIO_EQUALIZER_BANDS - 1 do
        LSample := ProcessBiquad(
          LBands[LBand].State[LChannel],
          LBands[LBand].Coeffs,
          LSample);

      LSamples[I] := Single(Max(-1.0, Min(1.0, LSample)));
    end;

    FLockBands.Acquire;
    try
      FBands := LBands;
    finally
      FLockBands.Release;
    end;

    Log(2, Format('g2dequalizer processed samples=%d', [LTotal]));
  finally
    _gst_buffer_unmap(buffer, @LMapInfo);
  end;

  Result := inherited ProcessAudioFrame(buffer, AInfo);
end;

procedure TG2DAudioEqualizerFilter.SetProperty(
  property_id: guint;
  const value: PGValue;
  pspec: PGParamSpec
);
var
  LBand: Integer;
begin
  LBand := G2DAudioEqualizerPropertyToBand(property_id);
  if (LBand >= 0) and (LBand < G2D_AUDIO_EQUALIZER_BANDS) then
  begin
    SetBandGain(LBand, _g_value_get_int(value));
    Exit;
  end;

  inherited SetProperty(property_id, value, pspec);
end;

procedure TG2DAudioEqualizerFilter.GetProperty(
  property_id: guint;
  value: PGValue;
  pspec: PGParamSpec
);
var
  LBand: Integer;
begin
  LBand := G2DAudioEqualizerPropertyToBand(property_id);
  if (LBand >= 0) and (LBand < G2D_AUDIO_EQUALIZER_BANDS) then
  begin
    _g_value_set_int(value, GetBandGain(LBand));
    Exit;
  end;

  inherited GetProperty(property_id, value, pspec);
end;

procedure G2DPrepareAudioEqualizerDefinition;
begin
  FillChar(G2DAudioEqualizerDefinition, SizeOf(G2DAudioEqualizerDefinition), 0);

  G2DAudioEqualizerDefinition.ElementName := G2D_AUDIO_EQUALIZER_ELEMENT_NAME;
  G2DAudioEqualizerDefinition.TypeName := G2D_AUDIO_EQUALIZER_TYPE_NAME;
  G2DAudioEqualizerDefinition.Rank := GST_RANK_NONE;
  G2DAudioEqualizerDefinition.FilterClass := TG2DAudioEqualizerFilter;

  G2DAudioEqualizerDefinition.Metadata.LongName := 'G2D Audio Equalizer';
  G2DAudioEqualizerDefinition.Metadata.Classification := 'Filter/Effect/Audio';
  G2DAudioEqualizerDefinition.Metadata.Description :=
    '8-band F32LE audio equalizer';
  G2DAudioEqualizerDefinition.Metadata.Author := 'G2D';

  G2DAudioEqualizerDefinition.SinkPad.NameTemplate := 'sink';
  G2DAudioEqualizerDefinition.SinkPad.Direction := GST_PAD_SINK;
  G2DAudioEqualizerDefinition.SinkPad.Presence := GST_PAD_ALWAYS;
  G2DAudioEqualizerDefinition.SinkPad.Caps :=
    'audio/x-raw,format=F32LE,layout=interleaved';

  G2DAudioEqualizerDefinition.SrcPad.NameTemplate := 'src';
  G2DAudioEqualizerDefinition.SrcPad.Direction := GST_PAD_SRC;
  G2DAudioEqualizerDefinition.SrcPad.Presence := GST_PAD_ALWAYS;
  G2DAudioEqualizerDefinition.SrcPad.Caps :=
    'audio/x-raw,format=F32LE,layout=interleaved';
end;

procedure G2DAudioEqualizerInstallProperties(AObjectClass: PGObjectClass);
var
  I: Integer;
  LPropertyID: guint;
  LName: UTF8String;
  LNick: UTF8String;
  LBlurb: UTF8String;
  LPropertyName: string;
begin
  for I := 0 to G2D_AUDIO_EQUALIZER_BANDS - 1 do
  begin
    LPropertyID := G2D_AUDIO_EQUALIZER_PROP_BAND0 + guint(I);
    LPropertyName := Format('band%d', [I]);

    _g_object_class_install_property(
      AObjectClass,
      LPropertyID,
      _g_param_spec_int(
        G2DUtf8Pgchar(LPropertyName, LName),
        G2DUtf8Pgchar(Format('Band %d', [I]), LNick),
        G2DUtf8Pgchar(
          Format('Gain for EQ band %d in dB (-30..30)', [I]),
          LBlurb),
        G2D_AUDIO_EQUALIZER_GAIN_MIN,
        G2D_AUDIO_EQUALIZER_GAIN_MAX,
        0,
        G_PARAM_READWRITE));
  end;
end;

procedure G2DAudioEqualizerClassInit(g_class: gpointer; class_data: gpointer); cdecl;
var
  LObjectClass: PGObjectClass;
begin
  G2DBaseFilterClassInit(
    PGstElementClass(g_class),
    G2DAudioEqualizerDefinition,
    G2DAudioEqualizerSinkTemplate,
    G2DAudioEqualizerSrcTemplate);

  LObjectClass := @PGstElementClass(g_class)^.parent_class.parent_class.parent_class;
  G2DAudioEqualizerInstallProperties(LObjectClass);

  _gst_element_class_set_static_metadata(
    PGstElementClass(g_class),
    Pgchar(PAnsiChar(G2DAudioEqualizerLongNameUtf8)),
    Pgchar(PAnsiChar(G2DAudioEqualizerClassificationUtf8)),
    Pgchar(PAnsiChar(G2DAudioEqualizerDescriptionUtf8)),
    Pgchar(PAnsiChar(G2DAudioEqualizerAuthorUtf8)));
end;

procedure G2DAudioEqualizerInit(instance: PGTypeInstance; g_class: gpointer); cdecl;
begin
  G2DBaseFilterInitInstance(
    @G2DAudioEqualizerDefinition,
    instance,
    G2DAudioEqualizerSinkTemplate,
    G2DAudioEqualizerSrcTemplate);
end;

function G2DAudioEqualizerGetType: GType; cdecl;
var
  LTypeInfo: GTypeInfo;
  LParentQuery: GTypeQuery;
  LTypeName: UTF8String;
begin
  if G2DAudioEqualizerType <> G_TYPE_INVALID then
    Exit(G2DAudioEqualizerType);

  G2D_RequirePluginAPI;

  FillChar(LTypeInfo, SizeOf(LTypeInfo), 0);
  FillChar(LParentQuery, SizeOf(LParentQuery), 0);
  _g_type_query(_gst_element_get_type, @LParentQuery);

  LTypeInfo.class_size := SizeOf(TG2DAudioEqualizerClass);
  LTypeInfo.class_init := G2DAudioEqualizerClassInit;
  LTypeInfo.instance_size := LParentQuery.instance_size;
  LTypeInfo.instance_init := G2DAudioEqualizerInit;

  G2DAudioEqualizerType := _g_type_register_static(
    _gst_element_get_type,
    G2DUtf8Pgchar(G2D_AUDIO_EQUALIZER_TYPE_NAME, LTypeName),
    @LTypeInfo,
    0);

  Result := G2DAudioEqualizerType;
end;

function G2DRegisterAudioEqualizer(APlugin: PGstPlugin): gboolean; cdecl;
begin
  Result := G2DRegisterElement(
    APlugin,
    G2D_AUDIO_EQUALIZER_ELEMENT_NAME,
    G2DAudioEqualizerDefinition.Rank,
    G2DAudioEqualizerGetType);
end;

initialization
  G2DPrepareAudioEqualizerDefinition;

end.

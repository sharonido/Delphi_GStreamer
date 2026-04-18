unit G2D.GstPipeline.DOO;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  G2D.Glib.Types,
  G2D.Gobject.Types,
  G2D.Gst.Types,
  G2D.GstElement.DOO,
  G2D.GstBin.DOO,
  G2D.GstBus.DOO,
  G2D.Glib.API,
  G2D.Gobject.API,
  G2D.Gst.API,
  G2D.Gobject.DOO;

type
  EG2DGstPipelineDOOError = class(Exception);

  TGstPipelineRef = class(TGstBinRef)
  private
    FElements: TObjectDictionary<string, TGstElementRef>;
    procedure ClearElements;
    procedure EnsureElements;
  protected
    procedure CheckPipelineHandle;
  public
    constructor Create(AHandle: PGstPipeline; AAddRef: Boolean = False; AOwnsRef: Boolean = True);
    destructor Destroy; override;

    class function New(const AName: string): TGstPipelineRef;
    class function Wrap(AHandle: PGstPipeline; AAddRef: Boolean = False; AOwnsRef: Boolean = True): TGstPipelineRef;
    class function Parse(const APipelineDescription: string): TGstPipelineRef;

    function PipelineHandle: PGstPipeline;

    function GetBus: TGstBusRef;

    function SetState(AState: GstState): GstStateChangeReturn;
    function GetState(out AState, APending: GstState; ATimeout: GstClockTime = GstClockTime(0)): GstStateChangeReturn;

    procedure MakeElements(const ADescription: string);
    function MakeElement(const AFactory, AName: string): TGstElementRef;
    function GetElement(const AName: string): TGstElementRef;
    function GetByName(const AName: string): TGstElementRef; reintroduce;
    function HasElement(const AName: string): Boolean;

    function AddElement(const AName: string): Boolean;
    function AddElements(const ANames: array of string): Boolean;

    function LinkElements(const AFromName, AToName: string): Boolean;
    function LinkMany(const ANames: array of string): Boolean;

    procedure SetPropertyString(const AElementName, APropName, AValue: string);
    procedure SetPropertyInt(const AElementName, APropName: string; AValue: Integer);
    procedure SetPropertyBool(const AElementName, APropName: string; AValue: Boolean);
    procedure SetPropertyFloat(const AElementName, APropName: string; AValue: Single);  { Tutorial 7 }
    procedure SetPropertyCaps(const AElementName, APropName: string; ACaps: gpointer);  { Tutorial 8 }

    function ConnectSignal(const AElementName, ASignalName: string;
      ACallback: Pointer; AUserData: Pointer = nil): Boolean;
  end;

implementation

{ TGstPipelineRef }

procedure TGstPipelineRef.CheckPipelineHandle;
begin
  if PipelineHandle = nil then
    raise EG2DGstPipelineDOOError.Create('TGstPipelineRef handle is nil');
end;

procedure TGstPipelineRef.EnsureElements;
begin
  if FElements = nil then
    FElements := TObjectDictionary<string, TGstElementRef>.Create([doOwnsValues]);
end;

procedure TGstPipelineRef.ClearElements;
begin
  if FElements <> nil then
    FElements.Clear;
end;

constructor TGstPipelineRef.Create(AHandle: PGstPipeline; AAddRef: Boolean; AOwnsRef: Boolean);
begin
  inherited Create(PGstBin(AHandle), AAddRef, AOwnsRef);
  FElements := TObjectDictionary<string, TGstElementRef>.Create([doOwnsValues]);
end;

destructor TGstPipelineRef.Destroy;
begin
  ClearElements;
  FreeAndNil(FElements);
  inherited;
end;

class function TGstPipelineRef.New(const AName: string): TGstPipelineRef;
var
  P: PGstElement;
  LName: UTF8String;
begin
  if AName = '' then
    P := _gst_pipeline_new(nil)
  else
  begin
    LName := UTF8String(AName);
    P := _gst_pipeline_new(Pgchar(PAnsiChar(LName)));
  end;

  if P = nil then
    Exit(nil);

  Result := TGstPipelineRef.Wrap(PGstPipeline(P), False, True);
end;

class function TGstPipelineRef.Wrap(AHandle: PGstPipeline; AAddRef: Boolean; AOwnsRef: Boolean): TGstPipelineRef;
begin
  Result := TGstPipelineRef.Create(AHandle, AAddRef, AOwnsRef);
end;

class function TGstPipelineRef.Parse(const APipelineDescription: string): TGstPipelineRef;
var
  LElem: TGstElementRef;
begin
  LElem := TGstElementRef.Parse(APipelineDescription);
  if LElem = nil then
    Exit(nil);

  try
    Result := TGstPipelineRef.Wrap(PGstPipeline(LElem.ElementHandle), True, True);
  finally
    LElem.Free;
  end;
end;

function TGstPipelineRef.PipelineHandle: PGstPipeline;
begin
  Result := PGstPipeline(BinHandle);
end;

function TGstPipelineRef.GetBus: TGstBusRef;
var
  LBus: PGstBus;
begin
  CheckPipelineHandle;
  LBus := _gst_element_get_bus(PGstElement(PipelineHandle));
  if LBus = nil then
    Exit(nil);
  Result := TGstBusRef.Wrap(LBus, False, True);
end;

function TGstPipelineRef.SetState(AState: GstState): GstStateChangeReturn;
begin
  CheckPipelineHandle;
  Result := _gst_element_set_state(PGstElement(PipelineHandle), AState);
end;

function TGstPipelineRef.GetState(out AState, APending: GstState; ATimeout: GstClockTime): GstStateChangeReturn;
begin
  CheckPipelineHandle;
  Result := _gst_element_get_state(
              PGstElement(PipelineHandle),
              @AState,
              @APending,
              ATimeout
            );
end;

Procedure GstDescriptionPasrer(const ADescription:string; var
  LElements, LTokens, LPairs : TArray<string>);
begin

end;

procedure TGstPipelineRef.MakeElements(const ADescription: string);
var
  LElements      : TArray<string>;
  LTokens        : TArray<string>;
  LPairs         : TArray<string>;
  LFactory       : string;
  LName          : string;
  LKey           : string;
  LValue         : string;
  LPair          : string;
  LElem          : TGstElementRef;
  I, J           : Integer;
  LAutoIndex     : Integer;
  LCandidateName : string;
  LKeyUtf8       : UTF8String;
  LValueUtf8     : UTF8String;
begin
  CheckPipelineHandle;
  EnsureElements;

  { Split description by '!' into individual element descriptions }
  LElements := ADescription.Split(['!']);

  for I := 0 to High(LElements) do
  begin
    { Split each element description by whitespace }
    LTokens := LElements[I].Trim.Split([' ', #9],
                 TStringSplitOptions.ExcludeEmpty);

    if Length(LTokens) = 0 then
      Continue;

    { First token is the factory name }
    LFactory := LTokens[0].Trim;
    if LFactory = '' then
      Continue;

    { Look for name=xxx among the key=value pairs }
    LName := '';
    for J := 1 to High(LTokens) do
    begin
      LPairs := LTokens[J].Split(['=']);
      if (Length(LPairs) = 2) and
         (LPairs[0].Trim.ToLower = 'name') then
      begin
        LName := LPairs[1].Trim;
        Break;
      end;
    end;

    { Auto-generate a name if none was given:
      try factoryname_0, factoryname_1, ... until not already in FElements }
    if LName = '' then
    begin
      LAutoIndex := 0;
      repeat
        LCandidateName := Format('%s_%d', [LFactory, LAutoIndex]);
        Inc(LAutoIndex);
      until not FElements.ContainsKey(LCandidateName);
      LName := LCandidateName;
    end;

    { Create the element (stored in FElements) }
    LElem := MakeElement(LFactory, LName);
    if LElem = nil then
      raise EG2DGstPipelineDOOError.CreateFmt(
        'MakeElements: failed to create element "%s" (factory "%s")',
        [LName, LFactory]);
    LElem.Free;  { MakeElement addref's - free our ref, FElements keeps its own }

    { Apply all key=value properties except name= }
    for J := 1 to High(LTokens) do
    begin
      LPair  := LTokens[J].Trim;
      LPairs := LPair.Split(['=']);
      if Length(LPairs) <> 2 then
        Continue;
      LKey   := LPairs[0].Trim;
      LValue := LPairs[1].Trim;
      if LKey.ToLower = 'name' then
        Continue;

      { Use GStreamer's own arg parser - handles ints, floats, bools,
        enums, flags and caps strings correctly }
      LElem := GetElement(LName);
      if LElem <> nil then
      try
        LKeyUtf8   := UTF8String(LKey);
        LValueUtf8 := UTF8String(LValue);
        _gst_util_set_object_arg(
          gpointer(LElem.ElementHandle),
          Pgchar(PAnsiChar(LKeyUtf8)),
          Pgchar(PAnsiChar(LValueUtf8))
        );
      finally
        LElem.Free;
      end;
    end;
  end;
end;

function TGstPipelineRef.MakeElement(const AFactory, AName: string): TGstElementRef;
var
  LStored: TGstElementRef;
  LCreated: TGstElementRef;
begin
  CheckPipelineHandle;
  EnsureElements;

  if FElements.TryGetValue(AName, LStored) then
  begin
    Result := TGstElementRef.Wrap(LStored.ElementHandle, True, True);
    Exit;
  end;

  LCreated := TGstElementRef.FactoryMake(AFactory, AName);
  if LCreated = nil then
    Exit(nil);

  FElements.Add(AName, LCreated);
  Result := TGstElementRef.Wrap(LCreated.ElementHandle, True, True);
end;

function TGstPipelineRef.GetElement(const AName: string): TGstElementRef;
var
  LStored: TGstElementRef;
  LFound: TGstElementRef;
  LCache: TGstElementRef;
begin
  CheckPipelineHandle;
  EnsureElements;

  if FElements.TryGetValue(AName, LStored) then
  begin
    Result := TGstElementRef.Wrap(LStored.ElementHandle, True, True);
    Exit;
  end;

  LFound := inherited GetByName(AName);
  if LFound = nil then
    Exit(nil);

  LCache := TGstElementRef.Wrap(LFound.ElementHandle, True, True);
  FElements.AddOrSetValue(AName, LCache);

  Result := LFound;
end;

function TGstPipelineRef.GetByName(const AName: string): TGstElementRef;
begin
  Result := GetElement(AName);
end;

function TGstPipelineRef.HasElement(const AName: string): Boolean;
var
  LElement: TGstElementRef;
begin
  LElement := GetElement(AName);
  try
    Result := LElement <> nil;
  finally
    LElement.Free;
  end;
end;

function TGstPipelineRef.AddElement(const AName: string): Boolean;
var
  LStored: TGstElementRef;
begin
  CheckPipelineHandle;
  EnsureElements;

  Result := False;
  if not FElements.TryGetValue(AName, LStored) then
    Exit;

  Result := inherited Add(LStored);
end;

function TGstPipelineRef.AddElements(const ANames: array of string): Boolean;
var
  I: Integer;
begin
  Result := True;
  for I := Low(ANames) to High(ANames) do
    if not AddElement(ANames[I]) then
      Exit(False);
end;

function TGstPipelineRef.LinkElements(const AFromName, AToName: string): Boolean;
var
  LFromStored: TGstElementRef;
  LToStored: TGstElementRef;
begin
  CheckPipelineHandle;
  EnsureElements;

  Result := False;

  if not FElements.TryGetValue(AFromName, LFromStored) then
    Exit;

  if not FElements.TryGetValue(AToName, LToStored) then
    Exit;

  Result := LFromStored.Link(LToStored);
end;

function TGstPipelineRef.LinkMany(const ANames: array of string): Boolean;
var
  I: Integer;
begin
  Result := True;

  if Length(ANames) < 2 then
    Exit(True);

  for I := Low(ANames) to High(ANames) - 1 do
    if not LinkElements(ANames[I], ANames[I + 1]) then
      Exit(False);
end;

procedure TGstPipelineRef.SetPropertyString(const AElementName, APropName, AValue: string);
var
  LStored: TGstElementRef;
begin
  LStored := GetElement(AElementName);
  LStored.SetPropertyString(APropName, AValue);
end;

procedure TGstPipelineRef.SetPropertyInt(const AElementName, APropName: string; AValue: Integer);
var
  LStored: TGstElementRef;
begin
  CheckPipelineHandle;
  EnsureElements;

  if not FElements.TryGetValue(AElementName, LStored) then
    raise EG2DGstPipelineDOOError.CreateFmt('Element "%s" not found', [AElementName]);

  LStored.SetPropertyInt(APropName, AValue);
end;

procedure TGstPipelineRef.SetPropertyBool(const AElementName, APropName: string; AValue: Boolean);
var
  LStored: TGstElementRef;
begin
  CheckPipelineHandle;
  EnsureElements;

  if not FElements.TryGetValue(AElementName, LStored) then
    raise EG2DGstPipelineDOOError.CreateFmt('Element "%s" not found', [AElementName]);

  LStored.SetPropertyBool(APropName, AValue);
end;

procedure TGstPipelineRef.SetPropertyFloat(const AElementName, APropName: string; AValue: Single);
var
  LStored: TGstElementRef;
begin
  CheckPipelineHandle;
  EnsureElements;

  if not FElements.TryGetValue(AElementName, LStored) then
    raise EG2DGstPipelineDOOError.CreateFmt('Element "%s" not found', [AElementName]);

  LStored.SetPropertyFloat(APropName, AValue);
end;

procedure TGstPipelineRef.SetPropertyCaps(const AElementName, APropName: string; ACaps: gpointer);
var
  LStored: TGstElementRef;
begin
  CheckPipelineHandle;
  EnsureElements;

  if not FElements.TryGetValue(AElementName, LStored) then
    raise EG2DGstPipelineDOOError.CreateFmt('Element "%s" not found', [AElementName]);

  LStored.SetPropertyCaps(APropName, ACaps);
end;

function TGstPipelineRef.ConnectSignal(const AElementName, ASignalName: string;
  ACallback: Pointer; AUserData: Pointer): Boolean;
var
  LStored: TGstElementRef;
begin
  CheckPipelineHandle;
  EnsureElements;

  Result := False;

  if not FElements.TryGetValue(AElementName, LStored) then
    Exit;

  Result := LStored.ConnectSignal(ASignalName, ACallback, AUserData) <> 0;
end;

end.

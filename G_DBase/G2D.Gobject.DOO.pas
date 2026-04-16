unit G2D.Gobject.DOO;

interface

uses
  System.SysUtils,
  G2D.Glib.Types,
  G2D.Gobject.Types,
  G2D.Gobject.API;

type
  EG2DGobjectOOError = class(Exception);

  TGObjectRef = class
  private
    FHandle: PGObject;
    FOwnsRef: Boolean;
  protected
    procedure CheckHandle;
  public
    constructor Create(AHandle: PGObject; AAddRef: Boolean = False; AOwnsRef: Boolean = True);
    destructor Destroy; override;

    class function Wrap(AHandle: PGObject; AAddRef: Boolean = False; AOwnsRef: Boolean = True): TGObjectRef;

    function Handle: PGObject;

    procedure Ref;
    procedure Unref;
    procedure RefSink;
    function IsFloating: Boolean;

    function GetData(const AKey: string): Pointer;
    procedure SetData(const AKey: string; AData: Pointer);

    function ConnectSignal(const ASignalName: string; ACallback: Pointer; AUserData: Pointer = nil): gulong;

    procedure SetPropertyInt(const AName: string; AValue: Integer);
    procedure SetPropertyBool(const AName: string; AValue: Boolean);
    procedure SetPropertyString(const AName, AValue: string);
    procedure SetPropertyDouble(const AName: string; AValue: Double);
    procedure SetPropertyFloat(const AName: string; AValue: Single);
    procedure SetPropertyEnum(const AName: string; AValue: Integer);
    procedure SetPropertyCaps(const AName: string; ACaps: gpointer);  { Tutorial 8 }

    function GetPropertyDouble(const AName: string): Double;
    function GetPropertyFloat(const AName: string): Single;
    function GetPropertyEnum(const AName: string): Integer;

    function GetPropertyInt(const AName: string): Integer;
    function GetPropertyBool(const AName: string): Boolean;
    function GetPropertyString(const AName: string): string;

    property OwnsRef: Boolean read FOwnsRef write FOwnsRef;
  end;

function Utf8Pgchar(const S: string): Pgchar;
function PgcharToString(P: Pgchar): string;

implementation

function Utf8Pgchar(const S: string): Pgchar;
begin
  Result := Pgchar(PAnsiChar(UTF8String(S)));
end;

function PgcharToString(P: Pgchar): string;
begin
  if P = nil then
    Exit('');
  Result := string(UTF8String(AnsiString(P)));
end;

{ TGObjectRef }

procedure TGObjectRef.CheckHandle;
begin
  if FHandle = nil then
    raise EG2DGobjectOOError.Create('TGObjectRef handle is nil');
end;

constructor TGObjectRef.Create(AHandle: PGObject; AAddRef: Boolean; AOwnsRef: Boolean);
begin
  inherited Create;

  FHandle := AHandle;
  FOwnsRef := AOwnsRef;

  if FHandle <> nil then
  begin
    if AAddRef then
      _g_object_ref(gpointer(FHandle));
  end;
end;

destructor TGObjectRef.Destroy;
begin
  if FOwnsRef and (FHandle <> nil) then
    _g_object_unref(gpointer(FHandle));

  FHandle := nil;

  inherited;
end;

class function TGObjectRef.Wrap(AHandle: PGObject; AAddRef: Boolean; AOwnsRef: Boolean): TGObjectRef;
begin
  Result := TGObjectRef.Create(AHandle, AAddRef, AOwnsRef);
end;

function TGObjectRef.Handle: PGObject;
begin
  Result := FHandle;
end;

procedure TGObjectRef.Ref;
begin
  CheckHandle;
  _g_object_ref(gpointer(FHandle));
end;

procedure TGObjectRef.Unref;
begin
  CheckHandle;
  _g_object_unref(gpointer(FHandle));
end;

procedure TGObjectRef.RefSink;
begin
  CheckHandle;
  _g_object_ref_sink(gpointer(FHandle));
end;

function TGObjectRef.IsFloating: Boolean;
begin
  CheckHandle;
  Result := _g_object_is_floating(gpointer(FHandle)) <> 0;
end;

function TGObjectRef.GetData(const AKey: string): Pointer;
var
  LKey: UTF8String;
begin
  CheckHandle;
  LKey := UTF8String(AKey);
  Result := _g_object_get_data(FHandle, Pgchar(PAnsiChar(LKey)));
end;

procedure TGObjectRef.SetData(const AKey: string; AData: Pointer);
var
  LKey: UTF8String;
begin
  CheckHandle;
  LKey := UTF8String(AKey);
  _g_object_set_data(FHandle, Pgchar(PAnsiChar(LKey)), AData);
end;

function TGObjectRef.ConnectSignal(const ASignalName: string; ACallback: Pointer; AUserData: Pointer): gulong;
var
  LSignalName: UTF8String;
begin
  CheckHandle;

  if not Assigned(_g_signal_connect_data) then
    raise EG2DGobjectOOError.Create('g_signal_connect_data is not loaded');

  if ACallback = nil then
    raise EG2DGobjectOOError.Create('ConnectSignal: callback is nil');

  LSignalName := UTF8String(ASignalName);

  Result := _g_signal_connect_data(
              gpointer(FHandle),
              Pgchar(PAnsiChar(LSignalName)),
              GCallback(ACallback),
              AUserData,
              nil,
              0
            );
end;

// set Property in Object
procedure TGObjectRef.SetPropertyInt(const AName: string; AValue: Integer);
var
  V: GValue;
  LName: UTF8String;
begin
  if FHandle = nil then
    raise EG2DGobjectOOError.Create('SetPropertyInt: FHandle is nil');

  FillChar(V, SizeOf(V), 0);
  LName := UTF8String(AName);

  _g_value_init(@V, G_TYPE_INT);
  try
    _g_value_set_int(@V, AValue);
    _g_object_set_property(PGObject(FHandle), Pgchar(PAnsiChar(LName)), @V);
  finally
    _g_value_unset(@V);
  end;
end;

procedure TGObjectRef.SetPropertyBool(const AName: string; AValue: Boolean);
var
  V: GValue;
  B: gboolean;
  LName: UTF8String;
begin
  if FHandle = nil then
    raise EG2DGobjectOOError.Create('SetPropertyBool: FHandle is nil');

  FillChar(V, SizeOf(V), 0);
  LName := UTF8String(AName);

  if AValue then
    B := 1
  else
    B := 0;

  _g_value_init(@V, G_TYPE_BOOLEAN);
  try
    _g_value_set_boolean(@V, B);
    _g_object_set_property(PGObject(FHandle), Pgchar(PAnsiChar(LName)), @V);
  finally
    _g_value_unset(@V);
  end;
end;

procedure TGObjectRef.SetPropertyString(const AName, AValue: string);
var
  V: GValue;
  LName: UTF8String;
  LValue: UTF8String;
begin
  if FHandle = nil then
    raise EG2DGobjectOOError.Create('SetPropertyString: FHandle is nil');

  FillChar(V, SizeOf(V), 0);

  LName := UTF8String(AName);
  LValue := UTF8String(AValue);

  _g_value_init(@V, G_TYPE_STRING);
  try
    _g_value_set_string(@V, Pgchar(PAnsiChar(LValue)));
    _g_object_set_property(PGObject(FHandle), Pgchar(PAnsiChar(LName)), @V);
  finally
    _g_value_unset(@V);
  end;
end;

function TGObjectRef.GetPropertyInt(const AName: string): Integer;
var
  V: GValue;
  LName: UTF8String;
begin
  if FHandle = nil then
    raise EG2DGobjectOOError.Create('GetPropertyInt: FHandle is nil');

  FillChar(V, SizeOf(V), 0);
  LName := UTF8String(AName);

  _g_value_init(@V, G_TYPE_INT);
  try
    _g_object_get_property(PGObject(FHandle), Pgchar(PAnsiChar(LName)), @V);
    Result := _g_value_get_int(@V);
  finally
    _g_value_unset(@V);
  end;
end;

function TGObjectRef.GetPropertyBool(const AName: string): Boolean;
var
  V: GValue;
  LName: UTF8String;
begin
  if FHandle = nil then
    raise EG2DGobjectOOError.Create('GetPropertyBool: FHandle is nil');

  FillChar(V, SizeOf(V), 0);
  LName := UTF8String(AName);

  _g_value_init(@V, G_TYPE_BOOLEAN);
  try
    _g_object_get_property(PGObject(FHandle), Pgchar(PAnsiChar(LName)), @V);
    Result := _g_value_get_boolean(@V) <> 0;
  finally
    _g_value_unset(@V);
  end;
end;

function TGObjectRef.GetPropertyString(const AName: string): string;
var
  V: GValue;
  P: Pgchar;
  LName: UTF8String;
begin
  if FHandle = nil then
    raise EG2DGobjectOOError.Create('GetPropertyString: FHandle is nil');

  FillChar(V, SizeOf(V), 0);
  LName := UTF8String(AName);

  _g_value_init(@V, G_TYPE_STRING);
  try
    _g_object_get_property(PGObject(FHandle), Pgchar(PAnsiChar(LName)), @V);
    P := _g_value_get_string(@V);
    Result := PgcharToString(P);
  finally
    _g_value_unset(@V);
  end;
end;

procedure TGObjectRef.SetPropertyDouble(const AName: string; AValue: Double);
var
  V: GValue;
  LName: UTF8String;
begin
  if FHandle = nil then
    raise EG2DGobjectOOError.Create('SetPropertyDouble: FHandle is nil');

  FillChar(V, SizeOf(V), 0);
  LName := UTF8String(AName);

  _g_value_init(@V, G_TYPE_DOUBLE);
  try
    _g_value_set_double(@V, AValue);
    _g_object_set_property(PGObject(FHandle), Pgchar(PAnsiChar(LName)), @V);
  finally
    _g_value_unset(@V);
  end;
end;

procedure TGObjectRef.SetPropertyFloat(const AName: string; AValue: Single);
var
  V: GValue;
  LName: UTF8String;
begin
  if FHandle = nil then
    raise EG2DGobjectOOError.Create('SetPropertyFloat: FHandle is nil');

  FillChar(V, SizeOf(V), 0);
  LName := UTF8String(AName);

  _g_value_init(@V, G_TYPE_FLOAT);
  try
    _g_value_set_float(@V, AValue);
    _g_object_set_property(PGObject(FHandle), Pgchar(PAnsiChar(LName)), @V);
  finally
    _g_value_unset(@V);
  end;
end;

procedure TGObjectRef.SetPropertyEnum(const AName: string; AValue: Integer);
begin
  SetPropertyInt(AName, AValue);
end;

procedure TGObjectRef.SetPropertyCaps(const AName: string; ACaps: gpointer);
var
  LName: UTF8String;
begin
  if FHandle = nil then
    raise EG2DGobjectOOError.Create('SetPropertyCaps: FHandle is nil');

  LName := UTF8String(AName);
  _g_object_set(gpointer(FHandle), Pgchar(PAnsiChar(LName)), ACaps, nil);
end;

function TGObjectRef.GetPropertyDouble(const AName: string): Double;
var
  V: GValue;
  LName: UTF8String;
begin
  if FHandle = nil then
    raise EG2DGobjectOOError.Create('GetPropertyDouble: FHandle is nil');

  FillChar(V, SizeOf(V), 0);
  LName := UTF8String(AName);

  _g_value_init(@V, G_TYPE_DOUBLE);
  try
    _g_object_get_property(PGObject(FHandle), Pgchar(PAnsiChar(LName)), @V);
    Result := _g_value_get_double(@V);
  finally
    _g_value_unset(@V);
  end;
end;

function TGObjectRef.GetPropertyFloat(const AName: string): Single;
var
  V: GValue;
  LName: UTF8String;
begin
  if FHandle = nil then
    raise EG2DGobjectOOError.Create('GetPropertyFloat: FHandle is nil');

  FillChar(V, SizeOf(V), 0);
  LName := UTF8String(AName);

  _g_value_init(@V, G_TYPE_FLOAT);
  try
    _g_object_get_property(PGObject(FHandle), Pgchar(PAnsiChar(LName)), @V);
    Result := _g_value_get_float(@V);
  finally
    _g_value_unset(@V);
  end;
end;

function TGObjectRef.GetPropertyEnum(const AName: string): Integer;
begin
  Result := GetPropertyInt(AName);
end;

end.

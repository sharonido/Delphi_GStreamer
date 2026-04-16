unit G2D.GstBus.DOO;

interface

uses
  System.SysUtils,
  G2D.Glib.Types,
  G2D.Gobject.Types,
  G2D.Gst.Types,
  G2D.GObject.DOO,
  G2D.GstObject.DOO,
  G2D.GstMessage.DOO,
  G2D.Glib.API,
  G2D.Gobject.API,
  G2D.Gst.API;

type
  EG2DGstBusDOOError = class(Exception);

  TGstBusRef = class(TGstObjectRef)
  protected
    procedure CheckBusHandle;
  public
    constructor Create(AHandle: PGstBus; AAddRef: Boolean = False; AOwnsRef: Boolean = True);
    class function Wrap(AHandle: PGstBus; AAddRef: Boolean = False; AOwnsRef: Boolean = True): TGstBusRef;

    function BusHandle: PGstBus;

    function HavePending: Boolean;

    function Pop: PGstMessage;
    function TimedPopFiltered(ATimeout: GstClockTime; ATypes: GstMessageType): PGstMessage;

    function PopMessage: TGstMessageRef;
    function TimedPopMessage(ATimeout: GstClockTime; ATypes: GstMessageType): TGstMessageRef;

    class function MessageTypeName(AMessage: PGstMessage): string; overload; static;
    class function MessageTypeName(AType: GstMessageType): string; overload; static;
    class function MessageTypeName(AMessage: TGstMessageRef): string; overload; static;

    class function StateToString(AState: GstState): string; static;

    class procedure ParseErrorMessage(
      AMessage: PGstMessage;
      out AErrorText: string;
      out ADebugText: string
    ); overload; static;

    class procedure ParseErrorMessage(
      AMessage: TGstMessageRef;
      out AErrorText: string;
      out ADebugText: string
    ); overload; static;

    class procedure ParseWarningMessage(
      AMessage: PGstMessage;
      out AWarningText: string;
      out ADebugText: string
    ); overload; static;

    class procedure ParseWarningMessage(
      AMessage: TGstMessageRef;
      out AWarningText: string;
      out ADebugText: string
    ); overload; static;

    class procedure ParseStateChangedMessage(
      AMessage: PGstMessage;
      out AOldState: GstState;
      out ANewState: GstState;
      out APendingState: GstState
    ); overload; static;

    class procedure ParseStateChangedMessage(
      AMessage: TGstMessageRef;
      out AOldState: GstState;
      out ANewState: GstState;
      out APendingState: GstState
    ); overload; static;
  end;

implementation
{ TGstBusRef }

procedure TGstBusRef.CheckBusHandle;
begin
  if BusHandle = nil then
    raise EG2DGstBusDOOError.Create('TGstBusRef handle is nil');
end;

constructor TGstBusRef.Create(AHandle: PGstBus; AAddRef: Boolean; AOwnsRef: Boolean);
begin
  inherited Create(PGstObject(AHandle), AAddRef, AOwnsRef);
end;

class function TGstBusRef.Wrap(AHandle: PGstBus; AAddRef: Boolean; AOwnsRef: Boolean): TGstBusRef;
begin
  Result := TGstBusRef.Create(AHandle, AAddRef, AOwnsRef);
end;

function TGstBusRef.BusHandle: PGstBus;
begin
  Result := PGstBus(GstHandle);
end;

function TGstBusRef.HavePending: Boolean;
begin
  CheckBusHandle;
  Result := _gst_bus_have_pending(BusHandle) <> 0;
end;

function TGstBusRef.Pop: PGstMessage;
begin
  CheckBusHandle;
  Result := _gst_bus_pop(BusHandle);
end;

function TGstBusRef.TimedPopFiltered(ATimeout: GstClockTime; ATypes: GstMessageType): PGstMessage;
begin
  CheckBusHandle;
  Result := _gst_bus_timed_pop_filtered(BusHandle, ATimeout, ATypes);
end;

function TGstBusRef.PopMessage: TGstMessageRef;
var
  LMsg: PGstMessage;
begin
  LMsg := Pop;
  if LMsg = nil then
    Exit(nil);

  Result := TGstMessageRef.Wrap(LMsg, False, True);
end;

function TGstBusRef.TimedPopMessage(ATimeout: GstClockTime; ATypes: GstMessageType): TGstMessageRef;
var
  LMsg: PGstMessage;
begin
  LMsg := TimedPopFiltered(ATimeout, ATypes);
  if LMsg = nil then
    Exit(nil);

  Result := TGstMessageRef.Wrap(LMsg, False, True);
end;

class function TGstBusRef.MessageTypeName(AMessage: PGstMessage): string;
begin
  if AMessage = nil then
    Exit('');
  Result := MessageTypeName(AMessage^.D_type);
end;

class function TGstBusRef.MessageTypeName(AType: GstMessageType): string;
var
  P: Pgchar;
begin
  P := _gst_message_type_get_name(AType);
  Result := PgcharToString(P);
end;

class function TGstBusRef.MessageTypeName(AMessage: TGstMessageRef): string;
begin
  if AMessage = nil then
    Exit('');
  Result := AMessage.MessageTypeName;
end;

class function TGstBusRef.StateToString(AState: GstState): string;
var
  P: Pgchar;
begin
  P := _gst_element_state_get_name(AState);
  if P <> nil then
    Exit(PgcharToString(P));

  case AState of
    0: Result := 'VOID_PENDING';
    1: Result := 'NULL';
    2: Result := 'READY';
    3: Result := 'PAUSED';
    4: Result := 'PLAYING';
  else
    Result := 'UNKNOWN(' + IntToStr(AState) + ')';
  end;
end;

class procedure TGstBusRef.ParseErrorMessage(
  AMessage: PGstMessage;
  out AErrorText: string;
  out ADebugText: string
);
var
  LErr: PGError;
  LDebug: Pgchar;
begin
  AErrorText := '';
  ADebugText := '';

  if AMessage = nil then
    raise EG2DGstBusDOOError.Create('ParseErrorMessage: message is nil');

  LErr := nil;
  LDebug := nil;

  _gst_message_parse_error(AMessage, @LErr, @LDebug);
  try
    if LErr <> nil then
      AErrorText := PgcharToString(LErr^.message);

    if LDebug <> nil then
      ADebugText := PgcharToString(LDebug);
  finally
    if LErr <> nil then
      _g_error_free(LErr);

    if LDebug <> nil then
      _g_free(LDebug);
  end;
end;

class procedure TGstBusRef.ParseErrorMessage(
  AMessage: TGstMessageRef;
  out AErrorText: string;
  out ADebugText: string
);
begin
  AErrorText := '';
  ADebugText := '';

  if AMessage = nil then
    raise EG2DGstBusDOOError.Create('ParseErrorMessage: message wrapper is nil');

  AMessage.ParseError(AErrorText, ADebugText);
end;

class procedure TGstBusRef.ParseWarningMessage(
  AMessage: PGstMessage;
  out AWarningText: string;
  out ADebugText: string
);
var
  LErr: PGError;
  LDebug: Pgchar;
begin
  AWarningText := '';
  ADebugText := '';

  if AMessage = nil then
    raise EG2DGstBusDOOError.Create('ParseWarningMessage: message is nil');

  LErr := nil;
  LDebug := nil;

  _gst_message_parse_warning(AMessage, @LErr, @LDebug);
  try
    if LErr <> nil then
      AWarningText := PgcharToString(LErr^.message);

    if LDebug <> nil then
      ADebugText := PgcharToString(LDebug);
  finally
    if LErr <> nil then
      _g_error_free(LErr);

    if LDebug <> nil then
      _g_free(LDebug);
  end;
end;

class procedure TGstBusRef.ParseWarningMessage(
  AMessage: TGstMessageRef;
  out AWarningText: string;
  out ADebugText: string
);
begin
  AWarningText := '';
  ADebugText := '';

  if AMessage = nil then
    raise EG2DGstBusDOOError.Create('ParseWarningMessage: message wrapper is nil');

  AMessage.ParseWarning(AWarningText, ADebugText);
end;

class procedure TGstBusRef.ParseStateChangedMessage(
  AMessage: PGstMessage;
  out AOldState: GstState;
  out ANewState: GstState;
  out APendingState: GstState
);
begin
  if AMessage = nil then
    raise EG2DGstBusDOOError.Create('ParseStateChangedMessage: message is nil');

  AOldState := 0;
  ANewState := 0;
  APendingState := 0;

  _gst_message_parse_state_changed(
    AMessage,
    @AOldState,
    @ANewState,
    @APendingState
  );
end;

class procedure TGstBusRef.ParseStateChangedMessage(
  AMessage: TGstMessageRef;
  out AOldState: GstState;
  out ANewState: GstState;
  out APendingState: GstState
);
begin
  if AMessage = nil then
    raise EG2DGstBusDOOError.Create('ParseStateChangedMessage: message wrapper is nil');

  AMessage.ParseStateChanged(AOldState, ANewState, APendingState);
end;

end.

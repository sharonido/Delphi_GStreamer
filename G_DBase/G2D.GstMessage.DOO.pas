unit G2D.GstMessage.DOO;

interface

uses
  System.SysUtils,
  G2D.Glib.Types,
  G2D.Gobject.Types,
  G2D.Gst.Types,
  G2D.Gobject.DOO,
  G2D.GstObject.DOO,
  G2D.Glib.API,
  G2D.Gobject.API,
  G2D.Gst.API;

type
  EG2DGstMessageDOOError = class(Exception);

{ =======================
  TGstMiniObjectRef
  ======================= }

  TGstMiniObjectRef = class
  protected
    FHandle: PGstMiniObject;
    FOwnsRef: Boolean;

    procedure CheckHandle;
  public
    constructor Create(AHandle: PGstMiniObject; AAddRef: Boolean = False; AOwnsRef: Boolean = True);
    destructor Destroy; override;

    class function Wrap(AHandle: PGstMiniObject; AAddRef: Boolean = False; AOwnsRef: Boolean = True): TGstMiniObjectRef;

    function MiniObjectHandle: PGstMiniObject;

    procedure Ref;
    procedure Unref;
  end;

{ =======================
  TGstMessageRef
  ======================= }

  TGstMessageRef = class(TGstMiniObjectRef)
  protected
    procedure CheckMessageHandle;
  public
    constructor Create(AHandle: PGstMessage; AAddRef: Boolean = False; AOwnsRef: Boolean = True);
    class function Wrap(AHandle: PGstMessage; AAddRef: Boolean = False; AOwnsRef: Boolean = True): TGstMessageRef;

    function MessageHandle: PGstMessage;

    function MessageType: GstMessageType;
    function MessageTypeName: string;

    function SourceHandle: PGstObject;
    function SourceName: string;

    function IsError: Boolean;
    function IsWarning: Boolean;
    function IsStateChanged: Boolean;
    function IsEOS: Boolean;

    procedure ParseError(out AErrorText: string; out ADebugText: string);
    procedure ParseWarning(out AWarningText: string; out ADebugText: string);

    procedure ParseStateChanged(
      out AOldState: GstState;
      out ANewState: GstState;
      out APendingState: GstState
    );

    function StateChangedToText: string;
  end;

implementation
{ =======================
  TGstMiniObjectRef
  ======================= }

procedure TGstMiniObjectRef.CheckHandle;
begin
  if FHandle = nil then
    raise EG2DGstMessageDOOError.Create('MiniObject handle is nil');
end;

constructor TGstMiniObjectRef.Create(AHandle: PGstMiniObject; AAddRef: Boolean; AOwnsRef: Boolean);
begin
  inherited Create;

  FHandle := AHandle;
  FOwnsRef := AOwnsRef;

  if (FHandle <> nil) and AAddRef then
    _gst_mini_object_ref(FHandle);
end;

destructor TGstMiniObjectRef.Destroy;
begin
  if FOwnsRef and (FHandle <> nil) then
    _gst_mini_object_unref(FHandle);

  inherited;
end;

class function TGstMiniObjectRef.Wrap(AHandle: PGstMiniObject; AAddRef: Boolean; AOwnsRef: Boolean): TGstMiniObjectRef;
begin
  Result := TGstMiniObjectRef.Create(AHandle, AAddRef, AOwnsRef);
end;

function TGstMiniObjectRef.MiniObjectHandle: PGstMiniObject;
begin
  Result := FHandle;
end;

procedure TGstMiniObjectRef.Ref;
begin
  CheckHandle;
  _gst_mini_object_ref(FHandle);
end;

procedure TGstMiniObjectRef.Unref;
begin
  CheckHandle;
  _gst_mini_object_unref(FHandle);
end;

{ =======================
  TGstMessageRef
  ======================= }

procedure TGstMessageRef.CheckMessageHandle;
begin
  if MessageHandle = nil then
    raise EG2DGstMessageDOOError.Create('Message handle is nil');
end;

constructor TGstMessageRef.Create(AHandle: PGstMessage; AAddRef: Boolean; AOwnsRef: Boolean);
begin
  inherited Create(PGstMiniObject(AHandle), AAddRef, AOwnsRef);
end;

class function TGstMessageRef.Wrap(AHandle: PGstMessage; AAddRef: Boolean; AOwnsRef: Boolean): TGstMessageRef;
begin
  Result := TGstMessageRef.Create(AHandle, AAddRef, AOwnsRef);
end;

function TGstMessageRef.MessageHandle: PGstMessage;
begin
  Result := PGstMessage(MiniObjectHandle);
end;

function TGstMessageRef.MessageType: GstMessageType;
begin
  CheckMessageHandle;
  Result := MessageHandle^.D_type;
end;

function TGstMessageRef.MessageTypeName: string;
begin
  Result := PgcharToString(_gst_message_type_get_name(MessageType));
end;

function TGstMessageRef.SourceHandle: PGstObject;
begin
  Result := MessageHandle^.src;
end;

function TGstMessageRef.SourceName: string;
begin
  if SourceHandle = nil then
    Exit('');

  Result := PgcharToString(_gst_object_get_name(SourceHandle));
end;

function TGstMessageRef.IsError: Boolean;
begin
  Result := MessageType = GST_MESSAGE_ERROR;
end;

function TGstMessageRef.IsWarning: Boolean;
begin
  Result := MessageType = GST_MESSAGE_WARNING;
end;

function TGstMessageRef.IsStateChanged: Boolean;
begin
  Result := MessageType = GST_MESSAGE_STATE_CHANGED;
end;

function TGstMessageRef.IsEOS: Boolean;
begin
  Result := MessageType = GST_MESSAGE_EOS;
end;

procedure TGstMessageRef.ParseError(out AErrorText: string; out ADebugText: string);
var
  LErr: PGError;
  LDebug: Pgchar;
begin
  CheckMessageHandle;

  AErrorText := '';
  ADebugText := '';

  LErr := nil;
  LDebug := nil;

  _gst_message_parse_error(MessageHandle, @LErr, @LDebug);
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

procedure TGstMessageRef.ParseWarning(out AWarningText: string; out ADebugText: string);
var
  LErr: PGError;
  LDebug: Pgchar;
begin
  CheckMessageHandle;

  AWarningText := '';
  ADebugText := '';

  LErr := nil;
  LDebug := nil;

  _gst_message_parse_warning(MessageHandle, @LErr, @LDebug);
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

procedure TGstMessageRef.ParseStateChanged(
  out AOldState: GstState;
  out ANewState: GstState;
  out APendingState: GstState
);
begin
  CheckMessageHandle;

  _gst_message_parse_state_changed(
    MessageHandle,
    @AOldState,
    @ANewState,
    @APendingState
  );
end;

function TGstMessageRef.StateChangedToText: string;
var
  OldState, NewState, PendingState: GstState;
begin
  if not IsStateChanged then
    Exit('');

  ParseStateChanged(OldState, NewState, PendingState);

  Result :=
    'old=' + PgcharToString(_gst_element_state_get_name(OldState)) +
    ' new=' + PgcharToString(_gst_element_state_get_name(NewState)) +
    ' pending=' + PgcharToString(_gst_element_state_get_name(PendingState));
end;

end.

unit G2D.GstObject.DOO;

interface

uses
  System.SysUtils,
  G2D.Glib.Types,
  G2D.Gobject.Types,
  G2D.Gst.Types,
  G2D.Gobject.DOO,
  G2D.Glib.API,
  G2D.Gobject.API,
  G2D.Gst.API;

type
  EG2DGstDOOError = class(Exception);

  TGstObjectRef = class(TGObjectRef)
  protected
    procedure CheckGstHandle;
  public
    constructor Create(AHandle: PGstObject; AAddRef: Boolean = False; AOwnsRef: Boolean = True);
    class function Wrap(AHandle: PGstObject; AAddRef: Boolean = False; AOwnsRef: Boolean = True): TGstObjectRef;

    function GstHandle: PGstObject;

    function GetName: string;
    function SetName(const AName: string): Boolean;
  end;


implementation

{ TGstObjectRef }

procedure TGstObjectRef.CheckGstHandle;
begin
  if GstHandle = nil then
    raise EG2DGstDOOError.Create('TGstObjectRef handle is nil');
end;

constructor TGstObjectRef.Create(AHandle: PGstObject; AAddRef: Boolean; AOwnsRef: Boolean);
begin
  inherited Create(PGObject(AHandle), AAddRef, AOwnsRef);
end;

class function TGstObjectRef.Wrap(AHandle: PGstObject; AAddRef: Boolean; AOwnsRef: Boolean): TGstObjectRef;
begin
  Result := TGstObjectRef.Create(AHandle, AAddRef, AOwnsRef);
end;

function TGstObjectRef.GstHandle: PGstObject;
begin
  Result := PGstObject(Handle);
end;

function TGstObjectRef.GetName: string;
var
  P: Pgchar;
begin
  CheckGstHandle;
  P := _gst_object_get_name(GstHandle);
  Result := PgcharToString(P);
end;

function TGstObjectRef.SetName(const AName: string): Boolean;
var
  LName: UTF8String;
begin
  CheckGstHandle;
  LName := UTF8String(AName);
  Result := _gst_object_set_name(GstHandle, Pgchar(PAnsiChar(LName))) <> 0;
end;
End.

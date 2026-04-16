unit G2D.GstBin.DOO;

interface

uses
  System.SysUtils,
  G2D.Glib.Types,
  G2D.Gobject.Types,
  G2D.Gst.Types,
  G2D.GstElement.DOO,
  G2D.Glib.API,
  G2D.Gobject.API,
  G2D.Gst.API,
  G2D.Gobject.DOO;

type
  EG2DGstBinDOOError = class(Exception);

  TGstBinRef = class(TGstElementRef)
  protected
    procedure CheckBinHandle;
  public
    constructor Create(AHandle: PGstBin; AAddRef: Boolean = False; AOwnsRef: Boolean = True);
    class function Wrap(AHandle: PGstBin; AAddRef: Boolean = False; AOwnsRef: Boolean = True): TGstBinRef;

    function BinHandle: PGstBin;

    function Add(const AElement: TGstElementRef): Boolean; overload;
    function Add(const AElement: PGstElement): Boolean; overload;

    function Remove(const AElement: TGstElementRef): Boolean; overload;
    function Remove(const AElement: PGstElement): Boolean; overload;

    function GetByName(const AName: string): TGstElementRef;
    function HasElement(const AName: string): Boolean;
  end;

implementation

{ TGstBinRef }

procedure TGstBinRef.CheckBinHandle;
begin
  if BinHandle = nil then
    raise EG2DGstBinDOOError.Create('TGstBinRef handle is nil');
end;

constructor TGstBinRef.Create(AHandle: PGstBin; AAddRef: Boolean; AOwnsRef: Boolean);
begin
  inherited Create(PGstElement(AHandle), AAddRef, AOwnsRef);
end;

class function TGstBinRef.Wrap(AHandle: PGstBin; AAddRef: Boolean; AOwnsRef: Boolean): TGstBinRef;
begin
  Result := TGstBinRef.Create(AHandle, AAddRef, AOwnsRef);
end;

function TGstBinRef.BinHandle: PGstBin;
begin
  Result := PGstBin(ElementHandle);
end;

function TGstBinRef.Add(const AElement: TGstElementRef): Boolean;
begin
  if AElement = nil then
    raise EG2DGstBinDOOError.Create('Add element is nil');

  Result := Add(AElement.ElementHandle);
end;

function TGstBinRef.Add(const AElement: PGstElement): Boolean;
begin
  CheckBinHandle;

  if AElement = nil then
    raise EG2DGstBinDOOError.Create('Add element handle is nil');

  Result := _gst_bin_add(BinHandle, AElement) <> 0;
end;

function TGstBinRef.Remove(const AElement: TGstElementRef): Boolean;
begin
  if AElement = nil then
    raise EG2DGstBinDOOError.Create('Remove element is nil');

  Result := Remove(AElement.ElementHandle);
end;

function TGstBinRef.Remove(const AElement: PGstElement): Boolean;
begin
  CheckBinHandle;

  if AElement = nil then
    raise EG2DGstBinDOOError.Create('Remove element handle is nil');

  Result := _gst_bin_remove(BinHandle, AElement) <> 0;
end;

function TGstBinRef.GetByName(const AName: string): TGstElementRef;
var
  LName: UTF8String;
  LElement: PGstElement;
begin
  CheckBinHandle;

  LName := UTF8String(AName);
  LElement := _gst_bin_get_by_name(
                BinHandle,
                Pgchar(PAnsiChar(LName))
              );

  if LElement = nil then
    Exit(nil);

  Result := TGstElementRef.Wrap(LElement, False, True);
end;

function TGstBinRef.HasElement(const AName: string): Boolean;
var
  LElement: TGstElementRef;
begin
  LElement := GetByName(AName);
  try
    Result := LElement <> nil;
  finally
      if assigned(LElement) then LElement.Free;
  end;
end;

end.

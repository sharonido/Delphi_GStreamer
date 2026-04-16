unit G2D.GstPad.DOO;

interface

uses
  System.SysUtils,
  G2D.Glib.Types,
  G2D.Gobject.Types,
  G2D.Gst.Types,
  G2D.Gst.API,
  G2D.Glib.API,
  G2D.GObject.DOO,
  G2D.GstObject.DOO,
  G2D.GstElement.DOO;

type
  EG2DGstPadDOOError = class(Exception);

{==============================================================================
  TGstStructureRef - wrapper for GstStructure (part of Caps)
==============================================================================}

  TGstStructureRef = class
  private
    FHandle: PGstStructure;
    // Structure is owned by Caps, so we don't ref/unref it
  public
    constructor Create(AHandle: PGstStructure);
    class function Wrap(AHandle: PGstStructure): TGstStructureRef;

    function StructureHandle: PGstStructure;
    function GetName: string;
    function IsValid: Boolean;

    // Iterate through all fields with callback
    function ForEach(AFunc: GstStructureForeachFunc; AUserData: gpointer): Boolean;
  end;

{==============================================================================
  TGstCapsRef - wrapper for GstCaps
==============================================================================}

  TGstCapsRef = class
  private
    FHandle: PGstCaps;
    FOwnsRef: Boolean;
  public
    constructor Create(AHandle: PGstCaps; AOwnsRef: Boolean = True);
    destructor Destroy; override;
    class function Wrap(AHandle: PGstCaps; AOwnsRef: Boolean = True): TGstCapsRef;

    function CapsHandle: PGstCaps;
    function IsValid: Boolean;

    function IsAny: Boolean;
    function IsEmpty: Boolean;
    function GetSize: Integer;
    function GetStructure(AIndex: Integer): TGstStructureRef;
    function ToString: string; reintroduce;
  end;

{==============================================================================
  TGstPadRef - wrapper for GstPad
==============================================================================}

  TGstPadRef = class(TGstObjectRef)
  public
    constructor Create(AHandle: PGstPad; AAddRef: Boolean = False; AOwnsRef: Boolean = True);
    class function Wrap(AHandle: PGstPad; AAddRef: Boolean = False; AOwnsRef: Boolean = True): TGstPadRef;

    function PadHandle: PGstPad;

    function GetName: string;

    function IsLinked: Boolean;

    function Link(const AOther: TGstPadRef): GstPadLinkReturn;
    function Unlink(const AOther: TGstPadRef): Boolean;

    function LinkTo(const AOther: TGstPadRef): GstPadLinkReturn;
    function UnlinkFrom(const AOther: TGstPadRef): Boolean;

    function GetParentElement: TGstElementRef;

    { Tutorial 6 - Caps related methods }
    function GetCurrentCaps: TGstCapsRef;
    function GetPadTemplateCaps: TGstCapsRef;

    class function LinkResultToString(AResult: GstPadLinkReturn): string;

    { Tutorial 7 - Request Pads }
    // Request a pad from AElement using the given template name (e.g. 'src_%u').
    // The returned TGstPadRef has AOwnsRef=False — caller must call ReleaseFrom.
    class function RequestFrom(AElement: TGstElementRef;
      const ATemplateName: string): TGstPadRef; overload;
    class function RequestFrom(AElement: PGstElement;
      const ATemplateName: string): TGstPadRef; overload;

    // Release the pad back to its element and unref it.
    // Mirrors: gst_element_release_request_pad(element, pad) + gst_object_unref(pad)
    procedure ReleaseFrom(AElement: TGstElementRef); overload;
    procedure ReleaseFrom(AElement: PGstElement); overload;
  end;

{==============================================================================
  D-wrapper functions for direct API access (Layer 3 naming convention)
==============================================================================}

{ Pad functions }
function DGstPadGetCurrentCaps(APad: PGstPad): PGstCaps;
function DGstPadGetPadTemplateCaps(APad: PGstPad): PGstCaps;

{ Caps functions }
function DGstCapsIsAny(ACaps: PGstCaps): Boolean;
function DGstCapsIsEmpty(ACaps: PGstCaps): Boolean;
function DGstCapsGetSize(ACaps: PGstCaps): Integer;
function DGstCapsGetStructure(ACaps: PGstCaps; AIndex: Integer): PGstStructure;
function DGstCapsToString(ACaps: PGstCaps): string;
procedure DGstCapsUnref(ACaps: PGstCaps);

{ Structure functions }
function DGstStructureGetName(AStructure: PGstStructure): string;
function DGstStructureForEach(AStructure: PGstStructure; AFunc: GstStructureForeachFunc; AUserData: gpointer): Boolean;

implementation

{==============================================================================
  TGstStructureRef implementation
==============================================================================}

constructor TGstStructureRef.Create(AHandle: PGstStructure);
begin
  inherited Create;
  FHandle := AHandle;
end;

class function TGstStructureRef.Wrap(AHandle: PGstStructure): TGstStructureRef;
begin
  if AHandle = nil then
    Exit(nil);
  Result := TGstStructureRef.Create(AHandle);
end;

function TGstStructureRef.StructureHandle: PGstStructure;
begin
  Result := FHandle;
end;

function TGstStructureRef.GetName: string;
var
  P: Pgchar;
begin
  if FHandle = nil then
    Exit('');

  P := _gst_structure_get_name(FHandle);
  if P = nil then
    Exit('');

  Result := PgcharToString(P);
end;

function TGstStructureRef.IsValid: Boolean;
begin
  Result := FHandle <> nil;
end;

function TGstStructureRef.ForEach(AFunc: GstStructureForeachFunc; AUserData: gpointer): Boolean;
begin
  if FHandle = nil then
    Exit(False);

  Result := _gst_structure_foreach(FHandle, AFunc, AUserData) <> 0;
end;

{==============================================================================
  TGstCapsRef implementation
==============================================================================}

constructor TGstCapsRef.Create(AHandle: PGstCaps; AOwnsRef: Boolean);
begin
  inherited Create;
  FHandle := AHandle;
  FOwnsRef := AOwnsRef;
end;

destructor TGstCapsRef.Destroy;
begin
  if FOwnsRef and (FHandle <> nil) then
    _gst_caps_unref(FHandle);
  inherited;
end;

class function TGstCapsRef.Wrap(AHandle: PGstCaps; AOwnsRef: Boolean): TGstCapsRef;
begin
  if AHandle = nil then
    Exit(nil);
  Result := TGstCapsRef.Create(AHandle, AOwnsRef);
end;

function TGstCapsRef.CapsHandle: PGstCaps;
begin
  Result := FHandle;
end;

function TGstCapsRef.IsValid: Boolean;
begin
  Result := FHandle <> nil;
end;

function TGstCapsRef.IsAny: Boolean;
begin
  if FHandle = nil then
    Exit(False);
  Result := _gst_caps_is_any(FHandle) <> 0;
end;

function TGstCapsRef.IsEmpty: Boolean;
begin
  if FHandle = nil then
    Exit(True);
  Result := _gst_caps_is_empty(FHandle) <> 0;
end;

function TGstCapsRef.GetSize: Integer;
begin
  if FHandle = nil then
    Exit(0);
  Result := _gst_caps_get_size(FHandle);
end;

function TGstCapsRef.GetStructure(AIndex: Integer): TGstStructureRef;
var
  LStruct: PGstStructure;
begin
  if FHandle = nil then
    Exit(nil);

  LStruct := _gst_caps_get_structure(FHandle, AIndex);
  Result := TGstStructureRef.Wrap(LStruct);
end;

function TGstCapsRef.ToString: string;
var
  P: Pgchar;
begin
  if FHandle = nil then
    Exit('NULL');

  P := _gst_caps_to_string(FHandle);
  if P = nil then
    Exit('');

  Result := PgcharToString(P);
  _g_free(P);
end;

{==============================================================================
  TGstPadRef implementation
==============================================================================}

constructor TGstPadRef.Create(AHandle: PGstPad; AAddRef: Boolean; AOwnsRef: Boolean);
begin
  inherited Create(PGstObject(AHandle), AAddRef, AOwnsRef);
end;

class function TGstPadRef.Wrap(AHandle: PGstPad; AAddRef: Boolean; AOwnsRef: Boolean): TGstPadRef;
begin
  if AHandle = nil then
    Exit(nil);

  Result := TGstPadRef.Create(AHandle, AAddRef, AOwnsRef);
end;

function TGstPadRef.PadHandle: PGstPad;
begin
  Result := PGstPad(GstHandle);
end;

function TGstPadRef.GetName: string;
begin
  CheckHandle;
  Result := inherited GetName;
end;

function TGstPadRef.IsLinked: Boolean;
begin
  CheckHandle;
  Result := _gst_pad_is_linked(PadHandle) <> 0;
end;

function TGstPadRef.Link(const AOther: TGstPadRef): GstPadLinkReturn;
begin
  CheckHandle;

  if AOther = nil then
    raise EG2DGstPadDOOError.Create('Link: other pad is nil');

  AOther.CheckHandle;

  Result := _gst_pad_link(PadHandle, AOther.PadHandle);
end;

function TGstPadRef.Unlink(const AOther: TGstPadRef): Boolean;
begin
  CheckHandle;

  if AOther = nil then
    raise EG2DGstPadDOOError.Create('Unlink: other pad is nil');

  AOther.CheckHandle;

  Result := _gst_pad_unlink(PadHandle, AOther.PadHandle) <> 0;
end;

function TGstPadRef.LinkTo(const AOther: TGstPadRef): GstPadLinkReturn;
begin
  Result := Link(AOther);
end;

function TGstPadRef.UnlinkFrom(const AOther: TGstPadRef): Boolean;
begin
  Result := Unlink(AOther);
end;

function TGstPadRef.GetParentElement: TGstElementRef;
var
  LElement: PGstElement;
begin
  CheckHandle;

  LElement := _gst_pad_get_parent_element(PadHandle);

  if LElement = nil then
    Exit(nil);

  Result := TGstElementRef.Wrap(LElement, False, True);
end;

{ Tutorial 6 - Caps related methods }

function TGstPadRef.GetCurrentCaps: TGstCapsRef;
var
  LCaps: PGstCaps;
begin
  CheckHandle;

  LCaps := _gst_pad_get_current_caps(PadHandle);
  Result := TGstCapsRef.Wrap(LCaps, True);
end;

function TGstPadRef.GetPadTemplateCaps: TGstCapsRef;
var
  LCaps: PGstCaps;
begin
  CheckHandle;

  LCaps := _gst_pad_get_pad_template_caps(PadHandle);
  Result := TGstCapsRef.Wrap(LCaps, True);
end;

class function TGstPadRef.LinkResultToString(AResult: GstPadLinkReturn): string;
var
  P: Pgchar;
begin
  P := _gst_pad_link_get_name(AResult);
  if P = nil then
    Exit(IntToStr(AResult));

  Result := PgcharToString(P);
end;

{ Tutorial 7 - Request Pads }

class function TGstPadRef.RequestFrom(AElement: TGstElementRef;
  const ATemplateName: string): TGstPadRef;
begin
  if AElement = nil then
    raise EG2DGstPadDOOError.Create('RequestFrom: element wrapper is nil');

  Result := RequestFrom(AElement.ElementHandle, ATemplateName);
end;

class function TGstPadRef.RequestFrom(AElement: PGstElement;
  const ATemplateName: string): TGstPadRef;
var
  LName: UTF8String;
  LPad: PGstPad;
begin
  if AElement = nil then
    raise EG2DGstPadDOOError.Create('RequestFrom: element handle is nil');

  LName := UTF8String(ATemplateName);
  LPad  := _gst_element_request_pad_simple(AElement, Pgchar(PAnsiChar(LName)));

  if LPad = nil then
    raise EG2DGstPadDOOError.CreateFmt(
      'RequestFrom: failed to get request pad "%s"', [ATemplateName]);

  // AOwnsRef=False — caller must call ReleaseFrom, not just Free
  Result := TGstPadRef.Wrap(LPad, False, False);
end;

procedure TGstPadRef.ReleaseFrom(AElement: TGstElementRef);
begin
  if AElement = nil then
    raise EG2DGstPadDOOError.Create('ReleaseFrom: element wrapper is nil');

  ReleaseFrom(AElement.ElementHandle);
end;

procedure TGstPadRef.ReleaseFrom(AElement: PGstElement);
begin
  if AElement = nil then
    raise EG2DGstPadDOOError.Create('ReleaseFrom: element handle is nil');

  if PadHandle = nil then
    raise EG2DGstPadDOOError.Create('ReleaseFrom: pad handle is nil');

  // Mirrors the C pattern:
  //   gst_element_release_request_pad(tee, pad);
  //   gst_object_unref(pad);
  _gst_element_release_request_pad(AElement, PadHandle);
  _gst_object_unref(gpointer(PadHandle));
end;

{==============================================================================
  D-wrapper functions implementation
==============================================================================}

{ Pad functions }

function DGstPadGetCurrentCaps(APad: PGstPad): PGstCaps;
begin
  if APad = nil then
    Exit(nil);
  Result := _gst_pad_get_current_caps(APad);
end;

function DGstPadGetPadTemplateCaps(APad: PGstPad): PGstCaps;
begin
  if APad = nil then
    Exit(nil);
  Result := _gst_pad_get_pad_template_caps(APad);
end;

{ Caps functions }

function DGstCapsIsAny(ACaps: PGstCaps): Boolean;
begin
  if ACaps = nil then
    Exit(False);
  Result := _gst_caps_is_any(ACaps) <> 0;
end;

function DGstCapsIsEmpty(ACaps: PGstCaps): Boolean;
begin
  if ACaps = nil then
    Exit(True);
  Result := _gst_caps_is_empty(ACaps) <> 0;
end;

function DGstCapsGetSize(ACaps: PGstCaps): Integer;
begin
  if ACaps = nil then
    Exit(0);
  Result := _gst_caps_get_size(ACaps);
end;

function DGstCapsGetStructure(ACaps: PGstCaps; AIndex: Integer): PGstStructure;
begin
  if ACaps = nil then
    Exit(nil);
  Result := _gst_caps_get_structure(ACaps, AIndex);
end;

function DGstCapsToString(ACaps: PGstCaps): string;
var
  P: Pgchar;
begin
  if ACaps = nil then
    Exit('NULL');

  P := _gst_caps_to_string(ACaps);
  if P = nil then
    Exit('');

  Result := PgcharToString(P);
  _g_free(P);
end;

procedure DGstCapsUnref(ACaps: PGstCaps);
begin
  if ACaps <> nil then
    _gst_caps_unref(ACaps);
end;

{ Structure functions }

function DGstStructureGetName(AStructure: PGstStructure): string;
var
  P: Pgchar;
begin
  if AStructure = nil then
    Exit('');

  P := _gst_structure_get_name(AStructure);
  if P = nil then
    Exit('');

  Result := PgcharToString(P);
end;

function DGstStructureForEach(AStructure: PGstStructure; AFunc: GstStructureForeachFunc; AUserData: gpointer): Boolean;
begin
  if AStructure = nil then
    Exit(False);
  Result := _gst_structure_foreach(AStructure, AFunc, AUserData) <> 0;
end;

end.

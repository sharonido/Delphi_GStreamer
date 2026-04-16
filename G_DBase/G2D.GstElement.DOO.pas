unit G2D.GstElement.DOO;

interface

uses
  System.SysUtils,
  G2D.Glib.Types,
  G2D.Gobject.Types,
  G2D.Gst.Types,
  G2D.Gobject.DOO,
  G2D.Gstobject.DOO,
  G2D.GstBus.DOO,
  G2D.Glib.API,
  G2D.Gobject.API,
  G2D.Gst.API;

type
  EG2DGstDOOError = class(Exception);

  // Forward declaration
  TGstElementRef = class;

{==============================================================================
  TGstElementFactoryRef - wrapper for GstElementFactory (Tutorial 6)
==============================================================================}

  TGstElementFactoryRef = class(TGObjectRef)
  public
    constructor Create(AHandle: PGstElementFactory; AAddRef: Boolean = False; AOwnsRef: Boolean = True);
    class function Wrap(AHandle: PGstElementFactory; AAddRef: Boolean = False; AOwnsRef: Boolean = True): TGstElementFactoryRef;
    class function Find(const AName: string): TGstElementFactoryRef;

    function FactoryHandle: PGstElementFactory;
    function IsValid: Boolean;

    { Tutorial 6 - Factory inspection }
    function GetStaticPadTemplates: PGList;
    function GetMetadata(const AKey: string): string;
    function CreateElement(const AName: string): TGstElementRef;
  end;

{==============================================================================
  TGstElementRef - wrapper for GstElement
==============================================================================}

  TGstElementRef = class(TGstObjectRef)
  public
    constructor Create(AHandle: PGstElement; AAddRef: Boolean = False; AOwnsRef: Boolean = True);
    class function Wrap(AHandle: PGstElement; AAddRef: Boolean = False; AOwnsRef: Boolean = True): TGstElementRef;
    class function Parse(const APipelineDescription: string): TGstElementRef;
    class function FactoryMake(const AFactory, AName: string): TGstElementRef;

    function ElementHandle: PGstElement;

    function Link(const ADest: TGstElementRef): Boolean; overload;
    function Link(const ADest: PGstElement): Boolean; overload;

    procedure Unlink(const ADest: TGstElementRef); overload;
    procedure Unlink(const ADest: PGstElement); overload;

    function SetState(AState: GstState): GstStateChangeReturn;
    function GetState: GstState;
    function Play: GstStateChangeReturn;
    function Pause: GstStateChangeReturn;
    function Ready: GstStateChangeReturn;
    function Null: GstStateChangeReturn;

    function GetBus: TGstBusRef;
    function GetStaticPad(const AName: string): PGstPad;

    { Tutorial 6 - Factory access }
    function GetFactory: TGstElementFactoryRef;

    procedure SetWindowHandle(AHandle: NativeUInt);

  end;

{==============================================================================
  D-wrapper functions for ElementFactory (Layer 3 naming convention)
==============================================================================}

function DGstElementFactoryFind(const AName: string): PGstElementFactory;
function DGstElementFactoryGetStaticPadTemplates(AFactory: PGstElementFactory): PGList;
function DGstElementFactoryGetMetadata(AFactory: PGstElementFactory; const AKey: string): string;
function DGstElementFactoryCreate(AFactory: PGstElementFactory; const AName: string): PGstElement;

implementation

uses
  G2D.GstPad.DOO;

{==============================================================================
  TGstElementFactoryRef implementation
==============================================================================}

constructor TGstElementFactoryRef.Create(AHandle: PGstElementFactory; AAddRef: Boolean; AOwnsRef: Boolean);
begin
  inherited Create(PGObject(AHandle), AAddRef, AOwnsRef);
end;

class function TGstElementFactoryRef.Wrap(AHandle: PGstElementFactory; AAddRef: Boolean; AOwnsRef: Boolean): TGstElementFactoryRef;
begin
  if AHandle = nil then
    Exit(nil);
  Result := TGstElementFactoryRef.Create(AHandle, AAddRef, AOwnsRef);
end;

class function TGstElementFactoryRef.Find(const AName: string): TGstElementFactoryRef;
var
  LName: UTF8String;
  LFactory: PGstElementFactory;
begin
  LName := UTF8String(AName);
  LFactory := _gst_element_factory_find(Pgchar(PAnsiChar(LName)));

  if LFactory = nil then
    Exit(nil);

  Result := TGstElementFactoryRef.Wrap(LFactory, False, True);
end;

function TGstElementFactoryRef.FactoryHandle: PGstElementFactory;
begin
  Result := PGstElementFactory(Handle);
end;

function TGstElementFactoryRef.IsValid: Boolean;
begin
  Result := FactoryHandle <> nil;
end;

function TGstElementFactoryRef.GetStaticPadTemplates: PGList;
begin
  CheckHandle;
  Result := _gst_element_factory_get_static_pad_templates(FactoryHandle);
end;

function TGstElementFactoryRef.GetMetadata(const AKey: string): string;
var
  LKey: UTF8String;
  P: Pgchar;
begin
  CheckHandle;

  LKey := UTF8String(AKey);
  P := _gst_element_factory_get_metadata(FactoryHandle, Pgchar(PAnsiChar(LKey)));

  if P = nil then
    Exit('');

  Result := PgcharToString(P);
end;

function TGstElementFactoryRef.CreateElement(const AName: string): TGstElementRef;
var
  LName: UTF8String;
  LElement: PGstElement;
begin
  CheckHandle;

  LName := UTF8String(AName);
  LElement := _gst_element_factory_create(FactoryHandle, Pgchar(PAnsiChar(LName)));

  if LElement = nil then
    raise EG2DGstDOOError.CreateFmt('Failed to create element from factory: %s', [AName]);

  Result := TGstElementRef.Wrap(LElement, False, True);
end;

{==============================================================================
  TGstElementRef implementation
==============================================================================}

constructor TGstElementRef.Create(AHandle: PGstElement; AAddRef: Boolean; AOwnsRef: Boolean);
begin
  inherited Create(PGstObject(AHandle), AAddRef, AOwnsRef);
end;

class function TGstElementRef.Wrap(AHandle: PGstElement; AAddRef: Boolean; AOwnsRef: Boolean): TGstElementRef;
begin
  Result := TGstElementRef.Create(AHandle, AAddRef, AOwnsRef);
end;

class function TGstElementRef.Parse(const APipelineDescription: string): TGstElementRef;
var
  LDesc: UTF8String;
  LHandle: PGstElement;
  LErr: PGError;
begin
  LErr := nil;
  LDesc := UTF8String(APipelineDescription);
  LHandle := _gst_parse_launch(Pgchar(PAnsiChar(LDesc)), @LErr);
  if LErr <> nil then
  begin
    try
      if LHandle <> nil then
        _gst_object_unref(gpointer(LHandle));

      raise EG2DGstDOOError.CreateFmt('gst_parse_launch failed: %s',
        [PgcharToString(LErr^.message)]
      );
    finally
      _g_error_free(LErr);
    end;
  end;
  if LHandle = nil then
    raise EG2DGstDOOError.Create('gst_parse_launch returned nil');
  Result := TGstElementRef.Wrap(LHandle, False, True);
end;

class function TGstElementRef.FactoryMake(const AFactory, AName: string): TGstElementRef;
var
  LFactory: UTF8String;
  LName: UTF8String;
  LHandle: PGstElement;
begin
  LFactory := UTF8String(AFactory);
  LName := UTF8String(AName);

  LHandle := _gst_element_factory_make(
               Pgchar(PAnsiChar(LFactory)),
               Pgchar(PAnsiChar(LName))
             );

  if LHandle = nil then
    raise EG2DGstDOOError.CreateFmt(
      'gst_element_factory_make failed: %s', [AFactory]);

  Result := TGstElementRef.Create(LHandle, False, True);
end;

function TGstElementRef.ElementHandle: PGstElement;
begin
  Result := PGstElement(GstHandle);
end;

function TGstElementRef.Link(const ADest: TGstElementRef): Boolean;
begin
  if ADest = nil then
    raise EG2DGstDOOError.Create('Link destination is nil');

  Result := Link(ADest.ElementHandle);
end;

function TGstElementRef.Link(const ADest: PGstElement): Boolean;
begin
  if ElementHandle = nil then
    raise EG2DGstDOOError.Create('Source element handle is nil');

  if ADest = nil then
    raise EG2DGstDOOError.Create('Destination element handle is nil');

  Result := _gst_element_link(ElementHandle, ADest) <> 0;
end;

procedure TGstElementRef.Unlink(const ADest: TGstElementRef);
begin
  if ADest = nil then
    raise EG2DGstDOOError.Create('Unlink destination is nil');

  Unlink(ADest.ElementHandle);
end;

procedure TGstElementRef.Unlink(const ADest: PGstElement);
begin
  if ElementHandle = nil then
    raise EG2DGstDOOError.Create('Source element handle is nil');

  if ADest = nil then
    raise EG2DGstDOOError.Create('Destination element handle is nil');

  _gst_element_unlink(ElementHandle, ADest);
end;

function TGstElementRef.SetState(AState: GstState): GstStateChangeReturn;
begin
  if ElementHandle = nil then
    raise EG2DGstDOOError.Create('Element handle is nil');

  Result := _gst_element_set_state(ElementHandle, AState);
end;

procedure TGstElementRef.SetWindowHandle(AHandle: NativeUInt);
begin
  if ElementHandle = nil then
    Exit;
  _gst_video_overlay_set_window_handle(
    gpointer(ElementHandle), guintptr(AHandle));
end;

function TGstElementRef.GetState: GstState;
var
  LState: GstState;
begin
  if ElementHandle = nil then
    raise EG2DGstDOOError.Create('Element handle is nil');
  LState := GST_STATE_NULL;
  _gst_element_get_state(ElementHandle, @LState, nil, 0);
  Result := LState;
end;

function TGstElementRef.Play: GstStateChangeReturn;
begin
  Result := SetState(GST_STATE_PLAYING);
end;

function TGstElementRef.Pause: GstStateChangeReturn;
begin
  Result := SetState(GST_STATE_PAUSED);
end;

function TGstElementRef.Ready: GstStateChangeReturn;
begin
  Result := SetState(GST_STATE_READY);
end;

function TGstElementRef.Null: GstStateChangeReturn;
begin
  Result := SetState(GST_STATE_NULL);
end;

function TGstElementRef.GetBus: TGstBusRef;
var
  LBus: PGstBus;
begin
  if ElementHandle = nil then
    raise EG2DGstDOOError.Create('Element handle is nil');

  LBus := _gst_element_get_bus(ElementHandle);

  if LBus = nil then
    Exit(nil);

  Result := TGstBusRef.Wrap(LBus, False, True);
end;

function TGstElementRef.GetStaticPad(const AName: string): PGstPad;
var
  LName: UTF8String;
begin
  if ElementHandle = nil then
    raise EG2DGstDOOError.Create('Element handle is nil');
  LName := UTF8String(AName);
  Result := _gst_element_get_static_pad(ElementHandle, Pgchar(PAnsiChar(LName)));
end;

{ Tutorial 6 - Factory access }

function TGstElementRef.GetFactory: TGstElementFactoryRef;
var
  LFactory: PGstElementFactory;
  LClass: PGstElementClass;
begin
  if ElementHandle = nil then
    raise EG2DGstDOOError.Create('Element handle is nil');

  // Navigate through the struct hierarchy:
  // GstElement.D_object -> GstObject.D_object -> GInitiallyUnowned.parent_instance -> GObject.g_type_instance.g_class
  LClass := PGstElementClass(
    PGstElement(ElementHandle)^.D_object.D_object.parent_instance.g_type_instance.g_class
  );

  if LClass = nil then
    Exit(nil);

  LFactory := LClass^.elementfactory;
  if LFactory = nil then
    Exit(nil);

  // Factory is owned by the class, so we add ref but don't take ownership
  Result := TGstElementFactoryRef.Wrap(LFactory, True, False);
end;


{==============================================================================
  D-wrapper functions implementation
==============================================================================}

function DGstElementFactoryFind(const AName: string): PGstElementFactory;
var
  LName: UTF8String;
begin
  LName := UTF8String(AName);
  Result := _gst_element_factory_find(Pgchar(PAnsiChar(LName)));
end;

function DGstElementFactoryGetStaticPadTemplates(AFactory: PGstElementFactory): PGList;
begin
  if AFactory = nil then
    Exit(nil);
  Result := _gst_element_factory_get_static_pad_templates(AFactory);
end;

function DGstElementFactoryGetMetadata(AFactory: PGstElementFactory; const AKey: string): string;
var
  LKey: UTF8String;
  P: Pgchar;
begin
  if AFactory = nil then
    Exit('');

  LKey := UTF8String(AKey);
  P := _gst_element_factory_get_metadata(AFactory, Pgchar(PAnsiChar(LKey)));

  if P = nil then
    Exit('');

  Result := PgcharToString(P);
end;

function DGstElementFactoryCreate(AFactory: PGstElementFactory; const AName: string): PGstElement;
var
  LName: UTF8String;
begin
  if AFactory = nil then
    Exit(nil);

  LName := UTF8String(AName);
  Result := _gst_element_factory_create(AFactory, Pgchar(PAnsiChar(LName)));
end;

end.

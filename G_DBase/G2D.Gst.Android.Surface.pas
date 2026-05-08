unit G2D.Gst.Android.Surface;

interface

uses
  System.SysUtils,
  FMX.Controls
{$IF Defined(ANDROID)}
  , Androidapi.JNI.GraphicsContentViewText
  , Androidapi.NativeWindow
{$ENDIF}
  ;

type
  EG2DAndroidSurfaceError = class(Exception);

  TG2DAndroidSurfaceHelper = class
  private
    FControl: TControl;
{$IF Defined(ANDROID)}
    FSurfaceView: JSurfaceView;
    FNativeWindow: PANativeWindow;
    function GetNativeWindowHandle: NativeUInt;
    function GetNativeWindowHeight: Integer;
    function GetNativeWindowWidth: Integer;
{$ENDIF}
  public
    constructor Create(AControl: TControl);
    destructor Destroy; override;

    procedure Attach;
    procedure Detach;
    procedure UpdateBounds;
    function TryAcquireNativeWindow: Boolean;
    procedure ReleaseNativeWindow;

{$IF Defined(ANDROID)}
    property SurfaceView: JSurfaceView read FSurfaceView;
    property NativeWindow: PANativeWindow read FNativeWindow;
    property NativeWindowHandle: NativeUInt read GetNativeWindowHandle;
    property NativeWindowHeight: Integer read GetNativeWindowHeight;
    property NativeWindowWidth: Integer read GetNativeWindowWidth;
{$ENDIF}
  end;

implementation

{$IF Defined(ANDROID)}
uses
  Androidapi.Helpers,
  Androidapi.Jni,
  Androidapi.JNI.App,
  Androidapi.JNIBridge,
  Androidapi.NativeWindowJni,
  FMX.Forms,
  FMX.Platform.Android;

function _FormForControl(AControl: TControl): TCommonCustomForm;
begin
  Result := nil;
  if (AControl <> nil) and (AControl.Root <> nil) and
    (AControl.Root.GetObject is TCommonCustomForm) then
    Result := TCommonCustomForm(AControl.Root.GetObject);
end;

constructor TG2DAndroidSurfaceHelper.Create(AControl: TControl);
begin
  inherited Create;
  FControl := AControl;
end;

destructor TG2DAndroidSurfaceHelper.Destroy;
begin
  Detach;
  inherited;
end;

procedure TG2DAndroidSurfaceHelper.Attach;
var
  LForm: TCommonCustomForm;
begin
  if FSurfaceView <> nil then
    Exit;

  if FControl = nil then
    raise EG2DAndroidSurfaceError.Create('Surface control is nil');

  LForm := _FormForControl(FControl);
  if LForm = nil then
    raise EG2DAndroidSurfaceError.Create('Surface control is not attached to a form');

  FSurfaceView := TJSurfaceView.JavaClass.init(TAndroidHelper.Activity);
  FSurfaceView.setVisibility(TJView.JavaClass.VISIBLE);
  FSurfaceView.setZOrderOnTop(False);
  FSurfaceView.setZOrderMediaOverlay(True);

  WindowHandleToPlatform(LForm.Handle).ZOrderManager.AddOrSetLink(
    FControl, FSurfaceView, nil);
  UpdateBounds;
end;

procedure TG2DAndroidSurfaceHelper.Detach;
var
  LForm: TCommonCustomForm;
begin
  ReleaseNativeWindow;

  if FSurfaceView = nil then
    Exit;

  LForm := _FormForControl(FControl);
  if LForm <> nil then
    WindowHandleToPlatform(LForm.Handle).ZOrderManager.RemoveLink(FControl);

  FSurfaceView := nil;
end;

function TG2DAndroidSurfaceHelper.GetNativeWindowHandle: NativeUInt;
begin
  Result := NativeUInt(FNativeWindow);
end;

function TG2DAndroidSurfaceHelper.GetNativeWindowHeight: Integer;
begin
  if FNativeWindow = nil then
    Exit(0);

  Result := ANativeWindow_getHeight(FNativeWindow);
end;

function TG2DAndroidSurfaceHelper.GetNativeWindowWidth: Integer;
begin
  if FNativeWindow = nil then
    Exit(0);

  Result := ANativeWindow_getWidth(FNativeWindow);
end;

procedure TG2DAndroidSurfaceHelper.UpdateBounds;
var
  LForm: TCommonCustomForm;
begin
  if FSurfaceView = nil then
    Exit;

  LForm := _FormForControl(FControl);
  if LForm = nil then
    Exit;

  WindowHandleToPlatform(LForm.Handle).ZOrderManager.UpdateOrderAndBounds(FControl);
end;

function TG2DAndroidSurfaceHelper.TryAcquireNativeWindow: Boolean;
var
  LEnv: PJNIEnv;
  LSurface: JSurface;
begin
  Result := False;
  ReleaseNativeWindow;

  if FSurfaceView = nil then
    Attach;

  LSurface := FSurfaceView.getHolder.getSurface;
  if (LSurface = nil) or not LSurface.isValid then
    Exit;

  LEnv := TJNIResolver.GetJNIEnv;
  if LEnv = nil then
    Exit;

  FNativeWindow := ANativeWindow_fromSurface(LEnv,
    JNIObject(TJNIResolver.JavaInstanceToID(LSurface)));
  Result := FNativeWindow <> nil;
end;

procedure TG2DAndroidSurfaceHelper.ReleaseNativeWindow;
begin
  if FNativeWindow <> nil then
  begin
    ANativeWindow_release(FNativeWindow);
    FNativeWindow := nil;
  end;
end;
{$ELSE}
constructor TG2DAndroidSurfaceHelper.Create(AControl: TControl);
begin
  inherited Create;
  FControl := AControl;
end;

destructor TG2DAndroidSurfaceHelper.Destroy;
begin
  inherited;
end;

procedure TG2DAndroidSurfaceHelper.Attach;
begin
  raise EG2DAndroidSurfaceError.Create('Android surfaces are available only on Android');
end;

procedure TG2DAndroidSurfaceHelper.Detach;
begin
end;

procedure TG2DAndroidSurfaceHelper.UpdateBounds;
begin
end;

function TG2DAndroidSurfaceHelper.TryAcquireNativeWindow: Boolean;
begin
  Result := False;
end;

procedure TG2DAndroidSurfaceHelper.ReleaseNativeWindow;
begin
end;
{$ENDIF}

end.

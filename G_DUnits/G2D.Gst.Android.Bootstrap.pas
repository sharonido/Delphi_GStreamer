unit G2D.Gst.Android.Bootstrap;

interface

{$IF Defined(ANDROID)}
uses
  G2D.API.Loader;
{$ENDIF}

function G2DInitializeAndroidGStreamer: Boolean;
function G2DAndroidGStreamerInitialized: Boolean;
function G2DAndroidGStreamerLastError: string;

{$IF Defined(ANDROID)}
function G2DAndroidGStreamerHandle: TG2DLibraryHandle;
{$ENDIF}

implementation

uses
  System.SysUtils
{$IF Defined(ANDROID)}
  , Androidapi.Helpers
  , Androidapi.Jni
  , Androidapi.JNIBridge
  , Androidapi.Log
{$ENDIF}
  ;

{$IF Defined(ANDROID)}
type
  TGstAndroidInit = procedure(AEnv: PJNIEnv; AContext: JNIObject); cdecl;

var
  GAndroidGStreamerHandle: TG2DLibraryHandle = 0;
  GAndroidGStreamerInit: TGstAndroidInit = nil;
  GAndroidJNIOnLoad: TJNI_OnLoad = nil;
{$ENDIF}

var
  GAndroidGStreamerInitialized: Boolean = False;
  GAndroidGStreamerLastError: string = '';

function G2DAndroidGStreamerInitialized: Boolean;
begin
  Result := GAndroidGStreamerInitialized;
end;

function G2DAndroidGStreamerLastError: string;
begin
  Result := GAndroidGStreamerLastError;
end;

{$IF Defined(ANDROID)}
function G2DAndroidGStreamerHandle: TG2DLibraryHandle;
begin
  Result := GAndroidGStreamerHandle;
end;

procedure _SetAndroidGStreamerError(const AMessage: string);
begin
  GAndroidGStreamerLastError := AMessage;
  LOGE(MarshaledAString(UTF8String('G2D: ' + AMessage)));
end;

function _LoadAndroidGStreamerEntryPoint: Boolean;
begin
  Result := False;

  if Assigned(GAndroidGStreamerInit) then
    Exit(True);

  if GAndroidGStreamerHandle = 0 then
  begin
    GAndroidGStreamerHandle := G2DLoadLibrary('libgstreamer_android.so');
    if GAndroidGStreamerHandle = 0 then
    begin
      _SetAndroidGStreamerError(
        'Failed to load libgstreamer_android.so: ' + G2DLastLoadError);
      Exit;
    end;
  end;

  @GAndroidGStreamerInit := G2DLoadProc(GAndroidGStreamerHandle,
    'gst_android_init');
  if Assigned(GAndroidGStreamerInit) then
    Exit(True);

  @GAndroidJNIOnLoad := G2DLoadProc(GAndroidGStreamerHandle, 'JNI_OnLoad');
  if not Assigned(GAndroidJNIOnLoad) then
  begin
    _SetAndroidGStreamerError(
      'Failed to load gst_android_init or JNI_OnLoad: ' + G2DLastLoadError);
    Exit;
  end;

  Result := True;
end;

function G2DInitializeAndroidGStreamer: Boolean;
var
  LEnv: PJNIEnv;
  LContext: JNIObject;
  LJNIResult: JNIInt;
begin
  Result := False;

  if GAndroidGStreamerInitialized then
    Exit(True);

  GAndroidGStreamerLastError := '';

  if not _LoadAndroidGStreamerEntryPoint then
    Exit;

  if Assigned(GAndroidGStreamerInit) then
  begin
    LEnv := TJNIResolver.GetJNIEnv;
    if LEnv = nil then
    begin
      _SetAndroidGStreamerError('Failed to get JNI environment');
      Exit;
    end;

    LContext := JNIObject(TJNIResolver.JavaInstanceToID(TAndroidHelper.Context));
    if LContext = nil then
    begin
      _SetAndroidGStreamerError('Failed to get Android application context');
      Exit;
    end;

    GAndroidGStreamerInit(LEnv, LContext);
  end
  else
  begin
    if System.JavaMachine = nil then
    begin
      _SetAndroidGStreamerError('Failed to get Java VM');
      Exit;
    end;

    LJNIResult := GAndroidJNIOnLoad(System.JavaMachine, nil);
    if LJNIResult = JNI_ERR then
    begin
      _SetAndroidGStreamerError('GStreamer JNI_OnLoad failed');
      Exit;
    end;
  end;

  GAndroidGStreamerInitialized := True;
  LOGI('G2D: Android GStreamer bootstrap completed');
  Result := True;
end;
{$ELSE}
function G2DInitializeAndroidGStreamer: Boolean;
begin
  GAndroidGStreamerInitialized := True;
  GAndroidGStreamerLastError := '';
  Result := True;
end;
{$ENDIF}

end.

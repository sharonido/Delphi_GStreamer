unit G2D.Gst.Android.Bootstrap;

interface

{$IF Defined(ANDROID)}
uses
  G2D.API.Loader;
{$ENDIF}

function G2DInitializeAndroidGStreamer: Boolean;
function G2DInitializeAndroidGStreamerJava: Boolean;
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
  , Androidapi.JNI.GraphicsContentViewText
  , Androidapi.JNI.JavaTypes
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
  GAndroidJavaLibraryLoaded: Boolean = False;
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

procedure _DescribeAndClearJavaException(const AContext: string);
var
  LEnv: PJNIEnv;
begin
  LEnv := TJNIResolver.GetJNIEnv;
  if (LEnv <> nil) and (LEnv^.ExceptionCheck(LEnv) <> JNI_FALSE) then
  begin
    LOGE(MarshaledAString(UTF8String('G2D: Java exception at ' + AContext)));
    LEnv^.ExceptionDescribe(LEnv);
    LEnv^.ExceptionClear(LEnv);
  end;
end;

function _CallAndroidGStreamerJavaInit: Boolean;
var
  LEnv: PJNIEnv;
  LClassLoader: JNIObject;
  LClassLoaderClass: JNIClass;
  LLoadClassMethod: JNIMethodID;
  LGStreamerName: JNIString;
  LGStreamerClassObject: JNIObject;
  LGStreamerClass: JNIClass;
  LInitMethod: JNIMethodID;
  LContext: JNIObject;
  LArgs: TJNIValueArray;
  LName: UTF8String;
  LSignature: UTF8String;
begin
  Result := False;

  LEnv := TJNIResolver.GetJNIEnv;
  if LEnv = nil then
  begin
    _SetAndroidGStreamerError('Failed to get JNI environment');
    Exit;
  end;

  LClassLoader := TJNIResolver.JavaInstanceToID(
    TAndroidHelper.Context.getClassLoader);
  if LClassLoader = nil then
  begin
    _SetAndroidGStreamerError('Failed to get Android class loader');
    Exit;
  end;

  LClassLoaderClass := LEnv^.GetObjectClass(LEnv, LClassLoader);
  if LClassLoaderClass = nil then
  begin
    _SetAndroidGStreamerError('Failed to get Android class loader class');
    Exit;
  end;

  LName := UTF8String('loadClass');
  LSignature := UTF8String('(Ljava/lang/String;)Ljava/lang/Class;');
  LLoadClassMethod := LEnv^.GetMethodID(LEnv, LClassLoaderClass,
    MarshaledAString(LName), MarshaledAString(LSignature));
  if LLoadClassMethod = nil then
  begin
    _SetAndroidGStreamerError('Failed to get ClassLoader.loadClass method');
    Exit;
  end;

  LGStreamerName := LEnv^.NewStringUTF(LEnv,
    MarshaledAString(UTF8String('org.freedesktop.gstreamer.GStreamer')));
  if LGStreamerName = nil then
  begin
    _SetAndroidGStreamerError('Failed to create GStreamer Java class name');
    Exit;
  end;

  LArgs := ArgsToJNIValues([LGStreamerName]);
  LGStreamerClassObject := LEnv^.CallObjectMethodA(LEnv, LClassLoader,
    LLoadClassMethod, PJNIValue(LArgs));
  if LEnv^.ExceptionCheck(LEnv) <> JNI_FALSE then
  begin
    _DescribeAndClearJavaException('ClassLoader.loadClass(GStreamer)');
    _SetAndroidGStreamerError(
      'Failed to load org.freedesktop.gstreamer.GStreamer through app class loader');
    Exit;
  end;

  if LGStreamerClassObject = nil then
  begin
    _SetAndroidGStreamerError('Android class loader returned no GStreamer class');
    Exit;
  end;

  LGStreamerClass := JNIClass(LGStreamerClassObject);
  if LGStreamerClass = nil then
  begin
    _SetAndroidGStreamerError(
      'Failed to load org.freedesktop.gstreamer.GStreamer through app class loader');
    Exit;
  end;

  LName := UTF8String('init');
  LSignature := UTF8String('(Landroid/content/Context;)V');
  LInitMethod := LEnv^.GetStaticMethodID(LEnv, LGStreamerClass,
    MarshaledAString(LName), MarshaledAString(LSignature));
  if LInitMethod = nil then
  begin
    if LEnv^.ExceptionCheck(LEnv) <> JNI_FALSE then
      _DescribeAndClearJavaException('GetStaticMethodID(GStreamer.init)');
    _SetAndroidGStreamerError(
      'Failed to get GStreamer.init method; see logcat for Java exception');
    Exit;
  end;

  LContext := TJNIResolver.JavaInstanceToID(TAndroidHelper.Context);
  if LContext = nil then
  begin
    _SetAndroidGStreamerError('Failed to get Android application context');
    Exit;
  end;

  LArgs := ArgsToJNIValues([LContext]);
  LEnv^.CallStaticVoidMethodA(LEnv, LGStreamerClass, LInitMethod,
    PJNIValue(LArgs));
  if LEnv^.ExceptionCheck(LEnv) <> JNI_FALSE then
  begin
    _DescribeAndClearJavaException('CallStaticVoidMethod(GStreamer.init)');
    _SetAndroidGStreamerError(
      'GStreamer.init raised a Java exception; see logcat');
    Exit;
  end;

  Result := True;
end;

function _LoadAndroidGStreamerWithJava: Boolean;
begin
  Result := False;

  if GAndroidJavaLibraryLoaded then
    Exit(True);

  try
    if not _CallAndroidGStreamerJavaInit then
      Exit;
    GAndroidJavaLibraryLoaded := True;
    Result := True;
  except
    on E: Exception do
      _SetAndroidGStreamerError(
        'Failed to initialize gstreamer_android through Java: ' +
        E.ClassName + ': ' + E.Message);
  end;
end;

function G2DInitializeAndroidGStreamerJava: Boolean;
begin
  GAndroidGStreamerLastError := '';
  Result := _LoadAndroidGStreamerWithJava;
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

  if GAndroidJavaLibraryLoaded then
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

  if not _LoadAndroidGStreamerWithJava then
    Exit;

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
    if GAndroidJavaLibraryLoaded then
    begin
      GAndroidGStreamerInitialized := True;
      LOGI('G2D: Android GStreamer bootstrap completed');
      Exit(True);
    end;

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

function G2DInitializeAndroidGStreamerJava: Boolean;
begin
  GAndroidGStreamerLastError := '';
  Result := True;
end;
{$ENDIF}

end.

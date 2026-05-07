param(
  [string] $GStreamerRootAndroid = "$PSScriptRoot\..\..\tmp\gstreamer\android\1.28.2\gstreamer-1.0-android-universal-1.28.2",
  [string] $NdkBuild = "C:\Users\Public\Documents\Embarcadero\Studio\37.0\CatalogRepository\AndroidSDK-37.0.59082.6021\ndk\27.1.12297006\ndk-build.cmd"
)

$ErrorActionPreference = "Stop"

$JniDir = Join-Path $PSScriptRoot "jni"
$OutDir = Join-Path $PSScriptRoot "out"
$LibsOut = Join-Path $OutDir "libs"
$ObjOut = Join-Path $OutDir "obj"

if (-not (Test-Path $NdkBuild)) {
  throw "ndk-build.cmd not found: $NdkBuild"
}

if (-not (Test-Path $GStreamerRootAndroid)) {
  throw "GStreamer Android root not found: $GStreamerRootAndroid"
}

New-Item -ItemType Directory -Force -Path $LibsOut, $ObjOut | Out-Null

Push-Location $PSScriptRoot
try {
  & $NdkBuild `
    "NDK_PROJECT_PATH=$PSScriptRoot" `
    "APP_BUILD_SCRIPT=$JniDir\Android.mk" `
    "NDK_APPLICATION_MK=$JniDir\Application.mk" `
    "NDK_LIBS_OUT=$LibsOut" `
    "NDK_OUT=$ObjOut" `
    "GSTREAMER_ROOT_ANDROID=$GStreamerRootAndroid" `
    V=1
}
finally {
  Pop-Location
}

if ($LASTEXITCODE -ne 0) {
  throw "ndk-build failed with exit code $LASTEXITCODE"
}

$BuiltLib = Join-Path $LibsOut "arm64-v8a\libgstreamer_android.so"
if (-not (Test-Path $BuiltLib)) {
  throw "Expected output not found: $BuiltLib"
}

Write-Host "Built $BuiltLib"

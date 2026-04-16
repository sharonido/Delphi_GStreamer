unit G2D.OpenCV.API;

{------------------------------------------------------------------------------
  G2D.OpenCV.API
  Dynamic loader for G2DOpenCV.dll - the thin C wrapper around OpenCV.

  G2DOpenCV.dll exposes clean extern "C" functions that Delphi can call
  directly. It links internally against opencv_world4130.dll.

  Both DLLs must be findable by G2D_LoadDLLModule:
    1. Normal Windows search (exe dir, PATH)
    2. Walk-up search for a DLLs\ sibling folder in the directory tree
------------------------------------------------------------------------------}

interface

uses
  Winapi.Windows,
  System.SysUtils,
  G2D.Glib.API;

type
  EG2DOpenCVError = class(Exception);

  { Opaque handle to a cv::dnn::Net - never dereference in Delphi }
  TG2DCVNet = Pointer;

  { Detection result - matches G2DCV_Detection in G2DOpenCV.h (#pragma pack 1) }
  TG2DCVDetection = packed record
    ClassId    : Integer;
    Confidence : Single;
    X, Y, W, H : Single;   { normalised 0..1 }
    DLabel     : array[0..63] of AnsiChar;
  end;
  PG2DCVDetection = ^TG2DCVDetection;

var
  G2D_OpenCVHandle : HMODULE = 0;
  G2D_OpenCVLoaded : Boolean = False;

  { Lifecycle }
  _G2DCV_Init     : function: Integer; cdecl = nil;
  _G2DCV_Shutdown : procedure; cdecl = nil;
  _G2DCV_Version  : function: PAnsiChar; cdecl = nil;

  { Rotation }
  _G2DCV_RotateFrame : function(
    src    : PByte;
    dst    : PByte;
    width  : Integer;
    height : Integer;
    stride : Integer;
    angle  : Double;
    bgFill : Cardinal): Integer; cdecl = nil;

  { Object detection - Phase 2 }
  _G2DCV_Net_Load : function(
    modelPath  : PAnsiChar;
    configPath : PAnsiChar;
    framework  : PAnsiChar): TG2DCVNet; cdecl = nil;

  _G2DCV_Net_Free : procedure(
    net: TG2DCVNet); cdecl = nil;

  _G2DCV_Net_Detect : function(
    net           : TG2DCVNet;
    src           : PByte;
    width         : Integer;
    height        : Integer;
    stride        : Integer;
    confThreshold : Single;
    results       : PG2DCVDetection;
    maxResults    : Integer): Integer; cdecl = nil;

function  G2D_LoadOpenCV: Boolean;
procedure G2D_UnloadOpenCV;
function  G2D_OpenCVLoadedOK: Boolean;

{ Convenience wrappers }
function G2DCV_Version: string;
function G2DCV_RotateFrame(ASrc, ADst: PByte; AWidth, AHeight, AStride: Integer;
  AAngle: Double; ABgFill: Cardinal = 0): Boolean;

implementation

{ --- Internal helpers ------------------------------------------------------- }

function _LoadProcCV(const AName: AnsiString): Pointer;
begin
  Result := GetProcAddress(G2D_OpenCVHandle, PAnsiChar(AName));
  if Result = nil then
    raise EG2DOpenCVError.CreateFmt(
      'G2DOpenCV: required function not found: %s', [string(AName)]);
end;

procedure _ResetOpenCVPointers;
begin
  _G2DCV_Init       := nil;
  _G2DCV_Shutdown   := nil;
  _G2DCV_Version    := nil;
  _G2DCV_RotateFrame := nil;
  _G2DCV_Net_Load   := nil;
  _G2DCV_Net_Free   := nil;
  _G2DCV_Net_Detect := nil;
end;

procedure _BindOpenCVFunctions;
begin
  @_G2DCV_Init       := _LoadProcCV('G2DCV_Init');
  @_G2DCV_Shutdown   := _LoadProcCV('G2DCV_Shutdown');
  @_G2DCV_Version    := _LoadProcCV('G2DCV_Version');
  @_G2DCV_RotateFrame := _LoadProcCV('G2DCV_RotateFrame');
  @_G2DCV_Net_Load   := _LoadProcCV('G2DCV_Net_Load');
  @_G2DCV_Net_Free   := _LoadProcCV('G2DCV_Net_Free');
  @_G2DCV_Net_Detect := _LoadProcCV('G2DCV_Net_Detect');
end;

{ --- Public API ------------------------------------------------------------- }

function G2D_LoadOpenCV: Boolean;
begin
  if G2D_OpenCVLoaded then
    Exit(True);

  _ResetOpenCVPointers;

  G2D_OpenCVHandle := G2D_LoadDLLModule('G2DOpenCV.dll');

  try
    _BindOpenCVFunctions;
    _G2DCV_Init();
    G2D_OpenCVLoaded := True;
    Result := True;
  except
    FreeLibrary(G2D_OpenCVHandle);
    G2D_OpenCVHandle := 0;
    _ResetOpenCVPointers;
    G2D_OpenCVLoaded := False;
    raise;
  end;
end;

procedure G2D_UnloadOpenCV;
begin
  if G2D_OpenCVLoaded and Assigned(_G2DCV_Shutdown) then
    _G2DCV_Shutdown();

  if G2D_OpenCVHandle <> 0 then
  begin
    FreeLibrary(G2D_OpenCVHandle);
    G2D_OpenCVHandle := 0;
  end;

  _ResetOpenCVPointers;
  G2D_OpenCVLoaded := False;
end;

function G2D_OpenCVLoadedOK: Boolean;
begin
  Result := G2D_OpenCVLoaded and (G2D_OpenCVHandle <> 0);
end;

{ --- Convenience wrappers --------------------------------------------------- }

function G2DCV_Version: string;
begin
  if not G2D_OpenCVLoadedOK then
    Exit('not loaded');
  Result := string(AnsiString(_G2DCV_Version()));
end;

function G2DCV_RotateFrame(ASrc, ADst: PByte; AWidth, AHeight, AStride: Integer;
  AAngle: Double; ABgFill: Cardinal): Boolean;
begin
  Result := G2D_OpenCVLoadedOK and
            (_G2DCV_RotateFrame(ASrc, ADst, AWidth, AHeight,
                                AStride, AAngle, ABgFill) <> 0);
end;

initialization
  _ResetOpenCVPointers;

finalization
  G2D_UnloadOpenCV;

end.

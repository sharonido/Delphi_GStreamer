unit G2D.API.Loader;

interface

uses
  System.SysUtils;

type
  TG2DLibraryHandle = NativeUInt;

function G2DLoadLibrary(const ALibraryName: string): TG2DLibraryHandle;
function G2DLoadProc(const ALibraryHandle: TG2DLibraryHandle;
  const AProcName: AnsiString): Pointer;
function G2DUnloadLibrary(const ALibraryHandle: TG2DLibraryHandle): Boolean;
function G2DLastLoadError: string;
function G2DPlatformLibraryPrefix: string;
function G2DPlatformLibraryExtension: string;

implementation

{$IF Defined(MSWINDOWS)}
uses
  Winapi.Windows;

const
  LOAD_LIBRARY_SEARCH_DEFAULT_DIRS = $00001000;
  LOAD_LIBRARY_SEARCH_USER_DIRS    = $00000400;

type
  TDllDirectory = NativeUInt;

function AddDllDirectory(NewDirectory: PWideChar): TDllDirectory;
  stdcall; external 'kernel32.dll' name 'AddDllDirectory';
function RemoveDllDirectory(Cookie: TDllDirectory): BOOL;
  stdcall; external 'kernel32.dll' name 'RemoveDllDirectory';
{$ELSEIF Defined(ANDROID) or Defined(LINUX) or Defined(MACOS)}
uses
  Posix.Dlfcn;
{$ENDIF}

{$IF Defined(MSWINDOWS)}
function _G2DFindInDLLsFolder(const ALibraryName: string): string;
var
  LExePath: string;
  LDir: string;
  LCandidate: string;
begin
  Result := '';
  LExePath := ExtractFilePath(ParamStr(0));
  LDir := ExcludeTrailingPathDelimiter(LExePath);

  while LDir <> '' do
  begin
    LCandidate := IncludeTrailingPathDelimiter(LDir) + 'DLLs' + PathDelim +
      ALibraryName;
    if FileExists(LCandidate) then
      Exit(LCandidate);

    LDir := ExcludeTrailingPathDelimiter(ExtractFilePath(LDir));
    if LDir.EndsWith(':') then
      LDir := '';
  end;
end;

function _G2DTryLoadLibraryPath(const AFullPath: string): TG2DLibraryHandle;
var
  LDir: string;
  LCookie: TDllDirectory;
begin
  if not FileExists(AFullPath) then
    Exit(0);

  LDir := ExtractFilePath(AFullPath);
  LCookie := AddDllDirectory(PWideChar(LDir));
  try
    SetLastError(0);
    Result := TG2DLibraryHandle(LoadLibraryEx(PChar(AFullPath), 0,
      LOAD_LIBRARY_SEARCH_DEFAULT_DIRS or LOAD_LIBRARY_SEARCH_USER_DIRS));
  finally
    if LCookie <> 0 then
      RemoveDllDirectory(LCookie);
  end;

  if Result <> 0 then
    SetDllDirectory(PChar(ExcludeTrailingPathDelimiter(LDir)));
end;
{$ENDIF}

function G2DLoadLibrary(const ALibraryName: string): TG2DLibraryHandle;
{$IF Defined(MSWINDOWS)}
var
  LFound: string;
begin
  SetLastError(0);
  Result := TG2DLibraryHandle(LoadLibrary(PChar(ALibraryName)));
  if Result <> 0 then
    Exit;

  LFound := _G2DFindInDLLsFolder(ExtractFileName(ALibraryName));
  if LFound <> '' then
  begin
    Result := _G2DTryLoadLibraryPath(LFound);
    if Result <> 0 then
      Exit;
  end;

  SetLastError(0);
  Result := TG2DLibraryHandle(LoadLibrary(PChar(ALibraryName)));
end;
{$ELSEIF Defined(ANDROID) or Defined(LINUX) or Defined(MACOS)}
begin
  dlerror;
  Result := TG2DLibraryHandle(dlopen(MarshaledAString(UTF8String(ALibraryName)),
    RTLD_NOW));
end;
{$ELSE}
begin
  Result := 0;
end;
{$ENDIF}

function G2DLoadProc(const ALibraryHandle: TG2DLibraryHandle;
  const AProcName: AnsiString): Pointer;
{$IF Defined(MSWINDOWS)}
begin
  SetLastError(0);
  if ALibraryHandle = 0 then
    Exit(nil);

  Result := GetProcAddress(HMODULE(ALibraryHandle), PAnsiChar(AProcName));
end;
{$ELSEIF Defined(ANDROID) or Defined(LINUX) or Defined(MACOS)}
begin
  dlerror;
  if ALibraryHandle = 0 then
    Exit(nil);

  Result := dlsym(ALibraryHandle, PAnsiChar(AProcName));
end;
{$ELSE}
begin
  Result := nil;
end;
{$ENDIF}

function G2DUnloadLibrary(const ALibraryHandle: TG2DLibraryHandle): Boolean;
{$IF Defined(MSWINDOWS)}
begin
  if ALibraryHandle = 0 then
    Exit(True);

  SetLastError(0);
  Result := FreeLibrary(HMODULE(ALibraryHandle));
end;
{$ELSEIF Defined(ANDROID) or Defined(LINUX) or Defined(MACOS)}
begin
  if ALibraryHandle = 0 then
    Exit(True);

  dlerror;
  Result := dlclose(ALibraryHandle) = 0;
end;
{$ELSE}
begin
  Result := ALibraryHandle = 0;
end;
{$ENDIF}

function G2DLastLoadError: string;
{$IF Defined(MSWINDOWS)}
var
  LBuf: array[0..1023] of Char;
  LError: DWORD;
begin
  LError := GetLastError;
  if LError = 0 then
    Exit('');

  FillChar(LBuf, SizeOf(LBuf), 0);
  FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM or FORMAT_MESSAGE_IGNORE_INSERTS,
    nil, LError, 0, LBuf, Length(LBuf), nil);
  Result := Trim(LBuf);
  if Result = '' then
    Result := SysErrorMessage(LError);
end;
{$ELSEIF Defined(ANDROID) or Defined(LINUX) or Defined(MACOS)}
var
  LError: MarshaledAString;
begin
  LError := dlerror;
  if LError = nil then
    Result := ''
  else
    Result := string(UTF8String(LError));
end;
{$ELSEIF Defined(IOS)}
begin
  Result := 'Dynamic library loading is restricted on iOS';
end;
{$ELSE}
begin
  Result := 'Dynamic library loading is not implemented for this platform';
end;
{$ENDIF}

function G2DPlatformLibraryPrefix: string;
begin
{$IF Defined(MSWINDOWS)}
  Result := '';
{$ELSEIF Defined(ANDROID) or Defined(LINUX) or Defined(MACOS) or Defined(IOS)}
  Result := 'lib';
{$ELSE}
  Result := '';
{$ENDIF}
end;

function G2DPlatformLibraryExtension: string;
begin
{$IF Defined(MSWINDOWS)}
  Result := '.dll';
{$ELSEIF Defined(ANDROID) or Defined(LINUX)}
  Result := '.so';
{$ELSEIF Defined(MACOS)}
  Result := '.dylib';
{$ELSEIF Defined(IOS)}
  Result := '.dylib';
{$ELSE}
  Result := '';
{$ENDIF}
end;

end.

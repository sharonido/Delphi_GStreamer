unit G2D.Glib.API;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  G2D.Glib.Types;

{ AddDllDirectory / RemoveDllDirectory / LoadLibraryEx flags not declared
  in all Delphi versions - import and define manually. }
const
  LOAD_LIBRARY_SEARCH_DEFAULT_DIRS = $00001000;
  LOAD_LIBRARY_SEARCH_USER_DIRS    = $00000400;

type
  TDllDirectory = NativeUInt;

function AddDllDirectory(NewDirectory: PWideChar): TDllDirectory;
  stdcall; external 'kernel32.dll' name 'AddDllDirectory';
function RemoveDllDirectory(Cookie: TDllDirectory): BOOL;
  stdcall; external 'kernel32.dll' name 'RemoveDllDirectory';

type
  EG2DAPILoaderError = class(Exception);
  EG2DGlibError = class(Exception);

var
  G2D_GlibHandle: HMODULE = 0;
  G2D_GlibLoaded: Boolean = False;

  _g_malloc: function(n_bytes: gsize): gpointer; cdecl = nil;
  _g_try_malloc: function(n_bytes: gsize): gpointer; cdecl = nil;
  _g_free: procedure(mem: gpointer); cdecl = nil;
  _g_strdup: function(const D_str: Pgchar): Pgchar; cdecl = nil;

  _g_error_free: procedure(error: PGError); cdecl = nil;
  _g_clear_error: procedure(error: PPGError); cdecl = nil;

  _g_list_append: function(list: PGList; data: gpointer): PGList; cdecl = nil;
  _g_list_prepend: function(list: PGList; data: gpointer): PGList; cdecl = nil;
  _g_list_remove: function(list: PGList; data: gconstpointer): PGList; cdecl = nil;
  _g_list_free: procedure(list: PGList); cdecl = nil;
  _g_list_length: function(list: PGList): guint; cdecl = nil;

  _g_slist_append: function(list: PGSList; data: gpointer): PGSList; cdecl = nil;
  _g_slist_prepend: function(list: PGSList; data: gpointer): PGSList; cdecl = nil;
  _g_slist_remove: function(list: PGSList; data: gconstpointer): PGSList; cdecl = nil;
  _g_slist_free: procedure(list: PGSList); cdecl = nil;
  _g_slist_length: function(list: PGSList): guint; cdecl = nil;

  { Tutorial 6 - Quark }
  _g_quark_to_string: function(quark: GQuark): Pgchar; cdecl = nil;


function G2D_LoadDLLModule(const ADllPath: string): HMODULE;
function G2D_LoadGlib: Boolean;
procedure G2D_UnloadGlib;
function G2D_GlibLoadedOK: Boolean;

{ D-wrapper helper functions }
function DGQuarkToString(AQuark: GQuark): string;

implementation

function _LoadProc(const AName: AnsiString): Pointer;
begin
  Result := GetProcAddress(G2D_GlibHandle, PAnsiChar(AName));
  if Result = nil then
    raise EG2DGlibError.CreateFmt(
      'GLib: required function not found: %s',
      [string(AName)]
    );
end;

procedure _ResetGlibPointers;
begin
  _g_malloc := nil;
  _g_try_malloc := nil;
  _g_free := nil;
  _g_strdup := nil;

  _g_error_free := nil;
  _g_clear_error := nil;

  _g_list_append := nil;
  _g_list_prepend := nil;
  _g_list_remove := nil;
  _g_list_free := nil;
  _g_list_length := nil;

  _g_slist_append := nil;
  _g_slist_prepend := nil;
  _g_slist_remove := nil;
  _g_slist_free := nil;
  _g_slist_length := nil;

  { Tutorial 6 }
  _g_quark_to_string := nil;
end;

procedure _BindGlibFunctions;
begin
  @_g_malloc := _LoadProc('g_malloc');
  @_g_try_malloc := _LoadProc('g_try_malloc');
  @_g_free := _LoadProc('g_free');
  @_g_strdup := _LoadProc('g_strdup');

  @_g_error_free := _LoadProc('g_error_free');
  @_g_clear_error := _LoadProc('g_clear_error');

  @_g_list_append := _LoadProc('g_list_append');
  @_g_list_prepend := _LoadProc('g_list_prepend');
  @_g_list_remove := _LoadProc('g_list_remove');
  @_g_list_free := _LoadProc('g_list_free');
  @_g_list_length := _LoadProc('g_list_length');

  @_g_slist_append := _LoadProc('g_slist_append');
  @_g_slist_prepend := _LoadProc('g_slist_prepend');
  @_g_slist_remove := _LoadProc('g_slist_remove');
  @_g_slist_free := _LoadProc('g_slist_free');
  @_g_slist_length := _LoadProc('g_slist_length');

  { Tutorial 6 }
  @_g_quark_to_string := _LoadProc('g_quark_to_string');
end;


function G2D_LastErrorText: string;
var
  LBuf: array[0..1023] of Char;
begin
  FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM or FORMAT_MESSAGE_IGNORE_INSERTS,
                nil, GetLastError, 0, LBuf, Length(LBuf), nil);
  Result := Trim(LBuf);
end;

{ Try to load a DLL by full path, returning 0 on failure without raising. }
function G2D_TryLoadLibrary(const AFullPath: string): HMODULE;
var
  LDir    : string;
  LCookie : TDllDirectory;
begin
  if not FileExists(AFullPath) then
    Exit(0);

  { Add the DLL's own directory so Windows finds its dependencies there }
  LDir    := ExtractFilePath(AFullPath);
  LCookie := AddDllDirectory(PWideChar(LDir));
  try
    SetLastError(0);
    Result := LoadLibraryEx(PChar(AFullPath), 0,
                LOAD_LIBRARY_SEARCH_DEFAULT_DIRS or
                LOAD_LIBRARY_SEARCH_USER_DIRS);
  finally
    if LCookie <> 0 then
      RemoveDllDirectory(LCookie);
  end;
end;

{ Walk up from the exe directory looking for a sibling 'DLLs' folder.
  Returns the full path to the DLL if found, otherwise ''. }
function G2D_FindInDLLsFolder(const ADllName: string): string;
var
  LExePath : string;
  LDir     : string;
  LCandidate: string;
begin
  Result  := '';
  LExePath := ExtractFilePath(ParamStr(0));
  LDir     := ExcludeTrailingPathDelimiter(LExePath);

  while LDir <> '' do
  begin
    LCandidate := IncludeTrailingPathDelimiter(LDir) + 'DLLs' + PathDelim + ADllName;
    if FileExists(LCandidate) then
    begin
      Result := LCandidate;
      Exit;
    end;
    { Go one level up }
    LDir := ExcludeTrailingPathDelimiter(ExtractFilePath(LDir));
    if LDir.EndsWith(':') then LDir := '';
  end;
end;

function G2D_LoadDLLModule(const ADllPath: string): HMODULE;
var
  LHandle  : HMODULE;
  LFound   : string;
  LDllName : string;
begin
  if ADllPath = '' then
    raise EG2DAPILoaderError.Create('DLL name/path is empty');

  { Step 1: try normal Windows search (exe dir + PATH) }
  SetLastError(0);
  LHandle := LoadLibrary(PChar(ADllPath));
  if LHandle <> 0 then
  begin
    Result := LHandle;
    Exit;
  end;

  { Step 2: walk up from exe dir looking for a DLLs\ sibling folder }
  LDllName := ExtractFileName(ADllPath);
  LFound   := G2D_FindInDLLsFolder(LDllName);
  if LFound <> '' then
  begin
    LHandle := G2D_TryLoadLibrary(LFound);
    if LHandle <> 0 then
    begin
      Result := LHandle;
      Exit;
    end;
  end;

  { Both searches failed - raise a descriptive error }
  SetLastError(0);
  LoadLibrary(PChar(ADllPath));  { re-trigger to get correct LastError }
  case GetLastError of
    ERROR_MOD_NOT_FOUND:
      raise EG2DAPILoaderError.CreateFmt(
        'DLL not found or dependency missing: %s', [LDllName]);
    ERROR_BAD_EXE_FORMAT:
      raise EG2DAPILoaderError.CreateFmt(
        'DLL wrong architecture (32/64 mismatch): %s', [LDllName]);
  else
    raise EG2DAPILoaderError.CreateFmt(
      'Failed to load DLL: %s (%s)', [LDllName, G2D_LastErrorText]);
  end;
end;


function G2D_LoadGlib: Boolean;

begin
  if G2D_GlibLoaded then
    Exit(True);

  _ResetGlibPointers;

  G2D_GlibHandle := G2D_LoadDLLModule(PChar('glib-2.0-0.dll'));
  if G2D_GlibHandle = 0 then
    raise EG2DGlibError.Create('Failed to load GLib DLL: glib-2.0-0.dll');

  try
    _BindGlibFunctions;
    G2D_GlibLoaded := True;
    Result := True;
  except
    FreeLibrary(G2D_GlibHandle);
    G2D_GlibHandle := 0;
    _ResetGlibPointers;
    G2D_GlibLoaded := False;
    raise;
  end;
end;

procedure G2D_UnloadGlib;
begin
  if G2D_GlibHandle <> 0 then
  begin
    FreeLibrary(G2D_GlibHandle);
    G2D_GlibHandle := 0;
  end;

  _ResetGlibPointers;
  G2D_GlibLoaded := False;
end;

function G2D_GlibLoadedOK: Boolean;
begin
  Result := G2D_GlibLoaded and (G2D_GlibHandle <> 0);
end;

{ D-wrapper helper functions }

function DGQuarkToString(AQuark: GQuark): string;
var
  P: Pgchar;
begin
  P := _g_quark_to_string(AQuark);
  if P = nil then
    Exit('');
  Result := string(UTF8String(AnsiString(P)));
end;

initialization
  _ResetGlibPointers;

finalization
  G2D_UnloadGlib;

end.

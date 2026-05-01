unit G2D.GstFFT.API;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  G2D.Glib.Types;

type
  PGstFFTF32 = Pointer;

  GstFFTWindow = gint;

  GstFFTF32Complex = record
    r: Single;
    i: Single;
  end;
  PGstFFTF32Complex = ^GstFFTF32Complex;

const
  GST_FFT_WINDOW_RECTANGULAR = GstFFTWindow(0);
  GST_FFT_WINDOW_HAMMING     = GstFFTWindow(1);
  GST_FFT_WINDOW_HANN        = GstFFTWindow(2);
  GST_FFT_WINDOW_BARTLETT    = GstFFTWindow(3);
  GST_FFT_WINDOW_BLACKMAN    = GstFFTWindow(4);

var
  _gst_fft_next_fast_length: function(n: gint): gint; cdecl = nil;

  _gst_fft_f32_new: function(len: gint; inverse: gboolean): PGstFFTF32; cdecl = nil;
  _gst_fft_f32_free: procedure(self: PGstFFTF32); cdecl = nil;
  _gst_fft_f32_fft: procedure(self: PGstFFTF32; timedata: PSingle;
    freqdata: PGstFFTF32Complex); cdecl = nil;
  _gst_fft_f32_inverse_fft: procedure(self: PGstFFTF32;
    freqdata: PGstFFTF32Complex; timedata: PSingle); cdecl = nil;
  _gst_fft_f32_window: procedure(self: PGstFFTF32; timedata: PSingle;
    window: GstFFTWindow); cdecl = nil;

function G2D_LoadGstFFT: Boolean;
procedure G2D_UnloadGstFFT;

implementation

var
  GstFFTHandle: HMODULE = 0;

function _LoadProcGstFFT(const AName: PAnsiChar): Pointer;
begin
  Result := nil;
  if GstFFTHandle <> 0 then
    Result := GetProcAddress(GstFFTHandle, AName);
end;

function G2D_LoadGstFFT: Boolean;
begin
  if GstFFTHandle <> 0 then
    Exit(True);

  GstFFTHandle := LoadLibrary('gstfft-1.0-0.dll');
  if GstFFTHandle = 0 then
    Exit(False);

  @_gst_fft_next_fast_length := _LoadProcGstFFT('gst_fft_next_fast_length');

  @_gst_fft_f32_new := _LoadProcGstFFT('gst_fft_f32_new');
  @_gst_fft_f32_free := _LoadProcGstFFT('gst_fft_f32_free');
  @_gst_fft_f32_fft := _LoadProcGstFFT('gst_fft_f32_fft');
  @_gst_fft_f32_inverse_fft := _LoadProcGstFFT('gst_fft_f32_inverse_fft');
  @_gst_fft_f32_window := _LoadProcGstFFT('gst_fft_f32_window');

  Result :=
    Assigned(_gst_fft_next_fast_length) and
    Assigned(_gst_fft_f32_new) and
    Assigned(_gst_fft_f32_free) and
    Assigned(_gst_fft_f32_fft) and
    Assigned(_gst_fft_f32_inverse_fft) and
    Assigned(_gst_fft_f32_window);

  if not Result then
    G2D_UnloadGstFFT;
end;

procedure G2D_UnloadGstFFT;
begin
  _gst_fft_next_fast_length := nil;
  _gst_fft_f32_new := nil;
  _gst_fft_f32_free := nil;
  _gst_fft_f32_fft := nil;
  _gst_fft_f32_inverse_fft := nil;
  _gst_fft_f32_window := nil;

  if GstFFTHandle <> 0 then
  begin
    FreeLibrary(GstFFTHandle);
    GstFFTHandle := 0;
  end;
end;

initialization

finalization
  G2D_UnloadGstFFT;

end.

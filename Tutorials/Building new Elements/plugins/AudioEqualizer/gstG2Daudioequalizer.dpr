library gstG2Daudioequalizer;

{------------------------------------------------------------------------------
  gstG2Daudioequalizer

  Standalone GStreamer plugin DLL example for a Delphi audio element.

  This project registers one element:

    g2dequalizer

  Dynamic loader export:
    gst_plugin_g2daudioequalizer_get_desc
    gst_plugin_G2Daudioequalizer_get_desc

  Static registration-style export:
    gst_plugin_g2daudioequalizer_register
    gst_plugin_G2Daudioequalizer_register
------------------------------------------------------------------------------}

uses
  System.SysUtils,
  G2D.Glib.Types in '..\..\..\..\G_Types\G2D.Glib.Types.pas',
  G2D.Glib.API in '..\..\..\..\G_API\G2D.Glib.API.pas',
  G2D.Gobject.Types in '..\..\..\..\G_Types\G2D.Gobject.Types.pas',
  G2D.Gobject.API in '..\..\..\..\G_API\G2D.Gobject.API.pas',
  G2D.Gst.Types in '..\..\..\..\G_Types\G2D.Gst.Types.pas',
  G2D.Gst.API in '..\..\..\..\G_API\G2D.Gst.API.pas',
  G2D.Plugin.Types in '..\..\..\..\G_Types\G2D.Plugin.Types.pas',
  G2D.Plugin.API in '..\..\..\..\G_API\G2D.Plugin.API.pas',
  G2D.Plugin.Element in '..\..\..\..\G_DPlugin\G2D.Plugin.Element.pas',
  G2D.Plugin.BaseFilter in '..\..\..\..\G_DPlugin\G2D.Plugin.BaseFilter.pas',
  G2D.Plugin.AudioFilter in '..\..\..\..\G_DPlugin\G2D.Plugin.AudioFilter.pas',
  G2D.Plugin.AudioEqualizer in 'G2D.Plugin.AudioEqualizer.pas',
  G2D.API.Loader in '..\..\..\..\G_API\G2D.API.Loader.pas';

const
  G2D_PLUGIN_NAME             = 'g2daudioequalizer';
  G2D_PLUGIN_DESCRIPTION      = 'G2D Delphi audio equalizer filter plugin';
  G2D_PLUGIN_VERSION          = '0.1.0';
  G2D_PLUGIN_LICENSE          = 'MIT';
  G2D_PLUGIN_SOURCE           = 'G2D';
  G2D_PLUGIN_PACKAGE          = 'GStreamer to Delphi Wrapper';
  G2D_PLUGIN_ORIGIN           = 'https://github.com/sharonido/Delphi_GStreamer';

var
  GPluginNameUtf8: UTF8String = UTF8String(G2D_PLUGIN_NAME);
  GPluginDescriptionUtf8: UTF8String = UTF8String(G2D_PLUGIN_DESCRIPTION);
  GPluginVersionUtf8: UTF8String = UTF8String(G2D_PLUGIN_VERSION);
  GPluginLicenseUtf8: UTF8String = UTF8String(G2D_PLUGIN_LICENSE);
  GPluginSourceUtf8: UTF8String = UTF8String(G2D_PLUGIN_SOURCE);
  GPluginPackageUtf8: UTF8String = UTF8String(G2D_PLUGIN_PACKAGE);
  GPluginOriginUtf8: UTF8String = UTF8String(G2D_PLUGIN_ORIGIN);

function GstPluginInit(plugin: PGstPlugin): gboolean; cdecl;
begin
  try
    G2D_RequirePluginAPI;
    Result := G2DRegisterAudioEqualizer(plugin);
  except
    Result := 0;
  end;
end;

var
  GPluginDesc: GstPluginDesc = (
    major_version: G2D_GST_VERSION_MAJOR;
    minor_version: G2D_GST_VERSION_MINOR;
    name: nil;
    description: nil;
    plugin_init: GstPluginInit;
    version: nil;
    license: nil;
    source: nil;
    package: nil;
    origin: nil;
    release_datetime: nil;
    _gst_reserved: (nil, nil, nil, nil)
  );

procedure InitPluginDesc;
begin
  GPluginDesc.name := Pgchar(PAnsiChar(GPluginNameUtf8));
  GPluginDesc.description := Pgchar(PAnsiChar(GPluginDescriptionUtf8));
  GPluginDesc.version := Pgchar(PAnsiChar(GPluginVersionUtf8));
  GPluginDesc.license := Pgchar(PAnsiChar(GPluginLicenseUtf8));
  GPluginDesc.source := Pgchar(PAnsiChar(GPluginSourceUtf8));
  GPluginDesc.package := Pgchar(PAnsiChar(GPluginPackageUtf8));
  GPluginDesc.origin := Pgchar(PAnsiChar(GPluginOriginUtf8));
end;

function gst_plugin_g2daudioequalizer_get_desc: PGstPluginDesc; cdecl;
begin
  InitPluginDesc;
  Result := @GPluginDesc;
end;

procedure gst_plugin_g2daudioequalizer_register; cdecl;
begin
  InitPluginDesc;
  try
    G2D_RequirePluginAPI;
    _gst_plugin_register_static(
      GPluginDesc.major_version,
      GPluginDesc.minor_version,
      GPluginDesc.name,
      GPluginDesc.description,
      GPluginDesc.plugin_init,
      GPluginDesc.version,
      GPluginDesc.license,
      GPluginDesc.source,
      GPluginDesc.package,
      GPluginDesc.origin);
  except
    { Static registration is optional for this DLL plugin. Dynamic loading uses
      gst_plugin_g2daudioequalizer_get_desc. }
  end;
end;

exports
  gst_plugin_g2daudioequalizer_get_desc,
  gst_plugin_g2daudioequalizer_get_desc name 'gst_plugin_G2Daudioequalizer_get_desc',
  gst_plugin_g2daudioequalizer_register,
  gst_plugin_g2daudioequalizer_register name 'gst_plugin_G2Daudioequalizer_register';

begin
  System.IsMultiThread := True;
  InitPluginDesc;
end.

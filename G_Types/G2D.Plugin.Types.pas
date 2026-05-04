unit G2D.Plugin.Types;

{------------------------------------------------------------------------------
  G2D.Plugin.Types

  ABI-level types used when authoring real GStreamer plugin DLLs in Delphi.
  Keep this unit small and close to the C declarations.
------------------------------------------------------------------------------}

interface

{$MINENUMSIZE 4}

uses
  G2D.Glib.Types,
  G2D.Gobject.Types,
  G2D.Gst.Types;

const
  G2D_GST_VERSION_MAJOR = 1;
  G2D_GST_VERSION_MINOR = 0;

type
  GstRank = guint;
  PGstRank = ^GstRank;

const
  GST_RANK_NONE      = GstRank(0);
  GST_RANK_MARGINAL  = GstRank(64);
  GST_RANK_SECONDARY = GstRank(128);
  GST_RANK_PRIMARY   = GstRank(256);

type
  TGstPluginInitFunc = GstPluginInitFunc;

  TGstPadChainFunction = GstPadChainFunction;
  TGstPadEventFunction = GstPadEventFunction;
  TGstPadQueryFunction = GstPadQueryFunction;

  PGstPluginDesc = ^GstPluginDesc;
  GstPluginDesc = record
    major_version: gint;
    minor_version: gint;
    name: Pgchar;
    description: Pgchar;
    plugin_init: GstPluginInitFunc;
    version: Pgchar;
    license: Pgchar;
    source: Pgchar;
    package: Pgchar;
    origin: Pgchar;
    release_datetime: Pgchar;
    _gst_reserved: array[0..GST_PADDING - 1] of gpointer;
  end;

  TG2DPluginMetadata = record
    LongName: string;
    Classification: string;
    Description: string;
    Author: string;
  end;

  TG2DPadTemplateInfo = record
    NameTemplate: string;
    Direction: GstPadDirection;
    Presence: GstPadPresence;
    Caps: string;
  end;

  TG2DStaticPadTemplate = record
    NameTemplateUtf8: UTF8String;
    CapsUtf8: UTF8String;
    Template: GstStaticPadTemplate;
  end;

implementation

end.

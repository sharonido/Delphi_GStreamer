unit G2D.Gst.Types;

interface

{$MINENUMSIZE 4}

uses
  G2D.Glib.Types,
  G2D.Gobject.Types;

const
  GST_PADDING       = 4;
  GST_PADDING_LARGE = 20;

type
{==============================================================================
  Basic scalar types
==============================================================================}

  GstClockTime = guint64;
  PGstClockTime = ^GstClockTime;
  PPGstClockTime = ^PGstClockTime;

  GstClockTimeDiff = gint64;
  PGstClockTimeDiff = ^GstClockTimeDiff;
  PPGstClockTimeDiff = ^PGstClockTimeDiff;

  GstMessageType = guint;
  PGstMessageType = ^GstMessageType;
  PPGstMessageType = ^PGstMessageType;

  GstState = gint;
  PGstState = ^GstState;
  PPGstState = ^PGstState;

  GstStateChangeReturn = gint;
  PGstStateChangeReturn = ^GstStateChangeReturn;
  PPGstStateChangeReturn = ^PGstStateChangeReturn;

  GstStateChange = gint;
  PGstStateChange = ^GstStateChange;
  PPGstStateChange = ^PGstStateChange;

  GstPadDirection = gint;
  PGstPadDirection = ^GstPadDirection;
  PPGstPadDirection = ^PGstPadDirection;

  GstPadMode = gint;
  PGstPadMode = ^GstPadMode;
  PPGstPadMode = ^PGstPadMode;

  GstPadLinkReturn = gint;
  PGstPadLinkReturn = ^GstPadLinkReturn;
  PPGstPadLinkReturn = ^PGstPadLinkReturn;

  GstFlowReturn = gint;
  PGstFlowReturn = ^GstFlowReturn;
  PPGstFlowReturn = ^PGstFlowReturn;

  GstMapFlags = guint;
  PGstMapFlags = ^GstMapFlags;
  PPGstMapFlags = ^PGstMapFlags;

  GstBufferCopyFlags = guint;
  PGstBufferCopyFlags = ^GstBufferCopyFlags;
  PPGstBufferCopyFlags = ^PGstBufferCopyFlags;

  GstMiniObjectFlags = guint;
  PGstMiniObjectFlags = ^GstMiniObjectFlags;
  PPGstMiniObjectFlags = ^PGstMiniObjectFlags;

  GstObjectFlags = guint32;
  PGstObjectFlags = ^GstObjectFlags;
  PPGstObjectFlags = ^PGstObjectFlags;

  GstElementFlags = guint32;
  PGstElementFlags = ^GstElementFlags;
  PPGstElementFlags = ^PGstElementFlags;

  GstPadFlags = guint32;
  PGstPadFlags = ^GstPadFlags;
  PPGstPadFlags = ^PGstPadFlags;

  GstFormat = gint;
  PGstFormat = ^GstFormat;
  PPGstFormat = ^PGstFormat;

  GstSeekFlags = guint;
  PGstSeekFlags = ^GstSeekFlags;
  PPGstSeekFlags = ^PGstSeekFlags;

  GstSeekType = gint;
  PGstSeekType = ^GstSeekType;
  PPGstSeekType = ^PGstSeekType;

  GstPadPresence = gint;
  PGstPadPresence = ^GstPadPresence;
  PPGstPadPresence = ^PGstPadPresence;

  GstAudioFormat = gint;
  PGstAudioFormat = ^GstAudioFormat;
  PPGstAudioFormat = ^PGstAudioFormat;

  GstAudioChannelPosition = gint;
  PGstAudioChannelPosition = ^GstAudioChannelPosition;
  PPGstAudioChannelPosition = ^PGstAudioChannelPosition;

  GstAudioFormatFlags = guint;
  PGstAudioFormatFlags = ^GstAudioFormatFlags;
  PPGstAudioFormatFlags = ^PGstAudioFormatFlags;

  GstAudioPackFlags = guint;
  PGstAudioPackFlags = ^GstAudioPackFlags;
  PPGstAudioPackFlags = ^PGstAudioPackFlags;

  GstAudioFlags = guint;
  PGstAudioFlags = ^GstAudioFlags;
  PPGstAudioFlags = ^PGstAudioFlags;

  GstAudioLayout = gint;
  PGstAudioLayout = ^GstAudioLayout;
  PPGstAudioLayout = ^PGstAudioLayout;


  GstVideoFormat = gint;
  PGstVideoFormat = ^GstVideoFormat;
  PPGstVideoFormat = ^PGstVideoFormat;

  GstVideoFrameFlags = guint;
  PGstVideoFrameFlags = ^GstVideoFrameFlags;
  PPGstVideoFrameFlags = ^PGstVideoFrameFlags;

Const
  GST_VIDEO_FORMAT_UNKNOWN = GstVideoFormat(0);
  GST_VIDEO_FORMAT_ENCODED = GstVideoFormat(1);
  GST_VIDEO_FORMAT_I420    = GstVideoFormat(2);
  GST_VIDEO_FORMAT_YV12    = GstVideoFormat(3);
  GST_VIDEO_FORMAT_YUY2    = GstVideoFormat(4);
  GST_VIDEO_FORMAT_UYVY    = GstVideoFormat(5);
  GST_VIDEO_FORMAT_AYUV    = GstVideoFormat(6);
  GST_VIDEO_FORMAT_RGBx    = GstVideoFormat(7);
  GST_VIDEO_FORMAT_BGRx    = GstVideoFormat(8);
  GST_VIDEO_FORMAT_xRGB    = GstVideoFormat(9);
  GST_VIDEO_FORMAT_xBGR    = GstVideoFormat(10);
  GST_VIDEO_FORMAT_RGBA    = GstVideoFormat(11);
  GST_VIDEO_FORMAT_BGRA    = GstVideoFormat(12);
  GST_VIDEO_FORMAT_ARGB    = GstVideoFormat(13);
  GST_VIDEO_FORMAT_ABGR    = GstVideoFormat(14);
  GST_VIDEO_FORMAT_RGB     = GstVideoFormat(15);
  GST_VIDEO_FORMAT_BGR     = GstVideoFormat(16);
  GST_VIDEO_FORMAT_NV12    = GstVideoFormat(23);
  GST_VIDEO_FORMAT_NV21    = GstVideoFormat(24);

  GST_VIDEO_FRAME_FLAG_NONE        = GstVideoFrameFlags(0);
  GST_VIDEO_FRAME_FLAG_INTERLACED  = GstVideoFrameFlags(1 shl 0);
  GST_VIDEO_FRAME_FLAG_TFF         = GstVideoFrameFlags(1 shl 1);
  GST_VIDEO_FRAME_FLAG_RFF         = GstVideoFrameFlags(1 shl 2);
  GST_VIDEO_FRAME_FLAG_ONEFIELD    = GstVideoFrameFlags(1 shl 3);
  GST_VIDEO_FRAME_FLAG_MULTIPLE_VIEW = GstVideoFrameFlags(1 shl 4);
  GST_VIDEO_FRAME_FLAG_FIRST_IN_BUNDLE = GstVideoFrameFlags(1 shl 5);

const
  GST_CLOCK_TIME_NONE = GstClockTime(High(guint64));
  GST_SECOND  = GstClockTime(1000000000);
  GST_MSECOND = GstClockTime(1000000);
  GST_USECOND = GstClockTime(1000);
  GST_NSECOND = GstClockTime(1);

  GST_STATE_VOID_PENDING = GstState(0);
  GST_STATE_NULL         = GstState(1);
  GST_STATE_READY        = GstState(2);
  GST_STATE_PAUSED       = GstState(3);
  GST_STATE_PLAYING      = GstState(4);

  GST_STATE_CHANGE_FAILURE    = GstStateChangeReturn(0);
  GST_STATE_CHANGE_SUCCESS    = GstStateChangeReturn(1);
  GST_STATE_CHANGE_ASYNC      = GstStateChangeReturn(2);
  GST_STATE_CHANGE_NO_PREROLL = GstStateChangeReturn(3);

  GST_STATE_CHANGE_NULL_TO_READY      = GstStateChange((1 shl 3) or 2);
  GST_STATE_CHANGE_READY_TO_PAUSED    = GstStateChange((2 shl 3) or 3);
  GST_STATE_CHANGE_PAUSED_TO_PLAYING  = GstStateChange((3 shl 3) or 4);
  GST_STATE_CHANGE_PLAYING_TO_PAUSED  = GstStateChange((4 shl 3) or 3);
  GST_STATE_CHANGE_PAUSED_TO_READY    = GstStateChange((3 shl 3) or 2);
  GST_STATE_CHANGE_READY_TO_NULL      = GstStateChange((2 shl 3) or 1);
  GST_STATE_CHANGE_NULL_TO_NULL       = GstStateChange((1 shl 3) or 1);
  GST_STATE_CHANGE_READY_TO_READY     = GstStateChange((2 shl 3) or 2);
  GST_STATE_CHANGE_PAUSED_TO_PAUSED   = GstStateChange((3 shl 3) or 3);
  GST_STATE_CHANGE_PLAYING_TO_PLAYING = GstStateChange((4 shl 3) or 4);

  GST_MESSAGE_UNKNOWN              = GstMessageType(0);
  GST_MESSAGE_EOS                  = GstMessageType(1 shl 0);
  GST_MESSAGE_ERROR                = GstMessageType(1 shl 1);
  GST_MESSAGE_WARNING              = GstMessageType(1 shl 2);
  GST_MESSAGE_INFO                 = GstMessageType(1 shl 3);
  GST_MESSAGE_TAG                  = GstMessageType(1 shl 4);
  GST_MESSAGE_BUFFERING            = GstMessageType(1 shl 5);
  GST_MESSAGE_STATE_CHANGED        = GstMessageType(1 shl 6);
  GST_MESSAGE_STATE_DIRTY          = GstMessageType(1 shl 7);
  GST_MESSAGE_STEP_DONE            = GstMessageType(1 shl 8);
  GST_MESSAGE_CLOCK_PROVIDE        = GstMessageType(1 shl 9);
  GST_MESSAGE_CLOCK_LOST           = GstMessageType(1 shl 10);
  GST_MESSAGE_NEW_CLOCK            = GstMessageType(1 shl 11);
  GST_MESSAGE_STRUCTURE_CHANGE     = GstMessageType(1 shl 12);
  GST_MESSAGE_STREAM_STATUS        = GstMessageType(1 shl 13);
  GST_MESSAGE_APPLICATION          = GstMessageType(1 shl 14);
  GST_MESSAGE_ELEMENT              = GstMessageType(1 shl 15);
  GST_MESSAGE_SEGMENT_START        = GstMessageType(1 shl 16);
  GST_MESSAGE_SEGMENT_DONE         = GstMessageType(1 shl 17);
  GST_MESSAGE_DURATION_CHANGED     = GstMessageType(1 shl 18);
  GST_MESSAGE_LATENCY              = GstMessageType(1 shl 19);
  GST_MESSAGE_ASYNC_START          = GstMessageType(1 shl 20);
  GST_MESSAGE_ASYNC_DONE           = GstMessageType(1 shl 21);
  GST_MESSAGE_REQUEST_STATE        = GstMessageType(1 shl 22);
  GST_MESSAGE_STEP_START           = GstMessageType(1 shl 23);
  GST_MESSAGE_QOS                  = GstMessageType(1 shl 24);
  GST_MESSAGE_PROGRESS             = GstMessageType(1 shl 25);
  GST_MESSAGE_TOC                  = GstMessageType(1 shl 26);
  GST_MESSAGE_RESET_TIME           = GstMessageType(1 shl 27);
  GST_MESSAGE_STREAM_START         = GstMessageType(1 shl 28);
  GST_MESSAGE_NEED_CONTEXT         = GstMessageType(1 shl 29);
  GST_MESSAGE_HAVE_CONTEXT         = GstMessageType(1 shl 30);
  GST_MESSAGE_EXTENDED             = GstMessageType(guint($80000000));
  GST_MESSAGE_DEVICE_ADDED         = GstMessageType(guint($80000000) or (1 shl 0));
  GST_MESSAGE_DEVICE_REMOVED       = GstMessageType(guint($80000000) or (1 shl 1));
  GST_MESSAGE_PROPERTY_NOTIFY      = GstMessageType(guint($80000000) or (1 shl 2));
  GST_MESSAGE_STREAM_COLLECTION    = GstMessageType(guint($80000000) or (1 shl 3));
  GST_MESSAGE_STREAMS_SELECTED     = GstMessageType(guint($80000000) or (1 shl 4));
  GST_MESSAGE_REDIRECT             = GstMessageType(guint($80000000) or (1 shl 5));
  GST_MESSAGE_DEVICE_CHANGED       = GstMessageType(guint($80000000) or (1 shl 6));
  GST_MESSAGE_INSTANT_RATE_REQUEST = GstMessageType(guint($80000000) or (1 shl 7));
  GST_MESSAGE_ANY                  = GstMessageType(guint(not 0));

  GST_PAD_UNKNOWN = GstPadDirection(0);
  GST_PAD_SRC     = GstPadDirection(1);
  GST_PAD_SINK    = GstPadDirection(2);

  GST_PAD_MODE_NONE = GstPadMode(0);
  GST_PAD_MODE_PUSH = GstPadMode(1);
  GST_PAD_MODE_PULL = GstPadMode(2);

  GST_PAD_LINK_OK              = GstPadLinkReturn(0);
  GST_PAD_LINK_WRONG_HIERARCHY = GstPadLinkReturn(-1);
  GST_PAD_LINK_WAS_LINKED      = GstPadLinkReturn(-2);
  GST_PAD_LINK_WRONG_DIRECTION = GstPadLinkReturn(-3);
  GST_PAD_LINK_NOFORMAT        = GstPadLinkReturn(-4);
  GST_PAD_LINK_NOSCHED         = GstPadLinkReturn(-5);
  GST_PAD_LINK_REFUSED         = GstPadLinkReturn(-6);

  GST_FLOW_CUSTOM_SUCCESS_2 = GstFlowReturn(102);
  GST_FLOW_CUSTOM_SUCCESS_1 = GstFlowReturn(101);
  GST_FLOW_CUSTOM_SUCCESS   = GstFlowReturn(100);
  GST_FLOW_OK               = GstFlowReturn(0);
  GST_FLOW_NOT_LINKED       = GstFlowReturn(-1);
  GST_FLOW_FLUSHING         = GstFlowReturn(-2);
  GST_FLOW_EOS              = GstFlowReturn(-3);
  GST_FLOW_NOT_NEGOTIATED   = GstFlowReturn(-4);
  GST_FLOW_ERROR            = GstFlowReturn(-5);
  GST_FLOW_NOT_SUPPORTED    = GstFlowReturn(-6);
  GST_FLOW_CUSTOM_ERROR     = GstFlowReturn(-100);
  GST_FLOW_CUSTOM_ERROR_1   = GstFlowReturn(-101);
  GST_FLOW_CUSTOM_ERROR_2   = GstFlowReturn(-102);

  GST_FORMAT_UNDEFINED = GstFormat(0);
  GST_FORMAT_DEFAULT   = GstFormat(1);
  GST_FORMAT_BYTES     = GstFormat(2);
  GST_FORMAT_TIME      = GstFormat(3);
  GST_FORMAT_BUFFERS   = GstFormat(4);
  GST_FORMAT_PERCENT   = GstFormat(5);

  GST_SEEK_FLAG_NONE           = GstSeekFlags(0);
  GST_SEEK_FLAG_FLUSH          = GstSeekFlags(1 shl 0);
  GST_SEEK_FLAG_ACCURATE       = GstSeekFlags(1 shl 1);
  GST_SEEK_FLAG_KEY_UNIT       = GstSeekFlags(1 shl 2);
  GST_SEEK_FLAG_SEGMENT        = GstSeekFlags(1 shl 3);
  GST_SEEK_FLAG_SKIP           = GstSeekFlags(1 shl 4);
  GST_SEEK_FLAG_SNAP_BEFORE    = GstSeekFlags(1 shl 5);
  GST_SEEK_FLAG_SNAP_AFTER     = GstSeekFlags(1 shl 6);
  GST_SEEK_FLAG_SNAP_NEAREST   = GstSeekFlags(1 shl 7);
  GST_SEEK_FLAG_TRICKMODE      = GstSeekFlags(1 shl 8);
  GST_SEEK_FLAG_TRICKMODE_KEY_UNITS = GstSeekFlags(1 shl 9);
  GST_SEEK_FLAG_TRICKMODE_NO_AUDIO  = GstSeekFlags(1 shl 10);
  GST_SEEK_FLAG_TRICKMODE_FORWARD_PREDICTED = GstSeekFlags(1 shl 11);
  GST_SEEK_FLAG_INSTANT_RATE_CHANGE = GstSeekFlags(1 shl 12);

  GST_SEEK_TYPE_NONE = GstSeekType(0);
  GST_SEEK_TYPE_SET  = GstSeekType(1);
  GST_SEEK_TYPE_END  = GstSeekType(2);

  GST_PAD_ALWAYS    = GstPadPresence(0);
  GST_PAD_SOMETIMES = GstPadPresence(1);
  GST_PAD_REQUEST   = GstPadPresence(2);

  GST_BUFFER_COPY_NONE       = GstBufferCopyFlags(0);
  GST_BUFFER_COPY_FLAGS      = GstBufferCopyFlags(1 shl 0);
  GST_BUFFER_COPY_TIMESTAMPS = GstBufferCopyFlags(1 shl 1);
  GST_BUFFER_COPY_META       = GstBufferCopyFlags(1 shl 2);
  GST_BUFFER_COPY_MEMORY     = GstBufferCopyFlags(1 shl 3);
  GST_BUFFER_COPY_MERGE      = GstBufferCopyFlags(1 shl 4);
  GST_BUFFER_COPY_DEEP       = GstBufferCopyFlags(1 shl 5);
  GST_BUFFER_COPY_METADATA   = GstBufferCopyFlags((1 shl 0) or (1 shl 1) or (1 shl 2));
  GST_BUFFER_COPY_ALL        = GstBufferCopyFlags(((1 shl 0) or (1 shl 1) or (1 shl 2)) or (1 shl 3));

  GST_LOCK_FLAG_READ      = 1 shl 0;
  GST_LOCK_FLAG_WRITE     = 1 shl 1;
  GST_LOCK_FLAG_EXCLUSIVE = 1 shl 2;

  GST_MINI_OBJECT_FLAG_LOCK_READONLY = GstMiniObjectFlags(1 shl 0);
  GST_MINI_OBJECT_FLAG_LAST          = GstMiniObjectFlags(1 shl 4);

  GST_MEMORY_FLAG_READONLY              = 1 shl 0;
  GST_MEMORY_FLAG_NO_SHARE              = 1 shl 4;
  GST_MEMORY_FLAG_ZERO_PREFIXED         = 1 shl 5;
  GST_MEMORY_FLAG_ZERO_PADDED           = 1 shl 6;
  GST_MEMORY_FLAG_PHYSICALLY_CONTIGUOUS = 1 shl 7;
  GST_MEMORY_FLAG_NOT_MAPPABLE          = 1 shl 8;
  GST_MEMORY_FLAG_LAST                  = 1 shl 20;

  GST_MAP_READ      = GstMapFlags(1 shl 0);
  GST_MAP_WRITE     = GstMapFlags(1 shl 1);
  GST_MAP_FLAG_LAST = GstMapFlags(1 shl 16);
  GST_MAP_READWRITE = GstMapFlags((1 shl 0) or (1 shl 1));

  GST_OBJECT_FLAG_MAY_BE_LEAKED = GstObjectFlags(1 shl 0);
  GST_OBJECT_FLAG_CONSTRUCTED   = GstObjectFlags(1 shl 1);
  GST_OBJECT_FLAG_LAST          = GstObjectFlags(1 shl 4);

  GST_ELEMENT_FLAG_LOCKED_STATE  = GstElementFlags(1 shl 4);
  GST_ELEMENT_FLAG_SINK          = GstElementFlags(1 shl 5);
  GST_ELEMENT_FLAG_SOURCE        = GstElementFlags(1 shl 6);
  GST_ELEMENT_FLAG_PROVIDE_CLOCK = GstElementFlags(1 shl 7);
  GST_ELEMENT_FLAG_REQUIRE_CLOCK = GstElementFlags(1 shl 8);
  GST_ELEMENT_FLAG_INDEXABLE     = GstElementFlags(1 shl 9);
  GST_ELEMENT_FLAG_LAST          = GstElementFlags(1 shl 14);

  GST_PAD_FLAG_BLOCKED          = GstPadFlags(1 shl 0);
  GST_PAD_FLAG_FLUSHING         = GstPadFlags(1 shl 1);
  GST_PAD_FLAG_EOS              = GstPadFlags(1 shl 2);
  GST_PAD_FLAG_BLOCKING         = GstPadFlags(1 shl 3);
  GST_PAD_FLAG_NEED_PARENT      = GstPadFlags(1 shl 4);
  GST_PAD_FLAG_NEED_RECONFIGURE = GstPadFlags(1 shl 5);
  GST_PAD_FLAG_PENDING_EVENTS   = GstPadFlags(1 shl 6);
  GST_PAD_FLAG_FIXED_CAPS       = GstPadFlags(1 shl 7);
  GST_PAD_FLAG_PROXY_CAPS       = GstPadFlags(1 shl 8);
  GST_PAD_FLAG_PROXY_ALLOCATION = GstPadFlags(1 shl 9);
  GST_PAD_FLAG_PROXY_SCHEDULING = GstPadFlags(1 shl 10);
  GST_PAD_FLAG_ACCEPT_INTERSECT = GstPadFlags(1 shl 11);
  GST_PAD_FLAG_ACCEPT_TEMPLATE  = GstPadFlags(1 shl 12);
  GST_PAD_FLAG_LAST             = GstPadFlags(1 shl 16);

  GST_AUDIO_FORMAT_UNKNOWN  = GstAudioFormat(0);
  GST_AUDIO_FORMAT_ENCODED  = GstAudioFormat(1);
  GST_AUDIO_FORMAT_S8       = GstAudioFormat(2);
  GST_AUDIO_FORMAT_U8       = GstAudioFormat(3);
  GST_AUDIO_FORMAT_S16LE    = GstAudioFormat(4);
  GST_AUDIO_FORMAT_S16BE    = GstAudioFormat(5);
  GST_AUDIO_FORMAT_U16LE    = GstAudioFormat(6);
  GST_AUDIO_FORMAT_U16BE    = GstAudioFormat(7);
  GST_AUDIO_FORMAT_S24_32LE = GstAudioFormat(8);
  GST_AUDIO_FORMAT_S24_32BE = GstAudioFormat(9);
  GST_AUDIO_FORMAT_U24_32LE = GstAudioFormat(10);
  GST_AUDIO_FORMAT_U24_32BE = GstAudioFormat(11);
  GST_AUDIO_FORMAT_S32LE    = GstAudioFormat(12);
  GST_AUDIO_FORMAT_S32BE    = GstAudioFormat(13);
  GST_AUDIO_FORMAT_U32LE    = GstAudioFormat(14);
  GST_AUDIO_FORMAT_U32BE    = GstAudioFormat(15);
  GST_AUDIO_FORMAT_S24LE    = GstAudioFormat(16);
  GST_AUDIO_FORMAT_S24BE    = GstAudioFormat(17);
  GST_AUDIO_FORMAT_U24LE    = GstAudioFormat(18);
  GST_AUDIO_FORMAT_U24BE    = GstAudioFormat(19);
  GST_AUDIO_FORMAT_S20LE    = GstAudioFormat(20);
  GST_AUDIO_FORMAT_S20BE    = GstAudioFormat(21);
  GST_AUDIO_FORMAT_U20LE    = GstAudioFormat(22);
  GST_AUDIO_FORMAT_U20BE    = GstAudioFormat(23);
  GST_AUDIO_FORMAT_S18LE    = GstAudioFormat(24);
  GST_AUDIO_FORMAT_S18BE    = GstAudioFormat(25);
  GST_AUDIO_FORMAT_U18LE    = GstAudioFormat(26);
  GST_AUDIO_FORMAT_U18BE    = GstAudioFormat(27);
  GST_AUDIO_FORMAT_F32LE    = GstAudioFormat(28);
  GST_AUDIO_FORMAT_F32BE    = GstAudioFormat(29);
  GST_AUDIO_FORMAT_F64LE    = GstAudioFormat(30);
  GST_AUDIO_FORMAT_F64BE    = GstAudioFormat(31);

  GST_AUDIO_CHANNEL_POSITION_NONE                = GstAudioChannelPosition(-3);
  GST_AUDIO_CHANNEL_POSITION_MONO                = GstAudioChannelPosition(-2);
  GST_AUDIO_CHANNEL_POSITION_INVALID             = GstAudioChannelPosition(-1);
  GST_AUDIO_CHANNEL_POSITION_FRONT_LEFT          = GstAudioChannelPosition(0);
  GST_AUDIO_CHANNEL_POSITION_FRONT_RIGHT         = GstAudioChannelPosition(1);
  GST_AUDIO_CHANNEL_POSITION_FRONT_CENTER        = GstAudioChannelPosition(2);
  GST_AUDIO_CHANNEL_POSITION_LFE1                = GstAudioChannelPosition(3);
  GST_AUDIO_CHANNEL_POSITION_REAR_LEFT           = GstAudioChannelPosition(4);
  GST_AUDIO_CHANNEL_POSITION_REAR_RIGHT          = GstAudioChannelPosition(5);
  GST_AUDIO_CHANNEL_POSITION_FRONT_LEFT_OF_CENTER  = GstAudioChannelPosition(6);
  GST_AUDIO_CHANNEL_POSITION_FRONT_RIGHT_OF_CENTER = GstAudioChannelPosition(7);
  GST_AUDIO_CHANNEL_POSITION_REAR_CENTER         = GstAudioChannelPosition(8);
  GST_AUDIO_CHANNEL_POSITION_LFE2                = GstAudioChannelPosition(9);
  GST_AUDIO_CHANNEL_POSITION_SIDE_LEFT           = GstAudioChannelPosition(10);
  GST_AUDIO_CHANNEL_POSITION_SIDE_RIGHT          = GstAudioChannelPosition(11);
  GST_AUDIO_CHANNEL_POSITION_TOP_FRONT_LEFT      = GstAudioChannelPosition(12);
  GST_AUDIO_CHANNEL_POSITION_TOP_FRONT_RIGHT     = GstAudioChannelPosition(13);
  GST_AUDIO_CHANNEL_POSITION_TOP_FRONT_CENTER    = GstAudioChannelPosition(14);
  GST_AUDIO_CHANNEL_POSITION_TOP_CENTER          = GstAudioChannelPosition(15);
  GST_AUDIO_CHANNEL_POSITION_TOP_REAR_LEFT       = GstAudioChannelPosition(16);
  GST_AUDIO_CHANNEL_POSITION_TOP_REAR_RIGHT      = GstAudioChannelPosition(17);
  GST_AUDIO_CHANNEL_POSITION_TOP_SIDE_LEFT       = GstAudioChannelPosition(18);
  GST_AUDIO_CHANNEL_POSITION_TOP_SIDE_RIGHT      = GstAudioChannelPosition(19);
  GST_AUDIO_CHANNEL_POSITION_TOP_REAR_CENTER     = GstAudioChannelPosition(20);
  GST_AUDIO_CHANNEL_POSITION_BOTTOM_FRONT_CENTER = GstAudioChannelPosition(21);
  GST_AUDIO_CHANNEL_POSITION_BOTTOM_FRONT_LEFT   = GstAudioChannelPosition(22);
  GST_AUDIO_CHANNEL_POSITION_BOTTOM_FRONT_RIGHT  = GstAudioChannelPosition(23);
  GST_AUDIO_CHANNEL_POSITION_WIDE_LEFT           = GstAudioChannelPosition(24);
  GST_AUDIO_CHANNEL_POSITION_WIDE_RIGHT          = GstAudioChannelPosition(25);
  GST_AUDIO_CHANNEL_POSITION_SURROUND_LEFT       = GstAudioChannelPosition(26);
  GST_AUDIO_CHANNEL_POSITION_SURROUND_RIGHT      = GstAudioChannelPosition(27);

  GST_AUDIO_FORMAT_FLAG_INTEGER = GstAudioFormatFlags(1 shl 0);
  GST_AUDIO_FORMAT_FLAG_FLOAT   = GstAudioFormatFlags(1 shl 1);
  GST_AUDIO_FORMAT_FLAG_SIGNED  = GstAudioFormatFlags(1 shl 2);
  GST_AUDIO_FORMAT_FLAG_COMPLEX = GstAudioFormatFlags(1 shl 4);
  GST_AUDIO_FORMAT_FLAG_UNPACK  = GstAudioFormatFlags(1 shl 5);

  GST_AUDIO_PACK_FLAG_NONE           = GstAudioPackFlags(0);
  GST_AUDIO_PACK_FLAG_TRUNCATE_RANGE = GstAudioPackFlags(1 shl 0);

  GST_AUDIO_FLAG_NONE         = GstAudioFlags(0);
  GST_AUDIO_FLAG_UNPOSITIONED = GstAudioFlags(1 shl 0);

  GST_AUDIO_LAYOUT_INTERLEAVED     = GstAudioLayout(0);
  GST_AUDIO_LAYOUT_NON_INTERLEAVED = GstAudioLayout(1);

type
{==============================================================================
  Opaque types
==============================================================================}

  PGstAllocator = Pointer;
  PPGstAllocator = ^PGstAllocator;

  PGstBufferPool = Pointer;
  PPGstBufferPool = ^PGstBufferPool;

  PGstBus = Pointer;
  PPGstBus = ^PGstBus;

  { Opaque types for capabilities }
  GstCaps = record end;
  PGstCaps = ^GstCaps;
  PPGstCaps = ^PGstCaps;

  PGstClock = Pointer;
  PPGstClock = ^PGstClock;

  PGstContext = Pointer;
  PPGstContext = ^PGstContext;

  PGstElementFactory = Pointer;
  PPGstElementFactory = ^PGstElementFactory;

  PGstEvent = Pointer;
  PPGstEvent = ^PGstEvent;

  PGstMeta = Pointer;
  PPGstMeta = ^PGstMeta;

  { Opaque types for pad template }
  GstPadTemplate = record end;
  PGstPadTemplate = ^GstPadTemplate;
  PPGstPadTemplate = ^PGstPadTemplate;

  PGstPlugin = Pointer;
  PPGstPlugin = ^PGstPlugin;

  PGstQuery = Pointer;
  PPGstQuery = ^PGstQuery;

  PGstSample = Pointer;
  PPGstSample = ^PGstSample;

  { Opaque types for structure }
  GstStructure = record end;
  PGstStructure = ^GstStructure;
  PPGstStructure = ^PGstStructure;


  PGstTagList = Pointer;
  PPGstTagList = ^PGstTagList;

  PGstTask = Pointer;
  PPGstTask = ^PGstTask;

  PGstIterator = Pointer;
  PPGstIterator = ^PGstIterator;

{==============================================================================
  Forward pointer declarations needed before callbacks
==============================================================================}

  PGstMiniObject = ^GstMiniObject;
  PPGstMiniObject = ^PGstMiniObject;

  PGstObject = ^GstObject;
  PPGstObject = ^PGstObject;

  PGstObjectClass = ^GstObjectClass;
  PPGstObjectClass = ^PGstObjectClass;

  PGstMessage = ^GstMessage;
  PPGstMessage = ^PGstMessage;

  PGstMemory = ^GstMemory;
  PPGstMemory = ^PGstMemory;

  PGstBuffer = ^GstBuffer;
  PPGstBuffer = ^PGstBuffer;

  PGstMapInfo = ^GstMapInfo;
  PPGstMapInfo = ^PGstMapInfo;

  PGstElement = ^GstElement;
  PPGstElement = ^PGstElement;

  PGstElementClass = ^GstElementClass;
  PPGstElementClass = ^PGstElementClass;

  PGstBin = ^GstBin;
  PPGstBin = ^PGstBin;

  PGstBinClass = ^GstBinClass;
  PPGstBinClass = ^PGstBinClass;

  PGstPipeline = ^GstPipeline;
  PPGstPipeline = ^PGstPipeline;

  PGstPipelineClass = ^GstPipelineClass;
  PPGstPipelineClass = ^PGstPipelineClass;

  PGstPad = ^GstPad;
  PPGstPad = ^PGstPad;

  PGstPadClass = ^GstPadClass;
  PPGstPadClass = ^PGstPadClass;

  PGstStaticCaps = ^GstStaticCaps;
  PPGstStaticCaps = ^PGstStaticCaps;

  PGstStaticPadTemplate = ^GstStaticPadTemplate;
  PPGstStaticPadTemplate = ^PGstStaticPadTemplate;

  PGstAudioFormatInfo = ^GstAudioFormatInfo;
  PPGstAudioFormatInfo = ^PGstAudioFormatInfo;

  PGstAudioInfo = ^GstAudioInfo;
  PPGstAudioInfo = ^PGstAudioInfo;

  PGstVideoFormatInfo = ^GstVideoFormatInfo;
  PPGstVideoFormatInfo = ^PGstVideoFormatInfo;

  PGstVideoInfo = ^GstVideoInfo;
  PPGstVideoInfo = ^PGstVideoInfo;

  PGstVideoFrame = ^GstVideoFrame;
  PPGstVideoFrame = ^PGstVideoFrame;

    GstVideoFormatInfo = record
    format: GstVideoFormat;
    name: Pgchar;
    description: Pgchar;
    flags: guint;
    bits: guint;
    n_components: guint;
    shift: array[0..3] of guint;
    depth: array[0..3] of guint;
    pixel_stride: array[0..3] of gint;
    n_planes: guint;
    plane: array[0..3] of guint;
    poffset: array[0..3] of guint;
    w_sub: array[0..3] of guint;
    h_sub: array[0..3] of guint;
    unpack_format: GstVideoFormat;
    unpack_func: gpointer;
    pack_lines: gint;
    pack_func: gpointer;
    tile_mode: gint;
    tile_ws: guint;
    tile_hs: guint;
    _gst_reserved: array[0..GST_PADDING_LARGE - 1] of gpointer;
  end;

  GstVideoInfo = record
    finfo: PGstVideoFormatInfo;
    interlace_mode: gint;
    flags: guint;
    width: gint;
    height: gint;
    size: gsize;
    views: gint;
    chroma_site: gint;
    colorimetry: array[0..3] of gint;
    par_n: gint;
    par_d: gint;
    fps_n: gint;
    fps_d: gint;
    offset: array[0..3] of gsize;
    stride: array[0..3] of gint;
    _gst_reserved: array[0..GST_PADDING_LARGE - 1] of gpointer;
  end;

  { GST_VIDEO_MAX_PLANES = 4 }

  GstMapInfo = record
    memory: PGstMemory;
    flags: GstMapFlags;
    data: Pguint8;
    size: gsize;
    maxsize: gsize;
    user_data: array[0..3] of gpointer;
    _gst_reserved: array[0..GST_PADDING - 1] of gpointer;
  end;

  GstVideoFrame = record
    info: GstVideoInfo;
    flags: GstVideoFrameFlags;
    buffer: PGstBuffer;
    meta: gpointer;
    id: gint;
    data: array[0..3] of gpointer;
    map: array[0..3] of GstMapInfo;
    _gst_reserved: array[0..GST_PADDING_LARGE - 1] of gpointer;
  end;
{==============================================================================
  Callback types
==============================================================================}

  GstMiniObjectCopyFunction = function(D_object: PGstMiniObject): PGstMiniObject; cdecl;
  GstMiniObjectDisposeFunction = function(D_object: PGstMiniObject): gboolean; cdecl;
  GstMiniObjectFreeFunction = procedure(D_object: PGstMiniObject); cdecl;
  GstMiniObjectNotify = procedure(data: gpointer; D_object: PGstMiniObject); cdecl;

  GstObjectDeepNotifyFunc = procedure(D_object, orig: PGstObject; pspec: PGParamSpec); cdecl;

  GstElementPadSignalProc = procedure(element: PGstElement; pad: PGstPad); cdecl;
  GstElementNoMorePadsProc = procedure(element: PGstElement); cdecl;

  GstElementRequestNewPadFunc = function(
    element: PGstElement;
    templ: PGstPadTemplate;
    name: Pgchar;
    caps: PGstCaps
  ): PGstPad; cdecl;

  GstElementReleasePadProc = procedure(
    element: PGstElement;
    pad: PGstPad
  ); cdecl;

  GstElementGetStateFunc = function(
    element: PGstElement;
    state: PGstState;
    pending: PGstState;
    timeout: GstClockTime
  ): GstStateChangeReturn; cdecl;

  GstElementSetStateFunc = function(
    element: PGstElement;
    state: GstState
  ): GstStateChangeReturn; cdecl;

  GstElementChangeStateFunc = function(
    element: PGstElement;
    transition: GstStateChange
  ): GstStateChangeReturn; cdecl;

  GstElementStateChangedProc = procedure(
    element: PGstElement;
    oldstate: GstState;
    newstate: GstState;
    pending: GstState
  ); cdecl;

  GstElementSetBusProc = procedure(
    element: PGstElement;
    bus: PGstBus
  ); cdecl;

  GstElementProvideClockFunc = function(
    element: PGstElement
  ): PGstClock; cdecl;

  GstElementSetClockFunc = function(
    element: PGstElement;
    clock: PGstClock
  ): gboolean; cdecl;

  GstElementSendEventFunc = function(
    element: PGstElement;
    event: PGstEvent
  ): gboolean; cdecl;

  GstElementQueryFunc = function(
    element: PGstElement;
    query: PGstQuery
  ): gboolean; cdecl;

  GstElementPostMessageFunc = function(
    element: PGstElement;
    message: PGstMessage
  ): gboolean; cdecl;

  GstElementSetContextProc = procedure(
    element: PGstElement;
    context: PGstContext
  ); cdecl;

  GstPadActivateFunction = Pointer;
  GstPadActivateModeFunction = Pointer;
  GstPadLinkFunction = Pointer;
  GstPadUnlinkFunction = Pointer;
  GstPadChainFunction = Pointer;
  GstPadChainListFunction = Pointer;
  GstPadGetRangeFunction = Pointer;
  GstPadEventFunction = Pointer;
  GstPadEventFullFunction = Pointer;
  GstPadQueryFunction = Pointer;
  GstPadIterIntLinkFunction = Pointer;

  GstPadLinkedProc = procedure(pad, peer: PGstPad); cdecl;

  GstBinElementAddedProc = procedure(bin: PGstBin; element: PGstElement); cdecl;
  GstBinElementRemovedProc = procedure(bin: PGstBin; element: PGstElement); cdecl;
  GstBinDeepElementAddedProc = procedure(bin: PGstBin; sub_bin: PGstBin; element: PGstElement); cdecl;
  GstBinDeepElementRemovedProc = procedure(bin: PGstBin; sub_bin: PGstBin; element: PGstElement); cdecl;

  GstAudioFormatUnpack = procedure(
    const info: PGstAudioFormatInfo;
    flags: GstAudioPackFlags;
    dest: gpointer;
    data: gpointer;
    length: gint
  ); cdecl;

  GstAudioFormatPack = procedure(
    const info: PGstAudioFormatInfo;
    flags: GstAudioPackFlags;
    src: gpointer;
    data: gpointer;
    length: gint
  ); cdecl;

{==============================================================================
  Public structs
==============================================================================}

  GstMiniObject = record
    D_type: GType;
    refcount: gint;
    lockstate: gint;
    flags: guint;
    copy: GstMiniObjectCopyFunction;
    dispose: GstMiniObjectDisposeFunction;
    free: GstMiniObjectFreeFunction;
    n_qdata: guint;
    qdata: gpointer;
  end;

  GstObject = record
    D_object: GInitiallyUnowned;
    lock: GMutex;
    name: Pgchar;
    parent: PGstObject;
    flags: guint32;
    control_bindings: PGList;
    control_rate: guint64;
    last_sync: guint64;
    _gst_reserved: gpointer;
  end;

  GstObjectClass = record
    parent_class: GInitiallyUnownedClass;
    path_string_separator: Pgchar;
    deep_notify: GstObjectDeepNotifyFunc;
    _gst_reserved: array[0..GST_PADDING - 1] of gpointer;
  end;

  GstMessage = record
    mini_object: GstMiniObject;
    D_type: GstMessageType;
    timestamp: guint64;
    src: PGstObject;
    seqnum: guint32;
    lock: GMutex;
    cond: GCond;
  end;

  GstMemory = record
    mini_object: GstMiniObject;
    allocator: PGstAllocator;
    parent: PGstMemory;
    maxsize: gsize;
    align: gsize;
    offset: gsize;
    size: gsize;
  end;


  GstBuffer = record
    mini_object: GstMiniObject;
    pool: PGstBufferPool;
    pts: GstClockTime;
    dts: GstClockTime;
    duration: GstClockTime;
    offset: guint64;
    offset_end: guint64;
  end;

{==============================================================================
  Tutorial 6 - Caps and Structure types
==============================================================================}

  { Callback type for structure iteration }
  GstStructureForeachFunc = function(
    field_id: GQuark;
    value: PGValue;
    user_data: gpointer
  ): gboolean; cdecl;

  GstStaticCaps = record
    string_: Pgchar;
  end;

  GstStaticPadTemplate = record
    name_template: Pgchar;
    direction: GstPadDirection;
    presence: GstPadPresence;
    static_caps: GstStaticCaps;
  end;

  GstAudioFormatInfo = record
    format: GstAudioFormat;
    name: Pgchar;
    description: Pgchar;
    flags: GstAudioFormatFlags;
    endianness: gint;
    width: gint;
    depth: gint;
    silence: array[0..7] of gint8;
    unpack_format: GstAudioFormat;
    unpack_func: GstAudioFormatUnpack;
    pack_func: GstAudioFormatPack;
    _gst_reserved: array[0..GST_PADDING - 1] of gpointer;
  end;

  GstAudioInfo = record
    finfo: PGstAudioFormatInfo;
    flags: GstAudioFlags;
    layout: GstAudioLayout;
    rate: gint;
    channels: gint;
    bpf: gint;
    position: array[0..63] of GstAudioChannelPosition;
    _gst_reserved: array[0..GST_PADDING - 1] of gpointer;
  end;

  GstElement = record
    D_object: GstObject;
    state_lock: GRecMutex;
    state_cond: GCond;
    state_cookie: guint32;
    target_state: GstState;
    current_state: GstState;
    next_state: GstState;
    pending_state: GstState;
    last_return: GstStateChangeReturn;
    bus: PGstBus;
    clock: PGstClock;
    base_time: GstClockTimeDiff;
    start_time: GstClockTime;
    numpads: guint16;
    pads: PGList;
    numsrcpads: guint16;
    srcpads: PGList;
    numsinkpads: guint16;
    sinkpads: PGList;
    pads_cookie: guint32;
    contexts: PGList;
    _gst_reserved: array[0..GST_PADDING - 2] of gpointer;
  end;

  GstElementClass = record
    parent_class: GstObjectClass;
    metadata: gpointer;
    elementfactory: PGstElementFactory;
    padtemplates: PGList;
    numpadtemplates: gint;
    pad_templ_cookie: guint32;

    pad_added: GstElementPadSignalProc;
    pad_removed: GstElementPadSignalProc;
    no_more_pads: GstElementNoMorePadsProc;

    request_new_pad: GstElementRequestNewPadFunc;
    release_pad: GstElementReleasePadProc;

    get_state: GstElementGetStateFunc;
    set_state: GstElementSetStateFunc;
    change_state: GstElementChangeStateFunc;
    state_changed: GstElementStateChangedProc;

    set_bus: GstElementSetBusProc;

    provide_clock: GstElementProvideClockFunc;
    set_clock: GstElementSetClockFunc;

    send_event: GstElementSendEventFunc;
    query: GstElementQueryFunc;
    post_message: GstElementPostMessageFunc;
    set_context: GstElementSetContextProc;

    _gst_reserved: array[0..GST_PADDING_LARGE - 3] of gpointer;
  end;

  GstBin = record
    element: GstElement;
    _gst_reserved: array[0..GST_PADDING_LARGE - 1] of gpointer;
  end;

  GstBinClass = record
    parent_class: GstElementClass;
    element_added: GstBinElementAddedProc;
    element_removed: GstBinElementRemovedProc;
    deep_element_added: GstBinDeepElementAddedProc;
    deep_element_removed: GstBinDeepElementRemovedProc;
    _gst_reserved: array[0..GST_PADDING - 1] of gpointer;
  end;

  GstPipeline = record
    bin: GstBin;
    _gst_reserved: array[0..GST_PADDING - 1] of gpointer;
  end;

  GstPipelineClass = record
    parent_class: GstBinClass;
    _gst_reserved: array[0..GST_PADDING - 1] of gpointer;
  end;

  GstPad = record
    D_object: GstObject;
    element_private: gpointer;
    padtemplate: PGstPadTemplate;
    direction: GstPadDirection;

    stream_rec_lock: GRecMutex;
    task: PGstTask;

    block_cond: GCond;
    probes: GHookList;

    mode: GstPadMode;
    activatefunc: GstPadActivateFunction;
    activatedata: gpointer;
    activatenotify: GDestroyNotify;
    activatemodefunc: GstPadActivateModeFunction;
    activatemodedata: gpointer;
    activatemodenotify: GDestroyNotify;

    peer: PGstPad;
    linkfunc: GstPadLinkFunction;
    linkdata: gpointer;
    linknotify: GDestroyNotify;
    unlinkfunc: GstPadUnlinkFunction;
    unlinkdata: gpointer;
    unlinknotify: GDestroyNotify;

    chainfunc: GstPadChainFunction;
    chaindata: gpointer;
    chainnotify: GDestroyNotify;
    chainlistfunc: GstPadChainListFunction;
    chainlistdata: gpointer;
    chainlistnotify: GDestroyNotify;
    getrangefunc: GstPadGetRangeFunction;
    getrangedata: gpointer;
    getrangenotify: GDestroyNotify;
    eventfunc: GstPadEventFunction;
    eventdata: gpointer;
    eventnotify: GDestroyNotify;

    offset: gint64;

    queryfunc: GstPadQueryFunction;
    querydata: gpointer;
    querynotify: GDestroyNotify;

    iterintlinkfunc: GstPadIterIntLinkFunction;
    iterintlinkdata: gpointer;
    iterintlinknotify: GDestroyNotify;

    num_probes: gint;
    num_blocked: gint;

    priv: gpointer;

    ABI_reserved: array[0..GST_PADDING - 1] of gpointer;
  end;

  GstPadClass = record
    parent_class: GstObjectClass;
    linked: GstPadLinkedProc;
    unlinked: GstPadLinkedProc;
    _gst_reserved: array[0..GST_PADDING - 1] of gpointer;
  end;


  GstPadProbeType = guint;
  GstPadProbeReturn = gint;

  PGstPadProbeInfo = ^TGstPadProbeInfo;
  TGstPadProbeInfo = record
    D_type: GstPadProbeType;
    D_id: guint64;
    D_data: gpointer;
    D_offset: guint64;
    D_size: guint32;
  end;

const
  GST_PAD_PROBE_TYPE_INVALID          : GstPadProbeType = 0;
  GST_PAD_PROBE_TYPE_IDLE             : GstPadProbeType = 1 shl 0;
  GST_PAD_PROBE_TYPE_BLOCK            : GstPadProbeType = 1 shl 1;
  GST_PAD_PROBE_TYPE_BUFFER           : GstPadProbeType = 1 shl 4;
  GST_PAD_PROBE_TYPE_BUFFER_LIST      : GstPadProbeType = 1 shl 5;
  GST_PAD_PROBE_TYPE_EVENT_DOWNSTREAM : GstPadProbeType = 1 shl 6;
  GST_PAD_PROBE_TYPE_EVENT_UPSTREAM   : GstPadProbeType = 1 shl 7;
  GST_PAD_PROBE_TYPE_EVENT_FLUSH      : GstPadProbeType = 1 shl 8;
  GST_PAD_PROBE_TYPE_QUERY_DOWNSTREAM : GstPadProbeType = 1 shl 9;
  GST_PAD_PROBE_TYPE_QUERY_UPSTREAM   : GstPadProbeType = 1 shl 10;
  GST_PAD_PROBE_TYPE_PUSH             : GstPadProbeType = 1 shl 12;
  GST_PAD_PROBE_TYPE_PULL             : GstPadProbeType = 1 shl 13;

  GST_PAD_PROBE_OK       : GstPadProbeReturn = 0;
  GST_PAD_PROBE_DROP     : GstPadProbeReturn = 1;
  GST_PAD_PROBE_REMOVE   : GstPadProbeReturn = 2;
  GST_PAD_PROBE_PASS     : GstPadProbeReturn = 3;
  GST_PAD_PROBE_HANDLED  : GstPadProbeReturn = 4;

function GstPadLinkReturn2Str(Res :GstPadLinkReturn) :string;

implementation

function GstPadLinkReturn2Str(Res :GstPadLinkReturn) :string;
begin
case Res of
  GST_PAD_LINK_OK              :Result:='GST_PAD_LINK_OK';
  GST_PAD_LINK_WRONG_HIERARCHY :Result:='GST_PAD_LINK_WRONG_HIERARCHY';
  GST_PAD_LINK_WAS_LINKED      :Result:='GST_PAD_LINK_WAS_LINKED';
  GST_PAD_LINK_WRONG_DIRECTION :Result:='GST_PAD_LINK_WRONG_DIRECTION';
  GST_PAD_LINK_NOFORMAT        :Result:='GST_PAD_LINK_NOFORMAT';
  GST_PAD_LINK_NOSCHED         :Result:='GST_PAD_LINK_NOSCHED';
  GST_PAD_LINK_REFUSED         :Result:='GST_PAD_LINK_REFUSED';
  else Result:='GST_PAD_Unknown';
end;
end;

end.

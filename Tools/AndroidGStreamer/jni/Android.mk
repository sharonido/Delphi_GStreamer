LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := g2d_gst_smoke
LOCAL_SRC_FILES := g2d_gst_smoke.c
LOCAL_SHARED_LIBRARIES := gstreamer_android
LOCAL_LDLIBS := -llog

include $(BUILD_SHARED_LIBRARY)

ifndef GSTREAMER_ROOT_ANDROID
$(error GSTREAMER_ROOT_ANDROID is not defined)
endif

ifeq ($(TARGET_ARCH_ABI),arm64-v8a)
GSTREAMER_ROOT := $(GSTREAMER_ROOT_ANDROID)/arm64
else ifeq ($(TARGET_ARCH_ABI),armeabi-v7a)
GSTREAMER_ROOT := $(GSTREAMER_ROOT_ANDROID)/armv7
else ifeq ($(TARGET_ARCH_ABI),x86)
GSTREAMER_ROOT := $(GSTREAMER_ROOT_ANDROID)/x86
else ifeq ($(TARGET_ARCH_ABI),x86_64)
GSTREAMER_ROOT := $(GSTREAMER_ROOT_ANDROID)/x86_64
else
$(error Unsupported TARGET_ARCH_ABI=$(TARGET_ARCH_ABI))
endif

GSTREAMER_NDK_BUILD_PATH := $(GSTREAMER_ROOT)/share/gst-android/ndk-build

include $(GSTREAMER_NDK_BUILD_PATH)/plugins.mk

# Step 5 needs synthetic video, conversion, and an Android-capable GL sink.
GSTREAMER_PLUGINS := $(GSTREAMER_PLUGINS_CORE) $(GSTREAMER_PLUGINS_SYS)
GSTREAMER_EXTRA_DEPS := gstreamer-app-1.0 gstreamer-audio-1.0 gstreamer-video-1.0 gstreamer-gl-1.0
GSTREAMER_INCLUDE_FONTS := no

include $(GSTREAMER_NDK_BUILD_PATH)/gstreamer-1.0.mk

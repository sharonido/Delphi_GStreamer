


//#include <gtk/gtk.h>
#include <gst/gst.h>
#include <gst/video/videooverlay.h>
#include <gst/audio/audio.h>
#include "G2D.h"

GstElement* iTmp1 = NULL;//debuging
GstElement* iTmp2 = NULL;//debuging

void _Gst_init(int argc, char* argv[]) {
    gst_init(&argc, &argv);
}

GstElement* _Gst_element_factory_make(const gchar* factoryname, const gchar* name) {
    return gst_element_factory_make(factoryname, name);
    }


GstElement* _Gst_pipeline_new(const char* name) {
    //g_print("GstMiniObject size= %d ", sizeof(GstMiniObject));
    return gst_pipeline_new(name);
}

GstBus* _Gst_element_get_bus(GstElement *element) {
    return gst_element_get_bus(element);
}

void _Gst_object_unref(gpointer ref) {
    gst_object_unref(ref);
 }

void _Gst_mini_object_unref(GstMiniObject* mini_object) {
    gst_mini_object_unref(mini_object);
}

gboolean _Gst_bin_add(GstBin* bin, GstElement* element) {
    return gst_bin_add(bin, element);
}

gboolean _Gst_element_link(GstElement* src, GstElement* dest) {
    return gst_element_link(src, dest);
}

GstStateChangeReturn _Gst_element_set_state(GstElement* element, GstState state) {
    return gst_element_set_state(element, state);
}
GstMessage* _Gst_bus_timed_pop_filtered(GstBus* bus, GstClockTime timeout, GstMessageType types) {
    return gst_bus_timed_pop_filtered(bus, timeout, types);
}
void _Gst_message_unref(GstMessage* msg) {
    gst_message_unref(msg);
}
void _G_object_set_int(GstElement* element, const gchar* firstparam, const gint64 val) {
    g_object_set(element, firstparam, val, NULL);
}
void _G_object_set_float(GstElement* element, const gchar* firstparam, const float val) {
    g_object_set(element, firstparam, val, NULL);
}
void _G_object_set_pchar(GstElement* element, const gchar* firstparam, const gchar* val) {
    g_object_set(element, firstparam, val, NULL);
}

GstPad* _Gst_element_get_request_pad(GstElement* element, const gchar* name) {
    return gst_element_request_pad_simple(element, name); //gst_element_get_request_pad is depreated
}

GstPad* _Gst_element_get_static_pad(GstElement* element, const gchar* name){
    return gst_element_get_static_pad(element, name);
}

gchar* _Gst_object_get_name(GstObject* object) {
    return gst_object_get_name(object);
}

GstPadLinkReturn _Gst_pad_link(GstPad* srcpad, GstPad* sinkpad) {
    return gst_pad_link(srcpad, sinkpad);
}

void _Gst_element_release_request_pad(GstElement* element, GstPad* pad) {
    gst_element_release_request_pad(element, pad);
}

void _Gst_message_parse_state_changed(GstMessage* message, GstState* oldstate,
    GstState* newstate, GstState* pending) {
    gst_message_parse_state_changed(message, oldstate, newstate, pending);
}

void _Gst_message_parse_error(GstMessage* message, GError** gerror, gchar** debug) {
    gst_message_parse_error(message, gerror, debug);
}

void _G_signal_connect(gpointer instance, const gchar* detailed_signal, GCallback c_handler, gpointer data) {
    g_signal_connect(instance, detailed_signal, c_handler, data);
}

gboolean _Gst_pad_is_linked(GstPad* pad) {
    return gst_pad_is_linked(pad);
}

GstCaps* _Gst_pad_get_current_caps(GstPad* pad) {
    return gst_pad_get_current_caps(pad);
}

GstStructure* _Gst_caps_get_structure(const GstCaps* caps, guint index) {
    return gst_caps_get_structure(caps, index);
}

const gchar* _Gst_structure_get_name(const GstStructure* structure) {
    return gst_structure_get_name(structure);
}

gboolean _Gst_element_query_position(GstElement* element, GstFormat format, gint64* cur) {
    return gst_element_query_position(element, format, cur);
}

gboolean _Gst_element_query_duration(GstElement* element, GstFormat format, gint64* duration) {
    return gst_element_query_duration(element, format, duration);
}

gboolean _Gst_element_seek_simple(GstElement* element, GstFormat format, GstSeekFlags seek_flags, gint64 seek_pos) {
    return gst_element_seek_simple(element, format, seek_flags, seek_pos);
}

GstElementFactory* _Gst_element_factory_find(const gchar* name) {
    return gst_element_factory_find(name);
}

const gchar* _Gst_element_factory_get_metadata(GstElementFactory* factory, const gchar* key) {
    return gst_element_factory_get_metadata(factory, key);
}

const GList* _Gst_element_factory_get_static_pad_templates(GstElementFactory* factory) {
    return gst_element_factory_get_static_pad_templates(factory);
}

guint _Gst_element_factory_get_num_pad_templates(GstElementFactory* factory) {
    return gst_element_factory_get_num_pad_templates(factory);
}

GstCaps* _Gst_pad_query_caps(GstPad* pad, GstCaps* filter) {
    return gst_pad_query_caps(pad, filter);
}

guint _Gst_caps_get_size(const GstCaps* caps) {
    return gst_caps_get_size(caps);
}

gboolean _Gst_caps_is_any(const GstCaps* caps) {
    return gst_caps_is_any(caps);
}

gboolean _Gst_caps_is_empty(const GstCaps* caps) {
    return gst_caps_is_empty(caps);
}
gboolean _Gst_structure_foreach (const GstStructure * structure, GstStructureForeachFunc func, gpointer user_data){
	return gst_structure_foreach(structure, func, user_data);
}
gchar* _Gst_value_serialize (const GValue *value){
	return gst_value_serialize(value);
}
const gchar* _G_quark_to_string (GQuark quark){
	return g_quark_to_string(quark);
}
GstCaps* _Gst_static_caps_get (GstStaticCaps *static_caps){
	return gst_static_caps_get(static_caps);
}
void _Gst_bus_add_signal_watch (GstBus* bus){
	gst_bus_add_signal_watch(bus);
}
void _Gst_video_overlay_set_window_handle(GstElement* plugbin, guintptr handle) {
    gst_video_overlay_set_window_handle(GST_VIDEO_OVERLAY(plugbin), handle);
}
void _G_object_get(const gpointer object, const gpointer pkey, const gpointer pval) {
    g_object_get(object, pkey, pval, NULL);
}

void _G_signal_emit_by_name_int(gpointer instance, const gchar* detailed_signal, gint index, gpointer pval) {
    g_signal_emit_by_name(instance, detailed_signal, index, pval);
}
void _G_signal_emit_by_name_pointer(gpointer instance, const gchar* detailed_signal, gpointer p, gpointer pval) {
    g_signal_emit_by_name(instance, detailed_signal, p, pval);
}
void _G_signal_emit_by_name_pointer1(gpointer instance, const gchar* detailed_signal, gpointer pval) {
    g_signal_emit_by_name(instance, detailed_signal, pval);
}

gboolean _Gst_tag_list_get_string(const GstTagList* list, const gchar* tag, gchar** value) {
    return gst_tag_list_get_string(list, tag, value);
}

gboolean _Gst_tag_list_get_uint(const GstTagList* list, const gchar* tag, guint* value) {
    return gst_tag_list_get_uint(list, tag, value);
}

void _Gst_audio_info_set_format(GstAudioInfo* info, GstAudioFormat format, gint rate, gint channels, const GstAudioChannelPosition* position) {
    gst_audio_info_set_format(info, format, rate, channels, position);
}

GstCaps* _Gst_audio_info_to_caps(const GstAudioInfo* info) {
    return gst_audio_info_to_caps(info);
}

//should not be used in windows GUI
guint _G_idle_add(GSourceFunc  function, gpointer data) {
    return g_idle_add(function, data);
}

GstBuffer* _Gst_buffer_new_and_alloc(int size) {
    return gst_buffer_new_and_alloc(size);
}

gboolean _Gst_buffer_map(GstBuffer* buffer, GstMapInfo* info, GstMapFlags flags) {
    return gst_buffer_map(buffer, info, flags);
}

void _Gst_buffer_unmap(GstBuffer* buffer, GstMapInfo* info) {
    gst_buffer_unmap(buffer, info);
}

void _Gst_sample_unref(GstSample* sample) {
    gst_sample_unref(sample);
}

void _Gst_buffer_unref(GstBuffer* buf) {
    gst_buffer_unref(buf);
}

GstBuffer* _Gst_sample_get_buffer(GstSample* sample) {
    gst_sample_get_buffer(sample);
}

GstEvent* _Gst_event_new_seek(gdouble rate, GstFormat format, GstSeekFlags flags, GstSeekType start_type, gint64 start,
    GstSeekType stop_type, gint64 stop) G_GNUC_MALLOC {
    return gst_event_new_seek(rate, format, flags, start_type, start, stop_type, stop);
}

gboolean _Gst_element_send_event(GstElement* element, GstEvent* event) {
    return gst_element_send_event(element, event);
}
GstElement* _Gst_parse_launch(const gchar* pipeline_description, GError** error) {
    return gst_parse_launch(pipeline_description, error);
}
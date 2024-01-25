

#include <gst/gst.h>
#include "G2D.h"

GstElement* iTmp1 = NULL;//debuging
GstElement* iTmp2 = NULL;//debuging

void Dgst_init(int argc, char* argv[]) {
    gst_init(&argc, &argv);
}

GstElement* Dgst_element_factory_make(const gchar* factoryname, const gchar* name) {
    return gst_element_factory_make(factoryname, name);
    }


GstElement* Dgst_pipeline_new(const char* name) {
    //g_print("GstMiniObject size= %d ", sizeof(GstMiniObject));
    return gst_pipeline_new(name);
}

GstBus* Dgst_element_get_bus(GstElement *element) {
    return gst_element_get_bus(element);
}

void Dgst_object_unref(gpointer ref) {
    gst_object_unref(ref);
 }

void Dgst_mini_object_unref(GstMiniObject* mini_object) {
    gst_mini_object_unref(mini_object);
}

gboolean Dgst_bin_add(GstBin* bin, GstElement* element) {
    return gst_bin_add(bin, element);
}

gboolean Dgst_element_link(GstElement* src, GstElement* dest) {
    return gst_element_link(src, dest);
}

GstStateChangeReturn Dgst_element_set_state(GstElement* element, GstState state) {
    return gst_element_set_state(element, state);
}
GstMessage* Dgst_bus_timed_pop_filtered(GstBus* bus, GstClockTime timeout, GstMessageType types) {
    return gst_bus_timed_pop_filtered(bus, timeout, types);
}
void Dgst_message_unref(GstMessage* msg) {
    gst_message_unref(msg);
}
void Dg_object_set_int(GstElement* element, const gchar* firstparam, const int val) {
    g_object_set(element, firstparam, val, NULL);
}
void Dg_object_set_pchar(GstElement* element, const gchar* firstparam, const gchar* val) {
    g_object_set(element, firstparam, val, NULL);
}

GstPad* Dgst_element_get_request_pad(GstElement* element, const gchar* name) {
    return gst_element_request_pad_simple(element, name); //gst_element_get_request_pad is depreated
}

GstPad* Dgst_element_get_static_pad(GstElement* element, const gchar* name){
    return gst_element_get_static_pad(element, name);
}

gchar* Dgst_object_get_name(GstObject* object) {
    return gst_object_get_name(object);
}

GstPadLinkReturn Dgst_pad_link(GstPad* srcpad, GstPad* sinkpad) {
    return gst_pad_link(srcpad, sinkpad);
}

void Dgst_element_release_request_pad(GstElement* element, GstPad* pad) {
    gst_element_release_request_pad(element, pad);
}

void Dgst_message_parse_state_changed(GstMessage* message, GstState* oldstate,
    GstState* newstate, GstState* pending) {
    gst_message_parse_state_changed(message, oldstate, newstate, pending);
}

void Dg_signal_connect(gpointer instance, const gchar* detailed_signal, GCallback c_handler, gpointer data) {
    g_signal_connect(instance, detailed_signal, c_handler, data);
}

gboolean Dgst_pad_is_linked(GstPad* pad) {
    return gst_pad_is_linked(pad);
}

GstCaps* Dgst_pad_get_current_caps(GstPad* pad) {
    return gst_pad_get_current_caps(pad);
}

GstStructure* Dgst_caps_get_structure(const GstCaps* caps, guint index) {
    return gst_caps_get_structure(caps, index);
}

gchar* Dgst_structure_get_name(const GstStructure* structure) {
    return gst_structure_get_name(structure);
}

gboolean Dgst_element_query_position(GstElement* element, GstFormat format, gint64* cur) {
    return gst_element_query_position(element, format, cur);
}

gboolean Dgst_element_query_duration(GstElement* element, GstFormat format, gint64* duration) {
    return gst_element_query_duration(element, format, duration);
}

gboolean Dgst_element_seek_simple(GstElement* element, GstFormat format, GstSeekFlags seek_flags, gint64 seek_pos) {
    return gst_element_seek_simple(element, format, seek_flags, seek_pos);
}

GstElementFactory* Dgst_element_factory_find(const gchar* name) {
    return gst_element_factory_find(name);
}

const gchar* Dgst_element_factory_get_metadata(GstElementFactory* factory, const gchar* key) {
    return gst_element_factory_get_metadata(factory, key);
}

const GList* Dgst_element_factory_get_static_pad_templates(GstElementFactory* factory) {
    return gst_element_factory_get_static_pad_templates(factory);
}

guint Dgst_element_factory_get_num_pad_templates(GstElementFactory* factory) {
    return gst_element_factory_get_num_pad_templates(factory);
}

GstCaps* Dgst_pad_query_caps(GstPad* pad, GstCaps* filter) {
    return gst_pad_query_caps(pad, filter);
}

guint Dgst_caps_get_size(const GstCaps* caps) {
    return gst_caps_get_size(caps);
}

gboolean Dgst_caps_is_any(const GstCaps* caps) {
    return gst_caps_is_any(caps);
}

gboolean Dgst_caps_is_empty(const GstCaps* caps) {
    return gst_caps_is_empty(caps);
}
gboolean Dgst_structure_foreach (const GstStructure * structure, GstStructureForeachFunc func, gpointer user_data){
	return gst_structure_foreach(structure, func, user_data);
}
gchar* Dgst_value_serialize (const GValue *value){
	return gst_value_serialize(value);
}
const gchar* Dg_quark_to_string (GQuark quark){
	return g_quark_to_string(quark);
}
GstCaps* Dgst_static_caps_get (GstStaticCaps *static_caps){
	return gst_static_caps_get(static_caps);
}
void Dgst_bus_add_signal_watch (GstBus* bus){
	gst_bus_add_signal_watch(bus);
}
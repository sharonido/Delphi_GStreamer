

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
void Dg_object_set_pchar(GstElement* element, const gchar* firstparam, const gchar *val) {
    g_object_set(element, firstparam, val, NULL);
}




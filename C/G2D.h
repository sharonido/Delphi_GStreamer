#pragma once
// Define we are exporting functions from DLL
#define EXPORTDLL __declspec(dllexport)


//extern "C" __declspec(dllexport)  - the "C" is only for C++ and we are in C


extern EXPORTDLL GstElement* iTmp1;  //for debuging
extern EXPORTDLL GstElement* iTmp2;  //for debuging

extern EXPORTDLL int run_gst(const int plug_num, const char* plug_names[]);
extern EXPORTDLL void Dgst_init(int argc, char* argv[]);
extern EXPORTDLL GstElement* Dgst_pipeline_new(const char* name);
extern EXPORTDLL GstElement* Dgst_element_factory_make(const gchar* factoryname, const gchar* name);
extern EXPORTDLL void Dgst_object_unref(gpointer ref);
extern EXPORTDLL GstBus* Dgst_element_get_bus(GstElement* element);
extern EXPORTDLL gboolean Dgst_bin_add(GstBin* bin, GstElement* element);
extern EXPORTDLL gboolean Dgst_element_link(GstElement* src, GstElement* dest);
extern EXPORTDLL GstStateChangeReturn Dgst_element_set_state(GstElement* element, GstState state);
extern EXPORTDLL GstMessage* Dgst_bus_timed_pop_filtered(GstBus* bus, GstClockTime timeout, GstMessageType types);
extern EXPORTDLL void Dgst_message_unref(GstMessage* msg);

extern EXPORTDLL void Dg_object_set_int(GstElement* element, const gchar* firstparam, const int val);
extern EXPORTDLL void Dg_object_set_pchar(GstElement* element, const gchar* firstparam, const gchar* val);
#pragma once
// Define we are exporting functions from DLL
#define EXPORTDLL __declspec(dllexport)


//extern "C" __declspec(dllexport)  - the "C" is only for C++ and we are in C


extern EXPORTDLL GstElement* iTmp1;  //for debuging
extern EXPORTDLL GstElement* iTmp2;  //for debuging

//extern EXPORTDLL int run_gst(const int plug_num, const char* plug_names[]);
extern EXPORTDLL void _Gst_init(int argc, char* argv[]);

extern EXPORTDLL GstElement* _Gst_pipeline_new(const char* name);
extern EXPORTDLL GstElement* _Gst_element_factory_make(const gchar* factoryname, const gchar* name);
extern EXPORTDLL void _Gst_object_unref(gpointer ref);

extern EXPORTDLL void _Gst_mini_object_unref(GstMiniObject* mini_object);

extern EXPORTDLL GstBus* _Gst_element_get_bus(GstElement* element);
extern EXPORTDLL gboolean _Gst_bin_add(GstBin* bin, GstElement* element);
extern EXPORTDLL gboolean _Gst_element_link(GstElement* src, GstElement* dest);
extern EXPORTDLL GstStateChangeReturn _Gst_element_set_state(GstElement* element, GstState state);

extern EXPORTDLL GstMessage* _Gst_bus_timed_pop_filtered(GstBus* bus, GstClockTime timeout, GstMessageType types);
extern EXPORTDLL void _Gst_message_parse_state_changed(GstMessage* message, GstState* oldstate, GstState* newstate, GstState* pending);
extern EXPORTDLL void _Gst_message_unref(GstMessage* msg);

extern EXPORTDLL void _G_object_set_int(GstElement* element, const gchar* firstparam, const int val);
extern EXPORTDLL void _G_object_set_pchar(GstElement* element, const gchar* firstparam, const gchar* val);
extern EXPORTDLL gchar* _Gst_object_get_name(GstObject* object);

extern EXPORTDLL GstPad* _Gst_element_get_request_pad(GstElement* element, const gchar* name);
extern EXPORTDLL GstPad* _Gst_element_get_static_pad(GstElement* element, const gchar* name);
extern EXPORTDLL GstPadLinkReturn _Gst_pad_link(GstPad* srcpad, GstPad* sinkpad);
extern EXPORTDLL void _Gst_element_release_request_pad(GstElement* element, GstPad* pad);

extern EXPORTDLL void _G_signal_connect(gpointer instance, const gchar* detailed_signal, GCallback	c_handler, gpointer data);

extern EXPORTDLL gboolean _Gst_pad_is_linked(GstPad* pad);
extern EXPORTDLL GstCaps* _Gst_pad_get_current_caps(GstPad* pad);
extern EXPORTDLL GstStructure* _Gst_caps_get_structure(const GstCaps* caps, guint index);
extern EXPORTDLL const gchar* _Gst_structure_get_name(const GstStructure* structure);

extern EXPORTDLL gboolean _Gst_element_query_position(GstElement* element, GstFormat format, gint64* cur);
extern EXPORTDLL gboolean _Gst_element_query_duration(GstElement* element, GstFormat format, gint64* duration);
extern EXPORTDLL gboolean _Gst_element_seek_simple(GstElement* element, GstFormat format, GstSeekFlags seek_flags, gint64 seek_pos);
extern EXPORTDLL GstElementFactory* _Gst_element_factory_find(const gchar* name);
extern EXPORTDLL const gchar* _Gst_element_factory_get_metadata(GstElementFactory* factory, const gchar* key);
extern EXPORTDLL const GList* _Gst_element_factory_get_static_pad_templates(GstElementFactory* factory);
extern EXPORTDLL guint _Gst_element_factory_get_num_pad_templates(GstElementFactory* factory);
extern EXPORTDLL GstCaps* _Gst_pad_query_caps(GstPad* pad, GstCaps* filter);
extern EXPORTDLL guint _Gst_caps_get_size(const GstCaps* caps);
extern EXPORTDLL gboolean _Gst_caps_is_any(const GstCaps* caps);
extern EXPORTDLL gboolean _Gst_caps_is_empty(const GstCaps* caps);
extern EXPORTDLL gboolean _Gst_structure_foreach (const GstStructure * structure, GstStructureForeachFunc func, gpointer user_data);
extern EXPORTDLL gchar* _Gst_value_serialize (const GValue *value);
extern EXPORTDLL const gchar* _G_quark_to_string (GQuark quark);
extern EXPORTDLL GstCaps* _Gst_static_caps_get (GstStaticCaps *static_caps);
extern EXPORTDLL void _Gst_bus_add_signal_watch (GstBus* bus);
extern EXPORTDLL void _Gst_video_overlay_set_window_handle(GstElement* plugbin, guintptr handle);
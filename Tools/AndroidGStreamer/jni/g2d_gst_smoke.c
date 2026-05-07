#include <jni.h>

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM *vm, void *reserved)
{
  (void) vm;
  (void) reserved;
  return JNI_VERSION_1_6;
}

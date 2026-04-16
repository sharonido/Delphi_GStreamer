#pragma once

#ifdef G2DOPENCV_EXPORTS
#define G2DCV_API extern "C" __declspec(dllexport)
#else
#define G2DCV_API extern "C" __declspec(dllimport)
#endif

#pragma pack(push, 1)
typedef struct {
    int    classId;
    float  confidence;
    float  x, y, w, h;
    char   label[64];
} G2DCV_Detection;
#pragma pack(pop)

// Lifecycle
G2DCV_API int         G2DCV_Init();
G2DCV_API void        G2DCV_Shutdown();
G2DCV_API const char* G2DCV_Version();

// Rotation
// src/dst: raw BGRx pixel data (4 bytes per pixel)
// angle: degrees, positive = counter-clockwise
// bgFill: background colour as 0x00RRGGBB
G2DCV_API int G2DCV_RotateFrame(
    const unsigned char* src,
    unsigned char* dst,
    int                  width,
    int                  height,
    int                  stride,
    double               angle,
    unsigned int         bgFill
);

// Object detection (Phase 2 - placeholder)
typedef void* G2DCV_Net;
G2DCV_API G2DCV_Net G2DCV_Net_Load(const char* modelPath,
    const char* configPath,
    const char* framework);
G2DCV_API void      G2DCV_Net_Free(G2DCV_Net net);
G2DCV_API int       G2DCV_Net_Detect(
    G2DCV_Net            net,
    const unsigned char* src,
    int                  width,
    int                  height,
    int                  stride,
    float                confThreshold,
    G2DCV_Detection* results,
    int                  maxResults
);
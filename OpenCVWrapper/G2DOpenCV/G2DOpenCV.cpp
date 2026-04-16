#include "pch.h"
#include "G2DOpenCV.h"
#include <opencv2/opencv.hpp>

// -------------------------------------------------------------------------
// Lifecycle
// -------------------------------------------------------------------------

G2DCV_API int G2DCV_Init()
{
    return 1;
}

G2DCV_API void G2DCV_Shutdown()
{
}

G2DCV_API const char* G2DCV_Version()
{
    return CV_VERSION;
}

// -------------------------------------------------------------------------
// Rotation
// -------------------------------------------------------------------------

G2DCV_API int G2DCV_RotateFrame(
    const unsigned char* src,
    unsigned char* dst,
    int                  width,
    int                  height,
    int                  stride,
    double               angle,
    unsigned int         bgFill)
{
    if (!src || !dst || width <= 0 || height <= 0)
        return 0;

    try
    {
        // Wrap src in a Mat - no copy, BGRx = CV_8UC4
        cv::Mat srcMat(height, width, CV_8UC4, (void*)src, stride);

        // Decompose bgFill 0x00RRGGBB into BGR order for OpenCV
        unsigned char fillB = (bgFill) & 0xFF;
        unsigned char fillG = (bgFill >> 8) & 0xFF;
        unsigned char fillR = (bgFill >> 16) & 0xFF;
        cv::Scalar    borderColor(fillB, fillG, fillR, 0);

        // Build rotation matrix around frame centre
        cv::Point2f centre(width / 2.0f, height / 2.0f);
        cv::Mat     rotMat = cv::getRotationMatrix2D(centre, angle, 1.0);

        // Apply rotation into a temporary Mat
        cv::Mat dstMat;
        cv::warpAffine(srcMat, dstMat, rotMat, srcMat.size(),
            cv::INTER_LINEAR,
            cv::BORDER_CONSTANT, borderColor);

        // Copy result into dst, respecting stride
        for (int row = 0; row < height; ++row)
            memcpy(dst + row * stride,
                dstMat.ptr(row),
                width * 4);

        return 1;
    }
    catch (...)
    {
        return 0;
    }
}

// -------------------------------------------------------------------------
// Object detection (Phase 2)
// -------------------------------------------------------------------------

G2DCV_API G2DCV_Net G2DCV_Net_Load(
    const char* modelPath,
    const char* configPath,
    const char* framework)
{
    try
    {
        cv::dnn::Net* net = new cv::dnn::Net(
            cv::dnn::readNet(modelPath, configPath, framework));
        if (net->empty())
        {
            delete net;
            return nullptr;
        }
        return net;
    }
    catch (...)
    {
        return nullptr;
    }
}

G2DCV_API void G2DCV_Net_Free(G2DCV_Net net)
{
    if (net)
        delete static_cast<cv::dnn::Net*>(net);
}

G2DCV_API int G2DCV_Net_Detect(
    G2DCV_Net            net,
    const unsigned char* src,
    int                  width,
    int                  height,
    int                  stride,
    float                confThreshold,
    G2DCV_Detection* results,
    int                  maxResults)
{
    // Phase 2 - not yet implemented
    return 0;
}
### C side of the bridge to GStreamer
This directory holds the C source of the dll. This is here just for controbuters. A programer that is just using the G2D does not need to use this directory.

The C side is a dll writen in C using the GStreamer framework. It is compiled using Visual Studio 2019.

The dllmain.cpp is in C++. It is not nessery but gives a wrap around the dll for future use.

The G2D.c is where the function of the dll are. They are just a wrap over the native function of GStreamer.

The G2D.h is where the functions are exported to the dll. so they can be used from the Pascal side of the bridge

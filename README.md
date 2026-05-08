# Delphi GStreamer (G2D)

G2D is a Delphi / Object Pascal bridge for [GStreamer](https://gstreamer.freedesktop.org/).

Its goal is to let Delphi developers build multimedia applications and custom media pipelines without dropping down to C, C++, Python, or Java. This repository contains:

- Delphi wrappers around GStreamer types, APIs, and objects
- a higher-level framework layer for building pipelines from Delphi
- tutorial ports and examples
- examples of building custom audio and video filters in Delphi

The project currently focuses on practical Windows desktop development with 64-bit Delphi.

## Current Status
This project is still evolving but the main branch is stable.

What is stable:
- Basics:
  - using GStreamer from Delphi code
  - building pipelines from Delphi
  - following the GStreamer tutorials in Delphi form
  - experimenting with custom audio and video filters

- Building your own elements:
  - building and running your filters (audio & video) by subclassing video or audio filters Delphi provided classes
  - building and running your filters (audio & video) by using OnProcess procedures in the classic Delphi way
  - building and running your Plugins (*.dll files) by subclassing (audio & video) provided plugins

Current limitations:

- mainly tested on Windows 10/11 & Delphi 10 or above
- mainly tested with 64-bit builds on Delphi VCL
- There is a Delphi FMX example under Tutorials\FMX but it is very limited
- I will also provide a small android example

## Who This Is For

This repository is useful if you want to:

- Build, and route audio/video streams in Delphi
- Building your own elements, inline filters & plugins in Delphi
- learn GStreamer through Delphi examples
- build your own GStreamer-backed tools or applications
- create custom filters in Delphi

If you are looking for the companion written guide, see:

- [G2D.docx](./G2D.docx)

## Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/sharonido/Delphi_GStreamer.git
```

Keep the repository folder structure intact.

### 2. Install GStreamer

Install the official 64-bit Windows GStreamer runtime/development package.

Example download page:

- [GStreamer Windows downloads](https://gstreamer.freedesktop.org/data/pkg/windows/)

This project has been tested with the MSVC 64-bit Windows build of GStreamer.

### 3. Open the Delphi projects

You can start with:

- the tutorial projects under [Tutorials](./Tutorials)
- the custom filter examples under [Building new Elements](./Tutorials/Building%20new%20Elements)

### 4. Build for Win64

The current project setup is primarily intended for 64-bit Delphi builds.

## Repository Layout

### Core wrapper layers

- [G_Types](./G_Types)
  GStreamer-related Pascal types and records
- [G_API](./G_API)
  Low-level bindings to GStreamer DLL functions
- [G_DBase](./G_DBase)
  Base Delphi wrapper classes over GStreamer objects
- [G_DUnits](./G_DUnits)
  Higher-level framework classes and helper abstractions
- [G_DPlugin](./G_DPlugin)
  Reusable base classes and helpers for real GStreamer plugin elements

### Learning and examples

- [Tutorials](./Tutorials)
  Delphi versions of the official GStreamer tutorials
- [Building new Elements](./Tutorials/Building%20new%20Elements)
  Examples of custom filters/elements written in Delphi
### Other folders

- [DLLs](./DLLs)
  Local DLL-related material used by the project
- [OpenCVWrapper](./OpenCVWrapper)
  OpenCV-related wrapper/helper code used by some examples

## Tutorials

The [Tutorials](./Tutorials) folder follows the structure of the official GStreamer tutorials:

- [GStreamer tutorials](https://gstreamer.freedesktop.org/documentation/tutorials/)

In general:

- `example1`, `example2`, ... map to the corresponding tutorial topics
- console and VCL examples are both included
- files with `W` in the name are typically VCL / windowed examples

If you are new to G2D, this is the best place to start.

## Custom Filters

The [Building new Elements](./Tutorials/Building%20new%20Elements) folder shows how to build custom filters in Delphi.

There are two custom-filter styles in the repository:

- simple Delphi-side filters built with `appsink` / `appsrc`
- real GStreamer plugin DLLs that can be loaded by GStreamer like ordinary elements

Recent work in this repository includes safer audio-filter building blocks, including a managed audio filter chain that wraps:

```text
audioconvert -> audioresample -> appsink -> Delphi filter -> appsrc -> audioconvert -> audioresample
```

This makes it easier to build practical Delphi-side audio filters without manually wiring the full normalization chain each time.

### Real plugin DLLs

The plugin framework lives in [G_DPlugin](./G_DPlugin). It is intended to make a real GStreamer plugin element feel like ordinary Delphi inheritance work.

For a first video filter, the usual path is:

1. Create a subclass of `TG2DVideoFilter`.
2. Override `ProcessVideoFrame` for the actual frame operation.
3. Add any element properties by overriding `SetProperty` / `GetProperty`.
4. Create a small plugin `.dpr` that registers the element type and metadata.
5. Build the project as a Win64 DLL.

For a first audio filter, the path is the same idea:

1. Create a subclass of `TG2DAudioFilter`.
2. Override `ProcessAudioFrame` for the actual audio operation.
3. Add normal GObject properties for runtime parameters, for example `band0=10`.
4. Keep the VCL/demo code small: build the pipeline and set element properties.
5. Build the project as a Win64 DLL.

For non-video filters, start from `TG2DBaseFilter`. It already provides the common element behavior:

- sink/src pads
- chain, event, and query forwarding
- `debug`, `debugfile`, and `filter` properties
- bypass support when `filter=false`

The current full-plugin examples are:

- [VideoInvert](./Tutorials/Building%20new%20Elements/plugins/VideoInvert)
  Builds `g2dinvert`, a simple RGB video invert filter.
- [VideoRotate](./Tutorials/Building%20new%20Elements/plugins/VideoRotate)
  Builds `g2drotate`, a BGRx video rotate filter using the OpenCV helper DLL.
- [AudioEqualizer](./Tutorials/Building%20new%20Elements/plugins/AudioEqualizer)
  Builds `g2dequalizer`, an 8-band F32LE audio equalizer plugin with `band0..band7`
  integer dB properties and a VCL demo that starts with `Tutorials/MediaFiles/test.mp3`.

Each folder contains:

- the plugin element source unit
- the plugin DLL project
- a VCL demo project
- a prebuilt plugin DLL in the folder root so the demo can run without rebuilding the plugin first

## Design Overview

G2D is organized in layers so you can work at the level you need:

1. `G_Types`
   Raw type definitions
2. `G_API`
   Raw imported GStreamer functions
3. `G_DBase`
   Delphi wrappers around GStreamer objects
4. `G_DUnits`
   Higher-level framework and custom-element helpers
5. `G_DPlugin`
   Base classes and helpers for real plugin DLL elements

That means you can either:

- stay close to the C/GStreamer model when needed
- or use higher-level Delphi abstractions for faster application work

## Recommended Companion Technologies

If your work goes beyond stream routing and playback, the following libraries often fit well alongside GStreamer:

- FFmpeg
  Great for container/codec-oriented media work
- OpenCV
  Great for image/video analysis and computer vision
- GStreamer
  Great for media pipelines, routing, playback, capture, and filtering

They overlap, but each has a different sweet spot.

## Notes

- The project has mainly been exercised with Delphi 10+.
- The code may work with other Pascal compilers, but that is not the main tested path today.
- The focus of the examples is practical usage, not full wrapper completeness.

## Contributing

Issues, improvements, fixes, and wrapper extensions are welcome.

If you improve an example, add a missing wrapper, or make pipeline building easier for Delphi users, that is valuable work for this project.

## Author

- ido@pitaron.info

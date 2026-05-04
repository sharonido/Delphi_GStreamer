# Delphi GStreamer (G2D)

G2D is a Delphi / Object Pascal bridge for [GStreamer](https://gstreamer.freedesktop.org/).

Its goal is to let Delphi developers build multimedia applications and custom media pipelines without dropping down to C, C++, Python, or Java. This repository contains:

- Delphi wrappers around GStreamer types, APIs, and objects
- a higher-level framework layer for building pipelines from Delphi
- tutorial ports and examples
- examples of building custom audio and video filters in Delphi

The project currently focuses on practical Windows desktop development with 64-bit Delphi.

## Current Status

This project is still evolving and should be treated as work in progress.

What works well today:

- using GStreamer from Delphi code
- building pipelines from Delphi
- following the GStreamer tutorials in Delphi form
- experimenting with custom audio and video filters

Current limitations:

- mainly tested on Windows 10/11
- mainly tested with 64-bit builds
- not all of GStreamer is wrapped yet
- some parts are still low-level and improving over time

## Who This Is For

This repository is useful if you want to:

- inspect, and route audio/video streams from Delphi
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

### Learning and examples

- [Tutorials](./Tutorials)
  Delphi versions of the official GStreamer tutorials
- [Building new Elements](./Tutorials/Building%20new%20Elements)
  Examples of custom filters/elements written in Delphi
- [Uni-Tests](./Uni-Tests)
  Unit tests and validation work

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

Recent work in this repository includes safer audio-filter building blocks, including a managed audio filter chain that wraps:

```text
audioconvert -> audioresample -> appsink -> Delphi filter -> appsrc -> audioconvert -> audioresample
```

This makes it easier to build practical Delphi-side audio filters without manually wiring the full normalization chain each time.

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

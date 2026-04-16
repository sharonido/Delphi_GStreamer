#### Contributor:
ido@pitaron.info

## Before you start
For manipulate media there are a number of open source frameworks, each with his own advantages. They also overlap one another. The three that I would recommend (With Delphi wrappers) are:   
- ***FFMPEG*** – best for understanding and unwrapping, wrapping media streams and files from one hand and decoding encoding the streams. (Also used in all kinds of GStreamer plugins).  
- ***OpenCV*** – best for unveiling what reality is actually in the media (Also used in some GStreamer plugins, filters).
- **GStreamer – what is explained here,** best for stream routing & filtering of media.    
In my opinion, GStreamer is more complicated to master, if you can work with the above two you may be better off.

## G2D 
G2D is a bridge between GStreamer framework and Pascal. This Is Version 3.0 of G2D
G2D would enable Delphi (object pascal) developers to use the GStreamer framework in their pascal program. By doing so G2D enables endless manipulation and uses of multimedia on Windows, Linux, Mac, ios and Android systems. Because GStreamer was unavailable for Delphi developers many professional multimedia project development used C, C++, Python and Java (that do have bridges to GStreamer) although in all other aspects Delphi would be their preferred choice.
You should download & read the word document [**Gstreamer for Delphi G2D.docx**](https://github.com/sharonido/Delphi_GStreamer/blob/master/G2D.docx) that is provided here.
  
## Be Aware
This G2D framework is in new stages of construction!!!
In this stage, it supports limited operation.
Here is a partly list of limitations:<br>
-       Support only windows (tested on windows 10 & 11 desktop only)
-       Support only programs compiled in 64 bit
## Installation
If you only want to use the Basic you only need to
Install the G2D that is the bridge between Delphi and GStreamer, that is here by:
#### Installing GStreamer G2D
Open: https://github.com/sharonido/Delphi_GStreamer you should download the whole repository by the green download button, or if you have git installed in your system then from cmd line enter the command:
> git clone https://<i></i>github.com/sharonido/Delphi_GStreamer.git
It is important to maintain the G2D internal structure (that we have here). It does not matter where you decide to put this directory structure in your system.

But to use all GStreamer capabilities you must install the GStreamer framework:
#### Installing GStreamer framework
Download from https://gstreamer.freedesktop.org/data/pkg/windows/1.28.2/msvc/
choose only gstreamer-1.0-msvc-x86_64-1.28.2.exe
run it and follow the instructions:)

Note: G2D should work with any pascal compiler but was not tested for that, only Delphi 10 and above was tested.


### Explanation
In the **Tutorials** directory<br>
there are sub-directories that follow the tutorials of GStreamer.<br>
The sub-directories follows these directories in:<br>
https://gstreamer.freedesktop.org/documentation/tutorials/index.html?gi-language=c<br>
Each sub-directory follows a tutorial. That is, example1 directory follows tutorial 1,
example2 follows tutorial 2, and so on. In some sub-directories there are more then one
example. Some examples use a console program. Some examples (with a "W" in their name)
use VCL with a delphi Tpanel as an output for rendering the video.<br>
This wrraper is made out of 4 Layers in 4 directories:<br>
-       A Types layer in "G_Types" directory defines types used in GStreamer.<br>
-       An API layer in "G_API" directory calls function in GStreamer DLLs.<br>
-       A Base layer in "G_DBase" directory defines classes that wrap the C semi classes used in GStreamer.<br>
-       A Unit layer in "G_DUnit" directory defines classes that wrap the Framework itself and classes that you can build your own elements by inheriting from them as shown in Building new Elements directory.<br>

These files should be included in the uses of your project and in the units
that use them like in the examples provided in the Tutorials directory.<br>



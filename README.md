#### Contributor:
ido@pitaron.info

G2D is a bridge between GStreamer framework and Pascal. 

G2D enables Delphi (pascal) developers to use the GStreamer framework in their pascal program. By doing so G2D enables endless manipulation and uses of multimedia on Windows, Linux, Mac, ios and Android systems. Because GStreamer was unavailable for Delphi developers many professional multimedia project development used C, C++, Python and Java (that do have bridges to GStreamer) although in all other aspects Delphi would be their preferred choice.  
You should download & read the word document **Gstreamer for Delphi G2D.docx** that is provided here.
  
## Be Aware
This G2D framework is in early stages of construction!!!  
In this stage, it supports very limited operation.  
Here is a partly list of limitations:
-	Support only windows (tested on windows 10 desktop only)
-	Support only programs compiled in 64 bit
-	Support only desktops that installed the full GStreamer for windows “68_64” (the 64-bit version). In addition, did not customize any directory places etc.
-	Most of GStreamer function are not yet bridged to pascal. We are only at the beginning of the process.    
## Installation
Before you can start programing with GStreamer in Delphi, you must install two main things:
1.	Install the GStreamer framework.
2.	Install the G2D that is the bridge between Delphi and GStreamer.

Note: G2D should work with any pascal compiler but was not tested for that, only Delphi 10.3.3 was tested.
### Installing GStreamer framework
Download from https://gstreamer.freedesktop.org/data/pkg/windows/1.16.2/ 
choose two *.msi files: “gstreamer-1.0-devel-msvc-x86_64-1.16.2.msi” & “gstreamer-1.0-msvc-x86_64-1.16.2.msi”
After downloading be sure to install them (by Double click on both). When installing do not change anything (just press next… and finish) so they will be installed in the default directories.  
### Installing GStreamer G2D
Open: https://github.com/sharonido/Delphi_GStreamer you should download the whole repository by the green download button, or if you have git installed in your system then from cmd line enter the command:  
> git clone https://<i></i>github.com/sharonido/Delphi_GStreamer.git   
#### Explanation
**In bin** directory there is  “G2D.dll” file. If you are running the examples, they will find it in the bin directory. If you build your own program, you should include the G2D.dll file in the directory of your exe file.   
**In the Delphi** directory there are Pascal units that use the dll and build a Delphi Object oriented wrapper around the native C functions in the DLL. These files should be included in the uses of your project and in the units that use them like in the examples provided in the **examples directory**.  
**In the C** directory, there are the C source of the G2D.dll. You can use them if you want to change the G2D.dll. Do that only if you are sure you know what you are doing  .

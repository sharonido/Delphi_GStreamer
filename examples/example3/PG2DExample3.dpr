{* copyright (c) 2020 I. Sharon Ltd.
 *
 * This file is part of GStreamer 2 Delphi bridge (G2D).
 *
 * G2D is free software; You can redistribute it and modify it. It is licensed
 * under the GNU Lesser General Public License as published by the Free Software
 * Foundation. Either version 2.1 of the License, or any later version.

for info on G2D download:
https://github.com/sharonido/Delphi_GStreamer/blob/master/G2D.docx
for full G2D source and bin dpwnload from:
https://github.com/sharonido/Delphi_GStreamer
  or clone by:
git clone https://github.com/sharonido/Delphi_GStreamer.git
}
program PG2DExample3;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  G2D in '..\..\Delphi\G2D.pas',
  G2DCallDll in '..\..\Delphi\G2DCallDll.pas',
  G2DTypes in '..\..\Delphi\G2DTypes.pas',
  WinConsoleFunction in '..\..\Delphi\WinConsoleFunction.pas';

{---  readme.txt ---------------------------------------------------------------

This is a Basic tutorial 3A program for G2D (Gstreamer bridge to Delphi)
This follows the Basic tutorial 3 in Gsteramer Docs in:
https://gstreamer.freedesktop.org/documentation/tutorials/basic/dynamic-pipelines.html?gi-language=c#walkthrough
YOU SHOULD look at this uri it has graphic explanations of this example!!!
but we use here an object oriented framework of Delphi
-----------
This program is audio only. to use, you must have audio output in your PC !

This program shows how to dynamically link 2 plugins. It is needed when the
plugins cannot link before the stream is running, cause they do not know the stream type.
We create all plugins and then link the plugins that can link
The Src & convert plugins are linked dynamically at play time

------------------------------------------------------------------------------}

//main -------------------------------------------------------------------------
Var
Src,Sink,convert,resample :TGPlugin;
GStreamer:TGstFrameWork;
c:char='A';
DoOnce:boolean=True;
begin
  try
  GStreamer:=TGstFrameWork.Create(0,nil); //no parameters needed here
  if GStreamer.Started then
    try
    //Creating the Src & Sink Pluin classes & Adding the plugins to the pipe line
    //   data.source = gst_element_factory_make ("uridecodebin", "source");
    Src:=TGPlugIn.Create('uridecodebin', 'Internet source');
    GStreamer.PipeLine.AddPlugIn(Src);

    convert:=TGPlugIn.Create('audioconvert', 'convert');
    GStreamer.PipeLine.AddPlugIn(convert);

    resample:=TGPlugIn.Create('audioresample','resample');
    GStreamer.PipeLine.AddPlugIn(resample);

    Sink:=TGPlugIn.Create('autoaudiosink','Audio sink plugin');
    GStreamer.PipeLine.AddPlugIn(Sink);

    if not D_element_link(convert,resample) or    //link all, but do not link  Src to convert
       not D_element_link(resample,Sink)
       then writeln('Link error');

    //Set Src, to get stream from Internet URI - BE AWARE D_object... is not Dg_object...
    D_object_set_string(Src,'uri',
      'https://www.freedesktop.org/software/gstreamer-sdk/data/media/sintel_trailer-480p.webm');

    //Set the link between Src PlugIn & convert plugin to be daynamic:
    //only for when audio stream is recieve it will link the src audio to sink audio
    GStreamer.SetPadAddedCallback(Src, convert, 'audio');

    if not GStreamer.PipeLine.ChangeState(GST_STATE_PLAYING)  then //change pipeline state to "play"
      begin
      Writeln('Error PipeLine did not change state to play');
      readln;
      exit;
      end;

    GStreamer.WaitForPlay(10); //wait (for up to 10 sec) for stream to start running
    if GStreamer.State=GST_STATE_PLAYING
      then writeln('GStreamer running')
      else
      begin
      writeln('GStreamer did not start running for 10 seconds - Error');
      exit;
      end;
    writeln;
    Writeln('Mouse click on this window to focuse it, so keyboard will be read');
    writeln;
    write('Press Enter to stop the audio stream ');
    while not GStreamer.G2DTerminate and not KeyPressed(c) do
      GStreamer.CheckMsgAndRunFor(10*GST_MSECOND);

    finally
      GStreamer.Free;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
write('Press Enter to exit');
readln;
end.

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
program PG2DExample3A;

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

This program does exactly the same as example 3. But does not use the SetPadAddedCallback procedure
Instead it uses the primitive Gstreamer procedures (That are used in the SetPadAddedCallback procedure).

This program shows how to dynamically link 2 plugins. It is needed when the
plugins cannot link before the stream is running, cause they do not know the stream type.
We create all plugins and then link the plugins that can link
The Src & convert plugins are linked dynamically at play time

------------------------------------------------------------------------------}


Procedure pad_added_handler(src, new_pad, data:pointer); cdecl;

var
n1,n2:string;
sink_pad:^_GstPad;
GstCaps:^_GstCaps;
PStruct: PGstStructure;
GstCapsStr:Pansichar;
begin
n2:=string(_GstObject(src^).name);
n1:=string(_GstObject(new_pad^).name);
writeln('Received new pad '+n1+' from '+n2);
GstCaps:=nil;
sink_pad := Dgst_element_get_static_pad (data{convert.RealObject}, 'sink');
if Dgst_pad_is_linked(sink_pad)
  then writeln('We are already linked. Ignoring.')
  else
  begin
  GstCaps:=Dgst_pad_get_current_caps(new_pad);
  PStruct:=Dgst_caps_get_structure(GstCaps, 0);
  GstCapsStr:=Dgst_structure_get_name(PStruct);
  n1:=string(GstCapsStr);
  if not n1.Contains('audio')
    then writeln('This pad is of type '+n1+' which is not audio. Ignoring.')
    else
    begin
    if (Dgst_pad_link(new_pad, sink_pad)<>GstPadLinkReturn.GST_PAD_LINK_OK)
      then writeln('This pad is of type '+n1+' but link failed.')
      else writeln('Pad link  with (type '''+n1+''') succeeded.');
    end;
  end;
if GstCaps<>nil then
  Dgst_mini_object_unref (@GstCaps.mini_object);
if sink_pad<>nil then
  Dgst_object_unref (sink_pad);
end;

//main -------------------------------------------------------------------------
Var
Src,Sink,convert,resample :GPlugin;
GStreamer:GstFrameWork;
c:char='A';
begin
  try
  GStreamer:=GstFrameWork.Create(0,nil); //no parameters needed here
    try
    //Creating the Src & Sink Pluin classes & Adding the plugins to the pipe line
    //   data.source = gst_element_factory_make ("uridecodebin", "source");
    Src:=GPlugIn.Create('uridecodebin', 'Internet source');
    GStreamer.PipeLine.AddPlugIn(Src);

    convert:=GPlugIn.Create('audioconvert', 'convert');
    GStreamer.PipeLine.AddPlugIn(convert);

    resample:=GPlugIn.Create('audioresample','resample');
    GStreamer.PipeLine.AddPlugIn(resample);

    Sink:=GPlugIn.Create('autoaudiosink','Audio sink plugin');
    GStreamer.PipeLine.AddPlugIn(Sink);

    if not D_element_link(convert,resample) or    //link all, but not Src to convert
       not D_element_link(resample,Sink)
       then writeln('Link error');

    //Set Src, to get stream from Internet URI - BE AWARE D_object... is not Dg_object...
    D_object_set_string(Src,'uri',
      'https://www.freedesktop.org/software/gstreamer-sdk/data/media/sintel_trailer-480p.webm');

    Dg_signal_connect (Src.RealObject, ansistring('pad-added'), @pad_added_handler, convert.RealObject);

    if not GStreamer.PipeLine.ChangeState(GST_STATE_PLAYING)  then //change pipeline stste to "play"
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

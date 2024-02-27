{* copyright (c) 2020 I. Sharon Ltd.
 *
 * This file is part of GStreamer 2 Delphi bridge (G2D).
 *
 * G2D is free software; You can redistribute it and modify it. It is licensed
 * under the GNU Lesser General Public License as published by the Free Software
 * Foundation. Either version 2.1 of the License, or any later version.

for info on G2D download:
https://github.com/sharonido/Delphi_GStreamer/blob/master/G2D.docx
for full G2D source and bin download from:
https://github.com/sharonido/Delphi_GStreamer
  or clone by:
git clone https://github.com/sharonido/Delphi_GStreamer.git
}

program PG2DExample7;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  G2D in '..\..\Delphi\G2D.pas',
  G2DCallDll in '..\..\Delphi\G2DCallDll.pas',
  G2DTypes in '..\..\Delphi\G2DTypes.pas';

{---  readme.txt ---------------------------------------------------------------
This program:
1.  Takes an Audio src splites it by a tee plugin
2.  requests a src pad from the tee and links it to a queue and sends it through
    resample, convertor and a sink plugins to the PC speakers
3.  requests another src pad from the tee and links it to another queue that is
    linked to a visual plugin, thats turns the audio to a video.
4   Then sends the video through a convertor and a sink plugin to the screen
------------------------------------------------------------------------------}

//main -------------------------------------------------------------------------
Var
  GStreamer:TGstFrameWork;
  SrcChain, AudioChain, VideoChain: string;

begin
//this (VER360)compiler directive is to enable the description below to be written
// on consul in Delphi 12 and above
{$IfDef VER360}
WriteOutln('''
--------------------
This is example7.
This follows the example7 in Gsteramer Docs in:
https://gstreamer.freedesktop.org/documentation/tutorials/basic/multithreading-and-pad-availability.html?gi-language=c
You should open the above URI and look at the graphic explanations to understand this program
-----------
This program:
1.  Takes an Audio src splites it by a tee plugin
2.  requests a src pad from the tee and links it to a queue and sends it through
    resample, convertor and a sink plugins to the PC speakers
3.  requests another src pad from the tee and links it to another queue that is
    linked to a visual plugin, thats turns the audio to a video.
4   Then sends the video through a convertor and a sink plugin to the screen
-----------------
''');
{$Endif}
  try
  GStreamer:=TGstFrameWork.Create(0,nil); //no parameters needed here
    try
    SrcChain:='audiotestsrc name=audio_source ! tee ';
    AudioChain:= 'queue name=audio_queue ! audioconvert ! audioresample ! autoaudiosink name=audio_sink';
    VideoChain:= 'queue name=video_queue ! wavescope name=visual shader=0 style=1 !'+
                 ' videoconvert name=video_convert ! d3d11videosink name=video_sink';

    if not GStreamer.BuildPlugInsInPipeLine (SrcChain+'!'+AudioChain+'!'+VideoChain)
    //build the plugins in the pipe but
    //do not link them - it is not a simple link (it has branches)
      then exit;

    If GStreamer.link(SrcChain) and
      GStreamer.link(AudioChain) and
      GStreamer.link(VideoChain) and
      GStreamer.setTeeChain('tee','audio_queue') and
      GStreamer.setTeeChain('tee','video_queue')
      then
      begin
      if GStreamer.PipeLine.ChangeState(GST_STATE_PLAYING)  //change pipe state to play
        then GStreamer.CheckMsgAndRunFor(DoForEver) //now the stream is running (for ever)
        else WriteOutLn ('error in change pipeline state');
      end;
    finally
     GStreamer.Free;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
write('press enter to exit ');    readln;
end.

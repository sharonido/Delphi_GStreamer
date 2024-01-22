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
  GStreamer:GstFrameWork;
  res:string;
function setTeeChain(TeeName, ChainName:string):string;
var
Plug:GPlugIn;
PadSrc,PadSink:GPad;
begin
Result:='';
plug:=GStreamer.PipeLine.GetPlugByName(TeeName); //the tee plugin
PadSrc:=GPad.CreateReqested(Plug, 'src_%u');     //'src_%u' is the generic name for "tee" src pads
writeln('The '+plug.Name+' requested src pad obtained as '+PadSrc.Name);
  //Get queue PadSink by static
plug:=GStreamer.PipeLine.GetPlugByName(ChainName); //the audio_queue plugin
PadSink:=GPad.CreateStatic(Plug, 'sink');
writeln('The '+Plug.Name+' requested sink pad obtained as '+PadSink.Name);
  // link tee_audio_PadSrc to queue_audio_PadSink
if GST_PAD_LINK_OK<>PadSrc.LinkToSink(PadSink)
  then Result:='Error in link '+PadSrc.Name+' to '+PadSink.Name
  else
  begin
  writeln('Pads were linked');
  PadSink.Free;// Release extra sink pad
  end;
end;

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
  GStreamer:=GstFrameWork.Create(0,nil); //no parameters needed here
    try
    if GStreamer.BuildPlugInsInPipeLine  //build the plugins in the pipe but do not link them - it is not a simple link (it has branches)
         ('audiotestsrc name=audio_source freq=800.0 ! tee '+
          '! queue name=audio_queue ! audioconvert ! audioresample ! autoaudiosink name=audio_sink '+
          '! queue name=video_queue ! wavescope name=visual shader=0 style=1 ! videoconvert name=video_convert '+
          '! autovideosink name=video_sink'+
          ' ')
      then
      begin
      //link the audio src to the tee
      if not D_element_link(GStreamer.PipeLine,'audio_source','tee')
        then writeln('Error in linking audio_source & tee')
        else  //link Ok
        begin
        //link the audio branch (from the audio queue to audio sink
        Res:=D_element_link_many_by_name(GStreamer.PipeLine,'audio_queue, audioconvert, audioresample, audio_sink');
        if Res<>'' then writeln(Res)
          else //link Ok
          begin
          //Link the video branch from the video queue to the video sink
          Res:=D_element_link_many_by_name(GStreamer.PipeLine,'video_queue, visual, video_convert, video_sink');
          if Res<>'' then writeln(Res)
            else //link Ok
            begin
            // create the pads for the audio branch (tee src0 as src and audio_queue as sink) and link them
            res:=setTeeChain('tee','audio_queue');
            if Res<>'' then writeln(Res) //err
              else
              begin
              res:=setTeeChain('tee','video_queue');
              // create the pads for the audio branch (tee src1 as src and video_queue as sink) and link them
              if Res<>'' then writeln(Res) //err
                else
                begin
                if GStreamer.PipeLine.ChangeState(GST_STATE_PLAYING)  //change pipe state to play
                  then GStreamer.CheckMsgAndRunFor(DoForEver) //now the stream is running (for ever)
                  else writeln ('error in change pipeline state');
                end;
              end;
            end;
          end;
        end
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

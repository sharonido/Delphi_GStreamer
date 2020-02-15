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
program PG2DExample7;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  G2D in '..\Delphi\G2D.pas',
  G2DCallDll in '..\Delphi\G2DCallDll.pas',
  WinConsoleFunction in '..\Delphi\WinConsoleFunction.pas';

{---  readme.txt ---------------------------------------------------------------
This program:
1.  Takes an Audio src splites it by a tee plugin
2.  requests a src pad from the tee and links it to a queue and sends it through
    resample, convertor and a sink plugins to the speakers
3.  requests another src pad from the tee and links it to another queue that is
    link to a visual plugin, thats turns the audio to a video.
4   Then sends the video through a convertor and a sink plugin to the screen
------------------------------------------------------------------------------}

//main -------------------------------------------------------------------------
Var
  GStreamer:GstFrameWork;
  plug:GPlugIn;
  res:string;
  tee_audio_PadSrc,queue_audio_PadSink,
  tee_video_PadSrc,queue_video_PadSink:GPad;
  PadLinkRet:GstPadLinkReturn;

begin
  try
  GStreamer:=GstFrameWork.Create(0,nil); //no parameters needed here
    try
    if GStreamer.BuildPlugInsInPipeLine  //build the plugins in the pipe but do not link them - it is not a simple link (it has branches)
         ('audiotestsrc name=audio_source freq=421.0 ! tee '+
          '! queue name=audio_queue ! audioconvert ! audioresample ! autoaudiosink name=audio_sink '+
          '! queue name=video_queue ! wavescope name=visual shader=0 style=1 ! videoconvert name=video_convert '+
          '! autovideosink name=video_sink'+
          ' ')
      then
      begin
      //link the audio src to the tee
      if not D_element_link(GStreamer.PipeLine,'audio_source','tee') then writeln('Error in linking audio_source & tee')
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
            // create the pads for the audio branch and link them
              //Get tee_audio_PadSrc by request
            plug:=GStreamer.PipeLine.GetPlugByName('tee'); //the tee plugin
            tee_audio_PadSrc:=GPad.CreateReqested(Plug, 'src_%u');     //'src_%u' is the generic name for "tee" src pads
            writeln('The '+Plug.Name+' requested src pad obtained as '+tee_audio_PadSrc.Name);
              //Get queue_audio_PadSink by static
            plug:=GStreamer.PipeLine.GetPlugByName('audio_queue'); //the audio_queue plugin
            queue_audio_PadSink:=GPad.CreateStatic(Plug, 'sink');
            writeln('The '+Plug.Name+' requested sink pad obtained as '+queue_audio_PadSink.Name);
              // link tee_audio_PadSrc to queue_audio_PadSink
            PadLinkRet:=tee_audio_PadSrc.LinkToSink(queue_audio_PadSink);
            if PadLinkRet<>GST_PAD_LINK_OK
              then writeln('Error in link tee_audio_PadSrc to queue_audio_PadSink = '+GstPadLinkReturnName(PadLinkRet))
              else
              begin
              writeln('Pads were linked');
              queue_audio_PadSink.DisposeOf;// Release extra sink pad
            // create the pads for the video branch and link them
              //Get tee_video_Pads by request
              plug:=GStreamer.PipeLine.GetPlugByName('tee'); //the same tee plugin
              tee_video_PadSrc:=GPad.CreateReqested(Plug, 'src_%u');     //'src_%u' is the generic name for "tee" src pads
              writeln('The '+Plug.Name+' requested src pad obtained as '+tee_video_PadSrc.Name);
              //Get queue_video_PadSink by static
              plug:=GStreamer.PipeLine.GetPlugByName('video_queue'); //the audio_queue plugin
              queue_video_PadSink:=GPad.CreateStatic(Plug, 'sink');
              writeln('The '+Plug.Name+' requested sink pad obtained as '+queue_video_PadSink.Name);
              // link tee_audio_PadSrc to queue_audio_PadSink
              PadLinkRet:=tee_video_PadSrc.LinkToSink(queue_video_PadSink);
              if PadLinkRet<>GST_PAD_LINK_OK
                then writeln('Error in link tee_video_PadSrc to queue_audio_PadSink = '+GstPadLinkReturnName(PadLinkRet))
                else
                begin
                queue_video_PadSink.DisposeOf; // Release extra sink pad
                if GStreamer.PipeLine.ChangeState(GST_STATE_PLAYING)  //change pipe state to play
                  then GStreamer.StreamRun(GST_CLOCK_TIME_NONE,integer(GST_MESSAGE_ERROR) or integer(GST_MESSAGE_EOS)) //run forever
                  else writeln ('error in change pipeline state');
                tee_audio_PadSrc.DisposeOf;  //do not dispose requested pad befor end of stream (it is used)
                tee_video_PadSrc.DisposeOf;  //do not dispose requested pad befor end of stream (it is used)
                end;
              end;

            end;
          end;
        end
      end;
    finally
    if (GStreamer<>nil) and GstFrameWork.Started //check the static var "started", cause GStreamer may not have started
      then GStreamer.DisposeOf;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
write('press enter to exit');    readln;
end.

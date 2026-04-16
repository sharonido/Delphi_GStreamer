unit Uex7W;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils,
  System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.WinXCtrls,
  G2D.GstFramework,
  G2D.GstElement.DOO,
  G2D.GstPad.DOO,
  G2D.Gst.Types, Vcl.Imaging.pngimage;

type
  TForm1 = class(TForm)
    // Left panel
    PanelLeft: TPanel;
    SplitterLeft: TSplitter;
    PanelWhatsNew: TPanel;
    LblWhatsNew: TLabel;
    REWhatsNew: TRichEdit;
    PanelLogger: TPanel;
    LblLogger: TLabel;
    Logger: TRichEdit;
    // Right panel
    PanelRight: TPanel;
    PanelControls: TPanel;
    TrackFreq: TTrackBar;
    PanelFreqInfo: TPanel;
    LblFreqCaption: TLabel;
    LblFreq: TLabel;
    TogglePlay: TToggleSwitch;
    VideoPanel: TPanel;
    Image1: TImage;
    Splitter2: TSplitter;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TogglePlayClick(Sender: TObject);
    procedure TrackFreqChange(Sender: TObject);
  private
    FTeeAudioPad : TGstPadRef;
    FTeeVideoPad : TGstPadRef;
    procedure BuildPipeline;
    procedure UpdateFreqLabel;
  public
    GStreamer: TGstFramework;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

{ --------------------------------------------------------------------------- }
{  Helpers                                                                     }
{ --------------------------------------------------------------------------- }

procedure TForm1.UpdateFreqLabel;
begin
  LblFreq.Caption := IntToStr(TrackFreq.Position) + ' Hz';
end;

{ --------------------------------------------------------------------------- }
{  Pipeline build                                                    }
{ --------------------------------------------------------------------------- }

procedure TForm1.BuildPipeline;
var
  LTee           : TGstElementRef;
  LAudioQueue    : TGstElementRef;
  LVideoQueue    : TGstElementRef;
  LQueueAudioPad : TGstPadRef;
  LQueueVideoPad : TGstPadRef;
  LLinkRes       : GstPadLinkReturn;
begin
  // Create empty pipeline
  if not GStreamer.NewPipeline('tut7') then
    raise Exception.Create('Failed to create pipeline');

  // Make all elements
  GStreamer.MakeElement('audiotestsrc',  'audio_source');
  GStreamer.MakeElement('tee',           'tee');
  GStreamer.MakeElement('queue',         'audio_queue');
  GStreamer.MakeElement('audioconvert',  'audio_convert');
  GStreamer.MakeElement('audioresample', 'audio_resample');
  GStreamer.MakeElement('autoaudiosink', 'audio_sink');
  GStreamer.MakeElement('queue',         'video_queue');
  GStreamer.MakeElement('wavescope',     'visual');
  GStreamer.MakeElement('videoconvert',  'video_convert');
  GStreamer.MakeElement('d3d11videosink', 'video_sink');

  // Add all elements to the pipeline
  GStreamer.AddElements([
    'audio_source', 'tee',
    'audio_queue',  'audio_convert', 'audio_resample', 'audio_sink',
    'video_queue',  'visual',        'video_convert',  'video_sink'
  ]);

  // Configure audiotestsrc frequency and wavescope style
  GStreamer.SetElementPropertyFloat('audio_source', 'freq', TrackFreq.Position);
  GStreamer.SetElementPropertyInt('visual', 'shader', 0);
  GStreamer.SetElementPropertyInt('visual', 'style',  1);

  // Link the Always-pad chains (tee not included yet)
  if not GStreamer.LinkElements('audio_source', 'tee') then
    raise Exception.Create('Failed to link audio_source -> tee');

  if not GStreamer.LinkMany(['audio_queue', 'audio_convert', 'audio_resample', 'audio_sink']) then
    raise Exception.Create('Failed to link audio branch');

  if not GStreamer.LinkMany(['video_queue', 'visual', 'video_convert', 'video_sink']) then
    raise Exception.Create('Failed to link video branch');

  // Request pads from tee and link them manually
  LTee        := GStreamer.GetElement('tee');
  LAudioQueue := GStreamer.GetElement('audio_queue');
  LVideoQueue := GStreamer.GetElement('video_queue');

  FTeeAudioPad := TGstPadRef.RequestFrom(LTee, 'src_%u');
  FTeeVideoPad := TGstPadRef.RequestFrom(LTee, 'src_%u');

  LQueueAudioPad := TGstPadRef.Wrap(LAudioQueue.GetStaticPad('sink'), False, True);
  LQueueVideoPad := TGstPadRef.Wrap(LVideoQueue.GetStaticPad('sink'), False, True);

  LLinkRes := FTeeAudioPad.Link(LQueueAudioPad);
  if LLinkRes <> GST_PAD_LINK_OK then
    raise Exception.CreateFmt('Failed to link tee audio pad: %s',
      [TGstPadRef.LinkResultToString(LLinkRes)]);

  LLinkRes := FTeeVideoPad.Link(LQueueVideoPad);
  if LLinkRes <> GST_PAD_LINK_OK then
    raise Exception.CreateFmt('Failed to link tee video pad: %s',
      [TGstPadRef.LinkResultToString(LLinkRes)]);

  LQueueAudioPad.Free;  // destructor calls gst_object_unref
  LQueueVideoPad.Free;

  // Point the video sink at our VCL panel

  GStreamer.SetVisualWindow('video_sink', VideoPanel.Handle);
  // Play
  GStreamer.Play;
end;

{ --------------------------------------------------------------------------- }
{  Form events                                                                 }
{ --------------------------------------------------------------------------- }

procedure TForm1.FormCreate(Sender: TObject);
begin
  FTeeAudioPad := nil;
  FTeeVideoPad := nil;

  GStreamer := TGstFramework.Create(True);
  GStreamer.StringsLogger := Logger.Lines;
  BuildPipeline;
  UpdateFreqLabel;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  //TearDownPipeline;
  GStreamer.Free;
end;

procedure TForm1.TogglePlayClick(Sender: TObject);
begin
  if TogglePlay.State = tssOn
    then
    begin
    GStreamer.Play;
    TrackFreqChange(nil);
    end
    else GStreamer.Pause; //TearDownPipeline;
end;

procedure TForm1.TrackFreqChange(Sender: TObject);
begin
  UpdateFreqLabel;
  // Update frequency live while pipeline is running
  if (GStreamer <> nil) and GStreamer.Started and
     (GStreamer.State = GST_STATE_PLAYING) then
    GStreamer.SetElementPropertyFloat('audio_source', 'freq', TrackFreq.Position);
end;

end.

unit Uex8W;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils,
  System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls,
  VclTee.TeeGDIPlus, VCLTee.TeEngine,
  VCLTee.Series, VCLTee.TeeProcs, VCLTee.Chart,
  G2D.GstFramework,
  G2D.GstElement.DOO,
  G2D.GstPad.DOO,
  G2D.GstApp.DOO,
  G2D.Gst.Types,
  G2D.Glib.Types,
  Vcl.Imaging.pngimage;

const
  CHUNK_SIZE  = 8 * 1024;   // bytes per buffer
  SAMPLE_RATE = 44100;       // samples per second

type
  TInt16Arr  = array[0..(CHUNK_SIZE div 2) - 1] of SmallInt;
  PInt16Arr  = ^TInt16Arr;

  TForm1 = class(TForm)
    // Left side
    PanelLeft: TPanel;
    SplitterLeft: TSplitter;
    PanelWhatsNew: TPanel;
    LblWhatsNew: TLabel;
    REWhatsNew: TRichEdit;
    PanelLogger: TPanel;
    LblLogger: TLabel;
    Logger: TRichEdit;
    // Right side
    PanelRight: TPanel;
    PanelVideo: TPanel;
    Chart1: TChart;
    Series1: TFastLineSeries;
    PanelWave: TPanel;
    RBPsych: TRadioButton;
    RBSaw: TRadioButton;
    RBClear: TRadioButton;
    Timer1: TTimer;
    Image1: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    FFeeding    : Boolean;
    FNumSamples : UInt64;
    FXa, FXb, FXc, FXd : Single;
    FSawMax     : Integer;
    FData       : TInt16Arr;
    FTeeAudioPad: TGstPadRef;
    FTeeVideoPad: TGstPadRef;
    FTeeAppPad  : TGstPadRef;
    FAppSrc     : TGstAppSrcRef;
    FAppSink    : TGstAppSinkRef;
    procedure BuildPipeline;
    procedure PushData;
    procedure GenPsych(AData: PInt16Arr; ACount: Integer);
    procedure GenSaw(AData: PInt16Arr; ACount: Integer);
    procedure GenClear(AData: PInt16Arr; ACount: Integer);
  public
    GStreamer : TGstFramework;
  end;

{ Callbacks - must be global cdecl }
procedure cb_start_feed(source: PGstElement; size: guint; data: gpointer); cdecl;
procedure cb_stop_feed(source: PGstElement; data: gpointer); cdecl;
function  cb_new_sample(sink: PGstElement; data: gpointer): GstFlowReturn; cdecl;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  G2D.Gst.API,
  G2D.Glib.API;

{ --------------------------------------------------------------------------- }
{  Callbacks                                                                   }
{ --------------------------------------------------------------------------- }

procedure cb_start_feed(source: PGstElement; size: guint; data: gpointer); cdecl;
begin
  TThread.Queue(nil, procedure
  begin
    LogWriteln('Pushing data');
  end);
  Form1.PushData;
end;

procedure cb_stop_feed(source: PGstElement; data: gpointer); cdecl;
begin
  Form1.FFeeding := False;
end;

function cb_new_sample(sink: PGstElement; data: gpointer): GstFlowReturn; cdecl;
var
  LBytesRead: gsize;
begin
  if Form1.FAppSink.PullSampleData(
       @Form1.FData,
       SizeOf(Form1.FData),
       LBytesRead) then
    Result := GST_FLOW_OK
  else
    Result := GST_FLOW_ERROR;
end;

{ --------------------------------------------------------------------------- }
{  Waveform generators                                                         }
{ --------------------------------------------------------------------------- }

procedure TForm1.GenPsych(AData: PInt16Arr; ACount: Integer);
var
  i, j  : Integer;
  LFreq : Single;
begin
  for j := 0 to (ACount div 1024) - 1 do
  begin
    FXc := FXc + FXd;
    FXd := FXd - FXc / 1000;
    LFreq := 1100 + 1000 * FXd;
    for i := 0 to 1023 do
    begin
      FXa := FXa + FXb;
      FXb := FXb - FXa / LFreq;
      try
        AData[i + j * 1024] := Round(500 * FXa);
      except
        on ERangeError do
        begin
          FXb := 1; FXd := 1; FXc := 0; FXa := 0;
          Break;
        end;
      end;
    end;
  end;
end;

procedure TForm1.GenSaw(AData: PInt16Arr; ACount: Integer);
var
  i, LStep: Integer;
begin
  LStep := 2 * FSawMax div 256;
  AData[0] := FSawMax;
  for i := 1 to ACount - 1 do
  begin
    AData[i] := AData[i - 1] + LStep;
    if AData[i] > FSawMax then AData[i] := -FSawMax;
  end;
end;

procedure TForm1.GenClear(AData: PInt16Arr; ACount: Integer);
var i: Integer;
begin
  for i := 0 to ACount - 1 do AData[i] := 0;
end;

{ --------------------------------------------------------------------------- }
{  Push data into appsrc                                                       }
{ --------------------------------------------------------------------------- }

procedure TForm1.PushData;
var
  LBuffer          : PGstBuffer;
  LMap             : GstMapInfo;
  LRaw             : PInt16Arr;
  LNumChunkSamples : UInt64;
  LRet             : GstFlowReturn;
begin
  while GStreamer.State < GST_STATE_READY do
    Application.ProcessMessages;

  LNumChunkSamples := CHUNK_SIZE div 2;
  FFeeding := True;

  while FFeeding do
  begin
    LBuffer := _gst_buffer_new_allocate(nil, CHUNK_SIZE, nil);
    LBuffer^.pts      := FNumSamples * UInt64(GST_SECOND) div SAMPLE_RATE;
    LBuffer^.duration := LNumChunkSamples * UInt64(GST_SECOND) div SAMPLE_RATE;

    _gst_buffer_map(LBuffer, @LMap, GST_MAP_WRITE);
    LRaw := PInt16Arr(LMap.data);

    if RBPsych.Checked      then GenPsych(LRaw, LNumChunkSamples)
    else if RBSaw.Checked   then GenSaw(LRaw, LNumChunkSamples)
    else                         GenClear(LRaw, LNumChunkSamples);

    _gst_buffer_unmap(LBuffer, @LMap);
    FNumSamples := FNumSamples + LNumChunkSamples;

    LRet := FAppSrc.PushBuffer(LBuffer);
    _gst_buffer_unref(LBuffer);

    if LRet <> GST_FLOW_OK then Break;
  end;
end;

{ --------------------------------------------------------------------------- }
{  Pipeline                                                                    }
{ --------------------------------------------------------------------------- }

procedure TForm1.BuildPipeline;
var
  LInfo      : GstAudioInfo;
  LAudioCaps : PGstCaps;
  LTee       : TGstElementRef;
  LAudioQ    : TGstElementRef;
  LVideoQ    : TGstElementRef;
  LAppQ      : TGstElementRef;
  LQAudioPad : TGstPadRef;
  LQVideoPad : TGstPadRef;
  LQAppPad   : TGstPadRef;
  LLinkRes   : GstPadLinkReturn;
begin
  if not GStreamer.NewPipeline('tut8') then
    raise Exception.Create('Failed to create pipeline');

  // Make all elements
  GStreamer.MakeElement('appsrc',        'audio_source');
  GStreamer.MakeElement('tee',           'tee');
  GStreamer.MakeElement('queue',         'audio_queue');
  GStreamer.MakeElement('audioconvert',  'audio_convert1');
  GStreamer.MakeElement('audioresample', 'audio_resample');
  GStreamer.MakeElement('autoaudiosink', 'audio_sink');
  GStreamer.MakeElement('queue',         'video_queue');
  GStreamer.MakeElement('audioconvert',  'audio_convert2');
  GStreamer.MakeElement('wavescope',     'visual');
  GStreamer.MakeElement('videoconvert',  'video_convert');
  GStreamer.MakeElement('d3d11videosink','video_sink');
  GStreamer.MakeElement('queue',         'app_queue');
  GStreamer.MakeElement('appsink',       'app_sink');

  // Add all to pipeline
  GStreamer.AddElements([
    'audio_source', 'tee',
    'audio_queue',  'audio_convert1', 'audio_resample', 'audio_sink',
    'video_queue',  'audio_convert2', 'visual', 'video_convert', 'video_sink',
    'app_queue',    'app_sink'
  ]);

  // Build audio caps
  _gst_audio_info_set_format(@LInfo, GST_AUDIO_FORMAT_S16LE, SAMPLE_RATE, 1, nil);
  LAudioCaps := _gst_audio_info_to_caps(@LInfo);

  // Wrap appsrc and appsink with OOP wrappers
  FAppSrc  := TGstAppSrcRef.Wrap(
                GStreamer.GetElement('audio_source').ElementHandle, True, True);
  FAppSink := TGstAppSinkRef.Wrap(
                GStreamer.GetElement('app_sink').ElementHandle, True, True);

  // Configure appsrc
  FAppSrc.SetCaps(LAudioCaps);
  FAppSrc.SetFormat(GST_FORMAT_TIME);
  FAppSrc.ConnectNeedData(@cb_start_feed);
  FAppSrc.ConnectEnoughData(@cb_stop_feed);

  // Configure appsink
  FAppSink.SetEmitSignals(True);
  FAppSink.SetCaps(LAudioCaps);
  FAppSink.ConnectNewSample(@cb_new_sample);

  _gst_caps_unref(LAudioCaps);

  // Configure wavescope
  GStreamer.SetElementPropertyInt('visual', 'shader', 0);
  GStreamer.SetElementPropertyInt('visual', 'style',  1);

  // Link Always-pad chains
  if not GStreamer.LinkElements('audio_source', 'tee') then
    raise Exception.Create('Failed to link audio_source -> tee');
  if not GStreamer.LinkMany(['audio_queue', 'audio_convert1', 'audio_resample', 'audio_sink']) then
    raise Exception.Create('Failed to link audio branch');
  if not GStreamer.LinkMany(['video_queue', 'audio_convert2', 'visual', 'video_convert', 'video_sink']) then
    raise Exception.Create('Failed to link video branch');
  if not GStreamer.LinkMany(['app_queue', 'app_sink']) then
    raise Exception.Create('Failed to link app branch');

  // Request tee pads and link manually
  LTee    := GStreamer.GetElement('tee');
  LAudioQ := GStreamer.GetElement('audio_queue');
  LVideoQ := GStreamer.GetElement('video_queue');
  LAppQ   := GStreamer.GetElement('app_queue');

  FTeeAudioPad := TGstPadRef.RequestFrom(LTee, 'src_%u');
  FTeeVideoPad := TGstPadRef.RequestFrom(LTee, 'src_%u');
  FTeeAppPad   := TGstPadRef.RequestFrom(LTee, 'src_%u');

  LQAudioPad := TGstPadRef.Wrap(LAudioQ.GetStaticPad('sink'), False, True);
  LQVideoPad := TGstPadRef.Wrap(LVideoQ.GetStaticPad('sink'), False, True);
  LQAppPad   := TGstPadRef.Wrap(LAppQ.GetStaticPad('sink'),   False, True);

  LLinkRes := FTeeAudioPad.Link(LQAudioPad);
  if LLinkRes <> GST_PAD_LINK_OK then
    raise Exception.CreateFmt('Failed to link tee audio pad: %s',
      [TGstPadRef.LinkResultToString(LLinkRes)]);

  LLinkRes := FTeeVideoPad.Link(LQVideoPad);
  if LLinkRes <> GST_PAD_LINK_OK then
    raise Exception.CreateFmt('Failed to link tee video pad: %s',
      [TGstPadRef.LinkResultToString(LLinkRes)]);

  LLinkRes := FTeeAppPad.Link(LQAppPad);
  if LLinkRes <> GST_PAD_LINK_OK then
    raise Exception.CreateFmt('Failed to link tee app pad: %s',
      [TGstPadRef.LinkResultToString(LLinkRes)]);

  LQAudioPad.Free;
  LQVideoPad.Free;
  LQAppPad.Free;

  // Set video window
  GStreamer.SetVisualWindow('video_sink', PanelVideo.Handle);

  GStreamer.Play;
end;

{ --------------------------------------------------------------------------- }
{  Form events                                                                 }
{ --------------------------------------------------------------------------- }

procedure TForm1.FormCreate(Sender: TObject);
begin
  FFeeding    := False;
  FNumSamples := 0;
  FXb         := 1;
  FXd         := 1;
  FSawMax     := 30000;
  FAppSrc     := nil;
  FAppSink    := nil;

  GStreamer := TGstFramework.Create(True);
  GStreamer.StringsLogger := Logger.Lines;

  RBPsych.Checked := True;

  BuildPipeline;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FFeeding := False;
  FreeAndNil(FAppSrc);
  FreeAndNil(FAppSink);
  GStreamer.Free;
end;

{ --------------------------------------------------------------------------- }
{  Timer - update TChart from appsink data                                    }
{ --------------------------------------------------------------------------- }

procedure TForm1.Timer1Timer(Sender: TObject);
var
  i, LStart: Integer;
begin
  // Find zero crossing for sync
  LStart := 0;
  while (FData[LStart] > 0) and (LStart < 500) do Inc(LStart);
  while (FData[LStart] < 0) and (LStart < 500) do Inc(LStart);

  Series1.Clear;
  Chart1.Axes.Left.SetMinMax(-1, 1);
  for i := 0 to 1023 do
    Series1.AddXY(i * 1000 / SAMPLE_RATE, FData[LStart + i] / 32000);
end;

end.

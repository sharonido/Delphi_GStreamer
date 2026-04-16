unit UexSVE1;

{------------------------------------------------------------------------------
  PG2DExampleSimpleVideoElement
  Demonstrates inserting a TGstVideoSimple subclass between
  videotestsrc and d3d11videosink.

  Pipeline (logical):
    videotestsrc pattern=N --> TMyPassthroughFilter --> d3d11videosink

  Pipeline (actual GStreamer elements):
    videotestsrc --> appsink --> [Delphi ProcessFrame] --> appsrc --> videoconvert --> d3d11videosink

  The filter is a passthrough (default ProcessFrame - memcopy).
  Use the radio buttons to change the videotestsrc pattern while running.
------------------------------------------------------------------------------}

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  G2D.Gst.Types,
  G2D.GstFramework,
  G2D.GstElement.DOO,
  G2D.CustomSimpleVideoElement, Vcl.ComCtrls;

type

{------------------------------------------------------------------------------
  TMyPassthroughFilter
  Minimal subclass - relies on the default ProcessFrame (memcopy passthrough).
  Override ProcessFrame here to do real processing.
------------------------------------------------------------------------------}
  TMyPassthroughFilter = class(TGstVideoSimple)
  protected
    function GetSinkCaps: string; override;
  end;

{------------------------------------------------------------------------------
  TForm1
------------------------------------------------------------------------------}
  TForm1 = class(TForm)
    VideoPanel   : TPanel;
    GroupBox1    : TGroupBox;
    RadioButton1 : TRadioButton;
    RadioButton2 : TRadioButton;
    RadioButton3 : TRadioButton;
    RadioButton4 : TRadioButton;
    RadioButton5 : TRadioButton;
    RadioButton6 : TRadioButton;
    RadioButton7 : TRadioButton;
    RadioButton8 : TRadioButton;
    RadioButton9 : TRadioButton;
    RadioButton10: TRadioButton;
    Panel1: TPanel;
    Splitter1: TSplitter;
    Panel2: TPanel;
    RichEdit1: TRichEdit;
    Label1: TLabel;
    Splitter2: TSplitter;
    Panel3: TPanel;
    Label2: TLabel;
    logger: TRichEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure RadioButtonClick(Sender: TObject);
  private
    FGStreamer   : TGstFramework;
    FFilter      : TMyPassthroughFilter;
    FSrc         : TGstElementRef;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

{------------------------------------------------------------------------------
  TMyPassthroughFilter
------------------------------------------------------------------------------}

function TMyPassthroughFilter.GetSinkCaps: string;
begin
  { Let GStreamer negotiate the format freely between videotestsrc and
    d3d11videosink. Specifying a format like BGR here would cause a
    not-negotiated error if the sink does not support that format.
    For actual image processing, override this to pin a specific format
    e.g. 'video/x-raw,format=BGRx' once you know the sink accepts it. }
  Result := 'video/x-raw';
end;

{------------------------------------------------------------------------------
  TForm1
------------------------------------------------------------------------------}

procedure TForm1.FormCreate(Sender: TObject);
begin
  FGStreamer := TGstFramework.Create(True);
  FGStreamer.StringsLogger:=logger.Lines;

  if not FGStreamer.Started then
  begin
    logwriteln('GStreamer failed to start');
    Exit;
  end;

  { 1. Create the pipeline }
  if not FGStreamer.NewPipeline('sve1') then
  begin
    logwriteln('Failed to create pipeline');
    Exit;
  end;

  { 2. Make the standard elements using gst-launch style description.
    async=false on d3d11videosink skips preroll so READY->PAUSED completes
    without waiting for the first buffer (which only arrives after PLAYING). }
  FGStreamer.MakeElements(
    'videotestsrc name=src !' +
    'd3d11videosink name=video_sink async=false !' +
    'videoconvert name=vconv');

  { 3. Create our custom filter - this creates appsink + appsrc internally }
  FFilter := TMyPassthroughFilter.Create(FGStreamer);

  { 4. Add standard elements to the bin }
  FGStreamer.AddElements(['src', 'vconv', 'video_sink']);

  { 5. Add filter to pipeline and link: src -> appsink -> appsrc -> vconv }
  FFilter.AddAndLink('src', 'vconv');

  { 6. Link the remaining standard chain }
  if not FGStreamer.LinkElements('vconv', 'video_sink') then
  begin
    logwriteln('Failed to link vconv -> video_sink');
    Exit;
  end;

  { Keep a handle to src for pattern changes }
  FSrc := FGStreamer.FindElement('src');

  FGStreamer.SetVisualWindow('video_sink', VideoPanel.Handle);
  if not FGStreamer.Play then
    logwriteln('Failed to set pipeline to PLAYING');
end;


procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FSrc);
  FreeAndNil(FFilter);
  FreeAndNil(FGStreamer);
end;

procedure TForm1.RadioButtonClick(Sender: TObject);
begin
  if FSrc <> nil then
    FSrc.SetPropertyEnum('pattern', (Sender as TRadioButton).Tag);
end;

end.

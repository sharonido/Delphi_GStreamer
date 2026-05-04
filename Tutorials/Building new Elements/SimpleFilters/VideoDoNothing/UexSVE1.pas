unit UexSVE1;

{------------------------------------------------------------------------------
  PG2DExampleSimpleVideoElement
  Demonstrates using a managed G2DVideoFilter between
  videotestsrc and d3d11videosink.

  Pipeline (logical):
    videotestsrc pattern=N --> G2DVideoFilter --> d3d11videosink

  Pipeline (actual GStreamer elements):
    videotestsrc --> G2DVideoFilter bin --> d3d11videosink

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
    FFilter      : TG2DVideoFilterRef;
    FSrc         : TGstElementRef;
    function FilterGetSinkCaps(Sender: TObject): string;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

function TForm1.FilterGetSinkCaps(Sender: TObject): string;
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
  LogWriteln(FGStreamer.Version);
  LogWriteln('Example of simple filter That does nothing');

  if not FGStreamer.Started then
  begin
    logwriteln('GStreamer failed to start');
    Exit;
  end;

  { 1. Create the pipeline }
  if not FGStreamer.Build(
    'videotestsrc name=src ! ' +
    'G2DVideoFilter name=VF1 ! ' +
    'd3d11videosink name=video_sink async=false') then
  begin
    LogWriteln('Failed to build pipeline');
    Exit;
  end;

  FFilter := FGStreamer.FindVideoFilter('VF1');
  if FFilter = nil then
  begin
    LogWriteln('Failed to find video filter VF1');
    Exit;
  end;
  FFilter.OnGetSinkCaps := FilterGetSinkCaps;

  if not FGStreamer.Pipeline.LinkAllElements then
  begin
    LogWriteln('Failed to link built pipeline');
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
  if Assigned(FFilter) then
  begin
    FFilter.OnGetSinkCaps := nil;
    FFilter.Shutdown;
  end;
  FFilter := nil;
  FreeAndNil(FGStreamer);
end;

procedure TForm1.RadioButtonClick(Sender: TObject);
begin
  if FSrc <> nil then
    FSrc.SetPropertyEnum('pattern', (Sender as TRadioButton).Tag);
end;

end.

unit UVRotate1;

{------------------------------------------------------------------------------
  PG2DExampleRotateFilter
  Demonstrates frame rotation using OpenCV via G2DOpenCV.dll.

  Pipeline (logical):
    videotestsrc pattern=N --> G2DVideoFilter --> d3d11videosink

  Pipeline (actual GStreamer elements):
    videotestsrc --> G2DVideoFilter bin --> d3d11videosink

  TrackBar1 controls the rotation angle (-180..+180 degrees).
  LDegree shows the current angle.
  Format is pinned to BGRx so OpenCV receives 4 bytes per pixel.
------------------------------------------------------------------------------}

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.SyncObjs,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.ComCtrls,
  G2D.Gst.Types,
  G2D.GstFramework,
  G2D.GstElement.DOO,
  G2D.OpenCV.API,
  G2D.CustomSimpleVideoElement;

type
{------------------------------------------------------------------------------
  TForm1
------------------------------------------------------------------------------}
  TForm1 = class(TForm)
    Panel4       : TPanel;
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
    Panel5       : TPanel;
    LDegree      : TLabel;
    TrackBar1    : TTrackBar;
    Panel1       : TPanel;
    Splitter1    : TSplitter;
    Panel2       : TPanel;
    Label1       : TLabel;
    RichEdit1    : TRichEdit;
    Splitter2    : TSplitter;
    Panel3       : TPanel;
    Label2       : TLabel;
    logger       : TRichEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure RadioButtonClick(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
  private
    FGStreamer : TGstFramework;
    FFilter   : TG2DVideoFilterRef;
    FSrc      : TGstElementRef;
    FLockAngle: TCriticalSection;
    FAngle    : Double;
    function FilterGetSinkCaps(Sender: TObject): string;
    function FilterProcessFrame(Sender: TObject; const AIn: GstVideoFrame;
      const AInfo: GstVideoInfo; var AOut: GstVideoFrame): Boolean;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

function TForm1.FilterGetSinkCaps(Sender: TObject): string;
begin
  Result := 'video/x-raw,format=BGRx';
end;

function TForm1.FilterProcessFrame(Sender: TObject; const AIn: GstVideoFrame;
  const AInfo: GstVideoInfo; var AOut: GstVideoFrame): Boolean;
var
  LAngle : Double;
begin
  FLockAngle.Acquire;
  try
    LAngle := FAngle;
  finally
    FLockAngle.Release;
  end;

  Result := G2DCV_RotateFrame(
    PByte(AIn.data[0]),
    PByte(AOut.data[0]),
    AInfo.width,
    AInfo.height,
    AInfo.stride[0],
    LAngle,
    0  { black background }
  );
end;

{------------------------------------------------------------------------------
  TForm1
------------------------------------------------------------------------------}

procedure TForm1.FormCreate(Sender: TObject);
begin
  { Load OpenCV wrapper DLL before creating the framework }
  G2D_LoadOpenCV;

  FGStreamer := TGstFramework.Create(True);
  FGStreamer.StringsLogger := logger.Lines;
  LogWriteln(FGStreamer.Version);
  LogWriteln('OpenCV version: ' + G2DCV_Version);
  FLockAngle := TCriticalSection.Create;
  FAngle := 0.0;

  if not FGStreamer.Started then
  begin
    LogWriteln('GStreamer failed to start');
    Exit;
  end;

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
  FFilter.OnProcessFrame := FilterProcessFrame;

  if not FGStreamer.Pipeline.LinkAllElements then
  begin
    LogWriteln('Failed to link built pipeline');
    Exit;
  end;

  FSrc := FGStreamer.FindElement('src');

  FGStreamer.SetVisualWindow('video_sink', VideoPanel.Handle);
  if not FGStreamer.Play then
    LogWriteln('Failed to set pipeline to PLAYING');

  { Initialise label to match trackbar starting position (0) }
  TrackBar1Change(TrackBar1);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FSrc);
  if Assigned(FFilter) then
  begin
    FFilter.OnProcessFrame := nil;
    FFilter.OnGetSinkCaps := nil;
    FFilter.Shutdown;
  end;
  FFilter := nil;
  FreeAndNil(FLockAngle);
  FreeAndNil(FGStreamer);
end;

procedure TForm1.RadioButtonClick(Sender: TObject);
begin
  if FSrc <> nil then
    FSrc.SetPropertyEnum('pattern', (Sender as TRadioButton).Tag);
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
var
  LAngle: Integer;
begin
  LAngle := TrackBar1.Position;
  LDegree.Caption := Format('%4d', [LAngle]) + #176;
  FLockAngle.Acquire;
  try
    FAngle := -LAngle;
  finally
    FLockAngle.Release;
  end;
end;

end.

unit UVRotate1;

{------------------------------------------------------------------------------
  PG2DExampleRotateFilter
  Demonstrates frame rotation using OpenCV via G2DOpenCV.dll.

  Pipeline (logical):
    videotestsrc pattern=N --> TRotateFilter --> d3d11videosink

  Pipeline (actual GStreamer elements):
    videotestsrc --> appsink --> [ProcessFrame] --> appsrc --> videoconvert --> d3d11videosink

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
  TRotateFilter
  Rotates each BGRx video frame by a runtime-configurable angle using
  OpenCV's warpAffine. The angle is set from the main thread via SetAngle
  and read from the streaming thread in ProcessFrame.
------------------------------------------------------------------------------}
  TRotateFilter = class(TGstVideoSimple)
  private
    FLockAngle : TCriticalSection;
    FAngle     : Double;
  protected
    function GetSinkCaps: string; override;
    function ProcessFrame(const AIn: GstVideoFrame;
      const AInfo: GstVideoInfo;
      var AOut: GstVideoFrame): Boolean; override;
  public
    constructor Create(AFramework: TGstFramework);
    destructor Destroy; override;
    procedure SetAngle(AAngle: Double);
  end;

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
    FFilter   : TRotateFilter;
    FSrc      : TGstElementRef;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

{------------------------------------------------------------------------------
  TRotateFilter
------------------------------------------------------------------------------}

constructor TRotateFilter.Create(AFramework: TGstFramework);
begin
  inherited Create(AFramework);
  FLockAngle := TCriticalSection.Create;
  FAngle     := 0.0;
end;

destructor TRotateFilter.Destroy;
begin
  FreeAndNil(FLockAngle);
  inherited;
end;

function TRotateFilter.GetSinkCaps: string;
begin
  Result := 'video/x-raw,format=BGRx';
end;

procedure TRotateFilter.SetAngle(AAngle: Double);
begin
  FLockAngle.Acquire;
  try
    FAngle := AAngle;
  finally
    FLockAngle.Release;
  end;
end;

function TRotateFilter.ProcessFrame(const AIn: GstVideoFrame;
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
  LogWriteln('OpenCV version: ' + G2DCV_Version);

  if not FGStreamer.Started then
  begin
    LogWriteln('GStreamer failed to start');
    Exit;
  end;

  if not FGStreamer.NewPipeline('rotate1') then
  begin
    LogWriteln('Failed to create pipeline');
    Exit;
  end;

  FGStreamer.MakeElements(
    'videotestsrc name=src !' +
    'd3d11videosink name=video_sink async=false !' +
    'videoconvert name=vconv');

  FFilter := TRotateFilter.Create(FGStreamer);

  FGStreamer.AddElements(['src', 'vconv', 'video_sink']);
  FFilter.AddAndLink('src', 'vconv');

  if not FGStreamer.LinkElements('vconv', 'video_sink') then
  begin
    LogWriteln('Failed to link vconv -> video_sink');
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
  FreeAndNil(FFilter);
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
  if Assigned(FFilter) then
    FFilter.SetAngle(LAngle);
end;

end.

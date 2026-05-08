unit UFMXEx2;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.Layouts,

  G2D.Glib.Types,
  G2D.Gst.Types,
  G2D.Gst.API,
  G2D.Gst.Android.Surface,
  G2D.GstFramework,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, FMX.Edit, FMX.EditBox, FMX.NumberBox,
  FMX.Objects;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    SurfaceHost: TLayout;
    GroupBox1: TGroupBox;
    NumberBox1: TNumberBox;
    Label1: TLabel;
    Label2: TLabel;
    Splitter1: TSplitter;
    Rectangle1: TRectangle;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure NumberBox1Change(Sender: TObject);
    procedure SurfaceHostClick(Sender: TObject);
    procedure GroupBox1Click(Sender: TObject);
  private
    GStreamer: TGstFramework;
    FSurface: TG2DAndroidSurfaceHelper;
    FSurfaceRetryTimer: TTimer;
    FSurfaceRetryCount, FPatternIndex: Integer;
    procedure SetSourcePattern(APattern: Integer);
    procedure StartSurfaceRetry;
    procedure StartVideoPipeline;
    procedure SurfaceRetryTimer(Sender: TObject);
    procedure SurfaceHostResize(Sender: TObject);
    procedure TryAcquireSurfaceWindow;
    procedure UpdateVideoSurface;
  public
  end;

var
  Form1: TForm1;

implementation


{$R *.fmx}
{$R *.LgXhdpiPh.fmx ANDROID}

const
  PATTERN_KEYS: array[0..9] of Integer = (0, 1, 2, 3, 4, 5, 6, 11, 22, 18);

procedure TForm1.SetSourcePattern(APattern: Integer);
begin
  if (GStreamer = nil) or not GStreamer.Started then
    Exit;

  GStreamer.SetElementPropertyInt('src', 'pattern', APattern);
  LogWriteln(Format('pattern=%d', [APattern]));
end;

procedure TForm1.StartSurfaceRetry;
begin
  FreeAndNil(FSurfaceRetryTimer);
  FSurfaceRetryCount := 0;
  FSurfaceRetryTimer := TTimer.Create(Self);
  FSurfaceRetryTimer.Interval := 250;
  FSurfaceRetryTimer.OnTimer := SurfaceRetryTimer;
  FSurfaceRetryTimer.Enabled := True;
end;

procedure TForm1.StartVideoPipeline;
const
  LPipelineText: AnsiString =
    'videotestsrc pattern=0 name=src ! videoconvert ! glimagesink name=video_sink';
begin
  if GStreamer = nil then
    raise Exception.Create('GStreamer framework is not ready');

  if GStreamer.PipeLine <> nil then
    Exit;

  if (FSurface = nil) or (FSurface.NativeWindowHandle = 0) then
    raise Exception.Create('Native window handle is not ready');

  if not GStreamer.Build(string(LPipelineText)) then
    raise Exception.Create('Failed to build videotestsrc pipeline');
  LogWriteln('Pipeline created');

  if not GStreamer.SetVisualWindow('video_sink',
    TG2DWindowHandle(FSurface.NativeWindowHandle)) then
    raise Exception.Create('Failed to set video window');
  LogWriteln('Overlay handle set');

  if not GStreamer.PipeLine.LinkAllElements then
    raise Exception.Create('Failed to link pipeline');

  if not GStreamer.Play then
    raise Exception.Create('Pipeline failed to enter PLAYING');

  LogWriteln('Pipeline PLAYING');
  UpdateVideoSurface;
  SetSourcePattern(PATTERN_KEYS[Trunc(NumberBox1.Value)]);
end;

procedure TForm1.SurfaceRetryTimer(Sender: TObject);
begin
  TryAcquireSurfaceWindow;
end;

procedure TForm1.SurfaceHostClick(Sender: TObject);
begin
Memo1.Visible:=not Memo1.Visible;
GroupBox1.Visible:= not GroupBox1.Visible;
end;

procedure TForm1.SurfaceHostResize(Sender: TObject);
begin
  UpdateVideoSurface;
end;

procedure TForm1.TryAcquireSurfaceWindow;
begin
  Inc(FSurfaceRetryCount);

  if (FSurface <> nil) and FSurface.TryAcquireNativeWindow then
  begin
    LogWriteln('Native window: 0x' + NativeUInt(FSurface.NativeWindowHandle).ToHexString);
    if FSurfaceRetryTimer <> nil then
      FSurfaceRetryTimer.Enabled := False;
    try
      StartVideoPipeline;
    except
      on E: Exception do
        LogWriteln('Pipeline failed: ' + E.Message);
    end;
    Exit;
  end;

  if FSurfaceRetryCount >= 20 then
  begin
    LogWriteln('Native window not ready after retry');
    FSurfaceRetryTimer.Enabled := False;
  end;
end;

procedure TForm1.UpdateVideoSurface;
var
  LHeight: Integer;
  LWidth: Integer;
begin
  if FSurface <> nil then
    FSurface.UpdateBounds;

  if (GStreamer = nil) or (GStreamer.PipeLine = nil) or
     (FSurface = nil) or (FSurface.NativeWindowHandle = 0) then
    Exit;

  LWidth := FSurface.NativeWindowWidth;
  LHeight := FSurface.NativeWindowHeight;
  if (LWidth <= 0) or (LHeight <= 0) then
    Exit;

  if not GStreamer.SetVisualRectangle('video_sink', 0, 0, LWidth, LHeight) then
    LogWriteln('error in the program (SetVisualRectangle function)');
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Memo1.Lines.Clear;
  NumberBox1.OnChange := NumberBox1Change;
  NumberBox1.OnChangeTracking := NumberBox1Change;
  NumberBox1.OnTyping := NumberBox1Change;
  SurfaceHost.OnResize := SurfaceHostResize;
  SurfaceHost.OnResized := SurfaceHostResize;
{$IF Defined(ANDROID)}
  try
    GStreamer := TGstFramework.Create(True);
    if not GStreamer.Started then
      raise Exception.Create('GStreamer framework did not start');

    GStreamer.StringsLogger := Memo1.Lines;
    LogWriteln(GStreamer.Version);
    LogWriteln('G2D Tutorial 2 on Android');

    FSurface := TG2DAndroidSurfaceHelper.Create(SurfaceHost);
    FSurface.Attach;
    LogWriteln('SurfaceView attached');
    if FSurface.TryAcquireNativeWindow then
      LogWriteln('Native window: 0x' + NativeUInt(FSurface.NativeWindowHandle).ToHexString)
    else begin
      LogWriteln('Native window not ready yet');
      StartSurfaceRetry;
      Exit;
    end;

    StartVideoPipeline;
  except
    on E: Exception do
      LogWriteln('Failed: ' + E.Message);
  end;
{$ELSE}
  LogWriteln('Android smoke test');
{$ENDIF}
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FSurfaceRetryTimer);
  FreeAndNil(GStreamer);
  FreeAndNil(FSurface);
end;

procedure TForm1.GroupBox1Click(Sender: TObject);
begin
inc(FPatternIndex);
if FPatternIndex > High(PATTERN_KEYS) then
  FPatternIndex :=0;
end;

procedure TForm1.NumberBox1Change(Sender: TObject);
begin
  if not TryStrToInt(NumberBox1.Text.Trim, FPatternIndex) then
    FPatternIndex := Trunc(NumberBox1.Value);

  if FPatternIndex < Low(PATTERN_KEYS) then
    FPatternIndex := Low(PATTERN_KEYS)
  else if FPatternIndex > High(PATTERN_KEYS) then
    FPatternIndex := High(PATTERN_KEYS);

  SetSourcePattern(PATTERN_KEYS[FPatternIndex]);
end;

end.

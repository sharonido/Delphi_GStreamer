unit UFMXEx2;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Types,
  System.UITypes,
  FMX.Forms,
  FMX.Platform.Win,
  Winapi.Windows,
  G2D.GstFramework,
  G2D.Gst.API,
  G2D.GstElement.DOO, FMX.StdCtrls, FMX.Types, FMX.Controls,
  FMX.Controls.Presentation, FMX.Edit, FMX.EditBox, FMX.NumberBox;

type
  TForm1 = class(TForm)
    VideoPanel: TPanel;
    GroupBox1: TGroupBox;
    NumberBox1: TNumberBox;
    Label1: TLabel;
    Label2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar;
      Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure NumberBox1Change(Sender: TObject);
  private
    FGStreamer: TGstFramework;
    FSrc: TGstElementRef;
    procedure StartPipeline;
    procedure UpdateVideoRectangle;
    procedure SetSourcePattern(APattern: Integer);
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

const
  PATTERN_KEYS: array[0..9] of Integer = (0, 1, 2, 3, 4, 5, 6, 11, 22, 18);

procedure TForm1.FormCreate(Sender: TObject);
begin
  StartPipeline;
  NumberBox1.SetFocus;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FSrc);
  FreeAndNil(FGStreamer);
end;

procedure TForm1.StartPipeline;
var
  LWnd: HWND;
begin
  FGStreamer := TGstFramework.Create(True);
  LogWriteln(DGstVersionString);
  LogWriteln('Example 2 FMX');

  if not FGStreamer.Started then
  begin
    LogWriteln('GStreamer failed to start');
    Exit;
  end;

  if not FGStreamer.BuildAndPlay(
    'videotestsrc pattern=0 name=src ! d3d11videosink name=video_sink') then
  begin
    LogWriteln('error in the program (BuildAndPlay function)');
    Exit;
  end;

  LWnd := WindowHandleToPlatform(Handle).Wnd;
  if not FGStreamer.SetVisualWindow('video_sink', LWnd) then
    LogWriteln('error in the program (SetVisualWindow function)');

  UpdateVideoRectangle;

  FSrc := FGStreamer.FindElement('src');
  if FSrc = nil then
    LogWriteln('error in the program (FindElement function)')
  else
    LogWriteln('Press 0..9 to change videotestsrc pattern');
end;

procedure TForm1.UpdateVideoRectangle;
var
  R: TRectF;
  LX: Integer;
  LY: Integer;
  LWidth: Integer;
  LHeight: Integer;
begin
  if (FGStreamer = nil) or (VideoPanel = nil) then
    Exit;

  R := VideoPanel.AbsoluteRect;
  LX := Round(R.Left);
  LY := Round(R.Top);
  LWidth := Round(R.Width);
  LHeight := Round(R.Height);

  if (LWidth <= 0) or (LHeight <= 0) then
    Exit;

  if not FGStreamer.SetVisualRectangle('video_sink', LX, LY, LWidth, LHeight) then
    LogWriteln('error in the program (SetVisualRectangle function)');
end;

procedure TForm1.SetSourcePattern(APattern: Integer);
begin
  if FSrc = nil then
    Exit;

  FSrc.SetPropertyEnum('pattern', APattern);
  LogWriteln(Format('pattern=%d', [APattern]));
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  UpdateVideoRectangle;
end;


procedure TForm1.NumberBox1Change(Sender: TObject);
begin
  SetSourcePattern(PATTERN_KEYS[NumberBox1.Text.ToInteger
  ]);
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
var
  LIndex: Integer;
begin
  if (KeyChar >= '0') and (KeyChar <= '9') then
  begin
    LIndex := Ord(KeyChar) - Ord('0');
    SetSourcePattern(PATTERN_KEYS[LIndex]);
  end;
end;

end.

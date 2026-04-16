unit Uex5W;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils,
  System.Variants, System.Classes,
  G2D.GstFramework, G2D.GstElement.DOO, G2D.Gst.Types, WinConsoleFunction,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Buttons;

type
// This is a class bypass, just for accessing OnMouse events in standard VCL
TTrackBar = class(Vcl.ComCtrls.TTrackBar)
  published
    property OnMouseDown;
    property OnMouseUp;
    property OnMouseMove;
  end;

//Form of Ex5W
  TForm1 = class(TForm)
    Panel1: TPanel;
    TrackPos: TTrackBar;
    Panel2: TPanel;
    Panel3: TPanel;
    Timer1: TTimer;
    Label2: TLabel;
    LDuriation: TLabel;
    Label3: TLabel;
    LPosition: TLabel;
    Panel4: TPanel;
    Splitter1: TSplitter;
    Label4: TLabel;
    Panel6: TPanel;
    REWhatsNew: TRichEdit;
    Panel7: TPanel;
    Splitter2: TSplitter;
    Label5: TLabel;
    Logger: TRichEdit;
    Panel8: TPanel;
    BtnPlayPause: TSpeedButton;
    Panel9: TPanel;
    Panel10: TPanel;
    CbSource: TComboBox;
    BtnLoad: TButton;
    Panel5: TPanel;
    Label1: TLabel;
    VideoPanel: TPanel;
    OpenDialog1: TOpenDialog;
    Label6: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure TrackPosChange(Sender: TObject);
    procedure BtnPlayPauseClick(Sender: TObject);
    procedure BtnLoadClick(Sender: TObject);
    procedure CbSourceChange(Sender: TObject);
  private
    { Private declarations }
    StopTrackUpDate: Boolean;
    ThePos: Integer;
    procedure TrackPosMouseDown(Sender: TObject; Button: TMouseButton;
       Shift: TShiftState; X, Y: Integer);
    procedure TrackBarMouseUp(Sender: TObject; Button: TMouseButton;
       Shift: TShiftState; X, Y: Integer);
    procedure PlayURI(const AURI: string);
  public
    { Public declarations }
    GStreamer: TGstFrameWork;
    UriParameter: string;
    Dur64: Int64;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

{ Pre-defined sample sources shown in the combo }
const
  PREDEFINED_SOURCES: array[0..1] of string = (
    'https://www.freedesktop.org/software/gstreamer-sdk/data/media/sintel_trailer-480p.webm',
    'https://www.freedesktop.org/software/gstreamer-sdk/data/media/sintel_trailer-480p.ogv'
  );

{ Convert a local file path to a GStreamer file:/// URI }
function FilePathToURI(const APath: string): string;
begin
  Result := 'file:///' +
    StringReplace(ExpandFileName(APath), '\', '/', [rfReplaceAll]);
end;

{ Stop current pipeline and start a new one with the given URI }
procedure TForm1.PlayURI(const AURI: string);
begin
  GStreamer.Close;
  if not GStreamer.BuildAndPlay('playbin name=player uri=' + AURI) then
    Writeln('error in BuildAndPlay')
  else if not GStreamer.SetVisualWindow('player', VideoPanel.Handle) then
    Writeln('error in SetVisualWindow');
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  // trackbar mouse events
  TrackPos.OnMouseDown := TrackPosMouseDown;
  TrackPos.OnMouseUp   := TrackBarMouseUp;
  StopTrackUpDate := False;

  // populate the combo with pre-defined sources
  CbSource.Items.Clear;
  for I := Low(PREDEFINED_SOURCES) to High(PREDEFINED_SOURCES) do
    CbSource.Items.Add(PREDEFINED_SOURCES[I]);

  // pick the URI to start with
  UriParameter := ReadParameter('uri');
  if (UriParameter <> '') and FileExists(UriParameter) then
  begin
    UriParameter := FilePathToURI(UriParameter);
    CbSource.Items.Insert(0, UriParameter);
  end
  else
    UriParameter := PREDEFINED_SOURCES[0];

  CbSource.Text := UriParameter;

  // start GStreamer
  GStreamer := TGstFrameWork.Create(True);
  if GStreamer.Started then
  begin
    GStreamer.StringsLogger := Logger.Lines;
    PlayURI(UriParameter);
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  GStreamer.Free;
end;

{ Open file dialog — convert path to file:/// URI, add to combo, play }
procedure TForm1.BtnLoadClick(Sender: TObject);
var
  URI: string;
begin
  if not OpenDialog1.Execute then
    Exit;

  URI := FilePathToURI(OpenDialog1.FileName);

  // add to combo if not already there
  if CbSource.Items.IndexOf(URI) < 0 then
    CbSource.Items.Insert(0, URI);

  CbSource.Text := URI;
  PlayURI(URI);
end;

{ User picks an item from the combo dropdown }
procedure TForm1.CbSourceChange(Sender: TObject);
var
  URI: string;
begin
  URI := Trim(CbSource.Text);
  if URI = '' then
    Exit;

  // if it looks like a local path (no ://) convert it to a URI
  if Pos('://', URI) = 0 then
    URI := FilePathToURI(URI);

  PlayURI(URI);
end;

{ Play / Pause toggle }
procedure TForm1.BtnPlayPauseClick(Sender: TObject);
begin
  BtnPlayPause.Caption := #$231B;  // hourglass while switching
  if BtnPlayPause.Down then
  begin
    GStreamer.Play;
    BtnPlayPause.Caption := #$23F8;  // ⏸
    Exit;
  end;
  GStreamer.Pause;
  BtnPlayPause.Caption := #$25B6;  // ▶
end;

{ Timer — update trackbar and position/duration labels }
procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if GStreamer.Duration <= 10 then
  begin
    TrackPos.Max       := 10;
    TrackPos.Frequency := 1;
    TrackPos.Position  := 0;
  end
  else
  begin
    if not StopTrackUpDate then
    begin
      TrackPos.Max := uint64(GStreamer.Duration) div GST_MSECOND;
      ThePos       := uint64(GStreamer.Position)  div GST_MSECOND;
      if ThePos > 0 then TrackPos.Position := ThePos;
    end;
  end;

  LDuriation.Caption := GstClockTimeToStr(GStreamer.Duration);
  if not StopTrackUpDate then
    LPosition.Caption := GstClockTimeToStr(GStreamer.Position);
end;

{ Seek on mouse-up after dragging }
procedure TForm1.TrackBarMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if GStreamer.Duration > 10 then
    GStreamer.SeekSimple(
      uint64(TrackPos.Position) * GST_MSECOND,
      GST_FORMAT_TIME,
      GST_SEEK_FLAG_FLUSH or GST_SEEK_FLAG_KEY_UNIT);
  StopTrackUpDate := False;
end;

procedure TForm1.TrackPosChange(Sender: TObject);
begin
  if StopTrackUpDate then
    LPosition.Caption := GstClockTimeToStr(uint64(TrackPos.Position) * GST_MSECOND);
end;

procedure TForm1.TrackPosMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  StopTrackUpDate := True;
end;

end.

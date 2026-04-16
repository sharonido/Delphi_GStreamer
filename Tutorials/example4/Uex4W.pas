unit Uex4W;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  G2D.GstFramework, G2D.GstElement.DOO, G2D.Gst.Types, WinConsoleFunction,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.ComCtrls;

type
// This is a class bypass, just for accessing OnMouse events in standard VCL
TTrackBar = class(Vcl.ComCtrls.TTrackBar)
  published
    property OnMouseDown;
    property OnMouseUp;
    property OnMouseMove;
  end;

//Form of Ex4W
  TForm1 = class(TForm)
    VideoPanel: TPanel;
    Label1: TLabel;
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
    Panel5: TPanel;
    Label4: TLabel;
    Panel6: TPanel;
    REWhatsNew: TRichEdit;
    Panel7: TPanel;
    Splitter2: TSplitter;
    Label5: TLabel;
    Logger: TRichEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure TrackPosChange(Sender: TObject);
  private
    { Private declarations }

    StopTrackUpDate:boolean;
    ThePos:integer;
    procedure TrackPosMouseDown(Sender: TObject; Button: TMouseButton;
       Shift: TShiftState; X, Y: Integer);
    procedure TrackBarMouseUp (Sender: TObject; Button: TMouseButton;
       Shift: TShiftState; X, Y: Integer);
  public
    { Public declarations }
    GStreamer:TGstFrameWork;
    UriParameter:string;
    Dur64:int64;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}


procedure TForm1.FormCreate(Sender: TObject);
begin
// scrolling the video events
TrackPos.OnMouseDown := TrackPosMouseDown;
TrackPos.OnMouseUp   := TrackBarMouseUp;
StopTrackUpDate:=false;

// UriParameter: if your Internet connection is not good you can play an *.mp4
// file by "C:/somefile.mp4" (path+filename)
//in the program cmd line
UriParameter:= ReadParameter('uri');
if (UriParameter='') or not FileExists(UriParameter)
  then UriParameter:='https://www.freedesktop.org/'+
        'software/gstreamer-sdk/data/media/sintel_trailer-480p.webm'
  else UriParameter:='file:///'+StringReplace(ExpandFileName(UriParameter), '\', '/', [rfReplaceAll]);


//Example 4W
GStreamer:=TGstFrameWork.Create(true);
  if GStreamer.Started then
    begin
    GStreamer.StringsLogger:=Logger.Lines;
    if not GStreamer.BuildAndPlay('playbin name=player uri='+UriParameter)
      then writeln('error in the program (BuildAndPlay function)')
      //set the Form1.VideoPanel(vcl TPanel) as a render pallet for the video sink
      else if not GStreamer.SetVisualWindow('player',VideoPanel.Handle)
      then writeln('error in the program (SetVisualWindow function)');
    end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
GStreamer.Free;
end;


// Timer for showing the Video position on the TrackBar
procedure TForm1.Timer1Timer(Sender: TObject);
begin
If GStreamer.Duration<=10
  then
  begin
  TrackPos.Max:=10;
  TrackPos.Frequency:=1;
  TrackPos.Position:=0;
  end
  else
  begin
  if Not StopTrackUpDate then
    begin
    TrackPos.Max:=uint64(GStreamer.Duration) div GST_MSECOND;
    ThePos:=uint64(GStreamer.Position) div GST_MSECOND;
    If ThePos>0 then TrackPos.Position:=ThePos;
    end;
  end;
LDuriation.Caption:=GstClockTimeToStr(GStreamer.Duration);
If not StopTrackUpDate then
  LPosition.Caption:=GstClockTimeToStr(GStreamer.Position);
end;

//Scrolling the Video by dragging the track bar with the mouse
procedure TForm1.TrackBarMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
If GStreamer.Duration>10 then
  begin
  //GStreamer.Play;
  GStreamer.SeekSimple(
    uInt64(TrackPos.Position) * GST_MSECOND,
    GST_FORMAT_TIME,
    GST_SEEK_FLAG_FLUSH or GST_SEEK_FLAG_KEY_UNIT );
  end;
StopTrackUpDate:=false;
end;

procedure TForm1.TrackPosMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
StopTrackUpDate:=true;
end;

procedure TForm1.TrackPosChange(Sender: TObject);
begin
If StopTrackUpDate then
  LPosition.Caption:=GstClockTimeToStr(TrackPos.Position * GST_MSECOND);
end;


end.

unit UexTxtF1;

{------------------------------------------------------------------------------
  PG2DExampleTextFilter
  Demonstrates a text overlay filter using TGstVideoSimple.

  Pipeline (logical):
    videotestsrc pattern=N --> TTextOverlayFilter --> d3d11videosink

  Pipeline (actual GStreamer elements):
    videotestsrc --> appsink --> [ProcessFrame] --> appsrc --> videoconvert --> d3d11videosink

  Filter: when the toggle switch is on, draws the text from EditText onto
  each video frame at the bottom-left corner. Format is pinned to BGRx.

  The text is pre-rendered into a TBitmap once in OnVideoInfoChanged and
  reused for every frame - no per-frame GDI calls.
  When the text changes, RenderOverlay is called to rebuild the bitmap.
------------------------------------------------------------------------------}

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.SyncObjs,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.WinXCtrls, Vcl.Graphics,
  G2D.Gst.Types,
  G2D.GstFramework,
  G2D.GstElement.DOO,
  G2D.CustomSimpleVideoElement;

type

{------------------------------------------------------------------------------
  TTextOverlayFilter
  Draws text onto BGRx video frames.

  - OnVideoInfoChanged: allocates FOverlay bitmap matching frame size,
    calls RenderOverlay to draw the current text.
  - RenderOverlay: redraws text onto FOverlay (call when text changes).
  - ProcessFrame: if enabled, blends FOverlay pixels onto output frame.

  Thread safety: FEnabled and FOverlay are accessed from the streaming
  thread. FLockOverlay protects FOverlay during rebuild.
------------------------------------------------------------------------------}
  TTextOverlayFilter = class(TGstVideoSimple)
  private
    FLockOverlay : TCriticalSection;
    FOverlay     : TBitmap;       { pre-rendered text, BGRx-sized }
    FText        : string;        { current overlay text }
    FEnabled     : Boolean;       { whether overlay is drawn }

  protected
    function GetSinkCaps: string; override;
    procedure OnVideoInfoChanged(const AInfo: GstVideoInfo); override;
    function ProcessFrame(const AIn: GstVideoFrame;
      const AInfo: GstVideoInfo;
      var AOut: GstVideoFrame): Boolean; override;

  public
    constructor Create(AFramework: TGstFramework);
    destructor Destroy; override;

    { Call from main thread when text or enabled state changes.
      Rebuilds the overlay bitmap with the current text. }
    procedure RenderOverlay(const AText: string; AEnabled: Boolean);
  end;

{------------------------------------------------------------------------------
  TForm1
------------------------------------------------------------------------------}
  TForm1 = class(TForm)
    Panel4        : TPanel;
    VideoPanel    : TPanel;
    GroupBox1     : TGroupBox;
    RadioButton1  : TRadioButton;
    RadioButton2  : TRadioButton;
    RadioButton3  : TRadioButton;
    RadioButton4  : TRadioButton;
    RadioButton5  : TRadioButton;
    RadioButton6  : TRadioButton;
    RadioButton7  : TRadioButton;
    RadioButton8  : TRadioButton;
    RadioButton9  : TRadioButton;
    RadioButton10 : TRadioButton;
    Panel5        : TPanel;
    Label3        : TLabel;
    Edit1         : TEdit;
    ToggleSwitch1 : TToggleSwitch;
    Panel1        : TPanel;
    Splitter1     : TSplitter;
    Panel2        : TPanel;
    Label1        : TLabel;
    RichEdit1     : TRichEdit;
    Splitter2     : TSplitter;
    Panel3        : TPanel;
    Label2        : TLabel;
    logger        : TRichEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure RadioButtonClick(Sender: TObject);
    procedure ToggleSwitch1Click(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
  private
    FGStreamer : TGstFramework;
    FFilter   : TTextOverlayFilter;
    FSrc      : TGstElementRef;
    procedure UpdateOverlay;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

{------------------------------------------------------------------------------
  TTextOverlayFilter
------------------------------------------------------------------------------}

constructor TTextOverlayFilter.Create(AFramework: TGstFramework);
begin
  inherited Create(AFramework);
  FLockOverlay := TCriticalSection.Create;
  FOverlay     := nil;
  FText        := '';
  FEnabled     := False;
end;

destructor TTextOverlayFilter.Destroy;
begin
  FLockOverlay.Acquire;
  try
    FreeAndNil(FOverlay);
  finally
    FLockOverlay.Release;
  end;
  FreeAndNil(FLockOverlay);
  inherited;
end;

function TTextOverlayFilter.GetSinkCaps: string;
begin
  Result := 'video/x-raw,format=BGRx';
end;

procedure TTextOverlayFilter.OnVideoInfoChanged(const AInfo: GstVideoInfo);
begin
  { Rebuild the overlay bitmap at the new frame size.
    Called on the streaming thread - RenderOverlay acquires FLockOverlay. }
  RenderOverlay(FText, FEnabled);
end;

procedure TTextOverlayFilter.RenderOverlay(const AText: string;
  AEnabled: Boolean);
var
  LBmp    : TBitmap;
  LWidth  : Integer;
  LHeight : Integer;
begin
  { Snapshot video dimensions - HasVideoInfo may be false before first frame }
  if not HasVideoInfo then
  begin
    FLockOverlay.Acquire;
    try
      FText    := AText;
      FEnabled := AEnabled;
    finally
      FLockOverlay.Release;
    end;
    Exit;
  end;

  LWidth  := VideoInfo.width;
  LHeight := VideoInfo.height;

  LBmp := TBitmap.Create;
  try
    LBmp.PixelFormat := pf32bit;
    LBmp.Width       := LWidth;
    LBmp.Height      := LHeight;

    { Fill with black (transparent key: any pixel with B=0,G=0,R=0
      will not be drawn over the video) }
    LBmp.Canvas.Brush.Color := clBlack;
    LBmp.Canvas.FillRect(Rect(0, 0, LWidth, LHeight));

    if AEnabled and (AText <> '') then
    begin
      LBmp.Canvas.Font.Name  := 'Arial';
      LBmp.Canvas.Font.Size  := 18;
      LBmp.Canvas.Font.Style := [fsBold];
      LBmp.Canvas.Font.Color := clWhite;
      LBmp.Canvas.Brush.Style := bsClear;
      { Draw at bottom-left with a small margin }
      LBmp.Canvas.TextOut(10, LHeight - 36, AText);
    end;

    FLockOverlay.Acquire;
    try
      FText    := AText;
      FEnabled := AEnabled;
      FreeAndNil(FOverlay);
      FOverlay := LBmp;
      LBmp     := nil;  { ownership transferred }
    finally
      FLockOverlay.Release;
    end;
  finally
    LBmp.Free;  { no-op if ownership was transferred }
  end;
end;

function TTextOverlayFilter.ProcessFrame(const AIn: GstVideoFrame;
  const AInfo: GstVideoInfo; var AOut: GstVideoFrame): Boolean;
var
  LRow     : Integer;
  LSrcRow  : PByte;
  LDstRow  : PByte;
  LOvRow   : PByte;
  LStride  : Integer;
  LOvPix   : PByte;
  LDstPix  : PByte;
  LSrcPix  : PByte;
begin
  { Always copy input to output first }
  if (AIn.map[0].data <> nil) and (AOut.map[0].data <> nil)
    and (AIn.map[0].size > 0) then
    Move(AIn.map[0].data^, AOut.map[0].data^, AIn.map[0].size);

  LStride := AInfo.stride[0];

  FLockOverlay.Acquire;
  try
    if not FEnabled or (FOverlay = nil) then
    begin
      Result := True;
      Exit;
    end;

    { Blend overlay onto output: skip black pixels (they are transparent) }
    for LRow := 0 to AInfo.height - 1 do
    begin
      LSrcRow := PByte(AIn.data[0])  + LRow * LStride;
      LDstRow := PByte(AOut.data[0]) + LRow * LStride;
      LOvRow  := FOverlay.ScanLine[LRow];

      for var LCol := 0 to AInfo.width - 1 do
      begin
        LOvPix  := LOvRow  + LCol * 4;
        LDstPix := LDstRow + LCol * 4;
        LSrcPix := LSrcRow + LCol * 4;

        { BGRx overlay: [0]=B [1]=G [2]=R [3]=x
          TBitmap pf32bit: [0]=B [1]=G [2]=R [3]=A (unused here)
          Skip black pixels - treat as transparent }
        if (LOvPix[0] = 0) and (LOvPix[1] = 0) and (LOvPix[2] = 0) then
          { transparent - copy source unchanged }
          PCardinal(LDstPix)^ := PCardinal(LSrcPix)^
        else
        begin
          { opaque overlay pixel - write directly }
          LDstPix[0] := LOvPix[0];  { B }
          LDstPix[1] := LOvPix[1];  { G }
          LDstPix[2] := LOvPix[2];  { R }
          LDstPix[3] := LSrcPix[3]; { x - preserve }
        end;
      end;
    end;
  finally
    FLockOverlay.Release;
  end;

  Result := True;
end;

{------------------------------------------------------------------------------
  TForm1
------------------------------------------------------------------------------}

procedure TForm1.FormCreate(Sender: TObject);
begin
  FGStreamer := TGstFramework.Create(True);
  FGStreamer.StringsLogger := logger.Lines;

  if not FGStreamer.Started then
  begin
    LogWriteln('GStreamer failed to start');
    Exit;
  end;

  if not FGStreamer.NewPipeline('txtf1') then
  begin
    LogWriteln('Failed to create pipeline');
    Exit;
  end;

  FGStreamer.MakeElements(
    'videotestsrc name=src !' +
    'd3d11videosink name=video_sink async=false !' +
    'videoconvert name=vconv');

  FFilter := TTextOverlayFilter.Create(FGStreamer);

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
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FSrc);
  FreeAndNil(FFilter);
  FreeAndNil(FGStreamer);
end;

procedure TForm1.UpdateOverlay;
begin
  if Assigned(FFilter) then
    FFilter.RenderOverlay(Edit1.Text, ToggleSwitch1.State = tssOn);
end;

procedure TForm1.RadioButtonClick(Sender: TObject);
begin
  if FSrc <> nil then
    FSrc.SetPropertyEnum('pattern', (Sender as TRadioButton).Tag);
end;

procedure TForm1.ToggleSwitch1Click(Sender: TObject);
begin
  UpdateOverlay;
end;

procedure TForm1.Edit1Change(Sender: TObject);
begin
  UpdateOverlay;
end;

end.

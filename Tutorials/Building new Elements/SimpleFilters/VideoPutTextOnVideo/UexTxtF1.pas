unit UexTxtF1;

{------------------------------------------------------------------------------
  PG2DExampleTextFilter
  Demonstrates a text overlay filter using TGstVideoSimpleFilter.

  Pipeline (logical):
    videotestsrc pattern=N --> TTextOverlayFilter --> d3d11videosink

  Pipeline (actual GStreamer elements):
    videotestsrc --> TGstVideoSimpleFilter bin --> d3d11videosink

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
    FFilter    : TG2DVideoFilterRef;
    FSrc       : TGstElementRef;
    FLockOverlay: TCriticalSection;
    FOverlay   : TBitmap;
    FText      : string;
    FEnabled   : Boolean;
    function FilterGetSinkCaps(Sender: TObject): string;
    function FilterProcessFrame(Sender: TObject; const AIn: GstVideoFrame;
      const AInfo: GstVideoInfo; var AOut: GstVideoFrame): Boolean;
    procedure RenderOverlay(const AText: string; AEnabled: Boolean);
    procedure UpdateOverlay;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.RenderOverlay(const AText: string;
  AEnabled: Boolean);
var
  LBmp    : TBitmap;
  LWidth  : Integer;
  LHeight : Integer;
begin
  { Snapshot video dimensions - HasVideoInfo may be false before first frame }
  if not Assigned(FFilter) or not FFilter.HasVideoInfo then
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

  LWidth  := FFilter.VideoInfo.width;
  LHeight := FFilter.VideoInfo.height;

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

function TForm1.FilterGetSinkCaps(Sender: TObject): string;
begin
  Result := 'video/x-raw,format=BGRx';
end;

function TForm1.FilterProcessFrame(Sender: TObject; const AIn: GstVideoFrame;
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
  LNeedRebuild: Boolean;
  LCurrentText: string;
  LCurrentEnabled: Boolean;
begin
  { Always copy input to output first }
  if (AIn.map[0].data <> nil) and (AOut.map[0].data <> nil)
    and (AIn.map[0].size > 0) then
    Move(AIn.map[0].data^, AOut.map[0].data^, AIn.map[0].size);

  LStride := AInfo.stride[0];
  LNeedRebuild := False;

  FLockOverlay.Acquire;
  try
    LCurrentText := FText;
    LCurrentEnabled := FEnabled;
    if (FOverlay = nil) or (FOverlay.Width <> AInfo.width) or
       (FOverlay.Height <> AInfo.height) then
      LNeedRebuild := True;

    if not FEnabled or (FOverlay = nil) then
    begin
      { Let the lazy rebuild happen below if dimensions just became known. }
    end;
  finally
    FLockOverlay.Release;
  end;

  if LNeedRebuild then
    RenderOverlay(LCurrentText, LCurrentEnabled);

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
  LogWriteln(FGStreamer.Version);
  LogWriteln('Example of simple filter of Text over video');

  FLockOverlay := TCriticalSection.Create;
  FOverlay     := nil;
  FText        := '';
  FEnabled     := False;

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

  UpdateOverlay;
  FGStreamer.SetVisualWindow('video_sink', VideoPanel.Handle);
  if not FGStreamer.Play then
    LogWriteln('Failed to set pipeline to PLAYING');
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FSrc);
  if Assigned(FFilter) then
  begin
    FFilter.OnProcessFrame := nil;
    FFilter.OnGetSinkCaps  := nil;
    FFilter.Shutdown;
  end;
  FFilter := nil;
  if Assigned(FLockOverlay) then
  begin
    FLockOverlay.Acquire;
    try
      FreeAndNil(FOverlay);
    finally
      FLockOverlay.Release;
    end;
  end;
  FreeAndNil(FLockOverlay);
  FreeAndNil(FGStreamer);
end;

procedure TForm1.UpdateOverlay;
begin
  if Assigned(FFilter) then
    RenderOverlay(Edit1.Text, ToggleSwitch1.State = tssOn);
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

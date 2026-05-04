unit URealTxtF1;

{------------------------------------------------------------------------------
  PG2DRealVideoTextFilter
  Demonstrates a text overlay filter using TGstVideoSimpleFilter on top of a real
  decoded video source.

  Pipeline (logical):
    ocean.mp4 --> decode --> TTextOverlayFilter --> d3d11videosink

  Pipeline (actual GStreamer elements):
    uridecodebin --> TGstVideoSimpleFilter bin --> d3d11videosink

  The important difference from the videotestsrc example is that the filter now
  sits behind a real decoder path, so the pads negotiate actual decoded caps.
------------------------------------------------------------------------------}

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.SyncObjs,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.WinXCtrls, Vcl.Graphics, Vcl.ComCtrls,
  G2D.Gst.Types,
  G2D.GstFramework,
  G2D.GstElement.DOO,
  G2D.CustomSimpleVideoElement;

type
  TTextOverlayFilter = class(TGstVideoSimpleFilter)
  private
    FLockOverlay : TCriticalSection;
    FOverlay     : TBitmap;
    FText        : string;
    FEnabled     : Boolean;
  protected
    function GetSinkCaps: string; override;
    procedure OnVideoInfoChanged(const AInfo: GstVideoInfo); override;
    function ProcessFrame(const AIn: GstVideoFrame;
      const AInfo: GstVideoInfo;
      var AOut: GstVideoFrame): Boolean; override;
  public
    constructor Create(AFramework: TGstFramework);
    destructor Destroy; override;
    procedure RenderOverlay(const AText: string; AEnabled: Boolean);
  end;

  TForm1 = class(TForm)
    PanelMain: TPanel;
    Splitter1: TSplitter;
    PanelLeft: TPanel;
    PanelInfo: TPanel;
    Label1: TLabel;
    RichEdit1: TRichEdit;
    Splitter2: TSplitter;
    PanelLog: TPanel;
    Label2: TLabel;
    logger: TRichEdit;
    PanelRight: TPanel;
    PanelTop: TPanel;
    Label3: TLabel;
    Edit1: TEdit;
    ToggleSwitch1: TToggleSwitch;
    VideoPanel: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ToggleSwitch1Click(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
  private
    FGStreamer : TGstFramework;
    FFilter    : TTextOverlayFilter;
    function BuildOceanURI: string;
    procedure UpdateOverlay;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

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
  RenderOverlay(FText, FEnabled);
end;

procedure TTextOverlayFilter.RenderOverlay(const AText: string;
  AEnabled: Boolean);
var
  LBmp    : TBitmap;
  LWidth  : Integer;
  LHeight : Integer;
begin
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
    LBmp.Canvas.Brush.Color := clBlack;
    LBmp.Canvas.FillRect(Rect(0, 0, LWidth, LHeight));

    if AEnabled and (AText <> '') then
    begin
      LBmp.Canvas.Font.Name  := 'Arial';
      LBmp.Canvas.Font.Size  := 18;
      LBmp.Canvas.Font.Style := [fsBold];
      LBmp.Canvas.Font.Color := clWhite;
      LBmp.Canvas.Brush.Style := bsClear;
      LBmp.Canvas.TextOut(10, LHeight - 36, AText);
    end;

    FLockOverlay.Acquire;
    try
      FText    := AText;
      FEnabled := AEnabled;
      FreeAndNil(FOverlay);
      FOverlay := LBmp;
      LBmp     := nil;
    finally
      FLockOverlay.Release;
    end;
  finally
    LBmp.Free;
  end;
end;

function TTextOverlayFilter.ProcessFrame(const AIn: GstVideoFrame;
  const AInfo: GstVideoInfo; var AOut: GstVideoFrame): Boolean;
var
  LRow    : Integer;
  LSrcRow : PByte;
  LDstRow : PByte;
  LOvRow  : PByte;
  LStride : Integer;
  LOvPix  : PByte;
  LDstPix : PByte;
  LSrcPix : PByte;
  LCol    : Integer;
begin
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

    for LRow := 0 to AInfo.height - 1 do
    begin
      LSrcRow := PByte(AIn.data[0])  + LRow * LStride;
      LDstRow := PByte(AOut.data[0]) + LRow * LStride;
      LOvRow  := FOverlay.ScanLine[LRow];

      for LCol := 0 to AInfo.width - 1 do
      begin
        LOvPix  := LOvRow  + LCol * 4;
        LDstPix := LDstRow + LCol * 4;
        LSrcPix := LSrcRow + LCol * 4;

        if (LOvPix[0] = 0) and (LOvPix[1] = 0) and (LOvPix[2] = 0) then
          PCardinal(LDstPix)^ := PCardinal(LSrcPix)^
        else
        begin
          LDstPix[0] := LOvPix[0];
          LDstPix[1] := LOvPix[1];
          LDstPix[2] := LOvPix[2];
          LDstPix[3] := LSrcPix[3];
        end;
      end;
    end;
  finally
    FLockOverlay.Release;
  end;

  Result := True;
end;

function TForm1.BuildOceanURI: string;
const
  COceanPath = 'C:\Users\ido\Documents\Embarcadero\Projects\G2Dver3\Tutorials\MediaFiles\ocean.mp4';
begin
  if FileExists(COceanPath) then
    Result := 'file:///' + StringReplace(COceanPath, '\', '/', [rfReplaceAll])
  else
    Result := '';
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  LOceanURI: string;
begin
  FGStreamer := TGstFramework.Create(True);
  FGStreamer.StringsLogger := logger.Lines;
  LogWriteln(FGStreamer.Version);
  LogWriteln('Example RealVideoPutTextOnVideo');

  if not FGStreamer.Started then
  begin
    LogWriteln('GStreamer failed to start');
    Exit;
  end;

  LOceanURI := BuildOceanURI;
  if LOceanURI = '' then
  begin
    LogWriteln('Failed to locate Tutorials\\MediaFiles\\ocean.mp4');
    Exit;
  end;

  if not FGStreamer.NewPipeline('realtxtf1') then
  begin
    LogWriteln('Failed to create pipeline');
    Exit;
  end;

  FGStreamer.PipeLine.MakeElements(
    'uridecodebin name=src !' +
    'd3d11videosink name=video_sink async=false');

  FGStreamer.SetElementPropertyString('src', 'uri', LOceanURI);

  FFilter := TTextOverlayFilter.Create(FGStreamer);
  FGStreamer.AddElements(['src', 'video_sink']);
  FFilter.AddToPipeline;

  if not FGStreamer.LinkElements(FFilter.BinName, 'video_sink') then
  begin
    LogWriteln('Failed to link filter -> video_sink');
    Exit;
  end;

  if not FGStreamer.ConnectDynamicPad('src', FFilter.BinName, 'sink') then
  begin
    LogWriteln('Failed to connect dynamic decode pad');
    Exit;
  end;

  UpdateOverlay;
  FGStreamer.SetVisualWindow('video_sink', VideoPanel.Handle);

  if not FGStreamer.Play then
    LogWriteln('Failed to set pipeline to PLAYING');
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if Assigned(FFilter) then
  begin
    FFilter.Shutdown;
    FreeAndNil(FFilter);
  end;
  if Assigned(FGStreamer) then
    FGStreamer.Close;
  FreeAndNil(FGStreamer);
end;

procedure TForm1.UpdateOverlay;
begin
  if Assigned(FFilter) then
    FFilter.RenderOverlay(Edit1.Text, ToggleSwitch1.State = tssOn);
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

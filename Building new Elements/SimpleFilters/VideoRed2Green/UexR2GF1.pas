unit UexR2GF1;

{------------------------------------------------------------------------------
  PG2DExampleR2GFilter
  Demonstrates a real pixel-manipulation filter using G2DVideoFilter.

  Pipeline (logical):
    videotestsrc pattern=N --> G2DVideoFilter --> d3d11videosink

  Pipeline (actual GStreamer elements):
    videotestsrc --> G2DVideoFilter bin --> d3d11videosink

  Filter: replaces fully-saturated red pixels (R=255, G=0, B=0) with green
  (R=0, G=255, B=0). Format is pinned to BGRx so the byte layout is known.

  Use the radio buttons to change the videotestsrc pattern while running.
  Pattern 0 (SMPTE colour bars) is a good test - it contains a pure red bar.
------------------------------------------------------------------------------}

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.ComCtrls,
  G2D.Gst.Types,
  G2D.GstFramework,
  G2D.GstElement.DOO,
  G2D.CustomSimpleVideoElement, Vcl.WinXCtrls;

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
    Panel1       : TPanel;
    Splitter1    : TSplitter;
    Panel2       : TPanel;
    Splitter2    : TSplitter;
    Panel3       : TPanel;
    Label2       : TLabel;
    logger       : TRichEdit;
    ToggleSwitch1: TToggleSwitch;
    Label3: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure RadioButtonClick(Sender: TObject);
  private
    FGStreamer : TGstFramework;
    FFilter   : TG2DVideoFilterRef;
    FSrc      : TGstElementRef;
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
  { Pin to BGRx so ProcessFrame knows the exact byte layout:
    byte 0=B, 1=G, 2=R, 3=x (padding). }
  Result := 'video/x-raw,format=BGRx';
end;

function TForm1.FilterProcessFrame(Sender: TObject; const AIn: GstVideoFrame;
  const AInfo: GstVideoInfo; var AOut: GstVideoFrame): Boolean;
var
  LRow        : Integer;
  LCol        : Integer;
  LSrcRow     : PByte;
  LDstRow     : PByte;
  LSrcPix     : PByte;
  LDstPix     : PByte;
  LStride     : Integer;
begin
  LStride := AInfo.stride[0];  { bytes per row including any padding }

  for LRow := 0 to AInfo.height - 1 do
  begin
    LSrcRow := PByte(AIn.data[0])  + LRow * LStride;
    LDstRow := PByte(AOut.data[0]) + LRow * LStride;

    for LCol := 0 to AInfo.width - 1 do
    begin
      LSrcPix := LSrcRow + LCol * 4;
      LDstPix := LDstRow + LCol * 4;

      { BGRx: [0]=B [1]=G [2]=R [3]=x }
      if (LSrcPix[2] = 255) and   { R = 255 }
         (LSrcPix[1] = 0)   and   { G = 0   }
         (LSrcPix[0] = 0)   then  { B = 0   }
      begin
        If Form1.ToggleSwitch1.State=tssOn then
          begin
          { Replace with pure green }
          LDstPix[0] := 0;          { B }
          LDstPix[1] := 255;        { G }
          LDstPix[2] := 0;          { R }
          LDstPix[3] := LSrcPix[3]; { x - preserve padding byte }
          end
          else  PCardinal(LDstPix)^ := PCardinal(LSrcPix)^; //Copy pixel unchanged
      end
      else
      begin
        { Copy pixel unchanged }
        PCardinal(LDstPix)^ := PCardinal(LSrcPix)^;
      end;
    end;
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
  LogWriteln('Example of simple filter Switch pure Red 2 Green');

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
  FreeAndNil(FGStreamer);
end;

procedure TForm1.RadioButtonClick(Sender: TObject);
begin
  if FSrc <> nil then
    FSrc.SetPropertyEnum('pattern', (Sender as TRadioButton).Tag);
end;

end.

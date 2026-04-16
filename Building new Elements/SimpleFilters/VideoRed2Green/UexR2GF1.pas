unit UexR2GF1;

{------------------------------------------------------------------------------
  PG2DExampleR2GFilter
  Demonstrates a real pixel-manipulation filter using TGstVideoSimple.

  Pipeline (logical):
    videotestsrc pattern=N --> TRedToGreenFilter --> d3d11videosink

  Pipeline (actual GStreamer elements):
    videotestsrc --> appsink --> [ProcessFrame] --> appsrc --> videoconvert --> d3d11videosink

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
  TRedToGreenFilter
  Replaces fully-saturated red pixels with green in BGRx format.
  BGRx byte order: [0]=B [1]=G [2]=R [3]=x (padding, ignored)
------------------------------------------------------------------------------}
  TRedToGreenFilter = class(TGstVideoSimple)
  protected
    function GetSinkCaps: string; override;
    function ProcessFrame(const AIn: GstVideoFrame;
      const AInfo: GstVideoInfo;
      var AOut: GstVideoFrame): Boolean; override;
  end;

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
    FFilter   : TRedToGreenFilter;
    FSrc      : TGstElementRef;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

{------------------------------------------------------------------------------
  TRedToGreenFilter
------------------------------------------------------------------------------}

function TRedToGreenFilter.GetSinkCaps: string;
begin
  { Pin to BGRx so ProcessFrame knows the exact byte layout:
    byte 0=B, 1=G, 2=R, 3=x (padding). }
  Result := 'video/x-raw,format=BGRx';
end;

function TRedToGreenFilter.ProcessFrame(const AIn: GstVideoFrame;
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

  if not FGStreamer.Started then
  begin
    LogWriteln('GStreamer failed to start');
    Exit;
  end;

  if not FGStreamer.NewPipeline('r2gf1') then
  begin
    LogWriteln('Failed to create pipeline');
    Exit;
  end;

  FGStreamer.MakeElements(
    'videotestsrc name=src !' +
    'd3d11videosink name=video_sink async=false !' +
    'videoconvert name=vconv');

  FFilter := TRedToGreenFilter.Create(FGStreamer);

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

procedure TForm1.RadioButtonClick(Sender: TObject);
begin
  if FSrc <> nil then
    FSrc.SetPropertyEnum('pattern', (Sender as TRadioButton).Tag);
end;

end.

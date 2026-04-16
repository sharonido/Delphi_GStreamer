unit Uex2;

interface
{$APPTYPE CONSOLE} //use the console for loging events

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  G2D.GstFramework, G2D.GstElement.DOO,
  Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    VideoPanel: TPanel;
    Label1: TLabel;
    GroupBox1: TGroupBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    RadioButton5: TRadioButton;
    RadioButton6: TRadioButton;
    RadioButton7: TRadioButton;
    RadioButton8: TRadioButton;
    RadioButton9: TRadioButton;
    RadioButton10: TRadioButton;
    procedure FormCreate(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    GStreamer:TGstFrameWork;
  end;

var
  Form1: TForm1;
  Src: TGstElementRef;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
GStreamer:=TGstFrameWork.Create(true); //no parameters needed here
  if GStreamer.Started then
    //build a video test src and a video sink and link them together
    if not GStreamer.BuildAndPlay(
    'videotestsrc pattern=0 name=src ! d3d11videosink name=video_sink')
    //autovideosink can't be set at SetVisualWindow
      then writeln('error in the program (BuildAndPlay function)')
      //set the Form1.VideoPanel(vcl TPanel) as a render pallet for the video sink
      else if not GStreamer.SetVisualWindow('video_sink',VideoPanel.Handle)
      then writeln('error in the program (SetVisualWindow function)');
      Src := GStreamer.FindElement('src');
      If Src=nil
      then writeln('error in the program (FindElement function)');
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
GStreamer.Free;
end;

procedure TForm1.RadioButton1Click(Sender: TObject);
begin
Src.SetPropertyEnum('pattern', (Sender as TRadioButton).Tag);
end;
end.

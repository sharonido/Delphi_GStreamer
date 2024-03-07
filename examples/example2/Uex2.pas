unit Uex2;

interface
{$APPTYPE CONSOLE} //use the console for loging events

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  G2D,
  G2DCallDll,
  G2DTypes;

type
  TForm1 = class(TForm)
    VideoPanel: TPanel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    GStreamer:TGstFrameWork;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
GStreamer:=TGstFrameWork.Create(0,nil); //no parameters needed here
  if GStreamer.Started then
    //build a video test src and a video sink and link them together
    if not GStreamer.SimpleBuildLink('videotestsrc pattern=0 ! d3d11videosink name=video_sink')
      then writeln('error in the prog')
      else
      begin
      //set the Form1.VideoPanel(vcl TPanel) as a render pallet for the video sink
      GStreamer.SetVisualWindow('video_sink',VideoPanel);
      //Start playing
      GStreamer.PipeLine.ChangeState(GST_STATE_PLAYING);
      end;
end;

end.

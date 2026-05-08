program G2DEx2FMX;

uses
  System.StartUpCopy,
  FMX.Forms,
  G2D.API.Loader in '..\..\..\G_API\G2D.API.Loader.pas',
  G2D.Glib.Types in '..\..\..\G_Types\G2D.Glib.Types.pas',
  G2D.Glib.API in '..\..\..\G_API\G2D.Glib.API.pas',
  G2D.Gobject.Types in '..\..\..\G_Types\G2D.Gobject.Types.pas',
  G2D.Gobject.API in '..\..\..\G_API\G2D.Gobject.API.pas',
  G2D.Gst.Types in '..\..\..\G_Types\G2D.Gst.Types.pas',
  G2D.Gst.API in '..\..\..\G_API\G2D.Gst.API.pas',
  G2D.Gobject.DOO in '..\..\..\G_DBase\G2D.Gobject.DOO.pas',
  G2D.GstBin.DOO in '..\..\..\G_DBase\G2D.GstBin.DOO.pas',
  G2D.GstBus.DOO in '..\..\..\G_DBase\G2D.GstBus.DOO.pas',
  G2D.GstElement.DOO in '..\..\..\G_DBase\G2D.GstElement.DOO.pas',
  G2D.GstMessage.DOO in '..\..\..\G_DBase\G2D.GstMessage.DOO.pas',
  G2D.GstObject.DOO in '..\..\..\G_DBase\G2D.GstObject.DOO.pas',
  G2D.GstPad.DOO in '..\..\..\G_DBase\G2D.GstPad.DOO.pas',
  G2D.GstPipeline.DOO in '..\..\..\G_DBase\G2D.GstPipeline.DOO.pas',
  G2D.GstFramework in '..\..\..\G_DUnits\G2D.GstFramework.pas',
  G2D.Gst.Android.Bootstrap in '..\..\..\G_DBase\G2D.Gst.Android.Bootstrap.pas',
  G2D.Gst.Android.Surface in '..\..\..\G_DBase\G2D.Gst.Android.Surface.pas',
  UFMXEx2 in 'UFMXEx2.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

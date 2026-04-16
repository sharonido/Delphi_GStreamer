program PG2DExTextFilter;
//{$APPTYPE CONSOLE} //use the console for loging events
uses
  Vcl.Forms,
  UexTxtF1 in 'UexTxtF1.pas' {Form1},
  G2D.GstFramework in '..\..\..\G_DUnits\G2D.GstFramework.pas',
  G2D.Glib.API in '..\..\..\G_API\G2D.Glib.API.pas',
  G2D.Gobject.API in '..\..\..\G_API\G2D.Gobject.API.pas',
  G2D.Gst.API in '..\..\..\G_API\G2D.Gst.API.pas',
  G2D.Gobject.DOO in '..\..\..\G_DBase\G2D.Gobject.DOO.pas',
  G2D.GstBin.DOO in '..\..\..\G_DBase\G2D.GstBin.DOO.pas',
  G2D.GstBus.DOO in '..\..\..\G_DBase\G2D.GstBus.DOO.pas',
  G2D.GstElement.DOO in '..\..\..\G_DBase\G2D.GstElement.DOO.pas',
  G2D.GstMessage.DOO in '..\..\..\G_DBase\G2D.GstMessage.DOO.pas',
  G2D.GstObject.DOO in '..\..\..\G_DBase\G2D.GstObject.DOO.pas',
  G2D.GstPad.DOO in '..\..\..\G_DBase\G2D.GstPad.DOO.pas',
  G2D.GstPipeline.DOO in '..\..\..\G_DBase\G2D.GstPipeline.DOO.pas',
  G2D.Glib.Types in '..\..\..\G_Types\G2D.Glib.Types.pas',
  G2D.Gobject.Types in '..\..\..\G_Types\G2D.Gobject.Types.pas',
  G2D.Gst.Types in '..\..\..\G_Types\G2D.Gst.Types.pas',
  WinConsoleFunction in '..\..\WinConsoleFunction.pas',
  G2D.GstApp.DOO in '..\..\..\G_DBase\G2D.GstApp.DOO.pas',
  G2D.CustomSimpleBaseElement in '..\..\..\G_DUnits\G2D.CustomSimpleBaseElement.pas',
  G2D.CustomSimpleVideoElement in '..\..\..\G_DUnits\G2D.CustomSimpleVideoElement.pas';

//{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

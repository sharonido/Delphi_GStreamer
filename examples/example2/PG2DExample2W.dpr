program PG2DExample2W;
{$APPTYPE CONSOLE} //use the console for loging events

uses
  Vcl.Forms,
  Uex2 in 'Uex2.pas' {Form1},
  G2D in '..\..\Delphi\G2D.pas',
  G2DCallDll in '..\..\Delphi\G2DCallDll.pas',
  G2DTypes in '..\..\Delphi\G2DTypes.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

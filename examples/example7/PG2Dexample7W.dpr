program PG2Dexample7W;

uses
  Vcl.Forms,
  Uex7W in 'Uex7W.pas' {Form1},
  UTrackBarFrame in '..\test\UTrackBarFrame.pas' {FTrack: TFrame},
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

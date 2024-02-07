program PExample5a;

//{$APPTYPE CONSOLE}

uses
  Vcl.Forms,
  Uvcl in 'Uvcl.pas' {FormVideoWin},
  G2D in '..\..\Delphi\G2D.pas',
  G2DCallDll in '..\..\Delphi\G2DCallDll.pas',
  G2DTypes in '..\..\Delphi\G2DTypes.pas',
  UFPlayPauseBtn in '..\..\Delphi\UFPlayPauseBtn.pas' {FPlayPauseBtns: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormVideoWin, FormVideoWin);
  Application.Run;
end.

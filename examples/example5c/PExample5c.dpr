program PExample5c;

uses
  Vcl.Forms,
  G2D in '..\..\Delphi\G2D.pas',
  G2DCallDll in '..\..\Delphi\G2DCallDll.pas',
  G2DTypes in '..\..\Delphi\G2DTypes.pas',
  UFPlayPauseBtn in '..\..\Delphi\UFPlayPauseBtn.pas' {FPlayPauseBtns: TFrame},
  Uvcl5c in 'Uvcl5c.pas' {FormVideoWin},
  WinConsoleFunction in '..\..\Delphi\WinConsoleFunction.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormVideoWin, FormVideoWin);
  Application.Run;
end.

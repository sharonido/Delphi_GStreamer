unit UAndroidInitSmoke;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Layouts,
  FMX.Memo,
  FMX.StdCtrls,
  FMX.Types,
  G2D.GstFramework;

type
  TAndroidInitSmokeForm = class(TForm)
  private
    FGStreamer: TGstFramework;
    FMemo: TMemo;
    procedure AddLog(const AText: string);
    procedure RunSmokeTest;
  protected
    procedure DoShow; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  AndroidInitSmokeForm: TAndroidInitSmokeForm;

implementation

{$IF Defined(ANDROID)}
uses
  Androidapi.Log;
{$ENDIF}

procedure AndroidLog(const AText: string);
begin
{$IF Defined(ANDROID)}
  LOGI(MarshaledAString(UTF8String('G2D Android init smoke: ' + AText)));
{$ENDIF}
end;

constructor TAndroidInitSmokeForm.Create(AOwner: TComponent);
var
  LHeader: TLabel;
  LLayout: TVertScrollBox;
begin
  inherited;

  Caption := 'G2D Android init smoke';

  LLayout := TVertScrollBox.Create(Self);
  LLayout.Parent := Self;
  LLayout.Align := TAlignLayout.Client;
  LLayout.Padding.Rect := TRectF.Create(16, 16, 16, 16);

  LHeader := TLabel.Create(Self);
  LHeader.Parent := LLayout;
  LHeader.Align := TAlignLayout.Top;
  LHeader.Height := 36;
  LHeader.Text := 'GStreamer init smoke';
  LHeader.StyledSettings := LHeader.StyledSettings - [TStyledSetting.Size];
  LHeader.TextSettings.Font.Size := 18;

  FMemo := TMemo.Create(Self);
  FMemo.Parent := LLayout;
  FMemo.Align := TAlignLayout.Client;
  FMemo.ReadOnly := True;
  FMemo.WordWrap := True;
end;

destructor TAndroidInitSmokeForm.Destroy;
begin
  FreeAndNil(FGStreamer);
  inherited;
end;

procedure TAndroidInitSmokeForm.AddLog(const AText: string);
begin
  FMemo.Lines.Add(AText);
  AndroidLog(AText);
end;

procedure TAndroidInitSmokeForm.DoShow;
begin
  inherited;
  if FGStreamer = nil then
    RunSmokeTest;
end;

procedure TAndroidInitSmokeForm.RunSmokeTest;
begin
  AddLog('Starting TGstFramework...');
  try
    FGStreamer := TGstFramework.Create;
    AddLog('GStreamer initialized');
    AddLog('Version: ' + FGStreamer.Version);
  except
    on E: Exception do
      AddLog('ERROR: ' + E.ClassName + ': ' + E.Message);
  end;
end;

end.

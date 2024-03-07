object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Example 2. Render video on a VCL window '
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object VideoPanel: TPanel
    Left = 0
    Top = 0
    Width = 624
    Height = 441
    Align = alClient
    Caption = 'VideoPanel'
    TabOrder = 0
    ExplicitLeft = 200
    ExplicitTop = 160
    ExplicitWidth = 185
    ExplicitHeight = 41
  end
end

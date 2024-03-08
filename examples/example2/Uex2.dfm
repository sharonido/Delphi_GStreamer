object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Example 2. Render video on a VCL window '
  ClientHeight = 451
  ClientWidth = 696
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object Label1: TLabel
    Left = 0
    Top = 0
    Width = 696
    Height = 15
    Align = alTop
    AutoSize = False
    Caption = 'The video bellow is rendered on a Delphi (Pascal) VCL TPanel'
    ExplicitLeft = 184
    ExplicitTop = 48
    ExplicitWidth = 34
  end
  object VideoPanel: TPanel
    Left = 0
    Top = 15
    Width = 585
    Height = 436
    Align = alClient
    Caption = 'VideoPanel'
    TabOrder = 0
    ExplicitWidth = 583
    ExplicitHeight = 425
  end
  object GroupBox1: TGroupBox
    Left = 585
    Top = 15
    Width = 111
    Height = 436
    Align = alRight
    Caption = 'Choose Pattern'
    TabOrder = 1
    ExplicitLeft = 616
    object RadioButton1: TRadioButton
      Left = 6
      Top = 32
      Width = 113
      Height = 17
      Caption = 'Test pattern'
      Checked = True
      TabOrder = 0
      TabStop = True
      OnClick = RadioButton1Click
    end
    object RadioButton2: TRadioButton
      Tag = 1
      Left = 6
      Top = 55
      Width = 113
      Height = 17
      Caption = 'White noise'
      TabOrder = 1
      OnClick = RadioButton1Click
    end
    object RadioButton3: TRadioButton
      Tag = 2
      Left = 6
      Top = 78
      Width = 113
      Height = 17
      Caption = 'Black'
      TabOrder = 2
      OnClick = RadioButton1Click
    end
    object RadioButton4: TRadioButton
      Tag = 3
      Left = 6
      Top = 101
      Width = 113
      Height = 17
      Caption = 'White'
      TabOrder = 3
      OnClick = RadioButton1Click
    end
    object RadioButton5: TRadioButton
      Tag = 4
      Left = 6
      Top = 124
      Width = 113
      Height = 17
      Caption = 'Red'
      TabOrder = 4
      OnClick = RadioButton1Click
    end
    object RadioButton6: TRadioButton
      Tag = 5
      Left = 6
      Top = 147
      Width = 113
      Height = 17
      Caption = 'Green'
      TabOrder = 5
      OnClick = RadioButton1Click
    end
    object RadioButton7: TRadioButton
      Tag = 6
      Left = 6
      Top = 170
      Width = 113
      Height = 17
      Caption = 'Blue'
      TabOrder = 6
      OnClick = RadioButton1Click
    end
    object RadioButton8: TRadioButton
      Tag = 11
      Left = 6
      Top = 193
      Width = 113
      Height = 17
      Caption = 'Circles '
      TabOrder = 7
      OnClick = RadioButton1Click
    end
    object RadioButton9: TRadioButton
      Tag = 22
      Left = 6
      Top = 216
      Width = 113
      Height = 17
      Caption = 'White sun'
      TabOrder = 8
      OnClick = RadioButton1Click
    end
    object RadioButton10: TRadioButton
      Tag = 18
      Left = 6
      Top = 239
      Width = 113
      Height = 17
      Caption = 'Moving ball'
      TabOrder = 9
      OnClick = RadioButton1Click
    end
  end
end

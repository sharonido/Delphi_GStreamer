object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Example simple filter that changes Red to Green'
  ClientHeight = 451
  ClientWidth = 835
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object Splitter1: TSplitter
    Left = 185
    Top = 0
    Height = 451
    ExplicitLeft = 160
    ExplicitTop = 224
    ExplicitHeight = 100
  end
  object VideoPanel: TPanel
    Left = 188
    Top = 0
    Width = 536
    Height = 451
    Align = alClient
    Caption = 'VideoPanel'
    TabOrder = 0
  end
  object GroupBox1: TGroupBox
    Left = 724
    Top = 0
    Width = 111
    Height = 451
    Align = alRight
    Caption = 'Choose Pattern'
    TabOrder = 1
    object Label3: TLabel
      Left = 16
      Top = 299
      Width = 26
      Height = 15
      Caption = 'Filter'
    end
    object RadioButton1: TRadioButton
      Left = 6
      Top = 32
      Width = 113
      Height = 17
      Caption = 'Test pattern'
      Checked = True
      TabOrder = 0
      TabStop = True
      OnClick = RadioButtonClick
    end
    object RadioButton2: TRadioButton
      Tag = 1
      Left = 6
      Top = 55
      Width = 113
      Height = 17
      Caption = 'White noise'
      TabOrder = 1
      OnClick = RadioButtonClick
    end
    object RadioButton3: TRadioButton
      Tag = 2
      Left = 6
      Top = 78
      Width = 113
      Height = 17
      Caption = 'Black'
      TabOrder = 2
      OnClick = RadioButtonClick
    end
    object RadioButton4: TRadioButton
      Tag = 3
      Left = 6
      Top = 101
      Width = 113
      Height = 17
      Caption = 'White'
      TabOrder = 3
      OnClick = RadioButtonClick
    end
    object RadioButton5: TRadioButton
      Tag = 4
      Left = 6
      Top = 124
      Width = 113
      Height = 17
      Caption = 'Red'
      TabOrder = 4
      OnClick = RadioButtonClick
    end
    object RadioButton6: TRadioButton
      Tag = 5
      Left = 6
      Top = 147
      Width = 113
      Height = 17
      Caption = 'Green'
      TabOrder = 5
      OnClick = RadioButtonClick
    end
    object RadioButton7: TRadioButton
      Tag = 6
      Left = 6
      Top = 170
      Width = 113
      Height = 17
      Caption = 'Blue'
      TabOrder = 6
      OnClick = RadioButtonClick
    end
    object RadioButton8: TRadioButton
      Tag = 11
      Left = 6
      Top = 193
      Width = 113
      Height = 17
      Caption = 'Circles '
      TabOrder = 7
      OnClick = RadioButtonClick
    end
    object RadioButton9: TRadioButton
      Tag = 22
      Left = 6
      Top = 216
      Width = 113
      Height = 17
      Caption = 'White sun'
      TabOrder = 8
      OnClick = RadioButtonClick
    end
    object RadioButton10: TRadioButton
      Tag = 18
      Left = 6
      Top = 239
      Width = 113
      Height = 17
      Caption = 'Moving ball'
      TabOrder = 9
      OnClick = RadioButtonClick
    end
    object ToggleSwitch1: TToggleSwitch
      Left = 16
      Top = 320
      Width = 73
      Height = 20
      TabOrder = 10
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 185
    Height = 451
    Align = alLeft
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 2
    object Splitter2: TSplitter
      Left = 1
      Top = 210
      Width = 183
      Height = 3
      Cursor = crVSplit
      Align = alTop
      ExplicitTop = 187
      ExplicitWidth = 263
    end
    object Panel2: TPanel
      Left = 1
      Top = 1
      Width = 183
      Height = 209
      Align = alTop
      Caption = 'Panel2'
      TabOrder = 0
      object Label1: TLabel
        Left = 1
        Top = 1
        Width = 181
        Height = 15
        Align = alTop
        Caption = 'What we have here'
        ExplicitWidth = 100
      end
      object RichEdit1: TRichEdit
        Left = 1
        Top = 16
        Width = 181
        Height = 192
        Align = alClient
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        Lines.Strings = (
          'This is part of G2D GStreamer to delphi project'
          'You can build a GStreamer Element in 2 ways:'
          '1. a sample element'
          '2. a full element with a plugin'
          'Here we build a simple filter.'
          'When filter switch - on right panel'
          'is on the pixels that are pure red'
          'will become pure green.'
          'In test pattern you will see red strip becomes green.'
          'In full red pattern you will see red becomes green')
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssBoth
        TabOrder = 0
        WordWrap = False
      end
    end
    object Panel3: TPanel
      Left = 1
      Top = 213
      Width = 183
      Height = 237
      Align = alClient
      Caption = 'Panel3'
      ShowCaption = False
      TabOrder = 1
      object Label2: TLabel
        Left = 1
        Top = 1
        Width = 181
        Height = 15
        Align = alTop
        Caption = 'GStreamer Log'
        ExplicitWidth = 78
      end
      object logger: TRichEdit
        Left = 1
        Top = 16
        Width = 181
        Height = 220
        Align = alClient
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        TabOrder = 0
        WordWrap = False
      end
    end
  end
end

object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Tutorial 6: Media Formats and Pad Capabilities'
  ClientHeight = 600
  ClientWidth = 800
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 305
    Top = 41
    Width = 5
    Height = 559
    ExplicitLeft = 0
    ExplicitHeight = 800
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 800
    Height = 41
    Align = alTop
    TabOrder = 0
    object Panel5: TPanel
      Left = 1
      Top = 1
      Width = 798
      Height = 39
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      object Label3: TLabel
        AlignWithMargins = True
        Left = 10
        Top = 3
        Width = 74
        Height = 33
        Margins.Left = 10
        Align = alLeft
        Caption = 'Select Element:'
        Layout = tlCenter
        ExplicitHeight = 13
      end
      object ComboElements: TComboBox
        AlignWithMargins = True
        Left = 90
        Top = 8
        Width = 698
        Height = 21
        Margins.Top = 8
        Margins.Right = 10
        Margins.Bottom = 10
        Align = alClient
        Style = csDropDownList
        TabOrder = 0
        OnChange = ComboElementsChange
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 41
    Width = 305
    Height = 559
    Align = alLeft
    TabOrder = 1
    object Panel3: TPanel
      Left = 1
      Top = 1
      Width = 303
      Height = 24
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object Label1: TLabel
        AlignWithMargins = True
        Left = 10
        Top = 3
        Width = 290
        Height = 18
        Margins.Left = 10
        Align = alClient
        Caption = 'What'#39's new in this tutorial:'
        Layout = tlCenter
        ExplicitWidth = 128
        ExplicitHeight = 13
      end
    end
    object REInstructions: TRichEdit
      Left = 1
      Top = 25
      Width = 303
      Height = 533
      Align = alClient
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      Lines.Strings = (
        'Tutorial 6:'
        'Media Formats and Pad Capabilities'
        ''
        'This tutorial shows how to inspect '
        'GStreamer elements:'
        #8226' Select an element from the dropdown list'
        #8226' View its pad templates and capabilities'#39');'
        ' See how capabilities are negotiated during state changes'
        ''
        'The logger on the right shows:'
        '  - Pad templates (static capabilities)'
        '  - Actual negotiated capabilities per state'
        ''
        ' Select an element to begin inspection.')
      ParentFont = False
      ReadOnly = True
      ScrollBars = ssBoth
      TabOrder = 1
      WordWrap = False
    end
  end
  object Panel4: TPanel
    Left = 310
    Top = 41
    Width = 490
    Height = 559
    Align = alClient
    TabOrder = 2
    object Label2: TLabel
      Left = 1
      Top = 1
      Width = 488
      Height = 13
      Align = alTop
      Caption = '  Logger Output:'
      ExplicitWidth = 80
    end
    object Logger: TRichEdit
      Left = 1
      Top = 14
      Width = 488
      Height = 544
      Align = alClient
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 0
    end
  end
end

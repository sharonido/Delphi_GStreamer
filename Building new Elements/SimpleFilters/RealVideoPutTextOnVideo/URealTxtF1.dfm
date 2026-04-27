object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Real Video Put Text On Video'
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
  object PanelMain: TPanel
    Left = 0
    Top = 0
    Width = 835
    Height = 451
    Align = alClient
    Caption = 'PanelMain'
    ShowCaption = False
    TabOrder = 0
    object Splitter1: TSplitter
      Left = 185
      Top = 1
      Height = 449
      ExplicitLeft = 160
      ExplicitTop = 224
      ExplicitHeight = 100
    end
    object PanelLeft: TPanel
      Left = 1
      Top = 1
      Width = 184
      Height = 449
      Align = alLeft
      Caption = 'PanelLeft'
      ShowCaption = False
      TabOrder = 0
      object Splitter2: TSplitter
        Left = 1
        Top = 210
        Width = 182
        Height = 3
        Cursor = crVSplit
        Align = alTop
        ExplicitTop = 187
        ExplicitWidth = 263
      end
      object PanelInfo: TPanel
        Left = 1
        Top = 1
        Width = 182
        Height = 209
        Align = alTop
        Caption = 'PanelInfo'
        TabOrder = 0
        object Label1: TLabel
          Left = 1
          Top = 1
          Width = 180
          Height = 15
          Align = alTop
          Caption = 'What we have here'
          ExplicitWidth = 100
        end
        object RichEdit1: TRichEdit
          Left = 1
          Top = 16
          Width = 180
          Height = 192
          Align = alClient
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          Lines.Strings = (
            'This example is part of G2D GStreamer to Delphi.'
            'It is based on the text overlay video filter example,'
            'but instead of videotestsrc it uses a real file source:'
            'Tutorials\\MediaFiles\\ocean.mp4'
            ''
            'The goal is to let the pads negotiate real decoded video'
            'caps before the Delphi filter sees the frames.'
            ''
            'Type text on the right and use the switch to enable or'
            'disable the overlay.')
          ParentFont = False
          ReadOnly = True
          ScrollBars = ssBoth
          TabOrder = 0
          WordWrap = False
        end
      end
      object PanelLog: TPanel
        Left = 1
        Top = 213
        Width = 182
        Height = 235
        Align = alClient
        Caption = 'PanelLog'
        ShowCaption = False
        TabOrder = 1
        object Label2: TLabel
          Left = 1
          Top = 1
          Width = 78
          Height = 15
          Align = alTop
          Caption = 'GStreamer Log'
        end
        object logger: TRichEdit
          Left = 1
          Top = 16
          Width = 180
          Height = 218
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
    object PanelRight: TPanel
      Left = 188
      Top = 1
      Width = 646
      Height = 449
      Align = alClient
      Caption = 'PanelRight'
      ShowCaption = False
      TabOrder = 1
      object PanelTop: TPanel
        Left = 1
        Top = 1
        Width = 644
        Height = 41
        Align = alTop
        Caption = 'PanelTop'
        ShowCaption = False
        TabOrder = 0
        object Label3: TLabel
          Left = 240
          Top = 13
          Width = 26
          Height = 15
          Caption = 'Filter'
        end
        object Edit1: TEdit
          Left = 9
          Top = 10
          Width = 180
          Height = 23
          TabOrder = 0
          Text = 'Hello Real Video World'
          OnChange = Edit1Change
        end
        object ToggleSwitch1: TToggleSwitch
          Left = 280
          Top = 10
          Width = 73
          Height = 20
          State = tssOn
          TabOrder = 1
          OnClick = ToggleSwitch1Click
        end
      end
      object VideoPanel: TPanel
        Left = 1
        Top = 42
        Width = 644
        Height = 406
        Align = alClient
        Caption = 'VideoPanel'
        TabOrder = 1
      end
    end
  end
end

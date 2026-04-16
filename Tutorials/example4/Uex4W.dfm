object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Example 4. Scrolling a video'
  ClientHeight = 574
  ClientWidth = 1114
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
    Left = 209
    Top = 0
    Height = 534
    ExplicitLeft = 104
    ExplicitTop = 320
    ExplicitHeight = 100
  end
  object Panel5: TPanel
    Left = 212
    Top = 0
    Width = 902
    Height = 534
    Align = alClient
    Caption = 'Panel5'
    ShowCaption = False
    TabOrder = 2
    object Label1: TLabel
      Left = 1
      Top = 1
      Width = 900
      Height = 15
      Align = alTop
      AutoSize = False
      Caption = 'The video bellow is rendered on a Delphi (Pascal) VCL TPanel'
      ExplicitLeft = 184
      ExplicitTop = 48
      ExplicitWidth = 34
    end
    object VideoPanel: TPanel
      Left = 1
      Top = 16
      Width = 900
      Height = 517
      Align = alClient
      Caption = 'Wait for video'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -40
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 534
    Width = 1114
    Height = 40
    Align = alBottom
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 0
    object TrackPos: TTrackBar
      AlignWithMargins = True
      Left = 108
      Top = 11
      Width = 909
      Height = 25
      Margins.Top = 10
      Align = alClient
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 0
      ThumbLength = 15
      OnChange = TrackPosChange
    end
    object Panel2: TPanel
      Left = 1020
      Top = 1
      Width = 93
      Height = 38
      Align = alRight
      Caption = 'Panel2'
      ShowCaption = False
      TabOrder = 1
      object Label3: TLabel
        Left = 6
        Top = 5
        Width = 46
        Height = 15
        Caption = 'Position:'
      end
      object LPosition: TLabel
        Left = 6
        Top = 19
        Width = 77
        Height = 15
        Caption = '-:--:--.---'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
      end
    end
    object Panel3: TPanel
      Left = 1
      Top = 1
      Width = 104
      Height = 38
      Align = alLeft
      Caption = 'Panel2'
      ShowCaption = False
      TabOrder = 2
      object Label2: TLabel
        Left = 8
        Top = 5
        Width = 85
        Height = 15
        Caption = 'Video Duriation:'
      end
      object LDuriation: TLabel
        Left = 8
        Top = 19
        Width = 77
        Height = 15
        Caption = '-:--:--.---'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
      end
    end
  end
  object Panel4: TPanel
    Left = 0
    Top = 0
    Width = 209
    Height = 534
    Align = alLeft
    Caption = 'Panel4'
    TabOrder = 1
    object Splitter2: TSplitter
      Left = 1
      Top = 166
      Width = 207
      Height = 3
      Cursor = crVSplit
      Align = alTop
      ExplicitTop = 313
      ExplicitWidth = 292
    end
    object Panel6: TPanel
      Left = 1
      Top = 1
      Width = 207
      Height = 165
      Align = alTop
      Caption = 'Panel6'
      TabOrder = 0
      object Label4: TLabel
        AlignWithMargins = True
        Left = 4
        Top = 7
        Width = 199
        Height = 15
        Margins.Top = 6
        Align = alTop
        Caption = 'What'#39's new in this tutorial:'
        ExplicitWidth = 140
      end
      object REWhatsNew: TRichEdit
        Left = 1
        Top = 25
        Width = 205
        Height = 139
        Align = alClient
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        Lines.Strings = (
          'This tutorial follows tutorial 4 from:'
          
            'https://gstreamer.freedesktop.org/documentation/tutorials/basic/' +
            'index.html?gi-language=c'
          'On top of the basics, it has:'
          '1.The video is in a window'
          '2.The seek duration & position is in a scroll beneath the video'
          '3.The log goes into a log memo')
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssBoth
        TabOrder = 0
        WordWrap = False
      end
    end
    object Panel7: TPanel
      Left = 1
      Top = 169
      Width = 207
      Height = 364
      Align = alClient
      Caption = 'Panel7'
      TabOrder = 1
      object Label5: TLabel
        Left = 1
        Top = 1
        Width = 205
        Height = 15
        Align = alTop
        Caption = 'Logger:'
        ExplicitWidth = 40
      end
      object Logger: TRichEdit
        Left = 1
        Top = 16
        Width = 205
        Height = 347
        Align = alClient
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        ScrollBars = ssBoth
        TabOrder = 0
        WordWrap = False
      end
    end
  end
  object Timer1: TTimer
    Interval = 100
    OnTimer = Timer1Timer
    Left = 200
    Top = 399
  end
end

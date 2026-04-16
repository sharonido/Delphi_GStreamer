object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Example 5W. Play/Pause Button + Load Media File'
  ClientHeight = 572
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
    Left = 225
    Top = 0
    Height = 532
    ExplicitLeft = 104
    ExplicitTop = 320
    ExplicitHeight = 100
  end
  object Panel1: TPanel
    Left = 0
    Top = 532
    Width = 1114
    Height = 40
    Align = alBottom
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 0
    object TrackPos: TTrackBar
      AlignWithMargins = True
      Left = 157
      Top = 11
      Width = 860
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
        Top = 1
        Width = 46
        Height = 15
        Caption = 'Position:'
      end
      object LPosition: TLabel
        Left = 6
        Top = 18
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
      Left = 57
      Top = 1
      Width = 97
      Height = 38
      Align = alLeft
      Caption = 'Panel3'
      ShowCaption = False
      TabOrder = 2
      object Label2: TLabel
        Left = 1
        Top = 1
        Width = 82
        Height = 15
        Caption = 'Video Duration:'
      end
      object LDuriation: TLabel
        Left = 8
        Top = 18
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
    object Panel8: TPanel
      Left = 1
      Top = 1
      Width = 56
      Height = 38
      Align = alLeft
      Caption = 'Panel8'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clAntiquewhite
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      ShowCaption = False
      TabOrder = 3
      object BtnPlayPause: TSpeedButton
        Left = 1
        Top = 1
        Width = 54
        Height = 36
        Align = alClient
        AllowAllUp = True
        GroupIndex = 1
        Down = True
        Caption = #9208
        Flat = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -24
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        OnClick = BtnPlayPauseClick
        ExplicitLeft = 8
        ExplicitTop = 4
        ExplicitWidth = 41
        ExplicitHeight = 30
      end
    end
  end
  object Panel4: TPanel
    Left = 0
    Top = 0
    Width = 225
    Height = 532
    Align = alLeft
    Caption = 'Panel4'
    TabOrder = 1
    object Splitter2: TSplitter
      Left = 1
      Top = 179
      Width = 223
      Height = 3
      Cursor = crVSplit
      Align = alTop
      ExplicitTop = 313
      ExplicitWidth = 292
    end
    object Panel6: TPanel
      Left = 1
      Top = 1
      Width = 223
      Height = 178
      Align = alTop
      Caption = 'Panel6'
      TabOrder = 0
      object Label4: TLabel
        AlignWithMargins = True
        Left = 4
        Top = 7
        Width = 215
        Height = 15
        Margins.Top = 6
        Align = alTop
        Caption = 'What'#39's new in this tutorial:'
        ExplicitWidth = 140
      end
      object REWhatsNew: TRichEdit
        Left = 1
        Top = 25
        Width = 221
        Height = 152
        Align = alClient
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        Lines.Strings = (
          'This tutorial follows tutorial 5 from:'
          
            'https://gstreamer.freedesktop.org/documentation/tutorials/basic/' +
            'index.html?gi-language=c'
          'On top of tutorial 4 (example4W), '
          'it adds:'
          '1. Play/Pause SpeedButton'
          '2. Load any file via file dialog'
          '3. Pre-defined source combo box')
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssBoth
        TabOrder = 0
        WordWrap = False
      end
    end
    object Panel7: TPanel
      Left = 1
      Top = 182
      Width = 223
      Height = 349
      Align = alClient
      Caption = 'Panel7'
      TabOrder = 1
      object Label5: TLabel
        Left = 1
        Top = 1
        Width = 221
        Height = 15
        Align = alTop
        Caption = 'Logger:'
        ExplicitWidth = 40
      end
      object Logger: TRichEdit
        Left = 1
        Top = 16
        Width = 221
        Height = 332
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
  object Panel9: TPanel
    Left = 228
    Top = 0
    Width = 886
    Height = 532
    Align = alClient
    Caption = 'Panel9'
    ShowCaption = False
    TabOrder = 2
    object Panel10: TPanel
      Left = 1
      Top = 1
      Width = 884
      Height = 35
      Align = alTop
      Caption = 'Panel10'
      ShowCaption = False
      TabOrder = 0
      object Label6: TLabel
        AlignWithMargins = True
        Left = 4
        Top = 8
        Width = 74
        Height = 23
        Margins.Top = 7
        Align = alLeft
        Caption = 'Video source: '
        ExplicitHeight = 15
      end
      object BtnLoad: TButton
        Left = 848
        Top = 1
        Width = 55
        Height = 33
        Align = alRight
        Caption = 'Open...'
        TabOrder = 1
        OnClick = BtnLoadClick
      end
      object CbSource: TComboBox
        AlignWithMargins = True
        Left = 85
        Top = 5
        Width = 759
        Height = 23
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Align = alClient
        TabOrder = 0
        OnChange = CbSourceChange
      end
    end
    object Panel5: TPanel
      Left = 1
      Top = 36
      Width = 884
      Height = 495
      Align = alClient
      Caption = 'Panel5'
      ShowCaption = False
      TabOrder = 1
      object Label1: TLabel
        Left = 1
        Top = 1
        Width = 882
        Height = 15
        Align = alTop
        AutoSize = False
        Caption = 'The video below is rendered on a Delphi (Pascal) VCL TPanel'
        ExplicitLeft = 184
        ExplicitTop = 48
        ExplicitWidth = 34
      end
      object VideoPanel: TPanel
        Left = 1
        Top = 16
        Width = 882
        Height = 478
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
  end
  object Timer1: TTimer
    Interval = 100
    OnTimer = Timer1Timer
    Left = 200
    Top = 399
  end
  object OpenDialog1: TOpenDialog
    Filter = 
      'All media files|*.mp4;*.mkv;*.avi;*.mov;*.webm;*.ogv;*.ogg;*.mp3' +
      ';*.wav;*.flac|Video files|*.mp4;*.mkv;*.avi;*.mov;*.webm;*.ogv|A' +
      'udio files|*.ogg;*.mp3;*.wav;*.flac|All files|*.*'
    Title = 'Open media file'
    Left = 941
    Top = 73
  end
end

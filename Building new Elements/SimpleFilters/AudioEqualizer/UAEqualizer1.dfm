object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Example simple Audio Equalizer'
  ClientHeight = 494
  ClientWidth = 728
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object Panel4: TPanel
    Left = 277
    Top = 41
    Width = 451
    Height = 453
    Align = alRight
    Caption = 'Panel4'
    TabOrder = 1
    object Panel5: TPanel
      Left = 1
      Top = 1
      Width = 449
      Height = 145
      Align = alClient
      Caption = 'Panel5'
      ShowCaption = False
      TabOrder = 0
      ExplicitWidth = 392
      ExplicitHeight = 192
    end
    object Panel6: TPanel
      Left = 1
      Top = 146
      Width = 449
      Height = 306
      Align = alBottom
      Caption = 'Panel6'
      ShowCaption = False
      TabOrder = 1
      ExplicitTop = 144
      ExplicitWidth = 505
      object Label3: TLabel
        Left = 1
        Top = 1
        Width = 447
        Height = 15
        Align = alTop
        Alignment = taCenter
        Caption = 'Equalizer '
        ExplicitLeft = 208
        ExplicitTop = 80
        ExplicitWidth = 50
      end
      object Panel8: TPanel
        Left = 1
        Top = 16
        Width = 56
        Height = 289
        Align = alLeft
        BevelInner = bvRaised
        Caption = 'Panel8'
        ShowCaption = False
        TabOrder = 0
        object Label4: TLabel
          Left = 2
          Top = 272
          Width = 52
          Height = 15
          Align = alBottom
          Alignment = taCenter
          Caption = '100Hz'
          ExplicitLeft = 1
          ExplicitTop = 273
          ExplicitWidth = 32
        end
        object Label5: TLabel
          Left = 2
          Top = 2
          Width = 52
          Height = 15
          Align = alTop
          Alignment = taCenter
          Caption = '---dB'
          ExplicitWidth = 29
        end
        object TrackBar1: TTrackBar
          AlignWithMargins = True
          Left = 15
          Top = 20
          Width = 36
          Height = 249
          Margins.Left = 13
          Align = alClient
          Min = -10
          Orientation = trVertical
          TabOrder = 0
          OnChange = TrackBarChange
          ExplicitLeft = 2
          ExplicitTop = 69
          ExplicitWidth = 63
          ExplicitHeight = 203
        end
      end
      object Panel9: TPanel
        Left = 393
        Top = 16
        Width = 56
        Height = 289
        Align = alLeft
        BevelInner = bvRaised
        Caption = 'Panel8'
        ShowCaption = False
        TabOrder = 1
        ExplicitLeft = 0
        ExplicitTop = 17
        ExplicitHeight = 255
        object Label6: TLabel
          Left = 2
          Top = 272
          Width = 52
          Height = 15
          Align = alBottom
          Alignment = taCenter
          Caption = '8K+Hz'
          ExplicitWidth = 35
        end
        object Label7: TLabel
          Left = 2
          Top = 2
          Width = 52
          Height = 15
          Align = alTop
          Alignment = taCenter
          Caption = '---dB'
          ExplicitWidth = 29
        end
        object TrackBar2: TTrackBar
          AlignWithMargins = True
          Left = 15
          Top = 20
          Width = 36
          Height = 249
          Margins.Left = 13
          Align = alClient
          Min = -10
          Orientation = trVertical
          TabOrder = 0
          OnChange = TrackBarChange
        end
      end
      object Panel10: TPanel
        Left = 281
        Top = 16
        Width = 56
        Height = 289
        Align = alLeft
        BevelInner = bvRaised
        Caption = 'Panel8'
        ShowCaption = False
        TabOrder = 2
        ExplicitLeft = 0
        ExplicitTop = 17
        ExplicitHeight = 255
        object Label8: TLabel
          Left = 2
          Top = 272
          Width = 52
          Height = 15
          Align = alBottom
          Alignment = taCenter
          Caption = '4KHz'
          ExplicitWidth = 27
        end
        object Label9: TLabel
          Left = 2
          Top = 2
          Width = 52
          Height = 15
          Align = alTop
          Alignment = taCenter
          Caption = '---dB'
          ExplicitWidth = 29
        end
        object TrackBar3: TTrackBar
          AlignWithMargins = True
          Left = 15
          Top = 20
          Width = 36
          Height = 249
          Margins.Left = 13
          Align = alClient
          Min = -10
          Orientation = trVertical
          TabOrder = 0
          OnChange = TrackBarChange
        end
      end
      object Panel11: TPanel
        Left = 225
        Top = 16
        Width = 56
        Height = 289
        Align = alLeft
        BevelInner = bvRaised
        Caption = 'Panel8'
        ShowCaption = False
        TabOrder = 3
        ExplicitLeft = 0
        ExplicitTop = 17
        ExplicitHeight = 255
        object Label10: TLabel
          Left = 2
          Top = 272
          Width = 52
          Height = 15
          Align = alBottom
          Alignment = taCenter
          Caption = '2KHz'
          ExplicitWidth = 27
        end
        object Label11: TLabel
          Left = 2
          Top = 2
          Width = 52
          Height = 15
          Align = alTop
          Alignment = taCenter
          Caption = '---dB'
          ExplicitWidth = 29
        end
        object TrackBar4: TTrackBar
          AlignWithMargins = True
          Left = 15
          Top = 20
          Width = 36
          Height = 249
          Margins.Left = 13
          Align = alClient
          Min = -10
          Orientation = trVertical
          TabOrder = 0
          OnChange = TrackBarChange
        end
      end
      object Panel12: TPanel
        Left = 169
        Top = 16
        Width = 56
        Height = 289
        Align = alLeft
        BevelInner = bvRaised
        Caption = 'Panel8'
        ShowCaption = False
        TabOrder = 4
        ExplicitLeft = 0
        ExplicitTop = 17
        ExplicitHeight = 255
        object Label12: TLabel
          Left = 2
          Top = 272
          Width = 52
          Height = 15
          Align = alBottom
          Alignment = taCenter
          Caption = '1KHz'
          ExplicitWidth = 27
        end
        object Label13: TLabel
          Left = 2
          Top = 2
          Width = 52
          Height = 15
          Align = alTop
          Alignment = taCenter
          Caption = '---dB'
          ExplicitWidth = 29
        end
        object TrackBar5: TTrackBar
          AlignWithMargins = True
          Left = 15
          Top = 20
          Width = 36
          Height = 249
          Margins.Left = 13
          Align = alClient
          Min = -10
          Orientation = trVertical
          TabOrder = 0
          OnChange = TrackBarChange
        end
      end
      object Panel13: TPanel
        Left = 113
        Top = 16
        Width = 56
        Height = 289
        Align = alLeft
        BevelInner = bvRaised
        Caption = 'Panel8'
        ShowCaption = False
        TabOrder = 5
        ExplicitLeft = 0
        ExplicitTop = 17
        ExplicitHeight = 255
        object Label14: TLabel
          Left = 2
          Top = 272
          Width = 52
          Height = 15
          Align = alBottom
          Alignment = taCenter
          Caption = '500Hz'
          ExplicitWidth = 32
        end
        object Label15: TLabel
          Left = 2
          Top = 2
          Width = 52
          Height = 15
          Align = alTop
          Alignment = taCenter
          Caption = '---dB'
          ExplicitWidth = 29
        end
        object TrackBar6: TTrackBar
          AlignWithMargins = True
          Left = 15
          Top = 20
          Width = 36
          Height = 249
          Margins.Left = 13
          Align = alClient
          Min = -10
          Orientation = trVertical
          TabOrder = 0
          OnChange = TrackBarChange
        end
      end
      object Panel14: TPanel
        Left = 57
        Top = 16
        Width = 56
        Height = 289
        Align = alLeft
        BevelInner = bvRaised
        Caption = 'Panel8'
        ShowCaption = False
        TabOrder = 6
        ExplicitLeft = 0
        ExplicitTop = 17
        ExplicitHeight = 255
        object Label16: TLabel
          Left = 2
          Top = 272
          Width = 52
          Height = 15
          Align = alBottom
          Alignment = taCenter
          Caption = '250Hz'
          ExplicitWidth = 32
        end
        object Label17: TLabel
          Left = 2
          Top = 2
          Width = 52
          Height = 15
          Align = alTop
          Alignment = taCenter
          Caption = '---dB'
          ExplicitWidth = 29
        end
        object TrackBar7: TTrackBar
          AlignWithMargins = True
          Left = 15
          Top = 20
          Width = 36
          Height = 249
          Margins.Left = 13
          Align = alClient
          Min = -10
          Orientation = trVertical
          TabOrder = 0
          OnChange = TrackBarChange
          ExplicitLeft = 16
          ExplicitTop = 17
        end
      end
      object Panel16: TPanel
        Left = 337
        Top = 16
        Width = 56
        Height = 289
        Align = alLeft
        BevelInner = bvRaised
        Caption = 'Panel8'
        ShowCaption = False
        TabOrder = 7
        ExplicitLeft = 0
        ExplicitTop = 17
        ExplicitHeight = 255
        object Label18: TLabel
          Left = 2
          Top = 272
          Width = 52
          Height = 15
          Align = alBottom
          Alignment = taCenter
          Caption = '8KHz'
          ExplicitWidth = 27
        end
        object Label19: TLabel
          Left = 2
          Top = 2
          Width = 52
          Height = 15
          Align = alTop
          Alignment = taCenter
          Caption = '---dB'
          ExplicitWidth = 29
        end
        object TrackBar8: TTrackBar
          AlignWithMargins = True
          Left = 15
          Top = 20
          Width = 36
          Height = 249
          Margins.Left = 13
          Align = alClient
          Min = -10
          Orientation = trVertical
          TabOrder = 0
          OnChange = TrackBarChange
        end
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 41
    Width = 244
    Height = 453
    Align = alClient
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 0
    ExplicitTop = 0
    ExplicitWidth = 185
    ExplicitHeight = 451
    object Splitter2: TSplitter
      Left = 1
      Top = 210
      Width = 242
      Height = 3
      Cursor = crVSplit
      Align = alTop
      ExplicitTop = 187
      ExplicitWidth = 263
    end
    object Panel2: TPanel
      Left = 1
      Top = 1
      Width = 242
      Height = 209
      Align = alTop
      Caption = 'Panel2'
      TabOrder = 0
      ExplicitWidth = 183
      object Label1: TLabel
        Left = 1
        Top = 1
        Width = 240
        Height = 15
        Align = alTop
        Caption = 'What we have here'
        ExplicitWidth = 100
      end
      object RichEdit1: TRichEdit
        Left = 1
        Top = 16
        Width = 240
        Height = 192
        Align = alClient
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        Lines.Strings = (
          'This is part of G2D GStreamer to Delphi (Pascal) project'
          'This is a simple Audio element that is used as an Equalizer'
          'It uses OpenCV so the computation is fast')
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssBoth
        TabOrder = 0
        WordWrap = False
        ExplicitWidth = 187
      end
    end
    object Panel3: TPanel
      Left = 1
      Top = 213
      Width = 242
      Height = 239
      Align = alClient
      Caption = 'Panel3'
      ShowCaption = False
      TabOrder = 1
      ExplicitWidth = 183
      ExplicitHeight = 237
      object logger: TRichEdit
        Left = 1
        Top = 1
        Width = 240
        Height = 237
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
        ExplicitTop = 16
        ExplicitWidth = 181
        ExplicitHeight = 220
      end
    end
  end
  object Panel7: TPanel
    Left = 244
    Top = 41
    Width = 33
    Height = 453
    Align = alRight
    Caption = 'Panel7'
    ShowCaption = False
    TabOrder = 2
    ExplicitLeft = 256
    ExplicitTop = 232
    ExplicitHeight = 41
  end
  object Panel15: TPanel
    Left = 0
    Top = 0
    Width = 728
    Height = 41
    Align = alTop
    Caption = 'Panel15'
    ShowCaption = False
    TabOrder = 3
    ExplicitLeft = 9
    ExplicitTop = 9
    ExplicitWidth = 398
    DesignSize = (
      728
      41)
    object Label2: TLabel
      Left = 584
      Top = 12
      Width = 50
      Height = 15
      Anchors = [akTop, akRight]
      Caption = 'Equalizer:'
    end
    object LabeledEdit1: TLabeledEdit
      Left = 48
      Top = 12
      Width = 361
      Height = 23
      EditLabel.Width = 39
      EditLabel.Height = 23
      EditLabel.Caption = 'Source:'
      LabelPosition = lpLeft
      TabOrder = 0
      Text = ''
    end
    object Button1: TButton
      Left = 415
      Top = 10
      Width = 57
      Height = 25
      Caption = 'Browse'
      TabOrder = 1
      OnClick = Button1Click
    end
    object ToggleSwitch1: TToggleSwitch
      Left = 640
      Top = 10
      Width = 73
      Height = 20
      Anchors = [akTop, akRight]
      State = tssOn
      TabOrder = 2
      OnClick = ToggleSwitch1Click
    end
    object Button2: TButton
      Left = 478
      Top = 11
      Width = 51
      Height = 25
      Caption = 'Play'
      TabOrder = 3
      OnClick = Button2Click
    end
  end
end

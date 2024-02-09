object FormVideoWin: TFormVideoWin
  Left = 0
  Top = 0
  Caption = 'Example 5b Video window'
  ClientHeight = 507
  ClientWidth = 995
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object Splitter1: TSplitter
    Left = 305
    Top = 41
    Width = 6
    Height = 466
    ExplicitHeight = 470
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 995
    Height = 41
    Align = alTop
    BevelOuter = bvLowered
    Caption = 'Panel1'
    Color = 14803425
    ParentBackground = False
    ShowCaption = False
    TabOrder = 0
    object Label1: TLabel
      Left = 35
      Top = 13
      Width = 39
      Height = 15
      Caption = 'Source:'
    end
    object CBSrc: TComboBox
      Left = 80
      Top = 10
      Width = 553
      Height = 23
      TabOrder = 0
      Text = 
        'https://www.freedesktop.org/software/gstreamer-sdk/data/media/si' +
        'ntel_trailer-480p.webm'
      OnChange = CBSrcChange
      Items.Strings = (
        
          'https://www.freedesktop.org/software/gstreamer-sdk/data/media/si' +
          'ntel_trailer-480p.webm'
        'C:\temp\demo5.mp4')
    end
    object BLoad: TBitBtn
      Left = 639
      Top = 3
      Width = 35
      Height = 33
      Glyph.Data = {
        6A080000424D6A0800000000000036000000280000001C000000190000000100
        18000000000034080000C40E0000C40E00000000000000000000FFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF271E062E2A152E2A152E2B162E2B16
        D7AA37E6B53AE6B53AE6B53AE6B53A2E2B162E2B162E2B162E2B162E2B162E2B
        162E2B16E6B53AE6B53AE6B53AB793312E2B162E2B162E2B162C2813271C04FF
        FFFFFFFFFF506A648FE0F68FE0F693E7FF93E7FFDFB94AE6B53AE6B53AE6B53A
        E6B53A93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FFE6B53AE6B53AE6B5
        3AD1C26B93E7FF93E7FF93E7FF87D2E53B4233FFFFFFFFFFFF506A648FE0F68F
        E0F693E7FF93E7FFDFB94AE6B53AE6B53AE6B53AE6B53A93E7FF93E7FF93E7FF
        93E7FF93E7FF93E7FF93E7FFE6B53AE6B53AE6B53AD1C26B93E7FF93E7FF93E7
        FF87D2E53B4233FFFFFFFFFFFF6EA3AA93E7FF93E7FF93E7FF93E7FFDFB94AE6
        B53AE6B53AE6B53AE6B53A93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF
        E6B53AE6B53AE6B53AD1C26B93E7FF93E7FF93E7FF93E7FF4A5E56FFFFFFFFFF
        FF4A5E5693E7FF93E7FF93E7FF93E7FFDFB94AE6B53AE6B53AE6B53AE6B53A93
        E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FFE6B53AE6B53AE6B53AD1C26B
        93E7FF93E7FF93E7FF93E7FF4A5E56FFFFFFFFFFFF4A5E5693E7FF93E7FF93E7
        FF93E7FFDFB94AE6B53AE6B53AE6B53AE6B53AAFD6BDAFD6BDAFD6BDAFD6BDAF
        D6BDAFD6BDAFD6BDE6B53AE6B53AE6B53AD1C26B93E7FF93E7FF93E7FF93E7FF
        4A5E56FFFFFFFFFFFF4A5E5693E7FF93E7FF93E7FF93E7FFDFB94AE6B53AE6B5
        3AE6B53AE6B53AE6B53AE6B53AE6B53AE6B53AE6B53AE6B53AE6B53AE6B53AE6
        B53AE6B53AD1C26B93E7FF93E7FF93E7FF93E7FF4A5E56FFFFFFFFFFFF4A5E56
        93E7FF93E7FF93E7FF93E7FFDFB94BE6B53AE6B53AE6B53AE6B53AE6B53AE6B5
        3AE6B53AE6B53AE6B53AE6B53AE6B53AE6B53AE6B53AE6B53AD1C26C93E7FF93
        E7FF93E7FF93E7FF4A5E56FFFFFFFFFFFF4A5E5693E7FF93E7FF93E7FF93E7FF
        DFB94BE6B53AE6B53AE6B53AE6B53AE6B53AE6B53AE6B53AE6B53AE6B53AE6B5
        3AE6B53AE6B53AE6B53AE6B53AD1C26C93E7FF93E7FF93E7FF93E7FF4A5E56FF
        FFFFFFFFFF4A5E5693E7FF93E7FF93E7FF93E7FFC8C883E5B63DE6B53AE6B53A
        E6B53AE6B53AE6B53AE6B53AE6B53AE6B53AE6B53AE6B53AE6B53AE6B53AE4B6
        3EBECD9993E7FF93E7FF93E7FF93E7FF4A5E56FFFFFFFFFFFF4A5E5693E7FF93
        E7FF93E7FF93E7FF97E5F7A7DBD0A8DBCEA8DBCEA8DBCEA8DBCEA8DBCEA8DBCE
        A8DBCEA8DBCEA8DBCEA8DBCEA8DBCEA8DBCEA7DBD196E5F893E7FF93E7FF93E7
        FF93E7FF4A5E56FFFFFFFFFFFF4A5E5693E7FF93E7FF93E7FF93E7FF93E7FF93
        E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF
        93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF4A5E56FFFFFFFFFF
        FF4A5E5693E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93
        E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF
        93E7FF93E7FF93E7FF93E7FF4A5E56FFFFFFFFFFFF4A5E5693E7FF93E7FF93E7
        FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93
        E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF
        4A5E56FFFFFFFFFFFF4A5E5693E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7
        FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93
        E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF4A5E56FFFFFFFFFFFF4A5E56
        93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7
        FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93
        E7FF93E7FF93E7FF4A5E56FFFFFFFFFFFF4A5E5693E7FF93E7FF93E7FF93E7FF
        93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7
        FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF4A5E56FF
        FFFFFFFFFF4A5E5693E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF
        93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7
        FF93E7FF93E7FF93E7FF93E7FF93E7FF4A5E56FFFFFFFFFFFF3794A740D1FB40
        D1FB47D0F348D2F848D3FB48D3FB48D3FB41D1FB41D1FB52D6FC83E3FE93E7FF
        93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7FF93E7
        FF90E3FC475B52FFFFFFFFFFFF3794A740D1FB40D1FBAFBE7ABADFD2C0F0FEC0
        F0FEC0F0FE4BD4FB4BD4FB40D1FB4CD2F74A5E564A5E564A5E564A5E564A5E56
        4A5E564A5E564A5E564A5E564A5E564A5E564A5E564A5E562E2B16FFFFFFFFFF
        FF3794A740D1FB40D1FBAFBE7ABADFD2C0F0FEC0F0FEC0F0FE4BD4FB4BD4FB40
        D1FB4CD2F74A5E56FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF2F5B5A3ECAF03ECAF06ACA
        CB6ED6EC70DDFC70DDFC70DDFC44D2FB44D2FB3FCBF1337C87272714FFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFF4A5E564A5E564A5E564A5E564A5E564A5E564A5E564A5E
        564A5E564A5E564A5E564A5E564A5E56FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFF}
      TabOrder = 1
      OnClick = BLoadClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 41
    Width = 305
    Height = 466
    Align = alLeft
    BevelInner = bvRaised
    BevelOuter = bvLowered
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 1
    object Label2: TLabel
      Left = 2
      Top = 2
      Width = 301
      Height = 15
      Align = alTop
      Caption = 'Activity  Log:'
      ExplicitWidth = 69
    end
    object Mlog: TMemo
      Left = 2
      Top = 17
      Width = 301
      Height = 447
      Align = alClient
      Lines.Strings = (
        'This is example 5b.'
        'This program follows tutorial 5 of, '
        'Gsteramer Docs in:'
        
          'https://gstreamer.freedesktop.org/documentation/tutorials/basic/' +
          'toolkit-integration.html?gi-language=c'
        'But uses an object oriented framework of Delphi.'
        '-----------'
        'After working with this example,'
        'you can go to example 5c,'
        'for more of tutorial 5 options.'
        'In this example we added to 5a these topics'
        '1. You can choose a different sources like mp4 files in your pc'
        '2. When stream is loaded you can see its duration'
        '3. You see the position of the stream when playing'
        '4. You can move to a part of the stream you want  '
        '-------------------------------------------'
        '')
      ScrollBars = ssBoth
      TabOrder = 0
    end
  end
  object Panel4: TPanel
    Left = 311
    Top = 41
    Width = 684
    Height = 466
    Align = alClient
    Caption = 'Panel4'
    ShowCaption = False
    TabOrder = 2
    object PanelVideo: TPanel
      Left = 1
      Top = 1
      Width = 682
      Height = 427
      Align = alClient
      BevelOuter = bvNone
      Caption = 'GStreamer did not start yet'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -27
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold, fsItalic]
      ParentFont = False
      TabOrder = 0
      OnClick = PanelVideoClick
    end
    object Panel3: TPanel
      Left = 1
      Top = 428
      Width = 682
      Height = 37
      Align = alBottom
      Caption = 'Panel3'
      ShowCaption = False
      TabOrder = 1
      inline FPlayPauseBtns1: TFPlayPauseBtns
        Left = 1
        Top = 1
        Width = 68
        Height = 35
        Align = alLeft
        TabOrder = 0
        ExplicitLeft = 1
        ExplicitTop = 1
        ExplicitWidth = 68
        ExplicitHeight = 35
        inherited ToolBar1: TToolBar
          Width = 62
          Height = 35
          ExplicitWidth = 62
          ExplicitHeight = 35
        end
      end
      object PanelDuration: TPanel
        Left = 69
        Top = 1
        Width = 612
        Height = 35
        Align = alClient
        Caption = 'PanelDuration'
        ShowCaption = False
        TabOrder = 1
        object Label3: TLabel
          Left = 6
          Top = 11
          Width = 46
          Height = 15
          Caption = 'Position:'
        end
        object LPosition: TLabel
          Left = 55
          Top = 11
          Width = 51
          Height = 19
          AutoSize = False
          Caption = '00:00:00.0'
        end
        object Label4: TLabel
          Left = 475
          Top = 11
          Width = 49
          Height = 15
          Caption = 'Duration:'
        end
        object LDuration: TLabel
          Left = 527
          Top = 11
          Width = 68
          Height = 19
          AutoSize = False
          Caption = '00:00:00.0'
        end
        object PosSlider: TTrackBar
          Left = 112
          Top = 5
          Width = 357
          Height = 29
          Frequency = 2
          TabOrder = 0
          OnChange = PosSliderChange
        end
      end
    end
  end
  object DialogSrc: TOpenDialog
    Filter = 'Mpeg4 Video file|*.mp4|OGG Video File|*.ogg'
    Left = 568
    Top = 8
  end
end

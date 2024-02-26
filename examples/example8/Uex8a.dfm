object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Ex8a '
  ClientHeight = 571
  ClientWidth = 815
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object Splitter1: TSplitter
    Left = 289
    Top = 0
    Width = 7
    Height = 571
    ExplicitLeft = 298
    ExplicitHeight = 441
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 289
    Height = 571
    Align = alLeft
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 0
    object Label1: TLabel
      Left = 1
      Top = 1
      Width = 287
      Height = 15
      Align = alTop
      Caption = 'The console:'
      ExplicitWidth = 66
    end
    object Memo1: TMemo
      Left = 1
      Top = 16
      Width = 287
      Height = 512
      Align = alClient
      Lines.Strings = (
        'This is example8a.'
        'This follows the example8 in GStreamer Docs in:'
        
          'https://gstreamer.freedesktop.org/documentation/tutorials/basic/' +
          'multithreading-and-pad-availability.html?gi-language=c'
        
          'You should open the above URI and look at the graphic explanatio' +
          'ns to understand this program'
        'But works with a windows GUI (not console)'
        '-----------'
        'This program should explain appsrc PlugIns.'
        
          'appsrc is a plugin that can receive a stream from the our applic' +
          'ation.'
        'Receive streams is done by receiveing data buffers.'
        ''
        
          'This program builds on top of example7W that has a pipeline with' +
          ' a T'
        ''
        'This program:'
        
          '1. Build a new caps (Capability exchange)  element to the appsrc' +
          '.'
        '2. The src to the T plugin is an appsrc.'
        '3. We feed the appsrc with a stream of audio buffers.'
        '----------------------------------------'
        '')
      ScrollBars = ssBoth
      TabOrder = 0
    end
    object GroupBox1: TGroupBox
      Left = 1
      Top = 528
      Width = 287
      Height = 42
      Align = alBottom
      Caption = 'Write/Stop'
      TabOrder = 1
      object RBStart: TRadioButton
        Left = 7
        Top = 16
        Width = 76
        Height = 17
        Caption = 'Write log'
        Checked = True
        TabOrder = 0
        TabStop = True
        OnClick = RBStartClick
      end
      object RadioButton2: TRadioButton
        Left = 89
        Top = 16
        Width = 76
        Height = 17
        Caption = 'Stop log'
        TabOrder = 1
        OnClick = RBStartClick
      end
    end
  end
  object Panel2: TPanel
    Left = 296
    Top = 0
    Width = 519
    Height = 571
    Align = alClient
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 1
    object PanelVideo: TPanel
      Left = 1
      Top = 1
      Width = 517
      Height = 527
      Align = alClient
      Caption = 'PanelVideo'
      TabOrder = 0
    end
    object GroupBox2: TGroupBox
      Left = 1
      Top = 528
      Width = 517
      Height = 42
      Align = alBottom
      Caption = 'Signal form'
      TabOrder = 1
      object RBpsych: TRadioButton
        Left = 5
        Top = 16
        Width = 92
        Height = 17
        Caption = 'Psychodelic'
        Checked = True
        TabOrder = 0
        TabStop = True
      end
      object RBSaw: TRadioButton
        Left = 95
        Top = 16
        Width = 50
        Height = 17
        Caption = 'Saw'
        TabOrder = 1
      end
      object RBClear: TRadioButton
        Left = 159
        Top = 16
        Width = 50
        Height = 17
        Caption = 'Clear'
        TabOrder = 2
      end
    end
  end
end

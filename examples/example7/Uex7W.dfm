object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'G2D Example 7W (audio in speakers and on scope)'
  ClientHeight = 457
  ClientWidth = 951
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object Splitter1: TSplitter
    Left = 609
    Top = 0
    Width = 7
    Height = 457
    ExplicitLeft = 298
    ExplicitHeight = 441
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 609
    Height = 457
    Align = alLeft
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 0
    object Label1: TLabel
      Left = 1
      Top = 1
      Width = 607
      Height = 15
      Align = alTop
      Caption = 'The console:'
      ExplicitWidth = 66
    end
    object Memo1: TMemo
      Left = 1
      Top = 16
      Width = 607
      Height = 440
      Align = alClient
      Lines.Strings = (
        'This is example7W.'
        'This follows the example7 in Gsteramer Docs in:'
        
          'https://gstreamer.freedesktop.org/documentation/tutorials/basic/' +
          'multithreading-and-pad-availability.html?gi-language=c'
        
          'You should open the above URI and look at the graphic explanatio' +
          'ns to understand this program'
        'But works with a windows GUI (not console)'
        '-----------'
        'This program:'
        '1.  Takes an Audio src splites it by a tee plugin'
        
          '2.  requests a src pad from the tee and links it to a queue and ' +
          'sends it through'
        '    resample, convertor and a sink plugins to the PC speakers'
        
          '3.  requests another src pad from the tee and links it to anothe' +
          'r queue that is'
        '    linked to a visual plugin, thats turns the audio to a video.'
        
          '4   Then sends the video through a convertor and a sink plugin t' +
          'o the screen'
        '----------------------------------------')
      ScrollBars = ssBoth
      TabOrder = 0
    end
  end
  object Panel2: TPanel
    Left = 616
    Top = 0
    Width = 335
    Height = 457
    Align = alClient
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 1
    ExplicitLeft = 319
    ExplicitWidth = 632
    object Panel3: TPanel
      Left = 1
      Top = 400
      Width = 333
      Height = 56
      Align = alBottom
      Caption = 'Panel1'
      ShowCaption = False
      TabOrder = 0
      ExplicitWidth = 630
      object Label2: TLabel
        Left = 1
        Top = 1
        Width = 116
        Height = 54
        Align = alLeft
        AutoSize = False
        Caption = 'Frequency=800Hz'
        ExplicitLeft = 5
        ExplicitTop = 16
        ExplicitHeight = 15
      end
      object Panel4: TPanel
        Left = 117
        Top = 1
        Width = 215
        Height = 54
        Align = alClient
        Caption = 'Panel4'
        ShowCaption = False
        TabOrder = 0
        ExplicitWidth = 512
        DesignSize = (
          215
          54)
        object Label3: TLabel
          Left = 1
          Top = 3
          Width = 32
          Height = 15
          Caption = '200Hz'
        end
        object Label4: TLabel
          Left = 186
          Top = 3
          Width = 27
          Height = 15
          Anchors = [akTop, akRight]
          Caption = '2KHz'
          ExplicitLeft = 494
        end
        object TrackBar1: TTrackBar
          Left = 1
          Top = 24
          Width = 213
          Height = 29
          Align = alBottom
          Max = 2000
          Min = 200
          Frequency = 200
          Position = 200
          TabOrder = 0
          OnChange = TrackBar1Change
          ExplicitWidth = 510
        end
      end
    end
    object PanelVideo: TPanel
      Left = 1
      Top = 1
      Width = 333
      Height = 399
      Align = alClient
      Caption = 'PanelVideo'
      TabOrder = 1
      ExplicitLeft = -1
      ExplicitTop = -1
    end
  end
end

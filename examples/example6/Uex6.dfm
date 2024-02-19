object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'G2D Ex6 (Audio only) for MS Windows 64bit '
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object Splitter1: TSplitter
    Left = 297
    Top = 0
    Width = 8
    Height = 441
    ExplicitLeft = 185
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 297
    Height = 441
    Align = alLeft
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 0
    object Label1: TLabel
      Left = 1
      Top = 1
      Width = 295
      Height = 15
      Align = alTop
      Caption = 'The console:'
      ExplicitWidth = 66
    end
    object Memo1: TMemo
      Left = 1
      Top = 16
      Width = 295
      Height = 424
      Align = alClient
      Lines.Strings = (
        'This is example6.'
        'This follows the example6 in Gsteramer Docs in:'
        
          'https://gstreamer.freedesktop.org/documentation/tutorials/basic/' +
          'media-formats-and-pad-capabilities.html?gi-language=c'
        'but uses an object oriented framework of Delphi'
        '-----------'
        'In this grogram we'
        
          '1. show (print) the capabilities of a clean(Template) plugin ("a' +
          'udiotestsrc" and "autoaudiosink")'
        '2. shows the sink capabilities in Null/Pending state'
        
          '3. shows the sink parametrs after capabilities exchange in Ready' +
          ', Pause & Play states'
        ''
        '')
      ScrollBars = ssBoth
      TabOrder = 0
    end
  end
  object Panel2: TPanel
    Left = 305
    Top = 0
    Width = 319
    Height = 441
    Align = alClient
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 1
    ExplicitLeft = 370
    ExplicitWidth = 185
    object Label2: TLabel
      Left = 1
      Top = 1
      Width = 317
      Height = 15
      Align = alTop
      Caption = 'The Pad Capability(cap) data:'
      ExplicitWidth = 154
    end
    object Memo2: TMemo
      Left = 1
      Top = 16
      Width = 317
      Height = 424
      Align = alClient
      ScrollBars = ssBoth
      TabOrder = 0
    end
  end
end

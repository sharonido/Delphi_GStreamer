object FormVideoWin: TFormVideoWin
  Left = 0
  Top = 0
  Caption = 'Example 4 Video window'
  ClientHeight = 511
  ClientWidth = 971
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
    Height = 470
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 971
    Height = 41
    Align = alTop
    BevelOuter = bvLowered
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 0
    object Label1: TLabel
      Left = 35
      Top = 15
      Width = 39
      Height = 15
      Caption = 'Source:'
    end
    object ESrc: TEdit
      Left = 80
      Top = 12
      Width = 761
      Height = 23
      ReadOnly = True
      TabOrder = 0
      Text = 
        'https://www.freedesktop.org/software/gstreamer-sdk/data/media/si' +
        'ntel_trailer-480p.webm'
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 41
    Width = 305
    Height = 470
    Align = alLeft
    BevelInner = bvRaised
    BevelOuter = bvLowered
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 1
    object Label2: TLabel
      Left = 5
      Top = 160
      Width = 69
      Height = 15
      Caption = 'Activity  Log:'
    end
    object Mlog: TMemo
      Left = 2
      Top = 181
      Width = 301
      Height = 287
      Align = alBottom
      Lines.Strings = (
        'This is example 5a.'
        'This program follows tutorial 5 of, '
        'Gsteramer Docs in:'
        'https://gstreamer.freedesktop.org/documentation/t'
        'utorials/basic/toolkit-integration.html?gi-'
        'language=c'
        'but uses an object oriented framework of Delphi'
        '-----------'
        'After you understand this 5a prograrm you can '
        'move to example 5b that integrats all of tutorial 5.'
        'This grogram should use FMX so it can be easly '
        'integrated in android ios etc.'
        'but it uses VCL because geting a handle of a TPanel '
        'is much mor simple (In FMX you must embed a '
        'form in the panel)'
        '-----------'
        'This program:'
        '1. starts the gstreamer'
        '2. builds a playbin plugin'
        '3. gives the playbin a hanlde to a panel (PanelVideo)'
        '4 response to the play, pause, stop buttons'
        '-------------------------------------------'
        '')
      ScrollBars = ssVertical
      TabOrder = 0
    end
  end
  object Panel4: TPanel
    Left = 311
    Top = 41
    Width = 660
    Height = 470
    Align = alClient
    Caption = 'Panel4'
    ShowCaption = False
    TabOrder = 2
    ExplicitLeft = 275
    ExplicitWidth = 696
    object PanelVideo: TPanel
      Left = 1
      Top = 1
      Width = 658
      Height = 431
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
      ExplicitWidth = 694
      ExplicitHeight = 417
    end
    object Panel3: TPanel
      Left = 1
      Top = 432
      Width = 658
      Height = 37
      Align = alBottom
      Caption = 'Panel3'
      ShowCaption = False
      TabOrder = 1
      ExplicitWidth = 694
      inline FPlayPauseBtns1: TFPlayPauseBtns
        Left = -1
        Top = 2
        Width = 68
        Height = 45
        TabOrder = 0
        ExplicitLeft = -1
        ExplicitTop = 2
        ExplicitWidth = 68
        ExplicitHeight = 45
        inherited ToolBar1: TToolBar
          Width = 62
          Height = 45
        end
      end
    end
  end
end

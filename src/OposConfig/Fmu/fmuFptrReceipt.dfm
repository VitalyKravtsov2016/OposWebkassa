object fmFptrReceipt: TfmFptrReceipt
  Left = 575
  Top = 228
  AutoScroll = False
  BorderIcons = [biSystemMenu]
  Caption = #1042#1080#1076' '#1095#1077#1082#1072
  ClientHeight = 367
  ClientWidth = 484
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object SynEdit: TSynEdit
    Left = 0
    Top = 0
    Width = 455
    Height = 367
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    TabOrder = 0
    Gutter.Font.Charset = DEFAULT_CHARSET
    Gutter.Font.Color = clWindowText
    Gutter.Font.Height = -11
    Gutter.Font.Name = 'Courier New'
    Gutter.Font.Style = []
    Highlighter = SynXMLSyn
  end
  object ToolBar1: TToolBar
    Left = 455
    Top = 0
    Width = 29
    Height = 367
    Align = alRight
    ButtonHeight = 25
    Caption = 'ToolBar1'
    TabOrder = 1
    object SpeedButton1: TSpeedButton
      Left = 0
      Top = 2
      Width = 27
      Height = 25
    end
  end
  object SynXMLSyn: TSynXMLSyn
    WantBracesParsed = False
    Left = 48
    Top = 32
  end
end

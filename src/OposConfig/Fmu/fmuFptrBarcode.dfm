object fmFptrBarcode: TfmFptrBarcode
  Left = 657
  Top = 345
  AutoScroll = False
  BorderIcons = [biSystemMenu]
  Caption = #1064#1090#1088#1080#1093'-'#1082#1086#1076
  ClientHeight = 239
  ClientWidth = 408
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
  object rgBarcode: TRadioGroup
    Left = 8
    Top = 8
    Width = 393
    Height = 209
    Caption = #1055#1077#1095#1072#1090#1100' '#1096#1090#1088#1080#1093#1082#1086#1076#1086#1074
    TabOrder = 0
  end
  object rbBarcodeESCCommands: TRadioButton
    Left = 40
    Top = 40
    Width = 273
    Height = 17
    Caption = #1055#1077#1095#1072#1090#1100' '#1087#1088#1080' '#1087#1086#1084#1086#1097#1080' ESC '#1082#1086#1084#1072#1085#1076
    TabOrder = 1
    OnClick = ModifiedClick
  end
  object rbBarcodeGraphics: TRadioButton
    Left = 40
    Top = 72
    Width = 281
    Height = 17
    Caption = #1055#1077#1095#1072#1090#1100' '#1090#1086#1083#1100#1082#1086' '#1074' '#1075#1088#1072#1092#1080#1082#1077
    TabOrder = 2
    OnClick = ModifiedClick
  end
  object rbBarcodeText: TRadioButton
    Left = 40
    Top = 104
    Width = 281
    Height = 17
    Caption = #1055#1077#1095#1072#1090#1100' '#1074' '#1074#1080#1076#1077' '#1090#1077#1082#1089#1090#1072
    TabOrder = 3
    OnClick = ModifiedClick
  end
  object rbBarcodeNone: TRadioButton
    Left = 40
    Top = 136
    Width = 281
    Height = 17
    Caption = #1053#1077' '#1087#1077#1095#1072#1090#1072#1090#1100
    TabOrder = 4
    OnClick = ModifiedClick
  end
end

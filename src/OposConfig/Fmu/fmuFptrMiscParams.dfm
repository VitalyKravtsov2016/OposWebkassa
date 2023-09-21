object fmFptrMiscParams: TfmFptrMiscParams
  Left = 623
  Top = 224
  AutoScroll = False
  BorderIcons = [biSystemMenu]
  Caption = #1055#1088#1086#1095#1077#1077
  ClientHeight = 329
  ClientWidth = 536
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    536
    329)
  PixelsPerInch = 96
  TextHeight = 13
  object lblRoundType: TTntLabel
    Left = 8
    Top = 16
    Width = 63
    Height = 13
    Caption = #1054#1082#1088#1091#1075#1083#1077#1085#1080#1077':'
  end
  object lblVATSeries: TTntLabel
    Left = 8
    Top = 48
    Width = 61
    Height = 13
    Caption = #1057#1077#1088#1080#1103' '#1053#1044#1057':'
  end
  object lblVATNumber: TTntLabel
    Left = 8
    Top = 80
    Width = 64
    Height = 13
    Caption = #1053#1086#1084#1077#1088' '#1053#1044#1057':'
  end
  object lblAmountDecimalPlaces: TTntLabel
    Left = 8
    Top = 112
    Width = 248
    Height = 13
    Caption = #1050#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1079#1085#1072#1082#1086#1074' '#1087#1086#1089#1083#1077' '#1079#1072#1087#1103#1090#1086#1081' '#1074' '#1082#1086#1083#1080#1095#1077#1089#1090#1074#1077':'
  end
  object lblCurrencyName: TTntLabel
    Left = 8
    Top = 144
    Width = 95
    Height = 13
    Caption = #1053#1072#1079#1074#1072#1085#1080#1077' '#1074#1072#1083#1102#1090#1099':'
  end
  object cbRoundType: TComboBox
    Left = 96
    Top = 16
    Width = 434
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 0
    OnChange = ModifiedClick
    Items.Strings = (
      #1053#1077#1090
      #1048#1090#1086#1075' '#1095#1077#1082#1072
      #1055#1086#1079#1080#1094#1080#1080' '#1095#1077#1082#1072)
  end
  object edtVATSeries: TEdit
    Left = 96
    Top = 48
    Width = 434
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
    Text = 'edtVATSeries'
    OnChange = ModifiedClick
  end
  object edtVATNumber: TEdit
    Left = 96
    Top = 80
    Width = 434
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 2
    Text = 'edtVATNumber'
    OnChange = ModifiedClick
  end
  object cbAmountDecimalPlaces: TComboBox
    Left = 264
    Top = 112
    Width = 266
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 3
    OnChange = ModifiedClick
    Items.Strings = (
      '0'
      '2')
  end
  object edtCurrencyName: TEdit
    Left = 128
    Top = 144
    Width = 402
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 4
    Text = 'edtCurrencyName'
    OnChange = ModifiedClick
  end
  object chbPrintEnabled: TCheckBox
    Left = 8
    Top = 176
    Width = 233
    Height = 17
    Caption = #1055#1077#1095#1072#1090#1100' '#1085#1072' '#1095#1077#1082#1086#1074#1086#1081' '#1083#1077#1085#1090#1077
    TabOrder = 5
  end
end

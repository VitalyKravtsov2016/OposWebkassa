object fmPrinter: TfmPrinter
  Left = 544
  Top = 218
  Width = 471
  Height = 278
  Caption = #1055#1088#1080#1085#1090#1077#1088
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    455
    239)
  PixelsPerInch = 96
  TextHeight = 13
  object lblDeviceName: TTntLabel
    Left = 8
    Top = 40
    Width = 103
    Height = 13
    Caption = #1053#1072#1079#1074#1072#1085#1080#1077' '#1087#1088#1080#1085#1090#1077#1088#1072':'
  end
  object lblResultCode: TTntLabel
    Left = 8
    Top = 72
    Width = 56
    Height = 13
    Caption = #1056#1077#1079#1082#1083#1100#1090#1072#1090':'
  end
  object lblDeviceType: TTntLabel
    Left = 8
    Top = 8
    Width = 72
    Height = 13
    Caption = #1058#1080#1087' '#1087#1088#1080#1085#1090#1077#1088#1072':'
  end
  object cbDeviceName: TTntComboBox
    Left = 120
    Top = 40
    Width = 329
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 0
  end
  object memResult: TMemo
    Left = 120
    Top = 72
    Width = 329
    Height = 129
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = clBtnFace
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object btnTestConnection: TButton
    Left = 200
    Top = 208
    Width = 121
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1055#1088#1086#1074#1077#1088#1082#1072' '#1089#1074#1103#1079#1080
    TabOrder = 2
    OnClick = btnTestConnectionClick
  end
  object btnPrintReceipt: TButton
    Left = 328
    Top = 208
    Width = 121
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1058#1077#1089#1090#1086#1074#1099#1081' '#1095#1077#1082
    TabOrder = 3
    OnClick = btnPrintReceiptClick
  end
  object cbDeviceType: TTntComboBox
    Left = 118
    Top = 8
    Width = 329
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 4
    OnChange = cbDeviceTypeChange
    Items.Strings = (
      'POS '#1087#1088#1080#1085#1090#1077#1088
      'Windows '#1087#1088#1080#1085#1090#1077#1088)
  end
end

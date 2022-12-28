object fmFptrPayType: TfmFptrPayType
  Left = 757
  Top = 326
  AutoScroll = False
  BorderIcons = [biSystemMenu]
  Caption = #1058#1080#1087#1099' '#1086#1087#1083#1072#1090#1099
  ClientHeight = 224
  ClientWidth = 705
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    705
    224)
  PixelsPerInch = 96
  TextHeight = 13
  object lblPaymentType2: TTntLabel
    Left = 8
    Top = 16
    Width = 71
    Height = 13
    Caption = #1058#1080#1087' '#1086#1087#1083#1072#1090#1099' 2:'
  end
  object lblPaymentType3: TTntLabel
    Left = 8
    Top = 48
    Width = 71
    Height = 13
    Caption = #1058#1080#1087' '#1086#1087#1083#1072#1090#1099' 3:'
  end
  object lblPaymentType4: TTntLabel
    Left = 8
    Top = 80
    Width = 71
    Height = 13
    Caption = #1058#1080#1087' '#1086#1087#1083#1072#1090#1099' 4:'
  end
  object Label1: TLabel
    Left = 8
    Top = 120
    Width = 369
    Height = 39
    Caption = 
      #1042#1085#1080#1084#1072#1085#1080#1077'! '#13#10#1042' '#1088#1072#1084#1082#1072#1093' '#1087#1088#1086#1090#1086#1082#1086#1083#1072' 2.0.2 '#1080' '#1090#1080#1087#1099' '#1086#1087#1083#1072#1090#1099' "'#1090#1072#1088#1072'", '#1080' "'#1082#1088 +
      #1077#1076#1080#1090'" '#1080#1089#1082#1083#1102#1095#1077#1085#1099', '#13#10#1076#1086#1073#1072#1074#1080#1083#1089#1103' '#1085#1086#1074#1099#1081' '#1090#1080#1087' '#1086#1087#1083#1072#1090#1099' "'#1084#1086#1073#1080#1083#1100#1085#1099#1081' '#1087#1083#1072#1090#1077#1078'"' +
      '.'
  end
  object cbPaymentType2: TComboBox
    Left = 96
    Top = 16
    Width = 410
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 0
    OnChange = ModifiedClick
    Items.Strings = (
      #1053#1072#1083#1080#1095#1085#1099#1077
      #1041#1072#1085#1082#1086#1074#1089#1082#1072#1103' '#1082#1072#1088#1090#1072
      #1050#1088#1077#1076#1080#1090
      #1058#1072#1088#1072
      #1052#1086#1073#1080#1083#1100#1085#1099#1077)
  end
  object cbPaymentType3: TComboBox
    Left = 96
    Top = 48
    Width = 410
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 1
    OnChange = ModifiedClick
    Items.Strings = (
      #1053#1072#1083#1080#1095#1085#1099#1077
      #1041#1072#1085#1082#1086#1074#1089#1082#1072#1103' '#1082#1072#1088#1090#1072
      #1050#1088#1077#1076#1080#1090
      #1058#1072#1088#1072
      #1052#1086#1073#1080#1083#1100#1085#1099#1077)
  end
  object cbPaymentType4: TComboBox
    Left = 96
    Top = 80
    Width = 410
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 2
    OnChange = ModifiedClick
    Items.Strings = (
      #1053#1072#1083#1080#1095#1085#1099#1077
      #1041#1072#1085#1082#1086#1074#1089#1082#1072#1103' '#1082#1072#1088#1090#1072
      #1050#1088#1077#1076#1080#1090
      #1058#1072#1088#1072
      #1052#1086#1073#1080#1083#1100#1085#1099#1077)
  end
end

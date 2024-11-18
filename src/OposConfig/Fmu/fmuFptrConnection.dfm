object fmFptrConnection: TfmFptrConnection
  Left = 594
  Top = 238
  Width = 496
  Height = 482
  Caption = #1055#1086#1076#1082#1083#1102#1095#1077#1085#1080#1077
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    480
    443)
  PixelsPerInch = 96
  TextHeight = 13
  object gbConenctionParams: TTntGroupBox
    Left = 8
    Top = 8
    Width = 465
    Height = 321
    Anchors = [akLeft, akTop, akRight]
    Caption = 'WebKassa'
    TabOrder = 0
    DesignSize = (
      465
      321)
    object lblConnectTimeout: TTntLabel
      Left = 16
      Top = 56
      Width = 143
      Height = 13
      Caption = #1058#1072#1081#1084#1072#1091#1090' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103', '#1089#1077#1082'.:'
    end
    object lblWebkassaAddress: TTntLabel
      Left = 125
      Top = 24
      Width = 34
      Height = 13
      Caption = #1040#1076#1088#1077#1089':'
    end
    object lblLogin: TTntLabel
      Left = 125
      Top = 88
      Width = 34
      Height = 13
      Caption = #1051#1086#1075#1080#1085':'
    end
    object lblPassword: TTntLabel
      Left = 118
      Top = 120
      Width = 41
      Height = 13
      Caption = #1055#1072#1088#1086#1083#1100':'
    end
    object lblCashBoxNumber: TTntLabel
      Left = 87
      Top = 184
      Width = 72
      Height = 13
      Caption = #1053#1086#1084#1077#1088' '#1082#1072#1089#1089#1099':'
    end
    object lblResultCode: TTntLabel
      Left = 104
      Top = 248
      Width = 55
      Height = 13
      Caption = #1056#1077#1079#1091#1083#1100#1090#1072#1090':'
    end
    object lblAcceptLanguage: TTntLabel
      Left = 69
      Top = 152
      Width = 84
      Height = 13
      Caption = 'Accept language:'
    end
    object seConnectTimeout: TSpinEdit
      Left = 168
      Top = 56
      Width = 288
      Height = 22
      Anchors = [akLeft, akTop, akRight]
      MaxValue = 0
      MinValue = 0
      TabOrder = 1
      Value = 0
      OnChange = ModifiedClick
    end
    object edtWebkassaAddress: TTntEdit
      Left = 168
      Top = 24
      Width = 289
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      Text = 'edtWebkassaAddress'
      OnChange = ModifiedClick
    end
    object edtLogin: TTntEdit
      Left = 168
      Top = 88
      Width = 289
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 2
      Text = 'edtLogin'
      OnChange = ModifiedClick
    end
    object edtPassword: TTntEdit
      Left = 168
      Top = 120
      Width = 289
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 3
      Text = 'edtPassword'
      OnChange = ModifiedClick
    end
    object btnTestConnection: TTntButton
      Left = 168
      Top = 280
      Width = 145
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1055#1088#1086#1074#1077#1088#1080#1090#1100' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1077
      TabOrder = 7
      OnClick = btnTestConnectionClick
    end
    object cbCashboxNumber: TTntComboBox
      Left = 168
      Top = 184
      Width = 289
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      ItemHeight = 13
      Sorted = True
      TabOrder = 5
      Text = 'cbCashboxNumber'
      OnChange = ModifiedClick
    end
    object btnUpdateCashBoxNumbers: TTntButton
      Left = 320
      Top = 280
      Width = 137
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1055#1088#1086#1095#1080#1090#1072#1090#1100' '#1085#1086#1084#1077#1088#1072' '#1082#1072#1089#1089
      TabOrder = 8
      OnClick = btnUpdateCashBoxNumbersClick
    end
    object edtResultCode: TTntEdit
      Left = 168
      Top = 248
      Width = 290
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Color = clBtnFace
      TabOrder = 6
    end
    object edtAcceptLanguage: TTntEdit
      Left = 168
      Top = 152
      Width = 289
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 4
      Text = 'edtAcceptLanguage'
      OnChange = ModifiedClick
    end
  end
end

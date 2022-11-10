object fmPrinter: TfmPrinter
  Left = 544
  Top = 218
  Width = 471
  Height = 555
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
    517)
  PixelsPerInch = 96
  TextHeight = 13
  object lblPrinterName: TTntLabel
    Left = 8
    Top = 40
    Width = 103
    Height = 13
    Caption = #1053#1072#1079#1074#1072#1085#1080#1077' '#1087#1088#1080#1085#1090#1077#1088#1072':'
  end
  object lblResultCode: TTntLabel
    Left = 16
    Top = 440
    Width = 55
    Height = 13
    Caption = #1056#1077#1079#1091#1083#1100#1090#1072#1090':'
  end
  object lblPrinterType: TTntLabel
    Left = 8
    Top = 8
    Width = 72
    Height = 13
    Caption = #1058#1080#1087' '#1087#1088#1080#1085#1090#1077#1088#1072':'
  end
  object lblFontName: TTntLabel
    Left = 8
    Top = 72
    Width = 87
    Height = 13
    Caption = #1064#1088#1080#1092#1090' '#1087#1088#1080#1085#1090#1077#1088#1072':'
  end
  object cbPrinterName: TTntComboBox
    Left = 120
    Top = 40
    Width = 329
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 1
    OnChange = cbPrinterNameChange
  end
  object memResult: TMemo
    Left = 120
    Top = 440
    Width = 329
    Height = 38
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = clBtnFace
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 3
  end
  object btnTestConnection: TButton
    Left = 240
    Top = 485
    Width = 105
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1055#1088#1086#1074#1077#1088#1082#1072' '#1089#1074#1103#1079#1080
    TabOrder = 4
    OnClick = btnTestConnectionClick
  end
  object btnPrintReceipt: TButton
    Left = 352
    Top = 485
    Width = 97
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1058#1077#1089#1090#1086#1074#1099#1081' '#1095#1077#1082
    TabOrder = 5
    OnClick = btnPrintReceiptClick
  end
  object cbPrinterType: TTntComboBox
    Left = 120
    Top = 8
    Width = 329
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 0
    OnChange = cbPrinterTypeChange
    Items.Strings = (
      'OPOS '#1087#1088#1080#1085#1090#1077#1088
      'Windows '#1087#1088#1080#1085#1090#1077#1088
      'ESC POS '#1087#1088#1080#1085#1090#1077#1088', COM '#1087#1086#1088#1090
      'ESC POS '#1087#1088#1080#1085#1090#1077#1088', '#1089#1077#1090#1077#1074#1086#1077' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1077)
  end
  object cbFontName: TTntComboBox
    Left = 120
    Top = 72
    Width = 329
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 2
  end
  object pnlNetworkConnection: TPanel
    Left = 8
    Top = 101
    Width = 441
    Height = 100
    BevelOuter = bvNone
    TabOrder = 6
    Visible = False
    DesignSize = (
      441
      100)
    object lblRemoteHost: TLabel
      Left = 0
      Top = 0
      Width = 97
      Height = 13
      Caption = #1061#1086#1089#1090':'
    end
    object lblRemotePort: TLabel
      Left = 0
      Top = 32
      Width = 28
      Height = 13
      Caption = #1055#1086#1088#1090':'
    end
    object lblByteTimeout: TLabel
      Left = 0
      Top = 56
      Width = 110
      Height = 13
      Caption = #1058#1072#1081#1084#1072#1091#1090' '#1087#1088#1080#1077#1084#1072', '#1084#1089'.:'
    end
    object edtRemoteHost: TEdit
      Left = 144
      Top = 0
      Width = 297
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      Text = '10.11.7.176'
    end
    object seRemotePort: TSpinEdit
      Left = 144
      Top = 32
      Width = 297
      Height = 22
      Anchors = [akLeft, akTop, akRight]
      MaxValue = 0
      MinValue = 0
      TabOrder = 1
      Value = 0
    end
    object seByteTimeout: TSpinEdit
      Left = 144
      Top = 64
      Width = 297
      Height = 22
      Anchors = [akLeft, akTop, akRight]
      MaxValue = 0
      MinValue = 0
      TabOrder = 2
      Value = 0
    end
  end
end

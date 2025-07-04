object fmPrinter: TfmPrinter
  Left = 975
  Top = 225
  Width = 471
  Height = 502
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
    463)
  PixelsPerInch = 96
  TextHeight = 13
  object lblResultCode: TTntLabel
    Left = 8
    Top = 360
    Width = 55
    Height = 13
    Caption = #1056#1077#1079#1091#1083#1100#1090#1072#1090':'
  end
  object memResult: TTntMemo
    Left = 8
    Top = 376
    Width = 441
    Height = 49
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
  object btnTestConnection: TTntButton
    Left = 240
    Top = 432
    Width = 105
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1055#1088#1086#1074#1077#1088#1082#1072' '#1089#1074#1103#1079#1080
    TabOrder = 2
    OnClick = btnTestConnectionClick
  end
  object btnPrintReceipt: TTntButton
    Left = 352
    Top = 432
    Width = 97
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1058#1077#1089#1090#1086#1074#1099#1081' '#1095#1077#1082
    TabOrder = 3
    OnClick = btnPrintReceiptClick
  end
  object PageControl1: TTntPageControl
    Left = 8
    Top = 8
    Width = 441
    Height = 345
    ActivePage = tsCommonParams
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    object tsCommonParams: TTntTabSheet
      Caption = #1054#1073#1097#1080#1077
      object lblPrinterName: TTntLabel
        Left = 8
        Top = 56
        Width = 103
        Height = 13
        Caption = #1053#1072#1079#1074#1072#1085#1080#1077' '#1087#1088#1080#1085#1090#1077#1088#1072':'
      end
      object lblPrinterType: TTntLabel
        Left = 8
        Top = 24
        Width = 72
        Height = 13
        Caption = #1058#1080#1087' '#1087#1088#1080#1085#1090#1077#1088#1072':'
      end
      object lblFontName: TTntLabel
        Left = 8
        Top = 152
        Width = 87
        Height = 13
        Caption = #1064#1088#1080#1092#1090' '#1087#1088#1080#1085#1090#1077#1088#1072':'
      end
      object lblDevicePollTime: TTntLabel
        Left = 8
        Top = 280
        Width = 103
        Height = 13
        Caption = #1055#1077#1088#1080#1086#1076' '#1086#1087#1088#1086#1089#1072', '#1084#1089'.:'
      end
      object lblLineSpacing: TTntLabel
        Left = 8
        Top = 248
        Width = 124
        Height = 13
        Caption = #1052#1077#1078#1089#1090#1088#1086#1095#1085#1099#1081' '#1080#1085#1090#1077#1088#1074#1072#1083':'
      end
      object lblRecLineChars: TTntLabel
        Left = 8
        Top = 184
        Width = 162
        Height = 13
        Caption = #1050#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1089#1080#1084#1074#1086#1083#1086#1074' '#1074' '#1089#1090#1088#1086#1082#1077':'
      end
      object lblRecLineHeight: TTntLabel
        Left = 8
        Top = 216
        Width = 94
        Height = 13
        Caption = #1042#1099#1089#1086#1090#1072' '#1089#1080#1084#1074#1086#1083#1086#1074':'
      end
      object lblEscPrinterType: TTntLabel
        Left = 8
        Top = 88
        Width = 96
        Height = 13
        Caption = #1058#1080#1087' ESC '#1087#1088#1080#1085#1090#1077#1088#1072':'
      end
      object lblPortType: TTntLabel
        Left = 8
        Top = 120
        Width = 92
        Height = 13
        Caption = #1058#1080#1087' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1103':'
      end
      object cbPrinterName: TTntComboBox
        Left = 120
        Top = 56
        Width = 305
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 1
        OnChange = cbPrinterNameChange
      end
      object cbPrinterType: TTntComboBox
        Left = 120
        Top = 24
        Width = 305
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 0
        OnChange = cbPrinterTypeChange
        Items.Strings = (
          'OPOS '#1076#1088#1072#1081#1074#1077#1088
          'Windows '#1087#1088#1080#1085#1090#1077#1088
          #1059#1087#1088#1072#1074#1083#1077#1085#1080#1077' ESC '#1082#1086#1084#1072#1085#1076#1072#1084#1080)
      end
      object cbFontName: TTntComboBox
        Left = 120
        Top = 152
        Width = 305
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 4
        OnChange = cbFontNameChange
      end
      object seDevicePollTime: TSpinEdit
        Left = 184
        Top = 280
        Width = 241
        Height = 22
        MaxValue = 0
        MinValue = 0
        TabOrder = 8
        Value = 0
        OnClick = ModifiedClick
      end
      object seLineSpacing: TSpinEdit
        Left = 184
        Top = 248
        Width = 241
        Height = 22
        MaxValue = 0
        MinValue = 0
        TabOrder = 7
        Value = 0
        OnClick = ModifiedClick
      end
      object seRecLineChars: TSpinEdit
        Left = 184
        Top = 184
        Width = 241
        Height = 22
        MaxValue = 0
        MinValue = 0
        TabOrder = 5
        Value = 0
        OnClick = ModifiedClick
      end
      object seRecLineHeight: TSpinEdit
        Left = 184
        Top = 216
        Width = 241
        Height = 22
        MaxValue = 0
        MinValue = 0
        TabOrder = 6
        Value = 0
        OnClick = ModifiedClick
      end
      object cbEscPrinterType: TTntComboBox
        Left = 120
        Top = 88
        Width = 305
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 2
        OnChange = cbEscPrinterTypeChange
        Items.Strings = (
          'Rongta'
          'OA-48'
          'Posiflex'
          'XPrinter')
      end
      object cbPortType: TTntComboBox
        Left = 120
        Top = 120
        Width = 305
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 3
        OnChange = cbPrinterNameChange
        Items.Strings = (
          #1055#1086#1089#1083#1077#1076#1086#1074#1072#1090#1077#1083#1100#1085#1099#1081' '#1087#1086#1088#1090
          #1055#1086#1088#1090' '#1087#1088#1080#1085#1090#1077#1088#1072' Windows'
          #1057#1077#1090#1077#1074#1086#1077' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1077
          'USB '#1087#1086#1088#1090)
      end
    end
    object tsSerialParams: TTntTabSheet
      Caption = #1055#1086#1089#1083#1077#1076#1086#1074#1072#1090#1077#1083#1100#1085#1099#1081' '#1087#1086#1088#1090
      ImageIndex = 2
      object lblPortName: TTntLabel
        Left = 8
        Top = 24
        Width = 53
        Height = 13
        Caption = 'COM '#1087#1086#1088#1090':'
      end
      object lblBaudRate: TTntLabel
        Left = 8
        Top = 56
        Width = 51
        Height = 13
        Caption = #1057#1082#1086#1088#1086#1089#1090#1100':'
      end
      object lblDataBits: TTntLabel
        Left = 8
        Top = 88
        Width = 61
        Height = 13
        Caption = #1041#1080#1090' '#1076#1072#1085#1085#1099#1093':'
      end
      object lblStopBits: TTntLabel
        Left = 216
        Top = 24
        Width = 59
        Height = 13
        Caption = #1057#1090#1086#1087'-'#1073#1080#1090#1086#1074':'
      end
      object lblParity: TTntLabel
        Left = 216
        Top = 56
        Width = 51
        Height = 13
        Caption = #1063#1105#1090#1085#1086#1089#1090#1100':'
      end
      object lblFlowControl: TTntLabel
        Left = 216
        Top = 88
        Width = 65
        Height = 13
        Caption = #1059#1087#1088#1072#1074#1083#1077#1085#1080#1077':'
      end
      object Label1: TTntLabel
        Left = 8
        Top = 120
        Width = 69
        Height = 13
        Caption = #1058#1072#1081#1084#1072#1091#1090', '#1084#1089'.:'
      end
      object cbPortName: TTntComboBox
        Left = 88
        Top = 24
        Width = 113
        Height = 21
        Style = csDropDownList
        ItemHeight = 0
        TabOrder = 0
        OnChange = ModifiedClick
      end
      object cbBaudRate: TTntComboBox
        Left = 88
        Top = 56
        Width = 113
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 1
        OnChange = ModifiedClick
        Items.Strings = (
          '2400'
          '4800'
          '9600'
          '19200'
          '38400'
          '57600'
          '115200'
          '230400'
          '460800'
          '921600')
      end
      object cbDataBits: TTntComboBox
        Left = 88
        Top = 88
        Width = 113
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 2
        OnChange = ModifiedClick
        Items.Strings = (
          '8')
      end
      object cbStopBits: TTntComboBox
        Left = 296
        Top = 24
        Width = 113
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 3
        OnChange = ModifiedClick
        Items.Strings = (
          '1'
          '1.5'
          '2')
      end
      object cbParity: TTntComboBox
        Left = 296
        Top = 56
        Width = 113
        Height = 21
        Style = csDropDownList
        ItemHeight = 0
        TabOrder = 4
        OnChange = ModifiedClick
      end
      object cbFlowControl: TTntComboBox
        Left = 296
        Top = 88
        Width = 113
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 5
        OnChange = ModifiedClick
        Items.Strings = (
          'XON / XOFF'
          #1040#1087#1087#1072#1088#1072#1090#1085#1086#1077
          #1053#1077#1090)
      end
      object seSerialTimeout: TSpinEdit
        Left = 88
        Top = 120
        Width = 113
        Height = 22
        MaxValue = 0
        MinValue = 0
        TabOrder = 6
        Value = 0
        OnChange = ModifiedClick
      end
    end
    object tsUSBPort: TTntTabSheet
      Caption = 'USB '#1087#1086#1088#1090
      ImageIndex = 3
      DesignSize = (
        433
        317)
      object TntLabel1: TTntLabel
        Left = 8
        Top = 16
        Width = 63
        Height = 13
        Caption = #1059#1089#1090#1088#1086#1081#1089#1090#1074#1086':'
      end
      object cbUSBPort: TTntComboBox
        Left = 88
        Top = 16
        Width = 329
        Height = 21
        Style = csDropDownList
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 0
        TabOrder = 0
        OnChange = ModifiedClick
      end
      object btnReadUsbDevices: TTntButton
        Left = 160
        Top = 48
        Width = 257
        Height = 33
        Anchors = [akTop, akRight]
        Caption = #1055#1088#1086#1095#1080#1090#1072#1090#1100' '#1089#1087#1080#1089#1086#1082' '#1091#1089#1090#1088#1086#1081#1089#1090#1074
        TabOrder = 1
        OnClick = btnReadUsbDevicesClick
      end
    end
    object tsSocketParams: TTntTabSheet
      Caption = #1057#1077#1090#1077#1074#1086#1077' '#1087#1086#1076#1082#1083#1102#1095#1077#1085#1080#1077
      ImageIndex = 1
      object lblRemoteHost: TTntLabel
        Left = 8
        Top = 16
        Width = 27
        Height = 13
        Caption = #1061#1086#1089#1090':'
      end
      object lblByteTimeout: TTntLabel
        Left = 8
        Top = 80
        Width = 110
        Height = 13
        Caption = #1058#1072#1081#1084#1072#1091#1090' '#1087#1088#1080#1077#1084#1072', '#1084#1089'.:'
      end
      object lblRemotePort: TTntLabel
        Left = 8
        Top = 48
        Width = 28
        Height = 13
        Caption = #1055#1086#1088#1090':'
      end
      object edtRemoteHost: TTntEdit
        Left = 128
        Top = 16
        Width = 137
        Height = 21
        TabOrder = 0
        Text = '10.11.7.176'
        OnChange = ModifiedClick
      end
      object seRemotePort: TSpinEdit
        Left = 128
        Top = 48
        Width = 137
        Height = 22
        MaxValue = 0
        MinValue = 0
        TabOrder = 1
        Value = 0
        OnChange = ModifiedClick
      end
      object seByteTimeout: TSpinEdit
        Left = 128
        Top = 80
        Width = 137
        Height = 22
        MaxValue = 0
        MinValue = 0
        TabOrder = 2
        Value = 0
        OnChange = ModifiedClick
      end
    end
  end
end

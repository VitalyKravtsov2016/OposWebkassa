object fmMain: TfmMain
  Left = 628
  Top = 291
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1055#1088#1086#1075#1088#1072#1084#1084#1072' '#1085#1072#1089#1090#1088#1086#1081#1082#1080' OPOS'
  ClientHeight = 362
  ClientWidth = 484
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    484
    362)
  PixelsPerInch = 96
  TextHeight = 13
  object lblDevices: TTntLabel
    Left = 144
    Top = 8
    Width = 63
    Height = 13
    Caption = #1059#1089#1090#1088#1086#1081#1089#1090#1074#1072':'
  end
  object lblDeviceType: TTntLabel
    Left = 8
    Top = 8
    Width = 82
    Height = 13
    Caption = #1058#1080#1087' '#1091#1089#1090#1088#1086#1081#1089#1090#1074#1072':'
  end
  object Bevel1: TBevel
    Left = 8
    Top = 323
    Width = 472
    Height = 17
    Anchors = [akLeft, akRight, akBottom]
    Shape = bsTopLine
  end
  object lbDevices: TTntListBox
    Left = 144
    Top = 24
    Width = 248
    Height = 292
    Anchors = [akLeft, akTop, akRight, akBottom]
    BiDiMode = bdRightToLeftNoAlign
    ItemHeight = 13
    ParentBiDiMode = False
    TabOrder = 1
    OnClick = lbDevicesClick
    OnDblClick = EditDeviceClick
    OnKeyDown = lbDevicesKeyDown
  end
  object btnAddDevice: TTntBitBtn
    Left = 399
    Top = 88
    Width = 81
    Height = 25
    Anchors = [akTop, akRight]
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100
    TabOrder = 4
    OnClick = btnAddDeviceClick
  end
  object btnDeleteDevice: TTntBitBtn
    Left = 399
    Top = 56
    Width = 81
    Height = 25
    Anchors = [akTop, akRight]
    Caption = #1059#1076#1072#1083#1080#1090#1100
    Enabled = False
    TabOrder = 3
    OnClick = btnDeleteDeviceClick
    NumGlyphs = 2
  end
  object btnEditDevice: TTntBitBtn
    Left = 399
    Top = 24
    Width = 81
    Height = 25
    Anchors = [akTop, akRight]
    Caption = #1048#1079#1084#1077#1085#1080#1090#1100
    Enabled = False
    TabOrder = 2
    OnClick = EditDeviceClick
    NumGlyphs = 2
  end
  object lbDeviceType: TTntListBox
    Left = 8
    Top = 24
    Width = 129
    Height = 292
    Anchors = [akLeft, akTop, akBottom]
    ItemHeight = 13
    Items.Strings = (
      #1060#1080#1089#1082#1072#1083#1100#1085#1099#1081' '#1087#1088#1080#1085#1090#1077#1088
      #1044#1077#1085#1077#1078#1085#1099#1081' '#1103#1097#1080#1082
      'POS '#1087#1088#1080#1085#1090#1077#1088)
    TabOrder = 0
    OnClick = lbDeviceTypeClick
  end
  object btnClose: TTntButton
    Left = 399
    Top = 331
    Width = 81
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = #1047#1072#1082#1088#1099#1090#1100
    TabOrder = 5
    OnClick = btnCloseClick
  end
end

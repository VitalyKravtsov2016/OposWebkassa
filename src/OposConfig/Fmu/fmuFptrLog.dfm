object fmFptrLog: TfmFptrLog
  Left = 536
  Top = 304
  AutoScroll = False
  BorderIcons = [biSystemMenu]
  Caption = #1051#1086#1075
  ClientHeight = 191
  ClientWidth = 417
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    417
    191)
  PixelsPerInch = 96
  TextHeight = 13
  object lblLogFilePath: TTntLabel
    Left = 24
    Top = 40
    Width = 102
    Height = 13
    Caption = #1055#1072#1087#1082#1072' '#1092#1072#1081#1083#1086#1074' '#1083#1086#1075#1072':'
  end
  object lblMaxLogFileCount: TTntLabel
    Left = 24
    Top = 80
    Width = 182
    Height = 13
    Caption = #1052#1072#1082#1089#1080#1084#1072#1083#1100#1085#1086#1077' '#1082#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1092#1072#1081#1083#1086#1074':'
  end
  object Label1: TLabel
    Left = 24
    Top = 104
    Width = 199
    Height = 13
    Caption = '0 - '#1085#1077#1086#1075#1088#1072#1085#1080#1095#1077#1085#1085#1086#1077' '#1082#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1092#1072#1081#1083#1086#1074
  end
  object chbLogEnabled: TTntCheckBox
    Left = 8
    Top = 8
    Width = 97
    Height = 17
    Caption = #1042#1077#1089#1090#1080' '#1083#1086#1075
    TabOrder = 0
    OnClick = ModifiedClick
  end
  object edtLogFilePath: TTntEdit
    Left = 136
    Top = 40
    Width = 273
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
    Text = 'edtLogFilePath'
    OnChange = ModifiedClick
  end
  object seMaxLogFileCount: TSpinEdit
    Left = 216
    Top = 80
    Width = 193
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 2
    Value = 0
    OnChange = ModifiedClick
  end
end

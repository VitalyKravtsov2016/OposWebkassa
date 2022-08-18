object fmDevice: TfmDevice
  Left = 592
  Top = 466
  BorderStyle = bsDialog
  Caption = #1059#1089#1090#1088#1086#1081#1089#1090#1074#1086
  ClientHeight = 87
  ClientWidth = 295
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    295
    87)
  PixelsPerInch = 96
  TextHeight = 13
  object lblDeviceName: TTntLabel
    Left = 8
    Top = 20
    Width = 85
    Height = 13
    Caption = #1048#1084#1103' '#1091#1089#1090#1088#1086#1081#1089#1090#1074#1072':'
  end
  object btnOK: TTntButton
    Left = 136
    Top = 56
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TTntButton
    Left = 216
    Top = 56
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 2
  end
  object edtDeviceName: TTntEdit
    Left = 104
    Top = 16
    Width = 185
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    Text = 'edtDeviceName'
  end
end

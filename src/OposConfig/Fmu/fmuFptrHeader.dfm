object fmFptrHeader: TfmFptrHeader
  Left = 486
  Top = 159
  AutoScroll = False
  BorderIcons = [biSystemMenu]
  Caption = #1047#1072#1075#1086#1083#1086#1074#1086#1082' '#1095#1077#1082#1072
  ClientHeight = 400
  ClientWidth = 573
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
    573
    400)
  PixelsPerInch = 96
  TextHeight = 13
  object lblNumHeaderLines: TTntLabel
    Left = 8
    Top = 16
    Width = 94
    Height = 13
    Caption = #1050#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1089#1090#1088#1086#1082':'
  end
  object symHeader: TSynMemo
    Left = 8
    Top = 48
    Width = 558
    Height = 345
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    TabOrder = 0
    Gutter.DigitCount = 2
    Gutter.Font.Charset = DEFAULT_CHARSET
    Gutter.Font.Color = clWindowText
    Gutter.Font.Height = -11
    Gutter.Font.Name = 'Courier New'
    Gutter.Font.Style = []
    Gutter.LeftOffset = 6
    Gutter.RightOffset = 4
    Gutter.ShowLineNumbers = True
    ScrollBars = ssVertical
    OnChange = ModifiedClick
  end
  object cbNumHeaderLines: TTntComboBox
    Left = 128
    Top = 16
    Width = 438
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 1
    OnChange = ModifiedClick
  end
end

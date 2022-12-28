object fmFptrTrailer: TfmFptrTrailer
  Left = 623
  Top = 374
  AutoScroll = False
  BorderIcons = [biSystemMenu]
  Caption = #1055#1086#1076#1074#1072#1083' '#1095#1077#1082#1072
  ClientHeight = 288
  ClientWidth = 319
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
    319
    288)
  PixelsPerInch = 96
  TextHeight = 13
  object lblNumTrailerLines: TTntLabel
    Left = 8
    Top = 8
    Width = 94
    Height = 13
    Caption = #1050#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1089#1090#1088#1086#1082':'
  end
  object cbNumTrailerLines: TTntComboBox
    Left = 120
    Top = 8
    Width = 193
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 0
    OnChange = ModifiedClick
  end
  object symTrailer: TSynMemo
    Left = 8
    Top = 40
    Width = 305
    Height = 241
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    TabOrder = 1
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
end

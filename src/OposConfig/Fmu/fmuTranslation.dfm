object fmTranslation: TfmTranslation
  Left = 575
  Top = 228
  AutoScroll = False
  BorderIcons = [biSystemMenu]
  Caption = #1057#1086#1086#1073#1097#1077#1085#1080#1103
  ClientHeight = 359
  ClientWidth = 529
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnResize = FormResize
  DesignSize = (
    529
    359)
  PixelsPerInch = 96
  TextHeight = 13
  object StringGrid: TTntStringGrid
    Left = 0
    Top = 0
    Width = 529
    Height = 325
    Anchors = [akLeft, akTop, akRight, akBottom]
    ColCount = 3
    DefaultColWidth = 50
    DefaultRowHeight = 30
    RowCount = 10
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing, goAlwaysShowEditor]
    ParentFont = False
    ScrollBars = ssNone
    TabOrder = 0
  end
  object btnAdd: TTntButton
    Left = 416
    Top = 328
    Width = 105
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100
    TabOrder = 1
    OnClick = btnAddClick
  end
  object chbTranslationEnabled: TCheckBox
    Left = 8
    Top = 336
    Width = 225
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = #1048#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100' '#1087#1077#1088#1077#1074#1086#1076
    TabOrder = 2
  end
end

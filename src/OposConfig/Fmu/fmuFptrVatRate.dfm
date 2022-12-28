object fmFptrVatRate: TfmFptrVatRate
  Left = 663
  Top = 186
  AutoScroll = False
  BorderIcons = [biSystemMenu]
  Caption = #1053#1072#1083#1086#1075#1086#1074#1099#1077' '#1089#1090#1072#1074#1082#1080
  ClientHeight = 250
  ClientWidth = 387
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    387
    250)
  PixelsPerInch = 96
  TextHeight = 13
  object lblVatCode: TTntLabel
    Left = 8
    Top = 16
    Width = 60
    Height = 13
    Caption = #1050#1086#1076' '#1085#1072#1083#1086#1075#1072':'
  end
  object lblVatRate: TTntLabel
    Left = 8
    Top = 48
    Width = 91
    Height = 13
    Caption = #1057#1090#1072#1074#1082#1072' '#1085#1072#1083#1086#1075#1072', %:'
  end
  object TntLabel1: TTntLabel
    Left = 8
    Top = 80
    Width = 91
    Height = 13
    Caption = #1053#1072#1079#1074#1072#1085#1080#1077' '#1085#1072#1083#1086#1075#1072':'
  end
  object lvVatCodes: TListView
    Left = 8
    Top = 136
    Width = 372
    Height = 107
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <
      item
        Caption = #1050#1086#1076
        Width = 100
      end
      item
        Caption = #1057#1090#1072#1074#1082#1072', %'
        Width = 100
      end
      item
        AutoSize = True
        Caption = #1053#1072#1079#1074#1072#1085#1080#1077
      end>
    ColumnClick = False
    FlatScrollBars = True
    HideSelection = False
    ReadOnly = True
    RowSelect = True
    TabOrder = 6
    ViewStyle = vsReport
  end
  object btnDelete: TTntButton
    Left = 272
    Top = 48
    Width = 105
    Height = 25
    Anchors = [akTop, akRight]
    Caption = #1059#1076#1072#1083#1080#1090#1100
    Enabled = False
    TabOrder = 4
    OnClick = btnDeleteClick
  end
  object btnAdd: TTntButton
    Left = 272
    Top = 16
    Width = 105
    Height = 25
    Anchors = [akTop, akRight]
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100
    TabOrder = 3
    OnClick = btnAddClick
  end
  object seVatCode: TSpinEdit
    Left = 104
    Top = 16
    Width = 145
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 0
    Value = 1
    OnChange = ModifiedClick
  end
  object edtVatName: TEdit
    Left = 104
    Top = 80
    Width = 145
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 2
    OnChange = ModifiedClick
  end
  object chbVatCodeEnabled: TCheckBox
    Left = 8
    Top = 112
    Width = 241
    Height = 17
    Caption = #1048#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100' '#1085#1072#1083#1086#1075#1086#1074#1099#1077' '#1089#1090#1072#1074#1082#1080
    TabOrder = 5
    OnClick = ModifiedClick
  end
  object edtVatRate: TEdit
    Left = 104
    Top = 48
    Width = 145
    Height = 21
    TabOrder = 1
    OnChange = ModifiedClick
  end
end

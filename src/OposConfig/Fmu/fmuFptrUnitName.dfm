object fmFptrUnitName: TfmFptrUnitName
  Left = 1079
  Top = 200
  AutoScroll = False
  BorderIcons = [biSystemMenu]
  Caption = #1045#1076#1080#1085#1080#1094#1099' '#1080#1079#1084#1077#1088#1077#1085#1080#1103
  ClientHeight = 216
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
    216)
  PixelsPerInch = 96
  TextHeight = 13
  object lblAppUnitName: TTntLabel
    Left = 8
    Top = 8
    Width = 108
    Height = 13
    Caption = #1045#1076#1080#1085#1080#1094#1072' '#1087#1088#1080#1083#1086#1078#1077#1085#1080#1103
  end
  object lblSrvUnitName: TTntLabel
    Left = 8
    Top = 40
    Width = 91
    Height = 13
    Caption = #1045#1076#1080#1085#1080#1094#1072' '#1089#1077#1088#1074#1077#1088#1072':'
  end
  object lvUnitNames: TTntListView
    Left = 8
    Top = 72
    Width = 273
    Height = 137
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <
      item
        Caption = #1045#1076#1080#1085#1080#1094#1072' '#1087#1088#1080#1083#1086#1078#1077#1085#1080#1103
        Width = 150
      end
      item
        AutoSize = True
        Caption = #1045#1076#1080#1085#1080#1094#1072' '#1089#1077#1088#1074#1077#1088#1072
      end>
    ColumnClick = False
    FlatScrollBars = True
    HideSelection = False
    ReadOnly = True
    RowSelect = True
    TabOrder = 2
    ViewStyle = vsReport
    OnSelectItem = lvUnitNamesSelectItem
  end
  object btnDelete: TTntButton
    Left = 288
    Top = 72
    Width = 89
    Height = 25
    Anchors = [akTop, akRight]
    Caption = #1059#1076#1072#1083#1080#1090#1100
    Enabled = False
    TabOrder = 5
    OnClick = btnDeleteClick
  end
  object btnAdd: TTntButton
    Left = 288
    Top = 8
    Width = 89
    Height = 25
    Anchors = [akTop, akRight]
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100
    TabOrder = 3
    OnClick = btnAddClick
  end
  object edtAppUnitName: TTntEdit
    Left = 128
    Top = 8
    Width = 153
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    OnChange = ModifiedClick
  end
  object cbSrvUnitName: TComboBox
    Left = 128
    Top = 40
    Width = 153
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 1
  end
  object btnUpdateSrvUnits: TTntButton
    Left = 288
    Top = 40
    Width = 89
    Height = 25
    Anchors = [akTop, akRight]
    Caption = #1054#1073#1085#1086#1074#1080#1090#1100
    TabOrder = 4
    OnClick = btnUpdateSrvUnitsClick
  end
end

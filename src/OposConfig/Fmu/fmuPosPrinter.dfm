object fmPosPrinter: TfmPosPrinter
  Left = 544
  Top = 218
  Width = 471
  Height = 278
  Caption = 'POS printer'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    455
    240)
  PixelsPerInch = 96
  TextHeight = 13
  object lblDeviceName: TTntLabel
    Left = 8
    Top = 8
    Width = 66
    Height = 13
    Caption = 'Device name:'
  end
  object lblResultCode: TTntLabel
    Left = 8
    Top = 40
    Width = 33
    Height = 13
    Caption = 'Result:'
  end
  object cbDeviceName: TTntComboBox
    Left = 120
    Top = 8
    Width = 329
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 0
  end
  object memResult: TMemo
    Left = 120
    Top = 40
    Width = 329
    Height = 161
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
  object btnTestConnection: TButton
    Left = 200
    Top = 208
    Width = 121
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Test connection'
    TabOrder = 2
    OnClick = btnTestConnectionClick
  end
  object btnPrintReceipt: TButton
    Left = 328
    Top = 208
    Width = 121
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Test receipt'
    TabOrder = 3
    OnClick = btnPrintReceiptClick
  end
end

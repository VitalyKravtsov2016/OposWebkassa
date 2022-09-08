object fmMain: TfmMain
  Left = 406
  Top = 272
  Width = 295
  Height = 113
  Caption = 'Генератор кода'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object btnOpen: TBitBtn
    Left = 192
    Top = 8
    Width = 91
    Height = 25
    Caption = 'Открыть...'
    TabOrder = 0
    OnClick = btnOpenClick
    Glyph.Data = {
      F6000000424DF600000000000000760000002800000010000000100000000100
      0400000000008000000000000000000000001000000000000000000000000000
      8000008000000080800080000000800080008080000080808000C0C0C0000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888888888888
      88888888888888888888000000000008888800333333333088880B0333333333
      08880FB03333333330880BFB0333333333080FBFB000000000000BFBFBFBFB08
      88880FBFBFBFBF0888880BFB0000000888888000888888880008888888888888
      8008888888880888080888888888800088888888888888888888}
  end
  object btnClose: TButton
    Left = 192
    Top = 56
    Width = 91
    Height = 25
    Caption = 'Закрыть'
    TabOrder = 1
    OnClick = btnCloseClick
  end
  object OpenDialog: TOpenDialog
    DefaultExt = 'PAS'
    Filter = 'Module file (*.pas)|*.pas|All files (*.*)|*.*'
    Left = 8
    Top = 8
  end
end

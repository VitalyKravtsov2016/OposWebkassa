object fmFptrReceipt: TfmFptrReceipt
  Left = 784
  Top = 194
  AutoScroll = False
  BorderIcons = [biSystemMenu]
  Caption = #1060#1086#1088#1084#1072#1090' '#1095#1077#1082#1072
  ClientHeight = 450
  ClientWidth = 581
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    581
    450)
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 581
    Height = 417
    ActivePage = tsReceipt
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object tsReceipt: TTabSheet
      Caption = #1042#1080#1076' '#1095#1077#1082#1072
      object reReceipt: TRichEdit
        Left = 0
        Top = 0
        Width = 573
        Height = 389
        Align = alClient
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        Constraints.MinWidth = 320
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
    object tsXmlTemplate: TTabSheet
      Caption = #1060#1086#1088#1084#1072#1090' '#1095#1077#1082#1072
      ImageIndex = 1
      object seTemplate: TSynEdit
        Left = 0
        Top = 0
        Width = 573
        Height = 422
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        TabOrder = 0
        Gutter.Font.Charset = DEFAULT_CHARSET
        Gutter.Font.Color = clWindowText
        Gutter.Font.Height = -11
        Gutter.Font.Name = 'Courier New'
        Gutter.Font.Style = []
        Highlighter = SynXMLSyn
        OnChange = ReceiptChange
      end
    end
  end
  object chbTemplateEnabled: TCheckBox
    Left = 8
    Top = 424
    Width = 361
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = #1048#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100' '#1092#1086#1088#1084#1072#1090' '#1095#1077#1082#1072
    TabOrder = 1
  end
  object SynXMLSyn: TSynXMLSyn
    WantBracesParsed = False
    Left = 48
    Top = 32
  end
end

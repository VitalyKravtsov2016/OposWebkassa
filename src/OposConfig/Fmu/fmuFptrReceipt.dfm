object fmFptrReceipt: TfmFptrReceipt
  Left = 933
  Top = 183
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
    Height = 401
    ActivePage = tsReceipt
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object tsReceipt: TTntTabSheet
      Caption = #1042#1080#1076' '#1095#1077#1082#1072
      object reReceipt: TTntRichEdit
        Left = 0
        Top = 0
        Width = 573
        Height = 373
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
    object tsXmlTemplate: TTntTabSheet
      Caption = #1060#1086#1088#1084#1072#1090' '#1095#1077#1082#1072
      ImageIndex = 1
      object seTemplate: TSynEdit
        Left = 0
        Top = 0
        Width = 573
        Height = 373
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
        FontSmoothing = fsmNone
      end
    end
  end
  object chbTemplateEnabled: TTntCheckBox
    Left = 8
    Top = 416
    Width = 361
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = #1048#1089#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100' '#1092#1086#1088#1084#1072#1090' '#1095#1077#1082#1072
    TabOrder = 1
  end
  object btnUpdate: TButton
    Left = 472
    Top = 408
    Width = 99
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #1054#1073#1085#1086#1074#1080#1090#1100
    TabOrder = 2
    OnClick = btnUpdateClick
  end
  object SynXMLSyn: TSynXMLSyn
    Options.AutoDetectEnabled = False
    Options.AutoDetectLineLimit = 0
    Options.Visible = False
    WantBracesParsed = False
    Left = 48
    Top = 32
  end
end

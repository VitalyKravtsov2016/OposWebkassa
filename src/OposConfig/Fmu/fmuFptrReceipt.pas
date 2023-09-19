unit fmuFptrReceipt;

interface

uses
  // VCL
  StdCtrls, Controls, Classes, ComObj, SysUtils, Math, Graphics,
  // JVCL
  JvExStdCtrls, JvRichEdit,
  // Tnt
  TntSysUtils,
  // 3'd
  SynMemo, SynEdit, TntStdCtrls,
  // This
  PrinterParameters, FiscalPrinterDevice, Grids, TntGrids, Buttons,
  ToolWin, ComCtrls, SynEditHighlighter, SynHighlighterXML, ExtCtrls,
  WebkassaImpl, SalesReceipt, ReceiptTemplate, TextDocument, LogFile,
  PrinterTypes;

type
  { TfmFptrReceipt }

  TfmFptrReceipt = class(TFptrPage)
    SynXMLSyn: TSynXMLSyn;
    PageControl1: TPageControl;
    tsReceipt: TTabSheet;
    tsXmlTemplate: TTabSheet;
    reReceipt: TRichEdit;
    seTemplate: TSynEdit;
    chbTemplateEnabled: TCheckBox;
    procedure ReceiptChange(Sender: TObject);
  public
    procedure UpdatePage; override;
    procedure UpdateObject; override;

    procedure UpdateReceiptText(const TemplateXml: string);
    procedure UpdateReceiptText2(const TemplateXml: string);
  end;

implementation

{$R *.DFM}

{ TfmFptrReceipt }

procedure TfmFptrReceipt.UpdateReceiptText(const TemplateXml: string);
begin
  reReceipt.Lines.BeginUpdate;
  try
    reReceipt.SelAttributes.Size := 8;
    reReceipt.SelAttributes.Style := [];
    //reReceipt.SelText := 'Line 1' + CRLF;
    reReceipt.Lines.Add('Line 1');

    reReceipt.SelAttributes.Size := 10;
    reReceipt.SelAttributes.Style := [fsBold];
    //reReceipt.SelText := 'Line 1 Bold' + CRLF;
    reReceipt.Lines.Add('Line 1 Bold');

    reReceipt.SelAttributes.Size := 12;
    reReceipt.SelAttributes.Style := [fsBold];
    //reReceipt.SelText := 'Line 2 Bold';
    reReceipt.Lines.Add('Line 2 Bold');
  finally
    reReceipt.Lines.EndUpdate;
  end;
end;

procedure TfmFptrReceipt.UpdateReceiptText2(const TemplateXml: string);
var
  i: Integer;
  TextItem: TDocItem;
  Driver: TWebkassaImpl;
  Receipt: TSalesReceipt;
  ItemName: WideString;
const
  ReceiptItemsCount = 2;
  FontSizeNormal = 8;
  FontSizeDouble = 16;
  AnswerJson =
    '{"Data":{"CheckNumber":"1158917320297","DateTime":"19.07.2023 20:09:49",' +
    '"OfflineMode":false,"CashboxOfflineMode":false,"Cashbox":{"UniqueNumber":'+
    '"SWK00033059","RegistrationNumber":"427490326691","IdentityNumber":"657",'+
    '"Address":"Алматы","Ofd":{"Name":"АО \"КазТранском\"","Host":"dev.kofd.kz/consumer",'+
    '"Code":3}},"CheckOrderNumber":2,"ShiftNumber":100,"EmployeeName":"webkassa4@softit.kz",'+
    '"TicketUrl":"http://dev.kofd.kz/consumer?i=1158917320297&f=427490326691&s=15443.72&t=20230306T200949",'+
    '"TicketPrintUrl":"https://devkkm.webkassa.kz/Ticket?chb=SWK00033059&sh=100&extnum=92D51F08-13CF-428E-AF2F-67B6E8BDE994"}}';
begin
  reReceipt.Lines.Clear;
  if TemplateXml = '' then Exit;

  Parameters.PrinterType := PrinterTypeEscPrinterSerial;
  Driver := TWebkassaImpl.Create(nil);
  Receipt := TSalesReceipt.CreateReceipt(rtSell,
    Parameters.AmountDecimalPlaces, Parameters.RoundType);

  reReceipt.Lines.BeginUpdate;
  Driver.Params.Assign(Parameters);
  try
    Receipt.BeginFiscalReceipt(True);
    for i := 1 to ReceiptItemsCount do
    begin
      ItemName := Tnt_WideFormat('%d. Receipt item %d', [i, i]);
      Receipt.PrintRecItem(ItemName, 100, 1, 0, 100, '');
    end;
    Receipt.PrintRecTotal(1000, 1000, '0');
    Receipt.EndFiscalReceipt(false);
    Receipt.AnswerJson := AnswerJson;


    Parameters.Template.LoadFromXml(TemplateXml);
    Driver.PrintReceiptTemplate(Receipt, Parameters.Template);

    for i := 0 to Driver.Document.Items.Count-1 do
    begin
      TextItem := Driver.Document.Items[i];

      case TextItem.Style of
        STYLE_BOLD:
        begin
          reReceipt.SelAttributes.Size := FontSizeNormal;
          reReceipt.SelAttributes.Style := [fsBold];
          reReceipt.SelText := TextItem.Text;
        end;
        STYLE_ITALIC:
        begin
          reReceipt.SelAttributes.Size := FontSizeNormal;
          reReceipt.SelAttributes.Style := [fsItalic];
          reReceipt.SelText := TextItem.Text;
        end;
        STYLE_DWIDTH,
        STYLE_DHEIGHT,
        STYLE_DWIDTH_HEIGHT:
        begin
          reReceipt.SelAttributes.Size := FontSizeDouble;
          reReceipt.SelAttributes.Style := [fsBold];
          reReceipt.SelText := TextItem.Text;
        end;
        STYLE_QR_CODE:
        begin
          reReceipt.Lines.Add('  QRCODE: ' + TrimRight(TextItem.Text));
        end;
        STYLE_IMAGE: reReceipt.Lines.Add('  IMAGE: ' + TrimRight(TextItem.Text));
      else
        reReceipt.SelAttributes.Size := FontSizeNormal;
        reReceipt.SelAttributes.Style := [];
        reReceipt.SelText := TextItem.Text;
      end;
    end;
  finally
    Driver.Free;
    Receipt.Free;
    reReceipt.Lines.EndUpdate;
    reReceipt.Invalidate;
  end;
end;

procedure TfmFptrReceipt.UpdatePage;
begin
  chbTemplateEnabled.Checked := Parameters.TemplateEnabled;
  seTemplate.Lines.Text := Parameters.Template.AsXML;
  UpdateReceiptText2(Parameters.Template.AsXML);

end;

procedure TfmFptrReceipt.UpdateObject;
begin
  Parameters.TemplateEnabled := chbTemplateEnabled.Checked;
  Parameters.Template.AsXML := seTemplate.Lines.Text;
end;

procedure TfmFptrReceipt.ReceiptChange(Sender: TObject);
begin
  Modified;
  try
    UpdateReceiptText2(seTemplate.Lines.Text);
  except
    // !!!
  end;
end;

end.

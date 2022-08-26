unit duSalesReceipt;

interface

uses
  // VCL
  Windows, SysUtils, Classes,
  // DUnit
  TestFramework, TntClasses,
  // Opos
  OposFptr,
  // This
  LogFile, SalesReceipt;

type
  { TSalesReceiptTest }

  TSalesReceiptTest = class(TTestCase)
  private
    FReceipt: TSalesReceipt;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestEncoding;
    procedure TestPrintRecItem;
    procedure TestPrintRecVoid;
    procedure TestItemAdjustment;
    procedure TestSubtotalAdjustment;
  end;

implementation

{ TSalesReceiptTest }

procedure TSalesReceiptTest.SetUp;
begin
  inherited SetUp;
  FReceipt := TSalesReceipt.Create(False, 2);
end;

procedure TSalesReceiptTest.TearDown;
begin
  FReceipt.Free;
  inherited TearDown;
end;

procedure TSalesReceiptTest.TestPrintRecItem;
begin
  CheckEquals(0, FReceipt.GetTotal, 'FReceipt.Total');
  CheckEquals(0, FReceipt.GetPayment, 'FReceipt.Payment');
  CheckEquals(False, FReceipt.IsVoided, 'FReceipt.IsVoided');
  FReceipt.BeginFiscalReceipt(False);
  CheckEquals(0, FReceipt.GetTotal, 'FReceipt.Total');
  CheckEquals(0, FReceipt.GetPayment, 'FReceipt.Payment');
  CheckEquals(False, FReceipt.IsVoided, 'FReceipt.IsVoided');
  FReceipt.PrintRecItem('Description', 123.45, 1, 0, 123.45, 'UnitName');
  CheckEquals(123.45, FReceipt.GetTotal, 'FReceipt.Total');
  FReceipt.PrintRecTotal(123.45, 100, 'Оплата картой');
  CheckEquals(100, FReceipt.GetPayment, 'FReceipt.Payment');
  FReceipt.PrintRecTotal(123.45, 23.45, 'Наличными');
  CheckEquals(123.45, FReceipt.GetPayment, 'FReceipt.Payment');
end;

procedure TSalesReceiptTest.TestPrintRecVoid;
begin
  CheckEquals(0, FReceipt.GetTotal, 'FReceipt.Total');
  CheckEquals(0, FReceipt.GetPayment, 'FReceipt.Payment');
  CheckEquals(False, FReceipt.IsVoided, 'FReceipt.IsVoided');
  FReceipt.BeginFiscalReceipt(False);
  CheckEquals(False, FReceipt.IsVoided, 'FReceipt.IsVoided');
  FReceipt.PrintRecVoid('');
  CheckEquals(True, FReceipt.IsVoided, 'FReceipt.IsVoided');
end;

procedure TSalesReceiptTest.TestEncoding;
const
  Text: WideString = 'Позиция чека 1';
begin
  CheckEquals(Text, UTF8Decode(UTF8Encode(Text)), 'Text');
end;

procedure TSalesReceiptTest.TestItemAdjustment;
begin
  CheckEquals(0, FReceipt.GetTotal, 'FReceipt.Total');
  CheckEquals(0, FReceipt.GetPayment, 'FReceipt.Payment');
  CheckEquals(False, FReceipt.IsVoided, 'FReceipt.IsVoided');
  FReceipt.BeginFiscalReceipt(False);
  CheckEquals(False, FReceipt.IsVoided, 'FReceipt.IsVoided');
  // Item
  FReceipt.PrintRecItem('Description', 123.45, 1, 0, 123.45, 'UnitName');
  CheckEquals(123.45, FReceipt.GetTotal, 'FReceipt.Total');
  // Amount discount
  FReceipt.PrintRecItemAdjustment(FPTR_AT_AMOUNT_DISCOUNT, 'Скидка 1.23', 1.23, 0);
  CheckEquals(122.22, FReceipt.GetTotal, 'FReceipt.Total');
  // Amount charge
  FReceipt.PrintRecItemAdjustment(FPTR_AT_AMOUNT_SURCHARGE, 'Надбавка 2.34', 2.34, 0);
  CheckEquals(124.56, FReceipt.GetTotal, 'FReceipt.Total');
  // Percent discount
  FReceipt.PrintRecItemAdjustment(FPTR_AT_PERCENTAGE_DISCOUNT, 'Скидка 5%', 5, 0);
  CheckEquals(118.33, FReceipt.GetTotal, 'FReceipt.Total');
  // Percent charge
  FReceipt.PrintRecItemAdjustment(FPTR_AT_PERCENTAGE_SURCHARGE, 'Надбавка 10%', 10, 0);
  CheckEquals(130.16, FReceipt.GetTotal, 'FReceipt.Total');
  // Void amount discount
  FReceipt.PrintRecItemAdjustmentVoid(FPTR_AT_AMOUNT_DISCOUNT, 'Скидка 1.23', 1.23, 0);
  CheckEquals(131.39, FReceipt.GetTotal, 'FReceipt.Total');
  // Void amount charge
  FReceipt.PrintRecItemAdjustmentVoid(FPTR_AT_AMOUNT_SURCHARGE, 'Надбавка 2.34', 2.34, 0);
  CheckEquals(129.05, FReceipt.GetTotal, 'FReceipt.Total');
  // Void percent discount
  FReceipt.PrintRecItemAdjustmentVoid(FPTR_AT_PERCENTAGE_DISCOUNT, 'Скидка 5%', 5, 0);
  CheckEquals(135.50, FReceipt.GetTotal, 'FReceipt.Total');
  // Void percent charge
  FReceipt.PrintRecItemAdjustmentVoid(FPTR_AT_PERCENTAGE_SURCHARGE, 'Надбавка 10%', 10, 0);
  CheckEquals(121.95, FReceipt.GetTotal, 'FReceipt.Total');

  FReceipt.PrintRecTotal(121.95, 130, 'Наличными');
  FReceipt.EndFiscalReceipt;
end;

procedure TSalesReceiptTest.TestSubtotalAdjustment;
begin
  CheckEquals(0, FReceipt.GetTotal, 'FReceipt.Total');
  CheckEquals(0, FReceipt.GetPayment, 'FReceipt.Payment');
  CheckEquals(False, FReceipt.IsVoided, 'FReceipt.IsVoided');
  FReceipt.BeginFiscalReceipt(False);
  CheckEquals(False, FReceipt.IsVoided, 'FReceipt.IsVoided');
  // Item
  FReceipt.PrintRecItem('Description', 123.45, 1, 0, 123.45, 'UnitName');
  CheckEquals(123.45, FReceipt.GetTotal, 'FReceipt.Total');
  // Amount discount
  FReceipt.PrintRecSubtotalAdjustment(FPTR_AT_AMOUNT_DISCOUNT, 'Скидка 1.23', 1.23);
  CheckEquals(122.22, FReceipt.GetTotal, 'FReceipt.Total');
  // Amount charge
  FReceipt.PrintRecSubtotalAdjustment(FPTR_AT_AMOUNT_SURCHARGE, 'Надбавка 2.34', 2.34);
  CheckEquals(124.56, FReceipt.GetTotal, 'FReceipt.Total');
  // Percent discount
  FReceipt.PrintRecSubtotalAdjustment(FPTR_AT_PERCENTAGE_DISCOUNT, 'Скидка 5%', 5);
  CheckEquals(118.33, FReceipt.GetTotal, 'FReceipt.Total');
  // Percent charge
  FReceipt.PrintRecSubtotalAdjustment(FPTR_AT_PERCENTAGE_SURCHARGE, 'Надбавка 10%', 10);
  CheckEquals(130.16, FReceipt.GetTotal, 'FReceipt.Total');
  // Void amount discount
  FReceipt.PrintRecSubtotalAdjustVoid(FPTR_AT_AMOUNT_DISCOUNT, 1.23);
  CheckEquals(131.39, FReceipt.GetTotal, 'FReceipt.Total');
  // Void amount charge
  FReceipt.PrintRecSubtotalAdjustVoid(FPTR_AT_AMOUNT_SURCHARGE, 2.34);
  CheckEquals(129.05, FReceipt.GetTotal, 'FReceipt.Total');
  // Void percent discount
  FReceipt.PrintRecSubtotalAdjustVoid(FPTR_AT_PERCENTAGE_DISCOUNT, 5);
  CheckEquals(135.50, FReceipt.GetTotal, 'FReceipt.Total');
  // Void percent charge
  FReceipt.PrintRecSubtotalAdjustVoid(FPTR_AT_PERCENTAGE_SURCHARGE, 10);
  CheckEquals(121.95, FReceipt.GetTotal, 'FReceipt.Total');

  FReceipt.PrintRecTotal(121.95, 130, 'Наличными');
  FReceipt.EndFiscalReceipt;
end;

initialization
  RegisterTest('', TSalesReceiptTest.Suite);

end.

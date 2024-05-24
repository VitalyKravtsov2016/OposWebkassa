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
  LogFile, SalesReceipt, ReceiptItem, DirectIOAPI;

type
  { TSalesReceiptTest }

  TSalesReceiptTest = class(TTestCase)
  private
    FReceipt: TSalesReceipt;
    property Receipt: TSalesReceipt read FReceipt;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestEncoding;
    procedure TestPrintRecItem;
    procedure TestPrintRecVoid;
    procedure TestItemAdjustment;
    procedure TestSubtotalAdjustment;
    procedure TestReceiptWithChange;
    procedure TestDirectIO;
  end;

implementation

{ TSalesReceiptTest }

procedure TSalesReceiptTest.SetUp;
begin
  inherited SetUp;
  FReceipt := TSalesReceipt.CreateReceipt(rtSell, 2, RoundTypeNone);
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
  CheckEquals(118.39, FReceipt.GetTotal, 'FReceipt.Total');
  // Percent charge
  FReceipt.PrintRecItemAdjustment(FPTR_AT_PERCENTAGE_SURCHARGE, 'Надбавка 10%', 10, 0);
  CheckEquals(130.74, FReceipt.GetTotal, 'FReceipt.Total');
  // Void amount discount
  FReceipt.PrintRecItemAdjustmentVoid(FPTR_AT_AMOUNT_DISCOUNT, 'Скидка 1.23', 1.23, 0);
  CheckEquals(131.97, FReceipt.GetTotal, 'FReceipt.Total');
  // Void amount charge
  FReceipt.PrintRecItemAdjustmentVoid(FPTR_AT_AMOUNT_SURCHARGE, 'Надбавка 2.34', 2.34, 0);
  CheckEquals(129.63, FReceipt.GetTotal, 'FReceipt.Total');
  // Void percent discount
  FReceipt.PrintRecItemAdjustmentVoid(FPTR_AT_PERCENTAGE_DISCOUNT, 'Скидка 5%', 5, 0);
  CheckEquals(135.8, FReceipt.GetTotal, 'FReceipt.Total');
  // Void percent charge
  FReceipt.PrintRecItemAdjustmentVoid(FPTR_AT_PERCENTAGE_SURCHARGE, 'Надбавка 10%', 10, 0);
  CheckEquals(123.45, FReceipt.GetTotal, 'FReceipt.Total');

  FReceipt.PrintRecTotal(123.44, 130, 'Наличными');
  FReceipt.EndFiscalReceipt(False);
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
  FReceipt.EndFiscalReceipt(False);
end;

procedure TSalesReceiptTest.TestReceiptWithChange;
begin
  FReceipt.BeginFiscalReceipt(False);
  FReceipt.PrintRecItem('Item 1', 578, 3302, 4, 175, '');
  CheckEquals(578, FReceipt.GetTotal, 'FReceipt.Total');
  FReceipt.PrintRecTotal(578, 10, '0');
  FReceipt.PrintRecTotal(578, 20, '1');
  FReceipt.PrintRecTotal(578, 30, '2');
  FReceipt.PrintRecTotal(578, 40, '3');
  FReceipt.PrintRecTotal(578, 478, '4');
  CheckEquals(0, FReceipt.Change, 'Receipt.Change');
  FReceipt.EndFiscalReceipt(False);
  CheckEquals(10, FReceipt.Payments[0], 'Payments[0]');
  CheckEquals(20, FReceipt.Payments[1], 'Payments[1]');
  CheckEquals(30, FReceipt.Payments[2], 'Payments[2]');
  CheckEquals(40, FReceipt.Payments[3], 'Payments[3]');
  CheckEquals(478, FReceipt.Payments[4], 'Payments[4]');
end;

procedure TSalesReceiptTest.TestDirectIO;
var
  pData: Integer;
  pString: WideString;
begin
  CheckEquals('', Receipt.CustomerINN, 'Receipt.CustomerINN');
  CheckEquals('', Receipt.CustomerEmail, 'Receipt.CustomerEmail');
  CheckEquals('', Receipt.CustomerPhone, 'Receipt.CustomerPhone');

  pData := 1228;
  pString := 'CustomerINN';
  Receipt.DirectIO(DIO_WRITE_FS_STRING_TAG_OP, pData, pString);
  CheckEquals('', Receipt.CustomerEmail, 'Receipt.CustomerEmail');
  CheckEquals('', Receipt.CustomerPhone, 'Receipt.CustomerPhone');
  CheckEquals('CustomerINN', Receipt.CustomerINN, 'Receipt.CustomerINN');

  pData := 1008;
  pString := 'Customer@Email';
  Receipt.DirectIO(DIO_WRITE_FS_STRING_TAG_OP, pData, pString);
  CheckEquals('Customer@Email', Receipt.CustomerEmail, 'Receipt.CustomerEMail');
  CheckEquals('CustomerINN', Receipt.CustomerINN, 'Receipt.CustomerINN');
  CheckEquals('', Receipt.CustomerPhone, 'Receipt.CustomerPhone');

  pData := 1008;
  pString := '+727834657823';
  Receipt.DirectIO(DIO_WRITE_FS_STRING_TAG_OP, pData, pString);
  CheckEquals('CustomerINN', Receipt.CustomerINN, 'Receipt.CustomerINN');
  CheckEquals('Customer@Email', Receipt.CustomerEmail, 'Receipt.CustomerEMail');
  CheckEquals('+727834657823', Receipt.CustomerPhone, 'Receipt.CustomerPhone');
end;

initialization
  RegisterTest('', TSalesReceiptTest.Suite);

end.

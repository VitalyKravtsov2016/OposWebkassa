unit duSalesReceipt;

interface

uses
  // VCL
  Windows, SysUtils, Classes,
  // DUnit
  TestFramework, TntClasses,
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
    procedure TestPrintRecItem;
    procedure TestPrintRecVoid;
  end;

implementation

{ TSalesReceiptTest }

procedure TSalesReceiptTest.SetUp;
begin
  inherited SetUp;
  FReceipt := TSalesReceipt.Create(False);
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

initialization
  RegisterTest('', TSalesReceiptTest.Suite);

end.

unit duStorePoint;

interface

uses
  // VCL
  Windows, SysUtils, Classes, Registry,
  // DUnit
  TestFramework, TntClasses,
  // This
  StorePointIO_TLB;

type
  { TStorePointTest }

  TStorePointTest = class(TTestCase)
  private
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestInitDevices;
  end;

implementation

{ TStorePointTest }

procedure TStorePointTest.SetUp;
begin
end;

procedure TStorePointTest.TearDown;
begin
end;


procedure TStorePointTest.TestInitDevices;
var
  Driver: IIOSystemSO;
  //bNeedDispMsg: WordBool;
begin
  Driver := CoIOSystemSO.Create;
  CheckEquals(False, Driver.Get_IsFiscalPrinterActive);
  CheckEquals(False, Driver.Get_IsFiscalPrinterInitFailed);
  Driver.InitDevices;
  CheckEquals(False, Driver.Get_IsFiscalPrinterInitFailed, 'IsFiscalPrinterInitFailed = True');
  CheckEquals(42, Driver.Get_PrinterWidth, 'Get_PrinterWidth = 0');
  //CheckEquals(0, Driver.PrintFiscalXReport, 'PrintFiscalXReport');
  //bNeedDispMsg := True;
  //CheckEquals(True, Driver.PrintFiscalZReport(bNeedDispMsg), 'PrintFiscalZReport');
  //CheckEquals(True, Driver.PrintFiscalReport(0, '', ''), 'PrintFiscalReport');
  //CheckEquals(0, Driver.PrintFiscalLastTicket(''));
end;

initialization
  RegisterTest('', TStorePointTest.Suite);

end.

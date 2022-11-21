
unit duWebkassaImpl;

interface

uses
  // VCL
  Windows, SysUtils, Classes,
  // DUnit
  TestFramework,
  // Opos
  Opos, OposFptr, Oposhi, OposFptrhi, OposFptrUtils, OposUtils,
  // Tnt
  TntClasses, TntSysUtils,
  // This
  LogFile, WebkassaImpl, WebkassaClient, MockPosPrinter, PrinterParameters;

const
  CRLF = #13#10;

type
  { TWebkassaImplTest }

  TWebkassaImplTest = class(TTestCase)
  private
    FDriver: TWebkassaImpl;
    FPrintHeader: Boolean;
    procedure ClaimDevice;
    procedure EnableDevice;
    procedure OpenService;
    procedure TestCashIn;
    procedure FptrCheck(Code: Integer);

    property Driver: TWebkassaImpl read FDriver;
    procedure CheckTotal(Amount: Currency);
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure OpenClaimEnable;
    procedure TestCashIn2;
    procedure TestCashOut;
    procedure TestZReport;
    procedure TestXReport;
    procedure TestNonFiscal;
    procedure TestFiscalReceipt;
    procedure TestFiscalReceipt2;
    procedure TestFiscalReceipt3;
    procedure TestFiscalReceiptWithVAT;
    procedure TestFiscalReceiptWithAdjustments;
    procedure TestPrintBarcode;
    procedure TestGetData;
  end;

implementation

{ TWebkassaImplTest }

procedure TWebkassaImplTest.FptrCheck(Code: Integer);
var
  Text: WideString;
  ResultCode: Integer;
  ErrorString: WideString;
  ResultCodeExtended: Integer;
begin
  if Code <> OPOS_SUCCESS then
  begin
    ResultCode := Driver.GetPropertyNumber(PIDX_ResultCode);
    ResultCodeExtended := Driver.GetPropertyNumber(PIDX_ResultCodeExtended);
    ErrorString := Driver.GetPropertyString(PIDXFptr_ErrorString);

    if ResultCode = OPOS_E_EXTENDED then
      Text := Tnt_WideFormat('%d, %d, %s [%s]', [ResultCode, ResultCodeExtended,
      GetResultCodeExtendedText(ResultCodeExtended), ErrorString])
    else
      Text := Tnt_WideFormat('%d, %s [%s]', [ResultCode,
        GetResultCodeText(ResultCode), ErrorString]);

    raise Exception.Create(Text);
  end;
end;


procedure TWebkassaImplTest.SetUp;
begin
  inherited SetUp;
  FDriver := TWebkassaImpl.Create(nil);
  //FDriver.Printer := TMockPOSPrinter.Create(nil);

  FDriver.TestMode := True;
  FDriver.Params.LogFileEnabled := True;
  FDriver.Params.LogMaxCount := 10;
  FDriver.Params.LogFilePath := 'Logs';
  FDriver.Params.Login := 'webkassa4@softit.kz';
  FDriver.Params.Password := 'Kassa123';
  FDriver.Params.ConnectTimeout := 10;
  FDriver.Params.WebkassaAddress := 'https://devkkm.webkassa.kz/';
  FDriver.Params.CashboxNumber := 'SWK00032685';
  FDriver.Params.PrinterName := 'ThermalU';
  FDriver.Params.NumHeaderLines := 4;
  FDriver.Params.NumTrailerLines := 3;
  FDriver.Params.RoundType := RoundTypeNo;
  FDriver.Params.HeaderText :=
    ' ' + CRLF +
    '  Восточно-Казастанская область, город' + CRLF +
    '    Усть-Каменогорск, ул. Грейдерная, 1/10' + CRLF +
    '            ТОО PetroRetail';
  FDriver.Params.TrailerText :=
    '           Callцентр 039458039850 ' + CRLF +
    '          Горячая линия 20948802934' + CRLF +
    '            СПАСИБО ЗА ПОКУПКУ';

(*
  FDriver.Params.PrinterType := PrinterTypePosPrinter;
  FDriver.Params.PrinterName := 'ThermalU';
  FDriver.Params.FontName := '42';
  FDriver.Params.PrinterType := PrinterTypeWinPrinter;
  FDriver.Params.PrinterName := 'SLK-TE122';
  FDriver.Params.FontName := 'FontA11';
  
  FDriver.Params.PrinterType := PrinterTypeEscPrinterSerial;
  FDriver.Params.ByteTimeout := 100;
  FDriver.Params.FontName := 'FontA11';
  FDriver.Params.PortName := 'COM2';
  FDriver.Params.BaudRate := 19200;
  FDriver.Params.DataBits := DATABITS_8;
  FDriver.Params.StopBits := ONESTOPBIT;
  FDriver.Params.Parity := NOPARITY;
  FDriver.Params.FlowControl := 0;
  FDriver.Params.ReconnectPort := False;
*)
  // Network
  FDriver.Params.PrinterType := PrinterTypeEscPrinterNetwork;
  FDriver.Params.RemoteHost := '10.11.7.176';
  FDriver.Params.RemotePort := 9100;
  FDriver.Params.ByteTimeout := 1000;
  FDriver.Params.FontName := 'FontA11';
end;

procedure TWebkassaImplTest.TearDown;
begin
  if FDriver <> nil then
    FDriver.Close;

  FDriver.Free;
  inherited TearDown;
end;

procedure TWebkassaImplTest.OpenService;
begin
  FptrCheck(Driver.OpenService(OPOS_CLASSKEY_FPTR, 'DeviceName', nil));
end;

procedure TWebkassaImplTest.ClaimDevice;
begin
  CheckEquals(0, Driver.GetPropertyNumber(PIDX_Claimed),
    'Driver.GetPropertyNumber(PIDX_Claimed)');
  FptrCheck(Driver.ClaimDevice(1000));
  CheckEquals(1, Driver.GetPropertyNumber(PIDX_Claimed),
    'Driver.GetPropertyNumber(PIDX_Claimed)');
end;

procedure TWebkassaImplTest.EnableDevice;
var
  ResultCode: Integer;
begin
  Driver.SetPropertyNumber(PIDX_DeviceEnabled, 1);
  ResultCode := Driver.GetPropertyNumber(PIDX_ResultCode);
  FptrCheck(ResultCode);

  CheckEquals(OPOS_SUCCESS, ResultCode, 'OPOS_SUCCESS');
  CheckEquals(1, Driver.GetPropertyNumber(PIDX_DeviceEnabled), 'DeviceEnabled');
end;

procedure TWebkassaImplTest.OpenClaimEnable;
begin
  OpenService;
  ClaimDevice;
  EnableDevice;
end;

procedure TWebkassaImplTest.TestCashIn;
begin
  OpenClaimEnable;
  CheckEquals(0, Driver.ResetPrinter, 'Driver.ResetPrinter');
  Driver.SetHeaderLine(1, ' ', False);
  Driver.SetHeaderLine(2, '  Восточно-Казастанская область, город', False);
  Driver.SetHeaderLine(3, '    Усть-Каменогорск, ул. Грейдерная, 1/10', False);
  Driver.SetHeaderLine(4, '    ТОО PetroRetail', True);

  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_CASH_IN);
  CheckEquals(FPTR_RT_CASH_IN, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));
  FptrCheck(Driver.BeginFiscalReceipt(FPrintHeader));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  FptrCheck(Driver.PrintRecCash(10));
  FptrCheck(Driver.PrintRecCash(20));
  FptrCheck(Driver.PrintRecCash(30));
  FptrCheck(Driver.PrintRecTotal(0, 10, ''));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT_TOTAL, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  FptrCheck(Driver.PrintRecTotal(0, 20, ''));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT_TOTAL, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  FptrCheck(Driver.PrintRecTotal(0, 30, ''));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT_ENDING, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  FptrCheck(Driver.EndFiscalReceipt(not FPrintHeader));
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
end;

procedure TWebkassaImplTest.TestCashIn2;
begin
  FPrintHeader := True;
  //FPrintHeader := False;
  TestCashIn;
end;

procedure TWebkassaImplTest.TestCashOut;
begin
  OpenClaimEnable;
  CheckEquals(0, Driver.ResetPrinter, 'Driver.ResetPrinter');
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_CASH_OUT);
  CheckEquals(FPTR_RT_CASH_OUT, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));
  FptrCheck(Driver.BeginFiscalReceipt(False));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  FptrCheck(Driver.PrintRecCash(10));
  FptrCheck(Driver.PrintRecCash(20));
  FptrCheck(Driver.PrintRecCash(30));
  FptrCheck(Driver.PrintRecTotal(0, 10, ''));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT_TOTAL, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  FptrCheck(Driver.PrintRecTotal(0, 20, ''));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT_TOTAL, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  FptrCheck(Driver.PrintRecTotal(0, 30, ''));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT_ENDING, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  FptrCheck(Driver.EndFiscalReceipt(True));
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
end;

procedure TWebkassaImplTest.TestZReport;
begin
  OpenClaimEnable;
  CheckEquals(0, Driver.PrintZReport, 'Driver.PrintZReport');
end;

procedure TWebkassaImplTest.TestXReport;
begin
  OpenClaimEnable;
  CheckEquals(0, Driver.PrintXReport, 'Driver.PrintXReport');
end;

procedure TWebkassaImplTest.TestNonFiscal;
begin
  OpenClaimEnable;
  CheckEquals(0, Driver.ResetPrinter, 'ResetPrinter');
  CheckEquals(0, Driver.BeginNonFiscal, 'BeginNonFiscal');
  CheckEquals(0, Driver.PrintNormal(FPTR_S_RECEIPT, 'Строка для печати 1'));
  CheckEquals(0, Driver.PrintNormal(FPTR_S_RECEIPT, 'Строка для печати 2'));
  CheckEquals(0, Driver.PrintNormal(FPTR_S_RECEIPT, 'Строка для печати 3'));
  CheckEquals(0, Driver.EndNonFiscal, 'EndNonFiscal');
end;

procedure TWebkassaImplTest.TestFiscalReceipt;
begin
  OpenClaimEnable;
  CheckEquals(0, Driver.ResetPrinter, 'Driver.ResetPrinter');
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  CheckEquals(FPTR_RT_SALES, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));

  FptrCheck(Driver.BeginFiscalReceipt(True));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT, Driver.GetPropertyNumber(PIDXFptr_PrinterState));

  //FptrCheck(Driver.PrintRecItem('Item 1', 123.45, 1000, 0, 123.45, 'кг'));
  FptrCheck(Driver.PrintRecItem('Сер. № 5                                  ШОКОЛАДНАЯ ПЛИТКА MILKA BUBBLES МОЛОЧНЫЙ', 590, 1000, 4, 590, 'шт'));
  FptrCheck(Driver.PrintRecTotal(12345, 12345, '0'));

  CheckEquals(FPTR_PS_FISCAL_RECEIPT_ENDING, Driver.GetPropertyNumber(PIDXFptr_PrinterState));

  FptrCheck(Driver.EndFiscalReceipt(False));
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
end;

procedure TWebkassaImplTest.TestFiscalReceipt2;
begin
  FDriver.Params.RoundType := RoundTypeItems;

  OpenClaimEnable;
  CheckEquals(0, Driver.ResetPrinter, 'Driver.ResetPrinter');
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  CheckEquals(FPTR_RT_SALES, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));

  FptrCheck(Driver.BeginFiscalReceipt(True));
  FptrCheck(Driver.PrintRecItem('ТРК 1:АИ-98', 578, 3302, 4, 175, ''));
  FptrCheck(Driver.PrintRecItem('Киви в корзинке Астана', 620, 1000, 4, 620, 'шт'));
  FptrCheck(Driver.PrintRecItem('Ананас штучно Астана', 1250, 1000, 4, 1250, 'шт'));
  FptrCheck(Driver.PrintRecItem('Арбуз штучно Астана', 650, 1000, 4, 650, 'шт'));
  FptrCheck(Driver.PrintRecTotal(3098, 2521, '1'));
  FptrCheck(Driver.PrintRecTotal(3098, 577, '0'));
  FptrCheck(Driver.EndFiscalReceipt(False));
end;

procedure TWebkassaImplTest.TestFiscalReceipt3;
begin
  FDriver.Params.RoundType := RoundTypeItems;

  OpenClaimEnable;
  CheckEquals(0, Driver.ResetPrinter, 'Driver.ResetPrinter');
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  CheckEquals(FPTR_RT_SALES, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));

  FptrCheck(Driver.BeginFiscalReceipt(True));
  FptrCheck(Driver.PrintRecItem('Киви в корзинке Астана', 620, 1000, 4, 620, 'шт'));
  FptrCheck(Driver.PrintRecItem('Americano 180мл', 400, 1000, 4, 400, 'шт'));
  FptrCheck(Driver.PrintRecItemAdjustment(1, '98', 40, 4));
  FptrCheck(Driver.PrintRecTotal(980, 980, '0'));
  FptrCheck(Driver.EndFiscalReceipt(False));
end;

procedure TWebkassaImplTest.TestFiscalReceiptWithVAT;
begin
  FDriver.Params.VatRates.Clear;
  FDriver.Params.VatRates.Add(4, 12, 'Tax1');
  FDriver.Params.VatRateEnabled := True;
  FDriver.Params.RoundType := RoundTypeItems;

  OpenClaimEnable;
  CheckEquals(0, Driver.ResetPrinter, 'Driver.ResetPrinter');
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  CheckEquals(FPTR_RT_SALES, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));

  FptrCheck(Driver.BeginFiscalReceipt(True));
  FptrCheck(Driver.PrintRecItem('Киви в корзинке Астана', 620, 1000, 4, 620, 'шт'));
  FptrCheck(Driver.PrintRecItem('Americano 180мл', 400, 1000, 4, 400, 'шт'));
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_AMOUNT_DISCOUNT, '98', 40, 4));
  FptrCheck(Driver.PrintRecTotal(980, 980, '0'));
  FptrCheck(Driver.EndFiscalReceipt(False));
end;

procedure TWebkassaImplTest.CheckTotal(Amount: Currency);
var
  IData: Integer;
  Data: WideString;
  Total: Currency;
begin
  CheckEquals(0, Driver.GetData(FPTR_GD_CURRENT_TOTAL, IData, Data));
  Total := StrToCurr(Data);
  CheckEquals(Amount, Total, 'Total');
end;

procedure TWebkassaImplTest.TestFiscalReceiptWithAdjustments;
begin
  FDriver.Params.VatRates.Clear;
  FDriver.Params.VatRates.Add(4, 12, 'Tax1');
  FDriver.Params.VatRateEnabled := True;
  FDriver.Params.RoundType := RoundTypeItems;

  OpenClaimEnable;
  Driver.SetPropertyNumber(PIDXFptr_CheckTotal, 1);
  CheckEquals(0, Driver.ResetPrinter, 'Driver.ResetPrinter');
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  CheckEquals(FPTR_RT_SALES, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));

  FptrCheck(Driver.BeginFiscalReceipt(True));
  CheckTotal(0);
  FptrCheck(Driver.PrintRecItem('Киви в корзинке Астана', 620, 1000, 4, 620, 'шт'));
  CheckTotal(620);
  FptrCheck(Driver.PrintRecItem('Americano 180мл', 400, 1000, 4, 400, 'шт'));
  CheckTotal(1020);
  // Item adjustments
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_AMOUNT_DISCOUNT, 'Скидка 40', 40, 4));
  CheckTotal(980);
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_AMOUNT_SURCHARGE, 'Надбавка 12', 12, 4));
  CheckTotal(992);
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_PERCENTAGE_DISCOUNT, 'Скидка 10%', 10, 4));
  CheckTotal(955);
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_PERCENTAGE_SURCHARGE, 'Надбавка 5%', 5, 4));
  CheckTotal(972);
  // Total adjustments
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_AMOUNT_DISCOUNT, 'Скидка 10', 10));
  CheckTotal(962);
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_AMOUNT_SURCHARGE, 'Надбавка 5', 5));
  CheckTotal(967);
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_PERCENTAGE_DISCOUNT, 'Скидка 10%', 10));
  CheckTotal(870);
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_PERCENTAGE_SURCHARGE, 'Надбавка 5%', 5));
  CheckTotal(914);

  FptrCheck(Driver.PrintRecTotal(914, 1000, '0'));
  FptrCheck(Driver.EndFiscalReceipt(False));
end;

///////////////////////////////////////////////////////////////////////////////
//
// Проверить чек возврата
// Проверить чек возврата со скидками
// Проверить запросы getData
//
///////////////////////////////////////////////////////////////////////////////


procedure TWebkassaImplTest.TestPrintBarcode;
const
  Barcode = 'http://dev.kofd.kz/consumer?i=925871425876&f=211030200207&s=15443.72&t=20220826T210014';
begin
  OpenClaimEnable;
  Driver.PrintQRCode(Barcode);
end;

procedure TWebkassaImplTest.TestGetData;
var
  OptArgs: Integer;
  Data: WideString;
  DataExpected: WideString;
begin
  OpenClaimEnable;
  OptArgs := 0;
  Data := '';
  FptrCheck(Driver.GetData(FPTR_GD_GRAND_TOTAL, OptArgs, Data));
  DataExpected := Driver.ReadCashboxStatus.Field['Data'].Field[
    'CurrentState'].Field['XReport'].Field['SumInCashbox'].Value;
  CheckEquals(DataExpected, Data, 'FPTR_GD_GRAND_TOTAL');
  FptrCheck(Driver.GetData(FPTR_GD_DAILY_TOTAL, OptArgs, Data));
end;


initialization
  RegisterTest('', TWebkassaImplTest.Suite);

end.

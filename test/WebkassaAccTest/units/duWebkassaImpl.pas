
unit duWebkassaImpl;

interface

uses
  // VCL
  Windows, SysUtils, Classes, Forms,
  // DUnit
  TestFramework,
  // Opos
  Opos, OposFptr, Oposhi, OposFptrhi, OposFptrUtils, OposUtils,
  // Tnt
  TntClasses, TntSysUtils,
  // This
  LogFile, WebkassaImpl, WebkassaClient, MockPosPrinter, PrinterParameters,
  SerialPort, DirectIOAPI, FileUtils, oleFiscalPrinter, StringUtils;

const
  CRLF = #13#10;

type
  { TWebkassaImplTest }

  TWebkassaImplTest = class(TTestCase)
  private
    function GetParams: TPrinterParameters;
  private
    FPrintHeader: Boolean;
    procedure ClaimDevice;
    procedure EnableDevice;
    procedure OpenService;
    procedure FptrCheck(Code: Integer); overload;
    procedure FptrCheck(Code: Integer; const AText: WideString); overload;
    procedure CheckTotal(Amount: Currency);
    function DirectIO2(Command: Integer; const pData: Integer;
      const pString: WideString): Integer;

    property Params: TPrinterParameters read GetParams;
  protected
    procedure SetUp; override;
    procedure TearDown; override;

    procedure TestEvents;
  published
    procedure OpenClaimEnable;
    procedure TestCashIn;
    procedure TestCashIn2;
    procedure TestCashOut;
    procedure TestZReport;
    procedure TestXReport;
    procedure TestNonFiscal;
    procedure TestFiscalReceipt;
    procedure TestPrintReceiptDuplicate;
    procedure TestFiscalReceipt2;
    procedure TestFiscalReceipt3;
    procedure TestFiscalReceipt4;
    procedure TestFiscalReceipt5;
    procedure TestFiscalReceipt6;
    procedure TestFiscalReceipt7;
    procedure TestFiscalReceiptWithVAT;
    procedure TestFiscalReceiptWithAdjustments;
    procedure TestFiscalReceiptWithAdjustments2;
    procedure TestFiscalReceiptWithAdjustments3;
    procedure TestPrintBarcode;
    procedure TestGetData;
    procedure TestFontB;
  end;

implementation

{ TWebkassaImplTest }

var
  Driver: ToleFiscalPrinter;
  Printer: TMockPOSPrinter;

function TWebkassaImplTest.GetParams: TPrinterParameters;
begin
  Result := Driver.Driver.Params;
end;

procedure TWebkassaImplTest.FptrCheck(Code: Integer);
begin
  FptrCheck(Code, '');
end;

procedure TWebkassaImplTest.FptrCheck(Code: Integer; const AText: WideString);
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
      Text := Tnt_WideFormat('%s: %d, %d, %s [%s]', [AText, ResultCode,
        ResultCodeExtended, GetResultCodeExtendedText(ResultCodeExtended),
        ErrorString])
    else
      Text := Tnt_WideFormat('%s: %d, %s [%s]', [AText, ResultCode,
        GetResultCodeText(ResultCode), ErrorString]);

    raise Exception.Create(Text);
  end;
end;

procedure TWebkassaImplTest.SetUp;
begin
  inherited SetUp;
  if Printer = nil then
  begin
    Printer := TMockPOSPrinter.Create(nil);
  end;
  if Driver = nil then
  begin
    Driver := ToleFiscalPrinter.Create;
    Driver.Driver.Printer := Printer;
    Driver.Driver.LoadParamsEnabled := False;

    Params.LogFileEnabled := True;
    Params.LogMaxCount := 10;
    Params.LogFilePath := GetModulePath + 'Logs';
(*
    Params.Login := 'webkassa4@softit.kz';
    Params.Password := 'Kassa123';
    Params.CashboxNumber := 'SWK00033059';
*)
    Params.Login := 'apykhtin@ibtsmail.ru';
    Params.Password := 'Kassa123!';
    Params.CashboxNumber := 'SWK00033444';

    Params.ConnectTimeout := 10;
    Params.WebkassaAddress := 'https://devkkm.webkassa.kz';
    //Params.WebkassaAddress := 'http://localhost:1332';

    Params.NumHeaderLines := 6;
    Params.NumTrailerLines := 3;
    Params.RoundType := RoundTypeNone;

    Params.HeaderText :=
      ' ' + CRLF +
      '                  ТОО PetroRetail                 230498234              029384     203948' + CRLF +
      '                 БИН 181040037076                 ' + CRLF +
      '             НДС Серия 60001 № 1204525            ' + CRLF +
      '               АЗС №Z-5555 (Касса 1)              ' + CRLF +
      '                       стенд                      ';

    Params.TrailerText :=
      '           Callцентр 039458039850 ' + CRLF +
      '          Горячая линия 20948802934' + CRLF +
      '            СПАСИБО ЗА ПОКУПКУ';

    Params.PaymentType2 := 1;
    Params.PaymentType3 := 4;
    Params.PaymentType4 := 4;
    Params.VatRateEnabled := True;
    Params.RoundType := RoundTypeItems;
    Params.VATSeries := '12347';
    Params.VATNumber := '7654321';
    Params.AmountDecimalPlaces := 2;
    Params.VatRates.Clear;
    Params.VatRates.Add(1, 12, 'НДС 12%');

  (*
    // Network
    Params.PrinterType := PrinterTypeEscPrinterNetwork;
    Params.RemoteHost := '10.11.7.176';
    Params.RemotePort := 9100;
    Params.ByteTimeout := 1000;
    Params.FontName := 'FontA11';

    // Serial
    Params.PrinterType := PrinterTypeEscPrinterSerial;
    Params.ByteTimeout := 500;
    Params.FontName := 'FontA11';
    Params.PortName := 'COM6';
    Params.BaudRate := 19200;
    Params.DataBits := DATABITS_8;
    Params.StopBits := ONESTOPBIT;
    Params.Parity := NOPARITY;
    Params.FlowControl := FLOW_CONTROL_NONE;
    Params.ReconnectPort := False;
  *)
    Params.PrinterType := PrinterTypeEscPrinterWindows;
    Params.PrinterName := 'RONGTA 80mm Series Printer';
    Params.FontName := 'FontA11';
  end;
end;

procedure TWebkassaImplTest.TearDown;
begin
  inherited TearDown;
end;

procedure TWebkassaImplTest.OpenService;
begin
  if Driver.GetPropertyNumber(PIDX_State) = OPOS_S_CLOSED then
  begin
    FptrCheck(Driver.OpenService(OPOS_CLASSKEY_FPTR, 'DeviceName', nil));
    Driver.SetPropertyNumber(PIDX_PowerNotify, OPOS_PN_ENABLED);
  end;
end;

procedure TWebkassaImplTest.ClaimDevice;
begin
  if Driver.GetPropertyNumber(PIDX_Claimed) = 0 then
  begin
    CheckEquals(0, Driver.GetPropertyNumber(PIDX_Claimed),
      'GetPropertyNumber(PIDX_Claimed)');
    FptrCheck(Driver.ClaimDevice(1000));
    CheckEquals(1, Driver.GetPropertyNumber(PIDX_Claimed),
      'GetPropertyNumber(PIDX_Claimed)');
  end;
end;

procedure TWebkassaImplTest.EnableDevice;
var
  ResultCode: Integer;
begin
  if Driver.GetPropertyNumber(PIDX_DeviceEnabled) = 0 then
  begin
    Driver.SetPropertyNumber(PIDX_DeviceEnabled, 1);
    ResultCode := Driver.GetPropertyNumber(PIDX_ResultCode);
    FptrCheck(ResultCode);

    CheckEquals(OPOS_SUCCESS, ResultCode, 'OPOS_SUCCESS');
    CheckEquals(1, Driver.GetPropertyNumber(PIDX_DeviceEnabled), 'DeviceEnabled');
  end;
end;

procedure TWebkassaImplTest.OpenClaimEnable;
begin
  OpenService;
  ClaimDevice;
  EnableDevice;
  FptrCheck(Driver.ResetPrinter, 'ResetPrinter');
end;

procedure TWebkassaImplTest.TestCashIn;
begin
  OpenClaimEnable;
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
  FptrCheck(Driver.PrintZReport, 'PrintZReport');
end;

procedure TWebkassaImplTest.TestXReport;
begin
  OpenClaimEnable;
  FptrCheck(Driver.PrintXReport, 'PrintXReport');
end;

procedure TWebkassaImplTest.TestNonFiscal;
begin
  OpenClaimEnable;
  FptrCheck(Driver.BeginNonFiscal, 'BeginNonFiscal');
  FptrCheck(Driver.PrintNormal(FPTR_S_RECEIPT, 'Строка для печати 1'));
  FptrCheck(Driver.PrintNormal(FPTR_S_RECEIPT, 'Строка для печати 2'));
  FptrCheck(Driver.PrintNormal(FPTR_S_RECEIPT, 'Строка для печати 3'));
  FptrCheck(Driver.EndNonFiscal, 'EndNonFiscal');
  //Application.MessageBox('Restart printer', 'Attention');

  FptrCheck(Driver.ResetPrinter, 'ResetPrinter');
  FptrCheck(Driver.BeginNonFiscal, 'BeginNonFiscal');
  FptrCheck(Driver.PrintNormal(FPTR_S_RECEIPT, 'Строка для печати 1'));
  FptrCheck(Driver.PrintNormal(FPTR_S_RECEIPT, 'Строка для печати 2'));
  FptrCheck(Driver.PrintNormal(FPTR_S_RECEIPT, 'Строка для печати 3'));
  FptrCheck(Driver.EndNonFiscal, 'EndNonFiscal');
end;

procedure TWebkassaImplTest.TestFiscalReceipt;
begin
  OpenClaimEnable;
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


procedure TWebkassaImplTest.TestPrintReceiptDuplicate;
const
  ReceiptLines: array [0..38] of string = (
    '|bC              ДУБЛИКАТ',
    '       ТОО SOFT IT KAZAKHSTAN',
    '          БИН 131240010479',
    'НДС Серия 00000            № 0000000',
    '------------------------------------',
    '             Касса 2.0.2',
    '              Смена 213',
    '      Порядковый номер чека №13',
    'Чек №1176446355471',
    'Кассир apykhtin@ibtsmail.ru',
    'ПРОДАЖА',
    '------------------------------------',
    '  1. Сер. № 5',
    '           ШОКОЛАДНАЯ ПЛИТКА MILKA',
    'BUBBLES МОЛОЧНЫЙ',
    '   1 шт x 590,00',
    '   Стоимость                  590,00',
    '------------------------------------',
    'Наличные:                  12 345,00',
    'Сдача:                     11 755,00',
    '|bCИТОГО:                        590,00',
    '------------------------------------',
    'Фискальный признак: 1176446355471',
    'Время: 25.09.2023 17:20:28',
    'Оператор фискальных данных: АО',
    '"КазТранском"',
    'Для проверки чека зайдите на сайт:',
    'dev.kofd.kz/consumer',
    '------------------------------------',
    '|bC           ФИСКАЛЬНЫЙ ЧЕК',
    'http://dev.kofd.kz/consumer?i=174431930345',
    '1&f=427490326691&s=590.00&t=20230925T17202',
    '8            ИНК ОФД: 657',
    '             WEBKASSA.KZ',
    '          ЗНМ: SWK00033444',
    '             WEBKASSA.KZ',
    '           Callцентр 039458039850',
    '          Горячая линия 20948802934',
    '            СПАСИБО ЗА ПОКУПКУ');

var
  i: Integer;
  pData: Integer;
  pString: WideString;
  ExternalCheckNumber: WideString;
begin
  TestFiscalReceipt;

  Printer.Clear;
  FptrCheck(Printer.Lines.Count, 'Printer.Lines.Count');
  CheckEquals('', Printer.Lines.Text, 'Printer.Lines.Text');

  pString := '';
  pData := DriverParameterExternalCheckNumber;
  FptrCheck(Driver.DirectIO(DIO_GET_DRIVER_PARAMETER, pData, pString),
    'Driver.DirectIO(DIO_GET_DRIVER_PARAMETER, pData, pString)');

  pData := 0;
  ExternalCheckNumber := pString;
  FptrCheck(Driver.DirectIO(DIO_PRINT_RECEIPT_DUPLICATE, pData, ExternalCheckNumber),
    'DirectIO(DIO_PRINT_RECEIPT_DUPLICATE, 0, ExternalCheckNumber)');

  //CheckEquals(47, Printer.Lines.Count, 'Printer.Lines.Count');
  for i := 0 to 4 do
  begin
    CheckEquals(TrimRight(ReceiptLines[i]), TrimRight(Printer.Lines[i]), 'Line ' + IntToStr(i));
  end;
  for i := 9 to 21 do
  begin
    CheckEquals(TrimRight(ReceiptLines[i]), TrimRight(Printer.Lines[i]), 'Line ' + IntToStr(i));
  end;
  for i := 24 to 29 do
  begin
    CheckEquals(TrimRight(ReceiptLines[i]), TrimRight(Printer.Lines[i]), 'Line ' + IntToStr(i));
  end;
  for i := 34 to 38 do
  begin
    CheckEquals(TrimRight(ReceiptLines[i]), TrimRight(Printer.Lines[i]), 'Line ' + IntToStr(i));
  end;
end;


procedure TWebkassaImplTest.TestFiscalReceipt2;
begin
  Params.RoundType := RoundTypeItems;

  OpenClaimEnable;
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
  Params.RoundType := RoundTypeItems;

  OpenClaimEnable;
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

procedure TWebkassaImplTest.TestFiscalReceipt4;
begin
  OpenClaimEnable;
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  CheckEquals(FPTR_RT_SALES, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));

  FptrCheck(Driver.BeginFiscalReceipt(True));
  FptrCheck(Driver.PrintRecItem('ШОКОЛАДНЫЙ БАТОНЧИК TWIX 55 ГР.', 236, 1000, 4, 236, 'шт'));
  FptrCheck(Driver.PrintRecTotal(236, 236, '2'));
  FptrCheck(Driver.EndFiscalReceipt(False));
end;

procedure TWebkassaImplTest.TestFiscalReceipt5;
begin
  Params.RoundType := RoundTypeTotal;
  OpenClaimEnable;
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  FptrCheck(Driver.BeginFiscalReceipt(True));
  FptrCheck(Driver.PrintRecItem('Яблоки', 333, 1000, 4, 333, 'кг'));
  FptrCheck(Driver.PrintRecTotal(333, 333, '0'));
  FptrCheck(Driver.PrintRecMessage('Оператор ts1'));
  FptrCheck(Driver.PrintRecMessage('ID:      29211 '));
  FptrCheck(Driver.EndFiscalReceipt(False));
end;

function TWebkassaImplTest.DirectIO2(Command: Integer;
  const pData: Integer; const pString: WideString): Integer;
var
  pData2: Integer;
  pString2: WideString;
begin
  pData2 := pData;
  pString2 := pString;
  Result := Driver.DirectIO(Command, pData2, pString2);
end;

procedure TWebkassaImplTest.TestFiscalReceipt6;
begin
  Params.RoundType := RoundTypeTotal;

  OpenClaimEnable;
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  FptrCheck(Driver.BeginFiscalReceipt(True));

  FptrCheck(DirectIO2(30, 72, '4'));
  FptrCheck(DirectIO2(30, 73, '1'));
  FptrCheck(Driver.PrintRecItem('ТРК 1:АИ-92-К4/К5', 139, 870, 4, 160, 'л'));
  FptrCheck(Driver.PrintRecTotal(139, 139, '1'));
  FptrCheck(Driver.PrintRecMessage('Kaspi аварийный   №2832880234      '));
  FptrCheck(Driver.PrintRecMessage('Оператор: Кассир1'));
  FptrCheck(Driver.PrintRecMessage('Транз.:      11822 '));
  FptrCheck(Driver.PrintRecMessage('Транз. продажи: 11820 (200,00 тг)'));
  FptrCheck(Driver.EndFiscalReceipt(False));
end;

procedure TWebkassaImplTest.TestFiscalReceipt7;
var
  RecNumber: string;
begin
  RecNumber := CreateGUIDStr;
  Params.RoundType := RoundTypeTotal;

  OpenClaimEnable;
  FptrCheck(Driver.ClearError, 'ClearError');
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  FptrCheck(Driver.BeginFiscalReceipt(True));
  FptrCheck(DirectIO2(30, 72, '4'));
  FptrCheck(DirectIO2(30, 73, '1'));
  FptrCheck(Driver.PrintRecItem('ШОКОЛАДНЫЙ БАТОНЧИК SNICKERS 50ГР.', 1180, 1000, 4, 1180, 'шт'));
  FptrCheck(Driver.PrintRecTotal(1180, 1180, '0'));
  FptrCheck(Driver.PrintRecMessage('Оператор: ts'));
  FptrCheck(Driver.PrintRecMessage('ID:      ' + RecNumber));
  FptrCheck(DirectIO2(DIO_SET_DRIVER_PARAMETER, DriverParameterExternalCheckNumber, RecNumber));
  FptrCheck(Driver.EndFiscalReceipt(False));
end;

procedure TWebkassaImplTest.TestFiscalReceiptWithVAT;
begin
  Params.VatRates.Clear;
  Params.VatRates.Add(4, 12, 'Tax1');
  Params.VatRateEnabled := True;
  Params.RoundType := RoundTypeItems;

  OpenClaimEnable;
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
  FptrCheck(Driver.GetData(FPTR_GD_CURRENT_TOTAL, IData, Data));
  Total := StrToCurr(Data)/100;
  CheckEquals(Amount, Total, 'Total');
end;

procedure TWebkassaImplTest.TestFiscalReceiptWithAdjustments;
begin
  Params.VatRates.Clear;
  Params.VatRates.Add(4, 12, 'Tax1');
  Params.VatRateEnabled := True;
  Params.RoundType := RoundTypeNone;

  OpenClaimEnable;
  Driver.SetPropertyNumber(PIDXFptr_CheckTotal, 1);
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
  CheckTotal(952);
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_PERCENTAGE_SURCHARGE, 'Надбавка 5%', 5, 4));
  CheckTotal(972);
  // Total adjustments
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_AMOUNT_DISCOUNT, 'Скидка 10', 10));
  CheckTotal(962);
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_AMOUNT_SURCHARGE, 'Надбавка 5', 5));
  CheckTotal(967);
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_PERCENTAGE_DISCOUNT, 'Скидка 10%', 10));
  CheckTotal(870.3);
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_PERCENTAGE_SURCHARGE, 'Надбавка 5%', 5));
  CheckTotal(913.82);

  FptrCheck(Driver.PrintRecTotal(913.82, 914, '0'));
  FptrCheck(Driver.EndFiscalReceipt(False));
end;

procedure TWebkassaImplTest.TestFiscalReceiptWithAdjustments2;
begin
  Params.VatRates.Clear;
  Params.VatRates.Add(4, 12, 'Tax1');
  Params.VatRateEnabled := True;
  Params.RoundType := RoundTypeTotal;

  OpenClaimEnable;
  Driver.SetPropertyNumber(PIDXFptr_CheckTotal, 1);
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
  CheckTotal(952);
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_PERCENTAGE_SURCHARGE, 'Надбавка 5%', 5, 4));
  CheckTotal(972);
  // Total adjustments
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_AMOUNT_DISCOUNT, 'Скидка 10', 10));
  CheckTotal(962);
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_AMOUNT_SURCHARGE, 'Надбавка 5', 5));
  CheckTotal(967);
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_PERCENTAGE_DISCOUNT, 'Скидка 10%', 10));
  CheckTotal(871);
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_PERCENTAGE_SURCHARGE, 'Надбавка 5%', 5));
  CheckTotal(914);

  FptrCheck(Driver.PrintRecTotal(914, 1000, '0'));
  FptrCheck(Driver.EndFiscalReceipt(False));
end;

procedure TWebkassaImplTest.TestFiscalReceiptWithAdjustments3;
begin
  Params.VatRates.Clear;
  Params.VatRates.Add(4, 12, 'Tax1');
  Params.VatRateEnabled := True;
  Params.RoundType := RoundTypeItems;

  OpenClaimEnable;
  Driver.SetPropertyNumber(PIDXFptr_CheckTotal, 1);
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  CheckEquals(FPTR_RT_SALES, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));

  FptrCheck(Driver.BeginFiscalReceipt(True));
  CheckTotal(0);
  FptrCheck(Driver.PrintRecItem('Киви в корзинке Астана', 555.52, 896, 4, 620, 'шт'));
  CheckTotal(556);
  FptrCheck(Driver.PrintRecItem('Americano 180мл', 400, 1000, 4, 400, 'шт'));
  CheckTotal(956);
  // Item adjustments
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_AMOUNT_DISCOUNT, 'Скидка 40', 40, 4));
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_AMOUNT_SURCHARGE, 'Надбавка 12', 12, 4));
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_PERCENTAGE_DISCOUNT, 'Скидка 10%', 10, 4));
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_PERCENTAGE_SURCHARGE, 'Надбавка 5%', 5, 4));
  // Total adjustments
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_AMOUNT_DISCOUNT, 'Скидка 10', 10));
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_AMOUNT_SURCHARGE, 'Надбавка 5', 5));
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_PERCENTAGE_DISCOUNT, 'Скидка 10%', 10));
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_PERCENTAGE_SURCHARGE, 'Надбавка 5%', 5));
  CheckTotal(854);
  FptrCheck(Driver.PrintRecTotal(854, 1000, '0'));
  FptrCheck(Driver.EndFiscalReceipt(False));
end;

(*
TestFiscalReceiptWithAdjustments: Exception
at  $0054BA8D
114, 309, 309 [Позиция 'Americano 180мл': Налог подсчитан неверно.
(Текущее: 42,86, Ожидалось: 37,71); Сумма чека (914,00) не совпадает
с суммой платежей (1 000,00) и сдачей (86,18)]
*)

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
  Driver.Driver.PrintQRCodeAsGraphics(Barcode);
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
  DataExpected := Driver.Driver.ReadCashboxStatus.Field['Data'].Field[
    'CurrentState'].Field['XReport'].Field['SumInCashbox'].Value;
  DataExpected := IntToStr(Trunc(StrToCurr(DataExpected) * 100));
  CheckEquals(DataExpected, Data, 'FPTR_GD_GRAND_TOTAL');
  FptrCheck(Driver.GetData(FPTR_GD_DAILY_TOTAL, OptArgs, Data));
end;


procedure TWebkassaImplTest.TestEvents;
begin
  OpenClaimEnable;
  Application.MessageBox('Change printer state', 'Attention');
end;

procedure TWebkassaImplTest.TestFontB;
begin
  OpenClaimEnable;
end;


initialization
  RegisterTest('', TWebkassaImplTest.Suite);

finalization
  Driver.Free;
  Driver := nil;
  Printer.Free;
  Printer := nil;

end.

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
  SerialPort, DirectIOAPI, FileUtils, oleFiscalPrinter, StringUtils,
  PosPrinterRongta, VatRate, EscPrinterUtils;

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
    procedure TestGetData;
  published
    procedure OpenClaimEnable;
    procedure TestCashIn;
    procedure TestCashIn2;
    procedure TestCashOut;
    procedure TestZReport;
    procedure TestXReport;
    procedure TestNonFiscal;
    procedure TestNonFiscal2;
    procedure TestNonFiscal3;
    procedure TestFiscalReceipt;
    procedure TestPrintReceiptDuplicate;
    procedure TestPrintReceiptDuplicate2;
    procedure TestFiscalReceipt2;
    procedure TestFiscalReceipt3;
    procedure TestFiscalReceipt4;
    procedure TestFiscalReceipt5;
    procedure TestFiscalReceipt6;
    procedure TestFiscalReceipt7;
    procedure TestFiscalReceipt8;
    procedure TestFiscalReceiptWithVAT;
    procedure TestFiscalReceiptWithAdjustments;
    procedure TestFiscalReceiptWithAdjustments2;
    procedure TestFiscalReceiptWithAdjustments3;
    procedure TestPrintBarcode;
    procedure TestPrint2DBarcode;
    procedure TestFontB;

    procedure TestCutterError;
    procedure TestListIndexError;
    procedure TestCutLongHeader;

    procedure TestFiscalReceipt9;
    procedure TestFiscalReceipt10;
  end;

implementation

{ TWebkassaImplTest }

var
  Driver: ToleFiscalPrinter;
  Printer: TMockPOSPrinter;

function TWebkassaImplTest.GetParams: TPrinterParameters;
begin
  Result := Driver.Params;
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
var
  VatRate: TVatRateRec;
begin
  inherited SetUp;
  (*
  if Printer = nil then
  begin
    Printer := TMockPOSPrinter.Create;
  end;
  *)
  if Driver = nil then
  begin
    Driver := ToleFiscalPrinter.Create;
    Driver.Driver.LoadParamsEnabled := False;
    Params.PrintBarcode := PrintBarcodeGraphics;
    Params.LogFileEnabled := True;
    Params.LogMaxCount := 10;
    Params.LogFilePath := GetModulePath + 'Logs';
    Params.TemplateEnabled := False;
    Params.Template.SetDefaults;
    //Params.Template.LoadFromFile('Receipt.xml');

    Params.Login := 'apykhtin@ibtsmail.ru';
    Params.Password := 'Kassa123!';
    Params.CashboxNumber := 'SWK00032944';
    Params.ConnectTimeout := 10;
    Params.WebkassaAddress := 'https://devkkm.webkassa.kz';

    Params.NumHeaderLines := 4;
    Params.NumTrailerLines := 3;
    Params.RoundType := RoundTypeNone;

    Params.HeaderText :=
      '                  ТОО PetroRetail                 ' + CRLF +
      '                 БИН 181040037076                 ' + CRLF +
      '             НДС Серия 60001 № 1204525            ' + CRLF +
      '               АЗС №Z-5555 (Касса 1) стенд        ';

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

    VatRate.Id := 1;
    VatRate.Rate := 12;
    VatRate.Name := 'VAT 12%';
    VatRate.VatType := VAT_TYPE_NORMAL;
    Params.VatRates.Add(VatRate);

    Params.LineSpacing := 0;
    Params.RecLineChars := 42;
    Params.RecLineHeight := 30;
    Params.Utf8Enabled := True;
    Params.AcceptLanguage := 'kk-KZ';

    Params.USBPort := '';
    Params.PortType := PortTypeWindows;
    Params.PrinterName := 'RONGTA 80mm Series Printer';
    Params.PrinterType := PrinterTypeWindows;
    Params.EscPrinterType := EscPrinterTypeRongta;
    Params.FontName := 'Lucida Console';
    //«Courier New», Courier, monospace
    //«Lucida Console», Monaco, monospace

    (*
    Params.PortType := PortTypeUsb;
    Params.PrinterName := 'Test';
    Params.EscPrinterType := EscPrinterTypePosiflex;

    Params.PortType := PortTypeWindows;
    Params.PrinterName := 'RONGTA 80mm Series Printer';
    Params.EscPrinterType := EscPrinterTypeRongta;
    Params.PrinterName := 'POS-80C';
    Params.EscPrinterType := EscPrinterTypeOA48;


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
    if Driver.GetPropertyNumber(PIDX_CapPowerReporting) <> 0 then
    begin
      Driver.SetPropertyNumber(PIDX_PowerNotify, OPOS_PN_ENABLED);
    end;
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
  Driver.SetPropertyNumber(PIDXFptr_CheckTotal, 1);
end;

procedure TWebkassaImplTest.TestCashIn;
begin
  Params.NumHeaderLines := 4;

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
  FptrCheck(Driver.PrintRecTotal(60, 10, ''));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT_TOTAL, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  FptrCheck(Driver.PrintRecTotal(60, 20, ''));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT_TOTAL, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  FptrCheck(Driver.PrintRecTotal(60, 30, ''));
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
  FptrCheck(Driver.PrintRecTotal(60, 10, ''));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT_TOTAL, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  FptrCheck(Driver.PrintRecTotal(60, 20, ''));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT_TOTAL, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  FptrCheck(Driver.PrintRecTotal(60, 30, ''));
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
  Params.NumHeaderLines := 3;
  Params.NumTrailerLines := 3;
  Params.RoundType := RoundTypeNone;

  Params.HeaderText :=
    '                  ТОО PetroRetail                 ' + CRLF +
    '                 БИН 181040037076                 ' + CRLF +
    '             НДС Серия 60001 № 1204525            ';

  Params.TrailerText :=
    '           Callцентр 039458039850 ' + CRLF +
    '          Горячая линия 20948802934' + CRLF +
    '            СПАСИБО ЗА ПОКУПКУ';

  OpenClaimEnable;
  FptrCheck(Driver.BeginNonFiscal, 'BeginNonFiscal');
  FptrCheck(Driver.PrintNormal(FPTR_S_RECEIPT, 'Строка для печати 1'));
  FptrCheck(Driver.PrintNormal(FPTR_S_RECEIPT, 'Строка для печати 2'));
  FptrCheck(Driver.PrintNormal(FPTR_S_RECEIPT, 'Строка для печати 3'));
  FptrCheck(Driver.EndNonFiscal, 'EndNonFiscal');
  //Application.MessageBox('Restart printer', 'Attention');

(*
  FptrCheck(Driver.ResetPrinter, 'ResetPrinter');
  FptrCheck(Driver.BeginNonFiscal, 'BeginNonFiscal');
  FptrCheck(Driver.PrintNormal(FPTR_S_RECEIPT, 'Строка для печати 1'));
  FptrCheck(Driver.PrintNormal(FPTR_S_RECEIPT, 'Строка для печати 2'));
  FptrCheck(Driver.PrintNormal(FPTR_S_RECEIPT, 'Строка для печати 3'));
  FptrCheck(Driver.EndNonFiscal, 'EndNonFiscal');
*)
end;

procedure TWebkassaImplTest.TestNonFiscal2;
begin
  OpenClaimEnable;
  FptrCheck(Driver.ResetPrinter, 'ResetPrinter');
  FptrCheck(Driver.BeginNonFiscal, 'BeginNonFiscal');
  FptrCheck(Driver.PrintNormal(2, '****************Квитанция*****************'));
  FptrCheck(Driver.PrintNormal(2, 'ТР 2:                                АИ-92'));
  FptrCheck(Driver.PrintNormal(2, '------------------------------------------'));
  FptrCheck(Driver.PrintNormal(2, 'Итого:                              2,60 л'));
  FptrCheck(Driver.PrintNormal(2, '------------------------------------------'));
  FptrCheck(Driver.PrintNormal(2, 'Талоны онлайн:                      2,60 л'));
  FptrCheck(Driver.PrintNormal(2, '2692807                            20,00 л'));
  FptrCheck(Driver.PrintNormal(2, 'Ноливной талон                    -17,40 л'));
  FptrCheck(Driver.PrintNormal(2, '------------------------------------------'));
  FptrCheck(Driver.PrintNormal(2, '29.11.2023 13:35               Чек : 31863'));
  FptrCheck(Driver.PrintNormal(2, '                  Код авторизации: 5056439'));
  FptrCheck(Driver.PrintNormal(2, '------------------------------------------'));
  FptrCheck(Driver.PrintNormal(2, 'Оператор: ts'));
  FptrCheck(Driver.PrintNormal(2, 'Нефискальный чек'));
  FptrCheck(Driver.PrintNormal(2, '------------------------------------------'));
  FptrCheck(Driver.PrintNormal(2, '29.11.2023 13:37'));
  FptrCheck(Driver.PrintNormal(2, 'Ноливной талон:'));
  FptrCheck(Driver.PrintNormal(2, '3850201740002066'));
  FptrCheck(Driver.PrintNormal(2, 'АИ-92: 17,40 л'));
  FptrCheck(Driver.PrintNormal(2, 'Используйте сегодня'));
  FptrCheck(Driver.PrintNormal(2, 'Только на данной АЗС!'));
  FptrCheck(Driver.PrintNormal(2, 'Оператор: ts'));
  FptrCheck(Driver.PrintNormal(2, 'Нефискальный чек'));
  FptrCheck(DirectIO2(7, 51, '3850201740002066;DATAMATRIX;100;8;0;'));
  FptrCheck(Driver.PrintNormal(2, ''));
  FptrCheck(Driver.EndNonFiscal);
end;

procedure TWebkassaImplTest.TestNonFiscal3;
begin
  Params.ReplaceDataMatrixWithQRCode := True;
  TestNonFiscal2;
end;

procedure TWebkassaImplTest.TestFiscalReceipt;
var
  pData: Integer;
  pString: WideString;
  TicketUrl: WideString;
  TicketUrl2: WideString;
  Description: WideString;
begin
  OpenClaimEnable;
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  CheckEquals(FPTR_RT_SALES, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));

  FptrCheck(Driver.BeginFiscalReceipt(True));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT, Driver.GetPropertyNumber(PIDXFptr_PrinterState));

  //FptrCheck(Driver.PrintRecItem('Item 1', 123.45, 1000, 0, 123.45, 'кг'));

  Description := '';
  Description := Description + WideChar(1170) + WideChar(1171);
  Description := 'ШОКОЛАДНАЯ ПЛИТКА MILKA BUBBLES МОЛОЧНЫЙ' + Description;
  FptrCheck(Driver.PrintRecItem(Description, 590, 1000, 4, 590, 'шт'));
  FptrCheck(Driver.PrintRecTotal(590, 12345, '0'));

  CheckEquals(FPTR_PS_FISCAL_RECEIPT_ENDING, Driver.GetPropertyNumber(PIDXFptr_PrinterState));

  FptrCheck(Driver.EndFiscalReceipt(False));
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));

  pData := 0;
  pString := 'TicketUrl';
  FptrCheck(Driver.DirectIO(DIO_GET_RECEIPT_RESPONSE_PARAM, pData, pString));
  CheckNotEquals(pString, 'TicketUrl', 'pString did not changed');
  CheckNotEquals(pString, '', 'pString = ""');
  TicketUrl := pString;

  pString := 'Data.TicketUrl';
  FptrCheck(Driver.DirectIO(DIO_GET_RECEIPT_RESPONSE_FIELD, pData, pString));
  CheckNotEquals(pString, 'Data.TicketUrl', 'pString did not changed');
  CheckNotEquals(pString, '', 'pString = ""');
  TicketUrl2 := pString;

  CheckEquals(TicketUrl, TicketUrl2, 'pString <> TicketUrl');

  pString := 'Data.TicketUrl';
  FptrCheck(Driver.DirectIO(DIO_GET_RESPONSE_JSON_FIELD, pData, pString));
  CheckNotEquals(pString, 'Data.TicketUrl', 'pString did not changed');
  CheckNotEquals(pString, '', 'pString = ""');

  CheckEquals(pString, TicketUrl2, 'pString <> TicketUrl2');
end;

procedure TWebkassaImplTest.TestPrintReceiptDuplicate;
const
  ReceiptText: string =
    '|bC              ДУБЛИКАТ' + CRLF +

    '       ТОО SOFT IT KAZAKHSTAN' + CRLF +
    '          БИН 131240010479' + CRLF +
    'НДС Серия 00000            № 0000000' + CRLF +
    '------------------------------------' + CRLF +
    '             Касса 2.0.2' + CRLF +
    '              Смена 213' + CRLF +
    '      Порядковый номер чека №13' + CRLF +
    'Чек №1176446355471' + CRLF +
    'Кассир apykhtin@ibtsmail.ru' + CRLF +
    'ПРОДАЖА' + CRLF +
    '------------------------------------' + CRLF +
    '  1. Сер. № 5' + CRLF +
    '           ШОКОЛАДНАЯ ПЛИТКА MILKA' + CRLF +
    'BUBBLES МОЛОЧНЫЙ' + CRLF +
    '   1 шт x 590,00' + CRLF +
    '   Стоимость                  590,00' + CRLF +
    '------------------------------------' + CRLF +
    'Наличные:                  12 345,00' + CRLF +
    'Сдача:                     11 755,00' + CRLF +
    '|bCИТОГО:                        590,00' + CRLF +
    '------------------------------------' + CRLF +
    'Фискальный признак: 1176446355471' + CRLF +
    'Время: 25.09.2023 17:20:28' + CRLF +
    'Оператор фискальных данных: АО' + CRLF +
    '"КазТранском"' + CRLF +
    'Для проверки чека зайдите на сайт:' + CRLF +
    'dev.kofd.kz/consumer' + CRLF +
    '------------------------------------' + CRLF +
    '|bC           ФИСКАЛЬНЫЙ ЧЕК' + CRLF +
    'http://dev.kofd.kz/consumer?i=174431930345' + CRLF +
    '1&f=427490326691&s=590.00&t=20230925T17202' + CRLF +
    '8            ИНК ОФД: 657' + CRLF +
    '             WEBKASSA.KZ' + CRLF +
    '          ЗНМ: SWK00033444' + CRLF +
    '             WEBKASSA.KZ' + CRLF +
    '           Callцентр 039458039850' + CRLF +
    '          Горячая линия 20948802934' + CRLF +
    '            СПАСИБО ЗА ПОКУПКУ';

var
  i: Integer;
  pData: Integer;
  pString: WideString;
  ReceiptLines: TTntStrings;
  ExternalCheckNumber: WideString;
begin
  ReceiptLines := TTntStringList.Create;
  try
    ReceiptLines.Text := ReceiptText;

    TestFiscalReceipt;

    Printer.Clear;
    CheckEquals(0, Printer.Lines.Count, 'Printer.Lines.Count');
    CheckEquals('', Printer.Lines.Text, 'Printer.Lines.Text');

    pString := '';
    pData := DriverParameterExternalCheckNumber;
    FptrCheck(Driver.DirectIO(DIO_GET_DRIVER_PARAMETER, pData, pString),
      'Driver.DirectIO(DIO_GET_DRIVER_PARAMETER, pData, pString)');

    pData := 0;
    ExternalCheckNumber := pString;
    FptrCheck(Driver.DirectIO(DIO_PRINT_RECEIPT_DUPLICATE, pData, ExternalCheckNumber),
      'DirectIO(DIO_PRINT_RECEIPT_DUPLICATE, 0, ExternalCheckNumber)');

    WriteFileData('Duplicate1.txt', REceiptLines.Text);
    WriteFileData('Duplicate2.txt', Printer.Lines.Text);

    CheckEquals(41, Printer.Lines.Count, 'Printer.Lines.Count');
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
  finally
    ReceiptLines.Free;
  end;
end;


procedure TWebkassaImplTest.TestFiscalReceipt2;
begin
  Params.FontName := FontNameA;
  Params.NumHeaderLines := 3;
  Params.NumTrailerLines := 3;
  Params.HeaderText :=
    '           ТОО PetroRetail      ' + CRLF +
    '        БИН 181040037076        ' + CRLF +
    '    НДС Серия 60001 № 1204525   ' + CRLF +
    '       АЗС №Z-5555 (Касса 1)    ';

  Params.TrailerText :=
    '    Callцентр 039458039850      ' + CRLF +
    '   Горячая линия 20948802934    ' + CRLF +
    '      СПАСИБО ЗА ПОКУПКУ        ';
  Params.RoundType := RoundTypeItems;

  OpenClaimEnable;
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  CheckEquals(FPTR_RT_SALES, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));

  FptrCheck(Driver.BeginFiscalReceipt(True));
  FptrCheck(Driver.PrintRecItem('1. Item 1 ' + GetKazakhUnicodeChars, 578, 3302, 4, 175, ''));
  FptrCheck(Driver.PrintRecItem('2. Item 2 ' + GetKazakhUnicodeChars, 620, 1000, 4, 620, 'шт'));
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

procedure TWebkassaImplTest.TestFiscalReceipt8;
begin
  OpenClaimEnable;
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  FptrCheck(Driver.BeginFiscalReceipt(True));
  FptrCheck(Driver.PrintRecItem('ТРК 1:АИ-92-К4/К5', 101, 500, 4, 202, 'л'));
  FptrCheck(Driver.PrintRecTotal(101, 1000, '0'));
  FptrCheck(Driver.PrintRecMessage('Оператор: Кассир1'));
  FptrCheck(Driver.PrintRecMessage('Транз.:      16770 '));
  FptrCheck(Driver.PrintRecMessage('Транз. продажи: 16768 (1000,00 тг)'));
  FptrCheck(Driver.EndFiscalReceipt(False));
end;

procedure TWebkassaImplTest.TestFiscalReceiptWithVAT;
var
  VatRate: TVatRateRec;
begin
  Params.VatRates.Clear;
  VatRate.ID := 4;
  VatRate.Rate := 12;
  VatRate.Name := 'Tax1';
  VatRate.VatType := VAT_TYPE_NORMAL;
  Params.VatRates.Add(VatRate);
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
  Total := StrToCurr(Data);
  CheckEquals(Amount, Total, 'Total');
end;

procedure TWebkassaImplTest.TestFiscalReceiptWithAdjustments;
var
  VatRate: TVatRateRec;
begin
  Params.VatRates.Clear;
  VatRate.ID := 4;
  VatRate.Rate := 12;
  VatRate.Name := 'Tax1';
  VatRate.VatType := VAT_TYPE_NORMAL;
  Params.VatRates.Add(VatRate);
  Params.VatRateEnabled := True;
  Params.RoundType := RoundTypeNone;

  OpenClaimEnable;
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
var
  VatRate: TVatRateRec;
begin
  Params.VatRates.Clear;
  VatRate.ID := 4;
  VatRate.Rate := 12;
  VatRate.Name := 'Tax1';
  VatRate.VatType := VAT_TYPE_NORMAL;
  Params.VatRates.Add(VatRate);
  Params.VatRateEnabled := True;
  Params.RoundType := RoundTypeTotal;

  OpenClaimEnable;
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
var
  VatRate: TVatRateRec;
begin
  Params.VatRates.Clear;
  VatRate.ID := 4;
  VatRate.Rate := 12;
  VatRate.Name := 'Tax1';
  VatRate.VatType := VAT_TYPE_NORMAL;
  Params.VatRates.Add(VatRate);
  Params.VatRateEnabled := True;
  Params.RoundType := RoundTypeItems;

  OpenClaimEnable;
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
  FptrCheck(Driver.ResetPrinter, 'ResetPrinter');
  FptrCheck(Driver.BeginNonFiscal, 'BeginNonFiscal');

  FptrCheck(Driver.PrintNormal(FPTR_S_RECEIPT, 'DIO_BARCODE_PDF417'));
  FptrCheck(DirectIO2(7, DIO_BARCODE_PDF417, Barcode));

  FptrCheck(Driver.PrintNormal(FPTR_S_RECEIPT, 'DIO_BARCODE_AZTEC'));
  FptrCheck(DirectIO2(7, DIO_BARCODE_AZTEC, Barcode));

  FptrCheck(Driver.PrintNormal(FPTR_S_RECEIPT, 'DIO_BARCODE_QRCODE'));
  FptrCheck(DirectIO2(7, DIO_BARCODE_QRCODE, Barcode));

  FptrCheck(Driver.PrintNormal(FPTR_S_RECEIPT, 'DIO_BARCODE_DATAMATRIX'));
  FptrCheck(DirectIO2(7, DIO_BARCODE_DATAMATRIX, Barcode));

  FptrCheck(Driver.EndNonFiscal);
end;

procedure TWebkassaImplTest.TestPrint2DBarcode;

  procedure PrintBarcodes;
  const
    Barcode = 'http://dev.kofd.kz/consumer?i=925871425876&f=211030200207&s=15443.72&t=20220826T210014';
  begin
    FptrCheck(Driver.PrintNormal(FPTR_S_RECEIPT, 'DIO_BARCODE_PDF417' + CRLF));
    FptrCheck(DirectIO2(7, DIO_BARCODE_PDF417, Barcode));

    FptrCheck(Driver.PrintNormal(FPTR_S_RECEIPT, 'DIO_BARCODE_QRCODE' + CRLF));
    FptrCheck(DirectIO2(7, DIO_BARCODE_QRCODE, Barcode));

    FptrCheck(Driver.PrintNormal(FPTR_S_RECEIPT, 'DIO_BARCODE_DATAMATRIX' + CRLF));
    FptrCheck(DirectIO2(7, DIO_BARCODE_DATAMATRIX, Barcode));

    FptrCheck(Driver.PrintNormal(FPTR_S_RECEIPT, 'DIO_BARCODE_AZTEC' + CRLF));
    FptrCheck(DirectIO2(7, DIO_BARCODE_AZTEC, Barcode));
  end;

begin
  OpenClaimEnable;
  FptrCheck(Driver.ResetPrinter, 'ResetPrinter');

  FptrCheck(Driver.BeginNonFiscal, 'BeginNonFiscal');
  FptrCheck(Driver.PrintNormal(FPTR_S_RECEIPT, 'PrintBarcodeESCCommands'));
  Params.PrintBarcode := PrintBarcodeESCCommands;
  PrintBarcodes;
  FptrCheck(Driver.EndNonFiscal);

  FptrCheck(Driver.BeginNonFiscal, 'BeginNonFiscal');
  FptrCheck(Driver.PrintNormal(FPTR_S_RECEIPT, 'PrintBarcodeGraphics'));
  Params.PrintBarcode := PrintBarcodeGraphics;
  PrintBarcodes;
  FptrCheck(Driver.EndNonFiscal);
end;

procedure TWebkassaImplTest.TestGetData;
var
  Amount: Int64;
  Amount2: Int64;
  OptArgs: Integer;
  Data: WideString;
  DataExpected: WideString;
begin
  OpenClaimEnable;
  OptArgs := 0;
  Data := '';
  FptrCheck(Driver.GetData(FPTR_GD_GRAND_TOTAL, OptArgs, Data));
  Amount := StrToInt64(Data);
  DataExpected := Driver.Driver.ReadCashboxStatus.Field['Data'].Field[
    'CurrentState'].Field['XReport'].Field['SumInCashbox'].Value;
  DataExpected := WideFormat('%d', [Round(StrToCurr(DataExpected)*100)]);
  CheckEquals(DataExpected, Data, 'FPTR_GD_GRAND_TOTAL');

  FptrCheck(Driver.GetData(FPTR_GD_DAILY_TOTAL, OptArgs, Data));

  TestCashIn;

  FptrCheck(Driver.GetData(FPTR_GD_GRAND_TOTAL, OptArgs, Data));
  Amount2 := StrToInt64(Data);
  CheckEquals(Amount + 6000, Amount2, 'Amount.0');

  TestCashOut;

  FptrCheck(Driver.GetData(FPTR_GD_GRAND_TOTAL, OptArgs, Data));
  Amount2 := StrToInt64(Data);
  CheckEquals(Amount, Amount2, 0.001, 'Amount.1');
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

procedure TWebkassaImplTest.TestPrintReceiptDuplicate2;
begin
  OpenClaimEnable;
  FptrCheck(Driver.PrintDuplicateReceipt);
end;

procedure TWebkassaImplTest.TestCutterError;
begin
  Params.NumHeaderLines := 5;
  Params.NumTrailerLines := 3;
  Params.RoundType := RoundTypeNone;
  Params.HeaderText :=
    ' Header line 1' + CRLF +
    ' Header line 2' + CRLF +
    ' Header line 3' + CRLF +
    ' Header line 4' + CRLF +
    ' Header line 5';

  Params.TrailerText :=
    ' Trailer line 1' + CRLF +
    ' Trailer line 2' + CRLF +
    ' Trailer line 3';
  Params.PrintBarcode := PrintBarcodeESCCommands;

  OpenClaimEnable;
  Driver.SetPropertyNumber(PIDXFptr_CheckTotal, 1);
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, 4);
  FptrCheck(Driver.BeginFiscalReceipt(True));
  FptrCheck(Driver.DirectIO2(30, 72, '4'));
  FptrCheck(Driver.DirectIO2(30, 73, '1'));
  FptrCheck(Driver.PrintRecItem('ТРК 2:АИ-92-К4/К5', 2001, 10370, 4, 193, 'л'));
  FptrCheck(Driver.PrintRecItemAdjustment(1, 'Округление', 1.41, 4));
  FptrCheck(Driver.PrintRecTotal(2000, 2000, '2'));
  //FptrCheck(Driver.PrintRecTotal(2000, 2000, ''));
  FptrCheck(Driver.PrintRecMessage('VLife Клуб        №**************cLpN'));
  FptrCheck(Driver.PrintRecMessage('Kaspi QR          №8032963073      '));
  FptrCheck(Driver.PrintRecMessage('Оператор: Айдынгалиева Гульбану'));
  FptrCheck(Driver.PrintRecMessage('Транз.:    1439291 '));
  FptrCheck(Driver.DirectIO2(30, 302, '1'));
  //FptrCheck(Driver.DirectIO2(30, 300, '{EB51E167-20AB-4E95-AAA2-E1C8531048F1}'));
  FptrCheck(Driver.PrintRecMessage('Транз. продажи: 1439286 (2000,00 тг)'));
  FptrCheck(Driver.EndFiscalReceipt(False));
end;

procedure TWebkassaImplTest.TestListIndexError;
begin
  OpenClaimEnable;
  Params.PrintBarcode := PrintBarcodeESCCommands;

  FptrCheck(Driver.ResetPrinter);
  FptrCheck(Driver.ClearError);
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, 4);
  FptrCheck(Driver.BeginFiscalReceipt(True));
  FptrCheck(Driver.DirectIO2(30, 72, '4'));
  FptrCheck(Driver.DirectIO2(30, 73, '1'));
  FptrCheck(Driver.PrintRecItem('S ГРИЛЬ-ДОГ КУРИНЫЙ Q-CAFE', 1490, 1000, 4, 1490, 'шт'));
  FptrCheck(Driver.DirectIO2(120, 0, '1905903000'));
  FptrCheck(Driver.DirectIO2(30, 72, '4'));
  FptrCheck(Driver.DirectIO2(30, 73, '1'));
  FptrCheck(Driver.PrintRecItem('S ГРИЛЬ-ДОГ ГОВЯЖИЙ Q-CAFE', 1490, 1000, 4, 1490, 'шт'));
  FptrCheck(Driver.DirectIO2(120, 0, '1905903000'));
  FptrCheck(Driver.DirectIO2(30, 72, '4'));
  FptrCheck(Driver.DirectIO2(30, 73, '1'));
  FptrCheck(Driver.PrintRecItem('НАПИТОК ЭНЕРГЕТИЧЕСКИЙ TULPAR 450 МЛ Ж/Б', 1000, 2000, 4, 500, 'шт'));
  FptrCheck(Driver.DirectIO2(120, 0, '2202100000'));
  FptrCheck(Driver.PrintRecItemAdjustment(2, 'Акция трасса сент 24', 700, 4));
  FptrCheck(Driver.PrintRecTotal(4680, 4680, '1'));
  FptrCheck(Driver.PrintRecMessage('Halyk QR          №                '));
  FptrCheck(Driver.PrintRecMessage('Оператор: Ерпейсова Жадыра'));
  FptrCheck(Driver.PrintRecMessage('Транз.:     466000 '));
  FptrCheck(Driver.DirectIO2(30, 302, '1'));
  //FptrCheck(Driver.DirectIO2(30, 300, '{3DDDECA5-2DAD-4D14-81D6-0B2609680A0C}'));
  FptrCheck(Driver.EndFiscalReceipt(False));
end;

procedure TWebkassaImplTest.TestCutLongHeader;
begin
  Params.NumHeaderLines := 5;
  Params.NumTrailerLines := 3;
  Params.RoundType := RoundTypeNone;
  Params.HeaderText :=
    ' Header line 1' + CRLF +
    ' Header line 2' + CRLF +
    ' Header line 3' + CRLF +
    ' Header line 4' + CRLF +
    ' Header line 5';

  Params.TrailerText :=
    ' Trailer line 1' + CRLF +
    ' Trailer line 2' + CRLF +
    ' Trailer line 3';
  Params.PrintBarcode := PrintBarcodeESCCommands;

  OpenClaimEnable;
  FptrCheck(Driver.BeginNonFiscal, 'BeginNonFiscal');
  FptrCheck(Driver.PrintNormal(FPTR_S_RECEIPT, 'Строка для печати 1'));
  FptrCheck(Driver.PrintNormal(FPTR_S_RECEIPT, 'Строка для печати 2'));
  FptrCheck(Driver.PrintNormal(FPTR_S_RECEIPT, 'Строка для печати 3'));
  FptrCheck(Driver.EndNonFiscal, 'EndNonFiscal');

  FptrCheck(Driver.BeginNonFiscal, 'BeginNonFiscal');
  FptrCheck(Driver.PrintNormal(FPTR_S_RECEIPT, 'Строка для печати 1'));
  FptrCheck(Driver.PrintNormal(FPTR_S_RECEIPT, 'Строка для печати 2'));
  FptrCheck(Driver.PrintNormal(FPTR_S_RECEIPT, 'Строка для печати 3'));
  FptrCheck(Driver.EndNonFiscal, 'EndNonFiscal');
end;

procedure TWebkassaImplTest.TestFiscalReceipt9;
begin
  //Params.TemplateEnabled := True;
  Params.TemplateEnabled := False;
  Params.Template.LoadFromFile('Receipt2.xml');

  OpenClaimEnable;
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  FptrCheck(Driver.BeginFiscalReceipt(True));
  FptrCheck(Driver.DirectIO2(30, 72, '4'));
  FptrCheck(Driver.DirectIO2(30, 73, '1'));
  FptrCheck(Driver.PrintRecItem('ПАКЕТ - МАЙКА', 10, 1000, 4, 10, 'шт'));
  FptrCheck(Driver.PrintRecTotal(10, 10, '0'));
  FptrCheck(Driver.PrintRecMessage('Оператор: Плечистая Ирина Николаевна'));
  FptrCheck(Driver.PrintRecMessage('ID: 2013008'));
  FptrCheck(Driver.DirectIO2(30, 302, '1'));
  FptrCheck(Driver.DirectIO2(30, 300, CreateGUIDStr));
  FptrCheck(Driver.DirectIO2(40, 1203, '780409402215'));
  FptrCheck(Driver.EndFiscalReceipt(False));
end;

procedure TWebkassaImplTest.TestFiscalReceipt10;
begin
  Params.TemplateEnabled := True;
  Params.Template.LoadFromFile('Receipt3.xml');

  OpenClaimEnable;
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  FptrCheck(Driver.BeginFiscalReceipt(True));
  FptrCheck(Driver.DirectIO2(30, 72, '4'));
  FptrCheck(Driver.DirectIO2(30, 73, '1'));
  FptrCheck(Driver.PrintRecItem('ПАКЕТ - МАЙКА', 10, 1000, 4, 10, 'шт'));
  FptrCheck(Driver.PrintRecTotal(10, 10, '0'));
  FptrCheck(Driver.PrintRecMessage('Оператор: Плечистая Ирина Николаевна'));
  FptrCheck(Driver.PrintRecMessage('ID: 2013008'));
  FptrCheck(Driver.DirectIO2(30, 302, '1'));
  FptrCheck(Driver.DirectIO2(30, 300, CreateGUIDStr));
  FptrCheck(Driver.DirectIO2(40, 1203, '780409402215'));
  FptrCheck(Driver.EndFiscalReceipt(False));
end;

initialization
  RegisterTest('', TWebkassaImplTest.Suite);

finalization
  Driver.Free;
  Driver := nil;
  Printer.Free;
  Printer := nil;

end.

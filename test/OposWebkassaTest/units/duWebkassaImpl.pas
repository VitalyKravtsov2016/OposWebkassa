unit duWebkassaImpl;

interface

uses
  // VCL
  Windows, SysUtils, Classes, SyncObjs,
  // DUnit
  TestFramework,
  // Opos
  Opos, OposFptr, Oposhi, OposFptrhi, OposFptrUtils, OposUtils,
  OposEvents, OposPtr, RCSEvents, OposEsc,
  // Tnt
  TntClasses, TntSysUtils,
  // This
  LogFile, WebkassaImpl, WebkassaClient, MockPosPrinter, FileUtils,
  CustomReceipt, uLkJSON, ReceiptTemplate, SalesReceipt, DirectIOAPI,
  DebugUtils, StringUtils;

const
  CRLF = #13#10;

type
  { TWebkassaImplTest }

  TWebkassaImplTest = class(TTestCase, IOposEvents)
  private
    FLines: TStrings;
    FWaitEvent: TEvent;
    FEvents: TOposEvents;
    FDriver: TWebkassaImpl;
    FPrinter: TMockPosPrinter;

    procedure CheckLines;
    procedure WaitForEventsCount(Count: Integer);
  protected
    procedure ShowLines;
    procedure CheckNoEvent;
    procedure WaitForEvent;
    procedure ClaimDevice;
    procedure EnableDevice;
    procedure OpenService;
    procedure SetTemplateDefault;
    procedure FptrCheck(Code: Integer);

    property Events: TOposEvents read FEvents;
    property Driver: TWebkassaImpl read FDriver;
    procedure AddEvent(Event: TOposEvent);
  private
    // IOposEvents
    procedure DataEvent(Status: Integer);
    procedure StatusUpdateEvent(Data: Integer);
    procedure OutputCompleteEvent(OutputID: Integer);

    procedure DirectIOEvent(
      EventNumber: Integer;
      var pData: Integer;
      var pString: WideString);

    procedure ErrorEvent(
      ResultCode: Integer;
      ResultCodeExtended: Integer;
      ErrorLocus: Integer;
      var pErrorResponse: Integer);
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  public
    procedure PrintReceipt3;
    procedure TestXReport;
    procedure PrintHeaderAndCut;
  published
    procedure TestZReport;
    procedure TestCashIn;
    procedure TestCashOut;
    procedure TestNonFiscal;

    procedure OpenClaimEnable;
    procedure TestFiscalReceipt;
    procedure TestCoverError;
    procedure TestRecEmpty;
    procedure TestStatusUpateEvent;
    procedure TestDuplicateReceipt;
    procedure TestSetHeaderLines;
    procedure TestSetTrailerLines;
    procedure TestFiscalReceipt3;
    procedure TestReceiptTemplate;
    procedure TestReceiptTemplate2;
    procedure TestReceiptTemplate3;
    procedure TestGetJsonField;
    procedure TestEncoding;
    procedure TestBarcode;
  end;

implementation

const
  EventWaitTimeout  = 50;

{ TWebkassaImplTest }

procedure TWebkassaImplTest.SetUp;
begin
  inherited SetUp;
  FLines := TStringList.Create;
  FWaitEvent := TEvent.Create(nil, False, False, '');
  FEvents := TOposEvents.Create;
  FPrinter := TMockPosPrinter.Create(nil);
  FPrinter.RecLineChars := 42;
  FPrinter.FCapRecBold := False;
  FPrinter.FCapRecDwideDhigh := False;

  FDriver := TWebkassaImpl.Create(nil);
  FDriver.TestMode := True;
  FDriver.Client.TestMode := True;
  FDriver.Printer := FPrinter;
  FDriver.Params.FontName := '42';
  FDriver.Params.LogFileEnabled := False;
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
  FDriver.Params.RoundType := RoundTypeNone;

  FDriver.Params.HeaderText :=
    '                                          ' + CRLF +
    '   Восточно-Казастанская область, город   ' + CRLF +
    '  Усть-Каменогорск, ул. Грейдерная, 1/10  ' + CRLF +
    '            ТОО PetroRetail               ';
  FDriver.Params.TrailerText :=
    '           Callцентр 039458039850         ' + CRLF +
    '          Горячая линия 20948802934       ' + CRLF +
    '            СПАСИБО ЗА ПОКУПКУ            ';

  FDriver.Logger.CloseFile;
  FPrinter.FRecLinesToPaperCut := 0;
  DeleteFile(FDriver.Logger.FileName);
end;

procedure TWebkassaImplTest.TearDown;
begin
  if FDriver <> nil then
    FDriver.Close;

  FDriver.Free;
  FEvents.Free;
  FWaitEvent.Free;
  FLines.Free;
  inherited TearDown;
end;

procedure TWebkassaImplTest.WaitForEvent;
begin
  if FWaitEvent.WaitFor(EventWaitTimeout) <> wrSignaled then
    raise Exception.Create('Wait failed');
end;

procedure TWebkassaImplTest.WaitForEventsCount(Count: Integer);
begin
  repeat
    WaitForEvent;
  until Events.Count >= Count;
end;

procedure TWebkassaImplTest.CheckNoEvent;
begin
  if FWaitEvent.WaitFor(EventWaitTimeout) <> wrTimeOut then
    raise Exception.Create('Event fired');
end;

procedure TWebkassaImplTest.AddEvent(Event: TOposEvent);
begin
  FEvents.Add(Event);
  FWaitEvent.SetEvent;
end;

procedure TWebkassaImplTest.DataEvent(Status: Integer);
begin
  AddEvent(TDataEvent.Create(Status, EVENT_TYPE_INPUT, FDriver.Logger));
end;

procedure TWebkassaImplTest.DirectIOEvent(EventNumber: Integer;
  var pData: Integer; var pString: WideString);
begin
  AddEvent(TDirectIOEvent.Create(EventNumber, pData, pString, FDriver.Logger));
end;

procedure TWebkassaImplTest.ErrorEvent(ResultCode, ResultCodeExtended,
  ErrorLocus: Integer; var pErrorResponse: Integer);
begin
  AddEvent(TErrorEvent.Create(ResultCode, ResultCodeExtended, ErrorLocus, FDriver.Logger));
end;

procedure TWebkassaImplTest.OutputCompleteEvent(OutputID: Integer);
begin
  AddEvent(TOutputCompleteEvent.Create(OutputID, FDriver.Logger));
end;

procedure TWebkassaImplTest.StatusUpdateEvent(Data: Integer);
begin
  AddEvent(TStatusUpdateEvent.Create(Data, FDriver.Logger));
end;

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

procedure TWebkassaImplTest.OpenService;
begin
  FptrCheck(Driver.OpenService(OPOS_CLASSKEY_FPTR, 'DeviceName', TRCSEvents.Create(Self)));
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
const
  CashInReceiptText: string =
    '                                          ' + CRLF +
    '   Восточно-Казастанская область, город   ' + CRLF +
    '  Усть-Каменогорск, ул. Грейдерная, 1/10  ' + CRLF +
    '            ТОО PetroRetail               ' + CRLF +
    'БИН                                       ' + CRLF +
    'ЗНМ  ИНК ОФД                              ' + CRLF +
    'Дата:                                     ' + CRLF +
    'Message 1                                 ' + CRLF +
    'Message 2                                 ' + CRLF +
    'ВНЕСЕНИЕ ДЕНЕГ В КАССУ              =60.00' + CRLF +
    'НАЛИЧНЫХ В КАССЕ                     =0.00' + CRLF +
    'Message 3                                 ' + CRLF +
    'Message 4                                 ' + CRLF +
    '           Callцентр 039458039850         ' + CRLF +
    '          Горячая линия 20948802934       ' + CRLF +
    '            СПАСИБО ЗА ПОКУПКУ            ';

begin
  OpenClaimEnable;
  CheckEquals(0, Driver.ResetPrinter, 'Driver.ResetPrinter');
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_CASH_IN);
  CheckEquals(FPTR_RT_CASH_IN, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));
  FptrCheck(Driver.BeginFiscalReceipt(True));
  FptrCheck(Driver.PrintRecMessage('Message 1'));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  FptrCheck(Driver.PrintRecCash(10));
  FptrCheck(Driver.PrintRecCash(20));
  FptrCheck(Driver.PrintRecMessage('Message 2'));
  FptrCheck(Driver.PrintRecCash(30));
  FptrCheck(Driver.PrintRecTotal(0, 10, ''));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT_TOTAL, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  FptrCheck(Driver.PrintRecTotal(0, 20, ''));
  FptrCheck(Driver.PrintRecMessage('Message 3'));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT_TOTAL, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  FptrCheck(Driver.PrintRecTotal(0, 30, ''));
  FptrCheck(Driver.PrintRecMessage('Message 4'));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT_ENDING, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  FptrCheck(Driver.EndFiscalReceipt(False));
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));

  FLines.Text := CashInReceiptText;
  CheckLines;
end;

procedure TWebkassaImplTest.TestCashOut;
const
  CashOutReceiptText: string =
    '                                          ' + CRLF +
    '   Восточно-Казастанская область, город   ' + CRLF +
    '  Усть-Каменогорск, ул. Грейдерная, 1/10  ' + CRLF +
    '            ТОО PetroRetail               ' + CRLF +
    'БИН                                       ' + CRLF +
    'ЗНМ  ИНК ОФД                              ' + CRLF +
    'Дата:                                     ' + CRLF +
    'Message 1                                 ' + CRLF +
    'Message 2                                 ' + CRLF +
    'ИЗЪЯТИЕ ДЕНЕГ ИЗ КАССЫ              =60.00' + CRLF +
    'НАЛИЧНЫХ В КАССЕ                     =0.00' + CRLF +
    'Message 3                                 ' + CRLF +
    'Message 4                                 ' + CRLF +
    '           Callцентр 039458039850         ' + CRLF +
    '          Горячая линия 20948802934       ' + CRLF +
    '            СПАСИБО ЗА ПОКУПКУ            ';

begin
  OpenClaimEnable;
  CheckEquals(0, Driver.ResetPrinter, 'Driver.ResetPrinter');
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_CASH_OUT);
  CheckEquals(FPTR_RT_CASH_OUT, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));
  FptrCheck(Driver.BeginFiscalReceipt(True));
  FptrCheck(Driver.PrintRecMessage('Message 1'));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  FptrCheck(Driver.PrintRecCash(10));
  FptrCheck(Driver.PrintRecCash(20));
  FptrCheck(Driver.PrintRecMessage('Message 2'));
  FptrCheck(Driver.PrintRecCash(30));
  FptrCheck(Driver.PrintRecTotal(0, 10, ''));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT_TOTAL, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  FptrCheck(Driver.PrintRecTotal(0, 20, ''));
  FptrCheck(Driver.PrintRecMessage('Message 3'));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT_TOTAL, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  FptrCheck(Driver.PrintRecTotal(0, 30, ''));
  FptrCheck(Driver.PrintRecMessage('Message 4'));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT_ENDING, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  FptrCheck(Driver.EndFiscalReceipt(False));
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));

  FLines.Text := CashOutReceiptText;
  CheckLines;
end;

procedure TWebkassaImplTest.TestZReport;
begin
  OpenClaimEnable;
  FDriver.Client.AnswerJson := ReadFileData(GetModulePath + 'ZXReportAnswer2.txt');
  CheckEquals(0, Driver.PrintZReport, 'Driver.PrintZReport');
end;

procedure TWebkassaImplTest.TestXReport;
begin
  OpenClaimEnable;
  CheckEquals(0, Driver.PrintXReport, 'Driver.PrintXReport');
end;

procedure TWebkassaImplTest.TestNonFiscal;
const
  NonFiscalText: string =
    'Строка для печати 1                       ' + CRLF +
    'Строка для печати 2                       ' + CRLF +
    'Строка для печати 3                       ';
begin
  OpenClaimEnable;
  CheckEquals(0, Driver.ResetPrinter, 'ResetPrinter');
  CheckEquals(0, Driver.BeginNonFiscal, 'BeginNonFiscal');
  CheckEquals(0, Driver.PrintNormal(FPTR_S_RECEIPT, 'Строка для печати 1'));
  CheckEquals(0, Driver.PrintNormal(FPTR_S_RECEIPT, 'Строка для печати 2'));
  CheckEquals(0, Driver.PrintNormal(FPTR_S_RECEIPT, 'Строка для печати 3'));
  CheckEquals(0, Driver.EndNonFiscal, 'EndNonFiscal');

  FLines.Text := NonFiscalText;
  CheckLines;
end;

procedure TWebkassaImplTest.TestFiscalReceipt;
var
  ErrorItem: TErrorItem;
  ErrorResult: TErrorResult;
  ResultCode: Integer;
  ErrorString: WideString;
  ResultCodeExtended: Integer;
begin
  ErrorResult := TErrorResult.Create;
  try
    ErrorItem := ErrorResult.Errors.Add as TErrorItem;
    ErrorItem.Code := 11;
    ErrorItem.Text := 'Продолжительность смены превышает 24 часа';

    OpenClaimEnable;

    FDriver.Client.TestErrorResult := ErrorResult;

    CheckEquals(0, Driver.ResetPrinter, 'Driver.ResetPrinter');
    CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
    Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
    CheckEquals(FPTR_RT_SALES, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));

    FptrCheck(Driver.BeginFiscalReceipt(True));
    CheckEquals(FPTR_PS_FISCAL_RECEIPT, Driver.GetPropertyNumber(PIDXFptr_PrinterState));

    FptrCheck(Driver.PrintRecItem('Item 1', 123.45, 1000, 0, 123.45, 'кг'));
    FptrCheck(Driver.PrintRecTotal(123.45, 123.45, '1'));

    CheckEquals(FPTR_PS_FISCAL_RECEIPT_ENDING, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
    CheckEquals(OPOS_E_EXTENDED, Driver.EndFiscalReceipt(False));
    ResultCode := Driver.GetPropertyNumber(PIDX_ResultCode);
    CheckEquals(OPOS_E_EXTENDED, ResultCode, 'ResultCode');
    ResultCodeExtended := Driver.GetPropertyNumber(PIDX_ResultCodeExtended);
    CheckEquals(OPOS_EFPTR_DAY_END_REQUIRED, ResultCodeExtended, 'ResultCodeExtended');
    ErrorString := Driver.GetPropertyString(PIDXFptr_ErrorString);
    CheckEquals(ErrorItem.Text, ErrorString, 'ErrorString');
  finally
    ErrorResult.Free;
  end;
end;

const
  Receipt3Text: string =
    '                                          ' + CRLF +
    '   Восточно-Казастанская область, город   ' + CRLF +
    '  Усть-Каменогорск, ул. Грейдерная, 1/10  ' + CRLF +
    '            ТОО PetroRetail               ' + CRLF +
    'НДС Серия VATSeries            № VATNumber' + CRLF +
    '------------------------------------------' + CRLF +
    '               SWK00032685                ' + CRLF +
    '                СМЕНА №149                ' + CRLF +
    'ПРОДАЖА                                   ' + CRLF +
    '------------------------------------------' + CRLF +
    'Message 1                                 ' + CRLF +
    'Сер. № 5                                  ' + CRLF +
    'ШОКОЛАДНАЯ ПЛИТКА MILKA BUBBLES МОЛОЧНЫЙ  ' + CRLF +
    '   1.000 кг x 123.45                      ' + CRLF +
    '   Скидка                           -22.35' + CRLF +
    '   Наценка                          +11.17' + CRLF +
    '   Стоимость                        112.27' + CRLF +
    'Message 2                                 ' + CRLF +
    'Item 2                                    ' + CRLF +
    '   1.000 кг x 1.45                        ' + CRLF +
    '   Скидка                            -0.45' + CRLF +
    '   Стоимость                          1.00' + CRLF +
    'Message 3                                 ' + CRLF +
    '------------------------------------------' + CRLF +
    'Скидка:                              10.00' + CRLF +
    'Наценка:                              5.00' + CRLF +
    //'ИТОГ                               =108.27' + CRLF +
    'ИТОГ          =108.27' + CRLF +
    'Банковская карта:                  =123.45' + CRLF +
    '  СДАЧА                             =15.18' + CRLF +
    'в т.ч. НДС 12%                      =12.14' + CRLF +
    '------------------------------------------' + CRLF +
    'Фискальный признак: 923956785162          ' + CRLF +
    'Время: 04.08.2022 17:09:35                ' + CRLF +
    'Оператор фискальных данных:               ' + CRLF +
    'АО "КазТранском"                          ' + CRLF +
    'Для проверки чека зайдите на сайт:        ' + CRLF +
    'dev.kofd.kz/consumer                      ' + CRLF +
    '------------------------------------------' + CRLF +
    '              ФИСКАЛЬНЫЙ ЧЕK              ' + CRLF +
    '               ИНК ОФД: 270               ' + CRLF +
    '     Код ККМ КГД (РНМ): 211030200207      ' + CRLF +
    '             ЗНМ: SWK00032685             ' + CRLF +
    'Message 4                                 ' + CRLF +
    '           Callцентр 039458039850         ' + CRLF +
    '          Горячая линия 20948802934       ' + CRLF +
    '            СПАСИБО ЗА ПОКУПКУ            ';

const
  ItemBarcode = '8234827364';

procedure TWebkassaImplTest.TestFiscalReceipt3;
var
  Json: TlkJSON;
  Text: WideString;
  Doc: TlkJSONbase;
begin
  OpenClaimEnable;
  PrintReceipt3;
  // Check
  Json := TlkJSON.Create;
  try
    Doc := Json.ParseText(FDriver.Client.CommandJson);
    Text := Doc.Field['Positions'].Child[0].Field['Mark'].Value;
    CheckEquals(ItemBarcode, Text, 'ItemBarcode');
  finally
    Json.Free;
  end;

  FLines.Text := Receipt3Text;
  CheckLines;
end;

procedure TWebkassaImplTest.PrintReceipt3;
var
  S: AnsiString;
  pData: Integer;
  pString: WideString;
  OptArgs: Integer;
  Data: WideString;
  JsonText: string;
  ExpectedText: string;
  CustomerEmail: WideString;
const
  CustomerEmail_UTF16LE_HEX =
  '1e 04 3f 04 35 04 40 04 30 04 42 04 3e 04 40 04 ' +
  '3a 00 20 00 92 04 30 04 a3 04 a3 04 d9 04 20 00 ' +
  '9a 04 b1 04 37 04 3c 04 56 04 a3 04 30 04';
begin
  S := HexToStr(CustomerEmail_UTF16LE_HEX);

  CustomerEmail := 'Customer@Email';
(*
  SetLength(CustomerEmail, Length(S) div Sizeof(WideChar));
  Move(S[1], CustomerEmail[1], Length(S));
*)  


  FDriver.Client.TestMode := True;
  FDriver.Client.AnswerJson := ReadFileData(GetModulePath + 'SendReceiptAnswer.txt');
  FDriver.ReceiptJson := ReadFileData(GetModulePath + 'ReadReceiptAnswer.txt');
  FDriver.Params.VATSeries := 'VATSeries';
  FDriver.Params.VATNumber := 'VATNumber';
  FDriver.CashBox.Name := 'SWK00032685';

  CheckEquals(0, Driver.ResetPrinter, 'Driver.ResetPrinter');
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  CheckEquals(FPTR_RT_SALES, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));

  FptrCheck(Driver.BeginFiscalReceipt(True));

  CheckEquals(FPTR_PS_FISCAL_RECEIPT, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  // FiscalSign
  pData := DriverParameterFiscalSign;
  pString := '923956785162';
  FptrCheck(FDriver.DirectIO(DIO_SET_DRIVER_PARAMETER, pData, pString));
  // ExternalCheckNumber
  pData := DriverParameterExternalCheckNumber;
  pString := 'ExternalCheckNumber';
  FptrCheck(FDriver.DirectIO(DIO_SET_DRIVER_PARAMETER, pData, pString));
  // Customer iteqms
  Driver.DirectIO2(DIO_WRITE_FS_STRING_TAG_OP, 1228, 'CustomerINN');
  Driver.DirectIO2(DIO_WRITE_FS_STRING_TAG_OP, 1008, CustomerEmail);



  Driver.DirectIO2(DIO_WRITE_FS_STRING_TAG_OP, 1008, '+727834657823');
  // Item 1
  FptrCheck(Driver.PrintRecMessage('Message 1'));

  pData := DriverParameterBarcode;
  pString := ItemBarcode;
  FptrCheck(Driver.DirectIO(DIO_SET_DRIVER_PARAMETER, pData, pString));
  FptrCheck(Driver.PrintRecItem('Сер. № 5                                  ШОКОЛАДНАЯ ПЛИТКА MILKA BUBBLES МОЛОЧНЫЙ', 123.45, 1000, 1, 123.45, 'кг'));
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_AMOUNT_DISCOUNT, 'Скидка 10', 10, 1));
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_AMOUNT_SURCHARGE, 'Надбавка 5', 5, 1));
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_PERCENTAGE_DISCOUNT, 'Скидка 10%', 10, 1));
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_PERCENTAGE_SURCHARGE, 'Скидка 5%', 5, 1));
  // Item 2
  FptrCheck(Driver.PrintRecMessage('Message 2'));
  FptrCheck(Driver.PrintRecItem('Item 2', 1.45, 1000, 1, 1.45, 'кг'));
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_AMOUNT_DISCOUNT, 'Скидка', 0.45, 1));
  // Total adjustment
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_AMOUNT_DISCOUNT, 'Скидка 10', 10));
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_AMOUNT_SURCHARGE, 'Надбавка 5', 5));
  // Total
  FptrCheck(Driver.PrintRecMessage('Message 3'));
  FptrCheck(Driver.PrintRecTotal(123.45, 123.45, '1'));
  FptrCheck(Driver.PrintRecMessage('Message 4'));

  CheckEquals(FPTR_PS_FISCAL_RECEIPT_ENDING, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  CheckEquals(OPOS_SUCCESS, Driver.EndFiscalReceipt(False));
  CheckEquals(OPOS_SUCCESS, Driver.GetData(FPTR_GD_RECEIPT_NUMBER, OptArgs, Data));
  CheckEquals('923956785162', Data);

  JsonText := UTF8Decode(Driver.Client.CommandJson);
  ExpectedText := UTF8Decode(ReadFileData(GetModulePath + 'SendReceiptRequest2.json'));
  if JsonText <> ExpectedText then
  begin
    WriteFileData(GetModulePath + 'JsonText1.json', JsonText);
    WriteFileData(GetModulePath + 'ExpectedText1.json', ExpectedText);
  end;
  CheckEquals(ExpectedText, JsonText, 'Driver.Client.CommandJson');
end;

procedure TWebkassaImplTest.TestDuplicateReceipt;
begin
  OpenClaimEnable;
  CheckEquals(1, Driver.GetPropertyNumber(PIDXFptr_CapDuplicateReceipt), 'CapDuplicateReceipt');
  Driver.SetPropertyNumber(PIDXFptr_DuplicateReceipt, 1);
  PrintReceipt3;
  FLines.AddStrings(FPrinter.Lines);
  FLines.AddStrings(FPrinter.Lines);
  FPrinter.Lines.Clear;
  CheckEquals(OPOS_SUCCESS, Driver.PrintDuplicateReceipt, 'PrintDuplicateReceipt');

  CheckLines;
end;

procedure TWebkassaImplTest.TestCoverError;
var
  ResultCode: Integer;
  ErrorString: WideString;
  ResultCodeExtended: Integer;
begin
  OpenClaimEnable;
  FPrinter.FCoverOpen := True;
  CheckEquals(OPOS_E_EXTENDED, Driver.PrintXReport, 'Driver.PrintXReport');
  ResultCode := Driver.GetPropertyNumber(PIDX_ResultCode);
  ResultCodeExtended := Driver.GetPropertyNumber(PIDX_ResultCodeExtended);
  ErrorString := Driver.GetPropertyString(PIDXFptr_ErrorString);
  CheckEquals(OPOS_E_EXTENDED, ResultCode, 'ResultCode');
  CheckEquals(OPOS_EFPTR_COVER_OPEN, ResultCodeExtended, 'ResultCodeExtended');
  CheckEquals('Cover is opened', ErrorString, 'ErrorString');
end;

procedure TWebkassaImplTest.TestRecEmpty;
var
  ResultCode: Integer;
  ErrorString: WideString;
  ResultCodeExtended: Integer;
begin
  OpenClaimEnable;
  FPrinter.FRecEmpty := True;
  CheckEquals(OPOS_E_EXTENDED, Driver.PrintXReport, 'Driver.PrintXReport');
  ResultCode := Driver.GetPropertyNumber(PIDX_ResultCode);
  ResultCodeExtended := Driver.GetPropertyNumber(PIDX_ResultCodeExtended);
  ErrorString := Driver.GetPropertyString(PIDXFptr_ErrorString);
  CheckEquals(OPOS_E_EXTENDED, ResultCode, 'ResultCode');
  CheckEquals(OPOS_EFPTR_REC_EMPTY, ResultCodeExtended, 'ResultCodeExtended');
  CheckEquals('Receipt station is empty', ErrorString, 'ErrorString');
end;

procedure TWebkassaImplTest.TestStatusUpateEvent;
begin
  OpenClaimEnable;
  FDriver.SetPropertyNumber(PIDX_FreezeEvents, 0);
  // Invalid events for Fptr
  FDriver.PrinterStatusUpdateEvent(Self, PTR_SUE_JRN_CARTRIDGE_EMPTY);
  FDriver.PrinterStatusUpdateEvent(Self, PTR_SUE_JRN_CARTRIDGE_NEAREMPTY);
  FDriver.PrinterStatusUpdateEvent(Self, PTR_SUE_JRN_HEAD_CLEANING);
  FDriver.PrinterStatusUpdateEvent(Self, PTR_SUE_JRN_CARTRIDGE_OK);
  FDriver.PrinterStatusUpdateEvent(Self, PTR_SUE_REC_CARTRIDGE_EMPTY);
  FDriver.PrinterStatusUpdateEvent(Self, PTR_SUE_REC_CARTRIDGE_NEAREMPTY);
  FDriver.PrinterStatusUpdateEvent(Self, PTR_SUE_REC_HEAD_CLEANING);
  FDriver.PrinterStatusUpdateEvent(Self, PTR_SUE_REC_CARTRIDGE_OK);
  FDriver.PrinterStatusUpdateEvent(Self, PTR_SUE_SLP_CARTRIDGE_EMPTY);
  FDriver.PrinterStatusUpdateEvent(Self, PTR_SUE_SLP_CARTRIDGE_NEAREMPTY);
  FDriver.PrinterStatusUpdateEvent(Self, PTR_SUE_SLP_HEAD_CLEANING);
  FDriver.PrinterStatusUpdateEvent(Self, PTR_SUE_SLP_CARTRIDGE_OK);
  // Valid events for Fptr
  FDriver.PrinterStatusUpdateEvent(Self, PTR_SUE_COVER_OPEN);
  FDriver.PrinterStatusUpdateEvent(Self, PTR_SUE_COVER_OK);
  FDriver.PrinterStatusUpdateEvent(Self, PTR_SUE_JRN_COVER_OPEN);
  FDriver.PrinterStatusUpdateEvent(Self, PTR_SUE_JRN_COVER_OK);
  FDriver.PrinterStatusUpdateEvent(Self, PTR_SUE_REC_COVER_OPEN);
  FDriver.PrinterStatusUpdateEvent(Self, PTR_SUE_REC_COVER_OK);
  FDriver.PrinterStatusUpdateEvent(Self, PTR_SUE_SLP_COVER_OPEN);
  FDriver.PrinterStatusUpdateEvent(Self, PTR_SUE_SLP_COVER_OK);
  FDriver.PrinterStatusUpdateEvent(Self, PTR_SUE_JRN_EMPTY);
  FDriver.PrinterStatusUpdateEvent(Self, PTR_SUE_JRN_NEAREMPTY);
  FDriver.PrinterStatusUpdateEvent(Self, PTR_SUE_JRN_PAPEROK);
  FDriver.PrinterStatusUpdateEvent(Self, PTR_SUE_REC_EMPTY);
  FDriver.PrinterStatusUpdateEvent(Self, PTR_SUE_REC_NEAREMPTY);
  FDriver.PrinterStatusUpdateEvent(Self, PTR_SUE_REC_PAPEROK);
  FDriver.PrinterStatusUpdateEvent(Self, PTR_SUE_SLP_EMPTY);
  FDriver.PrinterStatusUpdateEvent(Self, PTR_SUE_SLP_NEAREMPTY);
  FDriver.PrinterStatusUpdateEvent(Self, PTR_SUE_SLP_PAPEROK);
  WaitForEventsCount(17);
  CheckEquals(17, Events.Count, 'Events.Count');
  CheckEquals(FPTR_SUE_COVER_OPEN, (Events[0] as TStatusUpdateEvent).Data);
  CheckEquals(FPTR_SUE_COVER_OK, (Events[1] as TStatusUpdateEvent).Data);
  CheckEquals(FPTR_SUE_JRN_COVER_OPEN, (Events[2] as TStatusUpdateEvent).Data);
  CheckEquals(FPTR_SUE_JRN_COVER_OK, (Events[3] as TStatusUpdateEvent).Data);
  CheckEquals(FPTR_SUE_REC_COVER_OPEN, (Events[4] as TStatusUpdateEvent).Data);
  CheckEquals(FPTR_SUE_REC_COVER_OK, (Events[5] as TStatusUpdateEvent).Data);
  CheckEquals(FPTR_SUE_SLP_COVER_OPEN, (Events[6] as TStatusUpdateEvent).Data);
  CheckEquals(FPTR_SUE_SLP_COVER_OK, (Events[7] as TStatusUpdateEvent).Data);
  CheckEquals(FPTR_SUE_JRN_EMPTY, (Events[8] as TStatusUpdateEvent).Data);
  CheckEquals(FPTR_SUE_JRN_NEAREMPTY, (Events[9] as TStatusUpdateEvent).Data);
  CheckEquals(FPTR_SUE_JRN_PAPEROK, (Events[10] as TStatusUpdateEvent).Data);
  CheckEquals(FPTR_SUE_REC_EMPTY, (Events[11] as TStatusUpdateEvent).Data);
  CheckEquals(FPTR_SUE_REC_NEAREMPTY, (Events[12] as TStatusUpdateEvent).Data);
  CheckEquals(FPTR_SUE_REC_PAPEROK, (Events[13] as TStatusUpdateEvent).Data);
  CheckEquals(FPTR_SUE_SLP_EMPTY, (Events[14] as TStatusUpdateEvent).Data);
  CheckEquals(FPTR_SUE_SLP_NEAREMPTY, (Events[15] as TStatusUpdateEvent).Data);
  CheckEquals(FPTR_SUE_SLP_PAPEROK, (Events[16] as TStatusUpdateEvent).Data);
end;

procedure TWebkassaImplTest.TestSetHeaderLines;
begin
  OpenClaimEnable;
  Driver.SetHeaderLine(1, 'Header line 1', True);
  Driver.SetHeaderLine(2, 'Header line 2', False);
  Driver.SetHeaderLine(3, 'Header line 3', True);
  Driver.SetHeaderLine(4, 'Header line 4', False);
  Driver.Close;

  OpenClaimEnable;
  CheckEquals(ESC_DoubleWide + 'Header line 1', Driver.Params.Header[0]);
  CheckEquals('Header line 2', Driver.Params.Header[1]);
  CheckEquals(ESC_DoubleWide + 'Header line 3', Driver.Params.Header[2]);
  CheckEquals('Header line 4', Driver.Params.Header[3]);
end;

procedure TWebkassaImplTest.TestSetTrailerLines;
begin
  OpenClaimEnable;
  Driver.SetTrailerLine(1, 'Trailer line 1', True);
  Driver.SetTrailerLine(2, 'Trailer line 2', False);
  Driver.SetTrailerLine(3, 'Trailer line 3', False);
  Driver.Close;

  OpenClaimEnable;
  CheckEquals(ESC_DoubleWide + 'Trailer line 1', Driver.Params.Trailer[0]);
  CheckEquals('Trailer line 2', Driver.Params.Trailer[1]);
  CheckEquals('Trailer line 3', Driver.Params.Trailer[2]);
end;

procedure TWebkassaImplTest.PrintHeaderAndCut;
const
  Text: string =
    '                                          ' + CRLF +
    '   Восточно-Казастанская область, город   ' + CRLF +
    '    Усть-Каменогорск, ул. Грейдерная, 1/10' + CRLF +
    '            ТОО PetroRetail               ';

begin
  FPrinter.Lines.Clear;
  OpenClaimEnable;
  Driver.PrintHeaderAndCut;
  CheckEquals(4, FPrinter.Lines.Count, 'Printer.Lines.Count');
  FLines.Text := Text;
  CheckLines;
end;

(*
 |bC№
*)

procedure TWebkassaImplTest.TestReceiptTemplate;
begin
  Driver.Params.Template.Clear;
  Driver.Params.TemplateEnabled := True;

  Driver.Params.HeaderText := '';
  Driver.Params.TrailerText := '';
  FDriver.Params.NumHeaderLines := 0;
  FDriver.Params.NumTrailerLines := 0;

  Driver.Params.Template.Header.AddSeparator;
  OpenClaimEnable;

  CheckEquals(0, Driver.ResetPrinter, 'Driver.ResetPrinter');
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  CheckEquals(FPTR_RT_SALES, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));

  FptrCheck(Driver.BeginFiscalReceipt(True));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  FptrCheck(Driver.PrintRecItem('Сер. № 5 ШОКОЛАДНАЯ ПЛИТКА MILKA BUBBLES МОЛОЧНЫЙ', 123.45, 1000, 1, 123.45, 'кг'));
  FptrCheck(Driver.PrintRecTotal(123.45, 123.45, '1'));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT_ENDING, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  CheckEquals(OPOS_SUCCESS, Driver.EndFiscalReceipt(False));

  FLines.Text := '------------------------------------------';
  CheckLines;
end;

procedure TWebkassaImplTest.SetTemplateDefault;
var
  Item: TTemplateItem;
begin
  Driver.Params.TemplateEnabled := True;
  Driver.Params.Template.Clear;
  // Line 1
  Item := Driver.Params.Template.Header.Add;
  Item.ItemType := TEMPLATE_TYPE_PARAM;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'VATSeries';
  Item.FormatText := 'НДС Серия %s';
  Item.Alignment := ALIGN_LEFT;
  //
  Item := Driver.Params.Template.Header.Add;
  Item.ItemType := TEMPLATE_TYPE_PARAM;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'VATNumber';
  Item.FormatText := '№ %s';
  Item.Alignment := ALIGN_RIGHT;
  Driver.Params.Template.Header.NewLine;
  // Line 2
  Driver.Params.Template.Header.AddSeparator;
  // Line3
  Item := Driver.Params.Template.Header.Add;
  Item.ItemType := TEMPLATE_TYPE_JSON_ANS_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Data.CashBox.UniqueNumber';
  Item.FormatText := '               %s';
  Item.Alignment := ALIGN_LEFT;
  // Line2
  Driver.Params.Template.Header.NewLine;
  // Line4
  Item := Driver.Params.Template.Header.Add;
  Item.ItemType := TEMPLATE_TYPE_JSON_ANS_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Data.ShiftNumber';
  Item.FormatText := 'СМЕНА №%s';
  Item.Alignment := ALIGN_CENTER;
  Driver.Params.Template.Header.NewLine;
  //
  Driver.Params.Template.Header.AddText('ПРОДАЖА' + CRLF);
  Driver.Params.Template.Header.AddSeparator;
  // Description
  Item := Driver.Params.Template.RecItem.Add;
  Item.ItemType := TEMPLATE_TYPE_ITEM_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Description';
  Item.FormatText := '';
  Item.Alignment := ALIGN_LEFT;
  Driver.Params.Template.RecItem.NewLine;
  // Quantity
  Item := Driver.Params.Template.RecItem.Add;
  Item.ItemType := TEMPLATE_TYPE_ITEM_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Quantity';
  Item.FormatText := '   %s кг x ';
  Item.Alignment := ALIGN_LEFT;
  // Price
  Item := Driver.Params.Template.RecItem.Add;
  Item.ItemType := TEMPLATE_TYPE_ITEM_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Price';
  Item.FormatText := '%s';
  Item.Alignment := ALIGN_LEFT;
  Driver.Params.Template.RecItem.NewLine;
  // Discount
  Driver.Params.Template.RecItem.AddText('   Скидка');
  Item := Driver.Params.Template.RecItem.Add;
  Item.ItemType := TEMPLATE_TYPE_ITEM_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Discount';
  Item.FormatText := '-%s';
  Item.Alignment := ALIGN_RIGHT;
  Item.Enabled := TEMPLATE_ITEM_ENABLED_IF_NOT_ZERO;
  Driver.Params.Template.RecItem.NewLine;
  // Charge
  Driver.Params.Template.RecItem.AddText('   Наценка');
  Item := Driver.Params.Template.RecItem.Add;
  Item.ItemType := TEMPLATE_TYPE_ITEM_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Charge';
  Item.FormatText := '+%s';
  Item.Alignment := ALIGN_RIGHT;
  Item.Enabled := TEMPLATE_ITEM_ENABLED_IF_NOT_ZERO;
  Driver.Params.Template.RecItem.NewLine;
  // Total
  Driver.Params.Template.RecItem.AddText('   Стоимость');
  Item := Driver.Params.Template.RecItem.Add;
  Item.ItemType := TEMPLATE_TYPE_ITEM_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Total';
  Item.FormatText := '';
  Item.Alignment := ALIGN_RIGHT;
  Driver.Params.Template.RecItem.NewLine;
  // Separator
  Driver.Params.Template.Trailer.AddSeparator;
  // Discount
  Driver.Params.Template.Trailer.AddText('Скидка:');
  Item := Driver.Params.Template.Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_ITEM_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Discount';
  Item.FormatText := '%s';
  Item.Alignment := ALIGN_RIGHT;
  Item.Enabled := TEMPLATE_ITEM_ENABLED_IF_NOT_ZERO;
  Driver.Params.Template.Trailer.NewLine;
  // Charge
  Driver.Params.Template.Trailer.AddText('Наценка:');
  Item := Driver.Params.Template.Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_ITEM_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Charge';
  Item.FormatText := '%s';
  Item.Alignment := ALIGN_RIGHT;
  Item.Enabled := TEMPLATE_ITEM_ENABLED_IF_NOT_ZERO;
  Driver.Params.Template.Trailer.NewLine;
  // Total
  Item := Driver.Params.Template.Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_TEXT;
  Item.TextStyle := STYLE_DWIDTH_HEIGHT;
  Item.Alignment := ALIGN_LEFT;
  Item.Text := 'ИТОГ';
  Item := Driver.Params.Template.Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_ITEM_FIELD;
  Item.TextStyle := STYLE_DWIDTH_HEIGHT;
  Item.Text := 'Total';
  Item.FormatText := '=%s';
  Item.Alignment := ALIGN_RIGHT;
  Item.Enabled := TEMPLATE_ITEM_ENABLED;
  Driver.Params.Template.Trailer.NewLine;
  // Payment0
  Driver.Params.Template.Trailer.AddText('Наличные:');
  Item := Driver.Params.Template.Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_ITEM_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Payment0';
  Item.FormatText := '=%s';
  Item.Alignment := ALIGN_RIGHT;
  Item.Enabled := TEMPLATE_ITEM_ENABLED_IF_NOT_ZERO;
  Driver.Params.Template.Trailer.NewLine;
  // Payment1
  Driver.Params.Template.Trailer.AddText('Банковская карта:');
  Item := Driver.Params.Template.Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_ITEM_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Payment1';
  Item.FormatText := '=%s';
  Item.Alignment := ALIGN_RIGHT;
  Item.Enabled := TEMPLATE_ITEM_ENABLED_IF_NOT_ZERO;
  Driver.Params.Template.Trailer.NewLine;
  // Payment2
  Driver.Params.Template.Trailer.AddText('Кредит:');
  Item := Driver.Params.Template.Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_ITEM_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Payment2';
  Item.FormatText := '=%s';
  Item.Alignment := ALIGN_RIGHT;
  Item.Enabled := TEMPLATE_ITEM_ENABLED_IF_NOT_ZERO;
  Driver.Params.Template.Trailer.NewLine;
  // Payment3
  Driver.Params.Template.Trailer.AddText('Оплата тарой:');
  Item := Driver.Params.Template.Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_ITEM_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Payment3';
  Item.FormatText := '=%s';
  Item.Alignment := ALIGN_RIGHT;
  Item.Enabled := TEMPLATE_ITEM_ENABLED_IF_NOT_ZERO;
  Driver.Params.Template.Trailer.NewLine;
  // Change
  Driver.Params.Template.Trailer.AddText('  СДАЧА');
  Item := Driver.Params.Template.Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_ITEM_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Change';
  Item.FormatText := '=%s';
  Item.Alignment := ALIGN_RIGHT;
  Item.Enabled := TEMPLATE_ITEM_ENABLED_IF_NOT_ZERO;
  Driver.Params.Template.Trailer.NewLine;
  // Taxes
  Driver.Params.Template.Trailer.AddText('в т.ч. НДС 12%');
  Item := Driver.Params.Template.Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_JSON_REC_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Data.Tax';
  Item.FormatText := '=%s';
  Item.Alignment := ALIGN_RIGHT;
  Item.Enabled := TEMPLATE_ITEM_ENABLED_IF_NOT_ZERO;
  Driver.Params.Template.Trailer.NewLine;
  // Separator
  Driver.Params.Template.Trailer.AddSeparator;
  // Fiscal sign
  Driver.Params.Template.Trailer.AddText('Фискальный признак: ');
  Item := Driver.Params.Template.Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_JSON_ANS_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Data.CheckNumber';
  Item.FormatText := '';
  Item.Alignment := ALIGN_LEFT;
  Item.Enabled := TEMPLATE_ITEM_ENABLED;
  Driver.Params.Template.Trailer.NewLine;
  // Time
  Driver.Params.Template.Trailer.AddText('Время: ');
  Item := Driver.Params.Template.Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_JSON_ANS_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Data.DateTime';
  Item.FormatText := '';
  Item.Alignment := ALIGN_LEFT;
  Item.Enabled := TEMPLATE_ITEM_ENABLED;
  Driver.Params.Template.Trailer.NewLine;
  // Fiscal data operator
  Driver.Params.Template.Trailer.AddText('Оператор фискальных данных:');
  Driver.Params.Template.Trailer.NewLine;
  Item := Driver.Params.Template.Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_JSON_ANS_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Data.Cashbox.Ofd.Name';
  Item.FormatText := '';
  Item.Alignment := ALIGN_LEFT;
  Item.Enabled := TEMPLATE_ITEM_ENABLED;
  Driver.Params.Template.Trailer.NewLine;
  // Ticket URL
  Driver.Params.Template.Trailer.AddText('Для проверки чека зайдите на сайт:');
  Driver.Params.Template.Trailer.NewLine;
  Item := Driver.Params.Template.Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_JSON_ANS_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Data.Cashbox.Ofd.Host';
  Item.FormatText := '';
  Item.Alignment := ALIGN_LEFT;
  Item.Enabled := TEMPLATE_ITEM_ENABLED;
  Driver.Params.Template.Trailer.NewLine;
  // Separator
  Driver.Params.Template.Trailer.AddSeparator;
  // Fiscal receipt
  Item := Driver.Params.Template.Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_TEXT;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'ФИСКАЛЬНЫЙ ЧЕK';
  Item.Alignment := ALIGN_CENTER;
  Driver.Params.Template.Trailer.NewLine;
  // Fiscal receipt
  Item := Driver.Params.Template.Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_JSON_ANS_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Data.Cashbox.IdentityNumber';
  Item.FormatText := 'ИНК ОФД: %s';
  Item.Alignment := ALIGN_CENTER;
  Driver.Params.Template.Trailer.NewLine;
  // Registration number
  Item := Driver.Params.Template.Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_JSON_ANS_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Data.Cashbox.RegistrationNumber';
  Item.FormatText := 'Код ККМ КГД (РНМ): %s';
  Item.Alignment := ALIGN_CENTER;
  Driver.Params.Template.Trailer.NewLine;
  // Unique number
  Item := Driver.Params.Template.Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_JSON_ANS_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Data.Cashbox.UniqueNumber';
  Item.FormatText := 'ЗНМ: %s';
  Item.Alignment := ALIGN_CENTER;
  Driver.Params.Template.Trailer.NewLine;
  Driver.Params.Template.SaveToFile('Receipt3.xml');
end;

procedure TWebkassaImplTest.TestReceiptTemplate2;
begin
  Driver.Params.TemplateEnabled := True;
  Driver.Params.Template.SetDefaults;
  OpenClaimEnable;
  PrintReceipt3;
  FLines.Text := Receipt3Text;
  CheckLines;
end;

procedure TWebkassaImplTest.TestReceiptTemplate3;
var
  Item: TTemplateItem;
const
  Receipt4Text: string =
    'ИТОГ                 =108.27' + CRLF;
begin
  Driver.Params.TemplateEnabled := True;
  Driver.Params.Template.Clear;
  FDriver.Params.NumHeaderLines := 0;
  FDriver.Params.NumTrailerLines := 0;
  FDriver.Params.HeaderText := '';
  FDriver.Params.TrailerText := '';
  // Total
  Item := Driver.Params.Template.Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_TEXT;
  Item.TextStyle := STYLE_DWIDTH_HEIGHT;
  Item.Alignment := ALIGN_LEFT;
  Item.LineChars := 56;
  Item.Text := 'ИТОГ';

  Item := Driver.Params.Template.Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_ITEM_FIELD;
  Item.TextStyle := STYLE_DWIDTH_HEIGHT;
  Item.Text := 'Total';
  Item.FormatText := '=%s';
  Item.Alignment := ALIGN_RIGHT;
  Item.Enabled := TEMPLATE_ITEM_ENABLED;
  Item.LineChars := 56;

  Driver.Params.Template.Trailer.NewLine;

  OpenClaimEnable;

  FDriver.Client.TestMode := True;
  CheckEquals(0, Driver.ResetPrinter, 'Driver.ResetPrinter');
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  CheckEquals(FPTR_RT_SALES, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));
  FptrCheck(Driver.BeginFiscalReceipt(True));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  FptrCheck(Driver.PrintRecItem('Сер. № 5                                  ШОКОЛАДНАЯ ПЛИТКА MILKA BUBBLES МОЛОЧНЫЙ', 123.45, 1000, 1, 123.45, 'кг'));
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_AMOUNT_DISCOUNT, 'Скидка 10', 10, 1));
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_AMOUNT_SURCHARGE, 'Надбавка 5', 5, 1));
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_PERCENTAGE_DISCOUNT, 'Скидка 10%', 10, 1));
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_PERCENTAGE_SURCHARGE, 'Скидка 5%', 5, 1));
  FptrCheck(Driver.PrintRecItem('Item 2', 1.45, 1000, 1, 1.45, 'кг'));
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_AMOUNT_DISCOUNT, 'Скидка', 0.45, 1));
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_AMOUNT_DISCOUNT, 'Скидка 10', 10));
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_AMOUNT_SURCHARGE, 'Надбавка 5', 5));
  FptrCheck(Driver.PrintRecTotal(123.45, 123.45, '1'));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT_ENDING, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  CheckEquals(OPOS_SUCCESS, Driver.EndFiscalReceipt(False));

  FLines.Text := Receipt4Text;
  CheckLines;
end;

procedure TWebkassaImplTest.ShowLines;
var
  i: Integer;
begin
  for i := 0 to FPrinter.Lines.Count-1 do
  begin
    ODS(Format('%d, %s', [i, FPrinter.Lines[i]]));
  end;
end;

procedure TWebkassaImplTest.CheckLines;
var
  i: Integer;
begin
  //ShowLines;
  CheckEquals(FLines.Count, FPrinter.Lines.Count, 'FPrinter.Lines.Count');
  for i := 0 to FLines.Count-1 do
  begin
    if FLines[i] <> FPrinter.Lines[i] then
    begin
      CheckEquals(TrimRight(FLines[i]), TrimRight(FPrinter.Lines[i]), IntToStr(i));
    end;
  end;
end;

procedure TWebkassaImplTest.TestGetJsonField;
var
  V: Variant;
  Json: TlkJSON;
  JsonText: WideString;
  JsonRoot: TlkJSONbase;
  Item: TlkJSONbase;
begin
  Json := TlkJSON.Create;
  try
    JsonText := ReadFileData(GetModulePath + 'SendReceiptAnswer.txt');
    JsonRoot := Json.ParseText(JsonText);
    Item := JsonRoot.Field['Data'];
    Check(Item <> nil, 'Data');
    CheckEquals('923956785162', Item.Field['CheckNumber'].Value, 'CheckNumber');
    Item := Item.Field['CashBox'];
    Check(Item <> nil, 'CashBox');
    CheckEquals('SWK00032685', Item.Field['UniqueNumber'].Value, 'UniqueNumber');

    V := Driver.GetJsonField(JsonText, 'Data.Cashbox.UniqueNumber');
    CheckEquals('SWK00032685', V, 'UniqueNumber');
  finally
    Json.Free;
  end;
end;

procedure TWebkassaImplTest.TestEncoding;
const
  TEXT_UTF16LE_HEX =
  '1e 04 3f 04 35 04 40 04 30 04 42 04 3e 04 40 04 ' +
  '3a 00 20 00 92 04 30 04 a3 04 a3 04 d9 04 20 00 ' +
  '9a 04 b1 04 37 04 3c 04 56 04 a3 04 30 04';
var
  S: AnsiString;
  Text: WideString;
begin
  FPrinter.FRecLinesToPaperCut := 0;
  FDriver.Params.NumHeaderLines := 0;
  FDriver.Params.NumTrailerLines := 0;

  S := HexToStr(TEXT_UTF16LE_HEX);
  SetLength(Text, Length(S) div Sizeof(WideChar));
  Move(S[1], Text[1], Length(S));

  OpenClaimEnable;
  CheckEquals(0, Driver.ResetPrinter, 'ResetPrinter');
  CheckEquals(0, Driver.BeginNonFiscal, 'BeginNonFiscal');
  CheckEquals(0, Driver.PrintNormal(FPTR_S_RECEIPT, Text));
  CheckEquals(0, Driver.EndNonFiscal, 'EndNonFiscal');

  FLines.Text := Text;
  CheckLines;
end;

procedure TWebkassaImplTest.TestBarcode;
const
  BarcodeData = 'http://dev.kofd.kz/consumer?i=925871425876&f=211030200207&s=15443.72&t=20220826T210014';
begin
  Driver.PrintQRCodeAsGraphics(BarcodeData);

end;

initialization
  RegisterTest('', TWebkassaImplTest.Suite);


end.

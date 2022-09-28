
unit duWebkassaImpl;

interface

uses
  // VCL
  Windows, SysUtils, Classes, SyncObjs,
  // DUnit
  TestFramework,
  // Opos
  Opos, OposFptr, Oposhi, OposFptrhi, OposFptrUtils, OposUtils,
  OposEvents, OposPtr, RCSEvents,
  // Tnt
  TntClasses, TntSysUtils,
  // This
  LogFile, WebkassaImpl, WebkassaClient, MockPosPrinter, FileUtils,
  CustomReceipt;

const
  CRLF = #13#10;

type
  { TWebkassaImplTest }

  TWebkassaImplTest = class(TTestCase, IOposEvents)
  private
    FLines: TStrings;
    FEvents: TOposEvents;
    FDriver: TWebkassaImpl;
    FPrinter: TMockPosPrinter;
    FWaitEvent: TEvent;
    procedure WaitForEventsCount(Count: Integer);
  protected
    procedure CheckNoEvent;
    procedure WaitForEvent;
    procedure ClaimDevice;
    procedure EnableDevice;
    procedure OpenService;
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
    // !!!
    procedure TestCashIn;
    procedure TestCashOut;
    procedure TestZReport;
    procedure TestXReport;
    procedure TestNonFiscal;
  published
    procedure OpenClaimEnable;
    procedure TestFiscalReceipt;
    procedure TestFiscalReceipt2;
    procedure TestFiscalReceipt3;
    procedure TestCoverError;
    procedure TestRecEmpty;
    procedure TestStatusUpateEvent;
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

  FDriver := TWebkassaImpl.Create(nil);
  FDriver.TestMode := True;
  FDriver.Client.TestMode := True;
  FDriver.Printer := FPrinter;
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
  FDriver.Params.Header :=
    ' ' + CRLF +
    '   Восточно-Казастанская область, город' + CRLF +
    '    Усть-Каменогорск, ул. Грейдерная, 1/10' + CRLF +
    '            ТОО PetroRetail';
  FDriver.Params.Trailer :=
    '           Callцентр 039458039850 ' + CRLF +
    '          Горячая линия 20948802934' + CRLF +
    '            СПАСИБО ЗА ПОКУПКУ';

  FDriver.Logger.CloseFile;
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
begin
  OpenClaimEnable;
  CheckEquals(0, Driver.ResetPrinter, 'Driver.ResetPrinter');
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_CASH_IN);
  CheckEquals(FPTR_RT_CASH_IN, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));
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
  FptrCheck(Driver.EndFiscalReceipt(False));
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
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
  FptrCheck(Driver.EndFiscalReceipt(False));
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

    FptrCheck(Driver.BeginFiscalReceipt(False));
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

procedure TWebkassaImplTest.TestFiscalReceipt2;
var
  pData: Integer;
  pString: WideString;
  Separator: WideString;
begin
  Separator := StringOfChar('-', FPrinter.RecLineChars);

  OpenClaimEnable;

  // FiscalSign
  pData := DriverParameterFiscalSign;
  pString := 'FiscalSign';
  FptrCheck(FDriver.DirectIO(DIO_SET_DRIVER_PARAMETER, pData, pString));
  // ExternalCheckNumber
  pData := DriverParameterExternalCheckNumber;
  pString := 'ExternalCheckNumber';
  FptrCheck(FDriver.DirectIO(DIO_SET_DRIVER_PARAMETER, pData, pString));

  FDriver.Client.TestMode := True;
  FDriver.Client.AnswerJson := ReadFileData(GetModulePath + 'SendReceiptAnswer.txt');
  FDriver.Params.VATSeries := 'VATSeries';
  FDriver.Params.VATNumber := 'VATNumber';
  FDriver.CashBox.Name := 'CashBox.Name';

  CheckEquals(0, Driver.ResetPrinter, 'Driver.ResetPrinter');
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  CheckEquals(FPTR_RT_SALES, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));

  FptrCheck(Driver.BeginFiscalReceipt(False));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  FptrCheck(Driver.PrintRecItem('Item 1', 123.45, 1000, 0, 123.45, 'кг'));
  FptrCheck(Driver.PrintRecTotal(123.45, 123.45, '1'));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT_ENDING, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  CheckEquals(OPOS_SUCCESS, Driver.EndFiscalReceipt(False));

  CheckEquals(33, FPrinter.Lines.Count, 'FPrinter.Lines.Count');
  FLines.Text := FDriver.Params.Header;
  CheckEquals(Trim(FLines[0]), Trim(FPrinter.Lines[0]));
  CheckEquals(Trim(FLines[1]), Trim(FPrinter.Lines[1]));
  CheckEquals(Trim(FLines[2]), Trim(FPrinter.Lines[2]));
  CheckEquals(Trim(FLines[3]), Trim(FPrinter.Lines[3]));
  CheckEquals('НДС Серия VATSeries            № VATNumber', Trim(FPrinter.Lines[4]));
  CheckEquals(Separator, Trim(FPrinter.Lines[5]));
  CheckEquals(FDriver.CashBox.Name, Trim(FPrinter.Lines[6])); // CashBox.Name
  CheckEquals('Смена 149', Trim(FPrinter.Lines[7]));
  CheckEquals('Чек №923956785162', Trim(FPrinter.Lines[8]));
  CheckEquals('Кассир webkassa4@softit.kz', Trim(FPrinter.Lines[9]));
  CheckEquals(Separator, Trim(FPrinter.Lines[10]));
  CheckEquals('  1. Item 1', TrimRight(FPrinter.Lines[11]));
  CheckEquals('   1.000 кг x 123.45', TrimRight(FPrinter.Lines[12]));
  CheckEquals('   Стоимость                        123.45', TrimRight(FPrinter.Lines[13]));
  CheckEquals(Separator, TrimRight(FPrinter.Lines[14]));
  CheckEquals('Банковская карта:                   123.45', TrimRight(FPrinter.Lines[15]));
  CheckEquals('ИТОГО:                              123.45', TrimRight(FPrinter.Lines[16]));
  CheckEquals(Separator, TrimRight(FPrinter.Lines[17]));
  CheckEquals('Фискальный признак:', TrimRight(FPrinter.Lines[18]));
  CheckEquals('Время:                 04.08.2022 17:09:35', TrimRight(FPrinter.Lines[19]));
  CheckEquals('Оператор фискальных данных:АО "КазТранском', TrimRight(FPrinter.Lines[20]));
  CheckEquals('Для проверки чека зайдите на сайт:', TrimRight(FPrinter.Lines[21]));
  CheckEquals('dev.kofd.kz/consumer', TrimRight(FPrinter.Lines[22]));
  CheckEquals(Separator, TrimRight(FPrinter.Lines[23]));
  CheckEquals('              ФИСКАЛЬНЫЙ ЧЕK', TrimRight(FPrinter.Lines[24]));
  CheckEquals('http://dev.kofd.kz/consumer?i=923956785162', TrimRight(FPrinter.Lines[25]));
  CheckEquals('               ИНК ОФД: 270', TrimRight(FPrinter.Lines[26]));
  CheckEquals('     Код ККМ КГД (РНМ): 211030200207', TrimRight(FPrinter.Lines[27]));
  CheckEquals('             ЗНМ: SWK00032685', TrimRight(FPrinter.Lines[28]));
  CheckEquals('           Callцентр 039458039850', TrimRight(FPrinter.Lines[29]));
  CheckEquals('          Горячая линия 20948802934', TrimRight(FPrinter.Lines[30]));
  CheckEquals('            СПАСИБО ЗА ПОКУПКУ', TrimRight(FPrinter.Lines[31]));
  CheckEquals('', TrimRight(FPrinter.Lines[32]));
end;

procedure TWebkassaImplTest.TestFiscalReceipt3;
var
  pData: Integer;
  pString: WideString;
  Separator: WideString;
begin
  Separator := StringOfChar('-', FPrinter.RecLineChars);

  OpenClaimEnable;

  // FiscalSign
  pData := DriverParameterFiscalSign;
  pString := 'FiscalSign';
  FptrCheck(FDriver.DirectIO(DIO_SET_DRIVER_PARAMETER, pData, pString));
  // ExternalCheckNumber
  pData := DriverParameterExternalCheckNumber;
  pString := 'ExternalCheckNumber';
  FptrCheck(FDriver.DirectIO(DIO_SET_DRIVER_PARAMETER, pData, pString));

  FDriver.Client.TestMode := True;
  FDriver.Client.AnswerJson := ReadFileData(GetModulePath + 'SendReceiptAnswer.txt');
  FDriver.Params.VATSeries := 'VATSeries';
  FDriver.Params.VATNumber := 'VATNumber';
  FDriver.CashBox.Name := 'CashBox.Name';

  CheckEquals(0, Driver.ResetPrinter, 'Driver.ResetPrinter');
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  CheckEquals(FPTR_RT_SALES, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));

  FptrCheck(Driver.BeginFiscalReceipt(False));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  // Item 1
  FptrCheck(Driver.PrintRecItem('Item 1', 123.45, 1000, 1, 123.45, 'кг'));
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_AMOUNT_DISCOUNT, 'Скидка 10', 10, 1));
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_AMOUNT_SURCHARGE, 'Надбавка 5', 5, 1));
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_PERCENTAGE_DISCOUNT, 'Скидка 10%', 10, 1));
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_PERCENTAGE_SURCHARGE, 'Скидка 5%', 5, 1));
  // Item 2
  FptrCheck(Driver.PrintRecItem('Item 2', 1.45, 1000, 1, 1.45, 'кг'));
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_AMOUNT_DISCOUNT, 'Скидка 0.45', 0.45, 1));
  // Total adjustment
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_AMOUNT_DISCOUNT, 'Скидка 10', 10));
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_AMOUNT_SURCHARGE, 'Надбавка 5', 5));
  // Total
  FptrCheck(Driver.PrintRecTotal(123.45, 123.45, '1'));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT_ENDING, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  CheckEquals(OPOS_SUCCESS, Driver.EndFiscalReceipt(False));

  CheckEquals(33, FPrinter.Lines.Count, 'FPrinter.Lines.Count');
  FLines.Text := FDriver.Params.Header;
  CheckEquals(Trim(FLines[0]), Trim(FPrinter.Lines[0]));
  CheckEquals(Trim(FLines[1]), Trim(FPrinter.Lines[1]));
  CheckEquals(Trim(FLines[2]), Trim(FPrinter.Lines[2]));
  CheckEquals(Trim(FLines[3]), Trim(FPrinter.Lines[3]));
  CheckEquals('НДС Серия VATSeries            № VATNumber', Trim(FPrinter.Lines[4]));
  CheckEquals(Separator, Trim(FPrinter.Lines[5]));
  CheckEquals(FDriver.CashBox.Name, Trim(FPrinter.Lines[6])); // CashBox.Name
  CheckEquals('Смена 149', Trim(FPrinter.Lines[7]));
  CheckEquals('Чек №923956785162', Trim(FPrinter.Lines[8]));
  CheckEquals('Кассир webkassa4@softit.kz', Trim(FPrinter.Lines[9]));
  CheckEquals(Separator, Trim(FPrinter.Lines[10]));
  CheckEquals('  1. Item 1', TrimRight(FPrinter.Lines[11]));
  CheckEquals('   1.000 кг x 123.45', TrimRight(FPrinter.Lines[12]));
  CheckEquals('   Стоимость                        123.45', TrimRight(FPrinter.Lines[13]));
  CheckEquals(Separator, TrimRight(FPrinter.Lines[14]));
  CheckEquals('Банковская карта:                   123.45', TrimRight(FPrinter.Lines[15]));
  CheckEquals('ИТОГО:                              123.45', TrimRight(FPrinter.Lines[16]));
  CheckEquals(Separator, TrimRight(FPrinter.Lines[17]));
  CheckEquals('Фискальный признак:', TrimRight(FPrinter.Lines[18]));
  CheckEquals('Время:                 04.08.2022 17:09:35', TrimRight(FPrinter.Lines[19]));
  CheckEquals('Оператор фискальных данных:АО "КазТранском', TrimRight(FPrinter.Lines[20]));
  CheckEquals('Для проверки чека зайдите на сайт:', TrimRight(FPrinter.Lines[21]));
  CheckEquals('dev.kofd.kz/consumer', TrimRight(FPrinter.Lines[22]));
  CheckEquals(Separator, TrimRight(FPrinter.Lines[23]));
  CheckEquals('              ФИСКАЛЬНЫЙ ЧЕK', TrimRight(FPrinter.Lines[24]));
  CheckEquals('http://dev.kofd.kz/consumer?i=923956785162', TrimRight(FPrinter.Lines[25]));
  CheckEquals('               ИНК ОФД: 270', TrimRight(FPrinter.Lines[26]));
  CheckEquals('     Код ККМ КГД (РНМ): 211030200207', TrimRight(FPrinter.Lines[27]));
  CheckEquals('             ЗНМ: SWK00032685', TrimRight(FPrinter.Lines[28]));
  CheckEquals('           Callцентр 039458039850', TrimRight(FPrinter.Lines[29]));
  CheckEquals('          Горячая линия 20948802934', TrimRight(FPrinter.Lines[30]));
  CheckEquals('            СПАСИБО ЗА ПОКУПКУ', TrimRight(FPrinter.Lines[31]));
  CheckEquals('', TrimRight(FPrinter.Lines[32]));
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

initialization
  RegisterTest('', TWebkassaImplTest.Suite);

end.

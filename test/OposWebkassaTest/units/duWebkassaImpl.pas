
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
  CustomReceipt, uLkJSON, ReceiptTemplate, SalesReceipt;

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
    procedure PrintReceipt3;
    procedure CheckLines;
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
    procedure TestXReport;
    procedure TestReceiptTemplate; // !!!
  published
    procedure TestZReport;
    procedure TestCashIn;
    procedure TestCashOut;
    procedure TestNonFiscal;

    procedure OpenClaimEnable;
    procedure TestFiscalReceipt;
    procedure TestFiscalReceipt3;
    procedure TestCoverError;
    procedure TestRecEmpty;
    procedure TestStatusUpateEvent;
    procedure TestDuplicateReceipt;
    procedure TestSetHeaderLines;
    procedure TestSetTrailerLines;
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
    ' ' + CRLF +
    '   ????????-???????????? ???????, ?????' + CRLF +
    '    ????-???????????, ??. ??????????, 1/10' + CRLF +
    '            ??? PetroRetail';
  FDriver.Params.TrailerText :=
    '           Call????? 039458039850 ' + CRLF +
    '          ??????? ????? 20948802934' + CRLF +
    '            ??????? ?? ???????';


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

procedure TWebkassaImplTest.CheckLines;
var
  i: Integer;
begin
  //CheckEquals(FLines.Count, FPrinter.Lines.Count, 'FPrinter.Lines.Count');
  for i := 0 to FLines.Count-1 do
  begin
    CheckEquals(Trim(FLines[i]), Trim(FPrinter.Lines[i]), IntToStr(i));
  end;
end;

procedure TWebkassaImplTest.TestCashIn;
const
  CashInReceiptText: string =
    '                                          ' + CRLF +
    '   ????????-???????????? ???????, ?????   ' + CRLF +
    '    ????-???????????, ??. ??????????, 1/10' + CRLF +
    '            ??? PetroRetail               ' + CRLF +
    '???                                       ' + CRLF +
    '???  ??? ???                              ' + CRLF +
    'Message 1                                 ' + CRLF +
    'Message 2                                 ' + CRLF +
    ESC_Bold + '???????? ????? ? ?????              =60.00' + CRLF +
    ESC_Bold + '???????? ? ?????                     =0.00' + CRLF +
    'Message 3                                 ' + CRLF +
    'Message 4                                 ' + CRLF +
    '           Call????? 039458039850         ' + CRLF +
    '          ??????? ????? 20948802934       ' + CRLF +
    '            ??????? ?? ???????            ' + CRLF +
    '                                          ';
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
    '   ????????-???????????? ???????, ?????   ' + CRLF +
    '    ????-???????????, ??. ??????????, 1/10' + CRLF +
    '            ??? PetroRetail               ' + CRLF +
    '???                                       ' + CRLF +
    '???  ??? ???                              ' + CRLF +
    'Message 1                                 ' + CRLF +
    'Message 2                                 ' + CRLF +
    ESC_Bold + '??????? ????? ?? ?????              =60.00' + CRLF +
    ESC_Bold + '???????? ? ?????                     =0.00' + CRLF +
    'Message 3                                 ' + CRLF +
    'Message 4                                 ' + CRLF +
    '           Call????? 039458039850         ' + CRLF +
    '          ??????? ????? 20948802934       ' + CRLF +
    '            ??????? ?? ???????            ' + CRLF +
    '                                          ';
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
    '?????? ??? ?????? 1                       ' + CRLF +
    '?????? ??? ?????? 2                       ' + CRLF +
    '?????? ??? ?????? 3                       ' + CRLF +
    '                                          ';
begin
  OpenClaimEnable;
  CheckEquals(0, Driver.ResetPrinter, 'ResetPrinter');
  CheckEquals(0, Driver.BeginNonFiscal, 'BeginNonFiscal');
  CheckEquals(0, Driver.PrintNormal(FPTR_S_RECEIPT, '?????? ??? ?????? 1'));
  CheckEquals(0, Driver.PrintNormal(FPTR_S_RECEIPT, '?????? ??? ?????? 2'));
  CheckEquals(0, Driver.PrintNormal(FPTR_S_RECEIPT, '?????? ??? ?????? 3'));
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
    ErrorItem.Text := '????????????????? ????? ????????? 24 ????';

    OpenClaimEnable;

    FDriver.Client.TestErrorResult := ErrorResult;

    CheckEquals(0, Driver.ResetPrinter, 'Driver.ResetPrinter');
    CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
    Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
    CheckEquals(FPTR_RT_SALES, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));

    FptrCheck(Driver.BeginFiscalReceipt(True));
    CheckEquals(FPTR_PS_FISCAL_RECEIPT, Driver.GetPropertyNumber(PIDXFptr_PrinterState));

    FptrCheck(Driver.PrintRecItem('Item 1', 123.45, 1000, 0, 123.45, '??'));
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
    '   ????????-???????????? ???????, ?????   ' + CRLF +
    '    ????-???????????, ??. ??????????, 1/10' + CRLF +
    '            ??? PetroRetail               ' + CRLF +
    '??? ????? VATSeries            ? VATNumber' + CRLF +
    '------------------------------------------' + CRLF +
    '               CashBox.Name               ' + CRLF +
    '                ????? 149                 ' + CRLF +
    '???????                                   ' + CRLF +
    '------------------------------------------' + CRLF +
    'Message 1                                 ' + CRLF +
    '???. ? 5                                  ' + CRLF +
    '?????????? ?????? MILKA BUBBLES ????????  ' + CRLF +
    '   1.000 ?? x 123.45                      ' + CRLF +
    '   ??????                           -22.35' + CRLF +
    '   ???????                          +11.17' + CRLF +
    '   ?????????                        112.27' + CRLF +
    'Message 2                                 ' + CRLF +
    'Item 2                                    ' + CRLF +
    '   1.000 ?? x 1.45                        ' + CRLF +
    '   ??????                            -0.45' + CRLF +
    '   ?????????                          1.00' + CRLF +
    'Message 3                                 ' + CRLF +
    '------------------------------------------' + CRLF +
    '??????:                              10.00' + CRLF +
    '???????:                              5.00' + CRLF +
    ESC_DoubleHighWide + '????          =108.27' + CRLF +
    '?????????? ?????:                  =123.45' + CRLF +
    '  ?????                             =15.18' + CRLF +
    '? ?.?. ??? 12%                      =12.14' + CRLF +
    '------------------------------------------' + CRLF +
    '?????????? ???????: 923956785162          ' + CRLF +
    '?????: 04.08.2022 17:09:35                ' + CRLF +
    '???????? ?????????? ??????:               ' + CRLF +
    '?? "???????????"                          ' + CRLF +
    '??? ???????? ???? ??????? ?? ????:        ' + CRLF +
    'dev.kofd.kz/consumer                      ' + CRLF +
    '------------------------------------------' + CRLF +
    '              ?????????? ??K              ' + CRLF +
    '               ??? ???: 270               ' + CRLF +
    '     ??? ??? ??? (???): 211030200207      ' + CRLF +
    '             ???: SWK00032685             ' + CRLF +
    'Message 4                                 ' + CRLF +
    '           Call????? 039458039850         ' + CRLF +
    '          ??????? ????? 20948802934       ' + CRLF +
    '            ??????? ?? ???????            ' + CRLF +
    '                                          ';

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
  pData: Integer;
  pString: WideString;
  OptArgs: Integer;
  Data: WideString;
begin
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

  FptrCheck(Driver.BeginFiscalReceipt(True));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  // Item 1
  FptrCheck(Driver.PrintRecMessage('Message 1'));

  pData := DriverParameterBarcode;
  pString := ItemBarcode;
  FptrCheck(Driver.DirectIO(DIO_SET_DRIVER_PARAMETER, pData, pString));
  FptrCheck(Driver.PrintRecItem('???. ? 5                                  ?????????? ?????? MILKA BUBBLES ????????', 123.45, 1000, 1, 123.45, '??'));
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_AMOUNT_DISCOUNT, '?????? 10', 10, 1));
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_AMOUNT_SURCHARGE, '???????? 5', 5, 1));
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_PERCENTAGE_DISCOUNT, '?????? 10%', 10, 1));
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_PERCENTAGE_SURCHARGE, '?????? 5%', 5, 1));
  // Item 2
  FptrCheck(Driver.PrintRecMessage('Message 2'));
  FptrCheck(Driver.PrintRecItem('Item 2', 1.45, 1000, 1, 1.45, '??'));
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_AMOUNT_DISCOUNT, '??????', 0.45, 1));
  // Total adjustment
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_AMOUNT_DISCOUNT, '?????? 10', 10));
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_AMOUNT_SURCHARGE, '???????? 5', 5));
  // Total
  FptrCheck(Driver.PrintRecMessage('Message 3'));
  FptrCheck(Driver.PrintRecTotal(123.45, 123.45, '1'));
  FptrCheck(Driver.PrintRecMessage('Message 4'));

  CheckEquals(FPTR_PS_FISCAL_RECEIPT_ENDING, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  CheckEquals(OPOS_SUCCESS, Driver.EndFiscalReceipt(False));
  CheckEquals(OPOS_SUCCESS, Driver.GetData(FPTR_GD_RECEIPT_NUMBER, OptArgs, Data));
  CheckEquals('923956785162', Data);
end;

procedure TWebkassaImplTest.TestDuplicateReceipt;
begin
  OpenClaimEnable;
  CheckEquals(1, Driver.GetPropertyNumber(PIDXFptr_CapDuplicateReceipt), 'CapDuplicateReceipt');
  Driver.SetPropertyNumber(PIDXFptr_DuplicateReceipt, 1);
  PrintReceipt3;
  FLines.Assign(FPrinter.Lines);
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

procedure TWebkassaImplTest.TestReceiptTemplate;
var
  Json: TlkJSON;
  JsonText: WideString;
  JsonRoot: TlkJSONbase;
  Template: TReceiptTemplate;
  TemplateItem: TTemplateItem;
  Receipt: TSalesReceipt;
  Command: TSendReceiptCommand;
begin
  Json := TlkJSON.Create;
  Receipt := TSalesReceipt.Create;
  Template := TReceiptTemplate.Create;
  Command := TSendReceiptCommand.Create;
  try
    JsonText := ReadFileData(GetModulePath + 'SendReceiptAnswer.txt');
    JsonRoot := Json.ParseText(JsonText);
    CheckEquals('923956785162', Driver.GetJsonField(JsonRoot, 'Data.CheckNumber'));
    CheckEquals(false, Driver.GetJsonField(JsonRoot, 'Data.CashboxOfflineMode'));
    CheckEquals(3, Driver.GetJsonField(JsonRoot, 'Data.Cashbox.Ofd.Code'));
    CheckEquals('dev.kofd.kz/consumer', Driver.GetJsonField(JsonRoot, 'Data.Cashbox.Ofd.Host'));

    // Line 1
    Template.Items.AddText('??? ????? ');
    Template.Items.AddParam('VATSeries');
    Template.Items.AddText(' ? %s');
    Template.Items.AddParam('VATNumber');
    Template.Items.AddText(CRLF);
    // Line2
    Template.Items.AddSeparator;
    // Line3
    //Template.Items.AddField('CashBox.Name');
    Template.Items.AddText(CRLF);
    // Line4
    TemplateItem := Template.Items.AddText('????? ');
    TemplateItem.Alignment := ALIGN_CENTER;
    Template.Items.AddField('Data.ShiftNumber');
    TemplateItem.Alignment := ALIGN_CENTER;
    Template.Items.AddText(CRLF);
    //
    CheckEquals(0, Driver.Document.Items.Count, 'Driver.Document.Items.Count');
    Driver.PrintReceipt2(Receipt, Command, Template, JsonRoot);

    FLines.Text := Receipt3Text;
    CheckLines;
  finally
    Json.Free;
    Receipt.Free;
    Template.Free;
    Command.Free;
  end;
end;

(*
  Document.Addlines(Format('??? ????? %s', [Params.VATSeries]),
    Format('? %s', [Params.VATNumber]));
  Document.AddSeparator;
  Document.Add(Document.AlignCenter(FCashBox.Name));
  Document.Add(Document.AlignCenter(Format('????? %d', [Command.Data.ShiftNumber])));
  Document.Add(OperationTypeToText(Command.Request.OperationType));

  //Document.Add(AlignCenter(Format('?????????? ????? ???? ?%d', [Command.Data.DocumentNumber])));
  //Document.Add(Format('??? ?%s', [Command.Data.CheckNumber]));
  //Document.Add(Format('?????? %s', [Command.Data.EmployeeName]));
  //Document.Add(UpperCase(Command.Data.OperationTypeText));
  Document.AddSeparator;


  for i := 0 to Receipt.Items.Count-1 do
  begin
    ReceiptItem := Receipt.Items[i];
    if ReceiptItem is TSalesReceiptItem then
    begin
      RecItem := ReceiptItem as TSalesReceiptItem;
      //Document.Add(Format('%3d. %s', [RecItem.Number, RecItem.Description]));
      Document.Add(RecItem.Description);

      ItemQuantity := 1;
      UnitPrice := RecItem.Price;
      if RecItem.Quantity <> 0 then
      begin
        ItemQuantity := RecItem.Quantity;
        UnitPrice := RecItem.UnitPrice;
      end;
      Document.Add(Format('   %.3f %s x %s', [ItemQuantity,
        RecItem.UnitName, AmountToStr(UnitPrice)]));
      // ??????
      Adjustment := RecItem.GetDiscount;
      if Adjustment.Amount <> 0 then
      begin
        if Adjustment.Name = '' then
          Adjustment.Name := '??????';
        Document.AddLines('   ' + Adjustment.Name,
          '-' + AmountToStr(Abs(Adjustment.Amount)));
      end;
      // ???????
      Adjustment := RecItem.GetCharge;
      if Adjustment.Amount <> 0 then
      begin
        if Adjustment.Name = '' then
          Adjustment.Name := '???????';
        Document.AddLines('   ' + Adjustment.Name,
          '+' + AmountToStr(Abs(Adjustment.Amount)));
      end;
      Document.AddLines('   ?????????', AmountToStr(RecItem.GetTotalAmount(Params.RoundType)));
    end;
    // Text
    if ReceiptItem is TRecTexItem then
    begin
      TextItem := ReceiptItem as TRecTexItem;
      Document.Add(TextItem.Text, TextItem.Style);
    end;
  end;
  Document.AddSeparator;
  // ?????? ?? ???
  Amount := Receipt.GetDiscount;
  if Amount <> 0 then
  begin
    Document.AddLines('??????:', AmountToStr(Amount));
  end;
  // ??????? ?? ???
  Amount := Receipt.GetCharge;
  if Amount <> 0 then
  begin
    Document.AddLines('???????:', AmountToStr(Amount));
  end;
  // ????
  Text := Document.ConcatLines('????', AmountToStrEq(Receipt.GetTotal), Document.LineChars div 2);
  Document.Add(Text, STYLE_DWIDTH_HEIGHT);
  // Payments
  for i := Low(Receipt.Payments) to High(Receipt.Payments) do
  begin
    Amount := Receipt.Payments[i];
    if Amount <> 0 then
    begin
      Document.AddLines(GetPaymentName(i) + ':', AmountToStrEq(Amount));
    end;
  end;
  if Receipt.Change <> 0 then
  begin
    Document.AddLines('  ?????', AmountToStrEq(Receipt.Change));
  end;

  // VAT amounts
  for i := 0 to Params.VatRates.Count-1 do
  begin
    VatRate := Params.VatRates[i];
    Amount := Receipt.GetTotalByVAT(VatRate.Code);
    if Amount <> 0 then
    begin
      Amount := Receipt.RoundAmount(Amount * VATRate.Rate / (100 + VATRate.Rate));
      Document.AddLines(Format('? ?.?. %s', [VATRate.Name]),
        AmountToStrEq(Amount));
    end;
  end;
  Document.AddSeparator;
  if Receipt.FiscalSign = '' then
  begin
    Receipt.FiscalSign := Command.Data.CheckNumber;
  end;
  Document.Add('?????????? ???????: ' + Receipt.FiscalSign);
  Document.Add('?????: ' + Command.Data.DateTime);
  Document.Add('???????? ?????????? ??????:');
  Document.Add(Command.Data.Cashbox.Ofd.Name);
  Document.Add('??? ???????? ???? ??????? ?? ????:');
  Document.Add(Command.Data.Cashbox.Ofd.Host);
  Document.AddSeparator;
  Document.Add(Document.AlignCenter('?????????? ??K'));
  Document.Add(Command.Data.TicketUrl, STYLE_QR_CODE);
  Document.Add(Document.AlignCenter('??? ???: ' + Command.Data.Cashbox.IdentityNumber));
  Document.Add(Document.AlignCenter('??? ??? ??? (???): ' + Command.Data.Cashbox.RegistrationNumber));
  Document.Add(Document.AlignCenter('???: ' + Command.Data.Cashbox.UniqueNumber));
  Document.AddText(Receipt.Trailer.Text);

  PrintDocumentSafe(Document);
  Printer.RecLineChars := FRecLineChars;
end;

*)

initialization
  RegisterTest('', TWebkassaImplTest.Suite);

end.

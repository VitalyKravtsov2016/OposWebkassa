unit duWebkassaImpl2;

interface

uses
  // VCL
  Windows, SysUtils, Classes, SyncObjs, Graphics,
  // DUnit
  TestFramework,
  // Mock
  PascalMock,
  // Opos
  Opos, OposFptr, Oposhi, OposFptrhi, OposFptrUtils, OposUtils,
  OposEvents, OposPtr, RCSEvents, OposEsc,
  // Tnt
  TntClasses, TntSysUtils,
  // This
  LogFile, WebkassaImpl, WebkassaClient, MockPosPrinter2, FileUtils,
  CustomReceipt, uLkJSON, ReceiptTemplate, SalesReceipt, DirectIOAPI,
  DebugUtils, StringUtils, OposServiceDevice19;

const
  CRLF = #13#10;

type
  { TWebkassaImplTest2 }

  TWebkassaImplTest2 = class(TTestCase, IOposEvents)
  private
    FWaitEvent: TEvent;
    FEvents: TOposEvents;
    FDriver: TWebkassaImpl;
    FPrinter: TMockPosPrinter2;

    procedure PrintReceipt;
  protected
    procedure CheckNoEvent;
    procedure WaitForEvent;
    procedure FptrCheck(Code: Integer);
    procedure AddEvent(Event: TOposEvent);
    procedure WaitForEventsCount(Count: Integer);

    property Events: TOposEvents read FEvents;
    property Driver: TWebkassaImpl read FDriver;
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
    procedure TestNonFiscal;
    procedure TestReceiptTemplate; // !!!
    procedure TestPrintQRCodeAsGraphics;
  published
    procedure TestMockMethod;
    procedure TestMockMethod2;
    procedure TestMockMethod3;

    procedure OpenService;
    procedure ClaimDevice;
    procedure EnableDevice;
    procedure OpenClaimEnable;
    procedure TestRenderQRCode;
  end;

implementation

const
  EventWaitTimeout  = 50;

const
  ReceiptText: string =
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

{ TWebkassaImplTest2 }

procedure TWebkassaImplTest2.SetUp;
begin
  inherited SetUp;
  FWaitEvent := TEvent.Create(nil, False, False, '');
  FEvents := TOposEvents.Create;
  FPrinter := TMockPosPrinter2.Create;

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
  DeleteFile(FDriver.Logger.FileName);
end;

procedure TWebkassaImplTest2.TearDown;
begin
  FPrinter.Expects('Set_DeviceEnabled').WithParams([False]);
  FPrinter.Expects('Close').Returns(0);

  FDriver.Free;
  FEvents.Free;
  FWaitEvent.Free;
  inherited TearDown;
end;

procedure TWebkassaImplTest2.WaitForEvent;
begin
  if FWaitEvent.WaitFor(EventWaitTimeout) <> wrSignaled then
    raise Exception.Create('Wait failed');
end;

procedure TWebkassaImplTest2.WaitForEventsCount(Count: Integer);
begin
  repeat
    WaitForEvent;
  until Events.Count >= Count;
end;

procedure TWebkassaImplTest2.CheckNoEvent;
begin
  if FWaitEvent.WaitFor(EventWaitTimeout) <> wrTimeOut then
    raise Exception.Create('Event fired');
end;

procedure TWebkassaImplTest2.AddEvent(Event: TOposEvent);
begin
  FEvents.Add(Event);
  FWaitEvent.SetEvent;
end;

procedure TWebkassaImplTest2.DataEvent(Status: Integer);
begin
  AddEvent(TDataEvent.Create(Status, EVENT_TYPE_INPUT, FDriver.Logger));
end;

procedure TWebkassaImplTest2.DirectIOEvent(EventNumber: Integer;
  var pData: Integer; var pString: WideString);
begin
  AddEvent(TDirectIOEvent.Create(EventNumber, pData, pString, FDriver.Logger));
end;

procedure TWebkassaImplTest2.ErrorEvent(ResultCode, ResultCodeExtended,
  ErrorLocus: Integer; var pErrorResponse: Integer);
begin
  AddEvent(TErrorEvent.Create(ResultCode, ResultCodeExtended, ErrorLocus, FDriver.Logger));
end;

procedure TWebkassaImplTest2.OutputCompleteEvent(OutputID: Integer);
begin
  AddEvent(TOutputCompleteEvent.Create(OutputID, FDriver.Logger));
end;

procedure TWebkassaImplTest2.StatusUpdateEvent(Data: Integer);
begin
  AddEvent(TStatusUpdateEvent.Create(Data, FDriver.Logger));
end;

procedure TWebkassaImplTest2.FptrCheck(Code: Integer);
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

procedure TWebkassaImplTest2.OpenService;
begin
  FPrinter.Expects('Open').WithParams(['ThermalU']).Returns(0);
  FptrCheck(Driver.OpenService(OPOS_CLASSKEY_FPTR, 'DeviceName', TRCSEvents.Create(Self)));
  FPrinter.Verify('OpenService');
end;

procedure TWebkassaImplTest2.ClaimDevice;
begin
  OpenService;
  FPrinter.Expects('ClaimDevice').WithParams([1000]).Returns(0);

  CheckEquals(0, Driver.GetPropertyNumber(PIDX_Claimed),
    'Driver.GetPropertyNumber(PIDX_Claimed)');
  FptrCheck(Driver.ClaimDevice(1000));
  CheckEquals(1, Driver.GetPropertyNumber(PIDX_Claimed),
    'Driver.GetPropertyNumber(PIDX_Claimed)');
  FPrinter.Verify('ClaimDevice');
end;

procedure TWebkassaImplTest2.EnableDevice;
var
  ResultCode: Integer;
begin
  ClaimDevice;

  FPrinter.Expects('Set_DeviceEnabled').WithParams([True]);
  FPrinter.Expects('Get_ResultCode').Returns(0);
  FPrinter.Expects('Set_RecLineChars').WithParams([42]);
  FPrinter.Expects('Set_RecLineSpacing').WithParams([30]);

  Driver.SetPropertyNumber(PIDX_DeviceEnabled, 1);
  ResultCode := Driver.GetPropertyNumber(PIDX_ResultCode);
  CheckEquals(OPOS_SUCCESS, ResultCode, 'OPOS_SUCCESS');
  CheckEquals(1, Driver.GetPropertyNumber(PIDX_DeviceEnabled), 'DeviceEnabled');

  FPrinter.Verify('EnableDevice');
end;

procedure TWebkassaImplTest2.OpenClaimEnable;
begin
  EnableDevice;
end;

procedure TWebkassaImplTest2.TestNonFiscal;
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

end;

procedure TWebkassaImplTest2.TestMockMethod;
var
  Mock: TMock;
  ResultCode: Integer;
begin
  Mock := TMock.Create;
  try
    Mock.Expects('Open').WithParams(['DeviceName']).Returns(123);
    ResultCode := Mock.AddCall('Open').WithParams(['DeviceName']).ReturnValue;
    Mock.Verify('OpenService');
    CheckEquals(123, ResultCode, 'ResultCode <> 0');
  finally
    Mock.Free;
  end;
end;

procedure TWebkassaImplTest2.TestMockMethod2;
var
  Printer: TMockPosPrinter2;
  ResultCode: Integer;
begin
  Printer := TMockPosPrinter2.Create;
  try
    Printer.Expects('Open').WithParams(['DeviceName']).Returns(123);
    ResultCode := Printer.AddCall('Open').WithParams(['DeviceName']).ReturnValue;
    Printer.Verify('OpenService');
    CheckEquals(123, ResultCode, 'ResultCode <> 0');
  finally
    Printer.Free;
  end;
end;

procedure TWebkassaImplTest2.TestMockMethod3;
var
  Printer: TMockPosPrinter2;
  ResultCode: Integer;
begin
  Printer := TMockPosPrinter2.Create;
  try
    Printer.Expects('Open').WithParams(['DeviceName']).Returns(123);
    ResultCode := Printer.Open('DeviceName');
    Printer.Verify('OpenService');
    CheckEquals(123, ResultCode, 'ResultCode <> 0');
  finally
    Printer.Free;
  end;
end;

procedure TWebkassaImplTest2.PrintReceipt;
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
  pString := '8234827364';
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

procedure TWebkassaImplTest2.TestReceiptTemplate;
var
  i: Integer;
  Lines: TStrings;
begin
  Lines := TStringList.Create;
  try
    Driver.Params.TemplateEnabled := True;
    Driver.Params.Template.SetDefaults;

    OpenClaimEnable;

    FPrinter.Expects('Get_RecLineChars').Returns(42);
    FPrinter.Expects('Get_RecLineHeight').Returns(10);
    FPrinter.Expects('Get_RecLineSpacing').Returns(6);

    FPrinter.Expects('CheckHealth').WithParams([OPOS_CH_INTERNAL]).Returns(0);
    FPrinter.Expects('Get_CapRecEmptySensor').Returns(True);
    FPrinter.Expects('Get_RecEmpty').Returns(False);
    FPrinter.Expects('Get_CapCoverSensor').Returns(True);
    FPrinter.Expects('Get_CoverOpen').Returns(False);
    FPrinter.Expects('Get_CapRecDwideDhigh').Returns(False);
    FPrinter.Expects('Get_CapRecBold').Returns(False);

    FPrinter.Expects('Get_RecLineChars').Returns(42);
    FPrinter.Expects('Get_RecLineHeight').Returns(10);
    FPrinter.Expects('Get_RecLineSpacing').Returns(6);

    FPrinter.Expects('Get_CapTransaction').Returns(True);
    FPrinter.Expects('TransactionPrint').WithParams([PTR_S_RECEIPT, PTR_TP_TRANSACTION]).Returns(0);

    Lines.Text := ReceiptText;
    for i := 0 to Lines.Count-1 do
    begin
      FPrinter.Expects('PrintNormal').WithParams([PTR_S_RECEIPT, Lines[i]]).Returns(0);
    end;
    PrintReceipt;
    FPrinter.Verify('TestReceiptTemplate');

  finally
    Lines.Free;
  end;
end;

procedure TWebkassaImplTest2.TestPrintQRCodeAsGraphics;
const
  BarcodeData = 'https://devkkm.webkassa.kz/Ticket?chb=SWK00033059&sh=100&extnum=92D51F08-13CF-428E-AF2F-67B6E8BDE994';
  BitmapData =
    '3?3?0000003>0028004:004:00010100003?00000000000200000000003?793?3?3?3?00003?3?3?'+
    '3?00003?3<3?3?3?003?3<3?3?3?003?3?3?413?003?3?3?413?003?3?3?3?3?003?3?3?3?3?003?'+
    '3?3?413?003?3?3?413?003?3?303?3?003?3?303?3?003?3?3?3?00003?3?3?3?00003?3?3?3?03'+
    '003?3?3?3?03003?3?3?7500003?3?3?7500003?3?3?3?3?003?3?3?3?3?003?3?3?3?3?003?3?3?'+
    '3?3?003?3?3?3?0?003?3?3?3?0?003?3?3?3?00003?3?3?3?00003?3?3?3?3?003?3?3?3?3?003?'+
    '3?3?3?3?003?3?3?3?3?003?0?3?3?3?003?0?3?3?3?003?3?3?3?3?003?3?3?3?3?003?3?3?3?3?'+
    '003?3?3?3?3?003?3?3?3?30003?3?3?3?30003?3?3?3?49003?3?3?3?49003?3?3?3?3?003?3?3?'+
    '3?3?003?3?3?3?49003?3?3?3?49003?3?3?3?3?003?3?3?3?3?003?3?3?0003003?3?3?0003003?'+
    '3?3?3?03003?3?3?3?03003?3?3?413?003?3?3?413?003<3?3?3?3?003<3?3?3?3?003?3?3?3?3?'+
    '003?3?3?3?3?003?3?3?3?03003?3?3?3?03003?3?3?3?3?003?3?3?3?3?003?3?3?3?00003?3?3?'+
    '3?00003?3?3?3?79003?3?3?3?79003?3?3?3?03003?3?3?3?03003?3?3?3?03003?3?3?3?03003?'+
    '3?3?3?03003?3?3?3?03003?3?3?3?79003?3?3?3?79003?3?3?3?00003?3?3?3?00003132333434'+
    '3535227=006=222<22437573746?6=657250686?6>65223:222;3737373731323334343535227=00'+
    '09225461785061796572494>223:2022313331323430303130343739222<0=0:0909225461785061'+
    '796572564154223:20747275652<0=0:09092254617850617965725641545365726961223:202230'+
    '30303030222<0=0:09092254617850617965725641544>756=626572223:20223030303030303022'+
    '2<0=0:0909225265706?72744>756=626572223:2031332<0=0:09092243617368626?78534>223:'+
    '202253574;3030303332363835222<0=0:09092243617368626?78494>223:203237302<0=0:0909'+
    '2243617368626?78524>223:2022323131303330323030323037222<0=0:09092253746172744?6>'+
    '223:202230392>30382>323032322031393:34323:3430222<0=0:0909225265706?72744?6>223:'+
    '202231322>30382>323032322031363:34393:3331222<0=0:090922436<6?73654?6>223:202231'+
    '322>30382>323032322030313:34393:3037222<0=0:09092243617368696572436?6465223:2031'+
    '2<0=0:09092253686966744>756=626572223:203135342<0=0:090922446?63756=656>74436?75'+
    '6>74223:2031332<0=0:0909225075744=6?6>657953756=223:20302>30';
begin
  FPrinter.Expects('Get_CapRecBitmap').Returns(True);
  FPrinter.Expects('Set_BinaryConversion').WithParams([OPOS_BC_NIBBLE]);
  FPrinter.Expects('PrintMemoryBitmap').WithParams([PTR_S_RECEIPT, BitmapData,
    PTR_BMT_BMP, PTR_BM_ASIS, PTR_BM_CENTER]).Returns(0);
  FPrinter.Expects('Set_BinaryConversion').WithParams([OPOS_BC_NONE]);
  Driver.PrintQRCodeAsGraphics(BarcodeData);
  FPrinter.Verify('TestPrintQRCodeAsGraphics');
end;


procedure TWebkassaImplTest2.TestRenderQRCode;
const
  BarcodeData = 'https://devkkm.webkassa.kz/Ticket?chb=SWK00033059&sh=100&extnum=92D51F08-13CF-428E-AF2F-67B6E8BDE994';
var
  Data: AnsiString;
  Graphic: TGraphic;
  Stream: TMemoryStream;
begin
  Data := Driver.RenderQRCode(BarcodeData);

  Graphic := TBitmap.Create;
  Stream := TMemoryStream.Create;
  try
    Stream.Write(Data[1], Length(Data));
    Stream.Position := 0;
    Graphic.LoadFromStream(Stream);

    CheckEquals(74, Graphic.Width, 'Graphic.Width');
    CheckEquals(74, Graphic.Height, 'Graphic.Height');
    Graphic.SaveToFile(GetModulePath + 'QRCodeBitmap.bmp');
  finally
    Stream.Free;
    Graphic.Free;
  end;
end;

initialization
  RegisterTest('', TWebkassaImplTest2.Suite);


end.

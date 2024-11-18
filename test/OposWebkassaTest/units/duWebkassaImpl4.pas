unit duWebkassaImpl4;

interface

uses
  // VCL
  Windows, SysUtils, Classes, SyncObjs, Math,
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
  DebugUtils, StringUtils, PrinterTypes, PrinterParameters,
  RawPrinterPort;

const
  CRLF = #13#10;

type
  { TRawPrinterPortTest }

  TRawPrinterPortTest = class(TRawPrinterPort)
  public
    procedure Flush; override;
  end;

  { TWebkassaImplTest4 }

  TWebkassaImplTest4 = class(TTestCase)
  private
    FPort: TRawPrinterPortTest;
    FDriver: TWebkassaImpl;
  protected
    procedure OpenService;
    procedure ClaimDevice;
    procedure EnableDevice;
    procedure OpenClaimEnable;
    procedure FptrCheck(Code: Integer);

    property Driver: TWebkassaImpl read FDriver;
    property Port: TRawPrinterPortTest read FPort;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestPrintDuplicate;
  end;

implementation

{ TRawPrinterPortTest }

procedure TRawPrinterPortTest.Flush;
begin

end;

{ TWebkassaImplTest4 }

procedure TWebkassaImplTest4.SetUp;
begin
  inherited SetUp;
  FDriver := TWebkassaImpl.Create(nil);
  FPort := TRawPrinterPortTest.Create(FDriver.Logger, '');
  FDriver.Port := FPort;
  FDriver.TestMode := True;
  FDriver.LoadParamsEnabled := False;
  FDriver.Client.TestMode := True;
  FDriver.Params.FontName := 'Font A (12x24)';
  FDriver.Params.RecLineChars := 42;
  FDriver.Params.RecLineHeight := 24;
  FDriver.Params.LineSpacing := 0;
  FDriver.Params.LogFileEnabled := False;
  FDriver.Params.LogMaxCount := 10;
  FDriver.Params.LogFilePath := 'Logs';
  FDriver.Params.Login := 'webkassa4@softit.kz';
  FDriver.Params.Password := 'Kassa123';
  FDriver.Params.ConnectTimeout := 10;
  FDriver.Params.WebkassaAddress := 'https://devkkm.webkassa.kz/';
  FDriver.Params.CashboxNumber := 'SWK00032685';
  FDriver.Params.PrinterName := 'ThermalU';
  FDriver.Params.PrinterType := PrinterTypeEscPrinterWindows;
  FDriver.Params.PrintBarcode := PrintBarcodeEscCommands;
  FDriver.Params.NumHeaderLines := 4;
  FDriver.Params.NumTrailerLines := 3;
  FDriver.Params.RoundType := RoundTypeNone;
  FDriver.Params.CurrencyName := 'руб';
  FDriver.Params.PaymentType2 := PaymentTypeCard;
  FDriver.Params.PaymentType3 := PaymentTypeCredit;
  FDriver.Params.PaymentType4 := PaymentTypeMobile;
  FDriver.Params.VatRates.Clear;
  FDriver.Params.VatRates.Add(4, 12, 'VAT 12%');
  FDriver.Params.VatRateEnabled := True;

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
end;

procedure TWebkassaImplTest4.TearDown;
begin
  if FDriver <> nil then
    FDriver.Close;

  FDriver.Free;
  inherited TearDown;
end;

procedure TWebkassaImplTest4.FptrCheck(Code: Integer);
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

procedure TWebkassaImplTest4.OpenService;
begin
  FptrCheck(Driver.OpenService(OPOS_CLASSKEY_FPTR, 'DeviceName', nil));
end;

procedure TWebkassaImplTest4.ClaimDevice;
begin
  CheckEquals(0, Driver.GetPropertyNumber(PIDX_Claimed),
    'Driver.GetPropertyNumber(PIDX_Claimed)');
  FptrCheck(Driver.ClaimDevice(1000));
  CheckEquals(1, Driver.GetPropertyNumber(PIDX_Claimed),
    'Driver.GetPropertyNumber(PIDX_Claimed)');
end;

procedure TWebkassaImplTest4.EnableDevice;
var
  ResultCode: Integer;
begin
  Driver.SetPropertyNumber(PIDX_DeviceEnabled, 1);
  ResultCode := Driver.GetPropertyNumber(PIDX_ResultCode);
  CheckEquals(OPOS_SUCCESS, ResultCode, 'OPOS_SUCCESS');
  CheckEquals(1, Driver.GetPropertyNumber(PIDX_DeviceEnabled), 'DeviceEnabled');
  Driver.SetPropertyNumber(PIDXFptr_CheckTotal, 1);
end;

procedure TWebkassaImplTest4.OpenClaimEnable;
begin
  OpenService;
  ClaimDevice;
  EnableDevice;
end;

procedure TWebkassaImplTest4.TestPrintDuplicate;
var
  Buffer: AnsiString;
begin
  OpenClaimEnable;
  FDriver.Client.TestMode := True;
  FDriver.Client.AnswerJson := ReadFileData(GetModulePath + 'ReadReceiptTextAnswer2.txt');

  FptrCheck(Driver.ResetPrinter);
  FptrCheck(Driver.DirectIO2(DIO_PRINT_RECEIPT_DUPLICATE, 0, '{29FA3A2F-5A60-47E4-872B-6AE8C3893CC7}'));
  Buffer := ReadFileData('ReceiptDuplicate.bin');
  if Buffer <> Port.Buffer then
  begin
    WriteFileData('ReceiptDuplicateErr.bin', Port.Buffer);
    CheckEquals(StrToHexText(Buffer), StrToHexText(Port.Buffer), 'Port.Buffer');
  end;
end;

initialization
  RegisterTest('', TWebkassaImplTest4.Suite);


end.

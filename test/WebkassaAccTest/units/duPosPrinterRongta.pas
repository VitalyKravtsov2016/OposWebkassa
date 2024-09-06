unit duPosPrinterRongta;

interface

uses
  // VCL
  Windows, SysUtils, Classes, Forms,
  // DUnit
  TestFramework,
  // Opos
  Opos, OposEsc, Oposhi, OposPtr, OposPtrUtils, OposUtils,
  OposPOSPrinter_CCO_TLB, OposEvents,
  // Tnt
  TntClasses, TntSysUtils, DebugUtils, StringUtils, SocketPort, LogFile,
  PrinterPort, PosPrinterRongta, SerialPort, RawPrinterPort, EscPrinterRongta;

type
  { TPosPrinterRongtaTest }

  TPosPrinterRongtaTest = class(TTestCase)
  private
    FLogger: ILogFile;
    FEvents: TStrings;
    FPrinter: TPosPrinterRongta;
    FPrinterPort: IPrinterPort;

    procedure ClaimDevice;
    procedure EnableDevice;
    procedure OpenService;
    procedure OpenClaimEnable;
    procedure PtrCheck(Code: Integer);
    procedure StatusUpdateEvent(ASender: TObject; Data: Integer);

    property Events: TStrings read FEvents;
    property Printer: TPosPrinterRongta read FPrinter;
    function GetKazakhUnicodeChars: WideString;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  public
    function CreateRawPort: TRawPrinterPort;
    function CreateSerialPort: TSerialPort;
    function CreateSocketPort: TSocketPort;
  published
    procedure TestCheckHealth;
    procedure TestPrintBarCode;
    procedure TestPrintBarCode2;
    procedure TestPrintBarCodeEsc;

    procedure TestStatusUpdateEvent;
    procedure TestCoverStateEvent;
    procedure TestPowerStateEvent;
    procedure TestPrintReceipt;
    procedure TestPrintNormal;
    procedure TestCharacterToCodePage;
  end;

implementation

{ TPosPrinterRongtaTest }

procedure TPosPrinterRongtaTest.PtrCheck(Code: Integer);
var
  Text: WideString;
begin
  if Code <> OPOS_SUCCESS then
  begin
    if Printer.ResultCode = OPOS_E_EXTENDED then
      Text := Tnt_WideFormat('%d, %d, %s [%s]', [Printer.ResultCode, Printer.ResultCodeExtended,
      PtrResultCodeExtendedText(Printer.ResultCodeExtended), Printer.ErrorString])
    else
      Text := Tnt_WideFormat('%d, %s [%s]', [Printer.ResultCode,
        GetResultCodeText(Printer.ResultCode), Printer.ErrorString]);

    raise Exception.Create(Text);
  end;
end;

procedure TPosPrinterRongtaTest.SetUp;
begin
  inherited SetUp;
  FLogger := TLogFile.Create;
  FLogger.Enabled := True;
  FLogger.MaxCount := 10;
  FLogger.FilePath := 'Logs';
  FLogger.DeviceName := 'DeviceName';
  FEvents := TStringList.Create;
  //FPrinterPort := CreateSerialPort;
  FPrinterPort := CreateRawPort;
  FPrinter := TPosPrinterRongta.Create2(nil, FPrinterPort, FLogger);
  FPrinter.OnStatusUpdateEvent := StatusUpdateEvent;
  FPrinter.BarcodeInGraphics := False;
end;

procedure TPosPrinterRongtaTest.StatusUpdateEvent(ASender: TObject; Data: Integer);
begin
  Events.Add(PtrStatusUpdateEventText(Data));
end;

function TPosPrinterRongtaTest.CreateRawPort: TRawPrinterPort;
begin
  //Result := TRawPrinterPort.Create(FLogger, 'RONGTA 80mm Series Printer');
  Result := TRawPrinterPort.Create(FLogger, 'POS-80C');
end;

function TPosPrinterRongtaTest.CreateSerialPort: TSerialPort;
var
  SerialParams: TSerialParams;
begin
  SerialParams.PortName := 'COM3';
  SerialParams.BaudRate := CBR_19200;
  SerialParams.DataBits := DATABITS_8;
  SerialParams.StopBits := STOPBITS_10;
  SerialParams.Parity := NOPARITY;
  SerialParams.FlowControl := FLOW_CONTROL_NONE;
  SerialParams.ReconnectPort := False;
  SerialParams.ByteTimeout := 200;
  Result := TSerialPort.Create(SerialParams, FLogger);
end;

function TPosPrinterRongtaTest.CreateSocketPort: TSocketPort;
var
  SocketParams: TSocketParams;
begin
  SocketParams.RemoteHost := '10.11.7.176';
  SocketParams.RemotePort := 9100;
  SocketParams.MaxRetryCount := 1;
  SocketParams.ByteTimeout := 1000;
  Result := TSocketPort.Create(SocketParams, FLogger);
end;

procedure TPosPrinterRongtaTest.TearDown;
begin
  FPrinter.Close;
  FPrinter.Free;
  FEvents.Free;
  FPrinterPort := nil;
  inherited TearDown;
end;

procedure TPosPrinterRongtaTest.OpenService;
begin
  PtrCheck(Printer.Open('ThermalU'));

  if (FPrinterPort.GetDescription <> 'RawPrinterPort') then
  begin
    CheckEquals(OPOS_PR_STANDARD, Printer.CapPowerReporting, 'CapPowerReporting');
    CheckEquals(OPOS_PN_DISABLED, Printer.PowerNotify, 'PowerNotify');
  end;
  CheckEquals(False, Printer.FreezeEvents, 'FreezeEvents');

  if Printer.CapPowerReporting <> OPOS_PR_NONE then
  begin
    Printer.PowerNotify := OPOS_PN_ENABLED;
    CheckEquals(OPOS_PN_ENABLED, Printer.PowerNotify, 'PowerNotify');
  end;
end;

procedure TPosPrinterRongtaTest.ClaimDevice;
begin
  CheckEquals(False, Printer.Claimed, 'Printer.Claimed');
  PtrCheck(Printer.ClaimDevice(1000));
  CheckEquals(True, Printer.Claimed, 'Printer.Claimed');
end;

procedure TPosPrinterRongtaTest.EnableDevice;
begin
  Printer.DeviceEnabled := True;
  PtrCheck(Printer.ResultCode);
  CheckEquals(True, Printer.DeviceEnabled, 'DeviceEnabled <> True');
end;

procedure TPosPrinterRongtaTest.OpenClaimEnable;
begin
  OpenService;
  ClaimDevice;
  EnableDevice;
end;

procedure TPosPrinterRongtaTest.TestCheckHealth;
begin
  OpenClaimEnable;
  PtrCheck(Printer.CheckHealth(OPOS_CH_INTERACTIVE));
end;

procedure TPosPrinterRongtaTest.TestPrintBarCode;
const
  Barcode = 'http://dev.kofd.kz/consumer?i=925871425876&f=211030200207&s=15443.72&t=20220826T210014';
  CRLF = #13#10;
var
  i: Integer;
begin
  OpenClaimEnable;

  if Printer.CapTransaction then
  begin
    PtrCheck(Printer.TransactionPrint(PTR_S_RECEIPT, PTR_TP_TRANSACTION));
  end;
  for i := 0 to 10 do
  begin
    PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, 'Line ' + IntToStr(i) + CRLF));
  end;
  PtrCheck(Printer.PrintBarCode(PTR_S_RECEIPT, Barcode, PTR_BCS_DATAMATRIX, 0, 4,
    PTR_BC_CENTER, PTR_BC_TEXT_NONE));

  for i := 0 to 10 do
  begin
    PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, 'Line ' + IntToStr(i) + CRLF));
  end;
  PtrCheck(Printer.CutPaper(90));
  if Printer.CapTransaction then
  begin
    Printer.TransactionPrint(PTR_S_RECEIPT, PTR_TP_NORMAL);
  end;
end;

procedure TPosPrinterRongtaTest.TestPrintBarCode2;
const
  Barcode = 'http://dev.kofd.kz/consumer?i=925871425876&f=211030200207&s=15443.72&t=20220826T210014';
  CRLF = #13#10;
begin
  OpenClaimEnable;

  FPrinter.BarcodeInGraphics := False;
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, 'FPrinter.BarcodeInGraphics = False' + CRLF));
  PtrCheck(Printer.PrintBarCode(PTR_S_RECEIPT, Barcode + CRLF,
    PTR_BCS_QRCODE, 200, 200, PTR_BC_CENTER, PTR_BC_TEXT_NONE));

  FPrinter.BarcodeInGraphics := True;
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, 'FPrinter.BarcodeInGraphics = True' + CRLF));
  PtrCheck(Printer.PrintBarCode(PTR_S_RECEIPT, Barcode + CRLF,
    PTR_BCS_QRCODE, 200, 200, PTR_BC_CENTER, PTR_BC_TEXT_NONE));
end;

procedure TPosPrinterRongtaTest.TestPrintBarCodeEsc;
var
  L: Word;
  Data: string;
const
  Barcode = 'http://dev.kofd.kz/consumer?i=925871425876&f=211030200207&s=15443.72&t=20220826T210014';
begin
  OpenClaimEnable;

  //Data := #$1B#$64#$0A;
  //PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, Data));
  //PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, ESC + '|1fT' + 'Typeface 1' + CRLF));
  //PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, ESC + '|2fT' + 'Typeface 2' + CRLF));
  //PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, ESC + '|90P' + CRLF));

  // Select QR code model
  //Data := #$1D#$28#$6B#$04#$00#$31#$41#$31#$00;
  //PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, Data));

  // Set QR code module size
  Data := #$1D#$28#$6B#$03#$00#$31#$43#$04;
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, Data));

  L := Length(Barcode);

  Data := #$1D#$28#$6B + Chr(Lo(L)) + Chr(Hi(L)) + #$31#$50#$30 + Barcode;
  ODS(StrToHex(Data));
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, Data));

  Data := GS + '(k'+ #$03#$00#$31#$51#$30 + CRLF;
  ODS(StrToHex(Data));
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, Data));

(*
  // ESC/POS Command Manual
  Data := ESC + '|33Rs101h200w400a-2t-13d123456789012e' + CRLF;
  PtrCheck(Printer.ValidateData(PTR_S_RECEIPT, Data));
  //PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, Data));
*)
end;

procedure TPosPrinterRongtaTest.TestStatusUpdateEvent;
begin
  OpenClaimEnable;
  if Printer.PowerNotify <> OPOS_PN_DISABLED then
  begin
    CheckEquals(1, FEvents.Count, 'FEvents.Count');
    CheckEquals('OPOS_SUE_POWER_ONLINE', Events[0], 'OPOS_SUE_POWER_ONLINE');
  end;
end;

procedure TPosPrinterRongtaTest.TestCoverStateEvent;
begin
  OpenClaimEnable;
  if Printer.PowerNotify <> OPOS_PN_DISABLED then
  begin
    CheckEquals(1, FEvents.Count, 'FEvents.Count');
    CheckEquals('OPOS_SUE_POWER_ONLINE', FEvents[0], 'OPOS_SUE_POWER_ONLINE');
    FEvents.Clear;
    if Application.MessageBox('Open printer cover and press OK', 'Attention',
      MB_OKCANCEL) = ID_CANCEL then Abort;
    Check(FEvents.IndexOf('PTR_SUE_COVER_OPEN') <> -1, 'PTR_SUE_COVER_OPEN');
    FEvents.Clear;
    if Application.MessageBox('Close printer cover and press OK', 'Attention',
      MB_OKCANCEL) = ID_CANCEL then Abort;
    Check(FEvents.IndexOf('PTR_SUE_COVER_OK') <> -1, 'PTR_SUE_COVER_OK');
  end;
end;

procedure TPosPrinterRongtaTest.TestPowerStateEvent;
begin
  OpenClaimEnable;
  if Printer.PowerNotify <> OPOS_PN_DISABLED then
  begin
    CheckEquals(1, FEvents.Count, 'FEvents.Count');
    CheckEquals('OPOS_SUE_POWER_ONLINE', Events[0], 'OPOS_SUE_POWER_ONLINE');
    FEvents.Clear;
    if Application.MessageBox('Turn printer OFF and press OK', 'Attention',
      MB_OKCANCEL) = ID_CANCEL then Abort;
    Check(FEvents.IndexOf('OPOS_SUE_POWER_OFF_OFFLINE') <> -1, 'OPOS_SUE_POWER_OFF_OFFLINE');
    FEvents.Clear;
    if Application.MessageBox('Turn printer ON and press OK', 'Attention',
      MB_OKCANCEL) = ID_CANCEL then Abort;
    CheckEquals(1, FEvents.Count, 'FEvents.Count');
    CheckEquals('OPOS_SUE_POWER_ONLINE', Events[0], 'OPOS_SUE_POWER_ONLINE');
  end;
end;

procedure TPosPrinterRongtaTest.TestPrintReceipt;
var
  i: Integer;
const
  Barcode = 'http://dev.kofd.kz/consumer?i=925871425876&f=211030200207&s=15443.72&t=20220826T210014';
begin
  OpenClaimEnable;

  if Printer.CapTransaction then
  begin
    PtrCheck(Printer.TransactionPrint(PTR_S_RECEIPT, PTR_TP_TRANSACTION));
  end;
  for i := 1 to 5 do
  begin
    PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, '—ÚÓÍ‡ ' + IntToStr(i) + CRLF));
  end;
  PtrCheck(Printer.PrintBarCode(PTR_S_RECEIPT, Barcode, PTR_BCS_QRCODE, 0, 4,
    PTR_BC_CENTER, PTR_BC_TEXT_NONE));

  for i := 1 to 5 do
  begin
    PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, '—ÚÓÍ‡ ' + IntToStr(i) + CRLF));
  end;
  PtrCheck(Printer.CutPaper(90));
  if Printer.CapTransaction then
  begin
    Printer.TransactionPrint(PTR_S_RECEIPT, PTR_TP_NORMAL);
  end;
end;

function TPosPrinterRongtaTest.GetKazakhUnicodeChars: WideString;
var
  i: Integer;
begin
  Result := '';
  for i := Low(KazakhUnicodeChars) to High(KazakhUnicodeChars) do
  begin
    Result := Result + WideChar(KazakhUnicodeChars[i]);
  end;
end;

procedure TPosPrinterRongtaTest.TestPrintNormal;
var
  Text: WideString;
begin
  OpenClaimEnable;
  Printer.CharacterSet := PTR_CS_UNICODE;
  if Printer.CapTransaction then
  begin
    PtrCheck(Printer.TransactionPrint(PTR_S_RECEIPT, PTR_TP_TRANSACTION));
  end;
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, 'Line 1' + CRLF));
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, 'Line 2' + CRLF));
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, 'Line 3' + CRLF));

  Text := 'KAZAKH CHARACTERS A: ' + GetKazakhUnicodeChars;
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, Text + CRLF));

  Text := ' ¿«¿’— »≈ —»Ã¬ŒÀ€ A: ' + GetKazakhUnicodeChars;
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, Text + CRLF));

  Text := 'ARABIC CHARACTERS A: ';
  Text := Text + WideChar($062B) + WideChar($062C) + WideChar($0635);
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, Text + CRLF));

  if Printer.CapTransaction then
  begin
    PtrCheck(Printer.TransactionPrint(PTR_S_RECEIPT, PTR_TP_NORMAL));
  end;
end;

procedure TPosPrinterRongtaTest.TestCharacterToCodePage;
var
  C: WideChar;
  CodePage: Integer;
begin
  CodePage := 1251;
  C := WideChar($0410); // Russian capital A
  CharacterToCodePage(C, CodePage);
  CheckEquals(1251, CodePage);

  C := WideChar(KazakhUnicodeChars[0]);
  CharacterToCodePage(C, CodePage);
  CheckEquals(1251, CodePage);

  C := WideChar($2593);
  CharacterToCodePage(C, CodePage);
  CheckEquals(1251, CodePage);

  C := WideChar($063A);
  CharacterToCodePage(C, CodePage);
  CheckEquals(720, CodePage);
end;

initialization
  RegisterTest('', TPosPrinterRongtaTest.Suite);

end.

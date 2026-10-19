unit duPosPrinters;

interface

uses
  // VCL
  Windows, SysUtils, Classes,
  // DUnit
  TestFramework,
  // 3'd
  Opos, OposPtr, OposPOSPrinter_CCO_TLB,
  // This
  LogFile, MockPrinterPort, PrinterPort, FileUtils, StringUtils, PrinterTypes, OposEsc,
  PosPrinterRongta, PosPrinterPosiflex, PosPrinterXPrinter, PosPrinterOA48;

type
  { TPosPrinterScenarioTest }

  TPosPrinterScenarioTest = class(TTestCase)
  private
    FLog: TStrings;
    FLogger: ILogFile;
    FPort: TMockPrinterPort;
    FPrinter: IOPOSPOSPrinter;
    procedure Step(const Name: string; ResultCode: Integer);
    function GoldenFileName: string;
  protected
    function CreatePrinter(APort: IPrinterPort; ALogger: ILogFile): IOPOSPOSPrinter; virtual; abstract;
    procedure SetUp; override;
    procedure TearDown; override;

    property Port: TMockPrinterPort read FPort;
    property Printer: IOPOSPOSPrinter read FPrinter;
  published
    procedure TestScenario;
  end;

  { TPosPrinterRongtaScenarioTest }

  TPosPrinterRongtaScenarioTest = class(TPosPrinterScenarioTest)
  protected
    function CreatePrinter(APort: IPrinterPort; ALogger: ILogFile): IOPOSPOSPrinter; override;
  end;

  { TPosPrinterPosiflexScenarioTest }

  TPosPrinterPosiflexScenarioTest = class(TPosPrinterScenarioTest)
  protected
    function CreatePrinter(APort: IPrinterPort; ALogger: ILogFile): IOPOSPOSPrinter; override;
  end;

  { TPosPrinterXPrinterScenarioTest }

  TPosPrinterXPrinterScenarioTest = class(TPosPrinterScenarioTest)
  protected
    function CreatePrinter(APort: IPrinterPort; ALogger: ILogFile): IOPOSPOSPrinter; override;
  end;

  { TPosPrinterOA48ScenarioTest }

  TPosPrinterOA48ScenarioTest = class(TPosPrinterScenarioTest)
  protected
    function CreatePrinter(APort: IPrinterPort; ALogger: ILogFile): IOPOSPOSPrinter; override;
  end;

  { TPosPrinterXPrinterTest }

  TPosPrinterXPrinterTest = class(TTestCase)
  private
    FLogger: ILogFile;
    FPort: TMockPrinterPort;
    FPrinter: IOPOSPOSPrinter;
    procedure OpenClaimEnable;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestOpenClaimEnable;
    procedure TestReleaseClose;
    procedure TestPrintNormal;
    procedure TestRecLineChars;
    procedure TestPrintNormalNotEnabled;
  end;

implementation

function CyrillicText: WideString;
const
  Codes: array [1..6] of Word = ($041F, $0440, $0438, $0432, $0435, $0442);
var
  i: Integer;
begin
  SetLength(Result, Length(Codes));
  for i := 1 to Length(Codes) do
    Result[i] := WideChar(Codes[i]);
end;

{ TPosPrinterScenarioTest }

procedure TPosPrinterScenarioTest.SetUp;
begin
  FLog := TStringList.Create;
  FLogger := TLogFile.Create;
  FPort := TMockPrinterPort.Create('');
  FPrinter := CreatePrinter(FPort, FLogger);
end;

procedure TPosPrinterScenarioTest.TearDown;
begin
  FPrinter := nil;
  FLogger := nil;
  FLog.Free;
end;

function TPosPrinterScenarioTest.GoldenFileName: string;
begin
  Result := GetModulePath + 'PosPrinters\' + ClassName + '.txt';
end;

procedure TPosPrinterScenarioTest.Step(const Name: string; ResultCode: Integer);
begin
  FLog.Add(Format('%s: %d', [Name, ResultCode]));
  if FPort.Buffer <> '' then
    FLog.Add('  ' + StrToHex(FPort.Buffer));
  FPort.Buffer := '';
end;

procedure TPosPrinterScenarioTest.TestScenario;
var
  FileName: string;
  Expected: TStrings;
begin
  Step('Open', Printer.Open('DeviceName'));
  Step('ClaimDevice', Printer.ClaimDevice(1000));
  Printer.DeviceEnabled := True;
  Step('DeviceEnabled', Printer.ResultCode);
  FLog.Add(Format('RecLineChars=%d RecLineHeight=%d RecLineSpacing=%d',
    [Printer.RecLineChars, Printer.RecLineHeight, Printer.RecLineSpacing]));
  FLog.Add(Format('CapRecBarCode=%d CapRecBitmap=%d CapRecPageMode=%d CapTransaction=%d',
    [Ord(Printer.CapRecBarCode), Ord(Printer.CapRecBitmap),
    Ord(Printer.CapRecPageMode), Ord(Printer.CapTransaction)]));

  Step('PrintNormal', Printer.PrintNormal(PTR_S_RECEIPT, 'Line 1' + CRLF));
  Step('PrintNormal Bold', Printer.PrintNormal(PTR_S_RECEIPT, ESC + '|bCBold' + CRLF));
  Step('PrintNormal Center', Printer.PrintNormal(PTR_S_RECEIPT, ESC + '|cACenter' + CRLF));
  Step('PrintNormal DoubleWide', Printer.PrintNormal(PTR_S_RECEIPT, ESC + '|2CWide' + CRLF));
  Step('PrintNormal Cyrillic', Printer.PrintNormal(PTR_S_RECEIPT, CyrillicText + CRLF));
  FLog.Add('CharacterSetList=' + Printer.CharacterSetList);
  Printer.MapCharacterSet := True;
  Step('MapCharacterSet', Printer.ResultCode);
  Printer.CharacterSet := PTR_CS_UNICODE;
  Step('CharacterSet Unicode', Printer.ResultCode);
  Step('PrintNormal Cyrillic Unicode', Printer.PrintNormal(PTR_S_RECEIPT, CyrillicText + CRLF));
  Printer.CharacterSet := PTR_CS_WINDOWS;
  Step('CharacterSet Windows', Printer.ResultCode);
  Step('PrintNormal Cyrillic Windows', Printer.PrintNormal(PTR_S_RECEIPT, CyrillicText + CRLF));
  Printer.RecLineChars := 42;
  Step('RecLineChars', Printer.ResultCode);
  Step('PrintNormal 42', Printer.PrintNormal(PTR_S_RECEIPT, 'Line 42' + CRLF));
  Step('PrintBarCode EAN13', Printer.PrintBarCode(PTR_S_RECEIPT, '4600000000008',
    PTR_BCS_EAN13, 100, 2, PTR_BC_CENTER, PTR_BC_TEXT_BELOW));
  Step('PrintBarCode QR', Printer.PrintBarCode(PTR_S_RECEIPT, 'https://example.kz/?i=1',
    PTR_BCS_QRCODE, 200, 4, PTR_BC_CENTER, PTR_BC_TEXT_NONE));
  Step('TransactionPrint Begin', Printer.TransactionPrint(PTR_S_RECEIPT, PTR_TP_TRANSACTION));
  Step('PrintNormal InTransaction', Printer.PrintNormal(PTR_S_RECEIPT, 'Transaction' + CRLF));
  Step('TransactionPrint End', Printer.TransactionPrint(PTR_S_RECEIPT, PTR_TP_NORMAL));
  Step('CutPaper', Printer.CutPaper(90));
  Printer.DeviceEnabled := False;
  Step('DeviceDisabled', Printer.ResultCode);
  Step('ReleaseDevice', Printer.ReleaseDevice);
  Step('Close', Printer.Close);

  FileName := GoldenFileName;
  if not FileExists(FileName) then
  begin
    ForceDirectories(ExtractFilePath(FileName));
    FLog.SaveToFile(FileName);
    Fail('Golden file created: ' + FileName);
  end;
  Expected := TStringList.Create;
  try
    Expected.LoadFromFile(FileName);
    if Expected.Text <> FLog.Text then
      FLog.SaveToFile(ChangeFileExt(FileName, '.actual.txt'));
    CheckEquals(Expected.Text, FLog.Text, 'Port output differs from ' + FileName);
  finally
    Expected.Free;
  end;
end;

{ TPosPrinterRongtaScenarioTest }

function TPosPrinterRongtaScenarioTest.CreatePrinter(APort: IPrinterPort;
  ALogger: ILogFile): IOPOSPOSPrinter;
begin
  Result := TPosPrinterRongta.Create(APort, ALogger);
end;

{ TPosPrinterPosiflexScenarioTest }

function TPosPrinterPosiflexScenarioTest.CreatePrinter(APort: IPrinterPort;
  ALogger: ILogFile): IOPOSPOSPrinter;
begin
  Result := TPosPrinterPosiflex.Create(APort, ALogger);
end;

{ TPosPrinterXPrinterScenarioTest }

function TPosPrinterXPrinterScenarioTest.CreatePrinter(APort: IPrinterPort;
  ALogger: ILogFile): IOPOSPOSPrinter;
begin
  Result := TPosPrinterXPrinter.Create(APort, ALogger);
end;

{ TPosPrinterOA48ScenarioTest }

function TPosPrinterOA48ScenarioTest.CreatePrinter(APort: IPrinterPort;
  ALogger: ILogFile): IOPOSPOSPrinter;
begin
  Result := TPosPrinterOA48.Create(APort, ALogger);
end;

{ TPosPrinterXPrinterTest }

procedure TPosPrinterXPrinterTest.SetUp;
begin
  FLogger := TLogFile.Create;
  FPort := TMockPrinterPort.Create('');
  FPrinter := TPosPrinterXPrinter.Create(FPort, FLogger);
end;

procedure TPosPrinterXPrinterTest.TearDown;
begin
  FPrinter := nil;
  FLogger := nil;
end;

procedure TPosPrinterXPrinterTest.OpenClaimEnable;
begin
  CheckEquals(OPOS_SUCCESS, FPrinter.Open('DeviceName'), 'Open');
  CheckEquals(OPOS_SUCCESS, FPrinter.ClaimDevice(1000), 'ClaimDevice');
  FPrinter.DeviceEnabled := True;
  CheckEquals(OPOS_SUCCESS, FPrinter.ResultCode, 'DeviceEnabled');
end;

procedure TPosPrinterXPrinterTest.TestOpenClaimEnable;
begin
  CheckEquals(OPOS_S_CLOSED, FPrinter.State, 'State before Open');
  OpenClaimEnable;
  CheckEquals(OPOS_S_IDLE, FPrinter.State, 'State');
  CheckEquals(True, FPrinter.Claimed, 'Claimed');
  CheckEquals(True, FPrinter.DeviceEnabled, 'DeviceEnabled');
end;

procedure TPosPrinterXPrinterTest.TestReleaseClose;
begin
  OpenClaimEnable;
  FPrinter.DeviceEnabled := False;
  CheckEquals(False, FPrinter.DeviceEnabled, 'DeviceEnabled');
  CheckEquals(OPOS_SUCCESS, FPrinter.ReleaseDevice, 'ReleaseDevice');
  CheckEquals(False, FPrinter.Claimed, 'Claimed');
  CheckEquals(OPOS_SUCCESS, FPrinter.Close, 'Close');
  CheckEquals(OPOS_S_CLOSED, FPrinter.State, 'State');
end;

procedure TPosPrinterXPrinterTest.TestPrintNormal;
begin
  OpenClaimEnable;
  FPort.Buffer := '';
  CheckEquals(OPOS_SUCCESS, FPrinter.PrintNormal(PTR_S_RECEIPT, 'Line 1'), 'PrintNormal');
  Check(Pos('Line 1', FPort.Buffer) > 0, 'Port.Buffer: ' + StrToHex(FPort.Buffer));
end;

procedure TPosPrinterXPrinterTest.TestRecLineChars;
begin
  OpenClaimEnable;
  FPrinter.RecLineChars := 42;
  CheckEquals(OPOS_SUCCESS, FPrinter.ResultCode, 'ResultCode');
  CheckEquals(42, FPrinter.RecLineChars, 'RecLineChars');
end;

procedure TPosPrinterXPrinterTest.TestPrintNormalNotEnabled;
begin
  CheckEquals(OPOS_SUCCESS, FPrinter.Open('DeviceName'), 'Open');
  CheckEquals(OPOS_E_DISABLED, FPrinter.PrintNormal(PTR_S_RECEIPT, 'Line 1'), 'PrintNormal');
end;

initialization
  RegisterTest('PosPrinters', TPosPrinterRongtaScenarioTest.Suite);
  RegisterTest('PosPrinters', TPosPrinterPosiflexScenarioTest.Suite);
  RegisterTest('PosPrinters', TPosPrinterXPrinterScenarioTest.Suite);
  RegisterTest('PosPrinters', TPosPrinterOA48ScenarioTest.Suite);
  RegisterTest('', TPosPrinterXPrinterTest.Suite);

end.

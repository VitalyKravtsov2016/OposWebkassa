unit duPosEscPrinter;

interface

uses
  // VCL
  Windows, SysUtils, Classes,
  // DUnit
  TestFramework,
  // 3'd
  TntClasses, Opos, OposPtr, OposPtrUtils,
  // This
  LogFile, PosEscPrinter, MockPrinterPort, PrinterPort, StringUtils;

type
  { TPosEscPrinterTest }

  TPosEscPrinterTest = class(TTestCase)
  private
    FLogger: ILogFile;
    FPort: TMockPrinterPort;
    FPrinter: TPosEscPrinter;
    procedure ClaimDevice;
    procedure EnableDevice;
    procedure OpenClaimEnable;
    procedure OpenService;
    procedure PtrCheck(Code: Integer);

    property Printer: TPosEscPrinter read FPrinter;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestPrintNormal;
  end;

implementation

{ TPosEscPrinterTest }

procedure TPosEscPrinterTest.SetUp;
begin
  FLogger := TLogFile.Create;
  FPort := TMockPrinterPort.Create('');
  FPrinter := TPosEscPrinter.Create2(nil, FPort, FLogger);
end;

procedure TPosEscPrinterTest.TearDown;
begin
  FPrinter.Free;
end;

procedure TPosEscPrinterTest.PtrCheck(Code: Integer);
var
  Text: WideString;
begin
  if Code <> OPOS_SUCCESS then
  begin
    if Printer.ResultCode = OPOS_E_EXTENDED then
      Text := Format('%d, %d, %s [%s]', [Printer.ResultCode, Printer.ResultCodeExtended,
      PtrResultCodeExtendedText(Printer.ResultCodeExtended), Printer.ErrorString])
    else
      Text := Format('%d, %s [%s]', [Printer.ResultCode,
        PtrResultCodeExtendedText(Printer.ResultCode), Printer.ErrorString]);

    raise Exception.Create(Text);
  end;
end;

procedure TPosEscPrinterTest.OpenService;
begin
  PtrCheck(Printer.Open('DeviceName'));
end;

procedure TPosEscPrinterTest.ClaimDevice;
begin
  CheckEquals(False, Printer.Claimed, 'Printer.Claimed');
  PtrCheck(Printer.ClaimDevice(1000));
  CheckEquals(True, Printer.Claimed, 'Printer.Claimed');
end;

procedure TPosEscPrinterTest.EnableDevice;
begin
  Printer.DeviceEnabled := True;
  CheckEquals(OPOS_SUCCESS, Printer.ResultCode, 'OPOS_SUCCESS');
  CheckEquals(True, Printer.DeviceEnabled, 'DeviceEnabled');
end;

procedure TPosEscPrinterTest.OpenClaimEnable;
begin
  OpenService;
  ClaimDevice;
  EnableDevice;
end;

procedure TPosEscPrinterTest.TestPrintNormal;
const
  Text = 'Line 1';
  InitText = '1B 40 1B 74 06 ';
begin
  OpenClaimEnable;
  CheckEquals(OPOS_SUCCESS, FPrinter.PrintNormal(PTR_S_RECEIPT, Text));
  CheckEquals(InitText + StrToHex(Text), StrToHex(FPort.Buffer), 'Port.Buffer');
end;

initialization
  RegisterTest('', TPosEscPrinterTest.Suite);

end.

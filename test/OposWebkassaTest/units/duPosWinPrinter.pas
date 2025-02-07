unit duPosWinPrinter;

interface

uses
  // VCL
  Windows, SysUtils, Classes,
  // DUnit
  TestFramework,
  // 3'd
  TntClasses, Opos, OposPtr, OposPtrUtils, OposEsc,
  // This
  LogFile, PosWinPrinter, MockPrinterPort, PrinterPort, StringUtils,
  CustomPrinter, FileUtils;

type
  { TPosWinPrinterTest }

  TPosWinPrinterTest = class(TTestCase)
  private
    FLogger: ILogFile;
    FWinPrinter: TBmpPrinter;
    FPrinter: TPosWinPrinter;

    procedure ClaimDevice;
    procedure EnableDevice;
    procedure OpenClaimEnable;
    procedure OpenService;
    procedure PtrCheck(Code: Integer);

    property Printer: TPosWinPrinter read FPrinter;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestRecLineChars;
    procedure TestPrintReceipt;
  end;

implementation

{ TPosWinPrinterTest }

procedure TPosWinPrinterTest.SetUp;
begin
  FLogger := TLogFile.Create;
  FWinPrinter := TBmpPrinter.Create;
  FPrinter := TPosWinPrinter.Create(FLogger, FWinPrinter);
end;

procedure TPosWinPrinterTest.TearDown;
begin
  FPrinter.Free;
end;

procedure TPosWinPrinterTest.PtrCheck(Code: Integer);
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

procedure TPosWinPrinterTest.OpenService;
begin
  PtrCheck(Printer.Open('DeviceName'));
end;

procedure TPosWinPrinterTest.ClaimDevice;
begin
  CheckEquals(False, Printer.Claimed, 'Printer.Claimed');
  PtrCheck(Printer.ClaimDevice(1000));
  CheckEquals(True, Printer.Claimed, 'Printer.Claimed');
end;

procedure TPosWinPrinterTest.EnableDevice;
begin
  Printer.DeviceEnabled := True;
  CheckEquals(OPOS_SUCCESS, Printer.ResultCode, 'OPOS_SUCCESS');
  CheckEquals(True, Printer.DeviceEnabled, 'DeviceEnabled');
end;

procedure TPosWinPrinterTest.OpenClaimEnable;
begin
  OpenService;
  ClaimDevice;
  EnableDevice;
end;

procedure TPosWinPrinterTest.TestRecLineChars;
begin
  OpenClaimEnable;
  CheckEquals(48, Printer.RecLineChars, 'Printer.RecLineChars.0');
  Printer.RecLineChars := 42;
  CheckEquals(42, Printer.RecLineChars, 'Printer.RecLineChars.0');
end;

procedure TPosWinPrinterTest.TestPrintReceipt;
var
  BitmapData: string;
  BitmapData2: string;
begin
  OpenClaimEnable;

  PtrCheck(FPrinter.TransactionPrint(PTR_S_RECEIPT, PTR_TP_TRANSACTION));
  PtrCheck(FPrinter.PrintNormal(PTR_S_RECEIPT, ESC_Normal + 'Normal text' + CRLF));
  PtrCheck(FPrinter.PrintNormal(PTR_S_RECEIPT, ESC_Bold + 'Bold text' + CRLF));
  PtrCheck(FPrinter.PrintNormal(PTR_S_RECEIPT, ESC_DoubleWide + 'Double wide text' + CRLF));
  PtrCheck(FPrinter.PrintNormal(PTR_S_RECEIPT, ESC_DoubleHigh + 'Double high text' + CRLF));
  PtrCheck(FPrinter.PrintNormal(PTR_S_RECEIPT, ESC_Normal + 'Normal text 2' + CRLF));

  PtrCheck(FPrinter.PrintNormal(PTR_S_RECEIPT, 'Bitmap' + CRLF));
  PtrCheck(FPrinter.PrintBitmap(PTR_S_RECEIPT, 'Logo.bmp', PTR_BM_ASIS, PTR_BM_CENTER));

  PtrCheck(FPrinter.PrintNormal(PTR_S_RECEIPT, 'QR code barcode' + CRLF));
  PtrCheck(FPrinter.PrintBarCode(PTR_S_RECEIPT, 'Barcode', PTR_BCS_QRCODE,
    100, 100, PTR_BC_CENTER, PTR_BC_TEXT_NONE));
  PtrCheck(FPrinter.TransactionPrint(PTR_S_RECEIPT, PTR_TP_NORMAL));

  FWinPrinter.Bitmap.SaveToFile('PrintReceipt.bmp');
  BitmapData := ReadFileData(GetModulePath + 'PrintReceipt.bmp');
  BitmapData2 := ReadFileData(GetModulePath + 'PrintReceipt2.bmp');
  CheckEquals(BitmapData, BitmapData2, 'Receipt bimap differs');
  DeleteFile('PrintReceipt.bmp');
end;

initialization
  RegisterTest('', TPosWinPrinterTest.Suite);

end.

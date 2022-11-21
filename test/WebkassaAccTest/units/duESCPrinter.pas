
unit duESCPrinter;

interface

uses
  // VCL
  Windows, SysUtils, Classes, Graphics,
  // DUnit
  TestFramework,
  // Tnt
  TntClasses, TntSysUtils,
  // This
  DebugUtils, StringUtils, ESCPrinter, PrinterPort, SerialPort, LogFile,
  FileUtils, SocketPort;

type
  { TESCPrinterTest }

  TESCPrinterTest = class(TTestCase)
  private
    FLogger: ILogFile;
    FPrinter: TESCPrinter;
    FPrinterPort: IPrinterPort;
  protected
    procedure SetUp; override;
    procedure TearDown; override;

    function CreateSerialPort: TSerialPort;
    function CreateSocketPort: TSocketPort;
    property Printer: TESCPrinter read FPrinter;
  published
    procedure TestReadStatus;
    procedure TestPrintMode;
    procedure TestPrintModeInLine;
    procedure TestBarcode;
    procedure TestBitmap;
    procedure TestReadPrinterID;
  end;

implementation

{ TESCPrinterTest }

procedure TESCPrinterTest.SetUp;
begin
  inherited SetUp;
  FLogger := TLogFile.Create;
  //FPrinterPort := CreateSocketPort;
  FPrinterPort := CreateSerialPort;
  FPrinterPort.Open;
  FPrinter := TEscPrinter.Create(FPrinterPort, FLogger);
end;

procedure TESCPrinterTest.TearDown;
begin
  FPrinter.Free;
  FPrinterPort := nil;
  inherited TearDown;
end;

function TESCPrinterTest.CreateSerialPort: TSerialPort;
var
  SerialParams: TSerialParams;
begin
  SerialParams.PortName := 'COM3';
  SerialParams.BaudRate := 115200;
  SerialParams.DataBits := 8;
  SerialParams.StopBits := 1;
  SerialParams.Parity := 0;
  SerialParams.FlowControl := 0;
  SerialParams.ReconnectPort := False;
  SerialParams.ByteTimeout := 1000;
  Result := TSerialPort.Create(SerialParams, FLogger);
end;

function TESCPrinterTest.CreateSocketPort: TSocketPort;
var
  SocketParams: TSocketParams;
begin
  SocketParams.RemoteHost := '10.11.7.176';
  SocketParams.RemotePort := 9100;
  SocketParams.MaxRetryCount := 1;
  SocketParams.ByteTimeout := 1000;
  Result := TSocketPort.Create(SocketParams, FLogger);
end;

procedure TESCPrinterTest.TestReadStatus;
var
  ErrorStatus: TErrorStatus;
  OfflineStatus: TOfflineStatus;
  PrinterStatus: TPrinterStatus;
  PaperStatus: TPaperStatus;
  RollStatus: TPaperRollStatus;
begin
  PrinterStatus := FPrinter.ReadPrinterStatus;
  CheckEquals(True, PrinterStatus.DrawerOpened, 'DrawerOpened');

  OfflineStatus := FPrinter.ReadOfflineStatus;
  CheckEquals(False, OfflineStatus.CoverOpened, 'CoverOpened');
  CheckEquals(False, OfflineStatus.FeedButton, 'FeedButton');
  CheckEquals(False, OfflineStatus.ErrorOccurred, 'ErrorOccurred');

  ErrorStatus := FPrinter.ReadErrorStatus;
  CheckEquals(False, ErrorStatus.CutterError, 'CutterError');
  CheckEquals(False, ErrorStatus.UnrecoverableError, 'UnrecoverableError');
  CheckEquals(False, ErrorStatus.AutoRecoverableError, 'AutoRecoverableError');

  PaperStatus := FPrinter.ReadPaperStatus;
  CheckEquals(True, PaperStatus.PaperPresent, 'PaperPresent');

  RollStatus := FPrinter.ReadPaperRollStatus;
  CheckEquals(False, RollStatus.PaperNearEnd, 'PaperNearEnd');
end;

procedure TESCPrinterTest.TestPrintMode;
var
  PrintMode: TPrintMode;
begin
  FPrinter.SetJustification(JUSTIFICATION_LEFT);
  // Normal mode, font A
  PrintMode.CharacterFontB := False;
  PrintMode.Emphasized := False;
  PrintMode.DoubleHeight := False;
  PrintMode.DoubleWidth := False;
  PrintMode.Underlined := False;
  FPrinter.SelectPrintMode(PrintMode);
  FPrinter.PrintText('Normal mode, font A' + CRLF);
  // Emphasized mode
  PrintMode.Emphasized := True;
  PrintMode.DoubleHeight := False;
  PrintMode.DoubleWidth := False;
  PrintMode.Underlined := False;
  FPrinter.SelectPrintMode(PrintMode);
  FPrinter.PrintText('Emphasized mode' + CRLF);
  // Underlined mode
  PrintMode.Emphasized := False;
  PrintMode.DoubleHeight := False;
  PrintMode.DoubleWidth := False;
  PrintMode.Underlined := True;
  FPrinter.SelectPrintMode(PrintMode);
  FPrinter.PrintText('Underlined mode' + CRLF);
  // Double height
  PrintMode.Emphasized := False;
  PrintMode.DoubleHeight := True;
  PrintMode.DoubleWidth := False;
  PrintMode.Underlined := False;
  FPrinter.SelectPrintMode(PrintMode);
  FPrinter.PrintText('Double height mode' + CRLF);
  // Double width
  PrintMode.Emphasized := False;
  PrintMode.DoubleHeight := False;
  PrintMode.DoubleWidth := True;
  PrintMode.Underlined := False;
  FPrinter.SelectPrintMode(PrintMode);
  FPrinter.PrintText('Double width mode' + CRLF);
  // Double height & width
  PrintMode.Emphasized := False;
  PrintMode.DoubleHeight := True;
  PrintMode.DoubleWidth := True;
  PrintMode.Underlined := False;
  FPrinter.SelectPrintMode(PrintMode);
  FPrinter.PrintText('Double height & width' + CRLF);

  // Normal mode, font B
  PrintMode.CharacterFontB := True;
  PrintMode.Emphasized := False;
  PrintMode.DoubleHeight := False;
  PrintMode.DoubleWidth := False;
  PrintMode.Underlined := False;
  FPrinter.SelectPrintMode(PrintMode);
  FPrinter.PrintText('Normal mode, font B' + CRLF);
  // Emphasized mode
  PrintMode.Emphasized := True;
  PrintMode.DoubleHeight := False;
  PrintMode.DoubleWidth := False;
  PrintMode.Underlined := False;
  FPrinter.SelectPrintMode(PrintMode);
  FPrinter.PrintText('Emphasized mode' + CRLF);
  // Underlined mode
  PrintMode.Emphasized := False;
  PrintMode.DoubleHeight := False;
  PrintMode.DoubleWidth := False;
  PrintMode.Underlined := True;
  FPrinter.SelectPrintMode(PrintMode);
  FPrinter.PrintText('Underlined mode' + CRLF);
  // Double height
  PrintMode.Emphasized := False;
  PrintMode.DoubleHeight := True;
  PrintMode.DoubleWidth := False;
  PrintMode.Underlined := False;
  FPrinter.SelectPrintMode(PrintMode);
  FPrinter.PrintText('Double height mode' + CRLF);
  // Double width
  PrintMode.Emphasized := False;
  PrintMode.DoubleHeight := False;
  PrintMode.DoubleWidth := True;
  PrintMode.Underlined := False;
  FPrinter.SelectPrintMode(PrintMode);
  FPrinter.PrintText('Double width mode' + CRLF);
  // Double height & width
  PrintMode.Emphasized := False;
  PrintMode.DoubleHeight := True;
  PrintMode.DoubleWidth := True;
  PrintMode.Underlined := False;
  FPrinter.SelectPrintMode(PrintMode);
  FPrinter.PrintText('Double height & width' + CRLF);

  FPrinter.PrintAndFeedLines(5);
  FPrinter.PartialCut;
end;

procedure TESCPrinterTest.TestPrintModeInLine;
var
  PrintMode: TPrintMode;
begin
  // Normal mode, font A
  PrintMode.CharacterFontB := False;
  PrintMode.Emphasized := False;
  PrintMode.DoubleHeight := False;
  PrintMode.DoubleWidth := False;
  PrintMode.Underlined := False;
  FPrinter.SelectPrintMode(PrintMode);
  FPrinter.PrintText('Normal');
  // Emphasized mode
  PrintMode.Emphasized := True;
  PrintMode.DoubleHeight := False;
  PrintMode.DoubleWidth := False;
  PrintMode.Underlined := False;
  FPrinter.SelectPrintMode(PrintMode);
  FPrinter.PrintText(' Emphasized');
  // Underlined mode
  PrintMode.Emphasized := False;
  PrintMode.DoubleHeight := False;
  PrintMode.DoubleWidth := False;
  PrintMode.Underlined := True;
  FPrinter.SelectPrintMode(PrintMode);
  FPrinter.PrintText(' Underlined');
  // Double height
  PrintMode.Emphasized := False;
  PrintMode.DoubleHeight := True;
  PrintMode.DoubleWidth := False;
  PrintMode.Underlined := False;
  FPrinter.SelectPrintMode(PrintMode);
  FPrinter.PrintText(' Double height');
  // Double width
  PrintMode.Emphasized := False;
  PrintMode.DoubleHeight := False;
  PrintMode.DoubleWidth := True;
  PrintMode.Underlined := False;
  FPrinter.SelectPrintMode(PrintMode);
  FPrinter.PrintText(' Double width');
  // Double height & width
  PrintMode.Emphasized := False;
  PrintMode.DoubleHeight := True;
  PrintMode.DoubleWidth := True;
  PrintMode.Underlined := False;
  FPrinter.SelectPrintMode(PrintMode);
  FPrinter.PrintText(' Double height & width' + CRLF);
end;

(*
  BARCODE2_UPC_A    = 65;
  BARCODE2_UPC_E    = 66;
  BARCODE2_EAN13    = 67;
  BARCODE2_EAN8     = 68;
  BARCODE2_CODE39   = 69;
  BARCODE2_ITF      = 70;
  BARCODE2_CODABAR  = 71;
  BARCODE2_CODE93   = 72;
  BARCODE2_CODE128  = 73;
*)

procedure TESCPrinterTest.TestBarcode;
begin
(*
var
  QRCode: TQRCode;

  FPrinter.SetNormalPrintMode;
  FPrinter.PrintText('Barcode test' + CRLF);
  FPrinter.PrintText('BARCODE2_UPC_A' + CRLF);
  FPrinter.PrintBarcode(BARCODE2_UPC_A, '1625341');

  FPrinter.PrintText('BARCODE2_CODE128' + CRLF);
  FPrinter.PrintBarcode(BARCODE2_CODE128, '1625341');


  FPrinter.SetPageMode;
  //FPrinter.SetBarcodeLeft(100);
  FPrinter.SetLeftMargin(100);
  FPrinter.Select2DBarcode(1); // QR code
  QRCode.SymbolVersion := 0;
  QRCode.ECLevel := 1;
  QRCode.ModuleSize := 4;
  QRCode.data := 'QRCode test test test';
  FPrinter.printQRCode(QRCode);
  FPrinter.PrintAndReturnStandardMode;
*)
end;

procedure TESCPrinterTest.TestBitmap;
var
  Bitmap: TBitmap;
  FileName: string;
begin
  Bitmap := TBitmap.Create;
  try
    FileName := GetModulePath + 'ShtrihM.bmp';
    Bitmap.LoadFromFile(FileName);
    //FPrinter.PrintRasterBMP(BMP_MODE_NORMAL, Bitmap);

    FPrinter.Initialize;
    FPrinter.DownloadBMP(JUSTIFICATION_LEFT, Bitmap);
    FPrinter.PrintBmp(BMP_MODE_NORMAL);

    FPrinter.Initialize;
    FPrinter.DownloadBMP(JUSTIFICATION_CENTERING, Bitmap);
    FPrinter.PrintBmp(BMP_MODE_NORMAL);

    FPrinter.Initialize;
    FPrinter.DownloadBMP(JUSTIFICATION_RIGHT, Bitmap);
    FPrinter.PrintBmp(BMP_MODE_NORMAL);
  finally
    Bitmap.Free;
  end;
end;

procedure TESCPrinterTest.TestReadPrinterID;
begin
  CheckEquals('_7.03 ESC/POS', FPrinter.ReadPrinterID(65), 'Firmware version');
  CheckEquals('_EPSON', FPrinter.ReadPrinterID(66), 'Manufacturer');
  CheckEquals('_TM-T88III', FPrinter.ReadPrinterID(67), 'Printer name');
  CheckEquals('_D6KG074561', FPrinter.ReadPrinterID(68), 'Serial number');
end;

initialization
  RegisterTest('', TESCPrinterTest.Suite);

end.

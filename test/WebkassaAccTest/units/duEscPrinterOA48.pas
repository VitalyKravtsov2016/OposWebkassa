unit duEscPrinterOA48;

interface

uses
  // VCL
  Windows, SysUtils, Classes, Graphics,
  // DUnit
  TestFramework,
  // Tnt
  TntClasses, TntSysUtils,
  // This
  DebugUtils, StringUtils, EscPrinterOA48, PrinterPort, SerialPort, LogFile,
  FileUtils, SocketPort, RawPrinterPort, EscPrinterUtils, USBPrinterPort;

type
  { TEscPrinterOA48Test }

  TEscPrinterOA48Test = class(TTestCase)
  private
    FLogger: ILogFile;
    FPrinter: TEscPrinterOA48;
    FPrinterPort: IPrinterPort;
  protected
    procedure SetUp; override;
    procedure TearDown; override;

    procedure PrintCodePageUTF8;
    procedure PrintCodePage(CodePage: Integer);
    procedure PrintCodePages(const CodePageName: string);

    function CreateSerialPort: TSerialPort;
    function CreateSocketPort: TSocketPort;
    function CreateUSBPort: TUSBPrinterPort;
    function CreateRawPort: TRawPrinterPort;

    property Printer: TEscPrinterOA48 read FPrinter;
  published
    procedure TestBitmap;
    procedure TestPrintRasterBMP;
    procedure TestInitialize;
    procedure TestPrintText;
    procedure TestReadStatus;
    procedure TestPrintMode;
    procedure TestPrintModeInLine;
    procedure TestBarcode;
    procedure TestBarcode2;
    procedure TestPDF417;
    procedure TestQRCode;
    procedure TestQRCodeECL;
    procedure TestQRCodeModuleSize;
    procedure TestQRCodeJustification;
    procedure PrintTestPage;
    procedure TestJustification;
    procedure TestJustification2;
    procedure TestUnderlined;
    procedure TestBeepParams;
    procedure TestEmphasized;
    procedure TestDoubleStrikeMode;
    procedure TestCharacterFont;
    procedure TestCodePage1;
    procedure TestCodePage2;
    procedure TestCodePages;
    procedure TestNVBitImage;
    procedure TestCoverOpen;
    procedure TestRecoverError;
    procedure TestPrintUnicode;
    procedure TestLineSpacing;
    procedure TestCutDistanceFontA;
    procedure TestCutDistanceFontB;
    procedure TestBitmap2;
    procedure TestPageMode;
    procedure TestPageModeA;
    procedure TestPageModeA2;
    procedure TestPageModeB;
    procedure TestPrintMaxiCode;
    procedure TestPrintUTF;
    procedure TestPrintRussianFontA;
    procedure TestPrintFontBMode;
    procedure TestPrintFontBMode2;
    procedure TestCutterError;
    procedure TestUnicodeChars;
  end;

implementation

{ TEscPrinterOA48Test }

procedure TEscPrinterOA48Test.SetUp;
begin
  inherited SetUp;
  FLogger := TLogFile.Create;
  FLogger.MaxCount := 10;
  FLogger.Enabled := True;
  FLogger.FilePath := 'Logs';
  FLogger.DeviceName := 'DeviceName';

  //FPrinterPort := CreateSocketPort;
  //FPrinterPort := CreateSerialPort;
  //FPrinterPort := CreateRawPort;
  FPrinterPort := CreateUsbPort;

  FPrinterPort.Open;
  FPrinter := TEscPrinterOA48.Create(FPrinterPort, FLogger);
end;

procedure TEscPrinterOA48Test.TearDown;
begin
  FPrinter.Free;
  FPrinterPort := nil;
  inherited TearDown;
end;

function TEscPrinterOA48Test.CreateUSBPort: TUSBPrinterPort;
begin
  Result := TUSBPrinterPort.Create(FLogger, ReadOA48PortName);
end;

function TEscPrinterOA48Test.CreateRawPort: TRawPrinterPort;
begin
  Result := TRawPrinterPort.Create(FLogger, 'POS-80C');
end;

function TEscPrinterOA48Test.CreateSerialPort: TSerialPort;
var
  SerialParams: TSerialParams;
begin
  SerialParams.PortName := 'COM7';
  SerialParams.BaudRate := 19200;
  SerialParams.DataBits := 8;
  SerialParams.StopBits := ONESTOPBIT;
  SerialParams.Parity := 0;
  SerialParams.FlowControl := FLOW_CONTROL_NONE;
  SerialParams.ReconnectPort := False;
  SerialParams.ByteTimeout := 1000;
  Result := TSerialPort.Create(SerialParams, FLogger);
end;

function TEscPrinterOA48Test.CreateSocketPort: TSocketPort;
var
  SocketParams: TSocketParams;
begin
  SocketParams.RemoteHost := '10.11.7.176';
  SocketParams.RemotePort := 9100;
  SocketParams.MaxRetryCount := 1;
  SocketParams.ByteTimeout := 1000;
  Result := TSocketPort.Create(SocketParams, FLogger);
end;

procedure TEscPrinterOA48Test.TestPrintText;
begin
  FPrinter.PrintText('12345678901234567890123456789012345678901234567890' + CRLF);

  FPrinter.PrintText('Печать строки 1' + CRLF);
  FPrinter.PrintText('Печать строки 2' + CRLF);
  FPrinter.PrintText('Печать строки 3' + CRLF);
end;

procedure TEscPrinterOA48Test.TestInitialize;
begin
  FPrinter.Initialize;
  FPrinter.SetCodePage(CODEPAGE_WCP1251);
end;

procedure TEscPrinterOA48Test.TestReadStatus;
var
  ErrorStatus: TErrorStatus;
  OfflineStatus: TOfflineStatus;
  PrinterStatus: TPrinterStatus;
  PaperStatus: TPaperStatus;
  RollStatus: TPaperRollStatus;
begin
  FPrinter.Initialize;
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

procedure TEscPrinterOA48Test.TestPrintMode;
var
  PrintMode: TPrintMode;
begin
  FPrinter.Initialize;
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

procedure TEscPrinterOA48Test.TestPrintModeInLine;
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

procedure TEscPrinterOA48Test.TestBarcode;
begin
  FPrinter.SetNormalPrintMode;
  FPrinter.SetBarcodeLeft(50);
  FPrinter.SetBarcodeHeight(50);
  FPrinter.SetHRIPosition(HRI_BELOW_BARCODE);

  FPrinter.PrintText('Barcode test' + CRLF);
  FPrinter.PrintText('UPC A' + CRLF);
  FPrinter.PrintBarcode(BARCODE_UPC_A, '17236517261');
  FPrinter.PrintText('UPC E' + CRLF);
  FPrinter.PrintBarcode(BARCODE_UPC_E, '17236517261');
  FPrinter.PrintText('EAN13' + CRLF);
  FPrinter.PrintBarcode(BARCODE_EAN13, '172365172613');
  FPrinter.PrintText('EAN8' + CRLF);
  FPrinter.PrintBarcode(BARCODE_EAN8, '1723651');
  FPrinter.PrintText('CODE39' + CRLF);
  FPrinter.PrintBarcode(BARCODE_CODE39, '837465873');
  FPrinter.PrintText('ITF' + CRLF);
  FPrinter.PrintBarcode(BARCODE_ITF, '83746587');
  FPrinter.PrintText('CODABAR' + CRLF);
  FPrinter.PrintBarcode(BARCODE_CODABAR, '837465873');
end;

procedure TEscPrinterOA48Test.TestBarcode2;
begin
  FPrinter.SetNormalPrintMode;
  FPrinter.SetBarcodeLeft(50);
  FPrinter.SetBarcodeHeight(50);
  FPrinter.SetHRIPosition(HRI_BELOW_BARCODE);

  FPrinter.PrintText('Barcode 2 test' + CRLF);
  FPrinter.PrintText('UPC A' + CRLF);
  FPrinter.PrintBarcode2(BARCODE2_UPC_A, '17236517261');
  FPrinter.PrintText('UPC E' + CRLF);
  FPrinter.PrintBarcode2(BARCODE2_UPC_E, '17236517261');
  FPrinter.PrintText('EAN13' + CRLF);
  FPrinter.PrintBarcode2(BARCODE2_EAN13, '172365172613');
  FPrinter.PrintText('EAN8' + CRLF);
  FPrinter.PrintBarcode2(BARCODE2_EAN8, '1723651');
  FPrinter.PrintText('CODE39' + CRLF);
  FPrinter.PrintBarcode2(BARCODE2_CODE39, '837465873');
  FPrinter.PrintText('ITF' + CRLF);
  FPrinter.PrintBarcode2(BARCODE2_ITF, '83746587');
  FPrinter.PrintText('CODABAR' + CRLF);
  FPrinter.PrintBarcode2(BARCODE2_CODABAR, '837465873');
  FPrinter.PrintText('CODE93' + CRLF);
  FPrinter.PrintBarcode2(BARCODE2_CODE93, '837465873');
  FPrinter.PrintText('CODE128' + CRLF);
  FPrinter.PrintBarcode2(BARCODE2_CODE128, '93487593845');
  FPrinter.PrintText(CRLF);
end;

procedure TEscPrinterOA48Test.TestPDF417;
var
  Barcode: TPDF417;
const
  BarcodeData = 'http://dev.kofd.kz/consumer?i=925871425876&f=211030200207&s=15443.72&t=20220826T210014';
begin
  FPrinter.Initialize;
  FPrinter.PrintText('PDF417 test' + CRLF);
  Barcode.RowNumber := 1;
  Barcode.ColumnNumber := 4; // 1..30
  Barcode.ModuleWidth := 2;
  Barcode.ModuleHeight := 4;
  Barcode.ErrorCorrectionLevel := 0;
  Barcode.Options := 0;
  Barcode.data := BarcodeData;
  FPrinter.printPDF417(Barcode);
end;

procedure TEscPrinterOA48Test.TestQRCode;
var
  QRCode: TQRCode;
begin
  QRCode.ModuleSize := 3;
  QRCode.ECLevel := OA48_QRCODE_ECL_7;
  QRCode.data := 'http://dev.kofd.kz/consumer?i=1320526842876&f=555697470167&s=2000.00&t=20240327T093611';

  FPrinter.Initialize;
  FPrinter.printQRCode(QRCode);
end;

///////////////////////////////////////////////////////////////////////////////
// ECL - Error correction level

procedure TEscPrinterOA48Test.TestQRCodeECL;
var
  QRCode: TQRCode;
begin
  QRCode.ModuleSize := 4;
  QRCode.ECLevel := 0;
  QRCode.data := 'http://dev.kofd.kz/consumer?i=1320526842876&f=555697470167&s=2000.00&t=20240327T093611';

  FPrinter.Initialize;
  FPrinter.PrintText(CRLF);
  FPrinter.PrintText('ECL 7%' + CRLF);
  QRCode.ECLevel := OA48_QRCODE_ECL_7;
  FPrinter.printQRCode(QRCode);

  FPrinter.PrintText(CRLF);
  FPrinter.PrintText('ECL 15%' + CRLF);
  QRCode.ECLevel := OA48_QRCODE_ECL_15;
  FPrinter.printQRCode(QRCode);

  FPrinter.PrintText(CRLF);
  FPrinter.PrintText('ECL 25%' + CRLF);
  QRCode.ECLevel := OA48_QRCODE_ECL_25;
  FPrinter.printQRCode(QRCode);

  FPrinter.PrintText(CRLF);
  FPrinter.PrintText('ECL 30%' + CRLF);
  QRCode.ECLevel := OA48_QRCODE_ECL_30;
  FPrinter.printQRCode(QRCode);
end;

procedure TEscPrinterOA48Test.TestQRCodeModuleSize;
var
  QRCode: TQRCode;
begin
  QRCode.ECLevel := OA48_QRCODE_ECL_7;
  QRCode.data := 'http://dev.kofd.kz/consumer?i=1320526842876&f=555697470167&s=2000.00&t=20240327T093611';

  FPrinter.Initialize;
  FPrinter.PrintText('Module size 3' + CRLF);
  QRCode.ModuleSize := 3;
  FPrinter.printQRCode(QRCode);

  FPrinter.PrintText('Module size 5' + CRLF);
  QRCode.ModuleSize := 5;
  FPrinter.printQRCode(QRCode);

  FPrinter.PrintText('Module size 10' + CRLF);
  QRCode.ModuleSize := 10;
  FPrinter.printQRCode(QRCode);
end;

procedure TEscPrinterOA48Test.TestQRCodeJustification;
var
  QRCode: TQRCode;
begin
  QRCode.ECLevel := 1;
  QRCode.ModuleSize := 4;
  QRCode.data := 'http://dev.kofd.kz/consumer?i=1320526842876&f=555697470167&s=2000.00&t=20240327T093611';

  FPrinter.Initialize;
  FPrinter.PrintText('Print QRCode as command test' + CRLF);
  FPrinter.SetJustification(JUSTIFICATION_LEFT);
  FPrinter.printQRCode(QRCode);
  FPrinter.SetJustification(JUSTIFICATION_CENTER);
  FPrinter.printQRCode(QRCode);
  FPrinter.SetJustification(JUSTIFICATION_RIGHT);
  FPrinter.printQRCode(QRCode);
end;

procedure TEscPrinterOA48Test.TestBitmap;
var
  Bitmap: TBitmap;
  FileName: string;
begin
  Bitmap := TBitmap.Create;
  try
    FileName := GetModulePath + 'ShtrihM.bmp';
    Bitmap.LoadFromFile(FileName);

    FPrinter.Initialize;
    FPrinter.DownloadBMP(Bitmap);
    FPrinter.SetJustification(JUSTIFICATION_LEFT);
    FPrinter.PrintBmp(BMP_MODE_NORMAL);
    FPrinter.SetJustification(JUSTIFICATION_CENTER);
    FPrinter.PrintBmp(BMP_MODE_NORMAL);
    FPrinter.SetJustification(JUSTIFICATION_RIGHT);
    FPrinter.PrintBmp(BMP_MODE_NORMAL);
  finally
    Bitmap.Free;
  end;
end;

procedure TEscPrinterOA48Test.TestPrintRasterBMP;
var
  Bitmap: TBitmap;
begin
  Bitmap := TBitmap.Create;
  try
    Bitmap.LoadFromFile(GetModulePath + 'ShtrihM.bmp');

    FPrinter.Initialize;
    FPrinter.PrintRasterBMP(0, Bitmap);
  finally
    Bitmap.Free;
  end;
end;

(*
_RP80
_7.03 ESC/POS
_2013-01-05
_RONGTA
*)

procedure TEscPrinterOA48Test.PrintTestPage;
begin
  FPrinter.Initialize;
  FPrinter.PrintTestPage;
end;

procedure TEscPrinterOA48Test.TestJustification;
var
  QRCode: TQRCode;
begin
  FPrinter.Initialize;
  FPrinter.SetHRIPosition(HRI_BELOW_BARCODE);
  FPrinter.SetJustification(JUSTIFICATION_CENTER);
  FPrinter.PrintText('QRCode test' + CRLF);
  QRCode.ECLevel := 1;
  QRCode.ModuleSize := 4;
  QRCode.data := 'QRCodetestQRCodetestQRCodetest';
  FPrinter.printQRCode(QRCode);
  FPrinter.SetJustification(JUSTIFICATION_LEFT);
end;

procedure TEscPrinterOA48Test.TestJustification2;
begin
  FPrinter.Initialize;
  FPrinter.PrintText('Default justification' + CRLF);
  FPrinter.SetJustification(JUSTIFICATION_LEFT);
  FPrinter.PrintText('Left justification' + CRLF);
  FPrinter.SetJustification(JUSTIFICATION_CENTER);
  FPrinter.PrintText('Centering justification' + CRLF);
  FPrinter.SetJustification(JUSTIFICATION_RIGHT);
  FPrinter.PrintText('Right justification' + CRLF);
end;

procedure TEscPrinterOA48Test.TestUnderlined;
var
  PrintMode: TPrintMode;
begin
  FPrinter.Initialize;
  FPrinter.PrintText('Not underlined text' + CRLF);
  FPrinter.SetUnderlineMode(UNDERLINE_MODE_1DOT);
  FPrinter.PrintText('Underlined text 1 dot' + CRLF);
  FPrinter.SetUnderlineMode(UNDERLINE_MODE_2DOT);
  FPrinter.PrintText('Underlined text 2 dot' + CRLF);
  FPrinter.SetUnderlineMode(UNDERLINE_MODE_NONE);
  FPrinter.PrintText('Not underlined text' + CRLF);
  FPrinter.SetUnderlineMode(UNDERLINE_MODE_2DOT);
  FPrinter.PrintText('Underlined');
  FPrinter.SetUnderlineMode(UNDERLINE_MODE_NONE);
  FPrinter.PrintText(' text in line' + CRLF);
  // Normal mode, font A
  PrintMode.CharacterFontB := False;
  PrintMode.Emphasized := False;
  PrintMode.DoubleHeight := False;
  PrintMode.DoubleWidth := False;
  PrintMode.Underlined := True;
  FPrinter.SelectPrintMode(PrintMode);
  FPrinter.PrintText('Underlined mode, font A' + CRLF);
end;

procedure TEscPrinterOA48Test.TestBeepParams;
begin
  FPrinter.Initialize;
  FPrinter.SetBeepParams(3, 1);
end;

procedure TEscPrinterOA48Test.TestEmphasized;
begin
  FPrinter.Initialize;
  FPrinter.PrintText('Emphasized mode OFF ');
  FPrinter.SetEmphasizedMode(True);
  FPrinter.PrintText('Emphasized mode ON' + CRLF);
  FPrinter.PrintText('Emphasized mode ON' + CRLF);
  FPrinter.SetEmphasizedMode(False);
end;

procedure TEscPrinterOA48Test.TestDoubleStrikeMode;
begin
  FPrinter.Initialize;
  FPrinter.PrintText('Double-strike mode OFF ');
  FPrinter.SetDoubleStrikeMode(True);
  FPrinter.PrintText('Double-strike mode ON' + CRLF);
  FPrinter.PrintText('Double-strike mode ON' + CRLF);
  FPrinter.SetDoubleStrikeMode(False);
end;

procedure TEscPrinterOA48Test.TestCharacterFont;
begin
  FPrinter.Initialize;
  FPrinter.PrintText('Character font A' + CRLF);
  FPrinter.PrintText('0123456789012345678901234567890123456789012345678901234567890123456789' + CRLF);
  FPrinter.SetCharacterFont(1);
  FPrinter.PrintText('Character font B' + CRLF);
  FPrinter.PrintText('0123456789012345678901234567890123456789012345678901234567890123456789' + CRLF);
  FPrinter.SetCharacterFont(0);
end;

procedure TEscPrinterOA48Test.TestCodePage1;
const
  TextCodePage1251: WideString = 'Кодовая страница 1251';
  TextCodePage866: WideString = 'Кодовая страница 866';
var
  Text: AnsiString;
  WideText: WideString;
  Strings: TTntStrings;
begin
  Strings := TTntStringList.Create;
  try
    FPrinter.Initialize;
    // 1251
    FPrinter.SetCodePage(CODEPAGE_WCP1251);
    Text := WideStringToAnsiString(1251, TextCodePage1251);
    FPrinter.PrintText(Text + CRLF);
    // 866
    FPrinter.SetCodePage(CODEPAGE_CP866);
    Text := WideStringToAnsiString(866, TextCodePage866);
    FPrinter.PrintText(Text + CRLF);
    // 1255 Hebrew
    FPrinter.SetCodePage(CODEPAGE_WCP1251);
    FPrinter.PrintText('CODEPAGE 1255 Hebrew' + CRLF);
    FPrinter.SetCodePage(CODEPAGE_WCP1255);
    Strings.LoadFromFile(GetModulePath + 'HebrewText.txt');
    WideText := Strings[0];
    Text := WideStringToAnsiString(1255, WideText);
    FPrinter.PrintText(Text + CRLF);
  finally
    Strings.Free;
  end;
end;

procedure TEscPrinterOA48Test.TestCodePage2;
const
  TextCodePage1251: WideString = 'Кодовая страница 1251';
  TextCodePage866: WideString = 'Кодовая страница 866';
var
  Text: AnsiString;
  WideText: WideString;
  Strings: TTntStrings;
begin
  Strings := TTntStringList.Create;
  try
    FPrinter.Initialize;
    // 1251
    FPrinter.SetCodePage(CODEPAGE_WCP1251);
    FPrinter.PrintText(Text);
    // 866
    FPrinter.SetCodePage(CODEPAGE_CP866);
    Text := WideStringToAnsiString(866, TextCodePage866);
    FPrinter.PrintText(Text);
    // 1255 Hebrew
    FPrinter.SetCodePage(CODEPAGE_WCP1251);
    FPrinter.PrintText('CODEPAGE 1255 Hebrew');
    FPrinter.SetCodePage(CODEPAGE_WCP1255);
    Strings.LoadFromFile(GetModulePath + 'HebrewText.txt');
    WideText := Strings[0];
    Text := WideStringToAnsiString(1255, WideText);
    FPrinter.PrintText(Text);
  finally
    Strings.Free;
  end;
end;

procedure TEscPrinterOA48Test.TestCodePages;

  procedure PrintCodePage2(CodePage: Integer);
  var
    i: Integer;
    S: AnsiString;
  begin
    FPrinter.SetCodePage(CodePage);
    FPrinter.PrintText(Format('Codepage %d, %s', [
      CodePage, GetCodepageName(CodePage)]) + CRLF);

    S := '';
    for i := $00 to $1f do
    begin
      S := S + Chr($80 + i);
    end;
    FPrinter.PrintText('0x80  ' + S + CRLF);
  end;

begin
  FPrinter.Initialize;
  FPrinter.UTF8Enable(False);
  FPrinter.SetCharacterFont(FONT_TYPE_A);

  PrintCodePage2(CODEPAGE_CP866);
  PrintCodePage2(CODEPAGE_WCP1251);
  PrintCodePage2(CODEPAGE_CP866);
  PrintCodePage(CODEPAGE_IRAN);
  PrintCodePage2(CODEPAGE_CP866);
(*
  ////////////////////////////////////////////////////////////////////////////
  // После включения арабской кодовой страницы для переключения в другую
  // кодовую страницу нужно инициализировать принтер OA48
  // Это особенность реализации принтера
  ////////////////////////////////////////////////////////////////////////////

  PrintCodePage(CODEPAGE_0C1256_ARABIC);
  FPrinter.Initialize;
  PrintCodePage(CODEPAGE_CP866);
*)
end;

procedure TEscPrinterOA48Test.PrintCodePage(CodePage: Integer);
var
  i: Integer;
  S: AnsiString;
begin
  FPrinter.SetCodePage(CodePage);
  FPrinter.PrintText(Format('Codepage %d, %s', [
    CodePage, GetCodepageName(CodePage)]) + CRLF);

  S := '';
  for i := $00 to $ff do
  begin
    S := S + Chr(i);
    if Length(S) = 16 then
    begin
      FPrinter.PrintText('0x' + IntToHex(i-$0F, 2) + '  ' + S + CRLF);
      S := '';
    end;
  end;
end;


procedure TEscPrinterOA48Test.TestNVBitImage;
var
  Bitmap: TBitmap;
  FileName: string;
begin
  Bitmap := TBitmap.Create;
  try
    FileName := GetModulePath + 'ShtrihM.bmp';
    Bitmap.LoadFromFile(FileName);

    FPrinter.Initialize;
    FPrinter.DefineNVBitImage(1, Bitmap);
    FPrinter.SetJustification(JUSTIFICATION_CENTER);
    FPrinter.PrintNVBitImage(1, BMP_MODE_NORMAL);
  finally
    Bitmap.Free;
  end;
end;

procedure TEscPrinterOA48Test.TestCoverOpen;
var
  i: Integer;
begin
  FPrinter.Initialize;
  FPrinter.RecoverError(True);
  FPrinter.SetCodePage(CODEPAGE_WCP1251);
  for i := 1 to 20 do
  begin
    FPrinter.PrintText('Печать строки ' + IntToStr(i) + CRLF);
  end;
(*
  for i := 1 to 100 do
  begin
    try
      FPrinter.ReadPaperStatus;
      FPrinter.ReadErrorStatus;
      FPrinter.ReadPrinterStatus;
      FPrinter.ReadOfflineStatus;
      FPrinter.ReadPaperRollStatus;
    except
      on E: Exception do
        FLogger.Error(E.Message);
    end;
  end;
*)
end;

procedure TEscPrinterOA48Test.TestRecoverError;
var
  ErrorStatus: TErrorStatus;
begin
  ErrorStatus := FPrinter.ReadErrorStatus;
  if ErrorStatus.AutoRecoverableError then
  begin
    FPrinter.RecoverError(True);
  end;
end;

procedure TEscPrinterOA48Test.TestLineSpacing;
var
  i: Integer;
begin
  FPrinter.Initialize;
  FPrinter.SetCharacterFont(FONT_TYPE_A);
  for i := 1 to 10 do
  begin
    FPrinter.PrintText('Default line spacing ' + IntToStr(i) + CRLF);
  end;
  FPrinter.SetLineSpacing(0);
  for i := 1 to 10 do
  begin
    FPrinter.PrintText('Zero line spacing ' + IntToStr(i) + CRLF);
  end;
  FPrinter.SetLineSpacing(100);
  for i := 1 to 10 do
  begin
    FPrinter.PrintText('100 line spacing ' + IntToStr(i) + CRLF);
  end;
end;

procedure TEscPrinterOA48Test.TestCutDistanceFontA;
begin
  FPrinter.Initialize;
  FPrinter.SetLineSpacing(0);
  FPrinter.SetCharacterFont(0);
  FPrinter.PrintText('Trailer line 1' + CRLF);
  FPrinter.PrintText('Trailer line 2' + CRLF);
  FPrinter.PrintText('Trailer line 3' + CRLF);
  FPrinter.PrintText('Trailer line 4' + CRLF);
  FPrinter.PrintText('Trailer line 5' + CRLF);
  FPrinter.PrintText(CRLF);
  FPrinter.PrintText('Header line 1' + CRLF);
  FPrinter.PrintText('Header line 2' + CRLF);
  FPrinter.PrintText('Header line 3' + CRLF);
  FPrinter.PartialCut;
  FPrinter.PrintText('Header line 4' + CRLF);
  FPrinter.PrintText('Header line 5' + CRLF);
  FPrinter.PrintText('Header line 6' + CRLF);
end;

procedure TEscPrinterOA48Test.TestCutDistanceFontB;
begin
  FPrinter.Initialize;
  FPrinter.SetLineSpacing(0);
  FPrinter.SetCharacterFont(1);
  FPrinter.PrintText('Trailer line 1' + CRLF);
  FPrinter.PrintText('Trailer line 2' + CRLF);
  FPrinter.PrintText('Trailer line 3' + CRLF);
  FPrinter.PrintText('Trailer line 4' + CRLF);
  FPrinter.PrintText('Trailer line 5' + CRLF);
  FPrinter.PrintText(CRLF);
  FPrinter.PrintText('Header line 1' + CRLF);
  FPrinter.PrintText('Header line 2' + CRLF);
  FPrinter.PrintText('Header line 3' + CRLF);
  FPrinter.PrintText('Header line 4' + CRLF);
  FPrinter.PartialCut;
end;

procedure TEscPrinterOA48Test.TestPrintUnicode;
var
  Text: WideString;
begin
  FPrinter.Initialize;
  FPrinter.UTF8Enable(False);
  FPrinter.WriteKazakhCharacters;
  // FONT A
  FPrinter.SetCharacterFont(FONT_TYPE_A);
  FPrinter.PrintUnicode('КАЗАХСКИЕ СИМВОЛЫ A: ' + CRLF);
  FPrinter.PrintUnicode(GetKazakhUnicodeChars + CRLF);
  FPrinter.PrintUnicode('АРАБСКИЕ СИМВОЛЫ: ' + CRLF);
  Text := '';
  Text := Text + WideChar($062B) + WideChar($062C) + WideChar($0635);
  FPrinter.PrintUnicode(Text + CRLF);
  // FONT B
  FPrinter.SetCharacterFont(FONT_TYPE_B);
  FPrinter.PrintUnicode('КАЗАХСКИЕ СИМВОЛЫ B: ' + CRLF);
  FPrinter.PrintUnicode(GetKazakhUnicodeChars + CRLF);
  FPrinter.PrintUnicode('АРАБСКИЕ СИМВОЛЫ: ' + CRLF);
  Text := '';
  Text := Text + WideChar($062B) + WideChar($062C) + WideChar($0635);
  FPrinter.PrintUnicode(Text + CRLF);
end;

procedure TEscPrinterOA48Test.TestBitmap2;
const
  DownloadBMPCommand =
  '1D 2A 0A 0A FF F9 E6 61 E6 7E 06 1F FF 80 80 19 9F 9F F9 E6 18 18 01 80 80 19 9F 9F F9 E6' + CRLF +
  '18 18 01 80 9F 99 E1 FE 1F 80 78 19 F9 80 9F 99 E1 FE 1F 80 78 19 F9 80 9F 99 87 9F 81 86' + CRLF +
  '00 19 F9 80 9F 99 87 9F 81 86 00 19 F9 80 9F 98 1E 7F F8 78 00 19 F9 80 9F 98 1E 7F F8 78' + CRLF +
  '00 19 F9 80 80 18 78 61 86 01 F9 98 01 80 80 18 78 61 86 01 F9 98 01 80 FF F9 99 99 99 99' + CRLF +
  '99 9F FF 80 FF F9 99 99 99 99 99 9F FF 80 00 00 67 81 87 E1 E1 80 00 00 00 00 67 81 87 E1' + CRLF +
  'E1 80 00 00 9F 99 E7 87 87 E6 79 E0 7F 80 9F 99 E7 87 87 E6 79 E0 7F 80 7E 00 01 9F 80 06' + CRLF +
  '01 E7 F8 00 7E 00 01 9F 80 06 01 E7 F8 00 FE 7F E6 19 E7 81 9E 07 E1 80 FE 7F E6 19 E7 81' + CRLF +
  '9E 07 E1 80 61 E1 98 7E 06 07 E1 99 98 00 61 E1 98 7E 06 07 E1 99 98 00 E7 9F F9 E1 80 06' + CRLF +
  '1E 7F F9 80 E7 9F F9 E1 80 06 1E 7F F9 80 E0 61 F8 18 1F 86 66 61 F8 00 E0 61 F8 18 1F 86' + CRLF +
  '66 61 F8 00 87 98 61 E7 FF 9E 18 00 61 80 87 98 61 E7 FF 9E 18 00 61 80 86 67 E1 99 98 7E' + CRLF +
  '06 07 E1 80 86 67 E1 99 98 7E 06 07 E1 80 79 FE 1E 7F F9 E1 80 06 1E 00 79 FE 1E 7F F9 E1' + CRLF +
  '80 06 1E 00 FF 86 67 E7 80 07 87 9E 66 00 FF 86 67 E7 80 07 87 9E 66 00 FE 18 61 86 19 E0' + CRLF +
  '1F 80 78 00 FE 18 61 86 19 E0 1F 80 78 00 79 E6 1E 78 60 66 7E 07 86 00 79 E6 1E 78 60 66' + CRLF +
  '7E 07 86 00 F8 1E 78 60 19 9F 87 9E 1E 00 F8 1E 78 60 19 9F 87 9E 1E 00 E0 61 80 07 F8 19' + CRLF +
  '86 7E 01 80 E0 61 80 07 F8 19 86 7E 01 80 7F FF F8 18 00 66 18 1F 86 00 7F FF F8 18 00 66' + CRLF +
  '18 1F 86 00 F9 86 7F F9 E7 E7 98 1E 18 00 F9 86 7F F9 E7 E7 98 1E 18 00 E6 1F 81 99 E1 E7' + CRLF +
  '86 78 06 00 E6 1F 81 99 E1 E7 86 78 06 00 19 E0 78 19 87 86 7E 07 E1 80 19 E0 78 19 87 86' + CRLF +
  '7E 07 E1 80 01 F8 19 F8 78 78 79 E0 79 80 01 F8 19 F8 78 78 79 E0 79 80 E7 80 60 67 FF 87' + CRLF +
  'E6 06 18 00 E7 80 60 67 FF 87 E6 06 18 00 06 78 19 80 1E 07 E7 FF 98 00 06 78 19 80 1E 07' + CRLF +
  'E7 FF 98 00 00 01 87 E6 19 81 87 81 E7 80 00 01 87 E6 19 81 87 81 E7 80 FF F8 1F E0 66 1F' + CRLF +
  'E1 99 F9 80 FF F8 1F E0 66 1F E1 99 F9 80 80 18 07 E0 07 80 7F 81 99 80 80 18 07 E0 07 80' + CRLF +
  '7F 81 99 80 9F 99 87 FE 19 99 F9 FF FF 80 9F 99 87 FE 19 99 F9 FF FF 80 9F 99 99 F8 7E 1E' + CRLF +
  '66 7E 7F 80 9F 99 99 F8 7E 1E 66 7E 7F 80 9F 99 FF E1 E0 07 81 98 7F 80 9F 99 FF E1 E0 07' + CRLF +
  '81 98 7F 80 80 18 18 01 FF E1 99 9F F9 80 80 18 18 01 FF E1 99 9F F9 80 FF F9 86 66 78 01' + CRLF +
  'E7 FF E1 80 FF F9 86 66 78 01 E7 FF E1 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00' + CRLF +
  '00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00' + CRLF +
  '00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00';

  PrintBMPCommand = '1D 2F 03';
var
  i: Integer;
begin
  for i := 1 to 10 do
  begin
    FPrinter.Initialize;
    FPrinter.PrintText('Print QRCode as bitmap test' + CRLF);
    FPrinter.Send(HexToStr(DownloadBMPCommand));
    FPrinter.Send(HexToStr(PrintBMPCommand));
  end;
end;

procedure TEscPrinterOA48Test.TestPageMode;
const
  Barcode = 't=20240719T1314&s=460.00&fn=7380440700076549&i=41110&fp=2026476352&n=1';
var
  //QRCode: TQRCode;
  PageSize: TRect;
begin
  FPrinter.Initialize;
  //FPrinter.SetLineSpacing(0);
  FPrinter.BeginDocument;
  // Page mode
  FPrinter.SetPageMode;
  PageSize.Left := 0;
  PageSize.Top := 0;
  PageSize.Right := 652;
  PageSize.Bottom := 550;
  //FPrinter.SetPageModeArea(PageSize);
  // QR code on the right
  FPrinter.SetJustification(JUSTIFICATION_LEFT);
  FPrinter.PrintText('ЗН ККТ 00106304241645' + CRLF);
  FPrinter.PrintText('РН ККТ 0000373856050035' + CRLF);
  FPrinter.PrintText('ИНН 7725699008' + CRLF);
  (*
  QRCode.ECLevel := 0;
  QRCode.ModuleSize := 6;
  QRCode.data := Barcode;
  FPrinter.printQRCode(QRCode);
  *)
  // Text on the left
  //FPrinter.SetPMRelativeVerticalPosition(70);
  FPrinter.SetPMAbsoluteVerticalPosition(70);
  FPrinter.SetJustification(JUSTIFICATION_RIGHT);
  FPrinter.PrintText('ФН 7380440700076549' + CRLF);
  FPrinter.PrintText('ФД 41110' + CRLF);
  FPrinter.PrintText('ФП 2026476352' + CRLF);
  FPrinter.PrintText('ПРИХОД 19.07.24 13:14' + CRLF);
  FPrinter.PrintAndReturnStandardMode;
  FPrinter.PrintText(CRLF);
  FPrinter.PrintText(CRLF);
  FPrinter.PrintText(CRLF);
  FPrinter.PrintText(CRLF);
  FPrinter.PartialCut;
  FPrinter.EndDocument;
end;


  (*
  000 "Компания ПАЙ"
  Кассовый чек
  1 Гречка отварная 80.00*1шт. =80.00
  НДС не облагается
  1 Свинина тушеная 260.00*1шт. =260.00
  НLС не облагается
  1 Суп мексиканский 120.00*1шт. =120.00
  НДС не облагается
  ИТОГ =460.00
  СУММА БЕЗ НДС =460.00
  БЕЗНАЛИЧНЫМИ =460.00
  Кассир Менеджер Елена 2022
  000 "Компания ПАЙ"
  115114. Москва. Дербеневская наб.. д.7 стр. 22
  Место расчетов                  Столовая
  ЗН ККТ 00106304241645
  РН ККТ 0000373856050035
  ИНН 7725699008
  ФН 7380440700076549
  ФД 41110
  ФП 2026476352
  ПРИХОД 19.07.24 13:14
  *)

procedure TEscPrinterOA48Test.TestPageModeA;
const
  Separator = '------------------------------------------------';
  Barcode = 't=20240719T1314&s=460.00&fn=7380440700076549&i=41110&fp=2026476352&n=1';
var
  QRCode: TQRCode;
  PageSize: TRect;
begin
  FPrinter.Initialize;
  FPrinter.SetLineSpacing(0);
  FPrinter.BeginDocument;
  //
  FPrinter.SetPrintMode($38);
  FPrinter.PrintText('000 "Компания ПАЙ"');
  FPrinter.SetPrintMode(0);
  FPrinter.PrintText(CRLF);
  FPrinter.PrintText(CRLF);
  // Normal
  FPrinter.SetJustification(JUSTIFICATION_CENTER);
  FPrinter.PrintText('Кассовый чек');
  FPrinter.PrintText(CRLF);
  FPrinter.SetJustification(JUSTIFICATION_LEFT);

  FPrinter.PrintText('1 Гречка отварная 80.00*1шт.              =80.00');
  FPrinter.PrintText(CRLF);
  FPrinter.PrintText('НДС не облагается');
  FPrinter.PrintText(CRLF);

  FPrinter.PrintText('1 Свинина тушеная 260.00*1шт.            =260.00');
  FPrinter.PrintText(CRLF);
  FPrinter.PrintText('НДС не облагается');
  FPrinter.PrintText(CRLF);

  FPrinter.PrintText('1 Суп мексиканский 120.00*1шт.           =120.00');
  FPrinter.PrintText(CRLF);
  FPrinter.PrintText('НДС не облагается');
  FPrinter.PrintText(CRLF);

  FPrinter.PrintText(Separator);
  FPrinter.PrintText(CRLF);

  FPrinter.SetPrintMode($38);
  FPrinter.PrintText('ИТОГ             =460.00');
  FPrinter.SetPrintMode(0);
  FPrinter.PrintText(CRLF);
  FPrinter.PrintText(Separator);
  FPrinter.PrintText(CRLF);

  FPrinter.PrintText('СУММА БЕЗ НДС                            =460.00');
  FPrinter.PrintText(CRLF);
  FPrinter.PrintText('БЕЗНАЛИЧНЫМИ                             =460.00');
  FPrinter.PrintText(CRLF);

  FPrinter.PrintText('Кассир                       Менеджер Елена 2022');
  FPrinter.PrintText(CRLF);
  FPrinter.PrintText('000 "Компания ПАЙ"');
  FPrinter.PrintText(CRLF);
  FPrinter.PrintText('115114. Москва. Дербеневская наб.. д.7 стр. 22');
  FPrinter.PrintText(CRLF);
  FPrinter.PrintText('Место расчетов                          Столовая');
  FPrinter.PrintText(CRLF);
  FPrinter.PrintText(Separator);
  FPrinter.PrintText(CRLF);

  FPrinter.SetPageMode;
  PageSize.Left := 0;
  PageSize.Top := 0;
  PageSize.Right := 652;
  PageSize.Bottom := 550;
  FPrinter.SetPageModeArea(PageSize);

  // QR code on the right
  FPrinter.SetJustification(JUSTIFICATION_RIGHT);
  QRCode.ECLevel := 0;
  QRCode.ModuleSize := 6;
  QRCode.data := Barcode;
  FPrinter.printQRCode(QRCode);
  // Text on the left
  FPrinter.SetPMRelativeVerticalPosition(0);
  //FPrinter.SetPMAbsoluteVerticalPosition(0);
  FPrinter.SetJustification(JUSTIFICATION_LEFT);
  FPrinter.PrintText('ЗН ККТ 00106304241645' + CRLF);
  FPrinter.PrintText('РН ККТ 0000373856050035' + CRLF);
  FPrinter.PrintText('ИНН 7725699008' + CRLF);
  FPrinter.PrintText('ФН 7380440700076549' + CRLF);
  FPrinter.PrintText('ФД 41110' + CRLF);
  FPrinter.PrintText('ФП 2026476352' + CRLF);
  FPrinter.PrintText('ПРИХОД 19.07.24 13:14' + CRLF);
  FPrinter.PrintAndReturnStandardMode;
  FPrinter.PrintText(CRLF);
  FPrinter.PrintText(CRLF);
  FPrinter.PrintText(CRLF);
  FPrinter.PrintText(CRLF);
  FPrinter.PartialCut;
  FPrinter.EndDocument;
end;

procedure TEscPrinterOA48Test.TestPageModeA2;
const
  Separator = '------------------------------------------------';
  Barcode = 'http://dev.kofd.kz/consumer?i=1556041617048&f=768814097419&s=3098.00&t=20241211T151839';
var
  QRCode: TQRCode;
  PageSize: TRect;
begin
  FPrinter.Initialize;
  FPrinter.SetCodePage(CODEPAGE_WCP1251);
  FPrinter.SetLineSpacing(0);
  FPrinter.SetPrintMode(0);

  FPrinter.SetPageMode;
  // Page mode area for text
  PageSize.Left := 100;
  PageSize.Top := 0;
  PageSize.Right := 512;
  PageSize.Bottom := 300;
  FPrinter.SetPageModeArea(PageSize);
  // QR code on the right
  FPrinter.PrintText('                         ');
  FPrinter.SetPMAbsoluteVerticalPosition(0);
  QRCode.ECLevel := 0;
  QRCode.ModuleSize := 4;
  QRCode.data := Barcode;
  FPrinter.printQRCode(QRCode);
  // Text on the left
  FPrinter.SetPMAbsoluteVerticalPosition(0);
  FPrinter.PrintText('ЗН ККТ 00106304241645' + CRLF);
  FPrinter.PrintText('РН ККТ 0000373856050035' + CRLF);
  FPrinter.PrintText('ИНН 7725699008' + CRLF);
  FPrinter.PrintText('ФН 7380440700076549' + CRLF);
  FPrinter.PrintText('ФД 41110' + CRLF);
  FPrinter.PrintText('ФП 2026476352' + CRLF);
  FPrinter.PrintText('ПРИХОД 19.07.24 13:14        ');
  FPrinter.PrintAndReturnStandardMode;

  FPrinter.PrintText(CRLF);
  FPrinter.PrintText(CRLF);
  FPrinter.PrintText(CRLF);
  FPrinter.PrintText(CRLF);
  FPrinter.PrintText(CRLF);
  FPrinter.PrintText(CRLF);
  FPrinter.PartialCut;
end;

procedure TEscPrinterOA48Test.TestPageModeB;
const
  Separator = '----------------------------------------------------------------';
  Barcode = 't=20240719T1314&s=460.00&fn=7380440700076549&i=41110&fp=2026476352&n=1';
var
  QRCode: TQRCode;
  PageSize: TRect;
begin
  FPrinter.Initialize;
  FPrinter.SetLineSpacing(0);
  FPrinter.BeginDocument;
  //
  FPrinter.SetPrintMode($39);
  FPrinter.PrintText('000 "Компания ПАЙ"');
  FPrinter.SetPrintMode(1);
  FPrinter.PrintText(CRLF);
  FPrinter.PrintText(CRLF);
  // Normal
  FPrinter.SetJustification(JUSTIFICATION_CENTER);
  FPrinter.PrintText('Кассовый чек');
  FPrinter.PrintText(CRLF);
  FPrinter.SetJustification(JUSTIFICATION_LEFT);

  FPrinter.PrintText('1 Гречка отварная 80.00*1шт.                              =80.00');
  FPrinter.PrintText(CRLF);
  FPrinter.PrintText('НДС не облагается');
  FPrinter.PrintText(CRLF);

  FPrinter.PrintText('1 Свинина тушеная 260.00*1шт.                            =260.00');
  FPrinter.PrintText(CRLF);
  FPrinter.PrintText('НДС не облагается');
  FPrinter.PrintText(CRLF);

  FPrinter.PrintText('1 Суп мексиканский 120.00*1шт.                           =120.00');
  FPrinter.PrintText(CRLF);
  FPrinter.PrintText('НДС не облагается');
  FPrinter.PrintText(CRLF);

  FPrinter.PrintText(Separator);
  FPrinter.PrintText(CRLF);

  FPrinter.SetPrintMode($39);
  FPrinter.PrintText('ИТОГ                     =460.00');
  FPrinter.SetPrintMode(1);
  FPrinter.PrintText(CRLF);
  FPrinter.PrintText(Separator);
  FPrinter.PrintText(CRLF);

  FPrinter.PrintText('СУММА БЕЗ НДС                                            =460.00');
  FPrinter.PrintText(CRLF);
  FPrinter.PrintText('БЕЗНАЛИЧНЫМИ                                             =460.00');
  FPrinter.PrintText(CRLF);

  FPrinter.PrintText('Кассир                                       Менеджер Елена 2022');
  FPrinter.PrintText(CRLF);
  FPrinter.PrintText('000 "Компания ПАЙ"');
  FPrinter.PrintText(CRLF);
  FPrinter.PrintText('115114. Москва. Дербеневская наб.. д.7 стр. 22');
  FPrinter.PrintText(CRLF);
  FPrinter.PrintText('Место расчетов                                          Столовая');
  FPrinter.PrintText(CRLF);
  FPrinter.PrintText(Separator);
  FPrinter.PrintText(CRLF);

  FPrinter.SetPageMode;
  PageSize.Left := 0;
  PageSize.Top := 0;
  PageSize.Right := 652;
  PageSize.Bottom := 550;
  FPrinter.SetPageModeArea(PageSize);

  // QR code on the right
  FPrinter.PrintText('                                         ');
  FPrinter.SetPMRelativeVerticalPosition(70);
  QRCode.ECLevel := 0;
  QRCode.ModuleSize := 6;
  QRCode.data := Barcode;
  FPrinter.printQRCode(QRCode);
  FPrinter.PrintText(CRLF);
  // Text on the left
  FPrinter.SetPMAbsoluteVerticalPosition(0);
  FPrinter.PrintText('ЗН ККТ 00106304241645' + CRLF);
  FPrinter.PrintText('РН ККТ 0000373856050035' + CRLF);
  FPrinter.PrintText('ИНН 7725699008' + CRLF);
  FPrinter.PrintText('ФН 7380440700076549' + CRLF);
  FPrinter.PrintText('ФД 41110' + CRLF);
  FPrinter.PrintText('ФП 2026476352' + CRLF);
  FPrinter.PrintText('ПРИХОД 19.07.24 13:14' + CRLF);
  FPrinter.PrintAndReturnStandardMode;
  FPrinter.PrintText(CRLF);
  FPrinter.PrintText(CRLF);
  FPrinter.PartialCut;
  FPrinter.EndDocument;
end;

procedure TEscPrinterOA48Test.TestPrintMaxiCode;
const
  Data = 'http://dev.kofd.kz/consumer?i=1320526842876&f=555697470167&s=2000.00&t=20240327T093611';
begin
  FPrinter.Initialize;
  FPrinter.MaxiCodeWriteData(Data);
  FPrinter.MaxiCodeSetMode(0);
  FPrinter.MaxiCodePrint;
end;

procedure TEscPrinterOA48Test.TestPrintUTF;
var
  Text: WideString;
begin
  Text := GetKazakhUnicodeChars;
  // Font A
  FPrinter.Initialize;
  FPrinter.UTF8Enable(True);
  FPrinter.SelectCodePage(CODEPAGE_WCP1251);
  FPrinter.SetCharacterFont(FONT_TYPE_A);
  FPrinter.PrintText(UTF8Encode('Printing in UTF mode, font A' + CRLF));
  FPrinter.PrintText(UTF8Encode(Text + CRLF));
  // Font B
  FPrinter.Initialize;
  FPrinter.UTF8Enable(True);
  FPrinter.SelectCodePage(CODEPAGE_WCP1251);
  FPrinter.SetCharacterFont(FONT_TYPE_B);
  FPrinter.PrintText(UTF8Encode('Printing in UTF mode, font B' + CRLF));
  FPrinter.PrintText(UTF8Encode(Text + CRLF));

  // ASCII mode
  // Font A
  FPrinter.Initialize;
  FPrinter.UTF8Enable(False);
  FPrinter.SelectCodePage(51);
  FPrinter.SetCharacterFont(FONT_TYPE_A);
  FPrinter.PrintText('Printing in normal mode, font A' + CRLF);
  FPrinter.PrintText(Text + CRLF);
  // Font B
  FPrinter.Initialize;
  FPrinter.UTF8Enable(False);
  FPrinter.SelectCodePage(CODEPAGE_WCP1251);
  FPrinter.SetCharacterFont(FONT_TYPE_B);
  FPrinter.PrintText('Printing in normal mode, font B' + CRLF);
  FPrinter.PrintText(Text + CRLF);
end;

procedure TEscPrinterOA48Test.PrintCodePageUTF8;
var
  i: Integer;
  S: AnsiString;
begin
  S := '';
  for i := $20 to $ff do
  begin
    S := S + Chr(i);
    if Length(S) = 32 then
    begin
      FPrinter.PrintText(UTF8Encode('0x' + IntToHex(i-$1F, 2) + '  ' + S + CRLF));
      S := '';
    end;
  end;
end;

procedure TEscPrinterOA48Test.PrintCodePages(const CodePageName: string);
begin
(*
  FPrinter.PrintText('-----------------------------------------' + CRLF);
  FPrinter.PrintText(CodePageName + CRLF);
  FPrinter.SetCharacterFont(FONT_TYPE_A);
  FPrinter.PrintText('Normal mode, font A' + CRLF);
  PrintCodePage;
  FPrinter.SetCharacterFont(FONT_TYPE_B);
  FPrinter.PrintText('Normal mode, font B' + CRLF);
  PrintCodePage;
*)
end;

procedure TEscPrinterOA48Test.TestPrintRussianFontA;
var
  CodePage: Integer;
begin
  FPrinter.Initialize;
  FPrinter.UTF8Enable(False);
  FPrinter.SetCharacterFont(FONT_TYPE_A);

  CodePage := CODEPAGE_WCP1251;
  FPrinter.SelectCodePage(CodePage);
  FPrinter.PrintText('---------------------------------------------' + CRLF);
  FPrinter.PrintText('Normal mode, font A, CodePage: ' + IntToStr(CodePage) + CRLF);
  FPrinter.PrintText('---------------------------------------------' + CRLF);
  //PrintCodePage2;
end;

procedure TEscPrinterOA48Test.TestPrintFontBMode;
var
  Text: AnsiString;
  KazakhText: WideString;
begin
  KazakhText := GetKazakhUnicodeChars;

  FPrinter.Initialize;
  FPrinter.SetCharacterFont(FONT_TYPE_B);
  FPrinter.SelectCodePage(CODEPAGE_CP866);

  FPrinter.UTF8Enable(False);
  Text := WideStringToAnsiString(866, 'Normal mode, font B, CODEPAGE_CP866' + CRLF);
  FPrinter.PrintText(Text);
  Text := WideStringToAnsiString(866, 'Казахский текст: ' + KazakhText + CRLF);
  FPrinter.PrintText(Text);

  FPrinter.UTF8Enable(True);
  FPrinter.PrintText(UTF8Encode('UTF mode, font B, CODEPAGE_CP866' + CRLF));
  FPrinter.PrintText(UTF8Encode('Казахский текст: ' + KazakhText + CRLF));
end;

procedure TEscPrinterOA48Test.TestPrintFontBMode2;
begin
  FPrinter.Initialize;
  FPrinter.SetCharacterFont(FONT_TYPE_A);
  FPrinter.UTF8Enable(True);

  FPrinter.SelectCodePage(CODEPAGE_CP866);
  FPrinter.PrintText(UTF8Encode('UTF mode, font A, CODEPAGE_CP866' + CRLF));
  FPrinter.PrintText(UTF8Encode('Казахский текст: ' + GetKazakhUnicodeChars + CRLF));

  FPrinter.SelectCodePage(CODEPAGE_WCP1251);
  FPrinter.PrintText(UTF8Encode('UTF mode, font A, CODEPAGE_WCP1251' + CRLF));
  FPrinter.PrintText(UTF8Encode('Казахский текст: ' + GetKazakhUnicodeChars + CRLF));
end;

procedure TEscPrinterOA48Test.TestCutterError;
var
  i: Integer;
  P: Integer;
  Line: string;
  Lines: TTntStrings;
begin
  FPrinter.Initialize;
  FPrinter.UTF8Enable(False);
  FPrinter.WriteKazakhCharacters;
  FPrinter.DisableUserCharacters;
  FPrinter.SelectCodePage(CODEPAGE_CP866);
  FPrinter.SetCharacterFont(FONT_TYPE_A);

  FPrinter.BeginDocument;
  Lines := TTntStringList.Create;
  try
    Lines.LoadFromFile('Receipt.txt');
    for i := 0 to Lines.Count-1 do
    begin
      Line := Lines[i];
      P := Pos('->', Line);
      if P <> 0 then
      begin
        Line := Copy(Line, P + 3, Length(Line));
        FPrinter.Send(HexToStr(Line));
      end;
    end;
  finally
    Lines.Free;
    FPrinter.EndDocument;
  end;
end;

procedure TEscPrinterOA48Test.TestUnicodeChars;
var
  Text: WideString;
begin
  Text := '';
  Text := Text + WideChar($062B) + WideChar($062C) + WideChar($0635);
  CheckEquals(True, TestCodePage(Text, 1256), 'CodePage not 1256');
end;

initialization
  RegisterTest('', TEscPrinterOA48Test.Suite);

end.

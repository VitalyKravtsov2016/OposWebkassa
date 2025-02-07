unit duEscPrinterPosiflex;

interface

uses
  // VCL
  Windows, SysUtils, Classes, Graphics,
  // DUnit
  TestFramework,
  // Tnt
  TntClasses, TntSysUtils,
  // This
  DebugUtils, StringUtils, EscPrinterPosiflex, PrinterPort, SerialPort, LogFile,
  FileUtils, SocketPort, RawPrinterPort, USBPrinterPort, EscPrinterUtils;

type
  { TEscPrinterPosiflexTest }

  TEscPrinterPosiflexTest = class(TTestCase)
  private
    FLogger: ILogFile;
    FPrinter: TEscPrinterPosiflex;
    FPrinterPort: IPrinterPort;
    function CreateUSBPort: TUSBPrinterPort;
  protected
    procedure SetUp; override;
    procedure TearDown; override;

    procedure PrintCodePage;
    procedure PrintCodePage2;
    procedure PrintCodePageUTF8;
    procedure PrintCodePages(const CodePageName: string);

    function CreateRawPort: TRawPrinterPort;
    function CreateSerialPort: TSerialPort;
    function CreateSocketPort: TSocketPort;
    function GetKazakhText: WideString;

    property Printer: TEscPrinterPosiflex read FPrinter;
  published
    procedure TestReadStatus;
    procedure TestReadPrinterID;
    procedure TestReadParams;

    procedure TestBitmap;
    procedure TestPrintRasterBMP;
    procedure TestInitialize;
    procedure TestPrintText;
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
    procedure TestCodePage;
    procedure TestCodePage2;
    procedure TestCodePages;
    procedure TestNVBitImage;
    procedure TestCoverOpen;
    procedure TestRecoverError;
    procedure TestUserCharacter;
    procedure TestUserCharacter2;
    procedure TestLineSpacing;
    procedure TestCutDistanceFontA;
    procedure TestCutDistanceFontB;
    procedure TestBitmap2;
    procedure TestPageMode;
    procedure TestPageModeA;
    procedure TestPageModeA2;
    procedure TestPageModeB;
    procedure TestKazakhCodePage;
    procedure TestKazakhCodePage2;
    procedure TestKazakhCodePage3;
    procedure TestPrintFontBMode;
    procedure TestPrintFontBMode2;
    procedure TestCutterError;
  end;

implementation

{ TEscPrinterPosiflexTest }

procedure TEscPrinterPosiflexTest.SetUp;
begin
  inherited SetUp;
  FLogger := TLogFile.Create;
  FLogger.MaxCount := 10;
  FLogger.Enabled := True;
  FLogger.FilePath := 'Logs';
  FLogger.DeviceName := 'DeviceName';

  //FPrinterPort := CreateSocketPort;
  //FPrinterPort := CreateSerialPort;
  FPrinterPort := CreateUSBPort;
  FPrinterPort.Open;
  FPrinter := TEscPrinterPosiflex.Create(FPrinterPort, FLogger);
end;

procedure TEscPrinterPosiflexTest.TearDown;
begin
  FPrinter.Free;
  FPrinterPort := nil;
  inherited TearDown;
end;

function TEscPrinterPosiflexTest.CreateUSBPort: TUSBPrinterPort;
var
  Devices: TUsbDevices;
begin
  Devices := ReadPosiflexDevices;
  CheckEquals(1, Length(Devices), 'Length(Devices)');
  Result := TUSBPrinterPort.Create(FLogger, Devices[0].Path);
end;

function TEscPrinterPosiflexTest.CreateRawPort: TRawPrinterPort;
begin
  Result := TRawPrinterPort.Create(FLogger, 'PP-6900 Thermal Printer');
end;

function TEscPrinterPosiflexTest.CreateSerialPort: TSerialPort;
var
  SerialParams: TSerialParams;
begin
  SerialParams.PortName := 'COM25';
  SerialParams.BaudRate := 19200;
  SerialParams.DataBits := 8;
  SerialParams.StopBits := ONESTOPBIT;
  SerialParams.Parity := 0;
  SerialParams.FlowControl := FLOW_CONTROL_NONE;
  SerialParams.ReconnectPort := False;
  SerialParams.ByteTimeout := 1000;
  Result := TSerialPort.Create(SerialParams, FLogger);
end;

function TEscPrinterPosiflexTest.CreateSocketPort: TSocketPort;
var
  SocketParams: TSocketParams;
begin
  SocketParams.RemoteHost := '10.11.7.176';
  SocketParams.RemotePort := 9100;
  SocketParams.MaxRetryCount := 1;
  SocketParams.ByteTimeout := 1000;
  Result := TSocketPort.Create(SocketParams, FLogger);
end;

procedure TEscPrinterPosiflexTest.TestPrintText;
begin
  FPrinter.PrintText('12345678901234567890123456789012345678901234567890' + CRLF);

  FPrinter.PrintText('Печать строки 1' + CRLF);
  FPrinter.PrintText('Печать строки 2' + CRLF);
  FPrinter.PrintText('Печать строки 3' + CRLF);
end;

procedure TEscPrinterPosiflexTest.TestInitialize;
begin
  FPrinter.Initialize;
  FPrinter.SetCodePage(CODEPAGE_WCP1251);
end;

procedure TEscPrinterPosiflexTest.TestReadStatus;
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

procedure TEscPrinterPosiflexTest.TestPrintMode;
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

procedure TEscPrinterPosiflexTest.TestPrintModeInLine;
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

procedure TEscPrinterPosiflexTest.TestBarcode;
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
(*
  Posiflex 6900 виснет при печати CODABAR
  FPrinter.PrintText('CODABAR' + CRLF);
  FPrinter.PrintBarcode(BARCODE_CODABAR, '8374658738237468');
*)
end;

procedure TEscPrinterPosiflexTest.TestBarcode2;
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

procedure TEscPrinterPosiflexTest.TestPDF417;
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

procedure TEscPrinterPosiflexTest.TestQRCode;
var
  QRCode: TQRCode;
begin
  QRCode.Model := 2;
  QRCode.ModuleSize := 3;
  QRCode.ECLevel := PFX_QRCODE_ECL_7;
  QRCode.data := 'http://dev.kofd.kz/consumer?i=1320526842876&f=555697470167&s=2000.00&t=20240327T093611';

  FPrinter.Initialize;
  FPrinter.printQRCode(QRCode);
end;

///////////////////////////////////////////////////////////////////////////////
// ECL - Error correction level

procedure TEscPrinterPosiflexTest.TestQRCodeECL;
var
  QRCode: TQRCode;
begin
  QRCode.Model := 1;
  QRCode.ModuleSize := 3;
  QRCode.ECLevel := 0;
  QRCode.data := 'http://dev.kofd.kz/consumer?i=1320526842876&f=555697470167&s=2000.00&t=20240327T093611';

  FPrinter.Initialize;
  FPrinter.PrintText(CRLF);
  FPrinter.PrintText('ECL 7%' + CRLF);
  QRCode.ECLevel := PFX_QRCODE_ECL_7;
  FPrinter.printQRCode(QRCode);

  FPrinter.PrintText(CRLF);
  FPrinter.PrintText('ECL 15%' + CRLF);
  QRCode.ECLevel := PFX_QRCODE_ECL_15;
  FPrinter.printQRCode(QRCode);

  FPrinter.PrintText(CRLF);
  FPrinter.PrintText('ECL 25%' + CRLF);
  QRCode.ECLevel := PFX_QRCODE_ECL_25;
  FPrinter.printQRCode(QRCode);

  FPrinter.PrintText(CRLF);
  FPrinter.PrintText('ECL 30%' + CRLF);
  QRCode.ECLevel := PFX_QRCODE_ECL_30;
  FPrinter.printQRCode(QRCode);
end;

procedure TEscPrinterPosiflexTest.TestQRCodeModuleSize;
var
  QRCode: TQRCode;
begin
  QRCode.Model := 2;
  QRCode.ECLevel := PFX_QRCODE_ECL_7;
  QRCode.data := 'http://dev.kofd.kz/consumer?i=1320526842876&f=555697470167&s=2000.00&t=20240327T093611';

  FPrinter.Initialize;
  FPrinter.PrintText('Module size 3' + CRLF);
  QRCode.ModuleSize := 3;
  FPrinter.printQRCode(QRCode);

  FPrinter.PrintText('Module size 5' + CRLF);
  QRCode.ModuleSize := 5;
  FPrinter.printQRCode(QRCode);

  FPrinter.PrintText('Module size 100' + CRLF);
  QRCode.ModuleSize := 100;
  FPrinter.printQRCode(QRCode);
end;

procedure TEscPrinterPosiflexTest.TestQRCodeJustification;
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

procedure TEscPrinterPosiflexTest.TestBitmap;
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

procedure TEscPrinterPosiflexTest.TestPrintRasterBMP;
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

procedure TEscPrinterPosiflexTest.TestReadPrinterID;
begin
  CheckEquals($20, FPrinter.ReadPrinterIdInt(1), 'ReadPrinterIdInt(1)');
  CheckEquals($02, FPrinter.ReadPrinterIdInt(2), 'ReadPrinterIdInt(2)');
  CheckEquals($10, FPrinter.ReadPrinterIdInt(3), 'ReadPrinterIdInt(3)');

  CheckEquals('POSIFLEX', FPrinter.ReadManufacturer, 'Manufacturer');
  CheckEquals('1.4', FPrinter.ReadFirmwareVersion, 'Firmware version');
  CheckEquals('PP-6900', FPrinter.ReadPrinterName, 'Printer name');
  CheckEquals('H6DFQ0', FPrinter.ReadSerialNumber, 'Serial number');
end;

procedure TEscPrinterPosiflexTest.TestReadParams;
begin
  CheckEquals('H6DFQ0  ', FPrinter.ReadParam(PFX_PARAM_SERIAL), 'ReadParam(PFX_PARAM_SERIAL)');
  CheckEquals('223', FPrinter.ReadParam(PFX_PARAM_SW1), 'ReadParam(PFX_PARAM_SW1)');
  CheckEquals('255', FPrinter.ReadParam(PFX_PARAM_SW2), 'ReadParam(PFX_PARAM_SW2)');
  CheckEquals('255', FPrinter.ReadParam(PFX_PARAM_SW3), 'ReadParam(PFX_PARAM_SW3)');
  CheckEquals('255', FPrinter.ReadParam(PFX_PARAM_SW4), 'ReadParam(PFX_PARAM_SW4)');
  CheckEquals('255', FPrinter.ReadParam(PFX_PARAM_SW5), 'ReadParam(PFX_PARAM_SW5)');
  CheckEquals('20170808', FPrinter.ReadParam(PFX_PARAM_INSTALL_DATE), 'ReadParam(PFX_PARAM_INSTALL_DATE)');
  CheckEquals('Cyrillic', FPrinter.ReadParam(PFX_PARAM_LANGUAGE), 'ReadParam(PFX_PARAM_LANGUAGE)');
  CheckEquals('17', FPrinter.ReadParam(PFX_PARAM_CODE_PAGE), 'ReadParam(PFX_PARAM_CODE_PAGE)');
  CheckEquals('0', FPrinter.ReadParam(PFX_PARAM_CHARSET), 'ReadParam(PFX_PARAM_CHARSET)');
(*
  CheckEquals('51076', FPrinter.ReadParam(PFX_PARAM_HOURS_POWERED), 'ReadParam(PFX_PARAM_HOURS_POWERED)');
  CheckEquals('1373980', FPrinter.ReadParam(PFX_PARAM_CUT_COUNT), 'ReadParam(PFX_PARAM_CUT_COUNT)');
  CheckEquals('13', FPrinter.ReadParam(PFX_PARAM_CUT_FAILED), 'ReadParam(PFX_PARAM_CUT_FAILED)');
  CheckEquals('52216416', FPrinter.ReadParam(PFX_PARAM_LINE_PRINTED), 'ReadParam(PFX_PARAM_LINE_PRINTED)');
*)  
end;

procedure TEscPrinterPosiflexTest.PrintTestPage;
begin
  FPrinter.Initialize;
  FPrinter.PrintTestPage;
end;

procedure TEscPrinterPosiflexTest.TestJustification;
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

procedure TEscPrinterPosiflexTest.TestJustification2;
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

procedure TEscPrinterPosiflexTest.TestUnderlined;
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

procedure TEscPrinterPosiflexTest.TestBeepParams;
begin
  FPrinter.Initialize;
  FPrinter.SetBeepParams(3, 1);
end;

procedure TEscPrinterPosiflexTest.TestEmphasized;
begin
  FPrinter.Initialize;
  FPrinter.PrintText('Emphasized mode OFF ');
  FPrinter.SetEmphasizedMode(True);
  FPrinter.PrintText('Emphasized mode ON' + CRLF);
  FPrinter.PrintText('Emphasized mode ON' + CRLF);
  FPrinter.SetEmphasizedMode(False);
end;

procedure TEscPrinterPosiflexTest.TestDoubleStrikeMode;
begin
  FPrinter.Initialize;
  FPrinter.PrintText('Double-strike mode OFF ');
  FPrinter.SetDoubleStrikeMode(True);
  FPrinter.PrintText('Double-strike mode ON' + CRLF);
  FPrinter.PrintText('Double-strike mode ON' + CRLF);
  FPrinter.SetDoubleStrikeMode(False);
end;

procedure TEscPrinterPosiflexTest.TestCharacterFont;
begin
  FPrinter.Initialize;
  FPrinter.PrintText('Character font A' + CRLF);
  FPrinter.PrintText('0123456789012345678901234567890123456789012345678901234567890123456789' + CRLF);
  FPrinter.SetCharacterFont(1);
  FPrinter.PrintText('Character font B' + CRLF);
  FPrinter.PrintText('0123456789012345678901234567890123456789012345678901234567890123456789' + CRLF);
  FPrinter.SetCharacterFont(0);
end;

procedure TEscPrinterPosiflexTest.TestCodePage;
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

procedure TEscPrinterPosiflexTest.TestCodePage2;
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

procedure TEscPrinterPosiflexTest.TestCodePages;
var
  i: Integer;
  Text: AnsiString;
begin
  Text := '';
  for i := $80 to $FF do
    Text := Text + AnsiChar(i);

  //for i := 0 to 20 do
  //for i := 21 to 40 do
  //for i := 220 to 230 do
  i := 224;
  begin
    FPrinter.Initialize;
    FPrinter.SetCodePage(i);
    FPrinter.PrintText(Format('Codepage %d', [i]) + CRLF);
    FPrinter.PrintText(Text + CRLF);
  end;
end;

procedure TEscPrinterPosiflexTest.TestNVBitImage;
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

procedure TEscPrinterPosiflexTest.TestCoverOpen;
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

procedure TEscPrinterPosiflexTest.TestRecoverError;
var
  ErrorStatus: TErrorStatus;
begin
  ErrorStatus := FPrinter.ReadErrorStatus;
  if ErrorStatus.AutoRecoverableError then
  begin
    FPrinter.RecoverError(True);
  end;
end;

procedure TEscPrinterPosiflexTest.TestLineSpacing;
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

procedure TEscPrinterPosiflexTest.TestCutDistanceFontA;
begin
  FPrinter.Initialize;
  FPrinter.SetLineSpacing(0);
  FPrinter.SetCharacterFont(0);
  FPrinter.PrintText('Trailer line 1' + CRLF);
  FPrinter.PrintText('Trailer line 2' + CRLF);
  FPrinter.PrintText('Trailer line 3' + CRLF);
  FPrinter.PrintText('Trailer line 4' + CRLF);
  FPrinter.PrintText('Trailer line 5' + CRLF);
  FPrinter.PrintText(' ' + CRLF);
  FPrinter.PartialCut;
  FPrinter.PrintText('Header line 1' + CRLF);
  FPrinter.PrintText('Header line 2' + CRLF);
  FPrinter.PrintText('Header line 3' + CRLF);
end;

procedure TEscPrinterPosiflexTest.TestCutDistanceFontB;
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

(*

&#1170; 0x0492
cyrillic capital letter ghe stroke
&#1171;
cyrillic small letter ghe stroke
&#1178;
cyrillic capital letter ka descender
&#1179;
cyrillic small letter ka descender
&#1186;
cyrillic capital letter en descender
&#1187;
cyrillic small letter en descender
&#1198;
cyrillic capital letter straight u
&#1199;
cyrillic small letter straight u
&#1200;
cyrillic capital letter straight u stroke
&#1201;
cyrillic small letter straight u stroke
&#1210;
cyrillic capital letter shha
&#1211;
cyrillic small letter shha
&#1240;
cyrillic capital letter schwa
&#1241;
cyrillic small letter schwa
&#1256;
cyrillic capital letter barred o
&#1257;
cyrillic small letter barred o
&#64488;
arabic letter uighur kazakh kirghiz alef maksura initial form
&#64489;
arabic letter uighur kazakh kirghiz alef maksura medial form
????
&#127472;
&#127487;
kazakhstan flag
*)

procedure TEscPrinterPosiflexTest.TestUserCharacter;
begin
(*
  FPrinter.Initialize;
  FPrinter.WriteKazakhCharacters;
  // FONT A
  FPrinter.SetCharacterFont(FONT_TYPE_A);
  FPrinter.PrintText('KAZAKH CHARACTERS A: ');
  FPrinter.PrintUnicode(GetKazakhUnicodeChars + CRLF);
  // FONT B
  FPrinter.SetCharacterFont(FONT_TYPE_B);
  FPrinter.PrintText('KAZAKH CHARACTERS B: ');
  FPrinter.SelectUserCharacter(1);
  FPrinter.PrintText(GetKazakhChars2 + CRLF);
  FPrinter.SelectUserCharacter(0);

  (*
  // Test that charater printed at full size
  FPrinter.SelectUserCharacter(1);
  FPrinter.Send(#$1B#$26#$03 + Chr($7E) + Chr($7E) + Chr(12) + StringOfChar(#$FF, 36));
  FPrinter.PrintText('KAZAKH CHARACTERS A: ' + Chr($7E) + CRLF);
  FPrinter.SelectUserCharacter(0);

  FPrinter.SelectUserCharacter(1);
  FPrinter.WriteUserChar(WideChar(1170), $7E, FONT_TYPE_A);
  FPrinter.PrintText('KAZAKH CHARACTERS A: ' + Chr($7E) + CRLF);
  FPrinter.SelectUserCharacter(0);

  FPrinter.WriteKazakhCharacters;
  for i := Low(KazakhUnicodeChars) to High(KazakhUnicodeChars) do
  begin
    Text2 := Text2 + Chr($20 + i);
  end;
  FPrinter.SelectUserCharacter(1);
  FPrinter.SetCharacterFont(FONT_TYPE_A);
  FPrinter.PrintText('KAZAKH CHARACTERS A: ' + Text2 + CRLF);
  FPrinter.SetCharacterFont(FONT_TYPE_B);
  FPrinter.PrintText('KAZAKH CHARACTERS B: ' + Text2 + CRLF);
  FPrinter.SelectUserCharacter(0);
*)
end;

procedure TEscPrinterPosiflexTest.TestUserCharacter2;
var
  Bitmap: TBitmap;
  UserChar: TUserChar;
begin
  Bitmap := TBitmap.Create;
  try
    Bitmap.LoadFromFile(GetModulePath + 'UserChars/UserChar_0x492.bmp');
    // Write
    UserChar.c1 := $7E;
    UserChar.c2 := $7E;
    UserChar.Font := FONT_TYPE_A;
    UserChar.Data := GetBitmapData(Bitmap, Bitmap.Height);
    UserChar.Width := Bitmap.Width;

    FPrinter.SelectUserCharacter(1);
    FPrinter.DefineUserCharacter(UserChar);
    FPrinter.PrintText('KAZAKH CHARACTERS' + Chr($7E) + CRLF);
    FPrinter.SelectUserCharacter(0);
  finally
    Bitmap.Free;
  end;
end;

procedure TEscPrinterPosiflexTest.TestBitmap2;
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

procedure TEscPrinterPosiflexTest.TestPageMode;
const
  Barcode = 't=20240719T1314&s=460.00&fn=7380440700076549&i=41110&fp=2026476352&n=1';
var
  //QRCode: TQRCode;
  PageSize: TRect;
begin
  FPrinter.Initialize;
  FPrinter.SetCodePage(CODEPAGE_WCP1251);
  FPrinter.BeginDocument;
  // Page mode
  FPrinter.SetPageMode;
  PageSize.Left := 0;
  PageSize.Top := 0;
  PageSize.Right := 512;
  PageSize.Bottom := 550;
  FPrinter.SetPageModeArea(PageSize);
  // QR code on the right
  FPrinter.SetJustification(JUSTIFICATION_LEFT);
  FPrinter.PrintText('ЗН ККТ 00106304241645' + CRLF);
  FPrinter.PrintText('РН ККТ 0000373856050035' + CRLF);
  FPrinter.PrintText('ИНН 7725699008' + CRLF);
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

procedure TEscPrinterPosiflexTest.TestPageModeA;
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

procedure TEscPrinterPosiflexTest.TestPageModeA2;
const
  Separator = '------------------------------------------------';
  Barcode = 'http://dev.kofd.kz/consumer?i=1556041617048&f=768814097419&s=3098.00&t=20241211T151839';
var
  QRCode: TQRCode;
  PageSize: TRect;
begin
  FPrinter.BeginDocument;
  FPrinter.Initialize;
  FPrinter.SetCodePage(CODEPAGE_WCP1251);
  FPrinter.SetLineSpacing(0);
  FPrinter.SetPrintMode(0);

  FPrinter.SetPageMode;
  // Page mode area for text
  PageSize.Left := 0;
  PageSize.Top := 0;
  PageSize.Right := 512-150;
  PageSize.Bottom := 450;
  FPrinter.SetPageModeArea(PageSize);
  // Text on the left
  FPrinter.PrintText('ЗН ККТ 0010630424164528736482764827634872683476287346' + CRLF);
  FPrinter.PrintText('РН ККТ 0000373856050035' + CRLF);
  FPrinter.PrintText('ИНН 7725699008' + CRLF);
  FPrinter.PrintText('ФН 7380440700076549' + CRLF);
  FPrinter.PrintText('ФД 41110' + CRLF);
  FPrinter.PrintText('ФП 2026476352' + CRLF);
  FPrinter.PrintText('ПРИХОД 19.07.24 13:14        ');
  // Page mode area for QR code
  PageSize.Left := 512-150 + 1;
  PageSize.Top := 0;
  PageSize.Right := 512;
  PageSize.Bottom := 450;
  FPrinter.SetPageModeArea(PageSize);
  // QR code on the right
  FPrinter.PrintText(CRLF);
  QRCode.ECLevel := 0;
  QRCode.ModuleSize := 4;
  QRCode.data := Barcode;
  FPrinter.printQRCode(QRCode);
  FPrinter.PrintAndReturnStandardMode;

  FPrinter.PrintText(CRLF);
  FPrinter.PrintText(CRLF);
  FPrinter.PrintText(CRLF);
  FPrinter.PrintText(CRLF);
  FPrinter.PrintText(CRLF);
  FPrinter.PrintText(CRLF);
  FPrinter.PartialCut;
  FPrinter.EndDocument;
end;

procedure TEscPrinterPosiflexTest.TestPageModeB;
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

function TEscPrinterPosiflexTest.GetKazakhText: WideString;
var
  Strings: TTntStringList;
begin
  Result := '';
  Strings := TTntStringList.Create;
  try
    Strings.LoadFromFile('KazakhText.txt');
    Result := Strings.Text;
  finally
    Strings.Free;
  end;
end;

procedure TEscPrinterPosiflexTest.PrintCodePage;
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
      FPrinter.PrintText('0x' + IntToHex(i-$1F, 2) + '  ' + S + CRLF);
      S := '';
    end;
  end;
end;

procedure TEscPrinterPosiflexTest.PrintCodePageUTF8;
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

procedure TEscPrinterPosiflexTest.PrintCodePage2;
var
  i: Integer;
  S: AnsiString;
begin
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

procedure TEscPrinterPosiflexTest.PrintCodePages(const CodePageName: string);
begin
  FPrinter.PrintText('-----------------------------------------' + CRLF);
  FPrinter.PrintText(CodePageName + CRLF);
  FPrinter.SetCharacterFont(FONT_TYPE_A);
  FPrinter.PrintText('Normal mode, font A' + CRLF);
  PrintCodePage;
  FPrinter.SetCharacterFont(FONT_TYPE_B);
  FPrinter.PrintText('Normal mode, font B' + CRLF);
  PrintCodePage;
end;

procedure TEscPrinterPosiflexTest.TestKazakhCodePage;
var
  CodePage: Integer;
begin
  FPrinter.Initialize;
  FPrinter.SetCharacterFont(FONT_TYPE_A);

  //for CodePage := 0 to 20 do
  CodePage := 224;
  begin
    FPrinter.SetCodePage(CodePage);
    FPrinter.PrintText('---------------------------------------------' + CRLF);
    FPrinter.PrintText('Normal mode, font B, CodePage: ' + IntToStr(CodePage) + CRLF);
    FPrinter.PrintText('---------------------------------------------' + CRLF);
    PrintCodePage2;
  end;
end;

procedure TEscPrinterPosiflexTest.TestKazakhCodePage2;
begin
  FPrinter.Initialize;
  // FONT A
  FPrinter.SetCharacterFont(FONT_TYPE_A);
  FPrinter.PrintUnicode('КАЗАХСКИЕ СИМВОЛЫ, ШРИФТ A: ' + CRLF);
  FPrinter.PrintUnicode(GetKazakhUnicodeChars + CRLF);
  // FONT B
  FPrinter.SetCharacterFont(FONT_TYPE_B);
  FPrinter.PrintUnicode('КАЗАХСКИЕ СИМВОЛЫ, ШРИФТ Б: ' + CRLF);
  FPrinter.PrintUnicode(GetKazakhUnicodeChars + CRLF);
end;

procedure TEscPrinterPosiflexTest.TestKazakhCodePage3;
var
  i: Integer;
begin
  FPrinter.Initialize;
  FPrinter.SetCodePage(224);
  FPrinter.SetCharacterFont(FONT_TYPE_A);
  for i := Low(KazakhUnicodeChars) to High(KazakhUnicodeChars) do
  begin
    FPrinter.PrintKazakhChar(WideChar(KazakhUnicodeChars[i]));
  end;
  FPrinter.PrintText(CRLF);
end;

procedure TEscPrinterPosiflexTest.TestPrintFontBMode;
var
  Text: AnsiString;
  KazakhText: WideString;
begin
  KazakhText := GetKazakhText;

  FPrinter.Initialize;
  FPrinter.SetCharacterFont(FONT_TYPE_B);
  FPrinter.SetCodePage(CODEPAGE_CP866);

  Text := WideStringToAnsiString(866, 'Normal mode, font B, CODEPAGE_CP866' + CRLF);
  FPrinter.PrintText(Text);
  Text := WideStringToAnsiString(866, 'Казахский текст: ' + KazakhText + CRLF);
  FPrinter.PrintText(Text);

  FPrinter.PrintText(UTF8Encode('UTF mode, font B, CODEPAGE_CP866' + CRLF));
  FPrinter.PrintText(UTF8Encode('Казахский текст: ' + KazakhText + CRLF));
end;

procedure TEscPrinterPosiflexTest.TestPrintFontBMode2;
var
  KazakhText: WideString;
begin
  KazakhText := GetKazakhText;

  FPrinter.Initialize;
  FPrinter.SetCharacterFont(FONT_TYPE_A);

  FPrinter.SetCodePage(CODEPAGE_CP866);
  FPrinter.PrintText(UTF8Encode('UTF mode, font A, CODEPAGE_CP866' + CRLF));
  FPrinter.PrintText(UTF8Encode('Казахский текст: ' + KazakhText + CRLF));

  FPrinter.SetCodePage(CODEPAGE_WCP1251);
  FPrinter.PrintText(UTF8Encode('UTF mode, font A, CODEPAGE_WCP1251' + CRLF));
  FPrinter.PrintText(UTF8Encode('Казахский текст: ' + KazakhText + CRLF));
end;

procedure TEscPrinterPosiflexTest.TestCutterError;
var
  i: Integer;
  P: Integer;
  Line: string;
  Lines: TTntStrings;
begin
  FPrinter.Initialize;
  FPrinter.WriteKazakhCharacters;
  FPrinter.DisableUserCharacters;
  FPrinter.SetCodePage(CODEPAGE_CP866);
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

initialization
  RegisterTest('', TEscPrinterPosiflexTest.Suite);

end.

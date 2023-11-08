
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
  FileUtils, SocketPort, RawPrinterPort;

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

    function CreateRawPort: TRawPrinterPort;
    function CreateSerialPort: TSerialPort;
    function CreateSocketPort: TSocketPort;
    property Printer: TESCPrinter read FPrinter;
  published
    procedure TestBitmap;
    procedure TestReadPrinterID;
    procedure TestInitialize;
    procedure TestPrintText;
    procedure TestReadStatus;
    procedure TestPrintMode;
    procedure TestPrintModeInLine;
    procedure TestBarcode;
    procedure TestBarcode2;
    procedure TestQRCode;
    procedure TestQRCode2;
    procedure PrintTestPage;
    procedure TestJustification;
    procedure TestJustification2;
    procedure TestUnderlined;
    procedure TestBeepParams;
    procedure TestEmphasized;
    procedure TestDoubleStrikeMode;
    procedure TestCharacterFont;
    procedure TestCodePage;
    procedure TestNVBitImage;
    procedure TestCoverOpen;
    procedure TestRecoverError;
    procedure TestUserCharacter;
  end;

implementation

{ TESCPrinterTest }

procedure TESCPrinterTest.SetUp;
begin
  inherited SetUp;
  FLogger := TLogFile.Create;
  FLogger.MaxCount := 10;
  FLogger.Enabled := True;
  FLogger.FilePath := 'Logs';
  FLogger.DeviceName := 'DeviceName';

  //FPrinterPort := CreateSocketPort;
  //FPrinterPort := CreateSerialPort;

  FPrinterPort := CreateRawPort;
  FPrinterPort.Open;
  FPrinter := TEscPrinter.Create(FPrinterPort, FLogger);
end;

procedure TESCPrinterTest.TearDown;
begin
  FPrinter.Free;
  FPrinterPort := nil;
  inherited TearDown;
end;

function TESCPrinterTest.CreateRawPort: TRawPrinterPort;
begin
  Result := TRawPrinterPort.Create(FLogger, 'RONGTA 80mm Series Printer');
end;

function TESCPrinterTest.CreateSerialPort: TSerialPort;
var
  SerialParams: TSerialParams;
begin
  SerialParams.PortName := 'COM12';
  SerialParams.BaudRate := 19200;
  SerialParams.DataBits := 8;
  SerialParams.StopBits := ONESTOPBIT;
  SerialParams.Parity := 0;
  SerialParams.FlowControl := FLOW_CONTROL_NONE;
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

procedure TESCPrinterTest.TestPrintText;
begin
  FPrinter.PrintText('Печать строки 1' + CRLF);
  FPrinter.PrintText('Печать строки 2' + CRLF);
  FPrinter.PrintText('Печать строки 3' + CRLF);
end;

procedure TESCPrinterTest.TestInitialize;
begin
  FPrinter.Initialize;
  FPrinter.SetCodePage(CODEPAGE_WCP1251);
end;

procedure TESCPrinterTest.TestReadStatus;
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

procedure TESCPrinterTest.TestPrintMode;
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

procedure TESCPrinterTest.TestBarcode;
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

procedure TESCPrinterTest.TestBarcode2;
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

procedure TESCPrinterTest.TestQRCode;
var
  QRCode: TQRCode;
begin
  FPrinter.Initialize;
  FPrinter.PrintText('QRCode test' + CRLF);
  FPrinter.PrintText('SetLeftMargin(100)' + CRLF);
  FPrinter.SetLeftMargin(100);
  FPrinter.PrintText('SetLeftMargin(100): OK' + CRLF);
  FPrinter.PrintText('SetLeftMargin(100): OK' + CRLF);
  FPrinter.Select2DBarcode(BARCODE_QR_CODE);
  QRCode.SymbolVersion := 0;
  QRCode.ECLevel := 1;
  QRCode.ModuleSize := 4;
  QRCode.data := 'QRCodetestQRCodetestQRCodetest';
  FPrinter.printQRCode(QRCode);
end;

procedure TESCPrinterTest.TestQRCode2;
var
  Data: string;
begin
  Data := HexToStr('1B5A0001045400687474703A2F2F6465762E6B6F66642E6B7A2F636F6E73756D65723F693D39333832393836333035343726663D32313130333032303032303726733D3133392E303026743D323032333031313754313730303237');
  FPrinter.Send(Data);
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

    FPrinter.Initialize;
    FPrinter.DownloadBMP(JUSTIFICATION_LEFT, Bitmap);

    FPrinter.SetJustification(JUSTIFICATION_LEFT);
    FPrinter.PrintBmp(BMP_MODE_NORMAL);
    FPrinter.SetJustification(JUSTIFICATION_CENTERING);
    FPrinter.PrintBmp(BMP_MODE_NORMAL);
    FPrinter.SetJustification(JUSTIFICATION_RIGHT);
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

procedure TESCPrinterTest.PrintTestPage;
begin
  FPrinter.Initialize;
  FPrinter.PrintTestPage;
end;

procedure TESCPrinterTest.TestJustification;
var
  QRCode: TQRCode;
begin
  FPrinter.Initialize;
  FPrinter.SetHRIPosition(HRI_BELOW_BARCODE);
  FPrinter.SetJustification(JUSTIFICATION_CENTERING);
  FPrinter.PrintText('QRCode test' + CRLF);
  FPrinter.Select2DBarcode(BARCODE_QR_CODE);
  QRCode.SymbolVersion := 0;
  QRCode.ECLevel := 1;
  QRCode.ModuleSize := 4;
  QRCode.data := 'QRCodetestQRCodetestQRCodetest';
  FPrinter.printQRCode(QRCode);
  FPrinter.SetJustification(JUSTIFICATION_LEFT);
end;

procedure TESCPrinterTest.TestJustification2;
begin
  FPrinter.Initialize;
  FPrinter.PrintText('Default justification' + CRLF);
  FPrinter.SetJustification(JUSTIFICATION_LEFT);
  FPrinter.PrintText('Left justification' + CRLF);
  FPrinter.SetJustification(JUSTIFICATION_CENTERING);
  FPrinter.PrintText('Centering justification' + CRLF);
  FPrinter.SetJustification(JUSTIFICATION_RIGHT);
  FPrinter.PrintText('Right justification' + CRLF);
end;

procedure TESCPrinterTest.TestUnderlined;
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

procedure TESCPrinterTest.TestBeepParams;
begin
  FPrinter.Initialize;
  FPrinter.SetBeepParams(3, 1);
end;

procedure TESCPrinterTest.TestEmphasized;
begin
  FPrinter.Initialize;
  FPrinter.PrintText('Emphasized mode OFF ');
  FPrinter.SetEmphasizedMode(True);
  FPrinter.PrintText('Emphasized mode ON' + CRLF);
  FPrinter.PrintText('Emphasized mode ON' + CRLF);
  FPrinter.SetEmphasizedMode(False);
end;

procedure TESCPrinterTest.TestDoubleStrikeMode;
begin
  FPrinter.Initialize;
  FPrinter.PrintText('Double-strike mode OFF ');
  FPrinter.SetDoubleStrikeMode(True);
  FPrinter.PrintText('Double-strike mode ON' + CRLF);
  FPrinter.PrintText('Double-strike mode ON' + CRLF);
  FPrinter.SetDoubleStrikeMode(False);
end;

procedure TESCPrinterTest.TestCharacterFont;
begin
  FPrinter.Initialize;
  FPrinter.PrintText('Character font A');
  FPrinter.SetCharacterFont(1);
  FPrinter.PrintText('Character font B' + CRLF);
  FPrinter.SetCharacterFont(0);
end;

procedure TESCPrinterTest.TestCodePage;
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
    // 1256 Arabic
    FPrinter.SetCodePage(CODEPAGE_WCP1251);
    FPrinter.PrintText('CODEPAGE 1256 Arabic' + CRLF);
    FPrinter.SetCodePage(CODEPAGE_WCP1256);
    Strings.LoadFromFile(GetModulePath + 'ArabicText.txt');
    WideText := Strings[0];
    Text := WideStringToAnsiString(1256, WideText);
    FPrinter.PrintText(Text + CRLF);
  finally
    Strings.Free;
  end;
end;

procedure TESCPrinterTest.TestNVBitImage;
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
    FPrinter.SetJustification(JUSTIFICATION_CENTERING);
    FPrinter.PrintNVBitImage(1, BMP_MODE_NORMAL);
  finally
    Bitmap.Free;
  end;
end;

procedure TESCPrinterTest.TestCoverOpen;
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

procedure TESCPrinterTest.TestRecoverError;
var
  ErrorStatus: TErrorStatus;
begin
  ErrorStatus := FPrinter.ReadErrorStatus;
  if ErrorStatus.AutoRecoverableError then
  begin
    FPrinter.RecoverError(True);
  end;
end;

procedure TESCPrinterTest.TestUserCharacter;
var
  i: Integer;
  C: WideChar;
  Text: WideString;
  Strings: TTntStrings;
begin
  FPrinter.Initialize;

  Strings := TTntStringList.Create;
  try
    Strings.LoadFromFile('KazakhText.txt');
    Text := Strings.Text;


    C := Text[1];
    FPrinter.SelectUserCharacter(1);
    FPrinter.WriteUserChar(C, FONT_TYPE_A, $33);
    FPrinter.PrintText(Chr($33) + CRLF);
    FPrinter.PrintText('F' + CRLF);
    FPrinter.SelectUserCharacter(0);
(*
    for i := 1 to Length(Text) do
    begin
      FPrinter.WriteUserChar(Text[i], FONT_TYPE_A, i + $70);
      FPrinter.PrintText(Chr(i + $70) + CRLF);
    end;
*)
  finally
    Strings.Free;
  end;
end;

initialization
  RegisterTest('', TESCPrinterTest.Suite);

end.

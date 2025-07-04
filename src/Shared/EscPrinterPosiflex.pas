unit EscPrinterPosiflex;

interface

uses
  // VCL
  Windows, Types, SysUtils, Graphics, Classes,
  // Tnt
  TntGraphics,
  // This
  ByteUtils, PrinterPort, RegExpr, StringUtils, LogFile, FileUtils,
  EscPrinterUtils, CharCode, DebugUtils, UserError, StringConst;

const
  MinLineSpacing = 5;

  /////////////////////////////////////////////////////////////////////////////
  // Params constants

  PFX_PARAM_HOURS_POWERED = $10;
  PFX_PARAM_CUT_COUNT     = $15;
  PFX_PARAM_INSTALL_DATE  = $09;
  PFX_PARAM_CUT_FAILED    = $16;
  PFX_PARAM_LINE_PRINTED  = $1B;
  PFX_PARAM_SERIAL   = $05;
  PFX_PARAM_LANGUAGE = $24;
  PFX_PARAM_CODE_PAGE = $21;
  PFX_PARAM_CHARSET = $22;
  PFX_PARAM_SW1 = $27;
  PFX_PARAM_SW2 = $28;
  PFX_PARAM_SW3 = $29;
  PFX_PARAM_SW4 = $2A;
  PFX_PARAM_SW5 = $2B;


  /////////////////////////////////////////////////////////////////////////////
  // PDF417 options

  // 0 Selects the standard PDF417.
  PDF417_OPTIONS_STANDARD   = 0;
  // 1 Selects the truncated PDF417
  PDF417_OPTIONS_TRANCATED  = 1;

  /////////////////////////////////////////////////////////////////////////////
  // Font type

  FONT_TYPE_A = 0; // 12x24
  FONT_TYPE_B = 1; // 8x16

  FONT_TYPE_MIN = FONT_TYPE_A;
  FONT_TYPE_MAX = FONT_TYPE_B;

  /////////////////////////////////////////////////////////////////////////////
  // QRCode error correction level

  PFX_QRCODE_ECL_7   = 0;
  PFX_QRCODE_ECL_15  = 1;
  PFX_QRCODE_ECL_25  = 2;
  PFX_QRCODE_ECL_30  = 3;

  SupportedCodePages: array [0..18] of Integer = (
    437,737,850,852,855,857,858,860,862,863,
    864,865,866,1251,1253,1254,1255,1256,1257);

  ESC   = #$1B;
  CRLF  = #13#10;

  /////////////////////////////////////////////////////////////////////////////
  // The allowable character code range is from ASCII code <20>H to
  // <7E>H (95 characters).

  USER_CHAR_CODE_MIN = $20;
  USER_CHAR_CODE_MAX = $7E;

  /////////////////////////////////////////////////////////////////////////////
  // Charset constants

  CHARSET_USA             = 0; // U.S.A
  CHARSET_FRANCE          = 1; // France
  CHARSET_GERMANY         = 2; // Germany
  CHARSET_UK              = 3; // U.K
  CHARSET_DENMARK_I       = 4;
  CHARSET_SWEDEN          = 5;
  CHARSET_ITALY           = 6;
  CHARSET_SPAIN           = 7;
  CHARSET_JAPAN           = 8;
  CHARSET_NORWAY          = 9;
  CHARSET_DENMARK_II      = 10;
  CHARSET_SPAIN_II        = 11;
  CHARSET_LATIN_AMERICA   = 12;
  CHARSET_KOREA           = 13;

  /////////////////////////////////////////////////////////////////////////////
  // Justification constants

  JUSTIFICATION_LEFT      = 0;
  JUSTIFICATION_CENTER    = 1;
  JUSTIFICATION_RIGHT     = 2;

  /////////////////////////////////////////////////////////////////////////////
  // Codepage constants

  CODEPAGE_CP437        = 0;
  CODEPAGE_KATAKANA     = 1;
  CODEPAGE_CP850        = 2;
  CODEPAGE_CP860        = 3;
  CODEPAGE_CP863        = 4; // CANADIAN-FRENCH
  CODEPAGE_CP865        = 5;
  CODEPAGE_CP866        = 17;
  CODEPAGE_CP852        = 18;
  CODEPAGE_CP858        = 19;
  CODEPAGE_CP862        = 21;
  CODEPAGE_CP864        = 22;
  CODEPAGE_WCP1254      = 24;
  CODEPAGE_WCP1257      = 26;
  CODEPAGE_WCP1256      = 27;
  CODEPAGE_WCP1251      = 28;
  CODEPAGE_CP737        = 29;
  CODEPAGE_THAI         = 31;
  CODEPAGE_WCP1255      = 33;
  CODEPAGE_THAI2        = 34;
  CODEPAGE_CP855        = 36;
  CODEPAGE_CP857        = 37;
  CODEPAGE_KAZAKH       = 224;

  /////////////////////////////////////////////////////////////////////////////
  // BMP mode constants

  BMP_MODE_NORMAL         = 0; // 203.2 DPI 203.2 DPI
  BMP_MODE_DOUBLE_WIDTH   = 1; // 203.2 DPI 101.6 DPI
  BMP_MODE_DOUBLE_HEIGHT  = 2; // 101.6 DPI 203.2 DPI
  BMP_MODE_QUADRUPLE      = 3;

  /////////////////////////////////////////////////////////////////////////////
  // Printer ID constants

  PID_MODEL_ID          = 1;
  PID_TYPE_ID           = 2;
  PID_FIRMWARE_VERSION  = 65;
  PID_MANUFACTURER      = 66; // EPOSN
  PID_PRINTER_NAME      = 67; // TM-T88V
  PID_SERIAL_NUMBER     = 68;
  PID_FONT_TYPES        = 69;

  /////////////////////////////////////////////////////////////////////////////
  // HRI position constants

  HRI_NOT_PRINTED           = 0;
  HRI_ABOVE_BARCODE         = 1;
  HRI_BELOW_BARCODE         = 2;
  HRI_BOTH_ABOVE_AND_BELOW  = 3;

  /////////////////////////////////////////////////////////////////////////////
  // Barcode constants

  BARCODE_UPC_A     = 0;
  BARCODE_UPC_E     = 1;
  BARCODE_EAN13     = 2;
  BARCODE_EAN8      = 3;
  BARCODE_CODE39    = 4;
  BARCODE_ITF       = 5;
  BARCODE_CODABAR   = 6;

  BARCODE2_UPC_A    = 65;
  BARCODE2_UPC_E    = 66;
  BARCODE2_EAN13    = 67;
  BARCODE2_EAN8     = 68;
  BARCODE2_CODE39   = 69;
  BARCODE2_ITF      = 70;
  BARCODE2_CODABAR  = 71;
  BARCODE2_CODE93   = 72;
  BARCODE2_CODE128  = 73;

  /////////////////////////////////////////////////////////////////////////////
  // Page mode direction constants

  PM_DIRECTION_LEFT_TO_RIGHT  = 0;
  PM_DIRECTION_BOTTOM_TO_TOP  = 1;
  PM_DIRECTION_RIGHT_TO_LEFT  = 2;
  PM_DIRECTION_TOP_TO_BOTTOM  = 3;

  /////////////////////////////////////////////////////////////////////////////
  // Underline mode constants

  UNDERLINE_MODE_NONE         = 0;
  UNDERLINE_MODE_1DOT         = 1;
  UNDERLINE_MODE_2DOT         = 2;

type
  { TDeviceMetrics }

  TDeviceMetrics = record
    PrintWidth: Integer;
  end;

  { TPrinterStatus }

  TPrinterStatus = record
    DrawerOpened: Boolean;
    IsOnline: Boolean;
  end;

  { TOfflineStatus }

  TOfflineStatus = record
    CoverOpened: Boolean; // 2
    FeedButton: Boolean; // 3
    ErrorOccurred: Boolean; // 6
  end;

  { TErrorStatus }

  TErrorStatus = record
    CutterError: Boolean; // 3
    UnrecoverableError: Boolean; // 5
    AutoRecoverableError: Boolean; // 6
  end;

  { TPaperStatus }

  TPaperStatus = record
    PaperNearEnd: Boolean; // 5.3
    PaperPresent: Boolean; // 5.6
  end;

  { TPaperRollStatus }

  TPaperRollStatus = record
    PaperNearEnd: Boolean;
  end;

  { TUserChar }

  TUserChar = record
    c1: Byte;
    c2: Byte;
    Font: Byte;
    Data: AnsiString;
    Width: Integer;
  end;

  { TPDF417 }

  TPDF417 = record
    RowNumber: Byte; // 1..30
    ColumnNumber: Byte; // 1..30
    ErrorCorrectionLevel: Byte; // 0..8
    ModuleWidth: Byte;
    ModuleHeight: Byte;
    Options: Byte;
    data: AnsiString;
  end;

  { TQRCode }

  TQRCode = record
    Model: Byte; // 1..2
    ECLevel: Byte; // 1..19
    ModuleSize: Byte; // 1..8
    data: AnsiString;
  end;

  { TEscPrinterPosiflex }

  TEscPrinterPosiflex = class
  private
    FFont: Integer;
    FLogger: ILogFile;
    FPort: IPrinterPort;
    FCodePage: Integer;
    FInTransaction: Boolean;
    FUserCharacterMode: Integer;
    FUserChars: TCharCodes;
    FKazakhChars: TCharCodes;
    FDeviceMetrics: TDeviceMetrics;
    procedure CheckUserCharCode(Code: Byte);
  public
    procedure EnableUserCharacters;
    procedure DisableUserCharacters;
    procedure DrawWideChar(AChar: WideChar; AFont: Byte; Bitmap: TBitmap; X, Y: Integer);
    function GetFontData(Bitmap: TBitmap): AnsiString;
  public
    constructor Create(APort: IPrinterPort; ALogger: ILogFile);
    destructor Destroy; override;

    procedure CheckCapRead;
    function CapRead: Boolean;
    procedure Send(const Data: AnsiString);

    procedure HorizontalTab;
    procedure LineFeed;
    procedure CarriageReturn;
    function ReadPrinterStatus: TPrinterStatus;
    function ReadOfflineStatus: TOfflineStatus;
    function ReadErrorStatus: TErrorStatus;
    function ReadPaperStatus: TPaperStatus;
    procedure RecoverError(ClearBuffer: Boolean);
    procedure GeneratePulse(n, m, t: Byte);
    procedure SetRightSideCharacterSpacing(n: Byte);
    procedure SelectPrintMode(Mode: TPrintMode);
    procedure SetPrintMode(Mode: Byte);
    procedure SetAbsolutePrintPosition(n: Word);
    procedure SelectUserCharacter(n: Byte);
    procedure DefineUserCharacter(C: TUserChar);
    procedure SelectBitImageMode(Mode: Integer; Image: TGraphic);
    procedure SetUnderlineMode(n: Byte);
    procedure SetDefaultLineSpacing;
    procedure SetLineSpacing(n: Byte);
    procedure CancelUserCharacter(n: Byte);
    procedure Initialize;
    procedure SetBeepParams(N: Byte; T: Byte);
    procedure SetHorizontalTabPositions(Tabs: AnsiString);
    procedure SetEmphasizedMode(Value: Boolean);
    procedure SetDoubleStrikeMode(Value: Boolean);
    procedure PrintAndFeed(N: Byte);
    procedure SetCharacterFont(N: Byte);
    procedure SetCharacterSet(N: Byte);
    procedure Set90ClockwiseRotation(Value: Boolean);
    procedure SetRelativePrintPosition(n: Word);
    procedure SetJustification(N: Byte);
    procedure EnableButtons(Value: Boolean);
    procedure PrintAndFeedLines(N: Byte);
    procedure SetCodePage(CodePage: Integer);
    procedure SetUpsideDownPrinting(Value: Boolean);
    procedure PartialCut;
    procedure PartialCut2;
    procedure SelectChineseCode(N: Byte);
    procedure PrintNVBitImage(Number, Mode: Byte);
    procedure DefineNVBitImage(Number: Byte; Image: TGraphic);
    procedure SetCharacterSize(N: Byte);
    procedure DownloadBMP(Image: TGraphic);
    procedure PrintBmp(Mode: Byte);
    procedure SetWhiteBlackReverse(Value: Boolean);
    function ReadPrinterID(N: Byte): AnsiString;
    function ReadParam(N: Byte): AnsiString;
    function ReadPrinterIDInt(N: Byte): Integer;
    procedure SetHRIPosition(N: Byte);
    procedure SetLeftMargin(N: Word);
    procedure SetCutModeAndCutPaper(M: Byte);
    procedure SetCutModeAndCutPaper2(n: Byte);
    procedure SetPrintAreaWidth(n: Byte);
    procedure StartEndMacroDefinition;
    procedure ExecuteMacro(r, t, m: Byte);
    procedure EnableAutomaticStatusBack(N: Byte);
    procedure SetHRIFont(N: Byte);
    procedure SetBarcodeHeight(N: Byte);
    procedure PrintBarcode(BCType: Byte; const Data: AnsiString);
    procedure PrintBarcode2(BCType: Byte; const Data: AnsiString);
    function ReadPaperRollStatus: TPaperRollStatus;
    procedure PrintRasterBMP(Mode: Byte; Image: TGraphic);
    procedure SetBarcodeWidth(N: Integer);
    procedure SetBarcodeLeft(N: Integer);
    procedure SetMotionUnits(x, y: Integer);
    procedure PrintTestPage;
    procedure SetKanjiMode(m: Byte);
    procedure SelectKanjiCharacter;
    procedure SetKanjiUnderline(Value: Boolean);
    procedure CancelKanjiCharacter;
    procedure DefineKanjiCharacters(c1, c2: Byte; const data: AnsiString);
    procedure SetPeripheralDevice(m: Byte);
    procedure SetKanjiSpacing(n1, n2: Byte);
    procedure PrintAndReturnStandardMode;
    procedure PrintDataInMode;
    procedure SetPageMode;
    procedure SetStandardMode;
    procedure SetPageModeDirection(n: Byte);
    procedure SetPageModeArea(R: TPageArea);
    procedure printPDF417(const Barcode: TPDF417);
    procedure printQRCode(const Barcode: TQRCode);
    procedure SetKanjiQuadSizeMode(Value: Boolean);
    procedure FeedMarkedPaper;
    procedure SetPMAbsoluteVerticalPosition(n: Integer);
    procedure ExecuteTestPrint(p: Integer; n, m: Byte);
    procedure SelectCounterPrintMode(n, m: Byte);
    procedure SelectCountMode(a, b: Word; n, r: Byte);
    procedure SetCounter(n: Word);
    procedure SetPMRelativeVerticalPosition(n: Word);
    procedure PrintCounter;
    procedure PrintText(Text: AnsiString);
    procedure SetNormalPrintMode;

    function ReadFirmwareVersion: AnsiString;
    function ReadManufacturer: AnsiString;
    function ReadPrinterName: AnsiString;
    function ReadSerialNumber: AnsiString;

    procedure BeginDocument;
    procedure EndDocument;
    procedure WriteUserChar(AChar: WideChar; ACode, AFont: Byte);
    procedure WriteUserChar2(AChar: WideChar; ACode, AFont: Byte);
    procedure WriteKazakhCharacters;
    procedure PrintUserChar(Char: WideChar);
    procedure PrintKazakhChar(Char: WideChar);
    function IsUserChar(Char: WideChar): Boolean;

    procedure QRCodeSetModuleSize(n: Byte);
    procedure QRCodeSetErrorCorrectionLevel(n: Byte);
    procedure QRCodePrint;
    procedure QRCodeWriteData(Data: AnsiString);
    procedure QRCodeSetModel(n: Byte);

    procedure PDF417SetColumnNumber(n: Byte);
    procedure PDF417SetRowNumber(n: Byte);
    procedure PDF417Print;
    procedure PDF417SetErrorCorrectionLevel(n: Byte);
    procedure PDF417SetModuleHeight(n: Byte);
    procedure PDF417SetModuleWidth(n: Byte);
    procedure PDF417SetOptions(m: Byte);
    procedure PDF417Write(const data: AnsiString);

    procedure PrintUnicode(const AText: WideString);
    class procedure CharacterToCodePage(C: WideChar; var CodePage: Integer);

    property Font: Integer read FFont;
    property Port: IPrinterPort read FPort;
    property Logger: ILogFile read FLogger;
    property CodePage: Integer read FCodePage;
    property DeviceMetrics: TDeviceMetrics read FDeviceMetrics write FDeviceMetrics;
  end;

implementation

const
  CR = #13;
  LF = #10;
  HT = #09;

const
  BoolToInt: array [Boolean] of Integer = (0, 1);

function CharacterSetToPrinterCodePage(CharacterSet: Integer): Integer;
begin
  case CharacterSet of
    437: Result := CODEPAGE_CP437;
    737: Result := CODEPAGE_CP737;
    850: Result := CODEPAGE_CP850;
    852: Result := CODEPAGE_CP852;
    855: Result := CODEPAGE_CP855;
    857: Result := CODEPAGE_CP857;
    858: Result := CODEPAGE_CP858;
    860: Result := CODEPAGE_CP860;
    862: Result := CODEPAGE_CP862;
    863: Result := CODEPAGE_CP863;
    864: Result := CODEPAGE_CP864;
    865: Result := CODEPAGE_CP865;
    //866: Result := CODEPAGE_CP866;
    866: Result := CODEPAGE_KAZAKH;
    1251: Result := CODEPAGE_WCP1251;
    1254: Result := CODEPAGE_WCP1254;
    1255: Result := CODEPAGE_WCP1255;
    1256: Result := CODEPAGE_WCP1256;
    1257: Result := CODEPAGE_WCP1257;
  else
    raise UserException.Create('Character set not supported');
  end;
end;

{ TEscPrinterPosiflex }

constructor TEscPrinterPosiflex.Create(APort: IPrinterPort; ALogger: ILogFile);

  procedure AddKazakhChars(Font: Integer);
  begin
    // 1170, // cyrillic capital letter ghe stroke
    FKazakhChars.Add($DB, WideChar(1170), Font);
    // 1171, // cyrillic small letter ghe stroke
    FKazakhChars.Add($DC, WideChar(1171), Font);
    // 1178, // cyrillic capital letter ka descender
    FKazakhChars.Add($DE, WideChar(1178), Font);
    // 1179, // cyrillic small letter ka descender
    FKazakhChars.Add($DF, WideChar(1179), Font);
    // 1186, // cyrillic capital letter en descender
    FKazakhChars.Add($F0, WideChar(1186), Font);
    // 1187, // cyrillic small letter en descender
    FKazakhChars.Add($F1, WideChar(1187), Font);
    // 1198, // cyrillic capital letter straight u
    FKazakhChars.Add($F7, WideChar(1198), Font);
    // 1199, // cyrillic small letter straight u
    FKazakhChars.Add($F2, WideChar(1199), Font);
    // 1200, // cyrillic capital letter straight u stroke
    FKazakhChars.Add($F5, WideChar(1200), Font);
    // 1201, // cyrillic small letter straight u stroke
    FKazakhChars.Add($F6, WideChar(1201), Font);
    // 1210, // cyrillic capital letter shha
    FKazakhChars.Add($FD, WideChar(1210), Font);
    // 1211, // cyrillic small letter shha
    FKazakhChars.Add($FE, WideChar(1211), Font);
    // 1240, // cyrillic capital letter schwa
    FKazakhChars.Add($B0, WideChar(1240), Font);
    // 1241, // cyrillic small letter schwa
    FKazakhChars.Add($B1, WideChar(1241), Font);
    // 1256, // cyrillic capital letter barred o
    FKazakhChars.Add($F3, WideChar(1256), Font);
    // 1257, // cyrillic small letter barred o
    FKazakhChars.Add($F4, WideChar(1257), Font);
    //1030,  // cyrillic capital letter byelorussian-ukrainian
    FKazakhChars.Add($49, WideChar(1030), Font);
    //1110 // cyrillic small letter byelorussian-ukrainian
    FKazakhChars.Add($69, WideChar(1110), Font);
  end;

begin
  inherited Create;
  FPort := APort;
  FLogger := ALogger;
  FDeviceMetrics.PrintWidth := 576;
  FUserChars := TCharCodes.Create(TCharCode);
  FKazakhChars := TCharCodes.Create(TCharCode);
  AddKazakhChars(FONT_TYPE_A);
  AddKazakhChars(FONT_TYPE_B);
  FFont := FONT_TYPE_A;
end;

destructor TEscPrinterPosiflex.Destroy;
begin
  FUserChars.Free;
  FKazakhChars.Free;
  inherited Destroy;
end;

procedure TEscPrinterPosiflex.Send(const Data: AnsiString);
begin
  FPort.Lock;
  try
    FLogger.Debug('-> ' + StrToHex(Data));
    FPort.Write(Data);
    if not FInTransaction then
    begin
      Port.Flush;
    end;
  finally
    FPort.Unlock;
  end;
end;

procedure TEscPrinterPosiflex.CarriageReturn;
begin
  Send(CR);
end;

procedure TEscPrinterPosiflex.HorizontalTab;
begin
  Send(HT);
end;

procedure TEscPrinterPosiflex.LineFeed;
begin
  Logger.Debug('TEscPrinterPosiflex.LineFeed');
  Send(LF);
end;

function TEscPrinterPosiflex.ReadPrinterStatus: TPrinterStatus;
var
  B: Byte;
begin
  Logger.Debug('TEscPrinterPosiflex.ReadPrinterStatus');
  CheckCapRead;

  FPort.Lock;
  try
    FPort.Purge;
    Send(#$10#$04#$01);
    B := FPort.ReadByte;
    Result.DrawerOpened := TestBit(B, 2);
    Result.IsOnline := not TestBit(B, 3);
  finally
    FPort.Unlock;
  end;
end;

function TEscPrinterPosiflex.ReadOfflineStatus: TOfflineStatus;
var
  B: Byte;
begin
  Logger.Debug('TEscPrinterPosiflex.ReadOfflineStatus');

  CheckCapRead;
  FPort.Lock;
  try
    FPort.Purge;
    Send(#$10#$04#$02);
    B := FPort.ReadByte;
    Result.CoverOpened := TestBit(B, 2);
    Result.FeedButton := TestBit(B, 3);
    Result.ErrorOccurred := TestBit(B, 6);
  finally
    FPort.Unlock;
  end;
end;

function TEscPrinterPosiflex.ReadErrorStatus: TErrorStatus;
var
  B: Byte;
begin
  Logger.Debug('TEscPrinterPosiflex.ReadErrorStatus');

  CheckCapRead;
  FPort.Lock;
  try
    FPort.Purge;
    Send(#$10#$04#$03);
    B := FPort.ReadByte;
    Result.CutterError := TestBit(B, 3);
    Result.UnrecoverableError := TestBit(B, 5);
    Result.AutoRecoverableError := TestBit(B, 6);
  finally
    FPort.Unlock;
  end;
end;

function TEscPrinterPosiflex.ReadPaperStatus: TPaperStatus;
var
  B: Byte;
begin
  Logger.Debug('TEscPrinterPosiflex.ReadPaperStatus');

  CheckCapRead;
  FPort.Lock;
  try
    FPort.Purge;
    Send(#$10#$04#$04);
    B := FPort.ReadByte;
    Result.PaperNearEnd := TestBit(B, 3);
    Result.PaperPresent := not TestBit(B, 5);
  finally
    FPort.Unlock;
  end;
end;

procedure TEscPrinterPosiflex.RecoverError(ClearBuffer: Boolean);
begin
  Logger.Debug('TEscPrinterPosiflex.RecoverError');
  if ClearBuffer then
    Send(#$10#$05#$02)
  else
    Send(#$10#$05#$01);
end;

procedure TEscPrinterPosiflex.GeneratePulse(n, m, t: Byte);
begin
  Logger.Debug('TEscPrinterPosiflex.GeneratePulse');
  Send(#$10#$14 + Chr(n) + Chr(m) + Chr(t));
end;

procedure TEscPrinterPosiflex.SetRightSideCharacterSpacing(n: Byte);
begin
  Logger.Debug('TEscPrinterPosiflex.SetRightSideCharacterSpacing');
  Send(#$1B#$20 + Chr(n));
end;

procedure TEscPrinterPosiflex.SelectPrintMode(Mode: TPrintMode);
begin
  SetPrintMode(PrintModeToByte(Mode));
end;

procedure TEscPrinterPosiflex.SetPrintMode(Mode: Byte);
begin
  Logger.Debug('TEscPrinterPosiflex.SetPrintMode');
  Send(#$1B#$21 + Chr(Mode));

  FFont := FONT_TYPE_A;
  if TestBit(Mode, 0) then
    FFont := FONT_TYPE_B;
end;

procedure TEscPrinterPosiflex.SetAbsolutePrintPosition(n: Word);
begin
  Logger.Debug('TEscPrinterPosiflex.SetAbsolutePrintPosition');
  Send(#$1B#$24 + Chr(Lo(n)) + Chr(Hi(n)));
end;

procedure TEscPrinterPosiflex.SelectUserCharacter(n: Byte);
begin
  if n = FUserCharacterMode then Exit;
  
  Logger.Debug(WideFormat('TEscPrinterPosiflex.SelectUserCharacter(%d)', [n]));
  Send(#$1B#$25 + Chr(n));
  FUserCharacterMode := n;
end;

procedure TEscPrinterPosiflex.EnableUserCharacters;
begin
  SelectUserCharacter(1);
end;

procedure TEscPrinterPosiflex.DisableUserCharacters;
begin
  SelectUserCharacter(0);
end;

procedure TEscPrinterPosiflex.CheckUserCharCode(Code: Byte);
begin
  if (not Code in [USER_CHAR_CODE_MIN..USER_CHAR_CODE_MAX]) then
    raise UserException.CreateFmt('Invalid character code, 0x%.2X', [Code]);
end;

///////////////////////////////////////////////////////////////////////////////
// Font A 12x24, font B 9x17
///////////////////////////////////////////////////////////////////////////////
// The allowable character code range is from ASCII code <20>H to
// <7E>H (95 characters).

procedure TEscPrinterPosiflex.WriteUserChar(AChar: WideChar; ACode, AFont: Byte);
var
  Bitmap: TBitmap;
  UserChar: TUserChar;
begin
  CheckUserCharCode(ACode);
  Bitmap := TBitmap.Create;
  try
    Bitmap.Monochrome := True;
    Bitmap.PixelFormat := pf1Bit;

    if AFont = FONT_TYPE_A then
    begin
      Bitmap.Width := 12;
      Bitmap.Height := 24;
    end else
    begin
      Bitmap.Width := 9;
      Bitmap.Height := 17;
    end;

    DrawWideChar(AChar, AFont, Bitmap, 0, 0);
    //Bitmap.SaveToFile(WideFormat('UnicodeChar_%d_%d.bmp', [AFont, Ord(AChar)]));
    // Write
    UserChar.c1 := ACode;
    UserChar.c2 := ACode;
    UserChar.Font := AFont;
    UserChar.Data := GetBitmapData(Bitmap, Bitmap.Height);
    UserChar.Width := Bitmap.Width;
    DefineUserCharacter(UserChar);
  finally
    Bitmap.Free;
  end;
  FUserChars.Add(ACode, AChar, AFont);
end;

procedure TEscPrinterPosiflex.DrawWideChar(AChar: WideChar; AFont: Byte;
  Bitmap: TBitmap; X, Y: Integer);
begin
  Bitmap.Canvas.Font.Name := 'Courier New';
  //Bitmap.Canvas.Font.Style := Bitmap.Canvas.Font.Style + [fsBold];
  if AFont = FONT_TYPE_A then
  begin
    Bitmap.Canvas.Font.Size := 16;
  end else
  begin
    Bitmap.Canvas.Font.Size := 14;
  end;
  TntGraphics.WideCanvasTextOut(Bitmap.Canvas, X, Y, AChar);
end;

procedure TEscPrinterPosiflex.WriteUserChar2(AChar: WideChar; ACode, AFont: Byte);
var
  Bitmap: TBitmap;
  FileName: string;
  UserChar: TUserChar;
begin
  CheckUserCharCode(ACode);
  Bitmap := TBitmap.Create;
  try
    FileName := GetModulePath + WideFormat('UserChars\UnicodeChar_%d_%d.bmp', [AFont, Ord(AChar)]);
    Bitmap.LoadFromFile(FileName);
    // Write
    UserChar.c1 := ACode;
    UserChar.c2 := ACode;
    UserChar.Font := AFont;
    UserChar.Data := GetBitmapData(Bitmap, Bitmap.Height);
    UserChar.Width := Bitmap.Width;
    DefineUserCharacter(UserChar);
  finally
    Bitmap.Free;
  end;
  FUserChars.Add(ACode, AChar, AFont);
end;

(*
y = 3
32 c1 c2 126
0 �T x �T 12 (when Font A (12X24) is
selected) 0 �T x �T 9 (when Font B (9X17) is
selected)

*)

procedure TEscPrinterPosiflex.DefineUserCharacter(C: TUserChar);
begin
  Logger.Debug('TEscPrinterPosiflex.DefineUserCharacter');
  Send(#$1B#$26#$03 + Chr(C.c1) + Chr(C.c2) + Chr(C.Width) + C.Data);
end;

function TEscPrinterPosiflex.GetFontData(Bitmap: TBitmap): AnsiString;
var
  B: Byte;
  Bit: Byte;
  x, y: Integer;
begin
  Result := '';
  for x := 1 to Bitmap.Width do
  begin
    B := 0;
    for y := 1 to Bitmap.Height do
    begin
      Bit := (y-1) mod 8;
      if Bitmap.Canvas.Pixels[x, y] = clBlack then
      begin
        SetBit(B, 7-Bit);
      end;
      if (y mod 8) = 0 then
      begin
        Result := Result + Chr(B);
        B := 0;
      end;
    end;
    if (Bitmap.Height mod 8) <> 0 then
    begin
      Result := Result + Chr(B);
    end;
  end;
end;

procedure TEscPrinterPosiflex.SelectBitImageMode(mode: Integer; Image: TGraphic);
var
  n: Word;
  data: AnsiString;
begin
  Logger.Debug('TEscPrinterPosiflex.SelectBitImageMode');

  n := Image.Width;
  data := GetImageData2(Image);
  Send(#$1B#$2A + Chr(Mode) + Chr(Lo(n)) + Chr(Hi(n)) + data);
end;

procedure TEscPrinterPosiflex.SetUnderlineMode(n: Byte);
begin
  Logger.Debug('TEscPrinterPosiflex.SetUnderlineMode');
  Send(#$1B#$2D + Chr(n));
end;

procedure TEscPrinterPosiflex.SetDefaultLineSpacing;
begin
  Logger.Debug('TEscPrinterPosiflex.SetDefaultLineSpacing');
  Send(#$1B#$32);
end;


procedure TEscPrinterPosiflex.SetLineSpacing(n: Byte);
begin
  Logger.Debug('TEscPrinterPosiflex.SetLineSpacing');
  Send(#$1B#$33 + Chr(n));
end;

procedure TEscPrinterPosiflex.CancelUserCharacter(n: Byte);
begin
  Logger.Debug('TEscPrinterPosiflex.CancelUserCharacter');
  Send(#$1B#$3F + Chr(n));
end;

procedure TEscPrinterPosiflex.Initialize;
begin
  Logger.Debug('TEscPrinterPosiflex.Initialize');
  Send(#$1B#$40);
  FCodePage := 0;
  FUserChars.Clear;
  FUserCharacterMode := 0;
  FInTransaction := False;
  FFont := FONT_TYPE_A;
end;

procedure TEscPrinterPosiflex.SetBeepParams(N, T: Byte);
begin
  Logger.Debug('TEscPrinterPosiflex.SetBeepParams');
  Send(#$1B#$42 + Chr(N) + Chr(T));
end;

procedure TEscPrinterPosiflex.SetHorizontalTabPositions(Tabs: AnsiString);
begin
  Logger.Debug('TEscPrinterPosiflex.SetHorizontalTabPositions');
  Send(#$1B#$44 + Tabs + #0);
end;

procedure TEscPrinterPosiflex.SetEmphasizedMode(Value: Boolean);
begin
  Logger.Debug('TEscPrinterPosiflex.SetEmphasizedMode');
  Send(#$1B#$45 + Chr(BoolToInt[Value]));
end;

procedure TEscPrinterPosiflex.SetDoubleStrikeMode(Value: Boolean);
begin
  Logger.Debug('TEscPrinterPosiflex.SetDoubleStrikeMode');
  Send(#$1B#$47 + Chr(BoolToInt[Value]));
end;

procedure TEscPrinterPosiflex.PrintAndFeed(n: Byte);
begin
  Logger.Debug('TEscPrinterPosiflex.PrintAndFeed');
  Send(#$1B#$4A + Chr(n));
end;

procedure TEscPrinterPosiflex.SetCharacterFont(n: Byte);
begin
  Logger.Debug('TEscPrinterPosiflex.SetCharacterFont');
  if n = FFont then Exit;
  if n in [FONT_TYPE_MIN..FONT_TYPE_MAX] then
  begin
    Send(#$1B#$4D + Chr(n));
    FFont := n;
  end;
end;

procedure TEscPrinterPosiflex.SetCharacterSet(N: Byte);
begin
  Logger.Debug('TEscPrinterPosiflex.SetCharacterSet');
  Send(#$1B#$52 + Chr(N));
end;

procedure TEscPrinterPosiflex.Set90ClockwiseRotation(Value: Boolean);
begin
  Logger.Debug('TEscPrinterPosiflex.Set90ClockwiseRotation');
  Send(#$1B#$56 + Chr(BoolToInt[Value]));
end;

procedure TEscPrinterPosiflex.SetRelativePrintPosition(n: Word);
begin
  Logger.Debug('TEscPrinterPosiflex.SetRelativePrintPosition');
  Send(#$1B#$5C + Chr(Lo(n)) + Chr(Hi(n)));
end;

procedure TEscPrinterPosiflex.SetJustification(N: Byte);
begin
  Logger.Debug('TEscPrinterPosiflex.SetJustification');
  Send(#$1B#$61 + Chr(N));
end;

procedure TEscPrinterPosiflex.EnableButtons(Value: Boolean);
begin
  Logger.Debug('TEscPrinterPosiflex.EnableButtons');
  Send(#$1B#$63#$35 + Chr(BoolToInt[Value]));
end;

procedure TEscPrinterPosiflex.PrintAndFeedLines(N: Byte);
begin
  Logger.Debug('TEscPrinterPosiflex.PrintAndFeedLines');
  Send(#$1B#$64 + Chr(N));
end;

procedure TEscPrinterPosiflex.SetCodePage(CodePage: Integer);
begin
  if FCodePage = CodePage then Exit;

  Logger.Debug(WideFormat('TEscPrinterPosiflex.SetCodePage(%d)', [CodePage]));
  Send(#$1B#$74 + Chr(CodePage));
  FCodePage := CodePage;
end;

procedure TEscPrinterPosiflex.SetUpsideDownPrinting(Value: Boolean);
begin
  Logger.Debug('TEscPrinterPosiflex.SetUpsideDownPrinting');
  Send(#$1B#$7B + Chr(BoolToInt[Value]));
end;

procedure TEscPrinterPosiflex.PartialCut;
begin
  Logger.Debug('TEscPrinterPosiflex.PartialCut');
  Send(#$1B#$69);
end;

procedure TEscPrinterPosiflex.PartialCut2;
begin
  Logger.Debug('TEscPrinterPosiflex.PartialCut2');
  Send(#$1B#$6D);
end;

procedure TEscPrinterPosiflex.SelectChineseCode(N: Byte);
begin
  Logger.Debug('TEscPrinterPosiflex.SelectChineseCode');
  Send(#$1B#$39 + Chr(N));
end;

procedure TEscPrinterPosiflex.PrintNVBitImage(Number, Mode: Byte);
begin
  Logger.Debug('TEscPrinterPosiflex.PrintNVBitImage');
  Send(#$1C#$70 + Chr(Number) + Chr(Mode));
end;

procedure TEscPrinterPosiflex.DefineNVBitImage(Number: Byte; Image: TGraphic);
var
  x, y: Integer;
  Bitmap: TBitmap;
begin
  Logger.Debug('TEscPrinterPosiflex.DefineNVBitImage');

  Bitmap := TBitmap.Create;
  try
    DrawImage(Image, Bitmap);

    x := (Bitmap.Width + 7) div 8;
    y := (Bitmap.Height + 7) div 8;
    Send(#$1C#$71 + Chr(Number) + Chr(Lo(x)) + Chr(Hi(x)) +
      Chr(Lo(y)) + Chr(Hi(y)) + GetBitmapData(Bitmap, Bitmap.Height));
  finally
    Bitmap.Free;
  end;
end;

procedure TEscPrinterPosiflex.SetCharacterSize(N: Byte);
begin
  Logger.Debug('TEscPrinterPosiflex.SetCharacterSize');
  Send(#$1D#$21 + Chr(N));
end;

procedure TEscPrinterPosiflex.DownloadBMP(Image: TGraphic);
var
  x, y: Byte;
  Bitmap: TBitmap;
begin
  Logger.Debug('TEscPrinterPosiflex.DownloadBMP');
  Bitmap := TBitmap.Create;
  try
    DrawImage(Image, Bitmap);

    x := (Bitmap.Width + 7) div 8;
    y := (Bitmap.Height + 7) div 8;
    Send(#$1D#$2A + Chr(x) + Chr(y) + GetBitmapData(Bitmap, Bitmap.Height));
  finally
    Bitmap.Free;
  end;
end;

procedure TEscPrinterPosiflex.PrintBmp(Mode: Byte);
begin
  Logger.Debug('TEscPrinterPosiflex.PrintBmp');
  Send(#$1D#$2F + Chr(Mode));
end;

procedure TEscPrinterPosiflex.SetWhiteBlackReverse(Value: Boolean);
begin
  Logger.Debug('TEscPrinterPosiflex.SetWhiteBlackReverse');
  Send(#$1D#$42 + Chr(BoolToInt[Value]));
end;

function TEscPrinterPosiflex.ReadPrinterIDInt(N: Byte): Integer;
begin
  Logger.Debug('TEscPrinterPosiflex.ReadPrinterIDInt');

  CheckCapRead;
  FPort.Lock;
  try
    FPort.Purge;
    Send(#$1D#$49 + Chr(N));
    Result := FPort.ReadByte;
  finally
    FPort.Unlock;
  end;
end;

function TEscPrinterPosiflex.ReadPrinterID(N: Byte): AnsiString;
begin
  Logger.Debug('TEscPrinterPosiflex.ReadPrinterID');

  CheckCapRead;
  FPort.Lock;
  try
    FPort.Purge;
    Send(#$1D#$49 + Chr(N));
    Result := FPort.ReadString;
    Result := TrimRight(Copy(Result, 2, Length(Result)));
  finally
    FPort.Unlock;
  end;
end;

function TEscPrinterPosiflex.ReadFirmwareVersion: AnsiString;
begin
  Logger.Debug('TEscPrinterPosiflex.ReadFirmwareVersion');
  CheckCapRead;
  Result := ReadPrinterID(65);
end;

function TEscPrinterPosiflex.ReadManufacturer: AnsiString;
begin
  Logger.Debug('TEscPrinterPosiflex.ReadManufacturer');
  CheckCapRead;
  Result := ReadPrinterID(66);
end;

function TEscPrinterPosiflex.ReadPrinterName: AnsiString;
begin
  Logger.Debug('TEscPrinterPosiflex.ReadPrinterName');
  CheckCapRead;
  Result := ReadPrinterID(67);
end;

function TEscPrinterPosiflex.ReadSerialNumber: AnsiString;
begin
  Logger.Debug('TEscPrinterPosiflex.ReadSerialNumber');
  CheckCapRead;
  Result := ReadPrinterID(68);
end;

procedure TEscPrinterPosiflex.SetHRIPosition(N: Byte);
begin
  Logger.Debug('TEscPrinterPosiflex.SetHRIPosition');
  Send(#$1D#$48 + Chr(N));
end;

procedure TEscPrinterPosiflex.SetLeftMargin(N: Word);
begin
  Logger.Debug('TEscPrinterPosiflex.SetLeftMargin');
  Send(#$1D#$4C + Chr(Lo(N)) + Chr(Hi(N)));
end;

procedure TEscPrinterPosiflex.SetCutModeAndCutPaper(M: Byte);
begin
  Logger.Debug('TEscPrinterPosiflex.SetCutModeAndCutPaper');
  Send(#$1D#$56 + Chr(M));
end;

procedure TEscPrinterPosiflex.SetCutModeAndCutPaper2(n: Byte);
begin
  Logger.Debug('TEscPrinterPosiflex.SetCutModeAndCutPaper2');
  Send(#$1D#$56#$66 + Chr(n));
end;

procedure TEscPrinterPosiflex.SetPrintAreaWidth(n: Byte);
begin
  Logger.Debug('TEscPrinterPosiflex.SetPrintAreaWidth');
  Send(#$1D#$57 + Chr(Lo(n)) + Chr(Hi(n)));
end;

procedure TEscPrinterPosiflex.StartEndMacroDefinition;
begin
  Logger.Debug('TEscPrinterPosiflex.StartEndMacroDefinition');
  Send(#$1D#$3A);
end;

procedure TEscPrinterPosiflex.ExecuteMacro(r, t, m: Byte);
begin
  Logger.Debug('TEscPrinterPosiflex.ExecuteMacro');
  Send(#$1D#$5E + Chr(r) + Chr(t) + Chr(m));
end;

procedure TEscPrinterPosiflex.EnableAutomaticStatusBack(N: Byte);
begin
  Logger.Debug('TEscPrinterPosiflex.EnableAutomaticStatusBack');
  Send(#$1D#$61 + Chr(N));
end;

procedure TEscPrinterPosiflex.SetHRIFont(N: Byte);
begin
  Logger.Debug('TEscPrinterPosiflex.SetHRIFont');
  Send(#$1D#$66 + Chr(N));
end;

procedure TEscPrinterPosiflex.SetBarcodeHeight(N: Byte);
begin
  Logger.Debug('TEscPrinterPosiflex.SetBarcodeHeight');
  Send(#$1D#$68 + Chr(N));
end;

procedure TEscPrinterPosiflex.PrintBarcode(BCType: Byte; const Data: AnsiString);
begin
  Logger.Debug('TEscPrinterPosiflex.PrintBarcode');
  Send(#$1D#$6B + Chr(BCType) + Data + #0);
end;

procedure TEscPrinterPosiflex.PrintBarcode2(BCType: Byte; const Data: AnsiString);
begin
  Logger.Debug('TEscPrinterPosiflex.PrintBarcode2');
  Send(#$1D#$6B + Chr(BCType) + Chr(Length(Data)) + Data);
end;

function TEscPrinterPosiflex.ReadPaperRollStatus: TPaperRollStatus;
begin
  Logger.Debug('TEscPrinterPosiflex.ReadPaperRollStatus');

  CheckCapRead;
  FPort.Lock;
  try
    FPort.Purge;
    Send(#$1D#$72#$01);
    Result.PaperNearEnd := TestBit(FPort.ReadByte, 2);
  finally
    FPort.Unlock;
  end;
end;

// Print raster bit image
procedure TEscPrinterPosiflex.PrintRasterBMP(Mode: Byte; Image: TGraphic);
var
  x, y: Byte;
begin
  Logger.Debug('TEscPrinterPosiflex.PrintRasterBMP');

  x := (Image.Width + 7) div 8;
  y := Image.Height;
  Send(#$1D#$76#$30 + Chr(Mode) + Chr(Lo(x)) + Chr(Hi(x)) +
    Chr(Lo(y)) + Chr(Hi(y)) + GetRasterImageData(Image));
end;

procedure TEscPrinterPosiflex.SetBarcodeWidth(N: Integer);
begin
  Logger.Debug('TEscPrinterPosiflex.SetBarcodeWidth');
  Send(#$1D#$77 + Chr(N));
end;

procedure TEscPrinterPosiflex.SetBarcodeLeft(N: Integer);
begin
  Logger.Debug('TEscPrinterPosiflex.SetBarcodeLeft');
  Send(#$1D#$78 + Chr(N));
end;

procedure TEscPrinterPosiflex.SetMotionUnits(x, y: Integer);
begin
  Logger.Debug('TEscPrinterPosiflex.SetMotionUnits');
  Send(#$1D#$50 + Chr(x) + Chr(y));
end;

procedure TEscPrinterPosiflex.PrintTestPage;
begin
  Logger.Debug('TEscPrinterPosiflex.PrintTestPage');
  Send(#$12#$54);
end;

procedure TEscPrinterPosiflex.SetKanjiMode(m: Byte);
begin
  Logger.Debug('TEscPrinterPosiflex.SetKanjiMode');
  Send(#$1C#$21 + Chr(m));
end;

procedure TEscPrinterPosiflex.SelectKanjiCharacter;
begin
  Logger.Debug('TEscPrinterPosiflex.SelectKanjiCharacter');
  Send(#$1C#$26);
end;

procedure TEscPrinterPosiflex.SetKanjiUnderline(Value: Boolean);
begin
  Logger.Debug('TEscPrinterPosiflex.SetKanjiUnderline');
  Send(#$1C#$2D + Chr(BoolToInt[Value]));
end;

procedure TEscPrinterPosiflex.CancelKanjiCharacter;
begin
  Logger.Debug('TEscPrinterPosiflex.CancelKanjiCharacter');
  Send(#$1C#$2E);
end;

procedure TEscPrinterPosiflex.DefineKanjiCharacters(c1, c2: Byte;
  const data: AnsiString);
begin
  Logger.Debug('TEscPrinterPosiflex.DefineKanjiCharacters');
  Send(#$1C#$32 + Chr(c1) + Chr(c2) + data);
end;

procedure TEscPrinterPosiflex.SetPeripheralDevice(m: Byte);
begin
  Logger.Debug('TEscPrinterPosiflex.SetPeripheralDevice');
  Send(#$1B#$3D + Chr(m));
end;

procedure TEscPrinterPosiflex.SetKanjiSpacing(n1, n2: Byte);
begin
  Logger.Debug('TEscPrinterPosiflex.SetKanjiSpacing');
  Send(#$1C#$53 + Chr(n1) + Chr(n2));
end;

procedure TEscPrinterPosiflex.PrintAndReturnStandardMode;
begin
  Logger.Debug('TEscPrinterPosiflex.PrintAndReturnStandardMode');
  Send(#$0C);
end;

procedure TEscPrinterPosiflex.PrintDataInMode;
begin
  Logger.Debug('TEscPrinterPosiflex.PrintDataInMode');
  Send(#$1B#$0C);
end;

procedure TEscPrinterPosiflex.SetPageMode;
begin
  Logger.Debug('TEscPrinterPosiflex.SetPageMode');
  Send(#$1B#$4C);
end;

procedure TEscPrinterPosiflex.SetStandardMode;
begin
  Logger.Debug('TEscPrinterPosiflex.SetStandardMode');
  Send(#$1B#$53);
end;

procedure TEscPrinterPosiflex.SetPageModeDirection(n: Byte);
begin
  Logger.Debug('TEscPrinterPosiflex.SetPageModeDirection');
  Send(#$1B#$54 + Chr(n));
end;

procedure TEscPrinterPosiflex.SetPageModeArea(R: TPageArea);
begin
  Logger.Debug(WideFormat('TEscPrinterPosiflex.SetPageModeArea(%d,%d,%d,%d)', [
    R.X, R.Y, R.Width, R.Height]));

  Send(#$1B#$57 +
    Chr(Lo(R.X)) + Chr(Hi(R.X)) +
    Chr(Lo(R.Y)) + Chr(Hi(R.Y)) +
    Chr(Lo(R.Width)) + Chr(Hi(R.Width)) +
    Chr(Lo(R.Height)) + Chr(Hi(R.Height)));
end;

(*
PDF417:barcode type0
m specifies column number of 2D barcode.(1.m.30)
n specifies security level to restore when barcode image
is damaged.(0.n.8)
k is used for define horizontal and vertical ratio.( 2.k.5)
d is the length of data
*)

procedure TEscPrinterPosiflex.printPDF417(const Barcode: TPDF417);
begin
  Logger.Debug('TEscPrinterPosiflex.printPDF417');
  PDF417SetColumnNumber(Barcode.ColumnNumber);
  PDF417SetRowNumber(Barcode.RowNumber);
  PDF417SetModuleWidth(Barcode.ModuleWidth);
  PDF417SetModuleHeight(Barcode.ModuleHeight);
  PDF417SetErrorCorrectionLevel(Barcode.ErrorCorrectionLevel);
  PDF417SetOptions(Barcode.Options);
  PDF417Write(Barcode.Data);
  PDF417Print;
end;

///////////////////////////////////////////////////////////////////////////////
// 0 <= n <= 30
procedure TEscPrinterPosiflex.PDF417SetColumnNumber(n: Byte);
begin
  if n > 30 then n := 30;
  Send(#$1D#$28#$6B#$03#$00#$30#$41 + Chr(n));
end;

///////////////////////////////////////////////////////////////////////////////
// 3 <= n <= 90, n = 0
procedure TEscPrinterPosiflex.PDF417SetRowNumber(n: Byte);
begin
  if (n in [1..2])or(n > 90) then n := 0;
  Send(#$1D#$28#$6B#$03#$00#$30#$42 + Chr(n));
end;

procedure TEscPrinterPosiflex.PDF417SetModuleWidth(n: Byte);
begin
  Send(#$1D#$28#$6B#$03#$00#$30#$43 + Chr(n));
end;

procedure TEscPrinterPosiflex.PDF417SetModuleHeight(n: Byte);
begin
  Send(#$1D#$28#$6B#$03#$00#$30#$44 + Chr(n));
end;

// n 0..8
procedure TEscPrinterPosiflex.PDF417SetErrorCorrectionLevel(n: Byte);
begin
  if N > 8 then n := 8;
  Send(#$1D#$28#$6B#$03#$00#$30#$45#$30 + Chr($30 + n));
end;

procedure TEscPrinterPosiflex.PDF417SetOptions(m: Byte);
begin
  Send(#$1D#$28#$6B#$03#$00#$30#$46 + Chr(m));
end;

procedure TEscPrinterPosiflex.PDF417Write(const data: AnsiString);
var
  L: Word;
begin
  L := Length(Data) + 3;
  Send(#$1D#$28#$6B + Chr(Lo(L)) + Chr(Hi(L)) + #$30#$50#$30 + Data);
end;

procedure TEscPrinterPosiflex.PDF417Print;
begin
  Send(#$1D#$28#$6B#$03#$00#$30#$51#$30);
end;

procedure TEscPrinterPosiflex.printQRCode(const Barcode: TQRCode);
begin
  Logger.Debug('TEscPrinterPosiflex.printQRCode');
  QRCodeSetModel(Barcode.Model);
  QRCodeSetErrorCorrectionLevel(Barcode.ECLevel);
  QRCodeSetModuleSize(Barcode.ModuleSize);
  QRCodeWriteData(Barcode.Data);
  QRCodePrint;
end;

procedure TEscPrinterPosiflex.QRCodeSetModel(n: Byte);
begin
  Logger.Debug(WideFormat('TEscPrinterPosiflex.QRCodeSetModel(%d)', [n]));

  if n < 1 then n := 1;
  if n > 2 then n := 2;
  Send(#$1D#$28#$6B#$04#$00#$31#$41 + Chr($30 + n) + #$00);
end;

procedure TEscPrinterPosiflex.QRCodeSetErrorCorrectionLevel(n: Byte);
begin
  Logger.Debug(WideFormat('TEscPrinterPosiflex.QRCodeSetErrorCorrectionLevel(%d)', [n]));

  if n > 3 then n := 3;
  Send(#$1D#$28#$6B#$04#$00#$31#$45 + Chr($30 + n));
end;

procedure TEscPrinterPosiflex.QRCodeSetModuleSize(n: Byte);
begin
  Logger.Debug(WideFormat('TEscPrinterPosiflex.QRCodeSetModuleSize(%d)', [n]));

  if n < 1 then n := 1;
  if n > 16 then n := 16;
  Send(#$1D#$28#$6B#$04#$00#$31#$43 + Chr(n) + #$00);
end;

procedure TEscPrinterPosiflex.QRCodeWriteData(Data: AnsiString);
var
  k: Integer;
begin
  Logger.Debug(WideFormat('TEscPrinterPosiflex.QRCodeWriteData(''%s'')', [Data]));

  k := Length(Data) + 3;
  Send(#$1D#$28#$6B + Chr(Lo(k)) + Chr(Hi(k)) + #$31#$50#$30 + Data);
end;

procedure TEscPrinterPosiflex.QRCodePrint;
begin
  Logger.Debug('TEscPrinterPosiflex.QRCodePrint');
  Send(#$1D#$28#$6B#$03#$00#$31#$51#$30);
end;

procedure TEscPrinterPosiflex.SetKanjiQuadSizeMode(Value: Boolean);
begin
  Logger.Debug('TEscPrinterPosiflex.SetKanjiQuadSizeMode');
  Send(#$1C#$57 + Chr(BoolToInt[Value]));
end;

procedure TEscPrinterPosiflex.FeedMarkedPaper;
begin
  Logger.Debug('TEscPrinterPosiflex.FeedMarkedPaper');
  Send(#$1D#$0C);
end;

procedure TEscPrinterPosiflex.SetPMAbsoluteVerticalPosition(n: Integer);
begin
  Logger.Debug('TEscPrinterPosiflex.SetPMAbsoluteVerticalPosition');
  Send(#$1D#$24 + Chr(Lo(n)) + Chr(Hi(n)));
end;

procedure TEscPrinterPosiflex.ExecuteTestPrint(p: Integer; n, m: Byte);
begin
  Logger.Debug('TEscPrinterPosiflex.ExecuteTestPrint');
  Send(#$1D#$28#$41 + Chr(Lo(p)) + Chr(Hi(p)) + Chr(n) + Chr(m));
end;

procedure TEscPrinterPosiflex.SelectCounterPrintMode(n, m: Byte);
begin
  Logger.Debug('TEscPrinterPosiflex.SelectCounterPrintMode');
  Send(#$1D#$43#$30 + Chr(n) + Chr(m));
end;

procedure TEscPrinterPosiflex.SelectCountMode(a, b: Word; n, r: Byte);
begin
  Logger.Debug('TEscPrinterPosiflex.SelectCountMode');
  Send(#$1D#$43#$31 + Chr(Lo(a)) + Chr(Hi(a)) +
    Chr(Lo(b)) + Chr(Hi(b)) + Chr(n) + Chr(r));
end;

procedure TEscPrinterPosiflex.SetCounter(n: Word);
begin
  Logger.Debug('TEscPrinterPosiflex.SetCounter');
  Send(#$1D#$43#$32 + Chr(Lo(n)) + Chr(Hi(n)));
end;

procedure TEscPrinterPosiflex.SetPMRelativeVerticalPosition(n: Word);
begin
  Logger.Debug('TEscPrinterPosiflex.SetPMRelativeVerticalPosition');
  Send(#$1D#$5C + Chr(Lo(n)) + Chr(Hi(n)));
end;

procedure TEscPrinterPosiflex.PrintCounter;
begin
  Logger.Debug('TEscPrinterPosiflex.PrintCounter');
  Send(#$1D#$63);
end;

procedure TEscPrinterPosiflex.SetNormalPrintMode;
var
  PrintMode: TPrintMode;
begin
  Logger.Debug('TEscPrinterPosiflex.SetNormalPrintMode');
  PrintMode.CharacterFontB := False;
  PrintMode.Emphasized := False;
  PrintMode.DoubleHeight := False;
  PrintMode.DoubleWidth := False;
  PrintMode.Underlined := False;
  SelectPrintMode(PrintMode);
end;

procedure TEscPrinterPosiflex.PrintText(Text: AnsiString);
begin
  //Logger.Debug(WideFormat('TEscPrinterPosiflex.PrintText(''%s'')', [TrimRight(Text)]));
  Send(Text);
end;

function TEscPrinterPosiflex.CapRead: Boolean;
begin
  Result := Port.CapRead;
end;

procedure TEscPrinterPosiflex.CheckCapRead;
begin
  if not Port.CapRead then
  begin
    raise UserException.Create(SReadNotSupported);
  end;
end;

procedure TEscPrinterPosiflex.BeginDocument;
begin
  FInTransaction := True;
end;

procedure TEscPrinterPosiflex.EndDocument;
begin
  FInTransaction := False;
  Port.Flush;
end;

procedure TEscPrinterPosiflex.WriteKazakhCharacters;
var
  i: Integer;
  Code: Byte;
  Count: Integer;
  Bitmap: TBitmap;
  Data: AnsiString;
  FontWidth: Integer;
  BitmapData: AnsiString;
  FontFileName: WideString;
begin
  Code := USER_CHAR_CODE_MIN;
  try
    EnableUserCharacters;
    Bitmap := TBitmap.Create;
    try
      // FONT_TYPE_A
      FontFileName := GetModulePath + 'Fonts\KazakhFontA.bmp';
      if FileExists(FontFileName) then
      begin
        SetCharacterFont(FONT_TYPE_A);
        Bitmap.LoadFromFile(FontFileName);
        FontWidth := 12;
        Count := Bitmap.Width div FontWidth;
        Data := GetBitmapData(Bitmap, 24);
        for i := 0 to Count-1 do
        begin
          FUserChars.Add(Code + i, WideChar(KazakhUnicodeChars[i]), FONT_TYPE_A);
          BitmapData := Chr(FontWidth) + Copy(Data, i*FontWidth*3 + 1, FontWidth*3);
          Send(#$1B#$26#$03 + Chr(Code + i) + Chr(Code + i) + BitmapData);
        end;
        Inc(Code, Count);
      end;
      // FONT_TYPE_B
      FontFileName := GetModulePath + 'Fonts\KazakhFontB.bmp';
      if FileExists(FontFileName) then
      begin
        SetCharacterFont(FONT_TYPE_B);
        Bitmap.LoadFromFile(FontFileName);
        FontWidth := 9;
        Count := Bitmap.Width div FontWidth;
        Data := GetBitmapData(Bitmap, 16);
        for i := 0 to Count-1 do
        begin
          FUserChars.Add(Code + i, WideChar(KazakhUnicodeChars[i]), FONT_TYPE_B);
          BitmapData := Chr(FontWidth) + Copy(Data, i*FontWidth*3 + 1, (FontWidth-1)*3);
          Send(#$1B#$26#$03 + Chr(Code + i) + Chr(Code + i) + BitmapData);
        end;
      end;
    finally
      Bitmap.Free;
    end;
    DisableUserCharacters;
  except
    on E: Exception do
    begin
      FLogger.Error('Failed to load Kazakh fonts ' + E.Message);
    end;
  end;
end;

function TEscPrinterPosiflex.IsUserChar(Char: WideChar): Boolean;
begin
  Result := IsKazakhUnicodeChar(Char);
end;

procedure TEscPrinterPosiflex.PrintUserChar(Char: WideChar);
var
  Item: TCharCode;
begin
  Item := FUserChars.ItemByChar(Char, Font);
  if Item <> nil then
  begin
    EnableUserCharacters;
    PrintText(Chr(Item.Code));
  end;
end;

procedure TEscPrinterPosiflex.PrintKazakhChar(Char: WideChar);
var
  Item: TCharCode;
begin
  Item := FKazakhChars.ItemByChar(Char, Font);
  if Item <> nil then
  begin
    SetCodePage(CODEPAGE_KAZAKH);
    PrintText(Chr(Item.Code));
  end;
end;

function TestCodePage(S: WideString; CodePage: Integer): Boolean;
var
  P: PAnsiChar;
  Count: Integer;
  UsedDefaultChar: BOOL;
const
  DefaultChar: PAnsiChar = '?';
begin
  ODS('TestCharCodePage. CodePage: ' + IntToStr(CodePage));
  Count := WideCharToMultiByte(CodePage, 0, PWideChar(S), Length(S), nil, 0,
    nil, nil);
  if Count > 0 then
  begin
    P := AllocMem(Count);
    Count := WideCharToMultiByte(CodePage, 0, PWideChar(S), Length(S),
      P, Count, DefaultChar, @UsedDefaultChar);
    FreeMem(P);
  end;
  Result := (Count > 0) and(not UsedDefaultChar);
end;

class procedure TEscPrinterPosiflex.CharacterToCodePage(C: WideChar;
  var CodePage: Integer);
var
  i: Integer;
begin
  if TestCodePage(C, CodePage) then Exit;
  for i := Low(SupportedCodePages) to High(SupportedCodePages) do
  begin
    CodePage := SupportedCodePages[i];
    if TestCodePage(C, CodePage) then Exit;
  end;
  CodePage := 1251;
end;


procedure TEscPrinterPosiflex.PrintUnicode(const AText: WideString);
var
  i: Integer;
  C: WideChar;
  CodePage: Integer;
begin
  CodePage := 1251;
  if TestCodePage(AText, CodePage) then
  begin
    Logger.Debug(WideFormat('TPosPrinterPosiflex.PrintText(''%s'')', [AText]));
    SetCodePage(CharacterSetToPrinterCodePage(CodePage));
    PrintText(WideStringToAnsiString(CodePage, AText));
  end else
  begin
    for i := 1 to Length(AText) do
    begin
      C := AText[i];
      Logger.Debug(WideFormat('TPosPrinterPosiflex.PrintChar(''%s'')', [C]));
      if IsKazakhUnicodeChar(C) then
      begin
        PrintKazakhChar(C);
      end else
      begin
        CharacterToCodePage(C, CodePage);
        SetCodePage(CharacterSetToPrinterCodePage(CodePage));
        PrintText(WideStringToAnsiString(CodePage, C));
      end;
    end;
  end;
end;

(*
1D 67 34 10 - Hous powered
1D 67 34 15 - Cut paper count
1D 67 34 09 - Install date
1D 67 34 16 - Failed paper cut
1D 67 34 1B - Line printed
1D 67 34 05 - Serial number
1D 67 34 24 - Language model
1D 67 34 21 - Code page
1D 67 34 22 - Character set

1D 67 34 27 - SW1
1D 67 34 28 - SW2
1D 67 34 29 - SW3
1D 67 34 2A - SW4
1D 67 34 2B - SW5
*)

function TEscPrinterPosiflex.ReadParam(N: Byte): AnsiString;
begin
  Logger.Debug('TEscPrinterPosiflex.ReadParam');

  CheckCapRead;
  FPort.Lock;
  try
    FPort.Purge;
    Send(#$1D#$67#$34 + Chr(N));
    Result := FPort.ReadString;
    Result := Copy(Result, 2, Length(Result));
  finally
    FPort.Unlock;
  end;
end;

end.

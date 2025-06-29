unit EscPrinterOA48;

interface

uses
  // VCL
  Windows, Types, SysUtils, Graphics, Classes,
  // Tnt
  TntGraphics,
  // This
  ByteUtils, PrinterPort, RegExpr, StringUtils, LogFile, FileUtils,
  EscPrinterUtils, CharCode, UserError, StringConst;

const
  /////////////////////////////////////////////////////////////////////////////
  // Supported code pages

  SupportedCodePagesB: array [0..11] of Integer = (
    866,437,850,852,858,860,863,865,997,998,
    999,1252);

  SupportedCodePagesA: array [0..28] of Integer =
  ( 866,437,737,747,772,774,850,851,852,855,857,
    858,860,861,862,863,864,865,869,874,
    928,997,998,999,1250,1252,1255,1256,1257);

  /////////////////////////////////////////////////////////////////////////////
  // QRCode error correction level

  OA48_QRCODE_ECL_7   = $48;
  OA48_QRCODE_ECL_15  = $49;
  OA48_QRCODE_ECL_25  = $50;
  OA48_QRCODE_ECL_30  = $51;

  ESC   = #$1B;
  CRLF  = #13#10;

  /////////////////////////////////////////////////////////////////////////////
  // The allowable character code range is from ASCII code <20>H to
  // <7E>H (95 characters).

  USER_CHAR_CODE_MIN = $20;
  USER_CHAR_CODE_MAX = $7E;

  /////////////////////////////////////////////////////////////////////////////
  // Font type

  FONT_TYPE_A = 0; // 12x24
  FONT_TYPE_B = 1; // 9x17

  FONT_TYPE_MIN = FONT_TYPE_A;
  FONT_TYPE_MAX = FONT_TYPE_B;

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
  CHARSET_SLOVENIA_CROATIA = 14;
  CHARSET_CHINA           = 15;

  /////////////////////////////////////////////////////////////////////////////
  // Justification constants

  JUSTIFICATION_LEFT      = 0;
  JUSTIFICATION_CENTER    = 1;
  JUSTIFICATION_RIGHT     = 2;

  /////////////////////////////////////////////////////////////////////////////
  // Codepage constants

  CODEPAGE_CP437              = 0;
  CODEPAGE_KATAKANA           = 1;
  CODEPAGE_CP850              = 2;
  CODEPAGE_CP860              = 3;
  CODEPAGE_CP863              = 4; // CANADIAN-FRENCH
  CODEPAGE_CP865              = 5;
  CODEPAGE_WEST_EUROPE        = 6;
  CODEPAGE_GREEK              = 7;
  CODEPAGE_HEBREW             = 8;
  CODEPAGE_EAST_EUROPE        = 9;
  CODEPAGE_IRAN               = 10;
  CODEPAGE_WCP1252            = 11;
  CODEPAGE_CP866              = 12;
  CODEPAGE_PC852              = 13;
  CODEPAGE_PC858              = 14;
  CODEPAGE_IRAN2              = 15;
  CODEPAGE_LATVIAN            = 16;
  CODEPAGE_ARABIC             = 17;
  CODEPAGE_PT1511251          = 18;
  CODEPAGE_PC747              = 19;
  CODEPAGE_WCP1257            = 20;
  CODEPAGE_THAI               = 21;
  CODEPAGE_VIETNAM            = 22;
  CODEPAGE_PC864              = 23;
  CODEPAGE_PC1001             = 24;
  CODEPAGE_UIGUR              = 25;
  CODEPAGE_HEBREW_2           = 26;
  CODEPAGE_WCP1255            = 27;
  CODEPAGE_PC437              = 28;
  CODEPAGE_KATAKANA2          = 29;
  CODEPAGE_PC437_STD_EUROPE   = 30;
  CODEPAGE_PC858_MULT         = 31;
  CODEPAGE_PC852_LATIN_2      = 32;
  CODEPAGE_PC860_PORTUGU      = 33;
  CODEPAGE_PC861_ICELANDIC    = 34;
  CODEPAGE_PC863_CANADIAN     = 35;
  CODEPAGE_PC865_NORDIC       = 36;
  CODEPAGE_PC866_RUSSIAN      = 37;
  CODEPAGE_PC855_BULGARIAN    = 38;
  CODEPAGE_PC857_TURKEY       = 39;
  CODEPAGE_PC862_HEBREW       = 40;
  CODEPAGE_PC864_ARABIC       = 41;
  CODEPAGE_PC737_GREEK        = 42;
  CODEPAGE_PC851_GREEK        = 43;
  CODEPAGE_PC869_GREEK        = 44;
  CODEPAGE_PC928_GREEK        = 45;
  CODEPAGE_PC772_LITHUANIAN   = 46;
  CODEPAGE_PC774_LITHUAN      = 47;
  CODEPAGE_PC874_THAI         = 48;
  CODEPAGE_WPC1252_LATINL     = 49;
  CODEPAGE_WCP1250            = 50;
  CODEPAGE_WCP1251            = 51;
  CODEPAGE_PC3840_IBM_RUSSIAN = 52;
  CODEPAGE_PC3841_GOST        = 53;
  CODEPAGE_PC3843_POLISH      = 54;
  CODEPAGE_PC3844_CS2         = 55;
  CODEPAGE_PC3845_HUNGARIAN   = 56;
  CODEPAGE_PC3846_TURKISH     = 57;
  CODEPAGE_PC3847_BRAZI1_ABNI = 58;
  CODEPAGE_PC3848_BRAZIL      = 59;
  CODEPAGE_PC1001_ARABIC      = 60;
  CODEPAGE_PC2001_LITHUAN     = 61;
  CODEPAGE_PC3001_ESTONIAN_1  = 62;
  CODEPAGE_PC3002_ESTON_2     = 63;
  CODEPAGE_PC3011_LATVIAN_1   = 64;
  CODEPAGE_PC3012_LATV_2      = 65;
  CODEPAGE_PC3021_BULGARIAN   = 66;
  CODEPAGE_PC3041_MALTESE     = 67;
  CODEPAGE_PC852_CROATIA      = 68;
  CODEPAGE_VISCII             = 69;
  CODEPAGE_0C1256_ARABIC      = 70;

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
    ECLevel: Byte; // 1..19
    ModuleSize: Byte; // 1..8
    data: AnsiString;
  end;

  { TEscPrinterOA48 }

  TEscPrinterOA48 = class
  private
    FFont: Integer;
    FLogger: ILogFile;
    FPort: IPrinterPort;
    FCodePage: Integer;
    FTextCodePage: Integer;
    FInTransaction: Boolean;
    FUserCharacterMode: Integer;
    FUserChars: TCharCodes;
    FDeviceMetrics: TDeviceMetrics;
  public
    procedure PDF417Print;
    procedure PDF417ReadDataSize;
    procedure PDF417SetColumnNumber(n: Byte);
    procedure PDF417SetErrorCorrectionLevel(m, n: Byte);
    procedure PDF417SetModuleHeight(n: Byte);
    procedure PDF417SetModuleWidth(n: Byte);
    procedure PDF417SetOptions(m: Byte);
    procedure PDF417SetRowNumber(n: Byte);
    procedure PDF417Write(const data: AnsiString);

    procedure QRCodePrint;
    procedure QRCodeSetErrorCorrectionLevel(n: Byte);
    procedure QRCodeSetModuleSize(n: Byte);
    procedure QRCodeWriteData(Data: AnsiString);

    procedure EnableUserCharacters;
    procedure DisableUserCharacters;
    procedure CheckUserCharCode(Code: Byte);
  public
    constructor Create(APort: IPrinterPort; ALogger: ILogFile);
    destructor Destroy; override;

    procedure CheckCapRead;
    function ReadByte: Byte;
    function CapRead: Boolean;
    function ReadAnsiString: AnsiString;
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
    procedure BeginDocument;
    procedure EndDocument;
    procedure WriteUserChar(AChar: WideChar; ACode, AFont: Byte);
    procedure WriteUserChar2(AChar: WideChar; ACode, AFont: Byte);
    procedure WriteKazakhCharacters;
    procedure PrintUserChar(Char: WideChar);
    function IsUserChar(Char: WideChar): Boolean;
    procedure PrintPDF417(const Barcode: TPDF417);
    procedure MaxiCodePrint;
    procedure MaxiCodeSetMode(n: Byte);
    procedure MaxiCodeWriteData(const Data: AnsiString);
    procedure SelectCodePage(B: Byte);
    procedure UTF8Enable(B: Boolean);
    procedure PrintUnicode(const AText: WideString);

    property Font: Integer read FFont;
    property Port: IPrinterPort read FPort;
    property Logger: ILogFile read FLogger;
    property CodePage: Integer read FCodePage;
    property DeviceMetrics: TDeviceMetrics read FDeviceMetrics write FDeviceMetrics;
  end;

function TextCPToPrinterCP(TextCP: Integer): Integer;
function IsKazakhUnicodeChar(Char: WideChar): Boolean;
procedure CharacterToCodePage(C: WideChar; var CodePage: Integer);
function GetCodepageName(Codepage: Integer): string;

implementation

const
  CR = #13;
  LF = #10;
  HT = #09;

const
  BoolToInt: array [Boolean] of Integer = (0, 1);


function IsKazakhUnicodeChar(Char: WideChar): Boolean;
var
  i: Integer;
  Code: Word;
begin
  for i := Low(KazakhUnicodeChars) to High(KazakhUnicodeChars) do
  begin
    Code := Word(Char);
    Result := Code = KazakhUnicodeChars[i];
    if Result then Break;
  end;
end;

function TextCPToPrinterCP(TextCP: Integer): Integer;
begin
  case TextCP of
    437: Result := CODEPAGE_CP437;
    737: Result := CODEPAGE_PC737_GREEK;
    850: Result := CODEPAGE_CP850;
    852: Result := CODEPAGE_PC852;
    855: Result := CODEPAGE_PC855_BULGARIAN;
    857: Result := CODEPAGE_PC857_TURKEY;
    858: Result := CODEPAGE_PC858;
    860: Result := CODEPAGE_CP860;
    862: Result := CODEPAGE_PC862_HEBREW;
    863: Result := CODEPAGE_CP863;
    864: Result := CODEPAGE_PC864;
    865: Result := CODEPAGE_CP865;
    866: Result := CODEPAGE_CP866;
    874: Result := CODEPAGE_PC874_THAI;

    1250: Result := CODEPAGE_WCP1250;
    1251: Result := CODEPAGE_WCP1251;
    1252: Result := CODEPAGE_WCP1252;
    1255: Result := CODEPAGE_WCP1255;
    1256: Result := CODEPAGE_0C1256_ARABIC;
    1257: Result := CODEPAGE_WCP1257;
  else
    raise UserException.Create('Code page not supported');
  end;
end;

procedure CharacterToCodePage(C: WideChar; var CodePage: Integer);
var
  i: Integer;
begin
  if TestCodePage(C, CodePage) then Exit;
  for i := Low(SupportedCodePagesA) to High(SupportedCodePagesA) do
  begin
    CodePage := SupportedCodePagesA[i];
    if TestCodePage(C, CodePage) then Exit;
  end;
  CodePage := 866;
end;

function GetCodepageName(Codepage: Integer): string;
begin
  case Codepage of
    0: Result := 'CP437';
    1: Result := 'KATAKANA';
    2: Result := 'CP850';
    3: Result := 'CP860';
    4: Result := 'CP863';
    5: Result := 'CP865';
    6: Result := 'WEST_EUROPE';
    7: Result := 'GREEK';
    8: Result := 'HEBREW';
    9: Result := 'EAST_EUROPE';
    10: Result := 'IRAN';
    11: Result := 'WCP1252';
    12: Result := 'CP866';
    13: Result := 'PC852';
    14: Result := 'PC858';
    15: Result := 'IRAN2';
    16: Result := 'LATVIAN';
    17: Result := 'ARABIC';
    18: Result := 'PT1511251';
    19: Result := 'PC747';
    20: Result := 'WCP1257';
    21: Result := 'THAI';
    22: Result := 'VIETNAM';
    23: Result := 'PC864';
    24: Result := 'PC1001';
    25: Result := 'UIGUR';
    26: Result := 'HEBREW_2';
    27: Result := 'WCP1255';
    28: Result := 'PC437';
    29: Result := 'KATAKANA2';
    30: Result := 'PC437_STD_EUROPE';
    31: Result := 'PC858_MULT';
    32: Result := 'PC852_LATIN_2';
    33: Result := 'PC860_PORTUGU';
    34: Result := 'PC861_ICELANDIC';
    35: Result := 'PC863_CANADIAN';
    36: Result := 'PC865_NORDIC';
    37: Result := 'PC866_RUSSIAN';
    38: Result := 'PC855_BULGARIAN';
    39: Result := 'PC857_TURKEY';
    40: Result := 'PC862_HEBREW';
    41: Result := 'PC864_ARABIC';
    42: Result := 'PC737_GREEK';
    43: Result := 'PC851_GREEK';
    44: Result := 'PC869_GREEK';
    45: Result := 'PC928_GREEK';
    46: Result := 'PC772_LITHUANIAN';
    47: Result := 'PC774_LITHUAN';
    48: Result := 'PC874_THAI';
    49: Result := 'WPC1252_LATINL';
    50: Result := 'WCP1250';
    51: Result := 'WCP1251';
    52: Result := 'PC3840_IBM_RUSSIAN';
    53: Result := 'PC3841_GOST';
    54: Result := 'PC3843_POLISH';
    55: Result := 'PC3844_CS2';
    56: Result := 'PC3845_HUNGARIAN';
    57: Result := 'PC3846_TURKISH';
    58: Result := 'PC3847_BRAZI1_ABNI';
    59: Result := 'PC3848_BRAZIL';
    60: Result := 'PC1001_ARABIC';
    61: Result := 'PC2001_LITHUAN';
    62: Result := 'PC3001_ESTONIAN_1';
    63: Result := 'PC3002_ESTON_2';
    64: Result := 'PC3011_LATVIAN_1';
    65: Result := 'PC3012_LATV_2';
    66: Result := 'PC3021_BULGARIAN';
    67: Result := 'PC3041_MALTESE';
    68: Result := 'PC852_CROATIA';
    69: Result := 'VISCII';
    70: Result := '0C1256_ARABIC';
  else
    Result := 'Unknown codepage';
  end;
end;

{ TEscPrinterOA48 }

constructor TEscPrinterOA48.Create(APort: IPrinterPort; ALogger: ILogFile);
begin
  inherited Create;
  FPort := APort;
  FLogger := ALogger;
  FDeviceMetrics.PrintWidth := 576;
  FUserChars := TCharCodes.Create(TCharCode);
  FFont := FONT_TYPE_A;
end;

destructor TEscPrinterOA48.Destroy;
begin
  FUserChars.Free;
  inherited Destroy;
end;

procedure TEscPrinterOA48.Send(const Data: AnsiString);
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

function TEscPrinterOA48.ReadByte: Byte;
begin
  Result := Ord(FPort.Read(1)[1]);
end;

function TEscPrinterOA48.ReadAnsiString: AnsiString;
var
  C: Char;
begin
  Result := '';
  repeat
    C := FPort.Read(1)[1];
    if C <> #0 then
      Result := Result + C;
  until C = #0;
end;

procedure TEscPrinterOA48.CarriageReturn;
begin
  Send(CR);
end;

procedure TEscPrinterOA48.HorizontalTab;
begin
  Send(HT);
end;

procedure TEscPrinterOA48.LineFeed;
begin
  Logger.Debug('TEscPrinterOA48.LineFeed');
  Send(LF);
end;

function TEscPrinterOA48.ReadPrinterStatus: TPrinterStatus;
begin
  Logger.Debug('TEscPrinterOA48.ReadPrinterStatus');
  CheckCapRead;

  FPort.Lock;
  try
    Send(#$10#$04#$01);
    Result.DrawerOpened := TestBit(ReadByte, 2);
  finally
    FPort.Unlock;
  end;
end;

function TEscPrinterOA48.ReadOfflineStatus: TOfflineStatus;
var
  B: Byte;
begin
  Logger.Debug('TEscPrinterOA48.ReadOfflineStatus');
  
  CheckCapRead;
  FPort.Lock;
  try
    Send(#$10#$04#$02);
    B := ReadByte;
    Result.CoverOpened := TestBit(B, 2);
    Result.FeedButton := TestBit(B, 3);
    Result.ErrorOccurred := TestBit(B, 6);
  finally
    FPort.Unlock;
  end;
end;

function TEscPrinterOA48.ReadErrorStatus: TErrorStatus;
var
  B: Byte;
begin
  Logger.Debug('TEscPrinterOA48.ReadErrorStatus');
  
  CheckCapRead;
  FPort.Lock;
  try
    Send(#$10#$04#$03);
    B := ReadByte;
    Result.CutterError := TestBit(B, 3);
    Result.UnrecoverableError := TestBit(B, 5);
    Result.AutoRecoverableError := TestBit(B, 6);
  finally
    FPort.Unlock;
  end;
end;

function TEscPrinterOA48.ReadPaperStatus: TPaperStatus;
var
  B: Byte;
begin
  Logger.Debug('TEscPrinterOA48.ReadPaperStatus');
  
  CheckCapRead;
  FPort.Lock;
  try
    Send(#$10#$04#$04);
    B := ReadByte;
    Result.PaperPresent := not TestBit(B, 5);
  finally
    FPort.Unlock;
  end;
end;

procedure TEscPrinterOA48.RecoverError(ClearBuffer: Boolean);
begin
  Logger.Debug(WideFormat('TEscPrinterOA48.RecoverError(ClearBuffer=%s)', [
    BoolToStr(ClearBuffer)]));

  if ClearBuffer then
    Send(#$10#$05#$02)
  else
    Send(#$10#$05#$01);
end;

procedure TEscPrinterOA48.GeneratePulse(n, m, t: Byte);
begin
  Logger.Debug(WideFormat('TEscPrinterOA48.GeneratePulse(%d, %d, %d)', [n, m, t]));
  Send(#$10#$14 + Chr(n) + Chr(m) + Chr(t));
end;

procedure TEscPrinterOA48.SetRightSideCharacterSpacing(n: Byte);
begin
  Logger.Debug(WideFormat('TEscPrinterOA48.SetRightSideCharacterSpacing(n)', [n]));
  Send(#$1B#$20 + Chr(n));
end;

procedure TEscPrinterOA48.SelectPrintMode(Mode: TPrintMode);
begin
  SetPrintMode(PrintModeToByte(Mode));
end;

procedure TEscPrinterOA48.SetPrintMode(Mode: Byte);
begin
  Logger.Debug(WideFormat('TEscPrinterOA48.SetPrintMode(%d)', [Mode]));
  Send(#$1B#$21 + Chr(Mode));

  FFont := FONT_TYPE_A;
  if TestBit(Mode, 0) then
    FFont := FONT_TYPE_B;
end;

procedure TEscPrinterOA48.SetAbsolutePrintPosition(n: Word);
begin
  Logger.Debug(WideFormat('TEscPrinterOA48.SetAbsolutePrintPosition(%d)', [n]));
  Send(#$1B#$24 + Chr(Lo(n)) + Chr(Hi(n)));
end;

procedure TEscPrinterOA48.SelectUserCharacter(n: Byte);
begin
  if n = FUserCharacterMode then Exit;

  Logger.Debug(WideFormat('TEscPrinterOA48.SelectUserCharacter(%d)', [n]));
  Send(#$1B#$25 + Chr(n));
  FUserCharacterMode := n;
end;

procedure TEscPrinterOA48.EnableUserCharacters;
begin
  SelectUserCharacter(1);
end;

procedure TEscPrinterOA48.DisableUserCharacters;
begin
  SelectUserCharacter(0);
end;

procedure TEscPrinterOA48.CheckUserCharCode(Code: Byte);
begin
  if (not Code in [USER_CHAR_CODE_MIN..USER_CHAR_CODE_MAX]) then
    raise UserException.CreateFmt('Invalid character code, 0x%.2X', [Code]);
end;

///////////////////////////////////////////////////////////////////////////////
// Font A 12x24, font B 9x17
///////////////////////////////////////////////////////////////////////////////
// The allowable character code range is from ASCII code <20>H to
// <7E>H (95 characters).

procedure TEscPrinterOA48.WriteUserChar(AChar: WideChar; ACode, AFont: Byte);
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

procedure TEscPrinterOA48.WriteUserChar2(AChar: WideChar; ACode, AFont: Byte);
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

procedure TEscPrinterOA48.DefineUserCharacter(C: TUserChar);
begin
  Logger.Debug('TEscPrinterOA48.DefineUserCharacter');
  Send(#$1B#$26#$03 + Chr(C.c1) + Chr(C.c2) + Chr(C.Width) + C.Data);
end;

procedure TEscPrinterOA48.SelectBitImageMode(mode: Integer; Image: TGraphic);
var
  n: Word;
  data: AnsiString;
begin
  Logger.Debug('TEscPrinterOA48.SelectBitImageMode');

  n := Image.Width;
  data := GetImageData2(Image);
  Send(#$1B#$2A + Chr(Mode) + Chr(Lo(n)) + Chr(Hi(n)) + data);
end;

procedure TEscPrinterOA48.SetUnderlineMode(n: Byte);
begin
  Logger.Debug('TEscPrinterOA48.SetUnderlineMode');
  Send(#$1B#$2D + Chr(n));
end;

procedure TEscPrinterOA48.SetDefaultLineSpacing;
begin
  Logger.Debug('TEscPrinterOA48.SetDefaultLineSpacing');
  Send(#$1B#$32);
end;

procedure TEscPrinterOA48.SetLineSpacing(n: Byte);
begin
  Logger.Debug('TEscPrinterOA48.SetLineSpacing');
  Send(#$1B#$33 + Chr(n));
end;

procedure TEscPrinterOA48.CancelUserCharacter(n: Byte);
begin
  Logger.Debug('TEscPrinterOA48.CancelUserCharacter');
  Send(#$1B#$3F + Chr(n));
end;

procedure TEscPrinterOA48.Initialize;
begin
  Logger.Debug('TEscPrinterOA48.Initialize');
  Send(#$1B#$40);

  FUserChars.Clear;
  FCodePage := 0;
  FTextCodePage := 866;
  FUserCharacterMode := 0;
  FInTransaction := False;
  FFont := FONT_TYPE_A;
end;

procedure TEscPrinterOA48.SetBeepParams(N, T: Byte);
begin
  Logger.Debug('TEscPrinterOA48.SetBeepParams');
  Send(#$1B#$42 + Chr(N) + Chr(T));
end;

procedure TEscPrinterOA48.SetHorizontalTabPositions(Tabs: AnsiString);
begin
  Logger.Debug('TEscPrinterOA48.SetHorizontalTabPositions');
  Send(#$1B#$44 + Tabs + #0);
end;

procedure TEscPrinterOA48.SetEmphasizedMode(Value: Boolean);
begin
  Logger.Debug('TEscPrinterOA48.SetEmphasizedMode');
  Send(#$1B#$45 + Chr(BoolToInt[Value]));
end;

procedure TEscPrinterOA48.SetDoubleStrikeMode(Value: Boolean);
begin
  Logger.Debug('TEscPrinterOA48.SetDoubleStrikeMode');
  Send(#$1B#$47 + Chr(BoolToInt[Value]));
end;

procedure TEscPrinterOA48.PrintAndFeed(n: Byte);
begin
  Logger.Debug('TEscPrinterOA48.PrintAndFeed');
  Send(#$1B#$4A + Chr(n));
end;

procedure TEscPrinterOA48.SetCharacterFont(n: Byte);
begin
  if n = FFont then Exit;

  Logger.Debug(WideFormat('TEscPrinterOA48.SetCharacterFont(%d)', [n]));
  if n in [FONT_TYPE_MIN..FONT_TYPE_MAX] then
  begin
    Send(#$1B#$4D + Chr(n));
    FFont := n;
  end;
end;

procedure TEscPrinterOA48.SetCharacterSet(N: Byte);
begin
  Logger.Debug('TEscPrinterOA48.SetCharacterSet');
  Send(#$1B#$52 + Chr(N));
end;

procedure TEscPrinterOA48.Set90ClockwiseRotation(Value: Boolean);
begin
  Logger.Debug('TEscPrinterOA48.Set90ClockwiseRotation');
  Send(#$1B#$56 + Chr(BoolToInt[Value]));
end;

procedure TEscPrinterOA48.SetRelativePrintPosition(n: Word);
begin
  Logger.Debug('TEscPrinterOA48.SetRelativePrintPosition');
  Send(#$1B#$5C + Chr(Lo(n)) + Chr(Hi(n)));
end;

procedure TEscPrinterOA48.SetJustification(N: Byte);
begin
  Logger.Debug('TEscPrinterOA48.SetJustification');
  Send(#$1B#$61 + Chr(N));
end;

procedure TEscPrinterOA48.EnableButtons(Value: Boolean);
begin
  Logger.Debug('TEscPrinterOA48.EnableButtons');
  Send(#$1B#$63#$35 + Chr(BoolToInt[Value]));
end;

procedure TEscPrinterOA48.PrintAndFeedLines(N: Byte);
begin
  Logger.Debug('TEscPrinterOA48.PrintAndFeedLines');
  Send(#$1B#$64 + Chr(N));
end;

procedure TEscPrinterOA48.SetCodePage(CodePage: Integer);
begin
  if FCodePage = CodePage then Exit;
  Logger.Debug(WideFormat('TEscPrinterOA48.SetCodePage(%d, %s)', [
    CodePage, GetCodePageName(CodePage)]));

  Send(#$1B#$74 + Chr(CodePage));
  FCodePage := CodePage;
end;

procedure TEscPrinterOA48.SetUpsideDownPrinting(Value: Boolean);
begin
  Logger.Debug('TEscPrinterOA48.SetUpsideDownPrinting');
  Send(#$1B#$7B + Chr(BoolToInt[Value]));
end;

procedure TEscPrinterOA48.PartialCut;
begin
  Logger.Debug('TEscPrinterOA48.PartialCut');
  Send(#$1B#$69);
end;

procedure TEscPrinterOA48.PartialCut2;
begin
  Logger.Debug('TEscPrinterOA48.PartialCut2');
  Send(#$1B#$6D);
end;

procedure TEscPrinterOA48.SelectChineseCode(N: Byte);
begin
  Logger.Debug('TEscPrinterOA48.SelectChineseCode');
  Send(#$1B#$39 + Chr(N));
end;

procedure TEscPrinterOA48.PrintNVBitImage(Number, Mode: Byte);
begin
  Logger.Debug('TEscPrinterOA48.PrintNVBitImage');
  Send(#$1C#$70 + Chr(Number) + Chr(Mode));
end;

procedure TEscPrinterOA48.DefineNVBitImage(Number: Byte; Image: TGraphic);
var
  x, y: Integer;
  Bitmap: TBitmap;
begin
  Logger.Debug('TEscPrinterOA48.DefineNVBitImage');

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

procedure TEscPrinterOA48.SetCharacterSize(N: Byte);
begin
  Logger.Debug('TEscPrinterOA48.SetCharacterSize');
  Send(#$1D#$21 + Chr(N));
end;

procedure TEscPrinterOA48.DownloadBMP(Image: TGraphic);
var
  x, y: Byte;
  Bitmap: TBitmap;
begin
  Logger.Debug('TEscPrinterOA48.DownloadBMP');
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

procedure TEscPrinterOA48.PrintBmp(Mode: Byte);
begin
  Logger.Debug('TEscPrinterOA48.PrintBmp');
  Send(#$1D#$2F + Chr(Mode));
end;

procedure TEscPrinterOA48.SetWhiteBlackReverse(Value: Boolean);
begin
  Logger.Debug('TEscPrinterOA48.SetWhiteBlackReverse');
  Send(#$1D#$42 + Chr(BoolToInt[Value]));
end;

procedure TEscPrinterOA48.SetHRIPosition(N: Byte);
begin
  Logger.Debug('TEscPrinterOA48.SetHRIPosition');
  Send(#$1D#$48 + Chr(N));
end;

procedure TEscPrinterOA48.SetLeftMargin(N: Word);
begin
  Logger.Debug('TEscPrinterOA48.SetLeftMargin');
  Send(#$1D#$4C + Chr(Lo(N)) + Chr(Hi(N)));
end;

procedure TEscPrinterOA48.SetCutModeAndCutPaper(M: Byte);
begin
  Logger.Debug('TEscPrinterOA48.SetCutModeAndCutPaper');
  Send(#$1D#$56 + Chr(M));
end;

procedure TEscPrinterOA48.SetCutModeAndCutPaper2(n: Byte);
begin
  Logger.Debug('TEscPrinterOA48.SetCutModeAndCutPaper2');
  Send(#$1D#$56#$66 + Chr(n));
end;

procedure TEscPrinterOA48.SetPrintAreaWidth(n: Byte);
begin
  Logger.Debug('TEscPrinterOA48.SetPrintAreaWidth');
  Send(#$1D#$57 + Chr(Lo(n)) + Chr(Hi(n)));
end;

procedure TEscPrinterOA48.StartEndMacroDefinition;
begin
  Logger.Debug('TEscPrinterOA48.StartEndMacroDefinition');
  Send(#$1D#$3A);
end;

procedure TEscPrinterOA48.ExecuteMacro(r, t, m: Byte);
begin
  Logger.Debug('TEscPrinterOA48.ExecuteMacro');
  Send(#$1D#$5E + Chr(r) + Chr(t) + Chr(m));
end;

procedure TEscPrinterOA48.EnableAutomaticStatusBack(N: Byte);
begin
  Logger.Debug('TEscPrinterOA48.EnableAutomaticStatusBack');
  Send(#$1D#$61 + Chr(N));
end;

procedure TEscPrinterOA48.SetHRIFont(N: Byte);
begin
  Logger.Debug('TEscPrinterOA48.SetHRIFont');
  Send(#$1D#$66 + Chr(N));
end;

procedure TEscPrinterOA48.SetBarcodeHeight(N: Byte);
begin
  Logger.Debug('TEscPrinterOA48.SetBarcodeHeight');
  Send(#$1D#$68 + Chr(N));
end;

procedure TEscPrinterOA48.PrintBarcode(BCType: Byte; const Data: AnsiString);
begin
  Logger.Debug('TEscPrinterOA48.PrintBarcode');
  Send(#$1D#$6B + Chr(BCType) + Data + #0);
end;

procedure TEscPrinterOA48.PrintBarcode2(BCType: Byte; const Data: AnsiString);
begin
  Logger.Debug('TEscPrinterOA48.PrintBarcode2');
  Send(#$1D#$6B + Chr(BCType) + Chr(Length(Data)) + Data);
end;

function TEscPrinterOA48.ReadPaperRollStatus: TPaperRollStatus;
begin
  Logger.Debug('TEscPrinterOA48.ReadPaperRollStatus');

  CheckCapRead;
  FPort.Lock;
  try
    Send(#$1D#$72#$01);
    Result.PaperNearEnd := TestBit(ReadByte, 2);
  finally
    FPort.Unlock;
  end;
end;

// Print raster bit image
procedure TEscPrinterOA48.PrintRasterBMP(Mode: Byte; Image: TGraphic);
var
  x, y: Byte;
begin
  Logger.Debug('TEscPrinterOA48.PrintRasterBMP');

  x := (Image.Width + 7) div 8;
  y := Image.Height;
  Send(#$1D#$76#$30 + Chr(Mode) + Chr(Lo(x)) + Chr(Hi(x)) +
    Chr(Lo(y)) + Chr(Hi(y)) + GetRasterImageData(Image));
end;

procedure TEscPrinterOA48.SetBarcodeWidth(N: Integer);
begin
  Logger.Debug('TEscPrinterOA48.SetBarcodeWidth');
  Send(#$1D#$77 + Chr(N));
end;

procedure TEscPrinterOA48.SetBarcodeLeft(N: Integer);
begin
  Logger.Debug('TEscPrinterOA48.SetBarcodeLeft');
  Send(#$1D#$78 + Chr(N));
end;

procedure TEscPrinterOA48.SetMotionUnits(x, y: Integer);
begin
  Logger.Debug('TEscPrinterOA48.SetMotionUnits');
  Send(#$1D#$50 + Chr(x) + Chr(y));
end;

procedure TEscPrinterOA48.PrintTestPage;
begin
  Logger.Debug('TEscPrinterOA48.PrintTestPage');
  Send(#$12#$54);
end;

procedure TEscPrinterOA48.SetKanjiMode(m: Byte);
begin
  Logger.Debug('TEscPrinterOA48.SetKanjiMode');
  Send(#$1C#$21 + Chr(m));
end;

procedure TEscPrinterOA48.SelectKanjiCharacter;
begin
  Logger.Debug('TEscPrinterOA48.SelectKanjiCharacter');
  Send(#$1C#$26);
end;

procedure TEscPrinterOA48.SetKanjiUnderline(Value: Boolean);
begin
  Logger.Debug('TEscPrinterOA48.SetKanjiUnderline');
  Send(#$1C#$2D + Chr(BoolToInt[Value]));
end;

procedure TEscPrinterOA48.CancelKanjiCharacter;
begin
  Logger.Debug('TEscPrinterOA48.CancelKanjiCharacter');
  Send(#$1C#$2E);
end;

procedure TEscPrinterOA48.DefineKanjiCharacters(c1, c2: Byte;
  const data: AnsiString);
begin
  Logger.Debug('TEscPrinterOA48.DefineKanjiCharacters');
  Send(#$1C#$32 + Chr(c1) + Chr(c2) + data);
end;

procedure TEscPrinterOA48.SetPeripheralDevice(m: Byte);
begin
  Logger.Debug('TEscPrinterOA48.SetPeripheralDevice');
  Send(#$1B#$3D + Chr(m));
end;

procedure TEscPrinterOA48.SetKanjiSpacing(n1, n2: Byte);
begin
  Logger.Debug('TEscPrinterOA48.SetKanjiSpacing');
  Send(#$1C#$53 + Chr(n1) + Chr(n2));
end;

procedure TEscPrinterOA48.PrintAndReturnStandardMode;
begin
  Logger.Debug('TEscPrinterOA48.PrintAndReturnStandardMode');
  Send(#$0C);
end;

procedure TEscPrinterOA48.PrintDataInMode;
begin
  Logger.Debug('TEscPrinterOA48.PrintDataInMode');
  Send(#$1B#$0C);
end;

procedure TEscPrinterOA48.SetPageMode;
begin
  Logger.Debug('TEscPrinterOA48.SetPageMode');
  Send(#$1B#$4C);
end;

procedure TEscPrinterOA48.SetStandardMode;
begin
  Logger.Debug('TEscPrinterOA48.SetStandardMode');
  Send(#$1B#$53);
end;

procedure TEscPrinterOA48.SetPageModeDirection(n: Byte);
begin
  Logger.Debug('TEscPrinterOA48.SetPageModeDirection');
  Send(#$1B#$54 + Chr(n));
end;

procedure TEscPrinterOA48.SetPageModeArea(R: TPageArea);
begin
  Logger.Debug(WideFormat('TEscPrinterOA48.SetPageModeArea(%d,%d,%d,%d)', [
    R.X, R.Y, R.Width, R.Height]));

  Send(#$1B#$57 +
    Chr(Lo(R.X)) + Chr(Hi(R.X)) +
    Chr(Lo(R.Y)) + Chr(Hi(R.Y)) +
    Chr(Lo(R.Width)) + Chr(Hi(R.Width)) +
    Chr(Lo(R.Height)) + Chr(Hi(R.Height)));
end;

procedure TEscPrinterOA48.SetKanjiQuadSizeMode(Value: Boolean);
begin
  Logger.Debug('TEscPrinterOA48.SetKanjiQuadSizeMode');
  Send(#$1C#$57 + Chr(BoolToInt[Value]));
end;

procedure TEscPrinterOA48.FeedMarkedPaper;
begin
  Logger.Debug('TEscPrinterOA48.FeedMarkedPaper');
  Send(#$1D#$0C);
end;

procedure TEscPrinterOA48.SetPMAbsoluteVerticalPosition(n: Integer);
begin
  Logger.Debug('TEscPrinterOA48.SetPMAbsoluteVerticalPosition');
  Send(#$1D#$24 + Chr(Lo(n)) + Chr(Hi(n)));
end;

procedure TEscPrinterOA48.ExecuteTestPrint(p: Integer; n, m: Byte);
begin
  Logger.Debug('TEscPrinterOA48.ExecuteTestPrint');
  Send(#$1D#$28#$41 + Chr(Lo(p)) + Chr(Hi(p)) + Chr(n) + Chr(m));
end;

procedure TEscPrinterOA48.SelectCounterPrintMode(n, m: Byte);
begin
  Logger.Debug('TEscPrinterOA48.SelectCounterPrintMode');
  Send(#$1D#$43#$30 + Chr(n) + Chr(m));
end;

procedure TEscPrinterOA48.SelectCountMode(a, b: Word; n, r: Byte);
begin
  Logger.Debug('TEscPrinterOA48.SelectCountMode');
  Send(#$1D#$43#$31 + Chr(Lo(a)) + Chr(Hi(a)) +
    Chr(Lo(b)) + Chr(Hi(b)) + Chr(n) + Chr(r));
end;

procedure TEscPrinterOA48.SetCounter(n: Word);
begin
  Logger.Debug('TEscPrinterOA48.SetCounter');
  Send(#$1D#$43#$32 + Chr(Lo(n)) + Chr(Hi(n)));
end;

procedure TEscPrinterOA48.SetPMRelativeVerticalPosition(n: Word);
begin
  Logger.Debug('TEscPrinterOA48.SetPMRelativeVerticalPosition');
  Send(#$1D#$5C + Chr(Lo(n)) + Chr(Hi(n)));
end;

procedure TEscPrinterOA48.PrintCounter;
begin
  Logger.Debug('TEscPrinterOA48.PrintCounter');
  Send(#$1D#$63);
end;

procedure TEscPrinterOA48.SetNormalPrintMode;
var
  PrintMode: TPrintMode;
begin
  Logger.Debug('TEscPrinterOA48.SetNormalPrintMode');
  PrintMode.CharacterFontB := False;
  PrintMode.Emphasized := False;
  PrintMode.DoubleHeight := False;
  PrintMode.DoubleWidth := False;
  PrintMode.Underlined := False;
  SelectPrintMode(PrintMode);
end;

procedure TEscPrinterOA48.PrintText(Text: AnsiString);
begin
  //Logger.Debug(WideFormat('TEscPrinterOA48.PrintText(''%s'')', [TrimRight(Text)]));
  Send(Text);
end;

function TEscPrinterOA48.CapRead: Boolean;
begin
  Result := Port.CapRead;
end;

procedure TEscPrinterOA48.CheckCapRead;
begin
  if not Port.CapRead then
  begin
    raise UserException.Create(SReadNotSupported);
  end;
end;

procedure TEscPrinterOA48.BeginDocument;
begin
  FInTransaction := True;
end;

procedure TEscPrinterOA48.EndDocument;
begin
  FInTransaction := False;
  Port.Flush;
end;

procedure TEscPrinterOA48.WriteKazakhCharacters;
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
        BitmapData := '';
        Count := Bitmap.Width div FontWidth;
        Data := GetBitmapData(Bitmap, 24);
        for i := 0 to Count-1 do
        begin
          FUserChars.Add(Code + i, WideChar(KazakhUnicodeChars[i]), FONT_TYPE_A);
          BitmapData := BitmapData + Chr(FontWidth) + Copy(Data, i*FontWidth*3 + 1, FontWidth*3);
        end;
        Send(#$1B#$26#$03 + Chr(Code) + Chr(Code + Count -1) + BitmapData);
        Inc(Code, Count);
      end;
      // FONT_TYPE_B
      FontFileName := GetModulePath + 'Fonts\KazakhFontB.bmp';
      if FileExists(FontFileName) then
      begin
        SetCharacterFont(FONT_TYPE_B);
        Bitmap.LoadFromFile(FontFileName);
        FontWidth := 9;
        BitmapData := '';
        Count := Bitmap.Width div FontWidth;
        Data := GetBitmapData(Bitmap, 17);
        for i := 0 to Count-1 do
        begin
          FUserChars.Add(Code + i, WideChar(KazakhUnicodeChars[i]), FONT_TYPE_B);
          BitmapData := BitmapData + Chr(FontWidth) + Copy(Data, i*FontWidth*3 + 1, FontWidth*3);
        end;
        Send(#$1B#$26#$03 + Chr(Code) + Chr(Code + Count -1) + BitmapData);
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

function TEscPrinterOA48.IsUserChar(Char: WideChar): Boolean;
begin
  Result := IsKazakhUnicodeChar(Char);
end;

procedure TEscPrinterOA48.PrintUserChar(Char: WideChar);
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

procedure TEscPrinterOA48.QRCodeSetModuleSize(n: Byte);
begin
  Send(#$1D#$28#$6B#$30#$67 + Chr(n));
end;

procedure TEscPrinterOA48.QRCodeSetErrorCorrectionLevel(n: Byte);
begin
  Send(#$1D#$28#$6B#$30#$69 + Chr(n));
end;

procedure TEscPrinterOA48.QRCodeWriteData(Data: AnsiString);
var
  L: Word;
  Command: AnsiString;
begin
  L := Length(Data);
  Command := #$1D#$28#$6B#$30#$80 + Chr(Lo(L)) + Chr(Hi(L)) + Data;
  Send(Command);
end;

procedure TEscPrinterOA48.QRCodePrint;
begin
  Send(#$1D#$28#$6B#$30#$81);
end;

procedure TEscPrinterOA48.printQRCode(const Barcode: TQRCode);
begin
  Logger.Debug('TEscPrinterOA48.printQRCode');
  QRCodeSetModuleSize(Barcode.ModuleSize);
  QRCodeSetErrorCorrectionLevel(Barcode.ECLevel);
  QRCodeWriteData(Barcode.Data);
  QRCodePrint;
end;

procedure TEscPrinterOA48.PDF417SetColumnNumber(n: Byte);
begin
  Send(#$1D#$28#$6B#$03#$00#$30#$41 + Chr(n));
end;

procedure TEscPrinterOA48.PDF417SetRowNumber(n: Byte);
begin
  Send(#$1D#$28#$6B#$03#$00#$30#$42 + Chr(n));
end;

procedure TEscPrinterOA48.PDF417SetModuleWidth(n: Byte);
begin
  Send(#$1D#$28#$6B#$03#$00#$30#$43 + Chr(n));
end;

procedure TEscPrinterOA48.PDF417SetModuleHeight(n: Byte);
begin
  Send(#$1D#$28#$6B#$03#$00#$30#$44 + Chr(n));
end;

procedure TEscPrinterOA48.PDF417SetErrorCorrectionLevel(m, n: Byte);
begin
  Send(#$1D#$28#$6B#$03#$00#$30#$45 + Chr(m) + Chr(n));
end;

procedure TEscPrinterOA48.PDF417SetOptions(m: Byte);
begin
  Send(#$1D#$28#$6B#$03#$00#$30#$46 + Chr(m));
end;

procedure TEscPrinterOA48.PDF417Write(const data: AnsiString);
var
  L: Word;
begin
  L := Length(Data) + 3;
  Send(#$1D#$28#$6B + Chr(Lo(L)) + Chr(Hi(L)) + #$30#$50#$30 + Data);
end;

procedure TEscPrinterOA48.PDF417Print;
begin
  Send(#$1D#$28#$6B#$03#$00#$30#$51#$30);
end;

procedure TEscPrinterOA48.PDF417ReadDataSize;
begin
  Send(#$1D#$28#$6B#$03#$00#$30#$52#$30);
  // Read size
end;

procedure TEscPrinterOA48.PrintPDF417(const Barcode: TPDF417);
begin
  PDF417SetRowNumber(Barcode.RowNumber);
  PDF417SetColumnNumber(Barcode.ColumnNumber);
  PDF417SetModuleWidth(Barcode.ModuleWidth);
  PDF417SetModuleHeight(Barcode.ModuleHeight);
  //PDF417SetErrorCorrectionLevel(Barcode.ErrorCorrectionLevel);
  //PDF417SetOptions(Barcode.Options);
  PDF417Write(Barcode.Data);
  PDF417Print;
end;

procedure TEscPrinterOA48.MaxiCodeSetMode(n: Byte);
begin
  Send(#$1D#$28#$6B#$03#$00#$32#$41 + Chr(n));
end;

procedure TEscPrinterOA48.MaxiCodeWriteData(const Data: AnsiString);
var
  L: Word;
begin
  L := Length(Data) + 3;
  Send(#$1D#$28#$6B + Chr(Lo(L)) + Chr(Hi(L)) + #$32#$50#$30 + Data);
end;

procedure TEscPrinterOA48.MaxiCodePrint;
begin
  Send(#$1D#$28#$6B#$03#$00#$32#$51#$30);
end;

procedure TEscPrinterOA48.UTF8Enable(B: Boolean);
begin
  Send(#$1F#$1B#$10#$01#$02 + Chr(BoolToInt[B]));
end;

procedure TEscPrinterOA48.SelectCodePage(B: Byte);
begin
  Send(#$1F#$1B#$1F#$FF + Chr(B) + #$0A#$00);
end;

procedure TEscPrinterOA48.PrintUnicode(const AText: WideString);
var
  i: Integer;
  C: WideChar;
begin
  if TestCodePage(AText, FTextCodePage) then
  begin
    SetCodePage(TextCPToPrinterCP(FTextCodePage));
    PrintText(WideStringToAnsiString(FTextCodePage, AText));
  end else
  begin
    for i := 1 to Length(AText) do
    begin
      C := AText[i];
      if IsUserChar(C) then
      begin
        PrintUserChar(C);
      end else
      begin
        DisableUserCharacters;
        CharacterToCodePage(C, FTextCodePage);
        SetCodePage(TextCPToPrinterCP(FTextCodePage));
        PrintText(WideStringToAnsiString(FTextCodePage, C));
      end;
    end;
  end;
  DisableUserCharacters;
end;

end.

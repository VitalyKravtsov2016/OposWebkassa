unit EscPrinterXPrinter;

interface

uses
  // VCL
  Windows, Types, SysUtils, Graphics, Classes,
  // Tnt
  TntGraphics, TntSysUtils,
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

  XPR_QRCODE_ECL_7   = $48;
  XPR_QRCODE_ECL_15  = $49;
  XPR_QRCODE_ECL_25  = $50;
  XPR_QRCODE_ECL_30  = $51;

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
  CHARSET_CHINA            = 15;

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
  CODEPAGE_WCP1252            = 16;
  CODEPAGE_CP866              = 17;
  CODEPAGE_PC852              = 18;
  CODEPAGE_PC858              = 19;
  CODEPAGE_IRAN2              = 20;
  CODEPAGE_LATVIAN            = 21;
  CODEPAGE_ARABIC             = 22;
  CODEPAGE_PT1511251          = 23;
  CODEPAGE_PC747              = 24;
  CODEPAGE_WCP1257            = 25;
  CODEPAGE_VIETNAM            = 27;
  CODEPAGE_PC864              = 28;
  CODEPAGE_PC1001             = 29;
  CODEPAGE_UIGUR              = 30;
  CODEPAGE_HEBREW_2           = 31;
  CODEPAGE_WCP1255            = 32;
  CODEPAGE_WCP1256            = 33;
  CODEPAGE_PC437              = 50;
  CODEPAGE_KATAKANA2          = 51;
  CODEPAGE_PC437_STD_EUROPE   = 52;
  CODEPAGE_PC858_MULT         = 53;
  CODEPAGE_PC852_LATIN_2      = 54;
  CODEPAGE_PC860_PORTUGU      = 55;
  CODEPAGE_PC861_ICELANDIC    = 56;
  CODEPAGE_PC863_CANADIAN     = 57;
  CODEPAGE_PC865_NORDIC       = 58;
  CODEPAGE_PC866_RUSSIAN      = 59;
  CODEPAGE_PC855_BULGARIAN    = 60;
  CODEPAGE_PC857_TURKEY       = 61;
  CODEPAGE_PC862_HEBREW       = 62;
  CODEPAGE_PC864_ARABIC       = 63;
  CODEPAGE_PC737_GREEK        = 64;
  CODEPAGE_PC851_GREEK        = 65;
  CODEPAGE_PC869_GREEK        = 66;
  CODEPAGE_PC928_GREEK        = 67;
  CODEPAGE_PC772_LITHUANIAN   = 68;
  CODEPAGE_PC774_LITHUAN      = 69;
  CODEPAGE_PC874_THAI         = 70;

  CODEPAGE_WPC1252_LATINL     = 71;
  CODEPAGE_WCP1250            = 72;
  CODEPAGE_WCP1251            = 73;
  CODEPAGE_PC3840_IBM_RUSSIAN = 74;
  CODEPAGE_PC3841_GOST        = 75;
  CODEPAGE_PC3843_POLISH      = 76;
  CODEPAGE_PC3844_CS2         = 77;
  CODEPAGE_PC3845_HUNGARIAN   = 78;
  CODEPAGE_PC3846_TURKISH     = 79;
  CODEPAGE_PC3847_BRAZI1_ABNI = 80;
  CODEPAGE_PC3848_BRAZIL      = 81;
  CODEPAGE_PC1001_ARABIC      = 82;
  CODEPAGE_PC2001_LITHUAN     = 83;
  CODEPAGE_PC3001_ESTONIAN_1  = 84;
  CODEPAGE_PC3002_ESTON_2     = 85;
  CODEPAGE_PC3011_LATVIAN_1   = 86;
  CODEPAGE_PC3012_LATV_2      = 87;
  CODEPAGE_PC3021_BULGARIAN   = 88;
  CODEPAGE_PC3041_MALTESE     = 89;


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

  { TEscPrinterXPrinter }

  TEscPrinterXPrinter = class
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
    CODEPAGE_CP437: Result := 'CODEPAGE_CP437';
    CODEPAGE_KATAKANA: Result := 'KATAKANA';
    CODEPAGE_CP850: Result := 'CP850';
    CODEPAGE_CP860: Result := 'CP860';
    CODEPAGE_CP863: Result := 'CP863';
    CODEPAGE_CP865: Result := 'CP865';
    CODEPAGE_WEST_EUROPE: Result := 'WEST_EUROPE';
    CODEPAGE_GREEK: Result := 'GREEK';
    CODEPAGE_HEBREW: Result := 'HEBREW';
    CODEPAGE_EAST_EUROPE: Result := 'EAST_EUROPE';
    CODEPAGE_IRAN: Result := 'IRAN';
    CODEPAGE_WCP1252: Result := 'WCP1252';
    CODEPAGE_CP866: Result := 'CP866';
    CODEPAGE_PC852: Result := 'PC852';
    CODEPAGE_PC858: Result := 'PC858';
    CODEPAGE_IRAN2: Result := 'IRAN2';
    CODEPAGE_LATVIAN: Result := 'LATVIAN';
    CODEPAGE_ARABIC: Result := 'ARABIC';
    CODEPAGE_PT1511251: Result := 'PT1511251';
    CODEPAGE_PC747: Result := 'PC747';
    CODEPAGE_WCP1257: Result := 'WCP1257';
    CODEPAGE_VIETNAM: Result := 'VIETNAM';
    CODEPAGE_PC864: Result := 'PC864';
    CODEPAGE_PC1001: Result := 'PC1001';
    CODEPAGE_UIGUR: Result := 'UIGUR';
    CODEPAGE_HEBREW_2: Result := 'HEBREW_2';
    CODEPAGE_WCP1255: Result := 'WCP1255';
    CODEPAGE_WCP1256: Result := 'WCP1256';
    CODEPAGE_PC437: Result := 'PC437';
    CODEPAGE_KATAKANA2: Result := 'KATAKANA2';
    CODEPAGE_PC437_STD_EUROPE: Result := 'PC437_STD_EUROPE';
    CODEPAGE_PC858_MULT: Result := 'PC858_MULT';
    CODEPAGE_PC852_LATIN_2: Result := 'PC852_LATIN_2';
    CODEPAGE_PC860_PORTUGU: Result := 'PC860_PORTUGU';
    CODEPAGE_PC861_ICELANDIC: Result := 'PC861_ICELANDIC';
    CODEPAGE_PC863_CANADIAN: Result := 'PC863_CANADIAN';
    CODEPAGE_PC865_NORDIC: Result := 'PC865_NORDIC';
    CODEPAGE_PC866_RUSSIAN: Result := 'PC866_RUSSIAN';
    CODEPAGE_PC855_BULGARIAN: Result := 'PC855_BULGARIAN';
    CODEPAGE_PC857_TURKEY: Result := 'PC857_TURKEY';
    CODEPAGE_PC862_HEBREW: Result := 'PC862_HEBREW';
    CODEPAGE_PC864_ARABIC: Result := 'PC864_ARABIC';
    CODEPAGE_PC737_GREEK: Result := 'PC737_GREEK';
    CODEPAGE_PC851_GREEK: Result := 'PC851_GREEK';
    CODEPAGE_PC869_GREEK: Result := 'PC869_GREEK';
    CODEPAGE_PC928_GREEK: Result := 'PC928_GREEK';
    CODEPAGE_PC772_LITHUANIAN: Result := 'PC772_LITHUANIAN';
    CODEPAGE_PC774_LITHUAN: Result := 'PC774_LITHUAN';
    CODEPAGE_PC874_THAI: Result := 'PC874_THAI';
    CODEPAGE_WPC1252_LATINL: Result := 'WPC1252_LATINL';
    CODEPAGE_WCP1250: Result := 'WCP1250';
    CODEPAGE_WCP1251: Result := 'WCP1251';
    CODEPAGE_PC3840_IBM_RUSSIAN: Result := 'PC3840_IBM_RUSSIAN';
    CODEPAGE_PC3841_GOST: Result := 'PC3841_GOST';
    CODEPAGE_PC3843_POLISH: Result := 'PC3843_POLISH';
    CODEPAGE_PC3844_CS2: Result := 'PC3844_CS2';
    CODEPAGE_PC3845_HUNGARIAN: Result := 'PC3845_HUNGARIAN';
    CODEPAGE_PC3846_TURKISH: Result := 'PC3846_TURKISH';
    CODEPAGE_PC3847_BRAZI1_ABNI: Result := 'PC3847_BRAZI1_ABNI';
    CODEPAGE_PC3848_BRAZIL: Result := 'PC3848_BRAZIL';
    CODEPAGE_PC1001_ARABIC: Result := 'PC1001_ARABIC';
    CODEPAGE_PC2001_LITHUAN: Result := 'PC2001_LITHUAN';
    CODEPAGE_PC3001_ESTONIAN_1: Result := 'PC3001_ESTONIAN_1';
    CODEPAGE_PC3002_ESTON_2: Result := 'PC3002_ESTON_2';
    CODEPAGE_PC3011_LATVIAN_1: Result := 'PC3011_LATVIAN_1';
    CODEPAGE_PC3012_LATV_2: Result := 'PC3012_LATV_2';
    CODEPAGE_PC3021_BULGARIAN: Result := 'PC3021_BULGARIAN';
    CODEPAGE_PC3041_MALTESE: Result := 'PC3041_MALTESE';
  else
    Result := 'Unknown codepage';
  end;
end;

{ TEscPrinterXPrinter }

constructor TEscPrinterXPrinter.Create(APort: IPrinterPort; ALogger: ILogFile);
begin
  inherited Create;
  FPort := APort;
  FLogger := ALogger;
  FDeviceMetrics.PrintWidth := 576;
  FUserChars := TCharCodes.Create(TCharCode);
  FFont := FONT_TYPE_A;
end;

destructor TEscPrinterXPrinter.Destroy;
begin
  FUserChars.Free;
  inherited Destroy;
end;

procedure TEscPrinterXPrinter.Send(const Data: AnsiString);
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

function TEscPrinterXPrinter.ReadByte: Byte;
begin
  Result := Ord(FPort.Read(1)[1]);
end;

function TEscPrinterXPrinter.ReadAnsiString: AnsiString;
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

procedure TEscPrinterXPrinter.CarriageReturn;
begin
  Send(CR);
end;

procedure TEscPrinterXPrinter.HorizontalTab;
begin
  Send(HT);
end;

procedure TEscPrinterXPrinter.LineFeed;
begin
  Logger.Debug('TEscPrinterXPrinter.LineFeed');
  Send(LF);
end;

function TEscPrinterXPrinter.ReadPrinterStatus: TPrinterStatus;
begin
  Logger.Debug('TEscPrinterXPrinter.ReadPrinterStatus');
  CheckCapRead;

  FPort.Lock;
  try
    Send(#$10#$04#$01);
    Result.DrawerOpened := TestBit(ReadByte, 2);
  finally
    FPort.Unlock;
  end;
end;

function TEscPrinterXPrinter.ReadOfflineStatus: TOfflineStatus;
var
  B: Byte;
begin
  Logger.Debug('TEscPrinterXPrinter.ReadOfflineStatus');
  
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

function TEscPrinterXPrinter.ReadErrorStatus: TErrorStatus;
var
  B: Byte;
begin
  Logger.Debug('TEscPrinterXPrinter.ReadErrorStatus');
  
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

function TEscPrinterXPrinter.ReadPaperStatus: TPaperStatus;
var
  B: Byte;
begin
  Logger.Debug('TEscPrinterXPrinter.ReadPaperStatus');
  
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

procedure TEscPrinterXPrinter.RecoverError(ClearBuffer: Boolean);
begin
  Logger.Debug(WideFormat('TEscPrinterXPrinter.RecoverError(ClearBuffer=%s)', [
    BoolToStr(ClearBuffer)]));

  if ClearBuffer then
    Send(#$10#$05#$02)
  else
    Send(#$10#$05#$01);
end;

procedure TEscPrinterXPrinter.GeneratePulse(n, m, t: Byte);
begin
  Logger.Debug(WideFormat('TEscPrinterXPrinter.GeneratePulse(%d, %d, %d)', [n, m, t]));
  Send(#$10#$14 + Chr(n) + Chr(m) + Chr(t));
end;

procedure TEscPrinterXPrinter.SetRightSideCharacterSpacing(n: Byte);
begin
  Logger.Debug(WideFormat('TEscPrinterXPrinter.SetRightSideCharacterSpacing(n)', [n]));
  Send(#$1B#$20 + Chr(n));
end;

procedure TEscPrinterXPrinter.SelectPrintMode(Mode: TPrintMode);
begin
  SetPrintMode(PrintModeToByte(Mode));
end;

procedure TEscPrinterXPrinter.SetPrintMode(Mode: Byte);
begin
  Logger.Debug(WideFormat('TEscPrinterXPrinter.SetPrintMode(%d)', [Mode]));
  Send(#$1B#$21 + Chr(Mode));

  FFont := FONT_TYPE_A;
  if TestBit(Mode, 0) then
    FFont := FONT_TYPE_B;
end;

procedure TEscPrinterXPrinter.SetAbsolutePrintPosition(n: Word);
begin
  Logger.Debug(WideFormat('TEscPrinterXPrinter.SetAbsolutePrintPosition(%d)', [n]));
  Send(#$1B#$24 + Chr(Lo(n)) + Chr(Hi(n)));
end;

procedure TEscPrinterXPrinter.SelectUserCharacter(n: Byte);
begin
  if n = FUserCharacterMode then Exit;

  Logger.Debug(WideFormat('TEscPrinterXPrinter.SelectUserCharacter(%d)', [n]));
  Send(#$1B#$25 + Chr(n));
  FUserCharacterMode := n;
end;

procedure TEscPrinterXPrinter.EnableUserCharacters;
begin
  SelectUserCharacter(1);
end;

procedure TEscPrinterXPrinter.DisableUserCharacters;
begin
  SelectUserCharacter(0);
end;

procedure TEscPrinterXPrinter.CheckUserCharCode(Code: Byte);
begin
  if (not Code in [USER_CHAR_CODE_MIN..USER_CHAR_CODE_MAX]) then
    raise UserException.CreateFmt('Invalid character code, 0x%.2X', [Code]);
end;

///////////////////////////////////////////////////////////////////////////////
// Font A 12x24, font B 9x17
///////////////////////////////////////////////////////////////////////////////
// The allowable character code range is from ASCII code <20>H to
// <7E>H (95 characters).

procedure TEscPrinterXPrinter.WriteUserChar(AChar: WideChar; ACode, AFont: Byte);
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

procedure TEscPrinterXPrinter.WriteUserChar2(AChar: WideChar; ACode, AFont: Byte);
var
  Bitmap: TBitmap;
  FileName: string;
  UserChar: TUserChar;
begin
  CheckUserCharCode(ACode);
  Bitmap := TBitmap.Create;
  try
    FileName := GetModulePath + Tnt_WideFormat('UserChars\UnicodeChar_%d_%d.bmp', [AFont, Ord(AChar)]);
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
0 „T x „T 12 (when Font A (12X24) is
selected) 0 „T x „T 9 (when Font B (9X17) is
selected)

*)

procedure TEscPrinterXPrinter.DefineUserCharacter(C: TUserChar);
begin
  Logger.Debug('TEscPrinterXPrinter.DefineUserCharacter');
  Send(#$1B#$26#$03 + Chr(C.c1) + Chr(C.c2) + Chr(C.Width) + C.Data);
end;

procedure TEscPrinterXPrinter.SelectBitImageMode(mode: Integer; Image: TGraphic);
var
  n: Word;
  data: AnsiString;
begin
  Logger.Debug('TEscPrinterXPrinter.SelectBitImageMode');

  n := Image.Width;
  data := GetImageData2(Image);
  Send(#$1B#$2A + Chr(Mode) + Chr(Lo(n)) + Chr(Hi(n)) + data);
end;

procedure TEscPrinterXPrinter.SetUnderlineMode(n: Byte);
begin
  Logger.Debug('TEscPrinterXPrinter.SetUnderlineMode');
  Send(#$1B#$2D + Chr(n));
end;

procedure TEscPrinterXPrinter.SetDefaultLineSpacing;
begin
  Logger.Debug('TEscPrinterXPrinter.SetDefaultLineSpacing');
  Send(#$1B#$32);
end;

procedure TEscPrinterXPrinter.SetLineSpacing(n: Byte);
begin
  Logger.Debug('TEscPrinterXPrinter.SetLineSpacing');
  Send(#$1B#$33 + Chr(n));
end;

procedure TEscPrinterXPrinter.CancelUserCharacter(n: Byte);
begin
  Logger.Debug('TEscPrinterXPrinter.CancelUserCharacter');
  Send(#$1B#$3F + Chr(n));
end;

procedure TEscPrinterXPrinter.Initialize;
begin
  Logger.Debug('TEscPrinterXPrinter.Initialize');
  Send(#$1B#$40);

  FUserChars.Clear;
  FCodePage := 0;
  FTextCodePage := 866;
  FUserCharacterMode := 0;
  FInTransaction := False;
  FFont := FONT_TYPE_A;
end;

procedure TEscPrinterXPrinter.SetBeepParams(N, T: Byte);
begin
  Logger.Debug('TEscPrinterXPrinter.SetBeepParams');
  Send(#$1B#$42 + Chr(N) + Chr(T));
end;

procedure TEscPrinterXPrinter.SetHorizontalTabPositions(Tabs: AnsiString);
begin
  Logger.Debug('TEscPrinterXPrinter.SetHorizontalTabPositions');
  Send(#$1B#$44 + Tabs + #0);
end;

procedure TEscPrinterXPrinter.SetEmphasizedMode(Value: Boolean);
begin
  Logger.Debug('TEscPrinterXPrinter.SetEmphasizedMode');
  Send(#$1B#$45 + Chr(BoolToInt[Value]));
end;

procedure TEscPrinterXPrinter.SetDoubleStrikeMode(Value: Boolean);
begin
  Logger.Debug('TEscPrinterXPrinter.SetDoubleStrikeMode');
  Send(#$1B#$47 + Chr(BoolToInt[Value]));
end;

procedure TEscPrinterXPrinter.PrintAndFeed(n: Byte);
begin
  Logger.Debug('TEscPrinterXPrinter.PrintAndFeed');
  Send(#$1B#$4A + Chr(n));
end;

procedure TEscPrinterXPrinter.SetCharacterFont(n: Byte);
begin
  if n = FFont then Exit;

  Logger.Debug(WideFormat('TEscPrinterXPrinter.SetCharacterFont(%d)', [n]));
  if n in [FONT_TYPE_MIN..FONT_TYPE_MAX] then
  begin
    Send(#$1B#$4D + Chr(n));
    FFont := n;
  end;
end;

procedure TEscPrinterXPrinter.SetCharacterSet(N: Byte);
begin
  Logger.Debug('TEscPrinterXPrinter.SetCharacterSet');
  Send(#$1B#$52 + Chr(N));
end;

procedure TEscPrinterXPrinter.Set90ClockwiseRotation(Value: Boolean);
begin
  Logger.Debug('TEscPrinterXPrinter.Set90ClockwiseRotation');
  Send(#$1B#$56 + Chr(BoolToInt[Value]));
end;

procedure TEscPrinterXPrinter.SetRelativePrintPosition(n: Word);
begin
  Logger.Debug('TEscPrinterXPrinter.SetRelativePrintPosition');
  Send(#$1B#$5C + Chr(Lo(n)) + Chr(Hi(n)));
end;

procedure TEscPrinterXPrinter.SetJustification(N: Byte);
begin
  Logger.Debug('TEscPrinterXPrinter.SetJustification');
  Send(#$1B#$61 + Chr(N));
end;

procedure TEscPrinterXPrinter.EnableButtons(Value: Boolean);
begin
  Logger.Debug('TEscPrinterXPrinter.EnableButtons');
  Send(#$1B#$63#$35 + Chr(BoolToInt[Value]));
end;

procedure TEscPrinterXPrinter.PrintAndFeedLines(N: Byte);
begin
  Logger.Debug('TEscPrinterXPrinter.PrintAndFeedLines');
  Send(#$1B#$64 + Chr(N));
end;

procedure TEscPrinterXPrinter.SetCodePage(CodePage: Integer);
begin
  if FCodePage = CodePage then Exit;
  Logger.Debug(WideFormat('TEscPrinterXPrinter.SetCodePage(%d, %s)', [
    CodePage, GetCodePageName(CodePage)]));

  Send(#$1B#$74 + Chr(CodePage));
  FCodePage := CodePage;
end;

procedure TEscPrinterXPrinter.SetUpsideDownPrinting(Value: Boolean);
begin
  Logger.Debug('TEscPrinterXPrinter.SetUpsideDownPrinting');
  Send(#$1B#$7B + Chr(BoolToInt[Value]));
end;

procedure TEscPrinterXPrinter.PartialCut;
begin
  Logger.Debug('TEscPrinterXPrinter.PartialCut');
  Send(#$1B#$69);
end;

procedure TEscPrinterXPrinter.PartialCut2;
begin
  Logger.Debug('TEscPrinterXPrinter.PartialCut2');
  Send(#$1B#$6D);
end;

procedure TEscPrinterXPrinter.SelectChineseCode(N: Byte);
begin
  Logger.Debug('TEscPrinterXPrinter.SelectChineseCode');
  Send(#$1B#$39 + Chr(N));
end;

procedure TEscPrinterXPrinter.PrintNVBitImage(Number, Mode: Byte);
begin
  Logger.Debug('TEscPrinterXPrinter.PrintNVBitImage');
  Send(#$1C#$70 + Chr(Number) + Chr(Mode));
end;

procedure TEscPrinterXPrinter.DefineNVBitImage(Number: Byte; Image: TGraphic);
var
  x, y: Integer;
  Bitmap: TBitmap;
begin
  Logger.Debug('TEscPrinterXPrinter.DefineNVBitImage');

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

procedure TEscPrinterXPrinter.SetCharacterSize(N: Byte);
begin
  Logger.Debug('TEscPrinterXPrinter.SetCharacterSize');
  Send(#$1D#$21 + Chr(N));
end;

procedure TEscPrinterXPrinter.DownloadBMP(Image: TGraphic);
var
  x, y: Byte;
  Bitmap: TBitmap;
begin
  Logger.Debug('TEscPrinterXPrinter.DownloadBMP');
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

procedure TEscPrinterXPrinter.PrintBmp(Mode: Byte);
begin
  Logger.Debug('TEscPrinterXPrinter.PrintBmp');
  Send(#$1D#$2F + Chr(Mode));
end;

procedure TEscPrinterXPrinter.SetWhiteBlackReverse(Value: Boolean);
begin
  Logger.Debug('TEscPrinterXPrinter.SetWhiteBlackReverse');
  Send(#$1D#$42 + Chr(BoolToInt[Value]));
end;

procedure TEscPrinterXPrinter.SetHRIPosition(N: Byte);
begin
  Logger.Debug('TEscPrinterXPrinter.SetHRIPosition');
  Send(#$1D#$48 + Chr(N));
end;

procedure TEscPrinterXPrinter.SetLeftMargin(N: Word);
begin
  Logger.Debug('TEscPrinterXPrinter.SetLeftMargin');
  Send(#$1D#$4C + Chr(Lo(N)) + Chr(Hi(N)));
end;

procedure TEscPrinterXPrinter.SetCutModeAndCutPaper(M: Byte);
begin
  Logger.Debug('TEscPrinterXPrinter.SetCutModeAndCutPaper');
  Send(#$1D#$56 + Chr(M));
end;

procedure TEscPrinterXPrinter.SetCutModeAndCutPaper2(n: Byte);
begin
  Logger.Debug('TEscPrinterXPrinter.SetCutModeAndCutPaper2');
  Send(#$1D#$56#$66 + Chr(n));
end;

procedure TEscPrinterXPrinter.SetPrintAreaWidth(n: Byte);
begin
  Logger.Debug('TEscPrinterXPrinter.SetPrintAreaWidth');
  Send(#$1D#$57 + Chr(Lo(n)) + Chr(Hi(n)));
end;

procedure TEscPrinterXPrinter.StartEndMacroDefinition;
begin
  Logger.Debug('TEscPrinterXPrinter.StartEndMacroDefinition');
  Send(#$1D#$3A);
end;

procedure TEscPrinterXPrinter.ExecuteMacro(r, t, m: Byte);
begin
  Logger.Debug('TEscPrinterXPrinter.ExecuteMacro');
  Send(#$1D#$5E + Chr(r) + Chr(t) + Chr(m));
end;

procedure TEscPrinterXPrinter.EnableAutomaticStatusBack(N: Byte);
begin
  Logger.Debug('TEscPrinterXPrinter.EnableAutomaticStatusBack');
  Send(#$1D#$61 + Chr(N));
end;

procedure TEscPrinterXPrinter.SetHRIFont(N: Byte);
begin
  Logger.Debug('TEscPrinterXPrinter.SetHRIFont');
  Send(#$1D#$66 + Chr(N));
end;

procedure TEscPrinterXPrinter.SetBarcodeHeight(N: Byte);
begin
  Logger.Debug('TEscPrinterXPrinter.SetBarcodeHeight');
  Send(#$1D#$68 + Chr(N));
end;

procedure TEscPrinterXPrinter.PrintBarcode(BCType: Byte; const Data: AnsiString);
begin
  Logger.Debug('TEscPrinterXPrinter.PrintBarcode');
  Send(#$1D#$6B + Chr(BCType) + Data + #0);
end;

procedure TEscPrinterXPrinter.PrintBarcode2(BCType: Byte; const Data: AnsiString);
begin
  Logger.Debug('TEscPrinterXPrinter.PrintBarcode2');
  Send(#$1D#$6B + Chr(BCType) + Chr(Length(Data)) + Data);
end;

function TEscPrinterXPrinter.ReadPaperRollStatus: TPaperRollStatus;
begin
  Logger.Debug('TEscPrinterXPrinter.ReadPaperRollStatus');

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
procedure TEscPrinterXPrinter.PrintRasterBMP(Mode: Byte; Image: TGraphic);
var
  x, y: Byte;
begin
  Logger.Debug('TEscPrinterXPrinter.PrintRasterBMP');

  x := (Image.Width + 7) div 8;
  y := Image.Height;
  Send(#$1D#$76#$30 + Chr(Mode) + Chr(Lo(x)) + Chr(Hi(x)) +
    Chr(Lo(y)) + Chr(Hi(y)) + GetRasterImageData(Image));
end;

procedure TEscPrinterXPrinter.SetBarcodeWidth(N: Integer);
begin
  Logger.Debug('TEscPrinterXPrinter.SetBarcodeWidth');
  Send(#$1D#$77 + Chr(N));
end;

procedure TEscPrinterXPrinter.SetBarcodeLeft(N: Integer);
begin
  Logger.Debug('TEscPrinterXPrinter.SetBarcodeLeft');
  Send(#$1D#$78 + Chr(N));
end;

procedure TEscPrinterXPrinter.SetMotionUnits(x, y: Integer);
begin
  Logger.Debug('TEscPrinterXPrinter.SetMotionUnits');
  Send(#$1D#$50 + Chr(x) + Chr(y));
end;

procedure TEscPrinterXPrinter.PrintTestPage;
begin
  Logger.Debug('TEscPrinterXPrinter.PrintTestPage');
  Send(#$1F#$1B#$1F#$67#$00);
end;

procedure TEscPrinterXPrinter.SetKanjiMode(m: Byte);
begin
  Logger.Debug('TEscPrinterXPrinter.SetKanjiMode');
  Send(#$1C#$21 + Chr(m));
end;

procedure TEscPrinterXPrinter.SelectKanjiCharacter;
begin
  Logger.Debug('TEscPrinterXPrinter.SelectKanjiCharacter');
  Send(#$1C#$26);
end;

procedure TEscPrinterXPrinter.SetKanjiUnderline(Value: Boolean);
begin
  Logger.Debug('TEscPrinterXPrinter.SetKanjiUnderline');
  Send(#$1C#$2D + Chr(BoolToInt[Value]));
end;

procedure TEscPrinterXPrinter.CancelKanjiCharacter;
begin
  Logger.Debug('TEscPrinterXPrinter.CancelKanjiCharacter');
  Send(#$1C#$2E);
end;

procedure TEscPrinterXPrinter.DefineKanjiCharacters(c1, c2: Byte;
  const data: AnsiString);
begin
  Logger.Debug('TEscPrinterXPrinter.DefineKanjiCharacters');
  Send(#$1C#$32 + Chr(c1) + Chr(c2) + data);
end;

procedure TEscPrinterXPrinter.SetPeripheralDevice(m: Byte);
begin
  Logger.Debug('TEscPrinterXPrinter.SetPeripheralDevice');
  Send(#$1B#$3D + Chr(m));
end;

procedure TEscPrinterXPrinter.SetKanjiSpacing(n1, n2: Byte);
begin
  Logger.Debug('TEscPrinterXPrinter.SetKanjiSpacing');
  Send(#$1C#$53 + Chr(n1) + Chr(n2));
end;

procedure TEscPrinterXPrinter.PrintAndReturnStandardMode;
begin
  Logger.Debug('TEscPrinterXPrinter.PrintAndReturnStandardMode');
  Send(#$0C);
end;

procedure TEscPrinterXPrinter.PrintDataInMode;
begin
  Logger.Debug('TEscPrinterXPrinter.PrintDataInMode');
  Send(#$1B#$0C);
end;

procedure TEscPrinterXPrinter.SetPageMode;
begin
  Logger.Debug('TEscPrinterXPrinter.SetPageMode');
  Send(#$1B#$4C);
end;

procedure TEscPrinterXPrinter.SetStandardMode;
begin
  Logger.Debug('TEscPrinterXPrinter.SetStandardMode');
  Send(#$1B#$53);
end;

procedure TEscPrinterXPrinter.SetPageModeDirection(n: Byte);
begin
  Logger.Debug('TEscPrinterXPrinter.SetPageModeDirection');
  Send(#$1B#$54 + Chr(n));
end;

procedure TEscPrinterXPrinter.SetPageModeArea(R: TPageArea);
begin
  Logger.Debug(WideFormat('TEscPrinterXPrinter.SetPageModeArea(%d,%d,%d,%d)', [
    R.X, R.Y, R.Width, R.Height]));

  Send(#$1B#$57 +
    Chr(Lo(R.X)) + Chr(Hi(R.X)) +
    Chr(Lo(R.Y)) + Chr(Hi(R.Y)) +
    Chr(Lo(R.Width)) + Chr(Hi(R.Width)) +
    Chr(Lo(R.Height)) + Chr(Hi(R.Height)));
end;

procedure TEscPrinterXPrinter.SetKanjiQuadSizeMode(Value: Boolean);
begin
  Logger.Debug('TEscPrinterXPrinter.SetKanjiQuadSizeMode');
  Send(#$1C#$57 + Chr(BoolToInt[Value]));
end;

procedure TEscPrinterXPrinter.FeedMarkedPaper;
begin
  Logger.Debug('TEscPrinterXPrinter.FeedMarkedPaper');
  Send(#$1D#$0C);
end;

procedure TEscPrinterXPrinter.SetPMAbsoluteVerticalPosition(n: Integer);
begin
  Logger.Debug('TEscPrinterXPrinter.SetPMAbsoluteVerticalPosition');
  Send(#$1D#$24 + Chr(Lo(n)) + Chr(Hi(n)));
end;

procedure TEscPrinterXPrinter.ExecuteTestPrint(p: Integer; n, m: Byte);
begin
  Logger.Debug('TEscPrinterXPrinter.ExecuteTestPrint');
  Send(#$1D#$28#$41 + Chr(Lo(p)) + Chr(Hi(p)) + Chr(n) + Chr(m));
end;

procedure TEscPrinterXPrinter.SelectCounterPrintMode(n, m: Byte);
begin
  Logger.Debug('TEscPrinterXPrinter.SelectCounterPrintMode');
  Send(#$1D#$43#$30 + Chr(n) + Chr(m));
end;

procedure TEscPrinterXPrinter.SelectCountMode(a, b: Word; n, r: Byte);
begin
  Logger.Debug('TEscPrinterXPrinter.SelectCountMode');
  Send(#$1D#$43#$31 + Chr(Lo(a)) + Chr(Hi(a)) +
    Chr(Lo(b)) + Chr(Hi(b)) + Chr(n) + Chr(r));
end;

procedure TEscPrinterXPrinter.SetCounter(n: Word);
begin
  Logger.Debug('TEscPrinterXPrinter.SetCounter');
  Send(#$1D#$43#$32 + Chr(Lo(n)) + Chr(Hi(n)));
end;

procedure TEscPrinterXPrinter.SetPMRelativeVerticalPosition(n: Word);
begin
  Logger.Debug('TEscPrinterXPrinter.SetPMRelativeVerticalPosition');
  Send(#$1D#$5C + Chr(Lo(n)) + Chr(Hi(n)));
end;

procedure TEscPrinterXPrinter.PrintCounter;
begin
  Logger.Debug('TEscPrinterXPrinter.PrintCounter');
  Send(#$1D#$63);
end;

procedure TEscPrinterXPrinter.SetNormalPrintMode;
var
  PrintMode: TPrintMode;
begin
  Logger.Debug('TEscPrinterXPrinter.SetNormalPrintMode');
  PrintMode.CharacterFontB := False;
  PrintMode.Emphasized := False;
  PrintMode.DoubleHeight := False;
  PrintMode.DoubleWidth := False;
  PrintMode.Underlined := False;
  SelectPrintMode(PrintMode);
end;

procedure TEscPrinterXPrinter.PrintText(Text: AnsiString);
begin
  //Logger.Debug(WideFormat('TEscPrinterXPrinter.PrintText(''%s'')', [TrimRight(Text)]));
  Send(Text);
end;

function TEscPrinterXPrinter.CapRead: Boolean;
begin
  Result := Port.CapRead;
end;

procedure TEscPrinterXPrinter.CheckCapRead;
begin
  if not Port.CapRead then
  begin
    raise UserException.Create(SReadNotSupported);
  end;
end;

procedure TEscPrinterXPrinter.BeginDocument;
begin
  FInTransaction := True;
end;

procedure TEscPrinterXPrinter.EndDocument;
begin
  FInTransaction := False;
  Port.Flush;
end;

procedure TEscPrinterXPrinter.WriteKazakhCharacters;
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

function TEscPrinterXPrinter.IsUserChar(Char: WideChar): Boolean;
begin
  Result := IsKazakhUnicodeChar(Char);
end;

procedure TEscPrinterXPrinter.PrintUserChar(Char: WideChar);
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

procedure TEscPrinterXPrinter.QRCodeSetModuleSize(n: Byte);
begin
  Send(#$1D#$28#$6B#$30#$67 + Chr(n));
end;

procedure TEscPrinterXPrinter.QRCodeSetErrorCorrectionLevel(n: Byte);
begin
  Send(#$1D#$28#$6B#$30#$69 + Chr(n));
end;

procedure TEscPrinterXPrinter.QRCodeWriteData(Data: AnsiString);
var
  L: Word;
  Command: AnsiString;
begin
  L := Length(Data);
  Command := #$1D#$28#$6B#$30#$80 + Chr(Lo(L)) + Chr(Hi(L)) + Data;
  Send(Command);
end;

procedure TEscPrinterXPrinter.QRCodePrint;
begin
  Send(#$1D#$28#$6B#$30#$81);
end;

procedure TEscPrinterXPrinter.printQRCode(const Barcode: TQRCode);
begin
  Logger.Debug('TEscPrinterXPrinter.printQRCode');
  QRCodeSetModuleSize(Barcode.ModuleSize);
  QRCodeSetErrorCorrectionLevel(Barcode.ECLevel);
  QRCodeWriteData(Barcode.Data);
  QRCodePrint;
end;

procedure TEscPrinterXPrinter.PDF417SetColumnNumber(n: Byte);
begin
  Send(#$1D#$28#$6B#$03#$00#$30#$41 + Chr(n));
end;

procedure TEscPrinterXPrinter.PDF417SetRowNumber(n: Byte);
begin
  Send(#$1D#$28#$6B#$03#$00#$30#$42 + Chr(n));
end;

procedure TEscPrinterXPrinter.PDF417SetModuleWidth(n: Byte);
begin
  Send(#$1D#$28#$6B#$03#$00#$30#$43 + Chr(n));
end;

procedure TEscPrinterXPrinter.PDF417SetModuleHeight(n: Byte);
begin
  Send(#$1D#$28#$6B#$03#$00#$30#$44 + Chr(n));
end;

procedure TEscPrinterXPrinter.PDF417SetErrorCorrectionLevel(m, n: Byte);
begin
  Send(#$1D#$28#$6B#$03#$00#$30#$45 + Chr(m) + Chr(n));
end;

procedure TEscPrinterXPrinter.PDF417SetOptions(m: Byte);
begin
  Send(#$1D#$28#$6B#$03#$00#$30#$46 + Chr(m));
end;

procedure TEscPrinterXPrinter.PDF417Write(const data: AnsiString);
var
  L: Word;
begin
  L := Length(Data) + 3;
  Send(#$1D#$28#$6B + Chr(Lo(L)) + Chr(Hi(L)) + #$30#$50#$30 + Data);
end;

procedure TEscPrinterXPrinter.PDF417Print;
begin
  Send(#$1D#$28#$6B#$03#$00#$30#$51#$30);
end;

procedure TEscPrinterXPrinter.PDF417ReadDataSize;
begin
  Send(#$1D#$28#$6B#$03#$00#$30#$52#$30);
  // Read size
end;

procedure TEscPrinterXPrinter.PrintPDF417(const Barcode: TPDF417);
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

procedure TEscPrinterXPrinter.MaxiCodeSetMode(n: Byte);
begin
  Send(#$1D#$28#$6B#$03#$00#$32#$41 + Chr(n));
end;

procedure TEscPrinterXPrinter.MaxiCodeWriteData(const Data: AnsiString);
var
  L: Word;
begin
  L := Length(Data) + 3;
  Send(#$1D#$28#$6B + Chr(Lo(L)) + Chr(Hi(L)) + #$32#$50#$30 + Data);
end;

procedure TEscPrinterXPrinter.MaxiCodePrint;
begin
  Send(#$1D#$28#$6B#$03#$00#$32#$51#$30);
end;

procedure TEscPrinterXPrinter.UTF8Enable(B: Boolean);
begin
  Send(#$1F#$1B#$10#$01#$02 + Chr(BoolToInt[B]));
end;

procedure TEscPrinterXPrinter.SelectCodePage(B: Byte);
begin
  Send(#$1F#$1B#$1F#$FF + Chr(B) + #$0A#$00);
end;

procedure TEscPrinterXPrinter.PrintUnicode(const AText: WideString);
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


(*

1b 70 00 1e ff 00 - OpenCashDrawer
1f 1b 1f 11 11 00 - Reset Factory settings
1f 1b 1f ff 00 0a 00 - set code page 0
1f 1b 1f ff 11 0a 00 - set code page 17
1f 1b 1f 67 00 - print test page

*)

end.

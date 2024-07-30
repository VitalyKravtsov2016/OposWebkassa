unit EscPrinter;

interface

uses
  // VCL
  Windows, Types, SysUtils, Graphics, Classes,
  // Tnt
  TntGraphics,
  // This
  ByteUtils, PrinterPort, RegExpr, StringUtils, LogFile, FileUtils;

const
  SupportedCodePages: array [0..36] of Integer = (
    437,720,737,755,775,850,852,855,856,857,858,860,862,863,864,865,866,874,
    1250,1251,1252,1253,1254,1255,1256,1257,1258,
    28591,28592,28593,28594,28595,28596,28597,28598,28599,28605);

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

  CODEPAGE_CP437        = 0;
  CODEPAGE_KATAKANA     = 1;
  CODEPAGE_CP850        = 2;
  CODEPAGE_CP860        = 3;
  CODEPAGE_CP863        = 4; // CANADIAN-FRENCH
  CODEPAGE_CP865        = 5;
  CODEPAGE_WCP1251      = 6;
  CODEPAGE_CP866        = 7;
  CODEPAGE_MIK          = 8;
  CODEPAGE_CP755        = 9;
  CODEPAGE_IRAN         = 10;
  CODEPAGE_RESERVE      = 11;
  CODEPAGE_CP862        = 15;
  CODEPAGE_WCP1252      = 16;
  CODEPAGE_WCP1253      = 17;
  CODEPAGE_CP852        = 18;
  CODEPAGE_CP858        = 19;
  CODEPAGE_IRAN_II      = 20;
  CODEPAGE_LATVIAN      = 21;
  CODEPAGE_CP864        = 22;
  CODEPAGE_ISO_8859_1   = 23;
  CODEPAGE_CP737        = 24;
  CODEPAGE_WCP1257      = 25;
  CODEPAGE_THAI         = 26;
  CODEPAGE_CP720_ARABIC = 27;
  CODEPAGE_CP855        = 28;
  CODEPAGE_CP857        = 29;
  CODEPAGE_WCP1250      = 30;
  CODEPAGE_CP775        = 31;
  CODEPAGE_WCP1254      = 32;
  CODEPAGE_WCP1255      = 33;
  CODEPAGE_WCP1256      = 34;
  CODEPAGE_WCP1258      = 35;
  CODEPAGE_ISO_8859_2   = 36;
  CODEPAGE_ISO_8859_3   = 37;
  CODEPAGE_ISO_8859_4   = 38;
  CODEPAGE_ISO_8859_5   = 39;
  CODEPAGE_ISO_8859_6   = 40;
  CODEPAGE_ISO_8859_7   = 41;
  CODEPAGE_ISO_8859_8   = 42;
  CODEPAGE_ISO_8859_9   = 43;
  CODEPAGE_ISO_8859_15  = 44;
  CODEPAGE_THAI2        = 45;
  CODEPAGE_CP856        = 46;
  CODEPAGE_CP874        = 47;

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
  // Barcode constants to select 2D barcode, 1D5A command

  BARCODE_PDF417    = 0;
  BARCODE_QR_CODE   = 1;

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

  KazakhUnicodeChars: array [0..17] of Integer = (
    1170, // cyrillic capital letter ghe stroke
    1171, // cyrillic small letter ghe stroke
    1178, // cyrillic capital letter ka descender
    1179, // cyrillic small letter ka descender
    1186, // cyrillic capital letter en descender
    1187, // cyrillic small letter en descender
    1198, // cyrillic capital letter straight u
    1199, // cyrillic small letter straight u
    1200, // cyrillic capital letter straight u stroke
    1201, // cyrillic small letter straight u stroke
    1210, // cyrillic capital letter shha
    1211, // cyrillic small letter shha
    1240, // cyrillic capital letter schwa
    1241, // cyrillic small letter schwa
    1256, // cyrillic capital letter barred o
    1257, // cyrillic small letter barred o
    64488, // arabic letter uighur kazakh kirghiz alef maksura initial form
    64489 // arabic letter uighur kazakh kirghiz alef maksura medial form
  );

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

  { TPrintMode }

  TPrintMode = record
    CharacterFontB: Boolean;
    Emphasized: Boolean;
    DoubleHeight: Boolean;
    DoubleWidth: Boolean;
    Underlined: Boolean;
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
    ColumnNumber: Byte; // 1..30
    SecurityLevel: Byte; // 0..8
    HVRatio: Byte; // 2..5
    data: AnsiString;
  end;

  { TQRCode }

  TQRCode = record
    SymbolVersion: Byte; // 1~40, 0:auto size
    ECLevel: Byte; // 1..19
    ModuleSize: Byte; // 1..8
    data: AnsiString;
  end;

  { TUserCharacter }

  TUserCharacter = class(TCollectionItem)
  private
    FCode: Byte;
    FFont: Byte;
    FChar: WideChar;
  public
    property Code: Byte read FCode;
    property Font: Byte read FFont;
    property Char: WideChar read FChar;
  end;

  { TUserCharacters }

  TUserCharacters = class(TCollection)
  private
    function GetItem(Index: Integer): TUserCharacter;
    procedure Remove(Char: WideChar);
  public
    function ItemByChar(Char: WideChar): TUserCharacter;
    function Add(Code: Byte; Char: WideChar; Font: Byte): TUserCharacter;
    property Items[Index: Integer]: TUserCharacter read GetItem; default;
  end;

  { TEscPrinter }

  TEscPrinter = class
  private
    FLogger: ILogFile;
    FPort: IPrinterPort;
    FCodePage: Integer;
    FUserCharCode: Byte;
    FInTransaction: Boolean;
    FUserCharacterMode: Integer;
    FUserChars: TUserCharacters;
    FDeviceMetrics: TDeviceMetrics;
    procedure CheckUserCharCode(Code: Byte);
    procedure ClearUserChars;
  public
    procedure EnableUserCharacters;
    procedure DisableUserCharacters;
    procedure WriteKazakhCharacters2;
    procedure WriteKazakhCharactersToBitmap;
    function GetImageData(Image: TGraphic): AnsiString;
    function GetBitmapData(Bitmap: TBitmap): AnsiString;
    function GetRasterBitmapData(Bitmap: TBitmap): AnsiString;
    function GetRasterImageData(Image: TGraphic): AnsiString;
    function GetImageData2(Image: TGraphic): AnsiString;
    procedure DrawImage(Image: TGraphic; Bitmap: TBitmap);
    procedure DrawWideChar(AChar: WideChar; AFont: Byte; Bitmap: TBitmap; X, Y: Integer);
    function GetFontData(Bitmap: TBitmap): AnsiString;
  public
    constructor Create(APort: IPrinterPort; ALogger: ILogFile);
    destructor Destroy; override;

    procedure CheckCapRead;
    function ReadByte: Byte;
    function CapRead: Boolean;
    function ReadAnsiString: AnsiString;
    procedure Send(const Data: AnsiString);

    procedure PortFlush;
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
    procedure SetPageModeArea(R: TRect);
    procedure printBarcode2D(m, n, k: Byte; const data: AnsiString);
    procedure printPDF417(const Barcode: TPDF417);
    procedure printQRCode(const Barcode: TQRCode);
    procedure SetKanjiQuadSizeMode(Value: Boolean);
    procedure FeedMarkedPaper;
    procedure SetPMAbsoluteVerticalPosition(n: Integer);
    procedure ExecuteTestPrint(p: Integer; n, m: Byte);
    procedure SelectCounterPrintMode(n, m: Byte);
    procedure SelectCountMode(a, b: Word; n, r: Byte);
    procedure SetCounter(n: Word);
    procedure Select2DBarcode(n: Byte);
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
    function IsUserChar(Char: WideChar): Boolean;

    property Port: IPrinterPort read FPort;
    property Logger: ILogFile read FLogger;
    property CodePage: Integer read FCodePage;
    property DeviceMetrics: TDeviceMetrics read FDeviceMetrics write FDeviceMetrics;
  end;

function IsKazakhUnicodeChar(Char: WideChar): Boolean;
function CharacterSetToPrinterCodePage(CharacterSet: Integer): Integer;

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
    720: Result := CODEPAGE_CP720_ARABIC;
    737: Result := CODEPAGE_CP737;
    755: Result := CODEPAGE_CP755;
    775: Result := CODEPAGE_CP775;
    850: Result := CODEPAGE_CP850;
    852: Result := CODEPAGE_CP852;
    855: Result := CODEPAGE_CP855;
    856: Result := CODEPAGE_CP856;
    857: Result := CODEPAGE_CP857;
    858: Result := CODEPAGE_CP858;
    860: Result := CODEPAGE_CP860;
    862: Result := CODEPAGE_CP862;
    863: Result := CODEPAGE_CP863;
    864: Result := CODEPAGE_CP864;
    865: Result := CODEPAGE_CP865;
    866: Result := CODEPAGE_CP866;
    874: Result := CODEPAGE_CP874;

    1250: Result := CODEPAGE_WCP1250;
    1251: Result := CODEPAGE_WCP1251;
    1252: Result := CODEPAGE_WCP1252;
    1253: Result := CODEPAGE_WCP1253;
    1254: Result := CODEPAGE_WCP1254;
    1255: Result := CODEPAGE_WCP1255;
    1256: Result := CODEPAGE_WCP1256;
    1257: Result := CODEPAGE_WCP1257;
    1258: Result := CODEPAGE_WCP1258;

    28591: Result := CODEPAGE_ISO_8859_1;
    28592: Result := CODEPAGE_ISO_8859_2;
    28593: Result := CODEPAGE_ISO_8859_3;
    28594: Result := CODEPAGE_ISO_8859_4;
    28595: Result := CODEPAGE_ISO_8859_5;
    28596: Result := CODEPAGE_ISO_8859_6;
    28597: Result := CODEPAGE_ISO_8859_7;
    28598: Result := CODEPAGE_ISO_8859_8;
    28599: Result := CODEPAGE_ISO_8859_9;
    28605: Result := CODEPAGE_ISO_8859_15;
  else
    raise Exception.Create('Character set not supported');
  end;
end;

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

{ TUserChars }

procedure TUserCharacters.Remove(Char: WideChar);
var
  i: Integer;
  Item: TUserCharacter;
begin
  for i := Count-1 downto 0 do
  begin
    Item := Items[i];
    if Item.Char = Char then
    begin
      Item.Free;
    end;
  end;
end;

function TUserCharacters.ItemByChar(Char: WideChar): TUserCharacter;
var
  i: Integer;
begin
  for i := 0 to Count-1 do
  begin
    Result := Items[i];
    if Result.Char = Char then Exit;
  end;
  Result := nil;
end;

function TUserCharacters.Add(Code: Byte; Char: WideChar; Font: Byte): TUserCharacter;
begin
  Remove(Char);
  Result := TUserCharacter.Create(Self);
  Result.FCode := Code;
  Result.FChar := Char;
  Result.FFont := Font;
end;

function TUserCharacters.GetItem(Index: Integer): TUserCharacter;
begin
  Result := inherited Items[Index] as TUserCharacter;
end;

{ TEscPrinter }

constructor TEscPrinter.Create(APort: IPrinterPort; ALogger: ILogFile);
begin
  inherited Create;
  FPort := APort;
  FLogger := ALogger;
  FDeviceMetrics.PrintWidth := 576;
  FUserChars := TUserCharacters.Create(TUserCharacter);
end;

destructor TEscPrinter.Destroy;
begin
  FUserChars.Free;
  inherited Destroy;
end;

procedure TEscPrinter.ClearUserChars;
begin
  FUserChars.Clear;
  FUserCharCode := USER_CHAR_CODE_MIN;
end;

procedure TEscPrinter.Send(const Data: AnsiString);
begin
  FPort.Lock;
  try
    FLogger.Debug('-> ' + StrToHex(Data));
    //FPort.Purge; !!!
    FPort.Write(Data);
    if not FInTransaction then
    begin
      Port.Flush;
    end;
  finally
    FPort.Unlock;
  end;
end;

function TEscPrinter.ReadByte: Byte;
begin
  Result := Ord(FPort.Read(1)[1]);
  FLogger.Debug('<- ' + StrToHex(Chr(Result)));
end;

function TEscPrinter.ReadAnsiString: AnsiString;
var
  C: Char;
begin
  Result := '';
  repeat
    C := FPort.Read(1)[1];
    if C <> #0 then
      Result := Result + C;
  until C = #0;
  FLogger.Debug('<- ' + StrToHex(Result));
end;

procedure TEscPrinter.CarriageReturn;
begin
  Send(CR);
end;

procedure TEscPrinter.HorizontalTab;
begin
  Send(HT);
end;

procedure TEscPrinter.LineFeed;
begin
  Logger.Debug('TEscPrinter.LineFeed');
  Send(LF);
end;

function TEscPrinter.ReadPrinterStatus: TPrinterStatus;
begin
  Logger.Debug('TEscPrinter.ReadPrinterStatus');
  CheckCapRead;

  FPort.Lock;
  try
    Send(#$10#$04#$01);
    Result.DrawerOpened := TestBit(ReadByte, 2);
  finally
    FPort.Unlock;
  end;
end;

function TEscPrinter.ReadOfflineStatus: TOfflineStatus;
var
  B: Byte;
begin
  Logger.Debug('TEscPrinter.ReadOfflineStatus');
  
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

function TEscPrinter.ReadErrorStatus: TErrorStatus;
var
  B: Byte;
begin
  Logger.Debug('TEscPrinter.ReadErrorStatus');
  
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

function TEscPrinter.ReadPaperStatus: TPaperStatus;
var
  B: Byte;
begin
  Logger.Debug('TEscPrinter.ReadPaperStatus');
  
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

procedure TEscPrinter.RecoverError(ClearBuffer: Boolean);
begin
  Logger.Debug('TEscPrinter.RecoverError');
  if ClearBuffer then
    Send(#$10#$05#$02)
  else
    Send(#$10#$05#$01);
end;

procedure TEscPrinter.GeneratePulse(n, m, t: Byte);
begin
  Logger.Debug('TEscPrinter.GeneratePulse');
  Send(#$10#$14 + Chr(n) + Chr(m) + Chr(t));
end;

procedure TEscPrinter.SetRightSideCharacterSpacing(n: Byte);
begin
  Logger.Debug('TEscPrinter.SetRightSideCharacterSpacing');
  Send(#$1B#$20 + Chr(n));
end;

procedure TEscPrinter.SelectPrintMode(Mode: TPrintMode);
var
  B: Byte;
begin
  Logger.Debug('TEscPrinter.SelectPrintMode');
  B := 0;
  if Mode.CharacterFontB then SetBit(B, 0);
  if Mode.Emphasized then SetBit(B, 3);
  if Mode.DoubleHeight then SetBit(B, 4);
  if Mode.DoubleWidth then SetBit(B, 5);
  if Mode.Underlined then SetBit(B, 7);
  Send(#$1B#$21 + Chr(B));
end;

procedure TEscPrinter.SetPrintMode(Mode: Byte);
begin
  Logger.Debug('TEscPrinter.SetPrintMode');
  Send(#$1B#$21 + Chr(Mode));
end;

procedure TEscPrinter.SetAbsolutePrintPosition(n: Word);
begin
  Logger.Debug('TEscPrinter.SetAbsolutePrintPosition');
  Send(#$1B#$24 + Chr(Lo(n)) + Chr(Hi(n)));
end;

procedure TEscPrinter.SelectUserCharacter(n: Byte);
begin
  if n = FUserCharacterMode then Exit;
  
  Logger.Debug(Format('TEscPrinter.SelectUserCharacter(%d)', [n]));
  Send(#$1B#$25 + Chr(n));
  FUserCharacterMode := n;
end;

procedure TEscPrinter.EnableUserCharacters;
begin
  SelectUserCharacter(1);
end;

procedure TEscPrinter.DisableUserCharacters;
begin
  SelectUserCharacter(0);
end;

procedure TEscPrinter.CheckUserCharCode(Code: Byte);
begin
  if (not Code in [USER_CHAR_CODE_MIN..USER_CHAR_CODE_MAX]) then
    raise Exception.CreateFmt('Invalid character code, 0x%.2X', [Code]);
end;

///////////////////////////////////////////////////////////////////////////////
// Font A 12x24, font B 9x17
///////////////////////////////////////////////////////////////////////////////
// The allowable character code range is from ASCII code <20>H to
// <7E>H (95 characters).

procedure TEscPrinter.WriteUserChar(AChar: WideChar; ACode, AFont: Byte);
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
    //Bitmap.SaveToFile(Format('UnicodeChar_%d_%d.bmp', [AFont, Ord(AChar)]));
    // Write
    UserChar.c1 := ACode;
    UserChar.c2 := ACode;
    UserChar.Font := AFont;
    UserChar.Data := GetBitmapData(Bitmap);
    UserChar.Width := Bitmap.Width;
    DefineUserCharacter(UserChar);
  finally
    Bitmap.Free;
  end;
  FUserChars.Add(ACode, AChar, AFont);
end;

procedure TEscPrinter.DrawWideChar(AChar: WideChar; AFont: Byte;
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

procedure TEscPrinter.WriteUserChar2(AChar: WideChar; ACode, AFont: Byte);
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
    UserChar.Data := GetBitmapData(Bitmap);
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
0 ДT x ДT 12 (when Font A (12X24) is
selected) 0 ДT x ДT 9 (when Font B (9X17) is
selected)

*)

procedure TEscPrinter.DefineUserCharacter(C: TUserChar);
begin
  Logger.Debug('TEscPrinter.DefineUserCharacter');
  Send(#$1B#$26#$03 + Chr(C.c1) + Chr(C.c2) + Chr(C.Width) + C.Data);
end;

function TEscPrinter.GetBitmapData(Bitmap: TBitmap): AnsiString;
var
  B: Byte;
  Bit: Byte;
  x, y, k: Integer;
  mx, my: Integer;
begin
  Result := '';
  mx := (Bitmap.Width + 7) div 8;
  my := (Bitmap.Height + 7) div 8;
  for x := 1 to mx*8 do
  begin
    y := 1;
    for k := 1 to my do
    begin
      B := 0;
      for Bit := 0 to 7 do
      begin
        if x > Bitmap.Width then Break;
        if y > Bitmap.Height then Break;

        if Bitmap.Canvas.Pixels[x, y] = clBlack then
        begin
          SetBit(B, 7-Bit);
        end;
        Inc(y);
      end;
      Result := Result + Chr(B);
    end;
  end;
end;

function TEscPrinter.GetFontData(Bitmap: TBitmap): AnsiString;
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

(*
function TEscPrinter.GetRasterBitmapData(Bitmap: TBitmap): AnsiString;
var
  B: Byte;
  x, y: Integer;
  mx: Integer;
begin
  Result := '';
  mx := (Bitmap.Width + 7) div 8;
  for y := 1 to Bitmap.Height do
  for x := 1 to mx do
  begin
    B := PByteArray(Bitmap.ScanLine[y-1])[x-1] xor $FF;
    Result := Result + Chr(B);
  end;
end;
*)

function TEscPrinter.GetRasterBitmapData(Bitmap: TBitmap): AnsiString;
var
  B: Byte;
  x, y: Integer;
  mx: Integer;
  Index: Integer;
begin
  mx := (Bitmap.Width + 7) div 8;
  Result := StringOfChar(#0, mx * Bitmap.Height);
  for y := 1 to Bitmap.Height do
  for x := 1 to mx*8 do
  begin
    if (x <= Bitmap.Width)and(y <= Bitmap.Height) then
    begin
      if Bitmap.Canvas.Pixels[x, y] = clBlack then
      begin
        Index := (y-1)*mx + ((x-1) div 8) + 1;
        B := Ord(Result[Index]);
        SetBit(B, (x-1) mod 8);
        Result[Index] := Chr(B);
      end;
    end;
  end;
  Result := SwapBytes(Result);
end;

function TEscPrinter.GetImageData(Image: TGraphic): AnsiString;
begin
  Result := GetImageData2(Image);
end;

function TEscPrinter.GetImageData2(Image: TGraphic): AnsiString;
var
  Bitmap: TBitmap;
begin
  Bitmap := TBitmap.Create;
  try
    DrawImage(Image, Bitmap);
    Result := GetBitmapData(Bitmap);
  finally
    Bitmap.Free;
  end;
end;

procedure TEscPrinter.DrawImage(Image: TGraphic; Bitmap: TBitmap);
begin
  Bitmap.Monochrome := True;
  Bitmap.PixelFormat := pf1Bit;
  Bitmap.Width := Image.Width;
  Bitmap.Height := Image.Height;
  Bitmap.Canvas.Draw(0, 0, Image);
end;

function TEscPrinter.GetRasterImageData(Image: TGraphic): AnsiString;
var
  Bitmap: TBitmap;
begin
  Bitmap := TBitmap.Create;
  try
    Bitmap.Monochrome := True;
    Bitmap.PixelFormat := pf1Bit;
    Bitmap.Width := Image.Width;
    Bitmap.Height := Image.Height;
    Bitmap.Canvas.Draw(0, 0, Image);
    Result := GetRasterBitmapData(Bitmap);
  finally
    Bitmap.Free;
  end;
end;

procedure TEscPrinter.SelectBitImageMode(mode: Integer; Image: TGraphic);
var
  n: Word;
  data: AnsiString;
begin
  Logger.Debug('TEscPrinter.SelectBitImageMode');

  n := Image.Width;
  data := GetImageData(Image);
  Send(#$1B#$2A + Chr(Mode) + Chr(Lo(n)) + Chr(Hi(n)) + data);
end;

procedure TEscPrinter.SetUnderlineMode(n: Byte);
begin
  Logger.Debug('TEscPrinter.SetUnderlineMode');
  Send(#$1B#$2D + Chr(n));
end;

procedure TEscPrinter.SetDefaultLineSpacing;
begin
  Logger.Debug('TEscPrinter.SetDefaultLineSpacing');
  Send(#$1B#$32);
end;


procedure TEscPrinter.SetLineSpacing(n: Byte);
begin
  Logger.Debug('TEscPrinter.SetLineSpacing');
  Send(#$1B#$33 + Chr(n));
end;

procedure TEscPrinter.CancelUserCharacter(n: Byte);
begin
  Logger.Debug('TEscPrinter.CancelUserCharacter');
  Send(#$1B#$3F + Chr(n));
end;

procedure TEscPrinter.Initialize;
begin
  Logger.Debug('TEscPrinter.Initialize');
  Send(#$1B#$40);
  ClearUserChars;
  FCodePage := 0;
  FUserCharacterMode := 0;
  FInTransaction := False;
end;

procedure TEscPrinter.SetBeepParams(N, T: Byte);
begin
  Logger.Debug('TEscPrinter.SetBeepParams');
  Send(#$1B#$42 + Chr(N) + Chr(T));
end;

procedure TEscPrinter.SetHorizontalTabPositions(Tabs: AnsiString);
begin
  Logger.Debug('TEscPrinter.SetHorizontalTabPositions');
  Send(#$1B#$44 + Tabs + #0);
end;

procedure TEscPrinter.SetEmphasizedMode(Value: Boolean);
begin
  Logger.Debug('TEscPrinter.SetEmphasizedMode');
  Send(#$1B#$45 + Chr(BoolToInt[Value]));
end;

procedure TEscPrinter.SetDoubleStrikeMode(Value: Boolean);
begin
  Logger.Debug('TEscPrinter.SetDoubleStrikeMode');
  Send(#$1B#$47 + Chr(BoolToInt[Value]));
end;

procedure TEscPrinter.PrintAndFeed(n: Byte);
begin
  Logger.Debug('TEscPrinter.PrintAndFeed');
  Send(#$1B#$4A + Chr(n));
end;

procedure TEscPrinter.SetCharacterFont(n: Byte);
begin
  Logger.Debug('TEscPrinter.SetCharacterFont');
  Send(#$1B#$4D + Chr(n));
end;

procedure TEscPrinter.SetCharacterSet(N: Byte);
begin
  Logger.Debug('TEscPrinter.SetCharacterSet');
  Send(#$1B#$52 + Chr(N));
end;

procedure TEscPrinter.Set90ClockwiseRotation(Value: Boolean);
begin
  Logger.Debug('TEscPrinter.Set90ClockwiseRotation');
  Send(#$1B#$56 + Chr(BoolToInt[Value]));
end;

procedure TEscPrinter.SetRelativePrintPosition(n: Word);
begin
  Logger.Debug('TEscPrinter.SetRelativePrintPosition');
  Send(#$1B#$5C + Chr(Lo(n)) + Chr(Hi(n)));
end;

procedure TEscPrinter.SetJustification(N: Byte);
begin
  Logger.Debug('TEscPrinter.SetJustification');
  Send(#$1B#$61 + Chr(N));
end;

procedure TEscPrinter.EnableButtons(Value: Boolean);
begin
  Logger.Debug('TEscPrinter.EnableButtons');
  Send(#$1B#$63#$35 + Chr(BoolToInt[Value]));
end;

procedure TEscPrinter.PrintAndFeedLines(N: Byte);
begin
  Logger.Debug('TEscPrinter.PrintAndFeedLines');
  Send(#$1B#$64 + Chr(N));
end;

procedure TEscPrinter.SetCodePage(CodePage: Integer);
begin
  //if FCodePage = CodePage then Exit;

  Logger.Debug(Format('TEscPrinter.SetCodePage(%d)', [CodePage]));
  Send(#$1B#$74 + Chr(CodePage));
  FCodePage := CodePage;
end;

procedure TEscPrinter.SetUpsideDownPrinting(Value: Boolean);
begin
  Logger.Debug('TEscPrinter.SetUpsideDownPrinting');
  Send(#$1B#$7B + Chr(BoolToInt[Value]));
end;

procedure TEscPrinter.PartialCut;
begin
  Logger.Debug('TEscPrinter.PartialCut');
  Send(#$1B#$69);
end;

procedure TEscPrinter.PartialCut2;
begin
  Logger.Debug('TEscPrinter.PartialCut2');
  Send(#$1B#$6D);
end;

procedure TEscPrinter.SelectChineseCode(N: Byte);
begin
  Logger.Debug('TEscPrinter.SelectChineseCode');
  Send(#$1B#$39 + Chr(N));
end;

procedure TEscPrinter.PrintNVBitImage(Number, Mode: Byte);
begin
  Logger.Debug('TEscPrinter.PrintNVBitImage');
  Send(#$1C#$70 + Chr(Number) + Chr(Mode));
end;

procedure TEscPrinter.DefineNVBitImage(Number: Byte; Image: TGraphic);
var
  x, y: Integer;
  Bitmap: TBitmap;
begin
  Logger.Debug('TEscPrinter.DefineNVBitImage');

  Bitmap := TBitmap.Create;
  try
    DrawImage(Image, Bitmap);

    x := (Bitmap.Width + 7) div 8;
    y := (Bitmap.Height + 7) div 8;
    Send(#$1C#$71 + Chr(Number) + Chr(Lo(x)) + Chr(Hi(x)) +
      Chr(Lo(y)) + Chr(Hi(y)) + GetBitmapData(Bitmap));
  finally
    Bitmap.Free;
  end;
end;

procedure TEscPrinter.SetCharacterSize(N: Byte);
begin
  Logger.Debug('TEscPrinter.SetCharacterSize');
  Send(#$1D#$21 + Chr(N));
end;

procedure TEscPrinter.DownloadBMP(Image: TGraphic);
var
  x, y: Byte;
  Bitmap: TBitmap;
begin
  Logger.Debug('TEscPrinter.DownloadBMP');
  Bitmap := TBitmap.Create;
  try
    DrawImage(Image, Bitmap);

    x := (Bitmap.Width + 7) div 8;
    y := (Bitmap.Height + 7) div 8;
    Send(#$1D#$2A + Chr(x) + Chr(y) + GetBitmapData(Bitmap));
  finally
    Bitmap.Free;
  end;
end;

procedure TEscPrinter.PrintBmp(Mode: Byte);
begin
  Logger.Debug('TEscPrinter.PrintBmp');
  Send(#$1D#$2F + Chr(Mode));
end;

procedure TEscPrinter.SetWhiteBlackReverse(Value: Boolean);
begin
  Logger.Debug('TEscPrinter.SetWhiteBlackReverse');
  Send(#$1D#$42 + Chr(BoolToInt[Value]));
end;

function TEscPrinter.ReadPrinterID(N: Byte): AnsiString;
var
  S: AnsiString;
begin
  Logger.Debug('TEscPrinter.ReadPrinterID');
  
  CheckCapRead;
  FPort.Lock;
  try
    Send(#$1D#$49 + Chr(N));
    S := ReadAnsiString;
    Result := Copy(S, 2, Length(S)-1);
  finally
    FPort.Unlock;
  end;
end;

function TEscPrinter.ReadFirmwareVersion: AnsiString;
begin
  Logger.Debug('TEscPrinter.ReadFirmwareVersion');
  CheckCapRead;
  Result := ReadPrinterID(65);
end;

function TEscPrinter.ReadManufacturer: AnsiString;
begin
  Logger.Debug('TEscPrinter.ReadManufacturer');
  CheckCapRead;
  Result := ReadPrinterID(66);
end;

function TEscPrinter.ReadPrinterName: AnsiString;
begin
  Logger.Debug('TEscPrinter.ReadPrinterName');
  CheckCapRead;
  Result := ReadPrinterID(67);
end;

function TEscPrinter.ReadSerialNumber: AnsiString;
begin
  Logger.Debug('TEscPrinter.ReadSerialNumber');
  CheckCapRead;
  Result := ReadPrinterID(68);
end;

procedure TEscPrinter.SetHRIPosition(N: Byte);
begin
  Logger.Debug('TEscPrinter.SetHRIPosition');
  Send(#$1D#$48 + Chr(N));
end;

procedure TEscPrinter.SetLeftMargin(N: Word);
begin
  Logger.Debug('TEscPrinter.SetLeftMargin');
  Send(#$1D#$4C + Chr(Lo(N)) + Chr(Hi(N)));
end;

procedure TEscPrinter.SetCutModeAndCutPaper(M: Byte);
begin
  Logger.Debug('TEscPrinter.SetCutModeAndCutPaper');
  Send(#$1D#$56 + Chr(M));
end;

procedure TEscPrinter.SetCutModeAndCutPaper2(n: Byte);
begin
  Logger.Debug('TEscPrinter.SetCutModeAndCutPaper2');
  Send(#$1D#$56#$66 + Chr(n));
end;

procedure TEscPrinter.SetPrintAreaWidth(n: Byte);
begin
  Logger.Debug('TEscPrinter.SetPrintAreaWidth');
  Send(#$1D#$57 + Chr(Lo(n)) + Chr(Hi(n)));
end;

procedure TEscPrinter.StartEndMacroDefinition;
begin
  Logger.Debug('TEscPrinter.StartEndMacroDefinition');
  Send(#$1D#$3A);
end;

procedure TEscPrinter.ExecuteMacro(r, t, m: Byte);
begin
  Logger.Debug('TEscPrinter.ExecuteMacro');
  Send(#$1D#$5E + Chr(r) + Chr(t) + Chr(m));
end;

procedure TEscPrinter.EnableAutomaticStatusBack(N: Byte);
begin
  Logger.Debug('TEscPrinter.EnableAutomaticStatusBack');
  Send(#$1D#$61 + Chr(N));
end;

procedure TEscPrinter.SetHRIFont(N: Byte);
begin
  Logger.Debug('TEscPrinter.SetHRIFont');
  Send(#$1D#$66 + Chr(N));
end;

procedure TEscPrinter.SetBarcodeHeight(N: Byte);
begin
  Logger.Debug('TEscPrinter.SetBarcodeHeight');
  Send(#$1D#$68 + Chr(N));
end;

procedure TEscPrinter.PrintBarcode(BCType: Byte; const Data: AnsiString);
begin
  Logger.Debug('TEscPrinter.PrintBarcode');
  Send(#$1D#$6B + Chr(BCType) + Data + #0);
end;

procedure TEscPrinter.PrintBarcode2(BCType: Byte; const Data: AnsiString);
begin
  Logger.Debug('TEscPrinter.PrintBarcode2');
  Send(#$1D#$6B + Chr(BCType) + Chr(Length(Data)) + Data);
end;

function TEscPrinter.ReadPaperRollStatus: TPaperRollStatus;
begin
  Logger.Debug('TEscPrinter.ReadPaperRollStatus');

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
procedure TEscPrinter.PrintRasterBMP(Mode: Byte; Image: TGraphic);
var
  x, y: Byte;
begin
  Logger.Debug('TEscPrinter.PrintRasterBMP');

  x := (Image.Width + 7) div 8;
  y := Image.Height;
  Send(#$1D#$76#$30 + Chr(Mode) + Chr(Lo(x)) + Chr(Hi(x)) +
    Chr(Lo(y)) + Chr(Hi(y)) + GetRasterImageData(Image));
end;

procedure TEscPrinter.SetBarcodeWidth(N: Integer);
begin
  Logger.Debug('TEscPrinter.SetBarcodeWidth');
  Send(#$1D#$77 + Chr(N));
end;

procedure TEscPrinter.SetBarcodeLeft(N: Integer);
begin
  Logger.Debug('TEscPrinter.SetBarcodeLeft');
  Send(#$1D#$78 + Chr(N));
end;

procedure TEscPrinter.SetMotionUnits(x, y: Integer);
begin
  Logger.Debug('TEscPrinter.SetMotionUnits');
  Send(#$1D#$50 + Chr(x) + Chr(y));
end;

procedure TEscPrinter.PrintTestPage;
begin
  Logger.Debug('TEscPrinter.PrintTestPage');
  Send(#$12#$54);
end;

procedure TEscPrinter.SetKanjiMode(m: Byte);
begin
  Logger.Debug('TEscPrinter.SetKanjiMode');
  Send(#$1C#$21 + Chr(m));
end;

procedure TEscPrinter.SelectKanjiCharacter;
begin
  Logger.Debug('TEscPrinter.SelectKanjiCharacter');
  Send(#$1C#$26);
end;

procedure TEscPrinter.SetKanjiUnderline(Value: Boolean);
begin
  Logger.Debug('TEscPrinter.SetKanjiUnderline');
  Send(#$1C#$2D + Chr(BoolToInt[Value]));
end;

procedure TEscPrinter.CancelKanjiCharacter;
begin
  Logger.Debug('TEscPrinter.CancelKanjiCharacter');
  Send(#$1C#$2E);
end;

procedure TEscPrinter.DefineKanjiCharacters(c1, c2: Byte;
  const data: AnsiString);
begin
  Logger.Debug('TEscPrinter.DefineKanjiCharacters');
  Send(#$1C#$32 + Chr(c1) + Chr(c2) + data);
end;

procedure TEscPrinter.SetPeripheralDevice(m: Byte);
begin
  Logger.Debug('TEscPrinter.SetPeripheralDevice');
  Send(#$1B#$3D + Chr(m));
end;

procedure TEscPrinter.SetKanjiSpacing(n1, n2: Byte);
begin
  Logger.Debug('TEscPrinter.SetKanjiSpacing');
  Send(#$1C#$53 + Chr(n1) + Chr(n2));
end;

procedure TEscPrinter.PrintAndReturnStandardMode;
begin
  Logger.Debug('TEscPrinter.PrintAndReturnStandardMode');
  Send(#$0C);
end;

procedure TEscPrinter.PrintDataInMode;
begin
  Logger.Debug('TEscPrinter.PrintDataInMode');
  Send(#$1B#$0C);
end;

procedure TEscPrinter.SetPageMode;
begin
  Logger.Debug('TEscPrinter.SetPageMode');
  Send(#$1B#$4C);
end;

procedure TEscPrinter.SetStandardMode;
begin
  Logger.Debug('TEscPrinter.SetStandardMode');
  Send(#$1B#$53);
end;

procedure TEscPrinter.SetPageModeDirection(n: Byte);
begin
  Logger.Debug('TEscPrinter.SetPageModeDirection');
  Send(#$1B#$54 + Chr(n));
end;

procedure TEscPrinter.SetPageModeArea(R: TRect);
begin
  Logger.Debug('TEscPrinter.SetPageModeArea');
  Send(#$1B#$57 +
    Chr(Lo(R.Left)) + Chr(Hi(R.Left)) +
    Chr(Lo(R.Top)) + Chr(Hi(R.Top)) +
    Chr(Lo(R.Right)) + Chr(Hi(R.Right)) +
    Chr(Lo(R.Bottom)) + Chr(Hi(R.Bottom)));
end;

procedure TEscPrinter.printBarcode2D(m, n, k: Byte; const data: AnsiString);
begin
  Logger.Debug('TEscPrinter.printBarcode2D');
  Send(#$1B#$5A + Chr(m) + Chr(n) + Chr(k) +
    Chr(Lo(Length(data))) + Chr(Hi(Length(data))) + data);
end;

(*
PDF417:barcode type0
m specifies column number of 2D barcode.(1.m.30)
n specifies security level to restore when barcode image
is damaged.(0.n.8)
k is used for define horizontal and vertical ratio.( 2.k.5)
d is the length of data
*)

procedure TEscPrinter.printPDF417(const Barcode: TPDF417);
begin
  Logger.Debug('TEscPrinter.printPDF417');
  printBarcode2D(Barcode.ColumnNumber, Barcode.SecurityLevel, Barcode.HVRatio, Barcode.data);
end;

procedure TEscPrinter.printQRCode(const Barcode: TQRCode);
begin
  Logger.Debug('TEscPrinter.printQRCode');
  printBarcode2D(Barcode.SymbolVersion, Barcode.ECLevel, Barcode.ModuleSize, Barcode.data);
end;

procedure TEscPrinter.SetKanjiQuadSizeMode(Value: Boolean);
begin
  Logger.Debug('TEscPrinter.SetKanjiQuadSizeMode');
  Send(#$1C#$57 + Chr(BoolToInt[Value]));
end;

procedure TEscPrinter.FeedMarkedPaper;
begin
  Logger.Debug('TEscPrinter.FeedMarkedPaper');
  Send(#$1D#$0C);
end;

procedure TEscPrinter.SetPMAbsoluteVerticalPosition(n: Integer);
begin
  Logger.Debug('TEscPrinter.SetPMAbsoluteVerticalPosition');
  Send(#$1D#$24 + Chr(Lo(n)) + Chr(Hi(n)));
end;

procedure TEscPrinter.ExecuteTestPrint(p: Integer; n, m: Byte);
begin
  Logger.Debug('TEscPrinter.ExecuteTestPrint');
  Send(#$1D#$28#$41 + Chr(Lo(p)) + Chr(Hi(p)) + Chr(n) + Chr(m));
end;

procedure TEscPrinter.SelectCounterPrintMode(n, m: Byte);
begin
  Logger.Debug('TEscPrinter.SelectCounterPrintMode');
  Send(#$1D#$43#$30 + Chr(n) + Chr(m));
end;

procedure TEscPrinter.SelectCountMode(a, b: Word; n, r: Byte);
begin
  Logger.Debug('TEscPrinter.SelectCountMode');
  Send(#$1D#$43#$31 + Chr(Lo(a)) + Chr(Hi(a)) +
    Chr(Lo(b)) + Chr(Hi(b)) + Chr(n) + Chr(r));
end;

procedure TEscPrinter.SetCounter(n: Word);
begin
  Logger.Debug('TEscPrinter.SetCounter');
  Send(#$1D#$43#$32 + Chr(Lo(n)) + Chr(Hi(n)));
end;

procedure TEscPrinter.Select2DBarcode(n: Byte);
begin
  Logger.Debug('TEscPrinter.Select2DBarcode');
  Send(#$1D#$5A + Chr(n));
end;

procedure TEscPrinter.SetPMRelativeVerticalPosition(n: Word);
begin
  Logger.Debug('TEscPrinter.SetPMRelativeVerticalPosition');
  Send(#$1D#$5C + Chr(Lo(n)) + Chr(Hi(n)));
end;

procedure TEscPrinter.PrintCounter;
begin
  Logger.Debug('TEscPrinter.PrintCounter');
  Send(#$1D#$63);
end;

procedure TEscPrinter.SetNormalPrintMode;
var
  PrintMode: TPrintMode;
begin
  Logger.Debug('TEscPrinter.SetNormalPrintMode');
  PrintMode.CharacterFontB := False;
  PrintMode.Emphasized := False;
  PrintMode.DoubleHeight := False;
  PrintMode.DoubleWidth := False;
  PrintMode.Underlined := False;
  SelectPrintMode(PrintMode);
end;

procedure TEscPrinter.PrintText(Text: AnsiString);
begin
  //Logger.Debug(Format('TEscPrinter.PrintText(''%s'')', [TrimRight(Text)]));
  Send(Text);
end;

function TEscPrinter.CapRead: Boolean;
begin
  Result := Port.CapRead;
end;

procedure TEscPrinter.CheckCapRead;
begin
  if not Port.CapRead then
  begin
    raise Exception.Create('ѕорт не поддерживает чтение');
  end;
end;

procedure TEscPrinter.BeginDocument;
begin
  FInTransaction := True;
end;

procedure TEscPrinter.EndDocument;
begin
  FInTransaction := False;
  Port.Flush;
end;

procedure TEscPrinter.PortFlush;
begin
  Port.Flush;
end;

procedure TEscPrinter.WriteKazakhCharactersToBitmap;
var
  i: Integer;
  C: WideChar;
  Bitmap: TBitmap;
begin
  Bitmap := TBitmap.Create;
  try
    Bitmap.Monochrome := True;
    Bitmap.PixelFormat := pf1Bit;

    // FONT_TYPE_A
    Bitmap.Width := 12 * Length(KazakhUnicodeChars);
    Bitmap.Height := 24;
    for i := Low(KazakhUnicodeChars) to High(KazakhUnicodeChars) do
    begin
      C := WideChar(KazakhUnicodeChars[i]);
      DrawWideChar(C, FONT_TYPE_A, Bitmap, i*12, 0);
    end;
    Bitmap.SaveToFile('KazakhFontA.bmp');

    // FONT_TYPE_B
    Bitmap.Width := 9 * Length(KazakhUnicodeChars);
    Bitmap.Height := 17;
    for i := Low(KazakhUnicodeChars) to High(KazakhUnicodeChars) do
    begin
      C := WideChar(KazakhUnicodeChars[i]);
      DrawWideChar(C, FONT_TYPE_B, Bitmap, i*12, 0);
    end;
    Bitmap.SaveToFile('KazakhFontB.bmp');
  finally
    Bitmap.Free;
  end;
end;

procedure TEscPrinter.WriteKazakhCharacters;
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
        Code := FUserCharCode;
        Data := GetFontData(Bitmap);
        for i := 0 to Count-1 do
        begin
          FUserChars.Add(Code + i, WideChar(KazakhUnicodeChars[i]), FONT_TYPE_A);
          BitmapData := BitmapData + Chr(FontWidth) + Copy(Data, i*FontWidth*3 + 1, FontWidth*3);
        end;
        Send(#$1B#$26#$03 + Chr(Code) + Chr(Code + Count -1) + BitmapData);
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
        Code := FUserCharCode;
        Inc(FUserCharCode, Count);
        Data := GetBitmapData(Bitmap);
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

procedure TEscPrinter.WriteKazakhCharacters2;
var
  i: Integer;
  Count: Integer;
  Bitmap: TBitmap;
  Data: AnsiString;
  FontWidth: Integer;
  BitmapData: AnsiString;
begin
  Bitmap := TBitmap.Create;
  try
    // FONT_TYPE_A
    Bitmap.LoadFromFile(GetModulePath + 'Fonts\KazakhFontA.bmp');
    FontWidth := 12;
    BitmapData := '';
    Count := Bitmap.Width div FontWidth;
    Data := GetBitmapData(Bitmap);
    for i := 0 to Count-1 do
    begin
      FUserChars.Add(FUserCharCode, WideChar(KazakhUnicodeChars[i]), FONT_TYPE_A);
      BitmapData := Copy(Data, i*FontWidth + 1, FontWidth*3);
      Send(#$1B#$26#$03 + Chr(FUserCharCode) + Chr(FUserCharCode) + Chr(FontWidth) + BitmapData);
      Inc(FUserCharCode);
    end;
(*
    // FONT_TYPE_B
    Bitmap.LoadFromFile(GetModulePath + 'Fonts\KazakhFontB.bmp');
    FontWidth := 9;
    BitmapData := '';
    Count := Bitmap.Width div FontWidth;
    Code := FUserCharCode;
    Inc(FUserCharCode, Count);
    Data := GetBitmapData(Bitmap);
    for i := 0 to Count-1 do
    begin
      FUserChars.Add(Code + i, WideChar(KazakhUnicodeChars[i]), FONT_TYPE_B);
      BitmapData := BitmapData + Chr(FontWidth) + Copy(Data, i*FontWidth + 1, FontWidth*3);
    end;
    Send(#$1B#$26#$03 + Chr(Code) + Chr(Code + Count -1) + BitmapData);
*)
  finally
    Bitmap.Free;
  end;
end;

function TEscPrinter.IsUserChar(Char: WideChar): Boolean;
begin
  Result := IsKazakhUnicodeChar(Char);
end;

procedure TEscPrinter.PrintUserChar(Char: WideChar);
var
  Item: TUserCharacter;
begin
  Item := FUserChars.ItemByChar(Char);
  if Item <> nil then
  begin
    EnableUserCharacters;
    PrintText(Chr(Item.Code));
  end;
end;


// Set QR code amplification (dot size)
// 1D 28 6B 30 67 07 - 7
// 1D 28 6B 30 67 01 - 1

// Set QR code error correction level
// 1D 28 6B 30 69 48 - 7%
// 1D 28 6B 30 69 49 - 15%
// 1D 28 6B 30 69 50 - 25%
// 1D 28 6B 30 69 51 - 30%


// Send QR code data ?
// 1D 28 6B 30 80 52 00 57 65 6C 63 6F 6D 65 20 74 6F 20 50 72 69
// 6E 74 65 72 0D 0A 54 65 63 68 6E 6F 6C 6F 67 79 20 74 6F 20 63
// 72 65 61 74 65 20 61 64 76 61 6E 74 61 67 65 73 0D 0A 51 75 61
// 6C 69 74 79 20 74 6F 20 77 69 6E 20 69 6E 20 74 68 65 20 66 75
// 74 75 72 65 00

// Print QR Code
// 1D 28 6B 30 81 1B 4A C8

// Self test
// 1F 1B 1F 67

// Set UTF codepage
// 1F 1B 10 01 02 01

// Codepage 1 (Katakana)
// 1F 1B 10 01 02 00
// 1F 1B 1F FF 01 0A 00

// Codepage 2 (Katakana)
// 1F 1B 10 01 02 00
// 1F 1B 1F FF 02 0A 00


end.

unit EscPrinterRongta;

interface

uses
  // VCL
  Windows, Types, SysUtils, Graphics, Classes,
  // Tnt
  TntGraphics,
  // This
  ByteUtils, PrinterPort, RegExpr, StringUtils, LogFile, FileUtils,
  EscPrinterUtils;

const
  /////////////////////////////////////////////////////////////////////////////
  // Font type

  FONT_TYPE_A = 0; // 12x24
  FONT_TYPE_B = 1; // 9x17

  FONT_TYPE_MIN = FONT_TYPE_A;
  FONT_TYPE_MAX = FONT_TYPE_B;

  /////////////////////////////////////////////////////////////////////////////
  // QRCode error correction level

  REP_QRCODE_ECL_7   = 0;
  REP_QRCODE_ECL_15  = 1;
  REP_QRCODE_ECL_25  = 2;
  REP_QRCODE_ECL_30  = 3;

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

  { TEscPrinterRongta }

  TEscPrinterRongta = class
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

{ TEscPrinterRongta }

constructor TEscPrinterRongta.Create(APort: IPrinterPort; ALogger: ILogFile);
begin
  inherited Create;
  FPort := APort;
  FLogger := ALogger;
  FDeviceMetrics.PrintWidth := 576;
  FUserChars := TUserCharacters.Create(TUserCharacter);
end;

destructor TEscPrinterRongta.Destroy;
begin
  FUserChars.Free;
  inherited Destroy;
end;

procedure TEscPrinterRongta.ClearUserChars;
begin
  FUserChars.Clear;
  FUserCharCode := USER_CHAR_CODE_MIN;
end;

procedure TEscPrinterRongta.Send(const Data: AnsiString);
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

function TEscPrinterRongta.ReadByte: Byte;
begin
  Result := Ord(FPort.Read(1)[1]);
  FLogger.Debug('<- ' + StrToHex(Chr(Result)));
end;

function TEscPrinterRongta.ReadAnsiString: AnsiString;
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

procedure TEscPrinterRongta.CarriageReturn;
begin
  Send(CR);
end;

procedure TEscPrinterRongta.HorizontalTab;
begin
  Send(HT);
end;

procedure TEscPrinterRongta.LineFeed;
begin
  Logger.Debug('TEscPrinterRongta.LineFeed');
  Send(LF);
end;

function TEscPrinterRongta.ReadPrinterStatus: TPrinterStatus;
begin
  Logger.Debug('TEscPrinterRongta.ReadPrinterStatus');
  CheckCapRead;

  FPort.Lock;
  try
    Send(#$10#$04#$01);
    Result.DrawerOpened := TestBit(ReadByte, 2);
  finally
    FPort.Unlock;
  end;
end;

function TEscPrinterRongta.ReadOfflineStatus: TOfflineStatus;
var
  B: Byte;
begin
  Logger.Debug('TEscPrinterRongta.ReadOfflineStatus');
  
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

function TEscPrinterRongta.ReadErrorStatus: TErrorStatus;
var
  B: Byte;
begin
  Logger.Debug('TEscPrinterRongta.ReadErrorStatus');
  
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

function TEscPrinterRongta.ReadPaperStatus: TPaperStatus;
var
  B: Byte;
begin
  Logger.Debug('TEscPrinterRongta.ReadPaperStatus');
  
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

procedure TEscPrinterRongta.RecoverError(ClearBuffer: Boolean);
begin
  Logger.Debug('TEscPrinterRongta.RecoverError');
  if ClearBuffer then
    Send(#$10#$05#$02)
  else
    Send(#$10#$05#$01);
end;

procedure TEscPrinterRongta.GeneratePulse(n, m, t: Byte);
begin
  Logger.Debug('TEscPrinterRongta.GeneratePulse');
  Send(#$10#$14 + Chr(n) + Chr(m) + Chr(t));
end;

procedure TEscPrinterRongta.SetRightSideCharacterSpacing(n: Byte);
begin
  Logger.Debug('TEscPrinterRongta.SetRightSideCharacterSpacing');
  Send(#$1B#$20 + Chr(n));
end;

procedure TEscPrinterRongta.SelectPrintMode(Mode: TPrintMode);
var
  B: Byte;
begin
  Logger.Debug('TEscPrinterRongta.SelectPrintMode');
  B := 0;
  if Mode.CharacterFontB then SetBit(B, 0);
  if Mode.Emphasized then SetBit(B, 3);
  if Mode.DoubleHeight then SetBit(B, 4);
  if Mode.DoubleWidth then SetBit(B, 5);
  if Mode.Underlined then SetBit(B, 7);
  Send(#$1B#$21 + Chr(B));
end;

procedure TEscPrinterRongta.SetPrintMode(Mode: Byte);
begin
  Logger.Debug('TEscPrinterRongta.SetPrintMode');
  Send(#$1B#$21 + Chr(Mode));
end;

procedure TEscPrinterRongta.SetAbsolutePrintPosition(n: Word);
begin
  Logger.Debug('TEscPrinterRongta.SetAbsolutePrintPosition');
  Send(#$1B#$24 + Chr(Lo(n)) + Chr(Hi(n)));
end;

procedure TEscPrinterRongta.SelectUserCharacter(n: Byte);
begin
  if n = FUserCharacterMode then Exit;
  
  Logger.Debug(Format('TEscPrinterRongta.SelectUserCharacter(%d)', [n]));
  Send(#$1B#$25 + Chr(n));
  FUserCharacterMode := n;
end;

procedure TEscPrinterRongta.EnableUserCharacters;
begin
  SelectUserCharacter(1);
end;

procedure TEscPrinterRongta.DisableUserCharacters;
begin
  SelectUserCharacter(0);
end;

procedure TEscPrinterRongta.CheckUserCharCode(Code: Byte);
begin
  if (not Code in [USER_CHAR_CODE_MIN..USER_CHAR_CODE_MAX]) then
    raise Exception.CreateFmt('Invalid character code, 0x%.2X', [Code]);
end;

///////////////////////////////////////////////////////////////////////////////
// Font A 12x24, font B 9x17
///////////////////////////////////////////////////////////////////////////////
// The allowable character code range is from ASCII code <20>H to
// <7E>H (95 characters).

procedure TEscPrinterRongta.WriteUserChar(AChar: WideChar; ACode, AFont: Byte);
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
    UserChar.Data := GetBitmapData(Bitmap, Bitmap.Height);
    UserChar.Width := Bitmap.Width;
    DefineUserCharacter(UserChar);
  finally
    Bitmap.Free;
  end;
  FUserChars.Add(ACode, AChar, AFont);
end;

procedure TEscPrinterRongta.DrawWideChar(AChar: WideChar; AFont: Byte;
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

procedure TEscPrinterRongta.WriteUserChar2(AChar: WideChar; ACode, AFont: Byte);
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
0 ДT x ДT 12 (when Font A (12X24) is
selected) 0 ДT x ДT 9 (when Font B (9X17) is
selected)

*)

procedure TEscPrinterRongta.DefineUserCharacter(C: TUserChar);
begin
  Logger.Debug('TEscPrinterRongta.DefineUserCharacter');
  Send(#$1B#$26#$03 + Chr(C.c1) + Chr(C.c2) + Chr(C.Width) + C.Data);
end;

function TEscPrinterRongta.GetFontData(Bitmap: TBitmap): AnsiString;
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

procedure TEscPrinterRongta.SelectBitImageMode(mode: Integer; Image: TGraphic);
var
  n: Word;
  data: AnsiString;
begin
  Logger.Debug('TEscPrinterRongta.SelectBitImageMode');

  n := Image.Width;
  data := GetImageData2(Image);
  Send(#$1B#$2A + Chr(Mode) + Chr(Lo(n)) + Chr(Hi(n)) + data);
end;

procedure TEscPrinterRongta.SetUnderlineMode(n: Byte);
begin
  Logger.Debug('TEscPrinterRongta.SetUnderlineMode');
  Send(#$1B#$2D + Chr(n));
end;

procedure TEscPrinterRongta.SetDefaultLineSpacing;
begin
  Logger.Debug('TEscPrinterRongta.SetDefaultLineSpacing');
  Send(#$1B#$32);
end;


procedure TEscPrinterRongta.SetLineSpacing(n: Byte);
begin
  Logger.Debug('TEscPrinterRongta.SetLineSpacing');
  Send(#$1B#$33 + Chr(n));
end;

procedure TEscPrinterRongta.CancelUserCharacter(n: Byte);
begin
  Logger.Debug('TEscPrinterRongta.CancelUserCharacter');
  Send(#$1B#$3F + Chr(n));
end;

procedure TEscPrinterRongta.Initialize;
begin
  Logger.Debug('TEscPrinterRongta.Initialize');
  Send(#$1B#$40);
  ClearUserChars;
  FCodePage := 0;
  FUserCharacterMode := 0;
  FInTransaction := False;
end;

procedure TEscPrinterRongta.SetBeepParams(N, T: Byte);
begin
  Logger.Debug('TEscPrinterRongta.SetBeepParams');
  Send(#$1B#$42 + Chr(N) + Chr(T));
end;

procedure TEscPrinterRongta.SetHorizontalTabPositions(Tabs: AnsiString);
begin
  Logger.Debug('TEscPrinterRongta.SetHorizontalTabPositions');
  Send(#$1B#$44 + Tabs + #0);
end;

procedure TEscPrinterRongta.SetEmphasizedMode(Value: Boolean);
begin
  Logger.Debug('TEscPrinterRongta.SetEmphasizedMode');
  Send(#$1B#$45 + Chr(BoolToInt[Value]));
end;

procedure TEscPrinterRongta.SetDoubleStrikeMode(Value: Boolean);
begin
  Logger.Debug('TEscPrinterRongta.SetDoubleStrikeMode');
  Send(#$1B#$47 + Chr(BoolToInt[Value]));
end;

procedure TEscPrinterRongta.PrintAndFeed(n: Byte);
begin
  Logger.Debug('TEscPrinterRongta.PrintAndFeed');
  Send(#$1B#$4A + Chr(n));
end;

procedure TEscPrinterRongta.SetCharacterFont(n: Byte);
begin
  Logger.Debug('TEscPrinterRongta.SetCharacterFont');
  Send(#$1B#$4D + Chr(n));
end;

procedure TEscPrinterRongta.SetCharacterSet(N: Byte);
begin
  Logger.Debug('TEscPrinterRongta.SetCharacterSet');
  Send(#$1B#$52 + Chr(N));
end;

procedure TEscPrinterRongta.Set90ClockwiseRotation(Value: Boolean);
begin
  Logger.Debug('TEscPrinterRongta.Set90ClockwiseRotation');
  Send(#$1B#$56 + Chr(BoolToInt[Value]));
end;

procedure TEscPrinterRongta.SetRelativePrintPosition(n: Word);
begin
  Logger.Debug('TEscPrinterRongta.SetRelativePrintPosition');
  Send(#$1B#$5C + Chr(Lo(n)) + Chr(Hi(n)));
end;

procedure TEscPrinterRongta.SetJustification(N: Byte);
begin
  Logger.Debug('TEscPrinterRongta.SetJustification');
  Send(#$1B#$61 + Chr(N));
end;

procedure TEscPrinterRongta.EnableButtons(Value: Boolean);
begin
  Logger.Debug('TEscPrinterRongta.EnableButtons');
  Send(#$1B#$63#$35 + Chr(BoolToInt[Value]));
end;

procedure TEscPrinterRongta.PrintAndFeedLines(N: Byte);
begin
  Logger.Debug('TEscPrinterRongta.PrintAndFeedLines');
  Send(#$1B#$64 + Chr(N));
end;

procedure TEscPrinterRongta.SetCodePage(CodePage: Integer);
begin
  if FCodePage = CodePage then Exit;

  Logger.Debug(Format('TEscPrinterRongta.SetCodePage(%d)', [CodePage]));
  Send(#$1B#$74 + Chr(CodePage));
  FCodePage := CodePage;
end;

procedure TEscPrinterRongta.SetUpsideDownPrinting(Value: Boolean);
begin
  Logger.Debug('TEscPrinterRongta.SetUpsideDownPrinting');
  Send(#$1B#$7B + Chr(BoolToInt[Value]));
end;

procedure TEscPrinterRongta.PartialCut;
begin
  Logger.Debug('TEscPrinterRongta.PartialCut');
  Send(#$1B#$69);
end;

procedure TEscPrinterRongta.PartialCut2;
begin
  Logger.Debug('TEscPrinterRongta.PartialCut2');
  Send(#$1B#$6D);
end;

procedure TEscPrinterRongta.SelectChineseCode(N: Byte);
begin
  Logger.Debug('TEscPrinterRongta.SelectChineseCode');
  Send(#$1B#$39 + Chr(N));
end;

procedure TEscPrinterRongta.PrintNVBitImage(Number, Mode: Byte);
begin
  Logger.Debug('TEscPrinterRongta.PrintNVBitImage');
  Send(#$1C#$70 + Chr(Number) + Chr(Mode));
end;

procedure TEscPrinterRongta.DefineNVBitImage(Number: Byte; Image: TGraphic);
var
  x, y: Integer;
  Bitmap: TBitmap;
begin
  Logger.Debug('TEscPrinterRongta.DefineNVBitImage');

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

procedure TEscPrinterRongta.SetCharacterSize(N: Byte);
begin
  Logger.Debug('TEscPrinterRongta.SetCharacterSize');
  Send(#$1D#$21 + Chr(N));
end;

procedure TEscPrinterRongta.DownloadBMP(Image: TGraphic);
var
  x, y: Byte;
  Bitmap: TBitmap;
begin
  Logger.Debug('TEscPrinterRongta.DownloadBMP');
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

procedure TEscPrinterRongta.PrintBmp(Mode: Byte);
begin
  Logger.Debug('TEscPrinterRongta.PrintBmp');
  Send(#$1D#$2F + Chr(Mode));
end;

procedure TEscPrinterRongta.SetWhiteBlackReverse(Value: Boolean);
begin
  Logger.Debug('TEscPrinterRongta.SetWhiteBlackReverse');
  Send(#$1D#$42 + Chr(BoolToInt[Value]));
end;

function TEscPrinterRongta.ReadPrinterID(N: Byte): AnsiString;
var
  S: AnsiString;
begin
  Logger.Debug('TEscPrinterRongta.ReadPrinterID');
  
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

function TEscPrinterRongta.ReadFirmwareVersion: AnsiString;
begin
  Logger.Debug('TEscPrinterRongta.ReadFirmwareVersion');
  CheckCapRead;
  Result := ReadPrinterID(65);
end;

function TEscPrinterRongta.ReadManufacturer: AnsiString;
begin
  Logger.Debug('TEscPrinterRongta.ReadManufacturer');
  CheckCapRead;
  Result := ReadPrinterID(66);
end;

function TEscPrinterRongta.ReadPrinterName: AnsiString;
begin
  Logger.Debug('TEscPrinterRongta.ReadPrinterName');
  CheckCapRead;
  Result := ReadPrinterID(67);
end;

function TEscPrinterRongta.ReadSerialNumber: AnsiString;
begin
  Logger.Debug('TEscPrinterRongta.ReadSerialNumber');
  CheckCapRead;
  Result := ReadPrinterID(68);
end;

procedure TEscPrinterRongta.SetHRIPosition(N: Byte);
begin
  Logger.Debug('TEscPrinterRongta.SetHRIPosition');
  Send(#$1D#$48 + Chr(N));
end;

procedure TEscPrinterRongta.SetLeftMargin(N: Word);
begin
  Logger.Debug('TEscPrinterRongta.SetLeftMargin');
  Send(#$1D#$4C + Chr(Lo(N)) + Chr(Hi(N)));
end;

procedure TEscPrinterRongta.SetCutModeAndCutPaper(M: Byte);
begin
  Logger.Debug('TEscPrinterRongta.SetCutModeAndCutPaper');
  Send(#$1D#$56 + Chr(M));
end;

procedure TEscPrinterRongta.SetCutModeAndCutPaper2(n: Byte);
begin
  Logger.Debug('TEscPrinterRongta.SetCutModeAndCutPaper2');
  Send(#$1D#$56#$66 + Chr(n));
end;

procedure TEscPrinterRongta.SetPrintAreaWidth(n: Byte);
begin
  Logger.Debug('TEscPrinterRongta.SetPrintAreaWidth');
  Send(#$1D#$57 + Chr(Lo(n)) + Chr(Hi(n)));
end;

procedure TEscPrinterRongta.StartEndMacroDefinition;
begin
  Logger.Debug('TEscPrinterRongta.StartEndMacroDefinition');
  Send(#$1D#$3A);
end;

procedure TEscPrinterRongta.ExecuteMacro(r, t, m: Byte);
begin
  Logger.Debug('TEscPrinterRongta.ExecuteMacro');
  Send(#$1D#$5E + Chr(r) + Chr(t) + Chr(m));
end;

procedure TEscPrinterRongta.EnableAutomaticStatusBack(N: Byte);
begin
  Logger.Debug('TEscPrinterRongta.EnableAutomaticStatusBack');
  Send(#$1D#$61 + Chr(N));
end;

procedure TEscPrinterRongta.SetHRIFont(N: Byte);
begin
  Logger.Debug('TEscPrinterRongta.SetHRIFont');
  Send(#$1D#$66 + Chr(N));
end;

procedure TEscPrinterRongta.SetBarcodeHeight(N: Byte);
begin
  Logger.Debug('TEscPrinterRongta.SetBarcodeHeight');
  Send(#$1D#$68 + Chr(N));
end;

procedure TEscPrinterRongta.PrintBarcode(BCType: Byte; const Data: AnsiString);
begin
  Logger.Debug('TEscPrinterRongta.PrintBarcode');
  Send(#$1D#$6B + Chr(BCType) + Data + #0);
end;

procedure TEscPrinterRongta.PrintBarcode2(BCType: Byte; const Data: AnsiString);
begin
  Logger.Debug('TEscPrinterRongta.PrintBarcode2');
  Send(#$1D#$6B + Chr(BCType) + Chr(Length(Data)) + Data);
end;

function TEscPrinterRongta.ReadPaperRollStatus: TPaperRollStatus;
begin
  Logger.Debug('TEscPrinterRongta.ReadPaperRollStatus');

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
procedure TEscPrinterRongta.PrintRasterBMP(Mode: Byte; Image: TGraphic);
var
  x, y: Byte;
begin
  Logger.Debug('TEscPrinterRongta.PrintRasterBMP');

  x := (Image.Width + 7) div 8;
  y := Image.Height;
  Send(#$1D#$76#$30 + Chr(Mode) + Chr(Lo(x)) + Chr(Hi(x)) +
    Chr(Lo(y)) + Chr(Hi(y)) + GetRasterImageData(Image));
end;

procedure TEscPrinterRongta.SetBarcodeWidth(N: Integer);
begin
  Logger.Debug('TEscPrinterRongta.SetBarcodeWidth');
  Send(#$1D#$77 + Chr(N));
end;

procedure TEscPrinterRongta.SetBarcodeLeft(N: Integer);
begin
  Logger.Debug('TEscPrinterRongta.SetBarcodeLeft');
  Send(#$1D#$78 + Chr(N));
end;

procedure TEscPrinterRongta.SetMotionUnits(x, y: Integer);
begin
  Logger.Debug('TEscPrinterRongta.SetMotionUnits');
  Send(#$1D#$50 + Chr(x) + Chr(y));
end;

procedure TEscPrinterRongta.PrintTestPage;
begin
  Logger.Debug('TEscPrinterRongta.PrintTestPage');
  Send(#$12#$54);
end;

procedure TEscPrinterRongta.SetKanjiMode(m: Byte);
begin
  Logger.Debug('TEscPrinterRongta.SetKanjiMode');
  Send(#$1C#$21 + Chr(m));
end;

procedure TEscPrinterRongta.SelectKanjiCharacter;
begin
  Logger.Debug('TEscPrinterRongta.SelectKanjiCharacter');
  Send(#$1C#$26);
end;

procedure TEscPrinterRongta.SetKanjiUnderline(Value: Boolean);
begin
  Logger.Debug('TEscPrinterRongta.SetKanjiUnderline');
  Send(#$1C#$2D + Chr(BoolToInt[Value]));
end;

procedure TEscPrinterRongta.CancelKanjiCharacter;
begin
  Logger.Debug('TEscPrinterRongta.CancelKanjiCharacter');
  Send(#$1C#$2E);
end;

procedure TEscPrinterRongta.DefineKanjiCharacters(c1, c2: Byte;
  const data: AnsiString);
begin
  Logger.Debug('TEscPrinterRongta.DefineKanjiCharacters');
  Send(#$1C#$32 + Chr(c1) + Chr(c2) + data);
end;

procedure TEscPrinterRongta.SetPeripheralDevice(m: Byte);
begin
  Logger.Debug('TEscPrinterRongta.SetPeripheralDevice');
  Send(#$1B#$3D + Chr(m));
end;

procedure TEscPrinterRongta.SetKanjiSpacing(n1, n2: Byte);
begin
  Logger.Debug('TEscPrinterRongta.SetKanjiSpacing');
  Send(#$1C#$53 + Chr(n1) + Chr(n2));
end;

procedure TEscPrinterRongta.PrintAndReturnStandardMode;
begin
  Logger.Debug('TEscPrinterRongta.PrintAndReturnStandardMode');
  Send(#$0C);
end;

procedure TEscPrinterRongta.PrintDataInMode;
begin
  Logger.Debug('TEscPrinterRongta.PrintDataInMode');
  Send(#$1B#$0C);
end;

procedure TEscPrinterRongta.SetPageMode;
begin
  Logger.Debug('TEscPrinterRongta.SetPageMode');
  Send(#$1B#$4C);
end;

procedure TEscPrinterRongta.SetStandardMode;
begin
  Logger.Debug('TEscPrinterRongta.SetStandardMode');
  Send(#$1B#$53);
end;

procedure TEscPrinterRongta.SetPageModeDirection(n: Byte);
begin
  Logger.Debug('TEscPrinterRongta.SetPageModeDirection');
  Send(#$1B#$54 + Chr(n));
end;

procedure TEscPrinterRongta.SetPageModeArea(R: TRect);
begin
  Logger.Debug('TEscPrinterRongta.SetPageModeArea');
  Send(#$1B#$57 +
    Chr(Lo(R.Left)) + Chr(Hi(R.Left)) +
    Chr(Lo(R.Top)) + Chr(Hi(R.Top)) +
    Chr(Lo(R.Right)) + Chr(Hi(R.Right)) +
    Chr(Lo(R.Bottom)) + Chr(Hi(R.Bottom)));
end;

procedure TEscPrinterRongta.printBarcode2D(m, n, k: Byte; const data: AnsiString);
begin
  Logger.Debug('TEscPrinterRongta.printBarcode2D');
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

procedure TEscPrinterRongta.printPDF417(const Barcode: TPDF417);
begin
  Logger.Debug('TEscPrinterRongta.printPDF417');
  printBarcode2D(Barcode.ColumnNumber, Barcode.SecurityLevel, Barcode.HVRatio, Barcode.data);
end;

procedure TEscPrinterRongta.printQRCode(const Barcode: TQRCode);
begin
  Logger.Debug('TEscPrinterRongta.printQRCode');
  printBarcode2D(Barcode.SymbolVersion, Barcode.ECLevel, Barcode.ModuleSize, Barcode.data);
end;

procedure TEscPrinterRongta.SetKanjiQuadSizeMode(Value: Boolean);
begin
  Logger.Debug('TEscPrinterRongta.SetKanjiQuadSizeMode');
  Send(#$1C#$57 + Chr(BoolToInt[Value]));
end;

procedure TEscPrinterRongta.FeedMarkedPaper;
begin
  Logger.Debug('TEscPrinterRongta.FeedMarkedPaper');
  Send(#$1D#$0C);
end;

procedure TEscPrinterRongta.SetPMAbsoluteVerticalPosition(n: Integer);
begin
  Logger.Debug('TEscPrinterRongta.SetPMAbsoluteVerticalPosition');
  Send(#$1D#$24 + Chr(Lo(n)) + Chr(Hi(n)));
end;

procedure TEscPrinterRongta.ExecuteTestPrint(p: Integer; n, m: Byte);
begin
  Logger.Debug('TEscPrinterRongta.ExecuteTestPrint');
  Send(#$1D#$28#$41 + Chr(Lo(p)) + Chr(Hi(p)) + Chr(n) + Chr(m));
end;

procedure TEscPrinterRongta.SelectCounterPrintMode(n, m: Byte);
begin
  Logger.Debug('TEscPrinterRongta.SelectCounterPrintMode');
  Send(#$1D#$43#$30 + Chr(n) + Chr(m));
end;

procedure TEscPrinterRongta.SelectCountMode(a, b: Word; n, r: Byte);
begin
  Logger.Debug('TEscPrinterRongta.SelectCountMode');
  Send(#$1D#$43#$31 + Chr(Lo(a)) + Chr(Hi(a)) +
    Chr(Lo(b)) + Chr(Hi(b)) + Chr(n) + Chr(r));
end;

procedure TEscPrinterRongta.SetCounter(n: Word);
begin
  Logger.Debug('TEscPrinterRongta.SetCounter');
  Send(#$1D#$43#$32 + Chr(Lo(n)) + Chr(Hi(n)));
end;

procedure TEscPrinterRongta.Select2DBarcode(n: Byte);
begin
  Logger.Debug('TEscPrinterRongta.Select2DBarcode');
  Send(#$1D#$5A + Chr(n));
end;

procedure TEscPrinterRongta.SetPMRelativeVerticalPosition(n: Word);
begin
  Logger.Debug('TEscPrinterRongta.SetPMRelativeVerticalPosition');
  Send(#$1D#$5C + Chr(Lo(n)) + Chr(Hi(n)));
end;

procedure TEscPrinterRongta.PrintCounter;
begin
  Logger.Debug('TEscPrinterRongta.PrintCounter');
  Send(#$1D#$63);
end;

procedure TEscPrinterRongta.SetNormalPrintMode;
var
  PrintMode: TPrintMode;
begin
  Logger.Debug('TEscPrinterRongta.SetNormalPrintMode');
  PrintMode.CharacterFontB := False;
  PrintMode.Emphasized := False;
  PrintMode.DoubleHeight := False;
  PrintMode.DoubleWidth := False;
  PrintMode.Underlined := False;
  SelectPrintMode(PrintMode);
end;

procedure TEscPrinterRongta.PrintText(Text: AnsiString);
begin
  //Logger.Debug(Format('TEscPrinterRongta.PrintText(''%s'')', [TrimRight(Text)]));
  Send(Text);
end;

function TEscPrinterRongta.CapRead: Boolean;
begin
  Result := Port.CapRead;
end;

procedure TEscPrinterRongta.CheckCapRead;
begin
  if not Port.CapRead then
  begin
    raise Exception.Create('ѕорт не поддерживает чтение');
  end;
end;

procedure TEscPrinterRongta.BeginDocument;
begin
  FInTransaction := True;
end;

procedure TEscPrinterRongta.EndDocument;
begin
  FInTransaction := False;
  Port.Flush;
end;

procedure TEscPrinterRongta.WriteKazakhCharacters;
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
  Code := FUserCharCode;
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
        Inc(FUserCharCode, Count);
      end;
      Code := FUserCharCode;
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
        Inc(FUserCharCode, Count);
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

procedure TEscPrinterRongta.WriteKazakhCharacters2;
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
    Data := GetBitmapData(Bitmap, 24);
    for i := 0 to Count-1 do
    begin
      FUserChars.Add(FUserCharCode, WideChar(KazakhUnicodeChars[i]), FONT_TYPE_A);
      BitmapData := Copy(Data, i*FontWidth + 1, FontWidth*3);
      Send(#$1B#$26#$03 + Chr(FUserCharCode) + Chr(FUserCharCode) + Chr(FontWidth) + BitmapData);
      Inc(FUserCharCode);
    end;
    // FONT_TYPE_B
    Bitmap.LoadFromFile(GetModulePath + 'Fonts\KazakhFontB.bmp');
    FontWidth := 9;
    BitmapData := '';
    Count := Bitmap.Width div FontWidth;
    Data := GetBitmapData(Bitmap, 17);
    for i := 0 to Count-1 do
    begin
      FUserChars.Add(FUserCharCode, WideChar(KazakhUnicodeChars[i]), FONT_TYPE_B);
      BitmapData := BitmapData + Chr(FontWidth) + Copy(Data, i*FontWidth + 1, FontWidth*3);
      Send(#$1B#$26#$03 + Chr(FUserCharCode) + Chr(FUserCharCode) + BitmapData);
      Inc(FUserCharCode);
    end;
  finally
    Bitmap.Free;
  end;
end;

function TEscPrinterRongta.IsUserChar(Char: WideChar): Boolean;
begin
  Result := IsKazakhUnicodeChar(Char);
end;

procedure TEscPrinterRongta.PrintUserChar(Char: WideChar);
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

end.

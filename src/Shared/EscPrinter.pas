unit EscPrinter;

interface

uses
  // VCL
  Graphics,
  // This
  ByteUtils;

const
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
  JUSTIFICATION_CENTERING = 1;
  JUSTIFICATION_RIGHT     = 2;

  /////////////////////////////////////////////////////////////////////////////
  // Codepage constants

  CODEPAGE_CP437      = 0;
  CODEPAGE_KATAKANA   = 1;
  CODEPAGE_CP850      = 2;
  CODEPAGE_CP860      = 3;
  CODEPAGE_CP863      = 4; // CANADIAN-FRENCH
  CODEPAGE_CP865      = 5;
  CODEPAGE_WCP1251    = 6;
  CODEPAGE_CP866      = 7;
  CODEPAGE_MIK        = 8;
  CODEPAGE_CP755      = 9;
  CODEPAGE_IRAN       = 10;
  CODEPAGE_RESERVE    = 11;
  CODEPAGE_CP862      = 15;
  CODEPAGE_WCP1252    = 16;
  CODEPAGE_WCP1253    = 17;
  CODEPAGE_CP852      = 18;
  CODEPAGE_CP858      = 19;
  CODEPAGE_IRAN_II    = 20;
  CODEPAGE_LATVIAN    = 21;
  CODEPAGE_CP864      = 22;
  CODEPAGE_ISO_8859_1 = 23;
  CODEPAGE_CP737      = 24;
  CODEPAGE_WCP1257    = 25;
  CODEPAGE_THAI       = 26;
  CODEPAGE_CP720_ARABIC = 27;
  CODEPAGE_CP855      = 28;
  CODEPAGE_CP857      = 29;
  CODEPAGE_WCP1250    = 30;
  CODEPAGE_CP775      = 31;
  CODEPAGE_WCP1254    = 32;
  CODEPAGE_WCP1255    = 33;
  CODEPAGE_WCP1256    = 34;
  CODEPAGE_WCP1258    = 35;
  CODEPAGE_ISO_8859_2 = 36;
  CODEPAGE_ISO_8859_3 = 37;
  CODEPAGE_ISO_8859_4 = 38;
  CODEPAGE_ISO_8859_5 = 39;
  CODEPAGE_ISO_8859_6 = 40;
  CODEPAGE_ISO_8859_7 = 41;
  CODEPAGE_ISO_8859_8 = 42;
  CODEPAGE_ISO_8859_9 = 43;
  CODEPAGE_ISO_8859_15 = 44;
  CODEPAGE_THAI2      = 45;
  CODEPAGE_CP856      = 46;
  CODEPAGE_CP874      = 47;

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

  BARCODE_UPC_A   = 0;
  BARCODE_UPC_E   = 1;
  BARCODE_JAN13   = 2;
  BARCODE_EAN8    = 3;
  BARCODE_CODE39  = 4;
  BARCODE_ITF     = 5;
  BARCODE_CODABAR = 6;
  BARCODE_CODE93  = 72;
  BARCODE_CODE128 = 73;

type
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

  { TPrintMode }

  TPrintMode = record
    CharacterFontB: Boolean;
    EmphasizedMode: Boolean;
    DoubleHeightMode: Boolean;
    DoubleWidthMode: Boolean;
    UnderlineMode: Boolean;
  end;

  { TUserChar }

  TUserChar = record
    c1: Byte;
    c2: Byte;
    Data: string;
  end;

  { TUnderlineMode }

  TUnderlineMode = (umNone, um1Dot, um2Dot);

  { TEscPrinter }

  TEscPrinter = class
  public
    function ReadByte: Byte;
    function ReadString: string;
    procedure Send(const Data: string);

    procedure HorizontalTab;
    procedure LineFeed;
    procedure CarriageReturn;
    function ReadPrinterStatus: TPrinterStatus;
    function ReadOfflineStatus: TOfflineStatus;
    function ReadErrorStatus: TErrorStatus;
    function ReadPaperStatus: TPaperStatus;
    procedure RecoverError(ClearBuffer: Boolean);
    procedure SetRightSideCharacterSpacing(SpacingInMm: Double);
    procedure SelectPrintMode(Mode: TPrintMode);
    procedure SetAbsolutePrintPosition(P: Double);
    procedure SelectUserCharacter(C: Byte);
    procedure DefineUserCharacter(C: TUserChar);
    procedure SelectBitImageMode(Mode: Integer; Image: TBitmap);
    procedure SetUnderlineMode(Mode: TUnderlineMode);
    procedure SetDefaultLineSpacing;
    procedure SetLineSpacing(B: Byte);
    procedure CancelUserCharacter(B: Byte);
    procedure Initialize;
    procedure SetBeepParams(N: Byte; T: Byte);
    procedure SetHorizontalTabPositions(Tabs: string);
    procedure SetEmphasizedMode(Value: Boolean);
    procedure SetDoubleStrikeMode(Value: Boolean);
    procedure PrintAndFeed(N: Byte);
    procedure SetCharacterFont(N: Byte);
    procedure SetCharacterSet(N: Byte);
    procedure Set90ClockwiseRotation(Value: Boolean);
    procedure SetRelativePrintPosition(N: Integer);
    procedure SetJustification(N: Byte);
    procedure EnableButtons(Value: Boolean);
    procedure PrintAndFeedLines(N: Byte);
    procedure SetCodeTable(n: Integer);
    procedure SetUpsideDownPrinting(Value: Boolean);
    procedure PartialCut;
    procedure PartialCut2;
    procedure SelectChineseCode(N: Byte);
    procedure PrintNVBitImage(N, M: Byte);
    procedure DefineNVBitImage(Image: TBitmap);
    procedure SetCharacterSize(N: Byte);
    procedure DownloadBitImage(Image: TBitmap);
    procedure PrintBmp(Mode: Byte);
    procedure SetWhiteBlackReverse(Value: Boolean);
    function ReadPrinterID(N: Byte): string;
    procedure SetHRIPosition(N: Byte);
    procedure SetLeftMargin(N: Word);
    procedure SetCutModeAndCutPaper(M: Byte);
    procedure SetPrintAreaWidth(M: Byte);
    procedure StartEndMacroDefinition;
    procedure ExecuteMacro(r, t, m: Byte);
    procedure EnableAutomaticStatusBack(N: Byte);
    procedure SetHRIFont(N: Byte);
    procedure SetBarcodeHeight(N: Byte);
    procedure PrintBarcode(BCType: Byte; const Data: string);
  end;

implementation

const
  CR = #13;
  LF = #10;
  HT = #09;

const
  BoolToInt: array [Boolean] of Integer = (0, 1);

{ TEscPrinter }

procedure TEscPrinter.Send(const Data: string);
begin
  { !!! }
end;

function TEscPrinter.ReadByte: Byte;
begin

end;

function TEscPrinter.ReadString: string;
begin
  Result := '';
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
  Send(LF);
end;

function TEscPrinter.ReadPrinterStatus: TPrinterStatus;
begin
  Send(#$10#$04#$01);
  Result.DrawerOpened := TestBit(ReadByte, 2);
end;

function TEscPrinter.ReadOfflineStatus: TOfflineStatus;
var
  B: Byte;
begin
  Send(#$10#$04#$02);
  B := ReadByte;
  Result.CoverOpened := TestBit(B, 2);
  Result.FeedButton := TestBit(B, 3);
  Result.ErrorOccurred := TestBit(B, 6);
end;

function TEscPrinter.ReadErrorStatus: TErrorStatus;
var
  B: Byte;
begin
  Send(#$10#$04#$03);
  B := ReadByte;
  Result.CutterError := TestBit(B, 3);
  Result.UnrecoverableError := TestBit(B, 5);
  Result.AutoRecoverableError := TestBit(B, 6);
end;

function TEscPrinter.ReadPaperStatus: TPaperStatus;
var
  B: Byte;
begin
  Send(#$10#$04#$04);
  B := ReadByte;
  Result.PaperPresent := TestBit(B, 5);
end;

procedure TEscPrinter.RecoverError(ClearBuffer: Boolean);
begin
  if ClearBuffer then
    Send(#$10#$05#$02)
  else
    Send(#$10#$05#$01);
end;

procedure TEscPrinter.SetRightSideCharacterSpacing(SpacingInMm: Double);
var
  B: Integer;
begin
  B := Round(SpacingInMm / 0.125);
  if (B >= 0)and(B <= 255) then
  begin
    Send(#$1B#$20 + Chr(B));
  end;
end;

procedure TEscPrinter.SelectPrintMode(Mode: TPrintMode);
var
  B: Byte;
begin
  B := 0;
  if Mode.CharacterFontB then SetBit(B, 0);
  if Mode.EmphasizedMode then SetBit(B, 3);
  if Mode.DoubleHeightMode then SetBit(B, 4);
  if Mode.DoubleWidthMode then SetBit(B, 5);
  if Mode.UnderlineMode then SetBit(B, 7);
  Send(#$1B#$21 + Chr(B));
end;

procedure TEscPrinter.SetAbsolutePrintPosition(P: Double);
var
  B: Word;
begin
  B := Round(P / 0.125);
  Send(#$1B#$24 + Chr(Lo(B)) + Chr(Hi(B)));
end;

procedure TEscPrinter.SelectUserCharacter(C: Byte);
begin
  Send(#$1B#$25 + Chr(C));
end;


(*
y = 3
32 c1 c2 126
0 „T x „T 12 (when Font A (12X24) is
selected) 0 „T x „T 9 (when Font B (9X17) is
selected)

*)
procedure TEscPrinter.DefineUserCharacter(C: TUserChar);
begin
  Send(#$1B#$26#$03 + Chr(C.c1) + Chr(C.c2) + C.Data);
end;

procedure TEscPrinter.SelectBitImageMode(Mode: Integer; Image: TBitmap);
var
  Data: string;
begin
  Send(#$1B#$2A + Chr(Mode) + Data);
end;

procedure TEscPrinter.SetUnderlineMode(Mode: TUnderlineMode);
begin
  Send(#$1B#$2D + Chr(Ord(Mode)));
end;

procedure TEscPrinter.SetDefaultLineSpacing;
begin
  Send(#$1B#$32);
end;

procedure TEscPrinter.SetLineSpacing(B: Byte);
begin
  Send(#$1B#$33 + Chr(B));
end;

procedure TEscPrinter.CancelUserCharacter(B: Byte);
begin
  Send(#$1B#$3F + Chr(B));
end;

procedure TEscPrinter.Initialize;
begin
  Send(#$1B#$40);
end;

procedure TEscPrinter.SetBeepParams(N, T: Byte);
begin
  Send(#$1B#$42 + Chr(N) + Chr(T));
end;

procedure TEscPrinter.SetHorizontalTabPositions(Tabs: string);
begin
  Send(#$1B#$44 + Tabs + #0);
end;

procedure TEscPrinter.SetEmphasizedMode(Value: Boolean);
begin
  Send(#$1B#$45 + Chr(BoolToInt[Value]));
end;

procedure TEscPrinter.SetDoubleStrikeMode(Value: Boolean);
begin
  Send(#$1B#$47 + Chr(BoolToInt[Value]));
end;

procedure TEscPrinter.PrintAndFeed(N: Byte);
begin
  Send(#$1B#$4A + Chr(N));
end;

procedure TEscPrinter.SetCharacterFont(N: Byte);
begin
  Send(#$1B#$4D + Chr(N));
end;

procedure TEscPrinter.SetCharacterSet(N: Byte);
begin
  Send(#$1B#$52 + Chr(N));
end;

procedure TEscPrinter.Set90ClockwiseRotation(Value: Boolean);
begin
  Send(#$1B#$56 + Chr(BoolToInt[Value]));
end;

procedure TEscPrinter.SetRelativePrintPosition(N: Integer);
begin
  Send(#$1B#$5C + Chr(Lo(N)) + Chr(Hi(N)));
end;

procedure TEscPrinter.SetJustification(N: Byte);
begin
  Send(#$1B#$61 + Chr(N));
end;

procedure TEscPrinter.EnableButtons(Value: Boolean);
begin
  Send(#$1B#$63#$35 + Chr(BoolToInt[Value]));
end;

procedure TEscPrinter.PrintAndFeedLines(N: Byte);
begin
  Send(#$1B#$64 + Chr(N));
end;

procedure TEscPrinter.SetCodeTable(n: Integer);
begin
  Send(#$1B#$74 + Chr(N));
end;

procedure TEscPrinter.SetUpsideDownPrinting(Value: Boolean);
begin
  Send(#$1B#$7B + Chr(BoolToInt[Value]));
end;

procedure TEscPrinter.PartialCut;
begin
  Send(#$1B#$69);
end;

procedure TEscPrinter.PartialCut2;
begin
  Send(#$1B#$6D);
end;

procedure TEscPrinter.SelectChineseCode(N: Byte);
begin
  Send(#$1B#$39 + Chr(N));
end;

procedure TEscPrinter.PrintNVBitImage(N, M: Byte);
begin
  Send(#$1C#$70 + Chr(N) + Chr(M));
end;

procedure TEscPrinter.DefineNVBitImage(Image: TBitmap);
begin
  { !!! }
end;

procedure TEscPrinter.SetCharacterSize(N: Byte);
begin
  Send(#$1D#$21 + Chr(N));
end;

procedure TEscPrinter.DownloadBitImage(Image: TBitmap);
begin
  { !!! }
end;

procedure TEscPrinter.PrintBmp(Mode: Byte);
begin
  Send(#$1D#$2F + Chr(Mode));
end;

procedure TEscPrinter.SetWhiteBlackReverse(Value: Boolean);
begin
  Send(#$1D#$42 + Chr(BoolToInt[Value]));
end;

function TEscPrinter.ReadPrinterID(N: Byte): string;
begin
  Send(#$1D#$42 + Chr(N));
  Result := ReadString;
end;

procedure TEscPrinter.SetHRIPosition(N: Byte);
begin
  Send(#$1D#$48 + Chr(N));
end;

procedure TEscPrinter.SetLeftMargin(N: Word);
begin
  Send(#$1D#$4C + Chr(Lo(N)) + Chr(Hi(N)));
end;

procedure TEscPrinter.SetCutModeAndCutPaper(M: Byte);
begin
  Send(#$1D#$56 + Chr(M));
end;

procedure TEscPrinter.SetPrintAreaWidth(M: Byte);
begin
  Send(#$1D#$57 + Chr(Lo(M)) + Chr(Hi(M)));
end;

procedure TEscPrinter.StartEndMacroDefinition;
begin
  Send(#$1D#$3A);
end;

procedure TEscPrinter.ExecuteMacro(r, t, m: Byte);
begin
  Send(#$1D#$5E + Chr(r) + Chr(t) + Chr(m));
end;

procedure TEscPrinter.EnableAutomaticStatusBack(N: Byte);
begin
  Send(#$1D#$61 + Chr(N));
end;

procedure TEscPrinter.SetHRIFont(N: Byte);
begin
  Send(#$1D#$66 + Chr(N));
end;

procedure TEscPrinter.SetBarcodeHeight(N: Byte);
begin
  Send(#$1D#$68 + Chr(N));
end;

procedure TEscPrinter.PrintBarcode(BCType: Byte; const Data: string);
begin
  Send(#$1D#$6B + Chr(BCType) + Data + #0);
end;

end.

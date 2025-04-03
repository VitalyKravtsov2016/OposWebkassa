unit EscCommand;

interface

uses
  // VCL
  Windows, Types, Classes, SysUtils, Graphics,
  // This
  EscPrinterUtils;

const
  CR    = #13;
  LF    = #10;
  HT    = #09;
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

  { TEscCommand }

  TEscCommand = class
  private
    procedure CheckUserCharCode(Code: Byte);
  public
    function PDF417Print: AnsiString;
    function PDF417ReadDataSize: AnsiString;
    function PDF417SetColumnNumber(n: Byte): AnsiString;
    function PDF417SetErrorCorrectionLevel(m, n: Byte): AnsiString;
    function PDF417SetModuleHeight(n: Byte): AnsiString;
    function PDF417SetModuleWidth(n: Byte): AnsiString;
    function PDF417SetOptions(m: Byte): AnsiString;
    function PDF417SetRowNumber(n: Byte): AnsiString;
    function PDF417Write(const data: AnsiString): AnsiString;

    function QRCodePrint: AnsiString;
    function QRCodeSetErrorCorrectionLevel(n: Byte): AnsiString;
    function QRCodeSetModuleSize(n: Byte): AnsiString;
    function QRCodeWriteData(Data: AnsiString): AnsiString;

    function EnableUserCharacters: AnsiString;
    function DisableUserCharacters: AnsiString;
  public
    function HorizontalTab: AnsiString;
    function LineFeed: AnsiString;
    function CarriageReturn: AnsiString;
    function ReadPrinterStatus: AnsiString;
    function ReadOfflineStatus: AnsiString;
    function ReadErrorStatus: AnsiString;
    function ReadPaperStatus: AnsiString;
    function RecoverError(ClearBuffer: Boolean): AnsiString;
    function GeneratePulse(n, m, t: Byte): AnsiString;
    function SetRightSideCharacterSpacing(n: Byte): AnsiString;
    function SelectPrintMode(Mode: TPrintMode): AnsiString;
    function SetPrintMode(Mode: Byte): AnsiString;
    function SetAbsolutePrintPosition(n: Word): AnsiString;
    function SelectUserCharacter(n: Byte): AnsiString;
    function DefineUserCharacter(C: TUserChar): AnsiString;
    function SelectBitImageMode(Mode: Integer; Image: TGraphic): AnsiString;
    function SetUnderlineMode(n: Byte): AnsiString;
    function SetDefaultLineSpacing: AnsiString;
    function SetLineSpacing(n: Byte): AnsiString;
    function CancelUserCharacter(n: Byte): AnsiString;
    function Initialize: AnsiString;
    function SetBeepParams(N: Byte; T: Byte): AnsiString;
    function SetHorizontalTabPositions(Tabs: AnsiString): AnsiString;
    function SetEmphasizedMode(Value: Boolean): AnsiString;
    function SetDoubleStrikeMode(Value: Boolean): AnsiString;
    function PrintAndFeed(N: Byte): AnsiString;
    function SetCharacterFont(N: Byte): AnsiString;
    function SetCharacterSet(N: Byte): AnsiString;
    function Set90ClockwiseRotation(Value: Boolean): AnsiString;
    function SetRelativePrintPosition(n: Word): AnsiString;
    function SetJustification(N: Byte): AnsiString;
    function EnableButtons(Value: Boolean): AnsiString;
    function PrintAndFeedLines(N: Byte): AnsiString;
    function SetCodePage(CodePage: Integer): AnsiString;
    function SetUpsideDownPrinting(Value: Boolean): AnsiString;
    function PartialCut: AnsiString;
    function PartialCut2: AnsiString;
    function SelectChineseCode(N: Byte): AnsiString;
    function PrintNVBitImage(Number, Mode: Byte): AnsiString;
    function DefineNVBitImage(Number: Byte; Image: TGraphic): AnsiString;
    function SetCharacterSize(N: Byte): AnsiString;
    function DownloadBMP(Image: TGraphic): AnsiString;
    function PrintBmp(Mode: Byte): AnsiString;
    function SetWhiteBlackReverse(Value: Boolean): AnsiString;
    function SetHRIPosition(N: Byte): AnsiString;
    function SetLeftMargin(N: Word): AnsiString;
    function SetCutModeAndCutPaper(M: Byte): AnsiString;
    function SetCutModeAndCutPaper2(n: Byte): AnsiString;
    function SetPrintAreaWidth(n: Byte): AnsiString;
    function StartEndMacroDefinition: AnsiString;
    function ExecuteMacro(r, t, m: Byte): AnsiString;
    function EnableAutomaticStatusBack(N: Byte): AnsiString;
    function SetHRIFont(N: Byte): AnsiString;
    function SetBarcodeHeight(N: Byte): AnsiString;
    function PrintBarcode(BCType: Byte; const Data: AnsiString): AnsiString;
    function PrintBarcode2(BCType: Byte; const Data: AnsiString): AnsiString;
    function ReadPaperRollStatus: AnsiString;
    function PrintRasterBMP(Mode: Byte; Image: TGraphic): AnsiString;
    function SetBarcodeWidth(N: Integer): AnsiString;
    function SetBarcodeLeft(N: Integer): AnsiString;
    function SetMotionUnits(x, y: Integer): AnsiString;
    function PrintTestPage: AnsiString;
    function SetKanjiMode(m: Byte): AnsiString;
    function SelectKanjiCharacter: AnsiString;
    function SetKanjiUnderline(Value: Boolean): AnsiString;
    function CancelKanjiCharacter: AnsiString;
    function DefineKanjiCharacters(c1, c2: Byte; const data: AnsiString): AnsiString;
    function SetPeripheralDevice(m: Byte): AnsiString;
    function SetKanjiSpacing(n1, n2: Byte): AnsiString;
    function PrintAndReturnStandardMode: AnsiString;
    function PrintDataInMode: AnsiString;
    function SetPageMode: AnsiString;
    function SetStandardMode: AnsiString;
    function SetPageModeDirection(n: Byte): AnsiString;
    function SetPageModeArea(R: TPageArea): AnsiString;
    function SetKanjiQuadSizeMode(Value: Boolean): AnsiString;
    function FeedMarkedPaper: AnsiString;
    function SetPMAbsoluteVerticalPosition(n: Integer): AnsiString;
    function ExecuteTestPrint(p: Integer; n, m: Byte): AnsiString;
    function SelectCounterPrintMode(n, m: Byte): AnsiString;
    function SelectCountMode(a, b: Word; n, r: Byte): AnsiString;
    function SetCounter(n: Word): AnsiString;
    function SetPMRelativeVerticalPosition(n: Word): AnsiString;
    function PrintCounter: AnsiString;
    function SetNormalPrintMode: AnsiString;
    function WriteUserChar(AChar: WideChar; ACode, AFont: Byte): AnsiString;
    function MaxiCodePrint: AnsiString;
    function MaxiCodeSetMode(n: Byte): AnsiString;
    function MaxiCodeWriteData(const Data: AnsiString): AnsiString;
    function SelectCodePage(B: Byte): AnsiString;
    function UTF8Enable(B: Boolean): AnsiString;
  end;

implementation

const
  BoolToInt: array [Boolean] of Integer = (0, 1);

{ TEscCommand }

function TEscCommand.CarriageReturn: AnsiString;
begin
  Result := CR;
end;

function TEscCommand.HorizontalTab: AnsiString;
begin
  Result := HT;
end;

function TEscCommand.LineFeed: AnsiString;
begin
  Result := LF;
end;

function TEscCommand.ReadPrinterStatus: AnsiString;
begin
  Result := #$10#$04#$01;
end;

function TEscCommand.ReadOfflineStatus: AnsiString;
begin
  Result := #$10#$04#$02;
end;

function TEscCommand.ReadErrorStatus: AnsiString;
begin
  Result := #$10#$04#$03;
end;

function TEscCommand.ReadPaperStatus: AnsiString;
begin
  Result := #$10#$04#$04;
end;

function TEscCommand.RecoverError(ClearBuffer: Boolean): AnsiString;
begin
  if ClearBuffer then
    Result := #$10#$05#$02
  else
    Result := #$10#$05#$01;
end;

function TEscCommand.GeneratePulse(n, m, t: Byte): AnsiString;
begin
  Result := #$10#$14 + Chr(n) + Chr(m) + Chr(t);
end;

function TEscCommand.SetRightSideCharacterSpacing(n: Byte): AnsiString;
begin
  Result := #$1B#$20 + Chr(n);
end;

function TEscCommand.SelectPrintMode(Mode: TPrintMode): AnsiString;
begin
  SetPrintMode(PrintModeToByte(Mode));
end;

function TEscCommand.SetPrintMode(Mode: Byte): AnsiString;
begin
  Result := #$1B#$21 + Chr(Mode);
end;

function TEscCommand.SetAbsolutePrintPosition(n: Word): AnsiString;
begin
  Result := #$1B#$24 + Chr(Lo(n)) + Chr(Hi(n));
end;

function TEscCommand.SelectUserCharacter(n: Byte): AnsiString;
begin
  Result := #$1B#$25 + Chr(n);
end;

function TEscCommand.EnableUserCharacters: AnsiString;
begin
  Result := SelectUserCharacter(1);
end;

function TEscCommand.DisableUserCharacters: AnsiString;
begin
  Result := SelectUserCharacter(0);
end;

procedure TEscCommand.CheckUserCharCode(Code: Byte);
begin
  if (not Code in [USER_CHAR_CODE_MIN..USER_CHAR_CODE_MAX]) then
    raise Exception.CreateFmt('Invalid character code, 0x%.2X', [Code]);
end;

///////////////////////////////////////////////////////////////////////////////
// Font A 12x24, font B 9x17
///////////////////////////////////////////////////////////////////////////////
// The allowable character code range is from ASCII code <20>H to
// <7E>H (95 characters).

function TEscCommand.WriteUserChar(AChar: WideChar; ACode, AFont: Byte): AnsiString;
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
    // Write
    UserChar.c1 := ACode;
    UserChar.c2 := ACode;
    UserChar.Font := AFont;
    UserChar.Data := GetBitmapData(Bitmap, Bitmap.Height);
    UserChar.Width := Bitmap.Width;
    Result := DefineUserCharacter(UserChar);
  finally
    Bitmap.Free;
  end;
end;

(*
y = 3
32 c1 c2 126
0 „T x „T 12 (when Font A (12X24) is
selected) 0 „T x „T 9 (when Font B (9X17) is
selected)

*)

function TEscCommand.DefineUserCharacter(C: TUserChar): AnsiString;
begin
  Result := #$1B#$26#$03 + Chr(C.c1) + Chr(C.c2) + Chr(C.Width) + C.Data;
end;

function TEscCommand.SelectBitImageMode(mode: Integer; Image: TGraphic): AnsiString;
var
  n: Word;
  data: AnsiString;
begin
  n := Image.Width;
  data := GetImageData2(Image);
  Result := #$1B#$2A + Chr(Mode) + Chr(Lo(n)) + Chr(Hi(n)) + data;
end;

function TEscCommand.SetUnderlineMode(n: Byte): AnsiString;
begin
  Result := #$1B#$2D + Chr(n);
end;

function TEscCommand.SetDefaultLineSpacing: AnsiString;
begin
  Result := #$1B#$32;
end;

function TEscCommand.SetLineSpacing(n: Byte): AnsiString;
begin
  Result := #$1B#$33 + Chr(n);
end;

function TEscCommand.CancelUserCharacter(n: Byte): AnsiString;
begin
  Result := #$1B#$3F + Chr(n);
end;

function TEscCommand.Initialize: AnsiString;
begin
  Result := #$1B#$40;
end;

function TEscCommand.SetBeepParams(N, T: Byte): AnsiString;
begin
  Result := #$1B#$42 + Chr(N) + Chr(T);
end;

function TEscCommand.SetHorizontalTabPositions(Tabs: AnsiString): AnsiString;
begin
  Result := #$1B#$44 + Tabs + #0;
end;

function TEscCommand.SetEmphasizedMode(Value: Boolean): AnsiString;
begin
  Result := #$1B#$45 + Chr(BoolToInt[Value]);
end;

function TEscCommand.SetDoubleStrikeMode(Value: Boolean): AnsiString;
begin
  Result := #$1B#$47 + Chr(BoolToInt[Value]);
end;

function TEscCommand.PrintAndFeed(n: Byte): AnsiString;
begin
  Result := #$1B#$4A + Chr(n);
end;

function TEscCommand.SetCharacterFont(n: Byte): AnsiString;
begin
  Result := #$1B#$4D + Chr(n);
end;

function TEscCommand.SetCharacterSet(N: Byte): AnsiString;
begin
  Result := #$1B#$52 + Chr(N);
end;

function TEscCommand.Set90ClockwiseRotation(Value: Boolean): AnsiString;
begin
  Result := #$1B#$56 + Chr(BoolToInt[Value]);
end;

function TEscCommand.SetRelativePrintPosition(n: Word): AnsiString;
begin
  Result := #$1B#$5C + Chr(Lo(n)) + Chr(Hi(n));
end;

function TEscCommand.SetJustification(N: Byte): AnsiString;
begin
  Result := #$1B#$61 + Chr(N);
end;

function TEscCommand.EnableButtons(Value: Boolean): AnsiString;
begin
  Result := #$1B#$63#$35 + Chr(BoolToInt[Value]);
end;

function TEscCommand.PrintAndFeedLines(N: Byte): AnsiString;
begin
  Result := #$1B#$64 + Chr(N);
end;

function TEscCommand.SetCodePage(CodePage: Integer): AnsiString;
begin
  Result := #$1B#$74 + Chr(CodePage);
end;

function TEscCommand.SetUpsideDownPrinting(Value: Boolean): AnsiString;
begin
  Result := #$1B#$7B + Chr(BoolToInt[Value]);
end;

function TEscCommand.PartialCut: AnsiString;
begin
  Result := #$1B#$69;
end;

function TEscCommand.PartialCut2: AnsiString;
begin
  Result := #$1B#$6D;
end;

function TEscCommand.SelectChineseCode(N: Byte): AnsiString;
begin
  Result := #$1B#$39 + Chr(N);
end;

function TEscCommand.PrintNVBitImage(Number, Mode: Byte): AnsiString;
begin
  Result := #$1C#$70 + Chr(Number) + Chr(Mode);
end;

function TEscCommand.DefineNVBitImage(Number: Byte; Image: TGraphic): AnsiString;
var
  x, y: Integer;
  Bitmap: TBitmap;
begin
  Bitmap := TBitmap.Create;
  try
    DrawImage(Image, Bitmap);

    x := (Bitmap.Width + 7) div 8;
    y := (Bitmap.Height + 7) div 8;
    Result := #$1C#$71 + Chr(Number) + Chr(Lo(x)) + Chr(Hi(x)) +
      Chr(Lo(y)) + Chr(Hi(y)) + GetBitmapData(Bitmap, Bitmap.Height);
  finally
    Bitmap.Free;
  end;
end;

function TEscCommand.SetCharacterSize(N: Byte): AnsiString;
begin
  Result := #$1D#$21 + Chr(N);
end;

function TEscCommand.DownloadBMP(Image: TGraphic): AnsiString;
var
  x, y: Byte;
  Bitmap: TBitmap;
begin
  Bitmap := TBitmap.Create;
  try
    DrawImage(Image, Bitmap);

    x := (Bitmap.Width + 7) div 8;
    y := (Bitmap.Height + 7) div 8;
    Result := #$1D#$2A + Chr(x) + Chr(y) + GetBitmapData(Bitmap, Bitmap.Height);
  finally
    Bitmap.Free;
  end;
end;

function TEscCommand.PrintBmp(Mode: Byte): AnsiString;
begin
  Result := #$1D#$2F + Chr(Mode);
end;

function TEscCommand.SetWhiteBlackReverse(Value: Boolean): AnsiString;
begin
  Result := #$1D#$42 + Chr(BoolToInt[Value]);
end;

function TEscCommand.SetHRIPosition(N: Byte): AnsiString;
begin
  Result := #$1D#$48 + Chr(N);
end;

function TEscCommand.SetLeftMargin(N: Word): AnsiString;
begin
  Result := #$1D#$4C + Chr(Lo(N)) + Chr(Hi(N));
end;

function TEscCommand.SetCutModeAndCutPaper(M: Byte): AnsiString;
begin
  Result := #$1D#$56 + Chr(M);
end;

function TEscCommand.SetCutModeAndCutPaper2(n: Byte): AnsiString;
begin
  Result := #$1D#$56#$66 + Chr(n);
end;

function TEscCommand.SetPrintAreaWidth(n: Byte): AnsiString;
begin
  Result := #$1D#$57 + Chr(Lo(n)) + Chr(Hi(n));
end;

function TEscCommand.StartEndMacroDefinition: AnsiString;
begin
  Result := #$1D#$3A;
end;

function TEscCommand.ExecuteMacro(r, t, m: Byte): AnsiString;
begin
  Result := #$1D#$5E + Chr(r) + Chr(t) + Chr(m);
end;

function TEscCommand.EnableAutomaticStatusBack(N: Byte): AnsiString;
begin
  Result := #$1D#$61 + Chr(N);
end;

function TEscCommand.SetHRIFont(N: Byte): AnsiString;
begin
  Result := #$1D#$66 + Chr(N);
end;

function TEscCommand.SetBarcodeHeight(N: Byte): AnsiString;
begin
  Result := #$1D#$68 + Chr(N);
end;

function TEscCommand.PrintBarcode(BCType: Byte; const Data: AnsiString): AnsiString;
begin
  Result := #$1D#$6B + Chr(BCType) + Data + #0;
end;

function TEscCommand.PrintBarcode2(BCType: Byte; const Data: AnsiString): AnsiString;
begin
  Result := #$1D#$6B + Chr(BCType) + Chr(Length(Data)) + Data;
end;

function TEscCommand.ReadPaperRollStatus: AnsiString;
begin
  Result := #$1D#$72#$01;
end;

function TEscCommand.PrintRasterBMP(Mode: Byte; Image: TGraphic): AnsiString;
var
  x, y: Byte;
begin
  x := (Image.Width + 7) div 8;
  y := Image.Height;
  Result := #$1D#$76#$30 + Chr(Mode) + Chr(Lo(x)) + Chr(Hi(x)) +
    Chr(Lo(y)) + Chr(Hi(y)) + GetRasterImageData(Image);
end;

function TEscCommand.SetBarcodeWidth(N: Integer): AnsiString;
begin
  Result := #$1D#$77 + Chr(N);
end;

function TEscCommand.SetBarcodeLeft(N: Integer): AnsiString;
begin
  Result := #$1D#$78 + Chr(N);
end;

function TEscCommand.SetMotionUnits(x, y: Integer): AnsiString;
begin
  Result := #$1D#$50 + Chr(x) + Chr(y);
end;

function TEscCommand.PrintTestPage: AnsiString;
begin
  Result := #$12#$54;
end;

function TEscCommand.SetKanjiMode(m: Byte): AnsiString;
begin
  Result := #$1C#$21 + Chr(m);
end;

function TEscCommand.SelectKanjiCharacter: AnsiString;
begin
  Result := #$1C#$26;
end;

function TEscCommand.SetKanjiUnderline(Value: Boolean): AnsiString;
begin
  Result := #$1C#$2D + Chr(BoolToInt[Value]);
end;

function TEscCommand.CancelKanjiCharacter: AnsiString;
begin
  Result := #$1C#$2E;
end;

function TEscCommand.DefineKanjiCharacters(c1, c2: Byte;
  const data: AnsiString): AnsiString;
begin
  Result := #$1C#$32 + Chr(c1) + Chr(c2) + data;
end;

function TEscCommand.SetPeripheralDevice(m: Byte): AnsiString;
begin
  Result := #$1B#$3D + Chr(m);
end;

function TEscCommand.SetKanjiSpacing(n1, n2: Byte): AnsiString;
begin
  Result := #$1C#$53 + Chr(n1) + Chr(n2);
end;

function TEscCommand.PrintAndReturnStandardMode: AnsiString;
begin
  Result := #$0C;
end;

function TEscCommand.PrintDataInMode: AnsiString;
begin
  Result := #$1B#$0C;
end;

function TEscCommand.SetPageMode: AnsiString;
begin
  Result := #$1B#$4C;
end;

function TEscCommand.SetStandardMode: AnsiString;
begin
  Result := #$1B#$53;
end;

function TEscCommand.SetPageModeDirection(n: Byte): AnsiString;
begin
  Result := #$1B#$54 + Chr(n);
end;

function TEscCommand.SetPageModeArea(R: TPageArea): AnsiString;
begin
  Result := #$1B#$57 +
    Chr(Lo(R.X)) + Chr(Hi(R.X)) +
    Chr(Lo(R.Y)) + Chr(Hi(R.Y)) +
    Chr(Lo(R.Width)) + Chr(Hi(R.Width)) +
    Chr(Lo(R.Height)) + Chr(Hi(R.Height));
end;

function TEscCommand.SetKanjiQuadSizeMode(Value: Boolean): AnsiString;
begin
  Result := #$1C#$57 + Chr(BoolToInt[Value]);
end;

function TEscCommand.FeedMarkedPaper: AnsiString;
begin
  Result := #$1D#$0C;
end;

function TEscCommand.SetPMAbsoluteVerticalPosition(n: Integer): AnsiString;
begin
  Result := #$1D#$24 + Chr(Lo(n)) + Chr(Hi(n));
end;

function TEscCommand.ExecuteTestPrint(p: Integer; n, m: Byte): AnsiString;
begin
  Result := #$1D#$28#$41 + Chr(Lo(p)) + Chr(Hi(p)) + Chr(n) + Chr(m);
end;

function TEscCommand.SelectCounterPrintMode(n, m: Byte): AnsiString;
begin
  Result := #$1D#$43#$30 + Chr(n) + Chr(m);
end;

function TEscCommand.SelectCountMode(a, b: Word; n, r: Byte): AnsiString;
begin
  Result := #$1D#$43#$31 + Chr(Lo(a)) + Chr(Hi(a)) +
    Chr(Lo(b)) + Chr(Hi(b)) + Chr(n) + Chr(r);
end;

function TEscCommand.SetCounter(n: Word): AnsiString;
begin
  Result := #$1D#$43#$32 + Chr(Lo(n)) + Chr(Hi(n));
end;

function TEscCommand.SetPMRelativeVerticalPosition(n: Word): AnsiString;
begin
  Result := #$1D#$5C + Chr(Lo(n)) + Chr(Hi(n));
end;

function TEscCommand.PrintCounter: AnsiString;
begin
  Result := #$1D#$63;
end;

function TEscCommand.SetNormalPrintMode: AnsiString;
var
  PrintMode: TPrintMode;
begin
  PrintMode.CharacterFontB := False;
  PrintMode.Emphasized := False;
  PrintMode.DoubleHeight := False;
  PrintMode.DoubleWidth := False;
  PrintMode.Underlined := False;
  Result := SelectPrintMode(PrintMode);
end;

function TEscCommand.QRCodeSetModuleSize(n: Byte): AnsiString;
begin
  Result := #$1D#$28#$6B#$30#$67 + Chr(n);
end;

function TEscCommand.QRCodeSetErrorCorrectionLevel(n: Byte): AnsiString;
begin
  Result := #$1D#$28#$6B#$30#$69 + Chr(n);
end;

function TEscCommand.QRCodeWriteData(Data: AnsiString): AnsiString;
var
  L: Word;
begin
  L := Length(Data);
  Result := #$1D#$28#$6B#$30#$80 + Chr(Lo(L)) + Chr(Hi(L)) + Data;
end;

function TEscCommand.QRCodePrint: AnsiString;
begin
  Result := #$1D#$28#$6B#$30#$81;
end;

function TEscCommand.PDF417SetColumnNumber(n: Byte): AnsiString;
begin
  Result := #$1D#$28#$6B#$03#$00#$30#$41 + Chr(n);
end;

function TEscCommand.PDF417SetRowNumber(n: Byte): AnsiString;
begin
  Result := #$1D#$28#$6B#$03#$00#$30#$42 + Chr(n);
end;

function TEscCommand.PDF417SetModuleWidth(n: Byte): AnsiString;
begin
  Result := #$1D#$28#$6B#$03#$00#$30#$43 + Chr(n);
end;

function TEscCommand.PDF417SetModuleHeight(n: Byte): AnsiString;
begin
  Result := #$1D#$28#$6B#$03#$00#$30#$44 + Chr(n);
end;

function TEscCommand.PDF417SetErrorCorrectionLevel(m, n: Byte): AnsiString;
begin
  Result := #$1D#$28#$6B#$03#$00#$30#$45 + Chr(m) + Chr(n);
end;

function TEscCommand.PDF417SetOptions(m: Byte): AnsiString;
begin
  Result := #$1D#$28#$6B#$03#$00#$30#$46 + Chr(m);
end;

function TEscCommand.PDF417Write(const data: AnsiString): AnsiString;
var
  L: Word;
begin
  L := Length(Data) + 3;
  Result := #$1D#$28#$6B + Chr(Lo(L)) + Chr(Hi(L)) + #$30#$50#$30 + Data;
end;

function TEscCommand.PDF417Print: AnsiString;
begin
  Result := #$1D#$28#$6B#$03#$00#$30#$51#$30;
end;

function TEscCommand.PDF417ReadDataSize: AnsiString;
begin
  Result := #$1D#$28#$6B#$03#$00#$30#$52#$30;
end;

function TEscCommand.MaxiCodeSetMode(n: Byte): AnsiString;
begin
  Result := #$1D#$28#$6B#$03#$00#$32#$41 + Chr(n);
end;

function TEscCommand.MaxiCodeWriteData(const Data: AnsiString): AnsiString;
var
  L: Word;
begin
  L := Length(Data) + 3;
  Result := #$1D#$28#$6B + Chr(Lo(L)) + Chr(Hi(L)) + #$32#$50#$30 + Data;
end;

function TEscCommand.MaxiCodePrint: AnsiString;
begin
  Result := #$1D#$28#$6B#$03#$00#$32#$51#$30;
end;

function TEscCommand.UTF8Enable(B: Boolean): AnsiString;
begin
  Result := #$1F#$1B#$10#$01#$02 + Chr(BoolToInt[B]);
end;

function TEscCommand.SelectCodePage(B: Byte): AnsiString;
begin
  Result := #$1F#$1B#$1F#$FF + Chr(B) + #$0A#$00;
end;

end.

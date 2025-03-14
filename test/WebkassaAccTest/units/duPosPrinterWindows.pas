unit duPosPrinterWindows;

interface

uses
  // VCL
  Windows, SysUtils, Classes, Forms, Printers, Graphics,
  // DUnit
  TestFramework,
  // Opos
  Opos, OposEsc, Oposhi, OposPtr, OposPtrUtils, OposUtils,
  OposPOSPrinter_CCO_TLB, OposEvents,
  // Tnt
  TntClasses, TntSysUtils,
  // JVCL
  JvUnicodeCanvas,
  // This
  DebugUtils, StringUtils, SocketPort, LogFile, PosPrinterWindows,
  EscPrinterUtils;

type
  { TPosPrinterWindowsTest }

  TPosPrinterWindowsTest = class(TTestCase)
  private
    FLogger: ILogFile;
    FPrinter: TPosPrinterWindows;

    procedure ClaimDevice;
    procedure EnableDevice;
    procedure OpenService;
    procedure OpenClaimEnable;
    procedure PtrCheck(Code: Integer);

    property Printer: TPosPrinterWindows read FPrinter;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestCheckHealth;
    procedure TestPrintBarCode;
    procedure TestPrintBarCode2;
    procedure TestPrintBarCodeEsc;
    procedure TestPrintReceipt;
    procedure TestPrintNormal;
    procedure TestPrintNormal2;
    procedure TestPageMode2;
    procedure TestFonts;
    procedure TestFont;
  end;

implementation

{ TPosPrinterWindowsTest }

procedure TPosPrinterWindowsTest.PtrCheck(Code: Integer);
var
  Text: WideString;
begin
  if Code <> OPOS_SUCCESS then
  begin
    if Printer.ResultCode = OPOS_E_EXTENDED then
      Text := Tnt_WideFormat('%d, %d, %s [%s]', [Printer.ResultCode, Printer.ResultCodeExtended,
      PtrResultCodeExtendedText(Printer.ResultCodeExtended), Printer.ErrorString])
    else
      Text := Tnt_WideFormat('%d, %s [%s]', [Printer.ResultCode,
        GetResultCodeText(Printer.ResultCode), Printer.ErrorString]);

    raise Exception.Create(Text);
  end;
end;

const
  PrinterName = 'RONGTA 80mm Series Printer';

procedure TPosPrinterWindowsTest.SetUp;
begin
  inherited SetUp;
  FLogger := TLogFile.Create;
  FLogger.Enabled := True;
  FLogger.MaxCount := 10;
  FLogger.FilePath := 'Logs';
  FLogger.DeviceName := 'DeviceName';
  FPrinter := TPosPrinterWindows.Create(FLogger, nil);
  FPrinter.PrinterName := PrinterName;
  //FPrinter.FontName := 'FontA11';
  FPrinter.FontName := 'Cascadia Mono';
  //FPrinter.FontName := 'Lucida Console';
  //Printers.Printer.PrinterIndex := Printers.Printer.Printers.IndexOf(PrinterName);
  Printers.Printer.Fonts.SaveToFile('FontNames.txt');

  (*
  FPrinter.TopLogoFile := Params.TopLogoFile;
  FPrinter.BottomLogoFile := Params.BottomLogoFile;
  FPrinter.BitmapFiles := Params.BitmapFiles;
  *)
end;

procedure TPosPrinterWindowsTest.TearDown;
begin
  FPrinter.Close;
  FPrinter.Free;
  inherited TearDown;
end;

procedure TPosPrinterWindowsTest.OpenService;
begin
  PtrCheck(Printer.Open(PrinterName));

  CheckEquals(OPOS_PR_NONE, Printer.CapPowerReporting, 'CapPowerReporting');
  CheckEquals(OPOS_PN_DISABLED, Printer.PowerNotify, 'PowerNotify');
  CheckEquals(False, Printer.FreezeEvents, 'FreezeEvents');

  if Printer.CapPowerReporting <> OPOS_PR_NONE then
  begin
    Printer.PowerNotify := OPOS_PN_ENABLED;
    CheckEquals(OPOS_PN_ENABLED, Printer.PowerNotify, 'PowerNotify');
  end;
end;

procedure TPosPrinterWindowsTest.ClaimDevice;
begin
  CheckEquals(False, Printer.Claimed, 'Printer.Claimed');
  PtrCheck(Printer.ClaimDevice(1000));
  CheckEquals(True, Printer.Claimed, 'Printer.Claimed');
end;

procedure TPosPrinterWindowsTest.EnableDevice;
begin
  Printer.DeviceEnabled := True;
  PtrCheck(Printer.ResultCode);
  CheckEquals(True, Printer.DeviceEnabled, 'DeviceEnabled <> True');
end;

procedure TPosPrinterWindowsTest.OpenClaimEnable;
begin
  OpenService;
  ClaimDevice;
  EnableDevice;
end;

procedure TPosPrinterWindowsTest.TestCheckHealth;
begin
  OpenClaimEnable;
  PtrCheck(Printer.CheckHealth(OPOS_CH_INTERACTIVE));
end;

procedure TPosPrinterWindowsTest.TestPrintBarCode;
const
  Barcode = 'http://dev.kofd.kz/consumer?i=925871425876&f=211030200207&s=15443.72&t=20220826T210014';
  CRLF = #13#10;
var
  i: Integer;
begin
  OpenClaimEnable;

  if Printer.CapTransaction then
  begin
    PtrCheck(Printer.TransactionPrint(PTR_S_RECEIPT, PTR_TP_TRANSACTION));
  end;
  for i := 0 to 10 do
  begin
    PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, 'Line ' + IntToStr(i) + CRLF));
  end;
  PtrCheck(Printer.PrintBarCode(PTR_S_RECEIPT, Barcode, PTR_BCS_DATAMATRIX, 0, 4,
    PTR_BC_CENTER, PTR_BC_TEXT_NONE));

  for i := 0 to 10 do
  begin
    PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, 'Line ' + IntToStr(i) + CRLF));
  end;
  PtrCheck(Printer.CutPaper(90));
  if Printer.CapTransaction then
  begin
    Printer.TransactionPrint(PTR_S_RECEIPT, PTR_TP_NORMAL);
  end;
end;

procedure TPosPrinterWindowsTest.TestPrintBarCode2;
const
  Barcode = 'http://dev.kofd.kz/consumer?i=925871425876&f=211030200207&s=15443.72&t=20220826T210014';
  CRLF = #13#10;
begin
  OpenClaimEnable;

  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, 'FPrinter.BarcodeInGraphics = True' + CRLF));
  PtrCheck(Printer.PrintBarCode(PTR_S_RECEIPT, Barcode + CRLF,
    PTR_BCS_QRCODE, 200, 200, PTR_BC_CENTER, PTR_BC_TEXT_NONE));
end;

procedure TPosPrinterWindowsTest.TestPrintBarCodeEsc;
var
  L: Word;
  Data: string;
const
  Barcode = 'http://dev.kofd.kz/consumer?i=925871425876&f=211030200207&s=15443.72&t=20220826T210014';
begin
  OpenClaimEnable;

  //Data := #$1B#$64#$0A;
  //PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, Data));
  //PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, ESC + '|1fT' + 'Typeface 1' + CRLF));
  //PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, ESC + '|2fT' + 'Typeface 2' + CRLF));
  //PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, ESC + '|90P' + CRLF));

  // Select QR code model
  //Data := #$1D#$28#$6B#$04#$00#$31#$41#$31#$00;
  //PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, Data));

  // Set QR code module size
  Data := #$1D#$28#$6B#$03#$00#$31#$43#$04;
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, Data));

  L := Length(Barcode);

  Data := #$1D#$28#$6B + Chr(Lo(L)) + Chr(Hi(L)) + #$31#$50#$30 + Barcode;
  ODS(StrToHex(Data));
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, Data));

  Data := GS + '(k'+ #$03#$00#$31#$51#$30 + CRLF;
  ODS(StrToHex(Data));
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, Data));

(*
  // ESC/POS Command Manual
  Data := ESC + '|33Rs101h200w400a-2t-13d123456789012e' + CRLF;
  PtrCheck(Printer.ValidateData(PTR_S_RECEIPT, Data));
  //PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, Data));
*)
end;

procedure TPosPrinterWindowsTest.TestPrintReceipt;
var
  i: Integer;
const
  Barcode = 'http://dev.kofd.kz/consumer?i=925871425876&f=211030200207&s=15443.72&t=20220826T210014';
begin
  OpenClaimEnable;

  if Printer.CapTransaction then
  begin
    PtrCheck(Printer.TransactionPrint(PTR_S_RECEIPT, PTR_TP_TRANSACTION));
  end;
  for i := 1 to 5 do
  begin
    PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, '—ÚÓÍ‡ ' + IntToStr(i) + CRLF));
  end;
  PtrCheck(Printer.PrintBarCode(PTR_S_RECEIPT, Barcode, PTR_BCS_QRCODE, 0, 4,
    PTR_BC_CENTER, PTR_BC_TEXT_NONE));

  for i := 1 to 5 do
  begin
    PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, '—ÚÓÍ‡ ' + IntToStr(i) + CRLF));
  end;
  PtrCheck(Printer.CutPaper(90));
  if Printer.CapTransaction then
  begin
    Printer.TransactionPrint(PTR_S_RECEIPT, PTR_TP_NORMAL);
  end;
end;

procedure TPosPrinterWindowsTest.TestPrintNormal2;
var
  Y: Integer;
  Text: WideString;
  Canvas: TJvUnicodeCanvas;

  procedure PrintTest(const FontName: string);
  var
    TextSize: TSize;
  begin
    Canvas.Font.Size := 18;
    //Canvas.Font.Style := [fsBold];
    Canvas.Font.Style := [];
    Canvas.Font.Name := FontName;
    TextSize := Canvas.TextExtentW(Text);

    Canvas.TextOutW(0, Y, '----------------------------------------');
    Inc(Y, TextSize.cy);

    Canvas.TextOutW(0, Y, FontName);
    Inc(Y, TextSize.cy);

    Text := 'KAZAKH CHARACTERS: ' + GetKazakhUnicodeChars;
    Canvas.TextOutW(0, Y, Text);
    Inc(Y, TextSize.cy);

    Text := ' ¿«¿’— »≈ —»Ã¬ŒÀ€: ' + GetKazakhUnicodeChars;
    Canvas.TextOutW(0, Y, Text);
    Inc(Y, TextSize.cy);

    Text := 'ARABIC CHARACTERS: ';
    Text := Text + WideChar($062B) + WideChar($062C) + WideChar($0635);
    Canvas.TextOutW(0, Y, Text);
    Inc(Y, TextSize.cy);
  end;

begin
  Y := 0;
  Canvas := TJvUnicodeCanvas.Create;
  try
    Printers.Printer.PrinterIndex := Printers.Printer.Printers.IndexOf(PrinterName);

    Printers.Printer.BeginDoc;
    Canvas.Handle := Printers.Printer.Canvas.Handle;

    //Canvas.Font.Name := 'Lucida Sans Unicode';
    //Canvas.Font.Name := 'Lucida Console';
    //Canvas.Font.Name := 'Courier New';


    PrintTest('Cascadia Mono ExtraLight');
    PrintTest('Cascadia Mono Light');
    PrintTest('Cascadia Mono SemiLight');
    PrintTest('Cascadia Mono');
    PrintTest('Cascadia Mono SemiBold');
    PrintTest('Cascadia Mono PL ExtraLight');
    PrintTest('Cascadia Mono PL Light');
    PrintTest('Cascadia Mono PL SemiLight');
    PrintTest('Cascadia Mono PL');
    PrintTest('Cascadia Mono PL SemiBold');


    Printers.Printer.EndDoc;
  finally
    Canvas.Free;
  end;
end;

procedure TPosPrinterWindowsTest.TestPrintNormal;

  procedure PrintUnicodeChars;
  var
    Text: WideString;
  begin
    Text := 'KAZAKH CHARACTERS: ' + GetKazakhUnicodeChars;
    PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, Text + CRLF));
    Text := ' ¿«¿’— »≈ —»Ã¬ŒÀ€: ' + GetKazakhUnicodeChars;
    PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, Text + CRLF));
    Text := 'ARABIC CHARACTERS: ';
    Text := Text + WideChar($062B) + WideChar($062C) + WideChar($0635);
    PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, Text + CRLF));
  end;

var
  Separator: string;
begin
  OpenClaimEnable;

  Separator := StringOfChar('-', Printer.RecLineChars) + CRLF;

  Printer.CharacterSet := PTR_CS_UNICODE;
  if Printer.CapTransaction then
  begin
    PtrCheck(Printer.TransactionPrint(PTR_S_RECEIPT, PTR_TP_TRANSACTION));
  end;
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, 'Line 1' + CRLF));
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, 'Line 2' + CRLF));
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, 'Line 3' + CRLF));

  //Printer.FontName := FontNameA;
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, Separator));
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, 'FONT A' + CRLF));
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, Separator));
  PrintUnicodeChars;

  //Printer.FontName := FontNameB;
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, Separator));
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, 'FONT B' + CRLF));
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, Separator));
  PrintUnicodeChars;

  if Printer.CapTransaction then
  begin
    PtrCheck(Printer.TransactionPrint(PTR_S_RECEIPT, PTR_TP_NORMAL));
  end;
end;

procedure TPosPrinterWindowsTest.TestPageMode2;
var
  PrintArea: TPageArea;
const
  Barcode = 'http://dev.kofd.kz/consumer?i=1556041617048&f=768814097419&s=3098.00&t=20241211T151839';
  BarcodeWidth = 200;
  PrintWidth = 576;
begin
  OpenClaimEnable;
  if Printer.CapTransaction then
  begin
    PtrCheck(Printer.TransactionPrint(PTR_S_RECEIPT, PTR_TP_TRANSACTION));
  end;

  CheckEquals(PrintWidth, FPrinter.RecLineWidth, 'RecLineWidth');
  // Start pagemode
  Printer.PageModePrint(PTR_PM_PAGE_MODE);
  // Barcode PageModeArea
  PrintArea.X := PrintWidth - BarcodeWidth;
  PrintArea.Y := 0;
  PrintArea.Width := PrintWidth - PrintArea.X;
  PrintArea.Height := BarcodeWidth * 2;
  Printer.PageModePrintArea := PageAreaToStr(PrintArea);
  // Barcode
  PtrCheck(Printer.PrintBarCode(PTR_S_RECEIPT, Barcode,
    PTR_BCS_QRCODE, 0, 0, PTR_BC_CENTER, PTR_BC_TEXT_NONE));
  // Text PageModeArea
  PrintArea.X := 0;
  PrintArea.Y := 0;
  PrintArea.Width := PrintWidth - BarcodeWidth - 10;
  PrintArea.Height := BarcodeWidth * 2;
  Printer.PageModePrintArea := PageAreaToStr(PrintArea);
  // Text
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, '01234567890123456789012345678901234567890123456789' + CRLF));
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, '01234567890123456789012345678901234567890123456789' + CRLF));
  // Stop pagemode
  Printer.PageModePrint(PTR_PM_NORMAL);

  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, 'After page mode 1' + CRLF));
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, 'After page mode 2' + CRLF));
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, 'After page mode 3' + CRLF));

  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, ' ' + CRLF));
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, ' ' + CRLF));
  Printer.CutPaper(90);
  if Printer.CapTransaction then
  begin
    Printer.TransactionPrint(PTR_S_RECEIPT, PTR_TP_NORMAL);
  end;
end;

procedure TPosPrinterWindowsTest.TestFonts;
var
  Fonts: TStringList;
begin
  Fonts := TStringList.Create;
  try
    Printers.Printer.PrinterIndex := Printers.Printer.Printers.IndexOf(PrinterName);
    Fonts.Text := GetDeviceFonts(Printers.Printer.Handle);
    CheckEquals(2, Fonts.Count, 'GetDeviceFonts');

    Fonts.Text := GetRasterFonts(Printers.Printer.Handle);
    CheckEquals(33, Fonts.Count, 'GetRasterFonts');
    Fonts.SaveToFile('Fonts.txt');
  finally
    Fonts.Free;
  end;
end;

procedure TPosPrinterWindowsTest.TestFont;
var
  TextSize: TSize;
begin
  Printers.Printer.PrinterIndex := Printers.Printer.Printers.IndexOf('RONGTA 80mm Series Printer');
  Printers.Printer.Canvas.Font.Name := 'Lucida Console';

  Printers.Printer.Canvas.Font.Size := 8;
  TextSize := Printers.Printer.Canvas.TextExtent('A');
  CheckEquals(14, TextSize.cx, 'TextSize.cx');
  CheckEquals(23, TextSize.cy, 'TextSize.cy');

  Printers.Printer.Canvas.Font.Size := 9;
  TextSize := Printers.Printer.Canvas.TextExtent('A');
  CheckEquals(15, TextSize.cx, 'TextSize.cx');
  CheckEquals(25, TextSize.cy, 'TextSize.cy');


  Printers.Printer.Canvas.Font.Name := 'FontA11';
  Printers.Printer.Canvas.Font.Size := 8;
  TextSize := Printers.Printer.Canvas.TextExtent('A');
  CheckEquals(14, TextSize.cx, 'FontA11, TextSize.cx');
  CheckEquals(25, TextSize.cy, 'FontA11, TextSize.cy');

  Printers.Printer.Canvas.Font.Size := 30;
  TextSize := Printers.Printer.Canvas.TextExtent('A');
  CheckEquals(14, TextSize.cx, 'FontA11, TextSize.cx');
  CheckEquals(25, TextSize.cy, 'FontA11, TextSize.cy');


  Printers.Printer.Canvas.Font.Name := 'FontA12';
  Printers.Printer.Canvas.Font.Size := 8;
  TextSize := Printers.Printer.Canvas.TextExtent('A');
  CheckEquals(14, TextSize.cx, 'FontA12, TextSize.cx');
  CheckEquals(44, TextSize.cy, 'FontA12, TextSize.cy');

  Printers.Printer.Canvas.Font.Size := 30;
  TextSize := Printers.Printer.Canvas.TextExtent('A');
  CheckEquals(14, TextSize.cx, 'FontA12, TextSize.cx');
  CheckEquals(44, TextSize.cy, 'FontA12, TextSize.cy');

end;

initialization
  RegisterTest('', TPosPrinterWindowsTest.Suite);

end.

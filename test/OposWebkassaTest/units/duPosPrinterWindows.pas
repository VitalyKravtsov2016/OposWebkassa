unit duPosPrinterWindows;

interface

uses
  // VCL
  Windows, SysUtils, Classes, Graphics,
  // JVCL
  JvUnicodeCanvas,
  // DUnit
  TestFramework,
  // 3'd
  TntClasses, Opos, OposPtr, OposPtrUtils, OposEsc,
  // This
  LogFile, PosPrinterWindows, MockPrinterPort, PrinterPort, StringUtils,
  CustomPrinter, FileUtils, EscPrinterUtils, PrinterTypes;

type
  { TPosPrinterWindowsTest }

  TPosPrinterWindowsTest = class(TTestCase)
  private
    FLogger: ILogFile;
    FWinPrinter: TBmpPrinter;
    FPrinter: TPosPrinterWindows;

    procedure OpenService;
    procedure ClaimDevice;
    procedure EnableDevice;
    procedure OpenClaimEnable;
    procedure PtrCheck(Code: Integer);

    property Printer: TPosPrinterWindows read FPrinter;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestRecLineChars;
    procedure TestPrintReceipt;
    procedure TestPageMode;
    procedure TestPageMode2;
    procedure TestPageMode3;
    procedure TestUnicodeCanvas;
  end;

implementation

{ TPosPrinterWindowsTest }

procedure TPosPrinterWindowsTest.SetUp;
begin
  FLogger := TLogFile.Create;
  FWinPrinter := TBmpPrinter.Create;
  FPrinter := TPosPrinterWindows.Create(FLogger, FWinPrinter);
  FPrinter.FontName := 'Courier New';
end;

procedure TPosPrinterWindowsTest.TearDown;
begin
  FPrinter.Free;
end;

procedure TPosPrinterWindowsTest.PtrCheck(Code: Integer);
var
  Text: WideString;
begin
  if Code <> OPOS_SUCCESS then
  begin
    if Printer.ResultCode = OPOS_E_EXTENDED then
      Text := Format('%d, %d, %s [%s]', [Printer.ResultCode, Printer.ResultCodeExtended,
      PtrResultCodeExtendedText(Printer.ResultCodeExtended), Printer.ErrorString])
    else
      Text := Format('%d, %s [%s]', [Printer.ResultCode,
        PtrResultCodeExtendedText(Printer.ResultCode), Printer.ErrorString]);

    raise Exception.Create(Text);
  end;
end;

procedure TPosPrinterWindowsTest.OpenService;
begin
  PtrCheck(Printer.Open('DeviceName'));
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
  CheckEquals(OPOS_SUCCESS, Printer.ResultCode, 'OPOS_SUCCESS');
  CheckEquals(True, Printer.DeviceEnabled, 'DeviceEnabled');
end;

procedure TPosPrinterWindowsTest.OpenClaimEnable;
begin
  OpenService;
  ClaimDevice;
  EnableDevice;
end;

procedure TPosPrinterWindowsTest.TestRecLineChars;
begin
  OpenClaimEnable;
  CheckEquals(48, Printer.RecLineChars, 'Printer.RecLineChars.0');
  Printer.RecLineChars := 42;
  CheckEquals(42, Printer.RecLineChars, 'Printer.RecLineChars.0');
end;

procedure TPosPrinterWindowsTest.TestPrintReceipt;
var
  BitmapData: string;
  BitmapData2: string;
begin
  OpenClaimEnable;

  PtrCheck(FPrinter.TransactionPrint(PTR_S_RECEIPT, PTR_TP_TRANSACTION));
  PtrCheck(FPrinter.PrintNormal(PTR_S_RECEIPT, ESC_Normal + 'Normal text' + CRLF));
  PtrCheck(FPrinter.PrintNormal(PTR_S_RECEIPT, ESC_Bold + 'Bold text' + CRLF));
  PtrCheck(FPrinter.PrintNormal(PTR_S_RECEIPT, ESC_DoubleWide + 'Double wide text' + CRLF));
  PtrCheck(FPrinter.PrintNormal(PTR_S_RECEIPT, ESC_DoubleHigh + 'Double high text' + CRLF));
  PtrCheck(FPrinter.PrintNormal(PTR_S_RECEIPT, ESC_Normal + 'Normal text 2' + CRLF));

  PtrCheck(FPrinter.PrintNormal(PTR_S_RECEIPT, 'Bitmap' + CRLF));
  PtrCheck(FPrinter.PrintBitmap(PTR_S_RECEIPT, 'Logo.bmp', PTR_BM_ASIS, PTR_BM_CENTER));

  PtrCheck(FPrinter.PrintNormal(PTR_S_RECEIPT, 'QR code barcode' + CRLF));
  PtrCheck(FPrinter.PrintBarCode(PTR_S_RECEIPT, 'Barcode', PTR_BCS_QRCODE,
    100, 100, PTR_BC_CENTER, PTR_BC_TEXT_NONE));
  PtrCheck(FPrinter.TransactionPrint(PTR_S_RECEIPT, PTR_TP_NORMAL));

  FWinPrinter.Bitmap.SaveToFile('PrintReceipt.bmp');
  BitmapData := ReadFileData(GetModulePath + 'PrintReceipt.bmp');
  BitmapData2 := ReadFileData(GetModulePath + 'PrintReceipt2.bmp');
  CheckEquals(BitmapData, BitmapData2, 'Receipt bimap differs');
  DeleteFile('PrintReceipt.bmp');
end;

procedure TPosPrinterWindowsTest.TestPageMode;
var
  PrintArea: TPageArea;
  BitmapData: string;
  BitmapData2: string;
const
  Barcode = 'http://dev.kofd.kz/consumer?i=1556041617048&f=768814097419&s=3098.00&t=20241211T151839';
begin
  OpenClaimEnable;
  PtrCheck(FPrinter.TransactionPrint(PTR_S_RECEIPT, PTR_TP_TRANSACTION));

  CheckEquals(576, FPrinter.RecLineWidth, 'RecLineWidth');
  // Start pagemode
  Printer.PageModePrint(PTR_PM_PAGE_MODE);
  // Barcode PageModeArea
  PrintArea.X := 380;
  PrintArea.Y := 0;
  PrintArea.Width := 512 - PrintArea.X;
  PrintArea.Height := 120;
  Printer.PageModePrintArea := PageAreaToStr(PrintArea);
  // Barcode
  PtrCheck(Printer.PrintBarCode(PTR_S_RECEIPT, Barcode,
    PTR_BCS_QRCODE, 0, 0, PTR_BC_CENTER, PTR_BC_TEXT_NONE));
  // Text PageModeArea
  PrintArea.X := 0;
  PrintArea.Y := 0;
  PrintArea.Width := 370;
  PrintArea.Height := 100;
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
  PtrCheck(FPrinter.TransactionPrint(PTR_S_RECEIPT, PTR_TP_NORMAL));


  FWinPrinter.Bitmap.SaveToFile('PageMode.bmp');
  BitmapData := ReadFileData(GetModulePath + 'PageMode.bmp');
  BitmapData2 := ReadFileData(GetModulePath + 'PageMode2.bmp');
  CheckEquals(BitmapData, BitmapData2, 'Receipt bimap differs');
  DeleteFile('PageMode.bmp');
end;

procedure TPosPrinterWindowsTest.TestPageMode2;
var
  PrintArea: TPageArea;
  BitmapData: string;
  BitmapData2: string;
const
  Barcode = 'http://dev.kofd.kz/consumer?i=1556041617048&f=768814097419&s=3098.00&t=20241211T151839';
begin
  OpenClaimEnable;
  CheckEquals(576, FPrinter.RecLineWidth, 'RecLineWidth');
  // Start pagemode
  Printer.PageModePrint(PTR_PM_PAGE_MODE);
  // Set PageMode area
  PrintArea.X := 0;
  PrintArea.Y := 0;
  PrintArea.Width := 576;
  PrintArea.Height := 500;
  Printer.PageModePrintArea := PageAreaToStr(PrintArea);
  // Barcode
  PtrCheck(Printer.PrintBarCode(PTR_S_RECEIPT, Barcode,
    PTR_BCS_QRCODE, 0, 0, PTR_BC_RIGHT, PTR_BC_TEXT_NONE));
  // Text
  Printer.PageModeVerticalPosition := 0;
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, '�� ��� 00106304241645' + CRLF));
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, '�� ��� 0000373856050035' + CRLF));
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, '��� 7725699008' + CRLF));
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, '�� 7380440700076549' + CRLF));
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, '�� 41110' + CRLF));
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, '�� 2026476352' + CRLF));
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, '������ 19.07.24 13:14' + CRLF));
  // Stop pagemode
  Printer.PageModePrint(PTR_PM_NORMAL);
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, ' ' + CRLF));
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, ' ' + CRLF));
  Printer.CutPaper(90);

  FWinPrinter.Bitmap.SaveToFile('PageMode_2.bmp');
  BitmapData := ReadFileData(GetModulePath + 'PageMode_2.bmp');
  BitmapData2 := ReadFileData(GetModulePath + 'PageMode_2_2.bmp');
  CheckEquals(BitmapData, BitmapData2, 'Receipt bimap differs');
  DeleteFile('PageMode_2.bmp');
end;

const
  ReceiptText: string =
    '���/���:                                  ' + CRLF +
    '��� ����� VATSeries            � VATNumber' + CRLF +
    '------------------------------------------' + CRLF +
    '               SWK00032685                ' + CRLF +
    '                ����� �149                ' + CRLF +
    '�������                                   ' + CRLF +
    '------------------------------------------' + CRLF +
    'Message 1                                 ' + CRLF +
    '���. � 5                                  ' + CRLF +
    '���������� ������ MILKA BUBBLES ��������  ' + CRLF +
    '   1.000 �� x 123.45 ���           =123.45' + CRLF +
    '   ������                           -22.35' + CRLF +
    '   �������                          +11.17' + CRLF +
    'Message 2                                 ' + CRLF +
    'Item 2                                    ' + CRLF +
    '   1.000 �� x 1.45 ���               =1.45' + CRLF +
    '   ������                            -0.45' + CRLF +
    'Message 3                                 ' + CRLF +
    '------------------------------------------' + CRLF +
    '������:                              10.00' + CRLF +
    '�������:                              5.00' + CRLF +
    '����                               =108.27' + CRLF +
    '��������:                           =63.45' + CRLF +
    '���������� �����:                   =10.00' + CRLF +
    '������:                             =20.00' + CRLF +
    '��������� ������:                   =30.00' + CRLF +
    '  �����                             =15.18' + CRLF +
    '� �.�. VAT 12%                      =12.14' + CRLF +
    '------------------------------------------' + CRLF +
    '��: 923956785162                          ' + CRLF +
    '�����: 04.08.2022 17:09:35                ' + CRLF +
    '���: �� "�����������"                     ' + CRLF +
    '��� �������� ����:                        ' + CRLF +
    'dev.kofd.kz/consumer                      ' + CRLF +
    '------------------------------------------' + CRLF +
    '              ���������� ��K              ';

procedure TPosPrinterWindowsTest.TestPageMode3;
var
  i: Integer;
  Lines: TStrings;
  BitmapData: string;
  BitmapData2: string;
  PrintArea: TPageArea;
const
  Barcode = 'http://dev.kofd.kz/consumer?i=1556041617048&f=768814097419&s=3098.00&t=20241211T151839';
begin
  OpenClaimEnable;
  CheckEquals(576, FPrinter.RecLineWidth, 'RecLineWidth');
  CheckEquals(48, FPrinter.RecLineChars, 'RecLineChars');

  // Print receipt text
  Lines := TStringList.Create;
  try
    Lines.Text := ReceiptText;
    for i := 0 to Lines.Count-1 do
    begin
      PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, Lines[i] + CRLF));
    end;
  finally
    Lines.Free;
  end;
  //PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, ReceiptText));
  // Start pagemode
  Printer.PageModePrint(PTR_PM_PAGE_MODE);
  // Set PageMode area
  PrintArea.X := 380;
  PrintArea.Y := 0;
  PrintArea.Width := FPrinter.RecLineWidth - PrintArea.X;
  PrintArea.Height := 400;
  Printer.PageModePrintArea := PageAreaToStr(PrintArea);
  // Barcode
  PtrCheck(Printer.PrintBarCode(PTR_S_RECEIPT, Barcode,
    PTR_BCS_QRCODE, 0, 0, PTR_BC_CENTER, PTR_BC_TEXT_NONE));
  // Text PageModeArea
  PrintArea.X := 0;
  PrintArea.Y := 0;
  PrintArea.Width := 370;
  PrintArea.Height := 400;
  Printer.PageModePrintArea := PageAreaToStr(PrintArea);
  // Text
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, '�� ��� 00106304241645' + CRLF));
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, '�� ��� 0000373856050035' + CRLF));
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, '��� 7725699008' + CRLF));
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, '�� 7380440700076549' + CRLF));
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, '�� 41110' + CRLF));
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, '�� 2026476352' + CRLF));
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, '������ 19.07.24 13:14' + CRLF));

  // Stop pagemode
  Printer.PageModePrint(PTR_PM_NORMAL);
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, ' ' + CRLF));
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, ' ' + CRLF));
  Printer.CutPaper(90);


  FWinPrinter.Bitmap.SaveToFile('PageMode_3.bmp');
  BitmapData := ReadFileData(GetModulePath + 'PageMode_3.bmp');
  BitmapData2 := ReadFileData(GetModulePath + 'PageMode_3_2.bmp');
  CheckEquals(BitmapData, BitmapData2, 'Receipt bimap differs');
  DeleteFile('PageMode_3.bmp');
end;

procedure TPosPrinterWindowsTest.TestUnicodeCanvas;
var
  Bitmap: TBitmap;
  BitmapData: string;
  BitmapData2: string;
  Canvas: TJvUnicodeCanvas;
begin
  Bitmap := TBitmap.Create;
  Canvas := TJvUnicodeCanvas.Create;
  try
    Bitmap.Monochrome := True;
    Bitmap.PixelFormat := pf1Bit;
    Bitmap.Width := 100;
    Bitmap.Height := 100;
    Bitmap.Canvas.Font.Size := 20;
    Bitmap.Canvas.Font.Style := [fsBold];

    Canvas.Handle := Bitmap.Canvas.Handle;
    Canvas.Font := Bitmap.Canvas.Font;
    Canvas.TextOutW(0, 0, 'Test');

    Bitmap.SaveToFile('TestUnicodeCanvas.bmp');
    BitmapData := ReadFileData(GetModulePath + 'TestUnicodeCanvas.bmp');
    BitmapData2 := ReadFileData(GetModulePath + 'TestUnicodeCanvas2.bmp');
    CheckEquals(BitmapData, BitmapData2, 'Receipt bimap differs');
    DeleteFile('TestUnicodeCanvas.bmp');
  finally
    Bitmap.Free;
    Canvas.Free;
  end;
end;

initialization
  RegisterTest('', TPosPrinterWindowsTest.Suite);

end.

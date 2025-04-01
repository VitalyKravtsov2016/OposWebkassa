unit duPrinterWindows;

interface

uses
  // VCL
  Windows, SysUtils, Classes, Forms, Printers, Graphics,
  // DUnit
  TestFramework,
  // This
  DebugUtils, StringUtils, SocketPort, LogFile, PosPrinterWindows,
  EscPrinterUtils;

type
  { TPrinterWindowsTest }

  TPrinterWindowsTest = class(TTestCase)
  private
  published
    procedure TestFont;
    procedure TestFonts;
    procedure TestEndDoc;
  end;

implementation

const
  PrinterName = 'RONGTA 80mm Series Printer';

{ TPrinterWindowsTest }

procedure TPrinterWindowsTest.TestFonts;
var
  Fonts: TStringList;
begin
  Fonts := TStringList.Create;
  try
    Printer.PrinterIndex := Printer.Printers.IndexOf(PrinterName);
    Fonts.Text := GetDeviceFonts(Printer.Handle);
    CheckEquals(2, Fonts.Count, 'GetDeviceFonts');

    Fonts.Text := GetRasterFonts(Printer.Handle);
    CheckEquals(33, Fonts.Count, 'GetRasterFonts');
    Fonts.SaveToFile('Fonts.txt');
  finally
    Fonts.Free;
  end;
end;

procedure TPrinterWindowsTest.TestFont;
var
  TextSize: TSize;
begin
  Printer.PrinterIndex := Printer.Printers.IndexOf('RONGTA 80mm Series Printer');

  Printer.Canvas.Font.Name := 'Cascadia Mono';
  Printer.Canvas.Font.Size := 8;
  TextSize := Printer.Canvas.TextExtent('A');
  CheckEquals(13, TextSize.cx, 'TextSize.cx.0');
  CheckEquals(30, TextSize.cy, 'TextSize.cy.0');

  Printer.Canvas.Font.Name := 'Lucida Console';
  Printer.Canvas.Font.Size := 16;
  TextSize := Printer.Canvas.TextExtent('A');
  CheckEquals(27, TextSize.cx, 'TextSize.cx.1');
  CheckEquals(45, TextSize.cy, 'TextSize.cy.1');

  Printer.Canvas.Font.Size := 9;
  TextSize := Printer.Canvas.TextExtent('A');
  CheckEquals(15, TextSize.cx, 'TextSize.cx.2');
  CheckEquals(25, TextSize.cy, 'TextSize.cy.2');


  Printer.Canvas.Font.Name := 'FontA11';
  Printer.Canvas.Font.Size := 8;
  TextSize := Printer.Canvas.TextExtent('A');
  CheckEquals(14, TextSize.cx, 'FontA11, TextSize.cx.3');
  CheckEquals(25, TextSize.cy, 'FontA11, TextSize.cy.3');

  Printer.Canvas.Font.Size := 30;
  TextSize := Printer.Canvas.TextExtent('A');
  CheckEquals(14, TextSize.cx, 'FontA11, TextSize.cx.4');
  CheckEquals(25, TextSize.cy, 'FontA11, TextSize.cy.4');


  Printer.Canvas.Font.Name := 'FontA12';
  Printer.Canvas.Font.Size := 8;
  TextSize := Printer.Canvas.TextExtent('A');
  CheckEquals(14, TextSize.cx, 'FontA12, TextSize.cx');
  CheckEquals(44, TextSize.cy, 'FontA12, TextSize.cy');

  Printer.Canvas.Font.Size := 30;
  TextSize := Printer.Canvas.TextExtent('A');
  CheckEquals(14, TextSize.cx, 'FontA12, TextSize.cx');
  CheckEquals(44, TextSize.cy, 'FontA12, TextSize.cy');
end;

procedure TPrinterWindowsTest.TestEndDoc;
var
  Size: TSize;
  Line: string;
  i, y: Integer;
begin
  y := 0;
  Printer.BeginDoc;
  for i := 1 to 10 do
  begin
    Line := Format('Header line %d', [i]);
    Printer.Canvas.TextOut(0, y, Line);
    Size := Printer.Canvas.TextExtent(Line);
    Inc(y, Size.cy);
  end;
  EndPage(Printer.Handle);
end;

initialization
  RegisterTest('', TPrinterWindowsTest.Suite);

end.

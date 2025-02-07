unit duEscPrinter;

interface

uses
  // VCL
  Windows, SysUtils, Classes, Graphics,
  // Tnt
  TntGraphics, TntClasses,
  // DUnit
  TestFramework,
  // 3'd
  Opos, OposPtr, OposPtrUtils,
  // This
  LogFile, PosPrinterRongta, MockPrinterPort, PrinterPort, StringUtils,
  EscPrinterRongta;

type
  { TEscPrinterRongtaTest }

  TEscPrinterRongtaTest = class(TTestCase)
  private
    FLogger: ILogFile;
    FPort: IPrinterPort;
    FPrinter: TEscPrinterRongta;
  protected
    procedure SetUp; override;
    procedure TearDown; override;

    property Printer: TEscPrinterRongta read FPrinter;
  published
    procedure EncodeUserCharacter;
  end;

implementation

{ TEscPrinterRongtaTest }

procedure TEscPrinterRongtaTest.SetUp;
begin
  FLogger := TLogFile.Create;
  FPort := TMockPrinterPort.Create('');
  FPrinter := TEscPrinterRongta.Create(FPort, FLogger);
end;

procedure TEscPrinterRongtaTest.TearDown;
begin
  FPort := nil;
  FLogger := nil;
  FPrinter.Free;
end;

///////////////////////////////////////////////////////////////////////////////
//  FONT_TYPE_A = 0; // 12x24
//  FONT_TYPE_B = 1; // 9x17

procedure TEscPrinterRongtaTest.EncodeUserCharacter;
var
  Font: TFont;
  Bitmap: TBitmap;
  Text: WideString;
  Strings: TTntStrings;
begin
  Font := TFont.Create;
  Bitmap := TBitmap.Create;
  Strings := TTntStringList.Create;
  try
    Font.Size := 16;
    Font.Name := 'Courier New';
    Strings.LoadFromFile('KazakhText.txt');
    Text := Strings.Text;

    Bitmap.Monochrome := True;
    Bitmap.PixelFormat := pf1Bit;
    Bitmap.Canvas.Font.Assign(Font);
    Bitmap.Width := 100;
    Bitmap.Height := 24;

    TntGraphics.WideCanvasTextOut(Bitmap.Canvas, 0, 0, Text);

    DeleteFile('KazakhText.bmp');
    Bitmap.SaveToFile('KazakhText.bmp');
  finally
    Font.Free;
    Bitmap.Free;
    Strings.Free;
  end;
end;



initialization
  RegisterTest('', TEscPrinterRongtaTest.Suite);

end.

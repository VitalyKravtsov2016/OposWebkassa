unit duEscPrinter;

interface

uses
  // VCL
  Windows, SysUtils, Classes, Graphics,
  // DUnit
  TestFramework,
  // 3'd
  TntClasses, Opos, OposPtr, OposPtrUtils,
  // This
  LogFile, PosEscPrinter, MockPrinterPort, PrinterPort, StringUtils, EscPrinter;

type
  { TPosEscPrinterTest }

  TPosEscPrinterTest = class(TTestCase)
  private
    FLogger: ILogFile;
    FPrinter: TEscPrinter;
    FPort: TMockPrinterPort;

    property Printer: TEscPrinter read FPrinter;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
    procedure EncodeUserCharacter;
  published
  end;

implementation

{ TPosEscPrinterTest }

procedure TPosEscPrinterTest.SetUp;
begin
  FLogger := TLogFile.Create;
  FPort := TMockPrinterPort.Create('');
  FPrinter := TEscPrinter.Create(FPort, FLogger);
end;

procedure TPosEscPrinterTest.TearDown;
begin
  FPrinter.Free;
end;

procedure TPosEscPrinterTest.EncodeUserCharacter;
var
  C: WideChar;
  Font: TFont;
begin
  Font := TFont.Create;
  try
    C := WideChar($1179);
    Font.Size := 12;
    //Font.Name :=
    Font.Style := [fsBold];
    Printer.EncodeUserCharacter(C, FONT_TYPE_A, 1, Font);
  finally
    Font.Free;
  end;
end;



initialization
  RegisterTest('', TPosEscPrinterTest.Suite);

end.

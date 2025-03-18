
unit duPrinterTest;

interface

uses
  // VCL
  Windows, SysUtils, Classes, Forms, Printers,
  // DUnit
  TestFramework,
  // JCL
  JclPrint,
  // Tnt
  TntClasses, TntSysUtils;

type
  { TWebkassaImplTest }

  TPrinterTest = class(TTestCase)
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestDocument;
    procedure TestDirectPrint;
  end;

implementation

{ TPrinterTest }


{ TPrinterTest }

procedure TPrinterTest.SetUp;
begin
  inherited;

end;

procedure TPrinterTest.TearDown;
begin
  inherited;

end;

const
  ESC_SetFontB = #$1B#$21#$01;
  ESC_Normal = #$1B#$21#$00;
  ESC_Emphasized = #$1B#$21#$08;
  ESC_DoubleHeight = #$1B#$21#$10;

  ReceiptText: string =
    ESC_Normal +
    '                                          ' + CRLF +
    '   ��������-������������ �������, �����   ' + CRLF +
    '    ����-�����������, ��. ����������, 1/10' + CRLF +
    '            ��� PetroRetail               ' + CRLF +
    '��� ����� VATSeries            � VATNumber' + CRLF +
    '------------------------------------------' + CRLF +
    ESC_DoubleHeight + '              ���������� ��K              ' + ESC_Normal + CRLF +
    ESC_SetFontB +
    '               ��� ���: 270               ' + CRLF +
    '     ��� ��� ��� (���): 211030200207      ' + CRLF +
    '             ���: SWK00032685             ' + CRLF +
    'Message 4                                 ' + CRLF +
    '           Call����� 039458039850         ' + CRLF +
    '          ������� ����� 20948802934       ' + CRLF +
    '            ������� �� �������            ' + CRLF +
    '                                          ';

procedure TPrinterTest.TestDocument;
var
  i: Integer;
  Y: Integer;
  Lines: TStrings;
begin
  Lines := TStringList.Create;
  try
    Printer.PrinterIndex := Printer.Printers.IndexOf('RONGTA 80mm Series Printer');
    Printer.BeginDoc;
    //Printer.Canvas.Font.Name := 'A11';
    Lines.Text := ReceiptText;
    Y := 0;
    for i := 0 to Lines.Count-1 do
    begin
      Printer.Canvas.TextOut(0, Y, Lines[i]);
      Inc(Y, Printer.Canvas.Font.Height);
    end;
    Printer.EndDoc;
  finally
    Lines.Free;
  end;
end;

procedure TPrinterTest.TestDirectPrint;
const
  PrinterName = 'RONGTA 80mm Series Printer';
begin
  DirectPrint(PrinterName, #$1B#$74#$06);
  DirectPrint(PrinterName, ReceiptText);
end;

initialization
  RegisterTest('', TPrinterTest.Suite);

end.

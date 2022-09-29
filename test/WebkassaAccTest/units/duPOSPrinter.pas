
unit duPOSPrinter;

interface

uses
  // VCL
  Windows, SysUtils, Classes,
  // DUnit
  TestFramework,
  // Opos
  Opos, Oposhi, OposPtr, OposPtrUtils, OposUtils, OposPOSPrinter_CCO_TLB,
  // Tnt
  TntClasses, TntSysUtils;

type
  { TPOSPrinterTest }

  TPOSPrinterTest = class(TTestCase)
  private
    FPrinter: TOPOSPOSPrinter;
    procedure ClaimDevice;
    procedure EnableDevice;
    procedure OpenService;
    procedure OpenClaimEnable;
    procedure PtrCheck(Code: Integer);

    property Printer: TOPOSPOSPrinter read FPrinter;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestCheckHealth;
    procedure TestPrintBarCode;
    procedure TestPrintBarCode2;
  end;

implementation

{ TPOSPrinterTest }

procedure TPOSPrinterTest.PtrCheck(Code: Integer);
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

procedure TPOSPrinterTest.SetUp;
begin
  inherited SetUp;
  FPrinter := TOPOSPOSPrinter.Create(nil);
end;

procedure TPOSPrinterTest.TearDown;
begin
  FPrinter.Close;
  FPrinter.Free;
  inherited TearDown;
end;

procedure TPOSPrinterTest.OpenService;
begin
  PtrCheck(Printer.Open('ThermalU'));
end;

procedure TPOSPrinterTest.ClaimDevice;
begin
  CheckEquals(False, Printer.Claimed, 'Printer.Claimed');
  PtrCheck(Printer.ClaimDevice(1000));
  CheckEquals(True, Printer.Claimed, 'Printer.Claimed');
end;

procedure TPOSPrinterTest.EnableDevice;
begin
  Printer.DeviceEnabled := True;
  CheckEquals(OPOS_SUCCESS, Printer.ResultCode, 'OPOS_SUCCESS');
  CheckEquals(True, Printer.DeviceEnabled, 'DeviceEnabled <> True');
end;

procedure TPOSPrinterTest.OpenClaimEnable;
begin
  OpenService;
  ClaimDevice;
  EnableDevice;
end;

procedure TPOSPrinterTest.TestCheckHealth;
begin
  OpenClaimEnable;
  PtrCheck(Printer.CheckHealth(OPOS_CH_INTERACTIVE));
end;


procedure TPOSPrinterTest.TestPrintBarCode;
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
  PtrCheck(Printer.PrintBarCode(PTR_S_RECEIPT, Barcode, PTR_BCS_DATAMATRIX, 200, 200,
    PTR_BC_CENTER, PTR_BC_TEXT_NONE));

  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, CRLF));
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, CRLF));
  PtrCheck(Printer.PrintNormal(PTR_S_RECEIPT, CRLF));

  PtrCheck(Printer.CutPaper(90));
  if Printer.CapTransaction then
  begin
    Printer.TransactionPrint(PTR_S_RECEIPT, PTR_TP_NORMAL);
  end;
end;

procedure TPOSPrinterTest.TestPrintBarCode2;
const
  Barcode = 'http://dev.kofd.kz/consumer?i=925871425876&f=211030200207&s=15443.72&t=20220826T210014';
  CRLF = #13#10;
begin
  OpenClaimEnable;
  PtrCheck(Printer.PrintBarCode(PTR_S_RECEIPT, Barcode + CRLF, PTR_BCS_DATAMATRIX, 200, 200,
    PTR_BC_CENTER, PTR_BC_TEXT_NONE));
end;

initialization
  RegisterTest('', TPOSPrinterTest.Suite);

end.

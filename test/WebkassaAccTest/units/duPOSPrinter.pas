
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

initialization
  RegisterTest('', TPOSPrinterTest.Suite);

end.

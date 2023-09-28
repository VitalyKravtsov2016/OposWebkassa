
unit duWebkassaImpl;

interface

uses
  // VCL
  Windows, SysUtils, Classes, Forms,
  // DUnit
  TestFramework,
  // Opos
  Opos, OposFptr, Oposhi, OposFptrhi, OposFptrUtils, OposUtils,
  // Tnt
  TntClasses, TntSysUtils,
  // This
  LogFile, WebkassaImpl, WebkassaClient, MockPosPrinter, PrinterParameters,
  SerialPort, DirectIOAPI, FileUtils, oleFiscalPrinter;

const
  CRLF = #13#10;

type
  { TWebkassaImplTest }

  TWebkassaImplTest = class(TTestCase)
  private
    function GetParams: TPrinterParameters;
  private
    FDriver: ToleFiscalPrinter;
    FPrinter: TMockPOSPrinter;
    FPrintHeader: Boolean;
    procedure ClaimDevice;
    procedure EnableDevice;
    procedure OpenService;
    procedure FptrCheck(Code: Integer); overload;
    procedure FptrCheck(Code: Integer; const AText: WideString); overload;
    procedure CheckTotal(Amount: Currency);
    function DirectIO2(Command: Integer; const pData: Integer;
      const pString: WideString): Integer;

    property Driver: ToleFiscalPrinter read FDriver;
    property Params: TPrinterParameters read GetParams;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure OpenClaimEnable;
    procedure TestCashIn;
    procedure TestCashIn2;
    procedure TestCashOut;
    procedure TestZReport;
    procedure TestXReport;
    procedure TestNonFiscal;
    procedure TestFiscalReceipt;
    procedure TestPrintReceiptDuplicate;
    procedure TestFiscalReceipt2;
    procedure TestFiscalReceipt3;
    procedure TestFiscalReceipt4;
    procedure TestFiscalReceipt5;
    procedure TestFiscalReceipt6;
    procedure TestFiscalReceiptWithVAT;
    procedure TestFiscalReceiptWithAdjustments;
    procedure TestFiscalReceiptWithAdjustments2;
    procedure TestFiscalReceiptWithAdjustments3;
    procedure TestPrintBarcode;
    procedure TestGetData;
    procedure TestEvents;
    procedure TestFontB;
  end;

implementation

{ TWebkassaImplTest }

function TWebkassaImplTest.GetParams: TPrinterParameters;
begin
  Result := FDriver.Driver.Params;
end;

procedure TWebkassaImplTest.FptrCheck(Code: Integer);
begin
  FptrCheck(Code, '');
end;

procedure TWebkassaImplTest.FptrCheck(Code: Integer; const AText: WideString);
var
  Text: WideString;
  ResultCode: Integer;
  ErrorString: WideString;
  ResultCodeExtended: Integer;
begin
  if Code <> OPOS_SUCCESS then
  begin
    ResultCode := Driver.GetPropertyNumber(PIDX_ResultCode);
    ResultCodeExtended := Driver.GetPropertyNumber(PIDX_ResultCodeExtended);
    ErrorString := Driver.GetPropertyString(PIDXFptr_ErrorString);

    if ResultCode = OPOS_E_EXTENDED then
      Text := Tnt_WideFormat('%s: %d, %d, %s [%s]', [AText, ResultCode,
        ResultCodeExtended, GetResultCodeExtendedText(ResultCodeExtended),
        ErrorString])
    else
      Text := Tnt_WideFormat('%s: %d, %s [%s]', [AText, ResultCode,
        GetResultCodeText(ResultCode), ErrorString]);

    raise Exception.Create(Text);
  end;
end;


procedure TWebkassaImplTest.SetUp;
begin
  inherited SetUp;
  FPrinter := TMockPOSPrinter.Create(nil);
  FDriver := ToleFiscalPrinter.Create;
  FDriver.Driver.Printer := FPrinter;
  FDriver.Driver.LoadParamsEnabled := False;

  Params.LogFileEnabled := True;
  Params.LogMaxCount := 10;
  Params.LogFilePath := GetModulePath + 'Logs';
  Params.Login := 'webkassa4@softit.kz';
  Params.Password := 'Kassa123';
  Params.ConnectTimeout := 10;
  Params.WebkassaAddress := 'https://devkkm.webkassa.kz';
  //Params.WebkassaAddress := 'http://localhost:1332';

  Params.CashboxNumber := 'SWK00033059';
  Params.NumHeaderLines := 6;
  Params.NumTrailerLines := 3;
  Params.RoundType := RoundTypeNone;

  Params.HeaderText :=
    ' ' + CRLF +
    '                  ��� PetroRetail                 230498234              029384     203948' + CRLF +
    '                 ��� 181040037076                 ' + CRLF +
    '             ��� ����� 60001 � 1204525            ' + CRLF +
    '               ��� �Z-5555 (����� 1)              ' + CRLF +
    '                       �����                      ';

(*
  Params.HeaderText :=
    ' ' + CRLF +
    '  ��������-������������ �������, �����' + CRLF +
    '    ����-�����������, ��. ����������, 1/10' + CRLF +
    '            ��� PetroRetail';
*)

  Params.TrailerText :=
    '           Call����� 039458039850 ' + CRLF +
    '          ������� ����� 20948802934' + CRLF +
    '            ������� �� �������';

  Params.PaymentType2 := 1;
  Params.PaymentType3 := 4;
  Params.PaymentType4 := 4;
  Params.VatRateEnabled := True;
  Params.RoundType := RoundTypeItems;
  Params.VATSeries := '12347';
  Params.VATNumber := '7654321';
  Params.AmountDecimalPlaces := 2;
  Params.VatRates.Clear;
  Params.VatRates.Add(1, 12, '��� 12%');

(*
  // Network
  Params.PrinterType := PrinterTypeEscPrinterNetwork;
  Params.RemoteHost := '10.11.7.176';
  Params.RemotePort := 9100;
  Params.ByteTimeout := 1000;
  Params.FontName := 'FontA11';

  // Serial
  Params.PrinterType := PrinterTypeEscPrinterSerial;
  Params.ByteTimeout := 500;
  Params.FontName := 'FontA11';
  Params.PortName := 'COM6';
  Params.BaudRate := 19200;
  Params.DataBits := DATABITS_8;
  Params.StopBits := ONESTOPBIT;
  Params.Parity := NOPARITY;
  Params.FlowControl := FLOW_CONTROL_NONE;
  Params.ReconnectPort := False;
*)
  Params.PrinterType := PrinterTypeEscPrinterWindows;
  Params.PrinterName := 'RONGTA 80mm Series Printer';
  Params.FontName := 'FontA11';
end;

procedure TWebkassaImplTest.TearDown;
begin
  FDriver.Free;
  FPrinter.Free;
  inherited TearDown;
end;

procedure TWebkassaImplTest.OpenService;
begin
  FptrCheck(Driver.OpenService(OPOS_CLASSKEY_FPTR, 'DeviceName', nil));
  Driver.SetPropertyNumber(PIDX_PowerNotify, OPOS_PN_ENABLED);
end;

procedure TWebkassaImplTest.ClaimDevice;
begin
  CheckEquals(0, Driver.GetPropertyNumber(PIDX_Claimed),
    'GetPropertyNumber(PIDX_Claimed)');
  FptrCheck(Driver.ClaimDevice(1000));
  CheckEquals(1, Driver.GetPropertyNumber(PIDX_Claimed),
    'GetPropertyNumber(PIDX_Claimed)');
end;

procedure TWebkassaImplTest.EnableDevice;
var
  ResultCode: Integer;
begin
  Driver.SetPropertyNumber(PIDX_DeviceEnabled, 1);
  ResultCode := Driver.GetPropertyNumber(PIDX_ResultCode);
  FptrCheck(ResultCode);

  CheckEquals(OPOS_SUCCESS, ResultCode, 'OPOS_SUCCESS');
  CheckEquals(1, Driver.GetPropertyNumber(PIDX_DeviceEnabled), 'DeviceEnabled');
end;

procedure TWebkassaImplTest.OpenClaimEnable;
begin
  OpenService;
  ClaimDevice;
  EnableDevice;
end;

procedure TWebkassaImplTest.TestCashIn;
begin
  OpenClaimEnable;
  FptrCheck(Driver.ResetPrinter, 'ResetPrinter');
  Driver.SetHeaderLine(1, ' ', False);
  Driver.SetHeaderLine(2, '  ��������-������������ �������, �����', False);
  Driver.SetHeaderLine(3, '    ����-�����������, ��. ����������, 1/10', False);
  Driver.SetHeaderLine(4, '    ��� PetroRetail', True);

  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_CASH_IN);
  CheckEquals(FPTR_RT_CASH_IN, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));
  FptrCheck(Driver.BeginFiscalReceipt(FPrintHeader));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  FptrCheck(Driver.PrintRecCash(10));
  FptrCheck(Driver.PrintRecCash(20));
  FptrCheck(Driver.PrintRecCash(30));
  FptrCheck(Driver.PrintRecTotal(0, 10, ''));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT_TOTAL, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  FptrCheck(Driver.PrintRecTotal(0, 20, ''));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT_TOTAL, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  FptrCheck(Driver.PrintRecTotal(0, 30, ''));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT_ENDING, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  FptrCheck(Driver.EndFiscalReceipt(not FPrintHeader));
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
end;

procedure TWebkassaImplTest.TestCashIn2;
begin
  FPrintHeader := True;
  //FPrintHeader := False;
  TestCashIn;
end;

procedure TWebkassaImplTest.TestCashOut;
begin
  OpenClaimEnable;
  CheckEquals(0, Driver.ResetPrinter, 'ResetPrinter');
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_CASH_OUT);
  CheckEquals(FPTR_RT_CASH_OUT, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));
  FptrCheck(Driver.BeginFiscalReceipt(False));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  FptrCheck(Driver.PrintRecCash(10));
  FptrCheck(Driver.PrintRecCash(20));
  FptrCheck(Driver.PrintRecCash(30));
  FptrCheck(Driver.PrintRecTotal(0, 10, ''));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT_TOTAL, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  FptrCheck(Driver.PrintRecTotal(0, 20, ''));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT_TOTAL, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  FptrCheck(Driver.PrintRecTotal(0, 30, ''));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT_ENDING, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  FptrCheck(Driver.EndFiscalReceipt(True));
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
end;

procedure TWebkassaImplTest.TestZReport;
begin
  OpenClaimEnable;
  FptrCheck(Driver.PrintZReport, 'PrintZReport');
end;

procedure TWebkassaImplTest.TestXReport;
begin
  OpenClaimEnable;
  CheckEquals(0, Driver.PrintXReport, 'PrintXReport');
end;

procedure TWebkassaImplTest.TestNonFiscal;
begin
  OpenClaimEnable;
  CheckEquals(0, Driver.ResetPrinter, 'ResetPrinter');
  CheckEquals(0, Driver.BeginNonFiscal, 'BeginNonFiscal');
  CheckEquals(0, Driver.PrintNormal(FPTR_S_RECEIPT, '������ ��� ������ 1'));
  CheckEquals(0, Driver.PrintNormal(FPTR_S_RECEIPT, '������ ��� ������ 2'));
  CheckEquals(0, Driver.PrintNormal(FPTR_S_RECEIPT, '������ ��� ������ 3'));
  CheckEquals(0, Driver.EndNonFiscal, 'EndNonFiscal');
  Application.MessageBox('Restart printer', 'Attention');

  CheckEquals(0, Driver.ResetPrinter, 'ResetPrinter');
  CheckEquals(0, Driver.BeginNonFiscal, 'BeginNonFiscal');
  CheckEquals(0, Driver.PrintNormal(FPTR_S_RECEIPT, '������ ��� ������ 1'));
  CheckEquals(0, Driver.PrintNormal(FPTR_S_RECEIPT, '������ ��� ������ 2'));
  CheckEquals(0, Driver.PrintNormal(FPTR_S_RECEIPT, '������ ��� ������ 3'));
  CheckEquals(0, Driver.EndNonFiscal, 'EndNonFiscal');
end;

procedure TWebkassaImplTest.TestFiscalReceipt;
begin
  OpenClaimEnable;
  CheckEquals(0, Driver.ResetPrinter, 'ResetPrinter');
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  CheckEquals(FPTR_RT_SALES, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));

  FptrCheck(Driver.BeginFiscalReceipt(True));
  CheckEquals(FPTR_PS_FISCAL_RECEIPT, Driver.GetPropertyNumber(PIDXFptr_PrinterState));

  //FptrCheck(Driver.PrintRecItem('Item 1', 123.45, 1000, 0, 123.45, '��'));
  FptrCheck(Driver.PrintRecItem('���. � 5                                  ���������� ������ MILKA BUBBLES ��������', 590, 1000, 4, 590, '��'));
  FptrCheck(Driver.PrintRecTotal(12345, 12345, '0'));

  CheckEquals(FPTR_PS_FISCAL_RECEIPT_ENDING, Driver.GetPropertyNumber(PIDXFptr_PrinterState));

  FptrCheck(Driver.EndFiscalReceipt(False));
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
end;


procedure TWebkassaImplTest.TestPrintReceiptDuplicate;
const
  ReceiptLines: array [0..39] of string = (
    '|bC              ��������',
    '       ��� SOFT IT KAZAKHSTAN',
    '          ��� 131240010479',
    '��� ����� 00000            � 0000000',
    '------------------------------------',
    '             ����� 2.0.2',
    '              ����� 213',
    '      ���������� ����� ���� �13',
    '��� �1176446355471',
    '������ webkassa4@softit.kz',
    '�������',
    '------------------------------------',
    '  1. ���. � 5',
    '           ���������� ������ MILKA',
    'BUBBLES ��������',
    '   1 �� x 590,00',
    '   ���������                  590,00',
    '------------------------------------',
    '��������:                  12�345,00',
    '�����:                     11�755,00',
    '|bC�����:                        590,00',
    '------------------------------------',
    '���������� �������: 1176446355471',
    '�����: 25.09.2023 17:20:28',
    '������',
    '�������� ���������� ������: ��',
    '"�����������"',
    '��� �������� ���� ������� �� ����:',
    'dev.kofd.kz/consumer',
    '------------------------------------',
    '|bC           ���������� ���',
    'http://dev.kofd.kz/consumer?i=117644635547',
    '1&f=427490326691&s=590.00&t=20230925T17202',
    '8            ��� ���: 657',
    '   ��� ��� ��� (���): 427490326691',
    '          ���: SWK00033059',
    '             WEBKASSA.KZ',
    '           Call����� 039458039850',
    '          ������� ����� 20948802934',
    '            ������� �� �������');

var
  i: Integer;
  pData: Integer;
  pString: WideString;
  ExternalCheckNumber: WideString;
begin
  TestFiscalReceipt;

  FPrinter.Clear;
  CheckEquals(0, FPrinter.Lines.Count, 'FPrinter.Lines.Count');
  CheckEquals('', FPrinter.Lines.Text, 'FPrinter.Lines.Text');

  pString := '';
  pData := DriverParameterExternalCheckNumber;
  FptrCheck(Driver.DirectIO(DIO_GET_DRIVER_PARAMETER, pData, pString),
    'Driver.DirectIO(DIO_GET_DRIVER_PARAMETER, pData, pString)');

  pData := 0;
  ExternalCheckNumber := pString;
  FptrCheck(Driver.DirectIO(DIO_PRINT_RECEIPT_DUPLICATE, pData, ExternalCheckNumber),
    'DirectIO(DIO_PRINT_RECEIPT_DUPLICATE, 0, ExternalCheckNumber)');

  CheckEquals(48, FPrinter.Lines.Count, 'FPrinter.Lines.Count');
  for i := 0 to 5 do
  begin
    CheckEquals(TrimRight(ReceiptLines[i]), TrimRight(FPrinter.Lines[i]), 'Line ' + IntToStr(i));
  end;
  for i := 9 to 21 do
  begin
    CheckEquals(TrimRight(ReceiptLines[i]), TrimRight(FPrinter.Lines[i]), 'Line ' + IntToStr(i));
  end;
  for i := 24 to 30 do
  begin
    CheckEquals(TrimRight(ReceiptLines[i]), TrimRight(FPrinter.Lines[i]), 'Line ' + IntToStr(i));
  end;
  for i := 34 to 39 do
  begin
    CheckEquals(TrimRight(ReceiptLines[i]), TrimRight(FPrinter.Lines[i]), 'Line ' + IntToStr(i));
  end;
end;


procedure TWebkassaImplTest.TestFiscalReceipt2;
begin
  Params.RoundType := RoundTypeItems;

  OpenClaimEnable;
  CheckEquals(0, Driver.ResetPrinter, 'ResetPrinter');
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  CheckEquals(FPTR_RT_SALES, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));

  FptrCheck(Driver.BeginFiscalReceipt(True));
  FptrCheck(Driver.PrintRecItem('��� 1:��-98', 578, 3302, 4, 175, ''));
  FptrCheck(Driver.PrintRecItem('���� � �������� ������', 620, 1000, 4, 620, '��'));
  FptrCheck(Driver.PrintRecItem('������ ������ ������', 1250, 1000, 4, 1250, '��'));
  FptrCheck(Driver.PrintRecItem('����� ������ ������', 650, 1000, 4, 650, '��'));
  FptrCheck(Driver.PrintRecTotal(3098, 2521, '1'));
  FptrCheck(Driver.PrintRecTotal(3098, 577, '0'));
  FptrCheck(Driver.EndFiscalReceipt(False));
end;

procedure TWebkassaImplTest.TestFiscalReceipt3;
begin
  Params.RoundType := RoundTypeItems;

  OpenClaimEnable;
  CheckEquals(0, Driver.ResetPrinter, 'ResetPrinter');
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  CheckEquals(FPTR_RT_SALES, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));

  FptrCheck(Driver.BeginFiscalReceipt(True));
  FptrCheck(Driver.PrintRecItem('���� � �������� ������', 620, 1000, 4, 620, '��'));
  FptrCheck(Driver.PrintRecItem('Americano 180��', 400, 1000, 4, 400, '��'));
  FptrCheck(Driver.PrintRecItemAdjustment(1, '98', 40, 4));
  FptrCheck(Driver.PrintRecTotal(980, 980, '0'));
  FptrCheck(Driver.EndFiscalReceipt(False));
end;

procedure TWebkassaImplTest.TestFiscalReceipt4;
begin
  OpenClaimEnable;
  CheckEquals(0, Driver.ResetPrinter, 'ResetPrinter');
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  CheckEquals(FPTR_RT_SALES, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));

  FptrCheck(Driver.BeginFiscalReceipt(True));
  FptrCheck(Driver.PrintRecItem('���������� �������� TWIX 55 ��.', 236, 1000, 4, 236, '��'));
  FptrCheck(Driver.PrintRecTotal(236, 236, '2'));
  FptrCheck(Driver.EndFiscalReceipt(False));
end;

procedure TWebkassaImplTest.TestFiscalReceipt5;
begin
  Params.RoundType := RoundTypeTotal;
  OpenClaimEnable;
  CheckEquals(0, Driver.ResetPrinter, 'ResetPrinter');
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  FptrCheck(Driver.BeginFiscalReceipt(True));
  FptrCheck(Driver.PrintRecItem('������', 333, 1000, 4, 333, '��'));
  FptrCheck(Driver.PrintRecTotal(333, 333, '0'));
  FptrCheck(Driver.PrintRecMessage('�������� ts1'));
  FptrCheck(Driver.PrintRecMessage('ID:      29211 '));
  FptrCheck(Driver.EndFiscalReceipt(False));
end;

function TWebkassaImplTest.DirectIO2(Command: Integer;
  const pData: Integer; const pString: WideString): Integer;
var
  pData2: Integer;
  pString2: WideString;
begin
  pData2 := pData;
  pString2 := pString;
  Result := FDriver.DirectIO(Command, pData2, pString2);
end;

procedure TWebkassaImplTest.TestFiscalReceipt6;
begin
  Params.RoundType := RoundTypeTotal;

  OpenClaimEnable;
  CheckEquals(0, Driver.ResetPrinter, 'ResetPrinter');
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  FptrCheck(Driver.BeginFiscalReceipt(True));

  FptrCheck(DirectIO2(30, 72, '4'));
  FptrCheck(DirectIO2(30, 73, '1'));
  FptrCheck(Driver.PrintRecItem('��� 1:��-92-�4/�5', 139, 870, 4, 160, '�'));
  FptrCheck(Driver.PrintRecTotal(139, 139, '1'));
  FptrCheck(Driver.PrintRecMessage('Kaspi ���������   �2832880234      '));
  FptrCheck(Driver.PrintRecMessage('��������: ������1'));
  FptrCheck(Driver.PrintRecMessage('�����.:      11822 '));
  FptrCheck(Driver.PrintRecMessage('�����. �������: 11820 (200,00 ��)'));
  FptrCheck(Driver.EndFiscalReceipt(False));
end;

procedure TWebkassaImplTest.TestFiscalReceiptWithVAT;
begin
  Params.VatRates.Clear;
  Params.VatRates.Add(4, 12, 'Tax1');
  Params.VatRateEnabled := True;
  Params.RoundType := RoundTypeItems;

  OpenClaimEnable;
  CheckEquals(0, Driver.ResetPrinter, 'ResetPrinter');
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  CheckEquals(FPTR_RT_SALES, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));

  FptrCheck(Driver.BeginFiscalReceipt(True));
  FptrCheck(Driver.PrintRecItem('���� � �������� ������', 620, 1000, 4, 620, '��'));
  FptrCheck(Driver.PrintRecItem('Americano 180��', 400, 1000, 4, 400, '��'));
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_AMOUNT_DISCOUNT, '98', 40, 4));
  FptrCheck(Driver.PrintRecTotal(980, 980, '0'));
  FptrCheck(Driver.EndFiscalReceipt(False));
end;

procedure TWebkassaImplTest.CheckTotal(Amount: Currency);
var
  IData: Integer;
  Data: WideString;
  Total: Currency;
begin
  CheckEquals(0, Driver.GetData(FPTR_GD_CURRENT_TOTAL, IData, Data));
  Total := StrToCurr(Data)/100;
  CheckEquals(Amount, Total, 'Total');
end;

procedure TWebkassaImplTest.TestFiscalReceiptWithAdjustments;
begin
  Params.VatRates.Clear;
  Params.VatRates.Add(4, 12, 'Tax1');
  Params.VatRateEnabled := True;
  Params.RoundType := RoundTypeNone;

  OpenClaimEnable;
  Driver.SetPropertyNumber(PIDXFptr_CheckTotal, 1);
  CheckEquals(0, Driver.ResetPrinter, 'ResetPrinter');
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  CheckEquals(FPTR_RT_SALES, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));

  FptrCheck(Driver.BeginFiscalReceipt(True));
  CheckTotal(0);
  FptrCheck(Driver.PrintRecItem('���� � �������� ������', 620, 1000, 4, 620, '��'));
  CheckTotal(620);
  FptrCheck(Driver.PrintRecItem('Americano 180��', 400, 1000, 4, 400, '��'));
  CheckTotal(1020);
  // Item adjustments
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_AMOUNT_DISCOUNT, '������ 40', 40, 4));
  CheckTotal(980);
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_AMOUNT_SURCHARGE, '�������� 12', 12, 4));
  CheckTotal(992);
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_PERCENTAGE_DISCOUNT, '������ 10%', 10, 4));
  CheckTotal(952);
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_PERCENTAGE_SURCHARGE, '�������� 5%', 5, 4));
  CheckTotal(972);
  // Total adjustments
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_AMOUNT_DISCOUNT, '������ 10', 10));
  CheckTotal(962);
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_AMOUNT_SURCHARGE, '�������� 5', 5));
  CheckTotal(967);
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_PERCENTAGE_DISCOUNT, '������ 10%', 10));
  CheckTotal(870.3);
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_PERCENTAGE_SURCHARGE, '�������� 5%', 5));
  CheckTotal(913.82);

  FptrCheck(Driver.PrintRecTotal(913.82, 914, '0'));
  FptrCheck(Driver.EndFiscalReceipt(False));
end;

procedure TWebkassaImplTest.TestFiscalReceiptWithAdjustments2;
begin
  Params.VatRates.Clear;
  Params.VatRates.Add(4, 12, 'Tax1');
  Params.VatRateEnabled := True;
  Params.RoundType := RoundTypeTotal;

  OpenClaimEnable;
  Driver.SetPropertyNumber(PIDXFptr_CheckTotal, 1);
  CheckEquals(0, Driver.ResetPrinter, 'ResetPrinter');
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  CheckEquals(FPTR_RT_SALES, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));

  FptrCheck(Driver.BeginFiscalReceipt(True));
  CheckTotal(0);
  FptrCheck(Driver.PrintRecItem('���� � �������� ������', 620, 1000, 4, 620, '��'));
  CheckTotal(620);
  FptrCheck(Driver.PrintRecItem('Americano 180��', 400, 1000, 4, 400, '��'));
  CheckTotal(1020);
  // Item adjustments
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_AMOUNT_DISCOUNT, '������ 40', 40, 4));
  CheckTotal(980);
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_AMOUNT_SURCHARGE, '�������� 12', 12, 4));
  CheckTotal(992);
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_PERCENTAGE_DISCOUNT, '������ 10%', 10, 4));
  CheckTotal(952);
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_PERCENTAGE_SURCHARGE, '�������� 5%', 5, 4));
  CheckTotal(972);
  // Total adjustments
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_AMOUNT_DISCOUNT, '������ 10', 10));
  CheckTotal(962);
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_AMOUNT_SURCHARGE, '�������� 5', 5));
  CheckTotal(967);
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_PERCENTAGE_DISCOUNT, '������ 10%', 10));
  CheckTotal(871);
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_PERCENTAGE_SURCHARGE, '�������� 5%', 5));
  CheckTotal(914);

  FptrCheck(Driver.PrintRecTotal(914, 1000, '0'));
  FptrCheck(Driver.EndFiscalReceipt(False));
end;

procedure TWebkassaImplTest.TestFiscalReceiptWithAdjustments3;
begin
  Params.VatRates.Clear;
  Params.VatRates.Add(4, 12, 'Tax1');
  Params.VatRateEnabled := True;
  Params.RoundType := RoundTypeItems;

  OpenClaimEnable;
  Driver.SetPropertyNumber(PIDXFptr_CheckTotal, 1);
  CheckEquals(0, Driver.ResetPrinter, 'ResetPrinter');
  CheckEquals(FPTR_PS_MONITOR, Driver.GetPropertyNumber(PIDXFptr_PrinterState));
  Driver.SetPropertyNumber(PIDXFptr_FiscalReceiptType, FPTR_RT_SALES);
  CheckEquals(FPTR_RT_SALES, Driver.GetPropertyNumber(PIDXFptr_FiscalReceiptType));

  FptrCheck(Driver.BeginFiscalReceipt(True));
  CheckTotal(0);
  FptrCheck(Driver.PrintRecItem('���� � �������� ������', 555.52, 896, 4, 620, '��'));
  CheckTotal(556);
  FptrCheck(Driver.PrintRecItem('Americano 180��', 400, 1000, 4, 400, '��'));
  CheckTotal(956);
  // Item adjustments
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_AMOUNT_DISCOUNT, '������ 40', 40, 4));
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_AMOUNT_SURCHARGE, '�������� 12', 12, 4));
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_PERCENTAGE_DISCOUNT, '������ 10%', 10, 4));
  FptrCheck(Driver.PrintRecItemAdjustment(FPTR_AT_PERCENTAGE_SURCHARGE, '�������� 5%', 5, 4));
  // Total adjustments
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_AMOUNT_DISCOUNT, '������ 10', 10));
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_AMOUNT_SURCHARGE, '�������� 5', 5));
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_PERCENTAGE_DISCOUNT, '������ 10%', 10));
  FptrCheck(Driver.PrintRecSubtotalAdjustment(FPTR_AT_PERCENTAGE_SURCHARGE, '�������� 5%', 5));
  CheckTotal(854);
  FptrCheck(Driver.PrintRecTotal(854, 1000, '0'));
  FptrCheck(Driver.EndFiscalReceipt(False));
end;

(*
TestFiscalReceiptWithAdjustments: Exception
at  $0054BA8D
114, 309, 309 [������� 'Americano 180��': ����� ��������� �������.
(�������: 42,86, ���������: 37,71); ����� ���� (914,00) �� ���������
� ������ �������� (1�000,00) � ������ (86,18)]
*)

///////////////////////////////////////////////////////////////////////////////
//
// ��������� ��� ��������
// ��������� ��� �������� �� ��������
// ��������� ������� getData
//
///////////////////////////////////////////////////////////////////////////////


procedure TWebkassaImplTest.TestPrintBarcode;
const
  Barcode = 'http://dev.kofd.kz/consumer?i=925871425876&f=211030200207&s=15443.72&t=20220826T210014';
begin
  OpenClaimEnable;
  Driver.Driver.PrintQRCodeAsGraphics(Barcode);
end;

procedure TWebkassaImplTest.TestGetData;
var
  OptArgs: Integer;
  Data: WideString;
  DataExpected: WideString;
begin
  OpenClaimEnable;
  OptArgs := 0;
  Data := '';
  FptrCheck(Driver.GetData(FPTR_GD_GRAND_TOTAL, OptArgs, Data));
  DataExpected := Driver.Driver.ReadCashboxStatus.Field['Data'].Field[
    'CurrentState'].Field['XReport'].Field['SumInCashbox'].Value;
  CheckEquals(DataExpected, Data, 'FPTR_GD_GRAND_TOTAL');
  FptrCheck(Driver.GetData(FPTR_GD_DAILY_TOTAL, OptArgs, Data));
end;


procedure TWebkassaImplTest.TestEvents;
begin
  OpenClaimEnable;
  Application.MessageBox('Change printer state', 'Attention');
end;

procedure TWebkassaImplTest.TestFontB;
begin
  OpenClaimEnable;
end;

initialization
  RegisterTest('', TWebkassaImplTest.Suite);

end.

unit duWebkassaImpl3;

interface

uses
  // VCL
  Windows, SysUtils, Classes, SyncObjs, Graphics,
  // DUnit
  TestFramework,
  // Mock
  PascalMock,
  // Opos
  Opos, OposFptr, Oposhi, OposFptrhi, OposFptrUtils, OposUtils,
  OposEvents, OposPtr, RCSEvents, OposEsc, OPOSException,
  // Tnt
  TntClasses, TntSysUtils,
  // This
  LogFile, WebkassaImpl, WebkassaClient, MockPosPrinter2, FileUtils,
  CustomReceipt, uLkJSON, ReceiptTemplate, SalesReceipt, DirectIOAPI,
  DebugUtils, StringUtils, OposServiceDevice19, PosPrinterRongta, PrinterPort,
  MockPrinterPort, PrinterTypes, PrinterParameters;

type
  { TWebkassaImplTest3 }

  TWebkassaImplTest3 = class(TTestCase)
  private
    FLogger: ILogFile;
    FDriver: TWebkassaImpl;
    FPrinter: TMockPOSPrinter2;
  protected
    property Driver: TWebkassaImpl read FDriver;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestPrintBarcodeAsGraphics;
    procedure TestPrintBarcodeFailed;
    procedure TestPrintBarcodeAsBarcode;
    procedure TestPrintBarcodeAsBarcode2;
  end;

implementation

{ TWebkassaImplTest3 }

procedure TWebkassaImplTest3.SetUp;
begin
  inherited SetUp;

  FLogger := TLogFile.Create;
  FPrinter := TMockPOSPrinter2.Create;
  FDriver := TWebkassaImpl.Create;

  FDriver.TestMode := True;
  FDriver.LoadParamsEnabled := False;
  FDriver.Client.TestMode := True;
  FDriver.Printer := FPrinter;
  FDriver.Params.FontName := 'Font A (12x24)';
  FDriver.Params.RecLineChars := 42;
  FDriver.Params.RecLineHeight := 24;
  FDriver.Params.LineSpacing := 0;
  FDriver.Params.LogFileEnabled := True;
  FDriver.Params.LogMaxCount := 10;
  FDriver.Params.LogFilePath := 'Logs';
  FDriver.Params.Login := 'webkassa4@softit.kz';
  FDriver.Params.Password := 'Kassa123';
  FDriver.Params.ConnectTimeout := 10;
  FDriver.Params.WebkassaAddress := 'https://devkkm.webkassa.kz/';
  FDriver.Params.CashboxNumber := 'SWK00032685';
  FDriver.Params.PrinterName := 'ThermalU';
  FDriver.Params.NumHeaderLines := 4;
  FDriver.Params.NumTrailerLines := 3;
  FDriver.Params.RoundType := RoundTypeNone;

  FDriver.Params.HeaderText :=
    '                                          ' + CRLF +
    '   ��������-������������ �������, �����   ' + CRLF +
    '  ����-�����������, ��. ����������, 1/10  ' + CRLF +
    '            ��� PetroRetail               ';
  FDriver.Params.TrailerText :=
    '           Call����� 039458039850         ' + CRLF +
    '          ������� ����� 20948802934       ' + CRLF +
    '            ������� �� �������            ';

  FDriver.Logger.CloseFile;
  DeleteFile(FDriver.Logger.FileName);
end;

procedure TWebkassaImplTest3.TearDown;
begin
  FDriver.Free;
  FPrinter.Free;
  inherited TearDown;
end;

procedure TWebkassaImplTest3.TestPrintBarcodeFailed;
var
  Barcode: TBarcodeRec;
begin
  FPrinter.Expects('Get_CapRecBarCode').Returns(False);
  FPrinter.Expects('Get_CapRecBitmap').Returns(False);

  Barcode.Data := '3850504580002030';
  Barcode.Text := 'DATAMATRIX';
  Barcode.Height := 100;
  Barcode.ModuleWidth := 4;
  Barcode.BarcodeType := DIO_BARCODE_DATAMATRIX;
  Barcode.Alignment := BARCODE_ALIGNMENT_CENTER;
  try
    FDriver.PrintBarcode2(Barcode);
    Fail('No exception');
  except
    on E: EOPOSException do
    begin
      CheckEquals(OPOS_E_ILLEGAL, E.ResultCode, 'E.ResultCode <> OPOS_E_ILLEGAL');
      CheckEquals('Bitmaps are not supported', E.Message, 'E.Message');
    end;
  end;
  FPrinter.Verify('TestPrintBarcodeFailed');
end;

procedure TWebkassaImplTest3.TestPrintBarcodeAsBarcode;
var
  Barcode: TBarcodeRec;
begin
  Barcode.Data := '3850504580002030';
  Barcode.Text := 'DATAMATRIX';
  Barcode.Height := 100;
  Barcode.Width := 100;
  Barcode.ModuleWidth := 4;
  Barcode.BarcodeType := DIO_BARCODE_DATAMATRIX;
  Barcode.Alignment := BARCODE_ALIGNMENT_CENTER;

  FPrinter.Expects('Get_CapRecBarCode').Returns(True);
  FPrinter.Expects('PrintBarCode').WithParams([FPTR_S_RECEIPT,
    Barcode.Data, PTR_BCS_DATAMATRIX, Barcode.Height, Barcode.Width,
    PTR_BC_CENTER, PTR_BC_TEXT_NONE]).Returns(0);
  FDriver.PrintBarcode2(Barcode);
  FPrinter.Verify('Verify success');
end;

(*
  PrintBarcodeESCCommands  = 0;
  PrintBarcodeGraphics     = 1;
  PrintBarcodeText         = 2;
  PrintBarcodeNone         = 3;

*)

procedure TWebkassaImplTest3.TestPrintBarcodeAsBarcode2;
var
  Barcode: TBarcodeRec;
begin
  FDriver.Params.PrintBarcode := PrintBarcodeESCCommands;
  Barcode.Data := '3850504580002030';
  Barcode.Text := 'DATAMATRIX';
  Barcode.Height := 100;
  Barcode.Width := 100;
  Barcode.ModuleWidth := 4;
  Barcode.BarcodeType := DIO_BARCODE_DATAMATRIX;
  Barcode.Alignment := BARCODE_ALIGNMENT_CENTER;

  FPrinter.Expects('Get_CapRecBarCode').Returns(True);
  FPrinter.Expects('PrintBarCode').WithParams([FPTR_S_RECEIPT,
    Barcode.Data, PTR_BCS_DATAMATRIX, Barcode.Height, Barcode.Width,
    PTR_BC_CENTER, PTR_BC_TEXT_NONE]).Returns(OPOS_E_ILLEGAL);
  FPrinter.Expects('Get_ResultCode').Returns(OPOS_E_ILLEGAL);
  FPrinter.Expects('Get_ResultCodeExtended').Returns(0);
  FPrinter.Expects('Get_ErrorString').Returns('ErrorString');
  try
    FDriver.PrintBarcode2(Barcode);
    Fail('No exception');
  except
    on E: EOPOSException do
    begin
      CheckEquals(OPOS_E_ILLEGAL, E.ResultCode, 'E.ResultCode <> OPOS_E_ILLEGAL');
      CheckEquals('ErrorString', E.Message, 'Invalid E.Message');
    end;
  end;
  FPrinter.Verify('Verify success');
end;

procedure TWebkassaImplTest3.TestPrintBarcodeAsGraphics;
var
  Barcode: TBarcodeRec;
const
  BitmapData =
  '424=76000000000000003>000000280000000>0000000>000000010001000000000038000' +
  '0000000000000000000020000000000000000000000??????0000000000285400005<?800' +
  '0035:400000?;80000302<000020<800006=;<00007==800001::<00003;=80000106<000' +
  '02=58000055540000';
begin
  FDriver.Params.PrintBarcode := PrintBarcodeGraphics;
  Barcode.Data := '3850504580002030';
  Barcode.Text := 'DATAMATRIX';
  Barcode.Height := 28;
  Barcode.ModuleWidth := 2;
  Barcode.BarcodeType := DIO_BARCODE_DATAMATRIX;
  Barcode.Alignment := BARCODE_ALIGNMENT_CENTER;

  FPrinter.Expects('Open').WithParams(['ThermalU']).Returns(0);
  FPrinter.Expects('Get_CapPowerReporting').Returns(True);
  FPrinter.Expects('Get_CapRecBitmap').Returns(True);
  FPrinter.Expects('Set_BinaryConversion').WithParams([OPOS_BC_NIBBLE]);
  FPrinter.Expects('PrintMemoryBitmap').WithParams([FPTR_S_RECEIPT, BitmapData,
    PTR_BMT_BMP, 28, PTR_BM_CENTER]).Returns(0);

  FPrinter.Expects('Set_BinaryConversion').WithParams([OPOS_BC_NONE]);
  FPrinter.Expects('Close').Returns(0);

  CheckEquals(0, FDriver.OpenService(OPOS_CLASSKEY_FPTR, 'DeviceName', nil), 'OpenService');
  CheckEquals(0, FDriver.ClaimDevice(1000), 'ClaimDevice');
  FDriver.SetPropertyNumber(PIDX_DeviceEnabled, 1);
  CheckEquals(1, FDriver.GetPropertyNumber(PIDX_DeviceEnabled), 'DeviceEnabled');
  FDriver.PrintBarcode2(Barcode);
  FDriver.Close;

  FPrinter.Verify('Verify success');
end;


initialization
  RegisterTest('', TWebkassaImplTest3.Suite);


end.

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
  OposEvents, OposPtr, RCSEvents, OposEsc,
  // Tnt
  TntClasses, TntSysUtils,
  // This
  LogFile, WebkassaImpl, WebkassaClient, MockPosPrinter2, FileUtils,
  CustomReceipt, uLkJSON, ReceiptTemplate, SalesReceipt, DirectIOAPI,
  DebugUtils, StringUtils, OposServiceDevice19, PosEscPrinter, PrinterPort,
  MockPrinterPort;

const
  CRLF = #13#10;

type
  { TWebkassaImplTest3 }

  TWebkassaImplTest3 = class(TTestCase)
  private
    FLogger: ILogFile;
    FPort: IPrinterPort;
    FDriver: TWebkassaImpl;
    FPrinter: TPosEscPrinter;
  protected
    property Driver: TWebkassaImpl read FDriver;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestPrintQRCode;
  end;

implementation

{ TWebkassaImplTest3 }

procedure TWebkassaImplTest3.SetUp;
begin
  inherited SetUp;

  FLogger := TLogFile.Create;
  FPort := TMockPrinterPort.Create('Printer');
  FPrinter := TPosEscPrinter.Create2(nil, FPort, FLogger);
  FDriver := TWebkassaImpl.Create(nil);

  FDriver.TestMode := True;
  FDriver.Client.TestMode := True;
  FDriver.Printer := FPrinter;
  FDriver.Params.FontName := '42';
  FDriver.Params.LogFileEnabled := False;
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
    '   Восточно-Казастанская область, город   ' + CRLF +
    '  Усть-Каменогорск, ул. Грейдерная, 1/10  ' + CRLF +
    '            ТОО PetroRetail               ';
  FDriver.Params.TrailerText :=
    '           Callцентр 039458039850         ' + CRLF +
    '          Горячая линия 20948802934       ' + CRLF +
    '            СПАСИБО ЗА ПОКУПКУ            ';

  FDriver.Logger.CloseFile;
  DeleteFile(FDriver.Logger.FileName);
end;

procedure TWebkassaImplTest3.TearDown;
begin
  FDriver.Free;
  inherited TearDown;
end;


procedure TWebkassaImplTest3.TestPrintQRCode;
const
  BarcodeData = 'https://devkkm.webkassa.kz/Ticket?chb=SWK00033059&sh=100&extnum=92D51F08-13CF-428E-AF2F-67B6E8BDE994';
begin
  FPrinter.FCapRecBitmap := True;
  FDriver.PrintQRCodeAsGraphics(BarcodeData);
end;

initialization
  RegisterTest('', TWebkassaImplTest3.Suite);


end.

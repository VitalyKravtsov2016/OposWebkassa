unit duPrinterParameters;

interface

uses
  // VCL
  Windows, SysUtils, Classes,
  // DUnit
  TestFramework,
  // This
  PrinterParameters, PrinterParametersX, PrinterParametersReg, LogFile;

type
  { TPrinterParametersTest }

  TPrinterParametersTest = class(TTestCase)
  private
    FLogger: ILogFile;
    FParams: TPrinterParameters;
    procedure SetNonDefaultParams;
    procedure CheckNonDefaultParams;
  protected
    procedure Setup; override;
    procedure TearDown; override;
  published
    procedure CheckLoadReg;
    procedure CheckSetDefaults;
    procedure CheckDefaultParams;
  end;

implementation

{ TPrinterParametersTest }

procedure TPrinterParametersTest.Setup;
begin
  inherited Setup;
  FLogger := TLogFile.Create;
  FParams := TPrinterParameters.Create(FLogger);
end;

procedure TPrinterParametersTest.TearDown;
begin
  FParams.Free;
  inherited TearDown;
end;

procedure TPrinterParametersTest.SetNonDefaultParams;
begin
  FParams.NumHeaderLines := 2;
  FParams.NumTrailerLines := 1;
  FParams.Header := 'wjyert84r6';
  FParams.Trailer := '2i34r6827346';
  FParams.LogMaxCount := 123;
  FParams.LogFileEnabled := False;
  FParams.LogFilePath := '97898798';
  FParams.WebkassaAddress := '-9-09';
  FParams.ConnectTimeout := 23454;
  FParams.Login := '2349-204';
  FParams.Password := '-23409820498';
  FParams.CashboxNumber := '2de9h9347r';
  FParams.PrinterName := '2138e09uhi432uy';
  FParams.PrinterType := 0;
  FParams.VatCodes.Clear;
  FParams.VatCodes.Add(123, 34.45, '2j3erkuy237');
  FParams.VatCodes.Add(546, 34.67, '2j3erkuy237');
  FParams.VatCodeEnabled := False;
  FParams.PaymentType2 := 0;
  FParams.PaymentType3 := 0;
  FParams.PaymentType4 := 0;
end;

procedure TPrinterParametersTest.CheckNonDefaultParams;
begin
  CheckEquals(2, FParams.NumHeaderLines, 'NumHeaderLines');
  CheckEquals(1, FParams.NumTrailerLines, 'NumTrailerLines');
  CheckEquals('wjyert84r6', FParams.Header, 'Header');
  CheckEquals('2i34r6827346', FParams.Trailer, 'Trailer');
  CheckEquals(123, FParams.LogMaxCount, 'LogMaxCount');
  CheckEquals(False, FParams.LogFileEnabled, 'LogFileEnabled');
  CheckEquals('97898798', FParams.LogFilePath, 'LogFilePath');
  CheckEquals('-9-09' , FParams.WebkassaAddress, 'WebkassaAddress');
  CheckEquals(23454, FParams.ConnectTimeout, 'ConnectTimeout');
  CheckEquals('2349-204', FParams.Login, 'Login');
  CheckEquals('-23409820498', FParams.Password, 'Password');
  CheckEquals('2de9h9347r', FParams.CashboxNumber, 'CashboxNumber');
  CheckEquals('2138e09uhi432uy', FParams.PrinterName, 'PrinterName');
  CheckEquals(0, FParams.PrinterType, 'PrinterType');
  CheckEquals(2, FParams.VatCodes.Count, 'VatCodes.Count');
  CheckEquals(123, FParams.VatCodes[0].Code, 'VatCodes[0].Code');
  CheckEquals(34.45, FParams.VatCodes[0].Rate, 0.001, 'VatCodes[0].Rate');
  CheckEquals('2j3erkuy237', FParams.VatCodes[0].Name, 'VatCodes[0].Name');
  CheckEquals(False, FParams.VatCodeEnabled, 'VatCodeEnabled');
  CheckEquals(0, FParams.PaymentType2, 'PaymentType2');
  CheckEquals(0, FParams.PaymentType3, 'PaymentType3');
  CheckEquals(0, FParams.PaymentType4, 'PaymentType4');
end;


procedure TPrinterParametersTest.CheckDefaultParams;
begin
  CheckEquals(DefHeader, FParams.Header, 'Params.Header');
  CheckEquals(DefTrailer, FParams.Trailer, 'Params.Trailer');
  CheckEquals(DefNumHeaderLines, FParams.NumHeaderLines, 'NumHeaderLines');
  CheckEquals(DefNumTrailerLines, FParams.NumTrailerLines, 'NumTrailerLines');
  CheckEquals(DefLogMaxCount, FParams.LogMaxCount, 'LogMaxCount');
  CheckEquals(DefLogFileEnabled, FParams.LogFileEnabled, 'LogFileEnabled');
  CheckEquals(DefWebkassaAddress, FParams.WebkassaAddress, 'WebkassaAddress');
  CheckEquals(DefConnectTimeout, FParams.ConnectTimeout, 'ConnectTimeout');
  CheckEquals(DefLogin, FParams.Login, 'Login');
  CheckEquals(DefPassword, FParams.Password, 'Password');
  CheckEquals(DefCashboxNumber, FParams.CashboxNumber, 'CashboxNumber');
  CheckEquals(DefPrinterName, FParams.PrinterName, 'PrinterName');
  CheckEquals(DefPrinterType, FParams.PrinterType, 'PrinterType');
  CheckEquals(6, FParams.VatCodes.Count, 'VatCodes.Count');
  CheckEquals(1, FParams.VatCodes[0].Code, 'VatCodes[0].Code');
  CheckEquals(20, FParams.VatCodes[0].Rate, 0.001, 'VatCodes[0].Rate');
  CheckEquals('ÍÄÑ 20%', FParams.VatCodes[0].Name, 'VatCodes[0].Name');
  CheckEquals(False, FParams.VatCodeEnabled, 'VatCodeEnabled');
  CheckEquals(1, FParams.PaymentType2, 'PaymentType2');
  CheckEquals(2, FParams.PaymentType3, 'PaymentType3');
  CheckEquals(3, FParams.PaymentType4, 'PaymentType4');
end;

procedure TPrinterParametersTest.CheckSetDefaults;
begin
  SetNonDefaultParams;
  FParams.SetDefaults;
  CheckDefaultParams;
end;

procedure TPrinterParametersTest.CheckLoadReg;
begin
  SetNonDefaultParams;
  SaveParametersReg(FParams, 'DeviceName', FLogger);
  FParams.SetDefaults;
  LoadParametersReg(FParams, 'DeviceName', FLogger);
  CheckNonDefaultParams;
  DeleteParametersReg('DeviceName', FLogger);
end;

initialization
  RegisterTest('', TPrinterParametersTest.Suite);


end.

unit duPrinterParameters;

interface

uses
  // VCL
  Windows, SysUtils, Classes,
  // DUnit
  TestFramework,
  // Tnt
  TntClasses,
  // This
  PrinterParameters, PrinterParametersReg, LogFile, StringUtils, FileUtils;

type
  { TPrinterParametersTest }

  TPrinterParametersTest = class(TTestCase)
  private
    FLogger: ILogFile;
    FParams: TPrinterParameters;

    procedure SetNonDefaultParams;
    procedure CheckNonDefaultParams;

    property Params: TPrinterParameters read FParams;
  protected
    procedure Setup; override;
    procedure TearDown; override;
  published
    procedure CheckLoadReg;
    procedure CheckLoadParams;
    procedure CheckSetDefaults;
    procedure CheckDefaultParams;
    procedure CheckGetTranslationText;
    procedure CheckArrayOfString;
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
  FParams.NumTrailerLines := 3;
  FParams.HeaderText := 'HLine 1' + CRLF + 'HLine 2';
  FParams.TrailerText := 'TLine 1' + CRLF + 'TLine 2' + CRLF + 'TLine 3';
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
  FParams.VatRates.Clear;
  FParams.VatRates.Add(123, 34.45, '2j3erkuy237');
  FParams.VatRates.Add(546, 34.67, '2j3erkuy237');
  FParams.VatRateEnabled := False;
  FParams.PaymentType2 := 0;
  FParams.PaymentType3 := 0;
  FParams.PaymentType4 := 0;
  FParams.RoundType := 1;
  FParams.VATNumber := '1234';
  FParams.TranslationEnabled := True;
  FParams.OfflineText := 'OfflineText';
  FParams.Units.Clear;
  FParams.Units.AddItem(1, '123', '234', '345');
  FParams.Units.AddItem(2, '876', '547', '875');
  FParams.ReplaceDataMatrixWithQRCode := True;
  FParams.UnitNames.Clear;
  FParams.AddUnitName('л.', 'литр', 1);
  FParams.AddUnitName('Л', 'литр', 2);
end;

procedure TPrinterParametersTest.CheckNonDefaultParams;
begin
  CheckEquals(2, FParams.NumHeaderLines, 'NumHeaderLines');
  CheckEquals(3, FParams.NumTrailerLines, 'NumTrailerLines');
  CheckEquals(2, Length(FParams.Header), 'Length(FParams.Header)');
  CheckEquals(3, Length(FParams.Trailer), 'Length(FParams.Trailer)');
  CheckEquals('HLine 1', FParams.Header[0], 'FParams.Header[0]');
  CheckEquals('HLine 2', FParams.Header[1], 'FParams.Header[1]');
  CheckEquals('TLine 1', FParams.Trailer[0], 'FParams.Trailer[0]');
  CheckEquals('TLine 2', FParams.Trailer[1], 'FParams.Trailer[1]');
  CheckEquals('TLine 3', FParams.Trailer[2], 'FParams.Trailer[2]');
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
  CheckEquals(2, FParams.VatRates.Count, 'VatRates.Count');
  CheckEquals(123, FParams.VatRates[0].ID, 'VatRates[0].ID');
  CheckEquals(34.45, FParams.VatRates[0].Rate, 0.001, 'VatRates[0].Rate');
  CheckEquals('2j3erkuy237', FParams.VatRates[0].Name, 'VatRates[0].Name');
  CheckEquals(False, FParams.VatRateEnabled, 'VatRateEnabled');
  CheckEquals(0, FParams.PaymentType2, 'PaymentType2');
  CheckEquals(0, FParams.PaymentType3, 'PaymentType3');
  CheckEquals(0, FParams.PaymentType4, 'PaymentType4');
  CheckEquals(1, FParams.RoundType, 'RoundType');
  CheckEquals('1234', FParams.VATNumber, 'VATNumber');
  CheckEquals(True, FParams.TranslationEnabled, 'TranslationEnabled');
  CheckEquals('OfflineText', FParams.OfflineText, 'OfflineText');
  CheckEquals(2, FParams.Units.Count, 'Units.Count');
  CheckEquals(1, FParams.Units[0].Code, 'Units[0].Code');
  CheckEquals('123', FParams.Units[0].NameRu, 'Units[0].NameRu');
  CheckEquals('234', FParams.Units[0].NameKz, 'Units[0].NameKz');
  CheckEquals('345', FParams.Units[0].NameEn, 'Units[0].NameEn');
  CheckEquals(2, FParams.Units[1].Code, 'Units[1].Code');
  CheckEquals('876', FParams.Units[1].NameRu, 'Units[1].NameRu');
  CheckEquals('547', FParams.Units[1].NameKz, 'Units[1].NameKz');
  CheckEquals('875', FParams.Units[1].NameEn, 'Units[1].NameEn');
  CheckEquals(True, FParams.ReplaceDataMatrixWithQRCode, 'ReplaceDataMatrixWithQRCode');
  CheckEquals(2, FParams.UnitNames.Count, 'UnitNames.Count');

  CheckEquals('л.', FParams.UnitNames[0].AppName, 'UnitNames[0].AppName');
  CheckEquals('литр', FParams.UnitNames[0].SrvName, 'UnitNames[0].SrvName');
  CheckEquals(1, FParams.UnitNames[0].SrvCode, 'UnitNames[0].SrvCode');

  CheckEquals('Л', FParams.UnitNames[1].AppName, 'UnitNames[1].AppName');
  CheckEquals('литр', FParams.UnitNames[1].SrvName, 'UnitNames[1].SrvName');
  CheckEquals(2, FParams.UnitNames[1].SrvCode, 'UnitNames[1].SrvCode');
end;


procedure TPrinterParametersTest.CheckDefaultParams;
begin
  CheckEquals(Trim(DefHeader), Trim(FParams.HeaderText), 'Params.HeaderText');
  CheckEquals(Trim(DefTrailer), Trim(FParams.TrailerText), 'Params.TrailerText');
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
  CheckEquals(1, FParams.VatRates.Count, 'VatRates.Count');
  CheckEquals(1, FParams.VatRates[0].ID, 'VatRates[0].ID');
  CheckEquals(12, FParams.VatRates[0].Rate, 0.001, 'VatRates[0].Rate');
  CheckEquals('НДС 12%', FParams.VatRates[0].Name, 'VatRates[0].Name');
  CheckEquals(True, FParams.VatRateEnabled, 'VatRateEnabled');
  CheckEquals(1, FParams.PaymentType2, 'PaymentType2');
  CheckEquals(2, FParams.PaymentType3, 'PaymentType3');
  CheckEquals(3, FParams.PaymentType4, 'PaymentType4');
  CheckEquals(DefRoundType, FParams.RoundType, 'RoundType');
  CheckEquals(DefVATNumber, FParams.VATNumber, 'VATNumber');
  CheckEquals(False, FParams.TranslationEnabled, 'TranslationEnabled');
  CheckEquals(DefOfflineText, FParams.OfflineText, 'OfflineText');
  CheckEquals(0, FParams.Units.Count, 'Units.Count');
  CheckEquals(False, FParams.ReplaceDataMatrixWithQRCode, 'ReplaceDataMatrixWithQRCode');
  CheckEquals(0, FParams.UnitNames.Count, 'UnitNames.Count');
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

procedure TPrinterParametersTest.CheckLoadParams;
begin
  SetNonDefaultParams;
  SaveParametersReg(FParams, 'DeviceName', FLogger);
  FParams.SetDefaults;
  LoadParametersReg(FParams, 'DeviceName', FLogger);
  CheckNonDefaultParams;
end;

procedure TPrinterParametersTest.CheckGetTranslationText;
var
  i: Integer;
  Text: WideString;
  FileName: WideString;
  LinesRus: TTntStrings;
  LinesKaz: TTntStrings;
begin
  Params.TranslationEnabled := True;
  LinesRus := TTntStringList.Create;
  LinesKaz := TTntStringList.Create;
  try
    FileName := GetModulePath + 'Translation\OposWebkassa';
    LinesRus.LoadFromFile(FileName + '.RUS');
    LinesKaz.LoadFromFile(FileName + '.KAZ');

    CheckEquals(15, LinesRus.Count, 'LinesRus.Count');
    CheckEquals(15, LinesKaz.Count, 'LinesKaz.Count');
    for i := 0 to LinesRus.Count-1 do
    begin
      Text := Params.GetTranslationText(LinesRus[i]);
      CheckEquals(LinesKaz[i], Text, 'Line ' + IntToStr(i));
    end;
  finally
    LinesRus.Free;
    LinesKaz.Free;
  end;
end;

procedure TPrinterParametersTest.CheckArrayOfString;
var
  Lines: array of WideString;
begin
  CheckEquals(0, Length(Lines), 'Length(Lines) <> 0');
  SetLength(Lines, 2);
  Lines[0] := 'Line 0';
  Lines[1] := 'Line 1';
  CheckEquals('Line 0', Lines[0], 'Lines[0]');
  CheckEquals('Line 1', Lines[1], 'Lines[1]');
  SetLength(Lines, 1);
  CheckEquals('Line 0', Lines[0], 'Lines[0]');
  SetLength(Lines, 3);
  CheckEquals('Line 0', Lines[0], 'Lines[0]');
  CheckEquals('', Lines[1], 'Lines[1]');
  CheckEquals('', Lines[2], 'Lines[2]');
end;

initialization
  RegisterTest('', TPrinterParametersTest.Suite);


end.

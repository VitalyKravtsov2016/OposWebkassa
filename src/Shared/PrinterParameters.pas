unit PrinterParameters;

interface

uses
  // VCL
  Windows, SysUtils, Classes,
  // 3'd
  TntClasses, TntStdCtrls, TntRegistry,
  // Opos
  Opos, Oposhi, OposException,
  // This
  WException, LogFile, FileUtils, VatCode;

const
  FiscalPrinterProgID = 'OposWebkassa.FiscalPrinter';

  // PrinterType constants
  PrinterTypePosPrinter = 0;
  PrinterTypeWinPrinter = 1;

  DefLogMaxCount = 10;
  DefLogFileEnabled = True;

  DefNumHeaderLines = 6;
  DefNumTrailerLines = 4;
  DefHeader =
    'Header line 1'#13#10 +
    'Header line 2'#13#10 +
    'Header line 3'#13#10 +
    'Header line 4'#13#10 +
    'Header line 5'#13#10 +
    'Header line 6';

  DefTrailer =
    'Trailer line 1'#13#10 +
    'Trailer line 2'#13#10 +
    'Trailer line 3'#13#10 +
    'Trailer line 4';

  DefVatCodeEnabled = False;
  DefLogin = 'webkassa4@softit.kz';
  DefPassword = 'Kassa123';
  DefConnectTimeout = 10;
  DefWebkassaAddress = 'https://devkkm.webkassa.kz/';
  DefCashboxNumber = 'SWK00032685';
  DefPrinterName = '';
  DefPrinterType = 0;
  DefRoundType = 2; // Îêðóãëåíèå ïîçèöèé

  /////////////////////////////////////////////////////////////////////////////
  // Header and trailer parameters

  MinHeaderLines  = 0;
  MaxHeaderLines  = 100;
  MinTrailerLines = 0;
  MaxTrailerLines = 100;

type
  { TPrinterParameters }

  TPrinterParameters = class(TPersistent)
  private
    FLogger: ILogFile;
    FHeader: WideString;
    FTrailer: WideString;
    FLogMaxCount: Integer;
    FLogFileEnabled: Boolean;
    FLogFilePath: WideString;
    FNumHeaderLines: Integer;
    FNumTrailerLines: Integer;
    FWebkassaAddress: WideString;
    FConnectTimeout: Integer;
    FLogin: WideString;
    FPassword: WideString;
    FCashboxNumber: WideString;
    FPrinterName: WideString;
    FPrinterType: Integer;
    FVatCodes: TVatCodes;
    FVatCodeEnabled: Boolean;
    FPaymentType2: Integer;
    FPaymentType3: Integer;
    FPaymentType4: Integer;
    FRoundType: Integer;

    procedure LogText(const Caption, Text: WideString);
    procedure SetNumHeaderLines(const Value: Integer);
    procedure SetNumTrailerLines(const Value: Integer);
  public
    constructor Create(ALogger: ILogFile);
    destructor Destroy; override;

    procedure SetDefaults;
    procedure CheckPrameters;
    procedure WriteLogParameters;

    property Logger: ILogFile read FLogger;
    property Login: WideString read FLogin write FLogin;
    property Password: WideString read FPassword write FPassword;
    property ConnectTimeout: Integer read FConnectTimeout write FConnectTimeout;
    property WebkassaAddress: WideString read FWebkassaAddress write FWebkassaAddress;
    property Header: WideString read FHeader write FHeader;
    property Trailer: WideString read FTrailer write FTrailer;
    property LogMaxCount: Integer read FLogMaxCount write FLogMaxCount;
    property LogFilePath: WideString read FLogFilePath write FLogFilePath;
    property LogFileEnabled: Boolean read FLogFileEnabled write FLogFileEnabled;
    property NumHeaderLines: Integer read FNumHeaderLines write SetNumHeaderLines;
    property NumTrailerLines: Integer read FNumTrailerLines write SetNumTrailerLines;
    property PrinterName: WideString read FPrinterName write FPrinterName;
    property PrinterType: Integer read FPrinterType write FPrinterType;
    property CashboxNumber: WideString read FCashboxNumber write FCashboxNumber;
    property VatCodes: TVatCodes read FVatCodes;
    property VatCodeEnabled: Boolean read FVatCodeEnabled write FVatCodeEnabled;
    property PaymentType2: Integer read FPaymentType2 write FPaymentType2;
    property PaymentType3: Integer read FPaymentType3 write FPaymentType3;
    property PaymentType4: Integer read FPaymentType4 write FPaymentType4;
    property RoundType: Integer read FRoundType write FRoundType;
  end;

implementation

{ TPrinterParameters }

constructor TPrinterParameters.Create(ALogger: ILogFile);
begin
  inherited Create;
  FLogger := ALogger;
  FVatCodes := TVatCodes.Create;
  SetDefaults;
end;

destructor TPrinterParameters.Destroy;
begin
  FVatCodes.Free;
  inherited Destroy;
end;

procedure TPrinterParameters.SetDefaults;
begin
  Logger.Debug('TPrinterParameters.SetDefaults');

  FLogin := DefLogin;
  FPassword := DefPassword;
  ConnectTimeout := DefConnectTimeout;
  WebkassaAddress := DefWebkassaAddress;
  CashboxNumber := DefCashboxNumber;

  FHeader := DefHeader;
  FTrailer := DefTrailer;
  FLogMaxCount := DefLogMaxCount;
  FLogFilePath := GetModulePath + 'Logs';
  FLogFileEnabled := DefLogFileEnabled;
  FNumHeaderLines := DefNumHeaderLines;
  FNumTrailerLines := DefNumTrailerLines;
  VatCodeEnabled := DefVatCodeEnabled;
  PaymentType2 := 1;
  PaymentType3 := 2;
  PaymentType4 := 3;
  PrinterName := DefPrinterName;
  PrinterType := DefPrinterType;
  RoundType := DefRoundType;

  // VatCodes
  VatCodes.Clear;
  VatCodes.Add(1, 20, 'ÍÄÑ 20%');     // ÍÄÑ 20%
  VatCodes.Add(2, 10, 'ÍÄÑ 10%');     // ÍÄÑ 10%
  VatCodes.Add(3, 0, 'ÍÄÑ 0%');       // ÍÄÑ 0%
  VatCodes.Add(4, 0, 'ÁÅÇ ÍÄÑ');      // ÁÅÇ ÍÄÑ
  VatCodes.Add(5, 20, 'ÍÄÑ 20/120');  // ÍÄÑ 20/120
  VatCodes.Add(6, 10, 'ÍÄÑ 10/110');  // ÍÄÑ 10/110
end;

procedure TPrinterParameters.LogText(const Caption, Text: WideString);
var
  i: Integer;
  Lines: TTntStrings;
begin
  Lines := TTntStringList.Create;
  try
    Lines.Text := Text;
    if Lines.Count = 1 then
    begin
      Logger.Debug(Format('%s: ''%s''', [Caption, Lines[0]]));
    end else
    begin
      for i := 0 to Lines.Count-1 do
      begin
        Logger.Debug(Format('%s.%d: ''%s''', [Caption, i, Lines[i]]));
      end;
    end;
  finally
    Lines.Free;
  end;
end;

procedure TPrinterParameters.WriteLogParameters;
var
  i: Integer;
  VatCode: TVatCode;
begin
  Logger.Debug('TPrinterParameters.WriteLogParameters');
  Logger.Debug(Logger.Separator);
  Logger.Debug('Login: ' + Login);
  Logger.Debug('Password: ' + Password);
  Logger.Debug('ConnectTimeout: ' + IntToStr(ConnectTimeout));
  Logger.Debug('WebkassaAddress: ' + WebkassaAddress);
  Logger.Debug('LogMaxCount: ' + IntToStr(LogMaxCount));
  Logger.Debug('LogFilePath: ' + LogFilePath);
  Logger.Debug('LogFileEnabled: ' + BoolToStr(LogFileEnabled));
  Logger.Debug('PrinterName: ' + PrinterName);
  Logger.Debug('PrinterType: ' + IntToStr(PrinterType));
  Logger.Debug('CashboxNumber: ' + CashboxNumber);
  Logger.Debug('NumHeaderLines: ' + IntToStr(NumHeaderLines));
  Logger.Debug('NumTrailerLines: ' + IntToStr(NumTrailerLines));
  LogText('Header', Header);
  LogText('Trailer', Trailer);
  Logger.Debug('PaymentType2: ' + IntToStr(PaymentType2));
  Logger.Debug('PaymentType3: ' + IntToStr(PaymentType3));
  Logger.Debug('PaymentType4: ' + IntToStr(PaymentType4));
  Logger.Debug('VatCodeEnabled: ' + BoolToStr(VatCodeEnabled));
  Logger.Debug('RoundType: ' + IntToStr(RoundType));
  // VatCodes
  for i := 0 to VatCodes.Count-1 do
  begin
    VatCode := VatCodes[i];
    Logger.Debug(Format('VAT: code=%d, rate=%.2f, name="%s"', [
      VatCode.Code, VatCode.Rate, VatCode.Name]));
  end;
  Logger.Debug(Logger.Separator);
end;

procedure TPrinterParameters.SetNumHeaderLines(const Value: Integer);
begin
  if Value in [MinHeaderLines..MaxHeaderLines] then
    FNumHeaderLines := Value;
end;

procedure TPrinterParameters.SetNumTrailerLines(const Value: Integer);
begin
  if Value in [MinTrailerLines..MaxTrailerLines] then
    FNumTrailerLines := Value;
end;

procedure TPrinterParameters.CheckPrameters;
begin
  if FWebkassaAddress = '' then
    RaiseOposException(OPOS_ORS_CONFIG, 'WebKassa address not defined');

  if Login = '' then
    RaiseOposException(OPOS_ORS_CONFIG, 'WebKassa login not defined');

  if Password = '' then
    RaiseOposException(OPOS_ORS_CONFIG, 'WebKassa password not defined');

  if CashboxNumber = '' then
    RaiseOposException(OPOS_ORS_CONFIG, 'WebKassa number not defined');

  if PrinterName = '' then
    RaiseOposException(OPOS_ORS_CONFIG, 'WebKassa printer name not defined');
end;

end.

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
  WException, LogFile, FileUtils, VatRate;

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

  DefVatRateEnabled = True;
  DefLogin = 'webkassa4@softit.kz';
  DefPassword = 'Kassa123';
  DefConnectTimeout = 10;
  DefWebkassaAddress = 'https://devkkm.webkassa.kz/';
  DefCashboxNumber = 'SWK00032685';
  DefPrinterName = '';
  DefPrinterType = 0;
  DefRoundType = 2; // Округление позиций
  DefVATNumber = '00000';
  DefVATSeries = '00000';
  DefAmountDecimalPlaces = 2;

  /////////////////////////////////////////////////////////////////////////////
  // Header and trailer parameters

  MinHeaderLines  = 0;
  MaxHeaderLines  = 100;
  MinTrailerLines = 0;
  MaxTrailerLines = 100;

  /////////////////////////////////////////////////////////////////////////////
  // QR code size

  QRSizeSmall     = 0;
  QRSizeMedium    = 1;
  QRSizeLarge     = 2;
  QRSizeXLarge    = 3;
  QRSizeXXLarge   = 4;

type
  { TPrinterParameters }

  TPrinterParameters = class(TPersistent)
  private
    FLogger: ILogFile;
    FHeader: TTntStringList;
    FTrailer: TTntStringList;
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
    FVatRates: TVatRates;
    FVatRateEnabled: Boolean;
    FPaymentType2: Integer;
    FPaymentType3: Integer;
    FPaymentType4: Integer;
    FRoundType: Integer;
    FVATNumber: WideString;
    FVATSeries: WideString;
    FAmountDecimalPlaces: Integer;

    procedure LogText(const Caption, Text: WideString);
    procedure SetHeaderText(const Text: WideString);
    procedure SetTrailerText(const Text: WideString);
    procedure SetNumHeaderLines(const Value: Integer);
    procedure SetNumTrailerLines(const Value: Integer);
    function GetHeaderText: WideString;
    function GetTrailerText: WideString;
    procedure SetAmountDecimalPlaces(const Value: Integer);
  public
    constructor Create(ALogger: ILogFile);
    destructor Destroy; override;

    procedure SetDefaults;
    procedure CheckPrameters;
    procedure WriteLogParameters;

    property Logger: ILogFile read FLogger;
    property Header: TTntStringList read FHeader;
    property Trailer: TTntStringList read FTrailer;
    property Login: WideString read FLogin write FLogin;
    property Password: WideString read FPassword write FPassword;
    property ConnectTimeout: Integer read FConnectTimeout write FConnectTimeout;
    property WebkassaAddress: WideString read FWebkassaAddress write FWebkassaAddress;
    property LogMaxCount: Integer read FLogMaxCount write FLogMaxCount;
    property LogFilePath: WideString read FLogFilePath write FLogFilePath;
    property LogFileEnabled: Boolean read FLogFileEnabled write FLogFileEnabled;
    property NumHeaderLines: Integer read FNumHeaderLines write SetNumHeaderLines;
    property NumTrailerLines: Integer read FNumTrailerLines write SetNumTrailerLines;
    property PrinterName: WideString read FPrinterName write FPrinterName;
    property PrinterType: Integer read FPrinterType write FPrinterType;
    property CashboxNumber: WideString read FCashboxNumber write FCashboxNumber;
    property VatRates: TVatRates read FVatRates;
    property VatRateEnabled: Boolean read FVatRateEnabled write FVatRateEnabled;
    property PaymentType2: Integer read FPaymentType2 write FPaymentType2;
    property PaymentType3: Integer read FPaymentType3 write FPaymentType3;
    property PaymentType4: Integer read FPaymentType4 write FPaymentType4;
    property RoundType: Integer read FRoundType write FRoundType;
    property VATSeries: WideString read FVATSeries write FVATSeries;
    property VATNumber: WideString read FVATNumber write FVATNumber;
    property HeaderText: WideString read GetHeaderText write SetHeaderText;
    property TrailerText: WideString read GetTrailerText write SetTrailerText;
    property AmountDecimalPlaces: Integer read FAmountDecimalPlaces write SetAmountDecimalPlaces;
  end;

function QRSizeToWidth(QRSize: Integer): Integer;

implementation

function QRSizeToWidth(QRSize: Integer): Integer;
begin
  Result := 0;
  case QRSize of
    QRSizeSmall     : Result := 102;
    QRSizeMedium    : Result := 153;
    QRSizeLarge     : Result := 204;
    QRSizeXLarge    : Result := 256;
    QRSizeXXLarge   : Result := 512;
  end;
end;

{ TPrinterParameters }

constructor TPrinterParameters.Create(ALogger: ILogFile);
begin
  inherited Create;
  FLogger := ALogger;
  FVatRates := TVatRates.Create;
  FHeader := TTntStringList.Create;
  FTrailer := TTntStringList.Create;
  SetDefaults;
end;

destructor TPrinterParameters.Destroy;
begin
  FHeader.Free;
  FTrailer.Free;
  FVatRates.Free;
  inherited Destroy;
end;

procedure TPrinterParameters.SetDefaults;
begin
  Logger.Debug('TPrinterParameters.SetDefaults');

  SetNumHeaderLines(DefNumHeaderLines);
  SetNumTrailerLines(DefNumTrailerLines);

  FLogin := DefLogin;
  FPassword := DefPassword;
  ConnectTimeout := DefConnectTimeout;
  WebkassaAddress := DefWebkassaAddress;
  CashboxNumber := DefCashboxNumber;

  SetHeaderText(DefHeader);
  SetTrailerText(DefTrailer);
  FLogMaxCount := DefLogMaxCount;
  FLogFilePath := GetModulePath + 'Logs';
  FLogFileEnabled := DefLogFileEnabled;
  VatRateEnabled := DefVatRateEnabled;
  PaymentType2 := 1;
  PaymentType3 := 2;
  PaymentType4 := 3;
  PrinterName := DefPrinterName;
  PrinterType := DefPrinterType;
  RoundType := DefRoundType;
  VATNumber := DefVATNumber;
  VATSeries := DefVATSeries;
  AmountDecimalPlaces := DefAmountDecimalPlaces;

  // VatRates
  VatRates.Clear;
  VatRates.Add(1, 12, 'НДС 12%'); // НДС 12%
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
  VatRate: TVatRate;
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
  LogText('Header', Header.Text);
  LogText('Trailer', Trailer.Text);
  Logger.Debug('PaymentType2: ' + IntToStr(PaymentType2));
  Logger.Debug('PaymentType3: ' + IntToStr(PaymentType3));
  Logger.Debug('PaymentType4: ' + IntToStr(PaymentType4));
  Logger.Debug('VatRateEnabled: ' + BoolToStr(VatRateEnabled));
  Logger.Debug('RoundType: ' + IntToStr(RoundType));
  Logger.Debug('VATSeries: ' + VATSeries);
  Logger.Debug('VATNumber: ' + VATNumber);
  Logger.Debug('AmountDecimalPlaces: ' + IntToStr(AmountDecimalPlaces));

  // VatRates
  for i := 0 to VatRates.Count-1 do
  begin
    VatRate := VatRates[i];
    Logger.Debug(Format('VAT: code=%d, rate=%.2f, name="%s"', [
      VatRate.Code, VatRate.Rate, VatRate.Name]));
  end;
  Logger.Debug(Logger.Separator);
end;

procedure TPrinterParameters.SetNumHeaderLines(const Value: Integer);
var
  i: Integer;
begin
  if Value in [MinHeaderLines..MaxHeaderLines] then
  begin
    FNumHeaderLines := Value;

    FHeader.Clear;
    for i := 1 to FNumHeaderLines do
      FHeader.Add('');
  end;
end;

procedure TPrinterParameters.SetNumTrailerLines(const Value: Integer);
var
  i: Integer;
begin
  if Value in [MinTrailerLines..MaxTrailerLines] then
  begin
    FNumTrailerLines := Value;

    FTrailer.Clear;
    for i := 1 to FNumTrailerLines do
      FTrailer.Add('');
  end;
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

procedure TPrinterParameters.SetHeaderText(const Text: WideString);
var
  i: Integer;
  Lines: TTntStringList;
begin
  Lines := TTntStringList.Create;
  try
    Lines.Text := Text;
    for i := 0 to Lines.Count-1 do
    begin
      if i >= NumHeaderLines then Break;
      FHeader[i] := Lines[i];
    end;
  finally
    Lines.Free;
  end;
end;

procedure TPrinterParameters.SetTrailerText(const Text: WideString);
var
  i: Integer;
  Lines: TTntStringList;
begin
  Lines := TTntStringList.Create;
  try
    Lines.Text := Text;
    for i := 0 to Lines.Count-1 do
    begin
      if i >= NumTrailerLines then Break;
      FTrailer[i] := Lines[i];
    end;
  finally
    Lines.Free;
  end;
end;

function TPrinterParameters.GetHeaderText: WideString;
begin
  Result := Header.Text;
end;

function TPrinterParameters.GetTrailerText: WideString;
begin
  Result := Trailer.Text;
end;

procedure TPrinterParameters.SetAmountDecimalPlaces(const Value: Integer);
begin
  if Value in [0, 2] then
    FAmountDecimalPlaces := Value;
end;

end.

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
  WException, LogFile, FileUtils, VatRate, SerialPort, SerialPorts, ReceiptItem,
  Translation, ReceiptTemplate;

const
  /////////////////////////////////////////////////////////////////////////////
  // Barcode print mode

  PrintBarcodeESCCommands  = 0;
  PrintBarcodeGraphics     = 1;
  PrintBarcodeText         = 2;
  PrintBarcodeNone         = 3;

  /////////////////////////////////////////////////////////////////////////////
  // Valid baudrates

  ValidBaudRates: array [0..9] of Integer = (
    2400,
    4800,
    9600,
    19200,
    38400,
    57600,
    115200,
    230400,
    460800,
    921600
  );

  FiscalPrinterProgID = 'OposWebkassa.FiscalPrinter';

  // PrinterType constants
  PrinterTypePosPrinter         = 0;
  PrinterTypeWinPrinter         = 1;
  PrinterTypeEscPrinterSerial   = 2;
  PrinterTypeEscPrinterNetwork  = 3;
  PrinterTypeEscPrinterWindows  = 4;


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
  DefFontName = '';
  DefRoundType = RoundTypeNone; // Округление позиций
  DefVATNumber = '00000';
  DefVATSeries = '00000';
  DefAmountDecimalPlaces = 2;
  DefRemoteHost = '192.168.1.87';
  DefRemotePort = 9100;
  DefByteTimeout = 500;

  DefPortName = 'COM1';
  DefBaudRate = CBR_9600;
  DefDataBits = DATABITS_8;
  DefStopBits = ONESTOPBIT;
  DefParity = NOPARITY;
  DefFlowControl = FLOW_CONTROL_NONE;
  DefReconnectPort = false;
  DefSerialTimeout = 500;
  DefDevicePollTime = 3000;
  DefReceiptTemplate = '';
  DefTranslationName = 'KAZ';
  DefPrintBarcode = PrintBarcodeEscCommands;
  DefTranslationEnabled = false;
  DefTemplateEnabled = False;
  DefCurrencyName = 'тг';
  DefLineSpacing = 30;
  DefPrintEnabled = True;
  DefRecLineChars = 42;
  DefRecLineHeight = 24;
  DefHeaderPrinted = false;

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

  /////////////////////////////////////////////////////////////////////////////
  // Translation name

  TranslationNameRus = 'RUS';
  TranslationNameKaz = 'KAZ';

type
  { TPrinterParameters }

  TPrinterParameters = class(TPersistent)
  private
    FLogger: ILogFile;
    FHeader: TTntStringList;
    FTrailer: TTntStringList;
    FTranslations: TTranslations;
    FTranslationName: WideString;
    FTranslation: TTranslation;
    FTranslationRus: TTranslation;
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
    FFontName: WideString;
    FVatRates: TVatRates;
    FVatRateEnabled: Boolean;
    FPaymentType2: Integer;
    FPaymentType3: Integer;
    FPaymentType4: Integer;
    FRoundType: Integer;
    FVATNumber: WideString;
    FVATSeries: WideString;
    FAmountDecimalPlaces: Integer;
    FRemoteHost: string;
    FRemotePort: Integer;
    FByteTimeout: Integer;
    FBaudRate: Integer;
    FDevicePollTime: Integer;
    FTranslationEnabled: Boolean;
    FTemplateEnabled: Boolean;
    FTemplate: TReceiptTemplate;
    FCurrencyName: string;
    FLineSpacing: Integer;
    FPrintEnabled: Boolean;

    procedure LogText(const Caption, Text: WideString);
    procedure SetHeaderText(const Text: WideString);
    procedure SetTrailerText(const Text: WideString);
    procedure SetNumHeaderLines(const Value: Integer);
    procedure SetNumTrailerLines(const Value: Integer);
    function GetHeaderText: WideString;
    function GetTrailerText: WideString;
    procedure SetAmountDecimalPlaces(const Value: Integer);
    procedure SetBaudRate(const Value: Integer);
    function GetTranslation: TTranslation;
    function GetTranslationRus: TTranslation;
  public
    PortName: string;
    DataBits: Integer;
    StopBits: Integer;
    Parity: Integer;
    FlowControl: Integer;
    SerialTimeout: Integer;
    ReconnectPort: Boolean;
    PrintBarcode: Integer;
    RecLineChars: Integer;
    RecLineHeight: Integer;
    HeaderPrinted: Boolean;

    constructor Create(ALogger: ILogFile);
    destructor Destroy; override;

    procedure SetDefaults;
    procedure CheckPrameters;
    procedure WriteLogParameters;
    function SerialPortNames: string;
    procedure Load(const DeviceName: WideString);
    procedure Save(const DeviceName: WideString);
    procedure Assign(Source: TPersistent); override;
    function BaudRateIndex(const Value: Integer): Integer;
    function GetTranslationText(const Text: WideString): WideString;
    function ItemByText(const ParamName: WideString): WideString;
    function GetTemplateXml: WideString;
    procedure SetTemplateXml(const Value: WideString);

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
    property FontName: WideString read FFontName write FFontName;
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
    property RemoteHost: string read FRemoteHost write FRemoteHost;
    property RemotePort: Integer read FRemotePort write FRemotePort;
    property ByteTimeout: Integer read FByteTimeout write FByteTimeout;
    property BaudRate: Integer read FBaudRate write SetBaudRate;
    property DevicePollTime: Integer read FDevicePollTime write FDevicePollTime;
    property Translations: TTranslations read FTranslations;
    property TranslationName: WideString read FTranslationName write FTranslationName;
    property Translation: TTranslation read GetTranslation;
    property TranslationRus: TTranslation read GetTranslationRus;
    property TranslationEnabled: Boolean read FTranslationEnabled write FTranslationEnabled;
    property TemplateEnabled: Boolean read FTemplateEnabled write FTemplateEnabled;
    property Template: TReceiptTemplate read FTemplate;
    property CurrencyName: string read FCurrencyName write FCurrencyName;
    property LineSpacing: Integer read FLineSpacing write FLineSpacing;
    property PrintEnabled: Boolean read FPrintEnabled write FPrintEnabled;
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
  FTranslations := TTranslations.Create;
  FTemplate := TReceiptTemplate.Create(ALogger);

  SetDefaults;
  Translations.Load;
end;

destructor TPrinterParameters.Destroy;
begin
  FHeader.Free;
  FTrailer.Free;
  FVatRates.Free;
  FTemplate.Free;
  FTranslations.Free;
  inherited Destroy;
end;

function TPrinterParameters.GetTemplateXml: WideString;
begin
  Result := Template.AsXML;
end;

procedure TPrinterParameters.SetTemplateXml(const Value: WideString);
begin
  Template.AsXML := Value;
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
  FontName := DefFontName;
  RoundType := DefRoundType;
  VATNumber := DefVATNumber;
  VATSeries := DefVATSeries;
  AmountDecimalPlaces := DefAmountDecimalPlaces;
  // VatRates
  VatRates.Clear;
  VatRates.Add(1, 12, 'НДС 12%'); // НДС 12%

  FRemoteHost := DefRemoteHost;
  FRemotePort := DefRemotePort;
  FByteTimeout := DefByteTimeout;
  PortName := DefPortName;
  BaudRate := DefBaudRate;
  DataBits := DefDataBits;
  StopBits := DefStopBits;
  Parity := DefParity;
  FlowControl := DefFlowControl;
  ReconnectPort := DefReconnectPort;
  SerialTimeout := DefSerialTimeout;
  DevicePollTime := DefDevicePollTime;
  PrintBarcode := DefPrintBarcode;
  TranslationName := DefTranslationName;
  TranslationEnabled := DefTranslationEnabled;
  TemplateEnabled := DefTemplateEnabled;
  Template.SetDefaults;
  CurrencyName := DefCurrencyName;
  LineSpacing := DefLineSpacing;
  PrintEnabled := DefPrintEnabled;
  RecLineChars := DefRecLineChars;
  RecLineHeight := DefRecLineHeight;
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

  Logger.Debug('RemoteHost: ' + RemoteHost);
  Logger.Debug('RemotePort: ' + IntToStr(RemotePort));
  Logger.Debug('ByteTimeout: ' + IntToStr(ByteTimeout));
  Logger.Debug('DevicePollTime: ' + IntToStr(DevicePollTime));
  Logger.Debug('PrintBarcode: ' + IntToStr(PrintBarcode));
  Logger.Debug('TemplateEnabled: ' + BoolToStr(TemplateEnabled));
  Logger.Debug('CurrencyName: ' + CurrencyName);
  Logger.Debug('LineSpacing: ' + IntToStr(LineSpacing));
  Logger.Debug('PrintEnabled: ' + BoolToStr(PrintEnabled));
  Logger.Debug('RecLineChars: ' + IntToStr(RecLineChars));
  Logger.Debug('RecLineHeight: ' + IntToStr(RecLineHeight));

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
  Text: WideString;
begin
  if Value = NumHeaderLines then Exit;

  if Value in [MinHeaderLines..MaxHeaderLines] then
  begin
    Text := HeaderText;
    FNumHeaderLines := Value;

    FHeader.Clear;
    for i := 0 to Value-1 do
    begin
      FHeader.Add('');
    end;
    SetHeaderText(Text);
  end;
end;

procedure TPrinterParameters.SetNumTrailerLines(const Value: Integer);
var
  i: Integer;
  Text: WideString;
begin
  if Value = NumTrailerLines then Exit;

  if Value in [MinTrailerLines..MaxTrailerLines] then
  begin
    Text := TrailerText;
    FNumTrailerLines := Value;

    FTrailer.Clear;
    for i := 0 to Value-1 do
      FTrailer.Add('');
    SetTrailerText(Text);
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

function TPrinterParameters.BaudRateIndex(const Value: Integer): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := Low(ValidBaudRates) to High(ValidBaudRates) do
  begin
    if ValidBaudRates[i] = Value then
    begin
      Result := i;
      Break;
    end;
  end;
end;

procedure TPrinterParameters.SetBaudRate(const Value: Integer);
begin
  if BaudRateIndex(Value) = -1 then
    raise Exception.CreateFmt('Invalid baudrate value, %d', [Value]);

  FBaudRate := Value;
end;

function TPrinterParameters.SerialPortNames: string;
begin
  Result := TSerialPorts.GetPortNames;
end;

procedure TPrinterParameters.Assign(Source: TPersistent);
var
  Src: TPrinterParameters;
begin
  if Source is TPrinterParameters then
  begin
    Src := Source as TPrinterParameters;
    Header.Assign(Src.Header);
    Trailer.Assign(Src.Trailer);
    LogMaxCount := Src.LogMaxCount;
    LogFileEnabled := Src.LogFileEnabled;
    LogFilePath := Src.LogFilePath;
    NumHeaderLines := Src.NumHeaderLines;
    NumTrailerLines := Src.NumTrailerLines;
    WebkassaAddress := Src.WebkassaAddress;
    ConnectTimeout := Src.ConnectTimeout;
    Login := Src.Login;
    Password := Src.Password;
    CashboxNumber := Src.CashboxNumber;
    PrinterName := Src.PrinterName;
    PrinterType := Src.PrinterType;
    FontName := Src.FontName;
    VatRateEnabled := Src.VatRateEnabled;
    PaymentType2 := Src.PaymentType2;
    PaymentType3 := Src.PaymentType3;
    PaymentType4 := Src.PaymentType4;
    RoundType := Src.RoundType;
    VATNumber := Src.VATNumber;
    VATSeries := Src.VATSeries;
    AmountDecimalPlaces := Src.AmountDecimalPlaces;
    RemoteHost := Src.RemoteHost;
    RemotePort := Src.RemotePort;
    ByteTimeout := Src.ByteTimeout;
    BaudRate := Src.BaudRate;
    PortName := Src.PortName;
    DataBits := Src.DataBits;
    StopBits := Src.StopBits;
    Parity := Src.Parity;
    FlowControl := Src.FlowControl;
    SerialTimeout := Src.SerialTimeout;
    ReconnectPort := Src.ReconnectPort;
    VatRates.Assign(VatRates);
    DevicePollTime := Src.DevicePollTime;
    TemplateEnabled := Src.TemplateEnabled;
    CurrencyName := Src.CurrencyName;
    PrintEnabled := Src.PrintEnabled;
    RecLineChars := Src.RecLineChars;
    RecLineHeight := Src.RecLineHeight;
  end else
    inherited Assign(Source);
end;

function TPrinterParameters.GetTranslationText(
  const Text: WideString): WideString;
var
  Index: Integer;
begin
  Result := Text;
  if not TranslationEnabled then Exit;

  if GetTranslation = nil then Exit;
  if GetTranslationRus = nil then Exit;
  Index := GetTranslationRus.Items.IndexOf(Text);
  if Index <> -1 then
    Result := GetTranslation.Items[Index];
end;

function TPrinterParameters.GetTranslationRus: TTranslation;
begin
  if FTranslationRus = nil then
  begin
    FTranslationRus := Translations.Find(TranslationNameRus);
    if FTranslationRus = nil then
    begin
      FTranslationRus := Translations.Add(TranslationNameRus);
    end;
  end;
  Result := FTranslationRus;
end;

function TPrinterParameters.GetTranslation: TTranslation;
begin
  if FTranslation = nil then
  begin
    FTranslation := Translations.Find(FTranslationName);
    if FTranslation = nil then
    begin
      FTranslation := Translations.Add(FTranslationName);
    end;
  end;
  Result := FTranslation;
end;

procedure TPrinterParameters.Load(const DeviceName: WideString);
var
  FileName: WideString;
begin
  FileName := GetModulePath + 'Params\' + DeviceName + '\Receipt.xml';
  if FileExists(FileName) then
  begin
    FTemplate.LoadFromFile(FileName);
  end;
end;

procedure TPrinterParameters.Save(const DeviceName: WideString);
var
  Path: WideString;
begin
  Path := GetModulePath + 'Params';
  if not DirectoryExists(Path) then CreateDir(Path);
  Path := Path + '\' + DeviceName;
  if not DirectoryExists(Path) then CreateDir(Path);
  FTemplate.SaveToFile(Path + '\Receipt.xml');
end;

function TPrinterParameters.ItemByText(const ParamName: WideString): WideString;
begin
  if AnsiCompareText(ParamName, 'VATSeries')=0 then
  begin
    Result := VATSeries;
    Exit;
  end;
  if AnsiCompareText(ParamName, 'VATNumber')=0 then
  begin
    Result := VATNumber;
    Exit;
  end;
  if AnsiCompareText(ParamName, 'CurrencyName')=0 then
  begin
    Result := CurrencyName;
    Exit;
  end;
end;

end.

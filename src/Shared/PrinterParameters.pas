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
  UserError, LogFile, FileUtils, VatRate, SerialPort, SerialPorts, ReceiptItem,
  Translation, ReceiptTemplate, WebkassaClient, PrinterTypes;

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

  /////////////////////////////////////////////////////////////////////////////
  // PrinterType constants

  PrinterTypeOPOS = 0; // OPOS driver
  PrinterTypeWindows = 1; // Windows printer
  PrinterTypeEscCommands = 2; // ESC printer

  /////////////////////////////////////////////////////////////////////////////
  // PortType constants

  PortTypeSerial = 0;
  PortTypeWindows  = 1;
  PortTypeNetwork = 2;
  PortTypeUSB = 3;

  /////////////////////////////////////////////////////////////////////////////
  // ESC printer command set

  EscPrinterTypeRongta    = 0;
  EscPrinterTypeOA48      = 1;
  EscPrinterTypePosiflex  = 2;
  EscPrinterTypeXPrinter  = 3;


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
  DefEscPrinterType = EscPrinterTypeRongta;
  DefFontName = '';
  DefRoundType = RoundTypeNone; // ���������� �������
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
  DefCurrencyName = '��';
  DefOfflineText = '���������� �����';
  DefLineSpacing = 0;
  DefPrintEnabled = True;
  DefRecLineChars = 48;
  DefRecLineHeight = 24;
  DefHeaderPrinted = false;
  DefUtf8Enabled = True;
  DefPortType = PortTypeSerial;

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
  { TUnitNameRec }

  TUnitNameRec = record
    AppName: WideString;
    SrvName: WideString;
    SrvCode: Integer;
  end;

  { TUnitName }

  TUnitName = class(TCollectionItem)
  private
    FData: TUnitNameRec;
  public
    property AppName: WideString read FData.AppName;
    property SrvName: WideString read FData.SrvName;
    property SrvCode: Integer read FData.SrvCode;
  end;

  { TUnitNames }

  TUnitNames = class(TCollection)
  private
    function GetItem(Index: Integer): TUnitName;
  public
    constructor Create;
    function ItemByAppName(const AppName: string): TUnitName;
    property Items[Index: Integer]: TUnitName read GetItem; default;
  end;

  { TWideStringArray }

  TWideStringArray = array of WideString;

  { TPrinterParameters }

  TPrinterParameters = class(TPersistent)
  private
    FLogger: ILogFile;
    FHeader: TWideStringArray;
    FTrailer: TWideStringArray;
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
    FEscPrinterType: Integer;
    FFontName: WideString;
    FVatRates: TVatRates;
    FUnitNames: TUnitNames;
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
    FCurrencyName: WideString;
    FOfflineText: WideString;
    FLineSpacing: Integer;
    FPrintEnabled: Boolean;
    FUnits: TUnitItems;

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
    function GetTemplateFileName(const DeviceName: WideString): WideString;
  public
    PortType: Integer;
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
    Utf8Enabled: Boolean;
    ShiftNumber: Integer;
    CheckNumber: WideString;
    SumInCashbox: Currency;
    GrossTotal: Currency;
    DailyTotal: Currency;
    SellTotal: Currency;
    RefundTotal: Currency;
    ReplaceDataMatrixWithQRCode: Boolean;
    AcceptLanguage: string;
    USBPort: string;
    TopLogoFile: string;
    BottomLogoFile: string;
    BitmapFiles: TBitmapFiles;

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
    procedure SetHeaderLine(LineNumber: Integer; const Text: WideString);
    procedure SetTrailerLine(LineNumber: Integer; const Text: WideString);
    procedure AddUnitName(const AppName, SrvName: string; SrvCode: Integer);

    property Units: TUnitItems read FUnits;
    property Logger: ILogFile read FLogger;
    property Header: TWideStringArray read FHeader;
    property Trailer: TWideStringArray read FTrailer;
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
    property EscPrinterType: Integer read FEscPrinterType write FEscPrinterType;
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
    property CurrencyName: WideString read FCurrencyName write FCurrencyName;
    property OfflineText: WideString read FOfflineText write FOfflineText;
    property LineSpacing: Integer read FLineSpacing write FLineSpacing;
    property PrintEnabled: Boolean read FPrintEnabled write FPrintEnabled;
    property UnitNames: TUnitNames read FUnitNames;
  end;

function QRSizeToWidth(QRSize: Integer): Integer;

implementation

function ArrayToText(A: array of WideString): WideString;
var
  i: Integer;
  Lines: TTntStrings;
begin
  Lines := TTntStringList.Create;
  try
    for i := Low(A) to High(A) do
      Lines.Add(A[i]);
    Result := Lines.Text;
  finally
    Lines.Free;
  end;
end;

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
  FUnitNames := TUnitNames.Create;

  FTranslations := TTranslations.Create;
  FTemplate := TReceiptTemplate.Create(ALogger);
  FUnits := TUnitItems.Create(TUnitItem);

  SetDefaults;
  Translations.Load;
end;

destructor TPrinterParameters.Destroy;
begin
  FUnits.Free;
  FVatRates.Free;
  FUnitNames.Free;
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
var
  VatRate: TVatRateRec;
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
  EscPrinterType := DefEscPrinterType;
  FontName := DefFontName;
  RoundType := DefRoundType;
  VATNumber := DefVATNumber;
  VATSeries := DefVATSeries;
  AmountDecimalPlaces := DefAmountDecimalPlaces;
  // VatRates
  VatRates.Clear;
  VatRate.ID := 1;
  VatRate.Rate := 12;
  VatRate.Name := '��� 12%';
  VatRate.VatType := VAT_TYPE_NORMAL;
  VatRates.Add(VatRate);

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
  OfflineText := DefOfflineText;
  Utf8Enabled := DefUtf8Enabled;
  SumInCashbox := 0;
  GrossTotal := 0;
  DailyTotal := 0;
  SellTotal := 0;
  RefundTotal := 0;
  Units.Clear;
  ReplaceDataMatrixWithQRCode := False;
  AcceptLanguage := 'kk-KZ';
  UnitNames.Clear;
  PortType := DefPortType;
  USBPort := '';
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
      Logger.Debug(WideFormat('%s: ''%s''', [Caption, Lines[0]]));
    end else
    begin
      for i := 0 to Lines.Count-1 do
      begin
        Logger.Debug(WideFormat('%s.%d: ''%s''', [Caption, i, Lines[i]]));
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
  Logger.Debug('EscPrinterType: ' + IntToStr(EscPrinterType));
  Logger.Debug('PortType: ' + IntToStr(PortType));
  Logger.Debug('USBPort: ' + USBPort);
  Logger.Debug('PortName: ' + PortName);
  Logger.Debug('DataBits: ' + IntToStr(DataBits));
  Logger.Debug('StopBits: ' + IntToStr(StopBits));
  Logger.Debug('Parity: ' + IntToStr(Parity));
  Logger.Debug('FlowControl: ' + IntToStr(FlowControl));
  Logger.Debug('SerialTimeout: ' + IntToStr(SerialTimeout));
  Logger.Debug('ReconnectPort: ' + BoolToStr(ReconnectPort));
  Logger.Debug('PrintBarcode: ' + IntToStr(PrintBarcode));
  Logger.Debug('CashboxNumber: ' + CashboxNumber);
  Logger.Debug('NumHeaderLines: ' + IntToStr(NumHeaderLines));
  Logger.Debug('NumTrailerLines: ' + IntToStr(NumTrailerLines));
  LogText('Header', HeaderText);
  LogText('Trailer', TrailerText);
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
  Logger.Debug('TemplateEnabled: ' + BoolToStr(TemplateEnabled));
  Logger.Debug('CurrencyName: ' + CurrencyName);
  Logger.Debug('OfflineText: ' + OfflineText);
  Logger.Debug('LineSpacing: ' + IntToStr(LineSpacing));
  Logger.Debug('PrintEnabled: ' + BoolToStr(PrintEnabled));
  Logger.Debug('RecLineChars: ' + IntToStr(RecLineChars));
  Logger.Debug('RecLineHeight: ' + IntToStr(RecLineHeight));
  Logger.Debug('Utf8Enabled: ' + BoolToStr(Utf8Enabled));
  Logger.Debug('ReplaceDataMatrixWithQRCode: ' + BoolToStr(ReplaceDataMatrixWithQRCode));
  Logger.Debug('AcceptLanguage: ' + AcceptLanguage);

  // VatRates
  for i := 0 to VatRates.Count-1 do
  begin
    VatRate := VatRates[i];
    Logger.Debug(WideFormat('VAT: ID=%d, rate=%.2f, name="%s"', [
      VatRate.ID, VatRate.Rate, VatRate.Name]));
  end;
  Logger.Debug(Logger.Separator);
end;

procedure TPrinterParameters.SetHeaderLine(LineNumber: Integer;
  const Text: WideString);
begin
  if (LineNumber <= 0)or(LineNumber > NumHeaderLines) then
    raiseIllegalError('Invalid line number');
  FHeader[LineNumber-1] := Text;
end;

procedure TPrinterParameters.SetTrailerLine(LineNumber: Integer;
  const Text: WideString);
begin
  if (LineNumber <= 0)or(LineNumber > NumTrailerLines) then
    raiseIllegalError('Invalid line number');
  FTrailer[LineNumber-1] := Text;
end;

procedure TPrinterParameters.SetNumHeaderLines(const Value: Integer);
begin
  if Value <> NumHeaderLines then
  begin
    if Value in [MinHeaderLines..MaxHeaderLines] then
    begin
      FNumHeaderLines := Value;
      SetLength(FHeader, Value);
    end;
  end;
end;

procedure TPrinterParameters.SetNumTrailerLines(const Value: Integer);
begin
  if Value <> NumTrailerLines then
  begin
    if Value in [MinTrailerLines..MaxTrailerLines] then
    begin
      FNumTrailerLines := Value;
      SetLength(FTrailer, Value);
    end;
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
  Result := ArrayToText(FHeader);
end;

function TPrinterParameters.GetTrailerText: WideString;
begin
  Result := ArrayToText(FTrailer);
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
    raise UserException.CreateFmt('Invalid baudrate value, %d', [Value]);

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
    FHeader := Src.FHeader;
    FTrailer := Src.FTrailer;
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
    EscPrinterType := Src.EscPrinterType;
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
    PortType := Src.PortType;
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
    OfflineText := Src.OfflineText;
    PrintEnabled := Src.PrintEnabled;
    RecLineChars := Src.RecLineChars;
    RecLineHeight := Src.RecLineHeight;
    Utf8Enabled := Src.Utf8Enabled;
    ReplaceDataMatrixWithQRCode := Src.ReplaceDataMatrixWithQRCode;
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
begin
  FTemplate.LoadFromFile(GetTemplateFileName(DeviceName));
end;

function TPrinterParameters.GetTemplateFileName(const DeviceName: WideString): WideString;
begin
  Result := GetModulePath + 'Params\' + DeviceName + '\Receipt.xml';
end;

procedure TPrinterParameters.Save(const DeviceName: WideString);
var
  Path: WideString;
begin
  Path := GetModulePath + 'Params';
  if not DirectoryExists(Path) then CreateDir(Path);
  Path := Path + '\' + DeviceName;
  if not DirectoryExists(Path) then CreateDir(Path);

  FTemplate.SaveToFile(GetTemplateFileName(DeviceName));
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

procedure TPrinterParameters.AddUnitName(const AppName, SrvName: string;
  SrvCode: Integer);
var
  Item: TUnitName;
  Data: TUnitNameRec;
begin
  if AppName = '' then
    raise UserException.Create('�������� ������� ���������� �� ����� ���� ������');

  if FUnitNames.
  ItemByAppName(AppName) <> nil then
    raise UserException.CreateFmt('������������ ��� ������� "%s" ��� ������', [AppName]);

  Data.AppName := AppName;
  Data.SrvName := SrvName;
  Data.SrvCode := SrvCode;
  Item := TUnitName.Create(FUnitNames);
  Item.FData := Data;
end;

{ TUnitNames }

constructor TUnitNames.Create;
begin
  inherited Create(TUnitName);
end;

function TUnitNames.GetItem(Index: Integer): TUnitName;
begin
  Result := inherited Items[Index] as TUnitName;
end;

function TUnitNames.ItemByAppName(const AppName: string): TUnitName;
var
  i: Integer;
begin
  for i := 0 to Count-1 do
  begin
    Result := Items[i];
    if Result.AppName = AppName then Exit;
  end;
  Result := nil;
end;

end.

unit RecPrinter;

interface

uses
  // VCL
  Windows, Classes, SysUtils, ComObj, ActiveX, Printers,
  // Tnt
  TntClasses, TntSysUtils,
  // Opos
  Opos, OposPtr, Oposhi, OposException, OposEsc, OposUtils, OposDevice,
  OposPOSPrinter_CCO_TLB,
  // This
  PosWinPrinter, PosEscPrinter, LogFile, PrinterParameters,
  SerialPort, SocketPort, RawPrinterPort, FiscalPrinterDevice;


type
  { TRecPrinter }

  TRecPrinter = class
  private
    FLines: TTntStrings;
    FPrinterObj: TObject;
    FPrinter: IOPOSPOSPrinter;
    FDevice: TFiscalPrinterDevice;

    function GetLogger: ILogFile;
    function GetParams: TPrinterParameters;
    procedure Check(AResultCode: Integer);
    procedure AddProp(const PropName: WideString; PropVal: Variant;
      PropText: WideString = '');
    procedure AddProps;

    property Logger: ILogFile read GetLogger;
    property Printer: IOPOSPOSPrinter read FPrinter;
    property Params: TPrinterParameters read GetParams;
  public
    constructor Create(ADevice: TFiscalPrinterDevice);
    destructor Destroy; override;

    function GetFontNames: WideString;
    function TestConnection: WideString;
    function PrintTestReceipt: WideString;
    function PrintTestReceipt2: WideString;
    function ReadDeviceList: WideString; virtual; abstract;
  end;

  { TWinPrinter }

  TWinPrinter = class(TRecPrinter)
  public
    constructor Create(ADevice: TFiscalPrinterDevice);
    function ReadDeviceList: WideString; override;
  end;

  { TOposPrinter }

  TOposPrinter = class(TRecPrinter)
  public
    constructor Create(ADevice: TFiscalPrinterDevice);
    function ReadDeviceList: WideString; override;
  end;

  { TSerialEscPrinter }

  TSerialEscPrinter = class(TRecPrinter)
  private
    function CreateSerialPort: TSerialPort;
  public
    constructor Create(ADevice: TFiscalPrinterDevice);
    function ReadDeviceList: WideString; override;
  end;

  { TNetworkEscPrinter }

  TNetworkEscPrinter = class(TRecPrinter)
  private
    function CreateSocketPort: TSocketPort;
  public
    constructor Create(ADevice: TFiscalPrinterDevice);
    function ReadDeviceList: WideString; override;
  end;

  { TWindowsEscPrinter }

  TWindowsEscPrinter = class(TRecPrinter)
  private
    function CreatePort: TRawPrinterPort;
  public
    constructor Create(ADevice: TFiscalPrinterDevice);
    function ReadDeviceList: WideString; override;
  end;

implementation

const
  CashOutReceiptText: string =
    '                                          ' + CRLF +
    '   Âîñòî÷íî-Êàçàñòàíñêàÿ îáëàñòü, ãîðîä   ' + CRLF +
    '    Óñòü-Êàìåíîãîðñê, óë. Ãðåéäåðíàÿ, 1/10' + CRLF +
    '            ÒÎÎ PetroRetail               ' + CRLF +
    'ÁÈÍ                                       ' + CRLF +
    'ÇÍÌ  ÈÍÊ ÎÔÄ                              ' + CRLF +
    'ÈÇÚßÒÈÅ ÄÅÍÅÃ ÈÇ ÊÀÑÑÛ              =60.00' + CRLF +
    'ÍÀËÈ×ÍÛÕ Â ÊÀÑÑÅ                     =0.00' + CRLF +
    '           Callöåíòð 039458039850         ' + CRLF +
    '          Ãîðÿ÷àÿ ëèíèÿ 20948802934       ' + CRLF +
    '            ÑÏÀÑÈÁÎ ÇÀ ÏÎÊÓÏÊÓ            ' + CRLF +
    '                                          ';

{ TRecPrinter }

constructor TRecPrinter.Create(ADevice: TFiscalPrinterDevice);
begin
  inherited Create;
  FDevice := ADevice;
  FLines := TTntStringList.Create;
end;

destructor TRecPrinter.Destroy;
begin
  FLines.Free;
  inherited Destroy;
end;

procedure TRecPrinter.Check(AResultCode: Integer);
begin
  if AResultCode <> OPOS_SUCCESS then
  begin
    raise Exception.CreateFmt('%d, %s, %d, %s', [
      AResultCode, GetResultCodeText(AResultCode),
      Printer.ResultCodeExtended, Printer.ErrorString]);
  end;
end;

function TRecPrinter.TestConnection: WideString;
const
  BoolToStr: array [Boolean] of string = ('[ ]', '[X]');
begin
  FLines.Clear;
  Check(Printer.Open(Params.PrinterName));
  try
    Check(Printer.ClaimDevice(0));
    Printer.DeviceEnabled := True;
    Check(Printer.ResultCode);

    AddProps;
  finally
    Printer.Close;
  end;
  Result := FLines.Text;
end;

procedure TRecPrinter.AddProp(const PropName: WideString; PropVal: Variant;
  PropText: WideString);
var
  Line: WideString;
begin
  Line := Tnt_WideFormat('%-30s: %s', [PropName, PropVal]);
  if PropText <> '' then
    Line := Line + ', ' + PropText;
  FLines.Add(Line);
end;

procedure TRecPrinter.AddProps;
begin
  AddProp('ControlObjectDescription', Printer.ControlObjectDescription);
  AddProp('ControlObjectVersion', Printer.ControlObjectVersion);
  AddProp('ServiceObjectDescription', Printer.ServiceObjectDescription);
  AddProp('ServiceObjectVersion', Printer.ServiceObjectVersion);
  AddProp('DeviceDescription', Printer.DeviceDescription);
  AddProp('DeviceName', Printer.DeviceName);
  AddProp('CapConcurrentJrnRec', Printer.CapConcurrentJrnRec);
  AddProp('CapConcurrentJrnSlp', Printer.CapConcurrentJrnSlp);
  AddProp('CapConcurrentRecSlp', Printer.CapConcurrentRecSlp);
  AddProp('CapCoverSensor', Printer.CapCoverSensor);
  AddProp('CapJrn2Color', Printer.CapJrn2Color);
  AddProp('CapJrnBold', Printer.CapJrnBold);
  AddProp('CapJrnDhigh', Printer.CapJrnDhigh);
  AddProp('CapJrnDwide', Printer.CapJrnDwide);
  AddProp('CapJrnDwideDhigh', Printer.CapJrnDwideDhigh);
  AddProp('CapJrnEmptySensor', Printer.CapJrnEmptySensor);
  AddProp('CapJrnItalic', Printer.CapJrnItalic);
  AddProp('CapJrnNearEndSensor', Printer.CapJrnNearEndSensor);
  AddProp('CapJrnPresent', Printer.CapJrnPresent);
  AddProp('CapJrnUnderline', Printer.CapJrnUnderline);
  AddProp('CapRec2Color', Printer.CapRec2Color);
  AddProp('CapRecBarCode', Printer.CapRecBarCode);
  AddProp('CapRecBitmap', Printer.CapRecBitmap);
  AddProp('CapRecBold', Printer.CapRecBold);
  AddProp('CapRecDhigh', Printer.CapRecDhigh);
  AddProp('CapRecDwide', Printer.CapRecDwide);
  AddProp('CapRecDwideDhigh', Printer.CapRecDwideDhigh);
  AddProp('CapRecEmptySensor', Printer.CapRecEmptySensor);
  AddProp('CapRecItalic', Printer.CapRecItalic);
  AddProp('CapRecLeft90', Printer.CapRecLeft90);
  AddProp('CapRecNearEndSensor', Printer.CapRecNearEndSensor);
  AddProp('CapRecPapercut', Printer.CapRecPapercut);
  AddProp('CapRecPresent', Printer.CapRecPresent);
  AddProp('CapRecRight90', Printer.CapRecRight90);
  AddProp('CapRecRotate180', Printer.CapRecRotate180);
  AddProp('CapRecStamp', Printer.CapRecStamp);
  AddProp('CapRecUnderline', Printer.CapRecUnderline);
  AddProp('CapSlp2Color', Printer.CapSlp2Color);
  AddProp('CapSlpBarCode', Printer.CapSlpBarCode);
  AddProp('CapSlpBitmap', Printer.CapSlpBitmap);
  AddProp('CapSlpBold', Printer.CapSlpBold);
  AddProp('CapSlpDhigh', Printer.CapSlpDhigh);
  AddProp('CapSlpDwide', Printer.CapSlpDwide);
  AddProp('CapSlpDwideDhigh', Printer.CapSlpDwideDhigh);
  AddProp('CapSlpEmptySensor', Printer.CapSlpEmptySensor);
  AddProp('CapSlpFullslip', Printer.CapSlpFullslip);
  AddProp('CapSlpItalic', Printer.CapSlpItalic);
  AddProp('CapSlpLeft90', Printer.CapSlpLeft90);
  AddProp('CapSlpNearEndSensor', Printer.CapSlpNearEndSensor);
  AddProp('CapSlpPresent', Printer.CapSlpPresent);
  AddProp('CapSlpRight90', Printer.CapSlpRight90);
  AddProp('CapSlpRotate180', Printer.CapSlpRotate180);
  AddProp('CapSlpUnderline', Printer.CapSlpUnderline);

  AddProp('CharacterSetList', Printer.CharacterSetList);
  AddProp('CoverOpen', Printer.CoverOpen);
  AddProp('ErrorStation', Printer.ErrorStation);
  AddProp('JrnEmpty', Printer.JrnEmpty);
  AddProp('JrnLineCharsList', Printer.JrnLineCharsList);
  AddProp('JrnLineWidth', Printer.JrnLineWidth);
  AddProp('JrnNearEnd', Printer.JrnNearEnd);
  AddProp('RecEmpty', Printer.RecEmpty);
  AddProp('RecLineCharsList', Printer.RecLineCharsList);
  AddProp('RecLinesToPaperCut', Printer.RecLinesToPaperCut);
  AddProp('RecLineWidth', Printer.RecLineWidth);
  AddProp('RecNearEnd', Printer.RecNearEnd);
  AddProp('RecSidewaysMaxChars', Printer.RecSidewaysMaxChars);
  AddProp('RecSidewaysMaxLines', Printer.RecSidewaysMaxLines);
  AddProp('SlpEmpty', Printer.SlpEmpty);
  AddProp('SlpLineCharsList', Printer.SlpLineCharsList);
  AddProp('SlpLinesNearEndToEnd', Printer.SlpLinesNearEndToEnd);
  AddProp('SlpLineWidth', Printer.SlpLineWidth);
  AddProp('SlpMaxLines', Printer.SlpMaxLines);
  AddProp('SlpNearEnd', Printer.SlpNearEnd);
  AddProp('SlpSidewaysMaxChars', Printer.SlpSidewaysMaxChars);
  AddProp('SlpSidewaysMaxLines', Printer.SlpSidewaysMaxLines);
  AddProp('CapCharacterSet', Printer.CapCharacterSet);
  AddProp('CapTransaction', Printer.CapTransaction);
  AddProp('ErrorLevel', Printer.ErrorLevel);
  AddProp('ErrorString', Printer.ErrorString);
  AddProp('FontTypefaceList', Printer.FontTypefaceList);
  AddProp('RecBarCodeRotationList', Printer.RecBarCodeRotationList);
  AddProp('SlpBarCodeRotationList', Printer.SlpBarCodeRotationList);
  AddProp('CapPowerReporting', Printer.CapPowerReporting);
  AddProp('PowerState', Printer.PowerState);
  AddProp('CapJrnCartridgeSensor', Printer.CapJrnCartridgeSensor);
  AddProp('CapJrnColor', Printer.CapJrnColor);
  AddProp('CapRecCartridgeSensor', Printer.CapRecCartridgeSensor);
  AddProp('CapRecColor', Printer.CapRecColor);
  AddProp('CapRecMarkFeed', Printer.CapRecMarkFeed);
  AddProp('CapSlpBothSidesPrint', Printer.CapSlpBothSidesPrint);
  AddProp('CapSlpCartridgeSensor', Printer.CapSlpCartridgeSensor);
  AddProp('CapSlpColor', Printer.CapSlpColor);
  AddProp('JrnCartridgeState', Printer.JrnCartridgeState);
  AddProp('RecCartridgeState', Printer.RecCartridgeState);
  AddProp('SlpCartridgeState', Printer.SlpCartridgeState);
  AddProp('SlpPrintSide', Printer.SlpPrintSide);
  AddProp('CapMapCharacterSet', Printer.CapMapCharacterSet);
  AddProp('RecBitmapRotationList', Printer.RecBitmapRotationList);
  AddProp('SlpBitmapRotationList', Printer.SlpBitmapRotationList);
  AddProp('CapStatisticsReporting', Printer.CapStatisticsReporting);
  AddProp('CapUpdateStatistics', Printer.CapUpdateStatistics);
  AddProp('CapCompareFirmwareVersion', Printer.CapCompareFirmwareVersion);
  AddProp('CapUpdateFirmware', Printer.CapUpdateFirmware);
  AddProp('CapConcurrentPageMode', Printer.CapConcurrentPageMode);
  AddProp('CapRecPageMode', Printer.CapRecPageMode);
  AddProp('CapSlpPageMode', Printer.CapSlpPageMode);
  AddProp('PageModeArea', Printer.PageModeArea);
  AddProp('PageModeDescriptor', Printer.PageModeDescriptor);
  AddProp('CapRecRuledLine', Printer.CapRecRuledLine);
  AddProp('CapSlpRuledLine', Printer.CapSlpRuledLine);
  AddProp('FreezeEvents', Printer.FreezeEvents);
  AddProp('AsyncMode', Printer.AsyncMode);
  AddProp('CharacterSet', Printer.CharacterSet);
  AddProp('FlagWhenIdle', Printer.FlagWhenIdle);
  AddProp('JrnLetterQuality', Printer.JrnLetterQuality);
  AddProp('JrnLineChars', Printer.JrnLineChars);
  AddProp('JrnLineHeight', Printer.JrnLineHeight);

  AddProp('JrnLineSpacing', Printer.JrnLineSpacing);
  AddProp('MapMode', Printer.MapMode);
  AddProp('RecLetterQuality', Printer.RecLetterQuality);
  AddProp('RecLineChars', Printer.RecLineChars);
  AddProp('RecLineHeight', Printer.RecLineHeight);
  AddProp('RecLineSpacing', Printer.RecLineSpacing);
  AddProp('SlpLetterQuality', Printer.SlpLetterQuality);
  AddProp('SlpLineChars', Printer.SlpLineChars);
  AddProp('SlpLineHeight', Printer.SlpLineHeight);
  AddProp('SlpLineSpacing', Printer.SlpLineSpacing);
  AddProp('RotateSpecial', Printer.RotateSpecial);
  AddProp('BinaryConversion', Printer.BinaryConversion);
  AddProp('PowerNotify', Printer.PowerNotify);
  AddProp('CartridgeNotify', Printer.CartridgeNotify);
  AddProp('JrnCurrentCartridge', Printer.JrnCurrentCartridge);
  AddProp('RecCurrentCartridge', Printer.RecCurrentCartridge);
  AddProp('SlpCurrentCartridge', Printer.SlpCurrentCartridge);
  AddProp('MapCharacterSet', Printer.MapCharacterSet);
  AddProp('PageModeHorizontalPosition', Printer.PageModeHorizontalPosition);
  AddProp('PageModePrintArea', Printer.PageModePrintArea);
  AddProp('PageModePrintDirection', Printer.PageModePrintDirection);
  AddProp('PageModeStation', Printer.PageModeStation);
  AddProp('PageModeVerticalPosition', Printer.PageModeVerticalPosition);
  AddProp('CheckHealthText', Printer.CheckHealthText);
end;

function TRecPrinter.PrintTestReceipt2: WideString;
begin
  Check(Printer.Open(Params.PrinterName));
  try
    Check(Printer.ClaimDevice(0));
    Printer.DeviceEnabled := True;
    Check(Printer.ResultCode);
    Check(Printer.CheckHealth(OPOS_CH_EXTERNAL));
  finally
    Printer.Close;
  end;
end;

function TRecPrinter.PrintTestReceipt: WideString;

  procedure CheckPtr(AResultCode: Integer);
  begin
    if AResultCode <> OPOS_SUCCESS then
    begin
      raise EOPOSException.Create(Printer.ErrorString,
        Printer.ResultCode, Printer.ResultCodeExtended);
    end;
  end;

var
  i: Integer;
  Lines: TStrings;
begin
  Check(Printer.Open(Params.PrinterName));
  Lines := TStringList.Create;
  try
    Lines.Text := CashOutReceiptText;
    Check(Printer.ClaimDevice(0));
    Printer.DeviceEnabled := True;
    if Pos(Params.FontName, Printer.RecLineCharsList) <> 0 then
      Printer.RecLineChars := StrToInt(Params.FontName);

    if Printer.CapTransaction then
    begin
      CheckPtr(Printer.TransactionPrint(PTR_S_RECEIPT, PTR_TP_TRANSACTION));
    end;
    for i := 0 to Lines.Count-1 do
    begin
      CheckPtr(Printer.PrintNormal(PTR_S_RECEIPT, TrimRight(Lines[i]) + CRLF));
    end;
    for i := 0 to Printer.RecLinesToPaperCut do
    begin
      CheckPtr(Printer.PrintNormal(PTR_S_RECEIPT, CRLF));
    end;
    CheckPtr(Printer.CutPaper(90));
    if Printer.CapTransaction then
    begin
      CheckPtr(Printer.TransactionPrint(PTR_S_RECEIPT, PTR_TP_NORMAL));
    end;
  finally
    Lines.Free;
    Printer.Close;
  end;
end;

function TRecPrinter.GetFontNames: WideString;
var
  Lines: TTntStrings;
begin
  Lines := TTntStringList.Create;
  Check(Printer.Open(Params.PrinterName));
  try
    Lines.Text := StringReplace(Printer.FontTypefaceList, ',', CRLF, [
      rfReplaceAll, rfIgnoreCase]);
    Result := Lines.Text;
  finally
    Lines.Free;
    Printer.Close;
  end;
end;

function TRecPrinter.GetLogger: ILogFile;
begin
  Result := FDevice.Logger;
end;

function TRecPrinter.GetParams: TPrinterParameters;
begin
  Result := FDevice.Parameters;
end;

{ TWinPrinter }

constructor TWinPrinter.Create(ADevice: TFiscalPrinterDevice);
var
  PosWinPrinter: TPosWinPrinter;
begin
  inherited Create(ADevice);
  PosWinPrinter := TPosWinPrinter.Create2(nil, Logger);
  FPrinterObj := PosWinPrinter;
  FPrinter := PosWinPrinter;
end;

function TWinPrinter.ReadDeviceList: WideString;
begin
  Result := Printers.Printer.Printers.Text;
end;

{ TOposPrinter }

constructor TOposPrinter.Create(ADevice: TFiscalPrinterDevice);
begin
  inherited Create(ADevice);
  FPrinter := TOPOSPOSPrinter.Create(nil).ControlInterface;
  FPrinterObj := nil;
end;

function TOposPrinter.ReadDeviceList: WideString;
var
  Device: TOposDevice;
  Strings: TTntStrings;
begin
  Strings := TTntStringList.Create;
  Device := TOposDevice.Create(nil, OPOS_CLASSKEY_PTR, OPOS_CLASSKEY_PTR,
    'Opos.PosPrinter');
  try
    Device.GetDeviceNames(Strings);
    Result := Strings.Text;
  finally
    Device.Free;
    Strings.Free;
  end;
end;

{ TSerialEscPrinter }

constructor TSerialEscPrinter.Create(ADevice: TFiscalPrinterDevice);
var
  PosEscPrinter: TPosEscPrinter;
begin
  inherited Create(ADevice);
  PosEscPrinter := TPosEscPrinter.Create2(nil, CreateSerialPort, Logger);
  FPrinterObj := PosEscPrinter;
  FPrinter := PosEscPrinter;
end;

function TSerialEscPrinter.CreateSerialPort: TSerialPort;
var
  SerialParams: TSerialParams;
begin
  SerialParams.PortName := Params.PortName;
  SerialParams.BaudRate := Params.BaudRate;
  SerialParams.DataBits := Params.DataBits;
  SerialParams.StopBits := Params.StopBits;
  SerialParams.Parity := Params.Parity;
  SerialParams.FlowControl := Params.FlowControl;
  SerialParams.ReconnectPort := Params.ReconnectPort;
  SerialParams.ByteTimeout := Params.SerialTimeout;
  Result := TSerialPort.Create(SerialParams, Logger);
end;

function TSerialEscPrinter.ReadDeviceList: WideString;
begin
  Result := 'Serial ESC printer';
end;

{ TNetworkEscPrinter }

constructor TNetworkEscPrinter.Create(ADevice: TFiscalPrinterDevice);
var
  PosEscPrinter: TPosEscPrinter;
begin
  inherited Create(ADevice);
  PosEscPrinter := TPosEscPrinter.Create2(nil, CreateSocketPort, Logger);
  FPrinterObj := PosEscPrinter;
  FPrinter := PosEscPrinter;
end;

function TNetworkEscPrinter.CreateSocketPort: TSocketPort;
var
  SocketParams: TSocketParams;
begin
  SocketParams.RemoteHost := Params.RemoteHost;
  SocketParams.RemotePort := Params.RemotePort;
  SocketParams.ByteTimeout := Params.ByteTimeout;
  SocketParams.MaxRetryCount := 1;
  Result := TSocketPort.Create(SocketParams, Logger);
end;

function TNetworkEscPrinter.ReadDeviceList: WideString;
begin
  Result := 'Network ESC printer';
end;

{ TWindowsEscPrinter }

constructor TWindowsEscPrinter.Create(ADevice: TFiscalPrinterDevice);
var
  PosEscPrinter: TPosEscPrinter;
begin
  inherited Create(ADevice);
  PosEscPrinter := TPosEscPrinter.Create2(nil, CreatePort, Logger);
  FPrinterObj := PosEscPrinter;
  FPrinter := PosEscPrinter;
end;

function TWindowsEscPrinter.CreatePort: TRawPrinterPort;
begin
  Result := TRawPrinterPort.Create(Logger, Params.PrinterName);
end;

function TWindowsEscPrinter.ReadDeviceList: WideString;
begin
  Result := Printers.Printer.Printers.Text;
end;

end.

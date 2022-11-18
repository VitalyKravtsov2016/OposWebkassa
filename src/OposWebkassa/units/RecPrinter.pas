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
  PosWinPrinter, PosEscPrinter, LogFile, PrinterParameters;

  
type
  { TRecPrinter }

  TRecPrinter = class
  private
    FLogger: ILogFile;
    FLines: TTntStrings;
    FPrinter: IOPOSPOSPrinter;
    FParams: TPrinterParameters;

    procedure Check(AResultCode: Integer);
    function GetPropVal(const PropertyName: WideString): WideString;
    procedure AddProp(const PropName: WideString; PropText: WideString = '');
    procedure AddProps;

    property Printer: IOPOSPOSPrinter read FPrinter;
  public
    constructor Create;
    destructor Destroy; override;

    function GetFontNames: WideString;
    function TestConnection: WideString;
    function PrintTestReceipt: WideString;
    function ReadDeviceList: WideString; virtual; abstract;
  end;

  { TWinPrinter }

  TWinPrinter = class(TRecPrinter)
  public
    constructor Create(AParams: TPrinterParameters);
    function ReadDeviceList: WideString; override;
  end;

  { TOposPrinter }

  TOposPrinter = class(TRecPrinter)
  public
    constructor Create(AParams: TPrinterParameters);
    function ReadDeviceList: WideString; override;
  end;

  { TSerialEscPrinter }

  TSerialEscPrinter = class(TRecPrinter)
  public
    constructor Create(AParams: TPrinterParameters);
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

constructor TRecPrinter.Create;
begin
  inherited Create;
  FLogger := TLogFile.Create;
  FLines := TTntStringList.Create;
end;

destructor TRecPrinter.Destroy;
begin
  FLines.Free;
  FLogger := nil;
  FPrinter := nil;
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
  Check(Printer.Open(FParams.PrinterName));
  try
    Check(Printer.ClaimDevice(0));
    Printer.DeviceEnabled := True;
    AddProps;
  finally
    Printer.Close;
  end;
  Result := FLines.Text;
end;

function TRecPrinter.GetPropVal(const PropertyName: WideString): WideString;
var
  Value: Variant;
  Intf: IDispatch;
  PName: PWideChar;
  PropID: Integer;
  DispParams: TDispParams;
begin
  Intf := Printer;
  PName := PWideChar(PropertyName);
  try
    OleCheck(Intf.GetIDsOfNames(GUID_NULL, @PName, 1, GetThreadLocale, @PropID));
    VarClear(Value);
    FillChar(DispParams, SizeOf(DispParams), 0);
    OleCheck(Intf.Invoke(PropID, GUID_NULL, 0, DISPATCH_PROPERTYGET,
      DispParams, @Value, nil, nil));

    Result := Value;
  except
    on E: Exception do Result := E.Message;
  end;
end;

procedure TRecPrinter.AddProp(const PropName: WideString; PropText: WideString);
var
  Line: WideString;
begin
  Line := GetPropVal(PropName);
  Line := Tnt_WideFormat('%-30s: %s', [PropName, Line]);
  if PropText <> '' then
    Line := Line + ', ' + PropText;
  FLines.Add(Line);
end;

procedure TRecPrinter.AddProps;
begin
  AddProp('ControlObjectDescription');
  AddProp('ControlObjectVersion');
  AddProp('ServiceObjectDescription');
  AddProp('ServiceObjectVersion');
  AddProp('DeviceDescription');
  AddProp('DeviceName');
  AddProp('CapConcurrentJrnRec');
  AddProp('CapConcurrentJrnSlp');
  AddProp('CapConcurrentRecSlp');
  AddProp('CapCoverSensor');
  AddProp('CapJrn2Color');
  AddProp('CapJrnBold');
  AddProp('CapJrnDhigh');
  AddProp('CapJrnDwide');
  AddProp('CapJrnDwideDhigh');
  AddProp('CapJrnEmptySensor');
  AddProp('CapJrnItalic');
  AddProp('CapJrnNearEndSensor');
  AddProp('CapJrnPresent');
  AddProp('CapJrnUnderline');
  AddProp('CapRec2Color');
  AddProp('CapRecBarCode');
  AddProp('CapRecBitmap');
  AddProp('CapRecBold');
  AddProp('CapRecDhigh');
  AddProp('CapRecDwide');
  AddProp('CapRecDwideDhigh');
  AddProp('CapRecEmptySensor');
  AddProp('CapRecItalic');
  AddProp('CapRecLeft90');
  AddProp('CapRecNearEndSensor');
  AddProp('CapRecPapercut');
  AddProp('CapRecPresent');
  AddProp('CapRecRight90');
  AddProp('CapRecRotate180');
  AddProp('CapRecStamp');
  AddProp('CapRecUnderline');
  AddProp('CapSlp2Color');
  AddProp('CapSlpBarCode');
  AddProp('CapSlpBitmap');
  AddProp('CapSlpBold');
  AddProp('CapSlpDhigh');
  AddProp('CapSlpDwide');
  AddProp('CapSlpDwideDhigh');
  AddProp('CapSlpEmptySensor');
  AddProp('CapSlpFullslip');
  AddProp('CapSlpItalic');
  AddProp('CapSlpLeft90');
  AddProp('CapSlpNearEndSensor');
  AddProp('CapSlpPresent');
  AddProp('CapSlpRight90');
  AddProp('CapSlpRotate180');
  AddProp('CapSlpUnderline');

  AddProp('CharacterSetList');
  AddProp('CoverOpen');
  AddProp('ErrorStation');
  AddProp('JrnEmpty');
  AddProp('JrnLineCharsList');
  AddProp('JrnLineWidth');
  AddProp('JrnNearEnd');
  AddProp('RecEmpty');
  AddProp('RecLineCharsList');
  AddProp('RecLinesToPaperCut');
  AddProp('RecLineWidth');
  AddProp('RecNearEnd');
  AddProp('RecSidewaysMaxChars');
  AddProp('RecSidewaysMaxLines');
  AddProp('SlpEmpty');
  AddProp('SlpLineCharsList');
  AddProp('SlpLinesNearEndToEnd');
  AddProp('SlpLineWidth');
  AddProp('SlpMaxLines');
  AddProp('SlpNearEnd');
  AddProp('SlpSidewaysMaxChars');
  AddProp('SlpSidewaysMaxLines');
  AddProp('CapCharacterSet');
  AddProp('CapTransaction');
  AddProp('ErrorLevel');
  AddProp('ErrorString');
  AddProp('FontTypefaceList');
  AddProp('RecBarCodeRotationList');
  AddProp('SlpBarCodeRotationList');
  AddProp('CapPowerReporting');
  AddProp('PowerState');
  AddProp('CapJrnCartridgeSensor');
  AddProp('CapJrnColor');
  AddProp('CapRecCartridgeSensor');
  AddProp('CapRecColor');
  AddProp('CapRecMarkFeed');
  AddProp('CapSlpBothSidesPrint');
  AddProp('CapSlpCartridgeSensor');
  AddProp('CapSlpColor');
  AddProp('JrnCartridgeState');
  AddProp('RecCartridgeState');
  AddProp('SlpCartridgeState');
  AddProp('SlpPrintSide');
  AddProp('CapMapCharacterSet');
  AddProp('RecBitmapRotationList');
  AddProp('SlpBitmapRotationList');
  AddProp('CapStatisticsReporting');
  AddProp('CapUpdateStatistics');
  AddProp('CapCompareFirmwareVersion');
  AddProp('CapUpdateFirmware');
  AddProp('CapConcurrentPageMode');
  AddProp('CapRecPageMode');
  AddProp('CapSlpPageMode');
  AddProp('PageModeArea');
  AddProp('PageModeDescriptor');
  AddProp('CapRecRuledLine');
  AddProp('CapSlpRuledLine');
  AddProp('FreezeEvents');
  AddProp('AsyncMode');
  AddProp('CharacterSet');
  AddProp('FlagWhenIdle');
  AddProp('JrnLetterQuality');
  AddProp('JrnLineChars');
  AddProp('JrnLineHeight');
  AddProp('JrnLineSpacing');
  AddProp('MapMode');
  AddProp('RecLetterQuality');
  AddProp('RecLineChars');
  AddProp('RecLineHeight');
  AddProp('RecLineSpacing');
  AddProp('SlpLetterQuality');
  AddProp('SlpLineChars');
  AddProp('SlpLineHeight');
  AddProp('SlpLineSpacing');
  AddProp('RotateSpecial');
  AddProp('BinaryConversion');
  AddProp('PowerNotify');
  AddProp('CartridgeNotify');
  AddProp('JrnCurrentCartridge');
  AddProp('RecCurrentCartridge');
  AddProp('SlpCurrentCartridge');
  AddProp('MapCharacterSet');
  AddProp('PageModeHorizontalPosition');
  AddProp('PageModePrintArea');
  AddProp('PageModePrintDirection');
  AddProp('PageModeStation');
  AddProp('PageModeVerticalPosition');
  AddProp('CheckHealthText');
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
  Check(Printer.Open(FParams.PrinterName));
  Lines := TStringList.Create;
  try
    Lines.Text := CashOutReceiptText;
    Check(Printer.ClaimDevice(0));
    Printer.DeviceEnabled := True;
    if Pos(FParams.FontName, Printer.RecLineCharsList) <> 0 then
      Printer.RecLineChars := StrToInt(FParams.FontName);

    if Printer.CapTransaction then
    begin
      CheckPtr(Printer.TransactionPrint(PTR_S_RECEIPT, PTR_TP_TRANSACTION));
    end;
    for i := 0 to Lines.Count-1 do
    begin
      CheckPtr(Printer.PrintNormal(PTR_S_RECEIPT, TrimRight(Lines[i]) + CRLF));
    end;
    CheckPtr(Printer.PrintNormal(PTR_S_RECEIPT, CRLF));
    CheckPtr(Printer.PrintNormal(PTR_S_RECEIPT, CRLF));
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
begin
  Check(Printer.Open(FParams.PrinterName));
  try
    Result := Printer.RecLineCharsList;
    Result := StringReplace(Result, ',', CRLF, [rfReplaceAll, rfIgnoreCase]);
  finally
    Printer.Close;
  end;
end;

{ TWinPrinter }

constructor TWinPrinter.Create(AParams: TPrinterParameters);
begin
  inherited Create;
  FParams := AParams;
  FPrinter := TPosWinPrinter.Create2(nil, FLogger);
end;

function TWinPrinter.ReadDeviceList: WideString;
begin
  Result := Printers.Printer.Printers.Text;
end;

{ TOposPrinter }

constructor TOposPrinter.Create(AParams: TPrinterParameters);
begin
  inherited Create;
  FParams := AParams;
  FPrinter := TOPOSPOSPrinter.Create(nil).ControlInterface;
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

constructor TSerialEscPrinter.Create(AParams: TPrinterParameters);
begin
  inherited Create;
  FParams := AParams;
  FPort := TSerialPort.Create(SerialParams);
  FPrinter := TPosEscPrinter.Create2(nil, FPort, FLogger);
end;

function TSerialEscPrinter.ReadDeviceList: WideString;
begin
  Result := 'Serial ESC printer';
end;

end.

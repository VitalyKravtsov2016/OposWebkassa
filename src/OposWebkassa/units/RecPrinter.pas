unit RecPrinter;

interface

uses
  // VCL
  Windows, Classes, SysUtils, ComObj, ActiveX,
  // Tnt
  TntClasses, TntSysUtils,
  // Opos
  Opos, Oposhi, OposUtils, OposDevice, OposPOSPrinter_CCO_TLB;

type
  { IRecPrinter }

  IRecPrinter = interface
    function TestConnection: WideString;
    function PrintTestReceipt: WideString;
    function ReadDeviceList: WideString;
    function GetDeviceName: WideString;
    procedure SetDeviceName(const Value: WideString);

    property DeviceName: WideString read GetDeviceName write SetDeviceName;
  end;

  { TPosPrinter }

  TPosPrinter = class(TInterfacedObject, IRecPrinter)
  private
    FLines: TTntStrings;
    FDeviceName: WideString;
    FPrinter: TOPOSPOSPrinter;

    procedure Check(AResultCode: Integer);
    function GetPrinter: TOPOSPOSPrinter;
    function GetPropVal(const PropertyName: WideString): WideString;
    procedure AddProp(const PropName: WideString; PropText: WideString = '');

    property Printer: TOPOSPOSPrinter read GetPrinter;
    function GetDeviceName: WideString;
    procedure SetDeviceName(const Value: WideString);
    procedure AddProps;
  public
    constructor Create;
    destructor Destroy; override;

    function TestConnection: WideString;
    function ReadDeviceList: WideString;
    function PrintTestReceipt: WideString;
    property DeviceName: WideString read GetDeviceName write SetDeviceName;
  end;

implementation

{ TPosPrinter }

constructor TPosPrinter.Create;
begin
  inherited Create;
  FLines := TTntStringList.Create;
end;

destructor TPosPrinter.Destroy;
begin
  FLines.Free;
  FPrinter.Free;
  inherited Destroy;
end;

procedure TPosPrinter.Check(AResultCode: Integer);
begin
  if AResultCode <> OPOS_SUCCESS then
  begin
    raise Exception.CreateFmt('%d, %s, %d, %s', [
      AResultCode, GetResultCodeText(AResultCode),
      Printer.ResultCodeExtended, Printer.ErrorString]);
  end;
end;

function TPosPrinter.GetPrinter: TOPOSPOSPrinter;
begin
  if FPrinter = nil then
    FPrinter := TOPOSPOSPrinter.Create(nil);
  Result := FPrinter;
end;

function TPosPrinter.GetDeviceName: WideString;
begin
  Result := FDeviceName;
end;

procedure TPosPrinter.SetDeviceName(const Value: WideString);
begin
  FDeviceName := Value;
end;


function TPosPrinter.ReadDeviceList: WideString;
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

function TPosPrinter.TestConnection: WideString;
const
  BoolToStr: array [Boolean] of string = ('[ ]', '[X]');
begin
  FLines.Clear;
  Check(Printer.Open(DeviceName));
  try
    Check(Printer.ClaimDevice(0));
    Printer.DeviceEnabled := True;
    AddProps;
  finally
    Printer.Close;
  end;
  Result := FLines.Text;
end;

function TPosPrinter.GetPropVal(const PropertyName: WideString): WideString;
var
  Value: Variant;
  Intf: IDispatch;
  PName: PWideChar;
  PropID: Integer;
  DispParams: TDispParams;
begin
  Intf := Printer.ControlInterface;
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

procedure TPosPrinter.AddProp(const PropName: WideString; PropText: WideString);
var
  Line: WideString;
begin
  Line := GetPropVal(PropName);
  Line := Tnt_WideFormat('%-30s: %s', [PropName, Line]);
  if PropText <> '' then
    Line := Line + ', ' + PropText;
  FLines.Add(Line);
end;

procedure TPosPrinter.AddProps;
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

function TPosPrinter.PrintTestReceipt: WideString;
begin
  Check(Printer.Open(DeviceName));
  try
    Check(Printer.ClaimDevice(0));
    Printer.DeviceEnabled := True;
    Check(Printer.CheckHealth(OPOS_CH_INTERACTIVE));
  finally
    Printer.Close;
  end;
end;

end.

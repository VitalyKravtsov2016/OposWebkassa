unit RecPrinter;

interface

uses
  // VCL
  Windows, Classes, SysUtils, ComObj, ActiveX, Printers,
  // Tnt
  TntClasses, TntSysUtils,
  // Opos
  Opos, OposPtr, Oposhi, OposException, OposEsc, OposUtils, OposDevice,
  OposPOSPrinter_CCO_TLB;

type
  { IRecPrinter }

  IRecPrinter = interface
    function TestConnection: WideString;
    function PrintTestReceipt: WideString;
    function ReadDeviceList: WideString;
    function GetDeviceName: WideString;
    function GetFontName: WideString;
    function GetFontNames: WideString;
    procedure SetDeviceName(const Value: WideString);
    procedure SetFontName(const Value: WideString);

    property FontName: WideString read GetFontName write SetFontName;
    property DeviceName: WideString read GetDeviceName write SetDeviceName;
  end;

  { TWinPrinter }

  TWinPrinter = class(TInterfacedObject, IRecPrinter)
  private
    FFontName: WideString;
    FDeviceName: WideString;
  public
    function TestConnection: WideString;
    function PrintTestReceipt: WideString;

    function ReadDeviceList: WideString;
    function GetFontNames: WideString;
    function GetFontName: WideString;
    procedure SetFontName(const Value: WideString);
    function GetDeviceName: WideString;
    procedure SetDeviceName(const Value: WideString);

    property FontName: WideString read GetFontName write SetFontName;
    property DeviceName: WideString read GetDeviceName write SetDeviceName;
  end;

  { TPosPrinter }

  TPosPrinter = class(TInterfacedObject, IRecPrinter)
  private
    FLines: TTntStrings;
    FFontName: WideString;
    FDeviceName: WideString;
    FPrinter: TOPOSPOSPrinter;

    procedure Check(AResultCode: Integer);
    function GetPrinter: TOPOSPOSPrinter;
    function GetPropVal(const PropertyName: WideString): WideString;
    procedure AddProp(const PropName: WideString; PropText: WideString = '');
    procedure AddProps;
    function GetFontName: WideString;
    function GetFontNames: WideString;
    procedure SetFontName(const Value: WideString);
    function GetDeviceName: WideString;
    procedure SetDeviceName(const Value: WideString);

    property Printer: TOPOSPOSPrinter read GetPrinter;
  public
    constructor Create;
    destructor Destroy; override;

    function TestConnection: WideString;
    function ReadDeviceList: WideString;
    function PrintTestReceipt: WideString;

    property FontName: WideString read GetFontName write SetFontName;
    property DeviceName: WideString read GetDeviceName write SetDeviceName;
  end;

implementation

const
  CashOutReceiptText: string =
    '                                          ' + CRLF +
    '   Восточно-Казастанская область, город   ' + CRLF +
    '    Усть-Каменогорск, ул. Грейдерная, 1/10' + CRLF +
    '            ТОО PetroRetail               ' + CRLF +
    'БИН                                       ' + CRLF +
    'ЗНМ  ИНК ОФД                              ' + CRLF +
    'ИЗЪЯТИЕ ДЕНЕГ ИЗ КАССЫ              =60.00' + CRLF +
    'НАЛИЧНЫХ В КАССЕ                     =0.00' + CRLF +
    '           Callцентр 039458039850         ' + CRLF +
    '          Горячая линия 20948802934       ' + CRLF +
    '            СПАСИБО ЗА ПОКУПКУ            ' + CRLF +
    '                                          ';

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
  Check(Printer.Open(DeviceName));
  Lines := TStringList.Create;
  try
    Lines.Text := CashOutReceiptText;
    Check(Printer.ClaimDevice(0));
    Printer.DeviceEnabled := True;
    if Pos(FontName, Printer.RecLineCharsList) <> 0 then
      Printer.RecLineChars := StrToInt(FontName);

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

function TPosPrinter.GetFontName: WideString;
begin
  Result := FFontName;
end;

procedure TPosPrinter.SetFontName(const Value: WideString);
begin
  FFontName := Value;
end;

function TPosPrinter.GetFontNames: WideString;
begin
  Check(Printer.Open(DeviceName));
  try
    Result := Printer.RecLineCharsList;
    Result := StringReplace(Result, ',', CRLF, [rfReplaceAll, rfIgnoreCase]);
  finally
    Printer.Close;
  end;
end;

{ TWinPrinter }

function TWinPrinter.ReadDeviceList: WideString;
begin
  Result := Printer.Printers.Text;
end;

function TWinPrinter.GetDeviceName: WideString;
begin
  Result := FDeviceName;
end;

procedure TWinPrinter.SetDeviceName(const Value: WideString);
begin
  FDeviceName := Value;
end;

function TWinPrinter.TestConnection: WideString;
var
  Lines: TStrings;
const
  OrientationText: array [TPrinterOrientation] of string = ('Портретная', 'Альбомная');
begin
  Lines := TStringList.Create;
  try
    Printer.PrinterIndex := Printer.Printers.IndexOf(DeviceName);
    Lines.Add(Format('Ширина страницы     : %d', [Printer.PageWidth]));
    Lines.Add(Format('Высота страницы     : %d', [Printer.PageHeight]));
    Lines.Add(Format('Ориентация страницы : %s', [OrientationText[Printer.Orientation]]));
    Lines.Add('Шрифты:');
    Lines.AddStrings(Printer.Fonts);
    Result := Lines.Text;
  finally
    Lines.Free;
  end;
end;

function TWinPrinter.PrintTestReceipt: WideString;
var
  i: Integer;
  Y: Integer;
  Lines: TStrings;
  Metrics: TTextMetric;
begin
  Printer.PrinterIndex := Printer.Printers.IndexOf(DeviceName);
  Printer.BeginDoc;
  Lines := TStringList.Create;
  try
    Lines.Text := CashOutReceiptText;
    Printer.Canvas.Font.Name := FontName;
    GetTextMetrics(Printer.Canvas.Handle, Metrics);

    Y := 0;
    for i := 0 to Lines.Count-1 do
    begin
      Printer.Canvas.TextOut(0, Y, Lines[i]);
      Inc(Y, Metrics.tmHeight);
    end;
  finally
    Lines.Free;
    Printer.EndDoc;
  end;
end;

function TWinPrinter.GetFontName: WideString;
begin
  Result := FFontName;
end;

procedure TWinPrinter.SetFontName(const Value: WideString);
begin
  FFontName := Value;
end;

function TWinPrinter.GetFontNames: WideString;
begin
  Printer.PrinterIndex := Printer.Printers.IndexOf(DeviceName);
  Result := Printer.Fonts.Text;
end;

end.

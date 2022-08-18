unit fmuPosPrinter;

interface

uses
  // VCL
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Spin, ActiveX, ComObj,
  // Tnt
  TntStdCtrls, TntSysUtils,
  // Opos
  Opos, OposPtr, Oposhi, OposUtils, OposDevice, OposPOSPrinter_CCO_TLB,
  // This
  untUtil, PrinterParameters, FptrTypes, FiscalPrinterDevice, FileUtils,
  WebkassaClient, JsonUtils;

type
  { TfmPosPrinter }

  TfmPosPrinter = class(TFptrPage)
    lblDeviceName: TTntLabel;
    cbDeviceName: TTntComboBox;
    memResult: TMemo;
    lblResultCode: TTntLabel;
    btnTestConnection: TButton;
    btnPrintReceipt: TButton;
    procedure btnTestConnectionClick(Sender: TObject);
    procedure btnPrintReceiptClick(Sender: TObject);
  private
    FPrinter: TOPOSPOSPrinter;
    procedure UpdateDeviceNames;
    function GetPrinter: TOPOSPOSPrinter;
    procedure Check(AResultCode: Integer);
    function GetPropVal(const PropertyName: WideString): WideString;
    procedure AddProp(const PropName: WideString; PropText: WideString = '');

    property Printer: TOPOSPOSPrinter read GetPrinter;
    procedure PrintReceiptText(Lines: TCollection);
  public
    destructor Destroy; override;

    procedure UpdatePage; override;
    procedure UpdateObject; override;
  end;

var
  fmPosPrinter: TfmPosPrinter;

implementation

{$R *.dfm}

{ TfmFptrConnection }

destructor TfmPosPrinter.Destroy;
begin
  FPrinter.Free;
  inherited Destroy;
end;

function TfmPosPrinter.GetPrinter: TOPOSPOSPrinter;
begin
  if FPrinter = nil then
    FPrinter := TOPOSPOSPrinter.Create(Self);
  Result := FPrinter;
end;


procedure TfmPosPrinter.UpdateDeviceNames;
var
  Device: TOposDevice;
begin
  Device := TOposDevice.Create(nil, OPOS_CLASSKEY_PTR, OPOS_CLASSKEY_PTR,
    'Opos.PosPrinter');
  try
    Device.GetDeviceNames(cbDeviceName.Items);
    if cbDeviceName.Items.Count > 0 then
      cbDeviceName.ItemIndex := 0;
  finally
    Device.Free;
  end;
end;

procedure TfmPosPrinter.Check(AResultCode: Integer);
begin
  if AResultCode <> OPOS_SUCCESS then
  begin
    raise Exception.CreateFmt('%d, %s, %d, %s', [
      AResultCode, GetResultCodeText(AResultCode),
      Printer.ResultCodeExtended, Printer.ErrorString]);
  end;
end;

procedure TfmPosPrinter.UpdatePage;
begin
  UpdateDeviceNames;
  cbDeviceName.Text := Parameters.PosPrinterDeviceName;
end;

procedure TfmPosPrinter.UpdateObject;
begin
  Parameters.PosPrinterDeviceName := cbDeviceName.Text;
end;

function TfmPosPrinter.GetPropVal(const PropertyName: WideString): WideString;
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

procedure TfmPosPrinter.AddProp(const PropName: WideString; PropText: WideString);
var
  Line: WideString;
begin
  Line := GetPropVal(PropName);
  Line := Tnt_WideFormat('%-30s: %s', [PropName, Line]);
  if PropText <> '' then
    Line := Line + ', ' + PropText;
  memResult.Lines.Add(Line);
end;

procedure TfmPosPrinter.btnTestConnectionClick(Sender: TObject);
const
  BoolToStr: array [Boolean] of string = ('[ ]', '[X]');
begin
  EnableButtons(False);
  memResult.Clear;
  try
    UpdateObject;

    Check(Printer.Open(Parameters.PosPrinterDeviceName));
    Check(Printer.ClaimDevice(0));
    Printer.DeviceEnabled := True;
    //Check(Printer.CheckHealth(OPOS_CH_INTERNAL));

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

    Printer.Close;
  except
    on E: Exception do
    begin
      memResult.Text := 'Ошибка: ' + E.Message;
    end;
  end;
  EnableButtons(True);
end;

procedure TfmPosPrinter.btnPrintReceiptClick(Sender: TObject);
var
  JsonText: WideString;
  Command: TReceiptTextCommand;
begin
  EnableButtons(False);
  memResult.Clear;

  Command := TReceiptTextCommand.Create;
  try
    JsonText := ReadFileData(GetModulePath + 'TestReceipt.json');
    JsonToObject(JsonText, Command);

    Check(Printer.Open(Parameters.PosPrinterDeviceName));
    Check(Printer.ClaimDevice(0));
    Printer.DeviceEnabled := True;

    PrintReceiptText(Command.Data.Lines);

    Printer.Close;
  except
    on E: Exception do
    begin
      memResult.Text := 'Ошибка: ' + E.Message;
    end;
  end;
  Command.Free;
  EnableButtons(True);
end;

procedure TfmPosPrinter.PrintReceiptText(Lines: TCollection);
var
  i: Integer;
  Text: WideString;
  CapRecBold: Boolean;
  RecLineChars: Integer;
  Item: TReceiptTextItem;
const
  ESC = #$1B;
  CRLF = #13#10;
begin
  CapRecBold := Printer.CapRecBold;
  RecLineChars := Printer.RecLineChars;
  if Printer.CapRecEmptySensor then
  begin
    if Printer.RecEmpty then
      raise Exception.Create('Нет бумаги');
  end;
  if Printer.CapTransaction then
  begin
    Check(Printer.TransactionPrint(PTR_S_RECEIPT, PTR_TP_TRANSACTION));
  end;
  for i := 0 to Lines.Count-1 do
  begin
    Item := LInes.Items[i] as TReceiptTextItem;
    if Item._Type = ItemTypeText then
    begin
      Text := Copy(Item.Value, 1, RecLineChars);
      if CapRecBold and (Item.Style = TextStyleBold) then
        Text := ESC + '|4C' + Text;
      Check(Printer.PrintNormal(PTR_S_RECEIPT, Text + CRLF));
    end;
    if Item._Type = ItemTypeQRCode then
    begin
      Printer.PrintBarCode(PTR_S_RECEIPT, Item.Value, PTR_BCS_DATAMATRIX, 200, 200,
        PTR_BC_CENTER, PTR_BC_TEXT_NONE);
    end;
  end;
  if Printer.CapRecPapercut then
  begin
    for i := 1 to Printer.RecLinesToPaperCut do
    begin
      Printer.PrintNormal(PTR_S_RECEIPT, CRLF);
    end;
    Printer.CutPaper(90);
  end;

  if Printer.CapTransaction then
  begin
    Check(Printer.TransactionPrint(PTR_S_RECEIPT, PTR_TP_NORMAL));
  end;
end;

end.

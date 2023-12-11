unit WebkassaImpl;

interface

uses
  // VCL
  Classes, SysUtils, Windows, DateUtils, ActiveX, ComObj, Math, Graphics,
  // Tnt
  TntSysUtils, TntClasses,
  // Opos
  Opos, OposPtr, OposPtrUtils, Oposhi, OposFptr, OposFptrHi, OposEvents,
  OposEventsRCS, OposException, OposFptrUtils, OposServiceDevice19,
  OposUtils, OposEsc, OposPOSPrinter_CCO_TLB, PosPrinterLog,
  // Json
  uLkJSON,
  // gnugettext
  gnugettext,
  // This
  OPOSWebkassaLib_TLB, LogFile, WException, VersionInfo, DriverError,
  WebkassaClient, FiscalPrinterState, CustomReceipt, NonFiscalDoc, ServiceVersion,
  PrinterParameters, PrinterParametersX, CashInReceipt, CashOutReceipt,
  SalesReceipt, TextDocument, ReceiptItem, StringUtils, DebugUtils, VatRate,
  uZintBarcode, uZintInterface, FileUtils, PosWinPrinter, PosEscPrinter,
  SerialPort, PrinterPort, SocketPort, ReceiptTemplate, RawPrinterPort,
  DIOHandler, PrinterTypes, DirectIOAPI, BarcodeUtils, PrinterParametersReg;

const
  FPTR_DEVICE_DESCRIPTION = 'WebKassa OPOS driver';

  // VatID values
  MinVatID = 1;
  MaxVatID = 6;

  // VatValue
  MinVatValue = 0;
  MaxVatValue = 9999;


type
  { TPaperStatus }

  TPaperStatus = record
    IsEmpty: Boolean;
    IsNearEnd: Boolean;
    Status: Integer;
  end;

  { TWebkassaImpl }

  TWebkassaImpl = class(TComponent, IFiscalPrinterService_1_12)
  private
    FLines: TTntStrings;
    FCheckNumber: WideString;
    FCashboxStatusJson: TlkJSON;
    FCashboxStatus: TlkJSONbase;
    FTestMode: Boolean;
    FLoadParamsEnabled: Boolean;
    FPOSID: WideString;
    FCashierID: WideString;
    FLogger: ILogFile;
    FUnits: TUnitItems;
    FCashBox: TCashBox;
    FCashier: TCashier;
    FCashiers: TCashiers;
    FCashBoxes: TCashBoxes;
    FClient: TWebkassaClient;
    FDocument: TTextDocument;
    FDuplicate: TTextDocument;
    FReceipt: TCustomReceipt;
    FPrinterObj: TObject;
    FPrinter: IOPOSPOSPrinter;
    FPrinterLog: TPOSPrinterLog;
    FParams: TPrinterParameters;
    FOposDevice: TOposServiceDevice19;
    FPrinterState: TFiscalPrinterState;
    FDIOHandlers: TDIOHandlers;
    FVatValues: array [MinVatID..MaxVatID] of Integer;
    FLineChars: Integer;
    FLineHeight: Integer;
    FLineSpacing: Integer;
    FPrefix: WideString;
    FCapRecBold: Boolean;
    FCapRecDwideDhigh: Boolean;
    FExternalCheckNumber: WideString;
    FCodePage: Integer;

    procedure PrintLine(Text: WideString);
    function GetReceiptItemText(ReceiptItem: TSalesReceiptItem;
      Item: TTemplateItem): WideString;
    function ReceiptItemByText(ReceiptItem: TSalesReceiptItem;
      Item: TTemplateItem): WideString;
    function ReceiptFieldByText(Receipt: TSalesReceipt;
      Item: TTemplateItem): WideString;
    procedure AddItems(Items: TList);
    function ReadReceiptJson(ShiftNumber: Integer;
      const CheckNumber: WideString): WideString;
    procedure BeginDocument(APrintHeader: boolean);
    procedure UpdateTemplateItem(Item: TTemplateItem);
    procedure CreateDIOHandlers;
    procedure PrintBarcodeAsGraphics(const Barcode: TBarcodeRec);
    procedure PrintDocItem(Item: TDocItem);
    procedure PtrPrintNormal(Station: Integer; const Data: WideString);
    function RenderBarcodeRec(Barcode: TBarcodeRec): AnsiString;
  public
    procedure PrintDocumentSafe(Document: TTextDocument);
    procedure CheckCanPrint;
    function GetVatRate(Code: Integer): TVatRate;
    function AmountToStr(Value: Currency): AnsiString;
    function AmountToOutStr(Value: Currency): AnsiString;
    function AmountToStrEq(Value: Currency): AnsiString;
    procedure SetPrinter(const Value: IOPOSPOSPrinter);
    function ReadDailyTotal: Currency;
    function ReadRefundTotal: Currency;
    function ReadSellTotal: Currency;
    procedure CutPaper;
    procedure ClearCashboxStatus;
    procedure PrintText(Prefix, Text: WideString; RecLineChars: Integer);
    procedure PrintTextLine(Prefix, Text: WideString;
      RecLineChars: Integer);
    function CreatePrinter: IOPOSPOSPrinter;
    function CreateSerialPort: TSerialPort;
    procedure PrintReceiptDuplicate(const pString: WideString);
    procedure PrintReceiptDuplicate2(const pString: WideString);
  public
    procedure PrintReceiptTemplate(Receipt: TSalesReceipt; Template: TReceiptTemplate);
    function GetJsonField(JsonText: WideString; const FieldName: WideString): Variant;
    function GetHeaderItemText(Receipt: TSalesReceipt; Item: TTemplateItem): WideString;

    procedure Initialize;
    procedure CheckEnabled;
    function ReadGrossTotal: Currency;
    function ReadGrandTotal: Currency;
    function IllegalError: Integer;
    procedure CheckState(AState: Integer);
    procedure SetPrinterState(Value: Integer);
    function DoClose: Integer;
    function GetPrinterStation(Station: Integer): Integer;
    procedure Print(Receipt: TCashInReceipt); overload;
    procedure Print(Receipt: TCashOutReceipt); overload;
    procedure Print(Receipt: TSalesReceipt); overload;
    procedure PrintReceipt(Receipt: TSalesReceipt; Command: TSendReceiptCommand);
    function GetPrinterState: Integer;
    function DoRelease: Integer;
    procedure UpdateUnits;
    procedure UpdateCashiers;
    procedure UpdateCashBoxes;
    procedure CheckCapSetVatTable;
    procedure CheckPtr(AResultCode: Integer);
    function CreateReceipt(FiscalReceiptType: Integer): TCustomReceipt;
    function GetPrinter: IOPOSPOSPrinter;
    function GetUnitCode(const UnitName: WideString): Integer;
    procedure PrinterErrorEvent(ASender: TObject; ResultCode,
      ResultCodeExtended, ErrorLocus: Integer;
      var pErrorResponse: Integer);
    procedure PrinterStatusUpdateEvent(ASender: TObject; Data: Integer);
    procedure PrintDocument(Document: TTextDocument);
    procedure PrintXZReport(IsZReport: Boolean);
    procedure AddPayments(Document: TTextDocument;
      Payments: TPaymentsByType);
    function GetQuantity(Value: Integer): Double;
    procedure PrinterDirectIOEvent(ASender: TObject; EventNumber: Integer;
      var pData: Integer; var pString: WideString);
    procedure PrinterOutputCompleteEvent(ASender: TObject;
      OutputID: Integer);
    function ReadCashboxStatus: TlkJSONbase;

    property Receipt: TCustomReceipt read FReceipt;
    property Document: TTextDocument read FDocument;
    property Duplicate: TTextDocument read FDuplicate;
    property StateDoc: TlkJSONbase read FCashboxStatus;
    property DIOHandlers: TDIOHandlers read FDIOHandlers;
    property Printer: IOPOSPOSPrinter read GetPrinter write SetPrinter;
    property PrinterState: Integer read GetPrinterState write SetPrinterState;
  private
    FPostLine: WideString;
    FPreLine: WideString;

    FDeviceEnabled: Boolean;
    FCheckTotal: Boolean;
    // boolean
    FDayOpened: Boolean;
    FCapAdditionalLines: Boolean;
    FCapAmountAdjustment: Boolean;
    FCapAmountNotPaid: Boolean;
    FCapCheckTotal: Boolean;
    FCapDoubleWidth: Boolean;
    FCapDuplicateReceipt: Boolean;
    FCapFixedOutput: Boolean;
    FCapHasVatTable: Boolean;
    FCapIndependentHeader: Boolean;
    FCapItemList: Boolean;
    FCapNonFiscalMode: Boolean;
    FCapOrderAdjustmentFirst: Boolean;
    FCapPercentAdjustment: Boolean;
    FCapPositiveAdjustment: Boolean;
    FCapPowerLossReport: Boolean;
    FCapPredefinedPaymentLines: Boolean;
    FCapReceiptNotPaid: Boolean;
    FCapRemainingFiscalMemory: Boolean;
    FCapReservedWord: Boolean;
    FCapSetPOSID: Boolean;
    FCapSetStoreFiscalID: Boolean;
    FCapSetVatTable: Boolean;
    FCapSlpFiscalDocument: Boolean;
    FCapSlpFullSlip: Boolean;
    FCapSlpValidation: Boolean;
    FCapSubAmountAdjustment: Boolean;
    FCapSubPercentAdjustment: Boolean;
    FCapSubtotal: Boolean;
    FCapTrainingMode: Boolean;
    FCapValidateJournal: Boolean;
    FCapXReport: Boolean;
    FCapAdditionalHeader: Boolean;
    FCapAdditionalTrailer: Boolean;
    FCapChangeDue: Boolean;
    FCapEmptyReceiptIsVoidable: Boolean;
    FCapFiscalReceiptStation: Boolean;
    FCapFiscalReceiptType: Boolean;
    FCapMultiContractor: Boolean;
    FCapOnlyVoidLastItem: Boolean;
    FCapPackageAdjustment: Boolean;
    FCapPostPreLine: Boolean;
    FCapSetCurrency: Boolean;
    FCapTotalizerType: Boolean;
    FCapPositiveSubtotalAdjustment: Boolean;
    FCapSetHeader: Boolean;
    FCapSetTrailer: Boolean;

    FAsyncMode: Boolean;
    FDuplicateReceipt: Boolean;
    FFlagWhenIdle: Boolean;
    // integer
    FCountryCode: Integer;
    FErrorLevel: Integer;
    FErrorOutID: Integer;
    FErrorState: Integer;
    FErrorStation: Integer;
    FQuantityDecimalPlaces: Integer;
    FQuantityLength: Integer;
    FSlipSelection: Integer;
    FActualCurrency: Integer;
    FContractorId: Integer;
    FDateType: Integer;
    FFiscalReceiptStation: Integer;
    FFiscalReceiptType: Integer;
    FMessageType: Integer;
    FTotalizerType: Integer;

    FAdditionalHeader: WideString;
    FAdditionalTrailer: WideString;
    FPredefinedPaymentLines: WideString;
    FReservedWord: WideString;
    FChangeDue: WideString;
    FRemainingFiscalMemory: Integer;
    FUnitsUpdated: Boolean;
    FCashiersUpdated: Boolean;
    FCashBoxesUpdated: Boolean;
    FReceiptJson: WideString;

    FPtrMapCharacterSet: Boolean;

    function DoCloseDevice: Integer;
    function DoOpen(const DeviceClass, DeviceName: WideString;
      const pDispatch: IDispatch): Integer;
    function GetEventInterface(FDispatch: IDispatch): IOposEvents;
    function ClearResult: Integer;
    function HandleException(E: Exception): Integer;
    procedure SetDeviceEnabled(Value: Boolean);
    function HandleDriverError(E: EDriverError): TOPOSError;
  public
    function Get_OpenResult: Integer; safecall;
    function COFreezeEvents(Freeze: WordBool): Integer; safecall;
    function GetPropertyNumber(PropIndex: Integer): Integer; safecall;
    procedure SetPropertyNumber(PropIndex: Integer; Number: Integer); safecall;
    function GetPropertyString(PropIndex: Integer): WideString; safecall;
    procedure SetPropertyString(PropIndex: Integer; const Text: WideString); safecall;
    function OpenService(const DeviceClass: WideString; const DeviceName: WideString;
                         const pDispatch: IDispatch): Integer; safecall;
    function CloseService: Integer; safecall;
    function CheckHealth(Level: Integer): Integer; safecall;
    function ClaimDevice(Timeout: Integer): Integer; safecall;
    function ClearOutput: Integer; safecall;
    function DirectIO(Command: Integer; var pData: Integer; var pString: WideString): Integer; safecall;
    function DirectIO2(Command: Integer; const pData: Integer; const pString: WideString): Integer;
    function ReleaseDevice: Integer; safecall;
    function BeginFiscalDocument(DocumentAmount: Integer): Integer; safecall;
    function BeginFiscalReceipt(PrintHeader: WordBool): Integer; safecall;
    function BeginFixedOutput(Station: Integer; DocumentType: Integer): Integer; safecall;
    function BeginInsertion(Timeout: Integer): Integer; safecall;
    function BeginItemList(VatID: Integer): Integer; safecall;
    function BeginNonFiscal: Integer; safecall;
    function BeginRemoval(Timeout: Integer): Integer; safecall;
    function BeginTraining: Integer; safecall;
    function ClearError: Integer; safecall;
    function EndFiscalDocument: Integer; safecall;
    function EndFiscalReceipt(PrintHeader: WordBool): Integer; safecall;
    function EndFixedOutput: Integer; safecall;
    function EndInsertion: Integer; safecall;
    function EndItemList: Integer; safecall;
    function EndNonFiscal: Integer; safecall;
    function EndRemoval: Integer; safecall;
    function EndTraining: Integer; safecall;
    function GetData(DataItem: Integer; out OptArgs: Integer; out Data: WideString): Integer; safecall;
    function GetDate(out Date: WideString): Integer; safecall;
    function GetTotalizer(VatID: Integer; OptArgs: Integer; out Data: WideString): Integer; safecall;
    function GetVatEntry(VatID: Integer; OptArgs: Integer; out VatRate: Integer): Integer; safecall;
    function PrintDuplicateReceipt: Integer; safecall;
    function PrintFiscalDocumentLine(const DocumentLine: WideString): Integer; safecall;
    function PrintFixedOutput(DocumentType: Integer; LineNumber: Integer; const Data: WideString): Integer; safecall;
    function PrintNormal(Station: Integer; const AData: WideString): Integer; safecall;
    function PrintPeriodicTotalsReport(const Date1: WideString; const Date2: WideString): Integer; safecall;
    function PrintPowerLossReport: Integer; safecall;
    function PrintRecItem(const Description: WideString; Price: Currency; Quantity: Integer;
                          VatInfo: Integer; UnitPrice: Currency; const UnitName: WideString): Integer; safecall;
    function PrintRecItemAdjustment(AdjustmentType: Integer; const Description: WideString; 
                                    Amount: Currency; VatInfo: Integer): Integer; safecall;
    function PrintRecMessage(const Message: WideString): Integer; safecall;
    function PrintRecNotPaid(const Description: WideString; Amount: Currency): Integer; safecall;
    function PrintRecRefund(const Description: WideString; Amount: Currency; VatInfo: Integer): Integer; safecall;
    function PrintRecSubtotal(Amount: Currency): Integer; safecall;
    function PrintRecSubtotalAdjustment(AdjustmentType: Integer; const Description: WideString;
                                        Amount: Currency): Integer; safecall;
    function PrintRecTotal(Total: Currency; Payment: Currency; const Description: WideString): Integer; safecall;
    function PrintRecVoid(const Description: WideString): Integer; safecall;
    function PrintRecVoidItem(const Description: WideString; Amount: Currency; Quantity: Integer; 
                              AdjustmentType: Integer; Adjustment: Currency; VatInfo: Integer): Integer; safecall;
    function PrintReport(ReportType: Integer; const StartNum: WideString; const EndNum: WideString): Integer; safecall;
    function PrintXReport: Integer; safecall;
    function PrintZReport: Integer; safecall;
    function ResetPrinter: Integer; safecall;
    function SetDate(const Date: WideString): Integer; safecall;
    function SetHeaderLine(LineNumber: Integer; const Text: WideString; DoubleWidth: WordBool): Integer; safecall;
    function SetPOSID(const POSID: WideString; const CashierID: WideString): Integer; safecall;
    function SetStoreFiscalID(const ID: WideString): Integer; safecall;
    function SetTrailerLine(LineNumber: Integer; const Text: WideString; DoubleWidth: WordBool): Integer; safecall;
    function SetVatTable: Integer; safecall;
    function SetVatValue(VatID: Integer; const VatValue: WideString): Integer; safecall;
    function VerifyItem(const ItemName: WideString; VatID: Integer): Integer; safecall;
    function PrintRecCash(Amount: Currency): Integer; safecall;
    function PrintRecItemFuel(const Description: WideString; Price: Currency; Quantity: Integer; 
                              VatInfo: Integer; UnitPrice: Currency; const UnitName: WideString; 
                              SpecialTax: Currency; const SpecialTaxName: WideString): Integer; safecall;
    function PrintRecItemFuelVoid(const Description: WideString; Price: Currency; VatInfo: Integer; 
                                  SpecialTax: Currency): Integer; safecall;
    function PrintRecPackageAdjustment(AdjustmentType: Integer; const Description: WideString; 
                                       const VatAdjustment: WideString): Integer; safecall;
    function PrintRecPackageAdjustVoid(AdjustmentType: Integer; const VatAdjustment: WideString): Integer; safecall;
    function PrintRecRefundVoid(const Description: WideString; Amount: Currency; VatInfo: Integer): Integer; safecall;
    function PrintRecSubtotalAdjustVoid(AdjustmentType: Integer; Amount: Currency): Integer; safecall;
    function PrintRecTaxID(const TaxID: WideString): Integer; safecall;
    function SetCurrency(NewCurrency: Integer): Integer; safecall;
    function GetOpenResult: Integer; safecall;
    function Open(const DeviceClass: WideString; const DeviceName: WideString; 
                  const pDispatch: IDispatch): Integer; safecall;
    function Close: Integer; safecall;
    function Claim(Timeout: Integer): Integer; safecall;
    function Release1: Integer; safecall;
    function ResetStatistics(const StatisticsBuffer: WideString): Integer; safecall;
    function RetrieveStatistics(var pStatisticsBuffer: WideString): Integer; safecall;
    function UpdateStatistics(const StatisticsBuffer: WideString): Integer; safecall;
    function CompareFirmwareVersion(const FirmwareFileName: WideString; out pResult: Integer): Integer; safecall;
    function UpdateFirmware(const FirmwareFileName: WideString): Integer; safecall;
    function PrintRecItemAdjustmentVoid(AdjustmentType: Integer; const Description: WideString; 
                                        Amount: Currency; VatInfo: Integer): Integer; safecall;
    function PrintRecItemVoid(const Description: WideString; Price: Currency; Quantity: Integer; 
                              VatInfo: Integer; UnitPrice: Currency; const UnitName: WideString): Integer; safecall;
    function PrintRecItemRefund(const Description: WideString; Amount: Currency; Quantity: Integer;
                                VatInfo: Integer; UnitAmount: Currency; const UnitName: WideString): Integer; safecall;
    function PrintRecItemRefundVoid(const Description: WideString; Amount: Currency;
                                    Quantity: Integer; VatInfo: Integer; UnitAmount: Currency;
                                    const UnitName: WideString): Integer; safecall;
    property OpenResult: Integer read Get_OpenResult;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function DecodeString(const Text: WideString): WideString;
    function EncodeString(const S: WideString): WideString;
    procedure PrintQRCodeAsGraphics(const BarcodeData: AnsiString);
    function RenderQRCode(const BarcodeData: AnsiString): AnsiString;
    procedure PrintBarcode(const Barcode: string);
    procedure PrintBarcode2(const Barcode: TBarcodeRec);

    property Logger: ILogFile read FLogger;
    property CashBox: TCashBox read FCashBox;
    property Client: TWebkassaClient read FClient;
    property Params: TPrinterParameters read FParams;
    property TestMode: Boolean read FTestMode write FTestMode;
    property OposDevice: TOposServiceDevice19 read FOposDevice;
    property ReceiptJson: WideString read FReceiptJson write FReceiptJson;
    property LoadParamsEnabled: Boolean read FLoadParamsEnabled write FLoadParamsEnabled;
    property ExternalCheckNumber: WideString read FExternalCheckNumber write FExternalCheckNumber;
  end;

implementation

uses
  DIOHandlers;

const
  BoolToInt: array [Boolean] of Integer = (0, 1);

function IntToBool(Value: Integer): Boolean;
begin
  Result := Value <> 0;
end;

function GetSystemLocaleStr: WideString;
const
  BoolToStr: array [Boolean] of WideString = ('0', '1');
begin
  Result := Format('LCID: %d, LangID: %d.%d, FarEast: %s, FarEast: %s',
    [SysLocale.DefaultLCID, SysLocale.PriLangID, SysLocale.SubLangID,
    BoolToStr[SysLocale.FarEast], BoolToStr[SysLocale.MiddleEast]]);
end;

function GetSystemVersionStr: WideString;
var
  OSVersionInfo: TOSVersionInfo;
begin
  Result := '';
  OSVersionInfo.dwOSVersionInfoSize := SizeOf(OSVersionInfo);
  if GetVersionEx(OSVersionInfo) then
  begin
    Result := Tnt_WideFormat('%d.%d.%d, Platform ID: %d', [
      OSVersionInfo.dwMajorVersion,
      OSVersionInfo.dwMinorVersion,
      OSVersionInfo.dwBuildNumber,
      OSVersionInfo.dwPlatformId]);
  end;
end;

function BarcodeAlignmentToBCAlignment(BarcodeAlignment: Integer): Integer;
begin
  case BarcodeAlignment of
    BARCODE_ALIGNMENT_LEFT   : Result := PTR_BC_LEFT;
    BARCODE_ALIGNMENT_CENTER : Result := PTR_BC_CENTER;
    BARCODE_ALIGNMENT_RIGHT  : Result := PTR_BC_RIGHT;
  else
    Result := PTR_BC_CENTER;
  end;
end;

function BarcodeAlignmentToBMPAlignment(BarcodeAlignment: Integer): Integer;
begin
  case BarcodeAlignment of
    BARCODE_ALIGNMENT_CENTER : Result := PTR_BM_CENTER;
    BARCODE_ALIGNMENT_LEFT   : Result := PTR_BM_LEFT;
    BARCODE_ALIGNMENT_RIGHT  : Result := PTR_BM_RIGHT;
  else
    Result := PTR_BM_CENTER;
  end;
end;

{ TWebkassaImpl }

constructor TWebkassaImpl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FLogger := TLogFile.Create;
  FDocument := TTextDocument.Create;
  FDuplicate := TTextDocument.Create;
  FReceipt := TCustomReceipt.Create;
  FClient := TWebkassaClient.Create(FLogger);
  FParams := TPrinterParameters.Create(FLogger);
  FOposDevice := TOposServiceDevice19.Create(FLogger);
  FOposDevice.ErrorEventEnabled := False;
  FPrinterState := TFiscalPrinterState.Create;
  FUnits := TUnitItems.Create(TUnitItem);
  FCashBoxes := TCashBoxes.Create(TCashBox);
  FCashiers := TCashiers.Create;
  FCashBox := TCashBox.Create(nil);
  FCashier := TCashier.Create(nil);
  FClient.RaiseErrors := True;
  FCashboxStatusJson := TlkJSON.Create;
  FLines := TTntStringList.Create;
  FDIOHandlers := TDIOHandlers.Create(FParams);
  CreateDIOHandlers;

  FLoadParamsEnabled := True;
end;

destructor TWebkassaImpl.Destroy;
begin
  if FOposDevice.Opened then
    Close;

  FPrinter := nil;
  FPrinterObj.Free;

  FLines.Free;
  FCashboxStatusJson.Free;
  FClient.Free;
  FParams.Free;
  FUnits.Free;
  FDocument.Free;
  FDuplicate.Free;
  FOposDevice.Free;
  FPrinterState.Free;
  FReceipt.Free;
  FPrinterLog.Free;
  FCashBoxes.Free;
  FCashBox.Free;
  FCashier.Free;
  FCashiers.Free;
  FDIOHandlers.Free;
  inherited Destroy;
end;

procedure TWebkassaImpl.CreateDIOHandlers;
begin
  FDIOHandlers.Clear;
  TDIOBarcode.CreateCommand(FDIOHandlers, DIO_PRINT_BARCODE, Self);
  TDIOBarcodeHex.CreateCommand(FDIOHandlers, DIO_PRINT_BARCODE_HEX, Self);
  TDIOPrintHeader.CreateCommand(FDIOHandlers, DIO_PRINT_HEADER, Self);
  TDIOPrintTrailer.CreateCommand(FDIOHandlers, DIO_PRINT_TRAILER, Self);
  TDIOSetDriverParameter.CreateCommand(FDIOHandlers, DIO_SET_DRIVER_PARAMETER, Self);
  TDIOGetDriverParameter.CreateCommand(FDIOHandlers, DIO_GET_DRIVER_PARAMETER, Self);
  TDIOPrintReceiptDuplicate.CreateCommand(FDIOHandlers, DIO_PRINT_RECEIPT_DUPLICATE, Self);
end;

procedure TWebkassaImpl.BeginDocument(APrintHeader: boolean);
begin
  Document.Clear;
  Document.LineChars := Printer.RecLineChars;
  Document.LineHeight := Printer.RecLineHeight;
  Document.LineSpacing := Printer.RecLineSpacing;
  if APrintHeader and not (Params.HeaderPrinted) then
  begin
    Document.AddText(Params.HeaderText);
    Params.HeaderPrinted := False;
    SaveUsrParameters(FParams, FOposDevice.DeviceName, FLogger);
  end;
end;

function TWebkassaImpl.AmountToStr(Value: Currency): AnsiString;
begin
  if Params.AmountDecimalPlaces = 0 then
  begin
    Result := IntToStr(Round(Value));
  end else
  begin
    Result := Format('%.*f', [Params.AmountDecimalPlaces, Value]);
  end;
end;

function TWebkassaImpl.AmountToOutStr(Value: Currency): AnsiString;
var
  L: Int64;
begin
  L := Trunc(Value * Math.Power(10, Params.AmountDecimalPlaces));
  Result := IntToStr(L);
end;

function TWebkassaImpl.AmountToStrEq(Value: Currency): AnsiString;
begin
  Result := '=' + AmountToStr(Value);
end;

function TWebkassaImpl.GetQuantity(Value: Integer): Double;
begin
  Result := Value / 1000;
end;

function TWebkassaImpl.GetPrinter: IOPOSPOSPrinter;
begin
  if FPrinter = nil then
    raise Exception.Create('Not opened');
  Result := FPrinter;
end;

procedure TWebkassaImpl.SetPrinter(const Value: IOPOSPOSPrinter);
begin
  FPrinterLog.Free;
  FPrinterLog := TPosPrinterLog.Create2(nil, Value, Logger);
  FPrinter := FPrinterLog;
end;

function TWebkassaImpl.CreateReceipt(FiscalReceiptType: Integer): TCustomReceipt;
begin
  case FiscalReceiptType of
    FPTR_RT_CASH_IN: Result := TCashInReceipt.Create;
    FPTR_RT_CASH_OUT: Result := TCashOutReceipt.Create;

    FPTR_RT_SALES,
    FPTR_RT_GENERIC,
    FPTR_RT_SERVICE,
    FPTR_RT_SIMPLE_INVOICE:
      Result := TSalesReceipt.CreateReceipt(rtSell,
        Params.AmountDecimalPlaces, Params.RoundType);

    FPTR_RT_REFUND:
      Result := TSalesReceipt.CreateReceipt(rtRetSell,
        Params.AmountDecimalPlaces, Params.RoundType);
  else
    Result := nil;
    InvalidPropertyValue('FiscalReceiptType', IntToStr(FiscalReceiptType));
  end;
end;

procedure TWebkassaImpl.CheckCapSetVatTable;
begin
  if not FCapSetVatTable then
    RaiseIllegalError(_('Not supported'));
end;

function TWebkassaImpl.DoRelease: Integer;
begin
  try
    SetDeviceEnabled(False);
    OposDevice.ReleaseDevice;
    Printer.ReleaseDevice;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.GetPrinterState: Integer;
begin
  Result := FPrinterState.State;
end;

procedure TWebkassaImpl.SetPrinterState(Value: Integer);
begin
  FPrinterState.SetState(Value);
end;

function TWebkassaImpl.DoClose: Integer;
begin
  try
    Result := DoCloseDevice;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

procedure TWebkassaImpl.Initialize;
begin
  FDayOpened := True;
  FCapAmountNotPaid := False;
  FCapFixedOutput := False;
  FCapIndependentHeader := False;
  FCapItemList := False;
  FCapNonFiscalMode := False;
  FCapOrderAdjustmentFirst := False;
  FCapPowerLossReport := False;
  FCapReceiptNotPaid := False;
  FCapReservedWord := False;
  FCapSetStoreFiscalID := False;
  FCapSlpValidation := False;
  FCapSlpFiscalDocument := False;
  FCapSlpFullSlip := False;
  FCapTrainingMode := False;
  FCapValidateJournal := False;
  FCapChangeDue := False;
  FCapMultiContractor := False;

  FCapAdditionalLines := True;
  FCapAmountAdjustment := True;
  FCapCheckTotal := True;
  FCapDoubleWidth := True;
  FCapDuplicateReceipt := True;
  FCapHasVatTable := True;
  FCapPercentAdjustment := True;
  FCapPositiveAdjustment := True;
  FCapPredefinedPaymentLines := True;
  FCapRemainingFiscalMemory := True;
  FCapSetPOSID := True;
  FCapSetVatTable := True;
  FCapSubAmountAdjustment := True;
  FCapSubPercentAdjustment := True;
  FCapSubtotal := True;
  FCapXReport := True;
  FCapAdditionalHeader := True;
  FCapAdditionalTrailer := True;
  FCapEmptyReceiptIsVoidable := True;
  FCapFiscalReceiptStation := True;
  FCapFiscalReceiptType := True;
  FCapOnlyVoidLastItem := False;
  FCapPackageAdjustment := True;
  FCapPostPreLine := True;
  FCapSetCurrency := False;
  FCapTotalizerType := True;
  FCapPositiveSubtotalAdjustment := True;

  FAsyncMode := False;
  FDuplicateReceipt := False;
  FFlagWhenIdle := False;
  // integer
  FOposDevice.ServiceObjectVersion := GenericServiceVersion;
  FCountryCode := FPTR_CC_RUSSIA;
  FErrorLevel := FPTR_EL_NONE;
  FErrorOutID := 0;
  FErrorState := FPTR_PS_MONITOR;
  FErrorStation := FPTR_S_RECEIPT;
  SetPrinterState(FPTR_PS_MONITOR);
  FQuantityDecimalPlaces := 3;
  FQuantityLength := 10;
  FSlipSelection := FPTR_SS_FULL_LENGTH;
  FActualCurrency := FPTR_AC_RUR;
  FContractorId := FPTR_CID_SINGLE;
  FDateType := FPTR_DT_RTC;
  FFiscalReceiptStation := FPTR_RS_RECEIPT;
  FFiscalReceiptType := FPTR_RT_SALES;
  FMessageType := FPTR_MT_FREE_TEXT;
  FTotalizerType := FPTR_TT_DAY;

  FAdditionalHeader := '';
  FAdditionalTrailer := '';
  FOposDevice.PhysicalDeviceName := FPTR_DEVICE_DESCRIPTION;
  FOposDevice.PhysicalDeviceDescription := FPTR_DEVICE_DESCRIPTION;
  FOposDevice.ServiceObjectDescription := 'WebKassa OPOS fiscal printer service. SHTRIH-M, 2022';
  FPredefinedPaymentLines := '0,1,2,3';
  FReservedWord := '';
  FChangeDue := '';
end;

function TWebkassaImpl.IllegalError: Integer;
begin
  Result := FOposDevice.SetResultCode(OPOS_E_ILLEGAL);
end;

function TWebkassaImpl.ClearResult: Integer;
begin
  Result := FOposDevice.ClearResult;
end;

procedure TWebkassaImpl.CheckEnabled;
begin
  FOposDevice.CheckEnabled;
end;

procedure TWebkassaImpl.CheckState(AState: Integer);
begin
  CheckEnabled;
  FPrinterState.CheckState(AState);
end;

function TWebkassaImpl.DecodeString(const Text: WideString): WideString;
begin
  Result := Text;
end;

function TWebkassaImpl.EncodeString(const S: WideString): WideString;
begin
  Result := S;
end;

function TWebkassaImpl.BeginFiscalDocument(
  DocumentAmount: Integer): Integer;
begin
  try
    CheckEnabled;
    CheckState(FPTR_PS_MONITOR);
    SetPrinterState(FPTR_PS_FISCAL_DOCUMENT);
    Document.LineChars := Printer.RecLineChars;

    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.BeginFiscalReceipt(PrintHeader: WordBool): Integer;
begin
  try
    CheckEnabled;
    CheckState(FPTR_PS_MONITOR);
    SetPrinterState(FPTR_PS_FISCAL_RECEIPT);

    FReceipt.Free;
    FReceipt := CreateReceipt(FFiscalReceiptType);
    FReceipt.BeginFiscalReceipt(PrintHeader);
    FExternalCheckNumber := CreateGUIDStr;

    BeginDocument(PrintHeader);

    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.BeginFixedOutput(Station,
  DocumentType: Integer): Integer;
begin
  Result := IllegalError;
end;

function TWebkassaImpl.BeginInsertion(Timeout: Integer): Integer;
begin
  Result := IllegalError;
end;

function TWebkassaImpl.BeginItemList(VatID: Integer): Integer;
begin
  Result := IllegalError;
end;

function TWebkassaImpl.BeginNonFiscal: Integer;
begin
  try
    CheckEnabled;
    CheckState(FPTR_PS_MONITOR);
    SetPrinterState(FPTR_PS_NONFISCAL);
    BeginDocument(False);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.BeginRemoval(Timeout: Integer): Integer;
begin
  Result := IllegalError;
end;

function TWebkassaImpl.BeginTraining: Integer;
begin
  try
    CheckEnabled;
    CheckState(FPTR_PS_MONITOR);
    RaiseOposException(OPOS_E_ILLEGAL, _('–ÂÊËÏ ÚÂÌËÓ‚ÍË ÌÂ ÔÓ‰‰ÂÊË‚‡ÂÚÒˇ'));
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.CheckHealth(Level: Integer): Integer;
begin
  try
    CheckEnabled;
    CheckPtr(Printer.CheckHealth(Level));
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.Claim(Timeout: Integer): Integer;
begin
  try
    FOposDevice.ClaimDevice(Timeout);
    CheckPtr(Printer.ClaimDevice(Timeout));
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.ClaimDevice(Timeout: Integer): Integer;
begin
  Result := Claim(Timeout);
end;

function TWebkassaImpl.ClearError: Integer;
begin
  Result := ClearResult;
end;

function TWebkassaImpl.ClearOutput: Integer;
begin
  try
    FOposDevice.CheckClaimed;
    CheckPtr(Printer.ClearOutput);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.Close: Integer;
begin
  Result := DoClose;
end;

function TWebkassaImpl.CloseService: Integer;
begin
  Result := DoClose;
end;

function TWebkassaImpl.COFreezeEvents(Freeze: WordBool): Integer;
begin
  try
    FOposDevice.FreezeEvents := Freeze;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.CompareFirmwareVersion(
  const FirmwareFileName: WideString; out pResult: Integer): Integer;
begin
  try
    CheckEnabled;
    Result := IllegalError;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.DirectIO(Command: Integer; var pData: Integer;
  var pString: WideString): Integer;
var
  Handler: TDIOHandler;
begin
  try
    FOposDevice.CheckOpened;

    Handler := DIOHandlers.findItem(Command);
    if Handler <> nil then
    begin
      Handler.DirectIO(pData, pString);
    end else
    begin
      if Receipt.IsOpened then
      begin
        Receipt.DirectIO(Command, pData, pString);
      end;
    end;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.DirectIO2(Command: Integer; const pData: Integer; const pString: WideString): Integer;
var
  pData2: Integer;
  pString2: WideString;
begin
  pData2 := pData;
  pString2 := pString;
  Result := DirectIO(Command, pData2, pString2);
end;

function TWebkassaImpl.EndFiscalDocument: Integer;
begin
  Result := IllegalError;
end;

function TWebkassaImpl.EndFiscalReceipt(PrintHeader: WordBool): Integer;
begin
  try
    FPrinterState.CheckState(FPTR_PS_FISCAL_RECEIPT_ENDING);
    FReceipt.EndFiscalReceipt(PrintHeader);
    FReceipt.Print(Self);
    if FDuplicateReceipt then
    begin
      FDuplicateReceipt := False;
      FDuplicate.Assign(Document);
    end;
    ClearCashboxStatus;
    SetPrinterState(FPTR_PS_MONITOR);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.EndFixedOutput: Integer;
begin
  Result := IllegalError;
end;

function TWebkassaImpl.EndInsertion: Integer;
begin
  Result := IllegalError;
end;

function TWebkassaImpl.EndItemList: Integer;
begin
  Result := IllegalError;
end;

function TWebkassaImpl.EndNonFiscal: Integer;
begin
  try
    CheckEnabled;
    CheckState(FPTR_PS_NONFISCAL);
    PrintDocumentSafe(Document);
    SetPrinterState(FPTR_PS_MONITOR);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.EndRemoval: Integer;
begin
  Result := IllegalError;
end;

function TWebkassaImpl.EndTraining: Integer;
begin
  try
    CheckEnabled;
    RaiseOposException(OPOS_E_ILLEGAL, _('Training mode is not active'));
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.Get_OpenResult: Integer;
begin
  Result := FOposDevice.OpenResult;
end;

procedure TWebkassaImpl.ClearCashboxStatus;
begin
  FCashboxStatus := nil;
end;

function TWebkassaImpl.ReadCashboxStatus: TlkJSONbase;
var
  Request: TCashboxRequest;
begin
  if FCashboxStatus = nil then
  begin
    Request := TCashboxRequest.Create;
    try
      Request.Token := Client.Token;
      Request.CashboxUniqueNumber := Params.CashboxNumber;
      Client.ReadCashboxStatus(Request);
      FCashboxStatus := FCashboxStatusJson.ParseText(FClient.AnswerJson);
    finally
      Request.Free;
    end;
  end;
  Result := FCashboxStatus;
end;

function TWebkassaImpl.ReadGrandTotal: Currency;
begin
  Result := ReadCashboxStatus.Get('Data').Get('CurrentState').Get(
    'XReport').Get('SumInCashbox').Value;
end;

function TWebkassaImpl.ReadGrossTotal: Currency;
var
  Node: TlkJSONbase;
begin
  Node := ReadCashboxStatus.Get('Data').Get('CurrentState').Get('XReport').Get('StartNonNullable');
  Result :=
    Currency(Node.Get('Sell').Value) -
    Currency(Node.Get('Buy').Value) -
    Currency(Node.Get('ReturnSell').Value) +
    Currency(Node.Get('ReturnBuy').Value);
end;

function TWebkassaImpl.ReadDailyTotal: Currency;
var
  Doc: TlkJSONbase;
begin
  Result := 0;
  Doc := ReadCashboxStatus.Get('Data').Get('CurrentState').Get('XReport');
  // Sell
  Result :=  Result +
    (Doc.Get('Sell').Get('Taken').Value -
    Doc.Get('Sell').Get('Change').Value);
  // Buy
  Result :=  Result -
    (Doc.Get('Buy').Get('Taken').Value -
    Doc.Get('Buy').Get('Change').Value);
  // ReturnSell
  Result :=  Result -
    (Doc.Get('ReturnSell').Get('Taken').Value -
    Doc.Get('ReturnSell').Get('Change').Value);
  // ReturnBuy
  Result :=  Result +
    (Doc.Get('ReturnBuy').Get('Taken').Value -
    Doc.Get('ReturnBuy').Get('Change').Value);
end;

function TWebkassaImpl.ReadSellTotal: Currency;
var
  Doc: TlkJSONbase;
begin
  Result := 0;
  Doc := ReadCashboxStatus.Get('Data').Get('CurrentState').Get('XReport');
  // Sell
  Result :=  Result +
    (Doc.Get('Sell').Get('Taken').Value -
    Doc.Get('Sell').Get('Change').Value);
  // ReturnBuy
  Result :=  Result +
    (Doc.Get('ReturnBuy').Get('Taken').Value -
    Doc.Get('ReturnBuy').Get('Change').Value);
end;

function TWebkassaImpl.ReadRefundTotal: Currency;
var
  Doc: TlkJSONbase;
begin
  Result := 0;
  Doc := ReadCashboxStatus.Get('Data').Get('CurrentState').Get('XReport');
  // Buy
  Result :=  Result +
    (Doc.Get('Buy').Get('Taken').Value -
    Doc.Get('Buy').Get('Change').Value);
  // ReturnSell
  Result :=  Result +
    (Doc.Get('ReturnSell').Get('Taken').Value -
    Doc.Get('ReturnSell').Get('Change').Value);
end;

function TWebkassaImpl.GetData(DataItem: Integer; out OptArgs: Integer;
  out Data: WideString): Integer;
var
  ZReportNumber: Integer;
begin
  try
    case DataItem of
      FPTR_GD_FIRMWARE: ;
      FPTR_GD_PRINTER_ID: Data := Params.CashboxNumber;
      FPTR_GD_CURRENT_TOTAL: Data := AmountToOutStr(Receipt.GetTotal());
      FPTR_GD_DAILY_TOTAL: Data := AmountToOutStr(ReadDailyTotal);
      FPTR_GD_GRAND_TOTAL: Data := AmountToOutStr(ReadGrandTotal);
      FPTR_GD_MID_VOID: Data := AmountToOutStr(0);
      FPTR_GD_NOT_PAID: Data := AmountToOutStr(0);
      FPTR_GD_RECEIPT_NUMBER: Data := FCheckNumber;
      FPTR_GD_REFUND: Data := AmountToOutStr(ReadRefundTotal);
      FPTR_GD_REFUND_VOID: Data := AmountToOutStr(0);
      FPTR_GD_Z_REPORT:
      begin
        ZReportNumber := ReadCashboxStatus.Get('Data').Get(
          'CurrentState').Get('ShiftNumber').Value;
        if ZReportNumber > 0 then
          ZReportNumber := ZReportNumber - 1;
        Data := IntToStr(ZReportNumber);
      end;
      FPTR_GD_FISCAL_REC: Data := AmountToOutStr(ReadSellTotal);
      FPTR_GD_FISCAL_DOC,
      FPTR_GD_FISCAL_DOC_VOID,
      FPTR_GD_FISCAL_REC_VOID,
      FPTR_GD_NONFISCAL_DOC,
      FPTR_GD_NONFISCAL_DOC_VOID,
      FPTR_GD_NONFISCAL_REC,
      FPTR_GD_RESTART,
      FPTR_GD_SIMP_INVOICE,
      FPTR_GD_TENDER,
      FPTR_GD_LINECOUNT:
        Data := AmountToStr(0);
      FPTR_GD_DESCRIPTION_LENGTH: Data := IntToStr(Printer.RecLineChars);
    else
      InvalidParameterValue('DataItem', IntToStr(DataItem));
    end;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
  Printer.CapStatisticsReporting

end;

function TWebkassaImpl.GetDate(out Date: WideString): Integer;
var
  Year, Month, Day, Hour, Minute, Second, MilliSecond: Word;
begin
  try
    case FDateType of
      FPTR_DT_RTC:
      begin
        DecodeDateTime(Now, Year, Month, Day, Hour, Minute, Second, MilliSecond);
        Date := Format('%.2d%.2d%.4d%.2d%.2d',[Day, Month, Year, Hour, Minute]);
      end;
    else
      InvalidPropertyValue('DateType', IntToStr(FDateType));
    end;

    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.GetOpenResult: Integer;
begin
  Result := FOposDevice.OpenResult;
end;

function TWebkassaImpl.GetPropertyNumber(PropIndex: Integer): Integer;
begin
  try
    case PropIndex of
      // standard
      PIDX_Claimed                    : Result := BoolToInt[FOposDevice.Claimed];
      PIDX_DataEventEnabled           : Result := BoolToInt[FOposDevice.DataEventEnabled];
      PIDX_DeviceEnabled              : Result := BoolToInt[FDeviceEnabled];
      PIDX_FreezeEvents               : Result := BoolToInt[FOposDevice.FreezeEvents];
      PIDX_OutputID                   : Result := FOposDevice.OutputID;
      PIDX_ResultCode                 : Result := FOposDevice.ResultCode;
      PIDX_ResultCodeExtended         : Result := FOposDevice.ResultCodeExtended;
      PIDX_ServiceObjectVersion       : Result := FOposDevice.ServiceObjectVersion;
      PIDX_State                      : Result := FOposDevice.State;
      PIDX_BinaryConversion           : Result := FOposDevice.BinaryConversion;
      PIDX_DataCount                  : Result := FOposDevice.DataCount;
      PIDX_PowerNotify                : Result := FOposDevice.PowerNotify;
      PIDX_PowerState                 : Result := FOposDevice.PowerState;
      PIDX_CapPowerReporting          : Result := FOposDevice.CapPowerReporting;
      PIDX_CapStatisticsReporting     : Result := BoolToInt[FOposDevice.CapStatisticsReporting];
      PIDX_CapUpdateStatistics        : Result := BoolToInt[FOposDevice.CapUpdateStatistics];
      PIDX_CapCompareFirmwareVersion  : Result := BoolToInt[FOposDevice.CapCompareFirmwareVersion];
      PIDX_CapUpdateFirmware          : Result := BoolToInt[FOposDevice.CapUpdateFirmware];
      // specific
      PIDXFptr_AmountDecimalPlaces    : Result := Params.AmountDecimalPlaces;
      PIDXFptr_AsyncMode              : Result := BoolToInt[FAsyncMode];
      PIDXFptr_CheckTotal             : Result := BoolToInt[FCheckTotal];
      PIDXFptr_CountryCode            : Result := FCountryCode;
      PIDXFptr_CoverOpen              : Result := BoolToInt[Printer.CoverOpen];
      PIDXFptr_DayOpened              : Result := BoolToInt[FDayOpened];
      PIDXFptr_DescriptionLength      : Result := Printer.RecLineChars;
      PIDXFptr_DuplicateReceipt       : Result := BoolToInt[FDuplicateReceipt];
      PIDXFptr_ErrorLevel             : Result := FErrorLevel;
      PIDXFptr_ErrorOutID             : Result := FErrorOutID;
      PIDXFptr_ErrorState             : Result := FErrorState;
      PIDXFptr_ErrorStation           : Result := FErrorStation;
      PIDXFptr_FlagWhenIdle           : Result := BoolToInt[FFlagWhenIdle];
      PIDXFptr_JrnEmpty               : Result := BoolToInt[Printer.JrnEmpty];
      PIDXFptr_JrnNearEnd             : Result := BoolToInt[Printer.JrnNearEnd];
      PIDXFptr_MessageLength          : Result := Printer.RecLineChars;
      PIDXFptr_NumHeaderLines         : Result := FParams.NumHeaderLines;
      PIDXFptr_NumTrailerLines        : Result := FParams.NumTrailerLines;
      PIDXFptr_NumVatRates            : Result := FParams.VatRates.Count;
      PIDXFptr_PrinterState           : Result := FPrinterState.State;
      PIDXFptr_QuantityDecimalPlaces  : Result := FQuantityDecimalPlaces;
      PIDXFptr_QuantityLength         : Result := FQuantityLength;
      PIDXFptr_RecEmpty               : Result := BoolToInt[Printer.RecEmpty];
      PIDXFptr_RecNearEnd             : Result := BoolToInt[Printer.RecNearEnd];
      PIDXFptr_RemainingFiscalMemory  : Result := FRemainingFiscalMemory;
      PIDXFptr_SlpEmpty               : Result := BoolToInt[Printer.SlpEmpty];
      PIDXFptr_SlpNearEnd             : Result := BoolToInt[Printer.SlpNearEnd];
      PIDXFptr_SlipSelection          : Result := FSlipSelection;
      PIDXFptr_TrainingModeActive     : Result := BoolToInt[False];
      PIDXFptr_ActualCurrency         : Result := FActualCurrency;
      PIDXFptr_ContractorId           : Result := FContractorId;
      PIDXFptr_DateType               : Result := FDateType;
      PIDXFptr_FiscalReceiptStation   : Result := FFiscalReceiptStation;
      PIDXFptr_FiscalReceiptType      : Result := FFiscalReceiptType;
      PIDXFptr_MessageType                : Result := FMessageType;
      PIDXFptr_TotalizerType              : Result := FTotalizerType;
      PIDXFptr_CapAdditionalLines         : Result := BoolToInt[FCapAdditionalLines];
      PIDXFptr_CapAmountAdjustment        : Result := BoolToInt[FCapAmountAdjustment];
      PIDXFptr_CapAmountNotPaid           : Result := BoolToInt[FCapAmountNotPaid];
      PIDXFptr_CapCheckTotal              : Result := BoolToInt[FCapCheckTotal];
      PIDXFptr_CapCoverSensor             : Result := BoolToInt[Printer.CapCoverSensor];
      PIDXFptr_CapDoubleWidth             : Result := BoolToInt[FCapDoubleWidth];
      PIDXFptr_CapDuplicateReceipt        : Result := BoolToInt[FCapDuplicateReceipt];
      PIDXFptr_CapFixedOutput             : Result := BoolToInt[FCapFixedOutput];
      PIDXFptr_CapHasVatTable             : Result := BoolToInt[FCapHasVatTable];
      PIDXFptr_CapIndependentHeader       : Result := BoolToInt[FCapIndependentHeader];
      PIDXFptr_CapItemList                : Result := BoolToInt[FCapItemList];
      PIDXFptr_CapJrnEmptySensor          : Result := BoolToInt[Printer.CapJrnEmptySensor];
      PIDXFptr_CapJrnNearEndSensor        : Result := BoolToInt[Printer.CapJrnNearEndSensor];
      PIDXFptr_CapJrnPresent              : Result := BoolToInt[Printer.CapJrnPresent];
      PIDXFptr_CapNonFiscalMode           : Result := BoolToInt[FCapNonFiscalMode];
      PIDXFptr_CapOrderAdjustmentFirst    : Result := BoolToInt[FCapOrderAdjustmentFirst];
      PIDXFptr_CapPercentAdjustment       : Result := BoolToInt[FCapPercentAdjustment];
      PIDXFptr_CapPositiveAdjustment      : Result := BoolToInt[FCapPositiveAdjustment];
      PIDXFptr_CapPowerLossReport         : Result := BoolToInt[FCapPowerLossReport];
      PIDXFptr_CapPredefinedPaymentLines  : Result := BoolToInt[FCapPredefinedPaymentLines];
      PIDXFptr_CapReceiptNotPaid          : Result := BoolToInt[FCapReceiptNotPaid];
      PIDXFptr_CapRecEmptySensor          : Result := BoolToInt[Printer.CapRecEmptySensor];
      PIDXFptr_CapRecNearEndSensor        : Result := BoolToInt[Printer.CapRecNearEndSensor];
      PIDXFptr_CapRecPresent              : Result := BoolToInt[Printer.CapRecPresent];
      PIDXFptr_CapRemainingFiscalMemory   : Result := BoolToInt[FCapRemainingFiscalMemory];
      PIDXFptr_CapReservedWord            : Result := BoolToInt[FCapReservedWord];
      PIDXFptr_CapSetHeader               : Result := BoolToInt[FCapSetHeader];
      PIDXFptr_CapSetPOSID                : Result := BoolToInt[FCapSetPOSID];
      PIDXFptr_CapSetStoreFiscalID        : Result := BoolToInt[FCapSetStoreFiscalID];
      PIDXFptr_CapSetTrailer              : Result := BoolToInt[FCapSetTrailer];
      PIDXFptr_CapSetVatTable             : Result := BoolToInt[FCapSetVatTable];
      PIDXFptr_CapSlpEmptySensor          : Result := BoolToInt[Printer.CapSlpEmptySensor];
      PIDXFptr_CapSlpFiscalDocument       : Result := BoolToInt[FCapSlpFiscalDocument];
      PIDXFptr_CapSlpFullSlip             : Result := BoolToInt[FCapSlpFullSlip];
      PIDXFptr_CapSlpNearEndSensor        : Result := BoolToInt[Printer.CapSlpNearEndSensor];
      PIDXFptr_CapSlpPresent              : Result := BoolToInt[Printer.CapSlpPresent];
      PIDXFptr_CapSlpValidation           : Result := BoolToInt[FCapSlpValidation];
      PIDXFptr_CapSubAmountAdjustment     : Result := BoolToInt[FCapSubAmountAdjustment];
      PIDXFptr_CapSubPercentAdjustment    : Result := BoolToInt[FCapSubPercentAdjustment];
      PIDXFptr_CapSubtotal                : Result := BoolToInt[FCapSubtotal];
      PIDXFptr_CapTrainingMode            : Result := BoolToInt[FCapTrainingMode];
      PIDXFptr_CapValidateJournal         : Result := BoolToInt[FCapValidateJournal];
      PIDXFptr_CapXReport                 : Result := BoolToInt[FCapXReport];
      PIDXFptr_CapAdditionalHeader        : Result := BoolToInt[FCapAdditionalHeader];
      PIDXFptr_CapAdditionalTrailer       : Result := BoolToInt[FCapAdditionalTrailer];
      PIDXFptr_CapChangeDue               : Result := BoolToInt[FCapChangeDue];
      PIDXFptr_CapEmptyReceiptIsVoidable  : Result := BoolToInt[FCapEmptyReceiptIsVoidable];
      PIDXFptr_CapFiscalReceiptStation    : Result := BoolToInt[FCapFiscalReceiptStation];
      PIDXFptr_CapFiscalReceiptType       : Result := BoolToInt[FCapFiscalReceiptType];
      PIDXFptr_CapMultiContractor         : Result := BoolToInt[FCapMultiContractor];
      PIDXFptr_CapOnlyVoidLastItem        : Result := BoolToInt[FCapOnlyVoidLastItem];
      PIDXFptr_CapPackageAdjustment       : Result := BoolToInt[FCapPackageAdjustment];
      PIDXFptr_CapPostPreLine             : Result := BoolToInt[FCapPostPreLine];
      PIDXFptr_CapSetCurrency             : Result := BoolToInt[FCapSetCurrency];
      PIDXFptr_CapTotalizerType           : Result := BoolToInt[FCapTotalizerType];
      PIDXFptr_CapPositiveSubtotalAdjustment: Result := BoolToInt[FCapPositiveSubtotalAdjustment];
    else
      Result := 0;
    end;
  except
    on E: Exception do
    begin
      Result := 0;
      HandleException(E);
    end;
  end;
end;

function TWebkassaImpl.GetPropertyString(PropIndex: Integer): WideString;
begin
  case PropIndex of
    // commmon
    PIDX_CheckHealthText                : Result := FOposDevice.CheckHealthText;
    PIDX_DeviceDescription              : Result := FOposDevice.PhysicalDeviceDescription;
    PIDX_DeviceName                     : Result := FOposDevice.PhysicalDeviceName;
    PIDX_ServiceObjectDescription       : Result := FOposDevice.ServiceObjectDescription;
    // specific
    PIDXFptr_ErrorString                : Result := FOposDevice.ErrorString;
    PIDXFptr_PredefinedPaymentLines     : Result := FPredefinedPaymentLines;
    PIDXFptr_ReservedWord               : Result := FReservedWord;
    PIDXFptr_AdditionalHeader           : Result := FAdditionalHeader;
    PIDXFptr_AdditionalTrailer          : Result := FAdditionalTrailer;
    PIDXFptr_ChangeDue                  : Result := FChangeDue;
    PIDXFptr_PostLine                   : Result := FPostLine;
    PIDXFptr_PreLine                    : Result := FPreLine;
  else
    Result := '';
  end;
end;

function TWebkassaImpl.GetTotalizer(VatID, OptArgs: Integer;
  out Data: WideString): Integer;

  function ReadGrossTotalizer(OptArgs: Integer): Currency;
  begin
    Result := 0;
    case OptArgs of
      FPTR_TT_DOCUMENT: Result := 0;
      FPTR_TT_DAY: Result := ReadDailyTotal;
      FPTR_TT_RECEIPT: Result := Receipt.GetTotal;
      FPTR_TT_GRAND: Result := ReadGrandTotal;
    else
      RaiseIllegalError;
    end;
  end;

begin
  try
    case VatID of
      FPTR_GT_GROSS: Data := AmountToOutStr(ReadGrossTotalizer(OptArgs));
      (*
      FPTR_GT_NET                      =  2;
      FPTR_GT_DISCOUNT                 =  3;
      FPTR_GT_DISCOUNT_VOID            =  4;
      FPTR_GT_ITEM                     =  5;
      FPTR_GT_ITEM_VOID                =  6;
      FPTR_GT_NOT_PAID                 =  7;
      FPTR_GT_REFUND                   =  8;
      FPTR_GT_REFUND_VOID              =  9;
      FPTR_GT_SUBTOTAL_DISCOUNT        =  10;
      FPTR_GT_SUBTOTAL_DISCOUNT_VOID   =  11;
      FPTR_GT_SUBTOTAL_SURCHARGES      =  12;
      FPTR_GT_SUBTOTAL_SURCHARGES_VOID =  13;
      FPTR_GT_SURCHARGE                =  14;
      FPTR_GT_SURCHARGE_VOID           =  15;
      FPTR_GT_VAT                      =  16;
      FPTR_GT_VAT_CATEGORY             =  17;
      *)
    end;

    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.GetVatEntry(VatID, OptArgs: Integer;
  out VatRate: Integer): Integer;
begin
  Result := ClearResult;
end;

function TWebkassaImpl.Open(const DeviceClass, DeviceName: WideString;
  const pDispatch: IDispatch): Integer;
begin
  Result := DoOpen(DeviceClass, DeviceName, pDispatch);
end;

function TWebkassaImpl.OpenService(const DeviceClass,
  DeviceName: WideString; const pDispatch: IDispatch): Integer;
begin
  Result := DoOpen(DeviceClass, DeviceName, pDispatch);
end;

function TWebkassaImpl.PrintDuplicateReceipt: Integer;
begin
  try
    CheckEnabled;
    CheckState(FPTR_PS_MONITOR);
    if FDuplicate.Items.Count > 0 then
    begin
      PrintDocument(FDuplicate);
    end;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.PrintFiscalDocumentLine(
  const DocumentLine: WideString): Integer;
begin
  Result := IllegalError;
end;

function TWebkassaImpl.PrintFixedOutput(DocumentType, LineNumber: Integer;
  const Data: WideString): Integer;
begin
  Result := IllegalError;
end;

function TWebkassaImpl.PrintNormal(Station: Integer;
  const AData: WideString): Integer;
begin
  try
    CheckEnabled;
    CheckState(FPTR_PS_NONFISCAL);
    Document.AddText(AData);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.PrintPeriodicTotalsReport(const Date1,
  Date2: WideString): Integer;
begin
  Result := IllegalError;
end;

function TWebkassaImpl.PrintPowerLossReport: Integer;
begin
  Result := IllegalError;
end;

function TWebkassaImpl.PrintRecCash(Amount: Currency): Integer;
begin
  try
    FReceipt.PrintRecCash(Amount);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.PrintRecItem(const Description: WideString;
  Price: Currency; Quantity, VatInfo: Integer; UnitPrice: Currency;
  const UnitName: WideString): Integer;
begin
  try
    CheckState(FPTR_PS_FISCAL_RECEIPT);
    FReceipt.PrintRecItem(Description, Price, GetQuantity(Quantity), VatInfo,
      UnitPrice, UnitName);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.PrintRecItemAdjustment(AdjustmentType: Integer;
  const Description: WideString; Amount: Currency;
  VatInfo: Integer): Integer;
begin
  try
    CheckState(FPTR_PS_FISCAL_RECEIPT);
    FReceipt.PrintRecItemAdjustment(AdjustmentType, Description, Amount, VatInfo);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.PrintRecItemAdjustmentVoid(AdjustmentType: Integer;
  const Description: WideString; Amount: Currency;
  VatInfo: Integer): Integer;
begin
  try
    CheckState(FPTR_PS_FISCAL_RECEIPT);
    FReceipt.PrintRecItemAdjustmentVoid(AdjustmentType, Description,
      Amount, VatInfo);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.PrintRecItemFuel(const Description: WideString;
  Price: Currency; Quantity, VatInfo: Integer; UnitPrice: Currency;
  const UnitName: WideString; SpecialTax: Currency;
  const SpecialTaxName: WideString): Integer;
begin
  try
    CheckState(FPTR_PS_FISCAL_RECEIPT);
    FReceipt.PrintRecItemFuel(Description, Price, GetQuantity(Quantity), VatInfo,
      UnitPrice, UnitName, SpecialTax, SpecialTaxName);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.PrintRecItemFuelVoid(const Description: WideString;
  Price: Currency; VatInfo: Integer; SpecialTax: Currency): Integer;
begin
  try
    CheckState(FPTR_PS_FISCAL_RECEIPT);
    FReceipt.PrintRecItemFuelVoid(Description, Price, VatInfo, SpecialTax);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.PrintRecItemRefund(const Description: WideString;
  Amount: Currency; Quantity, VatInfo: Integer; UnitAmount: Currency;
  const UnitName: WideString): Integer;
begin
  try
    CheckState(FPTR_PS_FISCAL_RECEIPT);
    FReceipt.PrintRecItemRefund(Description, Amount, GetQuantity(Quantity), VatInfo,
      UnitAmount, UnitName);
   Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.PrintRecItemRefundVoid(
  const Description: WideString; Amount: Currency; Quantity,
  VatInfo: Integer; UnitAmount: Currency;
  const UnitName: WideString): Integer;
begin
  try
    CheckState(FPTR_PS_FISCAL_RECEIPT);
    FReceipt.PrintRecItemRefundVoid(Description, Amount, GetQuantity(Quantity), VatInfo,
      UnitAmount, UnitName);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.PrintRecItemVoid(const Description: WideString;
  Price: Currency; Quantity, VatInfo: Integer; UnitPrice: Currency;
  const UnitName: WideString): Integer;
begin
  try
    CheckState(FPTR_PS_FISCAL_RECEIPT);
    FReceipt.PrintRecItemVoid(Description, Price, GetQuantity(Quantity), VatInfo,
      UnitPrice, UnitName);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.PrintRecMessage(const Message: WideString): Integer;
begin
  try
    CheckEnabled;
    FReceipt.PrintRecMessage(Message);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.PrintRecNotPaid(const Description: WideString;
  Amount: Currency): Integer;
begin
  try
    if not FCapReceiptNotPaid then
      RaiseOposException(OPOS_E_ILLEGAL, _('Not paid receipt is nor supported'));

    if (PrinterState <> FPTR_PS_FISCAL_RECEIPT_ENDING) and
      (PrinterState <> FPTR_PS_FISCAL_RECEIPT_TOTAL) then
      raiseExtendedError(OPOS_EFPTR_WRONG_STATE);

    FReceipt.PrintRecNotPaid(Description, Amount);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.PrintRecPackageAdjustment(AdjustmentType: Integer;
  const Description, VatAdjustment: WideString): Integer;
begin
  try
    CheckState(FPTR_PS_FISCAL_RECEIPT);
    FReceipt.PrintRecPackageAdjustment(AdjustmentType,
      Description, VatAdjustment);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.PrintRecPackageAdjustVoid(AdjustmentType: Integer;
  const VatAdjustment: WideString): Integer;
begin
  try
    CheckState(FPTR_PS_FISCAL_RECEIPT);
    FReceipt.PrintRecPackageAdjustVoid(AdjustmentType, VatAdjustment);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.PrintRecRefund(const Description: WideString;
  Amount: Currency; VatInfo: Integer): Integer;
begin
  try
    CheckState(FPTR_PS_FISCAL_RECEIPT);
    FReceipt.PrintRecRefund(Description, Amount, VatInfo);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.PrintRecRefundVoid(const Description: WideString;
  Amount: Currency; VatInfo: Integer): Integer;
begin
  try
    CheckState(FPTR_PS_FISCAL_RECEIPT);
    FReceipt.PrintRecRefundVoid(Description, Amount, VatInfo);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.PrintRecSubtotal(Amount: Currency): Integer;
begin
  try
    CheckState(FPTR_PS_FISCAL_RECEIPT);
    FReceipt.PrintRecSubtotal(Amount);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.PrintRecSubtotalAdjustment(AdjustmentType: Integer;
  const Description: WideString; Amount: Currency): Integer;
begin
  try
    CheckState(FPTR_PS_FISCAL_RECEIPT);
    FReceipt.PrintRecSubtotalAdjustment(AdjustmentType, Description, Amount);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.PrintRecSubtotalAdjustVoid(AdjustmentType: Integer;
  Amount: Currency): Integer;
begin
  try
    CheckState(FPTR_PS_FISCAL_RECEIPT);
    FReceipt.PrintRecSubtotalAdjustVoid(AdjustmentType, Amount);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.PrintRecTaxID(const TaxID: WideString): Integer;
begin
  try
    CheckState(FPTR_PS_FISCAL_RECEIPT);
    FReceipt.PrintRecTaxID(TaxID);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.PrintRecTotal(Total, Payment: Currency;
  const Description: WideString): Integer;
var
  PaymentType: Integer;
begin
  try
    if (PrinterState <> FPTR_PS_FISCAL_RECEIPT) and
      (PrinterState <> FPTR_PS_FISCAL_RECEIPT_TOTAL) then
      raiseExtendedError(OPOS_EFPTR_WRONG_STATE);

    if FCheckTotal and (FReceipt.GetTotal <> Total) then
    begin
      raiseExtendedError(OPOS_EFPTR_BAD_ITEM_AMOUNT,
        Format('App total %s, but receipt total %s', [
        AmountToStr(Total), AmountToStr(FReceipt.GetTotal)]));
    end;

    PaymentType := StrToIntDef(Description, 0);
    case PaymentType of
      0:;
      1: PaymentType := Params.PaymentType2;
      2: PaymentType := Params.PaymentType3;
      3: PaymentType := Params.PaymentType4;
    else
      PaymentType := PaymentTypeCash;
    end;

    FReceipt.PrintRecTotal(Total, Payment, IntToStr(PaymentType));
    if FReceipt.GetPayment >= FReceipt.GetTotal then
    begin
      SetPrinterState(FPTR_PS_FISCAL_RECEIPT_ENDING);
    end else
    begin
      SetPrinterState(FPTR_PS_FISCAL_RECEIPT_TOTAL);
    end;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.PrintRecVoid(
  const Description: WideString): Integer;
begin
  try
    CheckEnabled;
    if (PrinterState <> FPTR_PS_FISCAL_RECEIPT) and
      (PrinterState <> FPTR_PS_FISCAL_RECEIPT_ENDING) and
      (PrinterState <> FPTR_PS_FISCAL_RECEIPT_TOTAL) then
      raiseExtendedError(OPOS_EFPTR_WRONG_STATE);

    FReceipt.PrintRecVoid(Description);
    SetPrinterState(FPTR_PS_FISCAL_RECEIPT_ENDING);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.PrintRecVoidItem(const Description: WideString;
  Amount: Currency; Quantity, AdjustmentType: Integer;
  Adjustment: Currency; VatInfo: Integer): Integer;
begin
  try
    CheckState(FPTR_PS_FISCAL_RECEIPT);
    FReceipt.PrintRecVoidItem(Description, Amount, GetQuantity(Quantity),
      AdjustmentType, Adjustment, VatInfo);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.PrintReport(ReportType: Integer; const StartNum,
  EndNum: WideString): Integer;
begin
  Result := IllegalError;
end;

function TWebkassaImpl.PrintXReport: Integer;
begin
  try
    CheckState(FPTR_PS_MONITOR);
    SetPrinterState(FPTR_PS_REPORT);
    try
      PrintXZReport(False);
    finally
      SetPrinterState(FPTR_PS_MONITOR);
    end;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

procedure TWebkassaImpl.PrintXZReport(IsZReport: Boolean);
var
  i: Integer;
  Line1: WideString;
  Line2: WideString;
  Text: WideString;
  Total: Currency;
  Separator: WideString;
  Command: TZXReportCommand;

  Json: TlkJSON;
  Doc: TlkJSONbase;
  Node: TlkJSONbase;
  Count: Integer;
  Amount: Currency;
  SellNode: TlkJSONbase;
  OperationsNode: TlkJSONbase;
begin
  CheckCanPrint;

  Json := TlkJSON.Create;
  Command := TZXReportCommand.Create;
  try
    Command.Request.Token := FClient.Token;
    Command.Request.CashboxUniqueNumber := Params.CashboxNumber;
    if IsZReport then
      FClient.ZReport(Command)
    else
      FClient.XReport(Command);

    ClearCashboxStatus;
    Doc := Json.ParseText(FClient.AnswerJson);

    Total :=
      (Command.Data.EndNonNullable.Sell - Command.Data.StartNonNullable.Sell) -
      (Command.Data.EndNonNullable.Buy - Command.Data.StartNonNullable.Buy) -
      (Command.Data.EndNonNullable.ReturnSell - Command.Data.StartNonNullable.ReturnSell) +
      (Command.Data.EndNonNullable.ReturnBuy - Command.Data.StartNonNullable.ReturnBuy);

    BeginDocument(True);
    Separator := StringOfChar('-', Document.LineChars);
    Document.AddLines('»ÕÕ/¡»Õ', Command.Data.CashboxRN);
    Document.AddLines('«ÕÃ', Command.Data.CashboxSN);
    Document.AddLines(' Ó‰   Ã  √ƒ (–ÕÃ)', Command.Data.CashboxRN);
    if IsZReport then
      Document.AddLine(Document.AlignCenter('Z-Œ“◊≈“'))
    else
      Document.AddLine(Document.AlignCenter('X-Œ“◊≈“'));
    Document.AddLine(Document.AlignCenter(Format('—Ã≈Õ¿ π%d', [Command.Data.ShiftNumber])));
    Document.AddLine(Document.AlignCenter(Format('%s-%s', [Command.Data.StartOn, Command.Data.ReportOn])));
    Node := Doc.Get('Data').Get('Sections');
    if Node.Count > 0 then
    begin
      Document.AddLine(Separator);
      Document.AddLine(Document.AlignCenter('Œ“◊≈“ œŒ —≈ ÷»ﬂÃ'));
      Document.AddLine(Separator);
      for i := 0 to Node.Count-1 do
      begin
        Count := Node.Child[i].Get('Code').Value;
        Document.AddLines('—≈ ÷»ﬂ', IntToStr(Count + 1));
        OperationsNode := Node.Child[i].Field['Operations'];
        if OperationsNode <> nil then
        begin
          SellNode := OperationsNode.Field['Sell'];
          if SellNode <> nil then
          begin
            Count := SellNode.Get('Count').Value;
            Amount := SellNode.Get('Amount').Value;
            Document.AddLines(Format('%.4d œ–Œƒ¿∆', [Count]), AmountToStr(Amount));
          end;
        end;
      end;
    end;
    Document.AddLine(Separator);
    if IsZReport then
      Document.AddLine(Document.AlignCenter('Œ“◊≈“ — √¿ÿ≈Õ»≈Ã'))
    else
      Document.AddLine(Document.AlignCenter('Œ“◊≈“ ¡≈« √¿ÿ≈Õ»ﬂ'));
    Document.AddLine(Separator);
    Document.AddLine('Õ≈Œ¡Õ”À. —”ÃÃ€ Õ¿ Õ¿◊¿ÀŒ —Ã≈Õ€');
    Document.AddLines('œ–Œƒ¿∆', AmountToStr(Command.Data.StartNonNullable.Sell));
    Document.AddLines('œŒ ”œŒ ', AmountToStr(Command.Data.StartNonNullable.Buy));
    Document.AddLines('¬Œ«¬–¿“Œ¬ œ–Œƒ¿∆', AmountToStr(Command.Data.StartNonNullable.ReturnSell));
    Document.AddLines('¬Œ«¬–¿“Œ¬ œŒ ”œŒ ', AmountToStr(Command.Data.StartNonNullable.ReturnBuy));

    Document.AddLine('◊≈ Œ¬ œ–Œƒ¿∆');
    Line1 := Format('%.4d', [Command.Data.Sell.Count]);
    Line2 := AmountToStr(Total);
    Text := Line1 + StringOfChar(' ', (Document.LineChars div 2)-Length(Line1)-Length(Line2)) + Line2;
    Document.AddLine(Text, STYLE_DWIDTH_HEIGHT);
    AddPayments(Document, Command.Data.Sell.PaymentsByTypesApiModel);

    Document.AddLine('◊≈ Œ¬ œŒ ”œŒ ');
    Line1 := Format('%.4d', [Command.Data.Buy.Count]);
    Line2 := AmountToStr(Command.Data.Buy.Taken);
    Text := Line1 + StringOfChar(' ', (Document.LineChars div 2)-Length(Line1)-Length(Line2)) + Line2;
    Document.AddLine(Text, STYLE_DWIDTH_HEIGHT);
    AddPayments(Document, Command.Data.Buy.PaymentsByTypesApiModel);

    Document.AddLine('◊≈ Œ¬ ¬Œ«¬–¿“Œ¬ œ–Œƒ¿∆');
    Line1 := Format('%.4d', [Command.Data.ReturnSell.Count]);
    Line2 := AmountToStr(Command.Data.ReturnSell.Taken);
    Text := Line1 + StringOfChar(' ', (Document.LineChars div 2)-Length(Line1)-Length(Line2)) + Line2;
    Document.AddLine(Text, STYLE_DWIDTH_HEIGHT);
    AddPayments(Document, Command.Data.ReturnSell.PaymentsByTypesApiModel);

    Document.AddLine('◊≈ Œ¬ ¬Œ«¬–¿“Œ¬ œŒ ”œŒ ');
    Line1 := Format('%.4d', [Command.Data.ReturnBuy.Count]);
    Line2 := AmountToStr(Command.Data.ReturnBuy.Taken);
    Text := Line1 + StringOfChar(' ', (Document.LineChars div 2)-Length(Line1)-Length(Line2)) + Line2;
    Document.AddLine(Text, STYLE_DWIDTH_HEIGHT);
    AddPayments(Document, Command.Data.ReturnBuy.PaymentsByTypesApiModel);

    Document.AddLine('¬Õ≈—≈Õ»…');
    Node := Doc.Get('Data').Get('MoneyPlacementOperations').Get('Deposit');
    Count := Node.Get('Count').Value;
    Amount := Node.Get('Amount').Value;
    Document.AddLines(Format('%.4d', [Count]), AmountToStr(Amount));
    Document.AddLine('»«⁄ﬂ“»…');
    Node := Doc.Get('Data').Get('MoneyPlacementOperations').Get('WithDrawal');
    Count := Node.Get('Count').Value;
    Amount := Node.Get('Amount').Value;
    Document.AddLines(Format('%.4d', [Count]), AmountToStr(Amount));

    Document.AddLines('Õ¿À»◊Õ€’ ¬  ¿——≈', AmountToStr(Command.Data.SumInCashbox));
    Document.AddLines('¬€–”◊ ¿', AmountToStr(Total));
    Document.AddLine('Õ≈Œ¡Õ”À. —”ÃÃ€ Õ¿  ŒÕ≈÷ —Ã≈Õ€');
    Document.AddLines('œ–Œƒ¿∆', AmountToStr(Command.Data.EndNonNullable.Sell));
    Document.AddLines('œŒ ”œŒ ', AmountToStr(Command.Data.EndNonNullable.Buy));
    Document.AddLines('¬Œ«¬–¿“Œ¬ œ–Œƒ¿∆', AmountToStr(Command.Data.EndNonNullable.ReturnSell));
    Document.AddLines('¬Œ«¬–¿“Œ¬ œŒ ”œŒ ', AmountToStr(Command.Data.EndNonNullable.ReturnBuy));
    Document.AddLines('—‘ÓÏËÓ‚‡ÌÓ Œ‘ƒ: ', Command.Data.Ofd.Name);
    PrintDocumentSafe(Document);
  finally
    Command.Free;
    Json.Free;
  end;
end;

procedure TWebkassaImpl.AddPayments(Document: TTextDocument; Payments: TPaymentsByType);
var
  i: Integer;
  Payment: TPaymentByType;
begin
  for i := 0 to Payments.Count-1 do
  begin
    Payment := Payments[i];
    Document.AddLines(GetPaymentName(Payment._Type), AmountToStr(Payment.Sum));
  end;
end;

function TWebkassaImpl.PrintZReport: Integer;
begin
  try
    CheckState(FPTR_PS_MONITOR);
    SetPrinterState(FPTR_PS_REPORT);
    try
      PrintXZReport(True);
    finally
      SetPrinterState(FPTR_PS_MONITOR);
    end;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.Release1: Integer;
begin
  Result := DoRelease;
end;

function TWebkassaImpl.ReleaseDevice: Integer;
begin
  Result := DoRelease;
end;

function TWebkassaImpl.ResetPrinter: Integer;
begin
  try
    CheckEnabled;
    SetPrinterState(FPTR_PS_MONITOR);
    FReceipt.Free;
    FReceipt := TCustomReceipt.Create;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.ResetStatistics(
  const StatisticsBuffer: WideString): Integer;
begin
  Result := IllegalError;
end;

function TWebkassaImpl.RetrieveStatistics(
  var pStatisticsBuffer: WideString): Integer;
begin
  Result := IllegalError;
end;

function TWebkassaImpl.SetCurrency(NewCurrency: Integer): Integer;
begin
  try
    CheckEnabled;
    Result := IllegalError;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.SetDate(const Date: WideString): Integer;
begin
  try
    CheckEnabled;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.SetHeaderLine(LineNumber: Integer;
  const Text: WideString; DoubleWidth: WordBool): Integer;
var
  LineText: WideString;
begin
  try
    CheckEnabled;

    if (LineNumber <= 0)or(LineNumber > Params.NumHeaderLines) then
      raiseIllegalError('Invalid line number');

    LineText := Text;
    if DoubleWidth then
      LineText := ESC_DoubleWide + LineText;

    FParams.Header[LineNumber-1] := LineText;
    SaveUsrParameters(FParams, FOposDevice.DeviceName, FLogger);

    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.SetPOSID(const POSID,
  CashierID: WideString): Integer;
begin
  FPOSID := POSID;
  FCashierID := CashierID;
  Result := ClearResult;
end;

procedure TWebkassaImpl.SetPropertyNumber(PropIndex, Number: Integer);
begin
  try
    case PropIndex of
      // common
      PIDX_DeviceEnabled:
        SetDeviceEnabled(IntToBool(Number));

      PIDX_DataEventEnabled:
        FOposDevice.DataEventEnabled := IntToBool(Number);

      PIDX_PowerNotify:
      begin
        FOposDevice.PowerNotify := Number;
        Printer.PowerNotify := Number;
      end;

      PIDX_BinaryConversion:
      begin
        FOposDevice.BinaryConversion := Number;
        Printer.BinaryConversion := Number;
      end;

      // Specific
      PIDXFptr_AsyncMode:
      begin
        FAsyncMode := IntToBool(Number);
        Printer.AsyncMode := IntToBool(Number);
      end;

      PIDXFptr_CheckTotal: FCheckTotal := IntToBool(Number);
      PIDXFptr_DateType: FDateType := Number;
      PIDXFptr_DuplicateReceipt: FDuplicateReceipt := IntToBool(Number);
      PIDXFptr_FiscalReceiptStation: FFiscalReceiptStation := Number;

      PIDXFptr_FiscalReceiptType:
      begin
        CheckState(FPTR_PS_MONITOR);
        FFiscalReceiptType := Number;
      end;
      PIDXFptr_FlagWhenIdle:
      begin
        FFlagWhenIdle := IntToBool(Number);
        Printer.FlagWhenIdle  := IntToBool(Number);
      end;
      PIDXFptr_MessageType:
        FMessageType := Number;
      PIDXFptr_SlipSelection:
        FSlipSelection := Number;
      PIDXFptr_TotalizerType:
        FTotalizerType := Number;
      PIDX_FreezeEvents:
      begin
        FOposDevice.FreezeEvents := Number <> 0;
        Printer.FreezeEvents := Number <> 0;
      end;
    end;

    ClearResult;
  except
    on E: Exception do
      HandleException(E);
  end;
end;

procedure TWebkassaImpl.SetPropertyString(PropIndex: Integer;
  const Text: WideString);
begin
  try
    FOposDevice.CheckOpened;
    case PropIndex of
      PIDXFptr_AdditionalHeader   : FAdditionalHeader := Text;
      PIDXFptr_AdditionalTrailer  : FAdditionalTrailer := Text;
      PIDXFptr_PostLine           : FPostLine := Text;
      PIDXFptr_PreLine            : FPreLine := Text;
      PIDXFptr_ChangeDue          : FChangeDue := Text;
    end;
    ClearResult;
  except
    on E: Exception do
      HandleException(E);
  end;
end;

function TWebkassaImpl.SetStoreFiscalID(const ID: WideString): Integer;
begin
  try
    CheckEnabled;
    Result := IllegalError;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.SetTrailerLine(LineNumber: Integer;
  const Text: WideString; DoubleWidth: WordBool): Integer;
var
  LineText: WideString;
begin
  try
    CheckEnabled;
    if (LineNumber <= 0)or(LineNumber > Params.NumTrailerLines) then
      raiseIllegalError('Invalid line number');

    LineText := Text;
    if DoubleWidth then
      LineText := ESC_DoubleWide + LineText;

    Params.Trailer[LineNumber-1] := LineText;
    SaveUsrParameters(FParams, FOposDevice.DeviceName, FLogger);

    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.SetVatTable: Integer;
begin
  try
    CheckEnabled;
    CheckCapSetVatTable;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.SetVatValue(VatID: Integer;
  const VatValue: WideString): Integer;
var
  VatValueInt: Integer;
begin
  try
    CheckEnabled;
    CheckCapSetVatTable;

    // There are 6 taxes in Shtrih-M ECRs available
    if (VatID < MinVatID)or(VatID > MaxVatID) then
      InvalidParameterValue('VatID', IntToStr(VatID));

    VatValueInt := StrToInt(VatValue);
    if VatValueInt < MinVatValue then
      InvalidParameterValue('VatValue', VatValue);

    if VatValueInt > MaxVatValue then
      InvalidParameterValue('VatValue', VatValue);

    FVatValues[VatID] := VatValueInt;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.UpdateFirmware(
  const FirmwareFileName: WideString): Integer;
begin
  try
    CheckEnabled;
    Result := IllegalError;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.UpdateStatistics(
  const StatisticsBuffer: WideString): Integer;
begin
  try
    CheckEnabled;
    Result := IllegalError;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.VerifyItem(const ItemName: WideString;
  VatID: Integer): Integer;
begin
  Result := IllegalError;
end;

procedure TWebkassaImpl.CheckPtr(AResultCode: Integer);
begin
  if AResultCode <> OPOS_SUCCESS then
  begin
    raise EOPOSException.Create(Printer.ErrorString,
      Printer.ResultCode, Printer.ResultCodeExtended);
  end;
end;

procedure TWebkassaImpl.PrinterStatusUpdateEvent(ASender: TObject; Data: Integer);
begin
  Logger.Debug(Format('StatusUpdateEvent: %d, %s', [
    Data, PtrStatusUpdateEventText(Data)]));

  if IsValidOposStatusUpdateEvent(Data) or IsValidFptrStatusUpdateEvent(Data) then
  begin
    OposDevice.StatusUpdateEvent(Data);
  end;
end;

procedure TWebkassaImpl.PrinterErrorEvent(ASender: TObject; ResultCode: Integer;
  ResultCodeExtended: Integer; ErrorLocus: Integer; var pErrorResponse: Integer);
begin
  Logger.Debug(Format('PtrErrorEvent: %d, %d, %d', [
    ResultCode, ResultCodeExtended, ErrorLocus]));
end;

procedure TWebkassaImpl.PrinterDirectIOEvent(ASender: TObject; EventNumber: Integer;
  var pData: Integer; var pString: WideString);
begin
  Logger.Debug(Format('PtrDirectIOEvent: %d, %d, %s', [
    EventNumber, pData, pString]));
end;

procedure TWebkassaImpl.PrinterOutputCompleteEvent(ASender: TObject; OutputID: Integer);
begin
  Logger.Debug(Format('PtrOutputCompleteEvent: %d', [OutputID]));
end;

function TWebkassaImpl.DoOpen(const DeviceClass, DeviceName: WideString;
  const pDispatch: IDispatch): Integer;
begin
  try
    Initialize;
    FOposDevice.Open(DeviceClass, DeviceName, GetEventInterface(pDispatch));
    if FLoadParamsEnabled then
    begin
      LoadParameters(FParams, DeviceName, FLogger);
    end;

    Logger.MaxCount := FParams.LogMaxCount;
    Logger.Enabled := FParams.LogFileEnabled;
    Logger.FilePath := FParams.LogFilePath;
    Logger.DeviceName := DeviceName;

    FClient.Login := FParams.Login;
    FClient.Password := FParams.Password;
    FClient.ConnectTimeout := FParams.ConnectTimeout;
    FClient.Address := FParams.WebkassaAddress;
    FClient.CashboxNumber := FParams.CashboxNumber;
    FClient.RegKeyName := TPrinterParametersReg.GetUsrKeyName(DeviceName);
    if FLoadParamsEnabled then
    begin
      FClient.LoadParams;
    end;

    if FPrinter = nil then
    begin
      FPrinter := CreatePrinter;
    end;
    CheckPtr(Printer.Open(FParams.PrinterName));
    FOposDevice.CapPowerReporting := Printer.CapPowerReporting;

    Logger.Debug(Logger.Separator);
    Logger.Debug('LOG START');
    Logger.Debug(FOposDevice.ServiceObjectDescription);
    Logger.Debug('ServiceObjectVersion : ' + IntToStr(FOposDevice.ServiceObjectVersion));
    Logger.Debug('File version         : ' + GetFileVersionInfoStr);
    Logger.Debug('System               : ' + GetSystemVersionStr);
    Logger.Debug('System locale        : ' + GetSystemLocaleStr);
    Logger.Debug(Logger.Separator);
    FParams.WriteLogParameters;

    FQuantityDecimalPlaces := 3;
    Result := ClearResult;
  except
    on E: Exception do
    begin
      DoCloseDevice;
      Result := HandleException(E);
    end;
  end;
end;

function TWebkassaImpl.CreatePrinter: IOPOSPOSPrinter;
var
  POSPrinter: TOPOSPOSPrinter;
  PosWinPrinter: TPosWinPrinter;
  PosEscPrinter: TPosEscPrinter;
  PrinterPort: IPrinterPort;
  SocketParams: TSocketParams;
begin
  FPrinterObj.Free;
  case Params.PrinterType of
    PrinterTypePosPrinter:
    begin
      PosPrinter := TOPOSPOSPrinter.Create(nil);
      PosPrinter.OnStatusUpdateEvent := PrinterStatusUpdateEvent;
      PosPrinter.OnErrorEvent := PrinterErrorEvent;
      PosPrinter.OnDirectIOEvent := PrinterDirectIOEvent;
      PosPrinter.OnOutputCompleteEvent := PrinterOutputCompleteEvent;
      FPrinterLog := TPosPrinterLog.Create2(nil, PosPrinter.ControlInterface, Logger);
      FPrinterObj := FPrinterLog;
      Result := FPrinterLog;
    end;
    PrinterTypeWinPrinter:
    begin
      PosWinPrinter := TPosWinPrinter.Create2(nil, Logger);
      PosWinPrinter.FontName := Params.FontName;
      FPrinterObj := PosWinPrinter;
      Result := PosWinPrinter;
    end;
    PrinterTypeEscPrinterSerial:
    begin
      PrinterPort := CreateSerialPort;
      PosEscPrinter := TPosEscPrinter.Create2(nil, PrinterPort, Logger);
      PosEscPrinter.OnStatusUpdateEvent := PrinterStatusUpdateEvent;
      PosEscPrinter.OnErrorEvent := PrinterErrorEvent;
      PosEscPrinter.OnDirectIOEvent := PrinterDirectIOEvent;
      PosEscPrinter.OnOutputCompleteEvent := PrinterOutputCompleteEvent;
      PosEscPrinter.FontName := Params.FontName;
      PosEscPrinter.DevicePollTime := Params.DevicePollTime;
      FPrinterObj := PosEscPrinter;
      Result := PosEscPrinter;
    end;
    PrinterTypeEscPrinterNetwork:
    begin
      SocketParams.RemoteHost := Params.RemoteHost;
      SocketParams.RemotePort := Params.RemotePort;
      SocketParams.ByteTimeout := Params.ByteTimeout;
      SocketParams.MaxRetryCount := 1;
      PrinterPort := TSocketPort.Create(SocketParams, Logger);
      PosEscPrinter := TPosEscPrinter.Create2(nil, PrinterPort, Logger);
      PosEscPrinter.OnStatusUpdateEvent := PrinterStatusUpdateEvent;
      PosEscPrinter.OnErrorEvent := PrinterErrorEvent;
      PosEscPrinter.OnDirectIOEvent := PrinterDirectIOEvent;
      PosEscPrinter.OnOutputCompleteEvent := PrinterOutputCompleteEvent;
      PosEscPrinter.FontName := Params.FontName;
      PosEscPrinter.DevicePollTime := Params.DevicePollTime;
      FPrinterObj := PosEscPrinter;
      Result := PosEscPrinter;
    end;
    PrinterTypeEscPrinterWindows:
    begin
      PrinterPort := TRawPrinterPort.Create(Logger, Params.PrinterName);
      PosEscPrinter := TPosEscPrinter.Create2(nil, PrinterPort, Logger);
      PosEscPrinter.OnStatusUpdateEvent := PrinterStatusUpdateEvent;
      PosEscPrinter.OnErrorEvent := PrinterErrorEvent;
      PosEscPrinter.OnDirectIOEvent := PrinterDirectIOEvent;
      PosEscPrinter.OnOutputCompleteEvent := PrinterOutputCompleteEvent;
      PosEscPrinter.FontName := Params.FontName;
      PosEscPrinter.DevicePollTime := Params.DevicePollTime;
      FPrinterObj := PosEscPrinter;
      Result := PosEscPrinter;
    end;
  end;
end;

function TWebkassaImpl.CreateSerialPort: TSerialPort;
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

function TWebkassaImpl.DoCloseDevice: Integer;
begin
  try
    Result := ClearResult;
    if not FOposDevice.Opened then Exit;

    SetDeviceEnabled(False);
    FOposDevice.Close;
    Printer.Close;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TWebkassaImpl.GetEventInterface(FDispatch: IDispatch): IOposEvents;
begin
  Result := TOposEventsRCS.Create(FDispatch);
end;

function TWebkassaImpl.HandleException(E: Exception): Integer;
var
  OPOSError: TOPOSError;
  OPOSException: EOPOSException;
begin
  if E is EDriverError then
  begin
    OPOSError := HandleDriverError(E as EDriverError);
    FOposDevice.HandleException(OPOSError);
    Result := OPOSError.ResultCode;
    Exit;
  end;

  if E is EOPOSException then
  begin
    OPOSException := E as EOPOSException;
    OPOSError.ErrorString := GetExceptionMessage(E);
    OPOSError.ResultCode := OPOSException.ResultCode;
    OPOSError.ResultCodeExtended := OPOSException.ResultCodeExtended;
    FOposDevice.HandleException(OPOSError);
    Result := OPOSError.ResultCode;
    Exit;
  end;

  OPOSError.ErrorString := GetExceptionMessage(E);
  OPOSError.ResultCode := OPOS_E_FAILURE;
  OPOSError.ResultCodeExtended := OPOS_SUCCESS;
  FOposDevice.HandleException(OPOSError);
  Result := OPOSError.ResultCode;
end;

function GetMaxRecLine(const RecLineCharsList: WideString): Integer;
var
  S: WideString;
  K: Integer;
  N: Integer;
begin
  K := 1;
  Result := 0;
  while true do
  begin
    S := GetString(RecLineCharsList, K, [',']);
    if S = '' then Break;
    N := StrToIntDef(S, 0);
    if N > Result then
      Result := N;
    Inc(K);
  end;
end;

procedure TWebkassaImpl.SetDeviceEnabled(Value: Boolean);

  function IsCharacterSetSupported(const CharacterSetList: string;
    CharacterSet: Integer): Boolean;
  begin
    Result := Pos(IntToStr(CharacterSet), CharacterSetList) <> 0;
  end;

var
  CharacterSetList: WideString;
begin
  if Value <> FDeviceEnabled then
  begin
    if Value then
    begin
      FParams.CheckPrameters;
      FClient.Connect;
      UpdateCashBoxes;
      UpdateCashiers;
      UpdateUnits;

      Printer.DeviceEnabled := True;
      CheckPtr(Printer.ResultCode);

      CharacterSetList := Printer.CharacterSetList;
      if IsCharacterSetSupported(CharacterSetList, PTR_CS_UNICODE) then
      begin
        Printer.CharacterSet := PTR_CS_UNICODE;
      end else
      begin
        if IsCharacterSetSupported(CharacterSetList, PTR_CS_WINDOWS) then
          Printer.CharacterSet := PTR_CS_WINDOWS;
      end;

      FPtrMapCharacterSet := Printer.CapMapCharacterSet;
      if FPtrMapCharacterSet then
        Printer.MapCharacterSet := True;

      if Params.RecLineChars <> 0 then
      begin
        Printer.RecLineChars := Params.RecLineChars;
      end;
      if Params.LineSpacing >= 0 then
      begin
        Printer.RecLineSpacing := Params.LineSpacing;
      end;
      if Params.RecLineHeight <> 0 then
      begin
        Printer.RecLineHeight := Params.RecLineHeight;
      end;
    end else
    begin
      FClient.Disconnect;
      Printer.DeviceEnabled := False;
    end;
    FDeviceEnabled := Value;
    FUnitsUpdated := False;
    FCashBoxesUpdated := False;
    FOposDevice.DeviceEnabled := Value;
  end;
end;

function TWebkassaImpl.HandleDriverError(E: EDriverError): TOPOSError;
begin
  Result.ResultCode := OPOS_E_EXTENDED;
  Result.ErrorString := GetExceptionMessage(E);
  if E.ErrorCode = 11 then
  begin
    Result.ResultCodeExtended := OPOS_EFPTR_DAY_END_REQUIRED;
  end else
  begin
    Result.ResultCodeExtended := 300 + E.ErrorCode;
  end;
end;

procedure TWebkassaImpl.Print(Receipt: TCashInReceipt);
var
  Command: TMoneyOperationCommand;
begin
  Command := TMoneyOperationCommand.Create;
  try
    Command.Request.Token := FClient.Token;
    Command.Request.CashboxUniqueNumber := Params.CashboxNumber;
    Command.Request.OperationType := OperationTypeCashIn;
    Command.Request.Sum := Receipt.GetTotal;
    Command.Request.ExternalCheckNumber := FExternalCheckNumber;
    FClient.Execute(Command);
    // Create Document
    Document.AddLine('¡»Õ ' + Command.Data.Cashbox.RegistrationNumber);
    Document.AddLine(Format('«ÕÃ %s »Õ  Œ‘ƒ %s', [Command.Data.Cashbox.UniqueNumber,
      Command.Data.Cashbox.IdentityNumber]));
    Document.AddLine('ƒ‡Ú‡: ' + Command.Data.DateTime);
    Document.AddText(Receipt.Lines.Text);
    Document.AddLines('¬Õ≈—≈Õ»≈ ƒ≈Õ≈√ ¬  ¿——”', AmountToStrEq(Receipt.GetTotal), STYLE_BOLD);
    Document.AddLines('Õ¿À»◊Õ€’ ¬  ¿——≈', AmountToStrEq(Command.Data.Sum), STYLE_BOLD);
    Document.AddText(Receipt.Trailer.Text);
    // Print
    PrintDocumentSafe(Document);
  finally
    Command.Free;
  end;
end;

procedure TWebkassaImpl.Print(Receipt: TCashOutReceipt);
var
  Command: TMoneyOperationCommand;
begin
  Command := TMoneyOperationCommand.Create;
  try
    Command.Request.Token := FClient.Token;
    Command.Request.CashboxUniqueNumber := Params.CashboxNumber;
    Command.Request.OperationType := OperationTypeCashOut;
    Command.Request.Sum := Receipt.GetTotal;
    Command.Request.ExternalCheckNumber := FExternalCheckNumber;
    FClient.Execute(Command);
    //
    Document.AddLine('¡»Õ ' + Command.Data.Cashbox.RegistrationNumber);
    Document.AddLine(Format('«ÕÃ %s »Õ  Œ‘ƒ %s', [Command.Data.Cashbox.UniqueNumber,
      Command.Data.Cashbox.IdentityNumber]));
    Document.AddLine('ƒ‡Ú‡: ' + Command.Data.DateTime);
    Document.AddText(Receipt.Lines.Text);
    Document.AddLines('»«⁄ﬂ“»≈ ƒ≈Õ≈√ »«  ¿——€', AmountToStrEq(Receipt.GetTotal), STYLE_BOLD);
    Document.AddLines('Õ¿À»◊Õ€’ ¬  ¿——≈', AmountToStrEq(Command.Data.Sum), STYLE_BOLD);
    Document.AddText(Receipt.Trailer.Text);
    // print
    PrintDocumentSafe(Document);
  finally
    Command.Free;
  end;
end;

function TWebkassaImpl.GetUnitCode(const UnitName: WideString): Integer;
var
  i: Integer;
  Item: TUnitItem;
begin
  UpdateUnits;

  Result := 0;
  for i := 0 to FUnits.Count-1 do
  begin
    Item := FUnits.Items[i] as TUnitItem;
    if AnsiCompareText(UnitName, Item.NameRu) = 0 then
    begin
      Result := Item.Code;
      Break;
    end;
    if AnsiCompareText(UnitName, Item.NameKz) = 0 then
    begin
      Result := Item.Code;
      Break;
    end;
    if AnsiCompareText(UnitName, Item.NameEn) = 0 then
    begin
      Result := Item.Code;
      Break;
    end;
  end;
end;

procedure TWebkassaImpl.UpdateUnits;
var
  Command: TReadUnitsCommand;
begin
  if FUnitsUpdated then Exit;
  Command := TReadUnitsCommand.Create;
  try
    Command.Request.Token := FClient.Token;
    FClient.ReadUnits(Command);
    FUnits.Assign(Command.Data);
    FUnitsUpdated := True;
  finally
    Command.FRee;
  end;
end;

procedure TWebkassaImpl.UpdateCashBoxes;
var
  ACashBox: TCashBox;
  Command: TCashboxesCommand;
begin
  if FCashBoxesUpdated then Exit;
  Command := TCashboxesCommand.Create;
  try
    Command.Request.Token := FClient.Token;
    FClient.ReadCashBoxes(Command);
    FCashBoxes.Assign(Command.Data.List);
    ACashBox := FCashBoxes.ItemByUniqueNumber(Params.CashboxNumber);
    if ACashBox <> nil then
    begin
      FCashBox.Assign(ACashBox);
    end;

    FCashBoxesUpdated := True;
  finally
    Command.FRee;
  end;
end;

procedure TWebkassaImpl.UpdateCashiers;
var
  ACashier: TCashier;
  Command: TCashierCommand;
begin
  if FCashiersUpdated then Exit;
  Command := TCashierCommand.Create;
  try
    Command.Request.Token := FClient.Token;
    FClient.ReadCashiers(Command);
    FCashiers.Assign(Command.Data);
    ACashier := FCashiers.ItemByEMail(Params.Login);
    if ACashier <> nil then
    begin
      FCashier.Assign(ACashier);
    end;
    FCashiersUpdated := True;
  finally
    Command.FRee;
  end;
end;

function TWebkassaImpl.GetVatRate(Code: Integer): TVatRate;
begin
  Result := nil;
  if Params.VatRateEnabled then
  begin
    Result := Params.VatRates.ItemByCode(Code);
  end;
end;

procedure TWebkassaImpl.Print(Receipt: TSalesReceipt);

  function RecTypeToOperationType(RecType: TRecType): Integer;
  begin
    case RecType of
      rtBuy    : Result := OperationTypeBuy;
      rtRetBuy : Result := OperationTypeRetBuy;
      rtSell   : Result := OperationTypeSell;
      rtRetSell: Result := OperationTypeRetSell;
    else
      raise Exception.CreateFmt('Invalid receipt type, %d', [Ord(RecType)]);
    end;
  end;

var
  i: Integer;
  Payment: TPayment;
  Adjustment: TAdjustment;
  VatRate: TVatRate;
  Item: TSalesReceiptItem;
  ReceiptItem: TReceiptItem;
  Position: TTicketItem;
  Modifier: TTicketModifier;
  Command: TSendReceiptCommand;
begin
  Command := TSendReceiptCommand.Create;
  try
    Command.Request.Token := FClient.Token;
    Command.Request.CashboxUniqueNumber := Params.CashboxNumber;
    Command.Request.OperationType := RecTypeToOperationType(Receipt.RecType);
    Command.Request.Change := Receipt.Change;
    Command.Request.RoundType := FParams.RoundType;
    Command.Request.ExternalCheckNumber := FExternalCheckNumber;
    Command.Request.CustomerEmail := Receipt.CustomerEmail;
    Command.Request.CustomerPhone := Receipt.CustomerPhone;
    Command.Request.CustomerXin := Receipt.CustomerINN;

    // Items
    for i := 0 to Receipt.Items.Count-1 do
    begin
      ReceiptItem := Receipt.Items[i];
      if ReceiptItem is TSalesReceiptItem then
      begin
        Item := ReceiptItem as TSalesReceiptItem;

        VatRate := GetVatRate(Item.VatInfo);
        Position := Command.Request.Positions.Add as TTicketItem;
        if Item.UnitPrice <> 0 then
        begin
          Position.Count := Item.Quantity;
          Position.Price := Item.UnitPrice;
        end else
        begin
          Position.Count := 1;
          Position.Price := Item.Price;
        end;
        Position.PositionName := Item.Description;
        Position.DisplayName := Item.Description;
        Position.PositionCode := IntToStr(i+1);
        Position.Discount := Abs(Item.GetDiscount.Amount);
        Position.Markup := Abs(Item.GetCharge.Amount);
        Position.IsStorno := False;
        Position.MarkupDeleted := False;
        Position.DiscountDeleted := False;
        Position.UnitCode := GetUnitCode(Item.UnitName);
        Position.SectionCode := 0;
        Position.Mark := Item.MarkCode;
        Position.GTIN := '';
        Position.Productld := 0;
        Position.WarehouseType := 0;
        if VatRate = nil then
        begin
          Position.Tax := 0;
          Position.TaxPercent := 0;
          Position.TaxType := TaxTypeNoTax;
        end else
        begin
          Position.Tax := Abs(VatRate.GetTax(Item.GetTotalAmount(Params.RoundType)));
          Position.TaxType := TaxTypeVAT;
          Position.TaxPercent := VatRate.Rate;
        end;
      end;
    end;
    // Discounts
    for i := 0 to Receipt.Discounts.Count-1 do
    begin
      Adjustment := Receipt.Discounts[i];
      Modifier := Command.Request.TicketModifiers.Add as TTicketModifier;

      Modifier.Sum := Abs(Adjustment.Total);
      Modifier.Text := Adjustment.Description;
      Modifier._Type := ModifierTypeDiscount;
      Modifier.TaxType := TaxTypeNoTax;
      Modifier.Tax := 0;
    end;
    // Charges
    for i := 0 to Receipt.Charges.Count-1 do
    begin
      Adjustment := Receipt.Charges[i];
      Modifier := Command.Request.TicketModifiers.Add as TTicketModifier;

      Modifier.Sum := Abs(Adjustment.Total);
      Modifier.Text := Adjustment.Description;
      Modifier._Type := ModifierTypeCharge;
      Modifier.TaxType := TaxTypeNoTax;
      Modifier.Tax := 0;
    end;
    // Payments
    for i := Low(Receipt.Payments) to High(Receipt.Payments) do
    begin
      if Receipt.Payments[i] <> 0 then
      begin
        Payment := Command.Request.Payments.Add as TPayment;
        Payment.PaymentType := i;
        Payment.Sum := Receipt.Payments[i];
      end;
    end;
    FClient.SendReceipt(Command);
    FCheckNumber := Command.Data.CheckNumber;

    if Params.TemplateEnabled then
    begin
      Receipt.ReguestJson := FClient.CommandJson;
      Receipt.AnswerJson := FClient.AnswerJson;
      Receipt.ReceiptJson := ReadReceiptJson(Command.Data.ShiftNumber, Command.Data.CheckNumber);
      PrintReceiptTemplate(Receipt, Params.Template);
    end else
    begin
      PrintReceipt(Receipt, Command);
    end;
    PrintDocumentSafe(Document);
    Printer.RecLineChars := Params.RecLineChars;
  finally
    Command.Free;
  end;
end;

function TWebkassaImpl.ReadReceiptJson(ShiftNumber: Integer;
  const CheckNumber: WideString): WideString;
var
  Command: TReceiptCommand;
begin
  if FTestMode then
  begin
    Result := FReceiptJson;
    Exit;
  end;

  Command := TReceiptCommand.Create;
  try
    Command.Request.Token := Client.Token;
    Command.Request.CashboxUniqueNumber := Params.CashboxNumber;
    Command.Request.Number := CheckNumber;
    Command.Request.ShiftNumber := ShiftNumber;
    FClient.ReadReceipt(Command);
    Result := FClient.AnswerJson;
  finally
    Command.Free;
  end;
end;

function GetPaperKind(WidthInDots: Integer): Integer;
begin
  Result := PaperKind80mm;
  if WidthInDots <= 58 then
    Result := PaperKind58mm;
end;

(*
"             “ŒŒ SOFT IT KAZAKHSTAN             ",
"                ¡»Õ 131240010479                ",
"Õƒ— —ÂËˇ 00000                        π 0000000",
"------------------------------------------------",
"                      Œ‘ƒ 2                     ",
"                    —ÏÂÌ‡ 178                   ",
"            œÓˇ‰ÍÓ‚˚È ÌÓÏÂ ˜ÂÍ‡ π2            ",
"◊ÂÍ π925871425876",
" ‡ÒÒË webkassa4@softit.kz",
"
œ–Œƒ¿∆¿",
"------------------------------------------------",
"  1. œÓÁËˆËˇ ˜ÂÍ‡ 1",
"   123,456 ¯Ú x 123,45",
"   —ÍË‰Í‡                                 -12,00",
"   Õ‡ˆÂÌÍ‡                                +13,00",
"   —ÚÓËÏÓÒÚ¸                           15†241,64",
"  2. œÓÁËˆËˇ ˜ÂÍ‡ 2",
"   12,456 ¯Ú x 12,45",
"   —ÍË‰Í‡                                 -12,00",
"   Õ‡ˆÂÌÍ‡                                +13,00",
"   —ÚÓËÏÓÒÚ¸                              156,08",
"  3. œÓÁËˆËˇ ˜ÂÍ‡ 1",
"   2 ¯Ú x 23,00",
"   —ÚÓËÏÓÒÚ¸                               46,00",
"------------------------------------------------",
"Õ‡ÎË˜Ì˚Â:                                 800,00",
"¡‡ÌÍÓ‚ÒÍ‡ˇ Í‡Ú‡:                      14†597,72",
"Õ‡ÎË˜Ì˚Â:                                  46,00",
"—ÍË‰Í‡:                                    24,00",
"Õ‡ˆÂÌÍ‡:                                   26,00",
"»“Œ√Œ:                                  15443,72",
"‚ Ú.˜. Õƒ— 12%:                          1649,75",
"------------------------------------------------",
"‘ËÒÍ‡Î¸Ì˚È ÔËÁÌ‡Í: 925871425876",
"¬ÂÏˇ: 26.08.2022 21:00:14",
"ÚÂÒÚ",
"ŒÔÂ‡ÚÓ ÙËÒÍ‡Î¸Ì˚ı ‰‡ÌÌ˚ı: ¿Œ \" ‡Á“‡ÌÒÍÓÏ\"",
"ƒÎˇ ÔÓ‚ÂÍË ˜ÂÍ‡ Á‡È‰ËÚÂ Ì‡ Ò‡ÈÚ: ",
"dev.kofd.kz/consumer",
"------------------------------------------------",
"                 ‘»— ¿À‹Õ€… ◊≈K                 ",
"http://dev.kofd.kz/consumer?i=925871425876&f=211030200207&s=15443.72&t=20220826T210014",
"                  »Õ  Œ‘ƒ: 270                  ",
"          Ó‰   Ã  √ƒ (–ÕÃ): 211030200207        ",
"                «ÕÃ: SWK00032685                ",
"                   WEBKASSA.KZ                  ",



*)

function OperationTypeToText(OperationType: Integer): WideString;
begin
  Result := '';
  case OperationType of
    OperationTypeBuy: Result := 'œŒ ”œ ¿';
    OperationTypeRetBuy: Result := '¬Œ«¬–¿“ œŒ ”œ »';
    OperationTypeSell: Result := 'œ–Œƒ¿∆¿';
    OperationTypeRetSell: Result := '¬Œ«¬–¿“ œ–Œƒ¿∆»';
  end;
end;


procedure TWebkassaImpl.PrintReceipt(Receipt: TSalesReceipt;
  Command: TSendReceiptCommand);
var
  i: Integer;
  Text: WideString;
  VatRate: TVatRate;
  Amount: Currency;
  TextItem: TRecTexItem;
  ReceiptItem: TReceiptItem;
  RecItem: TSalesReceiptItem;
  ItemQuantity: Double;
  UnitPrice: Currency;
  Adjustment: TAdjustmentRec;
  BarcodeItem: TBarcodeItem;
begin
  Document.Addlines(Format('Õƒ— —ÂËˇ %s', [Params.VATSeries]),
    Format('π %s', [Params.VATNumber]));
  Document.AddSeparator;
  Document.AddLine(Document.AlignCenter(FCashBox.Name));
  Document.AddLine(Document.AlignCenter(Format('—Ã≈Õ¿ π%d', [Command.Data.ShiftNumber])));
  Document.AddLine(OperationTypeToText(Command.Request.OperationType));

  //Document.AddLine(AlignCenter(Format('œÓˇ‰ÍÓ‚˚È ÌÓÏÂ ˜ÂÍ‡ π%d', [Command.Data.DocumentNumber])));
  //Document.AddLine(Format('◊ÂÍ π%s', [Command.Data.CheckNumber]));
  //Document.AddLine(Format(' ‡ÒÒË %s', [Command.Data.EmployeeName]));
  //Document.AddLine(UpperCase(Command.Data.OperationTypeText));
  Document.AddSeparator;


  for i := 0 to Receipt.Items.Count-1 do
  begin
    ReceiptItem := Receipt.Items[i];
    if ReceiptItem is TSalesReceiptItem then
    begin
      RecItem := ReceiptItem as TSalesReceiptItem;
      //Document.AddLine(Format('%3d. %s', [RecItem.Number, RecItem.Description]));
      Document.AddLine(RecItem.Description);

      ItemQuantity := 1;
      UnitPrice := RecItem.Price;
      if RecItem.Quantity <> 0 then
      begin
        ItemQuantity := RecItem.Quantity;
        UnitPrice := RecItem.UnitPrice;
      end;
      Document.AddLine(Format('   %.3f %s x %s %s', [ItemQuantity,
        RecItem.UnitName, AmountToStr(UnitPrice), Params.CurrencyName]));
      // —ÍË‰Í‡
      Adjustment := RecItem.GetDiscount;
      if Adjustment.Amount <> 0 then
      begin
        if Adjustment.Name = '' then
          Adjustment.Name := '—ÍË‰Í‡';
        Document.AddLines('   ' + Adjustment.Name,
          '-' + AmountToStr(Abs(Adjustment.Amount)));
      end;
      // Õ‡ˆÂÌÍ‡
      Adjustment := RecItem.GetCharge;
      if Adjustment.Amount <> 0 then
      begin
        if Adjustment.Name = '' then
          Adjustment.Name := 'Õ‡ˆÂÌÍ‡';
        Document.AddLines('   ' + Adjustment.Name,
          '+' + AmountToStr(Abs(Adjustment.Amount)));
      end;
      Document.AddLines('   —ÚÓËÏÓÒÚ¸', AmountToStr(RecItem.GetTotalAmount(Receipt.RoundType)));
    end;
    // Text
    if ReceiptItem is TRecTexItem then
    begin
      TextItem := ReceiptItem as TRecTexItem;
      Document.AddLine(TextItem.Text, TextItem.Style);
    end;
    // Barcode
    if ReceiptItem is TBarcodeItem then
    begin
      BarcodeItem := ReceiptItem as TBarcodeItem;
      Document.AddBarcode(BarcodeItem.Barcode);
    end;
  end;
  Document.AddSeparator;
  // —ÍË‰Í‡ Ì‡ ˜ÂÍ
  Amount := Receipt.GetDiscount;
  if Amount <> 0 then
  begin
    Document.AddLines('—ÍË‰Í‡:', AmountToStr(Amount));
  end;
  // Õ‡ˆÂÌÍ‡ Ì‡ ˜ÂÍ
  Amount := Receipt.GetCharge;
  if Amount <> 0 then
  begin
    Document.AddLines('Õ‡ˆÂÌÍ‡:', AmountToStr(Amount));
  end;
  // »“Œ√
  Text := Document.ConcatLines('»“Œ√', AmountToStrEq(Receipt.GetTotal), Document.LineChars div 2);
  Document.AddLine(Text, STYLE_DWIDTH_HEIGHT);
  // Payments
  for i := Low(Receipt.Payments) to High(Receipt.Payments) do
  begin
    Amount := Receipt.Payments[i];
    if Amount <> 0 then
    begin
      Document.AddLines(GetPaymentName(i) + ':', AmountToStrEq(Amount));
    end;
  end;
  if Receipt.Change <> 0 then
  begin
    Document.AddLines('  —ƒ¿◊¿', AmountToStrEq(Receipt.Change));
  end;

  // VAT amounts
  for i := 0 to Params.VatRates.Count-1 do
  begin
    VatRate := Params.VatRates[i];
    Amount := Receipt.GetTotalByVAT(VatRate.Code);
    if Amount <> 0 then
    begin
      Amount := Receipt.RoundAmount(Amount * VATRate.Rate / (100 + VATRate.Rate));
      Document.AddLines(Format('‚ Ú.˜. %s', [VATRate.Name]),
        AmountToStrEq(Amount));
    end;
  end;
  Document.AddSeparator;
  if Receipt.FiscalSign = '' then
  begin
    Receipt.FiscalSign := Command.Data.CheckNumber;
  end;
  Document.AddLine('‘ËÒÍ‡Î¸Ì˚È ÔËÁÌ‡Í: ' + Receipt.FiscalSign);
  Document.AddLine('¬ÂÏˇ: ' + Command.Data.DateTime);
  Document.AddLine('ŒÔÂ‡ÚÓ ÙËÒÍ‡Î¸Ì˚ı ‰‡ÌÌ˚ı:');
  Document.AddLine(Command.Data.Cashbox.Ofd.Name);
  Document.AddLine('ƒÎˇ ÔÓ‚ÂÍË ˜ÂÍ‡ Á‡È‰ËÚÂ Ì‡ Ò‡ÈÚ:');
  Document.AddLine(Command.Data.Cashbox.Ofd.Host);
  Document.AddSeparator;
  Document.AddLine(Document.AlignCenter('‘»— ¿À‹Õ€… ◊≈K'));
  Document.AddItem(Command.Data.TicketUrl, STYLE_QR_CODE);
  Document.AddLine('');
  Document.AddLine(Document.AlignCenter('»Õ  Œ‘ƒ: ' + Command.Data.Cashbox.IdentityNumber));
  Document.AddLine(Document.AlignCenter(' Ó‰   Ã  √ƒ (–ÕÃ): ' + Command.Data.Cashbox.RegistrationNumber));
  Document.AddLine(Document.AlignCenter('«ÕÃ: ' + Command.Data.Cashbox.UniqueNumber));
  Document.AddText(Receipt.Trailer.Text);
end;

function TWebkassaImpl.GetJsonField(JsonText: WideString;
  const FieldName: WideString): Variant;
var
  P: Integer;
  S: WideString;
  Json: TlkJSON;
  Root: TlkJSONbase;
  Field: WideString;
begin
  Result := '';
  if JsonText = '' then Exit;
  if FieldName = '' then Exit;

  Json := TlkJSON.Create;
  try
    Root := Json.ParseText(JsonText);
    S := FieldName;
    Result := '';
    repeat
      P := Pos('.', S);
      if P <> 0 then
      begin
        Field := Copy(S, 1, P-1);
        S := Copy(S, P+1, Length(S));
      end else
      begin
        Field := S;
      end;
      Root := Root.Field[Field];
      if Root = nil then
      begin
        Result := '';
        Exit;
        { !!! }
        //raise Exception.CreateFmt('Field %s not found', [FieldName]);
      end;
    until P = 0;
    Result := Root.Value;
  finally
    Json.Free;
  end;
end;

function TWebkassaImpl.GetHeaderItemText(Receipt: TSalesReceipt;
  Item: TTemplateItem): WideString;
begin
  case Item.ItemType of
    TEMPLATE_TYPE_TEXT: Result := Item.Text;
    TEMPLATE_TYPE_PARAM: Result := Params.ItemByText(Item.Text);
    TEMPLATE_TYPE_ITEM_FIELD: Result := ReceiptFieldByText(Receipt, Item);
    TEMPLATE_TYPE_SEPARATOR: Result := StringOfChar('-', Item.LineChars);
    TEMPLATE_TYPE_JSON_REQ_FIELD: Result := GetJsonField(Receipt.ReguestJson, Item.Text);
    TEMPLATE_TYPE_JSON_ANS_FIELD: Result := GetJsonField(Receipt.AnswerJson, Item.Text);
    TEMPLATE_TYPE_JSON_REC_FIELD: Result := GetJsonField(Receipt.ReceiptJson, Item.Text);
    TEMPLATE_TYPE_NEWLINE: Result := CRLF;
  else
    Result := '';
  end;
end;

function TWebkassaImpl.GetReceiptItemText(ReceiptItem: TSalesReceiptItem;
  Item: TTemplateItem): WideString;
begin
  case Item.ItemType of
    TEMPLATE_TYPE_TEXT: Result := Item.Text;
    TEMPLATE_TYPE_ITEM_FIELD: Result := ReceiptItemByText(ReceiptItem, Item);
    TEMPLATE_TYPE_PARAM: Result := Params.ItemByText(Item.Text);
    TEMPLATE_TYPE_SEPARATOR: Result := StringOfChar('-', Document.LineChars);
    TEMPLATE_TYPE_NEWLINE: Result := CRLF;
  else
    Result := '';
  end;
end;

function TWebkassaImpl.ReceiptItemByText(ReceiptItem: TSalesReceiptItem;
  Item: TTemplateItem): WideString;
var
  Amount: Currency;
begin
  Result := '';
  if WideCompareText(Item.Text, 'Price') = 0 then
  begin
    if (Item.Enabled = TEMPLATE_ITEM_ENABLED)or(ReceiptItem.Price <> 0) then
    begin
      Result := Format('%.2f', [ReceiptItem.Price]);
    end;
    Exit;
  end;
  if WideCompareText(Item.Text, 'VatInfo') = 0 then
  begin
    Result := IntToStr(ReceiptItem.VatInfo);
    Exit;
  end;
  if WideCompareText(Item.Text, 'Quantity') = 0 then
  begin
    Result := Format('%.3f', [ReceiptItem.Quantity]);
    Exit;
  end;
  if WideCompareText(Item.Text, 'UnitPrice') = 0 then
  begin
    if (Item.Enabled = TEMPLATE_ITEM_ENABLED)or(ReceiptItem.UnitPrice <> 0) then
    begin
      Result := Format('%.2f', [ReceiptItem.UnitPrice]);
    end;
    Exit;
  end;
  if WideCompareText(Item.Text, 'UnitName') = 0 then
  begin
    Result := ReceiptItem.UnitName;
    Exit;
  end;
  if WideCompareText(Item.Text, 'Description') = 0 then
  begin
    Result := ReceiptItem.Description;
    Exit;
  end;
  if WideCompareText(Item.Text, 'MarkCode') = 0 then
  begin
    Result := ReceiptItem.MarkCode;
    Exit;
  end;
  if WideCompareText(Item.Text, 'Discount') = 0 then
  begin
    Amount := Abs(ReceiptItem.Discounts.GetTotal);
    if (Item.Enabled = TEMPLATE_ITEM_ENABLED)or(Amount <> 0) then
    begin
      Result := Format('%.2f', [Amount]);
    end;
    Exit;
  end;
  if WideCompareText(Item.Text, 'Charge') = 0 then
  begin
    Amount := Abs(ReceiptItem.Charges.GetTotal);
    if (Item.Enabled = TEMPLATE_ITEM_ENABLED)or(Amount <> 0) then
    Result := Format('%.2f', [Amount]);
    Exit;
  end;
  if WideCompareText(Item.Text, 'Total') = 0 then
  begin
    Amount := Abs(ReceiptItem.GetTotalAmount(Params.RoundType));
    if (Item.Enabled = TEMPLATE_ITEM_ENABLED)or(Amount <> 0) then
      Result := Format('%.2f', [Amount]);
    Exit;
  end;
  raise Exception.CreateFmt('Receipt item %s not found', [Item.Text]);
end;

function TWebkassaImpl.ReceiptFieldByText(Receipt: TSalesReceipt;
  Item: TTemplateItem): WideString;

  function GetRecTypeText(RecType: TRecType): string;
  begin
    case RecType of
      rtBuy    : Result := 'œŒ ”œ ¿';
      rtRetBuy : Result := '¬Œ«¬–¿“ œŒ ”œ »';
      rtSell   : Result := 'œ–Œƒ¿∆¿';
      rtRetSell: Result := '¬Œ«¬–¿“ œ–Œƒ¿∆»';
    else
      raise Exception.CreateFmt('Invalid receipt type, %d', [Ord(RecType)]);
    end;
  end;

var
  Amount: Currency;
begin
  Result := '';
  if WideCompareText(Item.Text, 'Discount') = 0 then
  begin
    Amount := Abs(Receipt.Discounts.GetTotal);
    if (Item.Enabled = TEMPLATE_ITEM_ENABLED)or(Amount <> 0) then
    begin
      Result := Format('%.2f', [Amount]);
    end;
    Exit;
  end;
  if WideCompareText(Item.Text, 'Charge') = 0 then
  begin
    Amount := Abs(Receipt.Charges.GetTotal);
    if (Item.Enabled = TEMPLATE_ITEM_ENABLED)or(Amount <> 0) then
    Result := Format('%.2f', [Amount]);
    Exit;
  end;
  if WideCompareText(Item.Text, 'Total') = 0 then
  begin
    Amount := Abs(Receipt.GetTotal);
    if (Item.Enabled = TEMPLATE_ITEM_ENABLED)or(Amount <> 0) then
      Result := Format('%.2f', [Amount]);
    Exit;
  end;
  if WideCompareText(Item.Text, 'Payment0') = 0 then
  begin
    Amount := Abs(Receipt.Payments[0]);
    if (Item.Enabled = TEMPLATE_ITEM_ENABLED)or(Amount <> 0) then
      Result := Format('%.2f', [Amount]);
    Exit;
  end;
  if WideCompareText(Item.Text, 'Payment1') = 0 then
  begin
    Amount := Abs(Receipt.Payments[1]);
    if (Item.Enabled = TEMPLATE_ITEM_ENABLED)or(Amount <> 0) then
      Result := Format('%.2f', [Amount]);
    Exit;
  end;
  if WideCompareText(Item.Text, 'Payment2') = 0 then
  begin
    Amount := Abs(Receipt.Payments[2]);
    if (Item.Enabled = TEMPLATE_ITEM_ENABLED)or(Amount <> 0) then
      Result := Format('%.2f', [Amount]);
    Exit;
  end;
  if WideCompareText(Item.Text, 'Payment3') = 0 then
  begin
    Amount := Abs(Receipt.Payments[3]);
    if (Item.Enabled = TEMPLATE_ITEM_ENABLED)or(Amount <> 0) then
      Result := Format('%.2f', [Amount]);
    Exit;
  end;
  if WideCompareText(Item.Text, 'Change') = 0 then
  begin
    Amount := Abs(Receipt.Change);
    if (Item.Enabled = TEMPLATE_ITEM_ENABLED)or(Amount <> 0) then
      Result := Format('%.2f', [Amount]);
    Exit;
  end;
  if WideCompareText(Item.Text, 'OperationTypeText') = 0 then
  begin
    Result := GetRecTypeText(Receipt.RecType);
    Exit;
  end;

  raise Exception.CreateFmt('Receipt field %s not found', [Item.Text]);
end;

function GetLastLine(const Line: WideString): WideString;
var
  P: Integer;
begin
  Result := Line;
  while True do
  begin
    P := Pos(CRLF, Result);
    if P <= 0 then Break;
    Result := Copy(Result, P+2, Length(Result));
  end;
end;

procedure TWebkassaImpl.PrintReceiptTemplate(Receipt: TSalesReceipt;
  Template: TReceiptTemplate);
var
  i, j: Integer;
  IsValid: Boolean;
  Item: TTemplateItem;
  LineItems: TList;
  ReceiptItem: TReceiptItem;
  RecTexItem: TRecTexItem;
begin
  IsValid := True;
  LineItems := TList.Create;
  try
    // Header
    LineItems.Clear;
    for i := 0 to Template.Header.Count-1 do
    begin
      Item := Template.Header[i];
      UpdateTemplateItem(Item);
      Item.Value := GetHeaderItemText(Receipt, Item);
      LineItems.Add(Item);
    end;
    AddItems(LineItems);
    LineItems.Clear;
    // Items
    for i := 0 to Receipt.Items.Count-1 do
    begin
      ReceiptItem := Receipt.Items[i];
      if ReceiptItem is TRecTexItem then
      begin
        RecTexItem := ReceiptItem as TRecTexItem;
        Document.AddLine(RecTexItem.Text, RecTexItem.Style);
      end;


      if ReceiptItem is TSalesReceiptItem then
      begin
        for j := 0 to Template.RecItem.Count-1 do
        begin
          Item := Template.RecItem[j];
          UpdateTemplateItem(Item);
          if Item.ItemType = TEMPLATE_TYPE_NEWLINE then
          begin
            Item.Value := CRLF;
            if IsValid then
            begin
              LineItems.Add(Item);
              AddItems(LineItems);
            end;
            LineItems.Clear;
            IsValid := True;
          end else
          begin
            LineItems.Add(Item);
            Item.Value := GetReceiptItemText(ReceiptItem as TSalesReceiptItem, Item);
            IsValid := Item.Value <> '';
          end;
        end;
      end;
    end;
    AddItems(LineItems);
    LineItems.Clear;
    for i := 0 to Template.Trailer.Count-1 do
    begin
      Item := Template.Trailer[i];
      UpdateTemplateItem(Item);
      Item.Value := GetHeaderItemText(Receipt, Item);
      LineItems.Add(Item);
    end;
    AddItems(LineItems);
    LineItems.Clear;
    Document.AddText(Receipt.Trailer.Text);
  finally
    LineItems.Free;
  end;
end;

procedure TWebkassaImpl.UpdateTemplateItem(Item: TTemplateItem);
begin
  if Item.LineChars = 0 then
  begin
    Item.LineChars := Document.LineChars;
  end;
  if Item.LineSpacing = 0 then
  begin
    Item.LineSpacing := Document.LineSpacing;
  end;
end;

procedure TWebkassaImpl.AddItems(Items: TList);

  procedure AddListItems(Items: TList);
  var
    i: Integer;
    Item: TTemplateItem;
  begin
    for i := 0 to Items.Count-1 do
    begin
      Item := TTemplateItem(Items[i]);
      Document.LineChars := Item.LineChars;
      Document.LineSpacing := Item.LineSpacing;
      case Item.TextStyle of
        STYLE_QR_CODE: Document.AddItem(Item.Value, Item.TextStyle);
      else
        Document.Add(Item.Value, Item.TextStyle);
      end;
    end;
  end;

var
  i: Integer;
  Len: Integer;
  List: TList;
  Valid: Boolean;
  Line: WideString;
  Item: TTemplateItem;
begin
  Line := '';
  Valid := True;
  List := TList.Create;
  try
    for i := 0 to Items.Count-1 do
    begin
      Item := TTemplateItem(Items[i]);

      if (Item.Enabled = TEMPLATE_ITEM_ENABLED_IF_NOT_ZERO) then
      begin
        if Item.Value = '' then
        begin
          List.Clear;
          Line := '';
          Valid := False;
        end;
      end;

      if Item.FormatText <> '' then
        Item.Value := Format(Item.FormatText, [Item.Value]);

      case Item.Alignment of
        ALIGN_RIGHT:
        begin
          Len := Item.GetLineLength - Length(Item.Value) - Length(Line);
          Item.Value := StringOfChar(' ', Len) + Item.Value;
        end;

        ALIGN_CENTER:
        begin
          Len := (Item.GetLineLength-Length(Item.Value)-Length(Line)) div 2;
          Item.Value := StringOfChar(' ', Len) + Item.Value;
        end;
      end;
      Line := Line + Item.Value;
      List.Add(Item);
      if Item.ItemType = TEMPLATE_TYPE_NEWLINE then
      begin
        if Valid then
        begin
          AddListItems(List);
        end;
        Line := '';
        List.Clear;
        Valid := True;
      end;
    end;
    AddListItems(List);
  finally
    List.Free;
  end;
end;


procedure TWebkassaImpl.CheckCanPrint;
begin
  if Printer.CapRecEmptySensor and Printer.RecEmpty then
    raiseOposFptrRecEmpty;

  if Printer.CapCoverSensor and Printer.CoverOpen then
    raiseOposFptrCoverOpened;
end;

procedure TWebkassaImpl.PrintDocumentSafe(Document: TTextDocument);
begin
  if not Params.PrintEnabled then Exit;

  try
    Document.AddText(Params.TrailerText);
    PrintDocument(Document);
  except
    on E: Exception do
    begin
      Document.Save;
      Logger.Error('Failed to print document, ' + E.Message);
    end;
  end;
end;

procedure TWebkassaImpl.PrintDocument(Document: TTextDocument);
var
  i: Integer;
  TickCount: DWORD;
begin
  Logger.Debug('PrintDocument');
  TickCount := GetTickCount;

  CheckPtr(Printer.CheckHealth(OPOS_CH_INTERNAL));
  CheckCanPrint;

  FCapRecBold := Printer.CapRecBold;
  FCapRecDwideDhigh := Printer.CapRecDwideDhigh;

  FLineChars := Printer.RecLineChars;
  FLineHeight := Printer.RecLineHeight;
  FLineSpacing := Printer.RecLineSpacing;

  if Printer.CapTransaction then
  begin
    CheckPtr(Printer.TransactionPrint(PTR_S_RECEIPT, PTR_TP_TRANSACTION));
  end;
  for i := 0 to Document.Items.Count-1 do
  begin
    PrintDocItem(Document.Items[i]);
  end;

  CutPaper;
  if Printer.CapTransaction then
  begin
    CheckPtr(Printer.TransactionPrint(PTR_S_RECEIPT, PTR_TP_NORMAL));
  end;
  CheckPtr(Printer.CheckHealth(OPOS_CH_INTERNAL));
  Logger.Debug(Format('PrintDocument, time=%d ms', [GetTickCount-TickCount]));
end;

procedure TWebkassaImpl.PrinTDocItem(Item: TDocItem);
var
  Text: WideString;
  Barcode: TBarcodeRec;
begin
  if (Item.LineChars <> 0)and(Item.LineChars <> FLineChars) then
  begin
    Printer.RecLineChars := Item.LineChars;
    FLineChars := Item.LineChars;
  end;
  if (Item.LineHeight <> 0)and(Item.LineHeight <> FLineHeight) then
  begin
    Printer.RecLineHeight := Item.LineHeight;
    FLineHeight := Item.LineHeight;
  end;
  if (Item.LineSpacing <> 0)and(Item.LineSpacing <> FLineSpacing) then
  begin
    Printer.RecLineSpacing := Item.LineSpacing;
    FLineSpacing := Item.LineSpacing;
  end;


  case Item.Style of
    STYLE_QR_CODE:
    begin
      Barcode.Data := Item.Text;
      Barcode.Text := Item.Text;
      Barcode.Height := 0;
      Barcode.BarcodeType := DIO_BARCODE_QRCODE;
      Barcode.ModuleWidth := 4;
      Barcode.Alignment := BARCODE_ALIGNMENT_CENTER;
      Barcode.Parameter1 := 0;
      Barcode.Parameter2 := 0;
      Barcode.Parameter3 := 0;
      Barcode.Parameter4 := 0;
      Barcode.Parameter5 := 0;
      PrintBarcode2(Barcode);
    end;
    STYLE_BARCODE: PrintBarcode2(StrToBarcode(Item.Text));
  else
    Text := Item.Text;
    FPrefix := '';
    // DWDH
    if Item.Style = STYLE_DWIDTH_HEIGHT then
    begin
      if FCapRecDwideDhigh then
        FPrefix := ESC_DoubleHighWide;
    end;
    // BOLD
    if Item.Style = STYLE_BOLD then
    begin
      if FCapRecBold then
        FPrefix := ESC_Bold;
    end;

    Text := Params.GetTranslationText(Text);
    PtrPrintNormal(PTR_S_RECEIPT, FPrefix + Text);
  end;
end;

procedure TWebkassaImpl.PtrPrintNormal(Station: Integer; const Data: WideString);
var
  Text: AnsiString;
begin
  if FPtrMapCharacterSet then
  begin
    CheckPtr(Printer.PrintNormal(Station, Data));
  end else
  begin
    Text := WideStringToAnsiString(FCodePage, Data);
    CheckPtr(Printer.PrintNormal(Station, Data));
  end;
end;

procedure TWebkassaImpl.PrintLine(Text: WideString);
begin
  Text := Params.GetTranslationText(Text);
  PtrPrintNormal(PTR_S_RECEIPT, Text + CRLF);
end;


procedure TWebkassaImpl.PrintText(Prefix, Text: WideString; RecLineChars: Integer);
var
  i: Integer;
  Lines: TTntStrings;
begin
  Lines := TTntStringList.Create;
  try
    Lines.Text := Text;
    for i := 0 to Lines.Count-1 do
    begin
      PrintTextLine(Prefix, Lines[i], RecLineChars);
    end;
  finally
    Lines.Free;
  end;
end;

procedure TWebkassaImpl.PrintTextLine(Prefix, Text: WideString; RecLineChars: Integer);
var
  Line: WideString;
begin
  if RecLineChars = 0 then
    raise Exception.Create('RecLineChars = 0');

  while True do
  begin
    Line := Prefix + Copy(Text, 1, RecLineChars);
    PrintLine(Line);
    Text := Copy(Text, RecLineChars + 1, Length(Text));
    if Length(Text) = 0 then Break;
  end;
end;

procedure TWebkassaImpl.CutPaper;
var
  i: Integer;
  Count: Integer;
  Text: WideString;
  RecLinesToPaperCut: Integer;
const
  PrintHeader = True;
begin
  PrintLine('');
  if Printer.CapRecPapercut then
  begin
    RecLinesToPaperCut := Printer.RecLinesToPaperCut;
    if PrintHeader then
    begin
      if FParams.NumHeaderLines <= RecLinesToPaperCut then
      begin
        for i := 0 to Params.Header.Count-1 do
        begin
          Text := TrimRight(Params.Header[i]);
          PrintLine(Text);
        end;
        Count := RecLinesToPaperCut - FParams.NumHeaderLines;
        for i := 0 to Count-1 do
        begin
          PrintLine('');
        end;
        Printer.CutPaper(90);
      end else
      begin
        for i := 1 to RecLinesToPaperCut do
        begin
          PrintLine(CRLF);
        end;
        Printer.CutPaper(90);
        for i := 0 to Params.Header.Count-1 do
        begin
          Text := TrimRight(Params.Header[i]);
          PrintLine(Text);
        end;
      end;
      Params.HeaderPrinted := True;
      SaveUsrParameters(FParams, FOposDevice.DeviceName, FLogger);
    end else
    begin
      for i := 1 to RecLinesToPaperCut do
      begin
        PrintLine('');
      end;
      Printer.CutPaper(90);
    end;
  end;
end;

function TWebkassaImpl.GetPrinterStation(Station: Integer): Integer;
begin
  if (Station and FPTR_S_RECEIPT) <> 0 then
  begin
    if not Printer.CapRecPresent then
      RaiseOposException(OPOS_E_ILLEGAL, _('ÕÂÚ ˜ÂÍÓ‚Ó„Ó ÔËÌÚÂ‡'));
  end;

  if (Station and FPTR_S_JOURNAL) <> 0 then
  begin
    if not Printer.CapJrnPresent then
      RaiseOposException(OPOS_E_ILLEGAL, _('ÕÂÚ ÔËÌÚÂ‡ ÍÓÌÚÓÎ¸ÌÓÈ ÎÂÌÚ˚'));
  end;

  if (Station and FPTR_S_SLIP) <> 0 then
  begin
    if not Printer.CapSlpPresent then
      RaiseOposException(OPOS_E_ILLEGAL, _('Slip station is not present'));
  end;
  if Station = 0 then
    RaiseOposException(OPOS_E_ILLEGAL, _('No station defined'));

  Result := Station;
end;

function TWebkassaImpl.RenderQRCode(const BarcodeData: AnsiString): AnsiString;
var
  Bitmap: TBitmap;
  Render: TZintBarcode;
  Stream: TMemoryStream;
begin
  Result := '';
  Bitmap := TBitmap.Create;
  Render := TZintBarcode.Create;
  Stream := TMemoryStream.Create;
  try
    Render.BorderWidth := 0;
    Render.FGColor := clBlack;
    Render.BGColor := clWhite;
    Render.Scale := 1;
    Render.Height := 200;
    Render.BarcodeType := tBARCODE_QRCODE;
    Render.Data := BarcodeData;
    Render.ShowHumanReadableText := False;
    Render.EncodeNow;
    RenderBarcode(Bitmap, Render.Symbol, False);
    ScaleBitmap(Bitmap, 2);
    Bitmap.SaveToStream(Stream);

    if Stream.Size > 0 then
    begin
      Stream.Position := 0;
      SetLength(Result, Stream.Size);
      Stream.ReadBuffer(Result[1], Stream.Size);
    end;
  finally
    Render.Free;
    Bitmap.Free;
    Stream.Free;
  end;
end;

procedure TWebkassaImpl.PrintQRCodeAsGraphics(const BarcodeData: AnsiString);
var
  Data: AnsiString;
begin
  if not Printer.CapRecBitmap then Exit;
  Printer.BinaryConversion := OPOS_BC_NIBBLE;
  try
    Data := RenderQRCode(BarcodeData);
    Data := OposStrToNibble(Data);
    CheckPtr(Printer.PrintMemoryBitmap(PTR_S_RECEIPT, Data,
      PTR_BMT_BMP, PTR_BM_ASIS, PTR_BM_CENTER));
  finally
    Printer.BinaryConversion := OPOS_BC_NONE;
  end;
end;

procedure TWebkassaImpl.PrintBarcodeAsGraphics(const Barcode: TBarcodeRec);
var
  Data: AnsiString;
  BMPAlignment: Integer;
begin
  if not Printer.CapRecBitmap then
    RaiseIllegalError('Bitmaps are not supported');


  Printer.BinaryConversion := OPOS_BC_NIBBLE;
  try
    Data := RenderBarcodeRec(Barcode);
    Data := OposStrToNibble(Data);
    BMPAlignment := BarcodeAlignmentToBMPAlignment(Barcode.Alignment);
    CheckPtr(Printer.PrintMemoryBitmap(PTR_S_RECEIPT, Data,
      PTR_BMT_BMP, PTR_BM_ASIS, BMPAlignment));
  finally
    Printer.BinaryConversion := OPOS_BC_NONE;
  end;
end;

function TWebkassaImpl.RenderBarcodeRec(Barcode: TBarcodeRec): AnsiString;

  function BTypeToZBType(BarcodeType: Integer): TZBType;
  begin
    case BarcodeType of
      DIO_BARCODE_EAN13_INT: Result := tBARCODE_EANX;
      DIO_BARCODE_CODE128A: Result := tBARCODE_CODE128;
      DIO_BARCODE_CODE128B: Result := tBARCODE_CODE128;
      DIO_BARCODE_CODE128C: Result := tBARCODE_CODE128;
      DIO_BARCODE_CODE39: Result := tBARCODE_CODE39;
      DIO_BARCODE_CODE25INTERLEAVED: Result := tBARCODE_C25INTER;
      DIO_BARCODE_CODE25INDUSTRIAL: Result := tBARCODE_C25IND;
      DIO_BARCODE_CODE25MATRIX: Result := tBARCODE_C25MATRIX;
      DIO_BARCODE_CODE39EXTENDED: Result := tBARCODE_EXCODE39;
      DIO_BARCODE_CODE93: Result := tBARCODE_CODE93;
      DIO_BARCODE_CODE93EXTENDED: Result := tBARCODE_CODE93;
      DIO_BARCODE_MSI: Result := tBARCODE_MSI_PLESSEY;
      DIO_BARCODE_POSTNET: Result := tBARCODE_POSTNET;
      DIO_BARCODE_CODABAR: Result := tBARCODE_CODABAR;
      DIO_BARCODE_EAN8: Result := tBARCODE_EANX;
      DIO_BARCODE_EAN13: Result := tBARCODE_EANX;
      DIO_BARCODE_UPC_A: Result := tBARCODE_UPCA;
      DIO_BARCODE_UPC_E0: Result := tBARCODE_UPCE;
      DIO_BARCODE_UPC_E1: Result := tBARCODE_UPCE;
      DIO_BARCODE_EAN128A: Result := tBARCODE_EAN128;
      DIO_BARCODE_EAN128B: Result := tBARCODE_EAN128;
      DIO_BARCODE_EAN128C: Result := tBARCODE_EAN128;
      DIO_BARCODE_CODE11: Result := tBARCODE_CODE11;
      DIO_BARCODE_C25IATA: Result := tBARCODE_C25IATA;
      DIO_BARCODE_C25LOGIC: Result := tBARCODE_C25LOGIC;
      DIO_BARCODE_DPLEIT: Result := tBARCODE_DPLEIT;
      DIO_BARCODE_DPIDENT: Result := tBARCODE_DPIDENT;
      DIO_BARCODE_CODE16K: Result := tBARCODE_CODE16K;
      DIO_BARCODE_CODE49: Result := tBARCODE_CODE49;
      DIO_BARCODE_FLAT: Result := tBARCODE_FLAT;
      DIO_BARCODE_RSS14: Result := tBARCODE_RSS14;
      DIO_BARCODE_RSS_LTD: Result := tBARCODE_RSS_LTD;
      DIO_BARCODE_RSS_EXP: Result := tBARCODE_RSS_EXP;
      DIO_BARCODE_TELEPEN: Result := tBARCODE_TELEPEN;
      DIO_BARCODE_FIM: Result := tBARCODE_FIM;
      DIO_BARCODE_LOGMARS: Result := tBARCODE_LOGMARS;
      DIO_BARCODE_PHARMA: Result := tBARCODE_PHARMA;
      DIO_BARCODE_PZN: Result := tBARCODE_PZN;
      DIO_BARCODE_PHARMA_TWO: Result := tBARCODE_PHARMA_TWO;
      DIO_BARCODE_PDF417: Result := tBARCODE_PDF417;
      DIO_BARCODE_PDF417TRUNC: Result := tBARCODE_PDF417TRUNC;
      DIO_BARCODE_MAXICODE: Result := tBARCODE_MAXICODE;
      DIO_BARCODE_QRCODE: Result := tBARCODE_QRCODE;
      DIO_BARCODE_DATAMATRIX: Result := tBARCODE_DATAMATRIX;
      DIO_BARCODE_AUSPOST: Result := tBARCODE_AUSPOST;
      DIO_BARCODE_AUSREPLY: Result := tBARCODE_AUSREPLY;
      DIO_BARCODE_AUSROUTE: Result := tBARCODE_AUSROUTE;
      DIO_BARCODE_AUSREDIRECT: Result := tBARCODE_AUSREDIRECT;
      DIO_BARCODE_ISBNX: Result := tBARCODE_ISBNX;
      DIO_BARCODE_RM4SCC: Result := tBARCODE_RM4SCC;
      DIO_BARCODE_EAN14: Result := tBARCODE_EAN14;
      DIO_BARCODE_CODABLOCKF: Result := tBARCODE_CODABLOCKF;
      DIO_BARCODE_NVE18: Result := tBARCODE_NVE18;
      DIO_BARCODE_JAPANPOST: Result := tBARCODE_JAPANPOST;
      DIO_BARCODE_KOREAPOST: Result := tBARCODE_KOREAPOST;
      DIO_BARCODE_RSS14STACK: Result := tBARCODE_RSS14STACK;
      DIO_BARCODE_RSS14STACK_OMNI: Result := tBARCODE_RSS14STACK_OMNI;
      DIO_BARCODE_RSS_EXPSTACK: Result := tBARCODE_RSS_EXPSTACK;
      DIO_BARCODE_PLANET: Result := tBARCODE_PLANET;
      DIO_BARCODE_MICROPDF417: Result := tBARCODE_MICROPDF417;
      DIO_BARCODE_ONECODE: Result := tBARCODE_ONECODE;
      DIO_BARCODE_PLESSEY: Result := tBARCODE_PLESSEY;
      DIO_BARCODE_TELEPEN_NUM: Result := tBARCODE_TELEPEN_NUM;
      DIO_BARCODE_ITF14: Result := tBARCODE_ITF14;
      DIO_BARCODE_KIX: Result := tBARCODE_KIX;
      DIO_BARCODE_AZTEC: Result := tBARCODE_AZTEC;
      DIO_BARCODE_DAFT: Result := tBARCODE_DAFT;
      DIO_BARCODE_MICROQR: Result := tBARCODE_MICROQR;
      DIO_BARCODE_HIBC_128: Result := tBARCODE_HIBC_128;
      DIO_BARCODE_HIBC_39: Result := tBARCODE_HIBC_39;
      DIO_BARCODE_HIBC_DM: Result := tBARCODE_HIBC_DM;
      DIO_BARCODE_HIBC_QR: Result := tBARCODE_HIBC_QR;
      DIO_BARCODE_HIBC_PDF: Result := tBARCODE_HIBC_PDF;
      DIO_BARCODE_HIBC_MICPDF: Result := tBARCODE_HIBC_MICPDF;
      DIO_BARCODE_HIBC_BLOCKF: Result := tBARCODE_HIBC_BLOCKF;
      DIO_BARCODE_HIBC_AZTEC: Result := tBARCODE_HIBC_AZTEC;
      DIO_BARCODE_AZRUNE: Result := tBARCODE_AZRUNE;
      DIO_BARCODE_CODE32: Result := tBARCODE_CODE32;
      DIO_BARCODE_EANX_CC: Result := tBARCODE_EANX_CC;
      DIO_BARCODE_EAN128_CC: Result := tBARCODE_EAN128_CC;
      DIO_BARCODE_RSS14_CC: Result := tBARCODE_RSS14_CC;
      DIO_BARCODE_RSS_LTD_CC: Result := tBARCODE_RSS_LTD_CC;
      DIO_BARCODE_RSS_EXP_CC: Result := tBARCODE_RSS_EXP_CC;
      DIO_BARCODE_UPCA_CC: Result := tBARCODE_UPCA_CC;
      DIO_BARCODE_UPCE_CC: Result := tBARCODE_UPCE_CC;
      DIO_BARCODE_RSS14STACK_CC: Result := tBARCODE_RSS14STACK_CC;
      DIO_BARCODE_RSS14_OMNI_CC: Result := tBARCODE_RSS14_OMNI_CC;
      DIO_BARCODE_RSS_EXPSTACK_CC: Result := tBARCODE_RSS_EXPSTACK_CC;
      DIO_BARCODE_CHANNEL: Result := tBARCODE_CHANNEL;
      DIO_BARCODE_CODEONE: Result := tBARCODE_CODEONE;
      DIO_BARCODE_GRIDMATRIX: Result := tBARCODE_GRIDMATRIX;
    else
      raise Exception.CreateFmt('Barcode type not supported, %d', [BarcodeType]);
    end;
  end;


var
  SCale: Integer;
  Bitmap: TBitmap;
  Render: TZintBarcode;
  Stream: TMemoryStream;
begin
  Result := '';

  Scale := 0;
  if Barcode.Height = 0 then
  begin
    Barcode.Height := 100;
    Scale := 4;
  end;

  Bitmap := TBitmap.Create;
  Render := TZintBarcode.Create;
  Stream := TMemoryStream.Create;
  try
    Render.BorderWidth := 0;
    Render.FGColor := clBlack;
    Render.BGColor := clWhite;
    Render.Scale := 1;
    Render.Height := Barcode.Height;
    Render.BarcodeType := BTypeToZBType(Barcode.BarcodeType);
    Render.Data := Barcode.Data;
    Render.ShowHumanReadableText := False;
    Render.EncodeNow;
    RenderBarcode(Bitmap, Render.Symbol, False);

    if Scale = 0 then
    begin
      Scale := Barcode.Height div Bitmap.Height;
      if not (Scale in [2..10]) then Scale := 2;
    end;
    ScaleBitmap(Bitmap, Scale);
    Bitmap.SaveToStream(Stream);

    if Stream.Size > 0 then
    begin
      Stream.Position := 0;
      SetLength(Result, Stream.Size);
      Stream.ReadBuffer(Result[1], Stream.Size);
    end;
  finally
    Render.Free;
    Bitmap.Free;
    Stream.Free;
  end;
end;

procedure TWebkassaImpl.PrintBarcode(const Barcode: string);
begin
  if FPrinterState.State = FPTR_PS_NONFISCAL then
  begin
    Document.AddBarcode(Barcode);
  end else
  begin
    Receipt.PrintBarcode(Barcode);
  end;
end;

procedure TWebkassaImpl.PrintBarcode2(const Barcode: TBarcodeRec);

  function BarcodeTypeToSymbology(BarcodeType: Integer): Integer;
  begin
    case BarcodeType of
      DIO_BARCODE_CODE128A,
      DIO_BARCODE_CODE128B,
      DIO_BARCODE_CODE128C: Result := PTR_BCS_Code128;
      DIO_BARCODE_CODE39: Result := PTR_BCS_Code39;
      DIO_BARCODE_CODE25INTERLEAVED: Result := PTR_BCS_ITF;
      DIO_BARCODE_CODE25INDUSTRIAL: Result := PTR_BCS_TF;
      DIO_BARCODE_CODE93: Result := PTR_BCS_Code93;
      DIO_BARCODE_CODABAR: Result := PTR_BCS_Codabar;
      DIO_BARCODE_EAN8: Result := PTR_BCS_EAN8;
      DIO_BARCODE_EAN13: Result := PTR_BCS_EAN13;
      DIO_BARCODE_UPC_A: Result := PTR_BCS_UPCA;
      DIO_BARCODE_UPC_E0: Result := PTR_BCS_UPCE;
      DIO_BARCODE_UPC_E1: Result := PTR_BCS_UPCE;
      DIO_BARCODE_EAN128A: Result := PTR_BCS_EAN128;
      DIO_BARCODE_EAN128B: Result := PTR_BCS_EAN128;
      DIO_BARCODE_EAN128C: Result := PTR_BCS_EAN128;
      DIO_BARCODE_RSS14: Result := PTR_BCS_RSS14;
      DIO_BARCODE_RSS_EXP: Result := PTR_BCS_RSS_EXPANDED;
      DIO_BARCODE_PDF417: Result := PTR_BCS_PDF417;
      DIO_BARCODE_PDF417TRUNC: Result := PTR_BCS_PDF417;
      DIO_BARCODE_MAXICODE: Result := PTR_BCS_MAXICODE;
      DIO_BARCODE_QRCODE: Result := PTR_BCS_QRCODE;
      DIO_BARCODE_DATAMATRIX: Result := PTR_BCS_DATAMATRIX;
      DIO_BARCODE_MICROPDF417: Result := PTR_BCS_UPDF417;
      DIO_BARCODE_AZTEC: Result := PTR_BCS_AZTEC;
      DIO_BARCODE_MICROQR: Result := PTR_BCS_UQRCODE;
    else
      raise Exception.CreateFmt('Invalid barcode type, %d', [BarcodeType]);
    end;
  end;

var
  Symbology: Integer;
  Alignment: Integer;
begin
  case Params.PrintBarcode of
    PrintBarcodeEscCommands:
    if Printer.CapRecBarcode then
    begin
      Symbology := BarcodeTypeToSymbology(Barcode.BarcodeType);
      Alignment := BarcodeAlignmentToBCAlignment(Barcode.Alignment);
      CheckPtr(Printer.PrintBarCode(FPTR_S_RECEIPT, Barcode.Data, Symbology,
        Barcode.Height, 0, Alignment, PTR_BC_TEXT_NONE));
    end else
    begin
      PrintBarcodeAsGraphics(Barcode);
    end;

    PrintBarcodeGraphics:
    begin
      PrintBarcodeAsGraphics(Barcode);
    end;

    PrintBarcodeText:
    begin
      PtrPrintNormal(PTR_S_RECEIPT, Barcode.Data);
    end;
  end;
end;

procedure TWebkassaImpl.PrintReceiptDuplicate(const pString: WideString);
const
  ValueDelimiters = [';'];
var
  i: Integer;
  Text: WideString;
  Item: TPositionItem;
  ShiftNumber: Integer;
  CheckNumber: WideString;
  Command: TReceiptCommand;
  ItemQuantity: Double;
  UnitName: WideString;
  UnitItem: TUnitItem;
  Payment: TPaymentItem;
begin
  ShiftNumber := GetInteger(pString, 1, ValueDelimiters);
  CheckNumber := GetString(pString, 2, ValueDelimiters);

  Command := TReceiptCommand.Create;
  try
    Command.Request.Token := Client.Token;
    Command.Request.CashboxUniqueNumber := Params.CashboxNumber;
    Command.Request.Number := CheckNumber;
    Command.Request.ShiftNumber := ShiftNumber;
    FClient.ReadReceipt(Command);

    Document.Addlines(Format('Õƒ— —ÂËˇ %s', [Params.VATSeries]),
      Format('π %s', [Params.VATNumber]));
    Document.AddSeparator;
    Document.AddLine(Document.AlignCenter(FCashBox.Name));
    Document.AddLine(Document.AlignCenter(Format('—Ã≈Õ¿ π%d', [ShiftNumber])));
    Document.AddLine(Command.Data.OperationTypeText);
    Document.AddSeparator;
    for i := 0 to Command.Data.Positions.Count-1 do
    begin
      Item := Command.Data.Positions[i];
      Document.AddLine(Item.PositionName);

      ItemQuantity := 1;
      if Item.Count <> 0 then
      begin
        ItemQuantity := Item.Count;
      end;
      UnitName := '';
      UnitItem := FUnits.ItemByCode(Item.UnitCode);
      if UnitItem <> nil then
        UnitName := UnitItem.NameKz;

      Document.AddLine(Format('   %.3f %s x %s %s', [ItemQuantity,
        UnitName, AmountToStr(Item.Price), Params.CurrencyName]));

      // —ÍË‰Í‡
      if (not Item.DiscountDeleted)and(Item.DiscountTenge <> 0) then
      begin
        Document.AddLines('   —ÍË‰Í‡', '-' + AmountToStr(Abs(Item.DiscountTenge)));
      end;

      // Õ‡ˆÂÌÍ‡
      if (not Item.MarkupDeleted)and(Item.Markup <> 0) then
      begin
        Document.AddLines('   Õ‡ˆÂÌÍ‡', '+' + AmountToStr(Abs(Item.Markup)));
      end;

      Document.AddLines('   —ÚÓËÏÓÒÚ¸', AmountToStr(Item.Sum));
    end;
    Document.AddSeparator;
    // —ÍË‰Í‡ Ì‡ ˜ÂÍ
    if Command.Data.Discount <> 0 then
    begin
      Document.AddLines('—ÍË‰Í‡:', AmountToStr(Command.Data.Discount));
    end;
    // Õ‡ˆÂÌÍ‡ Ì‡ ˜ÂÍ
    if Command.Data.Markup <> 0 then
    begin
      Document.AddLines('Õ‡ˆÂÌÍ‡:', AmountToStr(Command.Data.Markup));
    end;
    // »“Œ√
    Text := Document.ConcatLines('»“Œ√', AmountToStrEq(Command.Data.Total), Document.LineChars div 2);
    Document.AddLine(Text, STYLE_DWIDTH_HEIGHT);
    // Payments
    for i := 0 to Command.Data.Payments.Count-1 do
    begin
      Payment := Command.Data.Payments[i];
      if Payment.Sum <> 0 then
      begin
        Document.AddLines(Payment.PaymentTypeName + ':', AmountToStrEq(Payment.Sum));
      end;
    end;
    if Command.Data.Change <> 0 then
    begin
      Document.AddLines('  —ƒ¿◊¿', AmountToStrEq(Command.Data.Change));
    end;
    // VAT amounts
    if Command.Data.Tax <> 0 then
    begin
      Document.AddLines(Format('‚ Ú.˜. %s', [Command.Data.TaxPercent]),
          AmountToStrEq(Command.Data.Tax));
    end;
    Document.AddSeparator;
    Document.AddLine('‘ËÒÍ‡Î¸Ì˚È ÔËÁÌ‡Í: ' + CheckNumber);
    Document.AddLine('¬ÂÏˇ: ' + Command.Data.RegistratedOn);
    Document.AddLine('ŒÔÂ‡ÚÓ ÙËÒÍ‡Î¸Ì˚ı ‰‡ÌÌ˚ı:');
    Document.AddLine(Command.Data.Ofd.Name);
    Document.AddLine('ƒÎˇ ÔÓ‚ÂÍË ˜ÂÍ‡ Á‡È‰ËÚÂ Ì‡ Ò‡ÈÚ:');
    Document.AddLine(Command.Data.Ofd.Host);
    Document.AddSeparator;
    Document.AddLine(Document.AlignCenter('‘»— ¿À‹Õ€… ◊≈K'));
    Document.AddItem(Command.Data.TicketUrl, STYLE_QR_CODE);
    Document.AddLine('');
    Document.AddLine(Document.AlignCenter('»Õ  Œ‘ƒ: ' + Command.Data.CashboxIdentityNumber));
    Document.AddLine(Document.AlignCenter(' Ó‰   Ã  √ƒ (–ÕÃ): ' + Command.Data.CashboxRegistrationNumber));
    Document.AddLine(Document.AlignCenter('«ÕÃ: ' + Command.Data.CashboxUniqueNumber));
    Document.AddText(Receipt.Trailer.Text);
    // Print
    PrintDocumentSafe(Document);
  finally
    Command.Free;
  end;
end;

procedure TWebkassaImpl.PrintReceiptDuplicate2(const pString: WideString);

  function GetPaperKind: Integer;
  var
    LineWidthInMm: Integer;
  begin
    Printer.MapMode := PTR_MM_METRIC;
    LineWidthInMm := Printer.RecLineWidth;
    Printer.MapMode := PTR_MM_DOTS;

    if LineWidthInMm <= 5800 then
    begin
      Result := PaperKind58mm;
      Exit;
    end;
    if LineWidthInMm <= 8000 then
    begin
      Result := PaperKind80mm;
      Exit;
    end;
    if LineWidthInMm <= 21000 then
    begin
      Result := PaperKindA4Book;
      Exit;
    end;
    Result := PaperKindA4Album;
  end;

var
  i: Integer;
  Item: TReceiptTextItem;
  ExternalCheckNumber: WideString;
  Command: TReceiptTextCommand;
begin
  Document.Clear;
  FCapRecBold := Printer.CapRecBold;
  ExternalCheckNumber := pString;
  Command := TReceiptTextCommand.Create;
  try
    Command.Request.Token := FClient.Token;
    Command.Request.CashboxUniqueNumber := Params.CashboxNumber;
    Command.Request.ExternalCheckNumber := ExternalCheckNumber;
    Command.Request.isDuplicate := True;
    Command.Request.paperKind := GetPaperKind;
    FClient.ReadReceiptText(Command);
    for i := 0 to Command.Data.Lines.Count-1 do
    begin
      Item := Command.Data.Lines.Items[i] as TReceiptTextItem;
      case Item._Type of
        ItemTypeText:
        begin
          if (Item.Style = TextStyleNormal) then
            Document.AddLine(Item.Value, STYLE_NORMAL);
          if (Item.Style = TextStyleBold) then
            Document.AddLine(Item.Value, STYLE_BOLD);
        end;
        ItemTypePicture: Document.Add(Item.Value, STYLE_IMAGE);
        ItemTypeQRCode: Document.Add(Item.Value, STYLE_QR_CODE);
      end;
    end;
    // Print
    PrintDocumentSafe(Document);
  finally
    Command.Free;
  end;
end;

end.

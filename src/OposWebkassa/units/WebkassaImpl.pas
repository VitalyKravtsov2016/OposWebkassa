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
  SerialPort, PrinterPort, SocketPort;

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
    FCashboxStatusJson: TlkJSON;
    FCashboxStatus: TlkJSONbase;
    FTestMode: Boolean;
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
    FVatValues: array [MinVatID..MaxVatID] of Integer;
    FRecLineChars: Integer;
    FHeaderPrinted: Boolean;

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
    procedure PrintHeaderAndCut;
    procedure ClearCashboxStatus;
    procedure PrintText(Prefix, Text: WideString; RecLineChars: Integer);
    procedure PrintTextLine(Prefix, Text: WideString;
      RecLineChars: Integer);
    function CreatePrinter: IOPOSPOSPrinter;
    function CreateSerialPort: TSerialPort;
  public
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
    function GetUnitCode(const UnitName: string): Integer;
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

    property StateDoc: TlkJSONbase read FCashboxStatus;
    property Receipt: TCustomReceipt read FReceipt;
    property Document: TTextDocument read FDocument;
    property Duplicate: TTextDocument read FDuplicate;
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
    procedure PrintQRCode(const BarcodeData: WideString);

    property Logger: ILogFile read FLogger;
    property CashBox: TCashBox read FCashBox;
    property Client: TWebkassaClient read FClient;
    property Params: TPrinterParameters read FParams;
    property TestMode: Boolean read FTestMode write FTestMode;
    property OposDevice: TOposServiceDevice19 read FOposDevice;
  end;

implementation

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

{ TWebkassaImpl }

constructor TWebkassaImpl.Create(AOwner: TComponent);
begin
  ODS('TWebkassaImpl.Create');
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
  ODS('TWebkassaImpl.Create: OK');
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
  inherited Destroy;
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
      Result := TSalesReceipt.CreateReceipt(False, Params.AmountDecimalPlaces);

    FPTR_RT_REFUND:
      Result := TSalesReceipt.CreateReceipt(True, Params.AmountDecimalPlaces);
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
    Document.Clear;
    if PrintHeader then
    begin
      Document.AddText(Params.HeaderText);
    end;
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

    Document.Clear;
    Document.LineChars := Printer.RecLineChars;
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
begin
  try
    FOposDevice.CheckOpened;
    if Command = DIO_SET_DRIVER_PARAMETER then
    begin
      case pData of
        DriverParameterBarcode,
        DriverParameterExternalCheckNumber,
        DriverParameterFiscalSign:
          Receipt.DirectIO(Command, pData, pString);
      end;
    end;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
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

    PrintDocument(Document);

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
      FPTR_GD_RECEIPT_NUMBER: Data := ReadCashboxStatus.Get('Data').Get(
        'CurrentState').Get('ContinuousDocumentNumber').Value;
      FPTR_GD_REFUND: Data := AmountToOutStr(ReadRefundTotal);
      FPTR_GD_REFUND_VOID: Data := AmountToOutStr(0);
      FPTR_GD_Z_REPORT: Data := ReadCashboxStatus.Get('Data').Get(
        'CurrentState').Get('ShiftNumber').Value;
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
  Line1: string;
  Line2: string;
  Text: string;
  Total: Currency;
  Separator: string;
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

    Document.Clear;
    if not FHeaderPrinted then
    begin
      Document.AddText(Params.HeaderText);
    end;
    Document.PrintHeader := False;
    Document.LineChars := Printer.RecLineChars;
    Separator := StringOfChar('-', Document.LineChars);
    Document.AddLines('»ÕÕ/¡»Õ', Command.Data.CashboxRN);
    Document.AddLines('«ÕÃ', Command.Data.CashboxSN);
    Document.AddLines(' Ó‰   Ã  √ƒ (–ÕÃ)', IntToStr(Command.Data.CashboxIN));
    if IsZReport then
      Document.Add(Document.AlignCenter('Z-Œ“◊≈“'))
    else
      Document.Add(Document.AlignCenter('X-Œ“◊≈“'));
    Document.Add(Document.AlignCenter(Format('—Ã≈Õ¿ π%d', [Command.Data.ShiftNumber])));
    Document.Add(Document.AlignCenter(Format('%s-%s', [Command.Data.StartOn, Command.Data.ReportOn])));
    Node := Doc.Get('Data').Get('Sections');
    if Node.Count > 0 then
    begin
      Document.Add(Separator);
      Document.Add(Document.AlignCenter('Œ“◊≈“ œŒ —≈ ÷»ﬂÃ'));
      Document.Add(Separator);
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
    Document.Add(Separator);
    if IsZReport then
      Document.Add(Document.AlignCenter('Œ“◊≈“ — √¿ÿ≈Õ»≈Ã'))
    else
      Document.Add(Document.AlignCenter('Œ“◊≈“ ¡≈« √¿ÿ≈Õ»ﬂ'));
    Document.Add(Separator);
    Document.Add('Õ≈Œ¡Õ”À. —”ÃÃ€ Õ¿ Õ¿◊¿ÀŒ —Ã≈Õ€');
    Document.AddLines('œ–Œƒ¿∆', AmountToStr(Command.Data.StartNonNullable.Sell));
    Document.AddLines('œŒ ”œŒ ', AmountToStr(Command.Data.StartNonNullable.Buy));
    Document.AddLines('¬Œ«¬–¿“Œ¬ œ–Œƒ¿∆', AmountToStr(Command.Data.StartNonNullable.ReturnSell));
    Document.AddLines('¬Œ«¬–¿“Œ¬ œŒ ”œŒ ', AmountToStr(Command.Data.StartNonNullable.ReturnBuy));

    Document.Add('◊≈ Œ¬ œ–Œƒ¿∆');
    Line1 := Format('%.4d', [Command.Data.Sell.Count]);
    Line2 := AmountToStr(Total);
    Text := Line1 + StringOfChar(' ', (Document.LineChars div 2)-Length(Line1)-Length(Line2)) + Line2;
    Document.Add(Text, STYLE_DWIDTH_HEIGHT);
    AddPayments(Document, Command.Data.Sell.PaymentsByTypesApiModel);

    Document.Add('◊≈ Œ¬ œŒ ”œŒ ');
    Line1 := Format('%.4d', [Command.Data.Buy.Count]);
    Line2 := AmountToStr(Command.Data.Buy.Taken);
    Text := Line1 + StringOfChar(' ', (Document.LineChars div 2)-Length(Line1)-Length(Line2)) + Line2;
    Document.Add(Text, STYLE_DWIDTH_HEIGHT);
    AddPayments(Document, Command.Data.Buy.PaymentsByTypesApiModel);

    Document.Add('◊≈ Œ¬ ¬Œ«¬–¿“Œ¬ œ–Œƒ¿∆');
    Line1 := Format('%.4d', [Command.Data.ReturnSell.Count]);
    Line2 := AmountToStr(Command.Data.ReturnSell.Taken);
    Text := Line1 + StringOfChar(' ', (Document.LineChars div 2)-Length(Line1)-Length(Line2)) + Line2;
    Document.Add(Text, STYLE_DWIDTH_HEIGHT);
    AddPayments(Document, Command.Data.ReturnSell.PaymentsByTypesApiModel);

    Document.Add('◊≈ Œ¬ ¬Œ«¬–¿“Œ¬ œŒ ”œŒ ');
    Line1 := Format('%.4d', [Command.Data.ReturnBuy.Count]);
    Line2 := AmountToStr(Command.Data.ReturnBuy.Taken);
    Text := Line1 + StringOfChar(' ', (Document.LineChars div 2)-Length(Line1)-Length(Line2)) + Line2;
    Document.Add(Text, STYLE_DWIDTH_HEIGHT);
    AddPayments(Document, Command.Data.ReturnBuy.PaymentsByTypesApiModel);

    Document.Add('¬Õ≈—≈Õ»…');
    Node := Doc.Get('Data').Get('MoneyPlacementOperations').Get('Deposit');
    Count := Node.Get('Count').Value;
    Amount := Node.Get('Amount').Value;
    Document.AddLines(Format('%.4d', [Count]), AmountToStr(Amount));
    Document.Add('»«⁄ﬂ“»…');
    Node := Doc.Get('Data').Get('MoneyPlacementOperations').Get('WithDrawal');
    Count := Node.Get('Count').Value;
    Amount := Node.Get('Amount').Value;
    Document.AddLines(Format('%.4d', [Count]), AmountToStr(Amount));

    Document.AddLines('Õ¿À»◊Õ€’ ¬  ¿——≈', AmountToStr(Command.Data.SumInCashbox));
    Document.AddLines('¬€–”◊ ¿', AmountToStr(Total));
    Document.Add('Õ≈Œ¡Õ”À. —”ÃÃ€ Õ¿  ŒÕ≈÷ —Ã≈Õ€');
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
      PIDX_DeviceEnabled            : SetDeviceEnabled(IntToBool(Number));
      PIDX_DataEventEnabled         : FOposDevice.DataEventEnabled := IntToBool(Number);
      PIDX_PowerNotify              : FOposDevice.PowerNotify := Number;
      PIDX_BinaryConversion         : FOposDevice.BinaryConversion := Number;
      // Specific
      PIDXFptr_AsyncMode            : FAsyncMode := IntToBool(Number);
      PIDXFptr_CheckTotal           : FCheckTotal := IntToBool(Number);
      PIDXFptr_DateType             : FDateType := Number;
      PIDXFptr_DuplicateReceipt     : FDuplicateReceipt := IntToBool(Number);
      PIDXFptr_FiscalReceiptStation : FFiscalReceiptStation := Number;

      PIDXFptr_FiscalReceiptType:
      begin
        CheckState(FPTR_PS_MONITOR);
        FFiscalReceiptType := Number;
      end;
      PIDXFptr_FlagWhenIdle         : FFlagWhenIdle := IntToBool(Number);
      PIDXFptr_MessageType          : FMessageType := Number;
      PIDXFptr_SlipSelection        : FSlipSelection := Number;
      PIDXFptr_TotalizerType        : FTotalizerType := Number;
      PIDX_FreezeEvents             : FOposDevice.FreezeEvents := Number <> 0;
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
  Logger.Debug(Format('PtrStatusUpdateEvent: %d, %s', [
    Data, PtrStatusUpdateEventText(Data)]));

  if IsValidFptrStatusUpdateEvent(Data) then
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
    if not FTestMode then
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

    if FPrinter = nil then
    begin
      FPrinter := CreatePrinter;
    end;
    //FRecLineChars := StrToInt(Params.FontName); !!!
    FRecLineChars := FPrinter.RecLineChars;

    CheckPtr(Printer.Open(FParams.PrinterName));

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

function GetMaxRecLine(const RecLineCharsList: string): Integer;
var
  S: string;
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
    end else
    begin
      FClient.Disconnect;
    end;
    FDeviceEnabled := Value;
    FUnitsUpdated := False;
    FCashBoxesUpdated := False;
    FOposDevice.DeviceEnabled := Value;
    Printer.DeviceEnabled := Value;
    CheckPtr(Printer.ResultCode);
    Printer.RecLineChars := FRecLineChars;
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
    Command.Request.ExternalCheckNumber := Receipt.ExternalCheckNumber;
    FClient.Execute(Command);
    // Create Document
    Document.PrintHeader := Receipt.PrintHeader;
    Document.LineChars := Printer.RecLineChars;
    Document.Add('¡»Õ ' + Command.Data.Cashbox.RegistrationNumber);
    Document.Add(Format('«ÕÃ %s »Õ  Œ‘ƒ %s', [Command.Data.Cashbox.UniqueNumber,
      Command.Data.Cashbox.IdentityNumber]));
    Document.Add(Command.Data.DateTime);
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
    Command.Request.ExternalCheckNumber := Receipt.ExternalCheckNumber;
    FClient.Execute(Command);
    //
    Document.PrintHeader := Receipt.PrintHeader;
    Document.LineChars := Printer.RecLineChars;
    Document.Add('¡»Õ ' + Command.Data.Cashbox.RegistrationNumber);
    Document.Add(Format('«ÕÃ %s »Õ  Œ‘ƒ %s', [Command.Data.Cashbox.UniqueNumber,
      Command.Data.Cashbox.IdentityNumber]));
    Document.Add(Command.Data.DateTime);
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

function TWebkassaImpl.GetUnitCode(const UnitName: string): Integer;
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
var
  i: Integer;
  Payment: TPayment;
  Discount: TAdjustment;
  VatRate: TVatRate;
  Item: TSalesReceiptItem;
  ReceiptItem: TReceiptItem;
  OperationType: Integer;
  Position: TTicketItem;
  Modifier: TTicketModifier;
  Command: TSendReceiptCommand;
begin
  Command := TSendReceiptCommand.Create;
  try
    OperationType := OperationTypeSell;
    if Receipt.IsRefund then
      OperationType := OperationTypeRetSell;

    Command.Request.Token := FClient.Token;
    Command.Request.CashboxUniqueNumber := Params.CashboxNumber;
    Command.Request.OperationType := OperationType;
    Command.Request.Change := Receipt.Change;
    Command.Request.RoundType := FParams.RoundType;
    Command.Request.ExternalCheckNumber := Receipt.ExternalCheckNumber;
    Command.Request.CustomerEmail := '';
    Command.Request.CustomerPhone := '';
    Command.Request.CustomerXin := '';

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
        Position.PositionCode := '';
        Position.Discount := Item.GetDiscount;
        Position.Markup := Item.GetCharge;
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
          Position.Tax := Abs(VatRate.GetTax(Item.Total));
          Position.TaxType := TaxTypeVAT;
          Position.TaxPercent := VatRate.Rate;
        end;
      end;
    end;
    // Discounts
    for i := 0 to Receipt.Adjustments.Count-1 do
    begin
      Discount := Receipt.Adjustments[i];
      Modifier := Command.Request.TicketModifiers.Add as TTicketModifier;

      Modifier.Sum := Abs(Discount.Total);
      Modifier.Text := Discount.Description;
      Modifier._Type := ModifierTypeDiscount;
      if Discount.Total < 0 then
        Modifier._Type := ModifierTypeCharge;
      Modifier.TaxType := TaxTypeNoTax;
      Modifier.Tax := 0;
    end;
    // Payments
    for i := 0 to 3 do
    begin
      if Receipt.Payments[i] <> 0 then
      begin
        Payment := Command.Request.Payments.Add as TPayment;
        Payment.PaymentType := i;
        Payment.Sum := Receipt.Payments[i];
      end;
    end;
    FClient.SendReceipt(Command);
    PrintReceipt(Receipt, Command);
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
"œ–Œƒ¿∆¿",
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
  AdjustmentName: WideString;
begin
  Document.PrintHeader := Receipt.PrintHeader;
  Document.LineChars := Printer.RecLineChars;

  Document.Addlines(Format('Õƒ— —ÂËˇ %s', [Params.VATSeries]),
    Format('π %s', [Params.VATNumber]));
  Document.AddSeparator;
  Document.Add(Document.AlignCenter(FCashBox.Name));
  Document.Add(Document.AlignCenter(Format('—ÏÂÌ‡ %d', [Command.Data.ShiftNumber])));
  //Document.Add(AlignCenter(Format('œÓˇ‰ÍÓ‚˚È ÌÓÏÂ ˜ÂÍ‡ π%d', [Command.Data.DocumentNumber])));
  Document.Add(Format('◊ÂÍ π%s', [Command.Data.CheckNumber]));
  //Document.Add(Format(' ‡ÒÒË %s', [Command.Data.EmployeeName]));
  //Document.Add(UpperCase(Command.Data.OperationTypeText));
  Document.AddSeparator;


  for i := 0 to Receipt.Items.Count-1 do
  begin
    ReceiptItem := Receipt.Items[i];
    if ReceiptItem is TSalesReceiptItem then
    begin
      RecItem := ReceiptItem as TSalesReceiptItem;
      //Document.Add(Format('%3d. %s', [RecItem.Number, RecItem.Description]));
      Document.Add(RecItem.Description);

      ItemQuantity := 1;
      UnitPrice := RecItem.Price;
      if RecItem.Quantity <> 0 then
      begin
        ItemQuantity := RecItem.Quantity;
        UnitPrice := RecItem.UnitPrice;
      end;
      Document.Add(Format('   %.3f %s x %s', [ItemQuantity,
        RecItem.UnitName, AmountToStr(UnitPrice)]));
      // —ÍË‰Í‡
      Amount := RecItem.GetDiscount;
      if Amount <> 0 then
      begin
        Document.AddLines('   —ÍË‰Í‡ ' + AdjustmentName,
          '-' + AmountToStr(Amount));
      end;
      // Õ‡ˆÂÌÍ‡
      Amount := RecItem.GetCharge;
      if Amount <> 0 then
      begin
        Document.AddLines('   Õ‡ˆÂÌÍ‡ ' + AdjustmentName,
          '+' + AmountToStr(Amount));
      end;
      Document.AddLines('   —ÚÓËÏÓÒÚ¸', AmountToStr(RecItem.GetTotalWithDiscount));
    end;
    // Text
    if ReceiptItem is TRecTexItem then
    begin
      TextItem := ReceiptItem as TRecTexItem;
      Document.Add(TextItem.Text, TextItem.Style);
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
  Document.Add(Text, STYLE_DWIDTH_HEIGHT);
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
  if Receipt.FiscalSign <> '' then
  begin
    Document.Add('‘ËÒÍ‡Î¸Ì˚È ÔËÁÌ‡Í: ' + Receipt.FiscalSign);
  end;
  Document.Add('¬ÂÏˇ: ' + Command.Data.DateTime);
  Document.Add('ŒÔÂ‡ÚÓ ÙËÒÍ‡Î¸Ì˚ı ‰‡ÌÌ˚ı:');
  Document.Add(Command.Data.Cashbox.Ofd.Name);
  Document.Add('ƒÎˇ ÔÓ‚ÂÍË ˜ÂÍ‡ Á‡È‰ËÚÂ Ì‡ Ò‡ÈÚ:');
  Document.Add(Command.Data.Cashbox.Ofd.Host);
  Document.AddSeparator;
  Document.Add(Document.AlignCenter('‘»— ¿À‹Õ€… ◊≈K'));
  Document.Add(Command.Data.TicketUrl, STYLE_QR_CODE);
  Document.Add(Document.AlignCenter('»Õ  Œ‘ƒ: ' + Command.Data.Cashbox.IdentityNumber));
  Document.Add(Document.AlignCenter(' Ó‰   Ã  √ƒ (–ÕÃ): ' + Command.Data.Cashbox.RegistrationNumber));
  Document.Add(Document.AlignCenter('«ÕÃ: ' + Command.Data.Cashbox.UniqueNumber));
  Document.AddText(Receipt.Trailer.Text);

  PrintDocumentSafe(Document);
  Printer.RecLineChars := FRecLineChars;
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
  CheckCanPrint;
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
  Text: WideString;
  CapRecBold: Boolean;
  CapRecDwideDhigh: Boolean;
  RecLineChars: Integer;
  Item: TTextItem;
  TickCount: DWORD;
  Prefix: string;
begin
  Logger.Debug('PrintDocument');
  TickCount := GetTickCount;

  CheckCanPrint;
  CapRecDwideDhigh := Printer.CapRecDwideDhigh;
  CapRecBold := Printer.CapRecBold;

  if Printer.CapTransaction then
  begin
    CheckPtr(Printer.TransactionPrint(PTR_S_RECEIPT, PTR_TP_TRANSACTION));
  end;
  for i := 0 to Document.Items.Count-1 do
  begin
    RecLineChars := Printer.RecLineChars;
    Item := Document.Items[i] as TTextItem;
    case Item.Style of
      STYLE_QR_CODE:
      begin
        if Printer.CapRecBarcode then
        begin
          if Printer.PrintBarCode(PTR_S_RECEIPT, Item.Text, PTR_BCS_QRCODE, 0, 4,
            PTR_BC_CENTER, PTR_BC_TEXT_NONE) <> OPOS_SUCCESS then
          begin
            PrintQRCode(Item.Text);
          end;
        end else
        begin
          PrintQRCode(Item.Text);
        end;
      end;
    else
      Text := Item.Text;
      Prefix := '';
      // DWDH
      if Item.Style = STYLE_DWIDTH_HEIGHT then
      begin
        RecLineChars := RecLineChars div 2;
        if CapRecDwideDhigh then
          Prefix := ESC_DoubleHighWide;
      end;
      // BOLD
      if Item.Style = STYLE_BOLD then
      begin
        if CapRecBold then
          Prefix := ESC_Bold;
      end;
      PrintText(Prefix, Text, RecLineChars);
    end;
  end;
  PrintHeaderAndCut;
  if Printer.CapTransaction then
  begin
    CheckPtr(Printer.TransactionPrint(PTR_S_RECEIPT, PTR_TP_NORMAL));
  end;
  Logger.Debug(Format('PrintDocument, time=%d ms', [GetTickCount-TickCount]));
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
  while Length(Text) > 0 do
  begin
    Line := Prefix + TrimRight(Copy(Text, 1, RecLineChars));
    CheckPtr(Printer.PrintNormal(PTR_S_RECEIPT, Line + CRLF));
    Text := Copy(Text, RecLineChars + 1, Length(Text));
  end;
end;

procedure TWebkassaImpl.PrintHeaderAndCut;
var
  i: Integer;
  Count: Integer;
  Text: WideString;
  RecLinesToPaperCut: Integer;
begin
  if Printer.CapRecPapercut then
  begin
    RecLinesToPaperCut := Printer.RecLinesToPaperCut;
    if Document.PrintHeader then
    begin
      if FParams.NumHeaderLines <= RecLinesToPaperCut then
      begin
        for i := 0 to Params.Header.Count-1 do
        begin
          Text := TrimRight(Params.Header[i]) + CRLF;
          CheckPtr(Printer.PrintNormal(PTR_S_RECEIPT, Text));
        end;
        Count := RecLinesToPaperCut - FParams.NumHeaderLines;
        for i := 0 to Count-1 do
        begin
          CheckPtr(Printer.PrintNormal(PTR_S_RECEIPT, CRLF));
        end;
        Printer.CutPaper(90);
      end else
      begin
        for i := 1 to RecLinesToPaperCut do
        begin
          CheckPtr(Printer.PrintNormal(PTR_S_RECEIPT, CRLF));
        end;
        Printer.CutPaper(90);
        for i := 0 to Params.Header.Count-1 do
        begin
          Text := TrimRight(Params.Header[i]) + CRLF;
          CheckPtr(Printer.PrintNormal(PTR_S_RECEIPT, Text));
        end;
      end;
    end else
    begin
      for i := 1 to RecLinesToPaperCut do
      begin
        Printer.PrintNormal(PTR_S_RECEIPT, CRLF);
      end;
      Printer.CutPaper(90);
    end;
  end;
  FHeaderPrinted := Document.PrintHeader;
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

procedure RenderBarcode(Bitmap: TBitmap; Symbol: PZSymbol; Is1D: Boolean);
var
  B: Byte;
  X, Y: Integer;
begin
  Bitmap.Monochrome := True;
  Bitmap.PixelFormat := pf1Bit;
  Bitmap.Width := Symbol.width;
  if Is1D then
    Bitmap.Height := Symbol.Height
  else
    Bitmap.Height := Symbol.rows;

  for X := 0 to Symbol.width-1 do
  for Y := 0 to Symbol.Height-1 do
  begin
    Bitmap.Canvas.Pixels[X, Y] := clWhite;
    if Is1D then
      B := Byte(Symbol.encoded_data[0][X div 7])
    else
      B := Byte(Symbol.encoded_data[Y][X div 7]);

    if (B and (1 shl (X mod 7))) <> 0 then
      Bitmap.Canvas.Pixels[X, Y] := clBlack;
  end;
end;

procedure ScaleBitmap(Bitmap: TBitmap; Scale: Integer);
var
  P: TPoint;
  DstBitmap: TBitmap;
begin
  DstBitmap := TBitmap.Create;
  try
    DstBitmap.Monochrome := True;
    DstBitmap.PixelFormat := pf1Bit;
    P.X := Bitmap.Width * Scale;
    P.Y := Bitmap.Height * Scale;
    DstBitmap.Width := P.X;
    DstBitmap.Height := P.Y;
    DstBitmap.Canvas.StretchDraw(Rect(0, 0, P.X, P.Y), Bitmap);
    Bitmap.Assign(DstBitmap);
  finally
    DstBitmap.Free;
  end;
end;

procedure TWebkassaImpl.PrintQRCode(const BarcodeData: WideString);
var
  Data: string;
  Bitmap: TBitmap;
  Render: TZintBarcode;
  Stream: TMemoryStream;
  BitmapData: WideString;
begin
  if not Printer.CapRecBitmap then Exit;

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

    Stream.Position := 0;
    if Stream.Size > 0 then
    begin
      SetLength(Data, Stream.Size);
      Stream.ReadBuffer(Data[1], Stream.Size);

      Printer.BinaryConversion := OPOS_BC_NIBBLE;
      try
        BitmapData := OposStrToNibble(Data);
        CheckPtr(Printer.PrintMemoryBitmap(PTR_S_RECEIPT, BitmapData,
          PTR_BMT_BMP, PTR_BM_ASIS, PTR_BM_CENTER));
      finally
        Printer.BinaryConversion := OPOS_BC_NONE;
      end;
    end;
  finally
    Render.Free;
    Bitmap.Free;
    Stream.Free;
  end;
end;

end.

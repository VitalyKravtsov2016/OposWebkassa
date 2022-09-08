unit WebkassaImpl;

interface

uses
  // VCL
  Classes, SysUtils, Windows, DateUtils, ActiveX, ComObj, Math,
  // Tnt
  TntSysUtils,
  // Opos
  Opos, OposPtr, OposPtrUtils, Oposhi, OposFptr, OposFptrHi, OposEvents,
  OposEventsRCS, OposException, OposFptrUtils, OposServiceDevice19,
  OposUtils, OposEsc, OposPOSPrinter_CCO_TLB,
  // Json
  uLkJSON,
  // gnugettext
  gnugettext,
  // This
  OPOSWebkassaLib_TLB, LogFile, WException, VersionInfo, DriverError,
  WebkassaClient, FiscalPrinterState, CustomReceipt, NonFiscalDoc, ServiceVersion,
  PrinterParameters, PrinterParametersX, CashInReceipt, CashOutReceipt,
  SalesReceipt, TextDocument, ReceiptItem, StringUtils, PrinterLines,
  DebugUtils, VatRate, PosPrinterLog;

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
    FPOSID: WideString;
    FCashierID: WideString;
    FLogger: ILogFile;
    FUnits: TUnitItems;
    FHeader: TPrinterLines;
    FTrailer: TPrinterLines;
    FClient: TWebkassaClient;
    FDocument: TTextDocument;
    FReceipt: TCustomReceipt;
    FPrinter: IOPOSPOSPrinter;
    FPrinterLog: TPOSPrinterLog;
    FParams: TPrinterParameters;
    FOposDevice: TOposServiceDevice19;
    FPrinterState: TFiscalPrinterState;
    FVatValues: array [MinVatID..MaxVatID] of Integer;
    FRecLineChars: Integer;
    FMaxRecLineChars: Integer;
    procedure PrintDocumentSafe(Document: TTextDocument);
    procedure CheckCanPrint;
    function GetVatRate(Code: Integer): TVatRate;
    function AmountToStr(Value: Currency): AnsiString;
    procedure SetPrinter(const Value: IOPOSPOSPrinter);
  public
    procedure Initialize;
    procedure CheckEnabled;
    function IllegalError: Integer;
    procedure CheckState(AState: Integer);
    procedure SetPrinterState(Value: Integer);
    function DoClose: Integer;
    function GetPrinterStation(Station: Integer): Integer;
    procedure Print(Receipt: TCashInReceipt); overload;
    procedure Print(Receipt: TCashOutReceipt); overload;
    procedure Print(Receipt: TSalesReceipt); overload;
    procedure PrintReceipt(const ACheckNumber: string; IsDuplicate: Boolean);
    function GetPrinterState: Integer;
    function DoRelease: Integer;
    procedure UpdateUnits;
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

    property Receipt: TCustomReceipt read FReceipt;
    property Document: TTextDocument read FDocument;
    property Printer: IOPOSPOSPrinter read GetPrinter write SetPrinter;
    property PrinterState: Integer read GetPrinterState write SetPrinterState;
  private
    FPostLine: WideString;
    FPreLine: WideString;

    FDeviceEnabled: Boolean;
    FAmountDecimalPlaces: Integer;
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
    FCashierFullName: WideString;
    FCheckNumber: WideString;
    FUnitsUpdated: Boolean;

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

    property Logger: ILogFile read FLogger;
    property Client: TWebkassaClient read FClient;
    property Params: TPrinterParameters read FParams;
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

function CurrencyToStr(Value: Currency): WideString;
var
  SaveDecimalSeparator: Char;
begin
  SaveDecimalSeparator := DecimalSeparator;
  try
    DecimalSeparator := '.';
    Result := Tnt_WideFormat('%.2f', [Value]);
  finally
    DecimalSeparator := SaveDecimalSeparator;
  end;
end;

{ TWebkassaImpl }

constructor TWebkassaImpl.Create(AOwner: TComponent);
begin
  ODS('TWebkassaImpl.Create');
  inherited Create(AOwner);
  FLogger := TLogFile.Create;
  FDocument := TTextDocument.Create;
  FReceipt := TCustomReceipt.Create;
  FClient := TWebkassaClient.Create(FLogger);
  FParams := TPrinterParameters.Create(FLogger);
  FOposDevice := TOposServiceDevice19.Create(FLogger);
  FOposDevice.ErrorEventEnabled := False;
  FPrinterState := TFiscalPrinterState.Create;
  FUnits := TUnitItems.Create(TUnitItem);
  FClient.RaiseErrors := True;
  FHeader := TPrinterLines.Create(TPrinterLine);
  FTrailer := TPrinterLines.Create(TPrinterLine);
  ODS('TWebkassaImpl.Create: OK');
end;

destructor TWebkassaImpl.Destroy;
begin
  Close;
  FClient.Free;
  FParams.Free;
  FUnits.Free;
  FDocument.Free;
  FOposDevice.Free;
  FPrinterState.Free;
  FHeader.Free;
  FTrailer.Free;
  FReceipt.Free;
  FPrinter := nil;
  FPrinterLog.Free;
  inherited Destroy;
end;

function TWebkassaImpl.AmountToStr(Value: Currency): AnsiString;
begin
  if FAmountDecimalPlaces = 0 then
  begin
    Result := IntToStr(Round(Value));
  end else
  begin
    Result := Format('%.*f', [FAmountDecimalPlaces, Value]);
  end;
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
      Result := TSalesReceipt.CreateReceipt(False, FAmountDecimalPlaces);

    FPTR_RT_REFUND:
      Result := TSalesReceipt.CreateReceipt(True, FAmountDecimalPlaces);
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
  FAmountDecimalPlaces := 0;
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
const
  DIO_SET_DRIVER_PARAMETER        = 30; // write internal driver parameter
  DIO_WRITE_FS_STRING_TAG_OP      = 65; // Write string tag bound to operation
  DIO_READ_FS_PARAMETER           = 41; // Read fiscal storage parameter
  DIO_FS_PARAMETER_LAST_DOC_NUM2  = 11; // Document number
begin
  try
    FOposDevice.CheckOpened;
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
    FReceipt.EndFiscalReceipt;
    FReceipt.Print(Self);
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
    Document.AddText(Params.Trailer);
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

function TWebkassaImpl.GetData(DataItem: Integer; out OptArgs: Integer;
  out Data: WideString): Integer;
begin
  try
    case DataItem of
      FPTR_GD_FIRMWARE:;
      FPTR_GD_PRINTER_ID: Data := Params.CashboxNumber;
      FPTR_GD_CURRENT_TOTAL: Data := CurrencyToStr(Receipt.GetTotal());
      FPTR_GD_DAILY_TOTAL: Data := CurrencyToStr(0);
      FPTR_GD_GRAND_TOTAL: Data := CurrencyToStr(0);
      FPTR_GD_MID_VOID: Data := CurrencyToStr(0);
      FPTR_GD_NOT_PAID: Data := CurrencyToStr(0);
      FPTR_GD_RECEIPT_NUMBER: Data := FCheckNumber;
      FPTR_GD_REFUND: Data := CurrencyToStr(0);
      FPTR_GD_REFUND_VOID: Data := CurrencyToStr(0);

      FPTR_GD_FISCAL_DOC,
      FPTR_GD_FISCAL_DOC_VOID,
      FPTR_GD_FISCAL_REC,
      FPTR_GD_FISCAL_REC_VOID,
      FPTR_GD_NONFISCAL_DOC,
      FPTR_GD_NONFISCAL_DOC_VOID,
      FPTR_GD_NONFISCAL_REC,
      FPTR_GD_RESTART,
      FPTR_GD_SIMP_INVOICE,
      FPTR_GD_Z_REPORT,
      FPTR_GD_TENDER,
      FPTR_GD_LINECOUNT:
        Data := CurrencyToStr(0);
      FPTR_GD_DESCRIPTION_LENGTH: Data := IntToStr(Printer.RecLineChars);
    else
      InvalidParameterValue('DataItem', IntToStr(DataItem));
    end;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
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
      PIDXFptr_AmountDecimalPlaces    : Result := FAmountDecimalPlaces;
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
begin
  FOposDevice.ErrorString := _('—˜ÂÚ˜ËÍ ÌÂ ÔÓ‰‰ÂÊË‚‡ÂÚÒˇ');
  Result := FOposDevice.SetResultCode(OPOS_E_ILLEGAL);
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
  Result := IllegalError;
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


function AlignCenter(const Line: WideString; LineWidth: Integer): WideString;
var
  L: Integer;
begin
  Result := Copy(Line, 1, LineWidth);
  if Length(Result) < LineWidth then
  begin
    L := (LineWidth - Length(Result)) div 2;
    Result := StringOfChar(' ', L) + Result + StringOfChar(' ', LineWidth - Length(Result) - L);
  end;
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
  Document: TTextDocument;
  Command: TZXReportCommand;

  Json: TlkJSON;
  Doc: TlkJSONbase;
  Node: TlkJSONbase;
  Count: Integer;
  Amount: Currency;
begin
  CheckCanPrint;

  Json := TlkJSON.Create;
  Document := TTextDocument.Create;
  Command := TZXReportCommand.Create;
  try
    Command.Request.Token := FClient.Token;
    Command.Request.CashboxUniqueNumber := FClient.CashboxNumber;
    if IsZReport then
      FClient.ZReport(Command)
    else
      FClient.XReport(Command);

    Doc := Json.ParseText(FClient.AnswerJson);

    Total :=
      (Command.Data.EndNonNullable.Sell - Command.Data.StartNonNullable.Sell) -
      (Command.Data.EndNonNullable.Buy - Command.Data.StartNonNullable.Buy) -
      (Command.Data.EndNonNullable.ReturnSell - Command.Data.StartNonNullable.ReturnSell) +
      (Command.Data.EndNonNullable.ReturnBuy - Command.Data.StartNonNullable.ReturnBuy);

    Document.LineChars := Printer.RecLineChars;
    Document.AddText(Params.Header);

    Separator := StringOfChar('-', Document.LineChars);
    Document.AddLines('»ÕÕ/¡»Õ', Command.Data.CashboxRN);
    Document.AddLines('«ÕÃ', Command.Data.CashboxSN);
    Document.AddLines(' Ó‰   Ã  √ƒ (–ÕÃ)', IntToStr(Command.Data.CashboxIN));
    if IsZReport then
      Document.Add(AlignCenter('Z-Œ“◊≈“', Document.LineChars))
    else
      Document.Add(AlignCenter('X-Œ“◊≈“', Document.LineChars));
    Document.Add(AlignCenter(Format('—Ã≈Õ¿ π%d', [Command.Data.ShiftNumber]), Document.LineChars));
    Document.Add(AlignCenter(Format('%s-%s', [Command.Data.StartOn, Command.Data.ReportOn]), Document.LineChars));
    Node := Doc.Field['Data'].Field['Sections'];
    if Node.Count > 0 then
    begin
      Document.Add(Separator);
      Document.Add(AlignCenter('Œ“◊≈“ œŒ —≈ ÷»ﬂÃ', Document.LineChars));
      Document.Add(Separator);
      for i := 0 to Node.Count-1 do
      begin
        Count := Node.Child[i].Field['Code'].Value;
        Document.AddLines('—≈ ÷»ﬂ', IntToStr(Count + 1));
        Count := Node.Child[i].Field['Operations'].Field['Sell'].Field['Count'].Value;
        Amount := Node.Child[i].Field['Operations'].Field['Sell'].Field['Amount'].Value;
        Document.AddLines(Format('%.4d œ–Œƒ¿∆', [Count]), AmountToStr(Amount));
      end;
    end;
    Document.Add(Separator);
    if IsZReport then
      Document.Add(AlignCenter('Œ“◊≈“ — √¿ÿ≈Õ»≈Ã', Document.LineChars))
    else
      Document.Add(AlignCenter('Œ“◊≈“ ¡≈« √¿ÿ≈Õ»ﬂ', Document.LineChars));
    Document.Add(Separator);
    Document.Add('Õ≈Œ¡Õ”À. —”ÃÃ€ Õ¿ Õ¿◊¿ÀŒ —Ã≈Õ€');
    Document.AddLines('œ–Œƒ¿∆', CurrencyToStr(Command.Data.StartNonNullable.Sell));
    Document.AddLines('œŒ ”œŒ ', CurrencyToStr(Command.Data.StartNonNullable.Buy));
    Document.AddLines('¬Œ«¬–¿“Œ¬ œ–Œƒ¿∆', CurrencyToStr(Command.Data.StartNonNullable.ReturnSell));
    Document.AddLines('¬Œ«¬–¿“Œ¬ œŒ ”œŒ ', CurrencyToStr(Command.Data.StartNonNullable.ReturnBuy));

    Document.Add('◊≈ Œ¬ œ–Œƒ¿∆');
    Line1 := Format('%.4d', [Command.Data.Sell.Count]);
    Line2 := CurrencyToStr(Total);
    Text := Line1 + StringOfChar(' ', (Document.LineChars div 2)-Length(Line1)-Length(Line2)) + Line2;
    Document.Add(Text, STYLE_DWIDTH_HEIGHT);
    AddPayments(Document, Command.Data.Sell.PaymentsByTypesApiModel);

    Document.Add('◊≈ Œ¬ œŒ ”œŒ ');
    Line1 := Format('%.4d', [Command.Data.Buy.Count]);
    Line2 := CurrencyToStr(Command.Data.Buy.Taken);
    Text := Line1 + StringOfChar(' ', (Document.LineChars div 2)-Length(Line1)-Length(Line2)) + Line2;
    Document.Add(Text, STYLE_DWIDTH_HEIGHT);
    AddPayments(Document, Command.Data.Buy.PaymentsByTypesApiModel);

    Document.Add('◊≈ Œ¬ ¬Œ«¬–¿“Œ¬ œ–Œƒ¿∆');
    Line1 := Format('%.4d', [Command.Data.ReturnSell.Count]);
    Line2 := CurrencyToStr(Command.Data.ReturnSell.Taken);
    Text := Line1 + StringOfChar(' ', (Document.LineChars div 2)-Length(Line1)-Length(Line2)) + Line2;
    Document.Add(Text, STYLE_DWIDTH_HEIGHT);
    AddPayments(Document, Command.Data.ReturnSell.PaymentsByTypesApiModel);

    Document.Add('◊≈ Œ¬ ¬Œ«¬–¿“Œ¬ œŒ ”œŒ ');
    Line1 := Format('%.4d', [Command.Data.ReturnBuy.Count]);
    Line2 := CurrencyToStr(Command.Data.ReturnBuy.Taken);
    Text := Line1 + StringOfChar(' ', (Document.LineChars div 2)-Length(Line1)-Length(Line2)) + Line2;
    Document.Add(Text, STYLE_DWIDTH_HEIGHT);
    AddPayments(Document, Command.Data.ReturnBuy.PaymentsByTypesApiModel);

    Document.Add('¬Õ≈—≈Õ»…');
    Node := Doc.Field['Data'].Field['MoneyPlacementOperations'].Field['Deposit'];
    Count := Node.Field['Count'].Value;
    Amount := Node.Field['Amount'].Value;
    Document.AddLines(Format('%.4d', [Count]), CurrencyToStr(Amount));
    Document.Add('»«⁄ﬂ“»…');
    Node := Doc.Field['Data'].Field['MoneyPlacementOperations'].Field['WithDrawal'];
    Count := Node.Field['Count'].Value;
    Amount := Node.Field['Amount'].Value;
    Document.AddLines(Format('%.4d', [Count]), CurrencyToStr(Amount));

    Document.AddLines('Õ¿À»◊Õ€’ ¬  ¿——≈', CurrencyToStr(Command.Data.SumlnCashbox));
    Document.AddLines('¬€–”◊ ¿', CurrencyToStr(Total));
    Document.Add('Õ≈Œ¡Õ”À. —”ÃÃ€ Õ¿  ŒÕ≈÷ —Ã≈Õ€');
    Document.AddLines('œ–Œƒ¿∆', CurrencyToStr(Command.Data.EndNonNullable.Sell));
    Document.AddLines('œŒ ”œŒ ', CurrencyToStr(Command.Data.EndNonNullable.Buy));
    Document.AddLines('¬Œ«¬–¿“Œ¬ œ–Œƒ¿∆', CurrencyToStr(Command.Data.EndNonNullable.ReturnSell));
    Document.AddLines('¬Œ«¬–¿“Œ¬ œŒ ”œŒ ', CurrencyToStr(Command.Data.EndNonNullable.ReturnBuy));
    Document.AddLines('—‘ÓÏËÓ‚‡ÌÓ Œ‘ƒ: ', Command.Data.Ofd.Name);
    Document.AddText(Params.Trailer);

    PrintDocumentSafe(Document);
  finally
    Document.Free;
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
    Document.AddLines(GetPaymentName(Payment._Type), CurrencyToStr(Payment.Sum));
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
begin
  try
    CheckEnabled;
    FHeader.SetLine(LineNumber, Text, DoubleWidth);
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
begin
  try
    CheckEnabled;
    FTrailer.SetLine(LineNumber, Text, DoubleWidth);
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
var
  POSPrinter: TOPOSPOSPrinter;
begin
  try
    Initialize;
    FOposDevice.Open(DeviceClass, DeviceName, GetEventInterface(pDispatch));
    LoadParameters(FParams, DeviceName, FLogger);

    Logger.MaxCount := FParams.LogMaxCount;
    Logger.Enabled := FParams.LogFileEnabled;
    Logger.FilePath := FParams.LogFilePath;
    Logger.DeviceName := DeviceName;

    FHeader.Init(FParams.NumHeaderLines);
    FTrailer.Init(FParams.NumTrailerLines);
    FHeader.SetText(FParams.Header);
    FTrailer.SetText(FParams.Trailer);

    FClient.Login := FParams.Login;
    FClient.Password := FParams.Password;
    FClient.ConnectTimeout := FParams.ConnectTimeout;
    FClient.Address := FParams.WebkassaAddress;
    FClient.CashboxNumber := FParams.CashboxNumber;

    if FPrinter = nil then
    begin
      PosPrinter := TOPOSPOSPrinter.Create(nil);
      PosPrinter.OnStatusUpdateEvent := PrinterStatusUpdateEvent;
      PosPrinter.OnErrorEvent := PrinterErrorEvent;
      PosPrinter.OnDirectIOEvent := PrinterDirectIOEvent;
      PosPrinter.OnOutputCompleteEvent := PrinterOutputCompleteEvent;
      FPrinterLog := TPosPrinterLog.Create2(nil, PosPrinter.ControlInterface, Logger);
      FPrinter := FPrinterLog;
    end;
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
      UpdateUnits;
    end else
    begin
      FClient.Disconnect;
    end;
    FDeviceEnabled := Value;
    FOposDevice.DeviceEnabled := Value;
    Printer.DeviceEnabled := Value;
    FRecLineChars := Printer.RecLineChars;
    FMaxRecLineChars := GetMaxRecLine(Printer.RecLineCharsList);
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
  Document: TTextDocument;
  Command: TMoneyOperationCommand;
begin
  Document := TTextDocument.Create;
  Command := TMoneyOperationCommand.Create;
  try
    Command.Request.Token := FClient.Token;
    Command.Request.CashboxUniqueNumber := FClient.CashboxNumber;
    Command.Request.OperationType := OperationTypeCashIn;
    Command.Request.Sum := Receipt.GetTotal;
    Command.Request.ExternalCheckNumber := CreateGUIDStr;
    FClient.Execute(Command);
    // Create Document
    Document.LineChars := Printer.RecLineChars;
    Document.AddText(Params.Header);
    Document.Add('¡»Õ ' + Command.Data.Cashbox.RegistrationNumber);
    Document.Add(Format('«ÕÃ %s »Õ  Œ‘ƒ %s', [Command.Data.Cashbox.UniqueNumber,
      Command.Data.Cashbox.IdentityNumber]));
    Document.Add(Command.Data.DateTime);
    Document.AddText(Receipt.Lines.Text);
    Document.AddCurrency('¬Õ≈—≈Õ»≈ ƒ≈Õ≈√ ¬  ¿——”', Receipt.GetTotal);
    Document.AddCurrency('Õ¿À»◊Õ€’ ¬  ¿——≈', Command.Data.Sum);
    Document.Add('ŒÔÂ‡ÚÓ: ' + FCashierFullName);
    Document.AddText(Params.Trailer);
    Document.AddText(Receipt.Trailer.Text);
    // Print
    PrintDocumentSafe(Document);
  finally
    Command.Free;
    Document.Free;
  end;
end;

procedure TWebkassaImpl.Print(Receipt: TCashOutReceipt);
var
  Document: TTextDocument;
  Command: TMoneyOperationCommand;
begin
  Document := TTextDocument.Create;
  Command := TMoneyOperationCommand.Create;
  try
    Command.Request.Token := FClient.Token;
    Command.Request.CashboxUniqueNumber := FClient.CashboxNumber;
    Command.Request.OperationType := OperationTypeCashOut;
    Command.Request.Sum := Receipt.GetTotal;
    Command.Request.ExternalCheckNumber := CreateGUIDStr;
    FClient.Execute(Command);
    //
    Document.LineChars := Printer.RecLineChars;
    Document.AddText(Params.Header);
    Document.Add('¡»Õ ' + Command.Data.Cashbox.RegistrationNumber);
    Document.Add(Format('«ÕÃ %s »Õ  Œ‘ƒ %s', [Command.Data.Cashbox.UniqueNumber,
      Command.Data.Cashbox.IdentityNumber]));
    Document.Add(Command.Data.DateTime);
    Document.AddText(Receipt.Lines.Text);
    Document.AddCurrency('»«⁄ﬂ“»≈ ƒ≈Õ≈√ »«  ¿——€', Receipt.GetTotal);
    Document.AddCurrency('Õ¿À»◊Õ€’ ¬  ¿——≈', Command.Data.Sum);
    Document.Add('ŒÔÂ‡ÚÓ: ' + FCashierFullName);
    Document.AddText(Receipt.Trailer.Text);
    Document.AddText(Params.Trailer);
    // print
    PrintDocumentSafe(Document);
  finally
    Document.Free;
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
  Item: TReceiptItem;
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
    Command.Request.CashboxUniqueNumber := FClient.CashboxNumber;
    Command.Request.OperationType := OperationType;
    Command.Request.Change := Receipt.Change;
    Command.Request.RoundType := FParams.RoundType;
    Command.Request.ExternalCheckNumber := CreateGUIDStr;
    Command.Request.CustomerEmail := '';
    Command.Request.CustomerPhone := '';
    Command.Request.CustomerXin := '';

    // Items
    for i := 0 to Receipt.Items.Count-1 do
    begin
      Item := Receipt.Items[i];
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
      Position.Discount := Item.Adjustments.GetDiscounts;
      Position.Markup := Item.Adjustments.GetCharges;
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
    FCheckNumber := Command.Data.CheckNumber;
    PrintReceipt(Command.Request.ExternalCheckNumber, False);
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

procedure TWebkassaImpl.PrintReceipt(const ACheckNumber: string; IsDuplicate: Boolean);
var
  i: Integer;
  TextStyle: Integer;
  Item: TReceiptTextItem;
  Command: TReceiptTextCommand;
begin
  Document.Clear;
  Command := TReceiptTextCommand.Create;
  try
    Command.Request.token := FClient.Token;
    Command.Request.CashboxUniqueNumber := FClient.CashboxNumber;
    Command.Request.externalCheckNumber := ACheckNumber;
    Command.Request.isDuplicate := IsDuplicate;
    Command.Request.paperKind := GetPaperKind(Printer.RecLineWidth);
    FClient.ReadReceiptText(Command);

    Document.AddText(Params.Header);
    for i := 0 to Command.Data.Lines.Count-1 do
    begin
      Item := Command.Data.Lines.Items[i] as TReceiptTextItem;
      if Item._Type = ItemTypeText then
      begin
        TextStyle := STYLE_NORMAL;
        (*
        if Item.Style = TextStyleBold then
          TextStyle := STYLE_DWIDTH_HEIGHT;
        *)

        Document.Add(Item.Value, TextStyle);
      end;
      if Item._Type = ItemTypePicture then
      begin
        Document.Add(Item.Value, STYLE_IMAGE);
      end;
      if Item._Type = ItemTypeQRCode then
      begin
        Document.Add(Item.Value, STYLE_QR_CODE);
      end;
    end;
    Printer.RecLineChars := FMaxRecLineChars;
    Document.AddText(Params.Trailer);

    PrintDocumentSafe(Document);
    Printer.RecLineChars := FRecLineChars;
  finally
    Command.Free;
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
  CheckCanPrint;
  try
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
  Count: Integer;
  Text: WideString;
  CapRecBold: Boolean;
  CapRecDwideDhigh: Boolean;
  RecLineChars: Integer;
  Item: TTextItem;
const
  ESC = #$1B;
  CRLF = #13#10;
begin
  // Add header and trailer
  Document.AddText(0, Params.Header);
  Document.AddText(Params.Trailer);

  CheckCanPrint;
  CapRecDwideDhigh := Printer.CapRecDwideDhigh;
  CapRecBold := Printer.CapRecBold;
  RecLineChars := Printer.RecLineChars;
  if Printer.CapTransaction then
  begin
    CheckPtr(Printer.TransactionPrint(PTR_S_RECEIPT, PTR_TP_TRANSACTION));
  end;
  for i := 0 to Document.Items.Count-1 do
  begin
    Item := Document.Items[i] as TTextItem;
    case Item.Style of
      STYLE_QR_CODE:
      begin
        Printer.PrintBarCode(PTR_S_RECEIPT, Item.Text, PTR_BCS_DATAMATRIX, 200, 200,
          PTR_BC_CENTER, PTR_BC_TEXT_NONE);
      end;
    else
      Text := Copy(Item.Text, 1, RecLineChars);
      // DWDH
      if Item.Style = STYLE_DWIDTH_HEIGHT then
      begin
        Text := Copy(Item.Text, 1, RecLineChars div 2);
        if CapRecDwideDhigh then
          Text := ESCDWDH + Text;
      end;
      // BOLD
      if Item.Style = STYLE_BOLD then
      begin
        if CapRecBold then
          Text := ESCBold + Text;
      end;
      CheckPtr(Printer.PrintNormal(PTR_S_RECEIPT, Text));
    end;
  end;
  if Printer.CapRecPapercut then
  begin
    Count := Printer.RecLinesToPaperCut - FParams.NumHeaderLines + 1;
    if Count > 0 then
    begin
      for i := 1 to Count do
      begin
        Printer.PrintNormal(PTR_S_RECEIPT, CRLF);
      end;
    end;
    Printer.CutPaper(90);
  end;

  if Printer.CapTransaction then
  begin
    CheckPtr(Printer.TransactionPrint(PTR_S_RECEIPT, PTR_TP_NORMAL));
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

end.

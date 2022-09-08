unit oleMain;

interface

uses
  // VCL
  Windows, ComObj, ActiveX, AxCtrls,
  // This
  DrvFRLib_TLB, untDriver;

type
  { ToleMain }

  ToleMain = class(TActiveXControl, IDrvFR, IDrvFR2, IDrvFR3, IDrvFR4)
  private
    FDriver: TDriver;
    function GetDriver: TDriver;
    property Driver: TDriver read GetDriver;
  public
    // IDrvFR
    function  AddLD: Integer; safecall;
    function  Beep: Integer; safecall;
    function  Buy: Integer; safecall;
    function  BuyEx: Integer; safecall;
    function  CancelCheck: Integer; safecall;
    function  CashIncome: Integer; safecall;
    function  CashOutcome: Integer; safecall;
    function  Charge: Integer; safecall;
    function  CheckSubTotal: Integer; safecall;
    function  CloseCheck: Integer; safecall;
    function  ConfirmDate: Integer; safecall;
    function  Connect: Integer; safecall;
    function  ContinuePrint: Integer; safecall;
    function  Correction: Integer; safecall;
    function  CutCheck: Integer; safecall;
    function  DampRequest: Integer; safecall;
    function  DeleteLD: Integer; safecall;
    function  Disconnect: Integer; virtual; safecall;
    function  Discount: Integer; safecall;
    function  DozeOilCheck: Integer; safecall;
    function  Draw: Integer; safecall;
    function  EKLZDepartmentReportInDatesRange: Integer; safecall;
    function  EKLZDepartmentReportInSessionsRange: Integer; safecall;
    function  EKLZJournalOnSessionNumber: Integer; safecall;
    function  EKLZSessionReportInDatesRange: Integer; safecall;
    function  EKLZSessionReportInSessionsRange: Integer; safecall;
    function  ExchangeBytes: Integer; safecall;
    function  FeedDocument: Integer; safecall;
    function  Fiscalization: Integer; safecall;
    function  FiscalReportForDatesRange: Integer; safecall;
    function  FiscalReportForSessionRange: Integer; safecall;
    function  GetActiveLD: Integer; safecall;
    function  EnumLD: Integer; safecall;
    function  GetCashReg: Integer; safecall;
    function  GetCountLD: Integer; safecall;
    function  GetData: Integer; safecall;
    function  GetDeviceMetrics: Integer; safecall;
    function  GetECRStatus: Integer; safecall;
    function  GetShortECRStatus: Integer; safecall;
    function  GetExchangeParam: Integer; safecall;
    function  GetFieldStruct: Integer; safecall;
    function  GetFiscalizationParameters: Integer; safecall;
    function  GetFMRecordsSum: Integer; safecall;
    function  GetLastFMRecordDate: Integer; safecall;
    function  GetLiterSumCounter: Integer; safecall;
    function  GetOperationReg: Integer; safecall;
    function  GetParamLD: Integer; safecall;
    function  GetRangeDatesAndSessions: Integer; safecall;
    function  GetRKStatus: Integer; safecall;
    function  GetTableStruct: Integer; safecall;
    function  InitFM: Integer; safecall;
    function  InitTable: Integer; safecall;
    function  InterruptDataStream: Integer; safecall;
    function  InterruptFullReport: Integer; safecall;
    function  InterruptTest: Integer; safecall;
    function  LaunchRK: Integer; safecall;
    function  LoadLineData: Integer; safecall;
    function  OilSale: Integer; safecall;
    function  OpenCheck: Integer; safecall;
    function  OpenDrawer: Integer; safecall;
    function  PrintBarCode: Integer; safecall;
    function  PrintDepartmentReport: Integer; safecall;
    function  PrintDocumentTitle: Integer; safecall;
    function  PrintOperationReg: Integer; safecall;
    function  PrintReportWithCleaning: Integer; safecall;
    function  PrintReportWithoutCleaning: Integer; safecall;
    function  PrintString: Integer; safecall;
    function  PrintWideString: Integer; safecall;
    function  ReadEKLZDocumentOnKPK: Integer; safecall;
    function  ReadEKLZSessionTotal: Integer; safecall;
    function  ReadLicense: Integer; safecall;
    function  ReadTable: Integer; safecall;
    function  RepeatDocument: Integer; safecall;
    function  ResetAllTRK: Integer; safecall;
    function  ResetRK: Integer; safecall;
    function  ResetSettings: Integer; safecall;
    function  ResetSummary: Integer; safecall;
    function  ReturnBuy: Integer; safecall;
    function  ReturnBuyEx: Integer; safecall;
    function  ReturnSale: Integer; safecall;
    function  ReturnSaleEx: Integer; safecall;
    function  Sale: Integer; safecall;
    function  SaleEx: Integer; safecall;
    function  SetActiveLD: Integer; safecall;
    function  SetDate: Integer; safecall;
    function  SetDozeInMilliliters: Integer; safecall;
    function  SetDozeInMoney: Integer; safecall;
    function  SetExchangeParam: Integer; safecall;
    function  SetParamLD: Integer; safecall;
    function  SetPointPosition: Integer; safecall;
    function  SetRKParameters: Integer; safecall;
    function  SetSerialNumber: Integer; safecall;
    function  SetTime: Integer; safecall;
    function  ShowProperties: Integer; safecall;
    function  StopEKLZDocumentPrinting: Integer; safecall;
    function  StopRK: Integer; safecall;
    function  Storno: Integer; safecall;
    function  StornoEx: Integer; safecall;
    function  StornoCharge: Integer; safecall;
    function  StornoDiscount: Integer; safecall;
    function  SummOilCheck: Integer; safecall;
    function  SysAdminCancelCheck: Integer; safecall;
    function  Test: Integer; safecall;
    function  WriteLicense: Integer; safecall;
    function  WriteTable: Integer; safecall;
    function  Get_BarCode: WideString; safecall;
    procedure Set_BarCode(const Value: WideString); safecall;
    function  Get_BatteryCondition: WordBool; safecall;
    function  Get_BatteryVoltage: Double; safecall;
    function  Get_BaudRate: Integer; safecall;
    procedure Set_BaudRate(Value: Integer); safecall;
    function  Get_Change: Currency; safecall;
    function  Get_CheckResult: Currency; safecall;
    procedure Set_CheckResult(Value: Currency); safecall;
    function  Get_CheckType: Integer; safecall;
    procedure Set_CheckType(Value: Integer); safecall;
    function  Get_ComNumber: Integer; safecall;
    procedure Set_ComNumber(Value: Integer); safecall;
    function  Get_ContentsOfCashRegister: Currency; safecall;
    function  Get_ContentsOfOperationRegister: Integer; safecall;
    function  Get_CurrentDozeInMilliliters: Integer; safecall;
    procedure Set_CurrentDozeInMilliliters(Value: Integer); safecall;
    function  Get_CurrentDozeInMoney: Currency; safecall;
    procedure Set_CurrentDozeInMoney(Value: Currency); safecall;
    function  Get_CutType: WordBool; safecall;
    procedure Set_CutType(Value: WordBool); safecall;
    function  Get_DataBlock: WideString; safecall;
    function  Get_DataBlockNumber: Integer; safecall;
    function  Get_Date: TDateTime; safecall;
    procedure Set_Date(Value: TDateTime); safecall;
    function  Get_Department: Integer; safecall;
    procedure Set_Department(Value: Integer); safecall;
    function  Get_DeviceCode: Integer; safecall;
    procedure Set_DeviceCode(Value: Integer); safecall;
    function  Get_DeviceCodeDescription: WideString; safecall;
    function  Get_DiscountOnCheck: Double; safecall;
    procedure Set_DiscountOnCheck(Value: Double); safecall;
    function  Get_DocumentName: WideString; safecall;
    procedure Set_DocumentName(const Value: WideString); safecall;
    function  Get_DocumentNumber: Integer; safecall;
    procedure Set_DocumentNumber(Value: Integer); safecall;
    function  Get_DozeInMilliliters: Integer; safecall;
    procedure Set_DozeInMilliliters(Value: Integer); safecall;
    function  Get_DozeInMoney: Currency; safecall;
    procedure Set_DozeInMoney(Value: Currency); safecall;
    function  Get_DrawerNumber: Integer; safecall;
    procedure Set_DrawerNumber(Value: Integer); safecall;
    function  Get_ECRAdvancedMode: Integer; safecall;
    function  Get_ECRAdvancedModeDescription: WideString; safecall;
    function  Get_ECRBuild: Integer; safecall;
    function  Get_ECRFlags: Integer; safecall;
    function  Get_ECRInput: WideString; safecall;
    function  Get_ECRMode: Integer; safecall;
    function  Get_ECRMode8Status: Integer; safecall;
    function  Get_ECRModeDescription: WideString; safecall;
    function  Get_ECROutput: WideString; safecall;
    function  Get_ECRSoftDate: TDateTime; safecall;
    function  Get_ECRSoftVersion: WideString; safecall;
    function  Get_EKLZIsPresent: WordBool; safecall;
    function  Get_EmergencyStopCode: Integer; safecall;
    function  Get_EmergencyStopCodeDescription: WideString; safecall;
    function  Get_FieldName: WideString; safecall;
    function  Get_FieldNumber: Integer; safecall;
    procedure Set_FieldNumber(Value: Integer); safecall;
    function  Get_FieldSize: Integer; safecall;
    function  Get_FieldType: WordBool; safecall;
    function  Get_FirstLineNumber: Integer; safecall;
    procedure Set_FirstLineNumber(Value: Integer); safecall;
    function  Get_FirstSessionDate: TDateTime; safecall;
    procedure Set_FirstSessionDate(Value: TDateTime); safecall;
    function  Get_FirstSessionNumber: Integer; safecall;
    procedure Set_FirstSessionNumber(Value: Integer); safecall;
    function  Get_FM1IsPresent: WordBool; safecall;
    function  Get_FM2IsPresent: WordBool; safecall;
    function  Get_FMBuild: Integer; safecall;
    function  Get_FMFlags: Integer; safecall;
    function  Get_FMOverflow: WordBool; safecall;
    function  Get_FMSoftDate: TDateTime; safecall;
    function  Get_FMSoftVersion: WideString; safecall;
    function  Get_FreeRecordInFM: Integer; safecall;
    function  Get_FreeRegistration: Integer; safecall;
    function  Get_INN: WideString; safecall;
    procedure Set_INN(const Value: WideString); safecall;
    function  Get_IsCheckClosed: WordBool; safecall;
    function  Get_IsCheckMadeOut: WordBool; safecall;
    function  Get_IsDrawerOpen: WordBool; safecall;
    function  Get_JournalRibbonIsPresent: WordBool; safecall;
    function  Get_JournalRibbonLever: WordBool; safecall;
    function  Get_JournalRibbonOpticalSensor: WordBool; safecall;
    function  Get_KPKNumber: Integer; safecall;
    procedure Set_KPKNumber(Value: Integer); safecall;
    function  Get_LastLineNumber: Integer; safecall;
    procedure Set_LastLineNumber(Value: Integer); safecall;
    function  Get_LastSessionDate: TDateTime; safecall;
    procedure Set_LastSessionDate(Value: TDateTime); safecall;
    function  Get_LastSessionNumber: Integer; safecall;
    procedure Set_LastSessionNumber(Value: Integer); safecall;
    function  Get_License: WideString; safecall;
    procedure Set_License(const Value: WideString); safecall;
    function  Get_LicenseIsPresent: WordBool; safecall;
    function  Get_LidPositionSensor: WordBool; safecall;
    function  Get_LineData: WideString; safecall;
    procedure Set_LineData(const Value: WideString); safecall;
    function  Get_LineNumber: Integer; safecall;
    procedure Set_LineNumber(Value: Integer); safecall;
    function  Get_LogicalNumber: Integer; safecall;
    function  Get_MAXValueOfField: Integer; safecall;
    function  Get_MINValueOfField: Integer; safecall;
    function  Get_Motor: WordBool; safecall;
    function  Get_NameCashReg: WideString; safecall;
    function  Get_NameOperationReg: WideString; safecall;
    function  Get_NewPasswordTI: Integer; safecall;
    procedure Set_NewPasswordTI(Value: Integer); safecall;
    function  Get_OpenDocumentNumber: Integer; safecall;
    function  Get_OperatorNumber: Integer; safecall;
    function  Get_Password: Integer; safecall;
    procedure Set_Password(Value: Integer); safecall;
    function  Get_Pistol: WordBool; safecall;
    function  Get_PointPosition: WordBool; safecall;
    procedure Set_PointPosition(Value: WordBool); safecall;
    function  Get_PortNumber: Integer; safecall;
    procedure Set_PortNumber(Value: Integer); safecall;
    function  Get_Price: Currency; safecall;
    procedure Set_Price(Value: Currency); safecall;
    function  Get_Quantity: Double; safecall;
    procedure Set_Quantity(Value: Double); safecall;
    function  Get_QuantityOfOperations: Integer; safecall;
    function  Get_ReceiptRibbonIsPresent: WordBool; safecall;
    function  Get_ReceiptRibbonLever: WordBool; safecall;
    function  Get_ReceiptRibbonOpticalSensor: WordBool; safecall;
    function  Get_RegisterNumber: Integer; safecall;
    procedure Set_RegisterNumber(Value: Integer); safecall;
    function  Get_RegistrationNumber: Integer; safecall;
    procedure Set_RegistrationNumber(Value: Integer); safecall;
    function  Get_ReportType: WordBool; safecall;
    procedure Set_ReportType(Value: WordBool); safecall;
    function  Get_ResultCode: Integer; safecall;
    function  Get_ResultCodeDescription: WideString; safecall;
    function  Get_RKNumber: Integer; safecall;
    procedure Set_RKNumber(Value: Integer); safecall;
    function  Get_RNM: WideString; safecall;
    procedure Set_RNM(const Value: WideString); safecall;
    function  Get_RoughValve: WordBool; safecall;
    function  Get_RowNumber: Integer; safecall;
    procedure Set_RowNumber(Value: Integer); safecall;
    function  Get_RunningPeriod: Integer; safecall;
    procedure Set_RunningPeriod(Value: Integer); safecall;
    function  Get_SerialNumber: WideString; safecall;
    procedure Set_SerialNumber(const Value: WideString); safecall;
    function  Get_SessionNumber: Integer; safecall;
    procedure Set_SessionNumber(Value: Integer); safecall;
    function  Get_SlipDocumentIsMoving: WordBool; safecall;
    function  Get_SlipDocumentIsPresent: WordBool; safecall;
    function  Get_SlowingInMilliliters: Integer; safecall;
    procedure Set_SlowingInMilliliters(Value: Integer); safecall;
    function  Get_SlowingValve: WordBool; safecall;
    function  Get_StatusRK: Integer; safecall;
    function  Get_StatusRKDescription: WideString; safecall;
    function  Get_StringForPrinting: WideString; safecall;
    procedure Set_StringForPrinting(const Value: WideString); safecall;
    function  Get_StringQuantity: Integer; safecall;
    procedure Set_StringQuantity(Value: Integer); safecall;
    function  Get_Summ1: Currency; safecall;
    procedure Set_Summ1(Value: Currency); safecall;
    function  Get_Summ2: Currency; safecall;
    procedure Set_Summ2(Value: Currency); safecall;
    function  Get_Summ3: Currency; safecall;
    procedure Set_Summ3(Value: Currency); safecall;
    function  Get_Summ4: Currency; safecall;
    procedure Set_Summ4(Value: Currency); safecall;
    function  Get_TableName: WideString; safecall;
    function  Get_TableNumber: Integer; safecall;
    procedure Set_TableNumber(Value: Integer); safecall;
    function  Get_Tax1: Integer; safecall;
    procedure Set_Tax1(Value: Integer); safecall;
    function  Get_Tax2: Integer; safecall;
    procedure Set_Tax2(Value: Integer); safecall;
    function  Get_Tax3: Integer; safecall;
    procedure Set_Tax3(Value: Integer); safecall;
    function  Get_Tax4: Integer; safecall;
    procedure Set_Tax4(Value: Integer); safecall;
    function  Get_Time: TDateTime; safecall;
    procedure Set_Time(Value: TDateTime); safecall;
    function  Get_Timeout: Integer; safecall;
    procedure Set_Timeout(Value: Integer); safecall;
    function  Get_TimeStr: WideString; safecall;
    procedure Set_TimeStr(const Value: WideString); safecall;
    function  Get_TransferBytes: WideString; safecall;
    procedure Set_TransferBytes(const Value: WideString); safecall;
    function  Get_TRKNumber: Integer; safecall;
    procedure Set_TRKNumber(Value: Integer); safecall;
    function  Get_TypeOfLastEntryFM: WordBool; safecall;
    function  Get_TypeOfSumOfEntriesFM: WordBool; safecall;
    procedure Set_TypeOfSumOfEntriesFM(Value: WordBool); safecall;
    function  Get_UCodePage: Integer; safecall;
    function  Get_UDescription: WideString; safecall;
    function  Get_UMajorProtocolVersion: Integer; safecall;
    function  Get_UMajorType: Integer; safecall;
    function  Get_UMinorProtocolVersion: Integer; safecall;
    function  Get_UMinorType: Integer; safecall;
    function  Get_UModel: Integer; safecall;
    function  Get_UseJournalRibbon: WordBool; safecall;
    procedure Set_UseJournalRibbon(Value: WordBool); safecall;
    function  Get_UseReceiptRibbon: WordBool; safecall;
    procedure Set_UseReceiptRibbon(Value: WordBool); safecall;
    function  Get_UseSlipDocument: WordBool; safecall;
    procedure Set_UseSlipDocument(Value: WordBool); safecall;
    function  Get_ValueOfFieldInteger: Integer; safecall;
    procedure Set_ValueOfFieldInteger(Value: Integer); safecall;
    function  Get_ValueOfFieldString: WideString; safecall;
    procedure Set_ValueOfFieldString(const Value: WideString); safecall;
    function  PrintStringWithFont: Integer; safecall;
    function  Get_FontType: Integer; safecall;
    procedure Set_FontType(Value: Integer); safecall;
    function  Get_LDBaudrate: Integer; safecall;
    procedure Set_LDBaudrate(Value: Integer); safecall;
    function  Get_LDComNumber: Integer; safecall;
    procedure Set_LDComNumber(Value: Integer); safecall;
    function  Get_LDCount: Integer; safecall;
    function  Get_LDIndex: Integer; safecall;
    procedure Set_LDIndex(Value: Integer); safecall;
    function  Get_LDName: WideString; safecall;
    procedure Set_LDName(const Value: WideString); safecall;
    function  Get_LDNumber: Integer; safecall;
    procedure Set_LDNumber(Value: Integer); safecall;
    function  Get_WaitPrintingTime: Integer; safecall;
    function  Get_IsPrinterLeftSensorFailure: WordBool; safecall;
    function  Get_IsPrinterRightSensorFailure: WordBool; safecall;
    function  EKLZActivizationResult: Integer; safecall;
    function  EKLZActivization: Integer; safecall;
    function  CloseEKLZArchive: Integer; safecall;
    function  GetEKLZSerialNumber: Integer; safecall;
    function  Get_EKLZNumber: WideString; safecall;
    function  EKLZInterrupt: Integer; safecall;
    function GetEKLZCode1Report: Integer; safecall;
    function  Get_LastKPKDocumentResult: Currency; safecall;
    function  Get_LastKPKDate: TDateTime; safecall;
    function  Get_LastKPKTime: TDateTime; safecall;
    function  Get_LastKPKNumber: Integer; safecall;
    function  Get_EKLZFlags: Integer; safecall;
    function GetEKLZCode2Report: Integer; safecall;
    function  TestEKLZArchiveIntegrity: Integer; safecall;
    function  Get_TestNumber: Integer; safecall;
    procedure Set_TestNumber(Value: Integer); safecall;
    function  Get_EKLZVersion: WideString; safecall;
    function  Get_EKLZData: WideString; safecall;
    function  GetEKLZVersion: Integer; safecall;
    function  InitEKLZArchive: Integer; safecall;
    function  GetEKLZData: Integer; safecall;
    function  GetEKLZJournal: Integer; safecall;
    function  GetEKLZDocument: Integer; safecall;
    function  GetEKLZDepartmentReportInDatesRange: Integer; safecall;
    function  GetEKLZDepartmentReportInSessionsRange: Integer; safecall;
    function  GetEKLZSessionReportInDatesRange: Integer; safecall;
    function  GetEKLZSessionReportInSessionsRange: Integer; safecall;
    function  GetEKLZSessionTotal: Integer; safecall;
    function  GetEKLZActivizationResult: Integer; safecall;
    function  SetEKLZResultCode: Integer; safecall;
    function  Get_EKLZResultCode: Integer; safecall;
    procedure Set_EKLZResultCode(Value: Integer); safecall;
    function  Get_FMResultCode: Integer; safecall;
    function  Get_PowerSourceVoltage: Double; safecall;
    function  Get_IsEKLZOverflow: WordBool; safecall;
    function  OpenFiscalSlipDocument: Integer; safecall;
    function  OpenStandardFiscalSlipDocument: Integer; safecall;
    function  RegistrationOnSlipDocument: Integer; safecall;
    function  StandardRegistrationOnSlipDocument: Integer; safecall;
    function  ChargeOnSlipDocument: Integer; safecall;
    function  StandardChargeOnSlipDocument: Integer; safecall;
    function  CloseCheckOnSlipDocument: Integer; safecall;
    function  StandardCloseCheckOnSlipDocument: Integer; safecall;
    function  ConfigureSlipDocument: Integer; safecall;
    function  ConfigureStandardSlipDocument: Integer; safecall;
    function  FillSlipDocumentWithUnfiscalInfo: Integer; safecall;
    function  ClearSlipDocumentBufferString: Integer; safecall;
    function  ClearSlipDocumentBuffer: Integer; safecall;
    function  PrintSlipDocument: Integer; safecall;
    function  Get_CopyType: Integer; safecall;
    procedure Set_CopyType(Value: Integer); safecall;
    function  Get_NumberOfCopies: Integer; safecall;
    procedure Set_NumberOfCopies(Value: Integer); safecall;
    function  Get_CopyOffset1: Integer; safecall;
    procedure Set_CopyOffset1(Value: Integer); safecall;
    function  Get_CopyOffset2: Integer; safecall;
    procedure Set_CopyOffset2(Value: Integer); safecall;
    function  Get_CopyOffset3: Integer; safecall;
    procedure Set_CopyOffset3(Value: Integer); safecall;
    function  Get_CopyOffset4: Integer; safecall;
    procedure Set_CopyOffset4(Value: Integer); safecall;
    function  Get_CopyOffset5: Integer; safecall;
    procedure Set_CopyOffset5(Value: Integer); safecall;
    function  Get_ClicheFont: Integer; safecall;
    procedure Set_ClicheFont(Value: Integer); safecall;
    function  Get_HeaderFont: Integer; safecall;
    procedure Set_HeaderFont(Value: Integer); safecall;
    function  Get_EKLZFont: Integer; safecall;
    procedure Set_EKLZFont(Value: Integer); safecall;
    function  Get_ClicheStringNumber: Integer; safecall;
    procedure Set_ClicheStringNumber(Value: Integer); safecall;
    function  Get_HeaderStringNumber: Integer; safecall;
    procedure Set_HeaderStringNumber(Value: Integer); safecall;
    function  Get_EKLZStringNumber: Integer; safecall;
    procedure Set_EKLZStringNumber(Value: Integer); safecall;
    function  Get_FMStringNumber: Integer; safecall;
    procedure Set_FMStringNumber(Value: Integer); safecall;
    function  Get_ClicheOffset: Integer; safecall;
    procedure Set_ClicheOffset(Value: Integer); safecall;
    function  Get_HeaderOffset: Integer; safecall;
    procedure Set_HeaderOffset(Value: Integer); safecall;
    function  Get_EKLZOffset: Integer; safecall;
    procedure Set_EKLZOffset(Value: Integer); safecall;
    function  Get_KPKOffset: Integer; safecall;
    procedure Set_KPKOffset(Value: Integer); safecall;
    function  Get_FMOffset: Integer; safecall;
    procedure Set_FMOffset(Value: Integer); safecall;
    function  Get_OperationBlockFirstString: Integer; safecall;
    procedure Set_OperationBlockFirstString(Value: Integer); safecall;
    function  Get_QuantityFormat: Integer; safecall;
    procedure Set_QuantityFormat(Value: Integer); safecall;
    function  Get_StringQuantityInOperation: Integer; safecall;
    procedure Set_StringQuantityInOperation(Value: Integer); safecall;
    function  Get_TextStringNumber: Integer; safecall;
    procedure Set_TextStringNumber(Value: Integer); safecall;
    function  Get_QuantityStringNumber: Integer; safecall;
    procedure Set_QuantityStringNumber(Value: Integer); safecall;
    function  Get_SummStringNumber: Integer; safecall;
    procedure Set_SummStringNumber(Value: Integer); safecall;
    function  Get_DepartmentStringNumber: Integer; safecall;
    procedure Set_DepartmentStringNumber(Value: Integer); safecall;
    function  Get_TextFont: Integer; safecall;
    procedure Set_TextFont(Value: Integer); safecall;
    function  Get_QuantityFont: Integer; safecall;
    procedure Set_QuantityFont(Value: Integer); safecall;
    function  Get_MultiplicationFont: Integer; safecall;
    procedure Set_MultiplicationFont(Value: Integer); safecall;
    function  Get_PriceFont: Integer; safecall;
    procedure Set_PriceFont(Value: Integer); safecall;
    function  Get_SummFont: Integer; safecall;
    procedure Set_SummFont(Value: Integer); safecall;
    function  Get_DepartmentFont: Integer; safecall;
    procedure Set_DepartmentFont(Value: Integer); safecall;
    function  Get_TextSymbolNumber: Integer; safecall;
    procedure Set_TextSymbolNumber(Value: Integer); safecall;
    function  Get_QuantitySymbolNumber: Integer; safecall;
    procedure Set_QuantitySymbolNumber(Value: Integer); safecall;
    function  Get_PriceSymbolNumber: Integer; safecall;
    procedure Set_PriceSymbolNumber(Value: Integer); safecall;
    function  Get_SummSymbolNumber: Integer; safecall;
    procedure Set_SummSymbolNumber(Value: Integer); safecall;
    function  Get_DepartmentSymbolNumber: Integer; safecall;
    procedure Set_DepartmentSymbolNumber(Value: Integer); safecall;
    function  Get_TextOffset: Integer; safecall;
    procedure Set_TextOffset(Value: Integer); safecall;
    function  Get_QuantityOffset: Integer; safecall;
    procedure Set_QuantityOffset(Value: Integer); safecall;
    function  Get_SummOffset: Integer; safecall;
    procedure Set_SummOffset(Value: Integer); safecall;
    function  Get_DepartmentOffset: Integer; safecall;
    procedure Set_DepartmentOffset(Value: Integer); safecall;
    function  DiscountOnSlipDocument: Integer; safecall;
    function  StandardDiscountOnSlipDocument: Integer; safecall;
    function  Get_IsClearUnfiscalInfo: WordBool; safecall;
    procedure Set_IsClearUnfiscalInfo(Value: WordBool); safecall;
    function  Get_InfoType: Integer; safecall;
    procedure Set_InfoType(Value: Integer); safecall;
    function  Get_StringNumber: Integer; safecall;
    procedure Set_StringNumber(Value: Integer); safecall;
    function  EjectSlipDocument: Integer; safecall;
    function  Get_EjectDirection: Integer; safecall;
    procedure Set_EjectDirection(Value: Integer); safecall;
    function  LoadLineDataEx: Integer; safecall;
    function  DrawEx: Integer; safecall;
    function  ConfigureGeneralSlipDocument: Integer; safecall;
    function  Get_OperationNameStringNumber: Integer; safecall;
    procedure Set_OperationNameStringNumber(Value: Integer); safecall;
    function  Get_OperationNameFont: Integer; safecall;
    procedure Set_OperationNameFont(Value: Integer); safecall;
    function  Get_OperationNameOffset: Integer; safecall;
    procedure Set_OperationNameOffset(Value: Integer); safecall;
    function  Get_TotalStringNumber: Integer; safecall;
    procedure Set_TotalStringNumber(Value: Integer); safecall;
    function  Get_Summ1StringNumber: Integer; safecall;
    procedure Set_Summ1StringNumber(Value: Integer); safecall;
    function  Get_Summ2StringNumber: Integer; safecall;
    procedure Set_Summ2StringNumber(Value: Integer); safecall;
    function  Get_Summ3StringNumber: Integer; safecall;
    procedure Set_Summ3StringNumber(Value: Integer); safecall;
    function  Get_Summ4StringNumber: Integer; safecall;
    procedure Set_Summ4StringNumber(Value: Integer); safecall;
    function  Get_ChangeStringNumber: Integer; safecall;
    procedure Set_ChangeStringNumber(Value: Integer); safecall;
    function  Get_Tax1TurnOverStringNumber: Integer; safecall;
    procedure Set_Tax1TurnOverStringNumber(Value: Integer); safecall;
    function  Get_Tax2TurnOverStringNumber: Integer; safecall;
    procedure Set_Tax2TurnOverStringNumber(Value: Integer); safecall;
    function  Get_Tax3TurnOverStringNumber: Integer; safecall;
    procedure Set_Tax3TurnOverStringNumber(Value: Integer); safecall;
    function  Get_Tax4TurnOverStringNumber: Integer; safecall;
    procedure Set_Tax4TurnOverStringNumber(Value: Integer); safecall;
    function  Get_Tax1SumStringNumber: Integer; safecall;
    procedure Set_Tax1SumStringNumber(Value: Integer); safecall;
    function  Get_Tax2SumStringNumber: Integer; safecall;
    procedure Set_Tax2SumStringNumber(Value: Integer); safecall;
    function  Get_Tax3SumStringNumber: Integer; safecall;
    procedure Set_Tax3SumStringNumber(Value: Integer); safecall;
    function  Get_Tax4SumStringNumber: Integer; safecall;
    procedure Set_Tax4SumStringNumber(Value: Integer); safecall;
    function  Get_SubTotalStringNumber: Integer; safecall;
    procedure Set_SubTotalStringNumber(Value: Integer); safecall;
    function  Get_DiscountOnCheckStringNumber: Integer; safecall;
    procedure Set_DiscountOnCheckStringNumber(Value: Integer); safecall;
    function  Get_TotalFont: Integer; safecall;
    procedure Set_TotalFont(Value: Integer); safecall;
    function  Get_TotalSumFont: Integer; safecall;
    procedure Set_TotalSumFont(Value: Integer); safecall;
    function  Get_Summ1Font: Integer; safecall;
    procedure Set_Summ1Font(Value: Integer); safecall;
    function  Get_Summ1NameFont: Integer; safecall;
    procedure Set_Summ1NameFont(Value: Integer); safecall;
    function  Get_Summ2NameFont: Integer; safecall;
    procedure Set_Summ2NameFont(Value: Integer); safecall;
    function  Get_Summ3NameFont: Integer; safecall;
    procedure Set_Summ3NameFont(Value: Integer); safecall;
    function  Get_Summ4NameFont: Integer; safecall;
    procedure Set_Summ4NameFont(Value: Integer); safecall;
    function  Get_Summ2Font: Integer; safecall;
    procedure Set_Summ2Font(Value: Integer); safecall;
    function  Get_Summ3Font: Integer; safecall;
    procedure Set_Summ3Font(Value: Integer); safecall;
    function  Get_Summ4Font: Integer; safecall;
    procedure Set_Summ4Font(Value: Integer); safecall;
    function  Get_ChangeFont: Integer; safecall;
    procedure Set_ChangeFont(Value: Integer); safecall;
    function  Get_ChangeSumFont: Integer; safecall;
    procedure Set_ChangeSumFont(Value: Integer); safecall;
    function  Get_Tax1NameFont: Integer; safecall;
    procedure Set_Tax1NameFont(Value: Integer); safecall;
    function  Get_Tax2NameFont: Integer; safecall;
    procedure Set_Tax2NameFont(Value: Integer); safecall;
    function  Get_Tax3NameFont: Integer; safecall;
    procedure Set_Tax3NameFont(Value: Integer); safecall;
    function  Get_Tax4NameFont: Integer; safecall;
    procedure Set_Tax4NameFont(Value: Integer); safecall;
    function  Get_Tax1TurnOverFont: Integer; safecall;
    procedure Set_Tax1TurnOverFont(Value: Integer); safecall;
    function  Get_Tax2TurnOverFont: Integer; safecall;
    procedure Set_Tax2TurnOverFont(Value: Integer); safecall;
    function  Get_Tax3TurnOverFont: Integer; safecall;
    procedure Set_Tax3TurnOverFont(Value: Integer); safecall;
    function  Get_Tax4TurnOverFont: Integer; safecall;
    procedure Set_Tax4TurnOverFont(Value: Integer); safecall;
    function  Get_Tax1RateFont: Integer; safecall;
    procedure Set_Tax1RateFont(Value: Integer); safecall;
    function  Get_Tax2RateFont: Integer; safecall;
    procedure Set_Tax2RateFont(Value: Integer); safecall;
    function  Get_Tax3RateFont: Integer; safecall;
    procedure Set_Tax3RateFont(Value: Integer); safecall;
    function  Get_Tax4RateFont: Integer; safecall;
    procedure Set_Tax4RateFont(Value: Integer); safecall;
    function  Get_Tax1SumFont: Integer; safecall;
    procedure Set_Tax1SumFont(Value: Integer); safecall;
    function  Get_Tax2SumFont: Integer; safecall;
    procedure Set_Tax2SumFont(Value: Integer); safecall;
    function  Get_Tax3SumFont: Integer; safecall;
    procedure Set_Tax3SumFont(Value: Integer); safecall;
    function  Get_Tax4SumFont: Integer; safecall;
    procedure Set_Tax4SumFont(Value: Integer); safecall;
    function  Get_SubTotalFont: Integer; safecall;
    procedure Set_SubTotalFont(Value: Integer); safecall;
    function  Get_SubTotalSumFont: Integer; safecall;
    procedure Set_SubTotalSumFont(Value: Integer); safecall;
    function  Get_DiscountOnCheckFont: Integer; safecall;
    procedure Set_DiscountOnCheckFont(Value: Integer); safecall;
    function  Get_DiscountOnCheckSumFont: Integer; safecall;
    procedure Set_DiscountOnCheckSumFont(Value: Integer); safecall;
    function  Get_TotalSymbolNumber: Integer; safecall;
    procedure Set_TotalSymbolNumber(Value: Integer); safecall;
    function  Get_Summ1SymbolNumber: Integer; safecall;
    procedure Set_Summ1SymbolNumber(Value: Integer); safecall;
    function  Get_Summ2SymbolNumber: Integer; safecall;
    procedure Set_Summ2SymbolNumber(Value: Integer); safecall;
    function  Get_Summ3SymbolNumber: Integer; safecall;
    procedure Set_Summ3SymbolNumber(Value: Integer); safecall;
    function  Get_Summ4SymbolNumber: Integer; safecall;
    procedure Set_Summ4SymbolNumber(Value: Integer); safecall;
    function  Get_ChangeSymbolNumber: Integer; safecall;
    procedure Set_ChangeSymbolNumber(Value: Integer); safecall;
    function  Get_Tax1NameSymbolNumber: Integer; safecall;
    procedure Set_Tax1NameSymbolNumber(Value: Integer); safecall;
    function  Get_Tax1TurnOverSymbolNumber: Integer; safecall;
    procedure Set_Tax1TurnOverSymbolNumber(Value: Integer); safecall;
    function  Get_Tax1RateSymbolNumber: Integer; safecall;
    procedure Set_Tax1RateSymbolNumber(Value: Integer); safecall;
    function  Get_Tax1SumSymbolNumber: Integer; safecall;
    procedure Set_Tax1SumSymbolNumber(Value: Integer); safecall;
    function  Get_Tax2NameSymbolNumber: Integer; safecall;
    procedure Set_Tax2NameSymbolNumber(Value: Integer); safecall;
    function  Get_Tax2TurnOverSymbolNumber: Integer; safecall;
    procedure Set_Tax2TurnOverSymbolNumber(Value: Integer); safecall;
    function  Get_Tax2RateSymbolNumber: Integer; safecall;
    procedure Set_Tax2RateSymbolNumber(Value: Integer); safecall;
    function  Get_Tax2SumSymbolNumber: Integer; safecall;
    procedure Set_Tax2SumSymbolNumber(Value: Integer); safecall;
    function  Get_Tax3NameSymbolNumber: Integer; safecall;
    procedure Set_Tax3NameSymbolNumber(Value: Integer); safecall;
    function  Get_Tax3TurnOverSymbolNumber: Integer; safecall;
    procedure Set_Tax3TurnOverSymbolNumber(Value: Integer); safecall;
    function  Get_Tax3RateSymbolNumber: Integer; safecall;
    procedure Set_Tax3RateSymbolNumber(Value: Integer); safecall;
    function  Get_Tax3SumSymbolNumber: Integer; safecall;
    procedure Set_Tax3SumSymbolNumber(Value: Integer); safecall;
    function  Get_Tax4NameSymbolNumber: Integer; safecall;
    procedure Set_Tax4NameSymbolNumber(Value: Integer); safecall;
    function  Get_Tax4TurnOverSymbolNumber: Integer; safecall;
    procedure Set_Tax4TurnOverSymbolNumber(Value: Integer); safecall;
    function  Get_Tax4RateSymbolNumber: Integer; safecall;
    procedure Set_Tax4RateSymbolNumber(Value: Integer); safecall;
    function  Get_Tax4SumSymbolNumber: Integer; safecall;
    procedure Set_Tax4SumSymbolNumber(Value: Integer); safecall;
    function  Get_SubTotalSymbolNumber: Integer; safecall;
    procedure Set_SubTotalSymbolNumber(Value: Integer); safecall;
    function  Get_DiscountOnCheckSymbolNumber: Integer; safecall;
    procedure Set_DiscountOnCheckSymbolNumber(Value: Integer); safecall;
    function  Get_DiscountOnCheckSumSymbolNumber: Integer; safecall;
    procedure Set_DiscountOnCheckSumSymbolNumber(Value: Integer); safecall;
    function  Get_TotalOffset: Integer; safecall;
    procedure Set_TotalOffset(Value: Integer); safecall;
    function  Get_Summ1Offset: Integer; safecall;
    procedure Set_Summ1Offset(Value: Integer); safecall;
    function  Get_TotalSumOffset: Integer; safecall;
    procedure Set_TotalSumOffset(Value: Integer); safecall;
    function  Get_Summ1NameOffset: Integer; safecall;
    procedure Set_Summ1NameOffset(Value: Integer); safecall;
    function  Get_Summ2Offset: Integer; safecall;
    procedure Set_Summ2Offset(Value: Integer); safecall;
    function  Get_Summ2NameOffset: Integer; safecall;
    procedure Set_Summ2NameOffset(Value: Integer); safecall;
    function  Get_Summ3Offset: Integer; safecall;
    procedure Set_Summ3Offset(Value: Integer); safecall;
    function  Get_Summ3NameOffset: Integer; safecall;
    procedure Set_Summ3NameOffset(Value: Integer); safecall;
    function  Get_Summ4Offset: Integer; safecall;
    procedure Set_Summ4Offset(Value: Integer); safecall;
    function  Get_Summ4NameOffset: Integer; safecall;
    procedure Set_Summ4NameOffset(Value: Integer); safecall;
    function  Get_ChangeOffset: Integer; safecall;
    procedure Set_ChangeOffset(Value: Integer); safecall;
    function  Get_ChangeSumOffset: Integer; safecall;
    procedure Set_ChangeSumOffset(Value: Integer); safecall;
    function  Get_Tax1NameOffset: Integer; safecall;
    procedure Set_Tax1NameOffset(Value: Integer); safecall;
    function  Get_Tax1TurnOverOffset: Integer; safecall;
    procedure Set_Tax1TurnOverOffset(Value: Integer); safecall;
    function  Get_Tax1RateOffset: Integer; safecall;
    procedure Set_Tax1RateOffset(Value: Integer); safecall;
    function  Get_Tax1SumOffset: Integer; safecall;
    procedure Set_Tax1SumOffset(Value: Integer); safecall;
    function  Get_Tax2NameOffset: Integer; safecall;
    procedure Set_Tax2NameOffset(Value: Integer); safecall;
    function  Get_Tax2TurnOverOffset: Integer; safecall;
    procedure Set_Tax2TurnOverOffset(Value: Integer); safecall;
    function  Get_Tax2RateOffset: Integer; safecall;
    procedure Set_Tax2RateOffset(Value: Integer); safecall;
    function  Get_Tax2SumOffset: Integer; safecall;
    procedure Set_Tax2SumOffset(Value: Integer); safecall;
    function  Get_Tax3NameOffset: Integer; safecall;
    procedure Set_Tax3NameOffset(Value: Integer); safecall;
    function  Get_Tax3TurnOverOffset: Integer; safecall;
    procedure Set_Tax3TurnOverOffset(Value: Integer); safecall;
    function  Get_Tax3RateOffset: Integer; safecall;
    procedure Set_Tax3RateOffset(Value: Integer); safecall;
    function  Get_Tax3SumOffset: Integer; safecall;
    procedure Set_Tax3SumOffset(Value: Integer); safecall;
    function  Get_Tax4NameOffset: Integer; safecall;
    procedure Set_Tax4NameOffset(Value: Integer); safecall;
    function  Get_Tax4TurnOverOffset: Integer; safecall;
    procedure Set_Tax4TurnOverOffset(Value: Integer); safecall;
    function  Get_Tax4RateOffset: Integer; safecall;
    procedure Set_Tax4RateOffset(Value: Integer); safecall;
    function  Get_Tax4SumOffset: Integer; safecall;
    procedure Set_Tax4SumOffset(Value: Integer); safecall;
    function  Get_SubTotalOffset: Integer; safecall;
    procedure Set_SubTotalOffset(Value: Integer); safecall;
    function  Get_SubTotalSumOffset: Integer; safecall;
    procedure Set_SubTotalSumOffset(Value: Integer); safecall;
    function  Get_SlipDocumentWidth: Integer; safecall;
    procedure Set_SlipDocumentWidth(Value: Integer); safecall;
    function  Get_SlipDocumentLength: Integer; safecall;
    procedure Set_SlipDocumentLength(Value: Integer); safecall;
    function  Get_PrintingAlignment: Integer; safecall;
    procedure Set_PrintingAlignment(Value: Integer); safecall;
    function  Get_SlipStringIntervals: WideString; safecall;
    procedure Set_SlipStringIntervals(const Value: WideString); safecall;
    function  Get_SlipEqualStringIntervals: Integer; safecall;
    procedure Set_SlipEqualStringIntervals(Value: Integer); safecall;
    function  Get_KPKFont: Integer; safecall;
    procedure Set_KPKFont(Value: Integer); safecall;
    function  Get_DiscountOnCheckOffset: Integer; safecall;
    procedure Set_DiscountOnCheckOffset(Value: Integer); safecall;
    function  Get_DiscountOnCheckSumOffset: Integer; safecall;
    procedure Set_DiscountOnCheckSumOffset(Value: Integer); safecall;
    function  WideLoadLineData: Integer; safecall;
    function  PrintTaxReport: Integer; safecall;
    function  Get_QuantityPointPosition: WordBool; safecall;
    function  Get_FileVersionMS: LongWord; safecall;
    function  Get_FileVersionLS: LongWord; safecall;
    function  GetLongSerialNumberAndLongRNM: Integer; safecall;
    function  SetLongSerialNumber: Integer; safecall;
    function  FiscalizationWithLongRNM: Integer; safecall;
    function  Get_IsBatteryLow: WordBool; safecall;
    function  Get_IsLastFMRecordCorrupted: WordBool; safecall;
    function  Get_IsFMSessionOpen: WordBool; safecall;
    function  Get_IsFM24HoursOver: WordBool; safecall;
    function  Connect2: Integer; safecall;
    function  Get_ECRModeStatus: Integer; safecall;
    function  GetECRPrinterStatus: Integer; safecall;
    function  Get_PrinterStatus: Integer; safecall;
  protected
    function DoConnect: Integer; virtual;
    procedure DefinePropertyPages(DefinePropertyPage: TDefinePropertyPage); override;
    function Get_ServerVersion: WideString; safecall;
    function Get_LDComputerName: WideString; safecall;
    procedure Set_LDComputerName(const Value: WideString); safecall;
    function Get_LDTimeout: Integer; safecall;
    procedure Set_LDTimeout(Value: Integer); safecall;
    function Get_ComputerName: WideString; safecall;
    procedure Set_ComputerName(const Value: WideString); safecall;
    function ServerConnect: Integer; safecall;
    function ServerDisconnect: Integer; virtual; safecall;
    function Get_ServerConnected: WordBool; safecall;
    function LockPort: Integer; virtual; safecall;
    function UnlockPort: Integer; virtual; safecall;
    function Get_PortLocked: WordBool; safecall;
    function AdminUnlockPort: Integer; virtual; safecall;
    function AdminUnlockPorts: Integer; virtual; safecall;
    function ServerCheckKey: Integer; safecall;
    function GetFontMetrics: Integer; safecall;
    function Get_PrintWidth: Integer; safecall;
    function Get_CharWidth: Integer; safecall;
    function Get_CharHeight: Integer; safecall;
    function Get_FontCount: Integer; safecall;
    function GetFreeLDNumber: Integer; safecall;
    function Get_LogOn: WordBool; safecall;
    procedure Set_LogOn(Value: WordBool); safecall;
    function Get_CPLog: WordBool; safecall;
    procedure Set_CPLog(Value: WordBool); safecall;
    function ReadTable2: Integer; safecall;
    function WriteTable2: Integer; safecall;
    procedure SetFieldSize(Value: Integer); safecall;
    procedure SetIsString(Value: WordBool); safecall;
    procedure SetFieldMaxValue(Value: Integer); safecall;
    procedure SetFieldMinValue(Value: Integer); safecall;
  public
    destructor Destroy; override;
    procedure Initialize; override;
  end;

implementation

procedure MethodLog(const Data: string);
begin
  //OutputDebugString(PChar('Метод: ' + Data));
end;

{ ToleMain }


procedure ToleMain.Initialize;
begin
  inherited Initialize;
  Driver.Initialize;
end;

destructor ToleMain.Destroy;
begin
  FDriver.Free;
  inherited Destroy;
end;

function ToleMain.GetDriver: TDriver;
begin
  if FDriver = nil then
    FDriver := TDriver.Create;
  Result := FDriver;
end;

// IDrvFR

function ToleMain.Beep: Integer;
begin
  MethodLog('Beep');
  Result := Driver.Beep;
end;

function ToleMain.Buy: Integer;
begin
  MethodLog('Buy');
  Result := Driver.Buy;
end;

function ToleMain.BuyEx: Integer;
begin
  MethodLog('BuyEx');
  Result := Driver.BuyEx;
end;

function ToleMain.CancelCheck: Integer;
begin
  MethodLog('CancelCheck');
  Result := Driver.CancelCheck;
end;

function ToleMain.CashIncome: Integer;
begin
  MethodLog('CashIncome');
  Result := Driver.CashIncome;
end;

function ToleMain.CashOutcome: Integer;
begin
  MethodLog('CashOutcome');
  Result := Driver.CashOutcome;
end;

function ToleMain.Charge: Integer;
begin
  MethodLog('Charge');
  Result := Driver.Charge;
end;

function ToleMain.CheckSubTotal: Integer;
begin
  MethodLog('CheckSubTotal');
  Result := Driver.CheckSubTotal;
end;

function ToleMain.CloseCheck: Integer;
begin
  MethodLog('CloseCheck');
  Result := Driver.CloseCheck;
end;

function ToleMain.ConfirmDate: Integer;
begin
  MethodLog('ConfirmDate');
  Result := Driver.ConfirmDate;
end;

function ToleMain.Connect: Integer;
begin
  MethodLog('Connect');
  Result := Driver.Connect;
end;

function ToleMain.ContinuePrint: Integer;
begin
  MethodLog('ContinuePrint');
  Result := Driver.ContinuePrint;
end;

function ToleMain.CutCheck: Integer;
begin
  MethodLog('CutCheck');
  Result := Driver.CutCheck;
end;

function ToleMain.DampRequest: Integer;
begin
  MethodLog('DampRequest');
  Result := Driver.DampRequest;
end;

function ToleMain.Disconnect: Integer;
begin
  MethodLog('Disconnect');
  Result := Driver.Disconnect;
end;

function ToleMain.Discount: Integer;
begin
  MethodLog('Discount');
  Result := Driver.Discount;
end;

function ToleMain.Correction: Integer;
begin
  MethodLog('Correction');
  Result := Driver.Correction;
end;

function ToleMain.DozeOilCheck: Integer;
begin
  MethodLog('DozeOilCheck');
  Result := Driver.DozeOilCheck;
end;

function ToleMain.Draw: Integer;
begin
  MethodLog('Draw');
  Result := Driver.Draw;
end;

function ToleMain.EKLZDepartmentReportInDatesRange: Integer;
begin
  MethodLog('EKLZDepartmentReportInDatesRange');
  Result := Driver.EKLZDepartmentReportInDatesRange;
end;

function ToleMain.EKLZDepartmentReportInSessionsRange: Integer;
begin
  MethodLog('EKLZDepartmentReportInSessionsRange');
  Result := Driver.EKLZDepartmentReportInSessionsRange;
end;

function ToleMain.EKLZSessionReportInDatesRange: Integer;
begin
  MethodLog('EKLZSessionReportInDatesRange');
  Result := Driver.EKLZSessionReportInDatesRange;
end;

function ToleMain.EKLZSessionReportInSessionsRange: Integer;
begin
  MethodLog('EKLZSessionReportInSessionsRange');
  Result := Driver.EKLZSessionReportInSessionsRange;
end;

function ToleMain.EKLZJournalOnSessionNumber: Integer;
begin
  MethodLog('EKLZJournalOnSessionNumber');
  Result := Driver.EKLZJournalOnSessionNumber;
end;

function ToleMain.ExchangeBytes: Integer;
begin
  MethodLog('ExchangeBytes');
  Result := Driver.ExchangeBytes;
end;

function ToleMain.FeedDocument: Integer;
begin
  MethodLog('FeedDocument');
  Result := Driver.FeedDocument;
end;

function ToleMain.Fiscalization: Integer;
begin
  MethodLog('Fiscalization');
  Result := Driver.Fiscalization;
end;

function ToleMain.FiscalReportForDatesRange: Integer;
begin
  MethodLog('FiscalReportForDatesRange');
  Result := Driver.FiscalReportForDatesRange;
end;

function ToleMain.FiscalReportForSessionRange: Integer;
begin
  MethodLog('FiscalReportForSessionRange');
  Result := Driver.FiscalReportForSessionRange;
end;

function ToleMain.GetCashReg: Integer;
begin
  MethodLog('GetCashReg');
  Result := Driver.GetCashReg;
end;

function ToleMain.GetData: Integer;
begin
  MethodLog('GetData');
  Result := Driver.GetData;
end;

function ToleMain.GetDeviceMetrics: Integer;
begin
  MethodLog('GetDeviceMetrics');
  Result := Driver.GetDeviceMetrics;
end;

function ToleMain.GetShortECRStatus: Integer;
begin
  MethodLog('GetShortECRStatus');
  Result := Driver.GetShortECRStatus;
end;

function ToleMain.GetECRStatus: Integer;
begin
  MethodLog('GetECRStatus');
  Result := Driver.GetECRStatus;
end;

function ToleMain.GetExchangeParam: Integer;
begin
  MethodLog('GetExchangeParam');
  Result := Driver.GetExchangeParam;
end;

function ToleMain.GetFieldStruct: Integer;
begin
  MethodLog('GetFieldStruct');
  Result := Driver.GetFieldStruct;
end;

function ToleMain.GetFiscalizationParameters: Integer;
begin
  MethodLog('GetFiscalizationParameters');
  Result := Driver.GetFiscalizationParameters;
end;

function ToleMain.GetFMRecordsSum: Integer;
begin
  MethodLog('GetFMRecordsSum');
  Result := Driver.GetFMRecordsSum;
end;

function ToleMain.GetLastFMRecordDate: Integer;
begin
  MethodLog('GetLastFMRecordDate');
  Result := Driver.GetLastFMRecordDate;
end;

function ToleMain.GetLiterSumCounter: Integer;
begin
  MethodLog('GetLiterSumCounter');
  Result := Driver.GetLiterSumCounter;
end;

function ToleMain.GetOperationReg: Integer;
begin
  MethodLog('GetOperationReg');
  Result := Driver.GetOperationReg;
end;

function ToleMain.GetRangeDatesAndSessions: Integer;
begin
  MethodLog('GetRangeDatesAndSessions');
  Result := Driver.GetRangeDatesAndSessions;
end;

function ToleMain.GetRKStatus: Integer;
begin
  MethodLog('GetRKStatus');
  Result := Driver.GetRKStatus;
end;

function ToleMain.GetTableStruct: Integer;
begin
  MethodLog('GetTableStruct');
  Result := Driver.GetTableStruct;
end;

function ToleMain.InitFM: Integer;
begin
  MethodLog('InitFM');
  Result := Driver.InitFM;
end;

function ToleMain.InitTable: Integer;
begin
  MethodLog('InitTable');
  Result := Driver.InitTable;
end;

function ToleMain.InterruptDataStream: Integer;
begin
  MethodLog('InterruptDataStream');
  Result := Driver.InterruptDataStream;
end;

function ToleMain.InterruptFullReport: Integer;
begin
  MethodLog('InterruptFullReport');
  Result := Driver.InterruptFullReport;
end;

function ToleMain.InterruptTest: Integer;
begin
  MethodLog('InterruptTest');
  Result := Driver.InterruptTest;
end;

function ToleMain.LaunchRK: Integer;
begin
  MethodLog('LaunchRK');
  Result := Driver.LaunchRK;
end;

function ToleMain.LoadLineData: Integer;
begin
  MethodLog('LoadLineData');
  Result := Driver.LoadLineData;
end;

function ToleMain.OilSale: Integer;
begin
  MethodLog('OilSale');
  Result := Driver.OilSale;
end;

function ToleMain.OpenCheck: Integer;
begin
  MethodLog('OpenCheck');
  Result := Driver.OpenCheck;
end;

function ToleMain.OpenDrawer: Integer;
begin
  MethodLog('OpenDrawer');
  Result := Driver.OpenDrawer;
end;

function ToleMain.PrintBarCode: Integer;
begin
  MethodLog('PrintBarCode');
  Result := Driver.PrintBarCode;
end;

function ToleMain.PrintDepartmentReport: Integer;
begin
  MethodLog('PrintDepartmentReport');
  Result := Driver.PrintDepartmentReport;
end;

function ToleMain.PrintDocumentTitle: Integer;
begin
  MethodLog('PrintDocumentTitle');
  Result := Driver.PrintDocumentTitle;
end;

function ToleMain.PrintOperationReg: Integer;
begin
  MethodLog('PrintOperationReg');
  Result := Driver.PrintOperationReg;
end;

function ToleMain.PrintReportWithCleaning: Integer;
begin
  MethodLog('PrintReportWithCleaning');
  Result := Driver.PrintReportWithCleaning;
end;

function ToleMain.PrintReportWithoutCleaning: Integer;
begin
  MethodLog('PrintReportWithoutCleaning');
  Result := Driver.PrintReportWithoutCleaning;
end;

function ToleMain.PrintString: Integer;
begin
  MethodLog('PrintString');
  Result := Driver.PrintString;
end;

function ToleMain.PrintWideString: Integer;
begin
  MethodLog('PrintWideString');
  Result := Driver.PrintWideString;
end;

function ToleMain.ReadEKLZDocumentOnKPK: Integer;
begin
  MethodLog('ReadEKLZDocumentOnKPK');
  Result := Driver.ReadEKLZDocumentOnKPK;
end;

function ToleMain.ReadEKLZSessionTotal: Integer;
begin
  MethodLog('ReadEKLZSessionTotal');
  Result := Driver.ReadEKLZSessionTotal;
end;

function ToleMain.ReadLicense: Integer;
begin
  MethodLog('ReadLicense');
  Result := Driver.ReadLicense;
end;

function ToleMain.ReadTable: Integer;
begin
  MethodLog('ReadTable');
  Result := Driver.ReadTable;
end;

function ToleMain.RepeatDocument: Integer;
begin
  MethodLog('RepeatDocument');
  Result := Driver.RepeatDocument;
end;

function ToleMain.ResetAllTRK: Integer;
begin
  MethodLog('ResetAllTRK');
  Result := Driver.ResetAllTRK;
end;

function ToleMain.ResetRK: Integer;
begin
  MethodLog('ResetRK');
  Result := Driver.ResetRK;
end;

function ToleMain.ResetSettings: Integer;
begin
  MethodLog('ResetSettings');
  Result := Driver.ResetSettings;
end;

function ToleMain.ResetSummary: Integer;
begin
  MethodLog('ResetSummary');
  Result := Driver.ResetSummary;
end;

function ToleMain.ReturnBuy: Integer;
begin
  MethodLog('ReturnBuy');
  Result := Driver.ReturnBuy;
end;

function ToleMain.ReturnSale: Integer;
begin
  MethodLog('ReturnSale');
  Result := Driver.ReturnSale;
end;

function ToleMain.ReturnBuyEx: Integer;
begin
  MethodLog('ReturnBuyEx');
  Result := Driver.ReturnBuyEx;
end;

function ToleMain.ReturnSaleEx: Integer;
begin
  MethodLog('ReturnSaleEx');
  Result := Driver.ReturnSaleEx;
end;

function ToleMain.Sale: Integer;
begin
  MethodLog('Sale');
  Result := Driver.Sale;
end;

function ToleMain.SaleEx: Integer;
begin
  MethodLog('SaleEx');
  Result := Driver.SaleEx;
end;

function ToleMain.SetDate: Integer;
begin
  MethodLog('SetDate');
  Result := Driver.SetDate;
end;

function ToleMain.SetDozeInMilliliters: Integer;
begin
  MethodLog('SetDozeInMilliliters');
  Result := Driver.SetDozeInMilliliters;
end;

function ToleMain.SetDozeInMoney: Integer;
begin
  MethodLog('SetDozeInMoney');
  Result := Driver.SetDozeInMoney;
end;

function ToleMain.SetExchangeParam: Integer;
begin
  MethodLog('SetExchangeParam');
  Result := Driver.SetExchangeParam;
end;

function ToleMain.SetPointPosition: Integer;
begin
  MethodLog('SetPointPosition');
  Result := Driver.SetPointPosition;
end;

function ToleMain.SetRKParameters: Integer;
begin
  MethodLog('SetRKParameters');
  Result := Driver.SetRKParameters;
end;

function ToleMain.SetSerialNumber: Integer;
begin
  MethodLog('SetSerialNumber');
  Result := Driver.SetSerialNumber;
end;

function ToleMain.SetTime: Integer;
begin
  MethodLog('SetTime');
  Result := Driver.SetTime;
end;

function ToleMain.StopEKLZDocumentPrinting: Integer;
begin
  MethodLog('StopEKLZDocumentPrinting');
  Result := Driver.StopEKLZDocumentPrinting;
end;

function ToleMain.StopRK: Integer;
begin
  MethodLog('StopRK');
  Result := Driver.StopRK;
end;

function ToleMain.Storno: Integer;
begin
  MethodLog('Storno');
  Result := Driver.Storno;
end;

function ToleMain.StornoEx: Integer;
begin
  MethodLog('StornoEx');
  Result := Driver.StornoEx;
end;

function ToleMain.StornoCharge: Integer;
begin
  MethodLog('StornoCharge');
  Result := Driver.StornoCharge;
end;

function ToleMain.StornoDiscount: Integer;
begin
  MethodLog('StornoDiscount');
  Result := Driver.StornoDiscount;
end;

function ToleMain.SummOilCheck: Integer;
begin
  MethodLog('SummOilCheck');
  Result := Driver.SummOilCheck;
end;

function ToleMain.SysAdminCancelCheck: Integer;
begin
  MethodLog('SysAdminCancelCheck');
  Result := Driver.SysAdminCancelCheck;
end;

function ToleMain.Test: Integer;
begin
  MethodLog('Test');
  Result := Driver.Test;
end;

function ToleMain.WriteLicense: Integer;
begin
  MethodLog('WriteLicense');
  Result := Driver.WriteLicense;
end;

function ToleMain.WriteTable: Integer;
begin
  MethodLog('WriteTable');
  Result := Driver.WriteTable;
end;

function ToleMain.Get_BarCode: WideString;
begin
  MethodLog('Get_BarCode');
  Result := Driver.BarCode;
end;

procedure ToleMain.Set_BarCode(const Value: WideString);
begin
  MethodLog('Set_BarCode');
  Driver.BarCode := Value;
end;

function ToleMain.Get_BatteryCondition: WordBool;
begin
  MethodLog('Get_BatteryCondition');
  Result := Driver.Get_BatteryCondition;
end;

function ToleMain.Get_BatteryVoltage: Double;
begin
  MethodLog('Get_BatteryVoltage');
  Result := Driver.Get_BatteryVoltage;
end;

procedure ToleMain.Set_BaudRate(Value: Integer);
begin
  MethodLog('Set_BaudRate');
  Driver.Set_BaudRate(Value);
end;

function ToleMain.Get_BaudRate: Integer;
begin
  MethodLog('Get_BaudRate');
  Result := Driver.Get_BaudRate;
end;

function ToleMain.Get_Change: Currency;
begin
  MethodLog('Get_Change');
  Result := Driver.Get_Change;
end;

function ToleMain.Get_CheckResult: Currency;
begin
  MethodLog('Get_CheckResult');
  Result := Driver.Get_CheckResult;
end;

procedure ToleMain.Set_CheckResult(Value: Currency);
begin
  MethodLog('Set_CheckResult');
  Driver.Set_CheckResult(Value);
end;

function ToleMain.Get_CheckType: Integer;
begin
  MethodLog('Get_CheckType');
  Result := Driver.Get_CheckType;
end;

function ToleMain.Get_ComNumber: Integer;
begin
  MethodLog('Get_ComNumber');
  Result := Driver.Get_ComNumber;
end;

function ToleMain.Get_ContentsOfCashRegister: Currency;
begin
  MethodLog('Get_ContentsOfCashRegister');
  Result := Driver.Get_ContentsOfCashRegister;
end;

function ToleMain.Get_ContentsOfOperationRegister: Integer;
begin
  MethodLog('Get_ContentsOfOperationRegister');
  Result := Driver.Get_ContentsOfOperationRegister;
end;

function ToleMain.Get_CurrentDozeInMilliliters: Integer;
begin
  MethodLog('Get_CurrentDozeInMilliliters');
  Result := Driver.Get_CurrentDozeInMilliliters;
end;

function ToleMain.Get_CurrentDozeInMoney: Currency;
begin
  MethodLog('Get_CurrentDozeInMoney');
  Result := Driver.Get_CurrentDozeInMoney;
end;

procedure ToleMain.Set_CheckType(Value: Integer);
begin
  MethodLog('Set_CheckType');
  Driver.Set_CheckType(Value);
end;

procedure ToleMain.Set_ComNumber(Value: Integer);
begin
  MethodLog('Set_ComNumber');
  Driver.Set_ComNumber(Value);
end;

procedure ToleMain.Set_CurrentDozeInMilliliters(Value: Integer);
begin
  MethodLog('Set_CurrentDozeInMilliliters');
  Driver.Set_CurrentDozeInMilliliters(Value);
end;

procedure ToleMain.Set_CurrentDozeInMoney(Value: Currency);
begin
  MethodLog('Set_CurrentDozeInMoney');
  Driver.Set_CurrentDozeInMoney(Value);
end;

function ToleMain.Get_CutType: WordBool;
begin
  MethodLog('Get_CutType');
  Result := Driver.Get_CutType;
end;

function ToleMain.Get_DataBlock: WideString;
begin
  MethodLog('Get_DataBlock');
  Result := Driver.Get_DataBlock;
end;

function ToleMain.Get_DataBlockNumber: Integer;
begin
  MethodLog('Get_DataBlockNumber');
  Result := Driver.Get_DataBlockNumber;
end;

function ToleMain.Get_Date: TDateTime;
begin
  MethodLog('Get_Date');
  Result := Driver.Get_Date;
end;

procedure ToleMain.Set_CutType(Value: WordBool);
begin
  MethodLog('Set_CutType');
  Driver.Set_CutType(Value);
end;

procedure ToleMain.Set_Date(Value: TDateTime);
begin
  MethodLog('Set_Date');
  Driver.Set_Date(Value);
end;

function ToleMain.Get_Department: Integer;
begin
  MethodLog('Get_Department');
  Result := Driver.Get_Department;
end;

function ToleMain.Get_DeviceCode: Integer;
begin
  MethodLog('Get_DeviceCode');
  Result := Driver.Get_DeviceCode;
end;

function ToleMain.Get_DeviceCodeDescription: WideString;
begin
  MethodLog('Get_DeviceCodeDescription');
  Result := Driver.Get_DeviceCodeDescription;
end;

procedure ToleMain.Set_Department(Value: Integer);
begin
  MethodLog('Set_Department');
  Driver.Set_Department(Value);
end;

procedure ToleMain.Set_DeviceCode(Value: Integer);
begin
  MethodLog('Set_DeviceCode');
  Driver.Set_DeviceCode(Value);
end;

function ToleMain.Get_DiscountOnCheck: Double;
begin
  MethodLog('Get_DiscountOnCheck');
  Result := Driver.Get_DiscountOnCheck;
end;

procedure ToleMain.Set_DiscountOnCheck(Value: Double);
begin
  MethodLog('Set_DiscountOnCheck');
  Driver.Set_DiscountOnCheck(Value);
end;

function ToleMain.Get_DocumentName: WideString;
begin
  MethodLog('Get_DocumentName');
  Result := Driver.Get_DocumentName;
end;

procedure ToleMain.Set_DocumentName(const Value: WideString);
begin
  MethodLog('Set_DocumentName');
  Driver.Set_DocumentName(Value);
end;

function ToleMain.Get_DocumentNumber: Integer;
begin
  MethodLog('Get_DocumentNumber');
  Result := Driver.Get_DocumentNumber;
end;

function ToleMain.Get_DozeInMilliliters: Integer;
begin
  MethodLog('Get_DozeInMilliliters');
  Result := Driver.Get_DozeInMilliliters;
end;

function ToleMain.Get_DozeInMoney: Currency;
begin
  MethodLog('Get_DozeInMoney');
  Result := Driver.Get_DozeInMoney;
end;

procedure ToleMain.Set_DocumentNumber(Value: Integer);
begin
  MethodLog('Set_DocumentNumber');
  Driver.Set_DocumentNumber(Value);
end;

procedure ToleMain.Set_DozeInMilliliters(Value: Integer);
begin
  MethodLog('Set_DozeInMilliliters');
  Driver.Set_DozeInMilliliters(Value);
end;

procedure ToleMain.Set_DozeInMoney(Value: Currency);
begin
  MethodLog('Set_DozeInMoney');
  Driver.Set_DozeInMoney(Value);
end;

function ToleMain.Get_DrawerNumber: Integer;
begin
  MethodLog('Get_DrawerNumber');
  Result := Driver.Get_DrawerNumber;
end;

function ToleMain.Get_ECRAdvancedMode: Integer;
begin
  MethodLog('Get_ECRAdvancedMode');
  Result := Driver.Get_ECRAdvancedMode;
end;

function ToleMain.Get_ECRAdvancedModeDescription: WideString;
begin
  MethodLog('Get_ECRAdvancedModeDescription');
  Result := Driver.Get_ECRAdvancedModeDescription;
end;

function ToleMain.Get_ECRBuild: Integer;
begin
  MethodLog('Get_ECRBuild');
  Result := Driver.Get_ECRBuild;
end;

function ToleMain.Get_ECRFlags: Integer;
begin
  MethodLog('Get_ECRFlags');
  Result := Driver.Get_ECRFlags;
end;

function ToleMain.Get_ECRInput: WideString;
begin
  MethodLog('Get_ECRInput');
  Result := Driver.Get_ECRInput;
end;

procedure ToleMain.Set_DrawerNumber(Value: Integer);
begin
  MethodLog('Set_DrawerNumber');
  Driver.Set_DrawerNumber(Value);
end;

function ToleMain.Get_ECRMode: Integer;
begin
  MethodLog('Get_ECRMode');
  Result := Driver.Get_ECRMode;
end;

function ToleMain.Get_ECRMode8Status: Integer;
begin
  MethodLog('Get_ECRMode8Status');
  Result := Driver.Get_ECRMode8Status;
end;

function ToleMain.Get_ECRModeDescription: WideString;
begin
  MethodLog('Get_ECRModeDescription');
  Result := Driver.Get_ECRModeDescription;
end;

function ToleMain.Get_ECROutput: WideString;
begin
  MethodLog('Get_ECROutput');
  Result := Driver.Get_ECROutput;
end;

function ToleMain.Get_ECRSoftDate: TDateTime;
begin
  MethodLog('Get_ECRSoftDate');
  Result := Driver.Get_ECRSoftDate;
end;

function ToleMain.Get_ECRSoftVersion: WideString;
begin
  MethodLog('Get_ECRSoftVersion');
  Result := Driver.Get_ECRSoftVersion;
end;

function ToleMain.Get_EKLZIsPresent: WordBool;
begin
  MethodLog('Get_EKLZIsPresent');
  Result := Driver.Get_EKLZIsPresent;
end;

function ToleMain.Get_EmergencyStopCode: Integer;
begin
  MethodLog('Get_EmergencyStopCode');
  Result := Driver.Get_EmergencyStopCode;
end;

function ToleMain.Get_EmergencyStopCodeDescription: WideString;
begin
  MethodLog('Get_EmergencyStopCodeDescription');
  Result := Driver.Get_EmergencyStopCodeDescription;
end;

function ToleMain.Get_FieldName: WideString;
begin
  MethodLog('Get_FieldName');
  Result := Driver.Get_FieldName;
end;

function ToleMain.Get_FieldNumber: Integer;
begin
  MethodLog('Get_FieldNumber');
  Result := Driver.Get_FieldNumber;
end;

function ToleMain.Get_FieldSize: Integer;
begin
  MethodLog('Get_FieldSize');
  Result := Driver.Get_FieldSize;
end;

function ToleMain.Get_FieldType: WordBool;
begin
  MethodLog('Get_FieldType');
  Result := Driver.Get_FieldType;
end;

function ToleMain.Get_FirstLineNumber: Integer;
begin
  MethodLog('Get_FirstLineNumber');
  Result := Driver.Get_FirstLineNumber;
end;

function ToleMain.Get_FirstSessionDate: TDateTime;
begin
  MethodLog('Get_FirstSessionDate');
  Result := Driver.Get_FirstSessionDate;
end;

procedure ToleMain.Set_FieldNumber(Value: Integer);
begin
  MethodLog('Set_FieldNumber');
  Driver.Set_FieldNumber(Value);
end;

procedure ToleMain.Set_FirstLineNumber(Value: Integer);
begin
  FFirstLineNumber := Value;
end;

procedure ToleMain.Set_FirstSessionDate(Value: TDateTime);
var
  Year, Month, Day: Word;
begin
  DecodeDate(Value, Year, Month, Day);
  FFirstSessionYear := Year-2000;
  FFirstSessionMonth := Month;
  FFirstSessionDay := Day;
end;

function ToleMain.Get_FirstSessionNumber: Integer;
begin
  Result := FFirstSessionNumber;
end;

function ToleMain.Get_FM1IsPresent: WordBool;
begin
  Result := FStatus.FlagsFP and $1=$1;
end;

function ToleMain.Get_FM2IsPresent: WordBool;
begin
  Result := FStatus.FlagsFP and $2=$2;
end;

function ToleMain.Get_FMBuild: Integer;
begin
  Result := FStatus.BuildFP;
end;

procedure ToleMain.Set_FirstSessionNumber(Value: Integer);
begin
  FFirstSessionNumber := Value;
end;

function ToleMain.Get_FMFlags: Integer;
begin
  Result := FStatus.FlagsFP;
end;

function ToleMain.Get_FMOverflow: WordBool;
begin
  Result := FStatus.FlagsFP and $8=$8;
end;

function ToleMain.Get_FMSoftDate: TDateTime;
begin
with FStatus do
  try
    Result := EncodeDate(2000+YearFP,MonthFP,DayFP);
  except
    on EConvertError do Result := 0;
  end;
end;

function ToleMain.Get_FMSoftVersion: WideString;
begin
  with FStatus do Result := VersionFP[1]+'.'+VersionFP[2];
end;

function ToleMain.Get_FreeRecordInFM: Integer;
begin
  Result := FStatus.FreeRecordInCM;
end;

function ToleMain.Get_FreeRegistration: Integer;
begin
  Result := FStatus.FreeRegistration;
end;

function ToleMain.Get_INN: WideString;
begin
  Result := FINN;
end;

function ToleMain.Get_IsCheckClosed: WordBool;
begin
//  Result := ;
end;

procedure ToleMain.Set_INN(const Value: WideString);
begin
  FINN := Value;
end;

function ToleMain.Get_IsCheckMadeOut: WordBool;
begin
//  Result := ;
end;

function ToleMain.Get_IsDrawerOpen: WordBool;
begin
  Result := FStatus.FlagsFR and $800 = $800;
end;

function ToleMain.Get_JournalRibbonIsPresent: WordBool;
begin
  Result := FStatus.FlagsFR and $1=$1;
end;

function ToleMain.Get_JournalRibbonLever: WordBool;
begin
  Result := FStatus.FlagsFR and $100=$100;
end;

function ToleMain.Get_JournalRibbonOpticalSensor: WordBool;
begin
  Result := FStatus.FlagsFR and $40=$40;
end;

function ToleMain.Get_KPKNumber: Integer;
begin
  Result := FKPKNumber;
end;

function ToleMain.Get_LastLineNumber: Integer;
begin
  Result := FLastLineNumber;
end;

function ToleMain.Get_LastSessionDate: TDateTime;
begin
  try
    Result := EncodeDate(2000+FLastSessionYear,FLastSessionMonth,FLastSessionDay);
  except
    on EConvertError do Result := 0;
  end;
end;

function ToleMain.Get_LastSessionNumber: Integer;
begin
  Result := FLastSessionNumber;
end;

function ToleMain.Get_License: WideString;
begin
  Result := FLicense;
end;

procedure ToleMain.Set_KPKNumber(Value: Integer);
begin
  FKPKNumber := Value;
end;

procedure ToleMain.Set_LastLineNumber(Value: Integer);
begin
  FLastLineNumber := Value;
end;

procedure ToleMain.Set_LastSessionDate(Value: TDateTime);
var year,month,day:word;
begin
  DecodeDate(Value,year,month,day);
  FLastSessionYear := year-2000;
  FLastSessionMonth := month;
  FLastSessionDay := day;
end;

procedure ToleMain.Set_LastSessionNumber(Value: Integer);
begin
  FLastSessionNumber := Value;
end;

procedure ToleMain.Set_License(const Value: WideString);
begin
  FLicense := Value;
end;

function ToleMain.Get_LicenseIsPresent: WordBool;
begin
  Result := FStatus.FlagsFP and $4=$4;
end;

function ToleMain.Get_LidPositionSensor: WordBool;
begin
  Result := FStatus.FlagsFR and $400=$400;
end;

function ToleMain.Get_LineData: WideString;
begin
  Result := FLineData;
end;

procedure ToleMain.Set_LineData(const Value: WideString);
begin
  FLineData := Value;
end;

function ToleMain.Get_LineNumber: Integer;
begin
  Result := FLineNumber;
end;

function ToleMain.Get_LogicalNumber: Integer;
begin
  Result := FStatus.LogicalNumber;
end;

function ToleMain.Get_MAXValueOfField: Integer;
begin
  Result := FField.MaxValue;
end;

function ToleMain.Get_MINValueOfField: Integer;
begin
  Result := FField.MinValue;
end;

function ToleMain.Get_Motor: WordBool;
begin
//  Result := ;
end;

procedure ToleMain.Set_LineNumber(Value: Integer);
begin
  FLineNumber := Value;
end;

function ToleMain.Get_NameCashReg: WideString;
begin
  if FRegisterNumber in [0..High(CashRegisterName)] then
    Result := CashRegisterName[FRegisterNumber]
  else Result := 'Описание регистра не доступно';
end;

function ToleMain.Get_NameOperationReg: WideString;
begin
  if FRegisterNumber in [0..High(OperationRegisterName)] then
    Result := OperationRegisterName[FRegisterNumber]
  else Result := 'Описание регистра не доступно';
end;

function ToleMain.Get_NewPasswordTI: Integer;
begin
  Result := FNewPasswordTI;
end;

function ToleMain.Get_OpendocumentNumber: Integer;
begin
  Result := FStatus.DocNumber;
end;

function ToleMain.Get_OperatorNumber: Integer;
begin
  Result := FStatus.OperatorNumber;
end;

function ToleMain.Get_Password: Integer;
begin
  Result := FPassword;
end;

function ToleMain.Get_Pistol: WordBool;
begin
//  Result := ;
end;

function ToleMain.Get_PointPosition: WordBool;
begin
  Result := FStatus.FlagsFR and $10=$10;
end;

procedure ToleMain.Set_NewPasswordTI(Value: Integer);
begin
  FNewPasswordTI := Value;
end;

procedure ToleMain.Set_Password(Value: Integer);
begin
  FPassword := Value;
  FPassw := GetPassword(Value);
end;

procedure ToleMain.Set_PointPosition(Value: WordBool);
begin
  if Value then FPointPosition := 1 else FPointPosition := 0;
end;

function ToleMain.Get_PortNumber: Integer;
begin
  Result := FStatus.PortFR;
end;

procedure ToleMain.Set_PortNumber(Value: Integer);
begin
  FStatus.PortFR := Value;
end;

function ToleMain.Get_Price: Currency;
begin
  Result := FPrice;
end;

procedure ToleMain.Set_Price(Value: Currency);
begin
  FPrice := Value;
end;

function ToleMain.Get_Quantity: Double;
begin
  Result := FQuantity;
end;

procedure ToleMain.Set_Quantity(Value: Double);
begin
  FQuantity := Value;
end;

function ToleMain.Get_QuantityOfOperations: Integer;
begin
  Result := FSaleNum;
end;

function ToleMain.Get_ReceiptRibbonIsPresent: WordBool;
begin
  Result := FStatus.FlagsFR and $2=$2;
end;

function ToleMain.Get_ReceiptRibbonLever: WordBool;
begin
  Result := FStatus.FlagsFR and $200=$200;
end;

function ToleMain.Get_ReceiptRibbonOpticalSensor: WordBool;
begin
  Result := FStatus.FlagsFR and $80=$80;
end;

function ToleMain.Get_RegisterNumber: Integer;
begin
  Result := FRegisterNumber;
end;

function ToleMain.Get_RegistrationNumber: Integer;
begin
  Result := FRegistrationNumber;
end;

function ToleMain.Get_ReportType: WordBool;
begin
  Result := WordBool(FReportType);
end;

procedure ToleMain.Set_RegisterNumber(Value: Integer);
begin
  FRegisterNumber := Value;
end;

procedure ToleMain.Set_RegistrationNumber(Value: Integer);
begin
  FRegistrationNumber := Value;
end;

procedure ToleMain.Set_ReportType(Value: WordBool);
begin
  if Value then FReportType := 1 else FReportType := 0;
end;

function ToleMain.Get_ResultCode: Integer;
begin
  Result := FResultCode;
end;

function ToleMain.Get_ResultCodeDescription: WideString;
begin
  Result := FResultDescription;
end;

function ToleMain.Get_RKNumber: Integer;
begin
//  Result := ;
end;

function ToleMain.Get_RNM: WideString;
begin
  Result := FRNM;
end;

function ToleMain.Get_RoughValve: WordBool;
begin
  Result := False;
end;

procedure ToleMain.Set_RKNumber(Value: Integer);
begin

end;

procedure ToleMain.Set_RNM(const Value: WideString);
begin
  FRNM := Value;
end;

function ToleMain.Get_RowNumber: Integer;
begin
  Result := FRowNumber;
end;

function ToleMain.Get_RunningPeriod: Integer;
begin
  Result := FPeriod;
end;

function ToleMain.Get_SerialNumber: WideString;
begin
  Result := FSerialNumber;
end;

procedure ToleMain.Set_RowNumber(Value: Integer);
begin
  FRowNumber := Value;
end;

procedure ToleMain.Set_RunningPeriod(Value: Integer);
begin
  FPeriod := Value;
end;

procedure ToleMain.Set_SerialNumber(const Value: WideString);
begin
  FSerialNumber := Value;
end;

function ToleMain.Get_SessionNumber: Integer;
begin
  Result := FStatus.SessionNumber;
end;

function ToleMain.Get_SlipDocumentIsMoving: WordBool;
begin
  Result := FStatus.FlagsFR and $4=$4;
end;

function ToleMain.Get_SlipDocumentIsPresent: WordBool;
begin
  Result := FStatus.FlagsFR and $8=$8;
end;


procedure ToleMain.Set_SessionNumber(Value: Integer);
begin
  FStatus.SessionNumber := Value;
end;

function ToleMain.Get_SlowingInMilliliters: Integer;
begin
//  Result := ;
end;

function ToleMain.Get_SlowingValve: WordBool;
begin
//  Result := ;
end;

function ToleMain.Get_StatusRK: Integer;
begin
//  Result := ;
end;

function ToleMain.Get_StatusRKDescription: WideString;
begin
//  Result := ;
end;

function ToleMain.Get_StringForPrinting: WideString;
begin
  Result := FString;
end;

function ToleMain.Get_StringQuantity: Integer;
begin
  Result := FStringQuantity;
end;

function ToleMain.Get_Summ1: Currency;
begin
  Result := FSumm1;
end;

procedure ToleMain.Set_SlowingInMilliliters(Value: Integer);
begin
//
end;

procedure ToleMain.Set_StringForPrinting(const Value: WideString);
begin
  FString := Value;
end;

procedure ToleMain.Set_StringQuantity(Value: Integer);
begin
  FStringQuantity := Value;
end;

procedure ToleMain.Set_Summ1(Value: Currency);
begin
  FSumm1 := Value;
end;

function ToleMain.Get_Summ2: Currency;
begin
  Result := FSumm2;
end;

procedure ToleMain.Set_Summ2(Value: Currency);
begin
  FSumm2 := Value;
end;

function ToleMain.Get_Summ3: Currency;
begin
  Result := FSumm3;
end;

procedure ToleMain.Set_Summ3(Value: Currency);
begin
  FSumm3 := Value;
end;

function ToleMain.Get_Summ4: Currency;
begin
  Result := FSumm4;
end;

procedure ToleMain.Set_Summ4(Value: Currency);
begin
  FSumm4 := Value;
end;

function ToleMain.Get_TableName: WideString;
begin
  Result := FTableName;
end;

function ToleMain.Get_TableNumber: Integer;
begin
  Result := FTableNumber;
end;

function ToleMain.Get_Tax1: Integer;
begin
  Result := FTax1;
end;

function ToleMain.Get_Tax2: Integer;
begin
    Result := FTax2;
end;

function ToleMain.Get_Tax3: Integer;
begin
  Result := FTax3;
end;

function ToleMain.Get_Tax4: Integer;
begin
  Result := FTax4;
end;

function ToleMain.Get_Time: TDateTime;
begin
  Result := FTime;
end;

procedure ToleMain.Set_TableNumber(Value: Integer);
begin
  FTableNumber := Value;
end;

procedure ToleMain.Set_Tax1(Value: Integer);
begin
  FTax1 := Value;
end;

procedure ToleMain.Set_Tax2(Value: Integer);
begin
  FTax2 := Value;
end;

procedure ToleMain.Set_Tax3(Value: Integer);
begin
  FTax3 := Value;
end;

procedure ToleMain.Set_Tax4(Value: Integer);
begin
  FTax4 := Value;
end;

procedure ToleMain.Set_Time(Value: TDateTime);
begin
  FTime := Value;
end;

function ToleMain.Get_Timeout: Integer;
begin
  Result := FTimeout;
end;

function ToleMain.Get_TimeStr: WideString;
begin
  Result := TimeToStr1C(FTime);
end;

procedure ToleMain.Set_Timeout(Value: Integer);
begin
  FTimeout := Value;
end;

procedure ToleMain.Set_TimeStr(const Value: WideString);
begin
  try
    FTime := StrToTime(Value);
  except
    { !!! }
  end;
end;

function ToleMain.Get_TransferBytes: WideString;
begin
  Result := FTransferByte;
end;

procedure ToleMain.Set_TransferBytes(const Value: WideString);
begin
  FTransferByte := Value;
end;

function ToleMain.Get_TRKNumber: Integer;
begin
//  Result := ;
end;

function ToleMain.Get_TypeOfLastEntryFM: WordBool;
begin
  Result := WordBool(FTypeOfLastEntryCM);
end;

procedure ToleMain.Set_TRKNumber(Value: Integer);
begin
//
end;

function ToleMain.Get_TypeOfSumOfEntriesFM: WordBool;
begin
  Result := WordBool(FTypeOfSumOfEntriesCM);
end;

procedure ToleMain.Set_TypeOfSumOfEntriesFM(Value: WordBool);
begin
  if Value then FTypeOfSumOfEntriesCM := 1
  else FTypeOfSumOfEntriesCM := 0;
end;

function ToleMain.Get_UCodePage: Integer;
begin
  Result := FUCodePage;
end;

function ToleMain.Get_UDescription: WideString;
begin
  Result := FUDescription;
end;

function ToleMain.Get_UMajorProtocolVersion: Integer;
begin
  Result := FUMajorProtocolVersion;
end;

function ToleMain.Get_UMajorType: Integer;
begin
  Result := FUMajorType;
end;

function ToleMain.Get_UMinorProtocolVersion: Integer;
begin
  Result := FUMinorProtocolVersion;
end;


function ToleMain.Get_UMinorType: Integer;
begin
  Result := FUMinorType;
end;

function ToleMain.Get_UModel: Integer;
begin
  Result := FUModel;
end;

function ToleMain.Get_UseJournalRibbon: WordBool;
begin
  Result := (FTapeType and 1) = 1;
end;

function ToleMain.Get_UseReceiptRibbon: WordBool;
begin
  Result := (FTapeType and 2) = 2;
end;

procedure ToleMain.Set_UseJournalRibbon(Value: WordBool);
begin
  if Value then FTapeType := FTapeType or 1
  else FTapeType := FTapeType and $FE;
end;

procedure ToleMain.Set_UseReceiptRibbon(Value: WordBool);
begin
  if Value then FTapeType := FTapeType or 2
  else FTapeType := FTapeType and $FD;
end;

function ToleMain.Get_UseSlipDocument: WordBool;
begin
  Result := (FTapeType and 4) = 4;
end;

procedure ToleMain.Set_UseSlipDocument(Value: WordBool);
begin
  if Value then FTapeType := FTapeType or 4
  else FTapeType := FTapeType and $FB;
end;

function ToleMain.Get_ValueOfFieldInteger: Integer;
begin
  Result := FField.IntValue;
end;

function ToleMain.Get_ValueOfFieldString: WideString;
begin
  Result := FField.StrValue;
end;

procedure ToleMain.Set_ValueOfFieldInteger(Value: Integer);
begin
  FField.IntValue := Value;
end;

procedure ToleMain.Set_ValueOfFieldString(const Value: WideString);
begin
  FField.StrValue := Value;
end;

// Печать строки данным шрифтом

function ToleMain.PrintStringWithFont: Integer;
var
  Data: string;
begin
  try
    Data := #$2F + FPassw + Chr(FTapeType) + Chr(GetFontType) +
      GetStr(FString, 40, 7);
    Result := Send(Data);
    ccPrintString;
  except
    on E: Exception do Result := HandleException(E);
  end;
end;

function ToleMain.Get_FontType: Integer;
begin
  Result := FFontType;
end;

procedure ToleMain.Set_FontType(Value: Integer);
begin
  FFontType := Value;
end;

function ToleMain.Get_WaitPrintingTime: Integer;
begin
  Result := FWaitPrintingTime;
end;

function ToleMain.Get_IsPrinterRightSensorFailure: WordBool;
begin
  Result := FStatus.FlagsFR and $1000=$1000;
end;

function ToleMain.Get_IsPrinterLeftSensorFailure: WordBool;
begin
  Result := FStatus.FlagsFR and $2000=$2000;
end;

// Итог активизации ЭКЛЗ

function ToleMain.EKLZActivizationResult: Integer;
begin
  Result := Send(#$A8 + FPassw);
end;

// Активизация ЭКЛЗ

function ToleMain.EKLZActivization: Integer;
begin
  Result := Send(#$A9 + FPassw);
end;

// Закрытие архива ЭКЛЗ

function ToleMain.CloseEKLZArchive: Integer;
begin
  Result := Send(#$AA + FPassw);
end;

// Прекращение ЭКЛЗ

function ToleMain.EKLZInterrupt: Integer;
begin
  Result := Send(#$AC + FPassw);
end;

function ToleMain.Get_EKLZNumber: WideString;
begin
  Result := IntToStr(FEKLZNumber);
end;

// Запрос состояния по коду 1 ЭКЛЗ

function ToleMain.GetEKLZCode1Report: Integer;
begin
  FGetEKLZCode1Report := True;
  try
    Result := Send(#$AD + FPassw);
  finally
    FGetEKLZCode1Report := False;
  end;
end;

// Запрос регистрационного номера ЭКЛЗ

function ToleMain.GetEKLZSerialNumber: Integer;
begin
  Result := Send(#$AB + FPassw);
end;

function ToleMain.Get_LastKPKDate: TDateTime;
begin
  try
    Result := EncodeDate(2000+FLastKPKYear,FLastKPKMonth,FLastKPKDay);
  except
    on EConvertError do Result := 0;
  end;
end;

function ToleMain.Get_LastKPKDocumentResult: Currency;
begin
  Result := FLastKPKDocumentResult;
end;

function ToleMain.Get_LastKPKTime: TDateTime;
begin
  try
    Result := EncodeTime(FLastKPKHour,FLastKPKMin,0,0);
  except
    on EConvertError do Result := 0;
  end;
end;

function ToleMain.Get_EKLZFlags: Integer;
begin
  Result := FEKLZFlags;
end;

function ToleMain.Get_LastKPKNumber: Integer;
begin
  Result := FLastKPKNumber;
end;

// Запрос состояния по коду 2 ЭКЛЗ

function ToleMain.GetEKLZCode2Report: Integer;
begin
  Result := Send(#$AE + FPassw);
end;

// Тест целостности архива ЭКЛЗ

function ToleMain.TestEKLZArchiveIntegrity: Integer;
begin
  Result := Send(#$AF + FPassw);
end;

function ToleMain.Get_TestNumber: Integer;
begin
  Result := FTestNumber;
end;

procedure ToleMain.Set_TestNumber(Value: Integer);
begin
  FTestNumber := Value;
end;

function ToleMain.Get_EKLZData: WideString;
begin
  Result := FEKLZData;
end;

function ToleMain.Get_EKLZVersion: WideString;
begin
  Result := FEKLZVersion;
end;

// Запрос версии ЭКЛЗ

function ToleMain.GetEKLZVersion: Integer;
begin
  Result := Send(#$B1 + FPassw);
end;

// Инициализация архива ЭКЛЗ

function ToleMain.InitEKLZArchive: Integer;
begin
  Result := Send(#$B2 + FPassw);
end;

// Запрос данных отчёта ЭКЛЗ

function ToleMain.GetEKLZData: Integer;
begin
  Result := Send(#$B3 + FPassw);
end;

// Запрос отчёта ЭКЛЗ по отделам в заданном диапазоне дат

function ToleMain.GetEKLZDepartmentReportInDatesRange: Integer;
var
  Data: string;
begin
  try
    Data :=
      #$B6 +
      FPassw +
      Chr(FReportType) +
      Chr(GetDepartment) +
      Chr(FFirstSessionDay) +
      Chr(FFirstSessionMonth) +
      Chr(FFirstSessionYear) +
      Chr(FLastSessionDay) +
      Chr(FLastSessionMonth) +
      Chr(FLastSessionYear);

    Result := Send(Data);
  except
    on E: Exception do Result := HandleException(E);
  end;
end;

// Запрос отчёта ЭКЛЗ по отделам в заданном диапазоне номеров смен

function ToleMain.GetEKLZDepartmentReportInSessionsRange: Integer;
var
  Data: string;
begin
  try
    Data :=
      #$B7 +
      FPassw +
      Chr(FReportType) +
      Chr(GetDepartment) +
      WordToStr(GetFirstSessionNumber) +
      WordToStr(GetLastSessionNumber);

    Result := Send(Data);
  except
    on E: Exception do Result := HandleException(E);
  end;
end;

// Запрос документа ЭКЛЗ

function ToleMain.GetEKLZDocument: Integer;
var
  Data: string;
begin
  if not ValidKPKNumber then
  begin
    Result := InvalidParam;
    Exit;
  end;
  
  Data := #$B5 + FPassw + DWORDToStr(FKPKNumber);
  Result := Send(Data);
end;

// Запрос контрольной ленты ЭКЛЗ

function ToleMain.GetEKLZJournal: Integer;
var
  Data: string;
begin
  Data := #$B4 + FPassw + WordToStr(FStatus.SessionNumber);
  Result := Send(Data);
end;

// Запрос отчёта ЭКЛЗ по закрытиям смен в заданном диапазоне дат

function ToleMain.GetEKLZSessionReportInDatesRange: Integer;
var
  Data: string;
begin
  Data :=
    #$B8 +
    FPassw +
    Chr(FReportType) +
    Chr(FFirstSessionDay) +
    Chr(FFirstSessionMonth)+
    Chr(FFirstSessionYear) +
    Chr(FLastSessionDay) +
    Chr(FLastSessionMonth) +
    Chr(FLastSessionYear);

  Result := Send(Data);
end;

// Запрос отчёта ЭКЛЗ по закрытиям смен в заданном диапазоне номеров смен

function ToleMain.GetEKLZSessionReportInSessionsRange: Integer;
var
  Data: string;
begin
  try
    Data :=
      #$B9 +
      FPassw +
      Chr(FReportType) +
      WordToStr(GetFirstSessionNumber) +
      WordToStr(GetLastSessionNumber);

    Result := Send(Data);
  except
    on E: Exception do Result := HandleException(E);
  end;
end;

// Запрос итога активизации ЭКЛЗ

function ToleMain.GetEKLZActivizationResult: Integer;
begin
  Result := Send(#$BB + Fpassw);
end;

// Запрос в ЭКЛЗ итогов смены по номеру смены

function ToleMain.GetEKLZSessionTotal: Integer;
var
  Data: string;
begin
  Data := #$BA + FPassw + WordToStr(FStatus.SessionNumber);
  Result := Send(Data);
end;

// Вернуть ошибку ЭКЛЗ

function ToleMain.SetEKLZResultCode: Integer;
begin
  if (FEKLZError in [0..255]) then
    Result := Send(#$BC + FPassw + Chr(FEKLZError))
  else
    Result := InvalidParam;
end;

function ToleMain.Get_EKLZResultCode: Integer;
begin
  Result := FEKLZError;
end;

procedure ToleMain.Set_EKLZResultCode(Value: Integer);
begin
  FEKLZError := Value;
end;

function ToleMain.Get_FMResultCode: Integer;
begin
  Result := FFMError;
end;

function ToleMain.Get_PowerSourceVoltage: Double;
begin
  Result := Trunc(FXState*24/$D8*100+0.5)/100;
end;

function ToleMain.Get_IsEKLZOverflow: WordBool;
begin
  Result := FStatus.FlagsFR and $4000=$4000;
end;

// Открыть фискальный подкладной документ

function ToleMain.OpenFiscalSlipDocument: Integer;
var
  Data: string;
  DocArg: string;
  DocArgEx: string;
begin
  try
    SetLength(DocArg, SizeOf(FOpenSlipDocArg));
    Move(FOpenSlipDocArg, DocArg[1], SizeOf(FOpenSlipDocArg));
    SetLength(DocArgEx, SizeOf(FOpenSlipDocArgEx));
    Move(FOpenSlipDocArgEx, DocArgEx[1], SizeOf(FOpenSlipDocArgEx));

    Data :=
      #$70 +
      FPassw +
      Chr(GetCheckType) +
      DocArg +
      DocArgEx;

    Result := Send(Data);
  except
    on E: Exception do Result := HandleException(E);
  end;
end;

// Открыть стандартный фискальный подкладной документ

function ToleMain.OpenStandardFiscalSlipDocument: Integer;
var
  Data: string;
  DocArg: string;
begin
  try
    SetLength(DocArg, SizeOf(FOpenSlipDocArg));
    Move(FOpenSlipDocArg, DocArg[1], SizeOf(FOpenSlipDocArg));

    Data :=
      #$71 +
      FPassw +
      Chr(GetCheckType) +
      DocArg;

    Result := Send(Data);
  except
    on E: Exception do Result := HandleException(E);
  end;
end;

// Формирование операции на подкладном документе

function ToleMain.RegistrationOnSlipDocument: Integer;
var
  Data: string;
  RegSlipDocEx: string;
begin
  try
    SetLength(RegSlipDocEx, SizeOf(FRegSlipDocEx));
    Move(FRegSlipDocEx, RegSlipDocEx[1], SizeOf(FRegSlipDocEx));

    Data :=
      #$72 +
      FPassw +
      RegSlipDocEx +
      Chr(GetOperationBlockFirstString) +
      GetQuantity +
      GetPrice +
      Chr(GetDepartment) +
      Chr(GetTax1) +
      Chr(GetTax2) +
      Chr(GetTax3) +
      Chr(GetTax4) +
      GetStr(FString, 40, 42);

    Result := Send(Data);
  except
    on E: Exception do Result := HandleException(E);
  end;
end;

// Формирование стандартной операции на подкладном документе

function ToleMain.StandardRegistrationOnSlipDocument: Integer;
var
  Data: string;
begin
  try
    Data :=
      #$73 +
      FPassw +
      Chr(GetOperationBlockFirstString) +
      GetQuantity +
      GetPrice +
      Chr(GetDepartment) +
      Chr(GetTax1) +
      Chr(GetTax2) +
      Chr(GetTax3) +
      Chr(GetTax4) +
      GetStr(FString, 40, 21);

    Result := Send(Data);
  except
    on E: Exception do Result := HandleException(E);
  end;
end;

// Формирование скидки/надбавки на подкладном документе

function ToleMain.ChargeOnSlipDocument: Integer;
var
  Data: string;
begin
  try
    Data :=
      #$74 +
      FPassw +
      DiscountChargeExToStr(FDiscountChargeEx) +
      #$01 +
      Chr(GetOperationBlockFirstString) +
      GetSumm1 +
      Chr(GetTax1) +
      Chr(GetTax2) +
      Chr(GetTax3) +
      Chr(GetTax4) +
      GetStr(FString, 40, 28);
    Result := Send(Data);
  except
    on E: Exception do Result := HandleException(E);
  end;
end;

// Формирование стандартной скидки/надбавки на подкладном документе

function ToleMain.StandardChargeOnSlipDocument: Integer;
var
  Data: string;
begin
  try
    Data :=
      #$75 +
      FPassw +
      #$01 +
      Chr(GetOperationBlockFirstString) +
      GetSumm1 +
      Chr(GetTax1) +
      Chr(GetTax2) +
      Chr(GetTax3) +
      Chr(GetTax4) +
      GetStr(Fstring, 40, 16);
    Result := Send(Data);
  except
    on E: Exception do Result := HandleException(E);
  end;
end;

// Формирование закрытия чека на подкладном документе

function ToleMain.CloseCheckOnSlipDocument: Integer;

  function CloseCheckExToStr(const Value: TCloseCheckEx): string;
  begin
    SetLength(Result, SizeOf(TCloseCheckEx));
    Move(Value, Result[1], SizeOf(TCloseCheckEx));
  end;

var
  Data: string;
begin
  try
    Data :=
      #$76 +
      FPassw +
      CloseCheckExToStr(FCloseCheckEx) +
      Chr(GetOperationBlockFirstString) +
      GetSumm1 +
      GetSumm2 +
      GetSumm3 +
      GetSumm4 +
      GetDiscountOnCheck + 
      Chr(GetTax1) +
      Chr(GetTax2) +
      Chr(GetTax3) +
      Chr(GetTax4) +
      GetStr(FString, 40, 141);
    Result := Send(Data);
  except
    on E: Exception do Result := HandleException(E);
  end;
end;

// Формирование стандартного закрытия чека на подкладном документе

function ToleMain.StandardCloseCheckOnSlipDocument: Integer;
var
  Data: string;
begin
  try
    Data :=
      #$77 +
      FPassw +
      Chr(GetOperationBlockFirstString) +
      GetSumm1 +
      GetSumm2 +
      GetSumm3 +
      GetSumm4 +
      GetDiscountOnCheck +
      Chr(GetTax1) +
      Chr(GetTax2) +
      Chr(GetTax3) +
      Chr(GetTax4) +
      GetStr(FString, 40, 32);
    Result := Send(Data);
  except
    on E: Exception do Result := HandleException(E);
  end;
end;

// Конфигурация подкладного документа

function ToleMain.ConfigureSlipDocument: Integer;
var
  S: string;
  Data: string;
begin
  try
    SetLength(S, SizeOf(FSlipstringIntervals));
    Move(FSlipstringIntervals, S[1], SizeOf(FSlipstringIntervals));

    Data :=
      #$78 +
      FPassw +
      WordToStr(GetSlipWidth) +
      WordToStr(GetSlipLength) +
      Chr(GetPrintingAlignment) +
      S;
    Result := Send(Data);
  except
    on E: Exception do Result := HandleException(E);
  end;
end;

// Установка стандартной конфигурации подкладного документа

function ToleMain.ConfigureStandardSlipDocument: Integer;
begin
  Result := Send(#$79 + FPassw);
end;

// Очистка всего буфера подкладного документа
// от нефискальной информации

function ToleMain.ClearSlipDocumentBuffer: Integer;
begin
  Result := Send(#$7C + Fpassw);
end;

// Очистка строки буфера подкладного документа
// от нефискальной информации

function ToleMain.ClearSlipDocumentBufferString: Integer;
begin
  try
    Result := Send(#$7B + FPassw + Chr(GetStringNumber));
  except
    on E: Exception do Result := HandleException(E);
  end;
end;

// Заполнение буфера подкладного документа нефискальной информацией

function ToleMain.FillSlipDocumentWithUnfiscalInfo: Integer;
var
  Data: string;
begin
  try
    Data :=
      #$7A +
      FPassw +
      Chr(GetStringNumber) +
      Copy(FString, 1, 247);

    Result := Send(Data);
  except
    on E: Exception do Result := HandleException(E);
  end;
end;

// Печать подкладного документа

function ToleMain.PrintSlipDocument: Integer;
var
  Data: string;
begin
  if (FInfoType in [0..255]) then
  begin
    Data :=
      #$7D +
      FPassw +
      Chr(BoolToInt[FIsclearUnfiskalInfo]) +
      Chr(FInfoType);
    Result := Send(Data);
  end else
    Result := InvalidParam;  
end;

function ToleMain.Get_NumberOfCopies: Integer;
begin
  Result := FOpenSlipDocArg.CopyCount;
end;

function ToleMain.Get_CopyOffset1: Integer;
begin
  Result := FOpenSlipDocArg.CopyOffset1;
end;

function ToleMain.Get_CopyOffset2: Integer;
begin
  Result := FOpenSlipDocArg.CopyOffset2;
end;

function ToleMain.Get_CopyOffset3: Integer;
begin
  Result := FOpenSlipDocArg.CopyOffset3;
end;

function ToleMain.Get_CopyOffset4: Integer;
begin
  Result := FOpenSlipDocArg.CopyOffset4;
end;

function ToleMain.Get_CopyOffset5: Integer;
begin
  Result := FOpenSlipDocArg.CopyOffset5;
end;

function ToleMain.Get_CopyType: Integer;
begin
  Result := FOpenSlipDocArg.CopyType;
end;

function ToleMain.Get_DepartmentFont: Integer;
begin
  Result := FRegSlipDocEx.DepartmentFont;
end;

function ToleMain.Get_DepartmentOffset: Integer;
begin
  Result := FRegSlipDocEx.DepartmentOffset;
end;

function ToleMain.Get_DepartmentStringNumber: Integer;
begin
  Result := FRegSlipDocEx.DepartmentStringNumber;
end;

function ToleMain.Get_DepartmentSymbolNumber: Integer;
begin
  Result := FRegSlipDocEx.DepartmentSymbolNumber;
end;

function ToleMain.Get_EKLZFont: Integer;
begin
  Result := FOpenSlipDocArgEx.EKLZFont;
end;

function ToleMain.Get_EKLZOffset: Integer;
begin
  Result := FOpenSlipDocArgEx.EKLZOffset;
end;

function ToleMain.Get_EKLZStringNumber: Integer;
begin
  Result := FOpenSlipDocArgEx.EKLZStringNumber;
end;

function ToleMain.Get_OperationBlockFirstString: Integer;
begin
  Result := FOperationBlockFirstString;
end;

function ToleMain.Get_FMOffset: Integer;
begin
  Result := FOpenSlipDocArgEx.FMOffset;
end;

function ToleMain.Get_FMStringNumber: Integer;
begin
  Result := FOpenSlipDocArgEx.FMStringNumber;
end;

function ToleMain.Get_HeaderFont: Integer;
begin
  Result := FOpenSlipDocArgEx.HeaderFont;
end;

function ToleMain.Get_HeaderOffset: Integer;
begin
  Result := FOpenSlipDocArgEx.HeaderOffset;
end;

function ToleMain.Get_HeaderStringNumber: Integer;
begin
  Result := FOpenSlipDocArgEx.HeaderStringNumber;
end;

function ToleMain.Get_ClicheFont: Integer;
begin
  Result := FOpenSlipDocArgEx.KlicheFont;
end;

function ToleMain.Get_ClicheOffset: Integer;
begin
  Result := FOpenSlipDocArgEx.KlicheOffset;
end;

function ToleMain.Get_ClicheStringNumber: Integer;
begin
  Result := FOpenSlipDocArgEx.KlicheStringNumber;
end;

function ToleMain.Get_KPKOffset: Integer;
begin
  Result := FOpenSlipDocArgEx.KPKOffset;
end;

function ToleMain.Get_MultiplicationFont: Integer;
begin
  Result := FRegSlipDocEx.MultiplicationFont;
end;

function ToleMain.Get_PriceFont: Integer;
begin
  Result := FRegSlipDocEx.PriceFont;
end;

function ToleMain.Get_PriceSymbolNumber: Integer;
begin
  Result := FRegSlipDocEx.PriceSymbolNumber;
end;

function ToleMain.Get_QuantityFont: Integer;
begin
  Result := FRegSlipDocEx.QuantityFont;
end;

function ToleMain.Get_QuantityFormat: Integer;
begin
  Result := FRegSlipDocEx.QuantityFormat;
end;

function ToleMain.Get_QuantityOffset: Integer;
begin
  Result := FRegSlipDocEx.QuantityOffset;
end;

function ToleMain.Get_QuantityStringNumber: Integer;
begin
  Result := FRegSlipDocEx.QuantityStringNumber;
end;

function ToleMain.Get_QuantitySymbolNumber: Integer;
begin
  Result := FRegSlipDocEx.QuantitySymbolNumber;
end;

function ToleMain.Get_StringQuantityInOperation: Integer;
begin
  Result := FRegSlipDocEx.StringCountInOperation;
end;

function ToleMain.Get_SummFont: Integer;
begin
  Result := FRegSlipDocEx.SummFont;
end;

function ToleMain.Get_SummOffset: Integer;
begin
  Result := FRegSlipDocEx.SummOffset;
end;

function ToleMain.Get_SummStringNumber: Integer;
begin
  Result := FRegSlipDocEx.SummStringNumber;
end;

function ToleMain.Get_SummSymbolNumber: Integer;
begin
  Result := FRegSlipDocEx.SummSymbolNumber;
end;

function ToleMain.Get_TextFont: Integer;
begin
  Result := FRegSlipDocEx.TextFont;
end;

function ToleMain.Get_TextOffset: Integer;
begin
  Result := FRegSlipDocEx.TextOffset;
end;

function ToleMain.Get_TextStringNumber: Integer;
begin
  Result := FRegSlipDocEx.TextStringNumber;
end;

function ToleMain.Get_TextSymbolNumber: Integer;
begin
  Result := FRegSlipDocEx.TextSymbolNumber;
end;

procedure ToleMain.Set_NumberOfCopies(Value: Integer);
begin
  FOpenSlipDocArg.CopyCount := Value;
end;

procedure ToleMain.Set_CopyOffset1(Value: Integer);
begin
  FOpenSlipDocArg.CopyOffset1 := Value
end;

procedure ToleMain.Set_CopyOffset2(Value: Integer);
begin
  FOpenSlipDocArg.CopyOffset2 := Value;
end;

procedure ToleMain.Set_CopyOffset3(Value: Integer);
begin
  FOpenSlipDocArg.CopyOffset3 := Value;
end;

procedure ToleMain.Set_CopyOffset4(Value: Integer);
begin
  FOpenSlipDocArg.CopyOffset4 := Value;
end;

procedure ToleMain.Set_CopyOffset5(Value: Integer);
begin
  FOpenSlipDocArg.CopyOffset5 := Value;
end;

procedure ToleMain.Set_CopyType(Value: Integer);
begin
  FOpenSlipDocArg.CopyType := Value;
end;

procedure ToleMain.Set_DepartmentFont(Value: Integer);
begin
  FRegSlipDocEx.DepartmentFont := Value;
end;

procedure ToleMain.Set_DepartmentOffset(Value: Integer);
begin
  FRegSlipDocEx.DepartmentOffset := Value;
end;

procedure ToleMain.Set_DepartmentStringNumber(Value: Integer);
begin
  FRegSlipDocEx.DepartmentStringNumber := Value;
end;

procedure ToleMain.Set_DepartmentSymbolNumber(Value: Integer);
begin
  FRegSlipDocEx.DepartmentSymbolNumber := Value;
end;

procedure ToleMain.Set_EKLZFont(Value: Integer);
begin
  FOpenSlipDocArgEx.EKLZFont := Value;
end;

procedure ToleMain.Set_EKLZOffset(Value: Integer);
begin
  FOpenSlipDocArgEx.EKLZOffset := Value;
end;

procedure ToleMain.Set_EKLZStringNumber(Value: Integer);
begin
  FOpenSlipDocArgEx.EKLZStringNumber := Value;
end;

procedure ToleMain.Set_OperationBlockFirstString(Value: Integer);
begin
  FOperationBlockFirstString  := Value;
end;

procedure ToleMain.Set_FMOffset(Value: Integer);
begin
  FOpenSlipDocArgEx.FMOffset := Value;
end;

procedure ToleMain.Set_FMStringNumber(Value: Integer);
begin
  FOpenSlipDocArgEx.FMStringNumber := Value;
end;

procedure ToleMain.Set_HeaderFont(Value: Integer);
begin
  FOpenSlipDocArgEx.HeaderFont := Value;
end;

procedure ToleMain.Set_HeaderOffset(Value: Integer);
begin
  FOpenSlipDocArgEx.HeaderOffset := Value;
end;

procedure ToleMain.Set_HeaderStringNumber(Value: Integer);
begin
  FOpenSlipDocArgEx.HeaderStringNumber := Value;
end;

procedure ToleMain.Set_ClicheFont(Value: Integer);
begin
  FOpenSlipDocArgEx.KlicheFont := Value
end;

procedure ToleMain.Set_ClicheOffset(Value: Integer);
begin
  FOpenSlipDocArgEx.KlicheOffset := Value
end;

procedure ToleMain.Set_ClicheStringNumber(Value: Integer);
begin
  FOpenSlipDocArgEx.KlicheStringNumber := Value
end;

procedure ToleMain.Set_KPKOffset(Value: Integer);
begin
  FOpenSlipDocArgEx.KPKOffset := Value
end;

procedure ToleMain.Set_MultiplicationFont(Value: Integer);
begin
  FRegSlipDocEx.MultiplicationFont := Value
end;

procedure ToleMain.Set_PriceFont(Value: Integer);
begin
  FRegSlipDocEx.PriceFont := Value
end;

procedure ToleMain.Set_PriceSymbolNumber(Value: Integer);
begin
  FRegSlipDocEx.PriceSymbolNumber := Value
end;

procedure ToleMain.Set_QuantityFont(Value: Integer);
begin
  FRegSlipDocEx.QuantityFont := Value
end;

procedure ToleMain.Set_QuantityFormat(Value: Integer);
begin
  FRegSlipDocEx.QuantityFormat := Value
end;

procedure ToleMain.Set_QuantityOffset(Value: Integer);
begin
  FRegSlipDocEx.QuantityOffset := Value
end;

procedure ToleMain.Set_QuantityStringNumber(Value: Integer);
begin
  FRegSlipDocEx.QuantityStringNumber := Value
end;

procedure ToleMain.Set_QuantitySymbolNumber(Value: Integer);
begin
  FRegSlipDocEx.QuantitySymbolNumber := Value
end;

procedure ToleMain.Set_StringQuantityInOperation(Value: Integer);
begin
  FRegSlipDocEx.StringCountInOperation := Value;
  FDiscountChargeEx.StringQuantityInOperation := Value;
  FCloseCheckEx.StringQuantityInOperation := Value;
end;

procedure ToleMain.Set_SummFont(Value: Integer);
begin
  FRegSlipDocEx.SummFont := Value;
  FDiscountChargeEx.SummFont := Value;
end;

procedure ToleMain.Set_SummOffset(Value: Integer);
begin
  FRegSlipDocEx.SummOffset := Value;
  FDiscountChargeEx.SummOffset := Value;
end;

procedure ToleMain.Set_SummStringNumber(Value: Integer);
begin
  FRegSlipDocEx.SummStringNumber := Value;
  FDiscountChargeEx.SummStringNumber := Value;
end;

procedure ToleMain.Set_SummSymbolNumber(Value: Integer);
begin
  FRegSlipDocEx.SummSymbolNumber := Value;
  FDiscountChargeEx.SummSymbolNumber := Value;
end;

procedure ToleMain.Set_TextFont(Value: Integer);
begin
  FRegSlipDocEx.TextFont := Value;
  FDiscountChargeEx.TextFont := Value;
  FCloseCheckEx.TextFont := Value;
end;

procedure ToleMain.Set_TextOffset(Value: Integer);
begin
  FRegSlipDocEx.TextOffset := Value;
  FDiscountChargeEx.TextOffset := Value;
  FCloseCheckEx.TextOffset := Value;
end;

procedure ToleMain.Set_TextStringNumber(Value: Integer);
begin
  FRegSlipDocEx.TextStringNumber := Value;
  FDiscountChargeEx.TextStringNumber := Value;
  FCloseCheckEx.TextStringNumber := Value;
end;

procedure ToleMain.Set_TextSymbolNumber(Value: Integer);
begin
  FRegSlipDocEx.TextSymbolNumber := Value;
  FDiscountChargeEx.TextSymbolNumber := Value;
  FCloseCheckEx.TextSymbolNumber := Value;
end;

// Формирование скидки/надбавки на подкладном документе

function ToleMain.DiscountOnSlipDocument: Integer;
var
  Data: string;
begin
  try
    Data :=
      #$74 +
      FPassw +
      DiscountChargeExToStr(FDiscountChargeEx)+
      #$00 +
      Chr(GetOperationBlockFirstString) +
      GetSumm1 +
      Chr(GetTax1) +
      Chr(GetTax2) +
      Chr(GetTax3) +
      Chr(GetTax4) +
      GetStr(FString, 40, 28);
    Result := Send(Data);
  except
    on E: Exception do Result := HandleException(E);
  end;
end;

// Формирование стандартной скидки/надбавки на подкладном документе

function ToleMain.StandardDiscountOnSlipDocument: Integer;
var
  Data: string;
begin
  try
    Data :=
      #$75 +
      FPassw +
      #$00 +
      Chr(GetOperationBlockFirstString) +
      GetSumm1 +
      Chr(GetTax1) +
      Chr(GetTax2) +
      Chr(GetTax3) +
      Chr(GetTax4) +
      GetStr(FString, 40, 16);
    Result := Send(Data);
  except
    on E: Exception do Result := HandleException(E);
  end;
end;

function ToleMain.Get_IsClearUnfiscalInfo: WordBool;
begin
  Result := FIsClearUnfiskalInfo;
end;

procedure ToleMain.Set_IsClearUnfiscalInfo(Value: WordBool);
begin
  FIsClearUnfiskalInfo := Value
end;

function ToleMain.Get_InfoType: Integer;
begin
  Result := FInfoType;
end;

procedure ToleMain.Set_InfoType(Value: Integer);
begin
  FInfoType := Value;
end;

function ToleMain.Get_StringNumber: Integer;
begin
  Result := FStringNumber;
end;

procedure ToleMain.Set_StringNumber(Value: Integer);
begin
  FStringNumber := Value;
end;

// Выброс подкладного документа

function ToleMain.EjectSlipDocument: Integer;
begin
  if (FPushDirection in [0..255]) then
    Result := Send(#$2A + FPassw + Chr(FPushDirection))
  else
    Result := InvalidParam;
end;

function ToleMain.Get_EjectDirection: Integer;
begin
  Result := FPushDirection;
end;

procedure ToleMain.Set_EjectDirection(Value: Integer);
begin
  FPushDirection := Value;
end;

function ToleMain.DrawEx: Integer;
var
  Data: string;
begin
  if (FFirstLineNumber >= 0)and(FFirstLineNumber <= $FFFF)and
    (FLastLineNumber >= 0)and(FLastLineNumber <= $FFFF) then
  begin
    Data :=
      #$C3 +
      FPassw +
      WordToStr(FFirstLineNumber) +
      WordToStr(FLastLineNumber);
    Result := Send(Data);
  end else
    Result := InvalidParam;
end;

function ToleMain.LoadLineDataEx: Integer;
var
  Data: string;
begin
  try
    Data :=
      #$C4 +
      FPassw +
      WordToStr(GetLineNumber) +
      GetStr2(FLineData, 40);
    Result := Send(Data);
  except
    on E: Exception do Result := HandleException(E);
  end;
end;

function ToleMain.Connect2: Integer;
begin
  try
    OpenPort;
    Result := ClearResult;
  except
    on E: Exception do Result := HandleException(E);
  end;
end;

// Общая конфигурация подкладного документа

function ToleMain.ConfigureGeneralSlipDocument: Integer;
var
  Data: string;
begin
  try
    if
      (FSlipEqualStringIntervals in [0..255]) then
    begin
      Data :=
        #$7E +
        FPassw +
        WordTostr(GetSlipWidth) +
        WordTostr(GetSlipLength) +
        Chr(GetPrintingAlignment) +
        Chr(FSlipEqualStringIntervals);
      Result := Send(Data);
    end else
      Result := InvalidParam;
  except
    on E: Exception do Result := HandleException(E);
  end;

end;

function ToleMain.Get_ChangeFont: Integer;
begin
  Result := FCloseCheckEx.ChangeFont;
end;

function ToleMain.Get_ChangeStringNumber: Integer;
begin
  Result := FCloseCheckEx.ChangeStringNumber
end;

function ToleMain.Get_ChangeSumFont: Integer;
begin
  Result := FCloseCheckEx.ChangeSumFont
end;

function ToleMain.Get_ChangeSymbolNumber: Integer;
begin
  Result := FCloseCheckEx.ChangeSymbolNumber
end;

function ToleMain.Get_DiscountOnCheckFont: Integer;
begin
  Result := FCloseCheckEx.DiscountOnCheckFont
end;

function ToleMain.Get_DiscountOnCheckStringNumber: Integer;
begin
  Result := FCloseCheckEx.DiscountOnCheckStringNumber
end;

function ToleMain.Get_DiscountOnCheckSumFont: Integer;
begin
  Result := FCloseCheckEx.DiscountOnCheckSumFont
end;

function ToleMain.Get_DiscountOnCheckSumSymbolNumber: Integer;
begin
  Result := FCloseCheckEx.DiscountOnCheckSumSymbolNumber
end;

function ToleMain.Get_DiscountOnCheckSymbolNumber: Integer;
begin
  Result := FCloseCheckEx.DiscountOnCheckSymbolNumber
end;

function ToleMain.Get_OperationNameFont: Integer;
begin
  Result := FDiscountChargeEx.OperationNameFont;
end;

function ToleMain.Get_OperationNameOffset: Integer;
begin
  Result := FDiscountChargeEx.OperationNameOffset
end;

function ToleMain.Get_OperationNameStringNumber: Integer;
begin
  Result := FDiscountChargeEx.OperationNameStringNumber
end;

function ToleMain.Get_SubTotalFont: Integer;
begin
  Result := FCloseCheckEx.SubTotalFont
end;

function ToleMain.Get_SubTotalStringNumber: Integer;
begin
  Result := FCloseCheckEx.SubTotalStringNumber
end;

function ToleMain.Get_SubTotalSumFont: Integer;
begin
  Result := FCloseCheckEx.SubTotalSumFont
end;

function ToleMain.Get_SubTotalSymbolNumber: Integer;
begin
  Result := FCloseCheckEx.SubTotalSymbolNumber
end;

function ToleMain.Get_Summ1Font: Integer;
begin
  Result := FCloseCheckEx.Summ1Font
end;

function ToleMain.Get_Summ1NameFont: Integer;
begin
  Result := FCloseCheckEx.Summ1NameFont
end;

function ToleMain.Get_Summ1Offset: Integer;
begin
  Result := FCloseCheckEx.Summ1Offset
end;

function ToleMain.Get_Summ1StringNumber: Integer;
begin
  Result := FCloseCheckEx.Summ1StringNumber
end;

function ToleMain.Get_Summ1SymbolNumber: Integer;
begin
  Result := FCloseCheckEx.Summ1SymbolNumber
end;

function ToleMain.Get_Summ2Font: Integer;
begin
  Result := FCloseCheckEx.Summ2Font
end;

function ToleMain.Get_Summ2NameFont: Integer;
begin
  Result := FCloseCheckEx.Summ2NameFont
end;

function ToleMain.Get_Summ2StringNumber: Integer;
begin
  Result := FCloseCheckEx.Summ2StringNumber
end;

function ToleMain.Get_Summ2SymbolNumber: Integer;
begin
  Result := FCloseCheckEx.Summ2SymbolNumber
end;

function ToleMain.Get_Summ3Font: Integer;
begin
  Result := FCloseCheckEx.Summ3Font
end;

function ToleMain.Get_Summ3NameFont: Integer;
begin
  Result := FCloseCheckEx.Summ3NameFont
end;

function ToleMain.Get_Summ3StringNumber: Integer;
begin
  Result := FCloseCheckEx.Summ3StringNumber
end;

function ToleMain.Get_Summ3SymbolNumber: Integer;
begin
  Result := FCloseCheckEx.Summ3SymbolNumber
end;

function ToleMain.Get_Summ4Font: Integer;
begin
  Result := FCloseCheckEx.Summ4Font
end;

function ToleMain.Get_Summ4NameFont: Integer;
begin
  Result := FCloseCheckEx.Summ4NameFont
end;

function ToleMain.Get_Summ4StringNumber: Integer;
begin
  Result := FCloseCheckEx.Summ4StringNumber
end;

function ToleMain.Get_Summ4SymbolNumber: Integer;
begin
  Result := FCloseCheckEx.Summ4SymbolNumber
end;

function ToleMain.Get_Tax1NameFont: Integer;
begin
  Result := FCloseCheckEx.Tax1NameFont
end;

function ToleMain.Get_Tax1NameSymbolNumber: Integer;
begin
  Result := FCloseCheckEx.Tax1NameSymbolNumber
end;

function ToleMain.Get_Tax1RateFont: Integer;
begin
  Result := FCloseCheckEx.Tax1RateFont
end;

function ToleMain.Get_Tax1RateSymbolNumber: Integer;
begin
  Result := FCloseCheckEx.Tax1RateSymbolNumber
end;

function ToleMain.Get_Tax1SumFont: Integer;
begin
  Result := FCloseCheckEx.Tax1SumFont
end;

function ToleMain.Get_Tax1SumStringNumber: Integer;
begin
  Result := FCloseCheckEx.Tax1SumStringNumber
end;

function ToleMain.Get_Tax1SumSymbolNumber: Integer;
begin
  Result := FCloseCheckEx.Tax1SumSymbolNumber
end;

function ToleMain.Get_Tax1TurnOverFont: Integer;
begin
  Result := FCloseCheckEx.Tax1TurnOverFont
end;

function ToleMain.Get_Tax1TurnOverStringNumber: Integer;
begin
  Result := FCloseCheckEx.Tax1TurnOverStringNumber
end;

function ToleMain.Get_Tax1TurnOverSymbolNumber: Integer;
begin
  Result := FCloseCheckEx.Tax1TurnOverSymbolNumber
end;

function ToleMain.Get_Tax2NameFont: Integer;
begin
  Result := FCloseCheckEx.Tax2NameFont
end;

function ToleMain.Get_Tax2NameSymbolNumber: Integer;
begin
  Result := FCloseCheckEx.Tax2NameSymbolNumber
end;

function ToleMain.Get_Tax2RateFont: Integer;
begin
  Result := FCloseCheckEx.Tax2RateFont
end;

function ToleMain.Get_Tax2RateSymbolNumber: Integer;
begin
  Result := FCloseCheckEx.Tax2RateSymbolNumber
end;

function ToleMain.Get_Tax2SumFont: Integer;
begin
  Result := FCloseCheckEx.Tax2SumFont
end;

function ToleMain.Get_Tax2SumStringNumber: Integer;
begin
  Result := FCloseCheckEx.Tax2SumStringNumber
end;

function ToleMain.Get_Tax2SumSymbolNumber: Integer;
begin
  Result := FCloseCheckEx.Tax2SumSymbolNumber
end;

function ToleMain.Get_Tax2TurnOverFont: Integer;
begin
  Result := FCloseCheckEx.Tax2TurnOverFont
end;

function ToleMain.Get_Tax2TurnOverStringNumber: Integer;
begin
  Result := FCloseCheckEx.Tax2TurnOverStringNumber
end;

function ToleMain.Get_Tax2TurnOverSymbolNumber: Integer;
begin
  Result := FCloseCheckEx.Tax2TurnOverSymbolNumber
end;

function ToleMain.Get_Tax3NameFont: Integer;
begin
  Result := FCloseCheckEx.Tax3NameFont
end;

function ToleMain.Get_Tax3NameSymbolNumber: Integer;
begin
  Result := FCloseCheckEx.Tax3NameSymbolNumber
end;

function ToleMain.Get_Tax3RateFont: Integer;
begin
  Result := FCloseCheckEx.Tax3RateFont
end;

function ToleMain.Get_Tax3RateSymbolNumber: Integer;
begin
  Result := FCloseCheckEx.Tax3RateSymbolNumber
end;

function ToleMain.Get_Tax3SumFont: Integer;
begin
  Result := FCloseCheckEx.Tax3SumFont
end;

function ToleMain.Get_Tax3SumStringNumber: Integer;
begin
  Result := FCloseCheckEx.Tax3SumStringNumber
end;

function ToleMain.Get_Tax3SumSymbolNumber: Integer;
begin
  Result := FCloseCheckEx.Tax3SumSymbolNumber
end;

function ToleMain.Get_Tax3TurnOverFont: Integer;
begin
  Result := FCloseCheckEx.Tax3TurnOverFont
end;

function ToleMain.Get_Tax3TurnOverStringNumber: Integer;
begin
  Result := FCloseCheckEx.Tax3TurnOverStringNumber
end;

function ToleMain.Get_Tax3TurnOverSymbolNumber: Integer;
begin
  Result := FCloseCheckEx.Tax3TurnOverSymbolNumber
end;

function ToleMain.Get_Tax4NameFont: Integer;
begin
  Result := FCloseCheckEx.Tax4NameFont;
end;

function ToleMain.Get_Tax4NameSymbolNumber: Integer;
begin
  Result := FCloseCheckEx.Tax4NameSymbolNumber
end;

function ToleMain.Get_Tax4RateFont: Integer;
begin
  Result := FCloseCheckEx.Tax4RateFont
end;

function ToleMain.Get_Tax4RateSymbolNumber: Integer;
begin
  Result := FCloseCheckEx.Tax4RateSymbolNumber
end;

function ToleMain.Get_Tax4SumFont: Integer;
begin
  Result := FCloseCheckEx.Tax4SumFont
end;

function ToleMain.Get_Tax4SumStringNumber: Integer;
begin
  Result := FCloseCheckEx.Tax4SumStringNumber
end;

function ToleMain.Get_Tax4SumSymbolNumber: Integer;
begin
  Result := FCloseCheckEx.Tax4SumSymbolNumber
end;

function ToleMain.Get_Tax4TurnOverFont: Integer;
begin
  Result := FCloseCheckEx.Tax4TurnOverFont
end;

function ToleMain.Get_Tax4TurnOverStringNumber: Integer;
begin
  Result := FCloseCheckEx.Tax4TurnOverStringNumber
end;

function ToleMain.Get_Tax4TurnOverSymbolNumber: Integer;
begin
  Result := FCloseCheckEx.Tax4TurnOverSymbolNumber
end;

function ToleMain.Get_TotalFont: Integer;
begin
  Result := FCloseCheckEx.TotalFont
end;

function ToleMain.Get_TotalOffset: Integer;
begin
  Result := FCloseCheckEx.TotalOffset
end;

function ToleMain.Get_TotalStringNumber: Integer;
begin
  Result := FCloseCheckEx.TotalStringNumber
end;

function ToleMain.Get_TotalSumFont: Integer;
begin
  Result := FCloseCheckEx.TotalSumFont
end;

function ToleMain.Get_TotalSumOffset: Integer;
begin
  Result := FCloseCheckEx.TotalSumOffset
end;

function ToleMain.Get_TotalSymbolNumber: Integer;
begin
  Result := FCloseCheckEx.TotalSymbolNumber
end;

procedure ToleMain.Set_ChangeFont(Value: Integer);
begin
  FCloseCheckEx.ChangeFont := Value;
end;

procedure ToleMain.Set_ChangeStringNumber(Value: Integer);
begin
  FCloseCheckEx.ChangeStringNumber := Value;
end;

procedure ToleMain.Set_ChangeSumFont(Value: Integer);
begin
  FCloseCheckEx.ChangeSumFont := Value;
end;

procedure ToleMain.Set_ChangeSymbolNumber(Value: Integer);
begin
  FCloseCheckEx.ChangeSymbolNumber := Value;
end;

procedure ToleMain.Set_DiscountOnCheckFont(Value: Integer);
begin
  FCloseCheckEx.DiscountOnCheckFont := Value;
end;

procedure ToleMain.Set_DiscountOnCheckStringNumber(Value: Integer);
begin
  FCloseCheckEx.DiscountOnCheckStringNumber := Value;
end;

procedure ToleMain.Set_DiscountOnCheckSumFont(Value: Integer);
begin
  FCloseCheckEx.DiscountOnCheckSumFont := Value;
end;

procedure ToleMain.Set_DiscountOnCheckSumSymbolNumber(Value: Integer);
begin
  FCloseCheckEx.DiscountOnCheckSumSymbolNumber := Value;
end;

procedure ToleMain.Set_DiscountOnCheckSymbolNumber(Value: Integer);
begin
  FCloseCheckEx.DiscountOnCheckSymbolNumber := Value;
end;

procedure ToleMain.Set_OperationNameFont(Value: Integer);
begin
  FDiscountChargeEx.OperationNameFont := Value;
end;

procedure ToleMain.Set_OperationNameOffset(Value: Integer);
begin
  FDiscountChargeEx.OperationNameOffset := Value;
end;

procedure ToleMain.Set_OperationNameStringNumber(Value: Integer);
begin
  FDiscountChargeEx.OperationNameStringNumber := Value;
end;

procedure ToleMain.Set_SubTotalFont(Value: Integer);
begin
  FCloseCheckEx.SubTotalFont := Value;
end;

procedure ToleMain.Set_SubTotalStringNumber(Value: Integer);
begin
  FCloseCheckEx.SubTotalStringNumber := Value;
end;

procedure ToleMain.Set_SubTotalSumFont(Value: Integer);
begin
  FCloseCheckEx.SubTotalSumFont := Value;
end;

procedure ToleMain.Set_SubTotalSymbolNumber(Value: Integer);
begin
  FCloseCheckEx.SubTotalSymbolNumber := Value;
end;

procedure ToleMain.Set_Summ1Font(Value: Integer);
begin
  FCloseCheckEx.Summ1Font := Value;
end;

procedure ToleMain.Set_Summ1NameFont(Value: Integer);
begin
  FCloseCheckEx.Summ1NameFont := Value;
end;

procedure ToleMain.Set_Summ1Offset(Value: Integer);
begin
  FCloseCheckEx.Summ1Offset := Value;
end;

procedure ToleMain.Set_Summ1StringNumber(Value: Integer);
begin
  FCloseCheckEx.Summ1StringNumber := Value;
end;

procedure ToleMain.Set_Summ1SymbolNumber(Value: Integer);
begin
  FCloseCheckEx.Summ1SymbolNumber := Value;
end;

procedure ToleMain.Set_Summ2Font(Value: Integer);
begin
  FCloseCheckEx.Summ2Font := Value;
end;

procedure ToleMain.Set_Summ2NameFont(Value: Integer);
begin
  FCloseCheckEx.Summ2NameFont := Value;
end;

procedure ToleMain.Set_Summ2StringNumber(Value: Integer);
begin
  FCloseCheckEx.Summ2StringNumber := Value;
end;

procedure ToleMain.Set_Summ2SymbolNumber(Value: Integer);
begin
  FCloseCheckEx.Summ2SymbolNumber := Value;
end;

procedure ToleMain.Set_Summ3Font(Value: Integer);
begin
  FCloseCheckEx.Summ3Font := Value;
end;

procedure ToleMain.Set_Summ3NameFont(Value: Integer);
begin
  FCloseCheckEx.Summ3NameFont := Value;
end;

procedure ToleMain.Set_Summ3StringNumber(Value: Integer);
begin
  FCloseCheckEx.Summ3StringNumber := Value;
end;

procedure ToleMain.Set_Summ3SymbolNumber(Value: Integer);
begin
  FCloseCheckEx.Summ3SymbolNumber := Value;
end;

procedure ToleMain.Set_Summ4Font(Value: Integer);
begin
  FCloseCheckEx.Summ4Font := Value;
end;

procedure ToleMain.Set_Summ4NameFont(Value: Integer);
begin
  FCloseCheckEx.Summ4NameFont := Value;
end;

procedure ToleMain.Set_Summ4StringNumber(Value: Integer);
begin
  FCloseCheckEx.Summ4StringNumber := Value;
end;

procedure ToleMain.Set_Summ4SymbolNumber(Value: Integer);
begin
  FCloseCheckEx.Summ4SymbolNumber := Value;
end;

procedure ToleMain.Set_Tax1NameFont(Value: Integer);
begin
  FCloseCheckEx.Tax1NameFont := Value;
end;

procedure ToleMain.Set_Tax1NameSymbolNumber(Value: Integer);
begin
  FCloseCheckEx.Tax1NameSymbolNumber := Value;
end;

procedure ToleMain.Set_Tax1RateFont(Value: Integer);
begin
  FCloseCheckEx.Tax1RateFont := Value;
end;

procedure ToleMain.Set_Tax1RateSymbolNumber(Value: Integer);
begin
  FCloseCheckEx.Tax1RateSymbolNumber := Value;
end;

procedure ToleMain.Set_Tax1SumFont(Value: Integer);
begin
  FCloseCheckEx.Tax1SumFont := Value;
end;

procedure ToleMain.Set_Tax1SumStringNumber(Value: Integer);
begin
  FCloseCheckEx.Tax1SumStringNumber := Value;
end;

procedure ToleMain.Set_Tax1SumSymbolNumber(Value: Integer);
begin
  FCloseCheckEx.Tax1SumSymbolNumber := Value;
end;

procedure ToleMain.Set_Tax1TurnOverFont(Value: Integer);
begin
  FCloseCheckEx.Tax1TurnOverFont := Value;
end;

procedure ToleMain.Set_Tax1TurnOverStringNumber(Value: Integer);
begin
  FCloseCheckEx.Tax1TurnOverStringNumber := Value;
end;

procedure ToleMain.Set_Tax1TurnOverSymbolNumber(Value: Integer);
begin
  FCloseCheckEx.Tax1TurnOverSymbolNumber := Value;
end;

procedure ToleMain.Set_Tax2NameFont(Value: Integer);
begin
  FCloseCheckEx.Tax2NameFont := Value;
end;

procedure ToleMain.Set_Tax2NameSymbolNumber(Value: Integer);
begin
  FCloseCheckEx.Tax2NameSymbolNumber := Value;
end;

procedure ToleMain.Set_Tax2RateFont(Value: Integer);
begin
  FCloseCheckEx.Tax2RateFont := Value;
end;

procedure ToleMain.Set_Tax2RateSymbolNumber(Value: Integer);
begin
  FCloseCheckEx.Tax2RateSymbolNumber := Value;
end;

procedure ToleMain.Set_Tax2SumFont(Value: Integer);
begin
  FCloseCheckEx.Tax2SumFont := Value;
end;

procedure ToleMain.Set_Tax2SumStringNumber(Value: Integer);
begin
  FCloseCheckEx.Tax2SumStringNumber := Value;
end;

procedure ToleMain.Set_Tax2SumSymbolNumber(Value: Integer);
begin
  FCloseCheckEx.Tax2SumSymbolNumber := Value;
end;

procedure ToleMain.Set_Tax2TurnOverFont(Value: Integer);
begin
  FCloseCheckEx.Tax2TurnOverFont := Value;
end;

procedure ToleMain.Set_Tax2TurnOverStringNumber(Value: Integer);
begin
  FCloseCheckEx.Tax2TurnOverStringNumber := Value;
end;

procedure ToleMain.Set_Tax2TurnOverSymbolNumber(Value: Integer);
begin
  FCloseCheckEx.Tax2TurnOverSymbolNumber := Value;
end;

procedure ToleMain.Set_Tax3NameFont(Value: Integer);
begin
  FCloseCheckEx.Tax3NameFont := Value;
end;

procedure ToleMain.Set_Tax3NameSymbolNumber(Value: Integer);
begin
  FCloseCheckEx.Tax3NameSymbolNumber := Value;
end;

procedure ToleMain.Set_Tax3RateFont(Value: Integer);
begin
  FCloseCheckEx.Tax3RateFont := Value;
end;

procedure ToleMain.Set_Tax3RateSymbolNumber(Value: Integer);
begin
  FCloseCheckEx.Tax3RateSymbolNumber := Value;
end;

procedure ToleMain.Set_Tax3SumFont(Value: Integer);
begin
  FCloseCheckEx.Tax3SumFont := Value;
end;

procedure ToleMain.Set_Tax3SumStringNumber(Value: Integer);
begin
  FCloseCheckEx.Tax3SumStringNumber := Value;
end;

procedure ToleMain.Set_Tax3SumSymbolNumber(Value: Integer);
begin
  FCloseCheckEx.Tax3SumSymbolNumber := Value;
end;

procedure ToleMain.Set_Tax3TurnOverFont(Value: Integer);
begin
  FCloseCheckEx.Tax3TurnOverFont := Value;
end;

procedure ToleMain.Set_Tax3TurnOverStringNumber(Value: Integer);
begin
  FCloseCheckEx.Tax3TurnOverStringNumber := Value;
end;

procedure ToleMain.Set_Tax3TurnOverSymbolNumber(Value: Integer);
begin
  FCloseCheckEx.Tax3TurnOverSymbolNumber := Value;
end;

procedure ToleMain.Set_Tax4NameFont(Value: Integer);
begin
  FCloseCheckEx.Tax4NameFont := Value;
end;

procedure ToleMain.Set_Tax4NameSymbolNumber(Value: Integer);
begin
  FCloseCheckEx.Tax4NameSymbolNumber := Value;
end;

procedure ToleMain.Set_Tax4RateFont(Value: Integer);
begin
  FCloseCheckEx.Tax4RateFont := Value;
end;

procedure ToleMain.Set_Tax4RateSymbolNumber(Value: Integer);
begin
  FCloseCheckEx.Tax4RateSymbolNumber := Value;
end;

procedure ToleMain.Set_Tax4SumFont(Value: Integer);
begin
  FCloseCheckEx.Tax4SumFont := Value;
end;

procedure ToleMain.Set_Tax4SumStringNumber(Value: Integer);
begin
  FCloseCheckEx.Tax4SumStringNumber := Value;
end;

procedure ToleMain.Set_Tax4SumSymbolNumber(Value: Integer);
begin
  FCloseCheckEx.Tax4SumSymbolNumber := Value;
end;

procedure ToleMain.Set_Tax4TurnOverFont(Value: Integer);
begin
  FCloseCheckEx.Tax4TurnOverFont := Value;
end;

procedure ToleMain.Set_Tax4TurnOverStringNumber(Value: Integer);
begin
  FCloseCheckEx.Tax4TurnOverStringNumber := Value;
end;

procedure ToleMain.Set_Tax4TurnOverSymbolNumber(Value: Integer);
begin
  FCloseCheckEx.Tax4TurnOverSymbolNumber := Value;
end;

procedure ToleMain.Set_TotalFont(Value: Integer);
begin
  FCloseCheckEx.TotalFont := Value;
end;

procedure ToleMain.Set_TotalOffset(Value: Integer);
begin
  FCloseCheckEx.TotalOffset := Value;
end;

procedure ToleMain.Set_TotalStringNumber(Value: Integer);
begin
  FCloseCheckEx.TotalStringNumber := Value;
end;

procedure ToleMain.Set_TotalSumFont(Value: Integer);
begin
  FCloseCheckEx.TotalSumFont := Value;
end;

procedure ToleMain.Set_TotalSumOffset(Value: Integer);
begin
  FCloseCheckEx.TotalSumOffset := Value;
end;

procedure ToleMain.Set_TotalSymbolNumber(Value: Integer);
begin
  FCloseCheckEx.TotalSymbolNumber := Value;
end;

function ToleMain.Get_ChangeOffset: Integer;
begin
  Result := FCloseCheckEx.ChangeOffset;
end;

function ToleMain.Get_ChangeSumOffset: Integer;
begin
  Result := FCloseCheckEx.ChangeSumOffset;
end;

function ToleMain.Get_Summ1NameOffset: Integer;
begin
  Result := FCloseCheckEx.Summ1NameOffset;
end;

function ToleMain.Get_Summ2NameOffset: Integer;
begin
  Result := FCloseCheckEx.Summ2NameOffset;
end;

function ToleMain.Get_Summ2Offset: Integer;
begin
  Result := FCloseCheckEx.Summ2Offset;
end;

function ToleMain.Get_Summ3NameOffset: Integer;
begin
  Result := FCloseCheckEx.Summ3NameOffset;
end;

function ToleMain.Get_Summ3Offset: Integer;
begin
  Result := FCloseCheckEx.Summ3Offset;
end;

function ToleMain.Get_Summ4NameOffset: Integer;
begin
  Result := FCloseCheckEx.Summ4NameOffset;
end;

function ToleMain.Get_Summ4Offset: Integer;
begin
  Result := FCloseCheckEx.Summ4Offset;
end;

function ToleMain.Get_Tax1NameOffset: Integer;
begin
  Result := FCloseCheckEx.Tax1NameOffset;
end;

function ToleMain.Get_Tax1RateOffset: Integer;
begin
  Result := FCloseCheckEx.Tax1RateOffset;
end;

function ToleMain.Get_Tax1SumOffset: Integer;
begin
  Result := FCloseCheckEx.Tax1SumOffset;
end;

function ToleMain.Get_Tax1TurnOverOffset: Integer;
begin
  Result := FCloseCheckEx.Tax1TurnOverOffset;
end;

function ToleMain.Get_Tax2NameOffset: Integer;
begin
  Result := FCloseCheckEx.Tax2NameOffset;
end;

function ToleMain.Get_Tax2TurnOverOffset: Integer;
begin
  Result := FCloseCheckEx.Tax2TurnOverOffset;
end;

procedure ToleMain.Set_ChangeOffset(Value: Integer);
begin
  FCloseCheckEx.ChangeOffset := Value;
end;

procedure ToleMain.Set_ChangeSumOffset(Value: Integer);
begin
  FCloseCheckEx.ChangeSumOffset := Value;
end;

procedure ToleMain.Set_Summ1NameOffset(Value: Integer);
begin
  FCloseCheckEx.Summ1NameOffset := Value;
end;

procedure ToleMain.Set_Summ2NameOffset(Value: Integer);
begin
  FCloseCheckEx.Summ2NameOffset := Value;
end;

procedure ToleMain.Set_Summ2Offset(Value: Integer);
begin
  FCloseCheckEx.Summ2Offset := Value;
end;

procedure ToleMain.Set_Summ3NameOffset(Value: Integer);
begin
  FCloseCheckEx.Summ3NameOffset := Value;
end;

procedure ToleMain.Set_Summ3Offset(Value: Integer);
begin
  FCloseCheckEx.Summ3Offset := Value;
end;

procedure ToleMain.Set_Summ4NameOffset(Value: Integer);
begin
  FCloseCheckEx.Summ4NameOffset := Value;
end;

procedure ToleMain.Set_Summ4Offset(Value: Integer);
begin
  FCloseCheckEx.Summ4Offset := Value;
end;

procedure ToleMain.Set_Tax1NameOffset(Value: Integer);
begin
  FCloseCheckEx.Tax1NameOffset := Value;
end;

procedure ToleMain.Set_Tax1RateOffset(Value: Integer);
begin
  FCloseCheckEx.Tax1RateOffset := Value;
end;

procedure ToleMain.Set_Tax1SumOffset(Value: Integer);
begin
  FCloseCheckEx.Tax1SumOffset := Value;
end;

procedure ToleMain.Set_Tax1TurnOverOffset(Value: Integer);
begin
  FCloseCheckEx.Tax1TurnOverOffset := Value;
end;

procedure ToleMain.Set_Tax2NameOffset(Value: Integer);
begin
  FCloseCheckEx.Tax2NameOffset := Value;
end;

procedure ToleMain.Set_Tax2TurnOverOffset(Value: Integer);
begin
  FCloseCheckEx.Tax2TurnOverOffset := Value;
end;

function ToleMain.Get_SubTotalOffset: Integer;
begin
  Result := FCloseCheckEx.SubTotalOffset;
end;

function ToleMain.Get_SubTotalSumOffset: Integer;
begin
  Result := FCloseCheckEx.SubTotalSumOffset;
end;

function ToleMain.Get_Tax2RateOffset: Integer;
begin
  Result := FCloseCheckEx.Tax2RateOffset;
end;

function ToleMain.Get_Tax2SumOffset: Integer;
begin
  Result := FCloseCheckEx.Tax2SumOffset;
end;

function ToleMain.Get_Tax3NameOffset: Integer;
begin
  Result := FCloseCheckEx.Tax3NameOffset;
end;

function ToleMain.Get_Tax3RateOffset: Integer;
begin
  Result := FCloseCheckEx.Tax3RateOffset;
end;

function ToleMain.Get_Tax3SumOffset: Integer;
begin
  Result := FCloseCheckEx.Tax3SumOffset;
end;

function ToleMain.Get_Tax3TurnOverOffset: Integer;
begin
  Result := FCloseCheckEx.Tax3TurnOverOffset;
end;

function ToleMain.Get_Tax4NameOffset: Integer;
begin
  Result := FCloseCheckEx.Tax4NameOffset;
end;

function ToleMain.Get_Tax4RateOffset: Integer;
begin
  Result := FCloseCheckEx.Tax4RateOffset;
end;

function ToleMain.Get_Tax4SumOffset: Integer;
begin
  Result := FCloseCheckEx.Tax4SumOffset;
end;

function ToleMain.Get_Tax4TurnOverOffset: Integer;
begin
  Result := FCloseCheckEx.Tax4TurnOverOffset;
end;

procedure ToleMain.Set_SubTotalOffset(Value: Integer);
begin
  FCloseCheckEx.SubTotalOffset := Value;
end;

procedure ToleMain.Set_SubTotalSumOffset(Value: Integer);
begin
  FCloseCheckEx.SubTotalSumOffset := Value;
end;

procedure ToleMain.Set_Tax2RateOffset(Value: Integer);
begin
  FCloseCheckEx.Tax2RateOffset := Value;
end;

procedure ToleMain.Set_Tax2SumOffset(Value: Integer);
begin
  FCloseCheckEx.Tax2SumOffset := Value;
end;

procedure ToleMain.Set_Tax3NameOffset(Value: Integer);
begin
  FCloseCheckEx.Tax3NameOffset := Value;
end;

procedure ToleMain.Set_Tax3RateOffset(Value: Integer);
begin
  FCloseCheckEx.Tax3RateOffset := Value;
end;

procedure ToleMain.Set_Tax3SumOffset(Value: Integer);
begin
  FCloseCheckEx.Tax3SumOffset := Value;
end;

procedure ToleMain.Set_Tax3TurnOverOffset(Value: Integer);
begin
  FCloseCheckEx.Tax3TurnOverOffset := Value;
end;

procedure ToleMain.Set_Tax4NameOffset(Value: Integer);
begin
  FCloseCheckEx.Tax4NameOffset := Value;
end;

procedure ToleMain.Set_Tax4RateOffset(Value: Integer);
begin
  FCloseCheckEx.Tax4RateOffset := Value;
end;

procedure ToleMain.Set_Tax4SumOffset(Value: Integer);
begin
  FCloseCheckEx.Tax4SumOffset := Value;
end;

procedure ToleMain.Set_Tax4TurnOverOffset(Value: Integer);
begin
  FCloseCheckEx.Tax4TurnOverOffset := Value;
end;

function ToleMain.Get_PrintingAlignment: Integer;
begin
  Result := FPrintingAlignment;
end;

function ToleMain.Get_SlipDocumentLength: Integer;
begin
  Result := FSlipLength;
end;

function ToleMain.Get_SlipDocumentWidth: Integer;
begin
  Result := FSlipWidth;
end;

function ToleMain.Get_SlipEqualStringIntervals: Integer;
begin
  Result := FSlipEqualStringIntervals
end;

function ToleMain.Get_SlipStringIntervals: WideString;
var s: string;
    i: Integer;
begin
  s := '';
  for i := 1 to 199 do s := s+CHR(FSlipStringIntervals[i]);
  Result := s;
end;

procedure ToleMain.Set_PrintingAlignment(Value: Integer);
begin
  FPrintingAlignment := Value;
end;

procedure ToleMain.Set_SlipDocumentLength(Value: Integer);
begin
  FSlipLength := Value;
end;

procedure ToleMain.Set_SlipDocumentWidth(Value: Integer);
begin
  FSlipWidth := Value;
end;

procedure ToleMain.Set_SlipEqualStringIntervals(Value: Integer);
begin
  FSlipEqualStringIntervals := Value;
end;

procedure ToleMain.Set_SlipStringIntervals(const Value: WideString);
var s: string;
    i: Integer;
    maxlen: Integer;
begin
  s := VALUE;
  maxlen := min(199,length(s));
  For i := 1 to maxlen do FSlipStringIntervals[i] := Ord(s[i]);
  For i := maxlen+1 to 199 do FSlipStringIntervals[i] := 0;
end;

function ToleMain.Get_KPKFont: Integer;
begin
  Result := FOpenSlipDocArgEx.KPKFont;
end;

procedure ToleMain.Set_KPKFont(Value: Integer);
begin
  FOpenSlipDocArgEx.KPKFont := Value;
end;

function ToleMain.Get_DiscountOnCheckOffset: Integer;
begin
  Result := FCloseCheckEx.DiscountOnCheckOffset;
end;

function ToleMain.Get_DiscountOnCheckSumOffset: Integer;
begin
  Result := FCloseCheckEx.DiscountOnCheckSumOffset;
end;

procedure ToleMain.Set_DiscountOnCheckOffset(Value: Integer);
begin
  FCloseCheckEx.DiscountOnCheckOffset := Value;
end;

procedure ToleMain.Set_DiscountOnCheckSumOffset(Value: Integer);
begin
  FCloseCheckEx.DiscountOnCheckSumOffset := Value;
end;

function ToleMain.WideLoadLineData: Integer;
var
  i: Integer;
  Count: Integer;
  SaveLineNumber: Word;
  SaveLineData: string;
begin
  SaveLineData := FLineData;
  SaveLineNumber := FLineNumber;
  Count := (Length(SaveLineData) div 40) + 1;
  for i := 0 to Count-1 do
  begin
    Set_LineNumber(i + SaveLineNumber);
    Set_LineData(Copy(SaveLineData, i*40+1, 40));
    Result := LoadLineDataEx;
    if not DRV_SUCCESS(Result) then Break;
  end;
  FLineData := SaveLineData;
  FLineNumber := SaveLineNumber;
end;

// Отчёт по налогам

function ToleMain.PrintTaxReport: Integer;
begin
  Result := Send(#$43 + FPassw);
end;

function ToleMain.Get_QuantityPointPosition: WordBool;
begin
  Result := (FStatus.FlagsFR and $8000)=$8000;
end;

// Запрос длинного заводского номера и длинного РНМ

function ToleMain.GetLongSerialNumberAndLongRNM: Integer;
begin
  Result := Send(#$0F + FPassw);
end;

// Ввод длинного заводского номера

function ToleMain.SetLongSerialNumber: Integer;
var
  S: string;
  Value: Int64;
  Code: Integer;
begin
  Val(FSerialNumber, Value, Code);
  if Code = 0 then
  begin
    S := Int64ToStrLen(Value, 7);
    Result := Send(#$0E + FPassw + S);
  end else
    Result := InvalidParam;
end;

// Фискализация (перерегистрация) с длинным РНМ

function ToleMain.FiscalizationWithLongRNM: Integer;
var
  Data: string;
begin
  try
    Data :=
      #$0D +
      FPassw +
      DWORDToStr(FNewPasswordTI) +
      Int64ToStrLen(GetRNM, 7) +
      GetINN;

    Result := Send(Data);
  except
    on E: Exception do Result := HandleException(E);
  end;
end;

function ToleMain.Get_IsBatteryLow: WordBool;
begin
  Result := (FStatus.FlagsFP and 16)=16;
end;

function ToleMain.Get_IsFM24HoursOver: WordBool;
begin
  Result := (FStatus.FlagsFP and 128)=128;
end;

function ToleMain.Get_IsFMSessionOpen: WordBool;
begin
  Result := (FStatus.FlagsFP and 64)=64;
end;

function ToleMain.Get_IsLastFMRecordCorrupted: WordBool;
begin
  Result := (FStatus.FlagsFP and 32)=32;
end;

function ToleMain.Get_ECRModeStatus: Integer;
begin
  Result := FStatus.ModeFr shr 4;
end;

function ToleMain.Get_PrinterStatus: Integer;
begin
  Result := FPrinterStatus;
end;

function ToleMain.GetECRPrinterStatus: Integer;
begin
  Result := Send(#$F9 + FPassw);
end;

procedure ToleMain.DefinePropertyPages(
  DefinePropertyPage: TDefinePropertyPage);
begin
  DefinePropertyPage(Class_fmPage);
end;

function ToleMain.GetDevices: TDevices;
begin
  if FDevices = nil then
    FDevices := TDevices.Create;
  Result := FDevices;
end;

function ToleMain.AddLD: Integer;
begin
  MethodLog('AddLD');
  if Devices.AddLD then
    Result := ClearResult
  else
    Result := InvalidParam;
end;

procedure ToleMain.DeviceToParams(Device: TDevice);
begin
  FTimeout := Device.LDTimeout;
  FBaudRate := Device.LDBaudRate;
  FComNumber := Device.LDComNumber;
  FComputerName := Device.LDComputerName;
end;

function ToleMain.SetActiveLD: Integer;
var
  Device: TDevice;
begin
  MethodLog('SetActiveLD');
  Device := Devices.ItemByNumber(Devices.LDNumber);
  if Device <> nil then
  begin
    Disconnect;
    Devices.ActiveLDNumber := Devices.LDNumber;
    DeviceToParams(Device);
    Result := ClearResult;
  end else
  begin
    Result := InvalidParam;
  end;
end;

function ToleMain.DeleteLD: Integer;
begin
  if Devices.DeleteLD then
    Result := ClearResult
  else
    Result := InvalidParam;
end;

function ToleMain.EnumLD: Integer;
begin
  if Devices.EnumLD then
    Result := ClearResult
  else
    Result := InvalidParam;
end;

function ToleMain.GetActiveLD: Integer;
var
  Device: TDevice;
begin
  Device := Devices.ItemByNumber(Devices.ActiveLDNumber);
  if Device <> nil then
  begin
    Devices.LDNumber := Devices.ActiveLDNumber;
    Devices.LDIndex := Device.Index;
    Result := ClearResult;
  end else
  begin
    Result := InvalidParam;
  end;
end;

function ToleMain.GetCountLD: Integer;
begin
  Result := ClearResult;
end;

function ToleMain.GetParamLD: Integer;
begin
  if Devices.GetParamLD then
    Result := ClearResult
  else
    Result := InvalidParam;
end;

function ToleMain.SetParamLD: Integer;
begin
  if Devices.SetParamLD then
    Result := ClearResult
  else
    Result := InvalidParam;
end;

function ToleMain.ShowProperties: Integer;

  procedure CoFreeMem(P: Pointer);
  begin
    if P <> nil then CoTaskMemFree(P);
  end;

var
  Unknown: IUnknown;
  Pages: TCAGUID;
begin
  OleCheck(GetPages(Pages));
  try
    if Pages.cElems > 0 then
    begin
      Unknown := Self;
      OleCheck(OleCreatePropertyFrame(GetActiveWindow, 16, 16,
        nil,
        1, @Unknown, Pages.cElems, Pages.pElems,
        GetSystemDefaultLCID, 0, nil));
    end;
  finally
    CoFreeMem(pages.pElems);
  end;
end;

function ToleMain.Get_LDBaudrate: Integer;
begin
  Result := Devices.LDBaudRate;
end;

procedure ToleMain.Set_LDBaudrate(Value: Integer);
begin
  Devices.LDBaudRate := Value;
end;

function ToleMain.Get_LDComNumber: Integer;
begin
  Result := Devices.LDComNumber;
end;

function ToleMain.Get_LDCount: Integer;
begin
  Result := Devices.Count;
end;

function ToleMain.Get_LDIndex: Integer;
begin
  Result := Devices.LDIndex;
end;
                                       
function ToleMain.Get_LDName: WideString;
begin
  Result := Devices.LDName;
end;

function ToleMain.Get_LDNumber: Integer;
begin
  Result := Devices.LDNumber;
end;

procedure ToleMain.Set_LDComNumber(Value: Integer);
begin
  Devices.LDComNumber := Value;
end;

procedure ToleMain.Set_LDIndex(Value: Integer);
begin
  Devices.LDIndex := Value;
end;

procedure ToleMain.Set_LDName(const Value: WideString);
begin
  Devices.LDName := Value;
end;

procedure ToleMain.Set_LDNumber(Value: Integer);
begin
  Devices.LDNumber := Value;
end;

function ToleMain.Get_FileVersionLS: LongWord;
begin
  Result := FVInfo.MinorVersion;
end;

function ToleMain.Get_FileVersionMS: LongWord;
begin
  Result := FVInfo.MajorVersion;
end;

function ToleMain.Get_ServerVersion: WideString;
begin
  Result := GetServerVersion;
end;

function ToleMain.Get_LDComputerName: WideString;
begin
  Result := Devices.LDComputerName;
end;

procedure ToleMain.Set_LDComputerName(const Value: WideString);
begin
  Devices.LDComputerName := Value;
end;

function ToleMain.Get_LDTimeout: Integer;
begin
  Result := Devices.LDTimeout;
end;

procedure ToleMain.Set_LDTimeout(Value: Integer);
begin
  Devices.LDTimeout := Value;
end;

function ToleMain.Get_ComputerName: WideString;
begin
  Result := FComputerName;
end;

procedure ToleMain.Set_ComputerName(const Value: WideString);
begin
  if Value <> FComputerName then
  begin
    FComputerName := Value;
    FComputerNameChanged := True;
  end;
end;

function ToleMain.ServerConnect: Integer;
begin
  try
    // Отключаемся только если изменили имя компьютера
    if FComputerNameChanged then
    begin
      DoServerDisconnect;
    end;
    DoServerConnect;
    Result := ClearResult;
  except
    on E: Exception do
    begin
      DoServerDisconnect;
      Result := HandleException(E);
    end;
  end;
end;

function ToleMain.ServerDisconnect: Integer;
begin
  DoServerDisconnect;
  Result := ClearResult;
end;

function ToleMain.Get_ServerConnected: WordBool;
begin
  Result := HasDriver;
end;

function ToleMain.LockPort: Integer;
begin
  Result := ClearResult;
end;

function ToleMain.UnlockPort: Integer;
begin
  Result := ClearResult;
end;

function ToleMain.Get_PortLocked: WordBool;
begin
  Result := False;
end;

function ToleMain.AdminUnlockPort: Integer;
begin
  { !!! }
  //Result := DoAdminUnlockPort;
end;

function ToleMain.AdminUnlockPorts: Integer;
begin
  Result := ClearResult;
end;

function ToleMain.ServerCheckKey: Integer;
begin
  { Ничего не делает }
  Result := ClearResult;
end;

function ToleMain.GetFontMetrics: Integer;

  function GetFonts(const Fonts: array of TFontRec): Integer;
  var
    FontRec: TFontRec;
  begin
    Result := ClearResult;
    FFontCount := High(Fonts) - Low(Fonts) + 1;
    if (FFontType > 0)and(FFontType <= FFontCount) then
    begin
      FontRec := Fonts[FFontType-1];
      FLineWidth := FontRec.LineWidth;
      FCharWidth := FontRec.CharWidth;
      FCharHeight := FontRec.CharHeight;
    end else
    begin
      Result := InvalidFontType;
    end;
  end;

  function ReadByte(TableNumber, RowNumber, FieldNumber: Integer): Integer;
  var
    Data: string;
  begin
    FField.FieldSize := 1;
    FField.IsString := False;
    Data := #$1F + FPassw + Chr(TableNumber) + WordToStr(RowNumber) + Chr(FieldNumber);
    Result := Send(Data);
  end;

  function GetFRF4Font: Integer;
  var
    FontCompression: Boolean; // сжатие шрифтов
  begin
    FontCompression := False;
    if Get_UseJournalRibbon then
    begin
      Result := ReadByte(1,1,31);
      FontCompression := FField.IntValue <> 0;
    end else
    begin
      if Get_UseReceiptRibbon then
      begin
        Result := ReadByte(1,1,32);
      	FontCompression := FField.IntValue <> 0;
      end else
      begin
        Result := InvalidParam;
        FResultDescription := 'Неверное значение свойства TapeType.';
      end;
    end;
    if Result <> 0 then Exit;
    if FontCompression then Result := GetFonts(FRF4FontsCompressed)
    else Result := GetFonts(FRF4Fonts);
  end;

  function GetShtrih500Font: Integer;
  var
    FontCompression: Boolean; // сжатие шрифтов
  begin
    Result := ReadByte(1,1,9);
    FontCompression := FField.IntValue <> 0;
    if not DRV_SUCCESS(Result) then Exit;
    if FontCompression then Result := GetFonts(Shtrih500FontsCompressed)
    else Result := GetFonts(Shtrih500Fonts);
  end;

  function Get950Fonts: Integer;
  var
    LineSpacing: Integer;
  begin
    Result := ReadByte(1,1,36);
    if DRV_SUCCESS(Result) then
    begin
      Result := GetFonts(Shtrih950Fonts);
      // Добавляем межстрочный интервал
      if DRV_SUCCESS(Result) then
      begin
        LineSpacing := Trunc(FField.IntValue/2 + 0.5);
        FCharHeight := FCharHeight + LineSpacing;
      end;
    end;
  end;

  function GetComboFonts: Integer;
  var
    LineSpacing: Byte; 				// Межстрочный интервал
    FontCompression: Boolean; // Сжатие шрифтов
  begin
    Result := ReadByte(1,1,33);
    if not DRV_SUCCESS(Result) then Exit;
    FontCompression := FField.IntValue <> 0;
    // Межстрочный интервал
    Result := ReadByte(1,1,31);
    if not DRV_SUCCESS(Result) then Exit;
    LineSpacing := FField.IntValue;
    if FontCompression then LineSpacing := Trunc(LineSpacing/2 + 0.5);
    // Шрифты
    if FontCompression then Result := GetFonts(ShtrihMiniFontsCompressed)
    else Result := GetFonts(ShtrihMiniFonts);
    if not DRV_SUCCESS(Result) then Exit;
    // Изменяем высоту шрифта
    FCharHeight := FCharHeight - 5 + LineSpacing;
  end;

  function GetShtrihMiniFRKFonts: Integer;
  var
    Compression: Boolean; // Сжатие шрифтов
  begin
    // Сжатие шрифтов на чековой ленте
    Result := ReadByte(1,1,25);
    if not DRV_SUCCESS(Result) then Exit;
    Compression := FField.IntValue <> 0;
    // Шрифты
    if Compression then Result := GetFonts(ShtrihMiniFontsCompressed)
    else Result := GetFonts(ShtrihMiniFonts);
  end;

  function GetShtrihMiniFRK2Fonts: Integer;
  var
    Compression: Boolean;
  begin
    // Сжатие шрифтов на чековой ленте
    Result := ReadByte(1,1,25);
    if not DRV_SUCCESS(Result) then Exit;
    Compression := FField.IntValue <> 0;
    // Шрифты
    if Compression then Result := GetFonts(ShtrihMini2FontsCompressed)
    else Result := GetFonts(ShtrihMini2Fonts);
  end;

  function GetElvesFRKFonts: Integer;
  var
    Compression: Boolean;
  begin
    // Сжатие шрифтов на чековой ленте
    Result := ReadByte(1,1,25);
    if not DRV_SUCCESS(Result) then Exit;
    Compression := FField.IntValue <> 0;
    // Шрифты
    if Compression then Result := GetFonts(ElvesFRKFontsCompressed)
    else Result := GetFonts(ElvesFRKFonts);
  end;

  function GetFontParams: Integer;
  begin
    case GetModel of
      dmShtrihFRF3        : Result := GetFonts(FRF3Fonts);
      dmShtrihFRF4        : Result := GetFRF4Font;
      dmShtrihFRFKaz      : Result := GetFRF4Font;
      dmElvesMiniFRF      : Result := GetFRF4Font;
      dmShtrihFRK         : Result := GetFRF4Font;
      dmShtrih950K        : Result := Get950Fonts;
      dmShtrih950KV2		  : Result := Get950Fonts;
      dmElvesFRK          : Result := GetElvesFRKFonts;
      dmShtrihMiniFRK     : Result := GetShtrihMiniFRKFonts;
      dmShtrihMiniFRK2    : Result := GetShtrihMiniFRK2Fonts;
      dmShtrihFRFBel      : Result := GetFRF4Font;
      dmShtrihComboFRKv1  : Result := GetComboFonts;
      dmShtrihComboFRKv2  : Result := GetComboFonts;
      dmShtrihPOSF			  : Result := GetFRF4Font;
      dmShtrih500				  : Result := GetShtrih500Font;
    else
      Result := 55;
      FResultCode := Result;
      FResultDescription := CodeToStr(55);
    end;
  end;

begin
  try
    FInput := '';
    FOutput := '';
    // Запрос параметров устройства
    if not FGetDeviceMetrics then
    begin
      Result := GetDeviceMetrics;
      if Result <> 0 then Exit;
    end;
    // Проверка версий протокола
    if ((FUMajorProtocolVersion = 1)and(FUMinorProtocolVersion >= 5))or
      (FUMajorProtocolVersion > 1) then
    begin
      Result := Send(#$26 + FPassw + Chr(GetFontType))
    end else
    begin
      Result := GetFontParams;
    end;
  except
    on E: Exception do Result := HandleException(E);
  end;
end;

function ToleMain.Get_PrintWidth: Integer;
begin
  Result := FLineWidth;
end;

function ToleMain.Get_CharWidth: Integer;
begin
  Result := FCharWidth;
end;

function ToleMain.Get_CharHeight: Integer;
begin
  Result := FCharHeight;
end;

function ToleMain.Get_FontCount: Integer;
begin
  Result := FFontCount;
end;

function ToleMain.GetFreeLDNumber: Integer;
begin
  Result := Devices.GetFreeNumber;
end;

function ToleMain.Get_LogOn: WordBool;
begin
  Result := LogFile.Enabled;
end;

procedure ToleMain.Set_LogOn(Value: WordBool);
begin
  LogFile.Enabled := Value;
end;

function ToleMain.ReadTable2: Integer;
var
  Data: string;
begin
  try
    Data :=
      #$1F +
      FPassw +
      Chr(GetTableNumber) +
      WordToStr(GetRowNumber) +
      Chr(FFieldNumber);

    Result := Send(Data);
  except
    on E: Exception do Result := HandleException(E);
  end;
end;

function ToleMain.WriteTable2: Integer;
var
  Data: string;
begin
  try
    Data :=
      #$1E +
      FPassw +
      Chr(GetTableNumber) +
      WordToStr(GetRowNumber)+
      Chr(GetFieldNumber) +
      GetFieldValue;

    Result := Send(Data);
    if Result = 0 then UpdateValues;
  except
    on E: Exception do Result := HandleException(E);
  end;
end;

procedure ToleMain.SetFieldSize(Value: Integer);
begin
  FField.FieldSize := Value;
end;

procedure ToleMain.SetIsString(Value: WordBool);
begin
  FField.IsString := Value;
end;

procedure ToleMain.SetFieldMaxValue(Value: Integer);
begin
  FField.MaxValue := Value;
end;

procedure ToleMain.SetFieldMinValue(Value: Integer);
begin
  FField.MinValue := Value;
end;

function ToleMain.Get_CPLog: WordBool;
begin
  Result := False;
end;

procedure ToleMain.Set_CPLog(Value: WordBool);
begin
end;

end.

unit OposWebkassaLib_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// PASTLWTR : 1.2
// File generated on 14.01.2025 14:39:10 from Type Library described below.

// ************************************************************************  //
// Type Lib: D:\Projects\OposWebkassa\src\OposWebkassa\OposWebkassa.tlb (1)
// LIBID: {70222E65-8696-4B47-9D36-284716EE0DE8}
// LCID: 0
// Helpfile: 
// HelpString: OPOS Webkassa Library
// DepndLst: 
//   (1) v2.0 stdole, (C:\Windows\SysWOW64\stdole2.tlb)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
interface

uses Windows, ActiveX, Classes, Graphics, StdVCL, Variants;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  OposWebkassaLibMajorVersion = 1;
  OposWebkassaLibMinorVersion = 0;

  LIBID_OposWebkassaLib: TGUID = '{70222E65-8696-4B47-9D36-284716EE0DE8}';

  IID_IFiscalPrinterService_1_12: TGUID = '{DF348EB3-EC28-42FE-B360-531BC02E0508}';
  CLASS_FiscalPrinter: TGUID = '{B854925B-A26D-44C8-8CB7-DC93E5E7BC06}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IFiscalPrinterService_1_12 = interface;
  IFiscalPrinterService_1_12Disp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  FiscalPrinter = IFiscalPrinterService_1_12;


// *********************************************************************//
// Interface: IFiscalPrinterService_1_12
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {DF348EB3-EC28-42FE-B360-531BC02E0508}
// *********************************************************************//
  IFiscalPrinterService_1_12 = interface(IDispatch)
    ['{DF348EB3-EC28-42FE-B360-531BC02E0508}']
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
    function PrintNormal(Station: Integer; const Data: WideString): Integer; safecall;
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
  end;

// *********************************************************************//
// DispIntf:  IFiscalPrinterService_1_12Disp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {DF348EB3-EC28-42FE-B360-531BC02E0508}
// *********************************************************************//
  IFiscalPrinterService_1_12Disp = dispinterface
    ['{DF348EB3-EC28-42FE-B360-531BC02E0508}']
    property OpenResult: Integer readonly dispid 1;
    function COFreezeEvents(Freeze: WordBool): Integer; dispid 2;
    function GetPropertyNumber(PropIndex: Integer): Integer; dispid 3;
    procedure SetPropertyNumber(PropIndex: Integer; Number: Integer); dispid 4;
    function GetPropertyString(PropIndex: Integer): WideString; dispid 5;
    procedure SetPropertyString(PropIndex: Integer; const Text: WideString); dispid 6;
    function OpenService(const DeviceClass: WideString; const DeviceName: WideString; 
                         const pDispatch: IDispatch): Integer; dispid 7;
    function CloseService: Integer; dispid 8;
    function CheckHealth(Level: Integer): Integer; dispid 9;
    function ClaimDevice(Timeout: Integer): Integer; dispid 10;
    function ClearOutput: Integer; dispid 11;
    function DirectIO(Command: Integer; var pData: Integer; var pString: WideString): Integer; dispid 12;
    function ReleaseDevice: Integer; dispid 13;
    function BeginFiscalDocument(DocumentAmount: Integer): Integer; dispid 14;
    function BeginFiscalReceipt(PrintHeader: WordBool): Integer; dispid 15;
    function BeginFixedOutput(Station: Integer; DocumentType: Integer): Integer; dispid 16;
    function BeginInsertion(Timeout: Integer): Integer; dispid 17;
    function BeginItemList(VatID: Integer): Integer; dispid 18;
    function BeginNonFiscal: Integer; dispid 19;
    function BeginRemoval(Timeout: Integer): Integer; dispid 20;
    function BeginTraining: Integer; dispid 21;
    function ClearError: Integer; dispid 22;
    function EndFiscalDocument: Integer; dispid 23;
    function EndFiscalReceipt(PrintHeader: WordBool): Integer; dispid 24;
    function EndFixedOutput: Integer; dispid 25;
    function EndInsertion: Integer; dispid 26;
    function EndItemList: Integer; dispid 27;
    function EndNonFiscal: Integer; dispid 28;
    function EndRemoval: Integer; dispid 29;
    function EndTraining: Integer; dispid 30;
    function GetData(DataItem: Integer; out OptArgs: Integer; out Data: WideString): Integer; dispid 31;
    function GetDate(out Date: WideString): Integer; dispid 32;
    function GetTotalizer(VatID: Integer; OptArgs: Integer; out Data: WideString): Integer; dispid 33;
    function GetVatEntry(VatID: Integer; OptArgs: Integer; out VatRate: Integer): Integer; dispid 34;
    function PrintDuplicateReceipt: Integer; dispid 35;
    function PrintFiscalDocumentLine(const DocumentLine: WideString): Integer; dispid 36;
    function PrintFixedOutput(DocumentType: Integer; LineNumber: Integer; const Data: WideString): Integer; dispid 37;
    function PrintNormal(Station: Integer; const Data: WideString): Integer; dispid 38;
    function PrintPeriodicTotalsReport(const Date1: WideString; const Date2: WideString): Integer; dispid 39;
    function PrintPowerLossReport: Integer; dispid 40;
    function PrintRecItem(const Description: WideString; Price: Currency; Quantity: Integer; 
                          VatInfo: Integer; UnitPrice: Currency; const UnitName: WideString): Integer; dispid 41;
    function PrintRecItemAdjustment(AdjustmentType: Integer; const Description: WideString; 
                                    Amount: Currency; VatInfo: Integer): Integer; dispid 42;
    function PrintRecMessage(const Message: WideString): Integer; dispid 43;
    function PrintRecNotPaid(const Description: WideString; Amount: Currency): Integer; dispid 44;
    function PrintRecRefund(const Description: WideString; Amount: Currency; VatInfo: Integer): Integer; dispid 45;
    function PrintRecSubtotal(Amount: Currency): Integer; dispid 46;
    function PrintRecSubtotalAdjustment(AdjustmentType: Integer; const Description: WideString; 
                                        Amount: Currency): Integer; dispid 47;
    function PrintRecTotal(Total: Currency; Payment: Currency; const Description: WideString): Integer; dispid 48;
    function PrintRecVoid(const Description: WideString): Integer; dispid 49;
    function PrintRecVoidItem(const Description: WideString; Amount: Currency; Quantity: Integer; 
                              AdjustmentType: Integer; Adjustment: Currency; VatInfo: Integer): Integer; dispid 50;
    function PrintReport(ReportType: Integer; const StartNum: WideString; const EndNum: WideString): Integer; dispid 51;
    function PrintXReport: Integer; dispid 52;
    function PrintZReport: Integer; dispid 53;
    function ResetPrinter: Integer; dispid 54;
    function SetDate(const Date: WideString): Integer; dispid 55;
    function SetHeaderLine(LineNumber: Integer; const Text: WideString; DoubleWidth: WordBool): Integer; dispid 56;
    function SetPOSID(const POSID: WideString; const CashierID: WideString): Integer; dispid 57;
    function SetStoreFiscalID(const ID: WideString): Integer; dispid 58;
    function SetTrailerLine(LineNumber: Integer; const Text: WideString; DoubleWidth: WordBool): Integer; dispid 59;
    function SetVatTable: Integer; dispid 60;
    function SetVatValue(VatID: Integer; const VatValue: WideString): Integer; dispid 61;
    function VerifyItem(const ItemName: WideString; VatID: Integer): Integer; dispid 62;
    function PrintRecCash(Amount: Currency): Integer; dispid 63;
    function PrintRecItemFuel(const Description: WideString; Price: Currency; Quantity: Integer; 
                              VatInfo: Integer; UnitPrice: Currency; const UnitName: WideString; 
                              SpecialTax: Currency; const SpecialTaxName: WideString): Integer; dispid 64;
    function PrintRecItemFuelVoid(const Description: WideString; Price: Currency; VatInfo: Integer; 
                                  SpecialTax: Currency): Integer; dispid 65;
    function PrintRecPackageAdjustment(AdjustmentType: Integer; const Description: WideString; 
                                       const VatAdjustment: WideString): Integer; dispid 66;
    function PrintRecPackageAdjustVoid(AdjustmentType: Integer; const VatAdjustment: WideString): Integer; dispid 67;
    function PrintRecRefundVoid(const Description: WideString; Amount: Currency; VatInfo: Integer): Integer; dispid 68;
    function PrintRecSubtotalAdjustVoid(AdjustmentType: Integer; Amount: Currency): Integer; dispid 69;
    function PrintRecTaxID(const TaxID: WideString): Integer; dispid 70;
    function SetCurrency(NewCurrency: Integer): Integer; dispid 71;
    function GetOpenResult: Integer; dispid 80;
    function Open(const DeviceClass: WideString; const DeviceName: WideString; 
                  const pDispatch: IDispatch): Integer; dispid 81;
    function Close: Integer; dispid 82;
    function Claim(Timeout: Integer): Integer; dispid 83;
    function Release1: Integer; dispid 84;
    function ResetStatistics(const StatisticsBuffer: WideString): Integer; dispid 85;
    function RetrieveStatistics(var pStatisticsBuffer: WideString): Integer; dispid 86;
    function UpdateStatistics(const StatisticsBuffer: WideString): Integer; dispid 87;
    function CompareFirmwareVersion(const FirmwareFileName: WideString; out pResult: Integer): Integer; dispid 88;
    function UpdateFirmware(const FirmwareFileName: WideString): Integer; dispid 89;
    function PrintRecItemAdjustmentVoid(AdjustmentType: Integer; const Description: WideString; 
                                        Amount: Currency; VatInfo: Integer): Integer; dispid 90;
    function PrintRecItemVoid(const Description: WideString; Price: Currency; Quantity: Integer; 
                              VatInfo: Integer; UnitPrice: Currency; const UnitName: WideString): Integer; dispid 91;
    function PrintRecItemRefund(const Description: WideString; Amount: Currency; Quantity: Integer; 
                                VatInfo: Integer; UnitAmount: Currency; const UnitName: WideString): Integer; dispid 92;
    function PrintRecItemRefundVoid(const Description: WideString; Amount: Currency; 
                                    Quantity: Integer; VatInfo: Integer; UnitAmount: Currency; 
                                    const UnitName: WideString): Integer; dispid 93;
  end;

// *********************************************************************//
// The Class CoFiscalPrinter provides a Create and CreateRemote method to          
// create instances of the default interface IFiscalPrinterService_1_12 exposed by              
// the CoClass FiscalPrinter. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoFiscalPrinter = class
    class function Create: IFiscalPrinterService_1_12;
    class function CreateRemote(const MachineName: string): IFiscalPrinterService_1_12;
  end;

implementation

uses ComObj;

class function CoFiscalPrinter.Create: IFiscalPrinterService_1_12;
begin
  Result := CreateComObject(CLASS_FiscalPrinter) as IFiscalPrinterService_1_12;
end;

class function CoFiscalPrinter.CreateRemote(const MachineName: string): IFiscalPrinterService_1_12;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_FiscalPrinter) as IFiscalPrinterService_1_12;
end;

end.

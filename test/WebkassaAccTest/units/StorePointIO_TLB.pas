unit StorePointIO_TLB;

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
// File generated on 10.08.2022 16:41:09 from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\projects\WebKassa\test\WebkassaAccTest\units\StorePointIO.tlb (1)
// LIBID: {4904D633-B3F9-45C2-829A-44AF0414CAB0}
// LCID: 0
// Helpfile: 
// HelpString: PositiveIO Library
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
  StorePointIOMajorVersion = 1;
  StorePointIOMinorVersion = 0;

  LIBID_StorePointIO: TGUID = '{4904D633-B3F9-45C2-829A-44AF0414CAB0}';

  IID_IIOSystemSO: TGUID = '{2089CDE0-28DB-49C9-A7C8-D9B48EA303B9}';
  CLASS_IOSystemSO: TGUID = '{443AB998-7145-4972-B7C0-82774D61D3EF}';
  IID_ICallBack: TGUID = '{B742A229-E719-4C32-9D36-A5A62BAE46A0}';
  DIID_ICallBackEvents: TGUID = '{F9647288-77D1-4948-ABEB-34AB4C2B6334}';
  CLASS_CallBack: TGUID = '{43FD9472-1AE1-4251-B75F-4595B5696D64}';
  IID_IServices: TGUID = '{F6D3B1F6-9D06-4E32-88BF-5E5FA9BED74F}';
  CLASS_Services: TGUID = '{B068FC97-66B5-4FEA-B70F-91457BA9AFDD}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IIOSystemSO = interface;
  IIOSystemSODisp = dispinterface;
  ICallBack = interface;
  ICallBackDisp = dispinterface;
  ICallBackEvents = dispinterface;
  IServices = interface;
  IServicesDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  IOSystemSO = IIOSystemSO;
  CallBack = ICallBack;
  Services = IServices;


// *********************************************************************//
// Interface: IIOSystemSO
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {2089CDE0-28DB-49C9-A7C8-D9B48EA303B9}
// *********************************************************************//
  IIOSystemSO = interface(IDispatch)
    ['{2089CDE0-28DB-49C9-A7C8-D9B48EA303B9}']
    procedure SuppressDevices(iSuppressMode: Integer); safecall;
    procedure UnSuppressDevices(bForce: WordBool); safecall;
    procedure CloseDevices; safecall;
    procedure EnableEvents; safecall;
    function PrintSlip(Station: Integer; const wSlip: WideString; var TransObj: OleVariant): WordBool; safecall;
    function CheckFrank(const wFrankSlip: WideString): WordBool; safecall;
    function PrintFiscalXReport: Integer; safecall;
    function PrintFiscalZReport(var bNeedDispMsg: WordBool): WordBool; safecall;
    function PrintFiscalReport(ReportType: Integer; const StartNumDate: WideString; 
                               const EndNumDate: WideString): WordBool; safecall;
    function DisplayText(TransObj: OleVariant; const Data: WideString; 
                         const DataAmount: WideString; Attribute: Integer; 
                         bSrvLinkAssign: WordBool; bUseColumns: WordBool): Integer; safecall;
    function OpenDrawer(DrawerId: Integer): WordBool; safecall;
    function MICREndInsertion: Integer; safecall;
    function MICRBeginInsertion: Integer; safecall;
    function MICRBeginRemoval: Integer; safecall;
    function ReadWeight(var DataWeight: Double): WordBool; safecall;
    procedure SetBitmapInfo; safecall;
    procedure SendClearMsg(ClearDT: Integer; bImidiate: WordBool; iClearSrc: Integer); safecall;
    function InitDevices: WordBool; safecall;
    function ReInitDevices: WordBool; safecall;
    function DoHardRefresh(DeviceType: Integer; bForceRefresh: WordBool): WordBool; safecall;
    function Get_IsFiscalPrinterInitFailed: WordBool; safecall;
    function Get_IsFiscalPrinterActive: WordBool; safecall;
    function CheckIfFiscalVoidTicket: WordBool; safecall;
    function PinPadDisplayMessage(iClear: Integer; const sMsg: WideString; iType: Integer; 
                                  iSec: Integer): Integer; safecall;
    function PinPadIndicateHostDone(const sMsg: WideString): Integer; safecall;
    function CancelPinPadSession(bRefreshConnection: WordBool): Integer; safecall;
    function CheckPinpadAvailable(bTryToReconnect: WordBool): Integer; safecall;
    function GetPinEntry(var sData: WideString): Integer; safecall;
    function GetPinPadPromptData(const wDisplay: WideString; const wEchoFlag: WideString; 
                                 iTimeOut: Integer; iMinEntery: Integer; iMaxEntry: Integer; 
                                 var wData: WideString): Integer; safecall;
    function Get_UseTrackSentinels: WordBool; safecall;
    function Get_PrinterWidth: Integer; safecall;
    function InitSwitchPinpadSrv: Integer; safecall;
    procedure FreeSwitchPinpadSrv; safecall;
    procedure PrintSignInFiscalReport(const OperName: WideString; TermId: Integer); safecall;
    procedure PrintSignOutFiscalReport(const OperName: WideString; TermId: Integer); safecall;
    function Get_IsFiscalPrinterTicketVoid: WordBool; safecall;
    procedure Set_IsFiscalPrinterTicketVoid(Value: WordBool); safecall;
    function GetPinpadPaymentType(var sTrnType: WideString): Integer; safecall;
    function Get_MSRErrorCount: Integer; safecall;
    procedure Set_MSRErrorCount(Value: Integer); safecall;
    procedure PinPadRequestCardSwipeData(const wMsg: WideString); safecall;
    function GetPinPadCodedKey(iTime: Integer; const wDispMsg: WideString; 
                               var wTransType: WideString): WordBool; safecall;
    function GetPinPadCardSwipeData(var PinPadTrack1: WideString; var PinPadTrack2: WideString; 
                                    var PinPadData: WideString): WordBool; safecall;
    function TransactionNotifyAction(NotifyAction: Integer; var TransObj: OleVariant; 
                                     var RefObject: OleVariant; bAssignedSrvLink: WordBool): WordBool; safecall;
    function GetPropertyString(iDeviceType: Integer; PropIndex: Integer): WideString; safecall;
    function GetPropertyNumber(iDeviceType: Integer; PropIndex: Integer): Integer; safecall;
    function OPOSReturnTrnslt(DeviceType: Integer; iOPOSRet: Integer; iExtOPOSRet: Integer): WideString; safecall;
    function WaitForDrawerClose(DrawerId: Integer; iBeepTimeout: Integer; iBeepFrequency: Integer; 
                                iBeepDuration: Integer; iBeepDelay: Integer): Integer; safecall;
    procedure DoCloseDevice(DeviceType: Integer); safecall;
    procedure DoOpenDevice(DeviceType: Integer); safecall;
    procedure SetPropertyNumber(iDeviceType: Integer; PropIndex: Integer; iValue: Integer); safecall;
    function GetDevicesErrMessage: WideString; safecall;
    function PosDeviceLocked(iDeviceType: Integer; var wDeviceName: WideString; 
                             var wErrorMsg: WideString): WordBool; safecall;
    function BeginCapture: Integer; safecall;
    function EndCapture: Integer; safecall;
    function Get_PinpadType: Integer; safecall;
    function GetFiscalReceiptNumber: Integer; safecall;
    procedure Set_DeviceStateLog(Param1: Integer); safecall;
    procedure SetPropertyString(iDeviceType: Integer; PropIndex: Integer; const wValue: WideString); safecall;
    function FingerPrintValidate(iEmployeeId: Integer; const sPrintType: WideString): WordBool; safecall;
    function Get_FingerPrintActive: WordBool; safecall;
    procedure Set_IgnoreFreeze(Param1: WordBool); safecall;
    procedure Set_IgnoreDisable(Param1: WordBool); safecall;
    procedure ReInitDeviceByType(DeviceType: Integer); safecall;
    function Get_HyperActiveDevices: WideString; safecall;
    function Get_SigCapRawData: OleVariant; safecall;
    procedure ClearText; safecall;
    procedure RequestHyperSwipePaymentData(bSwipeOnly: WordBool); safecall;
    function ReadWeightEx(var DataWeight: Double; bForceReEnable: WordBool): Integer; safecall;
    procedure InitLogFile(var LogSrv: OleVariant; LogSrvType: Integer); safecall;
    function DisplayFormattedText(const ADispStr: WideString): WordBool; safecall;
    function PrintFiscalLastTicket(const LastTicketDay: WideString): Integer; safecall;
    function GetDeviceStatus(DeviceType: Integer; var ErrorMessage: WideString): Integer; safecall;
    function DoIOOperation(dt_Device: Integer; ot_Operation: Integer; const InBuffer: WideString; 
                           var OutBuffer: WideString): Integer; safecall;
    function ResetPrinter: Integer; safecall;
    function PrintXML(const XMLText: WideString; const FileName: WideString): Integer; safecall;
    function Get_IsFiscalPrinterError: WordBool; safecall;
    function CheckCF: WordBool; safecall;
    property IsFiscalPrinterInitFailed: WordBool read Get_IsFiscalPrinterInitFailed;
    property IsFiscalPrinterActive: WordBool read Get_IsFiscalPrinterActive;
    property UseTrackSentinels: WordBool read Get_UseTrackSentinels;
    property PrinterWidth: Integer read Get_PrinterWidth;
    property IsFiscalPrinterTicketVoid: WordBool read Get_IsFiscalPrinterTicketVoid write Set_IsFiscalPrinterTicketVoid;
    property MSRErrorCount: Integer read Get_MSRErrorCount write Set_MSRErrorCount;
    property PinpadType: Integer read Get_PinpadType;
    property DeviceStateLog: Integer write Set_DeviceStateLog;
    property FingerPrintActive: WordBool read Get_FingerPrintActive;
    property IgnoreFreeze: WordBool write Set_IgnoreFreeze;
    property IgnoreDisable: WordBool write Set_IgnoreDisable;
    property HyperActiveDevices: WideString read Get_HyperActiveDevices;
    property SigCapRawData: OleVariant read Get_SigCapRawData;
    property IsFiscalPrinterError: WordBool read Get_IsFiscalPrinterError;
  end;

// *********************************************************************//
// DispIntf:  IIOSystemSODisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {2089CDE0-28DB-49C9-A7C8-D9B48EA303B9}
// *********************************************************************//
  IIOSystemSODisp = dispinterface
    ['{2089CDE0-28DB-49C9-A7C8-D9B48EA303B9}']
    procedure SuppressDevices(iSuppressMode: Integer); dispid 1;
    procedure UnSuppressDevices(bForce: WordBool); dispid 2;
    procedure CloseDevices; dispid 3;
    procedure EnableEvents; dispid 4;
    function PrintSlip(Station: Integer; const wSlip: WideString; var TransObj: OleVariant): WordBool; dispid 6;
    function CheckFrank(const wFrankSlip: WideString): WordBool; dispid 7;
    function PrintFiscalXReport: Integer; dispid 8;
    function PrintFiscalZReport(var bNeedDispMsg: WordBool): WordBool; dispid 9;
    function PrintFiscalReport(ReportType: Integer; const StartNumDate: WideString; 
                               const EndNumDate: WideString): WordBool; dispid 10;
    function DisplayText(TransObj: OleVariant; const Data: WideString; 
                         const DataAmount: WideString; Attribute: Integer; 
                         bSrvLinkAssign: WordBool; bUseColumns: WordBool): Integer; dispid 11;
    function OpenDrawer(DrawerId: Integer): WordBool; dispid 12;
    function MICREndInsertion: Integer; dispid 15;
    function MICRBeginInsertion: Integer; dispid 16;
    function MICRBeginRemoval: Integer; dispid 17;
    function ReadWeight(var DataWeight: Double): WordBool; dispid 19;
    procedure SetBitmapInfo; dispid 20;
    procedure SendClearMsg(ClearDT: Integer; bImidiate: WordBool; iClearSrc: Integer); dispid 21;
    function InitDevices: WordBool; dispid 22;
    function ReInitDevices: WordBool; dispid 23;
    function DoHardRefresh(DeviceType: Integer; bForceRefresh: WordBool): WordBool; dispid 24;
    property IsFiscalPrinterInitFailed: WordBool readonly dispid 25;
    property IsFiscalPrinterActive: WordBool readonly dispid 26;
    function CheckIfFiscalVoidTicket: WordBool; dispid 27;
    function PinPadDisplayMessage(iClear: Integer; const sMsg: WideString; iType: Integer; 
                                  iSec: Integer): Integer; dispid 5;
    function PinPadIndicateHostDone(const sMsg: WideString): Integer; dispid 28;
    function CancelPinPadSession(bRefreshConnection: WordBool): Integer; dispid 29;
    function CheckPinpadAvailable(bTryToReconnect: WordBool): Integer; dispid 30;
    function GetPinEntry(var sData: WideString): Integer; dispid 31;
    function GetPinPadPromptData(const wDisplay: WideString; const wEchoFlag: WideString; 
                                 iTimeOut: Integer; iMinEntery: Integer; iMaxEntry: Integer; 
                                 var wData: WideString): Integer; dispid 32;
    property UseTrackSentinels: WordBool readonly dispid 33;
    property PrinterWidth: Integer readonly dispid 35;
    function InitSwitchPinpadSrv: Integer; dispid 36;
    procedure FreeSwitchPinpadSrv; dispid 37;
    procedure PrintSignInFiscalReport(const OperName: WideString; TermId: Integer); dispid 38;
    procedure PrintSignOutFiscalReport(const OperName: WideString; TermId: Integer); dispid 39;
    property IsFiscalPrinterTicketVoid: WordBool dispid 40;
    function GetPinpadPaymentType(var sTrnType: WideString): Integer; dispid 41;
    property MSRErrorCount: Integer dispid 42;
    procedure PinPadRequestCardSwipeData(const wMsg: WideString); dispid 43;
    function GetPinPadCodedKey(iTime: Integer; const wDispMsg: WideString; 
                               var wTransType: WideString): WordBool; dispid 44;
    function GetPinPadCardSwipeData(var PinPadTrack1: WideString; var PinPadTrack2: WideString; 
                                    var PinPadData: WideString): WordBool; dispid 45;
    function TransactionNotifyAction(NotifyAction: Integer; var TransObj: OleVariant; 
                                     var RefObject: OleVariant; bAssignedSrvLink: WordBool): WordBool; dispid 46;
    function GetPropertyString(iDeviceType: Integer; PropIndex: Integer): WideString; dispid 47;
    function GetPropertyNumber(iDeviceType: Integer; PropIndex: Integer): Integer; dispid 49;
    function OPOSReturnTrnslt(DeviceType: Integer; iOPOSRet: Integer; iExtOPOSRet: Integer): WideString; dispid 50;
    function WaitForDrawerClose(DrawerId: Integer; iBeepTimeout: Integer; iBeepFrequency: Integer; 
                                iBeepDuration: Integer; iBeepDelay: Integer): Integer; dispid 13;
    procedure DoCloseDevice(DeviceType: Integer); dispid 14;
    procedure DoOpenDevice(DeviceType: Integer); dispid 34;
    procedure SetPropertyNumber(iDeviceType: Integer; PropIndex: Integer; iValue: Integer); dispid 18;
    function GetDevicesErrMessage: WideString; dispid 48;
    function PosDeviceLocked(iDeviceType: Integer; var wDeviceName: WideString; 
                             var wErrorMsg: WideString): WordBool; dispid 51;
    function BeginCapture: Integer; dispid 52;
    function EndCapture: Integer; dispid 53;
    property PinpadType: Integer readonly dispid 54;
    function GetFiscalReceiptNumber: Integer; dispid 55;
    property DeviceStateLog: Integer writeonly dispid 56;
    procedure SetPropertyString(iDeviceType: Integer; PropIndex: Integer; const wValue: WideString); dispid 57;
    function FingerPrintValidate(iEmployeeId: Integer; const sPrintType: WideString): WordBool; dispid 201;
    property FingerPrintActive: WordBool readonly dispid 202;
    property IgnoreFreeze: WordBool writeonly dispid 58;
    property IgnoreDisable: WordBool writeonly dispid 59;
    procedure ReInitDeviceByType(DeviceType: Integer); dispid 60;
    property HyperActiveDevices: WideString readonly dispid 61;
    property SigCapRawData: OleVariant readonly dispid 62;
    procedure ClearText; dispid 63;
    procedure RequestHyperSwipePaymentData(bSwipeOnly: WordBool); dispid 64;
    function ReadWeightEx(var DataWeight: Double; bForceReEnable: WordBool): Integer; dispid 65;
    procedure InitLogFile(var LogSrv: OleVariant; LogSrvType: Integer); dispid 66;
    function DisplayFormattedText(const ADispStr: WideString): WordBool; dispid 67;
    function PrintFiscalLastTicket(const LastTicketDay: WideString): Integer; dispid 69;
    function GetDeviceStatus(DeviceType: Integer; var ErrorMessage: WideString): Integer; dispid 68;
    function DoIOOperation(dt_Device: Integer; ot_Operation: Integer; const InBuffer: WideString; 
                           var OutBuffer: WideString): Integer; dispid 70;
    function ResetPrinter: Integer; dispid 71;
    function PrintXML(const XMLText: WideString; const FileName: WideString): Integer; dispid 72;
    property IsFiscalPrinterError: WordBool readonly dispid 73;
    function CheckCF: WordBool; dispid 74;
  end;

// *********************************************************************//
// Interface: ICallBack
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {B742A229-E719-4C32-9D36-A5A62BAE46A0}
// *********************************************************************//
  ICallBack = interface(IDispatch)
    ['{B742A229-E719-4C32-9D36-A5A62BAE46A0}']
  end;

// *********************************************************************//
// DispIntf:  ICallBackDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {B742A229-E719-4C32-9D36-A5A62BAE46A0}
// *********************************************************************//
  ICallBackDisp = dispinterface
    ['{B742A229-E719-4C32-9D36-A5A62BAE46A0}']
  end;

// *********************************************************************//
// DispIntf:  ICallBackEvents
// Flags:     (4096) Dispatchable
// GUID:      {F9647288-77D1-4948-ABEB-34AB4C2B6334}
// *********************************************************************//
  ICallBackEvents = dispinterface
    ['{F9647288-77D1-4948-ABEB-34AB4C2B6334}']
    procedure DataEvent(DeviceType: Integer; Status: Integer); dispid 1;
    procedure ErrorEvent(DeviceType: Integer; ResultCode: Integer; ResultCodeExtended: Integer; 
                         ErrorLocus: Integer; var pErrorResponse: Integer); dispid 2;
    procedure StatusUpdateEvent(DeviceType: Integer; Status: Integer); dispid 3;
    procedure MessageEvent(MsgId: Integer; const MessageStr: WideString); dispid 4;
    procedure MessageResultEvent(MsgId: Integer; const InBuffer: WideString; 
                                 var OutBuffer: WideString); dispid 5;
  end;

// *********************************************************************//
// Interface: IServices
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F6D3B1F6-9D06-4E32-88BF-5E5FA9BED74F}
// *********************************************************************//
  IServices = interface(IDispatch)
    ['{F6D3B1F6-9D06-4E32-88BF-5E5FA9BED74F}']
    function PrintSlip(const sPrintBuffer: WideString): Integer; safecall;
  end;

// *********************************************************************//
// DispIntf:  IServicesDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F6D3B1F6-9D06-4E32-88BF-5E5FA9BED74F}
// *********************************************************************//
  IServicesDisp = dispinterface
    ['{F6D3B1F6-9D06-4E32-88BF-5E5FA9BED74F}']
    function PrintSlip(const sPrintBuffer: WideString): Integer; dispid 1;
  end;

// *********************************************************************//
// The Class CoIOSystemSO provides a Create and CreateRemote method to          
// create instances of the default interface IIOSystemSO exposed by              
// the CoClass IOSystemSO. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoIOSystemSO = class
    class function Create: IIOSystemSO;
    class function CreateRemote(const MachineName: string): IIOSystemSO;
  end;

// *********************************************************************//
// The Class CoCallBack provides a Create and CreateRemote method to          
// create instances of the default interface ICallBack exposed by              
// the CoClass CallBack. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoCallBack = class
    class function Create: ICallBack;
    class function CreateRemote(const MachineName: string): ICallBack;
  end;

// *********************************************************************//
// The Class CoServices provides a Create and CreateRemote method to          
// create instances of the default interface IServices exposed by              
// the CoClass Services. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoServices = class
    class function Create: IServices;
    class function CreateRemote(const MachineName: string): IServices;
  end;

implementation

uses ComObj;

class function CoIOSystemSO.Create: IIOSystemSO;
begin
  Result := CreateComObject(CLASS_IOSystemSO) as IIOSystemSO;
end;

class function CoIOSystemSO.CreateRemote(const MachineName: string): IIOSystemSO;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_IOSystemSO) as IIOSystemSO;
end;

class function CoCallBack.Create: ICallBack;
begin
  Result := CreateComObject(CLASS_CallBack) as ICallBack;
end;

class function CoCallBack.CreateRemote(const MachineName: string): ICallBack;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_CallBack) as ICallBack;
end;

class function CoServices.Create: IServices;
begin
  Result := CreateComObject(CLASS_Services) as IServices;
end;

class function CoServices.CreateRemote(const MachineName: string): IServices;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_Services) as IServices;
end;

end.

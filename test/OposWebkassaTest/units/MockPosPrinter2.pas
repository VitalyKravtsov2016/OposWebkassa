unit MockPosPrinter2;

interface

uses
  // VCL
  Classes, ComObj, SysUtils, 
  // Mock
  PascalMock,
  // Opos
  OposPOSPrinter_CCO_TLB, DebugUtils, StringUtils;

type
  { TMockPOSPrinter2 }

  TMockPOSPrinter2 = class(TMock, IDispatch, IOPOSPOSPrinter)
  public
    // IDispatch
    function GetTypeInfoCount(out Count: Integer): HResult; stdcall;
    function GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HResult; stdcall;
    function GetIDsOfNames(const IID: TGUID; Names: Pointer;
      NameCount, LocaleID: Integer; DispIDs: Pointer): HResult; stdcall;
    function Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;
      Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HResult; stdcall;
    // IOPOSPOSPrinter_1_5
    procedure SODataDummy(Status: Integer); safecall;
    procedure SODirectIO(EventNumber: Integer; var pData: Integer; var pString: WideString); safecall;
    procedure SOError(ResultCode: Integer; ResultCodeExtended: Integer; ErrorLocus: Integer;
                      var pErrorResponse: Integer); safecall;
    procedure SOOutputComplete(OutputID: Integer); safecall;
    procedure SOStatusUpdate(Data: Integer); safecall;
    function SOProcessID: Integer; safecall;
    function Get_OpenResult: Integer; safecall;
    function Get_CheckHealthText: WideString; safecall;
    function Get_Claimed: WordBool; safecall;
    function Get_DeviceEnabled: WordBool; safecall;
    procedure Set_DeviceEnabled(pDeviceEnabled: WordBool); safecall;
    function Get_FreezeEvents: WordBool; safecall;
    procedure Set_FreezeEvents(pFreezeEvents: WordBool); safecall;
    function Get_OutputID: Integer; safecall;
    function Get_ResultCode: Integer; safecall;
    function Get_ResultCodeExtended: Integer; safecall;
    function Get_State: Integer; safecall;
    function Get_ControlObjectDescription: WideString; safecall;
    function Get_ControlObjectVersion: Integer; safecall;
    function Get_ServiceObjectDescription: WideString; safecall;
    function Get_ServiceObjectVersion: Integer; safecall;
    function Get_DeviceDescription: WideString; safecall;
    function Get_DeviceName: WideString; safecall;
    function CheckHealth(Level: Integer): Integer; safecall;
    function ClaimDevice(Timeout: Integer): Integer; safecall;
    function ClearOutput: Integer; safecall;
    function Close: Integer; safecall;
    function DirectIO(Command: Integer; var pData: Integer; var pString: WideString): Integer; safecall;
    function Open(const DeviceName: WideString): Integer; safecall;
    function ReleaseDevice: Integer; safecall;
    function Get_AsyncMode: WordBool; safecall;
    procedure Set_AsyncMode(pAsyncMode: WordBool); safecall;
    function Get_CapConcurrentJrnRec: WordBool; safecall;
    function Get_CapConcurrentJrnSlp: WordBool; safecall;
    function Get_CapConcurrentRecSlp: WordBool; safecall;
    function Get_CapCoverSensor: WordBool; safecall;
    function Get_CapJrn2Color: WordBool; safecall;
    function Get_CapJrnBold: WordBool; safecall;
    function Get_CapJrnDhigh: WordBool; safecall;
    function Get_CapJrnDwide: WordBool; safecall;
    function Get_CapJrnDwideDhigh: WordBool; safecall;
    function Get_CapJrnEmptySensor: WordBool; safecall;
    function Get_CapJrnItalic: WordBool; safecall;
    function Get_CapJrnNearEndSensor: WordBool; safecall;
    function Get_CapJrnPresent: WordBool; safecall;
    function Get_CapJrnUnderline: WordBool; safecall;
    function Get_CapRec2Color: WordBool; safecall;
    function Get_CapRecBarCode: WordBool; safecall;
    function Get_CapRecBitmap: WordBool; safecall;
    function Get_CapRecBold: WordBool; safecall;
    function Get_CapRecDhigh: WordBool; safecall;
    function Get_CapRecDwide: WordBool; safecall;
    function Get_CapRecDwideDhigh: WordBool; safecall;
    function Get_CapRecEmptySensor: WordBool; safecall;
    function Get_CapRecItalic: WordBool; safecall;
    function Get_CapRecLeft90: WordBool; safecall;
    function Get_CapRecNearEndSensor: WordBool; safecall;
    function Get_CapRecPapercut: WordBool; safecall;
    function Get_CapRecPresent: WordBool; safecall;
    function Get_CapRecRight90: WordBool; safecall;
    function Get_CapRecRotate180: WordBool; safecall;
    function Get_CapRecStamp: WordBool; safecall;
    function Get_CapRecUnderline: WordBool; safecall;
    function Get_CapSlp2Color: WordBool; safecall;
    function Get_CapSlpBarCode: WordBool; safecall;
    function Get_CapSlpBitmap: WordBool; safecall;
    function Get_CapSlpBold: WordBool; safecall;
    function Get_CapSlpDhigh: WordBool; safecall;
    function Get_CapSlpDwide: WordBool; safecall;
    function Get_CapSlpDwideDhigh: WordBool; safecall;
    function Get_CapSlpEmptySensor: WordBool; safecall;
    function Get_CapSlpFullslip: WordBool; safecall;
    function Get_CapSlpItalic: WordBool; safecall;
    function Get_CapSlpLeft90: WordBool; safecall;
    function Get_CapSlpNearEndSensor: WordBool; safecall;
    function Get_CapSlpPresent: WordBool; safecall;
    function Get_CapSlpRight90: WordBool; safecall;
    function Get_CapSlpRotate180: WordBool; safecall;
    function Get_CapSlpUnderline: WordBool; safecall;
    function Get_CharacterSet: Integer; safecall;
    procedure Set_CharacterSet(pCharacterSet: Integer); safecall;
    function Get_CharacterSetList: WideString; safecall;
    function Get_CoverOpen: WordBool; safecall;
    function Get_ErrorStation: Integer; safecall;
    function Get_FlagWhenIdle: WordBool; safecall;
    procedure Set_FlagWhenIdle(pFlagWhenIdle: WordBool); safecall;
    function Get_JrnEmpty: WordBool; safecall;
    function Get_JrnLetterQuality: WordBool; safecall;
    procedure Set_JrnLetterQuality(pJrnLetterQuality: WordBool); safecall;
    function Get_JrnLineChars: Integer; safecall;
    procedure Set_JrnLineChars(pJrnLineChars: Integer); safecall;
    function Get_JrnLineCharsList: WideString; safecall;
    function Get_JrnLineHeight: Integer; safecall;
    procedure Set_JrnLineHeight(pJrnLineHeight: Integer); safecall;
    function Get_JrnLineSpacing: Integer; safecall;
    procedure Set_JrnLineSpacing(pJrnLineSpacing: Integer); safecall;
    function Get_JrnLineWidth: Integer; safecall;
    function Get_JrnNearEnd: WordBool; safecall;
    function Get_MapMode: Integer; safecall;
    procedure Set_MapMode(pMapMode: Integer); safecall;
    function Get_RecEmpty: WordBool; safecall;
    function Get_RecLetterQuality: WordBool; safecall;
    procedure Set_RecLetterQuality(pRecLetterQuality: WordBool); safecall;
    function Get_RecLineChars: Integer; safecall;
    procedure Set_RecLineChars(pRecLineChars: Integer); safecall;
    function Get_RecLineCharsList: WideString; safecall;
    function Get_RecLineHeight: Integer; safecall;
    procedure Set_RecLineHeight(pRecLineHeight: Integer); safecall;
    function Get_RecLineSpacing: Integer; safecall;
    procedure Set_RecLineSpacing(pRecLineSpacing: Integer); safecall;
    function Get_RecLinesToPaperCut: Integer; safecall;
    function Get_RecLineWidth: Integer; safecall;
    function Get_RecNearEnd: WordBool; safecall;
    function Get_RecSidewaysMaxChars: Integer; safecall;
    function Get_RecSidewaysMaxLines: Integer; safecall;
    function Get_SlpEmpty: WordBool; safecall;
    function Get_SlpLetterQuality: WordBool; safecall;
    procedure Set_SlpLetterQuality(pSlpLetterQuality: WordBool); safecall;
    function Get_SlpLineChars: Integer; safecall;
    procedure Set_SlpLineChars(pSlpLineChars: Integer); safecall;
    function Get_SlpLineCharsList: WideString; safecall;
    function Get_SlpLineHeight: Integer; safecall;
    procedure Set_SlpLineHeight(pSlpLineHeight: Integer); safecall;
    function Get_SlpLinesNearEndToEnd: Integer; safecall;
    function Get_SlpLineSpacing: Integer; safecall;
    procedure Set_SlpLineSpacing(pSlpLineSpacing: Integer); safecall;
    function Get_SlpLineWidth: Integer; safecall;
    function Get_SlpMaxLines: Integer; safecall;
    function Get_SlpNearEnd: WordBool; safecall;
    function Get_SlpSidewaysMaxChars: Integer; safecall;
    function Get_SlpSidewaysMaxLines: Integer; safecall;
    function BeginInsertion(Timeout: Integer): Integer; safecall;
    function BeginRemoval(Timeout: Integer): Integer; safecall;
    function CutPaper(Percentage: Integer): Integer; safecall;
    function EndInsertion: Integer; safecall;
    function EndRemoval: Integer; safecall;
    function PrintBarCode(Station: Integer; const Data: WideString; Symbology: Integer; 
                          Height: Integer; Width: Integer; Alignment: Integer; TextPosition: Integer): Integer; safecall;
    function PrintBitmap(Station: Integer; const FileName: WideString; Width: Integer; 
                         Alignment: Integer): Integer; safecall;
    function PrintImmediate(Station: Integer; const Data: WideString): Integer; safecall;
    function PrintNormal(Station: Integer; const Data: WideString): Integer; safecall;
    function PrintTwoNormal(Stations: Integer; const Data1: WideString; const Data2: WideString): Integer; safecall;
    function RotatePrint(Station: Integer; Rotation: Integer): Integer; safecall;
    function SetBitmap(BitmapNumber: Integer; Station: Integer; const FileName: WideString; 
                       Width: Integer; Alignment: Integer): Integer; safecall;
    function SetLogo(Location: Integer; const Data: WideString): Integer; safecall;
    function Get_CapCharacterSet: Integer; safecall;
    function Get_CapTransaction: WordBool; safecall;
    function Get_ErrorLevel: Integer; safecall;
    function Get_ErrorString: WideString; safecall;
    function Get_FontTypefaceList: WideString; safecall;
    function Get_RecBarCodeRotationList: WideString; safecall;
    function Get_RotateSpecial: Integer; safecall;
    procedure Set_RotateSpecial(pRotateSpecial: Integer); safecall;
    function Get_SlpBarCodeRotationList: WideString; safecall;
    function TransactionPrint(Station: Integer; Control: Integer): Integer; safecall;
    function ValidateData(Station: Integer; const Data: WideString): Integer; safecall;
    function Get_BinaryConversion: Integer; safecall;
    procedure Set_BinaryConversion(pBinaryConversion: Integer); safecall;
    function Get_CapPowerReporting: Integer; safecall;
    function Get_PowerNotify: Integer; safecall;
    procedure Set_PowerNotify(pPowerNotify: Integer); safecall;
    function Get_PowerState: Integer; safecall;
    function Get_CapJrnCartridgeSensor: Integer; safecall;
    function Get_CapJrnColor: Integer; safecall;
    function Get_CapRecCartridgeSensor: Integer; safecall;
    function Get_CapRecColor: Integer; safecall;
    function Get_CapRecMarkFeed: Integer; safecall;
    function Get_CapSlpBothSidesPrint: WordBool; safecall;
    function Get_CapSlpCartridgeSensor: Integer; safecall;
    function Get_CapSlpColor: Integer; safecall;
    function Get_CartridgeNotify: Integer; safecall;
    procedure Set_CartridgeNotify(pCartridgeNotify: Integer); safecall;
    function Get_JrnCartridgeState: Integer; safecall;
    function Get_JrnCurrentCartridge: Integer; safecall;
    procedure Set_JrnCurrentCartridge(pJrnCurrentCartridge: Integer); safecall;
    function Get_RecCartridgeState: Integer; safecall;
    function Get_RecCurrentCartridge: Integer; safecall;
    procedure Set_RecCurrentCartridge(pRecCurrentCartridge: Integer); safecall;
    function Get_SlpCartridgeState: Integer; safecall;
    function Get_SlpCurrentCartridge: Integer; safecall;
    procedure Set_SlpCurrentCartridge(pSlpCurrentCartridge: Integer); safecall;
    function Get_SlpPrintSide: Integer; safecall;
    function ChangePrintSide(Side: Integer): Integer; safecall;
    function MarkFeed(Type_: Integer): Integer; safecall;
    property OpenResult: Integer read Get_OpenResult;
    property CheckHealthText: WideString read Get_CheckHealthText;
    property Claimed: WordBool read Get_Claimed;
    property DeviceEnabled: WordBool read Get_DeviceEnabled write Set_DeviceEnabled;
    property FreezeEvents: WordBool read Get_FreezeEvents write Set_FreezeEvents;
    property OutputID: Integer read Get_OutputID;
    property ResultCode: Integer read Get_ResultCode;
    property ResultCodeExtended: Integer read Get_ResultCodeExtended;
    property State: Integer read Get_State;
    property ControlObjectDescription: WideString read Get_ControlObjectDescription;
    property ControlObjectVersion: Integer read Get_ControlObjectVersion;
    property ServiceObjectDescription: WideString read Get_ServiceObjectDescription;
    property ServiceObjectVersion: Integer read Get_ServiceObjectVersion;
    property DeviceDescription: WideString read Get_DeviceDescription;
    property DeviceName: WideString read Get_DeviceName;
    property AsyncMode: WordBool read Get_AsyncMode write Set_AsyncMode;
    property CapConcurrentJrnRec: WordBool read Get_CapConcurrentJrnRec;
    property CapConcurrentJrnSlp: WordBool read Get_CapConcurrentJrnSlp;
    property CapConcurrentRecSlp: WordBool read Get_CapConcurrentRecSlp;
    property CapCoverSensor: WordBool read Get_CapCoverSensor;
    property CapJrn2Color: WordBool read Get_CapJrn2Color;
    property CapJrnBold: WordBool read Get_CapJrnBold;
    property CapJrnDhigh: WordBool read Get_CapJrnDhigh;
    property CapJrnDwide: WordBool read Get_CapJrnDwide;
    property CapJrnDwideDhigh: WordBool read Get_CapJrnDwideDhigh;
    property CapJrnEmptySensor: WordBool read Get_CapJrnEmptySensor;
    property CapJrnItalic: WordBool read Get_CapJrnItalic;
    property CapJrnNearEndSensor: WordBool read Get_CapJrnNearEndSensor;
    property CapJrnPresent: WordBool read Get_CapJrnPresent;
    property CapJrnUnderline: WordBool read Get_CapJrnUnderline;
    property CapRec2Color: WordBool read Get_CapRec2Color;
    property CapRecBarCode: WordBool read Get_CapRecBarCode;
    property CapRecBitmap: WordBool read Get_CapRecBitmap;
    property CapRecBold: WordBool read Get_CapRecBold;
    property CapRecDhigh: WordBool read Get_CapRecDhigh;
    property CapRecDwide: WordBool read Get_CapRecDwide;
    property CapRecDwideDhigh: WordBool read Get_CapRecDwideDhigh;
    property CapRecEmptySensor: WordBool read Get_CapRecEmptySensor;
    property CapRecItalic: WordBool read Get_CapRecItalic;
    property CapRecLeft90: WordBool read Get_CapRecLeft90;
    property CapRecNearEndSensor: WordBool read Get_CapRecNearEndSensor;
    property CapRecPapercut: WordBool read Get_CapRecPapercut;
    property CapRecPresent: WordBool read Get_CapRecPresent;
    property CapRecRight90: WordBool read Get_CapRecRight90;
    property CapRecRotate180: WordBool read Get_CapRecRotate180;
    property CapRecStamp: WordBool read Get_CapRecStamp;
    property CapRecUnderline: WordBool read Get_CapRecUnderline;
    property CapSlp2Color: WordBool read Get_CapSlp2Color;
    property CapSlpBarCode: WordBool read Get_CapSlpBarCode;
    property CapSlpBitmap: WordBool read Get_CapSlpBitmap;
    property CapSlpBold: WordBool read Get_CapSlpBold;
    property CapSlpDhigh: WordBool read Get_CapSlpDhigh;
    property CapSlpDwide: WordBool read Get_CapSlpDwide;
    property CapSlpDwideDhigh: WordBool read Get_CapSlpDwideDhigh;
    property CapSlpEmptySensor: WordBool read Get_CapSlpEmptySensor;
    property CapSlpFullslip: WordBool read Get_CapSlpFullslip;
    property CapSlpItalic: WordBool read Get_CapSlpItalic;
    property CapSlpLeft90: WordBool read Get_CapSlpLeft90;
    property CapSlpNearEndSensor: WordBool read Get_CapSlpNearEndSensor;
    property CapSlpPresent: WordBool read Get_CapSlpPresent;
    property CapSlpRight90: WordBool read Get_CapSlpRight90;
    property CapSlpRotate180: WordBool read Get_CapSlpRotate180;
    property CapSlpUnderline: WordBool read Get_CapSlpUnderline;
    property CharacterSet: Integer read Get_CharacterSet write Set_CharacterSet;
    property CharacterSetList: WideString read Get_CharacterSetList;
    property CoverOpen: WordBool read Get_CoverOpen;
    property ErrorStation: Integer read Get_ErrorStation;
    property FlagWhenIdle: WordBool read Get_FlagWhenIdle write Set_FlagWhenIdle;
    property JrnEmpty: WordBool read Get_JrnEmpty;
    property JrnLetterQuality: WordBool read Get_JrnLetterQuality write Set_JrnLetterQuality;
    property JrnLineChars: Integer read Get_JrnLineChars write Set_JrnLineChars;
    property JrnLineCharsList: WideString read Get_JrnLineCharsList;
    property JrnLineHeight: Integer read Get_JrnLineHeight write Set_JrnLineHeight;
    property JrnLineSpacing: Integer read Get_JrnLineSpacing write Set_JrnLineSpacing;
    property JrnLineWidth: Integer read Get_JrnLineWidth;
    property JrnNearEnd: WordBool read Get_JrnNearEnd;
    property MapMode: Integer read Get_MapMode write Set_MapMode;
    property RecEmpty: WordBool read Get_RecEmpty;
    property RecLetterQuality: WordBool read Get_RecLetterQuality write Set_RecLetterQuality;
    property RecLineChars: Integer read Get_RecLineChars write Set_RecLineChars;
    property RecLineCharsList: WideString read Get_RecLineCharsList;
    property RecLineHeight: Integer read Get_RecLineHeight write Set_RecLineHeight;
    property RecLineSpacing: Integer read Get_RecLineSpacing write Set_RecLineSpacing;
    property RecLinesToPaperCut: Integer read Get_RecLinesToPaperCut;
    property RecLineWidth: Integer read Get_RecLineWidth;
    property RecNearEnd: WordBool read Get_RecNearEnd;
    property RecSidewaysMaxChars: Integer read Get_RecSidewaysMaxChars;
    property RecSidewaysMaxLines: Integer read Get_RecSidewaysMaxLines;
    property SlpEmpty: WordBool read Get_SlpEmpty;
    property SlpLetterQuality: WordBool read Get_SlpLetterQuality write Set_SlpLetterQuality;
    property SlpLineChars: Integer read Get_SlpLineChars write Set_SlpLineChars;
    property SlpLineCharsList: WideString read Get_SlpLineCharsList;
    property SlpLineHeight: Integer read Get_SlpLineHeight write Set_SlpLineHeight;
    property SlpLinesNearEndToEnd: Integer read Get_SlpLinesNearEndToEnd;
    property SlpLineSpacing: Integer read Get_SlpLineSpacing write Set_SlpLineSpacing;
    property SlpLineWidth: Integer read Get_SlpLineWidth;
    property SlpMaxLines: Integer read Get_SlpMaxLines;
    property SlpNearEnd: WordBool read Get_SlpNearEnd;
    property SlpSidewaysMaxChars: Integer read Get_SlpSidewaysMaxChars;
    property SlpSidewaysMaxLines: Integer read Get_SlpSidewaysMaxLines;
    property CapCharacterSet: Integer read Get_CapCharacterSet;
    property CapTransaction: WordBool read Get_CapTransaction;
    property ErrorLevel: Integer read Get_ErrorLevel;
    property ErrorString: WideString read Get_ErrorString;
    property FontTypefaceList: WideString read Get_FontTypefaceList;
    property RecBarCodeRotationList: WideString read Get_RecBarCodeRotationList;
    property RotateSpecial: Integer read Get_RotateSpecial write Set_RotateSpecial;
    property SlpBarCodeRotationList: WideString read Get_SlpBarCodeRotationList;
    property BinaryConversion: Integer read Get_BinaryConversion write Set_BinaryConversion;
    property CapPowerReporting: Integer read Get_CapPowerReporting;
    property PowerNotify: Integer read Get_PowerNotify write Set_PowerNotify;
    property PowerState: Integer read Get_PowerState;
    property CapJrnCartridgeSensor: Integer read Get_CapJrnCartridgeSensor;
    property CapJrnColor: Integer read Get_CapJrnColor;
    property CapRecCartridgeSensor: Integer read Get_CapRecCartridgeSensor;
    property CapRecColor: Integer read Get_CapRecColor;
    property CapRecMarkFeed: Integer read Get_CapRecMarkFeed;
    property CapSlpBothSidesPrint: WordBool read Get_CapSlpBothSidesPrint;
    property CapSlpCartridgeSensor: Integer read Get_CapSlpCartridgeSensor;
    property CapSlpColor: Integer read Get_CapSlpColor;
    property CartridgeNotify: Integer read Get_CartridgeNotify write Set_CartridgeNotify;
    property JrnCartridgeState: Integer read Get_JrnCartridgeState;
    property JrnCurrentCartridge: Integer read Get_JrnCurrentCartridge write Set_JrnCurrentCartridge;
    property RecCartridgeState: Integer read Get_RecCartridgeState;
    property RecCurrentCartridge: Integer read Get_RecCurrentCartridge write Set_RecCurrentCartridge;
    property SlpCartridgeState: Integer read Get_SlpCartridgeState;
    property SlpCurrentCartridge: Integer read Get_SlpCurrentCartridge write Set_SlpCurrentCartridge;
    property SlpPrintSide: Integer read Get_SlpPrintSide;
    // IOPOSPOSPrinter_1_7
    function Get_CapMapCharacterSet: WordBool; safecall;
    function Get_MapCharacterSet: WordBool; safecall;
    procedure Set_MapCharacterSet(pMapCharacterSet: WordBool); safecall;
    function Get_RecBitmapRotationList: WideString; safecall;
    function Get_SlpBitmapRotationList: WideString; safecall;
    property CapMapCharacterSet: WordBool read Get_CapMapCharacterSet;
    property MapCharacterSet: WordBool read Get_MapCharacterSet write Set_MapCharacterSet;
    property RecBitmapRotationList: WideString read Get_RecBitmapRotationList;
    property SlpBitmapRotationList: WideString read Get_SlpBitmapRotationList;
    // IOPOSPOSPrinter_1_8
    function Get_CapStatisticsReporting: WordBool; safecall;
    function Get_CapUpdateStatistics: WordBool; safecall;
    function ResetStatistics(const StatisticsBuffer: WideString): Integer; safecall;
    function RetrieveStatistics(var pStatisticsBuffer: WideString): Integer; safecall;
    function UpdateStatistics(const StatisticsBuffer: WideString): Integer; safecall;
    property CapStatisticsReporting: WordBool read Get_CapStatisticsReporting;
    property CapUpdateStatistics: WordBool read Get_CapUpdateStatistics;
    // IOPOSPOSPrinter_1_9
    function Get_CapCompareFirmwareVersion: WordBool; safecall;
    function Get_CapUpdateFirmware: WordBool; safecall;
    function CompareFirmwareVersion(const FirmwareFileName: WideString; out pResult: Integer): Integer; safecall;
    function UpdateFirmware(const FirmwareFileName: WideString): Integer; safecall;
    function Get_CapConcurrentPageMode: WordBool; safecall;
    function Get_CapRecPageMode: WordBool; safecall;
    function Get_CapSlpPageMode: WordBool; safecall;
    function Get_PageModeArea: WideString; safecall;
    function Get_PageModeDescriptor: Integer; safecall;
    function Get_PageModeHorizontalPosition: Integer; safecall;
    procedure Set_PageModeHorizontalPosition(pPageModeHorizontalPosition: Integer); safecall;
    function Get_PageModePrintArea: WideString; safecall;
    procedure Set_PageModePrintArea(const pPageModePrintArea: WideString); safecall;
    function Get_PageModePrintDirection: Integer; safecall;
    procedure Set_PageModePrintDirection(pPageModePrintDirection: Integer); safecall;
    function Get_PageModeStation: Integer; safecall;
    procedure Set_PageModeStation(pPageModeStation: Integer); safecall;
    function Get_PageModeVerticalPosition: Integer; safecall;
    procedure Set_PageModeVerticalPosition(pPageModeVerticalPosition: Integer); safecall;
    function ClearPrintArea: Integer; safecall;
    function PageModePrint(Control: Integer): Integer; safecall;
    property CapCompareFirmwareVersion: WordBool read Get_CapCompareFirmwareVersion;
    property CapUpdateFirmware: WordBool read Get_CapUpdateFirmware;
    property CapConcurrentPageMode: WordBool read Get_CapConcurrentPageMode;
    property CapRecPageMode: WordBool read Get_CapRecPageMode;
    property CapSlpPageMode: WordBool read Get_CapSlpPageMode;
    property PageModeArea: WideString read Get_PageModeArea;
    property PageModeDescriptor: Integer read Get_PageModeDescriptor;
    property PageModeHorizontalPosition: Integer read Get_PageModeHorizontalPosition write Set_PageModeHorizontalPosition;
    property PageModePrintArea: WideString read Get_PageModePrintArea write Set_PageModePrintArea;
    property PageModePrintDirection: Integer read Get_PageModePrintDirection write Set_PageModePrintDirection;
    property PageModeStation: Integer read Get_PageModeStation write Set_PageModeStation;
    property PageModeVerticalPosition: Integer read Get_PageModeVerticalPosition write Set_PageModeVerticalPosition;
    // IOPOSPOSPrinter_1_10
    function PrintMemoryBitmap(Station: Integer; const Data: WideString; Type_: Integer;
                               Width: Integer; Alignment: Integer): Integer; safecall;
    // IOPOSPOSPrinter_1_13
    function Get_CapRecRuledLine: Integer; safecall;
    function Get_CapSlpRuledLine: Integer; safecall;
    function DrawRuledLine(Station: Integer; const PositionList: WideString;
                           LineDirection: Integer; LineWidth: Integer; LineStyle: Integer;
                           LineColor: Integer): Integer; safecall;
    property CapRecRuledLine: Integer read Get_CapRecRuledLine;
    property CapSlpRuledLine: Integer read Get_CapSlpRuledLine;
  end;

implementation

{ TMockPOSPrinter2 }

// IDispatch

function TMockPOSPrinter2.GetIDsOfNames(const IID: TGUID; Names: Pointer;
  NameCount, LocaleID: Integer; DispIDs: Pointer): HResult;
begin
  Result := E_NOTIMPL;
end;

function TMockPOSPrinter2.GetTypeInfo(Index, LocaleID: Integer;
  out TypeInfo): HResult;
begin
  Result := E_NOTIMPL;
end;

function TMockPOSPrinter2.GetTypeInfoCount(out Count: Integer): HResult;
begin
  Result := E_NOTIMPL;
end;

function TMockPOSPrinter2.Invoke(DispID: Integer; const IID: TGUID;
  LocaleID: Integer; Flags: Word; var Params; VarResult, ExcepInfo,
  ArgErr: Pointer): HResult;
begin
  Result := E_NOTIMPL;
end;

function TMockPOSPrinter2.BeginInsertion(Timeout: Integer): Integer;
begin
  Result := AddCall('BeginInsertion').WithParams([Timeout]).ReturnValue;
end;

function TMockPOSPrinter2.BeginRemoval(Timeout: Integer): Integer;
begin
  Result := AddCall('BeginRemoval').WithParams([Timeout]).ReturnValue;
end;

function TMockPOSPrinter2.ChangePrintSide(Side: Integer): Integer;
begin
  Result := AddCall('ChangePrintSide').WithParams([Side]).ReturnValue;
end;

function TMockPOSPrinter2.CheckHealth(Level: Integer): Integer;
begin
  Result := AddCall('CheckHealth').WithParams([Level]).ReturnValue;
end;

function TMockPOSPrinter2.ClaimDevice(Timeout: Integer): Integer;
begin
  Result := AddCall('ClaimDevice').WithParams([Timeout]).ReturnValue;
end;

function TMockPOSPrinter2.ClearOutput: Integer;
begin
  Result := AddCall('ClearOutput').ReturnValue;
end;

function TMockPOSPrinter2.ClearPrintArea: Integer;
begin
  Result := AddCall('ClearPrintArea').ReturnValue;
end;

function TMockPOSPrinter2.Close: Integer;
begin
  Result := AddCall('Close').ReturnValue;
end;

function TMockPOSPrinter2.CompareFirmwareVersion(
  const FirmwareFileName: WideString; out pResult: Integer): Integer;
begin
  Result := AddCall('CompareFirmwareVersion').WithParams([FirmwareFileName, pResult]).ReturnValue;
end;

function TMockPOSPrinter2.CutPaper(Percentage: Integer): Integer;
begin
  Result := AddCall('CutPaper').WithParams([Percentage]).ReturnValue;
end;

function TMockPOSPrinter2.DirectIO(Command: Integer; var pData: Integer;
  var pString: WideString): Integer;
var
  Method: TMockMethod;
begin
  Method := AddCall('DirectIO').WithParams([Command, pData, pString]);
  Result := Method.ReturnValue;
  pData := Method.OutParams[0];
  pString := Method.OutParams[1];
end;

function TMockPOSPrinter2.DrawRuledLine(Station: Integer;
  const PositionList: WideString; LineDirection, LineWidth, LineStyle,
  LineColor: Integer): Integer;
begin
  Result := AddCall('DrawRuledLine').WithParams([Station, PositionList,
    LineDirection, LineWidth, LineStyle, LineColor]).ReturnValue;
end;

function TMockPOSPrinter2.EndInsertion: Integer;
begin
  Result := AddCall('EndInsertion').ReturnValue;
end;

function TMockPOSPrinter2.EndRemoval: Integer;
begin
  Result := AddCall('EndRemoval').ReturnValue;
end;

function TMockPOSPrinter2.Get_AsyncMode: WordBool;
begin
  Result := AddCall('Get_AsyncMode').ReturnValue;
end;

function TMockPOSPrinter2.Get_BinaryConversion: Integer;
begin
  Result := AddCall('Get_BinaryConversion').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapCharacterSet: Integer;
begin
  Result := AddCall('Get_CapCharacterSet').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapCompareFirmwareVersion: WordBool;
begin
  Result := AddCall('Get_CapCompareFirmwareVersion').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapConcurrentJrnRec: WordBool;
begin
  Result := AddCall('Get_CapConcurrentJrnRec').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapConcurrentJrnSlp: WordBool;
begin
  Result := AddCall('Get_CapConcurrentJrnSlp').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapConcurrentPageMode: WordBool;
begin
  Result := AddCall('Get_CapConcurrentPageMode').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapConcurrentRecSlp: WordBool;
begin
  Result := AddCall('Get_CapConcurrentRecSlp').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapCoverSensor: WordBool;
begin
  Result := AddCall('Get_CapCoverSensor').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapJrn2Color: WordBool;
begin
  Result := AddCall('Get_CapJrn2Color').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapJrnBold: WordBool;
begin
  Result := AddCall('Get_CapJrnBold').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapJrnCartridgeSensor: Integer;
begin
  Result := AddCall('Get_CapJrnCartridgeSensor').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapJrnColor: Integer;
begin
  Result := AddCall('Get_CapJrnColor').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapJrnDhigh: WordBool;
begin
  Result := AddCall('Get_CapJrnDhigh').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapJrnDwide: WordBool;
begin
  Result := AddCall('Get_CapJrnDwide').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapJrnDwideDhigh: WordBool;
begin
  Result := AddCall('Get_CapJrnDwideDhigh').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapJrnEmptySensor: WordBool;
begin
  Result := AddCall('Get_CapJrnEmptySensor').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapJrnItalic: WordBool;
begin
  Result := AddCall('Get_CapJrnItalic').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapJrnNearEndSensor: WordBool;
begin
  Result := AddCall('Get_CapJrnNearEndSensor').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapJrnPresent: WordBool;
begin
  Result := AddCall('Get_CapJrnPresent').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapJrnUnderline: WordBool;
begin
  Result := AddCall('Get_CapJrnUnderline').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapMapCharacterSet: WordBool;
begin
  Result := AddCall('Get_CapMapCharacterSet').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapPowerReporting: Integer;
begin
  Result := AddCall('Get_CapPowerReporting').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapRec2Color: WordBool;
begin
  Result := AddCall('Get_CapRec2Color').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapRecBarCode: WordBool;
begin
  Result := AddCall('Get_CapRecBarCode').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapRecBitmap: WordBool;
begin
  Result := AddCall('Get_CapRecBitmap').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapRecBold: WordBool;
begin
  Result := AddCall('Get_CapRecBold').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapRecCartridgeSensor: Integer;
begin
  Result := AddCall('Get_CapRecCartridgeSensor').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapRecColor: Integer;
begin
  Result := AddCall('Get_CapRecColor').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapRecDhigh: WordBool;
begin
  Result := AddCall('Get_CapRecDhigh').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapRecDwide: WordBool;
begin
  Result := AddCall('Get_CapRecDwide').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapRecDwideDhigh: WordBool;
begin
  Result := AddCall('Get_CapRecDwideDhigh').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapRecEmptySensor: WordBool;
begin
  Result := AddCall('Get_CapRecEmptySensor').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapRecItalic: WordBool;
begin
  Result := AddCall('Get_CapRecItalic').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapRecLeft90: WordBool;
begin
  Result := AddCall('Get_CapRecLeft90').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapRecMarkFeed: Integer;
begin
  Result := AddCall('Get_CapRecMarkFeed').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapRecNearEndSensor: WordBool;
begin
  Result := AddCall('Get_CapRecNearEndSensor').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapRecPageMode: WordBool;
begin
  Result := AddCall('Get_CapRecPageMode').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapRecPapercut: WordBool;
begin
  Result := AddCall('Get_CapRecPapercut').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapRecPresent: WordBool;
begin
  Result := AddCall('Get_CapRecPresent').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapRecRight90: WordBool;
begin
  Result := AddCall('Get_CapRecRight90').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapRecRotate180: WordBool;
begin
  Result := AddCall('Get_CapRecRotate180').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapRecRuledLine: Integer;
begin
  Result := AddCall('Get_CapRecRuledLine').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapRecStamp: WordBool;
begin
  Result := AddCall('Get_CapRecStamp').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapRecUnderline: WordBool;
begin
  Result := AddCall('Get_CapRecUnderline').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapSlp2Color: WordBool;
begin
  Result := AddCall('Get_CapSlp2Color').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapSlpBarCode: WordBool;
begin
  Result := AddCall('Get_CapSlpBarCode').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapSlpBitmap: WordBool;
begin
  Result := AddCall('Get_CapSlpBitmap').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapSlpBold: WordBool;
begin
  Result := AddCall('Get_CapSlpBold').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapSlpBothSidesPrint: WordBool;
begin
  Result := AddCall('Get_CapSlpBothSidesPrint').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapSlpCartridgeSensor: Integer;
begin
  Result := AddCall('Get_CapSlpCartridgeSensor').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapSlpColor: Integer;
begin
  Result := AddCall('Get_CapSlpColor').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapSlpDhigh: WordBool;
begin
  Result := AddCall('Get_CapSlpDhigh').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapSlpDwide: WordBool;
begin
  Result := AddCall('Get_CapSlpDwide').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapSlpDwideDhigh: WordBool;
begin
  Result := AddCall('Get_CapSlpDwideDhigh').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapSlpEmptySensor: WordBool;
begin
  Result := AddCall('Get_CapSlpEmptySensor').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapSlpFullslip: WordBool;
begin
  Result := AddCall('Get_CapSlpFullslip').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapSlpItalic: WordBool;
begin
  Result := AddCall('Get_CapSlpItalic').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapSlpLeft90: WordBool;
begin
  Result := AddCall('Get_CapSlpLeft90').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapSlpNearEndSensor: WordBool;
begin
  Result := AddCall('Get_CapSlpNearEndSensor').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapSlpPageMode: WordBool;
begin
  Result := AddCall('Get_CapSlpPageMode').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapSlpPresent: WordBool;
begin
  Result := AddCall('Get_CapSlpPresent').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapSlpRight90: WordBool;
begin
  Result := AddCall('Get_CapSlpRight90').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapSlpRotate180: WordBool;
begin
  Result := AddCall('Get_CapSlpRotate180').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapSlpRuledLine: Integer;
begin
  Result := AddCall('Get_CapSlpRuledLine').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapSlpUnderline: WordBool;
begin
  Result := AddCall('Get_CapSlpUnderline').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapStatisticsReporting: WordBool;
begin
  Result := AddCall('Get_CapStatisticsReporting').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapTransaction: WordBool;
begin
  Result := AddCall('Get_CapTransaction').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapUpdateFirmware: WordBool;
begin
  Result := AddCall('Get_CapUpdateFirmware').ReturnValue;
end;

function TMockPOSPrinter2.Get_CapUpdateStatistics: WordBool;
begin
  Result := AddCall('Get_CapUpdateStatistics').ReturnValue;
end;

function TMockPOSPrinter2.Get_CartridgeNotify: Integer;
begin
  Result := AddCall('Get_CartridgeNotify').ReturnValue;
end;

function TMockPOSPrinter2.Get_CharacterSet: Integer;
begin
  Result := AddCall('Get_CharacterSet').ReturnValue;
end;

function TMockPOSPrinter2.Get_CharacterSetList: WideString;
begin
  Result := AddCall('Get_CharacterSetList').ReturnValue;
end;

function TMockPOSPrinter2.Get_CheckHealthText: WideString;
begin
  Result := AddCall('Get_CheckHealthText').ReturnValue;
end;

function TMockPOSPrinter2.Get_Claimed: WordBool;
begin
  Result := AddCall('Get_Claimed').ReturnValue;
end;

function TMockPOSPrinter2.Get_ControlObjectDescription: WideString;
begin
  Result := AddCall('Get_ControlObjectDescription').ReturnValue;
end;

function TMockPOSPrinter2.Get_ControlObjectVersion: Integer;
begin
  Result := AddCall('Get_ControlObjectVersion').ReturnValue;
end;

function TMockPOSPrinter2.Get_CoverOpen: WordBool;
begin
  Result := AddCall('Get_CoverOpen').ReturnValue;
end;

function TMockPOSPrinter2.Get_DeviceDescription: WideString;
begin
  Result := AddCall('Get_DeviceDescription').ReturnValue;
end;

function TMockPOSPrinter2.Get_DeviceEnabled: WordBool;
begin
  Result := AddCall('Get_DeviceEnabled').ReturnValue;
end;

function TMockPOSPrinter2.Get_DeviceName: WideString;
begin
  Result := AddCall('Get_DeviceName').ReturnValue;
end;

function TMockPOSPrinter2.Get_ErrorLevel: Integer;
begin
  Result := AddCall('Get_ErrorLevel').ReturnValue;
end;

function TMockPOSPrinter2.Get_ErrorStation: Integer;
begin
  Result := AddCall('Get_ErrorStation').ReturnValue;
end;

function TMockPOSPrinter2.Get_ErrorString: WideString;
begin
  Result := AddCall('Get_ErrorString').ReturnValue;
end;

function TMockPOSPrinter2.Get_FlagWhenIdle: WordBool;
begin
  Result := AddCall('Get_FlagWhenIdle').ReturnValue;
end;

function TMockPOSPrinter2.Get_FontTypefaceList: WideString;
begin
  Result := AddCall('Get_FontTypefaceList').ReturnValue;
end;

function TMockPOSPrinter2.Get_FreezeEvents: WordBool;
begin
  Result := AddCall('Get_FreezeEvents').ReturnValue;
end;

function TMockPOSPrinter2.Get_JrnCartridgeState: Integer;
begin
  Result := AddCall('Get_JrnCartridgeState').ReturnValue;
end;

function TMockPOSPrinter2.Get_JrnCurrentCartridge: Integer;
begin
  Result := AddCall('Get_JrnCurrentCartridge').ReturnValue;
end;

function TMockPOSPrinter2.Get_JrnEmpty: WordBool;
begin
  Result := AddCall('Get_JrnEmpty').ReturnValue;
end;

function TMockPOSPrinter2.Get_JrnLetterQuality: WordBool;
begin
  Result := AddCall('Get_JrnLetterQuality').ReturnValue;
end;

function TMockPOSPrinter2.Get_JrnLineChars: Integer;
begin
  Result := AddCall('Get_JrnLineChars').ReturnValue;
end;

function TMockPOSPrinter2.Get_JrnLineCharsList: WideString;
begin
  Result := AddCall('Get_JrnLineCharsList').ReturnValue;
end;

function TMockPOSPrinter2.Get_JrnLineHeight: Integer;
begin
  Result := AddCall('Get_JrnLineHeight').ReturnValue;
end;

function TMockPOSPrinter2.Get_JrnLineSpacing: Integer;
begin
  Result := AddCall('Get_JrnLineSpacing').ReturnValue;
end;

function TMockPOSPrinter2.Get_JrnLineWidth: Integer;
begin
  Result := AddCall('Get_JrnLineWidth').ReturnValue;
end;

function TMockPOSPrinter2.Get_JrnNearEnd: WordBool;
begin
  Result := AddCall('Get_JrnNearEnd').ReturnValue;
end;

function TMockPOSPrinter2.Get_MapCharacterSet: WordBool;
begin
  Result := AddCall('Get_MapCharacterSet').ReturnValue;
end;

function TMockPOSPrinter2.Get_MapMode: Integer;
begin
  Result := AddCall('Get_MapMode').ReturnValue;
end;

function TMockPOSPrinter2.Get_OpenResult: Integer;
begin
  Result := AddCall('Get_OpenResult').ReturnValue;
end;

function TMockPOSPrinter2.Get_OutputID: Integer;
begin
  Result := AddCall('Get_OutputID').ReturnValue;
end;

function TMockPOSPrinter2.Get_PageModeArea: WideString;
begin
  Result := AddCall('Get_PageModeArea').ReturnValue;
end;

function TMockPOSPrinter2.Get_PageModeDescriptor: Integer;
begin
  Result := AddCall('Get_PageModeDescriptor').ReturnValue;
end;

function TMockPOSPrinter2.Get_PageModeHorizontalPosition: Integer;
begin
  Result := AddCall('Get_PageModeHorizontalPosition').ReturnValue;
end;

function TMockPOSPrinter2.Get_PageModePrintArea: WideString;
begin
  Result := AddCall('Get_PageModePrintArea').ReturnValue;
end;

function TMockPOSPrinter2.Get_PageModePrintDirection: Integer;
begin
  Result := AddCall('Get_PageModePrintDirection').ReturnValue;
end;

function TMockPOSPrinter2.Get_PageModeStation: Integer;
begin
  Result := AddCall('Get_PageModeStation').ReturnValue;
end;

function TMockPOSPrinter2.Get_PageModeVerticalPosition: Integer;
begin
  Result := AddCall('Get_PageModeVerticalPosition').ReturnValue;
end;

function TMockPOSPrinter2.Get_PowerNotify: Integer;
begin
  Result := AddCall('Get_PowerNotify').ReturnValue;
end;

function TMockPOSPrinter2.Get_PowerState: Integer;
begin
  Result := AddCall('Get_PowerState').ReturnValue;
end;

function TMockPOSPrinter2.Get_RecBarCodeRotationList: WideString;
begin
  Result := AddCall('Get_RecBarCodeRotationList').ReturnValue;
end;

function TMockPOSPrinter2.Get_RecBitmapRotationList: WideString;
begin
  Result := AddCall('Get_RecBitmapRotationList').ReturnValue;
end;

function TMockPOSPrinter2.Get_RecCartridgeState: Integer;
begin
  Result := AddCall('Get_RecCartridgeState').ReturnValue;
end;

function TMockPOSPrinter2.Get_RecCurrentCartridge: Integer;
begin
  Result := AddCall('Get_RecCurrentCartridge').ReturnValue;
end;

function TMockPOSPrinter2.Get_RecEmpty: WordBool;
begin
  Result := AddCall('Get_RecEmpty').ReturnValue;
end;

function TMockPOSPrinter2.Get_RecLetterQuality: WordBool;
begin
  Result := AddCall('Get_RecLetterQuality').ReturnValue;
end;

function TMockPOSPrinter2.Get_RecLineChars: Integer;
begin
  Result := AddCall('Get_RecLineChars').ReturnValue;
end;

function TMockPOSPrinter2.Get_RecLineCharsList: WideString;
begin
  Result := AddCall('Get_RecLineCharsList').ReturnValue;
end;

function TMockPOSPrinter2.Get_RecLineHeight: Integer;
begin
  Result := AddCall('Get_RecLineHeight').ReturnValue;
end;

function TMockPOSPrinter2.Get_RecLineSpacing: Integer;
begin
  Result := AddCall('Get_RecLineSpacing').ReturnValue;
end;

function TMockPOSPrinter2.Get_RecLinesToPaperCut: Integer;
begin
  Result := AddCall('Get_RecLinesToPaperCut').ReturnValue;
end;

function TMockPOSPrinter2.Get_RecLineWidth: Integer;
begin
  Result := AddCall('Get_RecLineWidth').ReturnValue;
end;

function TMockPOSPrinter2.Get_RecNearEnd: WordBool;
begin
  Result := AddCall('Get_RecNearEnd').ReturnValue;
end;

function TMockPOSPrinter2.Get_RecSidewaysMaxChars: Integer;
begin
  Result := AddCall('Get_RecSidewaysMaxChars').ReturnValue;
end;

function TMockPOSPrinter2.Get_RecSidewaysMaxLines: Integer;
begin
  Result := AddCall('Get_RecSidewaysMaxLines').ReturnValue;
end;

function TMockPOSPrinter2.Get_ResultCode: Integer;
begin
  Result := AddCall('Get_ResultCode').ReturnValue;
end;

function TMockPOSPrinter2.Get_ResultCodeExtended: Integer;
begin
  Result := AddCall('Get_ResultCodeExtended').ReturnValue;
end;

function TMockPOSPrinter2.Get_RotateSpecial: Integer;
begin
  Result := AddCall('Get_RotateSpecial').ReturnValue;
end;

function TMockPOSPrinter2.Get_ServiceObjectDescription: WideString;
begin
  Result := AddCall('Get_ServiceObjectDescription').ReturnValue;
end;

function TMockPOSPrinter2.Get_ServiceObjectVersion: Integer;
begin
  Result := AddCall('Get_ServiceObjectVersion').ReturnValue;
end;

function TMockPOSPrinter2.Get_SlpBarCodeRotationList: WideString;
begin
  Result := AddCall('Get_SlpBarCodeRotationList').ReturnValue;
end;

function TMockPOSPrinter2.Get_SlpBitmapRotationList: WideString;
begin
  Result := AddCall('Get_SlpBitmapRotationList').ReturnValue;
end;

function TMockPOSPrinter2.Get_SlpCartridgeState: Integer;
begin
  Result := AddCall('Get_SlpCartridgeState').ReturnValue;
end;

function TMockPOSPrinter2.Get_SlpCurrentCartridge: Integer;
begin
  Result := AddCall('Get_SlpCurrentCartridge').ReturnValue;
end;

function TMockPOSPrinter2.Get_SlpEmpty: WordBool;
begin
  Result := AddCall('Get_SlpEmpty').ReturnValue;
end;

function TMockPOSPrinter2.Get_SlpLetterQuality: WordBool;
begin
  Result := AddCall('Get_SlpLetterQuality').ReturnValue;
end;

function TMockPOSPrinter2.Get_SlpLineChars: Integer;
begin
  Result := AddCall('Get_SlpLineChars').ReturnValue;
end;

function TMockPOSPrinter2.Get_SlpLineCharsList: WideString;
begin
  Result := AddCall('Get_SlpLineCharsList').ReturnValue;
end;

function TMockPOSPrinter2.Get_SlpLineHeight: Integer;
begin
  Result := AddCall('Get_SlpLineHeight').ReturnValue;
end;

function TMockPOSPrinter2.Get_SlpLinesNearEndToEnd: Integer;
begin
  Result := AddCall('Get_SlpLinesNearEndToEnd').ReturnValue;
end;

function TMockPOSPrinter2.Get_SlpLineSpacing: Integer;
begin
  Result := AddCall('Get_SlpLineSpacing').ReturnValue;
end;

function TMockPOSPrinter2.Get_SlpLineWidth: Integer;
begin
  Result := AddCall('Get_SlpLineWidth').ReturnValue;
end;

function TMockPOSPrinter2.Get_SlpMaxLines: Integer;
begin
  Result := AddCall('Get_SlpMaxLines').ReturnValue;
end;

function TMockPOSPrinter2.Get_SlpNearEnd: WordBool;
begin
  Result := AddCall('Get_SlpNearEnd').ReturnValue;
end;

function TMockPOSPrinter2.Get_SlpPrintSide: Integer;
begin
  Result := AddCall('Get_SlpPrintSide').ReturnValue;
end;

function TMockPOSPrinter2.Get_SlpSidewaysMaxChars: Integer;
begin
  Result := AddCall('Get_SlpSidewaysMaxChars').ReturnValue;
end;

function TMockPOSPrinter2.Get_SlpSidewaysMaxLines: Integer;
begin
  Result := AddCall('Get_SlpSidewaysMaxLines').ReturnValue;
end;

function TMockPOSPrinter2.Get_State: Integer;
begin
  Result := AddCall('Get_State').ReturnValue;
end;

function TMockPOSPrinter2.MarkFeed(Type_: Integer): Integer;
begin
  Result := AddCall('MarkFeed').WithParams([Type_]).ReturnValue;
end;

function TMockPOSPrinter2.Open(const DeviceName: WideString): Integer;
begin
  Result := AddCall('Open').WithParams([DeviceName]).ReturnValue;
end;

function TMockPOSPrinter2.PageModePrint(Control: Integer): Integer;
begin
  Result := AddCall('PageModePrint').WithParams([Control]).ReturnValue;
end;

function TMockPOSPrinter2.PrintBarCode(Station: Integer;
  const Data: WideString; Symbology, Height, Width, Alignment,
  TextPosition: Integer): Integer;
begin
  Result := AddCall('PrintBarCode').WithParams([Station, Data, Symbology,
    Height, Width, Alignment, TextPosition]).ReturnValue;
end;

function TMockPOSPrinter2.PrintBitmap(Station: Integer;
  const FileName: WideString; Width, Alignment: Integer): Integer;
begin
  Result := AddCall('PrintBitmap').WithParams([
    Station, FileName, Width, Alignment]).ReturnValue;
end;

function TMockPOSPrinter2.PrintImmediate(Station: Integer;
  const Data: WideString): Integer;
begin
  Result := AddCall('PrintImmediate').WithParams([Station, Data]).ReturnValue;
end;

function TMockPOSPrinter2.PrintMemoryBitmap(Station: Integer;
  const Data: WideString; Type_, Width, Alignment: Integer): Integer;
begin
  Result := AddCall('PrintMemoryBitmap').WithParams([
    Station, Data, Type_, Width, Alignment]).ReturnValue;
end;

function TMockPOSPrinter2.PrintNormal(Station: Integer;
  const Data: WideString): Integer;
begin
  //ODS('"' + Data + '"');
  //ODS(StrToHex(Data));
  Result := AddCall('PrintNormal').WithParams([Station, Data]).ReturnValue;
end;

function TMockPOSPrinter2.PrintTwoNormal(Stations: Integer; const Data1,
  Data2: WideString): Integer;
begin
  Result := AddCall('PrintTwoNormal').WithParams([
    Stations, Data1, Data2]).ReturnValue;
end;

function TMockPOSPrinter2.ReleaseDevice: Integer;
begin
  Result := AddCall('ReleaseDevice').ReturnValue;
end;

function TMockPOSPrinter2.ResetStatistics(
  const StatisticsBuffer: WideString): Integer;
begin
  Result := AddCall('ResetStatistics').WithParams([
    StatisticsBuffer]).ReturnValue;
end;

function TMockPOSPrinter2.RetrieveStatistics(
  var pStatisticsBuffer: WideString): Integer;
var
  Method: TMockMethod;
begin
  Method := AddCall('RetrieveStatistics').WithParams([pStatisticsBuffer]);
  Result := Method.ReturnValue;
  pStatisticsBuffer := Method.OutParams[0];
end;

function TMockPOSPrinter2.RotatePrint(Station, Rotation: Integer): Integer;
begin
  Result := AddCall('RotatePrint').WithParams([
    Station, Rotation]).ReturnValue;
end;

procedure TMockPOSPrinter2.Set_AsyncMode(pAsyncMode: WordBool);
begin
  AddCall('Set_AsyncMode').WithParams([pAsyncMode]);
end;

procedure TMockPOSPrinter2.Set_BinaryConversion(
  pBinaryConversion: Integer);
begin
  AddCall('Set_BinaryConversion').WithParams([pBinaryConversion]);
end;

procedure TMockPOSPrinter2.Set_CartridgeNotify(pCartridgeNotify: Integer);
begin
  AddCall('Set_CartridgeNotify').WithParams([pCartridgeNotify]);
end;

procedure TMockPOSPrinter2.Set_CharacterSet(pCharacterSet: Integer);
begin
  AddCall('Set_CharacterSet').WithParams([pCharacterSet]);
end;

procedure TMockPOSPrinter2.Set_DeviceEnabled(pDeviceEnabled: WordBool);
begin
  AddCall('Set_DeviceEnabled').WithParams([pDeviceEnabled]);
end;

procedure TMockPOSPrinter2.Set_FlagWhenIdle(pFlagWhenIdle: WordBool);
begin
  AddCall('Set_FlagWhenIdle').WithParams([pFlagWhenIdle]);
end;

procedure TMockPOSPrinter2.Set_FreezeEvents(pFreezeEvents: WordBool);
begin
  AddCall('Set_FreezeEvents').WithParams([pFreezeEvents]);
end;

procedure TMockPOSPrinter2.Set_JrnCurrentCartridge(
  pJrnCurrentCartridge: Integer);
begin
  AddCall('Set_JrnCurrentCartridge').WithParams([pJrnCurrentCartridge]);
end;

procedure TMockPOSPrinter2.Set_JrnLetterQuality(
  pJrnLetterQuality: WordBool);
begin
  AddCall('Set_JrnLetterQuality').WithParams([pJrnLetterQuality]);
end;

procedure TMockPOSPrinter2.Set_JrnLineChars(pJrnLineChars: Integer);
begin
  AddCall('Set_JrnLineChars').WithParams([pJrnLineChars]);
end;

procedure TMockPOSPrinter2.Set_JrnLineHeight(pJrnLineHeight: Integer);
begin
  AddCall('Set_JrnLineHeight').WithParams([pJrnLineHeight]);
end;

procedure TMockPOSPrinter2.Set_JrnLineSpacing(pJrnLineSpacing: Integer);
begin
  AddCall('Set_JrnLineSpacing').WithParams([pJrnLineSpacing]);
end;

procedure TMockPOSPrinter2.Set_MapCharacterSet(pMapCharacterSet: WordBool);
begin
  AddCall('Set_MapCharacterSet').WithParams([pMapCharacterSet]);
end;

procedure TMockPOSPrinter2.Set_MapMode(pMapMode: Integer);
begin
  AddCall('Set_MapMode').WithParams([pMapMode]);
end;

procedure TMockPOSPrinter2.Set_PageModeHorizontalPosition(
  pPageModeHorizontalPosition: Integer);
begin
  AddCall('Set_PageModeHorizontalPosition').WithParams([pPageModeHorizontalPosition]);
end;

procedure TMockPOSPrinter2.Set_PageModePrintArea(
  const pPageModePrintArea: WideString);
begin
  AddCall('Set_PageModePrintArea').WithParams([pPageModePrintArea]);
end;

procedure TMockPOSPrinter2.Set_PageModePrintDirection(
  pPageModePrintDirection: Integer);
begin
  AddCall('Set_PageModePrintDirection').WithParams([pPageModePrintDirection]);
end;

procedure TMockPOSPrinter2.Set_PageModeStation(pPageModeStation: Integer);
begin
  AddCall('Set_PageModeStation').WithParams([pPageModeStation]);
end;

procedure TMockPOSPrinter2.Set_PageModeVerticalPosition(
  pPageModeVerticalPosition: Integer);
begin
  AddCall('Set_PageModeVerticalPosition').WithParams([pPageModeVerticalPosition]);
end;

procedure TMockPOSPrinter2.Set_PowerNotify(pPowerNotify: Integer);
begin
  AddCall('Set_PowerNotify').WithParams([pPowerNotify]);
end;

procedure TMockPOSPrinter2.Set_RecCurrentCartridge(
  pRecCurrentCartridge: Integer);
begin
  AddCall('Set_RecCurrentCartridge').WithParams([pRecCurrentCartridge]);
end;

procedure TMockPOSPrinter2.Set_RecLetterQuality(
  pRecLetterQuality: WordBool);
begin
  AddCall('Set_RecLetterQuality').WithParams([pRecLetterQuality]);
end;

procedure TMockPOSPrinter2.Set_RecLineChars(pRecLineChars: Integer);
begin
  AddCall('Set_RecLineChars').WithParams([pRecLineChars]);
end;

procedure TMockPOSPrinter2.Set_RecLineHeight(pRecLineHeight: Integer);
begin
  AddCall('Set_RecLineHeight').WithParams([pRecLineHeight]);
end;

procedure TMockPOSPrinter2.Set_RecLineSpacing(pRecLineSpacing: Integer);
begin
  AddCall('Set_RecLineSpacing').WithParams([pRecLineSpacing]);
end;

procedure TMockPOSPrinter2.Set_RotateSpecial(pRotateSpecial: Integer);
begin
  AddCall('Set_RotateSpecial').WithParams([pRotateSpecial]);
end;

procedure TMockPOSPrinter2.Set_SlpCurrentCartridge(
  pSlpCurrentCartridge: Integer);
begin
  AddCall('Set_SlpCurrentCartridge').WithParams([pSlpCurrentCartridge]);
end;

procedure TMockPOSPrinter2.Set_SlpLetterQuality(
  pSlpLetterQuality: WordBool);
begin
  AddCall('Set_SlpLetterQuality').WithParams([pSlpLetterQuality]);
end;

procedure TMockPOSPrinter2.Set_SlpLineChars(pSlpLineChars: Integer);
begin
  AddCall('Set_SlpLineChars').WithParams([pSlpLineChars]);
end;

procedure TMockPOSPrinter2.Set_SlpLineHeight(pSlpLineHeight: Integer);
begin
  AddCall('Set_SlpLineHeight').WithParams([pSlpLineHeight]);
end;

procedure TMockPOSPrinter2.Set_SlpLineSpacing(pSlpLineSpacing: Integer);
begin
  AddCall('Set_SlpLineSpacing').WithParams([pSlpLineSpacing]);
end;

function TMockPOSPrinter2.SetBitmap(BitmapNumber, Station: Integer;
  const FileName: WideString; Width, Alignment: Integer): Integer;
begin
  Result := AddCall('SetBitmap').WithParams([BitmapNumber, Station,
    FileName, Width, Alignment]).ReturnValue;
end;

function TMockPOSPrinter2.SetLogo(Location: Integer;
  const Data: WideString): Integer;
begin
  Result := AddCall('SetLogo').WithParams([Location, Data]).ReturnValue;
end;

procedure TMockPOSPrinter2.SODataDummy(Status: Integer);
begin
  AddCall('SODataDummy').WithParams([Status]);
end;

procedure TMockPOSPrinter2.SODirectIO(EventNumber: Integer;
  var pData: Integer; var pString: WideString);
var
  Method: TMockMethod;
begin
  Method := AddCall('SODirectIO').WithParams([EventNumber, pData, pString]);
  pData := Method.OutParams[0];
  pString := Method.OutParams[1];
end;

procedure TMockPOSPrinter2.SOError(ResultCode, ResultCodeExtended,
  ErrorLocus: Integer; var pErrorResponse: Integer);
var
  Method: TMockMethod;
begin
  Method := AddCall('SOError').WithParams([ResultCode,
    ResultCodeExtended, ErrorLocus, pErrorResponse]);
  pErrorResponse := Method.OutParams[0];
end;

procedure TMockPOSPrinter2.SOOutputComplete(OutputID: Integer);
begin
  AddCall('SOOutputComplete').WithParams([OutputID]);
end;

function TMockPOSPrinter2.SOProcessID: Integer;
begin
  Result := AddCall('SOProcessID').ReturnValue;
end;

procedure TMockPOSPrinter2.SOStatusUpdate(Data: Integer);
begin
  AddCall('SOStatusUpdate').WithParams([Data]);
end;

function TMockPOSPrinter2.TransactionPrint(Station,
  Control: Integer): Integer;
begin
  Result := AddCall('TransactionPrint').WithParams([Station, Control]).ReturnValue;
end;

function TMockPOSPrinter2.UpdateFirmware(
  const FirmwareFileName: WideString): Integer;
begin
  Result := AddCall('UpdateFirmware').WithParams([FirmwareFileName]).ReturnValue;
end;

function TMockPOSPrinter2.UpdateStatistics(
  const StatisticsBuffer: WideString): Integer;
begin
  Result := AddCall('UpdateStatistics').WithParams([StatisticsBuffer]).ReturnValue;
end;

function TMockPOSPrinter2.ValidateData(Station: Integer;
  const Data: WideString): Integer;
begin
  Result := AddCall('ValidateData').WithParams([Station, Data]).ReturnValue;
end;

end.

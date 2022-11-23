unit MockPosPrinter;

interface

uses
  // VCL
  Classes, ComObj,
  // Mock
  PascalMock,
  // Opos
  OposPOSPrinter_CCO_TLB;

type
  { TMockPOSPrinter }

  TMockPOSPrinter = class(TComponent, IOPOSPOSPrinter)
  private
    FLines: TStringList;
  public
    FOpenResult: Integer;
    FCheckHealthText: WideString;
    FClaimed: Boolean;
    FDeviceEnabled: Boolean;
    FFreezeEvents: Boolean;
    FOutputID: Integer;
    FResultCode: Integer;
    FResultCodeExtended: Integer;
    FState: Integer;
    FControlObjectDescription: WideString;
    FControlObjectVersion: Integer;
    FServiceObjectDescription: WideString;
    FServiceObjectVersion: Integer;
    FDeviceDescription: WideString;
    FDeviceName: WideString;
    FAsyncMode: Boolean;
    FCapConcurrentJrnRec: Boolean;
    FCapConcurrentJrnSlp: Boolean;
    FCapConcurrentRecSlp: Boolean;
    FCapCoverSensor: Boolean;
    FCapJrn2Color: Boolean;
    FCapJrnBold: Boolean;
    FCapJrnDhigh: Boolean;
    FCapJrnDwide: Boolean;
    FCapJrnDwideDhigh: Boolean;
    FCapJrnEmptySensor: Boolean;
    FCapJrnItalic: Boolean;
    FCapJrnNearEndSensor: Boolean;
    FCapJrnPresent: Boolean;
    FCapJrnUnderline: Boolean;
    FCapRec2Color: Boolean;
    FCapRecBarCode: Boolean;
    FCapRecBitmap: Boolean;
    FCapRecBold: Boolean;
    FCapRecDhigh: Boolean;
    FCapRecDwide: Boolean;
    FCapRecDwideDhigh: Boolean;
    FCapRecEmptySensor: Boolean;
    FCapRecItalic: Boolean;
    FCapRecLeft90: Boolean;
    FCapRecNearEndSensor: Boolean;
    FCapRecPapercut: Boolean;
    FCapRecPresent: Boolean;
    FCapRecRight90: Boolean;
    FCapRecRotate180: Boolean;
    FCapRecStamp: Boolean;
    FCapRecUnderline: Boolean;
    FCapSlp2Color: Boolean;
    FCapSlpBarCode: Boolean;
    FCapSlpBitmap: Boolean;
    FCapSlpBold: Boolean;
    FCapSlpDhigh: Boolean;
    FCapSlpDwide: Boolean;
    FCapSlpDwideDhigh: Boolean;
    FCapSlpEmptySensor: Boolean;
    FCapSlpFullslip: Boolean;
    FCapSlpItalic: Boolean;
    FCapSlpLeft90: Boolean;
    FCapSlpNearEndSensor: Boolean;
    FCapSlpPresent: Boolean;
    FCapSlpRight90: Boolean;
    FCapSlpRotate180: Boolean;
    FCapSlpUnderline: Boolean;
    FCharacterSet: Integer;
    FCharacterSetList: WideString;
    FCoverOpen: Boolean;
    FErrorStation: Integer;
    FFlagWhenIdle: Boolean;
    FJrnEmpty: Boolean;
    FJrnLetterQuality: Boolean;
    FJrnLineChars: Integer;
    FJrnLineCharsList: WideString;
    FJrnLineHeight: Integer;
    FJrnLineSpacing: Integer;
    FJrnLineWidth: Integer;
    FJrnNearEnd: Boolean;
    FMapMode: Integer;
    FRecEmpty: Boolean;
    FRecLetterQuality: Boolean;
    FRecLineChars: Integer;
    FRecLineCharsList: WideString;
    FRecLineHeight: Integer;
    FRecLineSpacing: Integer;
    FRecLinesToPaperCut: Integer;
    FRecLineWidth: Integer;
    FRecNearEnd: Boolean;
    FRecSidewaysMaxChars: Integer;
    FRecSidewaysMaxLines: Integer;
    FSlpEmpty: Boolean;
    FSlpLetterQuality: Boolean;
    FSlpLineChars: Integer;
    FSlpLineCharsList: WideString;
    FSlpLineHeight: Integer;
    FSlpLinesNearEndToEnd: Integer;
    FSlpLineSpacing: Integer;
    FSlpLineWidth: Integer;
    FSlpMaxLines: Integer;
    FSlpNearEnd: Boolean;
    FSlpSidewaysMaxChars: Integer;
    FSlpSidewaysMaxLines: Integer;
    FCapCharacterSet: Integer;
    FCapTransaction: Boolean;
    FErrorLevel: Integer;
    FErrorString: WideString;
    FFontTypefaceList: WideString;
    FRecBarCodeRotationList: WideString;
    FRotateSpecial: Integer;
    FSlpBarCodeRotationList: WideString;
    FBinaryConversion: Integer;
    FCapPowerReporting: Integer;
    FPowerNotify: Integer;
    FPowerState: Integer;
    FCapJrnCartridgeSensor: Integer;
    FCapJrnColor: Integer;
    FCapRecCartridgeSensor: Integer;
    FCapRecColor: Integer;
    FCapRecMarkFeed: Integer;
    FCapSlpBothSidesPrint: Boolean;
    FCapSlpCartridgeSensor: Integer;
    FCapSlpColor: Integer;
    FCartridgeNotify: Integer;
    FJrnCartridgeState: Integer;
    FJrnCurrentCartridge: Integer;
    FRecCartridgeState: Integer;
    FRecCurrentCartridge: Integer;
    FSlpCartridgeState: Integer;
    FSlpCurrentCartridge: Integer;
    FSlpPrintSide: Integer;
    FCapMapCharacterSet: Boolean;
    FMapCharacterSet: Boolean;
    FRecBitmapRotationList: WideString;
    FSlpBitmapRotationList: WideString;
    FCapStatisticsReporting: Boolean;
    FCapUpdateStatistics: Boolean;
    FCapCompareFirmwareVersion: Boolean;
    FCapUpdateFirmware: Boolean;
    FCapConcurrentPageMode: Boolean;
    FCapRecPageMode: Boolean;
    FCapSlpPageMode: Boolean;
    FPageModeArea: WideString;
    FPageModeDescriptor: Integer;
    FPageModeHorizontalPosition: Integer;
    FPageModePrintArea: WideString;
    FPageModePrintDirection: Integer;
    FPageModeStation: Integer;
    FPageModeVerticalPosition: Integer;
    FCapRecRuledLine: Integer;
    FCapSlpRuledLine: Integer;

    constructor Create(AOwner: Tcomponent); override;
    destructor Destroy; override;

    property Lines: TStringList read FLines;
  public
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

{ TMockPOSPrinter }

constructor TMockPOSPrinter.Create(AOwner: Tcomponent);
begin
  inherited Create(AOwner);
  FLines := TStringList.Create;
  FCapConcurrentJrnRec := True;
  FCapConcurrentJrnSlp := True;
  FCapConcurrentRecSlp := True;
  FCapCoverSensor := True;
  FCapJrn2Color := True;
  FCapJrnBold := True;
  FCapJrnDhigh := True;
  FCapJrnDwide := True;
  FCapJrnDwideDhigh := True;
  FCapJrnEmptySensor := True;
  FCapJrnItalic := True;
  FCapJrnNearEndSensor := True;
  FCapJrnPresent := True;
  FCapJrnUnderline := True;
  FCapRec2Color := True;
  FCapRecBarCode := True;
  FCapRecBitmap := True;
  FCapRecBold := True;
  FCapRecDhigh := True;
  FCapRecDwide := True;
  FCapRecDwideDhigh := True;
  FCapRecEmptySensor := True;
  FCapRecItalic := True;
  FCapRecLeft90 := True;
  FCapRecNearEndSensor := True;
  FCapRecPapercut := True;
  FCapRecPresent := True;
  FCapRecRight90 := True;
  FCapRecRotate180 := True;
  FCapRecStamp := True;
  FCapRecUnderline := True;
  FCapSlp2Color := True;
  FCapSlpBarCode := True;
  FCapSlpBitmap := True;
  FCapSlpBold := True;
  FCapSlpDhigh := True;
  FCapSlpDwide := True;
  FCapSlpDwideDhigh := True;
  FCapSlpEmptySensor := True;
  FCapSlpFullslip := True;
  FCapSlpItalic := True;
  FCapSlpLeft90 := True;
  FCapSlpNearEndSensor := True;
  FCapSlpPresent := True;
  FCapSlpRight90 := True;
  FCapSlpRotate180 := True;
  FCapSlpUnderline := True;
  FCapCharacterSet := 0;
  FCapTransaction := True;
  FCapPowerReporting := 0;
  FCapJrnCartridgeSensor := 0;
  FCapJrnColor := 0;
  FCapRecCartridgeSensor := 0;
  FCapRecColor := 0;
  FCapRecMarkFeed := 0;
  FCapSlpBothSidesPrint := True;
  FCapSlpCartridgeSensor := 0;
  FCapSlpColor := 0;
  FCapMapCharacterSet := True;
  FCapStatisticsReporting := True;
  FCapUpdateStatistics := True;
  FCapCompareFirmwareVersion := True;
  FCapUpdateFirmware := True;
  FCapConcurrentPageMode := True;
  FCapRecPageMode := True;
  FCapSlpPageMode := True;
  FCapRecRuledLine := 0;
  FCapSlpRuledLine := 0;
  FRecLinesToPaperCut := 4;
end;

destructor TMockPOSPrinter.Destroy;
begin
  FLines.Free;
  inherited Destroy;
end;

function TMockPOSPrinter.BeginInsertion(Timeout: Integer): Integer;
begin
  Result := 0;
end;

function TMockPOSPrinter.BeginRemoval(Timeout: Integer): Integer;
begin
  Result := 0;
end;

function TMockPOSPrinter.ChangePrintSide(Side: Integer): Integer;
begin
  Result := 0;
end;

function TMockPOSPrinter.CheckHealth(Level: Integer): Integer;
begin
  Result := 0;
end;

function TMockPOSPrinter.ClaimDevice(Timeout: Integer): Integer;
begin
  Result := 0;
  FClaimed := True;
end;

function TMockPOSPrinter.ClearOutput: Integer;
begin
  Result := 0;
end;

function TMockPOSPrinter.ClearPrintArea: Integer;
begin
  Result := 0;
end;

function TMockPOSPrinter.Close: Integer;
begin
  Result := 0;
end;

function TMockPOSPrinter.CompareFirmwareVersion(
  const FirmwareFileName: WideString; out pResult: Integer): Integer;
begin
  Result := 0;
end;

function TMockPOSPrinter.CutPaper(Percentage: Integer): Integer;
begin
  Result := 0;
end;

function TMockPOSPrinter.DirectIO(Command: Integer; var pData: Integer;
  var pString: WideString): Integer;
begin
  Result := 0;
end;

function TMockPOSPrinter.DrawRuledLine(Station: Integer;
  const PositionList: WideString; LineDirection, LineWidth, LineStyle,
  LineColor: Integer): Integer;
begin
  Result := 0;
end;

function TMockPOSPrinter.EndInsertion: Integer;
begin
  Result := 0;
end;

function TMockPOSPrinter.EndRemoval: Integer;
begin
  Result := 0;
end;

function TMockPOSPrinter.Get_AsyncMode: WordBool;
begin
  Result := FAsyncMode;
end;

function TMockPOSPrinter.Get_BinaryConversion: Integer;
begin
  Result := FBinaryConversion;
end;

function TMockPOSPrinter.Get_CapCharacterSet: Integer;
begin
  Result := FCapCharacterSet;
end;

function TMockPOSPrinter.Get_CapCompareFirmwareVersion: WordBool;
begin
  Result := FCapCompareFirmwareVersion;
end;

function TMockPOSPrinter.Get_CapConcurrentJrnRec: WordBool;
begin
  Result := FCapConcurrentJrnRec;
end;

function TMockPOSPrinter.Get_CapConcurrentJrnSlp: WordBool;
begin
  Result := FCapConcurrentJrnSlp;
end;

function TMockPOSPrinter.Get_CapConcurrentPageMode: WordBool;
begin
  Result := FCapConcurrentPageMode;
end;

function TMockPOSPrinter.Get_CapConcurrentRecSlp: WordBool;
begin
  Result := FCapConcurrentRecSlp;
end;

function TMockPOSPrinter.Get_CapCoverSensor: WordBool;
begin
  Result := FCapCoverSensor;
end;

function TMockPOSPrinter.Get_CapJrn2Color: WordBool;
begin
  Result := FCapJrn2Color;
end;

function TMockPOSPrinter.Get_CapJrnBold: WordBool;
begin
  Result := FCapJrnBold;
end;

function TMockPOSPrinter.Get_CapJrnCartridgeSensor: Integer;
begin
  Result := FCapJrnCartridgeSensor;
end;

function TMockPOSPrinter.Get_CapJrnColor: Integer;
begin
  Result := FCapJrnColor;
end;

function TMockPOSPrinter.Get_CapJrnDhigh: WordBool;
begin
  Result := FCapJrnDhigh;
end;

function TMockPOSPrinter.Get_CapJrnDwide: WordBool;
begin
  Result := FCapJrnDwide;
end;

function TMockPOSPrinter.Get_CapJrnDwideDhigh: WordBool;
begin
  Result := FCapJrnDwideDhigh;
end;

function TMockPOSPrinter.Get_CapJrnEmptySensor: WordBool;
begin
  Result := FCapJrnEmptySensor;
end;

function TMockPOSPrinter.Get_CapJrnItalic: WordBool;
begin
  Result := FCapJrnItalic;
end;

function TMockPOSPrinter.Get_CapJrnNearEndSensor: WordBool;
begin
  Result := FCapJrnNearEndSensor;
end;

function TMockPOSPrinter.Get_CapJrnPresent: WordBool;
begin
  Result := FCapJrnPresent;
end;

function TMockPOSPrinter.Get_CapJrnUnderline: WordBool;
begin
  Result := FCapJrnUnderline;
end;

function TMockPOSPrinter.Get_CapMapCharacterSet: WordBool;
begin
  Result := FCapMapCharacterSet;
end;

function TMockPOSPrinter.Get_CapPowerReporting: Integer;
begin
  Result := FCapPowerReporting;
end;

function TMockPOSPrinter.Get_CapRec2Color: WordBool;
begin
  Result := FCapRec2Color;
end;

function TMockPOSPrinter.Get_CapRecBarCode: WordBool;
begin
  Result := FCapRecBarCode;
end;

function TMockPOSPrinter.Get_CapRecBitmap: WordBool;
begin
  Result := FCapRecBitmap;
end;

function TMockPOSPrinter.Get_CapRecBold: WordBool;
begin
  Result := FCapRecBold;
end;

function TMockPOSPrinter.Get_CapRecCartridgeSensor: Integer;
begin
  Result := FCapRecCartridgeSensor;
end;

function TMockPOSPrinter.Get_CapRecColor: Integer;
begin
  Result := FCapRecCartridgeSensor;
end;

function TMockPOSPrinter.Get_CapRecDhigh: WordBool;
begin
  Result := FCapRecDhigh;
end;

function TMockPOSPrinter.Get_CapRecDwide: WordBool;
begin
  Result := FCapRecDwide;
end;

function TMockPOSPrinter.Get_CapRecDwideDhigh: WordBool;
begin
  Result := FCapRecDwideDhigh;
end;

function TMockPOSPrinter.Get_CapRecEmptySensor: WordBool;
begin
  Result := FCapRecEmptySensor;
end;

function TMockPOSPrinter.Get_CapRecItalic: WordBool;
begin
  Result := FCapRecItalic;
end;

function TMockPOSPrinter.Get_CapRecLeft90: WordBool;
begin
  Result := FCapRecLeft90;
end;

function TMockPOSPrinter.Get_CapRecMarkFeed: Integer;
begin
  Result := FCapRecMarkFeed;
end;

function TMockPOSPrinter.Get_CapRecNearEndSensor: WordBool;
begin
  Result := FCapRecNearEndSensor;
end;

function TMockPOSPrinter.Get_CapRecPageMode: WordBool;
begin
  Result := FCapRecPageMode;
end;

function TMockPOSPrinter.Get_CapRecPapercut: WordBool;
begin
  Result := FCapRecPapercut;
end;

function TMockPOSPrinter.Get_CapRecPresent: WordBool;
begin
  Result := FCapRecPresent;
end;

function TMockPOSPrinter.Get_CapRecRight90: WordBool;
begin
  Result := FCapRecRight90;
end;

function TMockPOSPrinter.Get_CapRecRotate180: WordBool;
begin
  Result := FCapRecRotate180;
end;

function TMockPOSPrinter.Get_CapRecRuledLine: Integer;
begin
  Result := FCapRecRuledLine;
end;

function TMockPOSPrinter.Get_CapRecStamp: WordBool;
begin
  Result := FCapRecStamp;
end;

function TMockPOSPrinter.Get_CapRecUnderline: WordBool;
begin
  Result := FCapRecUnderline;
end;

function TMockPOSPrinter.Get_CapSlp2Color: WordBool;
begin
  Result := FCapSlp2Color;
end;

function TMockPOSPrinter.Get_CapSlpBarCode: WordBool;
begin
  Result := FCapSlpBarCode;
end;

function TMockPOSPrinter.Get_CapSlpBitmap: WordBool;
begin
  Result := FCapSlpBitmap;
end;

function TMockPOSPrinter.Get_CapSlpBold: WordBool;
begin
  Result := FCapSlpBold;
end;

function TMockPOSPrinter.Get_CapSlpBothSidesPrint: WordBool;
begin
  Result := FCapSlpBothSidesPrint;
end;

function TMockPOSPrinter.Get_CapSlpCartridgeSensor: Integer;
begin
  Result := FCapSlpCartridgeSensor;
end;

function TMockPOSPrinter.Get_CapSlpColor: Integer;
begin
  Result := FCapSlpColor;
end;

function TMockPOSPrinter.Get_CapSlpDhigh: WordBool;
begin
  Result := FCapSlpDhigh;
end;

function TMockPOSPrinter.Get_CapSlpDwide: WordBool;
begin
  Result := FCapSlpDwide;
end;

function TMockPOSPrinter.Get_CapSlpDwideDhigh: WordBool;
begin
  Result := FCapSlpDwideDhigh;
end;

function TMockPOSPrinter.Get_CapSlpEmptySensor: WordBool;
begin
  Result := FCapSlpEmptySensor;
end;

function TMockPOSPrinter.Get_CapSlpFullslip: WordBool;
begin
  Result := FCapSlpFullslip;
end;

function TMockPOSPrinter.Get_CapSlpItalic: WordBool;
begin
  Result := FCapSlpItalic;
end;

function TMockPOSPrinter.Get_CapSlpLeft90: WordBool;
begin
  Result := FCapSlpLeft90;
end;

function TMockPOSPrinter.Get_CapSlpNearEndSensor: WordBool;
begin
  Result := FCapSlpNearEndSensor;
end;

function TMockPOSPrinter.Get_CapSlpPageMode: WordBool;
begin
  Result := FCapSlpPageMode;
end;

function TMockPOSPrinter.Get_CapSlpPresent: WordBool;
begin
  Result := FCapSlpPresent;
end;

function TMockPOSPrinter.Get_CapSlpRight90: WordBool;
begin
  Result := FCapSlpRight90;
end;

function TMockPOSPrinter.Get_CapSlpRotate180: WordBool;
begin
  Result := FCapSlpRotate180;
end;

function TMockPOSPrinter.Get_CapSlpRuledLine: Integer;
begin
  Result := FCapSlpRuledLine;
end;

function TMockPOSPrinter.Get_CapSlpUnderline: WordBool;
begin
  Result := FCapSlpUnderline;
end;

function TMockPOSPrinter.Get_CapStatisticsReporting: WordBool;
begin
  Result := FCapStatisticsReporting;
end;

function TMockPOSPrinter.Get_CapTransaction: WordBool;
begin
  Result := FCapTransaction;
end;

function TMockPOSPrinter.Get_CapUpdateFirmware: WordBool;
begin
  Result := FCapUpdateFirmware;
end;

function TMockPOSPrinter.Get_CapUpdateStatistics: WordBool;
begin
  Result := FCapUpdateStatistics;
end;

function TMockPOSPrinter.Get_CartridgeNotify: Integer;
begin
  Result := FCartridgeNotify;
end;

function TMockPOSPrinter.Get_CharacterSet: Integer;
begin
  Result := FCharacterSet;
end;

function TMockPOSPrinter.Get_CharacterSetList: WideString;
begin
  Result := FCharacterSetList;
end;

function TMockPOSPrinter.Get_CheckHealthText: WideString;
begin
  Result := FCharacterSetList;
end;

function TMockPOSPrinter.Get_Claimed: WordBool;
begin
  Result := FClaimed;
end;

function TMockPOSPrinter.Get_ControlObjectDescription: WideString;
begin
  Result := FControlObjectDescription;
end;

function TMockPOSPrinter.Get_ControlObjectVersion: Integer;
begin
  Result := FControlObjectVersion;
end;

function TMockPOSPrinter.Get_CoverOpen: WordBool;
begin
  Result := FCoverOpen;
end;

function TMockPOSPrinter.Get_DeviceDescription: WideString;
begin
  Result := FDeviceDescription;
end;

function TMockPOSPrinter.Get_DeviceEnabled: WordBool;
begin
  Result := FDeviceEnabled;
end;

function TMockPOSPrinter.Get_DeviceName: WideString;
begin
  Result := FDeviceName;
end;

function TMockPOSPrinter.Get_ErrorLevel: Integer;
begin
  Result := FErrorLevel;
end;

function TMockPOSPrinter.Get_ErrorStation: Integer;
begin
  Result := FErrorStation;
end;

function TMockPOSPrinter.Get_ErrorString: WideString;
begin
  Result := FErrorString;
end;

function TMockPOSPrinter.Get_FlagWhenIdle: WordBool;
begin
  Result := FFlagWhenIdle;
end;

function TMockPOSPrinter.Get_FontTypefaceList: WideString;
begin
  Result := FFontTypefaceList;
end;

function TMockPOSPrinter.Get_FreezeEvents: WordBool;
begin
  Result := FFreezeEvents;
end;

function TMockPOSPrinter.Get_JrnCartridgeState: Integer;
begin
  Result := FJrnCartridgeState;
end;

function TMockPOSPrinter.Get_JrnCurrentCartridge: Integer;
begin
  Result := FJrnCurrentCartridge;
end;

function TMockPOSPrinter.Get_JrnEmpty: WordBool;
begin
  Result := FJrnEmpty;
end;

function TMockPOSPrinter.Get_JrnLetterQuality: WordBool;
begin
  Result := FJrnLetterQuality;
end;

function TMockPOSPrinter.Get_JrnLineChars: Integer;
begin
  Result := FJrnLineChars;
end;

function TMockPOSPrinter.Get_JrnLineCharsList: WideString;
begin
  Result := FJrnLineCharsList;
end;

function TMockPOSPrinter.Get_JrnLineHeight: Integer;
begin
  Result := FJrnLineHeight;
end;

function TMockPOSPrinter.Get_JrnLineSpacing: Integer;
begin
  Result := FJrnLineSpacing;
end;

function TMockPOSPrinter.Get_JrnLineWidth: Integer;
begin
  Result := FJrnLineWidth;
end;

function TMockPOSPrinter.Get_JrnNearEnd: WordBool;
begin
  Result := FJrnNearEnd;
end;

function TMockPOSPrinter.Get_MapCharacterSet: WordBool;
begin
  Result := FMapCharacterSet;
end;

function TMockPOSPrinter.Get_MapMode: Integer;
begin
  Result := FMapMode;
end;

function TMockPOSPrinter.Get_OpenResult: Integer;
begin
  Result := FOpenResult;
end;

function TMockPOSPrinter.Get_OutputID: Integer;
begin
  Result := FOutputID;
end;

function TMockPOSPrinter.Get_PageModeArea: WideString;
begin
  Result := FPageModeArea;
end;

function TMockPOSPrinter.Get_PageModeDescriptor: Integer;
begin
  Result := FPageModeDescriptor;
end;

function TMockPOSPrinter.Get_PageModeHorizontalPosition: Integer;
begin
  Result := FPageModeHorizontalPosition;
end;

function TMockPOSPrinter.Get_PageModePrintArea: WideString;
begin
  Result := FPageModePrintArea;
end;

function TMockPOSPrinter.Get_PageModePrintDirection: Integer;
begin
  Result := FPageModePrintDirection;
end;

function TMockPOSPrinter.Get_PageModeStation: Integer;
begin
  Result := FPageModeStation;
end;

function TMockPOSPrinter.Get_PageModeVerticalPosition: Integer;
begin
  Result := FPageModeVerticalPosition;
end;

function TMockPOSPrinter.Get_PowerNotify: Integer;
begin
  Result := FPowerNotify;
end;

function TMockPOSPrinter.Get_PowerState: Integer;
begin
  Result := FPowerState;
end;

function TMockPOSPrinter.Get_RecBarCodeRotationList: WideString;
begin
  Result := FRecBarCodeRotationList;
end;

function TMockPOSPrinter.Get_RecBitmapRotationList: WideString;
begin
  Result := FRecBitmapRotationList;
end;

function TMockPOSPrinter.Get_RecCartridgeState: Integer;
begin
  Result := FRecCartridgeState;
end;

function TMockPOSPrinter.Get_RecCurrentCartridge: Integer;
begin
  Result := FRecCurrentCartridge;
end;

function TMockPOSPrinter.Get_RecEmpty: WordBool;
begin
  Result := FRecEmpty;
end;

function TMockPOSPrinter.Get_RecLetterQuality: WordBool;
begin
  Result := FRecLetterQuality;
end;

function TMockPOSPrinter.Get_RecLineChars: Integer;
begin
  Result := FRecLineChars;
end;

function TMockPOSPrinter.Get_RecLineCharsList: WideString;
begin
  Result := FRecLineCharsList;
end;

function TMockPOSPrinter.Get_RecLineHeight: Integer;
begin
  Result := FRecLineHeight;
end;

function TMockPOSPrinter.Get_RecLineSpacing: Integer;
begin
  Result := FRecLineSpacing;
end;

function TMockPOSPrinter.Get_RecLinesToPaperCut: Integer;
begin
  Result := FRecLinesToPaperCut;
end;

function TMockPOSPrinter.Get_RecLineWidth: Integer;
begin
  Result := FRecLineWidth;
end;

function TMockPOSPrinter.Get_RecNearEnd: WordBool;
begin
  Result := FRecNearEnd;
end;

function TMockPOSPrinter.Get_RecSidewaysMaxChars: Integer;
begin
  Result := FRecSidewaysMaxChars;
end;

function TMockPOSPrinter.Get_RecSidewaysMaxLines: Integer;
begin
  Result := FRecSidewaysMaxLines;
end;

function TMockPOSPrinter.Get_ResultCode: Integer;
begin
  Result := FResultCode;
end;

function TMockPOSPrinter.Get_ResultCodeExtended: Integer;
begin
  Result := FResultCodeExtended;
end;

function TMockPOSPrinter.Get_RotateSpecial: Integer;
begin
  Result := FRotateSpecial;
end;

function TMockPOSPrinter.Get_ServiceObjectDescription: WideString;
begin
  Result := FServiceObjectDescription;
end;

function TMockPOSPrinter.Get_ServiceObjectVersion: Integer;
begin
  Result := FServiceObjectVersion;
end;

function TMockPOSPrinter.Get_SlpBarCodeRotationList: WideString;
begin
  Result := FSlpBarCodeRotationList;
end;

function TMockPOSPrinter.Get_SlpBitmapRotationList: WideString;
begin
  Result := FSlpBitmapRotationList;
end;

function TMockPOSPrinter.Get_SlpCartridgeState: Integer;
begin
  Result := FSlpCartridgeState;
end;

function TMockPOSPrinter.Get_SlpCurrentCartridge: Integer;
begin
  Result := FSlpCurrentCartridge;
end;

function TMockPOSPrinter.Get_SlpEmpty: WordBool;
begin
  Result := FSlpEmpty;
end;

function TMockPOSPrinter.Get_SlpLetterQuality: WordBool;
begin
  Result := FSlpLetterQuality;
end;

function TMockPOSPrinter.Get_SlpLineChars: Integer;
begin
  Result := FSlpLineChars;
end;

function TMockPOSPrinter.Get_SlpLineCharsList: WideString;
begin
  Result := FSlpLineCharsList;
end;

function TMockPOSPrinter.Get_SlpLineHeight: Integer;
begin
  Result := FSlpLineHeight;
end;

function TMockPOSPrinter.Get_SlpLinesNearEndToEnd: Integer;
begin
  Result := FSlpLinesNearEndToEnd;
end;

function TMockPOSPrinter.Get_SlpLineSpacing: Integer;
begin
  Result := FSlpLineSpacing;
end;

function TMockPOSPrinter.Get_SlpLineWidth: Integer;
begin
  Result := FSlpLineWidth;
end;

function TMockPOSPrinter.Get_SlpMaxLines: Integer;
begin
  Result := FSlpMaxLines;
end;

function TMockPOSPrinter.Get_SlpNearEnd: WordBool;
begin
  Result := FSlpNearEnd;
end;

function TMockPOSPrinter.Get_SlpPrintSide: Integer;
begin
  Result := FSlpPrintSide;
end;

function TMockPOSPrinter.Get_SlpSidewaysMaxChars: Integer;
begin
  Result := FSlpSidewaysMaxChars;
end;

function TMockPOSPrinter.Get_SlpSidewaysMaxLines: Integer;
begin
  Result := FSlpSidewaysMaxLines;
end;

function TMockPOSPrinter.Get_State: Integer;
begin
  Result := FState;
end;

function TMockPOSPrinter.MarkFeed(Type_: Integer): Integer;
begin
  Result := 0;
end;

function TMockPOSPrinter.Open(const DeviceName: WideString): Integer;
begin
  Result := 0;
end;

function TMockPOSPrinter.PageModePrint(Control: Integer): Integer;
begin
  Result := 0;
end;

function TMockPOSPrinter.PrintBarCode(Station: Integer;
  const Data: WideString; Symbology, Height, Width, Alignment,
  TextPosition: Integer): Integer;
begin
  //FLines.AddObject(Data, TObject(Station));
  Result := 0;
end;

function TMockPOSPrinter.PrintBitmap(Station: Integer;
  const FileName: WideString; Width, Alignment: Integer): Integer;
begin
  Result := 0;
end;

function TMockPOSPrinter.PrintImmediate(Station: Integer;
  const Data: WideString): Integer;
begin
  Result := 0;
end;

function TMockPOSPrinter.PrintMemoryBitmap(Station: Integer;
  const Data: WideString; Type_, Width, Alignment: Integer): Integer;
begin
  Result := 0;
end;

function TMockPOSPrinter.PrintNormal(Station: Integer;
  const Data: WideString): Integer;
begin
  Result := 0;
  FLines.AddObject(Data, TObject(Station));
end;

function TMockPOSPrinter.PrintTwoNormal(Stations: Integer; const Data1,
  Data2: WideString): Integer;
begin
  Result := 0;
end;

function TMockPOSPrinter.ReleaseDevice: Integer;
begin
  Result := 0;
  FClaimed := False;
end;

function TMockPOSPrinter.ResetStatistics(
  const StatisticsBuffer: WideString): Integer;
begin
  Result := 0;
end;

function TMockPOSPrinter.RetrieveStatistics(
  var pStatisticsBuffer: WideString): Integer;
begin
  Result := 0;
end;

function TMockPOSPrinter.RotatePrint(Station, Rotation: Integer): Integer;
begin
  Result := 0;
end;

procedure TMockPOSPrinter.Set_AsyncMode(pAsyncMode: WordBool);
begin
  FAsyncMode := pAsyncMode;
end;

procedure TMockPOSPrinter.Set_BinaryConversion(pBinaryConversion: Integer);
begin
  FBinaryConversion := pBinaryConversion;
end;

procedure TMockPOSPrinter.Set_CartridgeNotify(pCartridgeNotify: Integer);
begin
  FCartridgeNotify := pCartridgeNotify;
end;

procedure TMockPOSPrinter.Set_CharacterSet(pCharacterSet: Integer);
begin
  FCharacterSet := pCharacterSet;
end;

procedure TMockPOSPrinter.Set_DeviceEnabled(pDeviceEnabled: WordBool);
begin
  FDeviceEnabled := pDeviceEnabled;
end;

procedure TMockPOSPrinter.Set_FlagWhenIdle(pFlagWhenIdle: WordBool);
begin
  FFlagWhenIdle := pFlagWhenIdle;
end;

procedure TMockPOSPrinter.Set_FreezeEvents(pFreezeEvents: WordBool);
begin
  FFreezeEvents := pFreezeEvents;
end;

procedure TMockPOSPrinter.Set_JrnCurrentCartridge(
  pJrnCurrentCartridge: Integer);
begin
  FJrnCurrentCartridge := pJrnCurrentCartridge;
end;

procedure TMockPOSPrinter.Set_JrnLetterQuality(
  pJrnLetterQuality: WordBool);
begin
  FJrnLetterQuality := pJrnLetterQuality;
end;

procedure TMockPOSPrinter.Set_JrnLineChars(pJrnLineChars: Integer);
begin
  FJrnLineChars := pJrnLineChars;
end;

procedure TMockPOSPrinter.Set_JrnLineHeight(pJrnLineHeight: Integer);
begin
  FJrnLineHeight := pJrnLineHeight;
end;

procedure TMockPOSPrinter.Set_JrnLineSpacing(pJrnLineSpacing: Integer);
begin
  FJrnLineSpacing := pJrnLineSpacing;
end;

procedure TMockPOSPrinter.Set_MapCharacterSet(pMapCharacterSet: WordBool);
begin
  FMapCharacterSet := pMapCharacterSet;
end;

procedure TMockPOSPrinter.Set_MapMode(pMapMode: Integer);
begin
  FMapMode := pMapMode;
end;

procedure TMockPOSPrinter.Set_PageModeHorizontalPosition(
  pPageModeHorizontalPosition: Integer);
begin
  FPageModeHorizontalPosition := pPageModeHorizontalPosition;
end;

procedure TMockPOSPrinter.Set_PageModePrintArea(
  const pPageModePrintArea: WideString);
begin
  FPageModePrintArea := pPageModePrintArea;
end;

procedure TMockPOSPrinter.Set_PageModePrintDirection(
  pPageModePrintDirection: Integer);
begin
  FPageModePrintDirection := pPageModePrintDirection;
end;

procedure TMockPOSPrinter.Set_PageModeStation(pPageModeStation: Integer);
begin
  FPageModeStation := pPageModeStation;
end;

procedure TMockPOSPrinter.Set_PageModeVerticalPosition(
  pPageModeVerticalPosition: Integer);
begin
  FPageModeVerticalPosition := pPageModeVerticalPosition;
end;

procedure TMockPOSPrinter.Set_PowerNotify(pPowerNotify: Integer);
begin
  FPowerNotify := pPowerNotify;
end;

procedure TMockPOSPrinter.Set_RecCurrentCartridge(
  pRecCurrentCartridge: Integer);
begin
  FRecCurrentCartridge := pRecCurrentCartridge;
end;

procedure TMockPOSPrinter.Set_RecLetterQuality(
  pRecLetterQuality: WordBool);
begin
  FRecLetterQuality := pRecLetterQuality;
end;

procedure TMockPOSPrinter.Set_RecLineChars(pRecLineChars: Integer);
begin
  FRecLineChars := pRecLineChars;
end;

procedure TMockPOSPrinter.Set_RecLineHeight(pRecLineHeight: Integer);
begin
  FRecLineHeight := pRecLineHeight;
end;

procedure TMockPOSPrinter.Set_RecLineSpacing(pRecLineSpacing: Integer);
begin
  FRecLineSpacing := pRecLineSpacing;
end;

procedure TMockPOSPrinter.Set_RotateSpecial(pRotateSpecial: Integer);
begin
  FRotateSpecial := pRotateSpecial;
end;

procedure TMockPOSPrinter.Set_SlpCurrentCartridge(
  pSlpCurrentCartridge: Integer);
begin
  FSlpCurrentCartridge := pSlpCurrentCartridge;
end;

procedure TMockPOSPrinter.Set_SlpLetterQuality(
  pSlpLetterQuality: WordBool);
begin
  FSlpLetterQuality := pSlpLetterQuality;
end;

procedure TMockPOSPrinter.Set_SlpLineChars(pSlpLineChars: Integer);
begin
  FSlpLineChars := pSlpLineChars;
end;

procedure TMockPOSPrinter.Set_SlpLineHeight(pSlpLineHeight: Integer);
begin
  FSlpLineHeight := pSlpLineHeight;
end;

procedure TMockPOSPrinter.Set_SlpLineSpacing(pSlpLineSpacing: Integer);
begin
  FSlpLineSpacing := pSlpLineSpacing;
end;

function TMockPOSPrinter.SetBitmap(BitmapNumber, Station: Integer;
  const FileName: WideString; Width, Alignment: Integer): Integer;
begin
  Result := 0;
end;

function TMockPOSPrinter.SetLogo(Location: Integer;
  const Data: WideString): Integer;
begin
  Result := 0;
end;

procedure TMockPOSPrinter.SODataDummy(Status: Integer);
begin

end;

procedure TMockPOSPrinter.SODirectIO(EventNumber: Integer;
  var pData: Integer; var pString: WideString);
begin

end;

procedure TMockPOSPrinter.SOError(ResultCode, ResultCodeExtended,
  ErrorLocus: Integer; var pErrorResponse: Integer);
begin

end;

procedure TMockPOSPrinter.SOOutputComplete(OutputID: Integer);
begin

end;

function TMockPOSPrinter.SOProcessID: Integer;
begin

end;

procedure TMockPOSPrinter.SOStatusUpdate(Data: Integer);
begin

end;

function TMockPOSPrinter.TransactionPrint(Station,
  Control: Integer): Integer;
begin
  Result := 0;
end;

function TMockPOSPrinter.UpdateFirmware(
  const FirmwareFileName: WideString): Integer;
begin
  Result := 0;
end;

function TMockPOSPrinter.UpdateStatistics(
  const StatisticsBuffer: WideString): Integer;
begin
  Result := 0;
end;

function TMockPOSPrinter.ValidateData(Station: Integer;
  const Data: WideString): Integer;
begin
  Result := 0;
end;

end.

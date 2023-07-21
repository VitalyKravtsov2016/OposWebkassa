unit PosWinPrinter;

interface

uses
  // VCL
  Windows, Classes, SysUtils, Printers, Graphics,
  // Tnt
  TntClasses,
  // Opos
  Opos, OposEsc, OposPtr, OposException, OposServiceDevice19,
  OposPOSPrinter_CCO_TLB, WException,
  // This
  LogFile, DriverError;

type
  { TPosWinPrinter }

  TPosWinPrinter = class(TComponent, IOPOSPOSPrinter)
  private
    FLogger: ILogFile;
    FDevice: TOposServiceDevice19;
    FPositionY: Integer;
    FTransaction: Boolean;
    FFontName: WideString;

    FAsyncMode: Boolean;
    FCapCharacterSet: Integer;
    FCapCompareFirmwareVersion: Boolean;
    FCapConcurrentJrnRec: Boolean;
    FCapConcurrentJrnSlp: Boolean;
    FCapConcurrentPageMode: Boolean;
    FCapConcurrentRecSlp: Boolean;
    FCapCoverSensor: Boolean;
    FCapJrn2Color: Boolean;
    FCapJrnBold: Boolean;
    FCapJrnCartridgeSensor: Integer;
    FCapJrnColor: Integer;
    FCapJrnDhigh: Boolean;
    FCapJrnDwide: Boolean;
    FCapJrnDwideDhigh: Boolean;
    FCapJrnEmptySensor: Boolean;
    FCapJrnItalic: Boolean;
    FCapJrnNearEndSensor: Boolean;
    FCapJrnPresent: Boolean;
    FCapJrnUnderline: Boolean;
    FCapMapCharacterSet: Boolean;
    FCapPowerReporting: Integer;
    FCapRec2Color: Boolean;
    FCapRecBarCode: Boolean;
    FCapRecBitmap: Boolean;
    FCapRecBold: Boolean;
    FCapRecCartridgeSensor: Integer;
    FCapRecColor: Integer;
    FCapRecDhigh: Boolean;
    FCapRecDwide: Boolean;
    FCapRecDwideDhigh: Boolean;
    FCapRecEmptySensor: Boolean;
    FCapRecItalic: Boolean;
    FCapRecLeft90: Boolean;
    FCapRecMarkFeed: Integer;
    FCapRecNearEndSensor: Boolean;
    FCapRecPageMode: Boolean;
    FCapRecPapercut: Boolean;
    FCapRecPresent: Boolean;
    FCapRecRight90: Boolean;
    FCapRecRotate180: Boolean;
    FCapRecRuledLine: Integer;
    FCapRecStamp: Boolean;
    FCapRecUnderline: Boolean;
    FCapSlp2Color: Boolean;
    FCapSlpBarCode: Boolean;
    FCapSlpBitmap: Boolean;
    FCapSlpBold: Boolean;
    FCapSlpBothSidesPrint: Boolean;
    FCapSlpCartridgeSensor: Integer;
    FCapSlpColor: Integer;
    FCapSlpDhigh: Boolean;
    FCapSlpDwide: Boolean;
    FCapSlpDwideDhigh: Boolean;
    FCapSlpEmptySensor: Boolean;
    FCapSlpFullslip: Boolean;
    FCapSlpItalic: Boolean;
    FCapSlpLeft90: Boolean;
    FCapSlpNearEndSensor: Boolean;
    FCapSlpPageMode: Boolean;
    FCapSlpPresent: Boolean;
    FCapSlpRight90: Boolean;
    FCapSlpRotate180: Boolean;
    FCapSlpRuledLine: Integer;
    FCapSlpUnderline: Boolean;
    FCapStatisticsReporting: Boolean;
    FCapTransaction: Boolean;
    FCapUpdateFirmware: Boolean;
    FCapUpdateStatistics: Boolean;
    FCartridgeNotify: Integer;
    FCharacterSet: Integer;
    FCharacterSetList: WideString;
    FCheckHealthText: WideString;
    FControlObjectDescription: WideString;
    FControlObjectVersion: Integer;
    FCoverOpen: Boolean;
    FDeviceDescription: WideString;
    FErrorLevel: Integer;
    FErrorStation: Integer;
    FFlagWhenIdle: Boolean;
    FFontTypefaceList: WideString;
    FJrnCartridgeState: Integer;
    FJrnCurrentCartridge: Integer;
    FJrnEmpty: Boolean;
    FJrnLetterQuality: Boolean;
    FJrnLineChars: Integer;
    FJrnLineCharsList: WideString;
    FJrnLineHeight: Integer;
    FJrnLineSpacing: Integer;
    FJrnLineWidth: Integer;
    FJrnNearEnd: Boolean;
    FMapCharacterSet: Boolean;
    FMapMode: Integer;
    FPageModeArea: WideString;
    FPageModeDescriptor: Integer;
    FPageModeHorizontalPosition: Integer;
    FPageModePrintArea: WideString;
    FPageModePrintDirection: Integer;
    FPageModeStation: Integer;
    FPageModeVerticalPosition: Integer;
    FRecBarCodeRotationList: WideString;
    FRecBitmapRotationList: WideString;
    FRecCartridgeState: Integer;
    FRecCurrentCartridge: Integer;
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
    FRotateSpecial: Integer;
    FSlpBarCodeRotationList: WideString;
    FSlpBitmapRotationList: WideString;
    FSlpCartridgeState: Integer;
    FSlpCurrentCartridge: Integer;
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
    FSlpPrintSide: Integer;
    FSlpSidewaysMaxChars: Integer;
    FSlpSidewaysMaxLines: Integer;

    function ClearResult: Integer;
    function HandleException(E: Exception): Integer;
    procedure CheckEnabled;
    function IllegalError: Integer;
    procedure Initialize;
    procedure CheckRecStation(Station: Integer);
    procedure PrintText(const Data: WideString);
    procedure PrintGraphics(Graphic: TGraphic; Width, Alignment: Integer);
  public
    constructor Create2(AOwner: TComponent; ALogger: ILogFile);
    destructor Destroy; override;
  public
    function Get_OpenResult: Integer; safecall;
    function Get_CheckHealthText: WideString; safecall;
    function Get_Claimed: WordBool; safecall;
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
    function Get_CharacterSetList: WideString; safecall;
    function Get_CoverOpen: WordBool; safecall;
    function Get_ErrorStation: Integer; safecall;
    function Get_JrnEmpty: WordBool; safecall;
    function Get_JrnLineCharsList: WideString; safecall;
    function Get_JrnLineWidth: Integer; safecall;
    function Get_JrnNearEnd: WordBool; safecall;
    function Get_RecEmpty: WordBool; safecall;
    function Get_RecLineCharsList: WideString; safecall;
    function Get_RecLinesToPaperCut: Integer; safecall;
    function Get_RecLineWidth: Integer; safecall;
    function Get_RecNearEnd: WordBool; safecall;
    function Get_RecSidewaysMaxChars: Integer; safecall;
    function Get_RecSidewaysMaxLines: Integer; safecall;
    function Get_SlpEmpty: WordBool; safecall;
    function Get_SlpLineCharsList: WideString; safecall;
    function Get_SlpLinesNearEndToEnd: Integer; safecall;
    function Get_SlpLineWidth: Integer; safecall;
    function Get_SlpMaxLines: Integer; safecall;
    function Get_SlpNearEnd: WordBool; safecall;
    function Get_SlpSidewaysMaxChars: Integer; safecall;
    function Get_SlpSidewaysMaxLines: Integer; safecall;
    function Get_CapCharacterSet: Integer; safecall;
    function Get_CapTransaction: WordBool; safecall;
    function Get_ErrorLevel: Integer; safecall;
    function Get_ErrorString: WideString; safecall;
    function Get_FontTypefaceList: WideString; safecall;
    function Get_RecBarCodeRotationList: WideString; safecall;
    function Get_SlpBarCodeRotationList: WideString; safecall;
    function Get_CapPowerReporting: Integer; safecall;
    function Get_PowerState: Integer; safecall;
    function Get_CapJrnCartridgeSensor: Integer; safecall;
    function Get_CapJrnColor: Integer; safecall;
    function Get_CapRecCartridgeSensor: Integer; safecall;
    function Get_CapRecColor: Integer; safecall;
    function Get_CapRecMarkFeed: Integer; safecall;
    function Get_CapSlpBothSidesPrint: WordBool; safecall;
    function Get_CapSlpCartridgeSensor: Integer; safecall;
    function Get_CapSlpColor: Integer; safecall;
    function Get_JrnCartridgeState: Integer; safecall;
    function Get_RecCartridgeState: Integer; safecall;
    function Get_SlpCartridgeState: Integer; safecall;
    function Get_SlpPrintSide: Integer; safecall;
    function Get_CapMapCharacterSet: WordBool; safecall;
    function Get_RecBitmapRotationList: WideString; safecall;
    function Get_SlpBitmapRotationList: WideString; safecall;
    function Get_CapStatisticsReporting: WordBool; safecall;
    function Get_CapUpdateStatistics: WordBool; safecall;
    function Get_CapCompareFirmwareVersion: WordBool; safecall;
    function Get_CapUpdateFirmware: WordBool; safecall;
    function Get_CapConcurrentPageMode: WordBool; safecall;
    function Get_CapRecPageMode: WordBool; safecall;
    function Get_CapSlpPageMode: WordBool; safecall;
    function Get_PageModeArea: WideString; safecall;
    function Get_PageModeDescriptor: Integer; safecall;
    function Get_CapRecRuledLine: Integer; safecall;
    function Get_CapSlpRuledLine: Integer; safecall;
    function Get_DeviceEnabled: WordBool; safecall;
    function Get_FreezeEvents: WordBool; safecall;
    function Get_AsyncMode: WordBool; safecall;
    function Get_CharacterSet: Integer; safecall;
    function Get_FlagWhenIdle: WordBool; safecall;
    function Get_JrnLetterQuality: WordBool; safecall;
    function Get_JrnLineChars: Integer; safecall;
    function Get_JrnLineHeight: Integer; safecall;
    function Get_JrnLineSpacing: Integer; safecall;
    function Get_MapMode: Integer; safecall;
    function Get_RecLetterQuality: WordBool; safecall;
    function Get_RecLineChars: Integer; safecall;
    function Get_RecLineHeight: Integer; safecall;
    function Get_RecLineSpacing: Integer; safecall;
    function Get_SlpLetterQuality: WordBool; safecall;
    function Get_SlpLineChars: Integer; safecall;
    function Get_SlpLineHeight: Integer; safecall;
    function Get_SlpLineSpacing: Integer; safecall;
    function Get_RotateSpecial: Integer; safecall;
    function Get_BinaryConversion: Integer; safecall;
    function Get_PowerNotify: Integer; safecall;
    function Get_CartridgeNotify: Integer; safecall;
    function Get_JrnCurrentCartridge: Integer; safecall;
    function Get_RecCurrentCartridge: Integer; safecall;
    function Get_SlpCurrentCartridge: Integer; safecall;
    function Get_MapCharacterSet: WordBool; safecall;
    function Get_PageModeHorizontalPosition: Integer; safecall;
    function Get_PageModePrintArea: WideString; safecall;
    function Get_PageModePrintDirection: Integer; safecall;
    function Get_PageModeStation: Integer; safecall;
    function Get_PageModeVerticalPosition: Integer; safecall;
  public
    procedure Set_DeviceEnabled(pDeviceEnabled: WordBool); safecall;
    procedure Set_FreezeEvents(pFreezeEvents: WordBool); safecall;
    procedure Set_AsyncMode(pAsyncMode: WordBool); safecall;
    procedure Set_CharacterSet(pCharacterSet: Integer); safecall;
    procedure Set_FlagWhenIdle(pFlagWhenIdle: WordBool); safecall;
    procedure Set_JrnLetterQuality(pJrnLetterQuality: WordBool); safecall;
    procedure Set_JrnLineChars(pJrnLineChars: Integer); safecall;
    procedure Set_JrnLineHeight(pJrnLineHeight: Integer); safecall;
    procedure Set_JrnLineSpacing(pJrnLineSpacing: Integer); safecall;
    procedure Set_MapMode(pMapMode: Integer); safecall;
    procedure Set_RecLetterQuality(pRecLetterQuality: WordBool); safecall;
    procedure Set_RecLineChars(pRecLineChars: Integer); safecall;
    procedure Set_RecLineHeight(pRecLineHeight: Integer); safecall;
    procedure Set_RecLineSpacing(pRecLineSpacing: Integer); safecall;
    procedure Set_SlpLetterQuality(pSlpLetterQuality: WordBool); safecall;
    procedure Set_SlpLineChars(pSlpLineChars: Integer); safecall;
    procedure Set_SlpLineHeight(pSlpLineHeight: Integer); safecall;
    procedure Set_SlpLineSpacing(pSlpLineSpacing: Integer); safecall;
    procedure Set_RotateSpecial(pRotateSpecial: Integer); safecall;
    procedure Set_BinaryConversion(pBinaryConversion: Integer); safecall;
    procedure Set_PowerNotify(pPowerNotify: Integer); safecall;
    procedure Set_CartridgeNotify(pCartridgeNotify: Integer); safecall;
    procedure Set_JrnCurrentCartridge(pJrnCurrentCartridge: Integer); safecall;
    procedure Set_RecCurrentCartridge(pRecCurrentCartridge: Integer); safecall;
    procedure Set_SlpCurrentCartridge(pSlpCurrentCartridge: Integer); safecall;
    procedure Set_MapCharacterSet(pMapCharacterSet: WordBool); safecall;
    procedure Set_PageModeHorizontalPosition(pPageModeHorizontalPosition: Integer); safecall;
    procedure Set_PageModePrintArea(const pPageModePrintArea: WideString); safecall;
    procedure Set_PageModePrintDirection(pPageModePrintDirection: Integer); safecall;
    procedure Set_PageModeStation(pPageModeStation: Integer); safecall;
    procedure Set_PageModeVerticalPosition(pPageModeVerticalPosition: Integer); safecall;
  public
    procedure SODataDummy(Status: Integer); safecall;
    procedure SODirectIO(EventNumber: Integer; var pData: Integer; var pString: WideString); safecall;
    procedure SOError(ResultCode: Integer; ResultCodeExtended: Integer; ErrorLocus: Integer; var pErrorResponse: Integer); safecall;
    procedure SOOutputComplete(OutputID: Integer); safecall;
    procedure SOStatusUpdate(Data: Integer); safecall;
    function SOProcessID: Integer; safecall;
    function CheckHealth(Level: Integer): Integer; safecall;
    function ClaimDevice(Timeout: Integer): Integer; safecall;
    function ClearOutput: Integer; safecall;
    function Close: Integer; safecall;
    function DirectIO(Command: Integer; var pData: Integer; var pString: WideString): Integer; safecall;
    function Open(const DeviceName: WideString): Integer; safecall;
    function ReleaseDevice: Integer; safecall;
    function BeginInsertion(Timeout: Integer): Integer; safecall;
    function BeginRemoval(Timeout: Integer): Integer; safecall;
    function CutPaper(Percentage: Integer): Integer; safecall;
    function EndInsertion: Integer; safecall;
    function EndRemoval: Integer; safecall;
    function PrintBarCode(Station: Integer; const Data: WideString; Symbology: Integer; Height: Integer; Width: Integer; Alignment: Integer; TextPosition: Integer): Integer; safecall;
    function PrintBitmap(Station: Integer; const FileName: WideString; Width: Integer; Alignment: Integer): Integer; safecall;
    function PrintImmediate(Station: Integer; const Data: WideString): Integer; safecall;
    function PrintNormal(Station: Integer; const Data: WideString): Integer; safecall;
    function PrintTwoNormal(Stations: Integer; const Data1: WideString; const Data2: WideString): Integer; safecall;
    function RotatePrint(Station: Integer; Rotation: Integer): Integer; safecall;
    function SetBitmap(BitmapNumber: Integer; Station: Integer; const FileName: WideString; Width: Integer; Alignment: Integer): Integer; safecall;
    function SetLogo(Location: Integer; const Data: WideString): Integer; safecall;
    function TransactionPrint(Station: Integer; Control: Integer): Integer; safecall;
    function ValidateData(Station: Integer; const Data: WideString): Integer; safecall;
    function ChangePrintSide(Side: Integer): Integer; safecall;
    function MarkFeed(Type_: Integer): Integer; safecall;
    function ResetStatistics(const StatisticsBuffer: WideString): Integer; safecall;
    function RetrieveStatistics(var pStatisticsBuffer: WideString): Integer; safecall;
    function UpdateStatistics(const StatisticsBuffer: WideString): Integer; safecall;
    function CompareFirmwareVersion(const FirmwareFileName: WideString; out pResult: Integer): Integer; safecall;
    function UpdateFirmware(const FirmwareFileName: WideString): Integer; safecall;
    function ClearPrintArea: Integer; safecall;
    function PageModePrint(Control: Integer): Integer; safecall;
    function PrintMemoryBitmap(Station: Integer; const Data: WideString; Type_: Integer; Width: Integer; Alignment: Integer): Integer; safecall;
    function DrawRuledLine(Station: Integer; const PositionList: WideString; LineDirection: Integer; LineWidth: Integer; LineStyle: Integer; LineColor: Integer): Integer; safecall;
  public
    property OpenResult: Integer read Get_OpenResult;
    property CheckHealthText: WideString read Get_CheckHealthText;
    property Claimed: WordBool read Get_Claimed;
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
    property CharacterSetList: WideString read Get_CharacterSetList;
    property CoverOpen: WordBool read Get_CoverOpen;
    property ErrorStation: Integer read Get_ErrorStation;
    property JrnEmpty: WordBool read Get_JrnEmpty;
    property JrnLineCharsList: WideString read Get_JrnLineCharsList;
    property JrnLineWidth: Integer read Get_JrnLineWidth;
    property JrnNearEnd: WordBool read Get_JrnNearEnd;
    property RecEmpty: WordBool read Get_RecEmpty;
    property RecLineCharsList: WideString read Get_RecLineCharsList;
    property RecLinesToPaperCut: Integer read Get_RecLinesToPaperCut;
    property RecLineWidth: Integer read Get_RecLineWidth;
    property RecNearEnd: WordBool read Get_RecNearEnd;
    property RecSidewaysMaxChars: Integer read Get_RecSidewaysMaxChars;
    property RecSidewaysMaxLines: Integer read Get_RecSidewaysMaxLines;
    property SlpEmpty: WordBool read Get_SlpEmpty;
    property SlpLineCharsList: WideString read Get_SlpLineCharsList;
    property SlpLinesNearEndToEnd: Integer read Get_SlpLinesNearEndToEnd;
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
    property SlpBarCodeRotationList: WideString read Get_SlpBarCodeRotationList;
    property CapPowerReporting: Integer read Get_CapPowerReporting;
    property PowerState: Integer read Get_PowerState;
    property CapJrnCartridgeSensor: Integer read Get_CapJrnCartridgeSensor;
    property CapJrnColor: Integer read Get_CapJrnColor;
    property CapRecCartridgeSensor: Integer read Get_CapRecCartridgeSensor;
    property CapRecColor: Integer read Get_CapRecColor;
    property CapRecMarkFeed: Integer read Get_CapRecMarkFeed;
    property CapSlpBothSidesPrint: WordBool read Get_CapSlpBothSidesPrint;
    property CapSlpCartridgeSensor: Integer read Get_CapSlpCartridgeSensor;
    property CapSlpColor: Integer read Get_CapSlpColor;
    property JrnCartridgeState: Integer read Get_JrnCartridgeState;
    property RecCartridgeState: Integer read Get_RecCartridgeState;
    property SlpCartridgeState: Integer read Get_SlpCartridgeState;
    property SlpPrintSide: Integer read Get_SlpPrintSide;
    property CapMapCharacterSet: WordBool read Get_CapMapCharacterSet;
    property RecBitmapRotationList: WideString read Get_RecBitmapRotationList;
    property SlpBitmapRotationList: WideString read Get_SlpBitmapRotationList;
    property CapStatisticsReporting: WordBool read Get_CapStatisticsReporting;
    property CapUpdateStatistics: WordBool read Get_CapUpdateStatistics;
    property CapCompareFirmwareVersion: WordBool read Get_CapCompareFirmwareVersion;
    property CapUpdateFirmware: WordBool read Get_CapUpdateFirmware;
    property CapConcurrentPageMode: WordBool read Get_CapConcurrentPageMode;
    property CapRecPageMode: WordBool read Get_CapRecPageMode;
    property CapSlpPageMode: WordBool read Get_CapSlpPageMode;
    property PageModeArea: WideString read Get_PageModeArea;
    property PageModeDescriptor: Integer read Get_PageModeDescriptor;
    property CapRecRuledLine: Integer read Get_CapRecRuledLine;
    property CapSlpRuledLine: Integer read Get_CapSlpRuledLine;
    property DeviceEnabled: WordBool read Get_DeviceEnabled write Set_DeviceEnabled;
    property FreezeEvents: WordBool read Get_FreezeEvents write Set_FreezeEvents;
    property AsyncMode: WordBool read Get_AsyncMode write Set_AsyncMode;
    property CharacterSet: Integer read Get_CharacterSet write Set_CharacterSet;
    property FlagWhenIdle: WordBool read Get_FlagWhenIdle write Set_FlagWhenIdle;
    property JrnLetterQuality: WordBool read Get_JrnLetterQuality write Set_JrnLetterQuality;
    property JrnLineChars: Integer read Get_JrnLineChars write Set_JrnLineChars;
    property JrnLineHeight: Integer read Get_JrnLineHeight write Set_JrnLineHeight;
    property JrnLineSpacing: Integer read Get_JrnLineSpacing write Set_JrnLineSpacing;
    property MapMode: Integer read Get_MapMode write Set_MapMode;
    property RecLetterQuality: WordBool read Get_RecLetterQuality write Set_RecLetterQuality;
    property RecLineChars: Integer read Get_RecLineChars write Set_RecLineChars;
    property RecLineHeight: Integer read Get_RecLineHeight write Set_RecLineHeight;
    property RecLineSpacing: Integer read Get_RecLineSpacing write Set_RecLineSpacing;
    property SlpLetterQuality: WordBool read Get_SlpLetterQuality write Set_SlpLetterQuality;
    property SlpLineChars: Integer read Get_SlpLineChars write Set_SlpLineChars;
    property SlpLineHeight: Integer read Get_SlpLineHeight write Set_SlpLineHeight;
    property SlpLineSpacing: Integer read Get_SlpLineSpacing write Set_SlpLineSpacing;
    property RotateSpecial: Integer read Get_RotateSpecial write Set_RotateSpecial;
    property BinaryConversion: Integer read Get_BinaryConversion write Set_BinaryConversion;
    property PowerNotify: Integer read Get_PowerNotify write Set_PowerNotify;
    property CartridgeNotify: Integer read Get_CartridgeNotify write Set_CartridgeNotify;
    property JrnCurrentCartridge: Integer read Get_JrnCurrentCartridge write Set_JrnCurrentCartridge;
    property RecCurrentCartridge: Integer read Get_RecCurrentCartridge write Set_RecCurrentCartridge;
    property SlpCurrentCartridge: Integer read Get_SlpCurrentCartridge write Set_SlpCurrentCartridge;
    property MapCharacterSet: WordBool read Get_MapCharacterSet write Set_MapCharacterSet;
    property PageModeHorizontalPosition: Integer read Get_PageModeHorizontalPosition write Set_PageModeHorizontalPosition;
    property PageModePrintArea: WideString read Get_PageModePrintArea write Set_PageModePrintArea;
    property PageModePrintDirection: Integer read Get_PageModePrintDirection write Set_PageModePrintDirection;
    property PageModeStation: Integer read Get_PageModeStation write Set_PageModeStation;
    property PageModeVerticalPosition: Integer read Get_PageModeVerticalPosition write Set_PageModeVerticalPosition;
  public
    property FontName: WideString read FFontName write FFontName;
  end;

implementation

constructor TPosWinPrinter.Create2(AOwner: TComponent; ALogger: ILogFile);
begin
  inherited Create(AOwner);
  FLogger := ALogger;
  FDevice := TOposServiceDevice19.Create(FLogger);
  FDevice.ErrorEventEnabled := False;
  Initialize;
end;

destructor TPosWinPrinter.Destroy;
begin
  FDevice.Free;
  inherited Destroy;
end;

procedure TPosWinPrinter.Initialize;
begin
  FAsyncMode := False;
  FCapCharacterSet := PTR_CCS_ASCII;
  FCapCompareFirmwareVersion := False;
  FCapConcurrentJrnRec := False;
  FCapConcurrentJrnSlp := False;
  FCapConcurrentPageMode := False;
  FCapConcurrentRecSlp := False;
  FCapCoverSensor := True;
  FCapJrn2Color := False;
  FCapJrnBold := False;
  FCapJrnCartridgeSensor := PTR_CART_OK;
  FCapJrnColor := 0;
  FCapJrnDhigh := False;
  FCapJrnDwide := False;
  FCapJrnDwideDhigh := False;
  FCapJrnEmptySensor := False;
  FCapJrnItalic := False;
  FCapJrnNearEndSensor := False;
  FCapJrnPresent := False;
  FCapJrnUnderline := False;
  FCapMapCharacterSet := False;
  FCapPowerReporting := OPOS_PR_STANDARD;
  FCapRec2Color := False;
  FCapRecBarCode := True;
  FCapRecBitmap := True;
  FCapRecBold := True;
  FCapRecCartridgeSensor := PTR_CART_OK;
  FCapRecColor := PTR_COLOR_PRIMARY;
  FCapRecDhigh := True;
  FCapRecDwide := True;
  FCapRecDwideDhigh := True;
  FCapRecEmptySensor := True;
  FCapRecItalic := False;
  FCapRecLeft90 := True;
  FCapRecMarkFeed := 0;
  FCapRecNearEndSensor := False;
  FCapRecPageMode := True;
  FCapRecPapercut := True;
  FCapRecPresent := True;
  FCapRecRight90 := True;
  FCapRecRotate180 := False;

  FCapRecRuledLine := 0;
  FCapRecStamp := False;
  FCapRecUnderline := True;
  FCapSlp2Color := False;
  FCapSlpBarCode := False;
  FCapSlpBitmap := False;
  FCapSlpBold := False;
  FCapSlpBothSidesPrint := False;
  FCapSlpCartridgeSensor := 0;
  FCapSlpColor := 0;
  FCapSlpDhigh := False;
  FCapSlpDwide := False;
  FCapSlpDwideDhigh := False;
  FCapSlpEmptySensor := False;
  FCapSlpFullslip := False;
  FCapSlpItalic := False;
  FCapSlpLeft90 := False;
  FCapSlpNearEndSensor := False;
  FCapSlpPageMode := False;
  FCapSlpPresent := False;
  FCapSlpRight90 := False;
  FCapSlpRotate180 := False;
  FCapSlpRuledLine := 0;
  FCapSlpUnderline := False;
  FCapStatisticsReporting := False;
  FCapTransaction := True;
  FCapUpdateFirmware := False;
  FCapUpdateStatistics := False;
  FCartridgeNotify := 0;
  FCharacterSet := PTR_CCS_ASCII;
  FCharacterSetList := '255,437,737,775,850,852,857,858,860,863,864,865,866,874,1250,1251,1252,1253,1254,1256,1257,1258,28604';
  FCheckHealthText := '';
  FControlObjectDescription := 'OPOS Windows Printer';
  FControlObjectVersion := 1014001;
  FCoverOpen := False;
  FDeviceDescription := 'OPOS Windows Printer';
  FErrorLevel := PTR_EL_NONE;
  FErrorStation := PTR_S_RECEIPT;
  FFlagWhenIdle := False;
  FFontTypefaceList := '';
  FJrnCartridgeState := 0;
  FJrnCurrentCartridge := 0;
  FJrnEmpty := False;
  FJrnLetterQuality := False;
  FJrnLineChars := 42;
  FJrnLineCharsList := '';
  FJrnLineHeight := 0;
  FJrnLineSpacing := 0;
  FJrnLineWidth := 0;
  FJrnNearEnd := False;
  FMapCharacterSet := False;
  FMapMode := PTR_MM_DOTS;
  FPageModeArea := '512,832';
  FPageModeDescriptor := PTR_PM_BARCODE + PTR_PM_BC_ROTATE;
  FPageModeHorizontalPosition := 0;
  FPageModePrintArea := '0,0,0,0';
  FPageModePrintDirection := 0;
  FPageModeStation := 0;
  FPageModeVerticalPosition := 0;
  FRecBarCodeRotationList := '0';
  FRecBitmapRotationList := '';
  FRecCartridgeState := 0;
  FRecCurrentCartridge := 0;
  FRecEmpty := False;
  FRecLetterQuality := False;
  FRecLineChars := 42;
  FRecLineCharsList := '42,56';
  FRecLineHeight := 24;
  FRecLineSpacing := 30;
  FRecLinesToPaperCut := 5;
  FRecLineWidth := 512;
  FRecNearEnd := False;
  FRecSidewaysMaxChars := 69;
  FRecSidewaysMaxLines := 17;
  FRotateSpecial := 1;
  FSlpBarCodeRotationList := '';
  FSlpBitmapRotationList := '';
  FSlpCartridgeState := 0;
  FSlpCurrentCartridge := 0;
  FSlpEmpty := False;
  FSlpLetterQuality := False;
  FSlpLineChars := 0;
  FSlpLineCharsList := '';
  FSlpLineHeight := 0;
  FSlpLinesNearEndToEnd := 0;
  FSlpLineSpacing := 0;
  FSlpLineWidth := 0;
  FSlpMaxLines := 0;
  FSlpNearEnd := False;
  FSlpPrintSide := 0;
  FSlpSidewaysMaxChars := 0;
  FSlpSidewaysMaxLines := 0;
end;

function TPosWinPrinter.ClearResult: Integer;
begin
  Result := FDevice.ClearResult;
end;

procedure TPosWinPrinter.CheckEnabled;
begin
  FDevice.CheckEnabled;
end;

function TPosWinPrinter.IllegalError: Integer;
begin
  Result := FDevice.SetResultCode(OPOS_E_ILLEGAL);
end;

function TPosWinPrinter.HandleException(E: Exception): Integer;
var
  OPOSError: TOPOSError;
  OPOSException: EOPOSException;
begin
  if E is EOPOSException then
  begin
    OPOSException := E as EOPOSException;
    OPOSError.ErrorString := GetExceptionMessage(E);
    OPOSError.ResultCode := OPOSException.ResultCode;
    OPOSError.ResultCodeExtended := OPOSException.ResultCodeExtended;
    FDevice.HandleException(OPOSError);
    Result := OPOSError.ResultCode;
    Exit;
  end;

  OPOSError.ErrorString := GetExceptionMessage(E);
  OPOSError.ResultCode := OPOS_E_FAILURE;
  OPOSError.ResultCodeExtended := OPOS_SUCCESS;
  FDevice.HandleException(OPOSError);
  Result := OPOSError.ResultCode;
end;

function TPosWinPrinter.BeginInsertion(Timeout: Integer): Integer;
begin
  Result := ClearResult;
end;

function TPosWinPrinter.BeginRemoval(Timeout: Integer): Integer;
begin
  Result := ClearResult;
end;

function TPosWinPrinter.ChangePrintSide(Side: Integer): Integer;
begin
  Result := ClearResult;
end;

function TPosWinPrinter.CheckHealth(Level: Integer): Integer;
begin
  Result := ClearResult;
end;

function TPosWinPrinter.ClaimDevice(Timeout: Integer): Integer;
begin
  try
    FDevice.ClaimDevice(Timeout);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TPosWinPrinter.ClearOutput: Integer;
begin
  try
    FDevice.CheckClaimed;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TPosWinPrinter.ClearPrintArea: Integer;
begin
  Result := ClearResult;
end;

function TPosWinPrinter.Close: Integer;
begin
  try
    Result := ClearResult;
    if not FDevice.Opened then Exit;

    Set_DeviceEnabled(False);
    FDevice.Close;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TPosWinPrinter.CompareFirmwareVersion(
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

function TPosWinPrinter.CutPaper(Percentage: Integer): Integer;
begin
  Result := ClearResult;
end;

function TPosWinPrinter.DirectIO(Command: Integer; var pData: Integer;
  var pString: WideString): Integer;
begin
  Result := ClearResult;
end;

function TPosWinPrinter.DrawRuledLine(Station: Integer;
  const PositionList: WideString; LineDirection, LineWidth, LineStyle,
  LineColor: Integer): Integer;
begin
  Result := ClearResult;
end;

function TPosWinPrinter.EndInsertion: Integer;
begin
  Result := ClearResult;
end;

function TPosWinPrinter.EndRemoval: Integer;
begin
  Result := ClearResult;
end;

function TPosWinPrinter.Get_AsyncMode: WordBool;
begin
  Result := FAsyncMode;
end;

function TPosWinPrinter.Get_BinaryConversion: Integer;
begin
  Result := FDevice.BinaryConversion;
end;

function TPosWinPrinter.Get_CapCharacterSet: Integer;
begin
  Result := FCapCharacterSet;
end;

function TPosWinPrinter.Get_CapCompareFirmwareVersion: WordBool;
begin
  Result := FCapCompareFirmwareVersion;
end;

function TPosWinPrinter.Get_CapConcurrentJrnRec: WordBool;
begin
  Result := FCapConcurrentJrnRec;
end;

function TPosWinPrinter.Get_CapConcurrentJrnSlp: WordBool;
begin
  Result := FCapConcurrentJrnSlp;
end;

function TPosWinPrinter.Get_CapConcurrentPageMode: WordBool;
begin
  Result := FCapConcurrentPageMode;
end;

function TPosWinPrinter.Get_CapConcurrentRecSlp: WordBool;
begin
  Result := FCapConcurrentRecSlp;
end;

function TPosWinPrinter.Get_CapCoverSensor: WordBool;
begin
  Result := FCapCoverSensor;
end;

function TPosWinPrinter.Get_CapJrn2Color: WordBool;
begin
  Result := FCapJrn2Color;
end;

function TPosWinPrinter.Get_CapJrnBold: WordBool;
begin
  Result := FCapJrnBold;
end;

function TPosWinPrinter.Get_CapJrnCartridgeSensor: Integer;
begin
  Result := FCapJrnCartridgeSensor;
end;

function TPosWinPrinter.Get_CapJrnColor: Integer;
begin
  Result := FCapJrnColor;
end;

function TPosWinPrinter.Get_CapJrnDhigh: WordBool;
begin
  Result := FCapJrnDhigh;
end;

function TPosWinPrinter.Get_CapJrnDwide: WordBool;
begin
  Result := FCapJrnDwide;
end;

function TPosWinPrinter.Get_CapJrnDwideDhigh: WordBool;
begin
  Result := FCapJrnDwideDhigh;
end;

function TPosWinPrinter.Get_CapJrnEmptySensor: WordBool;
begin
  Result := FCapJrnEmptySensor;
end;

function TPosWinPrinter.Get_CapJrnItalic: WordBool;
begin
  Result := FCapJrnItalic;
end;

function TPosWinPrinter.Get_CapJrnNearEndSensor: WordBool;
begin
  Result := FCapJrnNearEndSensor;
end;

function TPosWinPrinter.Get_CapJrnPresent: WordBool;
begin
  Result := FCapJrnPresent;
end;

function TPosWinPrinter.Get_CapJrnUnderline: WordBool;
begin
  Result := FCapJrnUnderline;
end;

function TPosWinPrinter.Get_CapMapCharacterSet: WordBool;
begin
  Result := FCapMapCharacterSet;
end;

function TPosWinPrinter.Get_CapPowerReporting: Integer;
begin
  Result := FCapPowerReporting;
end;

function TPosWinPrinter.Get_CapRec2Color: WordBool;
begin
  Result := FCapRec2Color;
end;

function TPosWinPrinter.Get_CapRecBarCode: WordBool;
begin
  Result := FCapRecBarCode;
end;

function TPosWinPrinter.Get_CapRecBitmap: WordBool;
begin
  Result := FCapRecBitmap;
end;

function TPosWinPrinter.Get_CapRecBold: WordBool;
begin
  Result := FCapRecBold;
end;

function TPosWinPrinter.Get_CapRecCartridgeSensor: Integer;
begin
  Result := FCapRecCartridgeSensor;
end;

function TPosWinPrinter.Get_CapRecColor: Integer;
begin
  Result := FCapRecColor;
end;

function TPosWinPrinter.Get_CapRecDhigh: WordBool;
begin
  Result := FCapRecDhigh;
end;

function TPosWinPrinter.Get_CapRecDwide: WordBool;
begin
  Result := FCapRecDwide;
end;

function TPosWinPrinter.Get_CapRecDwideDhigh: WordBool;
begin
  Result := FCapRecDwideDhigh;
end;

function TPosWinPrinter.Get_CapRecEmptySensor: WordBool;
begin
  Result := FCapRecEmptySensor;
end;

function TPosWinPrinter.Get_CapRecItalic: WordBool;
begin
  Result := FCapRecItalic;
end;

function TPosWinPrinter.Get_CapRecLeft90: WordBool;
begin
  Result := FCapRecLeft90;
end;

function TPosWinPrinter.Get_CapRecMarkFeed: Integer;
begin
  Result := FCapRecMarkFeed;
end;

function TPosWinPrinter.Get_CapRecNearEndSensor: WordBool;
begin
  Result := FCapRecNearEndSensor;
end;

function TPosWinPrinter.Get_CapRecPageMode: WordBool;
begin
  Result := FCapRecPageMode;
end;

function TPosWinPrinter.Get_CapRecPapercut: WordBool;
begin
  Result := FCapRecPapercut;
end;

function TPosWinPrinter.Get_CapRecPresent: WordBool;
begin
  Result := FCapRecPresent;
end;

function TPosWinPrinter.Get_CapRecRight90: WordBool;
begin
  Result := FCapRecRight90;
end;

function TPosWinPrinter.Get_CapRecRotate180: WordBool;
begin
  Result := FCapRecRotate180;
end;

function TPosWinPrinter.Get_CapRecRuledLine: Integer;
begin
  Result := FCapRecRuledLine;
end;

function TPosWinPrinter.Get_CapRecStamp: WordBool;
begin
  Result := FCapRecStamp;
end;

function TPosWinPrinter.Get_CapRecUnderline: WordBool;
begin
  Result := FCapRecUnderline;
end;

function TPosWinPrinter.Get_CapSlp2Color: WordBool;
begin
  Result := FCapSlp2Color;
end;

function TPosWinPrinter.Get_CapSlpBarCode: WordBool;
begin
  Result := FCapSlpBarCode;
end;

function TPosWinPrinter.Get_CapSlpBitmap: WordBool;
begin
  Result := FCapSlpBitmap;
end;

function TPosWinPrinter.Get_CapSlpBold: WordBool;
begin
  Result := FCapSlpBold;
end;

function TPosWinPrinter.Get_CapSlpBothSidesPrint: WordBool;
begin
  Result := FCapSlpBothSidesPrint;
end;

function TPosWinPrinter.Get_CapSlpCartridgeSensor: Integer;
begin
  Result := FCapSlpCartridgeSensor;
end;

function TPosWinPrinter.Get_CapSlpColor: Integer;
begin
  Result := FCapSlpColor;
end;

function TPosWinPrinter.Get_CapSlpDhigh: WordBool;
begin
  Result := FCapSlpDhigh;
end;

function TPosWinPrinter.Get_CapSlpDwide: WordBool;
begin
  Result := FCapSlpDwide;
end;

function TPosWinPrinter.Get_CapSlpDwideDhigh: WordBool;
begin
  Result := FCapSlpDwideDhigh;
end;

function TPosWinPrinter.Get_CapSlpEmptySensor: WordBool;
begin
  Result := FCapSlpEmptySensor;
end;

function TPosWinPrinter.Get_CapSlpFullslip: WordBool;
begin
  Result := FCapSlpFullslip;
end;

function TPosWinPrinter.Get_CapSlpItalic: WordBool;
begin
  Result := FCapSlpItalic;
end;

function TPosWinPrinter.Get_CapSlpLeft90: WordBool;
begin
  Result := FCapSlpLeft90;
end;

function TPosWinPrinter.Get_CapSlpNearEndSensor: WordBool;
begin
  Result := FCapSlpNearEndSensor;
end;

function TPosWinPrinter.Get_CapSlpPageMode: WordBool;
begin
  Result := FCapSlpPageMode;
end;

function TPosWinPrinter.Get_CapSlpPresent: WordBool;
begin
  Result := FCapSlpPresent;
end;

function TPosWinPrinter.Get_CapSlpRight90: WordBool;
begin
  Result := FCapSlpRight90;
end;

function TPosWinPrinter.Get_CapSlpRotate180: WordBool;
begin
  Result := FCapSlpRotate180;
end;

function TPosWinPrinter.Get_CapSlpRuledLine: Integer;
begin
  Result := FCapSlpRuledLine;
end;

function TPosWinPrinter.Get_CapSlpUnderline: WordBool;
begin
  Result := FCapSlpUnderline;
end;

function TPosWinPrinter.Get_CapStatisticsReporting: WordBool;
begin
  Result := FCapStatisticsReporting;
end;

function TPosWinPrinter.Get_CapTransaction: WordBool;
begin
  Result := FCapTransaction;
end;

function TPosWinPrinter.Get_CapUpdateFirmware: WordBool;
begin
  Result := FCapUpdateFirmware;
end;

function TPosWinPrinter.Get_CapUpdateStatistics: WordBool;
begin
  Result := FCapUpdateStatistics;
end;

function TPosWinPrinter.Get_CartridgeNotify: Integer;
begin
  Result := FCartridgeNotify;
end;

function TPosWinPrinter.Get_CharacterSet: Integer;
begin
  Result := FCharacterSet;
end;

function TPosWinPrinter.Get_CharacterSetList: WideString;
begin
  Result := FCharacterSetList;
end;

function TPosWinPrinter.Get_CheckHealthText: WideString;
begin
  Result := FCheckHealthText;
end;

function TPosWinPrinter.Get_Claimed: WordBool;
begin
  Result := FDevice.Claimed;
end;

function TPosWinPrinter.Get_ControlObjectDescription: WideString;
begin
  Result := FControlObjectDescription;
end;

function TPosWinPrinter.Get_ControlObjectVersion: Integer;
begin
  Result := FControlObjectVersion;
end;

function TPosWinPrinter.Get_CoverOpen: WordBool;
begin
  Result := FCoverOpen;
end;

function TPosWinPrinter.Get_DeviceDescription: WideString;
begin
  Result := FDeviceDescription;
end;

function TPosWinPrinter.Get_DeviceEnabled: WordBool;
begin
  Result := FDevice.DeviceEnabled;
end;

function TPosWinPrinter.Get_DeviceName: WideString;
begin
  Result := FDevice.DeviceName;
end;

function TPosWinPrinter.Get_ErrorLevel: Integer;
begin
  Result := FErrorLevel;
end;

function TPosWinPrinter.Get_ErrorStation: Integer;
begin
  Result := FErrorStation;
end;

function TPosWinPrinter.Get_ErrorString: WideString;
begin
  Result := FDevice.ErrorString;
end;

function TPosWinPrinter.Get_FlagWhenIdle: WordBool;
begin
  Result := FFlagWhenIdle;
end;

function TPosWinPrinter.Get_FontTypefaceList: WideString;
begin
  Result := FFontTypefaceList;
end;

function TPosWinPrinter.Get_FreezeEvents: WordBool;
begin
  Result := FDevice.FreezeEvents;
end;

function TPosWinPrinter.Get_JrnCartridgeState: Integer;
begin
  Result := FJrnCartridgeState;
end;

function TPosWinPrinter.Get_JrnCurrentCartridge: Integer;
begin
  Result := FJrnCurrentCartridge;
end;

function TPosWinPrinter.Get_JrnEmpty: WordBool;
begin
  Result := FJrnEmpty;
end;

function TPosWinPrinter.Get_JrnLetterQuality: WordBool;
begin
  Result := FJrnLetterQuality;
end;

function TPosWinPrinter.Get_JrnLineChars: Integer;
begin
  Result := FJrnLineChars;
end;

function TPosWinPrinter.Get_JrnLineCharsList: WideString;
begin
  Result := FJrnLineCharsList;
end;

function TPosWinPrinter.Get_JrnLineHeight: Integer;
begin
  Result := FJrnLineHeight;
end;

function TPosWinPrinter.Get_JrnLineSpacing: Integer;
begin
  Result := FJrnLineSpacing;
end;

function TPosWinPrinter.Get_JrnLineWidth: Integer;
begin
  Result := FJrnLineWidth;
end;

function TPosWinPrinter.Get_JrnNearEnd: WordBool;
begin
  Result := FJrnNearEnd;
end;

function TPosWinPrinter.Get_MapCharacterSet: WordBool;
begin
  Result := FMapCharacterSet;
end;

function TPosWinPrinter.Get_MapMode: Integer;
begin
  Result := FMapMode;
end;

function TPosWinPrinter.Get_OpenResult: Integer;
begin
  Result := FDevice.OpenResult;
end;

function TPosWinPrinter.Get_OutputID: Integer;
begin
  Result := FDevice.OutputID;
end;

function TPosWinPrinter.Get_PageModeArea: WideString;
begin
  Result := FPageModeArea;
end;

function TPosWinPrinter.Get_PageModeDescriptor: Integer;
begin
  Result := FPageModeDescriptor;
end;

function TPosWinPrinter.Get_PageModeHorizontalPosition: Integer;
begin
  Result := FPageModeHorizontalPosition;
end;

function TPosWinPrinter.Get_PageModePrintArea: WideString;
begin
  Result := FPageModePrintArea;
end;

function TPosWinPrinter.Get_PageModePrintDirection: Integer;
begin
  Result := FPageModePrintDirection;
end;

function TPosWinPrinter.Get_PageModeStation: Integer;
begin
  Result := FPageModeStation;
end;

function TPosWinPrinter.Get_PageModeVerticalPosition: Integer;
begin
  Result := FPageModeVerticalPosition;
end;

function TPosWinPrinter.Get_PowerNotify: Integer;
begin
  Result := FDevice.PowerNotify;
end;

function TPosWinPrinter.Get_PowerState: Integer;
begin
  Result := FDevice.PowerState;
end;

function TPosWinPrinter.Get_RecBarCodeRotationList: WideString;
begin
  Result := FRecBarCodeRotationList;
end;

function TPosWinPrinter.Get_RecBitmapRotationList: WideString;
begin
  Result := FRecBitmapRotationList;
end;

function TPosWinPrinter.Get_RecCartridgeState: Integer;
begin
  Result := FRecCartridgeState;
end;

function TPosWinPrinter.Get_RecCurrentCartridge: Integer;
begin
  Result := FRecCurrentCartridge;
end;

function TPosWinPrinter.Get_RecEmpty: WordBool;
begin
  Result := FRecEmpty;
end;

function TPosWinPrinter.Get_RecLetterQuality: WordBool;
begin
  Result := FRecLetterQuality;
end;

function TPosWinPrinter.Get_RecLineChars: Integer;
begin
  Result := FRecLineChars;
end;

function TPosWinPrinter.Get_RecLineCharsList: WideString;
begin
  Result := FRecLineCharsList;
end;

function TPosWinPrinter.Get_RecLineHeight: Integer;
begin
  Result := FRecLineHeight;
end;

function TPosWinPrinter.Get_RecLineSpacing: Integer;
begin
  Result := FRecLineSpacing;
end;

function TPosWinPrinter.Get_RecLinesToPaperCut: Integer;
begin
  Result := FRecLinesToPaperCut;
end;

function TPosWinPrinter.Get_RecLineWidth: Integer;
begin
  Result := FRecLineWidth;
end;

function TPosWinPrinter.Get_RecNearEnd: WordBool;
begin
  Result := FRecNearEnd;
end;

function TPosWinPrinter.Get_RecSidewaysMaxChars: Integer;
begin
  Result := FRecSidewaysMaxChars;
end;

function TPosWinPrinter.Get_RecSidewaysMaxLines: Integer;
begin
  Result := FRecSidewaysMaxLines;
end;

function TPosWinPrinter.Get_ResultCode: Integer;
begin
  Result := FDevice.ResultCode;
end;

function TPosWinPrinter.Get_ResultCodeExtended: Integer;
begin
  Result := FDevice.ResultCodeExtended;
end;

function TPosWinPrinter.Get_RotateSpecial: Integer;
begin
  Result := FRotateSpecial;
end;

function TPosWinPrinter.Get_ServiceObjectDescription: WideString;
begin
  Result := FDevice.ServiceObjectDescription;
end;

function TPosWinPrinter.Get_ServiceObjectVersion: Integer;
begin
  Result := FDevice.ServiceObjectVersion;
end;

function TPosWinPrinter.Get_SlpBarCodeRotationList: WideString;
begin
  Result := FSlpBarCodeRotationList;
end;

function TPosWinPrinter.Get_SlpBitmapRotationList: WideString;
begin
  Result := FSlpBitmapRotationList;
end;

function TPosWinPrinter.Get_SlpCartridgeState: Integer;
begin
  Result := FSlpCartridgeState;
end;

function TPosWinPrinter.Get_SlpCurrentCartridge: Integer;
begin
  Result := FSlpCurrentCartridge;
end;

function TPosWinPrinter.Get_SlpEmpty: WordBool;
begin
  Result := FSlpEmpty;
end;

function TPosWinPrinter.Get_SlpLetterQuality: WordBool;
begin
  Result := FSlpLetterQuality;
end;

function TPosWinPrinter.Get_SlpLineChars: Integer;
begin
  Result := FSlpLineChars;
end;

function TPosWinPrinter.Get_SlpLineCharsList: WideString;
begin
  Result := FSlpLineCharsList;
end;

function TPosWinPrinter.Get_SlpLineHeight: Integer;
begin
  Result := FSlpLineHeight;
end;

function TPosWinPrinter.Get_SlpLinesNearEndToEnd: Integer;
begin
  Result := FSlpLinesNearEndToEnd;
end;

function TPosWinPrinter.Get_SlpLineSpacing: Integer;
begin
  Result := FSlpLineSpacing;
end;

function TPosWinPrinter.Get_SlpLineWidth: Integer;
begin
  Result := FSlpLineWidth;
end;

function TPosWinPrinter.Get_SlpMaxLines: Integer;
begin
  Result := FSlpMaxLines;
end;

function TPosWinPrinter.Get_SlpNearEnd: WordBool;
begin
  Result := FSlpNearEnd;
end;

function TPosWinPrinter.Get_SlpPrintSide: Integer;
begin
  Result := FSlpPrintSide;
end;

function TPosWinPrinter.Get_SlpSidewaysMaxChars: Integer;
begin
  Result := FSlpSidewaysMaxChars;
end;

function TPosWinPrinter.Get_SlpSidewaysMaxLines: Integer;
begin
  Result := FSlpSidewaysMaxLines;
end;

function TPosWinPrinter.Get_State: Integer;
begin
  Result := FDevice.State;
end;

function TPosWinPrinter.MarkFeed(Type_: Integer): Integer;
begin
  Result := ClearResult;
end;

function TPosWinPrinter.Open(const DeviceName: WideString): Integer;
begin
  try
    FDevice.Open('POSPrinter', DeviceName, nil);
    Printer.PrinterIndex := Printer.Printers.IndexOf(DeviceName);
    Printer.Canvas.Font.Name := FontName;

    Result := ClearResult;
  except
    on E: Exception do
    begin
      Close;
      Result := HandleException(E);
    end;
  end;
end;

function TPosWinPrinter.PageModePrint(Control: Integer): Integer;
begin
  Result := ClearResult;
end;

function TPosWinPrinter.PrintBarCode(Station: Integer;
  const Data: WideString; Symbology, Height, Width, Alignment,
  TextPosition: Integer): Integer;
begin
  Result := ClearResult;
end;

function TPosWinPrinter.PrintBitmap(Station: Integer;
  const FileName: WideString; Width, Alignment: Integer): Integer;
var
  Bitmap: TBitmap;
begin
  Bitmap := TBitmap.Create;
  try
    CheckRecStation(Station);
    Bitmap.LoadFromFile(FileName);
    PrintGraphics(Bitmap, Width, Alignment);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
  Bitmap.Free;
end;

function TPosWinPrinter.PrintImmediate(Station: Integer;
  const Data: WideString): Integer;
begin
  Result := ClearResult;
end;

procedure ScaleGraphic(Graphic: TGraphic; Scale: Integer);
var
  P: TPoint;
  DstBitmap: TBitmap;
begin
  DstBitmap := TBitmap.Create;
  try
    DstBitmap.Monochrome := True;
    DstBitmap.PixelFormat := pf1Bit;
    P.X := Graphic.Width * Scale;
    P.Y := Graphic.Height * Scale;
    DstBitmap.Width := P.X;
    DstBitmap.Height := P.Y;
    DstBitmap.Canvas.StretchDraw(Rect(0, 0, P.X, P.Y), Graphic);
    Graphic.Assign(DstBitmap);
  finally
    DstBitmap.Free;
  end;
end;

procedure TPosWinPrinter.PrintGraphics(Graphic: TGraphic;
  Width, Alignment: Integer);
var
  PositionX: Integer;
begin
  PositionX := 0;
  ScaleGraphic(Graphic, 2);
  if Graphic.Width < RecLineWidth then
  begin
    if Alignment = PTR_BM_RIGHT then
      PositionX := RecLineWidth - Graphic.Width;
    if Alignment = PTR_BM_CENTER then
      PositionX := (RecLineWidth - Graphic.Width) div 2;
  end;
  Printer.Canvas.Draw(PositionX, FPositionY, Graphic);
  Inc(FPositionY, Graphic.Height + RecLineSpacing);
end;

function TPosWinPrinter.PrintMemoryBitmap(Station: Integer;
  const Data: WideString; Type_, Width, Alignment: Integer): Integer;
var
  Bitmap: TBitmap;
  BinaryData: string;
  Stream: TMemoryStream;
begin
  Bitmap := TBitmap.Create;
  Stream := TMemoryStream.Create;
  try
    CheckRecStation(Station);
    BinaryData := FDevice.TextToBinary(Data);
    if Length(BinaryData) > 0 then
    begin
      Stream.Write(BinaryData[1], Length(BinaryData));

      Stream.Position := 0;
      case Type_ of
        PTR_BMT_BMP: Bitmap.LoadFromStream(Stream);
      else
        raiseIllegalError('Only BMP supported');
      end;
      PrintGraphics(Bitmap, Width, Alignment);
    end;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
  Bitmap.Free;
  Stream.Free;
end;

procedure TPosWinPrinter.CheckRecStation(Station: Integer);
begin
  if Station <> PTR_S_RECEIPT then
    raiseIllegalError('Station not supported');
end;

procedure TPosWinPrinter.PrintText(const Data: WideString);
var
  i: Integer;
  Text: WideString;
  Lines: TTntStringList;
  IsDoubleHighAndWide: Boolean;
begin
  Lines := TTntStringList.Create;
  try
    Lines.Text := Data;
    for i := 0 to Lines.Count-1 do
    begin
      Text := Lines[i];
      IsDoubleHighAndWide := Pos(ESC_DoubleHighWide, Text) <> 0;
      if IsDoubleHighAndWide then
      begin
        Text := StringReplace(Text, ESC_DoubleHighWide, '', []);
        Printer.Canvas.Font.Name := 'FontA22';
      end;
      Printer.Canvas.TextOut(0, FPositionY, Text);
      Inc(FPositionY, RecLineSpacing);
      if IsDoubleHighAndWide then
      begin
        Printer.Canvas.Font.Name := 'FontA11';
        Inc(FPositionY, RecLineSpacing);
      end;
    end;
  finally
    Lines.Free;
  end;
end;

function TPosWinPrinter.PrintNormal(Station: Integer;
  const Data: WideString): Integer;
begin
  try
    CheckRecStation(Station);
    PrintText(Data);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TPosWinPrinter.PrintTwoNormal(Stations: Integer; const Data1,
  Data2: WideString): Integer;
begin
  Result := ClearResult;
end;

function TPosWinPrinter.ReleaseDevice: Integer;
begin
  try
    FDevice.ReleaseDevice;
    Result := ClearResult;
  except
    on E: Exception do
    begin
      Result := HandleException(E);
    end;
  end;
end;

function TPosWinPrinter.ResetStatistics(
  const StatisticsBuffer: WideString): Integer;
begin
  Result := ClearResult;
end;

function TPosWinPrinter.RetrieveStatistics(
  var pStatisticsBuffer: WideString): Integer;
begin
  Result := ClearResult;
end;

function TPosWinPrinter.RotatePrint(Station, Rotation: Integer): Integer;
begin
  Result := ClearResult;
end;

procedure TPosWinPrinter.Set_AsyncMode(pAsyncMode: WordBool);
begin
  FAsyncMode := pAsyncMode;
end;

procedure TPosWinPrinter.Set_BinaryConversion(pBinaryConversion: Integer);
begin
  FDevice.BinaryConversion := pBinaryConversion;
end;

procedure TPosWinPrinter.Set_CartridgeNotify(pCartridgeNotify: Integer);
begin
  FCartridgeNotify := pCartridgeNotify;
end;

procedure TPosWinPrinter.Set_CharacterSet(pCharacterSet: Integer);
begin
  FCharacterSet := pCharacterSet;
end;

procedure TPosWinPrinter.Set_DeviceEnabled(pDeviceEnabled: WordBool);
begin
  FDevice.DeviceEnabled := pDeviceEnabled;
end;

procedure TPosWinPrinter.Set_FlagWhenIdle(pFlagWhenIdle: WordBool);
begin
  FFlagWhenIdle := pFlagWhenIdle;
end;

procedure TPosWinPrinter.Set_FreezeEvents(pFreezeEvents: WordBool);
begin
  FDevice.FreezeEvents := pFreezeEvents;
end;

procedure TPosWinPrinter.Set_JrnCurrentCartridge(
  pJrnCurrentCartridge: Integer);
begin
  FJrnCurrentCartridge := pJrnCurrentCartridge;
end;

procedure TPosWinPrinter.Set_JrnLetterQuality(pJrnLetterQuality: WordBool);
begin
  FJrnLetterQuality := pJrnLetterQuality;
end;

procedure TPosWinPrinter.Set_JrnLineChars(pJrnLineChars: Integer);
begin
  FJrnLineChars := pJrnLineChars;
end;

procedure TPosWinPrinter.Set_JrnLineHeight(pJrnLineHeight: Integer);
begin
  FJrnLineHeight := pJrnLineHeight;
end;

procedure TPosWinPrinter.Set_JrnLineSpacing(pJrnLineSpacing: Integer);
begin
  FJrnLineSpacing := pJrnLineSpacing;
end;

procedure TPosWinPrinter.Set_MapCharacterSet(pMapCharacterSet: WordBool);
begin
  FMapCharacterSet := pMapCharacterSet;
end;

procedure TPosWinPrinter.Set_MapMode(pMapMode: Integer);
begin
  FMapMode := pMapMode;
end;

procedure TPosWinPrinter.Set_PageModeHorizontalPosition(
  pPageModeHorizontalPosition: Integer);
begin
  FPageModeHorizontalPosition := pPageModeHorizontalPosition;
end;

procedure TPosWinPrinter.Set_PageModePrintArea(
  const pPageModePrintArea: WideString);
begin
  FPageModePrintArea := pPageModePrintArea;
end;

procedure TPosWinPrinter.Set_PageModePrintDirection(
  pPageModePrintDirection: Integer);
begin
  FPageModePrintDirection := pPageModePrintDirection;
end;

procedure TPosWinPrinter.Set_PageModeStation(pPageModeStation: Integer);
begin
  FPageModeStation := pPageModeStation;
end;

procedure TPosWinPrinter.Set_PageModeVerticalPosition(
  pPageModeVerticalPosition: Integer);
begin
  FPageModeVerticalPosition := pPageModeVerticalPosition;
end;

procedure TPosWinPrinter.Set_PowerNotify(pPowerNotify: Integer);
begin
  FDevice.PowerNotify := pPowerNotify;
end;

procedure TPosWinPrinter.Set_RecCurrentCartridge(
  pRecCurrentCartridge: Integer);
begin
  FRecCurrentCartridge := pRecCurrentCartridge;
end;

procedure TPosWinPrinter.Set_RecLetterQuality(pRecLetterQuality: WordBool);
begin
  FRecLetterQuality := pRecLetterQuality;
end;

procedure TPosWinPrinter.Set_RecLineChars(pRecLineChars: Integer);
begin
  FRecLineChars := pRecLineChars;
end;

procedure TPosWinPrinter.Set_RecLineHeight(pRecLineHeight: Integer);
begin
  FRecLineHeight := pRecLineHeight;
end;

procedure TPosWinPrinter.Set_RecLineSpacing(pRecLineSpacing: Integer);
begin
  FRecLineSpacing := pRecLineSpacing;
end;

procedure TPosWinPrinter.Set_RotateSpecial(pRotateSpecial: Integer);
begin
  FRotateSpecial := pRotateSpecial;
end;

procedure TPosWinPrinter.Set_SlpCurrentCartridge(
  pSlpCurrentCartridge: Integer);
begin
  FSlpCurrentCartridge := pSlpCurrentCartridge;
end;

procedure TPosWinPrinter.Set_SlpLetterQuality(pSlpLetterQuality: WordBool);
begin
  FSlpLetterQuality := pSlpLetterQuality;
end;

procedure TPosWinPrinter.Set_SlpLineChars(pSlpLineChars: Integer);
begin
  FSlpLineChars := pSlpLineChars;
end;

procedure TPosWinPrinter.Set_SlpLineHeight(pSlpLineHeight: Integer);
begin
  FSlpLineHeight := pSlpLineHeight;
end;

procedure TPosWinPrinter.Set_SlpLineSpacing(pSlpLineSpacing: Integer);
begin
  FSlpLineSpacing := pSlpLineSpacing;
end;

function TPosWinPrinter.SetBitmap(BitmapNumber, Station: Integer;
  const FileName: WideString; Width, Alignment: Integer): Integer;
begin
  Result := ClearResult;
end;

function TPosWinPrinter.SetLogo(Location: Integer;
  const Data: WideString): Integer;
begin
  Result := ClearResult;
end;

procedure TPosWinPrinter.SODataDummy(Status: Integer);
begin

end;

procedure TPosWinPrinter.SODirectIO(EventNumber: Integer;
  var pData: Integer; var pString: WideString);
begin

end;

procedure TPosWinPrinter.SOError(ResultCode, ResultCodeExtended,
  ErrorLocus: Integer; var pErrorResponse: Integer);
begin

end;

procedure TPosWinPrinter.SOOutputComplete(OutputID: Integer);
begin

end;

function TPosWinPrinter.SOProcessID: Integer;
begin

end;

procedure TPosWinPrinter.SOStatusUpdate(Data: Integer);
begin

end;

function TPosWinPrinter.TransactionPrint(Station,
  Control: Integer): Integer;
begin
  try
    CheckRecStation(Station);
    case Control of
      PTR_TP_NORMAL:
      begin
        if FTransaction then
        begin
          Printer.EndDoc;
          FPositionY := 0;
          FTransaction := False;
        end;
      end;
      PTR_TP_TRANSACTION:
      begin
        if not FTransaction then
        begin
          Printer.BeginDoc;
          FTransaction := True;
          FPositionY := 0;
        end;
      end;
    end;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TPosWinPrinter.UpdateFirmware(
  const FirmwareFileName: WideString): Integer;
begin
  Result := ClearResult;
end;

function TPosWinPrinter.UpdateStatistics(
  const StatisticsBuffer: WideString): Integer;
begin
  Result := ClearResult;
end;

function TPosWinPrinter.ValidateData(Station: Integer;
  const Data: WideString): Integer;
begin
  Result := ClearResult;
end;

end.

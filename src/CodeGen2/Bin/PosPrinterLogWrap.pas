unit PosPrinterLogWrap;

interface

uses
  // VCL
  Classes,
  // Opos
  LogFile, OposPOSPrinter_CCO_TLB;

type

  { TPosPrinterLogWrap }

  TPosPrinterLogWrap = class(TComponent, IOPOSPOSPrinter)
  private
    FLogger: ILogFile;
    FDriver: TOPOSPOSPrinter;
    property Driver: TOPOSPOSPrinter read FDriver;
  public
    constructor Create(AOwner: TComponent; ADriver: TOPOSPOSPrinter; ALogger: ILogFile);
    procedure MethodStart(const AMathodName: string; Params: array of Variant);
    procedure MethodEnd(const AMathodName: string; Params: array of Variant);
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
  end;

implementation


constructor TPosPrinterLogWrap.Create(AOwner: TComponent;
  ADriver: TOPOSPOSPrinter; ALogger: ILogFile);
begin
  inherited Create(AOwner);
  FDriver := ADriver;
  FLogger := ALogger;
end;

procedure TPosPrinterLogWrap.MethodStart(const AMathodName: string; Params: array of Variant);
begin

end;

procedure TPosPrinterLogWrap.MethodEnd(const AMathodName: string; Params: array of Variant);
begin

end;


procedure TPosPrinterLogWrap.SODataDummy(Status: Integer); safecall;
begin
  MethodStart('SODataDummy', []);
  Driver.SODataDummy(Status);
  MethodEnd('SODataDummy', []);
end;

procedure TPosPrinterLogWrap.SODirectIO(EventNumber: Integer; var pData: Integer; var pString: WideString); safecall;
begin
  MethodStart('SODirectIO', []);
  Driver.SODirectIO(EventNumber,pData,pString);
  MethodEnd('SODirectIO', []);
end;

procedure TPosPrinterLogWrap.SOError(ResultCode: Integer; ResultCodeExtended: Integer; ErrorLocus: Integer; var pErrorResponse: Integer); safecall;
begin
  MethodStart('SOError', []);
  Driver.SOError(ResultCode,ResultCodeExtended,ErrorLocus,pErrorResponse);
  MethodEnd('SOError', []);
end;

procedure TPosPrinterLogWrap.SOOutputComplete(OutputID: Integer); safecall;
begin
  MethodStart('SOOutputComplete', []);
  Driver.SOOutputComplete(OutputID);
  MethodEnd('SOOutputComplete', []);
end;

procedure TPosPrinterLogWrap.SOStatusUpdate(Data: Integer); safecall;
begin
  MethodStart('SOStatusUpdate', []);
  Driver.SOStatusUpdate(Data);
  MethodEnd('SOStatusUpdate', []);
end;

function TPosPrinterLogWrap.SOProcessID: Integer; safecall;
begin
  MethodStart('SOProcessID', []);
  Result := Driver.SOProcessID;
  MethodEnd('SOProcessID', [Result]);
end;

function TPosPrinterLogWrap.CheckHealth(Level: Integer): Integer; safecall;
begin
  MethodStart('CheckHealth', []);
  Result := Driver.CheckHealth(Level);
  MethodEnd('CheckHealth', [Result]);
end;

function TPosPrinterLogWrap.ClaimDevice(Timeout: Integer): Integer; safecall;
begin
  MethodStart('ClaimDevice', []);
  Result := Driver.ClaimDevice(Timeout);
  MethodEnd('ClaimDevice', [Result]);
end;

function TPosPrinterLogWrap.ClearOutput: Integer; safecall;
begin
  MethodStart('ClearOutput', []);
  Result := Driver.ClearOutput;
  MethodEnd('ClearOutput', [Result]);
end;

function TPosPrinterLogWrap.Close: Integer; safecall;
begin
  MethodStart('Close', []);
  Result := Driver.Close;
  MethodEnd('Close', [Result]);
end;

function TPosPrinterLogWrap.DirectIO(Command: Integer; var pData: Integer; var pString: WideString): Integer; safecall;
begin
  MethodStart('DirectIO', []);
  Result := Driver.DirectIO(Command,pData,pString);
  MethodEnd('DirectIO', [Result]);
end;

function TPosPrinterLogWrap.Open(const DeviceName: WideString): Integer; safecall;
begin
  MethodStart('Open', []);
  Result := Driver.Open(DeviceName);
  MethodEnd('Open', [Result]);
end;

function TPosPrinterLogWrap.ReleaseDevice: Integer; safecall;
begin
  MethodStart('ReleaseDevice', []);
  Result := Driver.ReleaseDevice;
  MethodEnd('ReleaseDevice', [Result]);
end;

function TPosPrinterLogWrap.BeginInsertion(Timeout: Integer): Integer; safecall;
begin
  MethodStart('BeginInsertion', []);
  Result := Driver.BeginInsertion(Timeout);
  MethodEnd('BeginInsertion', [Result]);
end;

function TPosPrinterLogWrap.BeginRemoval(Timeout: Integer): Integer; safecall;
begin
  MethodStart('BeginRemoval', []);
  Result := Driver.BeginRemoval(Timeout);
  MethodEnd('BeginRemoval', [Result]);
end;

function TPosPrinterLogWrap.CutPaper(Percentage: Integer): Integer; safecall;
begin
  MethodStart('CutPaper', []);
  Result := Driver.CutPaper(Percentage);
  MethodEnd('CutPaper', [Result]);
end;

function TPosPrinterLogWrap.EndInsertion: Integer; safecall;
begin
  MethodStart('EndInsertion', []);
  Result := Driver.EndInsertion;
  MethodEnd('EndInsertion', [Result]);
end;

function TPosPrinterLogWrap.EndRemoval: Integer; safecall;
begin
  MethodStart('EndRemoval', []);
  Result := Driver.EndRemoval;
  MethodEnd('EndRemoval', [Result]);
end;

function TPosPrinterLogWrap.PrintBarCode(Station: Integer; const Data: WideString; Symbology: Integer; Height: Integer; Width: Integer; Alignment: Integer; TextPosition: Integer): Integer; safecall;
begin
  MethodStart('PrintBarCode', []);
  Result := Driver.PrintBarCode(Station,Data,Symbology,Height,Width,Alignment,TextPosition);
  MethodEnd('PrintBarCode', [Result]);
end;

function TPosPrinterLogWrap.PrintBitmap(Station: Integer; const FileName: WideString; Width: Integer; Alignment: Integer): Integer; safecall;
begin
  MethodStart('PrintBitmap', []);
  Result := Driver.PrintBitmap(Station,FileName,Width,Alignment);
  MethodEnd('PrintBitmap', [Result]);
end;

function TPosPrinterLogWrap.PrintImmediate(Station: Integer; const Data: WideString): Integer; safecall;
begin
  MethodStart('PrintImmediate', []);
  Result := Driver.PrintImmediate(Station,Data);
  MethodEnd('PrintImmediate', [Result]);
end;

function TPosPrinterLogWrap.PrintNormal(Station: Integer; const Data: WideString): Integer; safecall;
begin
  MethodStart('PrintNormal', []);
  Result := Driver.PrintNormal(Station,Data);
  MethodEnd('PrintNormal', [Result]);
end;

function TPosPrinterLogWrap.PrintTwoNormal(Stations: Integer; const Data1: WideString; const Data2: WideString): Integer; safecall;
begin
  MethodStart('PrintTwoNormal', []);
  Result := Driver.PrintTwoNormal(Stations,Data1,Data2);
  MethodEnd('PrintTwoNormal', [Result]);
end;

function TPosPrinterLogWrap.RotatePrint(Station: Integer; Rotation: Integer): Integer; safecall;
begin
  MethodStart('RotatePrint', []);
  Result := Driver.RotatePrint(Station,Rotation);
  MethodEnd('RotatePrint', [Result]);
end;

function TPosPrinterLogWrap.SetBitmap(BitmapNumber: Integer; Station: Integer; const FileName: WideString; Width: Integer; Alignment: Integer): Integer; safecall;
begin
  MethodStart('SetBitmap', []);
  Result := Driver.SetBitmap(BitmapNumber,Station,FileName,Width,Alignment);
  MethodEnd('SetBitmap', [Result]);
end;

function TPosPrinterLogWrap.SetLogo(Location: Integer; const Data: WideString): Integer; safecall;
begin
  MethodStart('SetLogo', []);
  Result := Driver.SetLogo(Location,Data);
  MethodEnd('SetLogo', [Result]);
end;

function TPosPrinterLogWrap.TransactionPrint(Station: Integer; Control: Integer): Integer; safecall;
begin
  MethodStart('TransactionPrint', []);
  Result := Driver.TransactionPrint(Station,Control);
  MethodEnd('TransactionPrint', [Result]);
end;

function TPosPrinterLogWrap.ValidateData(Station: Integer; const Data: WideString): Integer; safecall;
begin
  MethodStart('ValidateData', []);
  Result := Driver.ValidateData(Station,Data);
  MethodEnd('ValidateData', [Result]);
end;

function TPosPrinterLogWrap.ChangePrintSide(Side: Integer): Integer; safecall;
begin
  MethodStart('ChangePrintSide', []);
  Result := Driver.ChangePrintSide(Side);
  MethodEnd('ChangePrintSide', [Result]);
end;

function TPosPrinterLogWrap.MarkFeed(Type_: Integer): Integer; safecall;
begin
  MethodStart('MarkFeed', []);
  Result := Driver.MarkFeed(Type_);
  MethodEnd('MarkFeed', [Result]);
end;

function TPosPrinterLogWrap.ResetStatistics(const StatisticsBuffer: WideString): Integer; safecall;
begin
  MethodStart('ResetStatistics', []);
  Result := Driver.ResetStatistics(StatisticsBuffer);
  MethodEnd('ResetStatistics', [Result]);
end;

function TPosPrinterLogWrap.RetrieveStatistics(var pStatisticsBuffer: WideString): Integer; safecall;
begin
  MethodStart('RetrieveStatistics', []);
  Result := Driver.RetrieveStatistics(pStatisticsBuffer);
  MethodEnd('RetrieveStatistics', [Result]);
end;

function TPosPrinterLogWrap.UpdateStatistics(const StatisticsBuffer: WideString): Integer; safecall;
begin
  MethodStart('UpdateStatistics', []);
  Result := Driver.UpdateStatistics(StatisticsBuffer);
  MethodEnd('UpdateStatistics', [Result]);
end;

function TPosPrinterLogWrap.CompareFirmwareVersion(const FirmwareFileName: WideString; out pResult: Integer): Integer; safecall;
begin
  MethodStart('CompareFirmwareVersion', []);
  Result := Driver.CompareFirmwareVersion(FirmwareFileName,pResult);
  MethodEnd('CompareFirmwareVersion', [Result]);
end;

function TPosPrinterLogWrap.UpdateFirmware(const FirmwareFileName: WideString): Integer; safecall;
begin
  MethodStart('UpdateFirmware', []);
  Result := Driver.UpdateFirmware(FirmwareFileName);
  MethodEnd('UpdateFirmware', [Result]);
end;

function TPosPrinterLogWrap.ClearPrintArea: Integer; safecall;
begin
  MethodStart('ClearPrintArea', []);
  Result := Driver.ClearPrintArea;
  MethodEnd('ClearPrintArea', [Result]);
end;

function TPosPrinterLogWrap.PageModePrint(Control: Integer): Integer; safecall;
begin
  MethodStart('PageModePrint', []);
  Result := Driver.PageModePrint(Control);
  MethodEnd('PageModePrint', [Result]);
end;

function TPosPrinterLogWrap.PrintMemoryBitmap(Station: Integer; const Data: WideString; Type_: Integer; Width: Integer; Alignment: Integer): Integer; safecall;
begin
  MethodStart('PrintMemoryBitmap', []);
  Result := Driver.PrintMemoryBitmap(Station,Data,Type_,Width,Alignment);
  MethodEnd('PrintMemoryBitmap', [Result]);
end;

function TPosPrinterLogWrap.DrawRuledLine(Station: Integer; const PositionList: WideString; LineDirection: Integer; LineWidth: Integer; LineStyle: Integer; LineColor: Integer): Integer; safecall;
begin
  MethodStart('DrawRuledLine', []);
  Result := Driver.DrawRuledLine(Station,PositionList,LineDirection,LineWidth,LineStyle,LineColor);
  MethodEnd('DrawRuledLine', [Result]);
end;

function TPosPrinterLogWrap.Get_OpenResult: Integer;
begin
  MethodStart('Get_OpenResult', []);
  Result := Driver.OpenResult;
  MethodEnd('Get_OpenResult', [Result]);
end;

function TPosPrinterLogWrap.Get_CheckHealthText: WideString;
begin
  MethodStart('Get_CheckHealthText', []);
  Result := Driver.CheckHealthText;
  MethodEnd('Get_CheckHealthText', [Result]);
end;

function TPosPrinterLogWrap.Get_Claimed: WordBool;
begin
  MethodStart('Get_Claimed', []);
  Result := Driver.Claimed;
  MethodEnd('Get_Claimed', [Result]);
end;

function TPosPrinterLogWrap.Get_OutputID: Integer;
begin
  MethodStart('Get_OutputID', []);
  Result := Driver.OutputID;
  MethodEnd('Get_OutputID', [Result]);
end;

function TPosPrinterLogWrap.Get_ResultCode: Integer;
begin
  MethodStart('Get_ResultCode', []);
  Result := Driver.ResultCode;
  MethodEnd('Get_ResultCode', [Result]);
end;

function TPosPrinterLogWrap.Get_ResultCodeExtended: Integer;
begin
  MethodStart('Get_ResultCodeExtended', []);
  Result := Driver.ResultCodeExtended;
  MethodEnd('Get_ResultCodeExtended', [Result]);
end;

function TPosPrinterLogWrap.Get_State: Integer;
begin
  MethodStart('Get_State', []);
  Result := Driver.State;
  MethodEnd('Get_State', [Result]);
end;

function TPosPrinterLogWrap.Get_ControlObjectDescription: WideString;
begin
  MethodStart('Get_ControlObjectDescription', []);
  Result := Driver.ControlObjectDescription;
  MethodEnd('Get_ControlObjectDescription', [Result]);
end;

function TPosPrinterLogWrap.Get_ControlObjectVersion: Integer;
begin
  MethodStart('Get_ControlObjectVersion', []);
  Result := Driver.ControlObjectVersion;
  MethodEnd('Get_ControlObjectVersion', [Result]);
end;

function TPosPrinterLogWrap.Get_ServiceObjectDescription: WideString;
begin
  MethodStart('Get_ServiceObjectDescription', []);
  Result := Driver.ServiceObjectDescription;
  MethodEnd('Get_ServiceObjectDescription', [Result]);
end;

function TPosPrinterLogWrap.Get_ServiceObjectVersion: Integer;
begin
  MethodStart('Get_ServiceObjectVersion', []);
  Result := Driver.ServiceObjectVersion;
  MethodEnd('Get_ServiceObjectVersion', [Result]);
end;

function TPosPrinterLogWrap.Get_DeviceDescription: WideString;
begin
  MethodStart('Get_DeviceDescription', []);
  Result := Driver.DeviceDescription;
  MethodEnd('Get_DeviceDescription', [Result]);
end;

function TPosPrinterLogWrap.Get_DeviceName: WideString;
begin
  MethodStart('Get_DeviceName', []);
  Result := Driver.DeviceName;
  MethodEnd('Get_DeviceName', [Result]);
end;

function TPosPrinterLogWrap.Get_CapConcurrentJrnRec: WordBool;
begin
  MethodStart('Get_CapConcurrentJrnRec', []);
  Result := Driver.CapConcurrentJrnRec;
  MethodEnd('Get_CapConcurrentJrnRec', [Result]);
end;

function TPosPrinterLogWrap.Get_CapConcurrentJrnSlp: WordBool;
begin
  MethodStart('Get_CapConcurrentJrnSlp', []);
  Result := Driver.CapConcurrentJrnSlp;
  MethodEnd('Get_CapConcurrentJrnSlp', [Result]);
end;

function TPosPrinterLogWrap.Get_CapConcurrentRecSlp: WordBool;
begin
  MethodStart('Get_CapConcurrentRecSlp', []);
  Result := Driver.CapConcurrentRecSlp;
  MethodEnd('Get_CapConcurrentRecSlp', [Result]);
end;

function TPosPrinterLogWrap.Get_CapCoverSensor: WordBool;
begin
  MethodStart('Get_CapCoverSensor', []);
  Result := Driver.CapCoverSensor;
  MethodEnd('Get_CapCoverSensor', [Result]);
end;

function TPosPrinterLogWrap.Get_CapJrn2Color: WordBool;
begin
  MethodStart('Get_CapJrn2Color', []);
  Result := Driver.CapJrn2Color;
  MethodEnd('Get_CapJrn2Color', [Result]);
end;

function TPosPrinterLogWrap.Get_CapJrnBold: WordBool;
begin
  MethodStart('Get_CapJrnBold', []);
  Result := Driver.CapJrnBold;
  MethodEnd('Get_CapJrnBold', [Result]);
end;

function TPosPrinterLogWrap.Get_CapJrnDhigh: WordBool;
begin
  MethodStart('Get_CapJrnDhigh', []);
  Result := Driver.CapJrnDhigh;
  MethodEnd('Get_CapJrnDhigh', [Result]);
end;

function TPosPrinterLogWrap.Get_CapJrnDwide: WordBool;
begin
  MethodStart('Get_CapJrnDwide', []);
  Result := Driver.CapJrnDwide;
  MethodEnd('Get_CapJrnDwide', [Result]);
end;

function TPosPrinterLogWrap.Get_CapJrnDwideDhigh: WordBool;
begin
  MethodStart('Get_CapJrnDwideDhigh', []);
  Result := Driver.CapJrnDwideDhigh;
  MethodEnd('Get_CapJrnDwideDhigh', [Result]);
end;

function TPosPrinterLogWrap.Get_CapJrnEmptySensor: WordBool;
begin
  MethodStart('Get_CapJrnEmptySensor', []);
  Result := Driver.CapJrnEmptySensor;
  MethodEnd('Get_CapJrnEmptySensor', [Result]);
end;

function TPosPrinterLogWrap.Get_CapJrnItalic: WordBool;
begin
  MethodStart('Get_CapJrnItalic', []);
  Result := Driver.CapJrnItalic;
  MethodEnd('Get_CapJrnItalic', [Result]);
end;

function TPosPrinterLogWrap.Get_CapJrnNearEndSensor: WordBool;
begin
  MethodStart('Get_CapJrnNearEndSensor', []);
  Result := Driver.CapJrnNearEndSensor;
  MethodEnd('Get_CapJrnNearEndSensor', [Result]);
end;

function TPosPrinterLogWrap.Get_CapJrnPresent: WordBool;
begin
  MethodStart('Get_CapJrnPresent', []);
  Result := Driver.CapJrnPresent;
  MethodEnd('Get_CapJrnPresent', [Result]);
end;

function TPosPrinterLogWrap.Get_CapJrnUnderline: WordBool;
begin
  MethodStart('Get_CapJrnUnderline', []);
  Result := Driver.CapJrnUnderline;
  MethodEnd('Get_CapJrnUnderline', [Result]);
end;

function TPosPrinterLogWrap.Get_CapRec2Color: WordBool;
begin
  MethodStart('Get_CapRec2Color', []);
  Result := Driver.CapRec2Color;
  MethodEnd('Get_CapRec2Color', [Result]);
end;

function TPosPrinterLogWrap.Get_CapRecBarCode: WordBool;
begin
  MethodStart('Get_CapRecBarCode', []);
  Result := Driver.CapRecBarCode;
  MethodEnd('Get_CapRecBarCode', [Result]);
end;

function TPosPrinterLogWrap.Get_CapRecBitmap: WordBool;
begin
  MethodStart('Get_CapRecBitmap', []);
  Result := Driver.CapRecBitmap;
  MethodEnd('Get_CapRecBitmap', [Result]);
end;

function TPosPrinterLogWrap.Get_CapRecBold: WordBool;
begin
  MethodStart('Get_CapRecBold', []);
  Result := Driver.CapRecBold;
  MethodEnd('Get_CapRecBold', [Result]);
end;

function TPosPrinterLogWrap.Get_CapRecDhigh: WordBool;
begin
  MethodStart('Get_CapRecDhigh', []);
  Result := Driver.CapRecDhigh;
  MethodEnd('Get_CapRecDhigh', [Result]);
end;

function TPosPrinterLogWrap.Get_CapRecDwide: WordBool;
begin
  MethodStart('Get_CapRecDwide', []);
  Result := Driver.CapRecDwide;
  MethodEnd('Get_CapRecDwide', [Result]);
end;

function TPosPrinterLogWrap.Get_CapRecDwideDhigh: WordBool;
begin
  MethodStart('Get_CapRecDwideDhigh', []);
  Result := Driver.CapRecDwideDhigh;
  MethodEnd('Get_CapRecDwideDhigh', [Result]);
end;

function TPosPrinterLogWrap.Get_CapRecEmptySensor: WordBool;
begin
  MethodStart('Get_CapRecEmptySensor', []);
  Result := Driver.CapRecEmptySensor;
  MethodEnd('Get_CapRecEmptySensor', [Result]);
end;

function TPosPrinterLogWrap.Get_CapRecItalic: WordBool;
begin
  MethodStart('Get_CapRecItalic', []);
  Result := Driver.CapRecItalic;
  MethodEnd('Get_CapRecItalic', [Result]);
end;

function TPosPrinterLogWrap.Get_CapRecLeft90: WordBool;
begin
  MethodStart('Get_CapRecLeft90', []);
  Result := Driver.CapRecLeft90;
  MethodEnd('Get_CapRecLeft90', [Result]);
end;

function TPosPrinterLogWrap.Get_CapRecNearEndSensor: WordBool;
begin
  MethodStart('Get_CapRecNearEndSensor', []);
  Result := Driver.CapRecNearEndSensor;
  MethodEnd('Get_CapRecNearEndSensor', [Result]);
end;

function TPosPrinterLogWrap.Get_CapRecPapercut: WordBool;
begin
  MethodStart('Get_CapRecPapercut', []);
  Result := Driver.CapRecPapercut;
  MethodEnd('Get_CapRecPapercut', [Result]);
end;

function TPosPrinterLogWrap.Get_CapRecPresent: WordBool;
begin
  MethodStart('Get_CapRecPresent', []);
  Result := Driver.CapRecPresent;
  MethodEnd('Get_CapRecPresent', [Result]);
end;

function TPosPrinterLogWrap.Get_CapRecRight90: WordBool;
begin
  MethodStart('Get_CapRecRight90', []);
  Result := Driver.CapRecRight90;
  MethodEnd('Get_CapRecRight90', [Result]);
end;

function TPosPrinterLogWrap.Get_CapRecRotate180: WordBool;
begin
  MethodStart('Get_CapRecRotate180', []);
  Result := Driver.CapRecRotate180;
  MethodEnd('Get_CapRecRotate180', [Result]);
end;

function TPosPrinterLogWrap.Get_CapRecStamp: WordBool;
begin
  MethodStart('Get_CapRecStamp', []);
  Result := Driver.CapRecStamp;
  MethodEnd('Get_CapRecStamp', [Result]);
end;

function TPosPrinterLogWrap.Get_CapRecUnderline: WordBool;
begin
  MethodStart('Get_CapRecUnderline', []);
  Result := Driver.CapRecUnderline;
  MethodEnd('Get_CapRecUnderline', [Result]);
end;

function TPosPrinterLogWrap.Get_CapSlp2Color: WordBool;
begin
  MethodStart('Get_CapSlp2Color', []);
  Result := Driver.CapSlp2Color;
  MethodEnd('Get_CapSlp2Color', [Result]);
end;

function TPosPrinterLogWrap.Get_CapSlpBarCode: WordBool;
begin
  MethodStart('Get_CapSlpBarCode', []);
  Result := Driver.CapSlpBarCode;
  MethodEnd('Get_CapSlpBarCode', [Result]);
end;

function TPosPrinterLogWrap.Get_CapSlpBitmap: WordBool;
begin
  MethodStart('Get_CapSlpBitmap', []);
  Result := Driver.CapSlpBitmap;
  MethodEnd('Get_CapSlpBitmap', [Result]);
end;

function TPosPrinterLogWrap.Get_CapSlpBold: WordBool;
begin
  MethodStart('Get_CapSlpBold', []);
  Result := Driver.CapSlpBold;
  MethodEnd('Get_CapSlpBold', [Result]);
end;

function TPosPrinterLogWrap.Get_CapSlpDhigh: WordBool;
begin
  MethodStart('Get_CapSlpDhigh', []);
  Result := Driver.CapSlpDhigh;
  MethodEnd('Get_CapSlpDhigh', [Result]);
end;

function TPosPrinterLogWrap.Get_CapSlpDwide: WordBool;
begin
  MethodStart('Get_CapSlpDwide', []);
  Result := Driver.CapSlpDwide;
  MethodEnd('Get_CapSlpDwide', [Result]);
end;

function TPosPrinterLogWrap.Get_CapSlpDwideDhigh: WordBool;
begin
  MethodStart('Get_CapSlpDwideDhigh', []);
  Result := Driver.CapSlpDwideDhigh;
  MethodEnd('Get_CapSlpDwideDhigh', [Result]);
end;

function TPosPrinterLogWrap.Get_CapSlpEmptySensor: WordBool;
begin
  MethodStart('Get_CapSlpEmptySensor', []);
  Result := Driver.CapSlpEmptySensor;
  MethodEnd('Get_CapSlpEmptySensor', [Result]);
end;

function TPosPrinterLogWrap.Get_CapSlpFullslip: WordBool;
begin
  MethodStart('Get_CapSlpFullslip', []);
  Result := Driver.CapSlpFullslip;
  MethodEnd('Get_CapSlpFullslip', [Result]);
end;

function TPosPrinterLogWrap.Get_CapSlpItalic: WordBool;
begin
  MethodStart('Get_CapSlpItalic', []);
  Result := Driver.CapSlpItalic;
  MethodEnd('Get_CapSlpItalic', [Result]);
end;

function TPosPrinterLogWrap.Get_CapSlpLeft90: WordBool;
begin
  MethodStart('Get_CapSlpLeft90', []);
  Result := Driver.CapSlpLeft90;
  MethodEnd('Get_CapSlpLeft90', [Result]);
end;

function TPosPrinterLogWrap.Get_CapSlpNearEndSensor: WordBool;
begin
  MethodStart('Get_CapSlpNearEndSensor', []);
  Result := Driver.CapSlpNearEndSensor;
  MethodEnd('Get_CapSlpNearEndSensor', [Result]);
end;

function TPosPrinterLogWrap.Get_CapSlpPresent: WordBool;
begin
  MethodStart('Get_CapSlpPresent', []);
  Result := Driver.CapSlpPresent;
  MethodEnd('Get_CapSlpPresent', [Result]);
end;

function TPosPrinterLogWrap.Get_CapSlpRight90: WordBool;
begin
  MethodStart('Get_CapSlpRight90', []);
  Result := Driver.CapSlpRight90;
  MethodEnd('Get_CapSlpRight90', [Result]);
end;

function TPosPrinterLogWrap.Get_CapSlpRotate180: WordBool;
begin
  MethodStart('Get_CapSlpRotate180', []);
  Result := Driver.CapSlpRotate180;
  MethodEnd('Get_CapSlpRotate180', [Result]);
end;

function TPosPrinterLogWrap.Get_CapSlpUnderline: WordBool;
begin
  MethodStart('Get_CapSlpUnderline', []);
  Result := Driver.CapSlpUnderline;
  MethodEnd('Get_CapSlpUnderline', [Result]);
end;

function TPosPrinterLogWrap.Get_CharacterSetList: WideString;
begin
  MethodStart('Get_CharacterSetList', []);
  Result := Driver.CharacterSetList;
  MethodEnd('Get_CharacterSetList', [Result]);
end;

function TPosPrinterLogWrap.Get_CoverOpen: WordBool;
begin
  MethodStart('Get_CoverOpen', []);
  Result := Driver.CoverOpen;
  MethodEnd('Get_CoverOpen', [Result]);
end;

function TPosPrinterLogWrap.Get_ErrorStation: Integer;
begin
  MethodStart('Get_ErrorStation', []);
  Result := Driver.ErrorStation;
  MethodEnd('Get_ErrorStation', [Result]);
end;

function TPosPrinterLogWrap.Get_JrnEmpty: WordBool;
begin
  MethodStart('Get_JrnEmpty', []);
  Result := Driver.JrnEmpty;
  MethodEnd('Get_JrnEmpty', [Result]);
end;

function TPosPrinterLogWrap.Get_JrnLineCharsList: WideString;
begin
  MethodStart('Get_JrnLineCharsList', []);
  Result := Driver.JrnLineCharsList;
  MethodEnd('Get_JrnLineCharsList', [Result]);
end;

function TPosPrinterLogWrap.Get_JrnLineWidth: Integer;
begin
  MethodStart('Get_JrnLineWidth', []);
  Result := Driver.JrnLineWidth;
  MethodEnd('Get_JrnLineWidth', [Result]);
end;

function TPosPrinterLogWrap.Get_JrnNearEnd: WordBool;
begin
  MethodStart('Get_JrnNearEnd', []);
  Result := Driver.JrnNearEnd;
  MethodEnd('Get_JrnNearEnd', [Result]);
end;

function TPosPrinterLogWrap.Get_RecEmpty: WordBool;
begin
  MethodStart('Get_RecEmpty', []);
  Result := Driver.RecEmpty;
  MethodEnd('Get_RecEmpty', [Result]);
end;

function TPosPrinterLogWrap.Get_RecLineCharsList: WideString;
begin
  MethodStart('Get_RecLineCharsList', []);
  Result := Driver.RecLineCharsList;
  MethodEnd('Get_RecLineCharsList', [Result]);
end;

function TPosPrinterLogWrap.Get_RecLinesToPaperCut: Integer;
begin
  MethodStart('Get_RecLinesToPaperCut', []);
  Result := Driver.RecLinesToPaperCut;
  MethodEnd('Get_RecLinesToPaperCut', [Result]);
end;

function TPosPrinterLogWrap.Get_RecLineWidth: Integer;
begin
  MethodStart('Get_RecLineWidth', []);
  Result := Driver.RecLineWidth;
  MethodEnd('Get_RecLineWidth', [Result]);
end;

function TPosPrinterLogWrap.Get_RecNearEnd: WordBool;
begin
  MethodStart('Get_RecNearEnd', []);
  Result := Driver.RecNearEnd;
  MethodEnd('Get_RecNearEnd', [Result]);
end;

function TPosPrinterLogWrap.Get_RecSidewaysMaxChars: Integer;
begin
  MethodStart('Get_RecSidewaysMaxChars', []);
  Result := Driver.RecSidewaysMaxChars;
  MethodEnd('Get_RecSidewaysMaxChars', [Result]);
end;

function TPosPrinterLogWrap.Get_RecSidewaysMaxLines: Integer;
begin
  MethodStart('Get_RecSidewaysMaxLines', []);
  Result := Driver.RecSidewaysMaxLines;
  MethodEnd('Get_RecSidewaysMaxLines', [Result]);
end;

function TPosPrinterLogWrap.Get_SlpEmpty: WordBool;
begin
  MethodStart('Get_SlpEmpty', []);
  Result := Driver.SlpEmpty;
  MethodEnd('Get_SlpEmpty', [Result]);
end;

function TPosPrinterLogWrap.Get_SlpLineCharsList: WideString;
begin
  MethodStart('Get_SlpLineCharsList', []);
  Result := Driver.SlpLineCharsList;
  MethodEnd('Get_SlpLineCharsList', [Result]);
end;

function TPosPrinterLogWrap.Get_SlpLinesNearEndToEnd: Integer;
begin
  MethodStart('Get_SlpLinesNearEndToEnd', []);
  Result := Driver.SlpLinesNearEndToEnd;
  MethodEnd('Get_SlpLinesNearEndToEnd', [Result]);
end;

function TPosPrinterLogWrap.Get_SlpLineWidth: Integer;
begin
  MethodStart('Get_SlpLineWidth', []);
  Result := Driver.SlpLineWidth;
  MethodEnd('Get_SlpLineWidth', [Result]);
end;

function TPosPrinterLogWrap.Get_SlpMaxLines: Integer;
begin
  MethodStart('Get_SlpMaxLines', []);
  Result := Driver.SlpMaxLines;
  MethodEnd('Get_SlpMaxLines', [Result]);
end;

function TPosPrinterLogWrap.Get_SlpNearEnd: WordBool;
begin
  MethodStart('Get_SlpNearEnd', []);
  Result := Driver.SlpNearEnd;
  MethodEnd('Get_SlpNearEnd', [Result]);
end;

function TPosPrinterLogWrap.Get_SlpSidewaysMaxChars: Integer;
begin
  MethodStart('Get_SlpSidewaysMaxChars', []);
  Result := Driver.SlpSidewaysMaxChars;
  MethodEnd('Get_SlpSidewaysMaxChars', [Result]);
end;

function TPosPrinterLogWrap.Get_SlpSidewaysMaxLines: Integer;
begin
  MethodStart('Get_SlpSidewaysMaxLines', []);
  Result := Driver.SlpSidewaysMaxLines;
  MethodEnd('Get_SlpSidewaysMaxLines', [Result]);
end;

function TPosPrinterLogWrap.Get_CapCharacterSet: Integer;
begin
  MethodStart('Get_CapCharacterSet', []);
  Result := Driver.CapCharacterSet;
  MethodEnd('Get_CapCharacterSet', [Result]);
end;

function TPosPrinterLogWrap.Get_CapTransaction: WordBool;
begin
  MethodStart('Get_CapTransaction', []);
  Result := Driver.CapTransaction;
  MethodEnd('Get_CapTransaction', [Result]);
end;

function TPosPrinterLogWrap.Get_ErrorLevel: Integer;
begin
  MethodStart('Get_ErrorLevel', []);
  Result := Driver.ErrorLevel;
  MethodEnd('Get_ErrorLevel', [Result]);
end;

function TPosPrinterLogWrap.Get_ErrorString: WideString;
begin
  MethodStart('Get_ErrorString', []);
  Result := Driver.ErrorString;
  MethodEnd('Get_ErrorString', [Result]);
end;

function TPosPrinterLogWrap.Get_FontTypefaceList: WideString;
begin
  MethodStart('Get_FontTypefaceList', []);
  Result := Driver.FontTypefaceList;
  MethodEnd('Get_FontTypefaceList', [Result]);
end;

function TPosPrinterLogWrap.Get_RecBarCodeRotationList: WideString;
begin
  MethodStart('Get_RecBarCodeRotationList', []);
  Result := Driver.RecBarCodeRotationList;
  MethodEnd('Get_RecBarCodeRotationList', [Result]);
end;

function TPosPrinterLogWrap.Get_SlpBarCodeRotationList: WideString;
begin
  MethodStart('Get_SlpBarCodeRotationList', []);
  Result := Driver.SlpBarCodeRotationList;
  MethodEnd('Get_SlpBarCodeRotationList', [Result]);
end;

function TPosPrinterLogWrap.Get_CapPowerReporting: Integer;
begin
  MethodStart('Get_CapPowerReporting', []);
  Result := Driver.CapPowerReporting;
  MethodEnd('Get_CapPowerReporting', [Result]);
end;

function TPosPrinterLogWrap.Get_PowerState: Integer;
begin
  MethodStart('Get_PowerState', []);
  Result := Driver.PowerState;
  MethodEnd('Get_PowerState', [Result]);
end;

function TPosPrinterLogWrap.Get_CapJrnCartridgeSensor: Integer;
begin
  MethodStart('Get_CapJrnCartridgeSensor', []);
  Result := Driver.CapJrnCartridgeSensor;
  MethodEnd('Get_CapJrnCartridgeSensor', [Result]);
end;

function TPosPrinterLogWrap.Get_CapJrnColor: Integer;
begin
  MethodStart('Get_CapJrnColor', []);
  Result := Driver.CapJrnColor;
  MethodEnd('Get_CapJrnColor', [Result]);
end;

function TPosPrinterLogWrap.Get_CapRecCartridgeSensor: Integer;
begin
  MethodStart('Get_CapRecCartridgeSensor', []);
  Result := Driver.CapRecCartridgeSensor;
  MethodEnd('Get_CapRecCartridgeSensor', [Result]);
end;

function TPosPrinterLogWrap.Get_CapRecColor: Integer;
begin
  MethodStart('Get_CapRecColor', []);
  Result := Driver.CapRecColor;
  MethodEnd('Get_CapRecColor', [Result]);
end;

function TPosPrinterLogWrap.Get_CapRecMarkFeed: Integer;
begin
  MethodStart('Get_CapRecMarkFeed', []);
  Result := Driver.CapRecMarkFeed;
  MethodEnd('Get_CapRecMarkFeed', [Result]);
end;

function TPosPrinterLogWrap.Get_CapSlpBothSidesPrint: WordBool;
begin
  MethodStart('Get_CapSlpBothSidesPrint', []);
  Result := Driver.CapSlpBothSidesPrint;
  MethodEnd('Get_CapSlpBothSidesPrint', [Result]);
end;

function TPosPrinterLogWrap.Get_CapSlpCartridgeSensor: Integer;
begin
  MethodStart('Get_CapSlpCartridgeSensor', []);
  Result := Driver.CapSlpCartridgeSensor;
  MethodEnd('Get_CapSlpCartridgeSensor', [Result]);
end;

function TPosPrinterLogWrap.Get_CapSlpColor: Integer;
begin
  MethodStart('Get_CapSlpColor', []);
  Result := Driver.CapSlpColor;
  MethodEnd('Get_CapSlpColor', [Result]);
end;

function TPosPrinterLogWrap.Get_JrnCartridgeState: Integer;
begin
  MethodStart('Get_JrnCartridgeState', []);
  Result := Driver.JrnCartridgeState;
  MethodEnd('Get_JrnCartridgeState', [Result]);
end;

function TPosPrinterLogWrap.Get_RecCartridgeState: Integer;
begin
  MethodStart('Get_RecCartridgeState', []);
  Result := Driver.RecCartridgeState;
  MethodEnd('Get_RecCartridgeState', [Result]);
end;

function TPosPrinterLogWrap.Get_SlpCartridgeState: Integer;
begin
  MethodStart('Get_SlpCartridgeState', []);
  Result := Driver.SlpCartridgeState;
  MethodEnd('Get_SlpCartridgeState', [Result]);
end;

function TPosPrinterLogWrap.Get_SlpPrintSide: Integer;
begin
  MethodStart('Get_SlpPrintSide', []);
  Result := Driver.SlpPrintSide;
  MethodEnd('Get_SlpPrintSide', [Result]);
end;

function TPosPrinterLogWrap.Get_CapMapCharacterSet: WordBool;
begin
  MethodStart('Get_CapMapCharacterSet', []);
  Result := Driver.CapMapCharacterSet;
  MethodEnd('Get_CapMapCharacterSet', [Result]);
end;

function TPosPrinterLogWrap.Get_RecBitmapRotationList: WideString;
begin
  MethodStart('Get_RecBitmapRotationList', []);
  Result := Driver.RecBitmapRotationList;
  MethodEnd('Get_RecBitmapRotationList', [Result]);
end;

function TPosPrinterLogWrap.Get_SlpBitmapRotationList: WideString;
begin
  MethodStart('Get_SlpBitmapRotationList', []);
  Result := Driver.SlpBitmapRotationList;
  MethodEnd('Get_SlpBitmapRotationList', [Result]);
end;

function TPosPrinterLogWrap.Get_CapStatisticsReporting: WordBool;
begin
  MethodStart('Get_CapStatisticsReporting', []);
  Result := Driver.CapStatisticsReporting;
  MethodEnd('Get_CapStatisticsReporting', [Result]);
end;

function TPosPrinterLogWrap.Get_CapUpdateStatistics: WordBool;
begin
  MethodStart('Get_CapUpdateStatistics', []);
  Result := Driver.CapUpdateStatistics;
  MethodEnd('Get_CapUpdateStatistics', [Result]);
end;

function TPosPrinterLogWrap.Get_CapCompareFirmwareVersion: WordBool;
begin
  MethodStart('Get_CapCompareFirmwareVersion', []);
  Result := Driver.CapCompareFirmwareVersion;
  MethodEnd('Get_CapCompareFirmwareVersion', [Result]);
end;

function TPosPrinterLogWrap.Get_CapUpdateFirmware: WordBool;
begin
  MethodStart('Get_CapUpdateFirmware', []);
  Result := Driver.CapUpdateFirmware;
  MethodEnd('Get_CapUpdateFirmware', [Result]);
end;

function TPosPrinterLogWrap.Get_CapConcurrentPageMode: WordBool;
begin
  MethodStart('Get_CapConcurrentPageMode', []);
  Result := Driver.CapConcurrentPageMode;
  MethodEnd('Get_CapConcurrentPageMode', [Result]);
end;

function TPosPrinterLogWrap.Get_CapRecPageMode: WordBool;
begin
  MethodStart('Get_CapRecPageMode', []);
  Result := Driver.CapRecPageMode;
  MethodEnd('Get_CapRecPageMode', [Result]);
end;

function TPosPrinterLogWrap.Get_CapSlpPageMode: WordBool;
begin
  MethodStart('Get_CapSlpPageMode', []);
  Result := Driver.CapSlpPageMode;
  MethodEnd('Get_CapSlpPageMode', [Result]);
end;

function TPosPrinterLogWrap.Get_PageModeArea: WideString;
begin
  MethodStart('Get_PageModeArea', []);
  Result := Driver.PageModeArea;
  MethodEnd('Get_PageModeArea', [Result]);
end;

function TPosPrinterLogWrap.Get_PageModeDescriptor: Integer;
begin
  MethodStart('Get_PageModeDescriptor', []);
  Result := Driver.PageModeDescriptor;
  MethodEnd('Get_PageModeDescriptor', [Result]);
end;

function TPosPrinterLogWrap.Get_CapRecRuledLine: Integer;
begin
  MethodStart('Get_CapRecRuledLine', []);
  Result := Driver.CapRecRuledLine;
  MethodEnd('Get_CapRecRuledLine', [Result]);
end;

function TPosPrinterLogWrap.Get_CapSlpRuledLine: Integer;
begin
  MethodStart('Get_CapSlpRuledLine', []);
  Result := Driver.CapSlpRuledLine;
  MethodEnd('Get_CapSlpRuledLine', [Result]);
end;

function TPosPrinterLogWrap.Get_DeviceEnabled: WordBool;
begin
  MethodStart('Get_DeviceEnabled', []);
  Result := Driver.DeviceEnabled;
  MethodEnd('Get_DeviceEnabled', [Result]);
end;

procedure TPosPrinterLogWrap.Set_DeviceEnabled(pDeviceEnabled: WordBool);
begin
  MethodStart('Set_DeviceEnabled', [pDeviceEnabled]);
  Driver.DeviceEnabled := pDeviceEnabled;
  MethodEnd('Set_DeviceEnabled', []);
end;

function TPosPrinterLogWrap.Get_FreezeEvents: WordBool;
begin
  MethodStart('Get_FreezeEvents', []);
  Result := Driver.FreezeEvents;
  MethodEnd('Get_FreezeEvents', [Result]);
end;

procedure TPosPrinterLogWrap.Set_FreezeEvents(pFreezeEvents: WordBool);
begin
  MethodStart('Set_FreezeEvents', [pFreezeEvents]);
  Driver.FreezeEvents := pFreezeEvents;
  MethodEnd('Set_FreezeEvents', []);
end;

function TPosPrinterLogWrap.Get_AsyncMode: WordBool;
begin
  MethodStart('Get_AsyncMode', []);
  Result := Driver.AsyncMode;
  MethodEnd('Get_AsyncMode', [Result]);
end;

procedure TPosPrinterLogWrap.Set_AsyncMode(pAsyncMode: WordBool);
begin
  MethodStart('Set_AsyncMode', [pAsyncMode]);
  Driver.AsyncMode := pAsyncMode;
  MethodEnd('Set_AsyncMode', []);
end;

function TPosPrinterLogWrap.Get_CharacterSet: Integer;
begin
  MethodStart('Get_CharacterSet', []);
  Result := Driver.CharacterSet;
  MethodEnd('Get_CharacterSet', [Result]);
end;

procedure TPosPrinterLogWrap.Set_CharacterSet(pCharacterSet: Integer);
begin
  MethodStart('Set_CharacterSet', [pCharacterSet]);
  Driver.CharacterSet := pCharacterSet;
  MethodEnd('Set_CharacterSet', []);
end;

function TPosPrinterLogWrap.Get_FlagWhenIdle: WordBool;
begin
  MethodStart('Get_FlagWhenIdle', []);
  Result := Driver.FlagWhenIdle;
  MethodEnd('Get_FlagWhenIdle', [Result]);
end;

procedure TPosPrinterLogWrap.Set_FlagWhenIdle(pFlagWhenIdle: WordBool);
begin
  MethodStart('Set_FlagWhenIdle', [pFlagWhenIdle]);
  Driver.FlagWhenIdle := pFlagWhenIdle;
  MethodEnd('Set_FlagWhenIdle', []);
end;

function TPosPrinterLogWrap.Get_JrnLetterQuality: WordBool;
begin
  MethodStart('Get_JrnLetterQuality', []);
  Result := Driver.JrnLetterQuality;
  MethodEnd('Get_JrnLetterQuality', [Result]);
end;

procedure TPosPrinterLogWrap.Set_JrnLetterQuality(pJrnLetterQuality: WordBool);
begin
  MethodStart('Set_JrnLetterQuality', [pJrnLetterQuality]);
  Driver.JrnLetterQuality := pJrnLetterQuality;
  MethodEnd('Set_JrnLetterQuality', []);
end;

function TPosPrinterLogWrap.Get_JrnLineChars: Integer;
begin
  MethodStart('Get_JrnLineChars', []);
  Result := Driver.JrnLineChars;
  MethodEnd('Get_JrnLineChars', [Result]);
end;

procedure TPosPrinterLogWrap.Set_JrnLineChars(pJrnLineChars: Integer);
begin
  MethodStart('Set_JrnLineChars', [pJrnLineChars]);
  Driver.JrnLineChars := pJrnLineChars;
  MethodEnd('Set_JrnLineChars', []);
end;

function TPosPrinterLogWrap.Get_JrnLineHeight: Integer;
begin
  MethodStart('Get_JrnLineHeight', []);
  Result := Driver.JrnLineHeight;
  MethodEnd('Get_JrnLineHeight', [Result]);
end;

procedure TPosPrinterLogWrap.Set_JrnLineHeight(pJrnLineHeight: Integer);
begin
  MethodStart('Set_JrnLineHeight', [pJrnLineHeight]);
  Driver.JrnLineHeight := pJrnLineHeight;
  MethodEnd('Set_JrnLineHeight', []);
end;

function TPosPrinterLogWrap.Get_JrnLineSpacing: Integer;
begin
  MethodStart('Get_JrnLineSpacing', []);
  Result := Driver.JrnLineSpacing;
  MethodEnd('Get_JrnLineSpacing', [Result]);
end;

procedure TPosPrinterLogWrap.Set_JrnLineSpacing(pJrnLineSpacing: Integer);
begin
  MethodStart('Set_JrnLineSpacing', [pJrnLineSpacing]);
  Driver.JrnLineSpacing := pJrnLineSpacing;
  MethodEnd('Set_JrnLineSpacing', []);
end;

function TPosPrinterLogWrap.Get_MapMode: Integer;
begin
  MethodStart('Get_MapMode', []);
  Result := Driver.MapMode;
  MethodEnd('Get_MapMode', [Result]);
end;

procedure TPosPrinterLogWrap.Set_MapMode(pMapMode: Integer);
begin
  MethodStart('Set_MapMode', [pMapMode]);
  Driver.MapMode := pMapMode;
  MethodEnd('Set_MapMode', []);
end;

function TPosPrinterLogWrap.Get_RecLetterQuality: WordBool;
begin
  MethodStart('Get_RecLetterQuality', []);
  Result := Driver.RecLetterQuality;
  MethodEnd('Get_RecLetterQuality', [Result]);
end;

procedure TPosPrinterLogWrap.Set_RecLetterQuality(pRecLetterQuality: WordBool);
begin
  MethodStart('Set_RecLetterQuality', [pRecLetterQuality]);
  Driver.RecLetterQuality := pRecLetterQuality;
  MethodEnd('Set_RecLetterQuality', []);
end;

function TPosPrinterLogWrap.Get_RecLineChars: Integer;
begin
  MethodStart('Get_RecLineChars', []);
  Result := Driver.RecLineChars;
  MethodEnd('Get_RecLineChars', [Result]);
end;

procedure TPosPrinterLogWrap.Set_RecLineChars(pRecLineChars: Integer);
begin
  MethodStart('Set_RecLineChars', [pRecLineChars]);
  Driver.RecLineChars := pRecLineChars;
  MethodEnd('Set_RecLineChars', []);
end;

function TPosPrinterLogWrap.Get_RecLineHeight: Integer;
begin
  MethodStart('Get_RecLineHeight', []);
  Result := Driver.RecLineHeight;
  MethodEnd('Get_RecLineHeight', [Result]);
end;

procedure TPosPrinterLogWrap.Set_RecLineHeight(pRecLineHeight: Integer);
begin
  MethodStart('Set_RecLineHeight', [pRecLineHeight]);
  Driver.RecLineHeight := pRecLineHeight;
  MethodEnd('Set_RecLineHeight', []);
end;

function TPosPrinterLogWrap.Get_RecLineSpacing: Integer;
begin
  MethodStart('Get_RecLineSpacing', []);
  Result := Driver.RecLineSpacing;
  MethodEnd('Get_RecLineSpacing', [Result]);
end;

procedure TPosPrinterLogWrap.Set_RecLineSpacing(pRecLineSpacing: Integer);
begin
  MethodStart('Set_RecLineSpacing', [pRecLineSpacing]);
  Driver.RecLineSpacing := pRecLineSpacing;
  MethodEnd('Set_RecLineSpacing', []);
end;

function TPosPrinterLogWrap.Get_SlpLetterQuality: WordBool;
begin
  MethodStart('Get_SlpLetterQuality', []);
  Result := Driver.SlpLetterQuality;
  MethodEnd('Get_SlpLetterQuality', [Result]);
end;

procedure TPosPrinterLogWrap.Set_SlpLetterQuality(pSlpLetterQuality: WordBool);
begin
  MethodStart('Set_SlpLetterQuality', [pSlpLetterQuality]);
  Driver.SlpLetterQuality := pSlpLetterQuality;
  MethodEnd('Set_SlpLetterQuality', []);
end;

function TPosPrinterLogWrap.Get_SlpLineChars: Integer;
begin
  MethodStart('Get_SlpLineChars', []);
  Result := Driver.SlpLineChars;
  MethodEnd('Get_SlpLineChars', [Result]);
end;

procedure TPosPrinterLogWrap.Set_SlpLineChars(pSlpLineChars: Integer);
begin
  MethodStart('Set_SlpLineChars', [pSlpLineChars]);
  Driver.SlpLineChars := pSlpLineChars;
  MethodEnd('Set_SlpLineChars', []);
end;

function TPosPrinterLogWrap.Get_SlpLineHeight: Integer;
begin
  MethodStart('Get_SlpLineHeight', []);
  Result := Driver.SlpLineHeight;
  MethodEnd('Get_SlpLineHeight', [Result]);
end;

procedure TPosPrinterLogWrap.Set_SlpLineHeight(pSlpLineHeight: Integer);
begin
  MethodStart('Set_SlpLineHeight', [pSlpLineHeight]);
  Driver.SlpLineHeight := pSlpLineHeight;
  MethodEnd('Set_SlpLineHeight', []);
end;

function TPosPrinterLogWrap.Get_SlpLineSpacing: Integer;
begin
  MethodStart('Get_SlpLineSpacing', []);
  Result := Driver.SlpLineSpacing;
  MethodEnd('Get_SlpLineSpacing', [Result]);
end;

procedure TPosPrinterLogWrap.Set_SlpLineSpacing(pSlpLineSpacing: Integer);
begin
  MethodStart('Set_SlpLineSpacing', [pSlpLineSpacing]);
  Driver.SlpLineSpacing := pSlpLineSpacing;
  MethodEnd('Set_SlpLineSpacing', []);
end;

function TPosPrinterLogWrap.Get_RotateSpecial: Integer;
begin
  MethodStart('Get_RotateSpecial', []);
  Result := Driver.RotateSpecial;
  MethodEnd('Get_RotateSpecial', [Result]);
end;

procedure TPosPrinterLogWrap.Set_RotateSpecial(pRotateSpecial: Integer);
begin
  MethodStart('Set_RotateSpecial', [pRotateSpecial]);
  Driver.RotateSpecial := pRotateSpecial;
  MethodEnd('Set_RotateSpecial', []);
end;

function TPosPrinterLogWrap.Get_BinaryConversion: Integer;
begin
  MethodStart('Get_BinaryConversion', []);
  Result := Driver.BinaryConversion;
  MethodEnd('Get_BinaryConversion', [Result]);
end;

procedure TPosPrinterLogWrap.Set_BinaryConversion(pBinaryConversion: Integer);
begin
  MethodStart('Set_BinaryConversion', [pBinaryConversion]);
  Driver.BinaryConversion := pBinaryConversion;
  MethodEnd('Set_BinaryConversion', []);
end;

function TPosPrinterLogWrap.Get_PowerNotify: Integer;
begin
  MethodStart('Get_PowerNotify', []);
  Result := Driver.PowerNotify;
  MethodEnd('Get_PowerNotify', [Result]);
end;

procedure TPosPrinterLogWrap.Set_PowerNotify(pPowerNotify: Integer);
begin
  MethodStart('Set_PowerNotify', [pPowerNotify]);
  Driver.PowerNotify := pPowerNotify;
  MethodEnd('Set_PowerNotify', []);
end;

function TPosPrinterLogWrap.Get_CartridgeNotify: Integer;
begin
  MethodStart('Get_CartridgeNotify', []);
  Result := Driver.CartridgeNotify;
  MethodEnd('Get_CartridgeNotify', [Result]);
end;

procedure TPosPrinterLogWrap.Set_CartridgeNotify(pCartridgeNotify: Integer);
begin
  MethodStart('Set_CartridgeNotify', [pCartridgeNotify]);
  Driver.CartridgeNotify := pCartridgeNotify;
  MethodEnd('Set_CartridgeNotify', []);
end;

function TPosPrinterLogWrap.Get_JrnCurrentCartridge: Integer;
begin
  MethodStart('Get_JrnCurrentCartridge', []);
  Result := Driver.JrnCurrentCartridge;
  MethodEnd('Get_JrnCurrentCartridge', [Result]);
end;

procedure TPosPrinterLogWrap.Set_JrnCurrentCartridge(pJrnCurrentCartridge: Integer);
begin
  MethodStart('Set_JrnCurrentCartridge', [pJrnCurrentCartridge]);
  Driver.JrnCurrentCartridge := pJrnCurrentCartridge;
  MethodEnd('Set_JrnCurrentCartridge', []);
end;

function TPosPrinterLogWrap.Get_RecCurrentCartridge: Integer;
begin
  MethodStart('Get_RecCurrentCartridge', []);
  Result := Driver.RecCurrentCartridge;
  MethodEnd('Get_RecCurrentCartridge', [Result]);
end;

procedure TPosPrinterLogWrap.Set_RecCurrentCartridge(pRecCurrentCartridge: Integer);
begin
  MethodStart('Set_RecCurrentCartridge', [pRecCurrentCartridge]);
  Driver.RecCurrentCartridge := pRecCurrentCartridge;
  MethodEnd('Set_RecCurrentCartridge', []);
end;

function TPosPrinterLogWrap.Get_SlpCurrentCartridge: Integer;
begin
  MethodStart('Get_SlpCurrentCartridge', []);
  Result := Driver.SlpCurrentCartridge;
  MethodEnd('Get_SlpCurrentCartridge', [Result]);
end;

procedure TPosPrinterLogWrap.Set_SlpCurrentCartridge(pSlpCurrentCartridge: Integer);
begin
  MethodStart('Set_SlpCurrentCartridge', [pSlpCurrentCartridge]);
  Driver.SlpCurrentCartridge := pSlpCurrentCartridge;
  MethodEnd('Set_SlpCurrentCartridge', []);
end;

function TPosPrinterLogWrap.Get_MapCharacterSet: WordBool;
begin
  MethodStart('Get_MapCharacterSet', []);
  Result := Driver.MapCharacterSet;
  MethodEnd('Get_MapCharacterSet', [Result]);
end;

procedure TPosPrinterLogWrap.Set_MapCharacterSet(pMapCharacterSet: WordBool);
begin
  MethodStart('Set_MapCharacterSet', [pMapCharacterSet]);
  Driver.MapCharacterSet := pMapCharacterSet;
  MethodEnd('Set_MapCharacterSet', []);
end;

function TPosPrinterLogWrap.Get_PageModeHorizontalPosition: Integer;
begin
  MethodStart('Get_PageModeHorizontalPosition', []);
  Result := Driver.PageModeHorizontalPosition;
  MethodEnd('Get_PageModeHorizontalPosition', [Result]);
end;

procedure TPosPrinterLogWrap.Set_PageModeHorizontalPosition(pPageModeHorizontalPosition: Integer);
begin
  MethodStart('Set_PageModeHorizontalPosition', [pPageModeHorizontalPosition]);
  Driver.PageModeHorizontalPosition := pPageModeHorizontalPosition;
  MethodEnd('Set_PageModeHorizontalPosition', []);
end;

function TPosPrinterLogWrap.Get_PageModePrintArea: WideString;
begin
  MethodStart('Get_PageModePrintArea', []);
  Result := Driver.PageModePrintArea;
  MethodEnd('Get_PageModePrintArea', [Result]);
end;

procedure TPosPrinterLogWrap.Set_PageModePrintArea(const pPageModePrintArea: WideString);
begin
  MethodStart('Set_PageModePrintArea', [pPageModePrintArea]);
  Driver.PageModePrintArea := pPageModePrintArea;
  MethodEnd('Set_PageModePrintArea', []);
end;

function TPosPrinterLogWrap.Get_PageModePrintDirection: Integer;
begin
  MethodStart('Get_PageModePrintDirection', []);
  Result := Driver.PageModePrintDirection;
  MethodEnd('Get_PageModePrintDirection', [Result]);
end;

procedure TPosPrinterLogWrap.Set_PageModePrintDirection(pPageModePrintDirection: Integer);
begin
  MethodStart('Set_PageModePrintDirection', [pPageModePrintDirection]);
  Driver.PageModePrintDirection := pPageModePrintDirection;
  MethodEnd('Set_PageModePrintDirection', []);
end;

function TPosPrinterLogWrap.Get_PageModeStation: Integer;
begin
  MethodStart('Get_PageModeStation', []);
  Result := Driver.PageModeStation;
  MethodEnd('Get_PageModeStation', [Result]);
end;

procedure TPosPrinterLogWrap.Set_PageModeStation(pPageModeStation: Integer);
begin
  MethodStart('Set_PageModeStation', [pPageModeStation]);
  Driver.PageModeStation := pPageModeStation;
  MethodEnd('Set_PageModeStation', []);
end;

function TPosPrinterLogWrap.Get_PageModeVerticalPosition: Integer;
begin
  MethodStart('Get_PageModeVerticalPosition', []);
  Result := Driver.PageModeVerticalPosition;
  MethodEnd('Get_PageModeVerticalPosition', [Result]);
end;

procedure TPosPrinterLogWrap.Set_PageModeVerticalPosition(pPageModeVerticalPosition: Integer);
begin
  MethodStart('Set_PageModeVerticalPosition', [pPageModeVerticalPosition]);
  Driver.PageModeVerticalPosition := pPageModeVerticalPosition;
  MethodEnd('Set_PageModeVerticalPosition', []);
end;

end.

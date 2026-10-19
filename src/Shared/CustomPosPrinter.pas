unit CustomPosPrinter;

interface

uses
  // VCL
  Windows, Classes, SysUtils, Graphics, Math,
  // Tnt
  TntClasses, TntSysUtils,
  // Opos
  Opos, OposEsc, OposPtr, OposException, OposServiceDevice19, OposEvents,
  OposPOSPrinter_CCO_TLB, UserError, OposPtrUtils, OposUtils,
  // This
  LogFile, DriverError, PrinterPort, NotifyThread,
  RegExpr, SerialPort, Jpeg, GifImage, BarcodeUtils, StringUtils,
  DebugUtils, PtrDirectIO, EscPrinterUtils, ComUtils, OposEventsAdapter;

type
  { TCustomPosPrinter }

  TCustomPosPrinter = class(TDispIntfObject, IOPOSPOSPrinter)
  protected
    FLogger: ILogFile;
    FPort: IPrinterPort;
    FEvents: IOposEvents;
    FThread: TNotifyThread;
    FDevice: TOposServiceDevice19;
    FLastPrintMode: TPrinterModes;

    FFontName: WideString;
    FDevicePollTime: Integer;

    FAsyncMode: Boolean;
    FCapCharacterSet: Integer;
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
    FCapTransaction: Boolean;
    FCartridgeNotify: Integer;
    FCharacterSet: Integer;
    FCharacterSetList: WideString;
    FControlObjectDescription: WideString;
    FControlObjectVersion: Integer;
    FCoverOpened: Boolean;
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
    FPageModeDescriptor: Integer;
    FPageModeHorizontalPosition: Integer;
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

    FOnDirectIOEvent: TOPOSPOSPrinterDirectIOEvent;
    FOnErrorEvent: TOPOSPOSPrinterErrorEvent;
    FOnOutputCompleteEvent: TOPOSPOSPrinterOutputCompleteEvent;
    FOnStatusUpdateEvent: TOPOSPOSPrinterStatusUpdateEvent;
    FBarcodeInGraphics: Boolean;
    FPrintRasterGraphics: Boolean;

    property Device: TOposServiceDevice19 read FDevice;
  public
    procedure PrintMemoryGraphic(const Data: WideString;
      BMPType, Width, Alignment: Integer);
    procedure PrintBarcodeAsGraphics(var Barcode: TPosBarcode);
    procedure PrintWideString(const AText: WideString); virtual; abstract;
    function ClearResult: Integer;
    function HandleException(E: Exception): Integer;
    procedure CheckEnabled;
    function IllegalError: Integer;
    procedure Initialize; virtual; abstract;
    procedure CheckRecStation(Station: Integer);
    procedure PrintGraphics(Graphic: TGraphic; Width, Alignment: Integer); virtual; abstract;
    procedure DeviceProc(Sender: TObject); virtual; abstract;
    procedure UpdatePrinterStatus; virtual; abstract;
    procedure SetCoverState(CoverOpened: Boolean);

    property Logger: ILogFile read FLogger;

    procedure SetRecEmpty(ARecEmpty: Boolean);
    procedure SetRecNearEnd(ARecNearEnd: Boolean);
    procedure StartDeviceThread;
    procedure StopDeviceThread;

    procedure PrintText(Text: WideString); virtual; abstract;
    procedure InitializeDevice; virtual; abstract;
    procedure CheckPaperPresent; virtual; abstract;
    procedure CheckCoverClosed; virtual; abstract;
    procedure SetPowerState(PowerState: Integer);
  public
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
    function Get_RecLinesToPaperCut: Integer; virtual; safecall; abstract;
    function Get_RecLineWidth: Integer; virtual; safecall; abstract;
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
    function Get_PageModeArea: WideString; virtual; safecall; abstract;
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
    function Get_RecLineHeight: Integer; virtual; safecall; abstract;
    function Get_RecLineSpacing: Integer; virtual; safecall; abstract;
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
    function Get_PageModeHorizontalPosition: Integer; virtual; safecall; abstract;
    function Get_PageModePrintArea: WideString; virtual; safecall; abstract;
    function Get_PageModePrintDirection: Integer; safecall;
    function Get_PageModeStation: Integer; safecall;
    function Get_PageModeVerticalPosition: Integer; virtual; safecall; abstract;
  public
    procedure Set_DeviceEnabled(pDeviceEnabled: WordBool); virtual; safecall; abstract;
    procedure Set_FreezeEvents(pFreezeEvents: WordBool); safecall;
    procedure Set_AsyncMode(pAsyncMode: WordBool); safecall;
    procedure Set_CharacterSet(pCharacterSet: Integer); virtual; safecall; abstract;
    procedure Set_FlagWhenIdle(pFlagWhenIdle: WordBool); safecall;
    procedure Set_JrnLetterQuality(pJrnLetterQuality: WordBool); safecall;
    procedure Set_JrnLineChars(pJrnLineChars: Integer); safecall;
    procedure Set_JrnLineHeight(pJrnLineHeight: Integer); safecall;
    procedure Set_JrnLineSpacing(pJrnLineSpacing: Integer); safecall;
    procedure Set_MapMode(pMapMode: Integer); safecall;
    procedure Set_RecLetterQuality(pRecLetterQuality: WordBool); safecall;
    procedure Set_RecLineChars(pRecLineChars: Integer); virtual; safecall; abstract;
    procedure Set_RecLineHeight(pRecLineHeight: Integer); virtual; safecall; abstract;
    procedure Set_RecLineSpacing(pRecLineSpacing: Integer); virtual; safecall; abstract;
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
    procedure Set_PageModeHorizontalPosition(pPageModeHorizontalPosition: Integer); virtual; safecall; abstract;
    procedure Set_PageModePrintArea(const pPageModePrintArea: WideString); virtual; safecall; abstract;
    procedure Set_PageModePrintDirection(pPageModePrintDirection: Integer); safecall;
    procedure Set_PageModeStation(pPageModeStation: Integer); safecall;
    procedure Set_PageModeVerticalPosition(pPageModeVerticalPosition: Integer); virtual; safecall; abstract;
  public
    procedure SODataDummy(Status: Integer); safecall;
    procedure SODirectIO(EventNumber: Integer; var pData: Integer; var pString: WideString); safecall;
    procedure SOError(ResultCode: Integer; ResultCodeExtended: Integer; ErrorLocus: Integer; var pErrorResponse: Integer); safecall;
    procedure SOOutputComplete(OutputID: Integer); safecall;
    procedure SOStatusUpdate(Data: Integer); safecall;
    function SOProcessID: Integer; safecall;
    function CheckHealth(Level: Integer): Integer; virtual; safecall; abstract;
    function ClaimDevice(Timeout: Integer): Integer; safecall;
    function ClearOutput: Integer; safecall;
    function Close: Integer; safecall;
    function DirectIO(Command: Integer; var pData: Integer; var pString: WideString): Integer; virtual; safecall; abstract;
    function Open(const DeviceName: WideString): Integer; safecall;
    function ReleaseDevice: Integer; safecall;
    function BeginInsertion(Timeout: Integer): Integer; safecall;
    function BeginRemoval(Timeout: Integer): Integer; safecall;
    function CutPaper(Percentage: Integer): Integer; virtual; safecall; abstract;
    function EndInsertion: Integer; safecall;
    function EndRemoval: Integer; safecall;
    function PrintBarCode(Station: Integer; const Data: WideString; Symbology: Integer; Height: Integer; Width: Integer; Alignment: Integer; TextPosition: Integer): Integer; virtual; safecall; abstract;
    function PrintBitmap(Station: Integer; const FileName: WideString; Width: Integer; Alignment: Integer): Integer; safecall;
    function PrintImmediate(Station: Integer; const Data: WideString): Integer; safecall;
    function PrintNormal(Station: Integer; const Data: WideString): Integer; virtual; safecall; abstract;
    function PrintTwoNormal(Stations: Integer; const Data1: WideString; const Data2: WideString): Integer; safecall;
    function RotatePrint(Station: Integer; Rotation: Integer): Integer; safecall;
    function SetBitmap(BitmapNumber: Integer; Station: Integer; const FileName: WideString; Width: Integer; Alignment: Integer): Integer; safecall;
    function SetLogo(Location: Integer; const Data: WideString): Integer; safecall;
    function TransactionPrint(Station: Integer; Control: Integer): Integer; virtual; safecall; abstract;
    function ValidateData(Station: Integer; const Data: WideString): Integer; safecall;
    function ChangePrintSide(Side: Integer): Integer; safecall;
    function MarkFeed(Type_: Integer): Integer; safecall;
    function ResetStatistics(const StatisticsBuffer: WideString): Integer; safecall;
    function RetrieveStatistics(var pStatisticsBuffer: WideString): Integer; safecall;
    function UpdateStatistics(const StatisticsBuffer: WideString): Integer; safecall;
    function CompareFirmwareVersion(const FirmwareFileName: WideString; out pResult: Integer): Integer; safecall;
    function UpdateFirmware(const FirmwareFileName: WideString): Integer; safecall;
    function ClearPrintArea: Integer; safecall;
    function PageModePrint(Control: Integer): Integer; virtual; safecall; abstract;
    function PrintMemoryBitmap(Station: Integer; const Data: WideString; Type_: Integer; Width: Integer; Alignment: Integer): Integer; virtual; safecall; abstract;
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
    // IOposEvents
    procedure StatusUpdateEvent(Sender: TObject; Data: Integer);
    procedure OutputCompleteEvent(Sender: TObject; OutputID: Integer);
    procedure DirectIOEvent(Sender: TObject; EventNumber: Integer;
      var pData: Integer; var pString: WideString); virtual; abstract;
    procedure ErrorEvent(Sender: TObject; ResultCode: Integer;
      ResultCodeExtended: Integer; ErrorLocus: Integer; var pErrorResponse: Integer); virtual; abstract;

    property FontName: WideString read FFontName write FFontName;
    property DevicePollTime: Integer read FDevicePollTime write FDevicePollTime;

    property BarcodeInGraphics: Boolean read FBarcodeInGraphics write FBarcodeInGraphics;
    property PrintRasterGraphics: Boolean read FPrintRasterGraphics write FPrintRasterGraphics;
    property OnDirectIOEvent: TOPOSPOSPrinterDirectIOEvent read FOnDirectIOEvent write FOnDirectIOEvent;
    property OnErrorEvent: TOPOSPOSPrinterErrorEvent read FOnErrorEvent write FOnErrorEvent;
    property OnOutputCompleteEvent: TOPOSPOSPrinterOutputCompleteEvent read FOnOutputCompleteEvent write FOnOutputCompleteEvent;
    property OnStatusUpdateEvent: TOPOSPOSPrinterStatusUpdateEvent read FOnStatusUpdateEvent write FOnStatusUpdateEvent;
  end;

implementation

{ TCustomPosPrinter }

function TCustomPosPrinter.ClearResult: Integer;
begin
  Result := FDevice.ClearResult;
end;

procedure TCustomPosPrinter.CheckEnabled;
begin
  FDevice.CheckEnabled;
end;

function TCustomPosPrinter.IllegalError: Integer;
begin
  Result := FDevice.SetResultCode(OPOS_E_ILLEGAL);
end;

function TCustomPosPrinter.HandleException(E: Exception): Integer;
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
  if E is ESerialError then
  begin
    OPOSError.ErrorString := GetExceptionMessage(E);
    OPOSError.ResultCode := OPOS_E_TIMEOUT;
    OPOSError.ResultCodeExtended := OPOS_SUCCESS;
    FDevice.HandleException(OPOSError);
    Result := OPOSError.ResultCode;
    Exit;
  end;

  OPOSError.ErrorString := GetExceptionMessage(E);
  OPOSError.ResultCode := OPOS_E_FAILURE;
  OPOSError.ResultCodeExtended := OPOS_SUCCESS;
  FDevice.HandleException(OPOSError);
  Result := OPOSError.ResultCode;

  if OPOSError.ResultCode = OPOS_E_TIMEOUT then
  begin
    SetPowerState(OPOS_PS_OFF_OFFLINE);
  end;
end;

procedure TCustomPosPrinter.PrintMemoryGraphic(const Data: WideString;
  BMPType, Width, Alignment: Integer);
var
  Graphic: TGraphic;
  BinaryData: AnsiString;
begin
  Graphic := nil;
  try
    case BMPType of
      PTR_BMT_BMP: Graphic := TBitmap.Create;
      PTR_BMT_JPEG: Graphic := TJpegImage.Create;
      PTR_BMT_GIF: Graphic := TGifImage.Create;
    else
      raiseIllegalError('Only BMP supported');
    end;
    BinaryData := FDevice.TextToBinary(Data);
    LoadMemoryGraphic(Graphic, BinaryData);
    PrintGraphics(Graphic, Width, Alignment);
  finally
    Graphic.Free;
  end;
end;

function TCustomPosPrinter.BeginInsertion(Timeout: Integer): Integer;
begin
  Result := ClearResult;
end;

function TCustomPosPrinter.BeginRemoval(Timeout: Integer): Integer;
begin
  Result := ClearResult;
end;

function TCustomPosPrinter.ChangePrintSide(Side: Integer): Integer;
begin
  Result := ClearResult;
end;

function TCustomPosPrinter.ClaimDevice(Timeout: Integer): Integer;
begin
  try
    FDevice.ClaimDevice(Timeout);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TCustomPosPrinter.ClearOutput: Integer;
begin
  try
    FDevice.CheckClaimed;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TCustomPosPrinter.ClearPrintArea: Integer;
begin
  Result := ClearResult;
end;

function TCustomPosPrinter.Close: Integer;
begin
  try
    ReleaseDevice;
    FDevice.Close;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TCustomPosPrinter.CompareFirmwareVersion(
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

function TCustomPosPrinter.DrawRuledLine(Station: Integer;
  const PositionList: WideString; LineDirection, LineWidth, LineStyle,
  LineColor: Integer): Integer;
begin
  Result := ClearResult;
end;

function TCustomPosPrinter.EndInsertion: Integer;
begin
  Result := ClearResult;
end;

function TCustomPosPrinter.EndRemoval: Integer;
begin
  Result := ClearResult;
end;

function TCustomPosPrinter.Get_AsyncMode: WordBool;
begin
  Result := FAsyncMode;
end;

function TCustomPosPrinter.Get_BinaryConversion: Integer;
begin
  Result := FDevice.BinaryConversion;
end;

function TCustomPosPrinter.Get_CapCharacterSet: Integer;
begin
  Result := FCapCharacterSet;
end;

function TCustomPosPrinter.Get_CapCompareFirmwareVersion: WordBool;
begin
  Result := Device.CapCompareFirmwareVersion;
end;

function TCustomPosPrinter.Get_CapConcurrentJrnRec: WordBool;
begin
  Result := FCapConcurrentJrnRec;
end;

function TCustomPosPrinter.Get_CapConcurrentJrnSlp: WordBool;
begin
  Result := FCapConcurrentJrnSlp;
end;

function TCustomPosPrinter.Get_CapConcurrentPageMode: WordBool;
begin
  Result := FCapConcurrentPageMode;
end;

function TCustomPosPrinter.Get_CapConcurrentRecSlp: WordBool;
begin
  Result := FCapConcurrentRecSlp;
end;

function TCustomPosPrinter.Get_CapCoverSensor: WordBool;
begin
  Result := FCapCoverSensor;
end;

function TCustomPosPrinter.Get_CapJrn2Color: WordBool;
begin
  Result := FCapJrn2Color;
end;

function TCustomPosPrinter.Get_CapJrnBold: WordBool;
begin
  Result := FCapJrnBold;
end;

function TCustomPosPrinter.Get_CapJrnCartridgeSensor: Integer;
begin
  Result := FCapJrnCartridgeSensor;
end;

function TCustomPosPrinter.Get_CapJrnColor: Integer;
begin
  Result := FCapJrnColor;
end;

function TCustomPosPrinter.Get_CapJrnDhigh: WordBool;
begin
  Result := FCapJrnDhigh;
end;

function TCustomPosPrinter.Get_CapJrnDwide: WordBool;
begin
  Result := FCapJrnDwide;
end;

function TCustomPosPrinter.Get_CapJrnDwideDhigh: WordBool;
begin
  Result := FCapJrnDwideDhigh;
end;

function TCustomPosPrinter.Get_CapJrnEmptySensor: WordBool;
begin
  Result := FCapJrnEmptySensor;
end;

function TCustomPosPrinter.Get_CapJrnItalic: WordBool;
begin
  Result := FCapJrnItalic;
end;

function TCustomPosPrinter.Get_CapJrnNearEndSensor: WordBool;
begin
  Result := FCapJrnNearEndSensor;
end;

function TCustomPosPrinter.Get_CapJrnPresent: WordBool;
begin
  Result := FCapJrnPresent;
end;

function TCustomPosPrinter.Get_CapJrnUnderline: WordBool;
begin
  Result := FCapJrnUnderline;
end;

function TCustomPosPrinter.Get_CapMapCharacterSet: WordBool;
begin
  Result := FCapMapCharacterSet;
end;

function TCustomPosPrinter.Get_CapPowerReporting: Integer;
begin
  Result := Device.CapPowerReporting;
end;

function TCustomPosPrinter.Get_CapRec2Color: WordBool;
begin
  Result := FCapRec2Color;
end;

function TCustomPosPrinter.Get_CapRecBarCode: WordBool;
begin
  Result := FCapRecBarCode;
end;

function TCustomPosPrinter.Get_CapRecBitmap: WordBool;
begin
  Result := FCapRecBitmap;
end;

function TCustomPosPrinter.Get_CapRecBold: WordBool;
begin
  Result := FCapRecBold;
end;

function TCustomPosPrinter.Get_CapRecCartridgeSensor: Integer;
begin
  Result := FCapRecCartridgeSensor;
end;

function TCustomPosPrinter.Get_CapRecColor: Integer;
begin
  Result := FCapRecColor;
end;

function TCustomPosPrinter.Get_CapRecDhigh: WordBool;
begin
  Result := FCapRecDhigh;
end;

function TCustomPosPrinter.Get_CapRecDwide: WordBool;
begin
  Result := FCapRecDwide;
end;

function TCustomPosPrinter.Get_CapRecDwideDhigh: WordBool;
begin
  Result := FCapRecDwideDhigh;
end;

function TCustomPosPrinter.Get_CapRecEmptySensor: WordBool;
begin
  Result := FCapRecEmptySensor;
end;

function TCustomPosPrinter.Get_CapRecItalic: WordBool;
begin
  Result := FCapRecItalic;
end;

function TCustomPosPrinter.Get_CapRecLeft90: WordBool;
begin
  Result := FCapRecLeft90;
end;

function TCustomPosPrinter.Get_CapRecMarkFeed: Integer;
begin
  Result := FCapRecMarkFeed;
end;

function TCustomPosPrinter.Get_CapRecNearEndSensor: WordBool;
begin
  Result := FCapRecNearEndSensor;
end;

function TCustomPosPrinter.Get_CapRecPageMode: WordBool;
begin
  Result := FCapRecPageMode;
end;

function TCustomPosPrinter.Get_CapRecPapercut: WordBool;
begin
  Result := FCapRecPapercut;
end;

function TCustomPosPrinter.Get_CapRecPresent: WordBool;
begin
  Result := FCapRecPresent;
end;

function TCustomPosPrinter.Get_CapRecRight90: WordBool;
begin
  Result := FCapRecRight90;
end;

function TCustomPosPrinter.Get_CapRecRotate180: WordBool;
begin
  Result := FCapRecRotate180;
end;

function TCustomPosPrinter.Get_CapRecRuledLine: Integer;
begin
  Result := FCapRecRuledLine;
end;

function TCustomPosPrinter.Get_CapRecStamp: WordBool;
begin
  Result := FCapRecStamp;
end;

function TCustomPosPrinter.Get_CapRecUnderline: WordBool;
begin
  Result := FCapRecUnderline;
end;

function TCustomPosPrinter.Get_CapSlp2Color: WordBool;
begin
  Result := FCapSlp2Color;
end;

function TCustomPosPrinter.Get_CapSlpBarCode: WordBool;
begin
  Result := FCapSlpBarCode;
end;

function TCustomPosPrinter.Get_CapSlpBitmap: WordBool;
begin
  Result := FCapSlpBitmap;
end;

function TCustomPosPrinter.Get_CapSlpBold: WordBool;
begin
  Result := FCapSlpBold;
end;

function TCustomPosPrinter.Get_CapSlpBothSidesPrint: WordBool;
begin
  Result := FCapSlpBothSidesPrint;
end;

function TCustomPosPrinter.Get_CapSlpCartridgeSensor: Integer;
begin
  Result := FCapSlpCartridgeSensor;
end;

function TCustomPosPrinter.Get_CapSlpColor: Integer;
begin
  Result := FCapSlpColor;
end;

function TCustomPosPrinter.Get_CapSlpDhigh: WordBool;
begin
  Result := FCapSlpDhigh;
end;

function TCustomPosPrinter.Get_CapSlpDwide: WordBool;
begin
  Result := FCapSlpDwide;
end;

function TCustomPosPrinter.Get_CapSlpDwideDhigh: WordBool;
begin
  Result := FCapSlpDwideDhigh;
end;

function TCustomPosPrinter.Get_CapSlpEmptySensor: WordBool;
begin
  Result := FCapSlpEmptySensor;
end;

function TCustomPosPrinter.Get_CapSlpFullslip: WordBool;
begin
  Result := FCapSlpFullslip;
end;

function TCustomPosPrinter.Get_CapSlpItalic: WordBool;
begin
  Result := FCapSlpItalic;
end;

function TCustomPosPrinter.Get_CapSlpLeft90: WordBool;
begin
  Result := FCapSlpLeft90;
end;

function TCustomPosPrinter.Get_CapSlpNearEndSensor: WordBool;
begin
  Result := FCapSlpNearEndSensor;
end;

function TCustomPosPrinter.Get_CapSlpPageMode: WordBool;
begin
  Result := FCapSlpPageMode;
end;

function TCustomPosPrinter.Get_CapSlpPresent: WordBool;
begin
  Result := FCapSlpPresent;
end;

function TCustomPosPrinter.Get_CapSlpRight90: WordBool;
begin
  Result := FCapSlpRight90;
end;

function TCustomPosPrinter.Get_CapSlpRotate180: WordBool;
begin
  Result := FCapSlpRotate180;
end;

function TCustomPosPrinter.Get_CapSlpRuledLine: Integer;
begin
  Result := FCapSlpRuledLine;
end;

function TCustomPosPrinter.Get_CapSlpUnderline: WordBool;
begin
  Result := FCapSlpUnderline;
end;

function TCustomPosPrinter.Get_CapStatisticsReporting: WordBool;
begin
  Result := Device.CapStatisticsReporting;
end;

function TCustomPosPrinter.Get_CapTransaction: WordBool;
begin
  Result := FCapTransaction;
end;

function TCustomPosPrinter.Get_CapUpdateFirmware: WordBool;
begin
  Result := Device.CapUpdateFirmware;
end;

function TCustomPosPrinter.Get_CapUpdateStatistics: WordBool;
begin
  Result := Device.CapUpdateStatistics;
end;

function TCustomPosPrinter.Get_CartridgeNotify: Integer;
begin
  Result := FCartridgeNotify;
end;

function TCustomPosPrinter.Get_CharacterSet: Integer;
begin
  Result := FCharacterSet;
end;

function TCustomPosPrinter.Get_CharacterSetList: WideString;
begin
  Result := FCharacterSetList;
end;

function TCustomPosPrinter.Get_CheckHealthText: WideString;
begin
  Result := Device.CheckHealthText;
end;

function TCustomPosPrinter.Get_Claimed: WordBool;
begin
  Result := FDevice.Claimed;
end;

function TCustomPosPrinter.Get_ControlObjectDescription: WideString;
begin
  Result := FControlObjectDescription;
end;

function TCustomPosPrinter.Get_ControlObjectVersion: Integer;
begin
  Result := FControlObjectVersion;
end;

function TCustomPosPrinter.Get_CoverOpen: WordBool;
begin
  Result := FCoverOpened;
end;

function TCustomPosPrinter.Get_DeviceDescription: WideString;
begin
  Result := FDeviceDescription;
end;

function TCustomPosPrinter.Get_DeviceEnabled: WordBool;
begin
  Result := FDevice.DeviceEnabled;
end;

function TCustomPosPrinter.Get_DeviceName: WideString;
begin
  Result := FDevice.DeviceName;
end;

function TCustomPosPrinter.Get_ErrorLevel: Integer;
begin
  Result := FErrorLevel;
end;

function TCustomPosPrinter.Get_ErrorStation: Integer;
begin
  Result := FErrorStation;
end;

function TCustomPosPrinter.Get_ErrorString: WideString;
begin
  Result := FDevice.ErrorString;
end;

function TCustomPosPrinter.Get_FlagWhenIdle: WordBool;
begin
  Result := FFlagWhenIdle;
end;

function TCustomPosPrinter.Get_FontTypefaceList: WideString;
begin
  Result := FFontTypefaceList;
end;

function TCustomPosPrinter.Get_FreezeEvents: WordBool;
begin
  Result := FDevice.FreezeEvents;
end;

function TCustomPosPrinter.Get_JrnCartridgeState: Integer;
begin
  Result := FJrnCartridgeState;
end;

function TCustomPosPrinter.Get_JrnCurrentCartridge: Integer;
begin
  Result := FJrnCurrentCartridge;
end;

function TCustomPosPrinter.Get_JrnEmpty: WordBool;
begin
  Result := FJrnEmpty;
end;

function TCustomPosPrinter.Get_JrnLetterQuality: WordBool;
begin
  Result := FJrnLetterQuality;
end;

function TCustomPosPrinter.Get_JrnLineChars: Integer;
begin
  Result := FJrnLineChars;
end;

function TCustomPosPrinter.Get_JrnLineCharsList: WideString;
begin
  Result := FJrnLineCharsList;
end;

function TCustomPosPrinter.Get_JrnLineHeight: Integer;
begin
  Result := FJrnLineHeight;
end;

function TCustomPosPrinter.Get_JrnLineSpacing: Integer;
begin
  Result := FJrnLineSpacing;
end;

function TCustomPosPrinter.Get_JrnLineWidth: Integer;
begin
  Result := FJrnLineWidth;
end;

function TCustomPosPrinter.Get_JrnNearEnd: WordBool;
begin
  Result := FJrnNearEnd;
end;

function TCustomPosPrinter.Get_MapCharacterSet: WordBool;
begin
  Result := FMapCharacterSet;
end;

function TCustomPosPrinter.Get_MapMode: Integer;
begin
  Result := FMapMode;
end;

function TCustomPosPrinter.Get_OpenResult: Integer;
begin
  Result := FDevice.OpenResult;
end;

function TCustomPosPrinter.Get_OutputID: Integer;
begin
  Result := FDevice.OutputID;
end;

function TCustomPosPrinter.Get_PageModeDescriptor: Integer;
begin
  Result := FPageModeDescriptor;
end;

function TCustomPosPrinter.Get_PageModePrintDirection: Integer;
begin
  Result := FPageModePrintDirection;
end;

function TCustomPosPrinter.Get_PageModeStation: Integer;
begin
  Result := FPageModeStation;
end;

function TCustomPosPrinter.Get_PowerNotify: Integer;
begin
  Result := FDevice.PowerNotify;
end;

function TCustomPosPrinter.Get_PowerState: Integer;
begin
  Result := FDevice.PowerState;
end;

function TCustomPosPrinter.Get_RecBarCodeRotationList: WideString;
begin
  Result := FRecBarCodeRotationList;
end;

function TCustomPosPrinter.Get_RecBitmapRotationList: WideString;
begin
  Result := FRecBitmapRotationList;
end;

function TCustomPosPrinter.Get_RecCartridgeState: Integer;
begin
  Result := FRecCartridgeState;
end;

function TCustomPosPrinter.Get_RecCurrentCartridge: Integer;
begin
  Result := FRecCurrentCartridge;
end;

function TCustomPosPrinter.Get_RecEmpty: WordBool;
begin
  Result := FRecEmpty;
end;

function TCustomPosPrinter.Get_RecLetterQuality: WordBool;
begin
  Result := FRecLetterQuality;
end;

function TCustomPosPrinter.Get_RecLineChars: Integer;
begin
  Result := FRecLineChars;
end;

function TCustomPosPrinter.Get_RecLineCharsList: WideString;
begin
  Result := FRecLineCharsList;
end;

function TCustomPosPrinter.Get_RecNearEnd: WordBool;
begin
  Result := FRecNearEnd;
end;

function TCustomPosPrinter.Get_RecSidewaysMaxChars: Integer;
begin
  Result := FRecSidewaysMaxChars;
end;

function TCustomPosPrinter.Get_RecSidewaysMaxLines: Integer;
begin
  Result := FRecSidewaysMaxLines;
end;

function TCustomPosPrinter.Get_ResultCode: Integer;
begin
  Result := FDevice.ResultCode;
end;

function TCustomPosPrinter.Get_ResultCodeExtended: Integer;
begin
  Result := FDevice.ResultCodeExtended;
end;

function TCustomPosPrinter.Get_RotateSpecial: Integer;
begin
  Result := FRotateSpecial;
end;

function TCustomPosPrinter.Get_ServiceObjectDescription: WideString;
begin
  Result := FDevice.ServiceObjectDescription;
end;

function TCustomPosPrinter.Get_ServiceObjectVersion: Integer;
begin
  Result := FDevice.ServiceObjectVersion;
end;

function TCustomPosPrinter.Get_SlpBarCodeRotationList: WideString;
begin
  Result := FSlpBarCodeRotationList;
end;

function TCustomPosPrinter.Get_SlpBitmapRotationList: WideString;
begin
  Result := FSlpBitmapRotationList;
end;

function TCustomPosPrinter.Get_SlpCartridgeState: Integer;
begin
  Result := FSlpCartridgeState;
end;

function TCustomPosPrinter.Get_SlpCurrentCartridge: Integer;
begin
  Result := FSlpCurrentCartridge;
end;

function TCustomPosPrinter.Get_SlpEmpty: WordBool;
begin
  Result := FSlpEmpty;
end;

function TCustomPosPrinter.Get_SlpLetterQuality: WordBool;
begin
  Result := FSlpLetterQuality;
end;

function TCustomPosPrinter.Get_SlpLineChars: Integer;
begin
  Result := FSlpLineChars;
end;

function TCustomPosPrinter.Get_SlpLineCharsList: WideString;
begin
  Result := FSlpLineCharsList;
end;

function TCustomPosPrinter.Get_SlpLineHeight: Integer;
begin
  Result := FSlpLineHeight;
end;

function TCustomPosPrinter.Get_SlpLinesNearEndToEnd: Integer;
begin
  Result := FSlpLinesNearEndToEnd;
end;

function TCustomPosPrinter.Get_SlpLineSpacing: Integer;
begin
  Result := FSlpLineSpacing;
end;

function TCustomPosPrinter.Get_SlpLineWidth: Integer;
begin
  Result := FSlpLineWidth;
end;

function TCustomPosPrinter.Get_SlpMaxLines: Integer;
begin
  Result := FSlpMaxLines;
end;

function TCustomPosPrinter.Get_SlpNearEnd: WordBool;
begin
  Result := FSlpNearEnd;
end;

function TCustomPosPrinter.Get_SlpPrintSide: Integer;
begin
  Result := FSlpPrintSide;
end;

function TCustomPosPrinter.Get_SlpSidewaysMaxChars: Integer;
begin
  Result := FSlpSidewaysMaxChars;
end;

function TCustomPosPrinter.Get_SlpSidewaysMaxLines: Integer;
begin
  Result := FSlpSidewaysMaxLines;
end;

function TCustomPosPrinter.Get_State: Integer;
begin
  Result := FDevice.State;
end;

function TCustomPosPrinter.MarkFeed(Type_: Integer): Integer;
begin
  Result := ClearResult;
end;

function TCustomPosPrinter.Open(const DeviceName: WideString): Integer;
begin
  try
    FDevice.Open('POSPrinter', DeviceName, FEvents);
    Result := ClearResult;
  except
    on E: Exception do
    begin
      Close;
      Result := HandleException(E);
    end;
  end;
end;

procedure TCustomPosPrinter.PrintBarcodeAsGraphics(var Barcode: TPosBarcode);
var
  Data: AnsiString;
begin
  if not CapRecBitmap then
    RaiseIllegalError('Bitmaps are not supported');

  Data := RenderBarcodeRec(Barcode);
  PrintMemoryGraphic(Data, PTR_BMT_BMP, Barcode.Width, Barcode.Alignment);
end;

function TCustomPosPrinter.PrintBitmap(Station: Integer;
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

function TCustomPosPrinter.PrintImmediate(Station: Integer;
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

procedure TCustomPosPrinter.CheckRecStation(Station: Integer);
begin
  if Station <> PTR_S_RECEIPT then
    raiseIllegalError('Station not supported');
end;

function TCustomPosPrinter.PrintTwoNormal(Stations: Integer; const Data1,
  Data2: WideString): Integer;
begin
  Result := ClearResult;
end;

function TCustomPosPrinter.ReleaseDevice: Integer;
begin
  try
    DeviceEnabled := False;
    FDevice.ReleaseDevice;
    Result := ClearResult;
  except
    on E: Exception do
    begin
      Result := HandleException(E);
    end;
  end;
end;

function TCustomPosPrinter.ResetStatistics(
  const StatisticsBuffer: WideString): Integer;
begin
  Result := ClearResult;
end;

function TCustomPosPrinter.RetrieveStatistics(
  var pStatisticsBuffer: WideString): Integer;
begin
  Result := ClearResult;
end;

function TCustomPosPrinter.RotatePrint(Station, Rotation: Integer): Integer;
begin
  Result := ClearResult;
end;

procedure TCustomPosPrinter.Set_AsyncMode(pAsyncMode: WordBool);
begin
  FAsyncMode := pAsyncMode;
end;

procedure TCustomPosPrinter.Set_BinaryConversion(pBinaryConversion: Integer);
begin
  FDevice.BinaryConversion := pBinaryConversion;
end;

procedure TCustomPosPrinter.Set_CartridgeNotify(pCartridgeNotify: Integer);
begin
  FCartridgeNotify := pCartridgeNotify;
end;

procedure TCustomPosPrinter.StartDeviceThread;
begin
  if FThread = nil then
  begin
    FThread := TNotifyThread.Create(True);
    FThread.OnExecute := DeviceProc;
    FThread.Resume;
  end;
end;

procedure TCustomPosPrinter.StopDeviceThread;
begin
  if FThread <> nil then
  begin
    FThread.Terminate;
    FThread.Free;
    FThread := nil;
  end;
end;

procedure TCustomPosPrinter.SetCoverState(CoverOpened: Boolean);
begin
  if FCapCoverSensor then
  begin
    if CoverOpened <> FCoverOpened then
    begin
      if CoverOpened then
      begin
        FDevice.StatusUpdateEvent(PTR_SUE_COVER_OPEN);
      end else
      begin
        FDevice.StatusUpdateEvent(PTR_SUE_COVER_OK);
      end;
      FCoverOpened := CoverOpened;
    end;
  end;
end;

procedure TCustomPosPrinter.SetRecEmpty(ARecEmpty: Boolean);
begin
  if not FCapRecPresent then Exit;
  if not FCapRecEmptySensor then Exit;

  if ARecEmpty <> FRecEmpty then
  begin
    FRecEmpty := ARecEmpty;
    if FRecEmpty then
    begin
      FDevice.StatusUpdateEvent(PTR_SUE_REC_EMPTY)
    end else
    begin
      if FRecNearEnd then
        FDevice.StatusUpdateEvent(PTR_SUE_REC_NEAREMPTY)
      else
        FDevice.StatusUpdateEvent(PTR_SUE_REC_PAPEROK);
    end;
  end;
end;

procedure TCustomPosPrinter.SetRecNearEnd(ARecNearEnd: Boolean);
begin
  if not FCapRecPresent then Exit;
  if not FCapRecNearEndSensor then Exit;
  if FRecEmpty then Exit;

  if ARecNearEnd <> FRecNearEnd then
  begin
    FRecNearEnd := ARecNearEnd;
    if FRecNearEnd then
      FDevice.StatusUpdateEvent(PTR_SUE_REC_NEAREMPTY)
    else
      FDevice.StatusUpdateEvent(PTR_SUE_REC_PAPEROK);
  end;
end;

procedure TCustomPosPrinter.SetPowerState(PowerState: Integer);
begin
  if PowerState <> FDevice.PowerState then
  begin
    FDevice.PowerState := PowerState;
    if PowerState = OPOS_PS_ONLINE then
    begin
      InitializeDevice;
    end;
  end;
end;

procedure TCustomPosPrinter.Set_FlagWhenIdle(pFlagWhenIdle: WordBool);
begin
  FFlagWhenIdle := pFlagWhenIdle;
end;

procedure TCustomPosPrinter.Set_FreezeEvents(pFreezeEvents: WordBool);
begin
  FDevice.FreezeEvents := pFreezeEvents;
end;

procedure TCustomPosPrinter.Set_JrnCurrentCartridge(
  pJrnCurrentCartridge: Integer);
begin
  FJrnCurrentCartridge := pJrnCurrentCartridge;
end;

procedure TCustomPosPrinter.Set_JrnLetterQuality(pJrnLetterQuality: WordBool);
begin
  FJrnLetterQuality := pJrnLetterQuality;
end;

procedure TCustomPosPrinter.Set_JrnLineChars(pJrnLineChars: Integer);
begin
  FJrnLineChars := pJrnLineChars;
end;

procedure TCustomPosPrinter.Set_JrnLineHeight(pJrnLineHeight: Integer);
begin
  FJrnLineHeight := pJrnLineHeight;
end;

procedure TCustomPosPrinter.Set_JrnLineSpacing(pJrnLineSpacing: Integer);
begin
  FJrnLineSpacing := pJrnLineSpacing;
end;

procedure TCustomPosPrinter.Set_MapCharacterSet(pMapCharacterSet: WordBool);
begin
  FMapCharacterSet := pMapCharacterSet;
end;

procedure TCustomPosPrinter.Set_MapMode(pMapMode: Integer);
begin
  FMapMode := pMapMode;
end;

procedure TCustomPosPrinter.Set_PageModePrintDirection(
  pPageModePrintDirection: Integer);
begin
  FPageModePrintDirection := pPageModePrintDirection;
end;

procedure TCustomPosPrinter.Set_PageModeStation(pPageModeStation: Integer);
begin
  FPageModeStation := pPageModeStation;
end;

procedure TCustomPosPrinter.Set_PowerNotify(pPowerNotify: Integer);
begin
  FDevice.PowerNotify := pPowerNotify;
end;

procedure TCustomPosPrinter.Set_RecCurrentCartridge(
  pRecCurrentCartridge: Integer);
begin
  FRecCurrentCartridge := pRecCurrentCartridge;
end;

procedure TCustomPosPrinter.Set_RecLetterQuality(pRecLetterQuality: WordBool);
begin
  FRecLetterQuality := pRecLetterQuality;
end;

procedure TCustomPosPrinter.Set_RotateSpecial(pRotateSpecial: Integer);
begin
  FRotateSpecial := pRotateSpecial;
end;

procedure TCustomPosPrinter.Set_SlpCurrentCartridge(
  pSlpCurrentCartridge: Integer);
begin
  FSlpCurrentCartridge := pSlpCurrentCartridge;
end;

procedure TCustomPosPrinter.Set_SlpLetterQuality(pSlpLetterQuality: WordBool);
begin
  FSlpLetterQuality := pSlpLetterQuality;
end;

procedure TCustomPosPrinter.Set_SlpLineChars(pSlpLineChars: Integer);
begin
  FSlpLineChars := pSlpLineChars;
end;

procedure TCustomPosPrinter.Set_SlpLineHeight(pSlpLineHeight: Integer);
begin
  FSlpLineHeight := pSlpLineHeight;
end;

procedure TCustomPosPrinter.Set_SlpLineSpacing(pSlpLineSpacing: Integer);
begin
  FSlpLineSpacing := pSlpLineSpacing;
end;

function TCustomPosPrinter.SetBitmap(BitmapNumber, Station: Integer;
  const FileName: WideString; Width, Alignment: Integer): Integer;
begin

  Result := ClearResult;
end;

function TCustomPosPrinter.SetLogo(Location: Integer;
  const Data: WideString): Integer;
begin
  Result := ClearResult;
end;

function TCustomPosPrinter.UpdateFirmware(
  const FirmwareFileName: WideString): Integer;
begin
  Result := ClearResult;
end;

function TCustomPosPrinter.UpdateStatistics(
  const StatisticsBuffer: WideString): Integer;
begin
  Result := ClearResult;
end;

function TCustomPosPrinter.ValidateData(Station: Integer;
  const Data: WideString): Integer;
begin
  Result := ClearResult;
end;

procedure TCustomPosPrinter.OutputCompleteEvent(Sender: TObject; OutputID: Integer);
begin
  if Assigned(FOnOutputCompleteEvent) then
    FOnOutputCompleteEvent(Self, OutputID);
end;

procedure TCustomPosPrinter.StatusUpdateEvent(Sender: TObject; Data: Integer);
begin
  if Assigned(FOnStatusUpdateEvent) then
    FOnStatusUpdateEvent(Self, Data);
end;

procedure TCustomPosPrinter.SODataDummy(Status: Integer);
begin

end;

procedure TCustomPosPrinter.SODirectIO(EventNumber: Integer;
  var pData: Integer; var pString: WideString);
begin

end;

procedure TCustomPosPrinter.SOError(ResultCode, ResultCodeExtended,
  ErrorLocus: Integer; var pErrorResponse: Integer);
begin

end;

procedure TCustomPosPrinter.SOOutputComplete(OutputID: Integer);
begin

end;

function TCustomPosPrinter.SOProcessID: Integer;
begin

end;

procedure TCustomPosPrinter.SOStatusUpdate(Data: Integer);
begin

end;

end.

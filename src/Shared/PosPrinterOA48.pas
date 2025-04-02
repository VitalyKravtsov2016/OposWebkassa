unit PosPrinterOA48;

interface

uses
  // VCL
  Windows, Classes, SysUtils, Graphics, Math, Jpeg, GifImage,
  // Tnt
  TntClasses,
  // Opos
  Opos, OposEsc, OposPtr, OposException, OposServiceDevice19, OposEvents,
  OposPOSPrinter_CCO_TLB, WException, OposPtrUtils, PtrDirectIO,
  // This
  LogFile, DriverError, EscPrinterOA48, PrinterPort, NotifyThread,
  RegExpr, SerialPort, BarcodeUtils, StringUtils,
  DebugUtils, EscPrinterUtils, ComUtils, OposEventsAdapter;

type
  { TPosPrinterOA48 }

  TPosPrinterOA48 = class(TDispIntfObject, IOPOSPOSPrinter)
  private
    FLogger: ILogFile;
    FPort: IPrinterPort;
    FThread: TNotifyThread;
    FPrinter: TEscPrinterOA48;
    FDevice: TOposServiceDevice19;
    FLastPrintMode: TPrinterModes;
    FEvents: IOposEvents;

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
    FUtf8Enabled: Boolean;
    FPrinterCodePage: Integer;

    property Device: TOposServiceDevice19 read FDevice;
    function CharSetToPrinterCP(CharacterSet: Integer): Integer;
  public
    procedure PrintMemoryGraphic(const Data: WideString;
      BMPType, Width, Alignment: Integer);
    procedure PrintBarcodeAsGraphics(var Barcode: TPosBarcode);
    procedure PrintWideString(const AText: WideString);
    function ClearResult: Integer;
    function HandleException(E: Exception): Integer;
    procedure CheckEnabled;
    function IllegalError: Integer;
    procedure Initialize;
    procedure CheckRecStation(Station: Integer);
    procedure PrintGraphics(Graphic: TGraphic; Width, Alignment: Integer);
    procedure DeviceProc(Sender: TObject);
    procedure UpdatePrinterStatus;
    procedure SetCoverState(CoverOpened: Boolean);

    property Logger: ILogFile read FLogger;
    property Printer: TEscPrinterOA48 read FPrinter;

    procedure SetRecEmpty(ARecEmpty: Boolean);
    procedure SetRecNearEnd(ARecNearEnd: Boolean);
    procedure StartDeviceThread;
    procedure StopDeviceThread;

    procedure PrintText(Text: WideString);
    procedure InitializeDevice;
    procedure CheckPaperPresent;
    procedure CheckCoverClosed;
    procedure SetPowerState(PowerState: Integer);
  public
    constructor Create(APort: IPrinterPort; ALogger: ILogFile);
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
    // IOposEvents
    procedure DataEvent(Sender: TObject; Status: Integer);
    procedure StatusUpdateEvent(Sender: TObject; Data: Integer);
    procedure OutputCompleteEvent(Sender: TObject; OutputID: Integer);
    procedure DirectIOEvent(Sender: TObject; EventNumber: Integer;
      var pData: Integer; var pString: WideString);
    procedure ErrorEvent(Sender: TObject; ResultCode: Integer; ResultCodeExtended: Integer;
      ErrorLocus: Integer; var pErrorResponse: Integer);

    property FontName: WideString read FFontName write FFontName;
    property Utf8Enabled: Boolean read FUtf8Enabled write FUtf8Enabled;
    property DevicePollTime: Integer read FDevicePollTime write FDevicePollTime;
    property BarcodeInGraphics: Boolean read FBarcodeInGraphics write FBarcodeInGraphics;
    property PrintRasterGraphics: Boolean read FPrintRasterGraphics write FPrintRasterGraphics;
    property OnDirectIOEvent: TOPOSPOSPrinterDirectIOEvent read FOnDirectIOEvent write FOnDirectIOEvent;
    property OnErrorEvent: TOPOSPOSPrinterErrorEvent read FOnErrorEvent write FOnErrorEvent;
    property OnOutputCompleteEvent: TOPOSPOSPrinterOutputCompleteEvent read FOnOutputCompleteEvent write FOnOutputCompleteEvent;
    property OnStatusUpdateEvent: TOPOSPOSPrinterStatusUpdateEvent read FOnStatusUpdateEvent write FOnStatusUpdateEvent;
  end;

implementation

function IsValidCharacterSet(CharacterSet: Integer): Boolean;
var
  i: Integer;
begin
  for i := Low(SupportedCodePagesB) to High(SupportedCodePagesB) do
  begin
    Result := CharacterSet = SupportedCodePagesB[i];
    if Result then Break;
  end;
end;

function CharacterSetToCodePage(CharacterSet: Integer): Integer;
begin
  case CharacterSet of
    PTR_CS_UNICODE: Result := CP_ACP; // active code page
    PTR_CS_WINDOWS: Result := CP_ACP; // active code page
    PTR_CS_ASCII: Result := 20127;    // us-ascii	US-ASCII (7-bit)
  else
    Result := CharacterSet;
  end;
end;

{ TPosPrinterOA48 }

constructor TPosPrinterOA48.Create(APort: IPrinterPort; ALogger: ILogFile);

  function CreateEventsAdapter: TOposEventsAdapter;
  begin
    Result := TOposEventsAdapter.Create;
    Result.OnErrorEvent := ErrorEvent;
    Result.OnDirectIOEvent := DirectIOEvent;
    Result.OnStatusUpdateEvent := StatusUpdateEvent;
    Result.OnOutputCompleteEvent := OutputCompleteEvent;
  end;

begin
  inherited Create;
  FPort := APort;
  FLogger := ALogger;

  FEvents := CreateEventsAdapter;
  FPrinter := TEscPrinterOA48.Create(APort, ALogger);
  FDevice := TOposServiceDevice19.Create(FLogger);
  FDevice.ErrorEventEnabled := False;
  Initialize;

  Utf8Enabled := False;
  if Utf8Enabled then
  begin
    // Only codepage 1251 must be used
    FPrinterCodePage := 1251;
  end else
  begin
    // Font B russian chars are only in 866 code page
    FPrinterCodePage := 866;
  end;
end;

destructor TPosPrinterOA48.Destroy;
begin
  if FDevice.Opened then
    Close;

  FDevice.Free;
  FThread.Free;
  FPrinter.Free;
  FEvents := nil;
  FPort := nil;
  FLogger := nil;
  inherited Destroy;
end;

procedure TPosPrinterOA48.Initialize;
begin
  FAsyncMode := False;
  FCapCharacterSet := PTR_CCS_UNICODE;
  FCapConcurrentJrnRec := False;
  FCapConcurrentJrnSlp := False;
  FCapConcurrentPageMode := False;
  FCapConcurrentRecSlp := False;
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
  FCapMapCharacterSet := True;
  FCapRecNearEndSensor := False;
  if FPrinter.CapRead then
  begin
    FDevice.CapPowerReporting := OPOS_PR_STANDARD;
    FCapRecEmptySensor := True;
    FCapCoverSensor := True;
  end else
  begin
    Device.CapPowerReporting := OPOS_PR_NONE;
    FCapRecEmptySensor := False;
    FCapCoverSensor := False;
  end;
  FCapRec2Color := False;
  FCapRecBarCode := True;
  FCapRecBitmap := True;
  FCapRecBold := True;
  FCapRecCartridgeSensor := PTR_CART_OK;
  FCapRecColor := PTR_COLOR_PRIMARY;
  FCapRecDhigh := True;
  FCapRecDwide := True;
  FCapRecDwideDhigh := True;
  FCapRecItalic := False;
  FCapRecLeft90 := True;
  FCapRecMarkFeed := 0;
  FCapRecPageMode := False;
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
  FCapTransaction := True;
  FCartridgeNotify := 0;
  FCharacterSet := PTR_CS_UNICODE;
  FCharacterSetList := ArrayToString(SupportedCodePagesB);
  FControlObjectDescription := 'OPOS Windows Printer';
  FControlObjectVersion := 1014001;
  FCoverOpened := False;
  FDeviceDescription := 'OPOS Windows Printer';
  FErrorLevel := PTR_EL_NONE;
  FErrorStation := PTR_S_RECEIPT;
  FFlagWhenIdle := False;
  FFontName := FontNameA;
  FFontTypefaceList := FontNameA + ',' + FontNameB;
  FJrnCartridgeState := 0;
  FJrnCurrentCartridge := 0;
  FJrnEmpty := False;
  FJrnLetterQuality := False;
  FJrnLineChars := 0;
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
  FRecLineChars := 48;
  FRecLineCharsList := '48,64';
  FRecLineHeight := 24;
  FRecLineSpacing := 30;
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
  FLastPrintMode := [];
  FDevicePollTime := 3000;
  PrintRasterGraphics := True;
end;

function TPosPrinterOA48.ClearResult: Integer;
begin
  Result := FDevice.ClearResult;
end;

procedure TPosPrinterOA48.CheckEnabled;
begin
  FDevice.CheckEnabled;
end;

function TPosPrinterOA48.IllegalError: Integer;
begin
  Result := FDevice.SetResultCode(OPOS_E_ILLEGAL);
end;

function TPosPrinterOA48.HandleException(E: Exception): Integer;
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

procedure TPosPrinterOA48.PrintMemoryGraphic(const Data: WideString;
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

// IOPOSPOSPrinter

function TPosPrinterOA48.BeginInsertion(Timeout: Integer): Integer;
begin
  Result := ClearResult;
end;

function TPosPrinterOA48.BeginRemoval(Timeout: Integer): Integer;
begin
  Result := ClearResult;
end;

function TPosPrinterOA48.ChangePrintSide(Side: Integer): Integer;
begin
  Result := ClearResult;
end;

function TPosPrinterOA48.CheckHealth(Level: Integer): Integer;
begin
  try
    case Level of
      OPOS_CH_INTERNAL:
      begin
        CheckPaperPresent;
        CheckCoverClosed;
      end;
      OPOS_CH_EXTERNAL:
        FPrinter.PrintTestPage;

      OPOS_CH_INTERACTIVE:
        FPrinter.PrintTestPage;
    else
      raiseIllegalError('Invalid level parameter value');
    end;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TPosPrinterOA48.ClaimDevice(Timeout: Integer): Integer;
begin
  try
    FDevice.ClaimDevice(Timeout);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TPosPrinterOA48.ClearOutput: Integer;
begin
  try
    FDevice.CheckClaimed;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TPosPrinterOA48.ClearPrintArea: Integer;
begin
  Result := ClearResult;
end;

function TPosPrinterOA48.Close: Integer;
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

function TPosPrinterOA48.CompareFirmwareVersion(
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

function TPosPrinterOA48.CutPaper(Percentage: Integer): Integer;
begin
  try
    FPrinter.PrintText(' ' + CRLF);
    FPrinter.PartialCut;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TPosPrinterOA48.DirectIO(Command: Integer; var pData: Integer;
  var pString: WideString): Integer;
begin
  try
    Device.CheckOpened;
    case Command of
      DIO_PTR_CHECK_BARCODE:
      begin
        case pData of
          PTR_BCS_UPCA,
          PTR_BCS_UPCE,
          PTR_BCS_EAN8,
          PTR_BCS_EAN13,
          PTR_BCS_ITF,
          PTR_BCS_Codabar,
          PTR_BCS_Code39,
          PTR_BCS_Code93,
          PTR_BCS_Code128,
          PTR_BCS_QRCODE,
          PTR_BCS_PDF417: pString := '1';
        else
          pString := '0';
        end;
      end;
    end;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;


function TPosPrinterOA48.DrawRuledLine(Station: Integer;
  const PositionList: WideString; LineDirection, LineWidth, LineStyle,
  LineColor: Integer): Integer;
begin
  Result := ClearResult;
end;

function TPosPrinterOA48.EndInsertion: Integer;
begin
  Result := ClearResult;
end;

function TPosPrinterOA48.EndRemoval: Integer;
begin
  Result := ClearResult;
end;

function TPosPrinterOA48.Get_AsyncMode: WordBool;
begin
  Result := FAsyncMode;
end;

function TPosPrinterOA48.Get_BinaryConversion: Integer;
begin
  Result := FDevice.BinaryConversion;
end;

function TPosPrinterOA48.Get_CapCharacterSet: Integer;
begin
  Result := FCapCharacterSet;
end;

function TPosPrinterOA48.Get_CapCompareFirmwareVersion: WordBool;
begin
  Result := Device.CapCompareFirmwareVersion;
end;

function TPosPrinterOA48.Get_CapConcurrentJrnRec: WordBool;
begin
  Result := FCapConcurrentJrnRec;
end;

function TPosPrinterOA48.Get_CapConcurrentJrnSlp: WordBool;
begin
  Result := FCapConcurrentJrnSlp;
end;

function TPosPrinterOA48.Get_CapConcurrentPageMode: WordBool;
begin
  Result := FCapConcurrentPageMode;
end;

function TPosPrinterOA48.Get_CapConcurrentRecSlp: WordBool;
begin
  Result := FCapConcurrentRecSlp;
end;

function TPosPrinterOA48.Get_CapCoverSensor: WordBool;
begin
  Result := FCapCoverSensor;
end;

function TPosPrinterOA48.Get_CapJrn2Color: WordBool;
begin
  Result := FCapJrn2Color;
end;

function TPosPrinterOA48.Get_CapJrnBold: WordBool;
begin
  Result := FCapJrnBold;
end;

function TPosPrinterOA48.Get_CapJrnCartridgeSensor: Integer;
begin
  Result := FCapJrnCartridgeSensor;
end;

function TPosPrinterOA48.Get_CapJrnColor: Integer;
begin
  Result := FCapJrnColor;
end;

function TPosPrinterOA48.Get_CapJrnDhigh: WordBool;
begin
  Result := FCapJrnDhigh;
end;

function TPosPrinterOA48.Get_CapJrnDwide: WordBool;
begin
  Result := FCapJrnDwide;
end;

function TPosPrinterOA48.Get_CapJrnDwideDhigh: WordBool;
begin
  Result := FCapJrnDwideDhigh;
end;

function TPosPrinterOA48.Get_CapJrnEmptySensor: WordBool;
begin
  Result := FCapJrnEmptySensor;
end;

function TPosPrinterOA48.Get_CapJrnItalic: WordBool;
begin
  Result := FCapJrnItalic;
end;

function TPosPrinterOA48.Get_CapJrnNearEndSensor: WordBool;
begin
  Result := FCapJrnNearEndSensor;
end;

function TPosPrinterOA48.Get_CapJrnPresent: WordBool;
begin
  Result := FCapJrnPresent;
end;

function TPosPrinterOA48.Get_CapJrnUnderline: WordBool;
begin
  Result := FCapJrnUnderline;
end;

function TPosPrinterOA48.Get_CapMapCharacterSet: WordBool;
begin
  Result := FCapMapCharacterSet;
end;

function TPosPrinterOA48.Get_CapPowerReporting: Integer;
begin
  Result := Device.CapPowerReporting;
end;

function TPosPrinterOA48.Get_CapRec2Color: WordBool;
begin
  Result := FCapRec2Color;
end;

function TPosPrinterOA48.Get_CapRecBarCode: WordBool;
begin
  Result := FCapRecBarCode;
end;

function TPosPrinterOA48.Get_CapRecBitmap: WordBool;
begin
  Result := FCapRecBitmap;
end;

function TPosPrinterOA48.Get_CapRecBold: WordBool;
begin
  Result := FCapRecBold;
end;

function TPosPrinterOA48.Get_CapRecCartridgeSensor: Integer;
begin
  Result := FCapRecCartridgeSensor;
end;

function TPosPrinterOA48.Get_CapRecColor: Integer;
begin
  Result := FCapRecColor;
end;

function TPosPrinterOA48.Get_CapRecDhigh: WordBool;
begin
  Result := FCapRecDhigh;
end;

function TPosPrinterOA48.Get_CapRecDwide: WordBool;
begin
  Result := FCapRecDwide;
end;

function TPosPrinterOA48.Get_CapRecDwideDhigh: WordBool;
begin
  Result := FCapRecDwideDhigh;
end;

function TPosPrinterOA48.Get_CapRecEmptySensor: WordBool;
begin
  Result := FCapRecEmptySensor;
end;

function TPosPrinterOA48.Get_CapRecItalic: WordBool;
begin
  Result := FCapRecItalic;
end;

function TPosPrinterOA48.Get_CapRecLeft90: WordBool;
begin
  Result := FCapRecLeft90;
end;

function TPosPrinterOA48.Get_CapRecMarkFeed: Integer;
begin
  Result := FCapRecMarkFeed;
end;

function TPosPrinterOA48.Get_CapRecNearEndSensor: WordBool;
begin
  Result := FCapRecNearEndSensor;
end;

function TPosPrinterOA48.Get_CapRecPageMode: WordBool;
begin
  Result := FCapRecPageMode;
end;

function TPosPrinterOA48.Get_CapRecPapercut: WordBool;
begin
  Result := FCapRecPapercut;
end;

function TPosPrinterOA48.Get_CapRecPresent: WordBool;
begin
  Result := FCapRecPresent;
end;

function TPosPrinterOA48.Get_CapRecRight90: WordBool;
begin
  Result := FCapRecRight90;
end;

function TPosPrinterOA48.Get_CapRecRotate180: WordBool;
begin
  Result := FCapRecRotate180;
end;

function TPosPrinterOA48.Get_CapRecRuledLine: Integer;
begin
  Result := FCapRecRuledLine;
end;

function TPosPrinterOA48.Get_CapRecStamp: WordBool;
begin
  Result := FCapRecStamp;
end;

function TPosPrinterOA48.Get_CapRecUnderline: WordBool;
begin
  Result := FCapRecUnderline;
end;

function TPosPrinterOA48.Get_CapSlp2Color: WordBool;
begin
  Result := FCapSlp2Color;
end;

function TPosPrinterOA48.Get_CapSlpBarCode: WordBool;
begin
  Result := FCapSlpBarCode;
end;

function TPosPrinterOA48.Get_CapSlpBitmap: WordBool;
begin
  Result := FCapSlpBitmap;
end;

function TPosPrinterOA48.Get_CapSlpBold: WordBool;
begin
  Result := FCapSlpBold;
end;

function TPosPrinterOA48.Get_CapSlpBothSidesPrint: WordBool;
begin
  Result := FCapSlpBothSidesPrint;
end;

function TPosPrinterOA48.Get_CapSlpCartridgeSensor: Integer;
begin
  Result := FCapSlpCartridgeSensor;
end;

function TPosPrinterOA48.Get_CapSlpColor: Integer;
begin
  Result := FCapSlpColor;
end;

function TPosPrinterOA48.Get_CapSlpDhigh: WordBool;
begin
  Result := FCapSlpDhigh;
end;

function TPosPrinterOA48.Get_CapSlpDwide: WordBool;
begin
  Result := FCapSlpDwide;
end;

function TPosPrinterOA48.Get_CapSlpDwideDhigh: WordBool;
begin
  Result := FCapSlpDwideDhigh;
end;

function TPosPrinterOA48.Get_CapSlpEmptySensor: WordBool;
begin
  Result := FCapSlpEmptySensor;
end;

function TPosPrinterOA48.Get_CapSlpFullslip: WordBool;
begin
  Result := FCapSlpFullslip;
end;

function TPosPrinterOA48.Get_CapSlpItalic: WordBool;
begin
  Result := FCapSlpItalic;
end;

function TPosPrinterOA48.Get_CapSlpLeft90: WordBool;
begin
  Result := FCapSlpLeft90;
end;

function TPosPrinterOA48.Get_CapSlpNearEndSensor: WordBool;
begin
  Result := FCapSlpNearEndSensor;
end;

function TPosPrinterOA48.Get_CapSlpPageMode: WordBool;
begin
  Result := FCapSlpPageMode;
end;

function TPosPrinterOA48.Get_CapSlpPresent: WordBool;
begin
  Result := FCapSlpPresent;
end;

function TPosPrinterOA48.Get_CapSlpRight90: WordBool;
begin
  Result := FCapSlpRight90;
end;

function TPosPrinterOA48.Get_CapSlpRotate180: WordBool;
begin
  Result := FCapSlpRotate180;
end;

function TPosPrinterOA48.Get_CapSlpRuledLine: Integer;
begin
  Result := FCapSlpRuledLine;
end;

function TPosPrinterOA48.Get_CapSlpUnderline: WordBool;
begin
  Result := FCapSlpUnderline;
end;

function TPosPrinterOA48.Get_CapStatisticsReporting: WordBool;
begin
  Result := Device.CapStatisticsReporting;
end;

function TPosPrinterOA48.Get_CapTransaction: WordBool;
begin
  Result := FCapTransaction;
end;

function TPosPrinterOA48.Get_CapUpdateFirmware: WordBool;
begin
  Result := Device.CapUpdateFirmware;
end;

function TPosPrinterOA48.Get_CapUpdateStatistics: WordBool;
begin
  Result := Device.CapUpdateStatistics;
end;

function TPosPrinterOA48.Get_CartridgeNotify: Integer;
begin
  Result := FCartridgeNotify;
end;

function TPosPrinterOA48.Get_CharacterSet: Integer;
begin
  Result := FCharacterSet;
end;

function TPosPrinterOA48.Get_CharacterSetList: WideString;
begin
  Result := FCharacterSetList;
end;

function TPosPrinterOA48.Get_CheckHealthText: WideString;
begin
  Result := Device.CheckHealthText;
end;

function TPosPrinterOA48.Get_Claimed: WordBool;
begin
  Result := FDevice.Claimed;
end;

function TPosPrinterOA48.Get_ControlObjectDescription: WideString;
begin
  Result := FControlObjectDescription;
end;

function TPosPrinterOA48.Get_ControlObjectVersion: Integer;
begin
  Result := FControlObjectVersion;
end;

function TPosPrinterOA48.Get_CoverOpen: WordBool;
begin
  Result := FCoverOpened;
end;

function TPosPrinterOA48.Get_DeviceDescription: WideString;
begin
  Result := FDeviceDescription;
end;

function TPosPrinterOA48.Get_DeviceEnabled: WordBool;
begin
  Result := FDevice.DeviceEnabled;
end;

function TPosPrinterOA48.Get_DeviceName: WideString;
begin
  Result := FDevice.DeviceName;
end;

function TPosPrinterOA48.Get_ErrorLevel: Integer;
begin
  Result := FErrorLevel;
end;

function TPosPrinterOA48.Get_ErrorStation: Integer;
begin
  Result := FErrorStation;
end;

function TPosPrinterOA48.Get_ErrorString: WideString;
begin
  Result := FDevice.ErrorString;
end;

function TPosPrinterOA48.Get_FlagWhenIdle: WordBool;
begin
  Result := FFlagWhenIdle;
end;

function TPosPrinterOA48.Get_FontTypefaceList: WideString;
begin
  Result := FFontTypefaceList;
end;

function TPosPrinterOA48.Get_FreezeEvents: WordBool;
begin
  Result := FDevice.FreezeEvents;
end;

function TPosPrinterOA48.Get_JrnCartridgeState: Integer;
begin
  Result := FJrnCartridgeState;
end;

function TPosPrinterOA48.Get_JrnCurrentCartridge: Integer;
begin
  Result := FJrnCurrentCartridge;
end;

function TPosPrinterOA48.Get_JrnEmpty: WordBool;
begin
  Result := FJrnEmpty;
end;

function TPosPrinterOA48.Get_JrnLetterQuality: WordBool;
begin
  Result := FJrnLetterQuality;
end;

function TPosPrinterOA48.Get_JrnLineChars: Integer;
begin
  Result := FJrnLineChars;
end;

function TPosPrinterOA48.Get_JrnLineCharsList: WideString;
begin
  Result := FJrnLineCharsList;
end;

function TPosPrinterOA48.Get_JrnLineHeight: Integer;
begin
  Result := FJrnLineHeight;
end;

function TPosPrinterOA48.Get_JrnLineSpacing: Integer;
begin
  Result := FJrnLineSpacing;
end;

function TPosPrinterOA48.Get_JrnLineWidth: Integer;
begin
  Result := FJrnLineWidth;
end;

function TPosPrinterOA48.Get_JrnNearEnd: WordBool;
begin
  Result := FJrnNearEnd;
end;

function TPosPrinterOA48.Get_MapCharacterSet: WordBool;
begin
  Result := FMapCharacterSet;
end;

function TPosPrinterOA48.Get_MapMode: Integer;
begin
  Result := FMapMode;
end;

function TPosPrinterOA48.Get_OpenResult: Integer;
begin
  Result := FDevice.OpenResult;
end;

function TPosPrinterOA48.Get_OutputID: Integer;
begin
  Result := FDevice.OutputID;
end;

function TPosPrinterOA48.Get_PageModeArea: WideString;
begin
  Result := FPageModeArea;
end;

function TPosPrinterOA48.Get_PageModeDescriptor: Integer;
begin
  Result := FPageModeDescriptor;
end;

function TPosPrinterOA48.Get_PageModeHorizontalPosition: Integer;
begin
  Result := FPageModeHorizontalPosition;
end;

function TPosPrinterOA48.Get_PageModePrintArea: WideString;
begin
  Result := FPageModePrintArea;
end;

function TPosPrinterOA48.Get_PageModePrintDirection: Integer;
begin
  Result := FPageModePrintDirection;
end;

function TPosPrinterOA48.Get_PageModeStation: Integer;
begin
  Result := FPageModeStation;
end;

function TPosPrinterOA48.Get_PageModeVerticalPosition: Integer;
begin
  Result := FPageModeVerticalPosition;
end;

function TPosPrinterOA48.Get_PowerNotify: Integer;
begin
  Result := FDevice.PowerNotify;
end;

function TPosPrinterOA48.Get_PowerState: Integer;
begin
  Result := FDevice.PowerState;
end;

function TPosPrinterOA48.Get_RecBarCodeRotationList: WideString;
begin
  Result := FRecBarCodeRotationList;
end;

function TPosPrinterOA48.Get_RecBitmapRotationList: WideString;
begin
  Result := FRecBitmapRotationList;
end;

function TPosPrinterOA48.Get_RecCartridgeState: Integer;
begin
  Result := FRecCartridgeState;
end;

function TPosPrinterOA48.Get_RecCurrentCartridge: Integer;
begin
  Result := FRecCurrentCartridge;
end;

function TPosPrinterOA48.Get_RecEmpty: WordBool;
begin
  Result := FRecEmpty;
end;

function TPosPrinterOA48.Get_RecLetterQuality: WordBool;
begin
  Result := FRecLetterQuality;
end;

function TPosPrinterOA48.Get_RecLineChars: Integer;
begin
  Result := FRecLineChars;
end;

function TPosPrinterOA48.Get_RecLineCharsList: WideString;
begin
  Result := FRecLineCharsList;
end;

function TPosPrinterOA48.Get_RecLineHeight: Integer;
begin
  Result := FRecLineHeight;
end;

function TPosPrinterOA48.Get_RecLineSpacing: Integer;
begin
  Result := FRecLineSpacing;
end;

function TPosPrinterOA48.Get_RecLinesToPaperCut: Integer;
const
  DistanceToCutterInDots = 128;
begin
  Result := (DistanceToCutterInDots div (RecLineSpacing + RecLineHeight + 10))-1;
end;

function TPosPrinterOA48.Get_RecLineWidth: Integer;
begin
  Result := FRecLineWidth;
end;

function TPosPrinterOA48.Get_RecNearEnd: WordBool;
begin
  Result := FRecNearEnd;
end;

function TPosPrinterOA48.Get_RecSidewaysMaxChars: Integer;
begin
  Result := FRecSidewaysMaxChars;
end;

function TPosPrinterOA48.Get_RecSidewaysMaxLines: Integer;
begin
  Result := FRecSidewaysMaxLines;
end;

function TPosPrinterOA48.Get_ResultCode: Integer;
begin
  Result := FDevice.ResultCode;
end;

function TPosPrinterOA48.Get_ResultCodeExtended: Integer;
begin
  Result := FDevice.ResultCodeExtended;
end;

function TPosPrinterOA48.Get_RotateSpecial: Integer;
begin
  Result := FRotateSpecial;
end;

function TPosPrinterOA48.Get_ServiceObjectDescription: WideString;
begin
  Result := FDevice.ServiceObjectDescription;
end;

function TPosPrinterOA48.Get_ServiceObjectVersion: Integer;
begin
  Result := FDevice.ServiceObjectVersion;
end;

function TPosPrinterOA48.Get_SlpBarCodeRotationList: WideString;
begin
  Result := FSlpBarCodeRotationList;
end;

function TPosPrinterOA48.Get_SlpBitmapRotationList: WideString;
begin
  Result := FSlpBitmapRotationList;
end;

function TPosPrinterOA48.Get_SlpCartridgeState: Integer;
begin
  Result := FSlpCartridgeState;
end;

function TPosPrinterOA48.Get_SlpCurrentCartridge: Integer;
begin
  Result := FSlpCurrentCartridge;
end;

function TPosPrinterOA48.Get_SlpEmpty: WordBool;
begin
  Result := FSlpEmpty;
end;

function TPosPrinterOA48.Get_SlpLetterQuality: WordBool;
begin
  Result := FSlpLetterQuality;
end;

function TPosPrinterOA48.Get_SlpLineChars: Integer;
begin
  Result := FSlpLineChars;
end;

function TPosPrinterOA48.Get_SlpLineCharsList: WideString;
begin
  Result := FSlpLineCharsList;
end;

function TPosPrinterOA48.Get_SlpLineHeight: Integer;
begin
  Result := FSlpLineHeight;
end;

function TPosPrinterOA48.Get_SlpLinesNearEndToEnd: Integer;
begin
  Result := FSlpLinesNearEndToEnd;
end;

function TPosPrinterOA48.Get_SlpLineSpacing: Integer;
begin
  Result := FSlpLineSpacing;
end;

function TPosPrinterOA48.Get_SlpLineWidth: Integer;
begin
  Result := FSlpLineWidth;
end;

function TPosPrinterOA48.Get_SlpMaxLines: Integer;
begin
  Result := FSlpMaxLines;
end;

function TPosPrinterOA48.Get_SlpNearEnd: WordBool;
begin
  Result := FSlpNearEnd;
end;

function TPosPrinterOA48.Get_SlpPrintSide: Integer;
begin
  Result := FSlpPrintSide;
end;

function TPosPrinterOA48.Get_SlpSidewaysMaxChars: Integer;
begin
  Result := FSlpSidewaysMaxChars;
end;

function TPosPrinterOA48.Get_SlpSidewaysMaxLines: Integer;
begin
  Result := FSlpSidewaysMaxLines;
end;

function TPosPrinterOA48.Get_State: Integer;
begin
  Result := FDevice.State;
end;

function TPosPrinterOA48.MarkFeed(Type_: Integer): Integer;
begin
  Result := ClearResult;
end;

function TPosPrinterOA48.Open(const DeviceName: WideString): Integer;
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

function TPosPrinterOA48.PageModePrint(Control: Integer): Integer;
begin
  Result := ClearResult;
end;

function TPosPrinterOA48.PrintBarCode(Station: Integer;
  const Data: WideString; Symbology, Height, Width, Alignment,
  TextPosition: Integer): Integer;
var
  QRCode: TQRCode;
  BarcodeType: Integer;
  Barcode: TPosBarcode;
  Justification: Integer;
begin
  try
    CheckRecStation(Station);

    if BarcodeInGraphics then
    begin
      Barcode.Data := Data;
      Barcode.Width := Width;
      Barcode.Height := Height;
      Barcode.Alignment := Alignment;
      Barcode.Symbology := Symbology;
      Barcode.TextPosition := TextPosition;
      PrintBarcodeAsGraphics(Barcode);
    end else
    begin
      FPrinter.SetBarcodeHeight(Height);
      FPrinter.SetBarcodeWidth(Width);
      // Alignment
      case Alignment of
        PTR_BC_LEFT: Justification := JUSTIFICATION_LEFT;
        PTR_BC_CENTER: Justification := JUSTIFICATION_CENTER;
        PTR_BC_RIGHT: Justification := JUSTIFICATION_RIGHT;
      else
        Justification := JUSTIFICATION_CENTER;
      end;

      // textPosition
      case TextPosition of
        PTR_BC_TEXT_NONE: FPrinter.SetHRIPosition(HRI_NOT_PRINTED);
        PTR_BC_TEXT_ABOVE: FPrinter.SetHRIPosition(HRI_ABOVE_BARCODE);
        PTR_BC_TEXT_BELOW: FPrinter.SetHRIPosition(HRI_BELOW_BARCODE);
      end;
      // Symbology
      if Is2DBarcode(Symbology) then
      begin
        if (Symbology = PTR_BCS_PDF417)or(Symbology = PTR_BCS_QRCODE) then
        begin
          FPrinter.PrintAndFeed(10);
          FPrinter.SetJustification(Justification);
        end;

        case Symbology of
          PTR_BCS_QRCODE:
          begin
            QRCode.ECLevel := OA48_QRCODE_ECL_30;
            QRCode.ModuleSize := 4;
            QRCode.Data := Data;
            FPrinter.printQRCode(QRCode);
          end;
          PTR_BCS_MAXICODE,
          PTR_BCS_DATAMATRIX,
          PTR_BCS_UQRCODE,
          PTR_BCS_AZTEC,
          PTR_BCS_UPDF417:
          begin
            Barcode.Data := Data;
            Barcode.Symbology := Symbology;
            Barcode.Height := Height;
            Barcode.Width := Width;
            Barcode.Alignment := Alignment;
            Barcode.TextPosition := TextPosition;
            PrintBarcodeAsGraphics(Barcode);
          end;
        else
          RaiseIllegalError('Symbology not supported');
        end;

        if (Symbology = PTR_BCS_PDF417)or(Symbology = PTR_BCS_QRCODE) then
        begin
          FPrinter.PrintAndFeed(10);
          FPrinter.SetJustification(JUSTIFICATION_LEFT);
        end;
      end else
      begin
        BarcodeType := BARCODE2_CODE128;
        case Symbology of
          PTR_BCS_UPCA: BarcodeType := BARCODE2_UPC_A;
          PTR_BCS_UPCE: BarcodeType := BARCODE2_UPC_E;
          PTR_BCS_EAN8: BarcodeType := BARCODE2_EAN8;
          PTR_BCS_EAN13: BarcodeType := BARCODE2_EAN13;
          PTR_BCS_ITF: BarcodeType := BARCODE2_ITF;
          PTR_BCS_Codabar: BarcodeType := BARCODE2_CODABAR;
          PTR_BCS_Code39: BarcodeType := BARCODE2_CODE39;
          PTR_BCS_Code93: BarcodeType := BARCODE2_CODE93;
          PTR_BCS_Code128: BarcodeType := BARCODE2_CODE128;
        end;

        case Symbology of
          PTR_BCS_UPCA,
          PTR_BCS_UPCE,
          PTR_BCS_EAN8,
          PTR_BCS_EAN13,
          PTR_BCS_ITF,
          PTR_BCS_Codabar,
          PTR_BCS_Code39,
          PTR_BCS_Code93,
          PTR_BCS_Code128:
          begin
            FPrinter.PrintBarcode2(BarcodeType, Data);
          end;
          PTR_BCS_TF,
          PTR_BCS_UPCA_S,
          PTR_BCS_UPCE_S,
          PTR_BCS_UPCD1,
          PTR_BCS_UPCD2,
          PTR_BCS_UPCD3,
          PTR_BCS_UPCD4,
          PTR_BCS_UPCD5,
          PTR_BCS_EAN8_S,
          PTR_BCS_EAN13_S,
          PTR_BCS_EAN128,
          PTR_BCS_OCRA,
          PTR_BCS_OCRB,
          PTR_BCS_Code128_Parsed,
          PTR_BCS_RSS14,
          PTR_BCS_RSS_EXPANDED:
          begin
            Barcode.Data := Data;
            Barcode.Symbology := Symbology;
            Barcode.Height := Height;
            Barcode.Width := Width;
            Barcode.Alignment := Alignment;
            Barcode.TextPosition := TextPosition;
            PrintBarcodeAsGraphics(Barcode);
          end;
        else
          RaiseIllegalError('Symbology not supported');
        end;
      end;
    end;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

procedure TPosPrinterOA48.PrintBarcodeAsGraphics(var Barcode: TPosBarcode);
var
  Data: AnsiString;
begin
  if not CapRecBitmap then
    RaiseIllegalError('Bitmaps are not supported');

  Data := RenderBarcodeRec(Barcode);
  PrintMemoryGraphic(Data, PTR_BMT_BMP, Barcode.Width, Barcode.Alignment);
end;

function TPosPrinterOA48.PrintBitmap(Station: Integer;
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

function TPosPrinterOA48.PrintImmediate(Station: Integer;
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

procedure TPosPrinterOA48.PrintGraphics(Graphic: TGraphic; Width, Alignment: Integer);
var
  Scale: Integer;
  BMPMode: Integer;
  Justification: Integer;
begin
  BMPMode := BMP_MODE_NORMAL;
  if Width <> PTR_BM_ASIS then
  begin
    Scale := Round(Width / Graphic.Width);
    if Scale >= 2 then
    begin
      BMPMode := BMP_MODE_QUADRUPLE;
      Scale := Scale div 2;
      if Scale > 1 then
      begin
        ScaleGraphic(Graphic, Scale);
      end;
    end;
  end;

  case Alignment of
    PTR_BM_LEFT: Justification := JUSTIFICATION_LEFT;
    PTR_BM_CENTER: Justification := JUSTIFICATION_CENTER;
    PTR_BM_RIGHT: Justification := JUSTIFICATION_RIGHT;
  else
    Justification := JUSTIFICATION_LEFT;
  end;
  FPrinter.PrintAndFeed(10);
  FPrinter.SetJustification(Justification);
  if PrintRasterGraphics then
  begin
    FPrinter.PrintRasterBMP(BMPMode, Graphic);
  end else
  begin
    FPrinter.DownloadBMP(Graphic);
    FPrinter.PrintBmp(BMPMode);
  end;
  FPrinter.SetJustification(JUSTIFICATION_LEFT);
  FPrinter.PrintAndFeed(10);
end;

function TPosPrinterOA48.PrintMemoryBitmap(Station: Integer;
  const Data: WideString; Type_, Width, Alignment: Integer): Integer;
begin
  try
    CheckRecStation(Station);
    PrintMemoryGraphic(Data, Type_, Width, Alignment);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

procedure TPosPrinterOA48.CheckRecStation(Station: Integer);
begin
  if Station <> PTR_S_RECEIPT then
    raiseIllegalError('Station not supported');
end;

function TPosPrinterOA48.PrintNormal(Station: Integer;
  const Data: WideString): Integer;
begin
  try
    CheckEnabled;
    CheckRecStation(Station);
    CheckPaperPresent;
    PrintText(Data);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TPosPrinterOA48.PrintTwoNormal(Stations: Integer; const Data1,
  Data2: WideString): Integer;
begin
  Result := ClearResult;
end;

function TPosPrinterOA48.ReleaseDevice: Integer;
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

function TPosPrinterOA48.ResetStatistics(
  const StatisticsBuffer: WideString): Integer;
begin
  Result := ClearResult;
end;

function TPosPrinterOA48.RetrieveStatistics(
  var pStatisticsBuffer: WideString): Integer;
begin
  Result := ClearResult;
end;

function TPosPrinterOA48.RotatePrint(Station, Rotation: Integer): Integer;
begin
  Result := ClearResult;
end;

procedure TPosPrinterOA48.Set_AsyncMode(pAsyncMode: WordBool);
begin
  FAsyncMode := pAsyncMode;
end;

procedure TPosPrinterOA48.Set_BinaryConversion(pBinaryConversion: Integer);
begin
  FDevice.BinaryConversion := pBinaryConversion;
end;

procedure TPosPrinterOA48.Set_CartridgeNotify(pCartridgeNotify: Integer);
begin
  FCartridgeNotify := pCartridgeNotify;
end;

function TPosPrinterOA48.CharSetToPrinterCP(CharacterSet: Integer): Integer;
begin
  case CharacterSet of
    PTR_CS_ASCII,
    PTR_CS_UNICODE,
    PTR_CS_WINDOWS:
      Result := TextCPToPrinterCP(FPrinterCodePage);
  else
    Result := TextCPToPrinterCP(CharacterSet);
  end;
end;

procedure TPosPrinterOA48.Set_CharacterSet(pCharacterSet: Integer);
var
  CodePage: Integer;
begin
  if IsValidCharacterSet(pCharacterSet) then
  begin
    FCharacterSet := pCharacterSet;

    CodePage := CharSetToPrinterCP(CharacterSet);
    FPrinter.SetCodePage(CodePage);
  end;
end;

procedure TPosPrinterOA48.StartDeviceThread;
begin
  if FThread = nil then
  begin
    FThread := TNotifyThread.Create(True);
    FThread.OnExecute := DeviceProc;
    FThread.Resume;
  end;
end;

procedure TPosPrinterOA48.StopDeviceThread;
begin
  if FThread <> nil then
  begin
    FThread.Terminate;
    FThread.Free;
    FThread := nil;
  end;
end;

procedure TPosPrinterOA48.Set_DeviceEnabled(pDeviceEnabled: WordBool);
begin
  try
    if pDeviceEnabled <> FDevice.DeviceEnabled then
    begin
      if pDeviceEnabled then
      begin
        FPort.Open;
        InitializeDevice;
        UpdatePrinterStatus;
      end else
      begin
        StopDeviceThread;
        FPort.Close;
      end;
      FDevice.DeviceEnabled := pDeviceEnabled;
    end;
  except
    on E: Exception do
      HandleException(E);
  end;
end;

procedure TPosPrinterOA48.SetCoverState(CoverOpened: Boolean);
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

procedure TPosPrinterOA48.SetRecEmpty(ARecEmpty: Boolean);
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

procedure TPosPrinterOA48.SetRecNearEnd(ARecNearEnd: Boolean);
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

procedure TPosPrinterOA48.CheckPaperPresent;
begin
  if not FCapRecPresent then Exit;
  if not FCapRecEmptySensor then Exit;
  if not FPrinter.CapRead then Exit;

  FDevice.CheckOnline;
  SetRecEmpty(not FPrinter.ReadPaperStatus.PaperPresent);

  if FRecEmpty then
    RaiseExtendedError(OPOS_EPTR_REC_EMPTY, 'Receipt station is empty');
end;

procedure TPosPrinterOA48.CheckCoverClosed;
begin
  if not FCapCoverSensor then Exit;
  if not FPrinter.CapRead then Exit;

  FDevice.CheckOnline;
  SetCoverState(FPrinter.ReadOfflineStatus.CoverOpened);
  if FCoverOpened then
    RaiseExtendedError(OPOS_EPTR_COVER_OPEN, 'Cover is opened');
end;

procedure TPosPrinterOA48.UpdatePrinterStatus;
var
  ErrorStatus: TErrorStatus;
  OfflineStatus: TOfflineStatus;
begin
  if not FPrinter.CapRead then Exit;

  try
    OfflineStatus := FPrinter.ReadOfflineStatus;
    SetCoverState(OfflineStatus.CoverOpened);
    SetRecEmpty(not FPrinter.ReadPaperStatus.PaperPresent);
    SetRecNearEnd(FPrinter.ReadPaperRollStatus.PaperNearEnd);
    ErrorStatus := FPrinter.ReadErrorStatus;
    SetPowerState(OPOS_PS_ONLINE);
  except
    on E: Exception do
    begin
      SetPowerState(OPOS_PS_OFF_OFFLINE);
      raise;
    end;
  end;
end;

procedure TPosPrinterOA48.SetPowerState(PowerState: Integer);
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

procedure TPosPrinterOA48.InitializeDevice;
begin
  FPrinter.Initialize;
  FPrinter.CancelKanjiCharacter;
  if Utf8Enabled then
  begin
    FPrinter.UTF8Enable(True);
    FPrinter.SelectCodePage(CODEPAGE_WCP1251);
  end else
  begin
    FPrinter.UTF8Enable(False);
    FPrinter.WriteKazakhCharacters;
    FPrinter.DisableUserCharacters;
    FPrinter.SelectCodePage(CODEPAGE_CP866);
  end;
  FPrinter.SetCharacterFont(FONT_TYPE_A);
  if FontName = FontNameB then
  begin
    FLastPrintMode := [pmFontB];
    FPrinter.SetCharacterFont(FONT_TYPE_B);
  end;
end;

procedure TPosPrinterOA48.DeviceProc(Sender: TObject);
var
  TickCount: DWORD;
begin
  try
    while not FThread.Terminated do
    begin
      try
        UpdatePrinterStatus;
      except
        on E: Exception do
        begin
          FLogger.Error(E.Message);
        end;
      end;
      // wait
      TickCount := GetTickCount;
      repeat
        if FThread.Terminated then Break;
        Sleep(20);
      until (GetTickCount-TickCount) > DWORD(DevicePollTime);
    end;
  except
    on E: Exception do
    begin
      Logger.Error(E.Message);
    end;
  end;
end;

procedure TPosPrinterOA48.Set_FlagWhenIdle(pFlagWhenIdle: WordBool);
begin
  FFlagWhenIdle := pFlagWhenIdle;
end;

procedure TPosPrinterOA48.Set_FreezeEvents(pFreezeEvents: WordBool);
begin
  FDevice.FreezeEvents := pFreezeEvents;
end;

procedure TPosPrinterOA48.Set_JrnCurrentCartridge(
  pJrnCurrentCartridge: Integer);
begin
  FJrnCurrentCartridge := pJrnCurrentCartridge;
end;

procedure TPosPrinterOA48.Set_JrnLetterQuality(pJrnLetterQuality: WordBool);
begin
  FJrnLetterQuality := pJrnLetterQuality;
end;

procedure TPosPrinterOA48.Set_JrnLineChars(pJrnLineChars: Integer);
begin
  FJrnLineChars := pJrnLineChars;
end;

procedure TPosPrinterOA48.Set_JrnLineHeight(pJrnLineHeight: Integer);
begin
  FJrnLineHeight := pJrnLineHeight;
end;

procedure TPosPrinterOA48.Set_JrnLineSpacing(pJrnLineSpacing: Integer);
begin
  FJrnLineSpacing := pJrnLineSpacing;
end;

procedure TPosPrinterOA48.Set_MapCharacterSet(pMapCharacterSet: WordBool);
begin
  FMapCharacterSet := pMapCharacterSet;
end;

procedure TPosPrinterOA48.Set_MapMode(pMapMode: Integer);
begin
  FMapMode := pMapMode;
end;

procedure TPosPrinterOA48.Set_PageModeHorizontalPosition(
  pPageModeHorizontalPosition: Integer);
begin
  FPageModeHorizontalPosition := pPageModeHorizontalPosition;
end;

procedure TPosPrinterOA48.Set_PageModePrintArea(
  const pPageModePrintArea: WideString);
begin
  FPageModePrintArea := pPageModePrintArea;
end;

procedure TPosPrinterOA48.Set_PageModePrintDirection(
  pPageModePrintDirection: Integer);
begin
  FPageModePrintDirection := pPageModePrintDirection;
end;

procedure TPosPrinterOA48.Set_PageModeStation(pPageModeStation: Integer);
begin
  FPageModeStation := pPageModeStation;
end;

procedure TPosPrinterOA48.Set_PageModeVerticalPosition(
  pPageModeVerticalPosition: Integer);
begin
  FPageModeVerticalPosition := pPageModeVerticalPosition;
end;

procedure TPosPrinterOA48.Set_PowerNotify(pPowerNotify: Integer);
begin
  FDevice.PowerNotify := pPowerNotify;
end;

procedure TPosPrinterOA48.Set_RecCurrentCartridge(
  pRecCurrentCartridge: Integer);
begin
  FRecCurrentCartridge := pRecCurrentCartridge;
end;

procedure TPosPrinterOA48.Set_RecLetterQuality(pRecLetterQuality: WordBool);
begin
  FRecLetterQuality := pRecLetterQuality;
end;

procedure TPosPrinterOA48.Set_RecLineChars(pRecLineChars: Integer);
begin
  FRecLineChars := pRecLineChars;
end;

procedure TPosPrinterOA48.Set_RecLineHeight(pRecLineHeight: Integer);
begin
  if (pRecLineHeight >= 24) then
  begin
    FRecLineHeight := 24
  end else
  begin
    FRecLineHeight := 17;
  end;
end;

procedure TPosPrinterOA48.Set_RecLineSpacing(pRecLineSpacing: Integer);
begin
  if pRecLineSpacing <> FRecLineSpacing then
  begin
    if (pRecLineSpacing >= 0)and(pRecLineSpacing <= $FF) then
    begin
      FPrinter.SetLineSpacing(pRecLineSpacing);
    end;
    FRecLineSpacing := pRecLineSpacing;
  end;
end;

procedure TPosPrinterOA48.Set_RotateSpecial(pRotateSpecial: Integer);
begin
  FRotateSpecial := pRotateSpecial;
end;

procedure TPosPrinterOA48.Set_SlpCurrentCartridge(
  pSlpCurrentCartridge: Integer);
begin
  FSlpCurrentCartridge := pSlpCurrentCartridge;
end;

procedure TPosPrinterOA48.Set_SlpLetterQuality(pSlpLetterQuality: WordBool);
begin
  FSlpLetterQuality := pSlpLetterQuality;
end;

procedure TPosPrinterOA48.Set_SlpLineChars(pSlpLineChars: Integer);
begin
  FSlpLineChars := pSlpLineChars;
end;

procedure TPosPrinterOA48.Set_SlpLineHeight(pSlpLineHeight: Integer);
begin
  FSlpLineHeight := pSlpLineHeight;
end;

procedure TPosPrinterOA48.Set_SlpLineSpacing(pSlpLineSpacing: Integer);
begin
  FSlpLineSpacing := pSlpLineSpacing;
end;

function TPosPrinterOA48.SetBitmap(BitmapNumber, Station: Integer;
  const FileName: WideString; Width, Alignment: Integer): Integer;
begin

  Result := ClearResult;
end;

function TPosPrinterOA48.SetLogo(Location: Integer;
  const Data: WideString): Integer;
begin
  Result := ClearResult;
end;

function TPosPrinterOA48.TransactionPrint(Station,
  Control: Integer): Integer;
begin
  try
    if Control = PTR_TP_TRANSACTION then
    begin
      StopDeviceThread;
      FPrinter.BeginDocument;
      //InitializeDevice; !!!
    end;
    if Control = PTR_TP_NORMAL then
    begin
      FPrinter.EndDocument;
      StartDeviceThread;
    end;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TPosPrinterOA48.UpdateFirmware(
  const FirmwareFileName: WideString): Integer;
begin
  Result := ClearResult;
end;

function TPosPrinterOA48.UpdateStatistics(
  const StatisticsBuffer: WideString): Integer;
begin
  Result := ClearResult;
end;

function TPosPrinterOA48.ValidateData(Station: Integer;
  const Data: WideString): Integer;
begin
  Result := ClearResult;
end;

procedure TPosPrinterOA48.DataEvent(Sender: TObject; Status: Integer);
begin

end;

procedure TPosPrinterOA48.DirectIOEvent(Sender: TObject; EventNumber: Integer;
  var pData: Integer; var pString: WideString);
begin
  if Assigned(FOnDirectIOEvent) then
    FOnDirectIOEvent(Self, EventNumber, pData, pString);
end;

procedure TPosPrinterOA48.ErrorEvent(Sender: TObject; ResultCode, ResultCodeExtended,
  ErrorLocus: Integer; var pErrorResponse: Integer);
begin
  if Assigned(FOnErrorEvent) then
    FOnErrorEvent(Self, ResultCode, ResultCodeExtended, ErrorLocus, pErrorResponse);
end;

procedure TPosPrinterOA48.OutputCompleteEvent(Sender: TObject; OutputID: Integer);
begin
  if Assigned(FOnOutputCompleteEvent) then
    FOnOutputCompleteEvent(Self, OutputID);
end;

procedure TPosPrinterOA48.StatusUpdateEvent(Sender: TObject; Data: Integer);
begin
  if Assigned(FOnStatusUpdateEvent) then
    FOnStatusUpdateEvent(Self, Data);
end;

procedure TPosPrinterOA48.SODataDummy(Status: Integer);
begin

end;

procedure TPosPrinterOA48.SODirectIO(EventNumber: Integer;
  var pData: Integer; var pString: WideString);
begin

end;

procedure TPosPrinterOA48.SOError(ResultCode, ResultCodeExtended,
  ErrorLocus: Integer; var pErrorResponse: Integer);
begin

end;

procedure TPosPrinterOA48.SOOutputComplete(OutputID: Integer);
begin

end;

function TPosPrinterOA48.SOProcessID: Integer;
begin

end;

procedure TPosPrinterOA48.SOStatusUpdate(Data: Integer);
begin

end;

procedure TPosPrinterOA48.PrintText(Text: WideString);
var
  Mode: TPrintMode;
  Token: TEscToken;
  PrintMode: TPrinterModes;
begin
  PrintMode := [];
  if FontName = FontNameB then
  begin
    PrintMode := [pmFontB];
  end;

  //Text := ReplaceRegExpr('\' + ESC + '\|[0-9]{0,3}\P', Text, #$1B#$69);
  while GetToken(Text, Token) do
  begin
    if Token.IsEsc then
    begin
      // Normal Restores printer characteristics to normal condition.
      if Token.Text = ESC + '|N' then
        FPrinter.Initialize;
      // Font
      if Token.Text = ESC + '|0fT' then
        PrintMode := PrintMode - [pmFontB];
      if Token.Text = ESC + '|1fT' then
        PrintMode := PrintMode - [pmFontB];
      if Token.Text = ESC + '|2fT' then
        PrintMode := PrintMode + [pmFontB];

      // Bold
      if Token.Text = ESC_Bold then
        PrintMode := PrintMode + [pmBold];
      if Token.Text = ESC + '|!bC' then
        PrintMode := PrintMode - [pmBold];

      // Underline
      if Token.Text = ESC + '|uC' then
        PrintMode := PrintMode + [pmUnderlined];
      if Token.Text = ESC + '|!uC' then
        PrintMode := PrintMode - [pmUnderlined];

      if Token.Text = ESC + '|1C' then
        PrintMode := [];
      if Token.Text = ESC + '|2C' then
        PrintMode := PrintMode + [pmDoubleWide];
      if Token.Text = ESC + '|3C' then
        PrintMode := PrintMode + [pmDoubleHigh];
      if Token.Text = ESC + '|4C' then
        PrintMode := PrintMode + [pmDoubleWide, pmDoubleHigh];

    end else
    begin
      // Select print mode is needed
      if PrintMode <> FLastPrintMode then
      begin
        Mode.CharacterFontB := pmFontB in PrintMode;
        Mode.Emphasized := pmBold in PrintMode;
        Mode.DoubleHeight := pmDoubleHigh in PrintMode;
        Mode.DoubleWidth := pmDoubleWide in PrintMode;
        Mode.Underlined := pmUnderlined in PrintMode;
        FPrinter.SelectPrintMode(Mode);
        FLastPrintMode := PrintMode;
      end;
      PrintWideString(Token.Text);
    end;
  end;
end;

procedure TPosPrinterOA48.PrintWideString(const AText: WideString);
var
  CodePage: Integer;
begin
  if Utf8Enabled then
  begin
    FPrinter.PrintText(UTF8Encode(AText));
  end else
  begin
    case CharacterSet of
      PTR_CS_UNICODE,
      PTR_CS_WINDOWS: FPrinter.PrintUnicode(AText);
    else
      CodePage := CharacterSetToCodePage(CharacterSet);
      FPrinter.PrintText(WideStringToAnsiString(CodePage, AText));
    end;
  end;
end;

end.

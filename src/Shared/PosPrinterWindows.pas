unit PosPrinterWindows;

interface

uses
  // VCL
  Windows, Classes, SysUtils, Graphics, Printers, Jpeg, GifImage,
  // Tnt
  TntClasses,
  // JVCL
  JvUnicodeCanvas,
  // Opos
  Opos, OposEsc, OposPtr, OposException, OposServiceDevice19,
  OposPOSPrinter_CCO_TLB, WException, OposPtrUtils, OposUtils,
  // This
  LogFile, DriverError, CustomPrinter, EscPrinterUtils, BarcodeUtils, ComUtils,
  PrinterTypes;

type
  { TPosPrinterWindows }

  TPosPrinterWindows = class(TDispIntfObject, IOPOSPOSPrinter)
  private
    function GetPrinter: TCustomPrinter;
    procedure PrintBarcodeAsGraphics(var Barcode: TPosBarcode);
    procedure PrintMemoryGraphic(const Data: WideString; BMPType, Width,
      Alignment: Integer);
    procedure PrintText2(const Text: WideString);
    function GetCanvas: TCanvas;
    procedure FeedLines(N: Integer);
    procedure FeedUnits(N: Integer);
    function GetFontHeight: Integer;
    function AlignText(const Text: WideString;
      Alignment: Integer): WideString;
    procedure PrinterBeginDoc;
    procedure PrinterEndDoc;
  private
    FLogger: ILogFile;
    FPageModeBitmap: TBitmap;
    FAlignment: Integer;
    FVerticalScale: Integer;
    FHorizontalScale: Integer;
    FPrinter: TCustomPrinter;
    FDevice: TOposServiceDevice19;
    FVerticalPosition: Integer;
    FHorizontalPosition: Integer;
    FTransaction: Boolean;
    FPageMode: TPageMode;
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
    FPageModeArea: TPoint;
    FPageModeDescriptor: Integer;
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
    procedure PrintText(Text: WideString);
    procedure PrintGraphics(Graphic: TGraphic; Width, Alignment: Integer);

    property Printer: TCustomPrinter read GetPrinter;
  public
    constructor Create(ALogger: ILogFile; APrinter: TCustomPrinter);
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
    PrinterName: WideString;
    TopLogoFile: WideString;
    BottomLogoFile: WideString;
    BitmapFiles: TBitmapFiles;
    FontName: WideString;
  end;

const
  LineSpacing = 6;
  NormalFontSize = 8;
  DoubleFontSize = 16;
  DefaultFontName = 'Lucida Console';

implementation

constructor TPosPrinterWindows.Create(ALogger: ILogFile; APrinter: TCustomPrinter);
begin
  inherited Create;
  FLogger := ALogger;
  FPageModeBitmap := TBitmap.Create;
  FDevice := TOposServiceDevice19.Create(FLogger);
  FDevice.ErrorEventEnabled := False;
  FPrinter := APrinter;
  FPageMode.IsActive := False;

  Initialize;
end;

destructor TPosPrinterWindows.Destroy;
begin
  FDevice.Free;
  FPrinter.Free;
  FPageModeBitmap.Free;
  inherited Destroy;
end;

procedure TPosPrinterWindows.PrinterBeginDoc;
begin
  if not Printer.Printing then
  begin
    Printer.BeginDoc;
    Printer.Canvas.Font.Name := FontName;
    Printer.Canvas.Font.Size := NormalFontSize;
    Printer.Canvas.Font.Style := [];
  end;
end;

procedure TPosPrinterWindows.PrinterEndDoc;
begin
  if Printer.Printing then
  begin
    Printer.EndDoc(FVerticalPosition);
  end;
end;

function TPosPrinterWindows.GetCanvas: TCanvas;
begin
  if FPageMode.IsActive then
  begin
    Result := FPageModeBitmap.Canvas;
  end else
  begin
    Result := FPrinter.Canvas;
  end;
end;

function TPosPrinterWindows.GetPrinter: TCustomPrinter;
begin
  if FPrinter = nil then
    FPrinter := TWinPrinter.Create;
  Result := FPrinter;
end;

procedure TPosPrinterWindows.Initialize;
const
  DefPageModeArea: TPoint = (X: 512; Y: 832);
  DefPageModePrintArea: TPageArea = (X: 0; Y: 0; Width: 0; Height: 0);
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
  FCapPowerReporting := OPOS_PR_NONE;
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
  FPageModeArea := DefPageModeArea;
  FPageModeDescriptor := PTR_PM_BARCODE + PTR_PM_BC_ROTATE;
  FPageMode.HorizontalPosition := 0;
  FPageMode.VerticalPosition := 0;
  FPageMode.PrintArea := DefPageModePrintArea;
  FPageMode.PrintDirection := 0;
  FPageMode.Station := PTR_S_RECEIPT;

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
  FRecLinesToPaperCut := 5;
  FRecLineWidth := 576;
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
  FAlignment := ALIGN_LEFT;

  FontName := DefaultFontName;
end;

function TPosPrinterWindows.ClearResult: Integer;
begin
  Result := FDevice.ClearResult;
end;

procedure TPosPrinterWindows.CheckEnabled;
begin
  FDevice.CheckEnabled;
end;

function TPosPrinterWindows.IllegalError: Integer;
begin
  Result := FDevice.SetResultCode(OPOS_E_ILLEGAL);
end;

function TPosPrinterWindows.HandleException(E: Exception): Integer;
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

function TPosPrinterWindows.BeginInsertion(Timeout: Integer): Integer;
begin
  Result := ClearResult;
end;

function TPosPrinterWindows.BeginRemoval(Timeout: Integer): Integer;
begin
  Result := ClearResult;
end;

function TPosPrinterWindows.ChangePrintSide(Side: Integer): Integer;
begin
  Result := ClearResult;
end;

function TPosPrinterWindows.CheckHealth(Level: Integer): Integer;
begin
  Result := ClearResult;
end;

function TPosPrinterWindows.ClaimDevice(Timeout: Integer): Integer;
begin
  try
    FDevice.ClaimDevice(Timeout);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TPosPrinterWindows.ClearOutput: Integer;
begin
  try
    FDevice.CheckClaimed;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TPosPrinterWindows.ClearPrintArea: Integer;
begin
  Result := ClearResult;
end;

function TPosPrinterWindows.Close: Integer;
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

function TPosPrinterWindows.CompareFirmwareVersion(
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

function TPosPrinterWindows.CutPaper(Percentage: Integer): Integer;
begin
  Result := ClearResult;
end;

function TPosPrinterWindows.DirectIO(Command: Integer; var pData: Integer;
  var pString: WideString): Integer;
begin
  Result := ClearResult;
end;

function TPosPrinterWindows.DrawRuledLine(Station: Integer;
  const PositionList: WideString; LineDirection, LineWidth, LineStyle,
  LineColor: Integer): Integer;
begin
  Result := ClearResult;
end;

function TPosPrinterWindows.EndInsertion: Integer;
begin
  Result := ClearResult;
end;

function TPosPrinterWindows.EndRemoval: Integer;
begin
  Result := ClearResult;
end;

function TPosPrinterWindows.Get_AsyncMode: WordBool;
begin
  Result := FAsyncMode;
end;

function TPosPrinterWindows.Get_BinaryConversion: Integer;
begin
  Result := FDevice.BinaryConversion;
end;

function TPosPrinterWindows.Get_CapCharacterSet: Integer;
begin
  Result := FCapCharacterSet;
end;

function TPosPrinterWindows.Get_CapCompareFirmwareVersion: WordBool;
begin
  Result := FCapCompareFirmwareVersion;
end;

function TPosPrinterWindows.Get_CapConcurrentJrnRec: WordBool;
begin
  Result := FCapConcurrentJrnRec;
end;

function TPosPrinterWindows.Get_CapConcurrentJrnSlp: WordBool;
begin
  Result := FCapConcurrentJrnSlp;
end;

function TPosPrinterWindows.Get_CapConcurrentPageMode: WordBool;
begin
  Result := FCapConcurrentPageMode;
end;

function TPosPrinterWindows.Get_CapConcurrentRecSlp: WordBool;
begin
  Result := FCapConcurrentRecSlp;
end;

function TPosPrinterWindows.Get_CapCoverSensor: WordBool;
begin
  Result := FCapCoverSensor;
end;

function TPosPrinterWindows.Get_CapJrn2Color: WordBool;
begin
  Result := FCapJrn2Color;
end;

function TPosPrinterWindows.Get_CapJrnBold: WordBool;
begin
  Result := FCapJrnBold;
end;

function TPosPrinterWindows.Get_CapJrnCartridgeSensor: Integer;
begin
  Result := FCapJrnCartridgeSensor;
end;

function TPosPrinterWindows.Get_CapJrnColor: Integer;
begin
  Result := FCapJrnColor;
end;

function TPosPrinterWindows.Get_CapJrnDhigh: WordBool;
begin
  Result := FCapJrnDhigh;
end;

function TPosPrinterWindows.Get_CapJrnDwide: WordBool;
begin
  Result := FCapJrnDwide;
end;

function TPosPrinterWindows.Get_CapJrnDwideDhigh: WordBool;
begin
  Result := FCapJrnDwideDhigh;
end;

function TPosPrinterWindows.Get_CapJrnEmptySensor: WordBool;
begin
  Result := FCapJrnEmptySensor;
end;

function TPosPrinterWindows.Get_CapJrnItalic: WordBool;
begin
  Result := FCapJrnItalic;
end;

function TPosPrinterWindows.Get_CapJrnNearEndSensor: WordBool;
begin
  Result := FCapJrnNearEndSensor;
end;

function TPosPrinterWindows.Get_CapJrnPresent: WordBool;
begin
  Result := FCapJrnPresent;
end;

function TPosPrinterWindows.Get_CapJrnUnderline: WordBool;
begin
  Result := FCapJrnUnderline;
end;

function TPosPrinterWindows.Get_CapMapCharacterSet: WordBool;
begin
  Result := FCapMapCharacterSet;
end;

function TPosPrinterWindows.Get_CapPowerReporting: Integer;
begin
  Result := FCapPowerReporting;
end;

function TPosPrinterWindows.Get_CapRec2Color: WordBool;
begin
  Result := FCapRec2Color;
end;

function TPosPrinterWindows.Get_CapRecBarCode: WordBool;
begin
  Result := FCapRecBarCode;
end;

function TPosPrinterWindows.Get_CapRecBitmap: WordBool;
begin
  Result := FCapRecBitmap;
end;

function TPosPrinterWindows.Get_CapRecBold: WordBool;
begin
  Result := FCapRecBold;
end;

function TPosPrinterWindows.Get_CapRecCartridgeSensor: Integer;
begin
  Result := FCapRecCartridgeSensor;
end;

function TPosPrinterWindows.Get_CapRecColor: Integer;
begin
  Result := FCapRecColor;
end;

function TPosPrinterWindows.Get_CapRecDhigh: WordBool;
begin
  Result := FCapRecDhigh;
end;

function TPosPrinterWindows.Get_CapRecDwide: WordBool;
begin
  Result := FCapRecDwide;
end;

function TPosPrinterWindows.Get_CapRecDwideDhigh: WordBool;
begin
  Result := FCapRecDwideDhigh;
end;

function TPosPrinterWindows.Get_CapRecEmptySensor: WordBool;
begin
  Result := FCapRecEmptySensor;
end;

function TPosPrinterWindows.Get_CapRecItalic: WordBool;
begin
  Result := FCapRecItalic;
end;

function TPosPrinterWindows.Get_CapRecLeft90: WordBool;
begin
  Result := FCapRecLeft90;
end;

function TPosPrinterWindows.Get_CapRecMarkFeed: Integer;
begin
  Result := FCapRecMarkFeed;
end;

function TPosPrinterWindows.Get_CapRecNearEndSensor: WordBool;
begin
  Result := FCapRecNearEndSensor;
end;

function TPosPrinterWindows.Get_CapRecPageMode: WordBool;
begin
  Result := FCapRecPageMode;
end;

function TPosPrinterWindows.Get_CapRecPapercut: WordBool;
begin
  Result := FCapRecPapercut;
end;

function TPosPrinterWindows.Get_CapRecPresent: WordBool;
begin
  Result := FCapRecPresent;
end;

function TPosPrinterWindows.Get_CapRecRight90: WordBool;
begin
  Result := FCapRecRight90;
end;

function TPosPrinterWindows.Get_CapRecRotate180: WordBool;
begin
  Result := FCapRecRotate180;
end;

function TPosPrinterWindows.Get_CapRecRuledLine: Integer;
begin
  Result := FCapRecRuledLine;
end;

function TPosPrinterWindows.Get_CapRecStamp: WordBool;
begin
  Result := FCapRecStamp;
end;

function TPosPrinterWindows.Get_CapRecUnderline: WordBool;
begin
  Result := FCapRecUnderline;
end;

function TPosPrinterWindows.Get_CapSlp2Color: WordBool;
begin
  Result := FCapSlp2Color;
end;

function TPosPrinterWindows.Get_CapSlpBarCode: WordBool;
begin
  Result := FCapSlpBarCode;
end;

function TPosPrinterWindows.Get_CapSlpBitmap: WordBool;
begin
  Result := FCapSlpBitmap;
end;

function TPosPrinterWindows.Get_CapSlpBold: WordBool;
begin
  Result := FCapSlpBold;
end;

function TPosPrinterWindows.Get_CapSlpBothSidesPrint: WordBool;
begin
  Result := FCapSlpBothSidesPrint;
end;

function TPosPrinterWindows.Get_CapSlpCartridgeSensor: Integer;
begin
  Result := FCapSlpCartridgeSensor;
end;

function TPosPrinterWindows.Get_CapSlpColor: Integer;
begin
  Result := FCapSlpColor;
end;

function TPosPrinterWindows.Get_CapSlpDhigh: WordBool;
begin
  Result := FCapSlpDhigh;
end;

function TPosPrinterWindows.Get_CapSlpDwide: WordBool;
begin
  Result := FCapSlpDwide;
end;

function TPosPrinterWindows.Get_CapSlpDwideDhigh: WordBool;
begin
  Result := FCapSlpDwideDhigh;
end;

function TPosPrinterWindows.Get_CapSlpEmptySensor: WordBool;
begin
  Result := FCapSlpEmptySensor;
end;

function TPosPrinterWindows.Get_CapSlpFullslip: WordBool;
begin
  Result := FCapSlpFullslip;
end;

function TPosPrinterWindows.Get_CapSlpItalic: WordBool;
begin
  Result := FCapSlpItalic;
end;

function TPosPrinterWindows.Get_CapSlpLeft90: WordBool;
begin
  Result := FCapSlpLeft90;
end;

function TPosPrinterWindows.Get_CapSlpNearEndSensor: WordBool;
begin
  Result := FCapSlpNearEndSensor;
end;

function TPosPrinterWindows.Get_CapSlpPageMode: WordBool;
begin
  Result := FCapSlpPageMode;
end;

function TPosPrinterWindows.Get_CapSlpPresent: WordBool;
begin
  Result := FCapSlpPresent;
end;

function TPosPrinterWindows.Get_CapSlpRight90: WordBool;
begin
  Result := FCapSlpRight90;
end;

function TPosPrinterWindows.Get_CapSlpRotate180: WordBool;
begin
  Result := FCapSlpRotate180;
end;

function TPosPrinterWindows.Get_CapSlpRuledLine: Integer;
begin
  Result := FCapSlpRuledLine;
end;

function TPosPrinterWindows.Get_CapSlpUnderline: WordBool;
begin
  Result := FCapSlpUnderline;
end;

function TPosPrinterWindows.Get_CapStatisticsReporting: WordBool;
begin
  Result := FCapStatisticsReporting;
end;

function TPosPrinterWindows.Get_CapTransaction: WordBool;
begin
  Result := FCapTransaction;
end;

function TPosPrinterWindows.Get_CapUpdateFirmware: WordBool;
begin
  Result := FCapUpdateFirmware;
end;

function TPosPrinterWindows.Get_CapUpdateStatistics: WordBool;
begin
  Result := FCapUpdateStatistics;
end;

function TPosPrinterWindows.Get_CartridgeNotify: Integer;
begin
  Result := FCartridgeNotify;
end;

function TPosPrinterWindows.Get_CharacterSet: Integer;
begin
  Result := FCharacterSet;
end;

function TPosPrinterWindows.Get_CharacterSetList: WideString;
begin
  Result := FCharacterSetList;
end;

function TPosPrinterWindows.Get_CheckHealthText: WideString;
begin
  Result := FCheckHealthText;
end;

function TPosPrinterWindows.Get_Claimed: WordBool;
begin
  Result := FDevice.Claimed;
end;

function TPosPrinterWindows.Get_ControlObjectDescription: WideString;
begin
  Result := FControlObjectDescription;
end;

function TPosPrinterWindows.Get_ControlObjectVersion: Integer;
begin
  Result := FControlObjectVersion;
end;

function TPosPrinterWindows.Get_CoverOpen: WordBool;
begin
  Result := FCoverOpen;
end;

function TPosPrinterWindows.Get_DeviceDescription: WideString;
begin
  Result := FDeviceDescription;
end;

function TPosPrinterWindows.Get_DeviceEnabled: WordBool;
begin
  Result := FDevice.DeviceEnabled;
end;

function TPosPrinterWindows.Get_DeviceName: WideString;
begin
  Result := FDevice.DeviceName;
end;

function TPosPrinterWindows.Get_ErrorLevel: Integer;
begin
  Result := FErrorLevel;
end;

function TPosPrinterWindows.Get_ErrorStation: Integer;
begin
  Result := FErrorStation;
end;

function TPosPrinterWindows.Get_ErrorString: WideString;
begin
  Result := FDevice.ErrorString;
end;

function TPosPrinterWindows.Get_FlagWhenIdle: WordBool;
begin
  Result := FFlagWhenIdle;
end;

function TPosPrinterWindows.Get_FontTypefaceList: WideString;
begin
  Result := StringsToCommaSeparatedList(Printers.Printer.Fonts);
end;

function TPosPrinterWindows.Get_FreezeEvents: WordBool;
begin
  Result := FDevice.FreezeEvents;
end;

function TPosPrinterWindows.Get_JrnCartridgeState: Integer;
begin
  Result := FJrnCartridgeState;
end;

function TPosPrinterWindows.Get_JrnCurrentCartridge: Integer;
begin
  Result := FJrnCurrentCartridge;
end;

function TPosPrinterWindows.Get_JrnEmpty: WordBool;
begin
  Result := FJrnEmpty;
end;

function TPosPrinterWindows.Get_JrnLetterQuality: WordBool;
begin
  Result := FJrnLetterQuality;
end;

function TPosPrinterWindows.Get_JrnLineChars: Integer;
begin
  Result := FJrnLineChars;
end;

function TPosPrinterWindows.Get_JrnLineCharsList: WideString;
begin
  Result := FJrnLineCharsList;
end;

function TPosPrinterWindows.Get_JrnLineHeight: Integer;
begin
  Result := FJrnLineHeight;
end;

function TPosPrinterWindows.Get_JrnLineSpacing: Integer;
begin
  Result := FJrnLineSpacing;
end;

function TPosPrinterWindows.Get_JrnLineWidth: Integer;
begin
  Result := FJrnLineWidth;
end;

function TPosPrinterWindows.Get_JrnNearEnd: WordBool;
begin
  Result := FJrnNearEnd;
end;

function TPosPrinterWindows.Get_MapCharacterSet: WordBool;
begin
  Result := FMapCharacterSet;
end;

function TPosPrinterWindows.Get_MapMode: Integer;
begin
  Result := FMapMode;
end;

function TPosPrinterWindows.Get_OpenResult: Integer;
begin
  Result := FDevice.OpenResult;
end;

function TPosPrinterWindows.Get_OutputID: Integer;
begin
  Result := FDevice.OutputID;
end;

function TPosPrinterWindows.Get_PageModeArea: WideString;
begin
  Result := PointToStr(OposPtrUtils.MapFromDots(FPageModeArea, MapMode));
end;

function TPosPrinterWindows.Get_PageModeDescriptor: Integer;
begin
  Result := FPageModeDescriptor;
end;

function TPosPrinterWindows.Get_PageModeHorizontalPosition: Integer;
begin
  Result := FPageMode.HorizontalPosition;
end;

function TPosPrinterWindows.Get_PageModePrintArea: WideString;
begin
  Result := PageAreaToStr(PageAreaFromDots(FPageMode.PrintArea, MapMode));
end;

function TPosPrinterWindows.Get_PageModePrintDirection: Integer;
begin
  Result := FPageMode.PrintDirection;
end;

function TPosPrinterWindows.Get_PageModeStation: Integer;
begin
  Result := FPageMode.Station;
end;

function TPosPrinterWindows.Get_PageModeVerticalPosition: Integer;
begin
  Result := FPageMode.VerticalPosition;
end;

function TPosPrinterWindows.Get_PowerNotify: Integer;
begin
  Result := FDevice.PowerNotify;
end;

function TPosPrinterWindows.Get_PowerState: Integer;
begin
  Result := FDevice.PowerState;
end;

function TPosPrinterWindows.Get_RecBarCodeRotationList: WideString;
begin
  Result := FRecBarCodeRotationList;
end;

function TPosPrinterWindows.Get_RecBitmapRotationList: WideString;
begin
  Result := FRecBitmapRotationList;
end;

function TPosPrinterWindows.Get_RecCartridgeState: Integer;
begin
  Result := FRecCartridgeState;
end;

function TPosPrinterWindows.Get_RecCurrentCartridge: Integer;
begin
  Result := FRecCurrentCartridge;
end;

function TPosPrinterWindows.Get_RecEmpty: WordBool;
begin
  Result := FRecEmpty;
end;

function TPosPrinterWindows.Get_RecLetterQuality: WordBool;
begin
  Result := FRecLetterQuality;
end;

function TPosPrinterWindows.Get_RecLineChars: Integer;
begin
  Result := FRecLineChars;
end;

function TPosPrinterWindows.Get_RecLineCharsList: WideString;
begin
  Result := FRecLineCharsList;
end;

function TPosPrinterWindows.Get_RecLineHeight: Integer;
begin
  Result := FRecLineHeight;
end;

function TPosPrinterWindows.Get_RecLineSpacing: Integer;
begin
  Result := FRecLineSpacing;
end;

function TPosPrinterWindows.Get_RecLinesToPaperCut: Integer;
begin
  Result := FRecLinesToPaperCut;
end;

function TPosPrinterWindows.Get_RecLineWidth: Integer;
begin
  Result := FRecLineWidth;
end;

function TPosPrinterWindows.Get_RecNearEnd: WordBool;
begin
  Result := FRecNearEnd;
end;

function TPosPrinterWindows.Get_RecSidewaysMaxChars: Integer;
begin
  Result := FRecSidewaysMaxChars;
end;

function TPosPrinterWindows.Get_RecSidewaysMaxLines: Integer;
begin
  Result := FRecSidewaysMaxLines;
end;

function TPosPrinterWindows.Get_ResultCode: Integer;
begin
  Result := FDevice.ResultCode;
end;

function TPosPrinterWindows.Get_ResultCodeExtended: Integer;
begin
  Result := FDevice.ResultCodeExtended;
end;

function TPosPrinterWindows.Get_RotateSpecial: Integer;
begin
  Result := FRotateSpecial;
end;

function TPosPrinterWindows.Get_ServiceObjectDescription: WideString;
begin
  Result := FDevice.ServiceObjectDescription;
end;

function TPosPrinterWindows.Get_ServiceObjectVersion: Integer;
begin
  Result := FDevice.ServiceObjectVersion;
end;

function TPosPrinterWindows.Get_SlpBarCodeRotationList: WideString;
begin
  Result := FSlpBarCodeRotationList;
end;

function TPosPrinterWindows.Get_SlpBitmapRotationList: WideString;
begin
  Result := FSlpBitmapRotationList;
end;

function TPosPrinterWindows.Get_SlpCartridgeState: Integer;
begin
  Result := FSlpCartridgeState;
end;

function TPosPrinterWindows.Get_SlpCurrentCartridge: Integer;
begin
  Result := FSlpCurrentCartridge;
end;

function TPosPrinterWindows.Get_SlpEmpty: WordBool;
begin
  Result := FSlpEmpty;
end;

function TPosPrinterWindows.Get_SlpLetterQuality: WordBool;
begin
  Result := FSlpLetterQuality;
end;

function TPosPrinterWindows.Get_SlpLineChars: Integer;
begin
  Result := FSlpLineChars;
end;

function TPosPrinterWindows.Get_SlpLineCharsList: WideString;
begin
  Result := FSlpLineCharsList;
end;

function TPosPrinterWindows.Get_SlpLineHeight: Integer;
begin
  Result := FSlpLineHeight;
end;

function TPosPrinterWindows.Get_SlpLinesNearEndToEnd: Integer;
begin
  Result := FSlpLinesNearEndToEnd;
end;

function TPosPrinterWindows.Get_SlpLineSpacing: Integer;
begin
  Result := FSlpLineSpacing;
end;

function TPosPrinterWindows.Get_SlpLineWidth: Integer;
begin
  Result := FSlpLineWidth;
end;

function TPosPrinterWindows.Get_SlpMaxLines: Integer;
begin
  Result := FSlpMaxLines;
end;

function TPosPrinterWindows.Get_SlpNearEnd: WordBool;
begin
  Result := FSlpNearEnd;
end;

function TPosPrinterWindows.Get_SlpPrintSide: Integer;
begin
  Result := FSlpPrintSide;
end;

function TPosPrinterWindows.Get_SlpSidewaysMaxChars: Integer;
begin
  Result := FSlpSidewaysMaxChars;
end;

function TPosPrinterWindows.Get_SlpSidewaysMaxLines: Integer;
begin
  Result := FSlpSidewaysMaxLines;
end;

function TPosPrinterWindows.Get_State: Integer;
begin
  Result := FDevice.State;
end;

function TPosPrinterWindows.MarkFeed(Type_: Integer): Integer;
begin
  Result := ClearResult;
end;

function TPosPrinterWindows.Open(const DeviceName: WideString): Integer;
begin
  try
    FDevice.Open('POSPrinter', DeviceName, nil);

    Printer.PrinterName := PrinterName;
    FRecLineWidth := Printer.GetPageWidth;

    Result := ClearResult;
  except
    on E: Exception do
    begin
      Close;
      Result := HandleException(E);
    end;
  end;
end;

function TPosPrinterWindows.PageModePrint(Control: Integer): Integer;
begin
  try
    case Control of
      // Enter Page Mode
      PTR_PM_PAGE_MODE:
      begin
        FPageMode.IsActive := True;
        FPageMode.IsValid := False;
        FPageMode.PrintDirection := 0;
        FPageMode.VerticalPosition := 0;
        FPageMode.HorizontalPosition := 0;
      end;

      // Print the print area and destroy the canvas and exit PageMode.
      PTR_PM_NORMAL:
      begin
        if FPageMode.IsActive then
        begin
          FPageModeBitmap.SaveToFile('PageModeBitmap1.bmp');
          Printer.Canvas.Draw(FPageMode.PrintArea.X,
            FPageMode.VerticalPosition + FPageMode.PrintArea.Y, FPageModeBitmap);
          Inc(FVerticalPosition, FPageMode.PrintArea.Y + FPageMode.PrintArea.Height);

          FPageMode.IsActive := False;
          FPageMode.PrintDirection := 0;
          FPageMode.VerticalPosition := 0;
          FPageMode.HorizontalPosition := 0;
        end;
      end;

      // Clear the page and exit the Page Mode without any printing of any print area.
      PTR_PM_CANCEL:
      begin
        FPageMode.IsActive := False;
      end;
    end;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TPosPrinterWindows.PrintBarCode(Station: Integer;
  const Data: WideString; Symbology, Height, Width, Alignment,
  TextPosition: Integer): Integer;
var
  Barcode: TPosBarcode;
begin
  try
    CheckRecStation(Station);

    PrinterBeginDoc;
    Barcode.Data := Data;
    Barcode.Width := Width;
    Barcode.Height := Height;
    Barcode.Alignment := Alignment;
    Barcode.Symbology := Symbology;
    Barcode.TextPosition := TextPosition;
    PrintBarcodeAsGraphics(Barcode);

    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

procedure TPosPrinterWindows.PrintBarcodeAsGraphics(var Barcode: TPosBarcode);
var
  Data: AnsiString;
begin
  if not CapRecBitmap then
    RaiseIllegalError('Bitmaps are not supported');

  Data := RenderBarcodeRec(Barcode);
  PrintMemoryGraphic(Data, PTR_BMT_BMP, Barcode.Width, Barcode.Alignment);
end;

procedure TPosPrinterWindows.PrintMemoryGraphic(const Data: WideString;
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

function TPosPrinterWindows.PrintBitmap(Station: Integer;
  const FileName: WideString; Width, Alignment: Integer): Integer;
var
  Bitmap: TBitmap;
begin
  Bitmap := TBitmap.Create;
  try
    CheckRecStation(Station);
    Bitmap.LoadFromFile(FileName);

    PrinterBeginDoc;
    PrintGraphics(Bitmap, Width, Alignment);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
  Bitmap.Free;
end;

function TPosPrinterWindows.PrintImmediate(Station: Integer;
  const Data: WideString): Integer;
begin
  Result := ClearResult;
end;

procedure TPosPrinterWindows.PrintGraphics(Graphic: TGraphic;
  Width, Alignment: Integer);
var
  OffsetX: Integer;
begin
  OffsetX := 0;
  if FPageMode.IsActive then
  begin
    if Graphic.Width < FPageMode.PrintArea.Width then
    begin
      if Alignment = PTR_BM_RIGHT then
        OffsetX := FPageMode.PrintArea.Width - Graphic.Width;
      if Alignment = PTR_BM_CENTER then
        OffsetX := (FPageMode.PrintArea.Width - Graphic.Width) div 2;
    end;
    GetCanvas.Draw(OffsetX, FPageMode.VerticalPosition, Graphic);
    Inc(FPageMode.VerticalPosition, Graphic.Height + RecLineSpacing);
    FPageMode.IsValid := True;
  end else
  begin
    if Graphic.Width < RecLineWidth then
    begin
      if Alignment = PTR_BM_RIGHT then
        OffsetX := RecLineWidth - Graphic.Width;
      if Alignment = PTR_BM_CENTER then
        OffsetX := (RecLineWidth - Graphic.Width) div 2;
    end;
    GetCanvas.Draw(FHorizontalPosition + OffsetX, FVerticalPosition, Graphic);
    Inc(FVerticalPosition, Graphic.Height + RecLineSpacing);
  end;
end;

function TPosPrinterWindows.PrintMemoryBitmap(Station: Integer;
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

procedure TPosPrinterWindows.CheckRecStation(Station: Integer);
begin
  if Station <> PTR_S_RECEIPT then
    raiseIllegalError('Station not supported');
end;

procedure TPosPrinterWindows.PrintText(Text: WideString);
var
  i: Integer;
  Tag: TEscTag;
  Tags: TEscTags;
  Barcode: TOposBarcode;
begin
  PrinterBeginDoc;
  Tags := GetEscTags(Text);
  for i := 0 to Length(Tags)-1 do
  begin
    Tag := Tags[i];
    case Tag.TagType of
      ttText:
      begin
        PrintText2(Tag.Text);
      end;
      ttPrintBarcode:
      begin
        Barcode := ParseOposBarcode(Tag.Text);
        PrintBarcode(
          PTR_S_RECEIPT,
          Barcode.Data,
          Barcode.Symbology,
          Barcode.Height,
          Barcode.Width,
          Barcode.Alignment,
          Barcode.TextPosition);
      end;
      ttFontIndex:
      begin
        GetCanvas.Font.Name := Printers.Printer.Fonts[Tag.Number];
      end;
      ttBold:
      begin
        GetCanvas.Font.Style := GetCanvas.Font.Style + [fsBold];
      end;
      ttNoBold:
      begin
        GetCanvas.Font.Style := GetCanvas.Font.Style - [fsBold];
      end;
      ttUnderline:
      begin
        GetCanvas.Font.Style := GetCanvas.Font.Style + [fsUnderline];
      end;
      ttNoUnderline:
      begin
        GetCanvas.Font.Style := GetCanvas.Font.Style - [fsUnderline];
      end;
      ttItalic:
      begin
        GetCanvas.Font.Style := GetCanvas.Font.Style + [fsItalic];
      end;
      ttNoItalic:
      begin
        GetCanvas.Font.Style := GetCanvas.Font.Style - [fsItalic];
      end;
      ttNormalSize:
      begin
        GetCanvas.Font.Size := NormalFontSize;
        GetCanvas.Font.Style := GetCanvas.Font.Style - [fsBold];
      end;
      ttDoubleWide:
      begin
        GetCanvas.Font.Size := DoubleFontSize;
        GetCanvas.Font.Style := GetCanvas.Font.Style + [fsBold];
      end;
      ttDoubleHigh:
      begin
        GetCanvas.Font.Size := DoubleFontSize;
        GetCanvas.Font.Style := GetCanvas.Font.Style + [fsBold];
      end;
      ttDoubleHighWide:
      begin
        GetCanvas.Font.Size := DoubleFontSize;
        GetCanvas.Font.Style := GetCanvas.Font.Style + [fsBold];
      end;
      ttScaleHorizontally:
      begin
        FHorizontalScale := Tag.Number;
      end;
      ttScaleVertically:
      begin
        FVerticalScale := Tag.Number;
      end;
      ttNormal:
      begin
        GetCanvas.Font.Style := [];
        GetCanvas.Font.Name := DefaultFontName;
      end;
      ttPaperCut:
      begin
        Printer.Send(#$1B#$69);
      end;
      ttFeedCut:
      begin
        FeedLines(Tag.Number);
        Printer.Send(#$1B#$69);
      end;
      ttFeedUnits:
      begin
        if Tag.Number <= 0 then
          Tag.Number := 1;
        FeedUnits(Tag.Number);
      end;
      ttFeedReverse:
      begin
        if Tag.Number <= 0 then
          Tag.Number := 1;
        FeedLines(-Tag.Number);
      end;
      ttPassThrough:
      begin
        Printer.Send(Tag.Text);
      end;
      ttAlignCenter:
      begin
        FAlignment := ALIGN_CENTER;
      end;
      ttAlignRight:
      begin
        FAlignment := ALIGN_RIGHT;
      end;
      ttAlignLeft:
      begin
        FAlignment := ALIGN_LEFT;
      end;
      ttStrikeThrough:
      begin
        GetCanvas.Font.Style := GetCanvas.Font.Style + [fsStrikeOut];
      end;
      ttNoStrikeThrough:
      begin
        GetCanvas.Font.Style := GetCanvas.Font.Style - [fsStrikeOut];
      end;
      ttPrintBitmap:
      begin
        if Tag.Number < 0 then
          Tag.Number := 0;
        if Tag.Number >= MaxBitmapCount then
          Tag.Number := MaxBitmapCount-1;
        PrintBitmap(PTR_S_RECEIPT, BitmapFiles[Tag.Number], PTR_BM_ASIS, PTR_BM_CENTER);
      end;
      ttPrintTLogo:
      begin
        PrintBitmap(PTR_S_RECEIPT, TopLogoFile, PTR_BM_ASIS, PTR_BM_CENTER);
      end;
      ttPrintBLogo:
      begin
        PrintBitmap(PTR_S_RECEIPT, BottomLogoFile, PTR_BM_ASIS, PTR_BM_CENTER);
      end;
      ttFeedLines:
      begin
        if Tag.Number <= 0 then
          Tag.Number := 1;
        FeedLines(Tag.Number);
      end;
    end;
  end;
  GetCanvas.Font.Style := [];
  GetCanvas.Font.Name := FontName;
  GetCanvas.Font.Size := NormalFontSize;
end;

function TPosPrinterWindows.GetFontHeight: Integer;
var
  S: WideString;
  TextSize: TSize;
begin
  S := 'W';
  GetTextExtentPointW(GetCanvas.Handle, PWideChar(S), Length(S), TextSize);
  Result := TextSize.cy;
end;

procedure TPosPrinterWindows.FeedLines(N: Integer);
begin
  if FPageMode.IsActive then
  begin
    Inc(FPageMode.VerticalPosition, (GetFontHeight + LineSpacing)*N);
    if FPageMode.VerticalPosition < 0 then
      FPageMode.VerticalPosition := 0;
  end else
  begin
    Inc(FVerticalPosition, (GetFontHeight + LineSpacing)*N);
    if FVerticalPosition < 0 then
      FVerticalPosition := 0;
  end;
end;

procedure TPosPrinterWindows.FeedUnits(N: Integer);
begin
  if FPageMode.IsActive then
  begin
    Inc(FPageMode.VerticalPosition, N);
    if FPageMode.VerticalPosition < 0 then
      FPageMode.VerticalPosition := 0;
  end else
  begin
    Inc(FVerticalPosition, N);
    if FVerticalPosition < 0 then
      FVerticalPosition := 0;
  end;
end;

function TPosPrinterWindows.AlignText(const Text: WideString; Alignment: Integer): WideString;
begin
  case Alignment of
    ALIGN_CENTER: Result := StringOfChar(' ', (RecLineChars-Length(Text)) div 2) + Text;
    ALIGN_RIGHT: Result := StringOfChar(' ', RecLineChars-Length(Text)) + Text;
  else
    Result := Text;
  end;
end;

procedure TPosPrinterWindows.PrintText2(const Text: WideString);
var
  Line: WideString;
  TextSize: TSize;
  Canvas: TJvUnicodeCanvas;
begin
  Canvas := TJvUnicodeCanvas.Create;
  try
    Canvas.Handle := GetCanvas.Handle;
    Canvas.Font := GetCanvas.Font;

    Line := AlignText(Text, FAlignment);
    if FPageMode.IsActive then
    begin
      Canvas.TextOutW(FPageMode.HorizontalPosition, FPageMode.VerticalPosition, Line);
      TextSize := Canvas.TextExtentW(Line);
      Inc(FPageMode.VerticalPosition, TextSize.cy + LineSpacing);
      FPageMode.IsValid := True;
    end else
    begin
      Canvas.TextOutW(FHorizontalPosition, FVerticalPosition, Line);
      TextSize := Canvas.TextExtentW(Line);
      Inc(FVerticalPosition, TextSize.cy + LineSpacing);
    end;
  finally
    Canvas.Free;
  end;
end;

function TPosPrinterWindows.PrintNormal(Station: Integer;
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

function TPosPrinterWindows.PrintTwoNormal(Stations: Integer; const Data1,
  Data2: WideString): Integer;
begin
  Result := ClearResult;
end;

function TPosPrinterWindows.ReleaseDevice: Integer;
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

function TPosPrinterWindows.ResetStatistics(
  const StatisticsBuffer: WideString): Integer;
begin
  Result := ClearResult;
end;

function TPosPrinterWindows.RetrieveStatistics(
  var pStatisticsBuffer: WideString): Integer;
begin
  Result := ClearResult;
end;

function TPosPrinterWindows.RotatePrint(Station, Rotation: Integer): Integer;
begin
  Result := ClearResult;
end;

procedure TPosPrinterWindows.Set_AsyncMode(pAsyncMode: WordBool);
begin
  FAsyncMode := pAsyncMode;
end;

procedure TPosPrinterWindows.Set_BinaryConversion(pBinaryConversion: Integer);
begin
  FDevice.BinaryConversion := pBinaryConversion;
end;

procedure TPosPrinterWindows.Set_CartridgeNotify(pCartridgeNotify: Integer);
begin
  FCartridgeNotify := pCartridgeNotify;
end;

procedure TPosPrinterWindows.Set_CharacterSet(pCharacterSet: Integer);
begin
  FCharacterSet := pCharacterSet;
end;

procedure TPosPrinterWindows.Set_DeviceEnabled(pDeviceEnabled: WordBool);
begin
  FDevice.DeviceEnabled := pDeviceEnabled;
end;

procedure TPosPrinterWindows.Set_FlagWhenIdle(pFlagWhenIdle: WordBool);
begin
  FFlagWhenIdle := pFlagWhenIdle;
end;

procedure TPosPrinterWindows.Set_FreezeEvents(pFreezeEvents: WordBool);
begin
  FDevice.FreezeEvents := pFreezeEvents;
end;

procedure TPosPrinterWindows.Set_JrnCurrentCartridge(
  pJrnCurrentCartridge: Integer);
begin
  FJrnCurrentCartridge := pJrnCurrentCartridge;
end;

procedure TPosPrinterWindows.Set_JrnLetterQuality(pJrnLetterQuality: WordBool);
begin
  FJrnLetterQuality := pJrnLetterQuality;
end;

procedure TPosPrinterWindows.Set_JrnLineChars(pJrnLineChars: Integer);
begin
  FJrnLineChars := pJrnLineChars;
end;

procedure TPosPrinterWindows.Set_JrnLineHeight(pJrnLineHeight: Integer);
begin
  FJrnLineHeight := pJrnLineHeight;
end;

procedure TPosPrinterWindows.Set_JrnLineSpacing(pJrnLineSpacing: Integer);
begin
  FJrnLineSpacing := pJrnLineSpacing;
end;

procedure TPosPrinterWindows.Set_MapCharacterSet(pMapCharacterSet: WordBool);
begin
  FMapCharacterSet := pMapCharacterSet;
end;

procedure TPosPrinterWindows.Set_MapMode(pMapMode: Integer);
begin
  FMapMode := pMapMode;
end;

procedure TPosPrinterWindows.Set_PageModeHorizontalPosition(
  pPageModeHorizontalPosition: Integer);
begin
  FPageMode.HorizontalPosition := pPageModeHorizontalPosition;
end;

procedure TPosPrinterWindows.Set_PageModePrintArea(
  const pPageModePrintArea: WideString);
begin
  if FPageMode.IsActive and FPageMode.isValid then
  begin
    FPageModeBitmap.SaveToFile('PageModeBitmap0.bmp');
    Printer.Canvas.Draw(FPageMode.PrintArea.X,
      FPageMode.VerticalPosition + FPageMode.PrintArea.Y, FPageModeBitmap);
  end;
  FPageMode.IsActive := True;
  FPageMode.IsValid := False;
  FPageMode.PrintArea := PageAreaToDots(StrToPageArea(pPageModePrintArea), MapMode);
  FPageMode.VerticalPosition := FVerticalPosition;
  FPageMode.HorizontalPosition := FHorizontalPosition;

  FPageModeBitmap.Free;
  FPageModeBitmap := TBitmap.Create;
  FPageModeBitmap.Monochrome := True;
  FPageModeBitmap.PixelFormat := pf1Bit;
  FPageModeBitmap.Width := FPageMode.PrintArea.Width;
  FPageModeBitmap.Height := FPageMode.PrintArea.Height;
  FPageModeBitmap.Canvas.Font.Name := FontName;
  FPageModeBitmap.Canvas.Font.Size := NormalFontSize;
  FPageModeBitmap.Canvas.Font.Style := [];
end;

procedure TPosPrinterWindows.Set_PageModePrintDirection(
  pPageModePrintDirection: Integer);
begin
  FPageMode.PrintDirection := pPageModePrintDirection;
end;

procedure TPosPrinterWindows.Set_PageModeStation(pPageModeStation: Integer);
begin
  FPageMode.Station := pPageModeStation;
end;

procedure TPosPrinterWindows.Set_PageModeVerticalPosition(
  pPageModeVerticalPosition: Integer);
begin
  FPageMode.VerticalPosition := pPageModeVerticalPosition;
end;

procedure TPosPrinterWindows.Set_PowerNotify(pPowerNotify: Integer);
begin
  FDevice.PowerNotify := pPowerNotify;
end;

procedure TPosPrinterWindows.Set_RecCurrentCartridge(
  pRecCurrentCartridge: Integer);
begin
  FRecCurrentCartridge := pRecCurrentCartridge;
end;

procedure TPosPrinterWindows.Set_RecLetterQuality(pRecLetterQuality: WordBool);
begin
  FRecLetterQuality := pRecLetterQuality;
end;

procedure TPosPrinterWindows.Set_RecLineChars(pRecLineChars: Integer);
begin
  FRecLineChars := pRecLineChars;
end;

procedure TPosPrinterWindows.Set_RecLineHeight(pRecLineHeight: Integer);
begin
  FRecLineHeight := pRecLineHeight;
end;

procedure TPosPrinterWindows.Set_RecLineSpacing(pRecLineSpacing: Integer);
begin
  FRecLineSpacing := pRecLineSpacing;
end;

procedure TPosPrinterWindows.Set_RotateSpecial(pRotateSpecial: Integer);
begin
  FRotateSpecial := pRotateSpecial;
end;

procedure TPosPrinterWindows.Set_SlpCurrentCartridge(
  pSlpCurrentCartridge: Integer);
begin
  FSlpCurrentCartridge := pSlpCurrentCartridge;
end;

procedure TPosPrinterWindows.Set_SlpLetterQuality(pSlpLetterQuality: WordBool);
begin
  FSlpLetterQuality := pSlpLetterQuality;
end;

procedure TPosPrinterWindows.Set_SlpLineChars(pSlpLineChars: Integer);
begin
  FSlpLineChars := pSlpLineChars;
end;

procedure TPosPrinterWindows.Set_SlpLineHeight(pSlpLineHeight: Integer);
begin
  FSlpLineHeight := pSlpLineHeight;
end;

procedure TPosPrinterWindows.Set_SlpLineSpacing(pSlpLineSpacing: Integer);
begin
  FSlpLineSpacing := pSlpLineSpacing;
end;

function TPosPrinterWindows.SetBitmap(BitmapNumber, Station: Integer;
  const FileName: WideString; Width, Alignment: Integer): Integer;
begin
  Result := ClearResult;
end;

function TPosPrinterWindows.SetLogo(Location: Integer;
  const Data: WideString): Integer;
begin
  Result := ClearResult;
end;

procedure TPosPrinterWindows.SODataDummy(Status: Integer);
begin

end;

procedure TPosPrinterWindows.SODirectIO(EventNumber: Integer;
  var pData: Integer; var pString: WideString);
begin

end;

procedure TPosPrinterWindows.SOError(ResultCode, ResultCodeExtended,
  ErrorLocus: Integer; var pErrorResponse: Integer);
begin

end;

procedure TPosPrinterWindows.SOOutputComplete(OutputID: Integer);
begin

end;

function TPosPrinterWindows.SOProcessID: Integer;
begin

end;

procedure TPosPrinterWindows.SOStatusUpdate(Data: Integer);
begin

end;

function TPosPrinterWindows.TransactionPrint(Station,
  Control: Integer): Integer;
begin
  try
    CheckRecStation(Station);
    case Control of
      PTR_TP_NORMAL:
      begin
        if FTransaction then
        begin
          PrinterEndDoc;
          FVerticalPosition := 0;
          FTransaction := False;
        end;
      end;
      PTR_TP_TRANSACTION:
      begin
        if not FTransaction then
        begin
          PrinterBeginDoc;
          FTransaction := True;
          FVerticalPosition := 0;
        end;
      end;
    end;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TPosPrinterWindows.UpdateFirmware(
  const FirmwareFileName: WideString): Integer;
begin
  Result := ClearResult;
end;

function TPosPrinterWindows.UpdateStatistics(
  const StatisticsBuffer: WideString): Integer;
begin
  Result := ClearResult;
end;

function TPosPrinterWindows.ValidateData(Station: Integer;
  const Data: WideString): Integer;
begin
  Result := ClearResult;
end;

end.

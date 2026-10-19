unit PosPrinterPosiflex;

interface

uses
  // VCL
  Windows, Classes, SysUtils, Graphics, Math, ComObj,
  // Tnt
  TntClasses, TntSysUtils,
  // Opos
  Opos, OposEsc, OposPtr, OposException, OposServiceDevice19, OposEvents,
  OposPOSPrinter_CCO_TLB, UserError, OposPtrUtils, OposUtils,
  // This
  LogFile, DriverError, EscPrinterPosiflex, PrinterPort, NotifyThread,
  RegExpr, SerialPort, Jpeg, GifImage, BarcodeUtils, StringUtils, DebugUtils,
  PtrDirectIO, EscPrinterUtils, ComUtils, OposEventsAdapter, PrinterTypes, CustomPosPrinter;

type
  { TPosPrinterPosiflex }

  TPosPrinterPosiflex = class(TCustomPosPrinter)
  private
    FPrinter: TEscPrinterPosiflex;
    FPageModeArea: TPoint;
    FPageModePrintArea: TPageArea;
    FPageMode: TPageMode;
    procedure UpdatePageMode;
    procedure PrintBarCodeNormal(Barcode: TPosBarcode);
    function IsSymbologySupported(Symbology: Integer): Boolean;
    procedure PrintBarCodeEsc(Barcode: TPosBarcode);
    procedure PrintBarCodePageMode(Barcode: TPosBarcode);
    procedure PrintBarCodeEscQRCode(const Data: string);
    procedure UpdateLineSpacing;
  public
    procedure PrintWideString(const AText: WideString); override;
    procedure Initialize; override;
    procedure PrintGraphics(Graphic: TGraphic; Width, Alignment: Integer); override;
    procedure DeviceProc(Sender: TObject); override;
    procedure UpdatePrinterStatus; override;
    procedure UpdatePrinterStatus2;
    property Printer: TEscPrinterPosiflex read FPrinter;
    function GetToken(var Text: WideString; var Token: TEscToken): Boolean;
    procedure PrintText(Text: WideString); override;
    procedure InitializeDevice; override;
    procedure CheckPaperPresent; override;
    procedure CheckCoverClosed; override;
  public
    constructor Create(APort: IPrinterPort; ALogger: ILogFile);
    destructor Destroy; override;
  public
    PollEnabled: Boolean;
    function Get_RecLinesToPaperCut: Integer; override; safecall;
    function Get_RecLineWidth: Integer; override; safecall;
    function Get_PageModeArea: WideString; override; safecall;
    function Get_RecLineHeight: Integer; override; safecall;
    function Get_RecLineSpacing: Integer; override; safecall;
    function Get_PageModeHorizontalPosition: Integer; override; safecall;
    function Get_PageModePrintArea: WideString; override; safecall;
    function Get_PageModeVerticalPosition: Integer; override; safecall;
  public
    procedure Set_DeviceEnabled(pDeviceEnabled: WordBool); override; safecall;
    procedure Set_CharacterSet(pCharacterSet: Integer); override; safecall;
    procedure Set_RecLineChars(pRecLineChars: Integer); override; safecall;
    procedure Set_RecLineHeight(pRecLineHeight: Integer); override; safecall;
    procedure Set_RecLineSpacing(pRecLineSpacing: Integer); override; safecall;
    procedure Set_PageModeHorizontalPosition(pPageModeHorizontalPosition: Integer); override; safecall;
    procedure Set_PageModePrintArea(const pPageModePrintArea: WideString); override; safecall;
    procedure Set_PageModeVerticalPosition(pPageModeVerticalPosition: Integer); override; safecall;
  public
    function CheckHealth(Level: Integer): Integer; override; safecall;
    function DirectIO(Command: Integer; var pData: Integer; var pString: WideString): Integer; override; safecall;
    function CutPaper(Percentage: Integer): Integer; override; safecall;
    function PrintBarCode(Station: Integer; const Data: WideString; Symbology: Integer; Height: Integer; Width: Integer; Alignment: Integer; TextPosition: Integer): Integer; override; safecall;
    function PrintNormal(Station: Integer; const Data: WideString): Integer; override; safecall;
    function TransactionPrint(Station: Integer; Control: Integer): Integer; override; safecall;
    function PageModePrint(Control: Integer): Integer; override; safecall;
    function PrintMemoryBitmap(Station: Integer; const Data: WideString; Type_: Integer; Width: Integer; Alignment: Integer): Integer; override; safecall;
  public
    procedure DirectIOEvent(Sender: TObject; EventNumber: Integer;
      var pData: Integer; var pString: WideString); override;
    procedure ErrorEvent(Sender: TObject; ResultCode: Integer;
      ResultCodeExtended: Integer; ErrorLocus: Integer; var pErrorResponse: Integer); override;
  end;

implementation

const
  SupportedCodePages: array [0..18] of Integer = (
    437,737,850,852,855,857,858,860,862,863,864,865,866,1251,1253,1254,1255,1256,1257);

function CharacterSetToPrinterCodePage(CharacterSet: Integer): Integer;
begin
  case CharacterSet of
    PTR_CS_ASCII: Result := CODEPAGE_WCP1251;
    PTR_CS_UNICODE: Result := CODEPAGE_WCP1251;
    PTR_CS_WINDOWS: Result := CODEPAGE_WCP1251;

    437: Result := CODEPAGE_CP437;
    737: Result := CODEPAGE_CP737;
    850: Result := CODEPAGE_CP850;
    852: Result := CODEPAGE_CP852;
    855: Result := CODEPAGE_CP855;
    857: Result := CODEPAGE_CP857;
    858: Result := CODEPAGE_CP858;
    860: Result := CODEPAGE_CP860;
    862: Result := CODEPAGE_CP862;
    863: Result := CODEPAGE_CP863;
    864: Result := CODEPAGE_CP864;
    865: Result := CODEPAGE_CP865;
    866: Result := CODEPAGE_CP866;
    1251: Result := CODEPAGE_WCP1251;
    1254: Result := CODEPAGE_WCP1254;
    1255: Result := CODEPAGE_WCP1255;
    1256: Result := CODEPAGE_WCP1256;
    1257: Result := CODEPAGE_WCP1257;
  else
    raise UserException.Create('Character set not supported');
  end;
end;

function IsValidCharacterSet(CharacterSet: Integer): Boolean;
var
  i: Integer;
begin
  for i := Low(SupportedCodePages) to High(SupportedCodePages) do
  begin
    Result := CharacterSet = SupportedCodePages[i];
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

{ TPosPrinterPosiflex }

constructor TPosPrinterPosiflex.Create(APort: IPrinterPort; ALogger: ILogFile);

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
  PollEnabled := False;
  FEvents := CreateEventsAdapter;
  FPort := APort;
  FPrinter := TEscPrinterPosiflex.Create(APort, ALogger);
  FLogger := ALogger;
  FDevice := TOposServiceDevice19.Create(FLogger);
  FDevice.ErrorEventEnabled := False;
  FPageMode.IsActive := False;
  if APort <> nil then
    Initialize;
end;

destructor TPosPrinterPosiflex.Destroy;
begin
  Close;
  FThread.Free;
  FDevice.Free;
  FPrinter.Free;
  FEvents := nil;
  FPort := nil;
  FLogger := nil;
  inherited Destroy;
end;

procedure TPosPrinterPosiflex.Initialize;
const
  DefPageModeArea: TPoint = (X: 512; Y: 832);
  DefPageModePrintArea: TPageArea = (X: 0; Y: 0; Width: 0; Height: 0);
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
  FCapTransaction := True;
  FCartridgeNotify := 0;
  FCharacterSet := PTR_CS_UNICODE;
  FCharacterSetList := ArrayToString(SupportedCodePages);
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
  FPageModeArea := DefPageModeArea;
  FPageModeDescriptor := PTR_PM_BARCODE + PTR_PM_BC_ROTATE + PTR_PM_OPAQUE;
  FPageModeHorizontalPosition := 0;
  FPageModePrintArea := DefPageModePrintArea;
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
  FRecLineSpacing := FRecLineHeight + 5;
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

// IOPOSPOSPrinter

function TPosPrinterPosiflex.CheckHealth(Level: Integer): Integer;
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

function TPosPrinterPosiflex.CutPaper(Percentage: Integer): Integer;
begin
  try
    FPrinter.PartialCut;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TPosPrinterPosiflex.DirectIO(Command: Integer; var pData: Integer;
  var pString: WideString): Integer;

  function DioCheckBarcode(var pData: Integer; var pString: WideString): string;
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

  function DioGetBarcodeSize(var pData: Integer; var pString: WideString): string;
  var
    Barcode: TBarcodeRec;
  begin
    Barcode := StrToBarcode(pString);

    Result := '';
  end;

begin
  try
    Device.CheckOpened;
    case Command of
      DIO_PTR_CHECK_BARCODE:
        pString := DioCheckBarcode(pData, pString);

      DIO_PTR_GET_BARCODE_SIZE:
        pString := DioGetBarcodeSize(pData, pString);

    end;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TPosPrinterPosiflex.Get_PageModeArea: WideString;
begin
  Result := PointToStr(OposPtrUtils.MapFromDots(FPageModeArea, MapMode));
end;

function TPosPrinterPosiflex.Get_PageModeHorizontalPosition: Integer;
begin
  Result := OposPtrUtils.MapFromDots(FPageModeHorizontalPosition, MapMode);
end;

function TPosPrinterPosiflex.Get_PageModePrintArea: WideString;
begin
  Result := PageAreaToStr(PageAreaFromDots(FPageModePrintArea, MapMode));
end;

function TPosPrinterPosiflex.Get_PageModeVerticalPosition: Integer;
begin
  Result := MapFromDots(FPageModeVerticalPosition, MapMode);
end;

function TPosPrinterPosiflex.Get_RecLineHeight: Integer;
begin
  Result := MapFromDots(FRecLineHeight, MapMode);
end;

function TPosPrinterPosiflex.Get_RecLineSpacing: Integer;
begin
  Result := MapFromDots(FRecLineSpacing, MapMode);
end;

function TPosPrinterPosiflex.Get_RecLinesToPaperCut: Integer;
begin
  Result := 0;
end;

function TPosPrinterPosiflex.Get_RecLineWidth: Integer;
begin
  Result := MapFromDots(FRecLineWidth, MapMode);
end;

function TPosPrinterPosiflex.PageModePrint(Control: Integer): Integer;
begin
  try
    case Control of
      // Enter Page Mode
      PTR_PM_PAGE_MODE:
      begin
        FPageMode.IsActive := True;
        FPrinter.SetPageMode;
      end;

      // Print the print area and destroy the canvas and exit PageMode.
      PTR_PM_NORMAL:
      begin
        FPageMode.IsActive := False;
        FPrinter.PrintAndReturnStandardMode;
      end;

      // Clear the page and exit the Page Mode without any printing of any print area.
      PTR_PM_CANCEL:
      begin
        FPageMode.IsActive := False;
        FPrinter.SetStandardMode;
      end;
    end;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

function TPosPrinterPosiflex.PrintBarCode(Station: Integer;
  const Data: WideString; Symbology, Height, Width, Alignment,
  TextPosition: Integer): Integer;
var
  Barcode: TPosBarcode;
begin
  try
    CheckRecStation(Station);
    UpdatePageMode;

    Barcode.Data := Data;
    Barcode.Width := Width;
    Barcode.Height := Height;
    Barcode.Alignment := Alignment;
    Barcode.Symbology := Symbology;
    Barcode.TextPosition := TextPosition;
    if FPageMode.IsActive then
    begin
      PrintBarcodePageMode(Barcode);
    end else
    begin
      PrintBarcodeNormal(Barcode);
    end;
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

///////////////////////////////////////////////////////////////////////////////
// In page mode barcode printed only in ESC
// In page mode bitmaps are not supported

procedure TPosPrinterPosiflex.PrintBarCodePageMode(Barcode: TPosBarcode);
begin
  if Barcode.Symbology = PTR_BCS_QRCODE then
  begin
    PrintBarCodeEscQRCode(Barcode.Data);
  end;
end;

procedure TPosPrinterPosiflex.PrintBarCodeNormal(Barcode: TPosBarcode);
begin
  if BarcodeInGraphics then
  begin
    PrintBarcodeAsGraphics(Barcode);
  end else
  begin
    if IsSymbologySupported(Barcode.Symbology) then
      PrintBarCodeEsc(Barcode)
    else
      PrintBarcodeAsGraphics(Barcode);
  end;
end;

function TPosPrinterPosiflex.IsSymbologySupported(Symbology: Integer): Boolean;
begin
  case Symbology of
    PTR_BCS_UPCA,
    PTR_BCS_UPCE,
    PTR_BCS_EAN8,
    PTR_BCS_EAN13,
    PTR_BCS_ITF,
    PTR_BCS_Codabar,
    PTR_BCS_Code39,
    PTR_BCS_Code93,
    PTR_BCS_Code128,
    PTR_BCS_PDF417,
    PTR_BCS_QRCODE: Result := True;
  else
    Result := False;
  end;
end;

procedure TPosPrinterPosiflex.PrintBarCodeEsc(Barcode: TPosBarcode);
var
  PDF417: TPDF417;
  BarcodeType: Integer;
  Justification: Integer;
begin
  FPrinter.SetBarcodeHeight(Barcode.Height);
  FPrinter.SetBarcodeWidth(Barcode.Width);
  // Alignment
  case Barcode.Alignment of
    PTR_BC_LEFT: Justification := JUSTIFICATION_LEFT;
    PTR_BC_CENTER: Justification := JUSTIFICATION_CENTER;
    PTR_BC_RIGHT: Justification := JUSTIFICATION_RIGHT;
  else
    Justification := JUSTIFICATION_CENTER;
  end;

  // textPosition
  case Barcode.TextPosition of
    PTR_BC_TEXT_NONE: FPrinter.SetHRIPosition(HRI_NOT_PRINTED);
    PTR_BC_TEXT_ABOVE: FPrinter.SetHRIPosition(HRI_ABOVE_BARCODE);
    PTR_BC_TEXT_BELOW: FPrinter.SetHRIPosition(HRI_BELOW_BARCODE);
  end;
  // Symbology
  if Is2DBarcode(Barcode.Symbology) then
  begin
    if (Barcode.Symbology = PTR_BCS_PDF417)or(Barcode.Symbology = PTR_BCS_QRCODE) then
    begin
      FPrinter.PrintAndFeed(10);
      FPrinter.SetJustification(Justification);
    end;

    case Barcode.Symbology of
      PTR_BCS_PDF417:
      begin
        PDF417.RowNumber := 1;
        PDF417.ColumnNumber := 4;
        PDF417.ErrorCorrectionLevel := 0;
        PDF417.ModuleWidth := 3;
        PDF417.ModuleHeight := 100;
        PDF417.Options := PDF417_OPTIONS_STANDARD;
        PDF417.data := Barcode.Data;
        FPrinter.printPDF417(PDF417);
      end;
      PTR_BCS_QRCODE: PrintBarCodeEscQRCode(Barcode.Data);
    else
      RaiseIllegalError('Symbology not supported');
    end;

    if (Barcode.Symbology = PTR_BCS_PDF417)or(Barcode.Symbology = PTR_BCS_QRCODE) then
    begin
      FPrinter.PrintAndFeed(10);
      FPrinter.SetJustification(JUSTIFICATION_LEFT);
    end;
  end else
  begin
    BarcodeType := BARCODE2_CODE128;
    case Barcode.Symbology of
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

    case Barcode.Symbology of
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
        FPrinter.PrintBarcode2(BarcodeType, Barcode.Data);
      end;
    else
      RaiseIllegalError('Symbology not supported');
    end;
  end;
end;

procedure TPosPrinterPosiflex.PrintBarCodeEscQRCode(const Data: string);
var
  QRCode: TQRCode;
begin
  QRCode.Model := 0;
  QRCode.ECLevel := PFX_QRCODE_ECL_7;
  QRCode.ModuleSize := 4;
  QRCode.Data := Data;
  FPrinter.printQRCode(QRCode);
end;

procedure TPosPrinterPosiflex.PrintGraphics(Graphic: TGraphic; Width, Alignment: Integer);
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

function TPosPrinterPosiflex.PrintMemoryBitmap(Station: Integer;
  const Data: WideString; Type_, Width, Alignment: Integer): Integer;
begin
  try
    CheckRecStation(Station);
    UpdatePageMode;

    PrintMemoryGraphic(Data, Type_, Width, Alignment);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

procedure TPosPrinterPosiflex.UpdatePageMode;
var
  Count: Integer;
begin
  if not FPageMode.IsActive then Exit;
  if not EscPrinterUtils.IsEqual(FPageModePrintArea, FPageMode.PrintArea) then
  begin
    Printer.SetPageModeArea(FPageModePrintArea);
    FPageMode.PrintArea := FPageModePrintArea;
  end;
  if FPageModePrintDirection <> FPageMode.PrintDirection then
  begin
    Printer.SetPageModeDirection(FPageModePrintDirection-1);
    FPageMode.PrintDirection := FPageModePrintDirection;
  end;
  if FPageModeVerticalPosition <> FPageMode.VerticalPosition then
  begin
    FPrinter.SetPMAbsoluteVerticalPosition(FPageModeVerticalPosition);
    FPageMode.VerticalPosition := FPageModeVerticalPosition;
  end;
  if FPageModeHorizontalPosition <> FPageMode.HorizontalPosition then
  begin
    Count := FPageModeHorizontalPosition div 12;
    FPrinter.PrintText(StringOfChar(' ', Count));
    FPageMode.HorizontalPosition := FPageModeHorizontalPosition;
  end;
end;

function TPosPrinterPosiflex.PrintNormal(Station: Integer;
  const Data: WideString): Integer;
begin
  try
    CheckEnabled;
    CheckRecStation(Station);
    UpdatePageMode;
    PrintText(Data);
    Result := ClearResult;
  except
    on E: Exception do
      Result := HandleException(E);
  end;
end;

procedure TPosPrinterPosiflex.Set_CharacterSet(pCharacterSet: Integer);
var
  CodePage: Integer;
begin
  if IsValidCharacterSet(pCharacterSet) then
  begin
    FCharacterSet := pCharacterSet;

    CodePage := CharacterSetToPrinterCodePage(CharacterSet);
    FPrinter.SetCodePage(CodePage);
  end;
end;

procedure TPosPrinterPosiflex.Set_DeviceEnabled(pDeviceEnabled: WordBool);
begin
  try
    if pDeviceEnabled <> FDevice.DeviceEnabled then
    begin
      if pDeviceEnabled then
      begin
        FPort.Open;
        InitializeDevice;
        UpdatePrinterStatus;

        if FPrinter.CapRead then
        begin
          FDeviceDescription := Tnt_WideFormat('%s %s %s %s', [
            FPrinter.ReadManufacturer, FPrinter.ReadPrinterName,
            FPrinter.ReadFirmwareVersion, FPrinter.ReadSerialNumber]);
          if PollEnabled then StartDeviceThread;
        end;
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

procedure TPosPrinterPosiflex.CheckPaperPresent;
begin
  if not FCapRecPresent then Exit;
  if not FCapRecEmptySensor then Exit;
  if not FPrinter.CapRead then Exit;

  FDevice.CheckOnline;
  SetRecEmpty(not FPrinter.ReadPaperStatus.PaperPresent);

  if FRecEmpty then
    RaiseExtendedError(OPOS_EPTR_REC_EMPTY, 'Receipt station is empty');
end;

procedure TPosPrinterPosiflex.CheckCoverClosed;
begin
  if not FCapCoverSensor then Exit;
  if not FPrinter.CapRead then Exit;

  FDevice.CheckOnline;
  SetCoverState(FPrinter.ReadOfflineStatus.CoverOpened);
  if FCoverOpened then
    RaiseExtendedError(OPOS_EPTR_COVER_OPEN, 'Cover is opened');
end;

procedure TPosPrinterPosiflex.UpdatePrinterStatus;
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

procedure TPosPrinterPosiflex.UpdatePrinterStatus2;
var
  ErrorStatus: TErrorStatus;
  OfflineStatus: TOfflineStatus;
begin
  if not FPrinter.CapRead then Exit;

  try
    OfflineStatus := FPrinter.ReadOfflineStatus;
    SetCoverState(OfflineStatus.CoverOpened);
    SetRecEmpty(not FPrinter.ReadPaperStatus.PaperPresent);
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

procedure TPosPrinterPosiflex.InitializeDevice;
begin
  FPrinter.Initialize;
  FPrinter.CancelKanjiCharacter;
  FPrinter.SetCodePage(CODEPAGE_WCP1251);
  FPrinter.SetCharacterFont(FONT_TYPE_A);
  if FontName = FontNameB then
  begin
    FLastPrintMode := [pmFontB];
    FPrinter.SetCharacterFont(FONT_TYPE_B);
  end;
  UpdateLineSpacing;
end;

procedure TPosPrinterPosiflex.DeviceProc(Sender: TObject);
var
  TickCount: DWORD;
begin
  try
    while not FThread.Terminated do
    begin
      try
        UpdatePrinterStatus2;
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

procedure TPosPrinterPosiflex.Set_PageModeHorizontalPosition(
  pPageModeHorizontalPosition: Integer);
begin
  FPageModeHorizontalPosition := MapToDots(pPageModeHorizontalPosition, MapMode);
end;

procedure TPosPrinterPosiflex.Set_PageModePrintArea(
  const pPageModePrintArea: WideString);
begin
  FPageModePrintArea := PageAreaToDots(StrToPageArea(pPageModePrintArea), MapMode);
end;

procedure TPosPrinterPosiflex.Set_PageModeVerticalPosition(
  pPageModeVerticalPosition: Integer);
begin
  FPageModeVerticalPosition := MapToDots(pPageModeVerticalPosition, MapMode);
end;

procedure TPosPrinterPosiflex.Set_RecLineChars(pRecLineChars: Integer);
begin
  if pRecLineChars in [20..42] then
  begin
    FRecLineChars := pRecLineChars;
    FRecLineWidth := FRecLineChars * 12;
    FPageModeArea.X := RecLineWidth;
  end;
end;

procedure TPosPrinterPosiflex.Set_RecLineHeight(pRecLineHeight: Integer);
var
  RecLineHeightInDots: Integer;
begin
  RecLineHeightInDots := MapToDots(pRecLineHeight, MapMode);
  if (RecLineHeightInDots >= 24) then
  begin
    FRecLineHeight := 24
  end else
  begin
    FRecLineHeight := 17;
  end;
end;

procedure TPosPrinterPosiflex.Set_RecLineSpacing(pRecLineSpacing: Integer);
var
  RecLineSpacingInDots: Integer;
begin
  RecLineSpacingInDots := MapToDots(pRecLineSpacing, MapMode);
  if RecLineSpacingInDots <> FRecLineSpacing then
  begin
    if (RecLineSpacingInDots >= RecLineHeight + MinLineSpacing) then
    begin
      FRecLineSpacing := RecLineSpacingInDots;
      UpdateLineSpacing;
    end;
  end;
end;

procedure TPosPrinterPosiflex.UpdateLineSpacing;
var
  LineSpacing: Integer;
begin
  if (FRecLineSpacing >= 0)and(FRecLineSpacing <= $FF) then
  begin
    LineSpacing := (FRecLineSpacing - RecLineHeight)*2;
    if LineSpacing < 0 then
      LineSpacing := 0;
    FPrinter.SetLineSpacing(LineSpacing);
  end;
end;

function TPosPrinterPosiflex.TransactionPrint(Station,
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

procedure TPosPrinterPosiflex.DirectIOEvent(Sender: TObject;
  EventNumber: Integer; var pData: Integer; var pString: WideString);
begin
  if Assigned(FOnDirectIOEvent) then
    FOnDirectIOEvent(Self, EventNumber, pData, pString);
end;

procedure TPosPrinterPosiflex.ErrorEvent(Sender: TObject;
  ResultCode, ResultCodeExtended, ErrorLocus: Integer; var pErrorResponse: Integer);
begin
  if Assigned(FOnErrorEvent) then
    FOnErrorEvent(Self, ResultCode, ResultCodeExtended, ErrorLocus, pErrorResponse);
end;

function TPosPrinterPosiflex.GetToken(var Text: WideString; var Token: TEscToken): Boolean;
var
  P: Integer;
begin
  Result := False;
  if Length(Text) = 0 then Exit;

  Result := True;
  P := Pos(ESC + '|', Text);
  Token.IsEsc := P = 1;
  if P = 0 then
  begin
    Token.Text := Text;
    Text := '';
  end else
  begin
    if P = 1 then
    begin
      Token.Text := Copy(Text, 1, 4);
      Text := Copy(Text, 5, Length(Text));
    end else
    begin
      Token.Text := Copy(Text, 1, P-1);
      Text := Copy(Text, P, Length(Text));
    end;
  end;
end;

procedure TPosPrinterPosiflex.PrintText(Text: WideString);
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

procedure TPosPrinterPosiflex.PrintWideString(const AText: WideString);
var
  CodePage: Integer;
begin
  case CharacterSet of
    PTR_CS_UNICODE,
    PTR_CS_WINDOWS: FPrinter.PrintUnicode(AText);
  else
    CodePage := CharacterSetToCodePage(CharacterSet);
    FPrinter.PrintText(WideStringToAnsiString(CodePage, AText));
  end;
end;

end.

unit PosPrinterOA48;

interface

uses
  // VCL
  Windows, Classes, SysUtils, Graphics, Math, Jpeg, GifImage,
  // Tnt
  TntClasses,
  // Opos
  Opos, OposEsc, OposPtr, OposException, OposServiceDevice19, OposEvents,
  OposPOSPrinter_CCO_TLB, UserError, OposPtrUtils, PtrDirectIO,
  // This
  LogFile, DriverError, EscPrinterOA48, PrinterPort, NotifyThread,
  RegExpr, SerialPort, BarcodeUtils, StringUtils,
  DebugUtils, EscPrinterUtils, ComUtils, OposEventsAdapter, CustomPosPrinter;

type
  { TPosPrinterOA48 }

  TPosPrinterOA48 = class(TCustomPosPrinter)
  private
    FPrinter: TEscPrinterOA48;
    FPageModeArea: WideString;
    FPageModePrintArea: WideString;
    FUtf8Enabled: Boolean;
    FPrinterCodePage: Integer;
    function CharSetToPrinterCP(CharacterSet: Integer): Integer;
  public
    procedure PrintWideString(const AText: WideString); override;
    procedure Initialize; override;
    procedure PrintGraphics(Graphic: TGraphic; Width, Alignment: Integer); override;
    procedure DeviceProc(Sender: TObject); override;
    procedure UpdatePrinterStatus; override;
    property Printer: TEscPrinterOA48 read FPrinter;
    procedure PrintText(Text: WideString); override;
    procedure InitializeDevice; override;
    procedure CheckPaperPresent; override;
    procedure CheckCoverClosed; override;
  public
    constructor Create(APort: IPrinterPort; ALogger: ILogFile);
    destructor Destroy; override;
  public
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
    procedure DataEvent(Sender: TObject; Status: Integer);
    procedure DirectIOEvent(Sender: TObject; EventNumber: Integer;
      var pData: Integer; var pString: WideString); override;
    procedure ErrorEvent(Sender: TObject; ResultCode: Integer; ResultCodeExtended: Integer;
      ErrorLocus: Integer; var pErrorResponse: Integer); override;
    property Utf8Enabled: Boolean read FUtf8Enabled write FUtf8Enabled;
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

  FThread.Free;
  FDevice.Free;
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

// IOPOSPOSPrinter

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

function TPosPrinterOA48.CutPaper(Percentage: Integer): Integer;
begin
  try
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


function TPosPrinterOA48.Get_PageModeArea: WideString;
begin
  Result := FPageModeArea;
end;

function TPosPrinterOA48.Get_PageModeHorizontalPosition: Integer;
begin
  Result := FPageModeHorizontalPosition;
end;

function TPosPrinterOA48.Get_PageModePrintArea: WideString;
begin
  Result := FPageModePrintArea;
end;

function TPosPrinterOA48.Get_PageModeVerticalPosition: Integer;
begin
  Result := FPageModeVerticalPosition;
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
  DistanceToCutterInDots = 90;
begin
  Result := DistanceToCutterInDots div RecLineSpacing;
end;

function TPosPrinterOA48.Get_RecLineWidth: Integer;
begin
  Result := FRecLineWidth;
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

procedure TPosPrinterOA48.Set_PageModeVerticalPosition(
  pPageModeVerticalPosition: Integer);
begin
  FPageModeVerticalPosition := pPageModeVerticalPosition;
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

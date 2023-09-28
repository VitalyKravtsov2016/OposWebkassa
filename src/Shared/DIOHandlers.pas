unit DIOHandlers;

interface

uses
  // VCL
  Classes, SysUtils, Graphics, Extctrls,
  // 3'd
  TntSysUtils, TntClasses,
  // This
  DIOHandler, DirectIOAPI, LogFile, PrinterParameters,
  OposUtils, OposFptrUtils, WException, gnugettext, WebkassaImpl,
  StringUtils, PrinterTypes;

const
  ValueDelimiters = [';'];

type
  { TDIOHandler2 }

  TDIOHandler2 = class(TDIOHandler)
  private
    FPrinter: TWebkassaImpl;
    function GetParameters: TPrinterParameters;
  public
    constructor CreateCommand(AOwner: TDIOHandlers; ACommand: Integer;
      APrinter: TWebkassaImpl);

    property Printer: TWebkassaImpl read FPrinter;
    property Parameters: TPrinterParameters read GetParameters;
  end;

  { TDIOBarcode }

  TDIOBarcode = class(TDIOHandler2)
  public
    procedure DirectIO(var pData: Integer; var pString: WideString); override;
  end;

  { TDIOBarcodeHex }

  TDIOBarcodeHex = class(TDIOHandler2)
  public
    procedure DirectIO(var pData: Integer; var pString: WideString); override;
  end;

  { TDIOBarcodeHex2 }

  TDIOBarcodeHex2 = class(TDIOHandler2)
  public
    procedure DirectIO(var pData: Integer; var pString: WideString); override;
  end;

  { TDIOPrintText }

  TDIOPrintText = class(TDIOHandler2)
  public
    procedure DirectIO(var pData: Integer; var pString: WideString); override;
  end;

  { TDIOPrintHeader }

  TDIOPrintHeader = class(TDIOHandler2)
  public
    procedure DirectIO(var pData: Integer; var pString: WideString); override;
  end;

  { TDIOPrintTrailer }

  TDIOPrintTrailer = class(TDIOHandler2)
  public
    procedure DirectIO(var pData: Integer; var pString: WideString); override;
  end;

  { TDIOGetDriverParameter }

  TDIOGetDriverParameter = class(TDIOHandler2)
  public
    procedure DirectIO(var pData: Integer; var pString: WideString); override;
  end;

  { TDIOSetDriverParameter }

  TDIOSetDriverParameter = class(TDIOHandler2)
  public
    procedure DirectIO(var pData: Integer; var pString: WideString); override;
  end;

  { TDIOPrintReceiptDuplicate }

  TDIOPrintReceiptDuplicate = class(TDIOHandler2)
  public
    procedure DirectIO(var pData: Integer; var pString: WideString); override;
  end;

implementation

function BoolToStr(Value: Boolean): WideString;
begin
  if Value then Result := '1'
  else Result := '0';
end;

function StrToBool(const Value: WideString): Boolean;
begin
  Result := Value <> '0';
end;

{ TDIOHandler2 }

constructor TDIOHandler2.CreateCommand(AOwner: TDIOHandlers;
  ACommand: Integer; APrinter: TWebkassaImpl);
begin
  inherited Create(AOwner, ACommand);
  FPrinter := APrinter;
end;

function TDIOHandler2.GetParameters: TPrinterParameters;
begin
  Result := Printer.Params;
end;

{ TDIOBarcode }

procedure TDIOBarcode.DirectIO(var pData: Integer;
  var pString: WideString);
var
  Barcode: TBarcodeRec;
begin
  if Pos(';', pString) = 0 then
  begin
    Barcode.BarcodeType := pData;
    Barcode.Data := pString;
    Barcode.Text := pString;
    Barcode.Height := 100;
    Barcode.ModuleWidth := 3;
    Barcode.Alignment := 0;
    Barcode.Parameter1 := 0;
    Barcode.Parameter2 := 0;
    Barcode.Parameter3 := 0;
    Barcode.Parameter4 := 0;
    Barcode.Parameter5 := 0;
  end else
  begin
    Barcode.BarcodeType := pData;
    Barcode.Data := GetString(pString, 1, ValueDelimiters);
    Barcode.Text := GetString(pString, 2, ValueDelimiters);
    Barcode.Height := GetInteger(pString, 3, ValueDelimiters);
    Barcode.ModuleWidth := GetInteger(pString, 4, ValueDelimiters);
    Barcode.Alignment := GetInteger(pString, 5, ValueDelimiters);
    Barcode.Parameter1 := GetInteger(pString, 6, ValueDelimiters);
    Barcode.Parameter2 := GetInteger(pString, 7, ValueDelimiters);
    Barcode.Parameter3 := GetInteger(pString, 8, ValueDelimiters);
    Barcode.Parameter4 := GetInteger(pString, 9, ValueDelimiters);
    Barcode.Parameter5 := GetInteger(pString, 10, ValueDelimiters);
  end;
  Printer.PrintBarcode(BarcodeToStr(Barcode));
end;

{ TDIOBarcodeHex }

procedure TDIOBarcodeHex.DirectIO(var pData: Integer;
  var pString: WideString);
var
  Barcode: TBarcodeRec;
begin
  if Pos(';', pString) = 0 then
  begin
    Barcode.BarcodeType := pData;
    Barcode.Data := HexToStr(pString);
    Barcode.Text := pString;

    (*
    Barcode.Height := Printer.Params.BarcodeHeight;
    Barcode.ModuleWidth := Printer.Params.BarcodeModuleWidth;
    Barcode.Alignment := Printer.Params.BarcodeAlignment;
    Barcode.Parameter1 := Printer.Params.BarcodeParameter1;
    Barcode.Parameter2 := Printer.Params.BarcodeParameter2;
    Barcode.Parameter3 := Printer.Params.BarcodeParameter3;
    *)
  end else
  begin
    Barcode.BarcodeType := pData;
    Barcode.Data := HexToStr(GetString(pString, 1, ValueDelimiters));
    Barcode.Text := GetString(pString, 2, ValueDelimiters);
    Barcode.Height := GetInteger(pString, 3, ValueDelimiters);
    Barcode.ModuleWidth := GetInteger(pString, 4, ValueDelimiters);
    Barcode.Alignment := GetInteger(pString, 5, ValueDelimiters);
    Barcode.Parameter1 := GetInteger(pString, 6, ValueDelimiters);
    Barcode.Parameter2 := GetInteger(pString, 7, ValueDelimiters);
    Barcode.Parameter3 := GetInteger(pString, 8, ValueDelimiters);
  end;
  Printer.PrintBarcode(BarcodeToStr(Barcode));
end;

{ TDIOBarcodeHex2 }

procedure TDIOBarcodeHex2.DirectIO(var pData: Integer;
  var pString: WideString);
var
  Barcode: TBarcodeRec;
begin
  if Pos(';', pString) = 0 then
  begin
    Barcode.BarcodeType := pData;
    Barcode.Data := HexToStr(pString);
    Barcode.Text := pString;

    (*
    Barcode.Height := Printer.Params.BarcodeHeight;
    Barcode.ModuleWidth := Printer.Params.BarcodeModuleWidth;
    Barcode.Alignment := Printer.Params.BarcodeAlignment;
    Barcode.Parameter1 := Printer.Params.BarcodeParameter1;
    Barcode.Parameter2 := Printer.Params.BarcodeParameter2;
    Barcode.Parameter3 := Printer.Params.BarcodeParameter3;
    Barcode.Parameter4 := Printer.Params.BarcodeParameter4;
    Barcode.Parameter5 := Printer.Params.BarcodeParameter5;
    *)
  end else
  begin
    Barcode.BarcodeType := pData;
    Barcode.Data := HexToStr(GetString(pString, 1, ValueDelimiters));
    Barcode.Text := HexToStr(GetString(pString, 2, ValueDelimiters));
    Barcode.Height := GetInteger(pString, 3, ValueDelimiters);
    Barcode.ModuleWidth := GetInteger(pString, 4, ValueDelimiters);
    Barcode.Alignment := GetInteger(pString, 5, ValueDelimiters);
    Barcode.Parameter1 := GetInteger(pString, 6, ValueDelimiters);
    Barcode.Parameter2 := GetInteger(pString, 7, ValueDelimiters);
    Barcode.Parameter3 := GetInteger(pString, 8, ValueDelimiters);
    Barcode.Parameter4 := GetInteger(pString, 9, ValueDelimiters);
    Barcode.Parameter5 := GetInteger(pString, 10, ValueDelimiters);
  end;
  Printer.PrintBarcode(BarcodeToStr(Barcode));
end;

{ TDIOPrintText }

procedure TDIOPrintText.DirectIO(var pData: Integer;
  var pString: WideString);
(*
var
  Data: TTextRec;
*)  
begin
(*
  Data.Text := pString;
  Data.Station := Printer.Printer.Station;
  Data.Font := pData;
  Data.Alignment := taLeft;
  Data.Wrap := Printer.Parameters.WrapText;
  Printer.PrintText(Data);
*)
end;

{ TDIOPrintHeader }

procedure TDIOPrintHeader.DirectIO(var pData: Integer;
  var pString: WideString);
begin
  //Printer.PrintHeader; !!!
end;

{ TDIOPrintTrailer }

procedure TDIOPrintTrailer.DirectIO(var pData: Integer;
  var pString: WideString);
begin
  //Printer.PrintHeader; !!!
end;

{ TDIOGetDriverParameter }

procedure TDIOGetDriverParameter.DirectIO(var pData: Integer;
  var pString: WideString);
begin
  case pData of
    DriverParameterPrintEnabled: pString := BoolToStr(Printer.Params.PrintEnabled);
    DriverParameterBarcode: pString := Printer.Receipt.Barcode;
    DriverParameterExternalCheckNumber: pString := Printer.ExternalCheckNumber;
    DriverParameterFiscalSign: pString := Printer.Receipt.FiscalSign;
  end;
end;

{ TDIOSetDriverParameter }

procedure TDIOSetDriverParameter.DirectIO(var pData: Integer;
  var pString: WideString);
begin
  case pData of
    DriverParameterPrintEnabled: Printer.Params.PrintEnabled := StrToBool(pString);
    DriverParameterBarcode: Printer.Receipt.Barcode := pString;
    DriverParameterExternalCheckNumber:
    begin
      if pString <> '' then
        Printer.ExternalCheckNumber := pString;
    end;
    DriverParameterFiscalSign: Printer.Receipt.FiscalSign := pString;
  end;
end;

{ TDIOPrintReceiptDuplicate }

procedure TDIOPrintReceiptDuplicate.DirectIO(var pData: Integer;
  var pString: WideString);
begin
  Printer.PrintReceiptDuplicate2(pString);
end;

end.

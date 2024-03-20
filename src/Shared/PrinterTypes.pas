unit PrinterTypes;

interface

uses
  // VCL
  SysUtils,
  // This
  StringUtils;

type
  { TBarcodeRec }

  TBarcodeRec = record
    Data: WideString; // barcode data
    Text: WideString; // barcode text
    Width: Integer;
    Height: Integer;
    BarcodeType: Integer;
    ModuleWidth: Integer;
    Alignment: Integer;
    Parameter1: Byte;
    Parameter2: Byte;
    Parameter3: Byte;
    Parameter4: Byte;
    Parameter5: Byte;
  end;

const
  ValueDelimiters = [';'];

  CRLF = #13#10;

  /////////////////////////////////////////////////////////////////////////////
  // Template item style

  STYLE_NORMAL        = 0;
  STYLE_BOLD          = 1;
  STYLE_ITALIC        = 2;
  STYLE_DWIDTH        = 3;
  STYLE_DHEIGHT       = 4;
  STYLE_DWIDTH_HEIGHT = 5;
  STYLE_QR_CODE       = 6;
  STYLE_IMAGE         = 7;
  STYLE_BARCODE       = 8;

  /////////////////////////////////////////////////////////////////////////////
  // Template item types

  TEMPLATE_TYPE_TEXT            = 0;
  TEMPLATE_TYPE_PARAM           = 1;
  TEMPLATE_TYPE_ITEM_FIELD      = 2;
  TEMPLATE_TYPE_JSON_REQ_FIELD  = 3;
  TEMPLATE_TYPE_JSON_ANS_FIELD  = 4;
  TEMPLATE_TYPE_JSON_REC_FIELD  = 5;
  TEMPLATE_TYPE_SEPARATOR       = 6;
  TEMPLATE_TYPE_NEWLINE         = 7;

  /////////////////////////////////////////////////////////////////////////////
  // Alignment constants

  ALIGN_LEFT    = 0;
  ALIGN_CENTER  = 1;
  ALIGN_RIGHT   = 2;

  /////////////////////////////////////////////////////////////////////////////
  // Enabled constants

  TEMPLATE_ITEM_ENABLED             = 0;
  TEMPLATE_ITEM_ENABLED_IF_NOT_ZERO = 1;

function StrToBarcode(const Data: string): TBarcodeRec;
function BarcodeToStr(const Barcode: TBarcodeRec): string;

implementation

function StrToBarcode(const Data: string): TBarcodeRec;
begin
  Result.Data := GetString(Data, 1, ValueDelimiters);
  Result.Text := GetString(Data, 2, ValueDelimiters);
  Result.Height := GetInteger(Data, 3, ValueDelimiters);
  Result.BarcodeType := GetInteger(Data, 4, ValueDelimiters);
  Result.ModuleWidth := GetInteger(Data, 5, ValueDelimiters);
  Result.Alignment := GetInteger(Data, 6, ValueDelimiters);
  Result.Parameter1 := GetInteger(Data, 7, ValueDelimiters);
  Result.Parameter2 := GetInteger(Data, 8, ValueDelimiters);
  Result.Parameter3 := GetInteger(Data, 9, ValueDelimiters);
  Result.Parameter4 := GetInteger(Data, 10, ValueDelimiters);
  Result.Parameter5 := GetInteger(Data, 11, ValueDelimiters);
  Result.Width := GetInteger(Data, 12, ValueDelimiters);
end;

function BarcodeToStr(const Barcode: TBarcodeRec): string;
begin
  Result := Format('%s;%s;%d;%d;%d;%d;%d;%d;%d',[
    Barcode.Data,
    Barcode.Text,
    Barcode.Height,
    Barcode.BarcodeType,
    Barcode.ModuleWidth,
    Barcode.Alignment,
    Barcode.Parameter1,
    Barcode.Parameter2,
    Barcode.Parameter3,
    Barcode.Parameter4,
    Barcode.Parameter5]);
end;


end.

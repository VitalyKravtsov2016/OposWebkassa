unit BarcodeUtils;

interface

uses
  // VCL
  Types, Classes, SysUtils, Graphics,
  // Opos
  OposPtr,
  // This
  uZintBarcode, uZintInterface, UserError;

type
  { TPosBarcode }

  TPosBarcode = record
    Data: AnsiString;
    Symbology: Integer;
    Height: Integer;
    Width: Integer;
    Alignment: Integer;
    TextPosition: Integer;
  end;


procedure ScaleGraphic(Graphic: TGraphic; Scale: Integer);
procedure LoadMemoryGraphic(Graphic: TGraphic; const Data: AnsiString);
procedure RenderBarcode(Bitmap: TBitmap; Symbol: PZintSymbol; Is1D: Boolean);
procedure RenderBarcodeToBitmap(var Barcode: TPosBarcode; Bitmap: TBitmap);

function BitmapToStr(Bitmap: TBitmap): AnsiString;
function RenderBarcodeRec(var Barcode: TPosBarcode): AnsiString;

implementation

procedure LoadMemoryGraphic(Graphic: TGraphic; const Data: AnsiString);
var
  Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  try
    Stream.Write(Data[1], Length(Data));
    Stream.Position := 0;
    Graphic.LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;


procedure ScaleGraphic(Graphic: TGraphic; Scale: Integer);
var
  P: TPoint;
  DstBitmap: TBitmap;
begin
  if Scale <= 1 then Exit;

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

procedure RenderBarcode(Bitmap: TBitmap; Symbol: PZintSymbol; Is1D: Boolean);
var
  B: Byte;
  X, Y: Integer;
begin
  Bitmap.Monochrome := True;
  Bitmap.PixelFormat := pf1Bit;
  Bitmap.Width := Symbol.width;
  if Is1D then
    Bitmap.Height := Round(Symbol.Height)
  else
    Bitmap.Height := Round(Symbol.rows);

  for X := 0 to Bitmap.width-1 do
  for Y := 0 to Bitmap.Height-1 do
  begin
    Bitmap.Canvas.Pixels[X, Y] := clWhite;
    if Is1D then
      B := Byte(Symbol.encoded_data[0][X div 8])
    else
      B := Byte(Symbol.encoded_data[Y][X div 8]);

    if (B and (1 shl (X mod 8))) <> 0 then
      Bitmap.Canvas.Pixels[X, Y] := clBlack;
  end;
end;

function BTypeToZBType(BarcodeType: Integer): Integer;
begin
  case BarcodeType of
    PTR_BCS_UPCA: Result := BARCODE_UPCA;
    PTR_BCS_UPCE: Result := BARCODE_UPCE;
    PTR_BCS_EAN8: Result := BARCODE_EANX;
    PTR_BCS_EAN13: Result := BARCODE_EANX;
    PTR_BCS_TF: Result := BARCODE_C25INTER;
    PTR_BCS_ITF: Result := BARCODE_C25INTER;
    PTR_BCS_Codabar: Result := BARCODE_CODABAR;
    PTR_BCS_Code39: Result := BARCODE_CODE39;
    PTR_BCS_Code93: Result := BARCODE_CODE93;
    PTR_BCS_Code128: Result := BARCODE_CODE128;
    PTR_BCS_UPCA_S: Result := BARCODE_UPCA_CC;
    PTR_BCS_UPCE_S: Result := BARCODE_UPCE_CC;
    PTR_BCS_EAN8_S: Result := BARCODE_EANX;
    PTR_BCS_EAN13_S: Result := BARCODE_EANX;
    PTR_BCS_EAN128: Result := BARCODE_EANX;
    PTR_BCS_RSS14: Result := BARCODE_RSS14;
    PTR_BCS_RSS_EXPANDED: Result := BARCODE_RSS_EXP;
    PTR_BCS_PDF417: Result := BARCODE_PDF417;
    PTR_BCS_MAXICODE: Result := BARCODE_MAXICODE;
    PTR_BCS_DATAMATRIX: Result := BARCODE_DATAMATRIX;
    PTR_BCS_QRCODE: Result := BARCODE_QRCODE;
    PTR_BCS_UQRCODE: Result := BARCODE_MICROQR;
    PTR_BCS_AZTEC: Result := BARCODE_AZTEC;
    PTR_BCS_UPDF417: Result := BARCODE_MICROPDF417;
  else
    raise UserException.CreateFmt('Barcode type not supported, %d', [BarcodeType]);
  end;
end;

procedure RenderBarcodeToBitmap(var Barcode: TPosBarcode; Bitmap: TBitmap);
var
  Scale: Integer;
  Render: TZintBarcode;
begin
  if Barcode.Height = 0 then
  begin
    Barcode.Height := 100;
  end;
  if Barcode.Width = 0 then
  begin
    Barcode.Width := Barcode.Height;
  end;

  Render := TZintBarcode.Create;
  try
    Render.BorderWidth := 10;
    Render.FGColor := clBlack;
    Render.BGColor := clWhite;
    Render.Scale := 1;
    Render.Height := Barcode.Height;
    Render.BarcodeType := BTypeToZBType(Barcode.Symbology);
    Render.Data := Barcode.Data;
    Render.ShowHumanReadableText := False;
    Render.Option1 := 0;
    Render.EncodeNow;
    RenderBarcode(Bitmap, Render.Symbol, False);

    Scale := Round(Barcode.Width / Bitmap.Width);
    if not (Scale in [1..10]) then Scale := 1;
    ScaleGraphic(Bitmap, Scale);
    Barcode.Width  := Bitmap.Width;
    Barcode.Height  := Bitmap.Height;

  finally
    Render.Free;
  end;
end;

function BitmapToStr(Bitmap: TBitmap): AnsiString;
var
  Stream: TMemoryStream;
begin
  Result := '';
  Stream := TMemoryStream.Create;
  try
    Bitmap.SaveToStream(Stream);
    if Stream.Size > 0 then
    begin
      Stream.Position := 0;
      SetLength(Result, Stream.Size);
      Stream.ReadBuffer(Result[1], Stream.Size);
    end;
  finally
    Stream.Free;
  end;
end;


function RenderBarcodeRec(var Barcode: TPosBarcode): AnsiString;
var
  Bitmap: TBitmap;
begin
  Result := '';
  Bitmap := TBitmap.Create;
  try
    RenderBarcodeToBitmap(Barcode, Bitmap);
    Result := BitmapToStr(Bitmap);
  finally
    Bitmap.Free;
  end;
end;



end.

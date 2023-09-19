unit BarcodeUtils;

interface

uses
  // VCL
  Types, Graphics, uZintInterface;

procedure ScaleBitmap(Bitmap: TBitmap; Scale: Integer);
procedure RenderBarcode(Bitmap: TBitmap; Symbol: PZSymbol; Is1D: Boolean);

implementation

procedure ScaleBitmap(Bitmap: TBitmap; Scale: Integer);
var
  P: TPoint;
  DstBitmap: TBitmap;
begin
  DstBitmap := TBitmap.Create;
  try
    DstBitmap.Monochrome := True;
    DstBitmap.PixelFormat := pf1Bit;
    P.X := Bitmap.Width * Scale;
    P.Y := Bitmap.Height * Scale;
    DstBitmap.Width := P.X;
    DstBitmap.Height := P.Y;
    DstBitmap.Canvas.StretchDraw(Rect(0, 0, P.X, P.Y), Bitmap);
    Bitmap.Assign(DstBitmap);
  finally
    DstBitmap.Free;
  end;
end;

procedure RenderBarcode(Bitmap: TBitmap; Symbol: PZSymbol; Is1D: Boolean);
var
  B: Byte;
  X, Y: Integer;
begin
  Bitmap.Monochrome := True;
  Bitmap.PixelFormat := pf1Bit;
  Bitmap.Width := Symbol.width;
  if Is1D then
    Bitmap.Height := Symbol.Height
  else
    Bitmap.Height := Symbol.rows;

  for X := 0 to Symbol.width-1 do
  for Y := 0 to Symbol.Height-1 do
  begin
    Bitmap.Canvas.Pixels[X, Y] := clWhite;
    if Is1D then
      B := Byte(Symbol.encoded_data[0][X div 7])
    else
      B := Byte(Symbol.encoded_data[Y][X div 7]);

    if (B and (1 shl (X mod 7))) <> 0 then
      Bitmap.Canvas.Pixels[X, Y] := clBlack;
  end;
end;

end.

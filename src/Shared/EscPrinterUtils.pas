unit EscPrinterUtils;

interface

uses
  // VCL
  SysUtils, Graphics,
  // This
  TntGraphics, ByteUtils;

const
  KazakhUnicodeChars: array [0..17] of Integer = (
    1170, // cyrillic capital letter ghe stroke
    1171, // cyrillic small letter ghe stroke
    1178, // cyrillic capital letter ka descender
    1179, // cyrillic small letter ka descender
    1186, // cyrillic capital letter en descender
    1187, // cyrillic small letter en descender
    1198, // cyrillic capital letter straight u
    1199, // cyrillic small letter straight u
    1200, // cyrillic capital letter straight u stroke
    1201, // cyrillic small letter straight u stroke
    1210, // cyrillic capital letter shha
    1211, // cyrillic small letter shha
    1240, // cyrillic capital letter schwa
    1241, // cyrillic small letter schwa
    1256, // cyrillic capital letter barred o
    1257, // cyrillic small letter barred o
    1030,  // cyrillic capital letter byelorussian-ukrainian
    1110 // cyrillic small letter byelorussian-ukrainian
  );

procedure WriteKazakhCharactersToBitmap;
procedure DrawWideChar(AChar: WideChar; AFontSize: Byte;
  Bitmap: TBitmap; X, Y: Integer);
function IsKazakhUnicodeChar(Char: WideChar): Boolean;
function GetBitmapData(Bitmap: TBitmap; FontHeight: Integer): AnsiString;
function GetRasterImageData(Image: TGraphic): AnsiString;
function GetImageData2(Image: TGraphic): AnsiString;
procedure DrawImage(Image: TGraphic; Bitmap: TBitmap);


implementation

function IsKazakhUnicodeChar(Char: WideChar): Boolean;
var
  i: Integer;
  Code: Word;
begin
  for i := Low(KazakhUnicodeChars) to High(KazakhUnicodeChars) do
  begin
    Code := Word(Char);
    Result := Code = KazakhUnicodeChars[i];
    if Result then Break;
  end;
end;

procedure DrawWideChar(AChar: WideChar; AFontSize: Byte;
  Bitmap: TBitmap; X, Y: Integer);
begin
  Bitmap.Canvas.Font.Name := 'Courier New';
  //Bitmap.Canvas.Font.Style := Bitmap.Canvas.Font.Style + [fsBold];
  Bitmap.Canvas.Font.Size := AFontSize;
  TntGraphics.WideCanvasTextOut(Bitmap.Canvas, X, Y, AChar);
end;

procedure WriteKazakhCharactersToBitmap;
var
  i: Integer;
  C: WideChar;
  Bitmap: TBitmap;
begin
  Bitmap := TBitmap.Create;
  try
    Bitmap.Monochrome := True;
    Bitmap.PixelFormat := pf1Bit;

    // FONT_TYPE_A
    Bitmap.Width := 12 * Length(KazakhUnicodeChars);
    Bitmap.Height := 24;
    for i := Low(KazakhUnicodeChars) to High(KazakhUnicodeChars) do
    begin
      C := WideChar(KazakhUnicodeChars[i]);
      DrawWideChar(C, 16, Bitmap, i*12, 0);
    end;
    Bitmap.SaveToFile('KazakhFontA.bmp');

    // FONT_TYPE_B
    Bitmap.Width := 9 * Length(KazakhUnicodeChars);
    Bitmap.Height := 17;
    for i := Low(KazakhUnicodeChars) to High(KazakhUnicodeChars) do
    begin
      C := WideChar(KazakhUnicodeChars[i]);
      DrawWideChar(C, 14, Bitmap, i*12, 0);
    end;
    Bitmap.SaveToFile('KazakhFontB.bmp');
  finally
    Bitmap.Free;
  end;
end;

function GetBitmapData(Bitmap: TBitmap; FontHeight: Integer): AnsiString;
var
  B: Byte;
  Bit: Byte;
  x, y, k: Integer;
  mx, my: Integer;
begin
  Result := '';
  if Bitmap.Height < FontHeight then
    raise Exception.CreateFmt('Bitmap height < Font height, %d < %d', [
    Bitmap.Height, FontHeight]);

  mx := (Bitmap.Width + 7) div 8;
  my := (FontHeight + 7) div 8;
  for x := 1 to mx*8 do
  begin
    y := 1;
    for k := 1 to my do
    begin
      B := 0;
      for Bit := 0 to 7 do
      begin
        if x > Bitmap.Width then Break;
        if y > FontHeight then Break;

        if Bitmap.Canvas.Pixels[x-1, y-1] = clBlack then
        begin
          SetBit(B, 7-Bit);
        end;
        Inc(y);
      end;
      Result := Result + Chr(B);
    end;
  end;
end;

function GetRasterBitmapData(Bitmap: TBitmap): AnsiString;
var
  B: Byte;
  x, y: Integer;
  mx: Integer;
  Index: Integer;
begin
  mx := (Bitmap.Width + 7) div 8;
  Result := StringOfChar(#0, mx * Bitmap.Height);
  for y := 1 to Bitmap.Height do
  for x := 1 to mx*8 do
  begin
    if (x <= Bitmap.Width)and(y <= Bitmap.Height) then
    begin
      if Bitmap.Canvas.Pixels[x-1, y-1] = clBlack then
      begin
        Index := (y-1)*mx + ((x-1) div 8) + 1;
        B := Ord(Result[Index]);
        SetBit(B, (x-1) mod 8);
        Result[Index] := Chr(B);
      end;
    end;
  end;
  Result := SwapBytes(Result);
end;

function GetRasterImageData(Image: TGraphic): AnsiString;
var
  Bitmap: TBitmap;
begin
  Bitmap := TBitmap.Create;
  try
    Bitmap.Monochrome := True;
    Bitmap.PixelFormat := pf1Bit;
    Bitmap.Width := Image.Width;
    Bitmap.Height := Image.Height;
    Bitmap.Canvas.Draw(0, 0, Image);
    Result := GetRasterBitmapData(Bitmap);
  finally
    Bitmap.Free;
  end;
end;

procedure DrawImage(Image: TGraphic; Bitmap: TBitmap);
begin
  Bitmap.Monochrome := True;
  Bitmap.PixelFormat := pf1Bit;
  Bitmap.Width := Image.Width;
  Bitmap.Height := Image.Height;
  Bitmap.Canvas.Draw(0, 0, Image);
end;

function GetImageData2(Image: TGraphic): AnsiString;
var
  Bitmap: TBitmap;
begin
  Bitmap := TBitmap.Create;
  try
    DrawImage(Image, Bitmap);
    Result := GetBitmapData(Bitmap, Bitmap.Height);
  finally
    Bitmap.Free;
  end;
end;



end.

unit PrinterPage;

interface

uses
  // VCL
  Windows, Graphics,
  // JVCL
  JvUnicodeCanvas,
  // Opos
  OposPtr,
  // This
  EscPrinterUtils, PrinterTypes;

type
  { TPrinterPage }

  TPrinterPage = class
  private
    FBitmap: TBitmap;
    FIsActive: Boolean;
    FIsValid: Boolean;
    FStation: Integer;
    FPrintArea: TPageArea;
    FPrintDirection: Integer;
    FVerticalPosition: Integer;
    FHorizontalPosition: Integer;
    FLineSpacing: Integer;

    function GetCanvas: TCanvas;
    procedure SetPrintArea(const Value: TPageArea);
    procedure SetHorizontalPosition(const Value: Integer);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear;
    procedure Start;
    procedure FeedUnits(N: Integer);
    procedure FeedLines(N: Integer);
    procedure TextOut(const Line: WideString);
    procedure PrintGraphics(Graphic: TGraphic; Width, Alignment: Integer);
    function GetFontHeight: Integer;

    property Bitmap: TBitmap read FBitmap;
    property Canvas: TCanvas read GetCanvas;
    property IsActive: Boolean read FIsActive;
    property IsValid: Boolean read FIsValid;
    property Station: Integer read FStation write FStation;
    property PrintArea: TPageArea read FPrintArea write SetPrintArea;
    property LineSpacing: Integer read FLineSpacing write FLineSpacing;
    property PrintDirection: Integer read FPrintDirection write FPrintDirection;
    property VerticalPosition: Integer read FVerticalPosition write FVerticalPosition;
    property HorizontalPosition: Integer read FHorizontalPosition write SetHorizontalPosition;
  end;

implementation

{ TPrinterPage }

constructor TPrinterPage.Create;
const
  DefPageModePrintArea: TPageArea = (X: 0; Y: 0; Width: 0; Height: 0);
begin
  inherited Create;
  FBitmap := TBitmap.Create;
  FPrintDirection := 0;
  FVerticalPosition := 0;
  FHorizontalPosition := 0;
  FStation := PTR_S_RECEIPT;
  FPrintArea := DefPageModePrintArea;
end;

destructor TPrinterPage.Destroy;
begin
  FBitmap.Free;
  inherited Destroy;
end;

function TPrinterPage.GetCanvas: TCanvas;
begin
  Result := FBitmap.Canvas;
end;

procedure TPrinterPage.SetHorizontalPosition(const Value: Integer);
begin
  FHorizontalPosition := Value;
end;

procedure TPrinterPage.SetPrintArea(const Value: TPageArea);
begin
  FIsActive := True;
  FIsValid := False;
  FPrintArea := Value;
  FVerticalPosition := 0;
  FHorizontalPosition := 0;

  FBitmap.Free;
  FBitmap := TBitmap.Create;
  FBitmap.Monochrome := True;
  FBitmap.PixelFormat := pf1Bit;
  FBitmap.Width := FPrintArea.Width;
  FBitmap.Height := FPrintArea.Height;
end;

procedure TPrinterPage.Clear;
begin
  FIsActive := False;
  FIsValid := False;
  FPrintDirection := 0;
  FVerticalPosition := 0;
  FHorizontalPosition := 0;
end;

procedure TPrinterPage.Start;
begin
  Clear;
  FIsActive := True;
end;

procedure TPrinterPage.TextOut(const Line: WideString);
var
  i: Integer;
  TextSize: TSize;
  Canvas: TJvUnicodeCanvas;
begin
  Canvas := TJvUnicodeCanvas.Create;
  try
    Canvas.Handle := GetCanvas.Handle;
    Canvas.Font := GetCanvas.Font;

    for i := 1 to Length(Line) do
    begin
      TextSize := Canvas.TextExtentW(Line[i]);
      case Line[i] of
        CR: FHorizontalPosition := 0;
        LF: Inc(FVerticalPosition, TextSize.cy + LineSpacing);
      else
        Canvas.TextOutW(FHorizontalPosition, FVerticalPosition, Line[i]);
        Inc(FHorizontalPosition, TextSize.cx);
        if (FHorizontalPosition + TextSize.cx) >= FPrintArea.Width then
        begin
          FHorizontalPosition := 0;
          Inc(FVerticalPosition, TextSize.cy + LineSpacing);
        end;
      end;
    end;
    FIsValid := True;
  finally
    Canvas.Free;
  end;
end;

procedure TPrinterPage.PrintGraphics(Graphic: TGraphic; Width,
  Alignment: Integer);
var
  OffsetX: Integer;
begin
  OffsetX := 0;
  if Graphic.Width < FPrintArea.Width then
  begin
    if Alignment = PTR_BM_RIGHT then
      OffsetX := FPrintArea.Width - Graphic.Width;
    if Alignment = PTR_BM_CENTER then
      OffsetX := (FPrintArea.Width - Graphic.Width) div 2;
  end;
  GetCanvas.Draw(OffsetX, FVerticalPosition, Graphic);
  Inc(FVerticalPosition, Graphic.Height);
  FIsValid := True;
end;

function TPrinterPage.GetFontHeight: Integer;
var
  S: WideString;
  TextSize: TSize;
begin
  S := 'W';
  GetTextExtentPointW(Canvas.Handle, PWideChar(S), Length(S), TextSize);
  Result := TextSize.cy;
end;

procedure TPrinterPage.FeedLines(N: Integer);
begin
  Inc(FVerticalPosition, (GetFontHeight + LineSpacing)*N);
  if FVerticalPosition < 0 then
    FVerticalPosition := 0;
end;

procedure TPrinterPage.FeedUnits(N: Integer);
begin
  Inc(FVerticalPosition, N);
  if FVerticalPosition < 0 then
    FVerticalPosition := 0;
end;

end.

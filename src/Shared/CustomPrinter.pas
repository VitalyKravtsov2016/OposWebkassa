unit CustomPrinter;

interface

uses
  // VCL
  Graphics, Printers;

type
  { TCustomPrinter }

  TCustomPrinter = class
  public
    procedure EndDoc; virtual; abstract;
    procedure BeginDoc; virtual; abstract;
    function GetCanvas: TCanvas; virtual; abstract;
    function GetPrinterName: string; virtual; abstract;
    procedure SetPrinterName(const Value: string); virtual; abstract;

    property Canvas: TCanvas read GetCanvas;
    property PrinterName: string read GetPrinterName write SetPrinterName;
  end;

  { TWinPrinter }

  TWinPrinter = class(TCustomPrinter)
  private
    FPrinterName: string;
  public
    function GetCanvas: TCanvas; override;
    function GetPrinterName: string; override;

    procedure EndDoc; override;
    procedure BeginDoc; override;
    procedure SetPrinterName(const Value: string); override;

    property Canvas: TCanvas read GetCanvas;
    property PrinterName: string read GetPrinterName write SetPrinterName;
  end;

  { TEmfPrinter }

  TEmfPrinter = class(TCustomPrinter)
  private
    FPrinterName: string;
    FMetafile: TMetafile;
    FCanvas: TMetafileCanvas;
  public
    constructor Create;
    destructor Destroy; override;

    function GetCanvas: TCanvas; override;
    function GetPrinterName: string; override;
    procedure EndDoc; override;
    procedure BeginDoc; override;
    procedure SetPrinterName(const Value: string); override;

    property Canvas: TCanvas read GetCanvas;
    property Metafile: TMetafile read FMetafile;
    property PrinterName: string read GetPrinterName write SetPrinterName;
  end;

  { TBmpPrinter }

  TBmpPrinter = class(TCustomPrinter)
  private
    FBitmap: TBitmap;
    FPrinterName: string;
  public
    constructor Create;
    destructor Destroy; override;

    function GetCanvas: TCanvas; override;
    function GetPrinterName: string; override;
    procedure EndDoc; override;
    procedure BeginDoc; override;
    procedure SetPrinterName(const Value: string); override;

    property Bitmap: TBitmap read FBitmap;
    property Canvas: TCanvas read GetCanvas;
    property PrinterName: string read GetPrinterName write SetPrinterName;
  end;

implementation

{ TWinPrinter }

procedure TWinPrinter.BeginDoc;
begin
  Printer.BeginDoc;
end;

procedure TWinPrinter.EndDoc;
begin
  Printer.EndDoc;
end;

function TWinPrinter.GetCanvas: TCanvas;
begin
  Result := Printer.Canvas;
end;

function TWinPrinter.GetPrinterName: string;
begin
  Result := FPrinterName;
end;

procedure TWinPrinter.SetPrinterName(const Value: string);
begin
  FPrinterName := Value;
  Printer.PrinterIndex := Printer.Printers.IndexOf(Value);
end;

{ TEmfPrinter }

constructor TEmfPrinter.Create;
begin
  FMetafile := TMetafile.Create;
  FCanvas := TMetafileCanvas.Create(FMetafile, 0);
end;

destructor TEmfPrinter.Destroy;
begin
  FCanvas.Free;
  FMetafile.Free;
  inherited Destroy;
end;

procedure TEmfPrinter.BeginDoc;
begin
end;

procedure TEmfPrinter.EndDoc;
begin
end;

function TEmfPrinter.GetCanvas: TCanvas;
begin
  Result := FCanvas;
end;

function TEmfPrinter.GetPrinterName: string;
begin
  Result := FPrinterName;
end;

procedure TEmfPrinter.SetPrinterName(const Value: string);
begin
  FPrinterName := Value;
end;

{ TBmpPrinter }

constructor TBmpPrinter.Create;
begin
  FBitmap := TBitmap.Create;
  FBitmap.Monochrome := True;
  FBitmap.PixelFormat := pf1Bit;
  FBitmap.Width := 576;
  FBitmap.Height := 500;
end;

destructor TBmpPrinter.Destroy;
begin
  FBitmap.Free;
  inherited Destroy;
end;

procedure TBmpPrinter.BeginDoc;
begin
end;

procedure TBmpPrinter.EndDoc;
begin
end;

function TBmpPrinter.GetCanvas: TCanvas;
begin
  Result := Bitmap.Canvas;
end;

function TBmpPrinter.GetPrinterName: string;
begin
  Result := FPrinterName;
end;

procedure TBmpPrinter.SetPrinterName(const Value: string);
begin
  FPrinterName := Value;
end;

end.

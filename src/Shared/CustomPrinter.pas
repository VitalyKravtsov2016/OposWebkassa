unit CustomPrinter;

interface

uses
  // VCL
  Graphics, Printers,
  // Jcl
  JclPrint;

type
  { TCustomPrinter }

  TCustomPrinter = class
  public
    function Printing: Boolean; virtual;
    function GetPageWidth: Integer; virtual;
    function GetPageHeight: Integer; virtual;
    procedure EndDoc(Height: Integer); virtual; abstract;
    procedure BeginDoc; virtual; abstract;
    function GetCanvas: TCanvas; virtual; abstract;
    function GetPrinterName: string; virtual; abstract;
    procedure SetPrinterName(const Value: string); virtual; abstract;
    procedure Send(const Value: string); virtual;

    property Canvas: TCanvas read GetCanvas;
    property PrinterName: string read GetPrinterName write SetPrinterName;
  end;

  { TWinPrinter }

  TWinPrinter = class(TCustomPrinter)
  private
    FPrinterName: string;
  public
    function Printing: Boolean; override;
    function GetCanvas: TCanvas; override;
    function GetPrinterName: string; override;

    function GetPageHeight: Integer; override;
    function GetPageWidth: Integer; override;
    procedure EndDoc(Height: Integer); override;
    procedure BeginDoc; override;
    procedure SetPrinterName(const Value: string); override;
    procedure Send(const Value: string); override;

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
    procedure EndDoc(Height: Integer); override;
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

    function GetPageHeight: Integer; override;
    function GetPageWidth: Integer; override;
    function GetCanvas: TCanvas; override;
    function GetPrinterName: string; override;
    procedure EndDoc(Height: Integer); override;
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

procedure TWinPrinter.EndDoc(Height: Integer);
begin
  if Printer.Printing then
  begin
    Printer.EndDoc;
  end;
end;

function TWinPrinter.GetCanvas: TCanvas;
begin
  Result := Printer.Canvas;
end;

function TWinPrinter.GetPageHeight: Integer;
begin
  Result := Printer.PageHeight;
end;

function TWinPrinter.GetPageWidth: Integer;
begin
  Result := Printer.PageWidth;
end;

function TWinPrinter.GetPrinterName: string;
begin
  Result := FPrinterName;
end;

function TWinPrinter.Printing: Boolean;
begin
  Result := Printer.Printing;
end;

procedure TWinPrinter.Send(const Value: string);
begin
  DirectPrint(FPrinterName, Value);
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

procedure TEmfPrinter.EndDoc(Height: Integer);
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
  inherited Create;
  FBitmap := TBitmap.Create;
  FBitmap.Monochrome := True;
  FBitmap.PixelFormat := pf1Bit;
  FBitmap.Width := 576;
  FBitmap.Height := 2000;
end;

destructor TBmpPrinter.Destroy;
begin
  FBitmap.Free;
  inherited Destroy;
end;

procedure TBmpPrinter.BeginDoc;
begin
end;

procedure TBmpPrinter.EndDoc(Height: Integer);
begin
  Bitmap.Height := Height;
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

function TBmpPrinter.GetPageWidth: Integer;
begin
  Result := Bitmap.Width;
end;

function TBmpPrinter.GetPageHeight: Integer;
begin
  Result := Bitmap.Height;
end;

{ TCustomPrinter }

function TCustomPrinter.GetPageHeight: Integer;
begin
  Result := 0;
end;

function TCustomPrinter.GetPageWidth: Integer;
begin
  Result := 0;
end;

function TCustomPrinter.Printing: Boolean;
begin
  Result := True;
end;

procedure TCustomPrinter.Send(const Value: string);
begin

end;

end.

unit RawPrinterPort;

interface

uses
  // VCL
  Windows, SyncObjs,
  // Jcl
  JclPrint,
  // This
  PrinterPort;

type
  { TRawPrinterPort }

  TRawPrinterPort = class(TInterfacedObject, IPrinterPort)
  private
    FBuffer: AnsiString;
    FPrinterName: AnsiString;
    FLock: TCriticalSection;
  public
    constructor Create(const APrinterName: string);
    destructor Destroy; override;

    procedure Flush;
    procedure Purge;
    procedure Close;
    procedure Open;
    procedure Lock;
    procedure Unlock;
    procedure Write(const Data: AnsiString);
    function Read(Count: DWORD): AnsiString;
    function CapRead: Boolean;
  end;

implementation

{ TRawPrinterPort }

constructor TRawPrinterPort.Create(const APrinterName: string);
begin
  inherited Create;
  FLock := TCriticalSection.Create;
  FPrinterName := APrinterName;
end;

destructor TRawPrinterPort.Destroy;
begin
  FLock.Free;
  inherited Destroy;
end;

function TRawPrinterPort.CapRead: Boolean;
begin
  Result := False;
end;

procedure TRawPrinterPort.Close;
begin

end;

procedure TRawPrinterPort.Flush;
begin
  DirectPrint(FPrinterName, FBuffer);
  FBuffer := '';
end;

procedure TRawPrinterPort.Lock;
begin
  FLock.Enter;
end;

procedure TRawPrinterPort.Unlock;
begin
  FLock.Leave;
end;

procedure TRawPrinterPort.Open;
begin
  FBuffer := '';
end;

procedure TRawPrinterPort.Purge;
begin
  FBuffer := '';
end;

function TRawPrinterPort.Read(Count: DWORD): AnsiString;
begin

end;

procedure TRawPrinterPort.Write(const Data: AnsiString);
begin
  FBuffer := FBuffer + Data;
end;

end.

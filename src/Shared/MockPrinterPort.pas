unit MockPrinterPort;

interface

uses
  // VCL
  Windows, SyncObjs,
  // This
  PrinterPort;

type
  { TMockPrinterPort }

  TMockPrinterPort = class(TInterfacedObject, IPrinterPort)
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
    function GetDescription: WideString;

    property Buffer: AnsiString read FBuffer write FBuffer;
  end;

implementation

{ TMockPrinterPort }

constructor TMockPrinterPort.Create(const APrinterName: string);
begin
  inherited Create;
  FLock := TCriticalSection.Create;
  FPrinterName := APrinterName;
end;

destructor TMockPrinterPort.Destroy;
begin
  FLock.Free;
  inherited Destroy;
end;

function TMockPrinterPort.CapRead: Boolean;
begin
  Result := False;
end;

procedure TMockPrinterPort.Close;
begin

end;

procedure TMockPrinterPort.Flush;
begin
end;

procedure TMockPrinterPort.Lock;
begin
  FLock.Enter;
end;

procedure TMockPrinterPort.Unlock;
begin
  FLock.Leave;
end;

procedure TMockPrinterPort.Open;
begin
end;

procedure TMockPrinterPort.Purge;
begin
end;

function TMockPrinterPort.Read(Count: DWORD): AnsiString;
begin

end;

procedure TMockPrinterPort.Write(const Data: AnsiString);
begin
  FBuffer := FBuffer + Data;
end;

function TMockPrinterPort.GetDescription: WideString;
begin
  Result := 'MockPrinterPort';
end;

end.

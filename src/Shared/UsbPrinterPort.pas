unit UsbPrinterPort;

interface

uses
  // VCL
  Windows, SysUtils, SyncObjs,
  // Jcl
  JclPrint,
  // This
  PrinterPort, LogFile, StringUtils;

type
  { TUsbPrinterPort }

  TUsbPrinterPort = class(TInterfacedObject, IPrinterPort)
  private
    FLogger: ILogFile;
    FBuffer: AnsiString;
    FPrinterName: AnsiString;
    FLock: TCriticalSection;
  public
    constructor Create(ALogger: ILogFile; const APrinterName: string);
    destructor Destroy; override;

    procedure Flush; virtual;
    procedure Purge;
    procedure Close;
    procedure Open;
    procedure Lock;
    procedure Unlock;
    procedure Write(const Data: AnsiString);
    function Read(Count: DWORD): AnsiString;
    function CapRead: Boolean;
    function GetDescription: WideString;

    property Buffer: AnsiString read FBuffer;
  end;

implementation

{ TUsbPrinterPort }

constructor TUsbPrinterPort.Create(ALogger: ILogFile; const APrinterName: string);
begin
  inherited Create;
  FLogger := ALogger;
  FLock := TCriticalSection.Create;
  FPrinterName := APrinterName;
end;

destructor TUsbPrinterPort.Destroy;
begin
  FLock.Free;
  FLogger := nil;
  inherited Destroy;
end;

function TUsbPrinterPort.CapRead: Boolean;
begin
  Result := False;
end;

procedure TUsbPrinterPort.Close;
begin

end;

procedure TUsbPrinterPort.Flush;
begin
  try
    DirectPrint(FPrinterName, FBuffer);
  except
    on E: Exception do
    begin
      FLogger.Error('DirectPrint failed: ' + E.Message);
      raise;
    end;
  end;
  FBuffer := '';
end;

procedure TUsbPrinterPort.Lock;
begin
  FLock.Enter;
end;

procedure TUsbPrinterPort.Unlock;
begin
  FLock.Leave;
end;

procedure TUsbPrinterPort.Open;
begin

  FBuffer := '';
end;

procedure TUsbPrinterPort.Purge;
begin
  FBuffer := '';
end;

function TUsbPrinterPort.Read(Count: DWORD): AnsiString;
begin

end;

procedure TUsbPrinterPort.Write(const Data: AnsiString);
begin
  FBuffer := FBuffer + Data;
end;

function TUsbPrinterPort.GetDescription: WideString;
begin
  Result := 'RawPrinterPort';
end;

end.

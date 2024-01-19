unit RawPrinterPort;

interface

uses
  // VCL
  Windows, SysUtils, SyncObjs,
  // Jcl
  JclPrint,
  // This
  PrinterPort, LogFile, StringUtils;

type
  { TRawPrinterPort }

  TRawPrinterPort = class(TInterfacedObject, IPrinterPort)
  private
    FLogger: ILogFile;
    FBuffer: AnsiString;
    FPrinterName: AnsiString;
    FLock: TCriticalSection;
  public
    constructor Create(ALogger: ILogFile; const APrinterName: string);
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
  end;

implementation

{ TRawPrinterPort }

constructor TRawPrinterPort.Create(ALogger: ILogFile; const APrinterName: string);
begin
  inherited Create;
  FLogger := ALogger;
  FLock := TCriticalSection.Create;
  FPrinterName := APrinterName;
end;

destructor TRawPrinterPort.Destroy;
begin
  FLock.Free;
  FLogger := nil;
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
  //FLogger.Debug('DirectPrint => ' + StrToHexText(FBuffer));
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

function TRawPrinterPort.GetDescription: WideString;
begin
  Result := 'RawPrinterPort';
end;

end.

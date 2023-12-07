unit SocketPort;

interface

uses
  // VCL
  Windows, Messages, Classes, MConnect, ComObj, SysUtils, Variants, WinSock, SyncObjs,
  // Indy
  IdTCPClient, IdGlobal, IdStack, IdWinsock2,
  // This
  PrinterPort, DriverError, StringUtils, LogFile, WException;

const
  MaxRetryCountInfinite = 0;

type
  { TSocketParams }

  TSocketParams = record
    RemoteHost: string;
    RemotePort: Integer;
    MaxRetryCount: Integer;
    ByteTimeout: Integer;
  end;

  { TSocketPort }

  TSocketPort = class(TInterfacedObject, IPrinterPort)
  private
    FLogger: ILogFile;
    FLock: TCriticalsection;
    FConnection: TIdTCPClient;
    FParameters: TSocketParams;

    property Logger: ILogFile read FLogger;
  public
    constructor Create(AParameters: TSocketParams; ALogger: ILogFile);
    destructor Destroy; override;

    procedure Lock;
    procedure Unlock;
    procedure Purge;
    procedure Close;
    procedure Open;
    procedure Write(const Data: AnsiString);
    function ReadChar(var C: Char): Boolean;
    function Read(Count: DWORD): AnsiString;
    function CapRead: Boolean;
    procedure Flush;
    function GetDescription: WideString;
  end;


implementation

{ TSocketPort }

constructor TSocketPort.Create(AParameters: TSocketParams;
  ALogger: ILogFile);
begin
  inherited Create;
  FLogger := ALogger;
  FParameters := AParameters;
  FConnection := TIdTCPClient.Create;
  FLock := TCriticalsection.Create;
end;

destructor TSocketPort.Destroy;
begin
  Close;
  FLock.Free;
  FConnection.Free;
  inherited Destroy;
end;

procedure TSocketPort.Open;
begin
  if not FConnection.Connected then
  begin
    FConnection.Host := FParameters.RemoteHost;
    FConnection.Port := FParameters.RemotePort;
    FConnection.ReuseSocket := rsFalse;
    if FParameters.MaxRetryCount = MaxRetryCountInfinite then
    begin
      FConnection.ReadTimeout := 0;
      FConnection.ConnectTimeout := 0;
    end else
    begin
      FConnection.ReadTimeout := FParameters.ByteTimeout;
      FConnection.ConnectTimeout := FParameters.ByteTimeout;
    end;

    while True do
    begin
      try
        Logger.Debug(Format('TSocketPort.Connect(%s,%d,%d)', [
          FConnection.Host, FConnection.Port, FParameters.ByteTimeout]));

        FConnection.Connect();
        Break;
      except
        on E: Exception do
        begin
          Logger.Error(GetExceptionMessage(E));
          if FParameters.MaxRetryCount <> MaxRetryCountInfinite then raise;
        end;
      end;
    end;
  end;
end;

procedure TSocketPort.Close;
begin
  Lock;
  try
    FConnection.Disconnect;
    if (FConnection.IOHandler <> nil)and(FConnection.IOHandler.InputBuffer <> nil) then
    begin
      FConnection.IOHandler.InputBuffer.Clear;
    end;
  except
    on E: Exception do
      Logger.Error(GetExceptionMessage(E));
  end;
  Unlock;
end;

procedure TSocketPort.Write(const Data: AnsiString);
var
  i: Integer;
  Buffer: TIdBytes;
begin
  try
    Open;

    SetLength(Buffer, Length(Data));
    for i := 1 to Length(Data) do
    begin
      Buffer[i-1] := Ord(Data[i]);
    end;
    FConnection.Socket.Write(Buffer);
  except
    on E: Exception do
    begin
      Logger.Error(GetExceptionMessage(E));
      Close;
      raise;
    end;
  end;
end;

function TSocketPort.Read(Count: DWORD): AnsiString;
var
  C: Char;
  i: Integer;
begin
  Open;
  Result := '';
  try
    for i := 1 to Count do
    begin
      C := Chr(FConnection.Socket.ReadByte());
      Result := Result + C;
    end;
  except
    on E: Exception do
    begin
      Logger.Error(GetExceptionMessage(E));
      Close;
      raise;
    end;
  end;
end;

function TSocketPort.ReadChar(var C: Char): Boolean;
begin
  Open;
  Result := True;
  try
    C := Chr(FConnection.Socket.ReadByte());
  except
    on E: Exception do
    begin
      Logger.Error(GetExceptionMessage(E));
      Close;
      Result := False;
    end;
  end;
end;

procedure TSocketPort.Lock;
begin
  FLock.Enter;
end;

procedure TSocketPort.Unlock;
begin
  FLock.Leave;
end;

procedure TSocketPort.Purge;
begin
end;

function TSocketPort.CapRead: Boolean;
begin
  Result := True;
end;

procedure TSocketPort.Flush;
begin

end;

function TSocketPort.GetDescription: WideString;
begin
  Result := 'SocketPort';
end;

end.

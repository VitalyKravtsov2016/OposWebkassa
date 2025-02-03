unit UsbPrinterPort;

interface

uses
  // VCL
  Windows, Classes, SysUtils, SysConst, SyncObjs,
   // Jcl
  JclPrint, JvSetupApi, JvTypes, // Hid,
  // 3'd
  TntClasses, TntSysUtils,
  // This
  PrinterPort, LogFile, StringUtils, WException, DebugUtils;

type
  { TUsbPrinterPort }

  TUsbPrinterPort = class(TInterfacedObject, IPrinterPort)
  private
    FLogger: ILogFile;
    FHandle: THandle;
    FFileName: AnsiString;
    FLock: TCriticalSection;

    procedure CreateHandle;
    function GetHandle: THandle;
    function GetOpened: Boolean;
  public
    constructor Create(ALogger: ILogFile; const AFileName: string);
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
    function GetDeviceFileName: string;

    property Opened: Boolean read GetOpened;
    property Logger: ILogFile read FLogger;
  end;

  EUsbPortError = class(WideException);

implementation

function GetLastErrorText: AnsiString;
begin
  Result := Tnt_WideFormat(SOSError, [GetLastError, SysErrorMessage(GetLastError)]);
end;

{ TUsbPrinterPort }

constructor TUsbPrinterPort.Create(ALogger: ILogFile; const AFileName: string);
begin
  inherited Create;
  FLogger := ALogger;
  FLock := TCriticalSection.Create;
  FFileName := AFileName;
  FHandle := INVALID_HANDLE_VALUE;
end;

destructor TUsbPrinterPort.Destroy;
begin
  FLock.Free;
  FLogger := nil;
  inherited Destroy;
end;

function TUsbPrinterPort.GetOpened: Boolean;
begin
  Result := FHandle <> INVALID_HANDLE_VALUE;
end;

// {36fc9e60-c465-11cf-8056-444553540000}

(*

SetupDiEnumDeviceInterfaces ( 0x00587ab8, NULL, {a5dcbf10-6530-11d2-901f-00c04fb951ed}, 5, 0x04c2fd94 )	TRUE		0.0000017
SetupDiGetDeviceInterfaceDetailA ( 0x00587ab8, 0x04c2fd94, NULL, 0, 0x04c2fdb0, NULL )	FALSE	122 = The data area passed to a system call is too small. 	0.0000023

*)

const
  GUID_DEVINTERFACE_USB_DEVICE: TGUID = '{A5DCBF10-6530-11D2-901F-00C04FB951ED}';

function TUsbPrinterPort.GetDeviceFileName: string;
var
  PnPHandle: HDEVINFO;
  DevData: TSPDevInfoData;
  DeviceInterfaceData: TSPDeviceInterfaceData;
  FunctionClassDeviceData: PSPDeviceInterfaceDetailData;
  Success: LongBool;
  Devn: Integer;
  BytesReturned: DWORD;
  Handled: Boolean;
  RetryCreate: Boolean;
  DevicePath: string;
  DeviceGuid: TGUID;
begin
  DeviceGuid := GUID_DEVINTERFACE_USB_DEVICE;
  // Get a handle for the Plug and Play node and request currently active HID devices
  PnPHandle := SetupDiGetClassDevs(@DeviceGuid, nil, 0, DIGCF_PRESENT or DIGCF_DEVICEINTERFACE);
  if PnPHandle = Pointer(INVALID_HANDLE_VALUE) then Exit;
  Devn := 0;
  repeat
    DeviceInterfaceData.cbSize := SizeOf(TSPDeviceInterfaceData);
    // Is there a HID device at this table entry?
    Success := SetupDiEnumDeviceInterfaces(PnPHandle, nil, DeviceGuid, Devn, DeviceInterfaceData);
    if Success then
    begin
      DevData.cbSize := SizeOf(DevData);
      BytesReturned := 0;
      //evalue size needed to store the detailed interface data in FunctionClassDeviceData
      SetupDiGetDeviceInterfaceDetail(PnPHandle, @DeviceInterfaceData, nil, 0, BytesReturned, @DevData);
      if (BytesReturned <> 0) and (GetLastError = ERROR_INSUFFICIENT_BUFFER) then
      begin
        FunctionClassDeviceData := AllocMem(BytesReturned);
        try
          FunctionClassDeviceData^.cbSize := SizeOf(TSPDeviceInterfaceDetailData);
          if SetupDiGetDeviceInterfaceDetail(PnPHandle, @DeviceInterfaceData,
            FunctionClassDeviceData, BytesReturned, BytesReturned, @DevData) then
          begin
            // Win64: Don't include the padding bytes into the string length calculation
            SetString(DevicePath, PChar(@FunctionClassDeviceData.DevicePath),
              (BytesReturned - (SizeOf(FunctionClassDeviceData.cbSize) +
              SizeOf(FunctionClassDeviceData.DevicePath))) div SizeOf(Char));

            ODS('DevicePath: ' + DevicePath);
            Result := DevicePath;
            Break;
          end;
        finally
          FreeMem(FunctionClassDeviceData);
        end;
      end;
    end;
    Inc(Devn);
  until not Success;
  SetupDiDestroyDeviceInfoList(PnPHandle);
end;

procedure TUsbPrinterPort.CreateHandle;
var
  DevName: AnsiString;
  ErrorMessage: string;
begin
  DevName := '\\.\' + FFileName;
  FHandle := CreateFile(
    PCHAR(DevName),
    GENERIC_READ or GENERIC_WRITE,
    FILE_SHARE_READ + FILE_SHARE_WRITE,
    nil,
    OPEN_EXISTING,
    // FILE_ATTRIBUTE_NORMAL,
    FILE_FLAG_OVERLAPPED,
    0);

  if FHandle = INVALID_HANDLE_VALUE then
  begin
    if GetLastError = ERROR_ACCESS_DENIED then
      raise EUsbPortError.Create('Port is opened by another application');

    ErrorMessage := Format('CreateFile ERROR: 0x%.8x, %s', [
      GetLastError, SysErrorMessage(GetLastError)]);
    FLogger.Error(ErrorMessage);
    raise EUsbPortError.Create('Failed open port, ' + ErrorMessage);
  end;
end;

function TUsbPrinterPort.GetHandle: THandle;
begin
  Open;
  Result := FHandle;
end;

function TUsbPrinterPort.Read(Count: DWORD): AnsiString;
var
  ReadCount: DWORD;
begin
  Lock;
  try
    Result := '';
    if Count = 0 then Exit;

    SetLength(Result, Count);
    if not ReadFile(GetHandle, Result[1], Count, ReadCount, nil) then
    begin
      Logger.Error('ReadFile function failed.');
      Logger.Error(GetLastErrorText);
      RaiseLastWin32Error;
    end;

    SetLength(Result, ReadCount);
    if ReadCount <> Count then
    begin
      Logger.Error(Format('Read data: %d <> %d', [ReadCount, Count]));
      Logger.Error('Read error. ' + 'Device not connected');
      raise ETimeoutError.Create('Read data failed');
    end;
  finally
    Unlock;
  end;
end;

function TUsbPrinterPort.CapRead: Boolean;
begin
  Result := True;
end;

procedure TUsbPrinterPort.Close;
begin
  if Opened then
  begin
    CloseHandle(FHandle);
    FHandle := INVALID_HANDLE_VALUE;
  end;
end;

procedure TUsbPrinterPort.Flush;
begin
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
  if not GetOpened then
  begin
    CreateHandle;
  end;
end;

procedure TUsbPrinterPort.Purge;
begin
end;

procedure TUsbPrinterPort.Write(const Data: AnsiString);
var
  Count: DWORD;
  WriteCount: DWORD;
begin
  Lock;
  try
    Count := Length(Data);
    if Count = 0 then Exit;

    if not WriteFile(GetHandle, Data[1], Count, WriteCount, nil) then
    begin
      Logger.Error('WriteFile function failed.');
      Logger.Error(GetLastErrorText);
      RaiseLastWin32Error;
    end;

    if Count <> WriteCount then
    begin
      Logger.Error('Write failed. Device not connected');
      raise ETimeoutError.Create('Write data failed');
    end;
  finally
    Unlock;
  end;
end;

function TUsbPrinterPort.GetDescription: WideString;
begin
  Result := 'RawPrinterPort';
end;

end.

unit UsbPrinterPort;

interface

uses
  // VCL
  Windows, Classes, SysUtils, SysConst, SyncObjs,
   // Jcl
  JclPrint, JvSetupApi, JvTypes,
  // 3'd
  TntClasses, TntSysUtils,
  // This
  PrinterPort, LogFile, StringUtils, UserError, DebugUtils;

type
  { TUsbDevice }

  TUsbDevice = record
    Path: string;
    HardwareId: string;
    DeviceDesc: string;
  end;
  TUsbDevices = array of TUsbDevice;

  { TUsbPrinterPort }

  TUsbPrinterPort = class(TInterfacedObject, IPrinterPort)
  private
    FEvent: TEvent;
    FLogger: ILogFile;
    FHandle: THandle;
    FFileName: AnsiString;
    FLock: TCriticalSection;
    FReadTimeout: Integer;
    FOvlRead: TOverlapped;
    FOvlWrite: TOverlapped;

    procedure CreateHandle;
    function GetHandle: THandle;
    function GetOpened: Boolean;
    function DoRead(Count: DWORD): AnsiString;
    function DoRead2(Count: DWORD): AnsiString;
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
    function ReadString: AnsiString;
    function ReadByte: Byte;

    property Opened: Boolean read GetOpened;
    property Logger: ILogFile read FLogger;
    property ReadTimeout: Integer read FReadTimeout write FReadTimeout;
  end;

  EUsbPortError = class(UserException);

function ReadOA48PortName: string;
function ReadRongtaPortName: string;
function ReadPosiflexPortName: string;
function ReadSewooPortName: string;
function ReadPosiflexDevices: TUsbDevices;
function ReadUsbDevices(const HardwareIDSubstring: string): TUsbDevices;

const
  OA48PrinterHardwareId = 'VID_0483&PID_57';
  RongtaPrinterHardwareId = 'VID_0FE6&PID_81';
  PosiflexPrinterHardwareId = 'VID_0D3A&PID_03';
  SewooPrinterHardwareId = 'VID_0525&PID_A7';

implementation

function GetLastErrorText: AnsiString;
begin
  Result := Tnt_WideFormat(SOSError, [GetLastError, SysErrorMessage(GetLastError)]);
end;

///////////////////////////////////////////////////////////////////////////////
//
// PosiflexPrinter6900 = 'VID_0D3A&PID_0369';
//

function ReadUsbDevices(const HardwareIDSubstring: string): TUsbDevices;
const
  GUID_DEVINTERFACE_USB_DEVICE: TGUID = '{A5DCBF10-6530-11D2-901F-00C04FB951ED}';

  function ReadProperty(DevInfo: HDEVINFO; var DevData: TSPDevInfoData;
    PropertyId: DWORD): string;
  var
    RequiredSize: DWORD;
    PropertyRegDataType: DWORD;
  begin
    SetLength(Result, 100);
    if SetupDiGetDeviceRegistryProperty(DevInfo, DevData, PropertyId,
      PropertyRegDataType, @Result[1], Length(Result), RequiredSize) then
    begin
      Result := PChar(Result);
    end;
  end;

  function ReadDevicePath(DevInfo: HDEVINFO; Index: Integer): string;
  var
    Success: LongBool;
    DevicePath: string;
    BytesReturned: DWORD;
    DevData: TSPDevInfoData;
    DeviceInterfaceData: TSPDeviceInterfaceData;
    FunctionClassDeviceData: PSPDeviceInterfaceDetailData;
  begin
    DeviceInterfaceData.cbSize := SizeOf(TSPDeviceInterfaceData);
    Success := SetupDiEnumDeviceInterfaces(DevInfo, nil,
      GUID_DEVINTERFACE_USB_DEVICE, Index, DeviceInterfaceData);
    if Success then
    begin
      DevData.cbSize := SizeOf(DevData);
      BytesReturned := 0;
      //evalue size needed to store the detailed interface data in FunctionClassDeviceData
      SetupDiGetDeviceInterfaceDetail(DevInfo, @DeviceInterfaceData, nil, 0, BytesReturned, @DevData);
      if (BytesReturned <> 0) and (GetLastError = ERROR_INSUFFICIENT_BUFFER) then
      begin
        FunctionClassDeviceData := AllocMem(BytesReturned);
        try
          FunctionClassDeviceData^.cbSize := SizeOf(TSPDeviceInterfaceDetailData);
          if SetupDiGetDeviceInterfaceDetail(DevInfo, @DeviceInterfaceData,
            FunctionClassDeviceData, BytesReturned, BytesReturned, @DevData) then
          begin
            // Win64: Don't include the padding bytes into the string length calculation
            SetString(DevicePath, PChar(@FunctionClassDeviceData.DevicePath),
              (BytesReturned - (SizeOf(FunctionClassDeviceData.cbSize) +
              SizeOf(FunctionClassDeviceData.DevicePath))) div SizeOf(Char));

            Result := DevicePath;
          end;
        finally
          FreeMem(FunctionClassDeviceData);
        end;
      end;
    end;
  end;

var
  Index: Integer;
  DevInfo: HDEVINFO;
  Device: TUsbDevice;
  DevData: TSPDevInfoData;
  HardwareID: string;
  DeviceDesc: string;
  DevicePath: string;
begin
  if not LoadSetupApi then
    raise UserException.Create('Failed load SetupAPI');

  DevInfo := SetupDiGetClassDevs(@GUID_DEVINTERFACE_USB_DEVICE, nil, 0,
    DIGCF_PRESENT or DIGCF_DEVICEINTERFACE );
  if DevInfo = Pointer(INVALID_HANDLE_VALUE) then Exit;

  Index := 0;
  repeat
    DevData.cbSize := sizeof(DevData);
    if not SetupDiEnumDeviceInfo(DevInfo, Index, DevData) then Break;

    DevicePath := ReadDevicePath(DevInfo, Index);
    HardwareID := ReadProperty(DevInfo, DevData, SPDRP_HARDWAREID);
    DeviceDesc := ReadProperty(DevInfo, DevData, SPDRP_DEVICEDESC);

    ODS('DevicePath: ' + DevicePath);
    ODS('HardwareID: ' + HardwareID);
    ODS('DeviceDesc: ' + DeviceDesc);
    if Pos(HardwareIDSubstring, HardwareID) > 0 then
    begin
      SetLength(Result, Length(Result) + 1);
      Device.HardwareId := HardwareId;
      Device.DeviceDesc := DeviceDesc;
      Device.Path := DevicePath;
      Result[Length(Result)-1] := Device;
    end;
    Inc(Index);
  until False;
  SetupDiDestroyDeviceInfoList(DevInfo);
  UnloadSetupApi;
end;

function ReadPosiflexDevices: TUsbDevices;
begin
  Result := ReadUsbDevices(PosiflexPrinterHardwareId);
end;

function ReadUsbDevicePath(const HardwareIDSubstring: string): string;
var
  Devices: TUsbDevices;
begin
  Result := '';
  Devices := ReadUsbDevices(HardwareIDSubstring);
  if Length(Devices) > 0 then
    Result := Devices[0].Path;
end;

function ReadPosiflexPortName: string;
begin
  Result := ReadUsbDevicePath(PosiflexPrinterHardwareId);
end;

function ReadSewooPortName: string;
begin
  Result := ReadUsbDevicePath(SewooPrinterHardwareId);
end;

function ReadRongtaPortName: string;
begin
  Result := ReadUsbDevicePath(RongtaPrinterHardwareId);
end;

function ReadOA48PortName: string;
begin
  Result := ReadUsbDevicePath(OA48PrinterHardwareId);
end;

{ TUsbPrinterPort }

constructor TUsbPrinterPort.Create(ALogger: ILogFile; const AFileName: string);
begin
  inherited Create;
  FLock := TCriticalSection.Create;
  FEvent := TEvent.Create(nil, False, False, 'UsbPrinterPortEvent');

  FLogger := ALogger;
  FFileName := Trim(AFileName);
  if FFileName = '' then
    raise UserException.Create('USB port: Empty file name');

  FHandle := INVALID_HANDLE_VALUE;
  FReadTimeout := 3000;
end;

destructor TUsbPrinterPort.Destroy;
begin
  Close;
  FLock.Free;
  FEvent.Free;
  FLogger := nil;
  inherited Destroy;
end;

function TUsbPrinterPort.GetOpened: Boolean;
begin
  Result := FHandle <> INVALID_HANDLE_VALUE;
end;

procedure TUsbPrinterPort.CreateHandle;
var
  ErrorMessage: WideString;
begin
  FHandle := CreateFile(
    PChar(FFileName),
    GENERIC_READ or GENERIC_WRITE,
    FILE_SHARE_READ + FILE_SHARE_WRITE,
    nil,
    OPEN_EXISTING,
    //FILE_ATTRIBUTE_NORMAL,
    FILE_FLAG_OVERLAPPED,
    0);

  if FHandle = INVALID_HANDLE_VALUE then
  begin
    if GetLastError = ERROR_ACCESS_DENIED then
      raise EUsbPortError.Create('Port is opened by another application');

    ErrorMessage := WideFormat('CreateFile ERROR: 0x%.8x, %s', [
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
  TickCount: Int64;
begin
  Result := '';
  TickCount := GetTickCount;
  while True do
  begin
    Result := DoRead(Count);
    if Length(Result) > 0 then Break;
    if GetTickCount > (TickCount + ReadTimeout) then
      raise ETimeoutError.Create('Read data failed');
    Sleep(50);
  end;
end;

function TUsbPrinterPort.DoRead(Count: DWORD): AnsiString;
var
  LastError: Integer;
  ReadCount: DWORD;
begin
  Lock;
  try
    Result := '';
    if Count = 0 then Exit;

    Result := StringOfChar(#0, Count);
    FEvent.ResetEvent;
    FillChar(FOvlRead, SizeOf(TOverlapped), #0);
    FOvlRead.hEvent := FEvent.Handle;
    if not ReadFile(GetHandle, Result[1], Count, ReadCount, @FOvlRead) then
    begin
      LastError := GetLastError;
      if (LastError <> 0)and(LastError <> ERROR_IO_PENDING) then
      begin
        Logger.Error('ReadFile function failed.');
        Logger.Error(GetLastErrorText);
        RaiseLastWin32Error;
      end;
    end;
    if FEvent.WaitFor(ReadTimeout) <> wrSignaled then
      RaiseLastWin32Error;

    if not GetOverlappedResult(GetHandle, FOvlRead, ReadCount, True) then
    begin
      RaiseLastWin32Error;
    end;
    SetLength(Result, ReadCount);
  finally
    Unlock;
  end;
end;

function TUsbPrinterPort.DoRead2(Count: DWORD): AnsiString;
var
  ReadCount: DWORD;
  Buffer: AnsiString;
begin
  Lock;
  try
    Result := '';
    if Count = 0 then Exit;

    Buffer := StringOfChar(#0, Count);
    FEvent.ResetEvent;
    FillChar(FOvlRead, SizeOf(TOverlapped), #0);
    FOvlRead.hEvent := FEvent.Handle;
    if ReadFile(GetHandle, Buffer[1], Count, ReadCount, @FOvlRead) then
    begin
      FEvent.WaitFor(ReadTimeout);
      if GetOverlappedResult(GetHandle, FOvlRead, ReadCount, True) then
      begin
        SetLength(Buffer, ReadCount);
        Result := Buffer;
      end;
    end;
  finally
    Unlock;
  end;
end;

function TUsbPrinterPort.CapRead: Boolean;
begin
  //Result := True;
  Result := False;
end;

procedure TUsbPrinterPort.Close;
begin
  Lock;
  try
    if Opened then
    begin
      CloseHandle(FHandle);
      FHandle := INVALID_HANDLE_VALUE;
    end;
  finally
    Unlock;
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
  Lock;
  try
    if not GetOpened then
    begin
      CreateHandle;
    end;
  finally
    Unlock;
  end;
end;

procedure TUsbPrinterPort.Purge;
var
  i: Integer;
begin
  for i := 1 to 10 do
  begin
    if DoRead2($40) = '' then Break;
  end;
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

    FEvent.ResetEvent;
    FillChar(FOvlWrite, SizeOf(TOverlapped), #0);
    FOvlWrite.hEvent := FEvent.Handle;
    if not WriteFile(GetHandle, Data[1], Count, WriteCount, @FOvlWrite) then
    begin
      if GetLastError <> ERROR_IO_PENDING then
      begin
        Logger.Error('WriteFile function failed.');
        Logger.Error(GetLastErrorText);
        RaiseLastWin32Error;
      end;
    end;
    if FEvent.WaitFor(ReadTimeout) <> wrSignaled then
      RaiseLastWin32Error;

    if not GetOverlappedResult(GetHandle, FOvlWrite, DWORD(WriteCount), True) then
      RaiseLastWin32Error;

    if WriteCount < Count then
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
  Result := 'USBPrinterPort';
end;

function TUsbPrinterPort.ReadString: AnsiString;
begin
  Result := PChar(Read($40));
  FLogger.Debug('<- ' + StrToHex(Result));
end;

function TUsbPrinterPort.ReadByte: Byte;
var
  S: AnsiString;
begin
  S := Read(1);
  Result := Ord(S[1]);
  FLogger.Debug('<- ' + StrToHex(Chr(Result)));
end;



end.

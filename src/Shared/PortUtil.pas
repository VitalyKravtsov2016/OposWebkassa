unit PortUtil;
interface
uses
  // VCL
  Windows, SysUtils, Dialogs,
  // JVCL
  JvSetupAPI, WException;

procedure EnableComPort(PortName: string; AEnabled: Boolean);

implementation

const
  GUID_DEVCLASS_SERIAL: TGUID = '{4D36E978-E325-11CE-BFC1-08002BE10318}';


procedure RaiseLastError;
begin
  raiseException(SysErrorMessage(GetLastError));
end;

procedure Check(Res: Boolean);
begin
  if not Res then
    RaiseLastError;
end;

function GetComName(const Name: string): string;
var
  p1, p2: Integer;
begin
  Result := '';
  p1 := Pos('(', Name);
  p2 := Pos(')', Name);
  if (P1 <= 0)or(P2 <= 0) then Exit;
  Result := Copy(Name, p1+1, p2-p1-1);
end;

// Имя устройства в формате "Serial port (COM1)"
function GetDeviceName(DevInfo: HDEVINFO; const DevData: TSPDevInfoData): AnsiString;
var
  BytesReturned: DWORD;
  RegDataType: DWORD;
  Buffer: array[0..256] of CHAR;
begin
  LoadSetupApi;
  BytesReturned := 0;
  RegDataType := 0;
  Buffer[0] := #0;
  SetupDiGetDeviceRegistryProperty(DevInfo, DevData, SPDRP_FRIENDLYNAME,
    RegDataType, PByte(@Buffer[0]), SizeOf(Buffer), BytesReturned);
  Result := Buffer;
  if Result <> '' then
    exit;
  BytesReturned := 0;
  RegDataType := 0;
  Buffer[0] := #0;
  SetupDiGetDeviceRegistryProperty(DevInfo, DevData, SPDRP_DEVICEDESC,
    RegDataType, PByte(@Buffer[0]), SizeOf(Buffer), BytesReturned);
  Result := Buffer;
end;

function GetComPortDevIndex(DevInfo: HDEVINFO; PortName: string): DWORD;
var
  DevData: TSPDevInfoData;
  DeviceInterfaceData: TSPDeviceInterfaceData;
  RES: BOOL;
  Name: AnsiString;
begin
  LoadSetupApi;
  Result := 0;
  repeat
    DeviceInterfaceData.cbSize := SizeOf(TSPDeviceInterfaceData);
    DevData.cbSize := SizeOf(TSPDevInfoData);
    RES := SetupDiEnumDeviceInfo(DevInfo, Result, DevData);
    if RES then
    begin
      Name := GetDeviceName(DevInfo, DevData);
      if GetComName(Name) = PortName then
        Break
      else
        Inc(Result);
    end;
  until not RES;
end;

procedure EnableComPort(PortName: string; AEnabled: Boolean);
var
  DevInfo: HDEVINFO;
  PCHP: TSPPropChangeParams;
  DeviceData: TSPDevInfoData;
begin
  LoadSetupApi;
  DevInfo := SetupDiGetClassDevs(@GUID_DEVCLASS_SERIAL, nil, 0, DIGCF_PRESENT);
  try
    Check(DevInfo <> Pointer(INVALID_HANDLE_VALUE));

    DeviceData.cbSize := sizeof(TSPDevInfoData);
    if not SetupDiEnumDeviceInfo(DevInfo,
      GetComPortDevIndex(DevInfo, PortName), DeviceData) then Exit;

    PCHP.ClassInstallHeader.cbSize := sizeof(TSPClassInstallHeader);

    Check(SetupDiSetClassInstallParams(DevInfo, @DeviceData, @PCHP, sizeof(TSPPropChangeParams)));

    PCHP.ClassInstallHeader.cbSize := sizeof(TSPClassInstallHeader);
    PCHP.ClassInstallHeader.InstallFunction := DIF_PROPERTYCHANGE;
    PCHP.Scope := DICS_FLAG_GLOBAL; //DICS_FLAG_CONFIGSPECIFIC;
    PCHP.HwProfile := 0;
    if AEnabled then
      PCHP.StateChange := DICS_ENABLE
    else
      PCHP.StateChange := DICS_DISABLE;
    Check(SetupDiSetClassInstallParams(DevInfo, @DeviceData, @PCHP, sizeof(TSPPropChangeParams)));
    Check(SetupDiCallClassInstaller(DIF_PROPERTYCHANGE, DevInfo, @DeviceData));
    DeviceData.cbSize := sizeof(TSPDevInfoData);
  finally
    SetupDiDestroyDeviceInfoList(DevInfo);
  end;
end;

end.


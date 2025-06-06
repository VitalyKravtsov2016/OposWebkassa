unit OposUtils;

interface

uses
  // VCL
  Classes, SysUtils, Types,
  // OPOS
  Opos, Oposhi, OposException,
  // This
  GNUGetText, StringUtils;

type
  { TOposDate }

  TOposDate = record
    Day: Integer;
    Month: Integer;
    Year: Integer;
    Hour: Integer;
    Min: Integer;
  end;

function StrToRect(const S: string): TRect;
function StrToPoint(const S: string): TPoint;
function RectToStr(const R: TRect): string;
function PointToStr(const P: TPoint): string;
function IsEqual(const P1, P2: TPoint): Boolean; overload;
function IsEqual(const R1, R2: TRect): Boolean; overload;

function GetErrorLocusText(Value: Integer): WideString;
function GetResultCodeText(Value: Integer): WideString;
function GetErrorResponseText(Value: Integer): WideString;
function PowerStateToStr(PowerState: Integer): WideString;
function GetCommonPropertyName(const ID: Integer): WideString;
function GetOPOSStatusUpdateEventText(Value: Integer): WideString;
function GetOpenResultText(Value: Integer): WideString;
function BinaryConversionToStr(Value: Integer): WideString;
function StateToStr(Value: Integer): WideString;
function PowerReportingToStr(Value: Integer): WideString;
function PowerNotifyToStr(Value: Integer): WideString;
function OposStrToNibble(const Data: AnsiString): AnsiString;
function OposNibbleToStr(const Data: AnsiString): AnsiString;
function IsValidOposStatusUpdateEvent(Code: Integer): Boolean;

implementation

function StrToRect(const S: string): TRect;
begin
  Result.Left := GetInteger(S, 1, [',']);
  Result.Top := GetInteger(S, 2, [',']);
  Result.Right := GetInteger(S, 3, [',']);
  Result.Bottom := GetInteger(S, 4, [',']);
end;

function StrToPoint(const S: string): TPoint;
begin
  Result.X := GetInteger(S, 1, [',']);
  Result.Y := GetInteger(S, 2, [',']);
end;

function RectToStr(const R: TRect): string;
begin
  Result := Format('%d,%d,%d,%d', [R.Left, R.Top, R.Right, R.Bottom]);
end;

function PointToStr(const P: TPoint): string;
begin
  Result := Format('%d,%d', [P.X, P.Y]);
end;

function IsEqual(const P1, P2: TPoint): Boolean; overload;
begin
  Result := (P1.X = P2.X) and (P1.Y = P2.Y);
end;

function IsEqual(const R1, R2: TRect): Boolean; overload;
begin
  Result := IsEqual(R1.TopLeft, R2.TopLeft) and IsEqual(R1.BottomRight, R2.BottomRight);
end;


function GetCommonPropertyName(const ID: Integer): WideString;
begin
  case ID of
    // common
    PIDX_Claimed: Result := 'PIDX_Claimed';
    PIDX_DataEventEnabled: Result := 'PIDX_DataEventEnabled';
    PIDX_DeviceEnabled: Result := 'PIDX_DeviceEnabled';
    PIDX_FreezeEvents: Result := 'PIDX_FreezeEvents';
    PIDX_OutputID: Result := 'PIDX_OutputID';
    PIDX_ResultCode: Result := 'PIDX_ResultCode';
    PIDX_ResultCodeExtended: Result := 'PIDX_ResultCodeExtended';
    PIDX_ServiceObjectVersion: Result := 'PIDX_ServiceObjectVersion';
    PIDX_State: Result := 'PIDX_State';
    PIDX_AutoDisable: Result := 'PIDX_AutoDisable';
    PIDX_BinaryConversion: Result := 'PIDX_BinaryConversion';
    PIDX_DataCount: Result := 'PIDX_DataCount';
    PIDX_PowerNotify: Result := 'PIDX_PowerNotify';
    PIDX_PowerState: Result := 'PIDX_PowerState';
    PIDX_CapPowerReporting: Result := 'PIDX_CapPowerReporting';
    PIDX_CapStatisticsReporting: Result := 'PIDX_CapStatisticsReporting';
    PIDX_CapUpdateStatistics: Result := 'PIDX_CapUpdateStatistics';
    PIDX_CapCompareFirmwareVersion: Result := 'PIDX_CapCompareFirmwareVersion';
    PIDX_CapUpdateFirmware: Result := 'PIDX_CapUpdateFirmware';
    PIDX_CheckHealthText: Result := 'PIDX_CheckHealthText';
    PIDX_DeviceDescription: Result := 'PIDX_DeviceDescription';
    PIDX_DeviceName: Result := 'PIDX_DeviceName';
    PIDX_ServiceObjectDescription: Result := 'PIDX_ServiceObjectDescription';
  else
    Result := IntToStr(ID);
  end;
end;

function GetResultCodeText(Value: Integer): WideString;
begin
  case Value of
    OPOS_SUCCESS          : Result := 'OPOS_SUCCESS';
    OPOS_E_CLOSED         : Result := 'OPOS_E_CLOSED';
    OPOS_E_CLAIMED        : Result := 'OPOS_E_CLAIMED';
    OPOS_E_NOTCLAIMED     : Result := 'OPOS_E_NOTCLAIMED';
    OPOS_E_NOSERVICE      : Result := 'OPOS_E_NOSERVICE';
    OPOS_E_DISABLED       : Result := 'OPOS_E_DISABLED';
    OPOS_E_ILLEGAL        : Result := 'OPOS_E_ILLEGAL';
    OPOS_E_NOHARDWARE     : Result := 'OPOS_E_NOHARDWARE';
    OPOS_E_OFFLINE        : Result := 'OPOS_E_OFFLINE';
    OPOS_E_NOEXIST        : Result := 'OPOS_E_NOEXIST';
    OPOS_E_EXISTS         : Result := 'OPOS_E_EXISTS';
    OPOS_E_FAILURE        : Result := 'OPOS_E_FAILURE';
    OPOS_E_TIMEOUT        : Result := 'OPOS_E_TIMEOUT';
    OPOS_E_BUSY           : Result := 'OPOS_E_BUSY';
    OPOS_E_EXTENDED       : Result := 'OPOS_E_EXTENDED';
    OPOS_OR_ALREADYOPEN   : Result := 'OPOS_OR_ALREADYOPEN';
    OPOS_OR_REGBADNAME    : Result := 'OPOS_OR_REGBADNAME';
    OPOS_OR_REGPROGID     : Result := 'OPOS_OR_REGPROGID';
    OPOS_OR_CREATE        : Result := 'OPOS_OR_CREATE';
    OPOS_OR_BADIF         : Result := 'OPOS_OR_BADIF';
    OPOS_OR_FAILEDOPEN    : Result := 'OPOS_OR_FAILEDOPEN';
    OPOS_OR_BADVERSION    : Result := 'OPOS_OR_BADVERSION';
    OPOS_ORS_NOPORT       : Result := 'OPOS_ORS_NOPORT';
    OPOS_ORS_NOTSUPPORTED : Result := 'OPOS_ORS_NOTSUPPORTED';
    OPOS_ORS_CONFIG       : Result := 'OPOS_ORS_CONFIG';
    OPOS_ORS_SPECIFIC     : Result := 'OPOS_ORS_SPECIFIC';
  else
    Result := IntToStr(Value);
  end;
end;

function GetErrorLocusText(Value: Integer): WideString;
begin
  case Value of
    OPOS_EL_OUTPUT       : Result := 'OPOS_EL_OUTPUT';
    OPOS_EL_INPUT        : Result := 'OPOS_EL_INPUT';
    OPOS_EL_INPUT_DATA   : Result := 'OPOS_EL_INPUT_DATA';
  else
    Result := IntToStr(Value);
  end;
end;

function GetErrorResponseText(Value: Integer): WideString;
begin
  case Value of
    OPOS_ER_RETRY         : Result := 'OPOS_ER_RETRY';
    OPOS_ER_CLEAR         : Result := 'OPOS_ER_CLEAR';
    OPOS_ER_CONTINUEINPUT : Result := 'OPOS_ER_CONTINUEINPUT';
  else
    Result := IntToStr(Value);
  end;
end;

function GetOPOSStatusUpdateEventText(Value: Integer): WideString;
begin
  case Value of
    // common
    OPOS_SUE_POWER_ONLINE             	  : Result := 'OPOS_SUE_POWER_ONLINE';
    OPOS_SUE_POWER_OFF                    : Result := 'OPOS_SUE_POWER_OFF';
    OPOS_SUE_POWER_OFFLINE                : Result := 'OPOS_SUE_POWER_OFFLINE';
    OPOS_SUE_POWER_OFF_OFFLINE            : Result := 'OPOS_SUE_POWER_OFF_OFFLINE';
    OPOS_SUE_UF_PROGRESS                  : Result := 'OPOS_SUE_UF_PROGRESS';
    OPOS_SUE_UF_COMPLETE                  : Result := 'OPOS_SUE_UF_COMPLETE';
    OPOS_SUE_UF_COMPLETE_DEV_NOT_RESTORED : Result := 'OPOS_SUE_UF_COMPLETE_DEV_NOT_RESTORED';
    OPOS_SUE_UF_FAILED_DEV_OK             : Result := 'OPOS_SUE_UF_FAILED_DEV_OK';
    OPOS_SUE_UF_FAILED_DEV_UNRECOVERABLE  : Result := 'OPOS_SUE_UF_FAILED_DEV_UNRECOVERABLE';
    OPOS_SUE_UF_FAILED_DEV_NEEDS_FIRMWARE : Result := 'OPOS_SUE_UF_FAILED_DEV_NEEDS_FIRMWARE';
    OPOS_SUE_UF_FAILED_DEV_UNKNOWN        : Result := 'OPOS_SUE_UF_FAILED_DEV_UNKNOWN';
  else
    Result := IntToStr(Value);
  end;
end;

function PowerStateToStr(PowerState: Integer): WideString;
begin
  case PowerState of
    OPOS_PS_UNKNOWN     : Result := 'OPOS_PS_UNKNOWN';
    OPOS_PS_ONLINE      : Result := 'OPOS_PS_ONLINE';
    OPOS_PS_OFF         : Result := 'OPOS_PS_OFF';
    OPOS_PS_OFFLINE     : Result := 'OPOS_PS_OFFLINE';
    OPOS_PS_OFF_OFFLINE : Result := 'OPOS_PS_OFF_OFFLINE';
  else
    Result := IntToStr(PowerState);
  end;
end;

function GetOpenResultText(Value: Integer): WideString;
begin
  case Value of
    OPOS_OR_ALREADYOPEN   : Result :=
      _('Control Object already open');

    OPOS_OR_REGBADNAME    : Result :=
      _('The registry does not contain a key for the specified device name');

    OPOS_OR_REGPROGID     : Result :=
      _('Could not read the device name key''s default value, or could not convert this Prog ID to a valid Class ID');

    OPOS_OR_CREATE        : Result :=
      _('Could not create a service object instance, or could not get its IDispatch interface');

    OPOS_OR_BADIF         : Result :=
    _('The service object does not support one or more of the method required by its release');

    OPOS_OR_FAILEDOPEN    : Result :=
      _('The service object returned a failure status from its open call, but doesn''t have a more specific failure code');

    OPOS_OR_BADVERSION    : Result :=
      _('The service object major version number is not 1');

    OPOS_ORS_NOPORT       : Result :=
      _('Port access required at open, but configured port is invalid or inaccessible');

    OPOS_ORS_NOTSUPPORTED : Result :=
      _('Service Object does not support the specified device');

    OPOS_ORS_CONFIG       : Result :=
      _('Configuration information error');

    OPOS_ORS_SPECIFIC     : Result :=
      _('Errors greater than this value are SO-specific');
  else
    Result := _('Unknown code');
  end;
end;

function BinaryConversionToStr(Value: Integer): WideString;
begin
  case Value of
    0: Result := 'OPOS_BC_NONE';
    1: Result := 'OPOS_BC_NIBBLE';
    2: Result := 'OPOS_BC_DECIMAL';
  else
    Result := IntToStr(Value);
  end;
end;

function StateToStr(Value: Integer): WideString;
begin
  case Value of
    OPOS_S_CLOSED: Result := 'OPOS_S_CLOSED';
    OPOS_S_IDLE: Result := 'OPOS_S_IDLE';
    OPOS_S_BUSY: Result := 'OPOS_S_BUSY';
    OPOS_S_ERROR: Result := 'OPOS_S_ERROR';
  else
    Result := IntToStr(Value);
  end;
end;

function PowerReportingToStr(Value: Integer): WideString;
begin
  case Value of
    OPOS_PR_NONE: Result := 'OPOS_PR_NONE';
    OPOS_PR_STANDARD: Result := 'OPOS_PR_STANDARD';
    OPOS_PR_ADVANCED: Result := 'OPOS_PR_ADVANCED';
  else
    Result := IntToStr(Value);
  end;
end;

function PowerNotifyToStr(Value: Integer): WideString;
begin
  case Value of
    OPOS_PN_DISABLED: Result := 'OPOS_PN_DISABLED';
    OPOS_PN_ENABLED: Result := 'OPOS_PN_ENABLED';
  else
    Result := IntToStr(Value);
  end;
end;

function OposStrToNibble(const Data: AnsiString): AnsiString;
var
  B: Byte;
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(Data) do
  begin
    B := Ord(Data[i]);
    Result := Result + Char($30 + ((B shr 4) and $0F));
    Result := Result + Char($30 + (B and $0F));
  end;
end;

function OposNibbleToStr(const Data: AnsiString): AnsiString;
var
  B: Byte;
  i: Integer;
  L: Integer;
begin
  Result := '';
  L := Length(Data) div 2;
  for i := 1 to L do
  begin
    B := (Ord(Data[i*2-1])-$30) shl 4;
    B := B + (Ord(Data[i*2])-$30);
    Result := Result + Chr(B);
  end;
end;

function IsValidOposStatusUpdateEvent(Code: Integer): Boolean;
begin
  case Code of
    OPOS_SUE_POWER_ONLINE,
    OPOS_SUE_POWER_OFF,
    OPOS_SUE_POWER_OFFLINE,
    OPOS_SUE_POWER_OFF_OFFLINE,
    OPOS_SUE_UF_PROGRESS,
    OPOS_SUE_UF_COMPLETE,
    OPOS_SUE_UF_COMPLETE_DEV_NOT_RESTORED,
    OPOS_SUE_UF_FAILED_DEV_OK,
    OPOS_SUE_UF_FAILED_DEV_UNRECOVERABLE,
    OPOS_SUE_UF_FAILED_DEV_NEEDS_FIRMWARE,
    OPOS_SUE_UF_FAILED_DEV_UNKNOWN:
    REsult := True;
  else
    Result := False;
  end;
end;


end.

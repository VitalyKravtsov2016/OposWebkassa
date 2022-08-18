unit PrinterParametersReg;

interface

uses
  // VCL
  Windows, SysUtils, Classes, Registry,
  // 3'd
  TntClasses, TntStdCtrls, TntRegistry, TntSysUtils,
  // This
  PrinterParameters, LogFile, Oposhi, WException, gnugettext,
  DriverError, VatCode;

type
  { TPrinterParametersReg }

  TPrinterParametersReg = class
  private
    FLogger: ILogFile;
    FParameters: TPrinterParameters;

    procedure LoadSysParameters(const DeviceName: WideString);
    procedure LoadUsrParameters(const DeviceName: WideString);
    procedure SaveSysParameters(const DeviceName: WideString);
    procedure SaveUsrParameters(const DeviceName: WideString);
    class function GetUsrKeyName(const DeviceName: WideString): WideString;
    class function GetSysKeyName(const DeviceName: WideString): WideString;

    property Parameters: TPrinterParameters read FParameters;
  public
    constructor Create(AParameters: TPrinterParameters; ALogger: ILogFile);

    procedure Load(const DeviceName: WideString);
    procedure Save(const DeviceName: WideString);

    property Logger: ILogFile read FLogger;
  end;

procedure DeleteParametersReg(const DeviceName: WideString; Logger: ILogFile);
procedure LoadParametersReg(Item: TPrinterParameters; const DeviceName: WideString;
  Logger: ILogFile);

procedure SaveParametersReg(Item: TPrinterParameters; const DeviceName: WideString;
  Logger: ILogFile);

procedure SaveUsrParametersReg(Item: TPrinterParameters;
  const DeviceName: WideString; Logger: ILogFile);

implementation

const
  REG_KEY_VATCODES  = 'VatCodes';
  REG_KEY_PAYTYPES  = 'PaymentTypes';
  REGSTR_KEY_IBT = 'SOFTWARE\POSITIVE\POSITIVE32\Terminal';

procedure DeleteParametersReg(const DeviceName: WideString; Logger: ILogFile);
var
  Reg: TTntRegistry;
begin
  Reg := TTntRegistry.Create;
  try
    Reg.Access := KEY_ALL_ACCESS;
    Reg.RootKey := HKEY_CURRENT_USER;
    Reg.DeleteKey(TPrinterParametersReg.GetUsrKeyName(DeviceName));
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    Reg.DeleteKey(TPrinterParametersReg.GetSysKeyName(DeviceName));
  except
    on E: Exception do
      Logger.Error('TPrinterParametersReg.Save', E);
  end;
  Reg.Free;
end;

procedure LoadParametersReg(Item: TPrinterParameters; const DeviceName: WideString;
  Logger: ILogFile);
var
  Reader: TPrinterParametersReg;
begin
  Reader := TPrinterParametersReg.Create(Item, Logger);
  try
    Reader.Load(DeviceName);
  finally
    Reader.Free;
  end;
end;

procedure SaveParametersReg(Item: TPrinterParameters; const DeviceName: WideString;
  Logger: ILogFile);
var
  Writer: TPrinterParametersReg;
begin
  Writer := TPrinterParametersReg.Create(Item, Logger);
  try
    Writer.Save(DeviceName);
  finally
    Writer.Free;
  end;
end;

procedure SaveUsrParametersReg(Item: TPrinterParameters;
  const DeviceName: WideString; Logger: ILogFile);
var
  Writer: TPrinterParametersReg;
begin
  Writer := TPrinterParametersReg.Create(Item, Logger);
  try
    Writer.SaveUsrParameters(DeviceName);
  finally
    Writer.Free;
  end;
end;

{ TPrinterParametersReg }

constructor TPrinterParametersReg.Create(AParameters: TPrinterParameters;
  ALogger: ILogFile);
begin
  inherited Create;
  FParameters := AParameters;
  FLogger := ALogger;
end;

class function TPrinterParametersReg.GetSysKeyName(const DeviceName: WideString): WideString;
begin
  Result := Tnt_WideFormat('%s\%s\%s', [OPOS_ROOTKEY, OPOS_CLASSKEY_FPTR, DeviceName]);
end;

procedure TPrinterParametersReg.Load(const DeviceName: WideString);
begin
  LoadSysParameters(DeviceName);
  LoadUsrParameters(DeviceName);
end;

procedure TPrinterParametersReg.Save(const DeviceName: WideString);
begin
  SaveUsrParameters(DeviceName);
  SaveSysParameters(DeviceName);
end;

procedure TPrinterParametersReg.LoadSysParameters(const DeviceName: WideString);
var
  i: Integer;
  Reg: TTntRegistry;
  Names: TTntStrings;
  KeyName: WideString;
  VatCode: Integer;
  VatRate: Double;
  VatName: WideString;
begin
  Logger.Debug('TPrinterParametersReg.Load', [DeviceName]);

  Reg := TTntRegistry.Create;
  try
    Reg.Access := KEY_READ;
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    KeyName := GetSysKeyName(DeviceName);
    if Reg.OpenKey(KeyName, False) then
    begin
      if Reg.ValueExists('LogMaxCount') then
        Parameters.LogMaxCount := Reg.ReadInteger('LogMaxCount');

      if Reg.ValueExists('LogFileEnabled') then
        Parameters.LogFileEnabled := Reg.ReadBool('LogFileEnabled');

      if Reg.ValueExists('LogFilePath') then
        Parameters.LogFilePath := Reg.ReadString('LogFilePath');

      if Reg.ValueExists('NumHeaderLines') then
        Parameters.NumHeaderLines := Reg.ReadInteger('NumHeaderLines');

      if Reg.ValueExists('NumTrailerLines') then
        Parameters.NumTrailerLines := Reg.ReadInteger('NumTrailerLines');

      if Reg.ValueExists('WebkassaAddress') then
        Parameters.WebkassaAddress := Reg.ReadString('WebkassaAddress');

      if Reg.ValueExists('ConnectTimeout') then
        Parameters.ConnectTimeout := Reg.ReadInteger('ConnectTimeout');

      if Reg.ValueExists('Login') then
        Parameters.Login := Reg.ReadString('Login');

      if Reg.ValueExists('Password') then
        Parameters.Password := Reg.ReadString('Password');

      if Reg.ValueExists('CashboxNumber') then
        Parameters.CashboxNumber := Reg.ReadString('CashboxNumber');

      if Reg.ValueExists('PrinterName') then
        Parameters.PrinterName := Reg.ReadString('PrinterName');

      if Reg.ValueExists('PrinterType') then
        Parameters.PrinterType := Reg.ReadInteger('PrinterType');

      if Reg.ValueExists('VatCodeEnabled') then
        Parameters.VatCodeEnabled := Reg.ReadBool('VatCodeEnabled');

      if Reg.ValueExists('PaymentType2') then
        Parameters.PaymentType2 := Reg.ReadInteger('PaymentType2');

      if Reg.ValueExists('PaymentType3') then
        Parameters.PaymentType3 := Reg.ReadInteger('PaymentType3');

      if Reg.ValueExists('PaymentType4') then
        Parameters.PaymentType4 := Reg.ReadInteger('PaymentType4');

      Reg.CloseKey;
    end;
    // VatCodes
    if Reg.OpenKey(KeyName + '\' + REG_KEY_VATCODES, False) then
    begin
      Parameters.VatCodes.Clear;
      Names := TTntStringList.Create;
      try
        Reg.GetKeyNames(Names);
        Reg.CloseKey;

        for i := 0 to Names.Count-1 do
        begin
          if Reg.OpenKey(KeyName + '\' + REG_KEY_VATCODES, False) then
          begin
            if Reg.OpenKey(Names[i], False) then
            begin
              VatCode := Reg.ReadInteger('Code');
              VatRate := Reg.ReadFloat('Rate');
              VatName := Reg.ReadString('Name');
              Parameters.VatCodes.Add(VatCode, VatRate, VatName);
              Reg.CloseKey;
            end;
          end;
        end;
      finally
        Names.Free;
      end;
    end;
  finally
    Reg.Free;
  end;
end;

procedure TPrinterParametersReg.SaveSysParameters(const DeviceName: WideString);
var
  i: Integer;
  Item: TVatCode;
  Reg: TTntRegistry;
  KeyName: WideString;
begin
  Reg := TTntRegistry.Create;
  try
    Reg.Access := KEY_ALL_ACCESS;
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    KeyName := GetSysKeyName(DeviceName);
    if not Reg.OpenKey(KeyName, True) then
      raiseOpenKeyError(KeyName);

    Reg.WriteString('', FiscalPrinterProgID);
    Reg.WriteBool('LogFileEnabled', Parameters.LogFileEnabled);
    Reg.WriteString('LogFilePath', FParameters.LogFilePath);
    Reg.WriteInteger('LogMaxCount', FParameters.LogMaxCount);
    Reg.WriteInteger('NumHeaderLines', FParameters.NumHeaderLines);
    Reg.WriteInteger('NumTrailerLines', FParameters.NumTrailerLines);
    Reg.WriteString('WebkassaAddress', FParameters.WebkassaAddress);
    Reg.WriteInteger('ConnectTimeout', FParameters.ConnectTimeout);
    Reg.WriteString('Login', FParameters.Login);
    Reg.WriteString('Password', FParameters.Password);
    Reg.WriteString('CashboxNumber', FParameters.CashboxNumber);
    Reg.WriteString('PrinterName', FParameters.PrinterName);
    Reg.WriteInteger('PrinterType', FParameters.PrinterType);
    Reg.WriteInteger('PaymentType2', FParameters.PaymentType2);
    Reg.WriteInteger('PaymentType3', FParameters.PaymentType3);
    Reg.WriteInteger('PaymentType4', FParameters.PaymentType4);
    Reg.WriteBool('VatCodeEnabled', FParameters.VatCodeEnabled);
    Reg.CloseKey;
    // VatCodes
    Reg.DeleteKey(KeyName + '\' + REG_KEY_VATCODES);
    for i := 0 to Parameters.VatCodes.Count-1 do
    begin
      if Reg.OpenKey(KeyName + '\' + REG_KEY_VATCODES, True) then
      begin
        Item := Parameters.VatCodes[i];
        if Reg.OpenKey(IntToStr(i), True) then
        begin
          Reg.WriteInteger('Code', Item.Code);
          Reg.WriteFloat('Rate', Item.Rate);
          Reg.WriteString('Name', Item.Name);
          Reg.CloseKey;
        end;
        Reg.CloseKey;
      end;
    end;
  finally
    Reg.Free;
  end;
end;

class function TPrinterParametersReg.GetUsrKeyName(const DeviceName: WideString): WideString;
begin
  Result := Tnt_WideFormat('%s\%s\%s', [OPOS_ROOTKEY, OPOS_CLASSKEY_FPTR, DeviceName]);
end;

procedure TPrinterParametersReg.LoadUsrParameters(const DeviceName: WideString);
var
  Reg: TTntRegistry;
begin
  Logger.Debug('TPrinterParametersReg.LoadUsrParameters', [DeviceName]);
  Reg := TTntRegistry.Create;
  try
    Reg.Access := KEY_READ;
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey(REGSTR_KEY_IBT, False) then
    begin
      if Reg.ValueExists('IBTHeader') then
        Parameters.Header := Reg.ReadString('IBTHeader');

      if Reg.ValueExists('IBTTrailer') then
        Parameters.Trailer := Reg.ReadString('IBTTrailer');
    end;
  finally
    Reg.Free;
  end;
end;

procedure TPrinterParametersReg.SaveUsrParameters(const DeviceName: WideString);
var
  Reg: TTntRegistry;
begin
  Logger.Debug('TPrinterParametersReg.SaveUsrParameters', [DeviceName]);
  Reg := TTntRegistry.Create;
  try
    Reg.Access := KEY_ALL_ACCESS;
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey(REGSTR_KEY_IBT, True) then
    begin
      Reg.WriteString('IBTHeader', Parameters.Header);
      Reg.WriteString('IBTTrailer', Parameters.Trailer);
    end else
    begin
      raiseException(_('Registry key open error'));
    end;
  finally
    Reg.Free;
  end;
end;

end.

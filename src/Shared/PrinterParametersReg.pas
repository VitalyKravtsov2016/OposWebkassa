unit PrinterParametersReg;

interface

uses
  // VCL
  Windows, SysUtils, Classes, Registry,
  // 3'd
  TntClasses, TntStdCtrls, TntRegistry, TntSysUtils,
  // This
  PrinterParameters, LogFile, Oposhi, WException, gnugettext,
  DriverError, VatRate, WebkassaClient, FileUtils;

type
  { TPrinterParametersReg }

  TPrinterParametersReg = class
  private
    FLogger: ILogFile;
    FParameters: TPrinterParameters;

    procedure LoadSysParameters(const DeviceName: WideString);
    procedure LoadUsrParameters(const DeviceName: WideString);
    procedure LoadIBTParameters(const DeviceName: WideString);
    procedure SaveSysParameters(const DeviceName: WideString);
    procedure SaveUsrParameters(const DeviceName: WideString);
    procedure SaveIBTParameters(const DeviceName: WideString);

    property Parameters: TPrinterParameters read FParameters;
    procedure LoadVatRates(const DeviceName: WideString);
    procedure LoadUnitNames(const DeviceName: WideString);
  public
    constructor Create(AParameters: TPrinterParameters; ALogger: ILogFile);

    procedure Load(const DeviceName: WideString);
    procedure Save(const DeviceName: WideString);
    class function GetUsrKeyName(const DeviceName: WideString): WideString;
    class function GetSysKeyName(const DeviceName: WideString): WideString;

    property Logger: ILogFile read FLogger;
  end;

procedure DeleteParametersReg(const DeviceName: WideString; Logger: ILogFile);

procedure LoadParametersReg(Parameters: TPrinterParameters; const DeviceName: WideString;
  Logger: ILogFile);

procedure SaveParametersReg(Parameters: TPrinterParameters; const DeviceName: WideString;
  Logger: ILogFile);

procedure SaveUsrParametersReg(Parameters: TPrinterParameters;
  const DeviceName: WideString; Logger: ILogFile);

implementation

const
  REGSTR_KEY_VATRATES  = 'VatRates';
  REGSTR_KEY_PAYTYPES  = 'PaymentTypes';
  REGSTR_KEY_UNITITEMS = 'UnitItems';
  REGSTR_KEY_UNITNAMES = 'UnitNames';
  REGSTR_KEY_IBT       = 'SOFTWARE\POSITIVE\POSITIVE32\Terminal';

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

procedure LoadParametersReg(Parameters: TPrinterParameters; const DeviceName: WideString;
  Logger: ILogFile);
var
  Reader: TPrinterParametersReg;
begin
  Reader := TPrinterParametersReg.Create(Parameters, Logger);
  try
    Reader.Load(DeviceName);
  finally
    Reader.Free;
  end;
end;

procedure SaveParametersReg(Parameters: TPrinterParameters; const DeviceName: WideString;
  Logger: ILogFile);
var
  Writer: TPrinterParametersReg;
begin
  Writer := TPrinterParametersReg.Create(Parameters, Logger);
  try
    Writer.Save(DeviceName);
    Parameters.Save(DeviceName);
  finally
    Writer.Free;
  end;
end;

procedure SaveUsrParametersReg(Parameters: TPrinterParameters;
  const DeviceName: WideString; Logger: ILogFile);
var
  Writer: TPrinterParametersReg;
begin
  Writer := TPrinterParametersReg.Create(Parameters, Logger);
  try
    Writer.SaveUsrParameters(DeviceName);
    Writer.SaveIBTParameters(DeviceName);
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
  LoadIBTParameters(DeviceName);
  Parameters.Load(DeviceName);
end;

procedure TPrinterParametersReg.Save(const DeviceName: WideString);
begin
  SaveUsrParameters(DeviceName);
  SaveIBTParameters(DeviceName);
  SaveSysParameters(DeviceName);
  Parameters.Save(DeviceName);
end;

procedure TPrinterParametersReg.LoadSysParameters(const DeviceName: WideString);
var
  Reg: TTntRegistry;
  KeyName: WideString;
begin
  Logger.Debug('TPrinterParametersReg.LoadSysParameters', [DeviceName]);

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

      if Reg.ValueExists('EscPrinterType') then
        Parameters.EscPrinterType := Reg.ReadInteger('EscPrinterType');

      if Reg.ValueExists('VatRateEnabled') then
        Parameters.VatRateEnabled := Reg.ReadBool('VatRateEnabled');

      if Reg.ValueExists('PaymentType2') then
        Parameters.PaymentType2 := Reg.ReadInteger('PaymentType2');

      if Reg.ValueExists('PaymentType3') then
        Parameters.PaymentType3 := Reg.ReadInteger('PaymentType3');

      if Reg.ValueExists('PaymentType4') then
        Parameters.PaymentType4 := Reg.ReadInteger('PaymentType4');

      if Reg.ValueExists('RoundType') then
        Parameters.RoundType := Reg.ReadInteger('RoundType');

      if Reg.ValueExists('VATNumber') then
        Parameters.VATNumber := Reg.ReadString('VATNumber');

      if Reg.ValueExists('VATSeries') then
        Parameters.VATSeries := Reg.ReadString('VATSeries');

      if Reg.ValueExists('AmountDecimalPlaces') then
        Parameters.AmountDecimalPlaces := Reg.ReadInteger('AmountDecimalPlaces');

      if Reg.ValueExists('FontName') then
        Parameters.FontName := Reg.ReadString('FontName');

      if Reg.ValueExists('RemoteHost') then
        Parameters.RemoteHost := Reg.ReadString('RemoteHost');

      if Reg.ValueExists('RemotePort') then
        Parameters.RemotePort := Reg.ReadInteger('RemotePort');

      if Reg.ValueExists('ByteTimeout') then
        Parameters.ByteTimeout := Reg.ReadInteger('ByteTimeout');

      if Reg.ValueExists('PortName') then
        Parameters.PortName := Reg.ReadString('PortName');

      if Reg.ValueExists('BaudRate') then
        Parameters.BaudRate := Reg.ReadInteger('BaudRate');

      if Reg.ValueExists('DataBits') then
        Parameters.DataBits := Reg.ReadInteger('DataBits');

      if Reg.ValueExists('StopBits') then
        Parameters.StopBits := Reg.ReadInteger('StopBits');

      if Reg.ValueExists('Parity') then
        Parameters.Parity := Reg.ReadInteger('Parity');

      if Reg.ValueExists('FlowControl') then
        Parameters.FlowControl := Reg.ReadInteger('FlowControl');

      if Reg.ValueExists('ReconnectPort') then
        Parameters.ReconnectPort := Reg.ReadBool('ReconnectPort');

      if Reg.ValueExists('SerialTimeout') then
        Parameters.SerialTimeout := Reg.ReadInteger('SerialTimeout');

      if Reg.ValueExists('DevicePollTime') then
        Parameters.DevicePollTime := Reg.ReadInteger('DevicePollTime');

      if Reg.ValueExists('TranslationName') then
        Parameters.TranslationName := Reg.ReadString('TranslationName');

      if Reg.ValueExists('PrintBarcode') then
        Parameters.PrintBarcode := Reg.ReadInteger('PrintBarcode');

      if Reg.ValueExists('TranslationEnabled') then
        Parameters.TranslationEnabled := Reg.ReadBool('TranslationEnabled');

      if Reg.ValueExists('TemplateEnabled') then
        Parameters.TemplateEnabled := Reg.ReadBool('TemplateEnabled');

      if Reg.ValueExists('CurrencyName') then
        Parameters.CurrencyName := Reg.ReadString('CurrencyName');

      if Reg.ValueExists('OfflineText') then
        Parameters.OfflineText := Reg.ReadString('OfflineText');

      if Reg.ValueExists('LineSpacing') then
        Parameters.LineSpacing := Reg.ReadInteger('LineSpacing');

      if Reg.ValueExists('PrintEnabled') then
        Parameters.PrintEnabled := Reg.ReadBool('PrintEnabled');

      if Reg.ValueExists('RecLineChars') then
        Parameters.RecLineChars := Reg.ReadInteger('RecLineChars');

      if Reg.ValueExists('RecLineHeight') then
        Parameters.RecLineHeight := Reg.ReadInteger('RecLineHeight');

      if Reg.ValueExists('HeaderPrinted') then
        Parameters.HeaderPrinted := Reg.ReadBool('HeaderPrinted');

      if Reg.ValueExists('ReplaceDataMatrixWithQRCode') then
        Parameters.ReplaceDataMatrixWithQRCode := Reg.ReadBool('ReplaceDataMatrixWithQRCode');

      Reg.CloseKey;
    end;
    // VatRates
    LoadVatRates(DeviceName);
    // UnitNames
    LoadUnitNames(DeviceName);
  except
    on E: Exception do
      Logger.Error('TPrinterParametersReg.LoadSysParameters', E);
  end;
  Reg.Free;
end;

procedure TPrinterParametersReg.LoadUnitNames(const DeviceName: WideString);
var
  i: Integer;
  Reg: TTntRegistry;
  Names: TTntStrings;
  KeyName: WideString;
  Data: TUnitNameRec;
begin
  Parameters.UnitNames.Clear;

  Reg := TTntRegistry.Create;
  Names := TTntStringList.Create;
  try
    Reg.Access := KEY_READ;
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    KeyName := GetSysKeyName(DeviceName) + '\' + REGSTR_KEY_UNITNAMES;
    if Reg.OpenKey(KeyName, False) then
    begin
      Reg.GetKeyNames(Names);
      Reg.CloseKey;
    end;

    for i := 0 to Names.Count-1 do
    begin
      if Reg.OpenKey(KeyName + '\' + Names[i], False) then
      begin
        Data.AppName := Reg.ReadString('AppName');
        Data.SrvName := Reg.ReadString('SrvName');
        Data.SrvCode := Reg.ReadInteger('SrvCode');
        Parameters.AddUnitName(Data.AppName, Data.SrvName, Data.SrvCode);
        Reg.CloseKey;
      end;
    end;
  finally
    Reg.Free;
    Names.Free;
  end;
end;

procedure TPrinterParametersReg.LoadVatRates(const DeviceName: WideString);
var
  i: Integer;
  Reg: TTntRegistry;
  Names: TTntStrings;
  KeyName: WideString;
  VatRate: TVatRateRec;
begin
  Parameters.VatRates.Clear;

  Reg := TTntRegistry.Create;
  Names := TTntStringList.Create;
  try
    Reg.Access := KEY_READ;
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    KeyName := GetSysKeyName(DeviceName) + '\' + REGSTR_KEY_VATRATES;
    if Reg.OpenKey(KeyName, False) then
    begin
      Reg.GetKeyNames(Names);
      Reg.CloseKey;
    end;

    for i := 0 to Names.Count-1 do
    begin
      if Reg.OpenKey(KeyName + '\' + Names[i], False) then
      begin
        VatRate.ID := Reg.ReadInteger('ID');
        VatRate.Rate := Reg.ReadFloat('Rate');
        VatRate.Name := Reg.ReadString('Name');
        VatRate.VatType := Reg.ReadInteger('VatType');
        Parameters.VatRates.Add(VatRate);
        Reg.CloseKey;
      end;
    end;
  finally
    Reg.Free;
    Names.Free;
  end;
end;

procedure TPrinterParametersReg.SaveSysParameters(const DeviceName: WideString);
var
  i: Integer;
  Item: TVatRate;
  Reg: TTntRegistry;
  KeyName: WideString;
  UnitName: TUnitName;
  RootKeyName: WideString;
begin
  Logger.Debug('TPrinterParametersReg.SaveSysParameters', [DeviceName]);

  Reg := TTntRegistry.Create;
  try
    Reg.Access := KEY_ALL_ACCESS;
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    RootKeyName := GetSysKeyName(DeviceName);
    if not Reg.OpenKey(RootKeyName, True) then
      raiseOpenKeyError(RootKeyName);

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
    Reg.WriteInteger('EscPrinterType', FParameters.EscPrinterType);
    Reg.WriteString('FontName', FParameters.FontName);
    Reg.WriteInteger('PaymentType2', FParameters.PaymentType2);
    Reg.WriteInteger('PaymentType3', FParameters.PaymentType3);
    Reg.WriteInteger('PaymentType4', FParameters.PaymentType4);
    Reg.WriteBool('VatRateEnabled', FParameters.VatRateEnabled);
    Reg.WriteInteger('RoundType', FParameters.RoundType);
    Reg.WriteString('VATNumber', FParameters.VATNumber);
    Reg.WriteString('VATSeries', FParameters.VATSeries);
    Reg.WriteInteger('AmountDecimalPlaces', FParameters.AmountDecimalPlaces);
    Reg.WriteString('RemoteHost', FParameters.RemoteHost);
    Reg.WriteInteger('RemotePort', FParameters.RemotePort);
    Reg.WriteInteger('ByteTimeout', FParameters.ByteTimeout);

    Reg.WriteString('PortName', FParameters.PortName);
    Reg.WriteInteger('BaudRate', FParameters.BaudRate);
    Reg.WriteInteger('DataBits', FParameters.DataBits);
    Reg.WriteInteger('StopBits', FParameters.StopBits);
    Reg.WriteInteger('Parity', FParameters.Parity);
    Reg.WriteInteger('FlowControl', FParameters.FlowControl);
    Reg.WriteBool('ReconnectPort', FParameters.ReconnectPort);
    Reg.WriteInteger('SerialTimeout', FParameters.SerialTimeout);
    Reg.WriteInteger('DevicePollTime', FParameters.DevicePollTime);
    Reg.WriteString('TranslationName', FParameters.TranslationName);
    Reg.WriteInteger('PrintBarcode', FParameters.PrintBarcode);
    Reg.WriteBool('TranslationEnabled', FParameters.TranslationEnabled);
    Reg.WriteBool('TemplateEnabled', FParameters.TemplateEnabled);
    Reg.WriteString('CurrencyName', FParameters.CurrencyName);
    Reg.WriteString('OfflineText', FParameters.OfflineText);
    Reg.WriteInteger('LineSpacing', FParameters.LineSpacing);
    Reg.WriteBool('PrintEnabled', FParameters.PrintEnabled);
    Reg.WriteInteger('RecLineChars', FParameters.RecLineChars);
    Reg.WriteInteger('RecLineHeight', FParameters.RecLineHeight);
    Reg.WriteBool('HeaderPrinted', FParameters.HeaderPrinted);
    Reg.WriteBool('ReplaceDataMatrixWithQRCode', FParameters.ReplaceDataMatrixWithQRCode);
    Reg.WriteString('AcceptLanguage', FParameters.AcceptLanguage);

    Reg.CloseKey;
    // VatRates
    Reg.DeleteKey(RootKeyName + '\' + REGSTR_KEY_VATRATES);
    for i := 0 to Parameters.VatRates.Count-1 do
    begin
      if Reg.OpenKey(RootKeyName + '\' + REGSTR_KEY_VATRATES, True) then
      begin
        Item := Parameters.VatRates[i];
        if Reg.OpenKey(IntToStr(i), True) then
        begin
          Reg.WriteInteger('ID', Item.ID);
          Reg.WriteFloat('Rate', Item.Rate);
          Reg.WriteString('Name', Item.Name);
          Reg.WriteInteger('VatType', Item.VatType);
          Reg.CloseKey;
        end;
        Reg.CloseKey;
      end;
    end;
    // UnitNames
    Reg.DeleteKey(RootKeyName + '\' + REGSTR_KEY_UNITNAMES);
    for i := 0 to Parameters.UnitNames.Count-1 do
    begin
      UnitName := Parameters.UnitNames[i];
      KeyName := RootKeyName + '\' + REGSTR_KEY_UNITNAMES + '\' + IntToStr(i);
      if Reg.OpenKey(KeyName, True) then
      begin
        Reg.WriteString('AppName', UnitName.AppName);
        Reg.WriteString('SrvName', UnitName.SrvName);
        Reg.WriteInteger('SrvCode', UnitName.SrvCode);
      end;
      Reg.CloseKey;
    end;
  except
    on E: Exception do
      Logger.Error('TPrinterParametersReg.SaveSysParameters', E);
  end;
  Reg.Free;
end;

class function TPrinterParametersReg.GetUsrKeyName(const DeviceName: WideString): WideString;
begin
  Result := Tnt_WideFormat('%s\%s\%s', [OPOS_ROOTKEY, OPOS_CLASSKEY_FPTR, DeviceName]);
end;

procedure TPrinterParametersReg.LoadIBTParameters(const DeviceName: WideString);
var
  Reg: TTntRegistry;
begin
  Logger.Debug('TPrinterParametersReg.LoadIBTParameters', [DeviceName]);

  Reg := TTntRegistry.Create;
  try
    Reg.Access := KEY_READ;
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey(REGSTR_KEY_IBT, False) then
    begin
      if Reg.ValueExists('IBTHeader') then
        Parameters.HeaderText := Reg.ReadString('IBTHeader');

      if Reg.ValueExists('IBTTrailer') then
        Parameters.TrailerText := Reg.ReadString('IBTTrailer');
    end;
  except
    on E: Exception do
      Logger.Error('TPrinterParametersReg.LoadIBTParameters', E);
  end;
  Reg.Free;
end;

procedure TPrinterParametersReg.LoadUsrParameters(const DeviceName: WideString);
var
  i: Integer;
  Item: TUnitItem;
  Reg: TTntRegistry;
  KeyName: WideString;
  KeyNames: TTntStrings;
begin
  Logger.Debug('TPrinterParametersReg.LoadUsrParameters', [DeviceName]);

  Reg := TTntRegistry.Create;
  KeyNames := TTntStringList.Create;
  try
    Reg.Access := KEY_READ;
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    KeyName := GetUsrKeyName(DeviceName);
    if Reg.OpenKey(KeyName, False) then
    begin
      if Reg.ValueExists('ShiftNumber') then
        Parameters.ShiftNumber := Reg.ReadInteger('ShiftNumber');

      if Reg.ValueExists('CheckNumber') then
        Parameters.CheckNumber := Reg.ReadString('CheckNumber');

      if Reg.ValueExists('SumInCashbox') then
        Parameters.SumInCashbox := Reg.ReadCurrency('SumInCashbox');

      if Reg.ValueExists('GrossTotal') then
        Parameters.GrossTotal := Reg.ReadCurrency('GrossTotal');

      if Reg.ValueExists('DailyTotal') then
        Parameters.DailyTotal := Reg.ReadCurrency('DailyTotal');

      if Reg.ValueExists('SellTotal') then
        Parameters.SellTotal := Reg.ReadCurrency('SellTotal');

      if Reg.ValueExists('RefundTotal') then
        Parameters.RefundTotal := Reg.ReadCurrency('RefundTotal');

      if Reg.ValueExists('AcceptLanguage') then
        Parameters.AcceptLanguage := Reg.ReadString('AcceptLanguage');

      Parameters.Units.Clear;
      if Reg.OpenKey(REGSTR_KEY_UNITITEMS, False) then
      begin
        Reg.GetKeyNames(KeyNames);
        Reg.CloseKey;

        for i := 0 to KeyNames.Count-1 do
        begin
          KeyName := GetUsrKeyName(DeviceName) + '\' + REGSTR_KEY_UNITITEMS + '\' + KeyNames[i];
          if Reg.OpenKey(KeyName, False) then
          begin
            Item := Parameters.Units.Add as TUnitItem;
            Item.Code := Reg.ReadInteger('Code');
            Item.NameRu := Reg.ReadString('NameRu');
            Item.NameKz := Reg.ReadString('NameKz');
            Item.NameEn := Reg.ReadString('NameEn');
          end;
          Reg.CloseKey;
        end;
      end;
    end;
  except
    on E: Exception do
      Logger.Error('TPrinterParametersReg.LoadUsrParameters', E);
  end;
  Reg.Free;
  KeyNames.Free;
end;

procedure TPrinterParametersReg.SaveIBTParameters(const DeviceName: WideString);
var
  Reg: TTntRegistry;
begin
  Logger.Debug('TPrinterParametersReg.SaveIBTParameters', [DeviceName]);

  Reg := TTntRegistry.Create;
  try
    Reg.Access := KEY_ALL_ACCESS;
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    if Reg.OpenKey(REGSTR_KEY_IBT, True) then
    begin
      Reg.WriteString('IBTHeader', Parameters.HeaderText);
      Reg.WriteString('IBTTrailer', Parameters.TrailerText);
    end;
  except
    on E: Exception do
      Logger.Error('TPrinterParametersReg.SaveIBTParameters', E);
  end;
  Reg.Free;
end;

procedure TPrinterParametersReg.SaveUsrParameters(const DeviceName: WideString);
var
  i: Integer;
  Item: TUnitItem;
  Reg: TTntRegistry;
  KeyName: WideString;
  RootKeyName: WideString;
begin
  Logger.Debug('TPrinterParametersReg.SaveUsrParameters', [DeviceName]);

  Reg := TTntRegistry.Create;
  try
    Reg.Access := KEY_ALL_ACCESS;
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    RootKeyName := GetUsrKeyName(DeviceName);
    if Reg.OpenKey(RootKeyName, True) then
    begin
      Reg.WriteInteger('ShiftNumber', Parameters.ShiftNumber);
      Reg.WriteString('CheckNumber', Parameters.CheckNumber);
      Reg.WriteCurrency('SumInCashbox', Parameters.SumInCashbox);
      Reg.WriteCurrency('GrossTotal', Parameters.GrossTotal);
      Reg.WriteCurrency('DailyTotal', Parameters.DailyTotal);
      Reg.WriteCurrency('SellTotal', Parameters.SellTotal);
      Reg.WriteCurrency('RefundTotal', Parameters.RefundTotal);
      Reg.CloseKey;

      Reg.DeleteKey(RootKeyName + '\' + REGSTR_KEY_UNITITEMS);
      for i := 0 to Parameters.Units.Count-1 do
      begin
        Item := Parameters.Units[i];
        KeyName := RootKeyName + '\' + REGSTR_KEY_UNITITEMS + '\' + IntToStr(Item.Code);
        if Reg.OpenKey(KeyName, True) then
        begin
          Reg.WriteInteger('Code', Item.Code);
          Reg.WriteString('NameRu', Item.NameRu);
          Reg.WriteString('NameKz', Item.NameKz);
          Reg.WriteString('NameEn', Item.NameEn);
        end;
        Reg.CloseKey;
      end;
    end;
  except
    on E: Exception do
      Logger.Error('TPrinterParametersReg.SaveUsrParameters', E);
  end;
  Reg.Free;
end;

end.

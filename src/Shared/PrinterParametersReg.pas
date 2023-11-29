unit PrinterParametersReg;

interface

uses
  // VCL
  Windows, SysUtils, Classes, Registry,
  // 3'd
  TntClasses, TntStdCtrls, TntRegistry, TntSysUtils,
  // This
  PrinterParameters, LogFile, Oposhi, WException, gnugettext,
  DriverError, VatRate;

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

    property Parameters: TPrinterParameters read FParameters;
  public
    constructor Create(AParameters: TPrinterParameters; ALogger: ILogFile);

    procedure Load(const DeviceName: WideString);
    procedure Save(const DeviceName: WideString);
    class function GetUsrKeyName(const DeviceName: WideString): WideString;
    class function GetSysKeyName(const DeviceName: WideString): WideString;

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
  REG_KEY_VatRateS  = 'VatRates';
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
    Item.Load(DeviceName);     
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
    Item.Save(DeviceName);
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


      Reg.CloseKey;
    end;
    // VatRates
    if Reg.OpenKey(KeyName + '\' + REG_KEY_VatRateS, False) then
    begin
      Parameters.VatRates.Clear;
      Names := TTntStringList.Create;
      try
        Reg.GetKeyNames(Names);
        Reg.CloseKey;

        for i := 0 to Names.Count-1 do
        begin
          if Reg.OpenKey(KeyName + '\' + REG_KEY_VatRateS, False) then
          begin
            if Reg.OpenKey(Names[i], False) then
            begin
              VatCode := Reg.ReadInteger('Code');
              VatRate := Reg.ReadFloat('Rate');
              VatName := Reg.ReadString('Name');
              Parameters.VatRates.Add(VatCode, VatRate, VatName);
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
  Item: TVatRate;
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
    Reg.WriteInteger('LineSpacing', FParameters.LineSpacing);
    Reg.WriteBool('PrintEnabled', FParameters.PrintEnabled);
    Reg.WriteInteger('RecLineChars', FParameters.RecLineChars);
    Reg.WriteInteger('RecLineHeight', FParameters.RecLineHeight);
    Reg.WriteBool('HeaderPrinted', FParameters.HeaderPrinted);

    Reg.CloseKey;
    // VatRates
    Reg.DeleteKey(KeyName + '\' + REG_KEY_VatRateS);
    for i := 0 to Parameters.VatRates.Count-1 do
    begin
      if Reg.OpenKey(KeyName + '\' + REG_KEY_VatRateS, True) then
      begin
        Item := Parameters.VatRates[i];
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
        Parameters.HeaderText := Reg.ReadString('IBTHeader');

      if Reg.ValueExists('IBTTrailer') then
        Parameters.TrailerText := Reg.ReadString('IBTTrailer');
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
      Reg.WriteString('IBTHeader', Parameters.HeaderText);
      Reg.WriteString('IBTTrailer', Parameters.TrailerText);
    end else
    begin
      raiseException(_('Registry key open error'));
    end;
  finally
    Reg.Free;
  end;
end;

end.

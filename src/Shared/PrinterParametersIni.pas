unit PrinterParametersIni;

interface

uses
  // VCL
  Windows, SysUtils, Classes,
  // 3'd
  TntClasses, TntStdCtrls, TntRegistry, TntIniFiles, TntSysUtils,
  // This
  PrinterParameters, FileUtils, LogFile, SmIniFile, OposWebkassaLib_TLB;

type
  { TPrinterParametersIni }

  TPrinterParametersIni = class
  private
    FLogger: ILogFile;
    FParameters: TPrinterParameters;
    procedure LoadIni(const DeviceName: WideString);
    property Parameters: TPrinterParameters read FParameters;

    class function GetIniFileName: WideString;
    class function GetSectionName(const DeviceName: WideString): WideString;
    procedure SaveSysParameters(const DeviceName: WideString);
    procedure SaveUsrParameters(const DeviceName: WideString);

    property Logger: ILogFile read FLogger;
  public
    constructor Create(AParameters: TPrinterParameters; ALogger: ILogFile);
    procedure Load(const DeviceName: WideString);
    procedure Save(const DeviceName: WideString);
  end;

procedure DeleteParametersIni(const DeviceName: WideString);

procedure LoadParametersIni(Item: TPrinterParameters;
  const DeviceName: WideString; Logger: ILogFile);

procedure SaveParametersIni(Item: TPrinterParameters;
  const DeviceName: WideString; Logger: ILogFile);

procedure SaveUsrParametersIni(Item: TPrinterParameters;
  const DeviceName: WideString; Logger: ILogFile);

implementation

procedure DeleteParametersIni(const DeviceName: WideString);
begin
  try
    DeleteFile(TPrinterParametersIni.GetIniFileName);
  except
    on E: Exception do
      //Logger.Error('DeleteParametersIni', E);
  end;
end;

procedure LoadParametersIni(Item: TPrinterParameters;
  const DeviceName: WideString; Logger: ILogFile);
var
  Reader: TPrinterParametersIni;
begin
  Reader := TPrinterParametersIni.Create(Item, Logger);
  try
    Reader.Load(DeviceName);
    Item.Load(DeviceName);
  finally
    Reader.Free;
  end;
end;

procedure SaveParametersIni(Item: TPrinterParameters; const DeviceName: WideString;
  Logger: ILogFile);
var
  Writer: TPrinterParametersIni;
begin
  Writer := TPrinterParametersIni.Create(Item, Logger);
  try
    Writer.Save(DeviceName);
    Item.Save(DeviceName);
  finally
    Writer.Free;
  end;
end;

procedure SaveUsrParametersIni(Item: TPrinterParameters;
  const DeviceName: WideString; Logger: ILogFile);
var
  Writer: TPrinterParametersIni;
begin
  Writer := TPrinterParametersIni.Create(Item, Logger);
  try
    Writer.SaveUsrParameters(DeviceName);
  finally
    Writer.Free;
  end;
end;

{ TPrinterParametersIni }

constructor TPrinterParametersIni.Create(AParameters: TPrinterParameters;
  ALogger: ILogFile);
begin
  inherited Create;
  FParameters := AParameters;
  FLogger := ALogger;
end;

procedure TPrinterParametersIni.Load(const DeviceName: WideString);
begin
  try
    LoadIni(DeviceName);
  except
    on E: Exception do
    begin
      Logger.Error('TPrinterParametersIni.Load', E);
    end;
  end;
end;

procedure TPrinterParametersIni.Save(const DeviceName: WideString);
begin
  try
    SaveUsrParameters(DeviceName);
    SaveSysParameters(DeviceName);
  except
    on E: Exception do
      Logger.Error('TPrinterParametersIni.Save', E);
  end;
end;

class function TPrinterParametersIni.GetIniFileName: WideString;
begin
  Result := ExtractFilePath(CLSIDToFileName(Class_FiscalPrinter));
  if Result <> '' then
    Result := WideIncludeTrailingPathDelimiter(Result)
  else
    Result := GetModulePath;

  Result := Result + 'FiscalPrinter.ini';
end;

class function TPrinterParametersIni.GetSectionName(const DeviceName: WideString): WideString;
begin
  Result := 'FiscalPrinter_' + DeviceName;
end;

procedure TPrinterParametersIni.LoadIni(const DeviceName: WideString);
var
  Section: WideString;
  IniFile: TSmIniFile;
begin
  Logger.Debug('TPrinterParametersIni.Load', [DeviceName]);

  IniFile := TSmIniFile.Create(GetIniFileName);
  try
    Section := GetSectionName(DeviceName);
    if IniFile.SectionExists(Section) then
    begin
      FParameters.LogFileEnabled := IniFile.ReadBool(Section, 'LogFileEnabled', DefLogFileEnabled);
      FParameters.LogMaxCount := IniFile.ReadInteger(Section, 'LogMaxCount', DefLogMaxCount);
      FParameters.LogFilePath := IniFile.ReadString(Section, 'LogFilePath', '');
      FParameters.NumHeaderLines := IniFile.ReadInteger(Section, 'NumHeaderLines', DefNumHeaderLines);
      FParameters.NumTrailerLines := IniFile.ReadInteger(Section, 'NumTrailerLines', DefNumTrailerLines);
      FParameters.Login := IniFile.ReadString(Section, 'Login', 'Login');
      FParameters.Password := IniFile.ReadString(Section, 'Password', 'Password');
      FParameters.ConnectTimeout := IniFile.ReadInteger(Section, 'ConnectTimeout', 10);
      FParameters.WebkassaAddress := IniFile.ReadString(Section, 'WebkassaAddress', 'https://devkkm.webkassa.kz/');
      FParameters.CashboxNumber := IniFile.ReadString(Section, 'CashboxNumber', '');
      FParameters.PrinterName := IniFile.ReadString(Section, 'PrinterName', '');
      FParameters.PrinterType := IniFile.ReadInteger(Section, 'PrinterType', PrinterTypePosPrinter);
      FParameters.FontName := IniFile.ReadString(Section, 'FontName', DefFontName);
      FParameters.AmountDecimalPlaces := IniFile.ReadInteger(Section, 'AmountDecimalPlaces', DefAmountDecimalPlaces);
      FParameters.RemoteHost := IniFile.ReadString(Section, 'RemoteHost', DefRemoteHost);
      FParameters.RemotePort := IniFile.ReadInteger(Section, 'RemotePort', DefRemotePort);
      FParameters.ByteTimeout := IniFile.ReadInteger(Section, 'ByteTimeout', DefByteTimeout);
      FParameters.PortName := IniFile.ReadString(Section, 'PortName', DefPortName);
      FParameters.BaudRate := IniFile.ReadInteger(Section, 'BaudRate', DefBaudRate);
      FParameters.DataBits := IniFile.ReadInteger(Section, 'DataBits', DefDataBits);
      FParameters.StopBits := IniFile.ReadInteger(Section, 'StopBits', DefStopBits);
      FParameters.Parity := IniFile.ReadInteger(Section, 'Parity', DefParity);
      FParameters.FlowControl := IniFile.ReadInteger(Section, 'FlowControl', DefFlowControl);
      FParameters.ReconnectPort := IniFile.ReadBool(Section, 'ReconnectPort', DefReconnectPort);
      FParameters.SerialTimeout := IniFile.ReadInteger(Section, 'SerialTimeout', DefSerialTimeout);
      FParameters.DevicePollTime := IniFile.ReadInteger(Section, 'DevicePollTime', DefDevicePollTime);
      FParameters.TranslationName := IniFile.ReadString(Section, 'TranslationName', DefTranslationName);
      FParameters.PrintBarcode := IniFile.ReadInteger(Section, 'PrintBarcode', DefPrintBarcode);
      FParameters.TranslationEnabled := IniFile.ReadBool(Section, 'TranslationEnabled', DefTranslationEnabled);
      FParameters.TemplateEnabled := IniFile.ReadBool(Section, 'TemplateEnabled', DefTemplateEnabled);
      FParameters.CurrencyName := IniFile.ReadString(Section, 'CurrencyName', DefCurrencyName);
      FParameters.LineSpacing := IniFile.ReadInteger(Section, 'LineSpacing', DefLineSpacing);
      FParameters.PrintEnabled := IniFile.ReadBool(Section, 'PrintEnabled', DefPrintEnabled);
      FParameters.RecLineChars := IniFile.ReadInteger(Section, 'RecLineChars', DefRecLineChars);
      FParameters.RecLineHeight := IniFile.ReadInteger(Section, 'RecLineHeight', DefRecLineHeight);
      FParameters.HeaderPrinted := IniFile.ReadBool(Section, 'HeaderPrinted', DefHeaderPrinted);
    end;
  finally
    IniFile.Free;
  end;
end;

procedure TPrinterParametersIni.SaveSysParameters(const DeviceName: WideString);
var
  Section: WideString;
  IniFile: TSmIniFile;
begin
  IniFile := TSmIniFile.Create(GetIniFileName);
  try
    Section := GetSectionName(DeviceName);
    IniFile.WriteString(Section, 'LogFilePath', FParameters.LogFilePath);
    IniFile.WriteBool(Section, 'LogFileEnabled', Parameters.LogFileEnabled);
    IniFile.WriteInteger(Section, 'LogMaxCount', Parameters.LogMaxCount);
    IniFile.WriteInteger(Section, 'NumHeaderLines', Parameters.NumHeaderLines);
    IniFile.WriteInteger(Section, 'NumTrailerLines', Parameters.NumTrailerLines);
    IniFile.WriteString(Section, 'Login', FParameters.Login);
    IniFile.WriteString(Section, 'Password', FParameters.Password);
    IniFile.WriteInteger(Section, 'ConnectTimeout', FParameters.ConnectTimeout);
    IniFile.WriteString(Section, 'WebkassaAddress', FParameters.WebkassaAddress);
    IniFile.WriteString(Section, 'CashboxNumber', FParameters.CashboxNumber);
    IniFile.WriteString(Section, 'PrinterName', FParameters.PrinterName);
    IniFile.WriteInteger(Section, 'PrinterType', FParameters.PrinterType);
    IniFile.WriteString(Section, 'FontName', FParameters.FontName);
    IniFile.WriteInteger(Section, 'AmountDecimalPlaces', FParameters.AmountDecimalPlaces);
    IniFile.WriteString(Section, 'RemoteHost', FParameters.RemoteHost);
    IniFile.WriteInteger(Section, 'RemotePort', FParameters.RemotePort);
    IniFile.WriteInteger(Section, 'ByteTimeout', FParameters.ByteTimeout);
    IniFile.WriteString(Section, 'PortName', FParameters.PortName);
    IniFile.WriteInteger(Section, 'BaudRate', FParameters.BaudRate);
    IniFile.WriteInteger(Section, 'DataBits', FParameters.DataBits);
    IniFile.WriteInteger(Section, 'StopBits', FParameters.StopBits);
    IniFile.WriteInteger(Section, 'Parity', FParameters.Parity);
    IniFile.WriteInteger(Section, 'FlowControl', FParameters.FlowControl);
    IniFile.WriteBool(Section, 'ReconnectPort', FParameters.ReconnectPort);
    IniFile.WriteInteger(Section, 'SerialTimeout', FParameters.SerialTimeout);
    IniFile.WriteInteger(Section, 'DevicePollTime', FParameters.DevicePollTime);
    IniFile.WriteString(Section, 'TranslationName', FParameters.TranslationName);
    IniFile.WriteInteger(Section, 'PrintBarcode', FParameters.PrintBarcode);
    IniFile.WriteBool(Section, 'TranslationEnabled', FParameters.TranslationEnabled);
    IniFile.WriteBool(Section, 'TemplateEnabled', FParameters.TemplateEnabled);
    IniFile.WriteString(Section, 'CurrencyName', FParameters.CurrencyName);
    IniFile.WriteInteger(Section, 'LineSpacing', FParameters.LineSpacing);
    IniFile.WriteBool(Section, 'PrintEnabled', FParameters.PrintEnabled);
    IniFile.WriteInteger(Section, 'RecLineChars', FParameters.RecLineChars);
    IniFile.WriteInteger(Section, 'RecLineHeight', FParameters.RecLineHeight);
    IniFile.WriteBool(Section, 'HeaderPrinted', FParameters.HeaderPrinted);
  finally
    IniFile.Free;
  end;
end;

procedure TPrinterParametersIni.SaveUsrParameters(const DeviceName: WideString);
var
  Section: WideString;
  IniFile: TSmIniFile;
begin
  IniFile := TSmIniFile.Create(GetIniFileName);
  try
    Section := GetSectionName(DeviceName);

    IniFile.WriteText(Section, 'Header', Parameters.HeaderText);
    IniFile.WriteText(Section, 'Trailer', Parameters.TrailerText);
  finally
    IniFile.Free;
  end;
end;

end.

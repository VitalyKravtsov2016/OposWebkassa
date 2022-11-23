unit PrinterParametersX;

interface

uses
  // VCL
  SysUtils,
  // this
  LogFile,
  PrinterParameters,
  PrinterParametersIni,
  PrinterParametersReg;

procedure LoadParameters(Item: TPrinterParameters; const DeviceName: WideString;
  Logger: ILogFile);

procedure SaveParameters(Item: TPrinterParameters; const DeviceName: WideString;
  Logger: ILogFile);

procedure SaveUsrParameters(Item: TPrinterParameters; const DeviceName: WideString;
  Logger: ILogFile);

implementation

procedure LoadParameters(Item: TPrinterParameters; const DeviceName: WideString;
  Logger: ILogFile);
begin
  try
    LoadParametersReg(Item, DeviceName, Logger);
  except
    on E: Exception do
      Logger.Error('LoadParameters', E);
  end;
end;

procedure SaveParameters(Item: TPrinterParameters; const DeviceName: WideString;
  Logger: ILogFile);
begin
  try
    SaveParametersReg(Item, DeviceName, Logger);
  except
    on E: Exception do
      Logger.Error('SaveParameters', E);
  end;
end;

procedure SaveUsrParameters(Item: TPrinterParameters; const DeviceName: WideString;
  Logger: ILogFile);
begin
  try
    SaveUsrParametersReg(Item, DeviceName, Logger);
  except
    on E: Exception do
      Logger.Error('SaveUsrParameters', E);
  end;
end;

end.

unit PrinterParametersX;

interface

uses
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
  LoadParametersReg(Item, DeviceName, Logger);
end;

procedure SaveParameters(Item: TPrinterParameters; const DeviceName: WideString;
  Logger: ILogFile);
begin
  SaveParametersReg(Item, DeviceName, Logger);
end;

procedure SaveUsrParameters(Item: TPrinterParameters; const DeviceName: WideString;
  Logger: ILogFile);
begin
  SaveUsrParametersReg(Item, DeviceName, Logger);
end;

end.

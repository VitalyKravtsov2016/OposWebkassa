program EurekaLogTest;

{$APPTYPE CONSOLE}

uses
  ExceptionLog,
  SysUtils;

begin
  if IsEurekaLogInstalled then
    WriteLn('EurekaLog is installed');
  if IsEurekaLogActive then
    WriteLn('EurekaLog is active');

  {$IFDEF EUREKALOG}
  WriteLn('Compiled with EurekaLog.');
  {$ELSE}
  WriteLn('Compiled without EurekaLog.');
  {$ENDIF}  raise Exception.Create('EurekaLog test');end.


unit duOposDevice;

interface

uses
  // VCL
  Windows, SysUtils, Classes, SyncObjs, Math,
  // DUnit
  TestFramework,
  // Opos
  Opos, OposUtils, OposServiceDevice19, StringUtils, LogFile;

type
  { TOposUtilsTest }

  TOposDeviceTest = class(TTestCase)
  published
    procedure TestDataConversion;
  end;

implementation

{ TOposDeviceTest }

procedure TOposDeviceTest.TestDataConversion;
const
  Data = 'http://dev.kofd.kz/consumer?i=925871425876&f=211030200207&s=15443.72&t=20220826T210014'#13#10;
  DataNibble = '687474703:2?2?6465762>6;6?66642>6;7:2?636?6>73756=65723?693=39323538373134323538373626663=32313130333032303032303726733=31353434332>373226743=3230323230383236543231303031340=0:';
var
  S: AnsiString;
  Logger: ILogFile;
  Device: TOposServiceDevice19;
begin
  S := OposStrToNibble(Data);
  CheckEquals(DataNibble, S, 'OposStrToNibble');

  Logger := TLogFile.Create;
  Device := TOposServiceDevice19.Create(Logger);
  try
    Device.BinaryConversion := OPOS_BC_NIBBLE;
    S := Device.TextToBinary(DataNibble);
    CheckEquals(Data, S, 'Device.TextToBinary');
  finally
    Device.Free;
  end;
end;

initialization
  RegisterTest('', TOposDeviceTest.Suite);

end.

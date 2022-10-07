
unit duOposUtils;

interface

uses
  // VCL
  Windows, SysUtils, Classes, SyncObjs,
  // DUnit
  TestFramework,
  // Opos
  OposUtils;

type
  { TOposUtilsTest }

  TOposUtilsTest = class(TTestCase)
  published
    procedure TestStrToNibble;
  end;

implementation

{ TOposUtilsTest }

procedure TOposUtilsTest.TestStrToNibble;
const
  Data = 'Test'#13#10;
var
  S: string;
begin
  S := OposStrToNibble(Data);
  CheckEquals('546573740=0:', S, 'OposStrToNibble');

  S := OposNibbleToStr(OposStrToNibble(Data));
  CheckEquals(S, Data, 'Data');;
end;

initialization
  RegisterTest('', TOposUtilsTest.Suite);

end.

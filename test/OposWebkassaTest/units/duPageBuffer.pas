
unit duPageBuffer;

interface

uses
  // VCL
  Windows, SysUtils, Classes, SyncObjs, Math,
  // DUnit
  TestFramework,
  // Opos
  PageBuffer, StringUtils, PrinterTypes;

type
  { TPageBufferTest }

  TPageBufferTest = class(TTestCase)
  published
    procedure TestPrint;
  end;

implementation

{ TPageBufferTest }

procedure TPageBufferTest.TestPrint;
var
  Buffer: TPageBuffer;
begin
  Buffer := TPageBuffer.Create;
  try
    Buffer.LineWidth := 372;
    Buffer.LineSpacing := 5;
    Buffer.Print('01234567890123456789', []);
    Buffer.Print('01234567890123456789', []);
    Buffer.Print('0123456789' + CRLF, []);
    CheckEquals(58, Buffer.GetHeight, 'Buffer.GetHeight');
    CheckEquals('', Buffer.Line, 'Buffer.Line');
    CheckEquals('0123456789012345678901234567890', Buffer.Lines[0].Text, 'Buffer.Lines[0].Text');
    CheckEquals('1234567890123456789', Buffer.Lines[1].Text, 'Buffer.Lines[1].Text');
  finally
    Buffer.Free;
  end;
end;

initialization
  RegisterTest('', TPageBufferTest.Suite);

end.

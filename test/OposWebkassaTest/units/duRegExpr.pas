unit duRegExpr;

interface

uses
  // VCL
  Windows, SysUtils, Classes, SyncObjs,
  // DUnit
  TestFramework,
  // This
  RegExpr;

type
  { TRegExprTest }

  TRegExprTest = class(TTestCase)
  published
    procedure TestFontNumber;
  end;

implementation

{ TRegExprTest }

procedure TRegExprTest.TestFontNumber;
const
  Text0 = #$1B'|0fT';
  Text128 = #$1B'|128fT';
  RegExprFontIndex = '\'#$1B'\|[0-9]{0,3}fT';
var
  R: TRegExpr;
begin
  CheckEquals(True, ExecRegExpr(RegExprFontIndex, Text0));
  CheckEquals(True, ExecRegExpr(RegExprFontIndex, Text128));

  R := TRegExpr.Create;
  try
    R.Expression := '[0-9]{0,3}';
    CheckEquals(True, R.Exec(Text0));
    CheckEquals('0', R.Match[0], 'R.Match[0]');
    CheckEquals(True, R.Exec(Text128));
    CheckEquals('128', R.Match[0], 'R.Match[0]');
  finally
    R.Free;
  end;
end;

initialization
  RegisterTest('', TRegExprTest.Suite);


end.

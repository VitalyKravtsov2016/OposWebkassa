
unit duOposUtils;

interface

uses
  // VCL
  Windows, SysUtils, Classes, SyncObjs, Math, 
  // DUnit
  TestFramework,
  // Opos
  OposUtils, EscPrinter, StringUtils;

type
  { TOposUtilsTest }

  TOposUtilsTest = class(TTestCase)
  published
    procedure TestCeil;
    procedure TestStrToNibble;
  end;

implementation

{ TOposUtilsTest }

procedure TOposUtilsTest.TestCeil;
begin
  CheckEquals(2, Ceil(1.01));
  CheckEquals(2, Ceil(1.99));
  CheckEquals(2, Ceil(2.0));
  CheckEquals(3, Ceil(2.01));
end;

procedure TOposUtilsTest.TestStrToNibble;
const
  Data = 'http://dev.kofd.kz/consumer?i=925871425876&f=211030200207&s=15443.72&t=20220826T210014'#13#10;
  DataNibble = '687474703:2?2?6465762>6;6?66642>6;7:2?636?6>73756=65723?693=39323538373134323538373626663=32313130333032303032303726733=31353434332>373226743=3230323230383236543231303031340=0:';
var
  S: AnsiString;
begin
  S := OposStrToNibble(Data);
  CheckEquals(DataNibble, S, 'OposStrToNibble');

  S := OposNibbleToStr(OposStrToNibble(Data));
  CheckEquals(S, Data, 'Data');;
end;

(*
(*
class function TEscPrinter.ProcessEsc(const Text: string): string;
begin
  Result := Text;
  Result := ReplaceRegExpr('\' + ESC + '\|[0-9]{0,3}\P', Result, #$1B#$69);
  Result := StringReplace(Result, ESC + '|1C', #$1C#$21#$00, []);
  Result := StringReplace(Result, ESC + '|2C', #$1C#$21#$40, []);
  Result := StringReplace(Result, ESC + '|3C', #$1C#$21#$80, []);
  Result := StringReplace(Result, ESC + '|4C', #$1C#$21#$C0, []);
end;
  SetPrintMode(0);
  Text := ProcessEsc(Text);




procedure TOposUtilsTest.TestRegExpression;
var
  Text: string;
begin
  // Paper cut ESC |#P
  Text := '123' + ESC + '|75PText';
  Text := TEscPrinter.ProcessEsc(Text);
  CheckEquals('123'#$1B#$69'Text', Text, 'Paper cut ESC |#P');

  // Single high and wide ESC |1C
  Text := '123' + ESC + '|1CText';
  Text := TEscPrinter.ProcessEsc(Text);
  CheckEquals(StrToHex('123'#$1C#$21#$00'Text'), StrToHex(Text), 'Single high and wide ESC |1C');

  // Double wide ESC |2C
  Text := '123' + ESC + '|2CText';
  Text := TEscPrinter.ProcessEsc(Text);
  CheckEquals(StrToHex('123'#$1C#$21#$40'Text'), StrToHex(Text), 'Double wide ESC |2C');

  // Double high ESC |3C
  Text := '123' + ESC + '|3CText';
  Text := TEscPrinter.ProcessEsc(Text);
  CheckEquals(StrToHex('123'#$1C#$21#$80'Text'), StrToHex(Text), 'Double high ESC |3C');

  // Double high and wide ESC |4C
  Text := '123' + ESC + '|4CText';
  Text := TEscPrinter.ProcessEsc(Text);
  CheckEquals(StrToHex('123'#$1C#$21#$C0'Text'), StrToHex(Text), 'Double high and wide ESC |4C');
end;
*)

initialization
  RegisterTest('', TOposUtilsTest.Suite);

end.

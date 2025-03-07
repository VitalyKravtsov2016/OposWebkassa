unit duRegExpr;

interface

uses
  // VCL
  Windows, SysUtils, Classes, SyncObjs,
  // DUnit
  TestFramework,
  // This
  RegExpr, OposEsc;

type
  { TRegExprTest }

  TRegExprTest = class(TTestCase)
  published
    procedure TestFontNumber;
    procedure TestFontNumber2;
    procedure TestSplit;
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

procedure TRegExprTest.TestSplit;
const
  Text = '8273468273468'#$1B'|128fT987987'#$1B'|50P876876';
  RegExprEsc = '\'#$1B'\|';
var
  Pieces: TStrings;
begin
  Pieces := TStringList.Create;
  try
    SplitRegExpr(RegExprEsc, Text, Pieces);
    CheckEquals(3, Pieces.Count, 'Pieces.Count');
    CheckEquals('8273468273468', Pieces[0], 'Pieces[0]');
    CheckEquals('128fT987987', Pieces[1], 'Pieces[1]');
    CheckEquals('50P876876', Pieces[2], 'Pieces[2]');
  finally
    Pieces.Free;
  end;
end;

const
  RegExprNumber = '[0-9]{0,3}';
  RegExprFontIndex      = '\'#$1B'\|[0-9]fT';
  RegExprPartialCut     = '\'#$1B'\|[0-9]{0,3}P';
  RegExprFeedCut        = '\'#$1B'\|[0-9]{1,3}fP';
  RegExprFeedCutStamp   = '\'#$1B'\|[0-9]{1,3}sP';
  RegExprFireStamp      = '\'#$1B'\|sL'; // ESC |sL
  RegExprPrintBitmap    = '\'#$1B'\|[0-9]{1,2}B'; // ESC |#B

  /////////////////////////////////////////////////////////////////////////////
  // Print top logo
  // Prints the pre-stored top logo

  RegExprPrintTLogo     = '\'#$1B'\|tL';

  /////////////////////////////////////////////////////////////////////////////
  // Print bottom logo ESC |bL
  // Prints the pre-stored bottom logo.

  RegExprPrintBLogo    = '\'#$1B'\|bL';

  /////////////////////////////////////////////////////////////////////////////
  // Feed lines ESC |#lF
  // Feed the paper forward by lines. The character ‘#’ is
  // replaced by an ASCII decimal string telling the number of
  // lines to be fed. If ‘#’ is omitted, then one line is fed.

  RegExprFeedLines    = '\'#$1B'\|[0-9]{0,3}1F';

  /////////////////////////////////////////////////////////////////////////////
  // Feed units ESC |#uF
  // Feed the paper forward by mapping mode units. The
  // character ‘#’ is replaced by an ASCII decimal string
  // telling the number of units to be fed. If ‘#’ is omitted, then
  // one unit is fed.


function GetTag(var S: string; P: Integer; var Tag: TEscTag): Boolean;
var
  R: TRegExpr;
begin
(*
  Result := False;
  R := TRegExpr.Create;
  try
    R.Expression := RegExprNumber;
    if R.ExecPos(P) then
    begin
      R.Match[0]
        R.MatchPos[0]

      end;
    end;
  end;
    until false;

    R.Expression := RegExprFontIndex;
    CheckEquals(True, , 'R.ExecPos(1)');
    //R.Replace()
    CheckEquals('0', R.Match[0], 'R.Match[0]');



    CheckEquals(True, R.Exec(Text128));
    CheckEquals('128', R.Match[0], 'R.Match[0]');

  finally
    R.Free;
  end;
*)

end;


procedure TRegExprTest.TestFontNumber2;
const
  Text = '123'#$1B'|123fT456';
  EscPrefix = '\'#$1B'\|';
var
  S: string;
  P: Integer;
  Tag: TEscTag;
  Tags: TEscTags;
begin
  S := Text;
  repeat
    P := Pos(S, EscPrefix);
    if P >= 1 then
    begin
      //Copy(S, 1, P);
      if GetTag(S, P, Tag) then
      begin
        SetLength(Tags, Length(Tags) + 1);
        Tags[Length(Tags)-1] := Tag;
      end;
    end;
  until P = 0;

  CheckEquals(0, Length(Tags), 'Tags.Count');
end;

//initialization
//  RegisterTest('', TRegExprTest.Suite);


end.

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
    procedure TestSplit;
    procedure TestFontNumber;
    procedure TestGetTagNumber;
    procedure TestGetEscTag;
    procedure TestGetEscTags;
    procedure TestGetEscTags2;
    procedure TestGetEscTags3;
    procedure TestParseOposBarcode;
  end;

implementation

{ TRegExprTest }

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
    R.InputString := Text0;
    R.Expression := '[0-9]{0,3}';
    CheckEquals(True, R.Exec(Text0));
    CheckEquals(0, R.SubExprMatchCount, 'R.SubExprMatchCount');
    CheckEquals('0', R.Match[0], 'R.Match[0]');

    R.InputString := Text128;
    CheckEquals(True, R.Exec(Text128));
    CheckEquals('128', R.Match[0], 'R.Match[0]');
  finally
    R.Free;
  end;
end;

procedure TRegExprTest.TestGetTagNumber;
begin
  CheckEquals(123, GetTagNumber(#$1B'|123fT'), 'GetTagNumber.0');
  CheckEquals(75, GetTagNumber(#$1B'|75P'), 'GetTagNumber.1');
  CheckEquals(50, GetTagNumber(#$1B'|50P'), 'GetTagNumber.1');
end;

procedure TRegExprTest.TestGetEscTag;
var
  S: string;
  Tag: TEscTag;
begin
  S := #$1B'|123fT';
  CheckEquals(True, GetEscTag(S, Tag), 'GetEscTag.0');
  CheckEquals('', Tag.Text, 'Tag.Text.0');
  CheckEquals(Ord(ttFontIndex), Ord(Tag.TagType), 'Tag.TagType.0');
  CheckEquals(123, Tag.Number, 'Tag.Number');
end;


procedure TRegExprTest.TestGetEscTags;
var
  Tags: TEscTags;
const
  Text = '8273468273468'#$1B'|128fT987987'#$1B'|50P876876';
begin
  Tags := GetEscTags(Text);
  CheckEquals(5, Length(Tags), 'Length(Tags)');

  CheckEquals('8273468273468', Tags[0].Text, 'Tags[0].Text');
  CheckEquals(Ord(ttText), Ord(Tags[0].TagType), 'Tags[0].TagType');
  CheckEquals(0, Tags[0].Number, 'Tags[0].Number');

  CheckEquals('', Tags[1].Text, 'Tags[1].Text');
  CheckEquals(Ord(ttFontIndex), Ord(Tags[1].TagType), 'Tags[1].TagType');
  CheckEquals(128, Tags[1].Number, 'Tags[1].Number');

  CheckEquals('987987', Tags[2].Text, 'Tags[2].Text');
  CheckEquals(Ord(ttText), Ord(Tags[2].TagType), 'Tags[2].TagType');
  CheckEquals(0, Tags[2].Number, 'Tags[2].Number');

  CheckEquals('', Tags[3].Text, 'Tags[3].Text');
  CheckEquals(Ord(ttPaperCut), Ord(Tags[3].TagType), 'Tags[3].TagType');
  CheckEquals(50, Tags[3].Number, 'Tags[3].Number');

  CheckEquals('876876', Tags[4].Text, 'Tags[4].Text');
  CheckEquals(Ord(ttText), Ord(Tags[4].TagType), 'Tags[4].TagType');
  CheckEquals(0, Tags[4].Number, 'Tags[4].Number');
end;

procedure TRegExprTest.TestGetEscTags2;
var
  Tags: TEscTags;
const
  Text = '8273468273468';
begin
  Tags := GetEscTags(Text);
  CheckEquals(1, Length(Tags), 'Length(Tags)');
  CheckEquals('8273468273468', Tags[0].Text, 'Tags[0].Text');
  CheckEquals(Ord(ttText), Ord(Tags[0].TagType), 'Tags[0].TagType');
  CheckEquals(0, Tags[0].Number, 'Tags[0].Number');
end;

procedure TRegExprTest.TestGetEscTags3;
var
  Tags: TEscTags;
const
  Text = '8273468273468'#$1B'|33Rs101h200w400a-2t-13d123456789012e2873648273';
begin
  Tags := GetEscTags(Text);
  CheckEquals(3, Length(Tags), 'Length(Tags)');

  CheckEquals('8273468273468', Tags[0].Text, 'Tags[0].Text');
  CheckEquals(Ord(ttText), Ord(Tags[0].TagType), 'Tags[0].TagType');
  CheckEquals(0, Tags[0].Number, 'Tags[0].Number');

  CheckEquals('s101h200w400a-2t-13d123456789012e', Tags[1].Text, 'Tags[1].Text');
  CheckEquals(Ord(ttPrintBarcode), Ord(Tags[1].TagType), 'Tags[1].TagType');
  CheckEquals(33, Tags[1].Number, 'Tags[1].Number');

  CheckEquals('2873648273', Tags[2].Text, 'Tags[2].Text');
  CheckEquals(Ord(ttText), Ord(Tags[2].TagType), 'Tags[2].TagType');
  CheckEquals(0, Tags[2].Number, 'Tags[2].Number');
end;

procedure TRegExprTest.TestParseOposBarcode;
var
  Barcode: TOposBarcode;
begin
  Barcode := ParseOposBarcode('s101h200w400a-2t-13d123456789012e');
  CheckEquals(101, Barcode.Symbology, 'Barcode.Symbology');
  CheckEquals(200, Barcode.Height, 'Barcode.Height');
  CheckEquals(400, Barcode.Width, 'Barcode.Width');
  CheckEquals(-2, Barcode.Alignment, 'Barcode.Alignment');
  CheckEquals(-13, Barcode.TextPosition, 'Barcode.TextPosition');
  CheckEquals('123456789012', Barcode.Data, 'Barcode.Data');
end;

initialization
  RegisterTest('', TRegExprTest.Suite);


end.

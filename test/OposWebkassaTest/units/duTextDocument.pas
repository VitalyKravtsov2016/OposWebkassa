unit duTextDocument;

interface

uses
  // VCL
  Windows, SysUtils, Classes, SyncObjs,
  // DUnit
  TestFramework,
  // Opos
  Opos, OposFptr, Oposhi, OposFptrhi, OposFptrUtils, OposUtils,
  OposEvents, OposPtr, RCSEvents, OposEsc,
  // Tnt
  TntClasses, TntSysUtils,
  // This
  TextDocument, PrinterTypes;

type
  { TTextDocumentTest }

  TTextDocumentTest = class(TTestCase)
  private
    FDocument: TTextDocument;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestAdd;
    procedure TestAddItem;
  end;

implementation

{ TTextDocumentTest }

procedure TTextDocumentTest.SetUp;
begin
  inherited SetUp;
  FDocument := TTextDocument.Create;
end;

procedure TTextDocumentTest.TearDown;
begin
  FDocument.Free;
  inherited TearDown;
end;

procedure TTextDocumentTest.TestAdd;
var
  Line: WideString;
begin
  FDocument.LineChars := 42;
  CheckEquals(0, FDocument.Items.Count);
  FDocument.AddLine('—Â. π 5                                  ÿŒ ŒÀ¿ƒÕ¿ﬂ œÀ»“ ¿ MILKA BUBBLES ÃŒÀŒ◊Õ€…');
  CheckEquals(2, FDocument.Items.Count);
  Line := '—Â. π 5                                  ' + CRLF;
  CheckEquals(Length(Line), Length(FDocument.Items[0].Text), 'Length(Line)');
  CheckEquals(Line, FDocument.Items[0].Text, 'FDocument.Items[0].Text');
  Line := 'ÿŒ ŒÀ¿ƒÕ¿ﬂ œÀ»“ ¿ MILKA BUBBLES ÃŒÀŒ◊Õ€…' + CRLF;
  CheckEquals(Length(Line), Length(FDocument.Items[1].Text), 'Length(Line)');
  CheckEquals(Line, FDocument.Items[1].Text, 'FDocument.Items[1].Text');
end;

procedure TTextDocumentTest.TestAddItem;
var
  Item: TDocItem;
begin
  CheckEquals(0, FDocument.Items.Count, 'FDocument.Items.Count');
  FDocument.Items.Add;
  CheckEquals(1, FDocument.Items.Count, 'FDocument.Items.Count');
  FDocument.Clear;
  CheckEquals(0, FDocument.Items.Count, 'FDocument.Items.Count');


  FDocument.LineChars := 23;
  FDocument.LineHeight := 15;
  FDocument.LineSpacing := 10;
  Item := FDocument.AddItem('Test', STYLE_DHEIGHT);
  CheckEquals('Test', Item.Text, 'Item.Text');
  CheckEquals(STYLE_DHEIGHT, Item.Style, 'Item.Style');
  CheckEquals(FDocument.LineChars, Item.LineChars, 'Item.LineChars');
  CheckEquals(FDocument.LineHeight, Item.LineHeight, 'Item.LineHeight');
  CheckEquals(FDocument.LineSpacing, Item.LineSpacing, 'Item.LineSpacing');
end;


initialization
  RegisterTest('', TTextDocumentTest.Suite);


end.

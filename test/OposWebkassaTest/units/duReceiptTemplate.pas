unit duReceiptTemplate;

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
  ReceiptTemplate, LogFile, FileUtils, EscPrinterRongta;

type
  { TReceiptTemplateTest }

  TReceiptTemplateTest = class(TTestCase)
  private
    FLogger: ILogFile;
    FDocument: TReceiptTemplate;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestSave;
    procedure TestUnicode;
  end;

implementation

function WideStringToHex(const S: WideString): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(S) do
  begin
    if Result <> '' then Result := Result + ' ';
    Result := Result + Format('%.4X', [Ord(S[i])])
  end;
end;

{ TReceiptTemplateTest }

procedure TReceiptTemplateTest.SetUp;
begin
  inherited SetUp;
  FLogger := TLogFile.Create;
  FDocument := TReceiptTemplate.Create(FLogger);
end;

procedure TReceiptTemplateTest.TearDown;
begin
  FDocument.Free;
  inherited TearDown;
end;

procedure TReceiptTemplateTest.TestSave;
var
  FileName: string;
  Item: TTemplateItem;
  Strings: TTntStrings;
  UnicodeText: WideString;

  procedure CheckEqualsWide(S1, S2, Text: WideString);
  begin
    CheckEquals(WideStringToHex(S1), WideStringToHex(S2), Text);
  end;

begin
  Strings := TTntStringList.Create;
  try
    Strings.LoadFromFile('KazakhText.txt');
    UnicodeText := TrimRight(Strings.Text);
  finally
    Strings.Free;
  end;

  Item := FDocument.Header.Add;
  Item.Enabled := 1;
  Item.ItemType := 2;
  Item.TextStyle := 3;
  Item.Alignment := 4;
  Item.LineChars := 5;
  Item.LineSpacing := 6;
  Item.Text := UnicodeText;
  Item.FormatText := UnicodeText;
  Item := FDocument.Trailer.Add;
  Item.Enabled := 11;
  Item.ItemType := 12;
  Item.TextStyle := 13;
  Item.Alignment := 14;
  Item.LineChars := 15;
  Item.LineSpacing := 16;
  Item.Text := UnicodeText;
  Item.FormatText := UnicodeText;
  Item := FDocument.RecItem.Add;
  Item.Enabled := 31;
  Item.ItemType := 32;
  Item.TextStyle := 33;
  Item.Alignment := 34;
  Item.LineChars := 35;
  Item.LineSpacing := 36;
  Item.Text := UnicodeText;
  Item.FormatText := UnicodeText;

  FileName := GetModulePath + 'Receipt.xml';
  DeleteFile(FileName);
  CheckEquals(False, FileExists(FileName), 'FileExists(FileName).0');
  FDocument.SaveToFile(FileName);
  CheckEquals(True, FileExists(FileName), 'FileExists(FileName).1');

  FDocument.Clear;
  CheckEquals(0, FDocument.Header.Count, 'FDocument.Header.Count');
  CheckEquals(0, FDocument.Trailer.Count, 'FDocument.Trailer.Count');
  CheckEquals(0, FDocument.RecItem.Count, 'FDocument.RecItem.Count');

  FDocument.LoadFromFile(FileName);

  CheckEquals(1, FDocument.Header.Count, 'FDocument.Header.Count');
  Item := FDocument.Header.Items[0];
  CheckEquals(1, Item.Enabled, 'Item.Enabled');
  CheckEquals(2, Item.ItemType, 'Item.ItemType');
  CheckEquals(3, Item.TextStyle, 'Item.TextStyle');
  CheckEquals(4, Item.Alignment, 'Item.Alignment');
  CheckEquals(5, Item.LineChars, 'Item.LineChars');
  CheckEquals(6, Item.LineSpacing, 'Item.LineSpacing');
  CheckEqualsWide(UnicodeText, Item.Text, 'Item.Text');
  CheckEqualsWide(UnicodeText, Item.FormatText, 'Item.FormatText');

  CheckEquals(1, FDocument.Trailer.Count, 'FDocument.Trailer.Count');
  Item := FDocument.Trailer.Items[0];
  CheckEquals(11, Item.Enabled, 'Item.Enabled');
  CheckEquals(12, Item.ItemType, 'Item.ItemType');
  CheckEquals(13, Item.TextStyle, 'Item.TextStyle');
  CheckEquals(14, Item.Alignment, 'Item.Alignment');
  CheckEquals(15, Item.LineChars, 'Item.LineChars');
  CheckEquals(16, Item.LineSpacing, 'Item.LineSpacing');
  CheckEqualsWide(UnicodeText, Item.Text, 'Item.Text');
  CheckEqualsWide(UnicodeText, Item.FormatText, 'Item.FormatText');

  CheckEquals(1, FDocument.RecItem.Count, 'FDocument.RecItem.Count');
  Item := FDocument.RecItem.Items[0];
  CheckEquals(31, Item.Enabled, 'Item.Enabled');
  CheckEquals(32, Item.ItemType, 'Item.ItemType');
  CheckEquals(33, Item.TextStyle, 'Item.TextStyle');
  CheckEquals(34, Item.Alignment, 'Item.Alignment');
  CheckEquals(35, Item.LineChars, 'Item.LineChars');
  CheckEquals(36, Item.LineSpacing, 'Item.LineSpacing');
  CheckEqualsWide(UnicodeText, Item.Text, 'Item.Text');
  CheckEqualsWide(UnicodeText, Item.FormatText, 'Item.FormatText');
end;

procedure TReceiptTemplateTest.TestUnicode;
var
  i: Integer;
  UnicodeText: WideString;
begin
  UnicodeText := '';
  for i := Low(KazakhUnicodeChars) to High(KazakhUnicodeChars) do
    UnicodeText := UnicodeText + WideChar(KazakhUnicodeChars[i]);
  CheckEquals('0492 0493 049A 049B 04A2 04A3 04AE 04AF 04B0 04B1 04BA 04BB 04D8 04D9 04E8 04E9 FBE8 FBE9', WideStringToHex(UnicodeText));

  UnicodeText := '';
  UnicodeText := UnicodeText + WideChar($0492) + WideChar($0493) + WideChar($049A) + WideChar($049B) + WideChar($04A2) + WideChar($04A3);
  CheckEquals('0492 0493 049A 049B 04A2 04A3', WideStringToHex(UnicodeText));
end;

initialization
  RegisterTest('', TReceiptTemplateTest.Suite);


end.

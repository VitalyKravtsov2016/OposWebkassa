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
  ReceiptTemplate, LogFile, FileUtils;

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
  end;

implementation

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
begin
  Item := FDocument.Header.Add;
  Item.Enabled := 1;
  Item.ItemType := 2;
  Item.TextStyle := 3;
  Item.Alignment := 4;
  Item.LineChars := 5;
  Item.LineSpacing := 6;
  Item.Text := 'Test';
  Item.FormatText := 'FormatText';
  Item := FDocument.Trailer.Add;
  Item.Enabled := 11;
  Item.ItemType := 12;
  Item.TextStyle := 13;
  Item.Alignment := 14;
  Item.LineChars := 15;
  Item.LineSpacing := 16;
  Item.Text := 'Test2';
  Item.FormatText := 'FormatText2';
  Item := FDocument.RecItem.Add;
  Item.Enabled := 31;
  Item.ItemType := 32;
  Item.TextStyle := 33;
  Item.Alignment := 34;
  Item.LineChars := 35;
  Item.LineSpacing := 36;
  Item.Text := 'Test3';
  Item.FormatText := 'FormatText3';

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
  CheckEquals('Test', Item.Text, 'Item.Text');
  CheckEquals('FormatText', Item.FormatText, 'Item.FormatText');

  CheckEquals(1, FDocument.Trailer.Count, 'FDocument.Trailer.Count');
  Item := FDocument.Trailer.Items[0];
  CheckEquals(11, Item.Enabled, 'Item.Enabled');
  CheckEquals(12, Item.ItemType, 'Item.ItemType');
  CheckEquals(13, Item.TextStyle, 'Item.TextStyle');
  CheckEquals(14, Item.Alignment, 'Item.Alignment');
  CheckEquals(15, Item.LineChars, 'Item.LineChars');
  CheckEquals(16, Item.LineSpacing, 'Item.LineSpacing');
  CheckEquals('Test2', Item.Text, 'Item.Text');
  CheckEquals('FormatText2', Item.FormatText, 'Item.FormatText');

  CheckEquals(1, FDocument.RecItem.Count, 'FDocument.RecItem.Count');
  Item := FDocument.RecItem.Items[0];
  CheckEquals(31, Item.Enabled, 'Item.Enabled');
  CheckEquals(32, Item.ItemType, 'Item.ItemType');
  CheckEquals(33, Item.TextStyle, 'Item.TextStyle');
  CheckEquals(34, Item.Alignment, 'Item.Alignment');
  CheckEquals(35, Item.LineChars, 'Item.LineChars');
  CheckEquals(36, Item.LineSpacing, 'Item.LineSpacing');
  CheckEquals('Test3', Item.Text, 'Item.Text');
  CheckEquals('FormatText3', Item.FormatText, 'Item.FormatText');
end;

initialization
  RegisterTest('', TReceiptTemplateTest.Suite);


end.

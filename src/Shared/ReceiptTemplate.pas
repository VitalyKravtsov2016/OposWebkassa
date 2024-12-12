unit ReceiptTemplate;

interface

uses
  Classes, SysUtils, Variants, XMLDoc, XMLIntf, ActiveX,
  // This
  LogFile, PrinterTypes;

type
  TTemplateItem = class;
  TTemplateItems = class;

  { TReceiptTemplate }

  TReceiptTemplate = class
  private
    FLogger: ILogFile;
    FHeader: TTemplateItems;
    FRecItem: TTemplateItems;
    FTrailer: TTemplateItems;
    procedure LoadItem(Root: IXmlNode; Item: TTemplateItem);
    procedure LoadItems(Root: IXmlNode; Items: TTemplateItems);
    procedure SaveItems(Root: IXmlNode; Items: TTemplateItems);
    procedure SaveItem(Root: IXmlNode; Item: TTemplateItem);
    function GetAsXML: WideString;
    procedure SetAsXML(const Value: WideString);
  public
    constructor Create(ALogger: ILogFile);
    destructor Destroy; override;
    procedure Clear;
    procedure SetDefaults;
    procedure SaveToXml(var Xml: WideString);
    procedure LoadFromXml(const Xml: WideString);
    procedure SaveToFile(const FileName: WideString);
    procedure LoadFromFile(const FileName: WideString);

    property Logger: ILogFile read FLogger;
    property Header: TTemplateItems read FHeader;
    property Trailer: TTemplateItems read FTrailer;
    property RecItem: TTemplateItems read FRecItem;
    property AsXML: WideString read GetAsXML write SetAsXML;
  end;

  { TTemplateItems }

  TTemplateItems = class(TCollection)
  private
    function GetItem(Index: Integer): TTemplateItem;
  public
    function Add: TTemplateItem;
    function NewLine: TTemplateItem;
    procedure AddSeparator;
    function AddText(const Text: WideString): TTemplateItem;
    function AddParam(const Text: WideString): TTemplateItem;
    function AddField(const Text: WideString): TTemplateItem;
    function ItemByText(const Text: WideString): TTemplateItem;

    property Items[Index: Integer]: TTemplateItem read GetItem; default;
  end;

  { TTemplateItem }

  TTemplateItem  = class(TCollectionItem)
  private
    FValue: WideString;
    FText: WideString;
    FEnabled: Integer;
    FItemType: Integer;
    FTextStyle: Integer;
    FAlignment: Integer;
    FFormatText: WideString;
    FLineChars: Integer;
    FLineSpacing: Integer;
    FParameter: Integer;
  public
    function GetLineLength: Integer;

    property Value: WideString read FValue write FValue;
    property Text: WideString read FText write FText;
    property Enabled: Integer read FEnabled write FEnabled;
    property ItemType: Integer read FItemType write FItemType;
    property TextStyle: Integer read FTextStyle write FTextStyle;
    property Alignment: Integer read FAlignment write FAlignment;
    property FormatText: WideString read FFormatText write FFormatText;
    property LineChars: Integer read FLineChars write FLineChars;
    property LineSpacing: Integer read FLineSpacing write FLineSpacing;
    property Parameter: Integer read FParameter write FParameter;
  end;

implementation

{ TReceiptTemplate }

constructor TReceiptTemplate.Create(ALogger: ILogFile);
begin
  inherited Create;
  CoInitialize(nil);
  FLogger := ALogger;
  FHeader := TTemplateItems.Create(TTemplateItem);
  FTrailer := TTemplateItems.Create(TTemplateItem);
  FRecItem := TTemplateItems.Create(TTemplateItem);
end;

destructor TReceiptTemplate.Destroy;
begin
  CoUninitialize;
  FHeader.Free;
  FTrailer.Free;
  FRecItem.Free;
  inherited Destroy;
end;

procedure TReceiptTemplate.Clear;
begin
  FHeader.Clear;
  FTrailer.Clear;
  FRecItem.Clear;
end;

procedure TReceiptTemplate.LoadFromXml(const Xml: WideString);
var
  Root: IXmlNode;
  Doc: IXmlDocument;
begin
  Clear;
  if Xml = '' then Exit;
  try
    Doc := LoadXMLData(XML);
    Root := Doc.DocumentElement;
    LoadItems(Root.ChildNodes.FindNode('Header'), Header);
    LoadItems(Root.ChildNodes.FindNode('RecItem'), RecItem);
    LoadItems(Root.ChildNodes.FindNode('Trailer'), Trailer);
  except
    on E: Exception do
    begin
      Logger.Error('Failed to load, ' + E.Message);
    end;
  end;
end;

procedure TReceiptTemplate.LoadFromFile(const FileName: WideString);
var
  Root: IXmlNode;
  Doc: IXmlDocument;
begin
  Logger.Debug('TReceiptTemplate.LoadFromFile, ' + FileName);
  try
    if not FileExists(FileName) then
      raise Exception.Create('File not found, ' + FileName);

    Clear;
    Doc := LoadXMLDocument(FileName);
    Root := Doc.DocumentElement;
    LoadItems(Root.ChildNodes.FindNode('Header'), Header);
    LoadItems(Root.ChildNodes.FindNode('RecItem'), RecItem);
    LoadItems(Root.ChildNodes.FindNode('Trailer'), Trailer);
    Logger.Debug('TReceiptTemplate.LoadFromFile: OK');
  except
    on E: Exception do
    begin
      Logger.Error('Failed to load, ' + E.Message);
    end;
  end;
end;

procedure TReceiptTemplate.LoadItems(Root: IXmlNode; Items: TTemplateItems);
var
  i: Integer;
  Item: IXmlNode;
begin
  if Root = nil then Exit;

  for i := 0 to Root.ChildNodes.Count-1 do
  begin
    Item := Root.ChildNodes.Get(i);
    if CompareText(Item.NodeName, 'Item')=0  then
    begin
      LoadItem(Item, Items.Add);
    end;
  end;
end;

procedure TReceiptTemplate.LoadItem(Root: IXmlNode; Item: TTemplateItem);

  function GetChildValue(Root: IXmlNode; const NodeName: WideString): WideString;
  var
    Value: Variant;
  begin
    Result := '';
    Value := Root.ChildValues[NodeName];
    if not VarIsNull(Value) then
      Result := Value;
  end;

  function GetIntChildValue(Root: IXmlNode; const NodeName: WideString): Integer;
  begin
    Result := StrToIntDef(GetChildValue(Root, NodeName), 0);
  end;

begin
  Item.Text := GetChildValue(Root, 'Text');
  Item.Enabled := GetIntChildValue(Root, 'Enabled');
  Item.ItemType := GetIntChildValue(Root, 'ItemType');
  Item.TextStyle := GetIntChildValue(Root, 'TextStyle');
  Item.Alignment := GetIntChildValue(Root, 'Alignment');
  Item.FormatText := GetChildValue(Root, 'FormatText');
  Item.LineChars := GetIntChildValue(Root, 'LineChars');
  Item.LineSpacing := GetIntChildValue(Root, 'LineSpacing');
  Item.Parameter := GetIntChildValue(Root, 'Parameter');
end;

procedure TReceiptTemplate.SaveToXml(var Xml: WideString);
var
  Root: IXmlNode;
  Doc: IXmlDocument;
begin
  try
    Doc := NewXMLDocument('');
    Root := Doc.CreateElement('root', '');
    Doc.DocumentElement := Root;
    SaveItems(Root.AddChild('Header'), Header);
    SaveItems(Root.AddChild('RecItem'), RecItem);
    SaveItems(Root.AddChild('Trailer'), Trailer);
    Doc.SaveToXml(Xml);
    Xml := FormatXMLData(Xml);
  except
    on E: Exception do
    begin
      Logger.Error('Failed to load, ' + E.Message);
    end;
  end;
end;

procedure TReceiptTemplate.SaveToFile(const FileName: WideString);
var
  Root: IXmlNode;
  Doc: IXmlDocument;
begin
  Logger.Debug('TReceiptTemplate.SaveToFile, ' + FileName);
  try
    Doc := NewXMLDocument('');
    Root := Doc.CreateElement('root', '');
    Doc.DocumentElement := Root;
    SaveItems(Root.AddChild('Header'), Header);
    SaveItems(Root.AddChild('RecItem'), RecItem);
    SaveItems(Root.AddChild('Trailer'), Trailer);
    Doc.SaveToFile(FileName);
  except
    on E: Exception do
    begin
      Logger.Error('Failed to save, ' + E.Message);
    end;
  end;
end;

procedure TReceiptTemplate.SaveItems(Root: IXmlNode; Items: TTemplateItems);
var
  i: Integer;
begin
  if Root = nil then
    raise Exception.Create('Root must not be null');

  for i := 0 to Items.Count-1 do
  begin
    SaveItem(Root.AddChild('Item'), Items[i]);
  end;
end;

procedure TReceiptTemplate.SaveItem(Root: IXmlNode; Item: TTemplateItem);
begin
  Root.SetChildValue('Text', Item.Text);
  Root.SetChildValue('Enabled', IntToStr(Item.Enabled));
  Root.SetChildValue('ItemType', IntToStr(Item.ItemType));
  Root.SetChildValue('TextStyle', IntToStr(Item.TextStyle));
  Root.SetChildValue('Alignment', IntToStr(Item.Alignment));
  Root.SetChildValue('FormatText', Item.FormatText);
  Root.SetChildValue('LineChars', IntToStr(Item.LineChars));
  Root.SetChildValue('LineSpacing', IntToStr(Item.LineSpacing));
  Root.SetChildValue('Parameter', IntToStr(Item.Parameter));
end;

procedure TReceiptTemplate.SetDefaults;
var
  Item: TTemplateItem;
begin
  Clear;
  // Line 1
  Item := Header.Add;
  Item.ItemType := TEMPLATE_TYPE_CASHBOX_STATE_JSON;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Data.Xin';
  Item.FormatText := 'БСН/БИН: %s';
  Item.Alignment := ALIGN_LEFT;
  Header.NewLine;
  // Line 1
  Item := Header.Add;
  Item.ItemType := TEMPLATE_TYPE_PARAM;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'VATSeries';
  Item.FormatText := 'НДС Серия %s';
  Item.Alignment := ALIGN_LEFT;
  //
  Item := Header.Add;
  Item.ItemType := TEMPLATE_TYPE_PARAM;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'VATNumber';
  Item.FormatText := '№ %s';
  Item.Alignment := ALIGN_RIGHT;
  Header.NewLine;
  // Line 2
  Header.AddSeparator;
  // Line3
  Item := Header.Add;
  Item.ItemType := TEMPLATE_TYPE_JSON_ANS_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Data.CashBox.UniqueNumber';
  Item.FormatText := '               %s';
  Item.Alignment := ALIGN_LEFT;
  // Line2
  Header.NewLine;
  // Line4
  Item := Header.Add;
  Item.ItemType := TEMPLATE_TYPE_JSON_ANS_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Data.ShiftNumber';
  Item.FormatText := 'СМЕНА №%s';
  Item.Alignment := ALIGN_CENTER;
  Header.NewLine;
  // Тип чека
  Item := Header.Add;
  Item.ItemType := TEMPLATE_TYPE_ITEM_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'OperationTypeText';
  Item.FormatText := '';
  Item.Alignment := ALIGN_LEFT;
  Header.NewLine;
  Header.AddSeparator;
  // Description
  Item := RecItem.Add;
  Item.ItemType := TEMPLATE_TYPE_ITEM_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Description';
  Item.FormatText := '';
  Item.Alignment := ALIGN_LEFT;
  RecItem.NewLine;
  // Quantity
  Item := RecItem.Add;
  Item.ItemType := TEMPLATE_TYPE_ITEM_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Quantity';
  Item.FormatText := '   %s';
  Item.Alignment := ALIGN_LEFT;
  // UnitName
  Item := RecItem.Add;
  Item.ItemType := TEMPLATE_TYPE_ITEM_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'UnitName';
  Item.FormatText := ' %s x ';
  Item.Alignment := ALIGN_LEFT;
  // Price
  Item := RecItem.Add;
  Item.ItemType := TEMPLATE_TYPE_ITEM_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'UnitPrice';
  Item.FormatText := '%s ';
  Item.Alignment := ALIGN_LEFT;
  // Currency name
  Item := RecItem.Add;
  Item.ItemType := TEMPLATE_TYPE_PARAM;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'CurrencyName';
  Item.FormatText := '';
  Item.Alignment := ALIGN_LEFT;
  // Total
  Item := RecItem.Add;
  Item.ItemType := TEMPLATE_TYPE_ITEM_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Price';
  Item.FormatText := '=%s';
  Item.Alignment := ALIGN_RIGHT;
  RecItem.NewLine;
  // Discount
  RecItem.AddText('   Скидка');
  Item := RecItem.Add;
  Item.ItemType := TEMPLATE_TYPE_ITEM_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Discount';
  Item.FormatText := '-%s';
  Item.Alignment := ALIGN_RIGHT;
  Item.Enabled := TEMPLATE_ITEM_ENABLED_IF_NOT_ZERO;
  RecItem.NewLine;
  // Charge
  RecItem.AddText('   Наценка');
  Item := RecItem.Add;
  Item.ItemType := TEMPLATE_TYPE_ITEM_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Charge';
  Item.FormatText := '+%s';
  Item.Alignment := ALIGN_RIGHT;
  Item.Enabled := TEMPLATE_ITEM_ENABLED_IF_NOT_ZERO;
  RecItem.NewLine;
  // Separator
  Trailer.AddSeparator;
  // Discount
  Trailer.AddText('Скидка:');
  Item := Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_ITEM_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Discount';
  Item.FormatText := '%s';
  Item.Alignment := ALIGN_RIGHT;
  Item.Enabled := TEMPLATE_ITEM_ENABLED_IF_NOT_ZERO;
  Trailer.NewLine;
  // Charge
  Trailer.AddText('Наценка:');
  Item := Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_ITEM_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Charge';
  Item.FormatText := '%s';
  Item.Alignment := ALIGN_RIGHT;
  Item.Enabled := TEMPLATE_ITEM_ENABLED_IF_NOT_ZERO;
  Trailer.NewLine;
  // Total
  Item := Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_TEXT;
  Item.TextStyle := STYLE_DWIDTH_HEIGHT;
  Item.Alignment := ALIGN_LEFT;
  Item.Text := 'ИТОГ';
  Item := Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_ITEM_FIELD;
  Item.TextStyle := STYLE_DWIDTH_HEIGHT;
  Item.Text := 'Total';
  Item.FormatText := '=%s';
  Item.Alignment := ALIGN_RIGHT;
  Item.Enabled := TEMPLATE_ITEM_ENABLED;
  Trailer.NewLine;
  // Payment0
  Trailer.AddText('Наличные:');
  Item := Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_ITEM_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Payment0';
  Item.FormatText := '=%s';
  Item.Alignment := ALIGN_RIGHT;
  Item.Enabled := TEMPLATE_ITEM_ENABLED_IF_NOT_ZERO;
  Trailer.NewLine;
  // Payment1
  Trailer.AddText('Банковская карта:');
  Item := Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_ITEM_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Payment1';
  Item.FormatText := '=%s';
  Item.Alignment := ALIGN_RIGHT;
  Item.Enabled := TEMPLATE_ITEM_ENABLED_IF_NOT_ZERO;
  Trailer.NewLine;
  // Payment2
  Trailer.AddText('Кредит:');
  Item := Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_ITEM_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Payment2';
  Item.FormatText := '=%s';
  Item.Alignment := ALIGN_RIGHT;
  Item.Enabled := TEMPLATE_ITEM_ENABLED_IF_NOT_ZERO;
  Trailer.NewLine;
  // Payment3
  Trailer.AddText('Оплата тарой:');
  Item := Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_ITEM_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Payment3';
  Item.FormatText := '=%s';
  Item.Alignment := ALIGN_RIGHT;
  Item.Enabled := TEMPLATE_ITEM_ENABLED_IF_NOT_ZERO;
  Trailer.NewLine;
  // Payment4
  Trailer.AddText('Мобильный платеж:');
  Item := Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_ITEM_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Payment4';
  Item.FormatText := '=%s';
  Item.Alignment := ALIGN_RIGHT;
  Item.Enabled := TEMPLATE_ITEM_ENABLED_IF_NOT_ZERO;
  Trailer.NewLine;
  // Change
  Trailer.AddText('  СДАЧА');
  Item := Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_ITEM_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Change';
  Item.FormatText := '=%s';
  Item.Alignment := ALIGN_RIGHT;
  Item.Enabled := TEMPLATE_ITEM_ENABLED_IF_NOT_ZERO;
  Trailer.NewLine;
  // Taxes
  Trailer.AddText('в т.ч. НДС 12%');
  Item := Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_ITEM_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'TaxAmount';
  Item.FormatText := '=%s';
  Item.Alignment := ALIGN_RIGHT;
  Item.Enabled := TEMPLATE_ITEM_ENABLED_IF_NOT_ZERO;
  Item.Parameter := 1;
  Trailer.NewLine;
  // Separator
  Trailer.AddSeparator;
  // Start pagemode
  Item := Trailer.Add;
  Item.TextStyle := STYLE_START_PM;
  // QR code
  Item := Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_JSON_ANS_FIELD;
  Item.TextStyle := STYLE_QR_CODE;
  Item.Text := 'Data.TicketUrl';
  Item.Alignment := ALIGN_CENTER;
  // Fiscal sign
  Trailer.AddText('ФП: ');
  Item := Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_JSON_ANS_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Data.CheckNumber';
  Item.FormatText := '';
  Item.Alignment := ALIGN_LEFT;
  Item.Enabled := TEMPLATE_ITEM_ENABLED;
  Trailer.NewLine;
  // Time
  Trailer.AddText('Время: ');
  Item := Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_JSON_ANS_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Data.DateTime';
  Item.FormatText := '';
  Item.Alignment := ALIGN_LEFT;
  Item.Enabled := TEMPLATE_ITEM_ENABLED;
  Trailer.NewLine;
  // Fiscal data operator
  Trailer.AddText('ОФД: ');
  Item := Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_JSON_ANS_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Data.Cashbox.Ofd.Name';
  Item.FormatText := '';
  Item.Alignment := ALIGN_LEFT;
  Item.Enabled := TEMPLATE_ITEM_ENABLED;
  Trailer.NewLine;
  // Ticket URL
  Trailer.AddText('Для проверки чека:');
  Trailer.NewLine;
  Item := Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_JSON_ANS_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Data.Cashbox.Ofd.Host';
  Item.FormatText := '';
  Item.Alignment := ALIGN_LEFT;
  Item.Enabled := TEMPLATE_ITEM_ENABLED;
  Trailer.NewLine;
  // End pagemode
  Item := Trailer.Add;
  Item.TextStyle := STYLE_END_PM;
  // Separator
  Trailer.AddSeparator;
  // Fiscal receipt
  Item := Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_JSON_ANS_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Data.Cashbox.IdentityNumber';
  Item.FormatText := 'ИНК ОФД: %s';
  Item.Alignment := ALIGN_CENTER;
  Trailer.NewLine;
  // Registration number
  Item := Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_JSON_ANS_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Data.Cashbox.RegistrationNumber';
  Item.FormatText := 'Код ККМ КГД (РНМ): %s';
  Item.Alignment := ALIGN_CENTER;
  Trailer.NewLine;
  // Unique number
  Item := Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_JSON_ANS_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Data.Cashbox.UniqueNumber';
  Item.FormatText := 'ЗНМ: %s';
  Item.Alignment := ALIGN_CENTER;
  Trailer.NewLine;
end;

function TReceiptTemplate.GetAsXML: WideString;
begin
  SaveToXml(Result);
end;

procedure TReceiptTemplate.SetAsXML(const Value: WideString);
begin
  LoadFromXml(Value);
end;

{ TTemplateItems }

function TTemplateItems.Add: TTemplateItem;
begin
  Result := TTemplateItem.Create(Self);
end;

function TTemplateItems.NewLine: TTemplateItem;
begin
  Result := TTemplateItem.Create(Self);
  Result.ItemType := TEMPLATE_TYPE_NEWLINE;
end;

function TTemplateItems.AddText(const Text: WideString): TTemplateItem;
begin
  Result := TTemplateItem.Create(Self);
  Result.FItemType := TEMPLATE_TYPE_TEXT;
  Result.FTextStyle := STYLE_NORMAL;
  Result.FText := Text;
end;

function TTemplateItems.AddParam(const Text: WideString): TTemplateItem;
begin
  Result := TTemplateItem.Create(Self);
  Result.FItemType := TEMPLATE_TYPE_PARAM;
  Result.FTextStyle := STYLE_NORMAL;
  Result.FText := Text;
end;

function TTemplateItems.AddField(const Text: WideString): TTemplateItem;
begin
  Result := TTemplateItem.Create(Self);
  Result.FItemType := TEMPLATE_TYPE_ITEM_FIELD;
  Result.FTextStyle := STYLE_NORMAL;
  Result.FText := Text;
end;

function TTemplateItems.GetItem(Index: Integer): TTemplateItem;
begin
  Result := inherited Items[Index] as TTemplateItem;
end;

procedure TTemplateItems.AddSeparator;
var
  Item: TTemplateItem;
begin
  Item := TTemplateItem.Create(Self);
  Item.FItemType := TEMPLATE_TYPE_SEPARATOR;
  Item.FTextStyle := STYLE_NORMAL;
  Item.FText := '';

  Item := TTemplateItem.Create(Self);
  Item.ItemType := TEMPLATE_TYPE_NEWLINE;
end;

function TTemplateItems.ItemByText(const Text: WideString): TTemplateItem;
var
  i: Integer;
begin
  for i := 0 to Count-1 do
  begin
    Result := Items[i];
    if CompareText(Result.Text, Text) = 0 then Exit;
  end;
  Result := nil;
end;

{ TTemplateItem }

function TTemplateItem.GetLineLength: Integer;
begin
  Result := LineChars;
  if (TextStyle = STYLE_DWIDTH) or (TextStyle = STYLE_DWIDTH_HEIGHT) then
    Result := LineChars div 2;
end;

end.

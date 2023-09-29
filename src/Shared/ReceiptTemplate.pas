unit ReceiptTemplate;

interface

uses
  Classes, SysUtils,
  // This
  LogFile, XmlParser, PrinterTypes;

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
    procedure LoadItem(Root: TXmlItem; Item: TTemplateItem);
    procedure LoadItems(Root: TXmlItem; Items: TTemplateItems);
    procedure SaveItems(Root: TXmlItem; Items: TTemplateItems);
    procedure SaveItem(Root: TXmlItem; Item: TTemplateItem);
    function GetAsXML: WideString;
    procedure SetAsXML(const Value: WideString);
  public
    constructor Create(ALogger: ILogFile);
    destructor Destroy; override;
    procedure Clear;
    procedure SetDefaults;
    procedure SaveToXml(var Xml: WideString);
    procedure LoadFromXml(const Xml: WideString);

    procedure SaveToFile(const FileName: string);
    procedure LoadFromFile(const FileName: string);

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
  end;

implementation

{ TReceiptTemplate }

constructor TReceiptTemplate.Create(ALogger: ILogFile);
begin
  inherited Create;
  FLogger := ALogger;
  FHeader := TTemplateItems.Create(TTemplateItem);
  FTrailer := TTemplateItems.Create(TTemplateItem);
  FRecItem := TTemplateItems.Create(TTemplateItem);
end;

destructor TReceiptTemplate.Destroy;
begin
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
  Parser: TXmlParser;
begin
  Clear;
  if Xml = '' then Exit;

  Parser := TXmlParser.Create;
  try
    Parser.LoadFromString(Utf8Encode(Xml));

    LoadItems(Parser.Root.FindItem('Header'), Header);
    LoadItems(Parser.Root.FindItem('RecItem'), RecItem);
    LoadItems(Parser.Root.FindItem('Trailer'), Trailer);
  except
    on E: Exception do
    begin
      Logger.Error('Failed to load, ' + E.Message);
    end;
  end;
  Parser.Free;
end;

procedure TReceiptTemplate.LoadFromFile(const FileName: string);
var
  Parser: TXmlParser;
begin
  Clear;
  if not FileExists(FileName) then
    raise Exception.Create('File not found');

  Parser := TXmlParser.Create;
  try
    Parser.LoadFromFile(FileName);
    LoadItems(Parser.Root.FindItem('Header'), Header);
    LoadItems(Parser.Root.FindItem('RecItem'), RecItem);
    LoadItems(Parser.Root.FindItem('Trailer'), Trailer);
  except
    on E: Exception do
    begin
      Logger.Error('Failed to load, ' + E.Message);
    end;
  end;
  Parser.Free;
end;

procedure TReceiptTemplate.LoadItems(Root: TXmlItem; Items: TTemplateItems);
var
  i: Integer;
  Item: TXmlItem;
begin
  if Root = nil then Exit;
  for i := 0 to Root.Count-1 do
  begin
    Item := Root[i];
    if Item.NameIsEqual('Item')  then
    begin
      LoadItem(Item, Items.Add);
    end;
  end;
end;

procedure TReceiptTemplate.LoadItem(Root: TXmlItem; Item: TTemplateItem);
begin
  Item.Text := Root.GetText('Text');
  Item.Enabled := Root.GetIntDef('Enabled', 0);
  Item.ItemType := Root.GetIntDef('ItemType', 0);
  Item.TextStyle := Root.GetIntDef('TextStyle', 0);
  Item.Alignment := Root.GetIntDef('Alignment', 0);
  Item.FormatText := Root.GetText('FormatText');
  Item.LineChars := Root.GetIntDef('LineChars', 0);
  Item.LineSpacing := Root.GetIntDef('LineSpacing', 0);
end;

procedure TReceiptTemplate.SaveToXml(var Xml: WideString);
var
  Parser: TXmlParser;
begin
  Parser := TXmlParser.Create;
  try
    SaveItems(Parser.Root.Add('Header'), Header);
    SaveItems(Parser.Root.Add('RecItem'), RecItem);
    SaveItems(Parser.Root.Add('Trailer'), Trailer);
    Xml := Utf8Decode(Parser.GetXml);
  except
    on E: Exception do
    begin
      Logger.Error('Failed to load, ' + E.Message);
    end;
  end;
  Parser.Free;
end;

procedure TReceiptTemplate.SaveToFile(const FileName: string);
var
  Parser: TXmlParser;
begin
  Parser := TXmlParser.Create;
  try
    SaveItems(Parser.Root.Add('Header'), Header);
    SaveItems(Parser.Root.Add('RecItem'), RecItem);
    SaveItems(Parser.Root.Add('Trailer'), Trailer);
    Parser.SaveToFile(FileName);
  except
    on E: Exception do
    begin
      Logger.Error('Failed to load, ' + E.Message);
    end;
  end;
  Parser.Free;
end;

procedure TReceiptTemplate.SaveItems(Root: TXmlItem; Items: TTemplateItems);
var
  i: Integer;
begin
  if Root = nil then Exit;
  for i := 0 to Items.Count-1 do
  begin
    SaveItem(Root.Add('Item'), Items[i]);
  end;
end;

procedure TReceiptTemplate.SaveItem(Root: TXmlItem; Item: TTemplateItem);
begin
  Root.AddText('Text', Item.Text);
  Root.AddInt('Enabled', Item.Enabled);
  Root.AddInt('ItemType', Item.ItemType);
  Root.AddInt('TextStyle', Item.TextStyle);
  Root.AddInt('Alignment', Item.Alignment);
  Root.AddText('FormatText', Item.FormatText);
  Root.AddInt('LineChars', Item.LineChars);
  Root.AddInt('LineSpacing', Item.LineSpacing);
end;

procedure TReceiptTemplate.SetDefaults;
var
  Item: TTemplateItem;
begin
  Clear;
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
  // Total
  RecItem.AddText('   Стоимость');
  Item := RecItem.Add;
  Item.ItemType := TEMPLATE_TYPE_ITEM_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Total';
  Item.FormatText := '';
  Item.Alignment := ALIGN_RIGHT;
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
  Item.ItemType := TEMPLATE_TYPE_JSON_REC_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Data.Tax';
  Item.FormatText := '=%s';
  Item.Alignment := ALIGN_RIGHT;
  Item.Enabled := TEMPLATE_ITEM_ENABLED_IF_NOT_ZERO;
  Trailer.NewLine;
  // Separator
  Trailer.AddSeparator;
  // Fiscal sign
  Trailer.AddText('Фискальный признак: ');
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
  Trailer.AddText('Оператор фискальных данных:');
  Trailer.NewLine;
  Item := Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_JSON_ANS_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Data.Cashbox.Ofd.Name';
  Item.FormatText := '';
  Item.Alignment := ALIGN_LEFT;
  Item.Enabled := TEMPLATE_ITEM_ENABLED;
  Trailer.NewLine;
  // Ticket URL
  Trailer.AddText('Для проверки чека зайдите на сайт:');
  Trailer.NewLine;
  Item := Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_JSON_ANS_FIELD;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'Data.Cashbox.Ofd.Host';
  Item.FormatText := '';
  Item.Alignment := ALIGN_LEFT;
  Item.Enabled := TEMPLATE_ITEM_ENABLED;
  Trailer.NewLine;
  // Separator
  Trailer.AddSeparator;
  // Fiscal receipt
  Item := Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_TEXT;
  Item.TextStyle := STYLE_NORMAL;
  Item.Text := 'ФИСКАЛЬНЫЙ ЧЕK';
  Item.Alignment := ALIGN_CENTER;
  Trailer.NewLine;
  // QR code
  Item := Trailer.Add;
  Item.ItemType := TEMPLATE_TYPE_JSON_ANS_FIELD;
  Item.TextStyle := STYLE_QR_CODE;
  Item.Text := 'Data.TicketUrl';
  Item.Alignment := ALIGN_CENTER;
  Trailer.NewLine;
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

{ TTemplateItem }

function TTemplateItem.GetLineLength: Integer;
begin
  Result := LineChars;
  if (TextStyle = STYLE_DWIDTH) or (TextStyle = STYLE_DWIDTH_HEIGHT) then
    Result := LineChars div 2;
end;

end.

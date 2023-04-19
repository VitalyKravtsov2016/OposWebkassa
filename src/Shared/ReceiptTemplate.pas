unit ReceiptTemplate;

interface

uses
  Classes;

const
  STYLE_NORMAL        = 0;
  STYLE_BOLD          = 1;
  STYLE_ITALIC        = 2;
  STYLE_DWIDTH        = 3;
  STYLE_DHEIGHT       = 4;
  STYLE_DWIDTH_HEIGHT = 5;
  STYLE_QR_CODE       = 6;
  STYLE_IMAGE         = 7;

  /////////////////////////////////////////////////////////////////////////////
  // Template item types

  TEMPLATE_TYPE_TEXT          = 0;
  TEMPLATE_TYPE_PARAM         = 1;
  TEMPLATE_TYPE_ITEM_FIELD    = 2;
  TEMPLATE_TYPE_JSON_FIELD    = 3;
  TEMPLATE_TYPE_SEPARATOR     = 4;
  TEMPLATE_TYPE_NEWLINE       = 5;

  /////////////////////////////////////////////////////////////////////////////
  // Alignment constants

  ALIGN_LEFT    = 0;
  ALIGN_CENTER  = 1;
  ALIGN_RIGHT   = 2;

  /////////////////////////////////////////////////////////////////////////////
  // Enabled constants

  TEMPLATE_ITEM_ENABLED             = 0;
  TEMPLATE_ITEM_ENABLED_IF_NOT_ZERO = 1;


type
  TTemplateItem = class;
  TTemplateItems = class;

  { TReceiptTemplate }

  TReceiptTemplate = class
  private
    FHeader: TTemplateItems;
    FTrailer: TTemplateItems;
    FRecItem: TTemplateItems;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure SaveToXml(const FileName: string);
    procedure LoadFromXml(const FileName: string);

    property Header: TTemplateItems read FHeader;
    property Trailer: TTemplateItems read FTrailer;
    property RecItem: TTemplateItems read FRecItem;
  end;

  { TTemplateItems }

  TTemplateItems = class(TCollection)
  private
    function GetItem(Index: Integer): TTemplateItem;
  public
    function Add: TTemplateItem;
    function NewLine: TTemplateItem;
    function AddSeparator: TTemplateItem;
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
  public
    property Value: WideString read FValue write FValue;
    property Text: WideString read FText write FText;
    property Enabled: Integer read FEnabled write FEnabled;
    property ItemType: Integer read FItemType write FItemType;
    property TextStyle: Integer read FTextStyle write FTextStyle;
    property Alignment: Integer read FAlignment write FAlignment;
    property FormatText: WideString read FFormatText write FFormatText;
  end;

implementation

{ TReceiptTemplate }

constructor TReceiptTemplate.Create;
begin
  inherited Create;
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

procedure TReceiptTemplate.LoadFromXml(const FileName: string);
begin
  { !!! }
end;

procedure TReceiptTemplate.SaveToXml(const FileName: string);
begin
  { !!! }
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

function TTemplateItems.AddSeparator: TTemplateItem;
begin
  Result := TTemplateItem.Create(Self);
  Result.FItemType := TEMPLATE_TYPE_SEPARATOR;
  Result.FTextStyle := STYLE_NORMAL;
  Result.FText := '';
end;

end.

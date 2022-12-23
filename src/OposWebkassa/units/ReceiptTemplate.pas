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

  TEMPLATE_TYPE_TEXT      = 0;
  TEMPLATE_TYPE_PARAM     = 1;
  TEMPLATE_TYPE_FIELD     = 2;
  TEMPLATE_TYPE_SEPARATOR = 3;

  /////////////////////////////////////////////////////////////////////////////
  // Alignment constants

  ALIGN_LEFT    = 0;
  ALIGN_CENTER  = 1;
  ALIGN_RIGHT   = 2;


type
  TTemplateItem = class;
  TTemplateItems = class;

  { TReceiptTemplate }

  TReceiptTemplate = class
  private
    FItems: TTemplateItems;
  public
    constructor Create;
    destructor Destroy; override;
    property Items: TTemplateItems read FItems;
  end;

  { TTemplateItems }

  TTemplateItems = class(TCollection)
  private
    function GetItem(Index: Integer): TTemplateItem;
  public
    function Add: TTemplateItem;
    function AddSeparator: TTemplateItem;
    function AddText(const Text: WideString): TTemplateItem;
    function AddParam(const Text: WideString): TTemplateItem;
    function AddField(const Text: WideString): TTemplateItem;
    property Items[Index: Integer]: TTemplateItem read GetItem; default;
  end;

  { TTemplateItem }

  TTemplateItem  = class(TCollectionItem)
  private
    FText: WideString;
    FItemType: Integer;
    FTextStyle: Integer;
    FAlignment: Integer;
  public
    property Text: WideString read FText write FText;
    property ItemType: Integer read FItemType write FItemType;
    property TextStyle: Integer read FTextStyle write FTextStyle;
    property Alignment: Integer read FAlignment write FAlignment;
  end;

implementation

{ TReceiptTemplate }

constructor TReceiptTemplate.Create;
begin
  inherited Create;
  FItems := TTemplateItems.Create(TTemplateItem);
end;

destructor TReceiptTemplate.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

{ TTemplateItems }

function TTemplateItems.Add: TTemplateItem;
begin
  Result := TTemplateItem.Create(Self);
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
  Result.FItemType := TEMPLATE_TYPE_FIELD;
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

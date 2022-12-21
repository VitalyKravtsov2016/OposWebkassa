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

  TEMPLATE_TYPE_TEXT        = 0;
  TEMPLATE_TYPE_JSON_FIELD  = 1;


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
    property Items[Index: Integer]: TTemplateItem read GetItem; default;
  end;

  { TTemplateItem }

  TTemplateItem  = class(TCollectionItem)
  private
    FText: WideString;
    FItemType: Integer;
    FTextStyle: Integer;
  public
    property Text: WideString read FText;
    property ItemType: Integer read FItemType;
    property TextStyle: Integer read FTextStyle;
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

function TTemplateItems.GetItem(Index: Integer): TTemplateItem;
begin
  Result := inherited Items[Index] as TTemplateItem;
end;

end.

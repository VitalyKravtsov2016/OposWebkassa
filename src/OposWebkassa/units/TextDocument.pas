unit TextDocument;

interface

uses
  // VCL
  Classes, SysUtils, TntSysUtils,
  // This
  StringUtils;

const
  STYLE_NORMAL        = 0;
  STYLE_BOLD          = 1;
  STYLE_ITALIC        = 2;
  STYLE_DWIDTH        = 3;
  STYLE_DHEIGHT       = 4;
  STYLE_DWIDTH_HEIGHT = 5;
  STYLE_QR_CODE       = 6;
  STYLE_IMAGE         = 7;

type
  TTextItem = class;
  TTextItems = class;

  { TTextDocument }

  TTextDocument = class
  private
    FItems: TTextItems;
    FLineChars: Integer;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear;
    procedure AddText(const Text: string);
    procedure Add(const Line: string); overload;
    procedure AddLines(const Line1, Line2: string); overload;
    procedure AddLines(const Line1, Line2: string; Style: Integer); overload;
    procedure Add(const Line: string; Style: Integer); overload;
    procedure AddCurrency(const Line: string; Value: Currency);

    property Items: TTextItems read FItems;
    property LineChars: Integer read FLineChars write FLineChars;
  end;

  { TTextItems }

  TTextItems = class(TCollection)
  private
    function GetItem(Index: Integer): TTextItem;
  public
    function Add: TTextItem;
    property Items[Index: Integer]: TTextItem read GetItem; default;
  end;

  { TTextItem }

  TTextItem = class(TCollectionItem)
  private
    FStyle: Integer;
    FText: WideString;
  public
    property Style: Integer read FStyle;
    property Text: WideString read FText;
  end;

implementation

{ TTextDocument }

constructor TTextDocument.Create;
begin
  inherited Create;
  FItems := TTextItems.Create(TTextItem);
end;

destructor TTextDocument.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

procedure TTextDocument.Add(const Line: string);
begin
  Add(Line, STYLE_NORMAL);
end;

procedure TTextDocument.Add(const Line: string; Style: Integer);
var
  Item: TTextItem;
begin
  Item := FItems.Add;
  Item.FText := Line + CRLF;
  Item.FStyle := Style;
end;

procedure TTextDocument.AddLines(const Line1, Line2: string; Style: Integer);
var
  Text: string;
begin
  Text := Line1 + StringOfChar(' ', LineChars-Length(Line1)-Length(Line2)) + Line2;
  Add(Text, Style);
end;

procedure TTextDocument.AddLines(const Line1, Line2: string);
begin
  AddLines(Line1, Line2, STYLE_NORMAL);
end;

procedure TTextDocument.AddCurrency(const Line: string; Value: Currency);
var
  Text: string;
begin
  Text := '=' + CurrencyToStr(Value);
  Text := Line + StringOfChar(' ', LineChars-Length(Line)-Length(Text)) + Text;
  Add(Text, STYLE_BOLD);
end;

procedure TTextDocument.AddText(const Text: string);
var
  i: Integer;
  Lines: TStrings;
begin
  Lines := TStringList.Create;
  try
    Lines.Text := Text;
    for i := 0 to Lines.Count-1 do
    begin
      Add(Lines[i]);
    end;
  finally
    Lines.Free;
  end;
end;

procedure TTextDocument.Clear;
begin
  FItems.Clear;
end;

{ TTextItems }

function TTextItems.Add: TTextItem;
begin
  Result := TTextItem.Create(Self);
end;

function TTextItems.GetItem(Index: Integer): TTextItem;
begin
  Result := inherited Items[Index] as TTextItem;
end;

end.

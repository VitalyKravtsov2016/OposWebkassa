unit TextDocument;

interface

uses
  // VCL
  Classes, SysUtils, TntSysUtils, Graphics,
  // Tnt
  TntClasses,
  // Opos
  OposUtils,
  // This
  StringUtils, PrinterTypes;

type
  TDocItem = class;
  TDocItems = class;

  { TTextDocument }

  TTextDocument = class
  private
    FItems: TDocItems;
    FLineChars: Integer;
    FLineHeight: Integer;
    FLineSpacing: Integer;
    procedure Add(Index: Integer; const Line: WideString); overload;
    procedure Add2(const ALine: WideString; Style: Integer);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Save;
    procedure Clear;
    procedure AddSeparator;
    procedure AddText(const Text: WideString); overload;
    procedure AddText(Index: Integer; const Text: WideString); overload;

    procedure AddLine(const Line: WideString); overload;
    procedure AddLine(const ALine: WideString; Style: Integer); overload;
    procedure AddLines(const Line1, Line2: WideString); overload;
    procedure AddLines(const Line1, Line2: WideString; Style: Integer); overload;
    function AlignCenter(const Line: WideString): WideString;
    function ConcatLines(const Line1, Line2: WideString; LineChars: Integer): WideString;
    function AddItem(const Line: WideString; Style: Integer): TDocItem;
    function GetLineLength(Style: Integer): Integer;
    procedure Assign(Source: TTextDocument);
    procedure Add(const ALine: WideString; Style: Integer); overload;
    procedure AddBarcode(const Barcode: string);

    property Items: TDocItems read FItems;
    property LineChars: Integer read FLineChars write FLineChars;
    property LineHeight: Integer read FLineHeight write FLineHeight;
    property LineSpacing: Integer read FLineSpacing write FLineSpacing;
  end;

  { TDocItems }

  TDocItems = class(TCollection)
  private
    function GetItem(Index: Integer): TDocItem;
  public
    property Items[Index: Integer]: TDocItem read GetItem; default;
  end;

  { TDocItem }

  TDocItem = class(TCollectionItem)
  private
    FStyle: Integer;
    FText: WideString;
    FLineChars: Integer;
    FLineHeight: Integer;
    FLineSpacing: Integer;
  public
    procedure Assign(Source: TPersistent); override;

    property Style: Integer read FStyle;
    property Text: WideString read FText;
    property LineChars: Integer read FLineChars;
    property LineHeight: Integer read FLineHeight;
    property LineSpacing: Integer read FLineSpacing;
  end;

function AlignCenter2(const Line: WideString; LineWidth: Integer): WideString;

implementation

function AlignCenter2(const Line: WideString; LineWidth: Integer): WideString;
var
  L: Integer;
begin
  Result := Copy(Line, 1, LineWidth);
  if Length(Result) < LineWidth then
  begin
    L := (LineWidth - Length(Result)) div 2;
    Result := StringOfChar(' ', L) + Result;
  end;
end;


{ TTextDocument }

constructor TTextDocument.Create;
begin
  inherited Create;
  FItems := TDocItems.Create(TDocItem);
  LineChars := 42;
  LineHeight := 12;
  LineSpacing := 10;
end;

destructor TTextDocument.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

procedure TTextDocument.AddLine(const Line: WideString);
begin
  Add(Line + CRLF, STYLE_NORMAL);
end;

procedure TTextDocument.AddLine(const ALine: WideString; Style: Integer);
begin
  Add(ALine + CRLF, Style);
end;

procedure TTextDocument.Add(const ALine: WideString; Style: Integer);
var
  P: Integer;
  Text: WideString;
  Line: WideString;
begin
  Text := ALine;
  repeat
    P := Pos(CRLF, Text);
    if P <> 0 then
    begin
      Line := Copy(Text, 1, P + 1);
      Text := Copy(Text, P + 2, Length(Text));
    end  else
    begin
      Line := Text;
      Text := '';
    end;
    Add2(Line, Style);
  until Length(Text) = 0;
end;

function TTextDocument.GetLineLength(Style: Integer): Integer;
begin
  Result := LineChars;
  if (Style = STYLE_DWIDTH) or (Style = STYLE_DWIDTH_HEIGHT) then
    Result := LineChars div 2;
end;

procedure TTextDocument.Add2(const ALine: WideString; Style: Integer);
var
  Text: WideString;
  Line: WideString;
  LineLength: Integer;
begin
  LineLength := GetLineLength(Style);
  if LineLength = 0 then
  begin
    AddItem(ALine, Style);
    Exit;
  end;

  Text := ALine;
  repeat
    if (Length(Text) <= LineLength)or(Pos(CRLF, Text) = (LineLength + 1)) then
    begin
      Line := Copy(Text, 1, LineLength + 2);
      Text := Copy(Text, LineLength + 3, Length(Text));
    end else
    begin
      Line := Copy(Text, 1, LineLength) + CRLF;
      Text := Copy(Text, LineLength + 1, Length(Text));
    end;
    AddItem(Line, Style);
  until Length(Text) = 0;
end;

function TTextDocument.AddItem(const Line: WideString; Style: Integer): TDocItem;
var
  Item: TDocItem;
begin
  Item := TDocItem.Create(Items);
  Item.FText := Line;
  Item.FStyle := Style;
  Item.FLineChars := LineChars;
  Item.FLineHeight := LineHeight;
  Item.FLineSpacing := LineSpacing;
  Result := Item;
end;

procedure TTextDocument.Add(Index: Integer; const Line: WideString);
var
  Item: TDocItem;
begin
  Item := FItems.Insert(Index) as TDocItem;
  Item.FText := Line;
  Item.FStyle := STYLE_NORMAL;
end;

function TTextDocument.ConcatLines(const Line1, Line2: WideString; LineChars: Integer): WideString;
begin
  Result := Line1 + StringOfChar(' ', LineChars-Length(Line1)-Length(Line2)) + Line2;
end;

procedure TTextDocument.AddLines(const Line1, Line2: WideString; Style: Integer);
var
  Text: WideString;
begin
  Text := ConcatLines(Line1, Line2, LineChars) + CRLF;
  Add(Text, Style);
end;

procedure TTextDocument.AddLines(const Line1, Line2: WideString);
begin
  AddLines(Line1, Line2, STYLE_NORMAL);
end;

procedure TTextDocument.AddText(const Text: WideString);
var
  i: Integer;
  Lines: TTntStrings;
begin
  Lines := TTntStringList.Create;
  try
    Lines.Text := Text;
    for i := 0 to Lines.Count-1 do
    begin
      AddLine(Lines[i]);
    end;
  finally
    Lines.Free;
  end;
end;

procedure TTextDocument.AddText(Index: Integer; const Text: WideString);
var
  i: Integer;
  Lines: TTntStrings;
begin
  Lines := TTntStringList.Create;
  try
    Lines.Text := Text;
    for i := 0 to Lines.Count-1 do
    begin
      Add(Index + i, Lines[i]);
    end;
  finally
    Lines.Free;
  end;
end;

procedure TTextDocument.Clear;
begin
  FItems.Clear;
end;

procedure TTextDocument.Save;
begin
  { !!! }
end;

procedure TTextDocument.AddSeparator;
begin
  AddLine(StringOfChar('-', LineChars));
end;

function TTextDocument.AlignCenter(const Line: WideString): WideString;
begin
  Result := AlignCenter2(Line, LineChars);
end;

procedure TTextDocument.Assign(Source: TTextDocument);
begin
  FItems.Assign(Source.Items);
  FLineChars := Source.LineChars;
end;

procedure TTextDocument.AddBarcode(const Barcode: string);
var
  Item: TDocItem;
begin
  Item := TDocItem.Create(Items);
  Item.FStyle := STYLE_BARCODE;
  Item.FText := Barcode;
end;

{ TDocItems }

function TDocItems.GetItem(Index: Integer): TDocItem;
begin
  Result := inherited Items[Index] as TDocItem;
end;

{ TDocItem }

procedure TDocItem.Assign(Source: TPersistent);
var
  Src: TDocItem;
begin
  if Source is TDocItem then
  begin
    Src := Source as TDocItem;
    FStyle := Src.Style;
    FText := Src.Text;
  end else
    inherited Assign(Source);
end;

end.

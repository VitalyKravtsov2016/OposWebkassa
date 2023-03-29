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
    FPrintHeader: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Save;
    procedure Clear;
    procedure AddSeparator;
    procedure AddText(const Text: string); overload;
    procedure AddText(Index: Integer; const Text: string); overload;
    procedure Add(const Line: string); overload;
    procedure Add(Index: Integer; const Line: string); overload;
    procedure AddLines(const Line1, Line2: string); overload;
    procedure AddLines(const Line1, Line2: string; Style: Integer); overload;
    procedure Add(const Line: string; Style: Integer); overload;
    function AlignCenter(const Line: WideString): WideString;
    function ConcatLines(const Line1, Line2: string; LineChars: Integer): WideString;

    procedure Assign(Source: TTextDocument);

    property Items: TTextItems read FItems;
    property LineChars: Integer read FLineChars write FLineChars;
    property PrintHeader: Boolean read FPrintHeader write FPrintHeader;
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
    procedure Assign(Source: TPersistent); override;
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
  Item.FText := Line;
  Item.FStyle := Style;
end;

procedure TTextDocument.Add(Index: Integer; const Line: string);
var
  Item: TTextItem;
begin
  Item := FItems.Insert(Index) as TTextItem;
  Item.FText := Line;
  Item.FStyle := STYLE_NORMAL;
end;

function TTextDocument.ConcatLines(const Line1, Line2: string; LineChars: Integer): WideString;
begin
  Result := Line1 + StringOfChar(' ', LineChars-Length(Line1)-Length(Line2)) + Line2;
end;

procedure TTextDocument.AddLines(const Line1, Line2: string; Style: Integer);
var
  Text: string;
begin
  Text := ConcatLines(Line1, Line2, LineChars);
  Add(Text, Style);
end;

procedure TTextDocument.AddLines(const Line1, Line2: string);
begin
  AddLines(Line1, Line2, STYLE_NORMAL);
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
      Add(Lines[i] + CRLF);
    end;
  finally
    Lines.Free;
  end;
end;

procedure TTextDocument.AddText(Index: Integer; const Text: string);
var
  i: Integer;
  Lines: TStrings;
begin
  Lines := TStringList.Create;
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
  FPrintHeader := False;
end;

procedure TTextDocument.Save;
begin
  { !!! }
end;

procedure TTextDocument.AddSeparator;
begin
  Add(StringOfChar('-', LineChars));
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

{ TTextItems }

function TTextItems.Add: TTextItem;
begin
  Result := TTextItem.Create(Self);
end;

function TTextItems.GetItem(Index: Integer): TTextItem;
begin
  Result := inherited Items[Index] as TTextItem;
end;

{ TTextItem }

procedure TTextItem.Assign(Source: TPersistent);
var
  Src: TTextItem;
begin
  if Source is TTextItem then
  begin
    Src := Source as TTextItem;
    FStyle := Src.Style;
    FText := Src.Text;
  end else
    inherited Assign(Source);
end;

end.

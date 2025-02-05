unit CharCode;

interface

uses
  // VCL
  Classes;
  
type
  { TCharCode }

  TCharCode = class(TCollectionItem)
  private
    FCode: Byte;
    FFont: Byte;
    FChar: WideChar;
  public
    property Code: Byte read FCode;
    property Font: Byte read FFont;
    property Char: WideChar read FChar;
  end;

  { TCharCodes }

  TCharCodes = class(TCollection)
  private
    function GetItem(Index: Integer): TCharCode;
    procedure Remove(Char: WideChar);
  public
    function ItemByChar(Char: WideChar): TCharCode;
    function Add(Code: Byte; Char: WideChar; Font: Byte): TCharCode;
    property Items[Index: Integer]: TCharCode read GetItem; default;
  end;

implementation

{ TUserChars }

procedure TCharCodes.Remove(Char: WideChar);
var
  i: Integer;
  Item: TCharCode;
begin
  for i := Count-1 downto 0 do
  begin
    Item := Items[i];
    if Item.Char = Char then
    begin
      Item.Free;
    end;
  end;
end;

function TCharCodes.ItemByChar(Char: WideChar): TCharCode;
var
  i: Integer;
begin
  for i := 0 to Count-1 do
  begin
    Result := Items[i];
    if Result.Char = Char then Exit;
  end;
  Result := nil;
end;

function TCharCodes.Add(Code: Byte; Char: WideChar; Font: Byte): TCharCode;
begin
  Remove(Char);
  Result := TCharCode.Create(Self);
  Result.FCode := Code;
  Result.FChar := Char;
  Result.FFont := Font;
end;

function TCharCodes.GetItem(Index: Integer): TCharCode;
begin
  Result := inherited Items[Index] as TCharCode;
end;

end.

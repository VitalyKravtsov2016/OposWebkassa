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
  public
    function ItemByChar(Char: WideChar; Font: Integer): TCharCode;
    function Add(Code: Byte; Char: WideChar; Font: Byte): TCharCode;
    property Items[Index: Integer]: TCharCode read GetItem; default;
  end;

implementation

{ TUserChars }

function TCharCodes.ItemByChar(Char: WideChar; Font: Integer): TCharCode;
var
  i: Integer;
begin
  for i := 0 to Count-1 do
  begin
    Result := Items[i];
    if (Result.Char = Char)and(Result.Font = Font) then Exit;
  end;
  Result := nil;
end;

function TCharCodes.Add(Code: Byte; Char: WideChar; Font: Byte): TCharCode;
begin
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

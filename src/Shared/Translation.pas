unit Translation;

interface

uses
  // VCL
  Classes, SysUtils,
  // Tnt
  TntClasses;

type
  { TTranslation }

  TTranslation = class(TCollectionItem)
  private
    FName: WideString;
    FItems: TTntStringList;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;

    property Name: WideString read FName;
    property Items: TTntStringList read FItems;
  end;

  { TTranslations }

  TTranslations = class(TCollection)
  private
    function GetItem(Index: Integer): TTranslation;
  public
    constructor Create;
    function Find(const Name: WideString): TTranslation;
    property Items[Index: Integer]: TTranslation read GetItem; default;
  end;

implementation

{ TTranslation }

constructor TTranslation.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FItems := TTntStringList.Create;
end;

destructor TTranslation.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

{ TTranslations }

constructor TTranslations.Create;
begin
  inherited Create(TTranslation);
end;

function TTranslations.Find(const Name: WideString): TTranslation;
var
  i: Integer;
begin
  for i := 0 to Count-1 do
  begin
    Result := Items[i];
    if CompareText(Result.Name, Name) = 0 then Exit;
  end;
  Result := nil;
end;

function TTranslations.GetItem(Index: Integer): TTranslation;
begin
  Result := inherited Items[Index] as TTranslation;
end;

end.

unit VatCode;

interface

Uses
  // VCL
  Classes, SysUtils, WException, gnugettext, Math;

type
  TVatCode = class;

  { TVatCodes }

  TVatCodes = class
  private
    FList: TList;
    function GetCount: Integer;
    function GetItem(Index: Integer): TVatCode;
    procedure InsertItem(AItem: TVatCode);
    procedure RemoveItem(AItem: TVatCode);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function Add(ACode: Integer; ARate: Double; const AName: string): TVatCode;
    function ItemByCode(Code: Integer): TVatCode;

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TVatCode read GetItem; default;
  end;

  { TVatCode }

  TVatCode = class
  private
    FOwner: TVatCodes;
    FCode: Integer;
    FRate: Double;
    FName: WideString;
    procedure SetOwner(AOwner: TVatCodes);
  public
    constructor Create(AOwner: TVatCodes; ACode: Integer; ARate: Double;
      const AName: string);
    destructor Destroy; override;

    function GetTax(Amount: Currency): Currency;

    property Rate: Double read FRate write FRate;
    property Code: Integer read FCode write FCode;
    property Name: WideString read FName write FName;
  end;

implementation

{ TVatCodes }

constructor TVatCodes.Create;
begin
  inherited Create;
  FList := TList.Create;
end;

destructor TVatCodes.Destroy;
begin
  Clear;
  FList.Free;
  inherited Destroy;
end;

procedure TVatCodes.Clear;
begin
  while Count > 0 do Items[0].Free;
end;

function TVatCodes.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TVatCodes.GetItem(Index: Integer): TVatCode;
begin
  Result := FList[Index];
end;

procedure TVatCodes.InsertItem(AItem: TVatCode);
begin
  FList.Add(AItem);
  AItem.FOwner := Self;
end;

procedure TVatCodes.RemoveItem(AItem: TVatCode);
begin
  AItem.FOwner := nil;
  FList.Remove(AItem);
end;

function TVatCodes.Add(ACode: Integer; ARate: Double; const AName: string): TVatCode;
begin
  Result := TVatCode.Create(Self, ACode, ARate, AName);
end;

function TVatCodes.ItemByCode(Code: Integer): TVatCode;
var
  i: Integer;
begin
  for i := 0 to Count-1 do
  begin
    Result := Items[i];
    if Result.Code = Code then Exit;
  end;
  Result := nil;
end;

{ TVatCode }

constructor TVatCode.Create(AOwner: TVatCodes; ACode: Integer; ARate: Double;
  const AName: string);
begin
  inherited Create;
  SetOwner(AOwner);
  FCode := ACode;
  FRate := ARate;
  FName := AName;
end;

destructor TVatCode.Destroy;
begin
  SetOwner(nil);
  inherited Destroy;
end;

procedure TVatCode.SetOwner(AOwner: TVatCodes);
begin
  if AOwner <> FOwner then
  begin
    if FOwner <> nil then FOwner.RemoveItem(Self);
    if AOwner <> nil then AOwner.InsertItem(Self);
  end;
end;

function TVatCode.GetTax(Amount: Currency): Currency;
begin
  Result := Amount * (Rate/100) / (1 + Rate/100);
  Result := Round(Result * 100) / 100;
end;


end.

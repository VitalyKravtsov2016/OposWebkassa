unit VatRate;

interface

Uses
  // VCL
  Classes, SysUtils, WException, gnugettext, Math;

type
  TVatRate = class;

  { TVatRates }

  TVatRates = class
  private
    FList: TList;
    function GetCount: Integer;
    function GetItem(Index: Integer): TVatRate;
    procedure InsertItem(AItem: TVatRate);
    procedure RemoveItem(AItem: TVatRate);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    function Add(ACode: Integer; ARate: Double; const AName: string): TVatRate;
    function ItemByCode(Code: Integer): TVatRate;

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TVatRate read GetItem; default;
  end;

  { TVatRate }

  TVatRate = class
  private
    FOwner: TVatRates;
    FCode: Integer;
    FRate: Double;
    FName: WideString;
    procedure SetOwner(AOwner: TVatRates);
  public
    constructor Create(AOwner: TVatRates; ACode: Integer; ARate: Double;
      const AName: string);
    destructor Destroy; override;

    function GetTax(Amount: Currency): Currency;

    property Rate: Double read FRate write FRate;
    property Code: Integer read FCode write FCode;
    property Name: WideString read FName write FName;
  end;

implementation

{ TVatRates }

constructor TVatRates.Create;
begin
  inherited Create;
  FList := TList.Create;
end;

destructor TVatRates.Destroy;
begin
  Clear;
  FList.Free;
  inherited Destroy;
end;

procedure TVatRates.Clear;
begin
  while Count > 0 do Items[0].Free;
end;

function TVatRates.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TVatRates.GetItem(Index: Integer): TVatRate;
begin
  Result := FList[Index];
end;

procedure TVatRates.InsertItem(AItem: TVatRate);
begin
  FList.Add(AItem);
  AItem.FOwner := Self;
end;

procedure TVatRates.RemoveItem(AItem: TVatRate);
begin
  AItem.FOwner := nil;
  FList.Remove(AItem);
end;

function TVatRates.Add(ACode: Integer; ARate: Double; const AName: string): TVatRate;
begin
  Result := TVatRate.Create(Self, ACode, ARate, AName);
end;

function TVatRates.ItemByCode(Code: Integer): TVatRate;
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

{ TVatRate }

constructor TVatRate.Create(AOwner: TVatRates; ACode: Integer; ARate: Double;
  const AName: string);
begin
  inherited Create;
  SetOwner(AOwner);
  FCode := ACode;
  FRate := ARate;
  FName := AName;
end;

destructor TVatRate.Destroy;
begin
  SetOwner(nil);
  inherited Destroy;
end;

procedure TVatRate.SetOwner(AOwner: TVatRates);
begin
  if AOwner <> FOwner then
  begin
    if FOwner <> nil then FOwner.RemoveItem(Self);
    if AOwner <> nil then AOwner.InsertItem(Self);
  end;
end;

function TVatRate.GetTax(Amount: Currency): Currency;
begin
  Result := Amount * (Rate/100) / (1 + Rate/100);
  Result := Round(Result * 100) / 100;
end;


end.

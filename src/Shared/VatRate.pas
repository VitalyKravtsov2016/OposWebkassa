unit VatRate;

interface

Uses
  // VCL
  Classes, SysUtils, WException, gnugettext, Math;

type
  TVatRate = class;

  { TVatRates }

  TVatRates = class(TCollection)
  private
    function GetItem(Index: Integer): TVatRate;
  public
    constructor Create;

    function ItemByID(ID: Integer): TVatRate;
    function Add(AID: Integer; ARate: Double; const AName: string): TVatRate;
    property Items[Index: Integer]: TVatRate read GetItem; default;
  end;

  { TVatRate }

  TVatRate = class(TCollectionItem)
  private
    FID: Integer;
    FRate: Double;
    FTotal: Currency;
    FName: WideString;
  public
    constructor Create2(AOwner: TVatRates; AID: Integer; ARate: Double;
      const AName: string);

    function GetTax(Amount: Currency): Currency;
    procedure Assign(Source: TPersistent); override;

    property ID: Integer read FID;
    property Rate: Double read FRate;
    property Name: WideString read FName;
    property Total: Currency read FTotal;
  end;

implementation

{ TVatRates }

constructor TVatRates.Create;
begin
  inherited Create(TVatRate);
end;

function TVatRates.Add(AID: Integer; ARate: Double; const AName: string): TVatRate;
begin
  Result := TVatRate.Create2(Self, AID, ARate, AName);
end;

function TVatRates.ItemByID(ID: Integer): TVatRate;
var
  i: Integer;
begin
  for i := 0 to Count-1 do
  begin
    Result := Items[i];
    if Result.ID = ID then Exit;
  end;
  Result := nil;
end;

function TVatRates.GetItem(Index: Integer): TVatRate;
begin
  Result := inherited Items[Index] as TVatRate;
end;

{ TVatRate }

constructor TVatRate.Create2(AOwner: TVatRates; AID: Integer; ARate: Double;
  const AName: string);
begin
  inherited Create(AOwner);
  FID := AID;
  FRate := ARate;
  FName := AName;
end;

function TVatRate.GetTax(Amount: Currency): Currency;
begin
  Result := Amount * (Rate/100) / (1 + Rate/100);
  Result := Round(Result * 100) / 100;
end;

procedure TVatRate.Assign(Source: TPersistent);
var
  Src: TVatRate;
begin
  if Source is TVatRate then
  begin
    Src := Source as TVatRate;
    FID := Src.ID;
    FRate := Src.Rate;
    FName := Src.Name;
    FTotal := Src.Total;
  end else
    inherited Assign(Source);
end;



end.

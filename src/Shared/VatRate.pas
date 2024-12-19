unit VatRate;

interface

Uses
  // VCL
  Classes, SysUtils, WException, gnugettext, Math;

const
  /////////////////////////////////////////////////////////////////////////////
  // VatType constants

  VAT_TYPE_NORMAL     = 0;
  VAT_TYPE_ZERO_TAX   = 1;
  VAT_TYPE_NO_TAX     = 2;

type

  TVatRate = class;

  { TVatRateRec }

  TVatRateRec = record
    ID: Integer;
    Rate: Double;       // in percents
    Name: WideString;
    VatType: Integer;
  end;

  { TVatRates }

  TVatRates = class(TCollection)
  private
    function GetItem(Index: Integer): TVatRate;
  public
    constructor Create;

    function ItemByID(ID: Integer): TVatRate;
    function Add(const AData: TVatRateRec): TVatRate;
    property Items[Index: Integer]: TVatRate read GetItem; default;
  end;

  { TVatRate }

  TVatRate = class(TCollectionItem)
  private
    FData: TVatRateRec;
    FTotal: Currency;
    function GetVatTypeText: string;
  public
    constructor Create2(AOwner: TVatRates; const AData: TVatRateRec);

    function GetTax(Amount: Currency): Currency;
    procedure Assign(Source: TPersistent); override;

    property ID: Integer read FData.ID;
    property Rate: Double read FData.Rate;
    property Name: WideString read FData.Name;
    property Total: Currency read FTotal;
    property VatType: Integer read FData.VatType;
    property VatTypeText: string read GetVatTypeText;
  end;

implementation

{ TVatRates }

constructor TVatRates.Create;
begin
  inherited Create(TVatRate);
end;

function TVatRates.Add(const AData: TVatRateRec): TVatRate;
begin
  if ItemById(AData.ID) <> nil then
    raise Exception.CreateFmt('Налоговая ставка с кодом %d уже существует', [AData.ID]);

  Result := TVatRate.Create2(Self, AData);
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

constructor TVatRate.Create2(AOwner: TVatRates; const AData: TVatRateRec);
begin
  inherited Create(AOwner);

  if (AData.Rate < 0)or(AData.Rate > 100) then
    raise Exception.CreateFmt('Invalid VAT rate value, %.2f', [AData.Rate]);

  if not(AData.VatType in [VAT_TYPE_NORMAL, VAT_TYPE_ZERO_TAX, VAT_TYPE_NO_TAX]) then
    raise Exception.CreateFmt('Invalid VAT type value, %d', [AData.VatType]);

  FData := AData;
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
    FData := Src.FData;
  end else
    inherited Assign(Source);
end;

function TVatRate.GetVatTypeText: string;
begin
  case VatType of
    VAT_TYPE_NORMAL: Result := 'НДС';
    VAT_TYPE_ZERO_TAX: Result := 'НДС 0%';
    VAT_TYPE_NO_TAX: Result := 'БЕЗ НДС';
  else
    Result := '';
  end;
end;

end.

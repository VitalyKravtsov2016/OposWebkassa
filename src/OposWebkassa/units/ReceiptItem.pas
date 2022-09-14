unit ReceiptItem;

interface

Uses
  // VCL
  Classes,
  // This
  MathUtils;

type
  TAdjustment = class;
  TAdjustments = class;
  TReceiptItem = class;

  { TReceiptItems }

  TReceiptItems = class
  private
    FList: TList;
    function GetCount: Integer;
    function GetItem(Index: Integer): TReceiptItem;
  public
    constructor Create;
    destructor Destroy; override;

    function Add: TReceiptItem;
    function GetTotal: Currency;
    procedure Clear;
    procedure InsertItem(AItem: TReceiptItem);
    procedure RemoveItem(AItem: TReceiptItem);
    procedure Insert(Index: Integer; AItem: TReceiptItem);

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TReceiptItem read GetItem; default;
  end;

  { TReceiptItem }

  TReceiptItem = class
  private
    FOwner: TReceiptItems;
    procedure SetOwner(AOwner: TReceiptItems);
  public
    constructor Create(AOwner: TReceiptItems); virtual;
    destructor Destroy; override;
    function GetTotal: Currency; virtual;
  end;

  { TSalesReceiptItem }

  TSalesReceiptItem = class(TReceiptItem)
  private
    FPrice: Currency;
    FVatInfo: Integer;
    FQuantity: Double;
    FUnitPrice: Currency;
    FUnitName: WideString;
    FDescription: WideString;
    FMarkCode: string;
    FAdjustments: TAdjustments;
    FNumber: Integer;
  public
    constructor Create(AOwner: TReceiptItems); override;
    destructor Destroy; override;
    function GetTotal: Currency; override;
    function GetDiscount: Currency;
    function GetCharge: Currency;
    procedure Assign(Item: TSalesReceiptItem);
    function AddAdjustment: TAdjustment;

    property Total: Currency read GetTotal;
    property Price: Currency read FPrice write FPrice;
    property Number: Integer read FNumber write FNumber;
    property VatInfo: Integer read FVatInfo write FVatInfo;
    property Quantity: Double read FQuantity write FQuantity;
    property UnitPrice: Currency read FUnitPrice write FUnitPrice;
    property UnitName: WideString read FUnitName write FUnitName;
    property Description: WideString read FDescription write FDescription;
    property MarkCode: string read FMarkCode write FMarkCode;
    property Adjustments: TAdjustments read FAdjustments;
  end;

  { TAdjustments }

  TAdjustments = class
  private
    FList: TList;
    function GetCount: Integer;
    function GetItem(Index: Integer): TAdjustment;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear;
    function GetTotal: Currency;
    function GetCharge: Currency;
    function GetDiscount: Currency;
    procedure Add(Item: TAdjustment);

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TAdjustment read GetItem; default;
  end;

  { TAdjustment }

  TAdjustment = class(TReceiptItem)
  private
    FTotal: Currency;
    FAmount: Currency;
    FVatInfo: Integer;
    FAdjustmentType: Integer;
    FDescription: WideString;
  public
    procedure Assign(Item: TAdjustment);
    function IsDiscount: Boolean;
    function GetTotal: Currency; override;

    property Total: Currency read FTotal write FTotal;
    property Amount: Currency read FAmount write FAmount;
    property VatInfo: Integer read FVatInfo write FVatInfo;
    property Description: WideString read FDescription write FDescription;
    property AdjustmentType: Integer read FAdjustmentType write FAdjustmentType;
  end;

  { TTotalAdjustment }

  TTotalAdjustment = class(TAdjustment);

  { TItemAdjustment }

  TItemAdjustment = class(TAdjustment);

  { TRecTexItem }

  TRecTexItem = class(TReceiptItem)
  private
    FStyle: Integer;
    FText: WideString;
  public
    property Style: Integer read FStyle;
    property Text: WideString read FText;
  end;

implementation

{ TReceiptItems }

constructor TReceiptItems.Create;
begin
  inherited Create;
  FList := TList.Create;
end;

destructor TReceiptItems.Destroy;
begin
  Clear;
  FList.Free;
  inherited Destroy;
end;

procedure TReceiptItems.Clear;
begin
  while Count > 0 do Items[0].Free;
end;

function TReceiptItems.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TReceiptItems.GetItem(Index: Integer): TReceiptItem;
begin
  Result := FList[Index];
end;

procedure TReceiptItems.Insert(Index: Integer; AItem: TReceiptItem);
begin
  FList.Insert(Index, AItem);
  AItem.FOwner := Self;
end;

procedure TReceiptItems.InsertItem(AItem: TReceiptItem);
begin
  FList.Add(AItem);
  AItem.FOwner := Self;
end;

procedure TReceiptItems.RemoveItem(AItem: TReceiptItem);
begin
  AItem.FOwner := nil;
  FList.Remove(AItem);
end;

function TReceiptItems.GetTotal: Currency;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Count-1 do
    Result := Result + Items[i].GetTotal;
end;

function TReceiptItems.Add: TReceiptItem;
begin
  Result := TReceiptItem.Create(Self);
end;

{ TReceiptItem }

constructor TReceiptItem.Create(AOwner: TReceiptItems);
begin
  inherited Create;
  SetOwner(AOwner);
end;

destructor TReceiptItem.Destroy;
begin
  SetOwner(nil);
  inherited Destroy;
end;

procedure TReceiptItem.SetOwner(AOwner: TReceiptItems);
begin
  if AOwner <> FOwner then
  begin
    if FOwner <> nil then FOwner.RemoveItem(Self);
    if AOwner <> nil then AOwner.InsertItem(Self);
  end;
end;

function TReceiptItem.GetTotal: Currency;
begin
  Result := 0;
end;

{ TSalesReceiptItem }

constructor TSalesReceiptItem.Create(AOwner: TReceiptItems);
begin
  inherited Create(AOwner);
  FAdjustments := TAdjustments.Create;
end;

destructor TSalesReceiptItem.Destroy;
begin
  FAdjustments.Free;
  inherited Destroy;
end;

function TSalesReceiptItem.GetTotal: Currency;
begin
  Result := FPrice;
end;

procedure TSalesReceiptItem.Assign(Item: TSalesReceiptItem);
var
  Src: TSalesReceiptItem;
begin
  if Item is TSalesReceiptItem then
  begin
    Src := Item as TSalesReceiptItem;

    FPrice := Src.Price;
    FVatInfo := Src.VatInfo;
    FQuantity := Src.Quantity;
    FUnitPrice := Src.UnitPrice;
    FUnitName := Src.UnitName;
    FDescription := Src.Description;
  end;
end;

function TSalesReceiptItem.AddAdjustment: TAdjustment;
begin
  Result := TItemAdjustment.Create(FOwner);
  FAdjustments.Add(Result);
end;

function TSalesReceiptItem.GetCharge: Currency;
begin
  Result := FAdjustments.GetCharge;
end;

function TSalesReceiptItem.GetDiscount: Currency;
begin
  Result := FAdjustments.GetDiscount;
end;

{ TAdjustment }

procedure TAdjustment.Assign(Item: TAdjustment);
var
  Src: TAdjustment;
begin
  if Item is TAdjustment then
  begin
    Src := Item as TAdjustment;

    FAmount := Src.Amount;
    FVatInfo := Src.VatInfo;
    FDescription := Src.Description;
    FAdjustmentType := Src.AdjustmentType;
  end;
end;

function TAdjustment.IsDiscount: Boolean;
begin
  Result := GetTotal < 0;
end;

function TAdjustment.GetTotal: Currency;
begin
  Result := FTotal;
end;

{ TAdjustments }

constructor TAdjustments.Create;
begin
  inherited Create;
  FList := TList.Create;
end;

destructor TAdjustments.Destroy;
begin
  FList.Free;
  inherited Destroy;
end;

procedure TAdjustments.Add(Item: TAdjustment);
begin
  FList.Add(Item);
end;

procedure TAdjustments.Clear;
begin
  FList.Clear;
end;

function TAdjustments.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TAdjustments.GetItem(Index: Integer): TAdjustment;
begin
  Result := FList[Index];
end;

function TAdjustments.GetCharge: Currency;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Count-1 do
  begin
    if not Items[i].IsDiscount then
    Result := Result + Items[i].GetTotal;
  end;
  Result := Abs(Result);
end;

function TAdjustments.GetDiscount: Currency;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Count-1 do
  begin
    if Items[i].IsDiscount then
    Result := Result + Items[i].GetTotal;
  end;
  Result := Abs(Result);
end;

function TAdjustments.GetTotal: Currency;
begin
  Result := GetCharge - GetDiscount;
end;

end.

unit ReceiptItem;

interface

Uses
  // VCL
  Classes,
  // This
  MathUtils;

type
  TDiscount = class;
  TDiscounts = class;
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
    procedure Assign(Items: TReceiptItems);
    procedure Insert(Index: Integer; AItem: TReceiptItem);

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TReceiptItem read GetItem; default;
  end;

  { TReceiptItem }

  TReceiptItem = class
  private
    FPrice: Currency;
    FVatInfo: Integer;
    FQuantity: Double;
    FUnitPrice: Currency;
    FUnitName: WideString;
    FDescription: WideString;
    FDiscounts: TDiscounts;
    FMarkCode: string;
    FOwner: TReceiptItems;

    procedure SetOwner(AOwner: TReceiptItems);
  public
    constructor Create(AOwner: TReceiptItems);
    destructor Destroy; override;

    function GetTotal: Currency;
    procedure Assign(Item: TReceiptItem);

    property Total: Currency read GetTotal;
    property MarkCode: string read FMarkCode;
    property Discounts: TDiscounts read FDiscounts;
    property Price: Currency read FPrice write FPrice;
    property VatInfo: Integer read FVatInfo write FVatInfo;
    property Quantity: Double read FQuantity write FQuantity;
    property UnitPrice: Currency read FUnitPrice write FUnitPrice;
    property UnitName: WideString read FUnitName write FUnitName;
    property Description: WideString read FDescription write FDescription;
  end;

  { TDiscounts }

  TDiscounts = class
  private
    FList: TList;
    function GetCount: Integer;
    function GetItem(Index: Integer): TDiscount;
  public
    constructor Create;
    destructor Destroy; override;

    function Add: TDiscount;
    function GetTotal: Currency;
    procedure Clear;
    procedure InsertItem(AItem: TDiscount);
    procedure RemoveItem(AItem: TDiscount);
    procedure Assign(Items: TDiscounts);
    procedure Insert(Index: Integer; AItem: TDiscount);

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TDiscount read GetItem; default;
  end;

  { TDiscount }

  TDiscount = class
  private
    FOwner: TDiscounts;
    FTotal: Currency;
    FAmount: Currency;
    FVatInfo: Integer;
    FAdjustmentType: Integer;
    FDescription: WideString;
    procedure SetOwner(AOwner: TDiscounts);
  public
    constructor Create(AOwner: TDiscounts);
    destructor Destroy; override;
    procedure Assign(Item: TDiscount);

    property Total: Currency read FTotal write FTotal;
    property Amount: Currency read FAmount write FAmount;
    property VatInfo: Integer read FVatInfo write FVatInfo;
    property Description: WideString read FDescription write FDescription;
    property AdjustmentType: Integer read FAdjustmentType write FAdjustmentType;
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

procedure TReceiptItems.Assign(Items: TReceiptItems);
var
  i: Integer;
  Item: TReceiptItem;
begin
  Clear;
  for i := 0 to Items.Count-1 do
  begin
    Item := Items[i].ClassType.Create as TReceiptItem;
    InsertItem(Item);
    Item.Assign(Items[i]);
  end;
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
  FDiscounts := TDiscounts.Create;
end;

destructor TReceiptItem.Destroy;
begin
  FDiscounts.Free;
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
  Result := FPrice - FDiscounts.GetTotal;
end;

procedure TReceiptItem.Assign(Item: TReceiptItem);
var
  Src: TReceiptItem;
begin
  if Item is TReceiptItem then
  begin
    Src := Item as TReceiptItem;

    FPrice := Src.Price;
    FVatInfo := Src.VatInfo;
    FQuantity := Src.Quantity;
    FUnitPrice := Src.UnitPrice;
    FUnitName := Src.UnitName;
    FDescription := Src.Description;
    FDiscounts.Assign(Src.Discounts);
  end;
end;

{ TDiscounts }

constructor TDiscounts.Create;
begin
  inherited Create;
  FList := TList.Create;
end;

destructor TDiscounts.Destroy;
begin
  Clear;
  FList.Free;
  inherited Destroy;
end;

procedure TDiscounts.Clear;
begin
  while Count > 0 do Items[0].Free;
end;

function TDiscounts.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TDiscounts.GetItem(Index: Integer): TDiscount;
begin
  Result := FList[Index];
end;

procedure TDiscounts.Insert(Index: Integer; AItem: TDiscount);
begin
  FList.Insert(Index, AItem);
  AItem.FOwner := Self;
end;

procedure TDiscounts.InsertItem(AItem: TDiscount);
begin
  FList.Add(AItem);
  AItem.FOwner := Self;
end;

procedure TDiscounts.RemoveItem(AItem: TDiscount);
begin
  AItem.FOwner := nil;
  FList.Remove(AItem);
end;

function TDiscounts.GetTotal: Currency;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Count-1 do
    Result := Result + Items[i].Total;
end;

procedure TDiscounts.Assign(Items: TDiscounts);
var
  i: Integer;
  Item: TDiscount;
begin
  Clear;
  for i := 0 to Items.Count-1 do
  begin
    Item := Items[i].ClassType.Create as TDiscount;
    InsertItem(Item);
    Item.Assign(Items[i]);
  end;
end;

function TDiscounts.Add: TDiscount;
begin
  Result := TDiscount.Create(Self);
end;

{ TDiscount }

constructor TDiscount.Create(AOwner: TDiscounts);
begin
  inherited Create;
  SetOwner(AOwner);
end;

destructor TDiscount.Destroy;
begin
  SetOwner(nil);
  inherited Destroy;
end;

procedure TDiscount.SetOwner(AOwner: TDiscounts);
begin
  if AOwner <> FOwner then
  begin
    if FOwner <> nil then FOwner.RemoveItem(Self);
    if AOwner <> nil then AOwner.InsertItem(Self);
  end;
end;

procedure TDiscount.Assign(Item: TDiscount);
var
  Src: TDiscount;
begin
  if Item is TDiscount then
  begin
    Src := Item as TDiscount;

    FAmount := Src.Amount;
    FVatInfo := Src.VatInfo;
    FDescription := Src.Description;
    FAdjustmentType := Src.AdjustmentType;
  end;
end;

end.

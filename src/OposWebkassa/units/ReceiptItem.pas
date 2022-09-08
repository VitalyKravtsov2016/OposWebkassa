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
    FAdjustments: TAdjustments;
    FMarkCode: string;
    FOwner: TReceiptItems;

    procedure SetOwner(AOwner: TReceiptItems);
  public
    constructor Create(AOwner: TReceiptItems);
    destructor Destroy; override;

    function GetTotal: Currency;
    procedure Assign(Item: TReceiptItem);

    property Total: Currency read GetTotal;
    property Adjustments: TAdjustments read FAdjustments;
    property Price: Currency read FPrice write FPrice;
    property VatInfo: Integer read FVatInfo write FVatInfo;
    property Quantity: Double read FQuantity write FQuantity;
    property UnitPrice: Currency read FUnitPrice write FUnitPrice;
    property UnitName: WideString read FUnitName write FUnitName;
    property Description: WideString read FDescription write FDescription;
    property MarkCode: string read FMarkCode write FMarkCode;
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

    function Add: TAdjustment;
    function GetTotal: Currency;
    function GetCharges: Currency;
    function GetDiscounts: Currency;
    procedure Clear;
    procedure InsertItem(AItem: TAdjustment);
    procedure RemoveItem(AItem: TAdjustment);
    procedure Assign(Items: TAdjustments);
    procedure Insert(Index: Integer; AItem: TAdjustment);

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TAdjustment read GetItem; default;
  end;

  { TAdjustment }

  TAdjustment = class
  private
    FOwner: TAdjustments;
    FTotal: Currency;
    FAmount: Currency;
    FVatInfo: Integer;
    FAdjustmentType: Integer;
    FDescription: WideString;
    procedure SetOwner(AOwner: TAdjustments);
  public
    constructor Create(AOwner: TAdjustments);
    destructor Destroy; override;
    procedure Assign(Item: TAdjustment);

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
  FAdjustments := TAdjustments.Create;
end;

destructor TReceiptItem.Destroy;
begin
  FAdjustments.Free;
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
  Result := FPrice - FAdjustments.GetTotal;
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
    FAdjustments.Assign(Src.Adjustments);
  end;
end;

{ TAdjustments }

constructor TAdjustments.Create;
begin
  inherited Create;
  FList := TList.Create;
end;

destructor TAdjustments.Destroy;
begin
  Clear;
  FList.Free;
  inherited Destroy;
end;

procedure TAdjustments.Clear;
begin
  while Count > 0 do Items[0].Free;
end;

function TAdjustments.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TAdjustments.GetItem(Index: Integer): TAdjustment;
begin
  Result := FList[Index];
end;

procedure TAdjustments.Insert(Index: Integer; AItem: TAdjustment);
begin
  FList.Insert(Index, AItem);
  AItem.FOwner := Self;
end;

procedure TAdjustments.InsertItem(AItem: TAdjustment);
begin
  FList.Add(AItem);
  AItem.FOwner := Self;
end;

procedure TAdjustments.RemoveItem(AItem: TAdjustment);
begin
  AItem.FOwner := nil;
  FList.Remove(AItem);
end;

function TAdjustments.GetTotal: Currency;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Count-1 do
    Result := Result + Items[i].Total;
end;

function TAdjustments.GetCharges: Currency;
var
  i: Integer;
  Amount: Currency;
begin
  Result := 0;
  for i := 0 to Count-1 do
  begin
    Amount := Items[i].Total;
    if Amount < 0 then
      Result := Result + Amount;
  end;
  Result := Abs(Result);
end;

function TAdjustments.GetDiscounts: Currency;
var
  i: Integer;
  Amount: Currency;
begin
  Result := 0;
  for i := 0 to Count-1 do
  begin
    Amount := Items[i].Total;
    if Amount > 0 then
      Result := Result + Amount;
  end;
end;

procedure TAdjustments.Assign(Items: TAdjustments);
var
  i: Integer;
  Item: TAdjustment;
begin
  Clear;
  for i := 0 to Items.Count-1 do
  begin
    Item := Items[i].ClassType.Create as TAdjustment;
    InsertItem(Item);
    Item.Assign(Items[i]);
  end;
end;

function TAdjustments.Add: TAdjustment;
begin
  Result := TAdjustment.Create(Self);
end;

{ TAdjustment }

constructor TAdjustment.Create(AOwner: TAdjustments);
begin
  inherited Create;
  SetOwner(AOwner);
end;

destructor TAdjustment.Destroy;
begin
  SetOwner(nil);
  inherited Destroy;
end;

procedure TAdjustment.SetOwner(AOwner: TAdjustments);
begin
  if AOwner <> FOwner then
  begin
    if FOwner <> nil then FOwner.RemoveItem(Self);
    if AOwner <> nil then AOwner.InsertItem(Self);
  end;
end;

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

end.

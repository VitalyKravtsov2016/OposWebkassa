unit SalesReceipt;

interface

uses
  // VCL
  Windows, SysUtils, Forms, Controls, Classes, Messages, Math,
  // Opos
  Opos, OposFptrUtils, OposException, OposFptr, OposUtils,
  // Tnt
  TntClasses,
  // This
  CustomReceipt, ReceiptItem, gnugettext, UserError, MathUtils,
  TextDocument, PrinterTypes, VatRate;

const
  MaxPayments = 4;

type
  { TReceiptPayment }

  TReceiptPayment = class(TCollectionItem)
  private
    FAmount: Currency;
    FPayType: Integer;
  public
    property Amount: Currency read FAmount;
    property PayType: Integer read FPayType;
  end;

  { TReceiptPayments }

  TReceiptPayments = class(TCollection)
  published
    function GetItem(Index: Integer): TReceiptPayment;
  public
    function Add(PayType: Integer; Amount: Currency): TReceiptPayment;
    property Items[Index: Integer]: TReceiptPayment read GetItem; default;
  end;


  TRecType = (rtBuy, rtRetBuy, rtSell, rtRetSell);

  { TSalesReceipt }

  TSalesReceipt = class(TCustomReceipt)
  private
    FRecItems: TList;
    FChange: Currency;
    FRecType: TRecType;
    FRoundType: Integer;
    FItems: TReceiptItems;
    FCharges: TAdjustments;
    FDiscounts: TAdjustments;
    FPayments: TReceiptPayments;
    FAmountDecimalPlaces: Integer;

    function AddItem: TSalesReceiptItem;
    procedure SubtotalCharge(Amount: Currency;
      const Description: WideString);
  protected
    procedure SetRefundReceipt;
    procedure CheckPrice(Value: Currency);
    procedure CheckPercents(Value: Currency);
    procedure CheckQuantity(Quantity: Double);
    procedure CheckAmount(Amount: Currency);
    function GetLastItem: TSalesReceiptItem;
    procedure RecSubtotalAdjustment(const Description: WideString;
      AdjustmentType: Integer; Amount: Currency);
    procedure SubtotalDiscount(Amount: Currency;
      const Description: WideString);
  public
    ReguestJson: WideString;
    AnswerJson: WideString;

    constructor CreateReceipt(ARecType: TRecType;
      AAmountDecimalPlaces: Integer; ARoundType: Integer);
    destructor Destroy; override;

    function GetCharge: Currency;
    function GetDiscount: Currency;
    function GetTotal: Currency; override;
    function GetPayment: Currency; override;
    function RoundAmount(Amount: Currency): Currency;
    function GetTotalByVAT(VatInfo: Integer): Currency;

    procedure PrintRecVoid(const Description: WideString); override;

    procedure PrintRecItem(const Description: WideString; Price: Currency;
      Quantity: Double; VatInfo: Integer; UnitPrice: Currency;
      const UnitName: WideString); override;

    procedure PrintRecItemAdjustment(AdjustmentType: Integer;
      const Description: WideString; Amount: Currency;
      VatInfo: Integer); override;

    procedure PrintRecItemAdjustmentVoid(AdjustmentType: Integer;
      const Description: WideString; Amount: Currency; VatInfo: Integer); override;

    procedure PrintRecPackageAdjustment(AdjustmentType: Integer;
      const Description, VatAdjustment: WideString); override;

    procedure PrintRecPackageAdjustVoid(AdjustmentType: Integer;
      const VatAdjustment: WideString); override;

    procedure PrintRecRefund(const Description: WideString; Amount: Currency;
      VatInfo: Integer); override;

    procedure PrintRecRefundVoid(const Description: WideString;
      Amount: Currency; VatInfo: Integer); override;

    procedure PrintRecSubtotal(Amount: Currency); override;

    procedure PrintRecSubtotalAdjustment(AdjustmentType: Integer;
      const Description: WideString; Amount: Currency); override;

    procedure PrintRecTotal(Total, Payment: Currency;
      const Description: WideString); override;

    procedure PrintRecVoidItem(const Description: WideString; Amount: Currency;
      Quantity: Double; AdjustmentType: Integer; Adjustment: Currency;
      VatInfo: Integer);  override;

    procedure PrintRecItemVoid(const Description: WideString;
      Price: Currency; Quantity: Double; VatInfo: Integer; UnitPrice: Currency;
      const UnitName: WideString); override;

    procedure BeginFiscalReceipt(PrintHeader: Boolean); override;

    procedure EndFiscalReceipt(APrintHeader: Boolean); override;

    procedure PrintRecSubtotalAdjustVoid(AdjustmentType: Integer;
      Amount: Currency); override;

    procedure PrintRecItemRefund(
      const ADescription: WideString;
      Amount: Currency; Quantity: Double;
      VatInfo: Integer; UnitAmount: Currency;
      const AUnitName: WideString); override;

    procedure PrintRecItemRefundVoid(
      const ADescription: WideString;
      Amount: Currency; Quantity: Double;
      VatInfo: Integer; UnitAmount: Currency;
      const AUnitName: WideString); override;

    procedure Print(AVisitor: TObject); override;

    procedure PrintRecMessage(const Message: WideString); override;
    procedure PrintBarcode(const Barcode: string); override;
    function GetVatAmount(const VatRate: TVatRate): Currency;
    function GetPaymentAmount(PayType: Integer): Currency;

    property Change: Currency read FChange;
    property Charge: Currency read GetCharge;
    property RecType: TRecType read FRecType;
    property Items: TReceiptItems read FItems;
    property RoundType: Integer read FRoundType;
    property Discount: Currency read GetDiscount;
    property Charges: TAdjustments read FCharges;
    property Discounts: TAdjustments read FDiscounts;
    property Payments: TReceiptPayments read FPayments;
    property AmountDecimalPlaces: Integer read FAmountDecimalPlaces;
  end;

implementation

uses
  WebkassaImpl;

procedure CheckPercents(Amount: Currency);
begin
  if not((Amount >= 0)and(Amount <= 100)) then
    raiseExtendedError(OPOS_EFPTR_BAD_ITEM_AMOUNT, _('Invalid percentage'));
end;

function GetVoidAdjustmentType(AdjustmentType: Integer): Integer;
begin
  Result := AdjustmentType;
  case AdjustmentType of
    FPTR_AT_AMOUNT_DISCOUNT: Result := FPTR_AT_AMOUNT_SURCHARGE;
    FPTR_AT_AMOUNT_SURCHARGE: Result := FPTR_AT_AMOUNT_DISCOUNT;
    FPTR_AT_PERCENTAGE_DISCOUNT: Result := FPTR_AT_PERCENTAGE_SURCHARGE;
    FPTR_AT_PERCENTAGE_SURCHARGE: Result := FPTR_AT_PERCENTAGE_DISCOUNT;
  else
    InvalidParameterValue('AdjustmentType', IntToStr(AdjustmentType));
  end;
end;

{ TReceiptPayments }

function TReceiptPayments.Add(PayType: Integer;
  Amount: Currency): TReceiptPayment;
begin
  Result := TReceiptPayment.Create(Self);
  Result.FPayType := PayType;
  Result.FAmount := Amount;
end;

function TReceiptPayments.GetItem(Index: Integer): TReceiptPayment;
begin
  Result := inherited Items[Index] as TReceiptPayment;
end;

{ TSalesReceipt }

constructor TSalesReceipt.CreateReceipt(ARecType: TRecType;
  AAmountDecimalPlaces: Integer; ARoundType: Integer);
begin
  inherited Create;
  FRecType := ARecType;
  FRoundType := ARoundType;

  if not(AAmountDecimalPlaces in [0..4]) then
    raise UserException.Create('Invalid AmountDecimalPlaces');

  FAmountDecimalPlaces := AAmountDecimalPlaces;

  FRecItems := TList.Create;
  FItems := TReceiptItems.Create;
  FCharges := TAdjustments.Create;
  FDiscounts := TAdjustments.Create;
  FPayments := TReceiptPayments.Create(TReceiptPayment);
end;

destructor TSalesReceipt.Destroy;
begin
  FItems.Free;
  FCharges.Free;
  FRecItems.Free;
  FDiscounts.Free;
  FPayments.Free;
  inherited Destroy;
end;

function TSalesReceipt.GetPaymentAmount(PayType: Integer): Currency;
var
  i: integer;
begin
  Result := 0;
  for i := 0 to Payments.Count-1 do
  begin
    if Payments[i].PayType = PayType then
      Result := Result + Payments[i].Amount;
  end;
end;

function TSalesReceipt.GetCharge: Currency;
begin
  Result := Abs(Charges.GetTotal);
end;

function TSalesReceipt.GetDiscount: Currency;
begin
  Result := Abs(Discounts.GetTotal);
end;

procedure TSalesReceipt.Print(AVisitor: TObject);
begin
  if FIsVoided then Exit;
  TWebkassaImpl(AVisitor).Print(Self);
end;

procedure TSalesReceipt.CheckAmount(Amount: Currency);
begin
  if Amount < 0 then
    raiseExtendedError(OPOS_EFPTR_BAD_ITEM_AMOUNT, _('Negative amount'));
end;

procedure TSalesReceipt.SetRefundReceipt;
begin
  if FItems.Count = 0 then
  begin
    case RecType of
      rtBuy: FRecType := rtRetBuy;
      rtSell: FRecType := rtRetSell;
    end;
  end;
end;

function TSalesReceipt.GetLastItem: TSalesReceiptItem;
begin
  if FRecItems.Count = 0 then
    raiseException(_('�� ����� ��������� ������� ����'));
  Result := TSalesReceiptItem(FRecItems[FRecItems.Count-1]);
end;

procedure TSalesReceipt.CheckPrice(Value: Currency);
begin
  if Value < 0 then
    raiseExtendedError(OPOS_EFPTR_BAD_PRICE, _('Negative price'));
end;

procedure TSalesReceipt.CheckPercents(Value: Currency);
begin
  if (Value < 0)or(Value > 9999) then
    raiseExtendedError(OPOS_EFPTR_BAD_ITEM_AMOUNT, _('Invalid percents value'));
end;

procedure TSalesReceipt.CheckQuantity(Quantity: Double);
begin
  if Quantity < 0 then
    raiseExtendedError(OPOS_EFPTR_BAD_ITEM_QUANTITY, _('Negative quantity'));
end;

procedure TSalesReceipt.PrintRecVoid(const Description: WideString);
begin
  FIsVoided := True;
end;

procedure TSalesReceipt.BeginFiscalReceipt(PrintHeader: Boolean);
begin
  FIsOpened := True;
end;

procedure TSalesReceipt.EndFiscalReceipt(APrintHeader: Boolean);
begin
  FIsOpened := False;
end;

function TSalesReceipt.AddItem: TSalesReceiptItem;
begin
  Result := TSalesReceiptItem.Create(FItems);
  FRecItems.Add(Result);
  Result.Number := FRecItems.Count;
end;

procedure TSalesReceipt.PrintRecItem(const Description: WideString;
  Price: Currency; Quantity: Double; VatInfo: Integer;
  UnitPrice: Currency; const UnitName: WideString);
var
  Item: TSalesReceiptItem;
begin
  CheckNotVoided;
  CheckPrice(Price);
  CheckPrice(UnitPrice);
  CheckQuantity(Quantity);

  Item := AddItem;
  Item.Quantity := Quantity;
  Item.Price := Price;
  Item.UnitPrice := UnitPrice;
  Item.VatInfo := VatInfo;
  Item.Description := Description;
  Item.UnitName := UnitName;
  Item.MarkCode := FBarcode;
  FBarcode := '';
end;

procedure TSalesReceipt.PrintRecItemVoid(const Description: WideString;
  Price: Currency; Quantity: Double; VatInfo: Integer; UnitPrice: Currency;
  const UnitName: WideString);
var
  Item: TSalesReceiptItem;
begin
  CheckNotVoided;
  CheckPrice(Price);
  CheckPrice(UnitPrice);
  CheckQuantity(Quantity);

  Item := AddItem;
  Item.Quantity := -Quantity;
  Item.Price := Price;
  Item.UnitPrice := UnitPrice;
  Item.VatInfo := VatInfo;
  Item.Description := Description;
  Item.UnitName := UnitName;
  Item.MarkCode := FBarcode;
  FBarcode := '';
end;

procedure TSalesReceipt.PrintRecItemRefund(const ADescription: WideString;
  Amount: Currency; Quantity: Double; VatInfo: Integer;
  UnitAmount: Currency; const AUnitName: WideString);
var
  Item: TSalesReceiptItem;
begin
  CheckNotVoided;
  SetRefundReceipt;

  CheckPrice(Amount);
  CheckPrice(UnitAmount);
  CheckQuantity(Quantity);

  Item := AddItem;
  Item.Quantity := Quantity;
  Item.Price := Amount;
  Item.UnitPrice := UnitAmount;
  Item.VatInfo := VatInfo;
  Item.Description := ADescription;
  Item.UnitName := AUnitName;
  Item.MarkCode := FBarcode;
  FBarcode := '';
end;

procedure TSalesReceipt.PrintRecItemRefundVoid(
  const ADescription: WideString; Amount: Currency; Quantity: Double;
  VatInfo: Integer; UnitAmount: Currency; const AUnitName: WideString);
begin
  CheckNotVoided;
  PrintRecItemRefund(ADescription, Amount, Quantity, VatInfo, UnitAmount,
    AUnitName);
end;

procedure TSalesReceipt.PrintRecVoidItem(const Description: WideString;
  Amount: Currency; Quantity: Double; AdjustmentType: Integer;
  Adjustment: Currency; VatInfo: Integer);
var
  Item: TSalesReceiptItem;
begin
  CheckNotVoided;
  CheckPrice(Amount);
  CheckQuantity(Quantity);

  Item := AddItem;
  Item.Price := Amount;
  Item.Quantity := -Quantity;
  Item.VatInfo := VatInfo;
  Item.Description := Description;
  Item.UnitName := '';
  Item.UnitPrice := 0;
  Item.MarkCode := FBarcode;
  FBarcode := '';
end;

procedure TSalesReceipt.PrintRecItemAdjustment(
  AdjustmentType: Integer;
  const Description: WideString;
  Amount: Currency;
  VatInfo: Integer);
var
  Adjustment: TAdjustment;
begin
  CheckNotVoided;
  case AdjustmentType of
    FPTR_AT_AMOUNT_DISCOUNT:
    begin
      Adjustment := GetLastItem.AddDiscount;
      Adjustment.Amount := RoundAmount(Amount);
      Adjustment.Total := -RoundAmount(Amount);
      Adjustment.VatInfo := VatInfo;
      Adjustment.Description := Description;
      Adjustment.AdjustmentType := AdjustmentType;
    end;

    FPTR_AT_AMOUNT_SURCHARGE:
    begin
      Adjustment := GetLastItem.AddCharge;
      Adjustment.Amount := RoundAmount(Amount);
      Adjustment.Total := RoundAmount(Amount);
      Adjustment.VatInfo := VatInfo;
      Adjustment.Description := Description;
      Adjustment.AdjustmentType := AdjustmentType;
    end;
    FPTR_AT_PERCENTAGE_DISCOUNT:
    begin
      CheckPercents(Amount);
      Adjustment := GetLastItem.AddDiscount;
      Adjustment.Amount := Amount;
      Adjustment.Total := -RoundAmount(GetLastItem.Price * Amount/100);
      Adjustment.VatInfo := VatInfo;
      Adjustment.Description := Description;
      Adjustment.AdjustmentType := AdjustmentType;
    end;

    FPTR_AT_PERCENTAGE_SURCHARGE:
    begin
      CheckPercents(Amount);
      Adjustment := GetLastItem.AddCharge;
      Adjustment.Amount := Amount;
      Adjustment.Total := RoundAmount(GetLastItem.Price * Amount/100);
      Adjustment.VatInfo := VatInfo;
      Adjustment.Description := Description;
      Adjustment.AdjustmentType := AdjustmentType;
    end;
  else
    InvalidParameterValue('AdjustmentType', IntToStr(AdjustmentType));
  end;
end;

procedure TSalesReceipt.PrintRecItemAdjustmentVoid(AdjustmentType: Integer;
  const Description: WideString; Amount: Currency;
  VatInfo: Integer);
begin
  AdjustmentType := GetVoidAdjustmentType(AdjustmentType);
  PrintRecItemAdjustment(AdjustmentType, Description, Amount, VatInfo);
end;


procedure TSalesReceipt.PrintRecPackageAdjustment(
  AdjustmentType: Integer;
  const Description, VatAdjustment: WideString);
begin
  CheckNotVoided;
end;

procedure TSalesReceipt.PrintRecPackageAdjustVoid(AdjustmentType: Integer;
  const VatAdjustment: WideString);
begin
  CheckNotVoided;
end;

procedure TSalesReceipt.PrintRecRefund(const Description: WideString;
  Amount: Currency; VatInfo: Integer);
var
  Item: TSalesReceiptItem;
begin
  CheckNotVoided;
  SetRefundReceipt;
  CheckAmount(Amount);

  Item := AddItem;
  Item.Quantity := 1;
  Item.Price := Amount;
  Item.UnitPrice := Amount;
  Item.VatInfo := VatInfo;
  Item.Description := Description;
  Item.UnitName := '';
  Item.MarkCode := FBarcode;
  FBarcode := '';
end;

procedure TSalesReceipt.PrintRecRefundVoid(
  const Description: WideString;
  Amount: Currency; VatInfo: Integer);
var
  Item: TSalesReceiptItem;
begin
  CheckNotVoided;
  SetRefundReceipt;
  CheckAmount(Amount);

  Item := AddItem;
  Item.Quantity := -1;
  Item.Price := Amount;
  Item.UnitPrice := Amount;
  Item.VatInfo := VatInfo;
  Item.Description := Description;
  Item.UnitName := '';
  Item.MarkCode := FBarcode;
  FBarcode := '';
end;

procedure TSalesReceipt.PrintRecSubtotal(Amount: Currency);
begin
  CheckNotVoided;
end;

procedure TSalesReceipt.PrintRecSubtotalAdjustment(AdjustmentType: Integer;
  const Description: WideString; Amount: Currency);
begin
  CheckNotVoided;
  RecSubtotalAdjustment(Description, AdjustmentType, Amount);
end;

procedure TSalesReceipt.RecSubtotalAdjustment(const Description: WideString;
  AdjustmentType: Integer; Amount: Currency);
begin
  CheckNotVoided;
  case AdjustmentType of
    FPTR_AT_AMOUNT_DISCOUNT:
    begin
      SubtotalDiscount(-Amount, Description);
    end;

    FPTR_AT_AMOUNT_SURCHARGE:
    begin
      SubtotalCharge(Amount, Description);
    end;

    FPTR_AT_PERCENTAGE_DISCOUNT:
    begin
      CheckPercents(Amount);
      Amount := GetTotal * Amount/100;
      SubtotalDiscount(-Amount, Description);
    end;

    FPTR_AT_PERCENTAGE_SURCHARGE:
    begin
      CheckPercents(Amount);
      Amount := GetTotal * Amount/100;
      SubtotalCharge(Amount, Description);
    end;
  else
    InvalidParameterValue('AdjustmentType', IntToStr(AdjustmentType));
  end;
end;

function TSalesReceipt.RoundAmount(Amount: Currency): Currency;
var
  K: Integer;
begin
  K := Round(Power(10, AmountDecimalPlaces));
  Result := Round2(Amount * K) / K;
end;

procedure TSalesReceipt.SubtotalDiscount(Amount: Currency; const Description: WideString);
var
  Adjustment: TAdjustment;
begin
  Adjustment := TTotalAdjustment.Create(FItems);
  FDiscounts.Add(Adjustment);

  Adjustment.Total := RoundAmount(Amount);
  Adjustment.Amount := Adjustment.Total;
  Adjustment.VatInfo := 0;
  Adjustment.AdjustmentType := 0;
  Adjustment.Description := Description;
end;

procedure TSalesReceipt.SubtotalCharge(Amount: Currency; const Description: WideString);
var
  Adjustment: TAdjustment;
begin
  Adjustment := TTotalAdjustment.Create(FItems);
  FCharges.Add(Adjustment);

  Adjustment.Total := RoundAmount(Amount);
  Adjustment.Amount := Adjustment.Total;
  Adjustment.VatInfo := 0;
  Adjustment.AdjustmentType := 0;
  Adjustment.Description := Description;
end;

function TSalesReceipt.GetTotal: Currency;
var
  i: Integer;
  Item: TSalesReceiptItem;
begin
  Result := 0;
  for i := 0 to FRecItems.Count-1 do
  begin
    Item := TSalesReceiptItem(FRecItems[i]);
    Result := Result + Item.GetTotalAmount(RoundType);
  end;
  Result := Result - Abs(FDiscounts.GetTotal) + Abs(FCharges.GetTotal);
  if (RoundType = RoundTypeTotal)or(RoundType = RoundTypeItems) then
    Result := Ceil(Result);
end;

function TSalesReceipt.GetPayment: Currency;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Payments.Count-1 do
  begin
    Result := Result + Payments[i].Amount;
  end;
end;

procedure TSalesReceipt.PrintRecSubtotalAdjustVoid(
  AdjustmentType: Integer; Amount: Currency);
begin
  CheckNotVoided;
  AdjustmentType := GetVoidAdjustmentType(AdjustmentType);
  RecSubtotalAdjustment('', AdjustmentType, Amount);
end;

procedure TSalesReceipt.PrintRecTotal(Total: Currency; Payment: Currency;
  const Description: WideString);
var
  PayType: Integer;
begin
  CheckNotVoided;
  CheckAmount(Total);
  CheckAmount(Payment);

  FAfterTotal := True;
  PayType := StrToIntDef(Description, 0);
  Payments.Add(PayType, Payment);
  if GetPayment >= GetTotal then
  begin
    FChange := GetPayment - GetTotal;
  end;
end;

procedure TSalesReceipt.PrintRecMessage(const Message: WideString);
var
  Item: TRecTexItem;
begin
  if FAfterTotal then
  begin
    FTrailer.Add(Message);
  end else
  begin
    Item := TRecTexItem.Create(FItems);
    Item.Text := Message;
    Item.Style := STYLE_NORMAL;
  end;
end;

procedure TSalesReceipt.PrintBarcode(const Barcode: string);
var
  Item: TBarcodeItem;
begin
  Item := TBarcodeItem.Create(Items);
  Item.Barcode := Barcode;
end;

function TSalesReceipt.GetTotalByVAT(VatInfo: Integer): Currency;
begin
  Result := Items.GetTotalByVAT(VatInfo) + Charges.GetTotalByVAT(VatInfo)
    - Discounts.GetTotalByVAT(VatInfo)
end;

function TSalesReceipt.GetVatAmount(const VatRate: TVatRate): Currency;
var
  Amount: Currency;
begin
  Result := 0;
  if VatRate = nil then Exit;

  Amount := GetTotalByVAT(VatRate.ID);
  Result := RoundAmount(Amount * VATRate.Rate / (100 + VATRate.Rate));
end;

end.

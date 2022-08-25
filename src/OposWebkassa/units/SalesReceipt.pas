unit SalesReceipt;

interface

uses
  // VCL
  Windows, SysUtils, Forms, Controls, Classes, Messages,
  // Opos
  OposFptrUtils, OposException, OposFptr,
  // Tnt
  TntClasses,
  // This
  CustomReceipt, ReceiptItem, gnugettext, WException;

type
  TPayments = array [0..4] of Currency;

  { TSalesReceipt }

  TSalesReceipt = class(TCustomReceipt)
  private
    FChange: Currency;
    FFooter: TTntStrings;
    FIsRefund: Boolean;
    FPayments: TPayments;
    FItems: TReceiptItems;
    FAdjustments: TAdjustments;
  protected
    procedure SetRefundReceipt;
    procedure CheckPrice(Value: Currency);
    procedure CheckPercents(Value: Currency);
    procedure CheckQuantity(Quantity: Double);
    procedure CheckAmount(Amount: Currency);
    function GetLastItem: TReceiptItem;
    procedure RecSubtotalAdjustment(const Description: WideString;
      AdjustmentType: Integer; Amount: Currency);
    procedure SubtotalDiscount(Amount: Currency;
      const Description: WideString);
  public
    constructor Create(AIsRefund: Boolean);
    destructor Destroy; override;

    function GetTotal: Currency; override;
    function GetPayment: Currency; override;

    procedure PrintRecVoid(const Description: WideString); override;

    procedure PrintRecItem(const Description: WideString; Price: Currency;
      Quantity: Double; VatInfo: Integer; UnitPrice: Currency;
      const UnitName: WideString); override;

    procedure PrintRecItemAdjustment(AdjustmentType: Integer;
      const Description: WideString; Amount: Currency;
      VatInfo: Integer); override;

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

    procedure EndFiscalReceipt;  override;

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

    procedure PrintRecMessage(const Message: WideString); override;

    procedure Print(AVisitor: TObject); override;

    property Change: Currency read FChange;
    property Items: TReceiptItems read FItems;
    property IsRefund: Boolean read FIsRefund;
    property Footer: TTntStrings read FFooter;
    property Payments: TPayments read FPayments;
    property Adjustments: TAdjustments read FAdjustments;
  end;

implementation

uses
  WebkassaImpl;

{ TSalesReceipt }

constructor TSalesReceipt.Create(AIsRefund: Boolean);
begin
  inherited Create;
  FIsRefund := AIsRefund;
  FItems := TReceiptItems.Create;
  FAdjustments := TAdjustments.Create;
  FFooter := TTntStringLIst.Create;
end;

destructor TSalesReceipt.Destroy;
begin
  FItems.Free;
  FFooter.Free;
  FAdjustments.Free;
  inherited Destroy;
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
    FIsRefund := True;
end;

function TSalesReceipt.GetLastItem: TReceiptItem;
begin
  if FItems.Count = 0 then
    raiseException(_('Не задан последний элемент чека'));
  Result := FItems[FItems.Count-1];
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
end;


procedure TSalesReceipt.EndFiscalReceipt;
begin
end;

procedure TSalesReceipt.PrintRecItem(const Description: WideString;
  Price: Currency; Quantity: Double; VatInfo: Integer;
  UnitPrice: Currency; const UnitName: WideString);
var
  Item: TReceiptItem;
begin
  CheckNotVoided;
  CheckPrice(Price);
  CheckPrice(UnitPrice);
  CheckQuantity(Quantity);

  Item := FItems.Add;
  Item.Quantity := Quantity;
  if UnitPrice = 0 then
  begin
    if Price <> 0 then Item.Quantity := 1;
    Item.Price := Price;
  end else
  begin
    Item.Price := UnitPrice;
  end;
  Item.VatInfo := VatInfo;
  Item.Description := Description;
  Item.UnitName := UnitName;
end;

procedure TSalesReceipt.PrintRecItemVoid(const Description: WideString;
  Price: Currency; Quantity: Double; VatInfo: Integer; UnitPrice: Currency;
  const UnitName: WideString);
var
  Item: TReceiptItem;
begin
  CheckNotVoided;
  CheckPrice(Price);
  CheckPrice(UnitPrice);
  CheckQuantity(Quantity);

  Item := FItems.Add;
  Item.Quantity := -Quantity;
  if UnitPrice = 0 then
  begin
    if Price <> 0 then Item.Quantity := -1;
    Item.Price := Price;
  end else
  begin
    Item.Price := UnitPrice;
  end;
  Item.VatInfo := VatInfo;
  Item.Description := Description;
  Item.UnitName := UnitName;
end;

procedure TSalesReceipt.PrintRecItemRefund(const ADescription: WideString;
  Amount: Currency; Quantity: Double; VatInfo: Integer;
  UnitAmount: Currency; const AUnitName: WideString);
var
  Item: TReceiptItem;
begin
  CheckNotVoided;
  SetRefundReceipt;

  CheckPrice(Amount);
  CheckPrice(UnitAmount);
  CheckQuantity(Quantity);

  Item := FItems.Add;
  Item.Quantity := Quantity;
  if UnitAmount = 0 then
  begin
    if Amount <> 0 then Item.Quantity := 1;
    Item.Price := Amount;
  end else
  begin
    Item.Price := UnitAmount;
  end;
  Item.VatInfo := VatInfo;
  Item.Description := ADescription;
  Item.UnitName := AUnitName;
  Item.UnitPrice := UnitAmount;
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
  Item: TReceiptItem;
begin
  CheckNotVoided;
  CheckPrice(Amount);
  CheckQuantity(Quantity);

  Item := FItems.Add;
  Item.Price := Amount;
  Item.Quantity := -Quantity;
  Item.VatInfo := VatInfo;
  Item.Description := Description;
  Item.UnitName := '';
end;

procedure TSalesReceipt.PrintRecItemAdjustment(
  AdjustmentType: Integer;
  const Description: WideString;
  Amount: Currency;
  VatInfo: Integer);
var
  Discount: TAdjustment;
begin
  CheckNotVoided;
  case AdjustmentType of
    FPTR_AT_AMOUNT_DISCOUNT:
    begin
      Discount := GetLastItem.Adjustments.Add;
      Discount.Amount := Amount;
      Discount.Total := Amount;
      Discount.VatInfo := VatInfo;
      Discount.Description := Description;
      Discount.AdjustmentType := AdjustmentType;
    end;

    FPTR_AT_AMOUNT_SURCHARGE:
    begin
      Discount := GetLastItem.Adjustments.Add;
      Discount.Amount := Amount;
      Discount.Total := -Amount;
      Discount.VatInfo := VatInfo;
      Discount.Description := Description;
      Discount.AdjustmentType := AdjustmentType;
    end;
    FPTR_AT_PERCENTAGE_DISCOUNT:
    begin
      Discount := GetLastItem.Adjustments.Add;
      Discount.Amount := Amount;
      Discount.Total := GetLastItem.GetTotal * Amount/100;
      Discount.VatInfo := VatInfo;
      Discount.Description := Description;
      Discount.AdjustmentType := AdjustmentType;
    end;

    FPTR_AT_PERCENTAGE_SURCHARGE:
    begin
      Discount := GetLastItem.Adjustments.Add;
      Discount.Amount := Amount;
      Discount.Total := -GetLastItem.GetTotal * Amount/100;
      Discount.VatInfo := VatInfo;
      Discount.Description := Description;
      Discount.AdjustmentType := AdjustmentType;
    end;
  else
    InvalidParameterValue('AdjustmentType', IntToStr(AdjustmentType));
  end;
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
  Item: TREceiptItem;
begin
  CheckNotVoided;
  SetRefundReceipt;
  CheckAmount(Amount);

  Item := FItems.Add;
  Item.Quantity := 1;
  Item.Price := Amount;
  Item.UnitPrice := Amount;
  Item.VatInfo := VatInfo;
  Item.Description := Description;
  Item.UnitName := '';
end;

procedure TSalesReceipt.PrintRecRefundVoid(
  const Description: WideString;
  Amount: Currency; VatInfo: Integer);
var
  Item: TREceiptItem;
begin
  CheckNotVoided;
  SetRefundReceipt;
  CheckAmount(Amount);

  Item := FItems.Add;
  Item.Quantity := -1;
  Item.Price := Amount;
  Item.UnitPrice := Amount;
  Item.VatInfo := VatInfo;
  Item.Description := Description;
  Item.UnitName := '';
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
      SubtotalDiscount(Amount, Description);
    end;

    FPTR_AT_AMOUNT_SURCHARGE:
    begin
      SubtotalDiscount(-Amount, Description);
    end;

    FPTR_AT_PERCENTAGE_DISCOUNT:
    begin
      Amount := GetTotal * Amount/100;
      SubtotalDiscount(Amount, Description);
    end;

    FPTR_AT_PERCENTAGE_SURCHARGE:
    begin
      Amount := GetTotal * Amount/100;
      SubtotalDiscount(-Amount, Description);
    end;
  else
    InvalidParameterValue('AdjustmentType', IntToStr(AdjustmentType));
  end;
end;

procedure TSalesReceipt.SubtotalDiscount(Amount: Currency; const Description: WideString);
var
  Discount: TAdjustment;
begin
  Discount := FAdjustments.Add;
  Discount.Total := Amount;
  Discount.Amount := Amount;
  Discount.VatInfo := 0;
  Discount.AdjustmentType := 0;
  Discount.Description := Description;
end;

function TSalesReceipt.GetTotal: Currency;
begin
  Result := FItems.GetTotal - FAdjustments.GetTotal;
end;

function TSalesReceipt.GetPayment: Currency;
begin
  Result := FPayments[0] + FPayments[1] + FPayments[2] + FPayments[3];
end;

procedure TSalesReceipt.PrintRecSubtotalAdjustVoid(
  AdjustmentType: Integer; Amount: Currency);
begin
  CheckNotVoided;
  RecSubtotalAdjustment('', AdjustmentType, Amount);
end;

procedure TSalesReceipt.PrintRecTotal(Total: Currency; Payment: Currency;
  const Description: WideString);
var
  Index: Integer;
begin
  CheckNotVoided;
  CheckAmount(Total);
  CheckAmount(Payment);

  Index := StrToIntDef(Description, 0);
  FPayments[Index] := FPayments[Index] + Payment;

  if GetPayment >= GetTotal then
  begin
    FChange := GetPayment - GetTotal;
  end;
end;

procedure TSalesReceipt.PrintRecMessage(const Message: WideString);
begin
  if GetPayment > GetTotal then
  begin
    FFooter.Add(Message);
  end;
end;

end.

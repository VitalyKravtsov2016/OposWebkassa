unit CustomReceipt;

interface

uses
  // Opos
  Opos, OposFptr, OposException,
  // This
  gnugettext;

type
  { TCustomReceipt }

  TCustomReceipt = class
  protected
    FIsVoided: Boolean;
  public
    procedure CheckNotVoided;
    function GetTotal: Currency; virtual;
    function GetPayment: Currency; virtual;
    property IsVoided: Boolean read FIsVoided;
  public
    procedure BeginFiscalReceipt(PrintHeader: Boolean); virtual;

    procedure EndFiscalReceipt; virtual;

    procedure PrintRecCash(Amount: Currency); virtual;

    procedure PrintRecItem(const Description: WideString; Price: Currency;
      Quantity: Double; VatInfo: Integer; UnitPrice: Currency;
      const UnitName: WideString); virtual;

    procedure PrintRecItemAdjustment(AdjustmentType: Integer;
      const Description: WideString; Amount: Currency;
      VatInfo: Integer); virtual;

    procedure PrintRecMessage(const Message: WideString); virtual;

    procedure PrintRecNotPaid(const Description: WideString;
      Amount: Currency); virtual;

    procedure PrintRecRefund(const Description: WideString; Amount: Currency;
      VatInfo: Integer); virtual;

    procedure PrintRecSubtotal(Amount: Currency); virtual;

    procedure PrintRecSubtotalAdjustment(AdjustmentType: Integer;
      const Description: WideString; Amount: Currency); virtual;

    procedure PrintRecTotal(Total: Currency; Payment: Currency;
      const Description: WideString); virtual;

    procedure PrintRecVoid(const Description: WideString); virtual;

    procedure PrintRecVoidItem(const Description: WideString; Amount: Currency;
      Quantity: Double; AdjustmentType: Integer; Adjustment: Currency;
      VatInfo: Integer); virtual;

    procedure PrintRecItemFuel(const Description: WideString; Price: Currency;
      Quantity: Double; VatInfo: Integer; UnitPrice: Currency; const UnitName: WideString;
      SpecialTax: Currency; const SpecialTaxName: WideString); virtual;

    procedure PrintRecItemFuelVoid(const Description: WideString;
      Price: Currency; VatInfo: Integer; SpecialTax: Currency); virtual;

    procedure PrintRecPackageAdjustment(AdjustmentType: Integer;
      const Description, VatAdjustment: WideString); virtual;

    procedure PrintRecPackageAdjustVoid(AdjustmentType: Integer;
      const VatAdjustment: WideString); virtual;

    procedure PrintRecRefundVoid(const Description: WideString;
      Amount: Currency; VatInfo: Integer); virtual;

    procedure PrintRecSubtotalAdjustVoid(AdjustmentType: Integer;
      Amount: Currency); virtual;

    procedure PrintRecTaxID(const TaxID: WideString); virtual;

    procedure PrintRecItemAdjustmentVoid(AdjustmentType: Integer;
      const Description: WideString; Amount: Currency;
      VatInfo: Integer); virtual;

    procedure PrintRecItemVoid(const Description: WideString;
      Price: Currency; Quantity: Double; VatInfo: Integer; UnitPrice: Currency;
      const UnitName: WideString); virtual;

    procedure PrintRecItemRefund(
      const ADescription: WideString;
      Amount: Currency; Quantity: Double;
      VatInfo: Integer; UnitAmount: Currency;
      const AUnitName: WideString); virtual;

    procedure PrintRecItemRefundVoid(
      const ADescription: WideString;
      Amount: Currency; Quantity: Double;
      VatInfo: Integer; UnitAmount: Currency;
      const AUnitName: WideString); virtual;

    procedure PrintNormal(const Text: WideString; Station: Integer); virtual;

    procedure Print(AVisitor: TObject); virtual;
  end;

function CurrencyToInt64(Value: Currency): Int64;

implementation

function CurrencyToInt64(Value: Currency): Int64;
begin
  Result := Trunc(Value * 100); // !!!
end;

procedure RaiseIllegalError;
begin
  RaiseOposException(OPOS_E_ILLEGAL, _('Receipt method is not supported'));
end;

{ TCustomReceipt }

procedure TCustomReceipt.BeginFiscalReceipt(PrintHeader: Boolean);
begin
end;

procedure TCustomReceipt.EndFiscalReceipt;
begin
  RaiseIllegalError;
end;

procedure TCustomReceipt.PrintRecItem(const Description: WideString;
  Price: Currency; Quantity: Double; VatInfo: Integer; UnitPrice: Currency;
  const UnitName: WideString);
begin
  RaiseIllegalError;
end;

procedure TCustomReceipt.PrintRecItemAdjustment(AdjustmentType: Integer;
  const Description: WideString; Amount: Currency; VatInfo: Integer);
begin
  RaiseIllegalError;
end;

procedure TCustomReceipt.PrintRecNotPaid(const Description: WideString;
  Amount: Currency);
begin
  RaiseIllegalError;
end;

procedure TCustomReceipt.PrintRecRefund(const Description: WideString;
  Amount: Currency; VatInfo: Integer);
begin
  RaiseIllegalError;
end;

procedure TCustomReceipt.PrintRecSubtotal(Amount: Currency);
begin
  RaiseIllegalError;
end;

procedure TCustomReceipt.PrintRecSubtotalAdjustment(
  AdjustmentType: Integer; const Description: WideString; Amount: Currency);
begin
  RaiseIllegalError;
end;

procedure TCustomReceipt.PrintRecTotal(Total, Payment: Currency;
  const Description: WideString);
begin
  RaiseIllegalError;
end;

procedure TCustomReceipt.PrintRecVoid(const Description: WideString);
begin
  RaiseIllegalError;
end;

procedure TCustomReceipt.PrintRecCash(Amount: Currency);
begin
  RaiseIllegalError;
end;

procedure TCustomReceipt.PrintRecItemFuel(const Description: WideString;
  Price: Currency; Quantity: Double; VatInfo: Integer; UnitPrice: Currency;
  const UnitName: WideString; SpecialTax: Currency;
  const SpecialTaxName: WideString);
begin
  RaiseIllegalError;
end;

procedure TCustomReceipt.PrintRecItemFuelVoid(const Description: WideString;
  Price: Currency; VatInfo: Integer; SpecialTax: Currency);
begin
  RaiseIllegalError;
end;

procedure TCustomReceipt.PrintRecPackageAdjustment(AdjustmentType: Integer;
  const Description, VatAdjustment: WideString);
begin
  RaiseIllegalError;
end;

procedure TCustomReceipt.PrintRecPackageAdjustVoid(AdjustmentType: Integer;
  const VatAdjustment: WideString);
begin
  RaiseIllegalError;
end;

procedure TCustomReceipt.PrintRecRefundVoid(const Description: WideString;
  Amount: Currency; VatInfo: Integer);
begin
  RaiseIllegalError;
end;

procedure TCustomReceipt.PrintRecSubtotalAdjustVoid(
  AdjustmentType: Integer; Amount: Currency);
begin
  RaiseIllegalError;
end;

procedure TCustomReceipt.PrintRecTaxID(const TaxID: WideString);
begin
  RaiseIllegalError;
end;

procedure TCustomReceipt.PrintRecItemAdjustmentVoid(
  AdjustmentType: Integer; const Description: WideString; Amount: Currency;
  VatInfo: Integer);
begin
  RaiseIllegalError;
end;

procedure TCustomReceipt.PrintRecVoidItem(
  const Description: WideString;
  Amount: Currency;
  Quantity: Double; AdjustmentType: Integer;
  Adjustment: Currency; VatInfo: Integer);
begin
  RaiseIllegalError;
end;

procedure TCustomReceipt.PrintRecItemVoid(
  const Description: WideString; Price: Currency; Quantity: Double;
  VatInfo: Integer; UnitPrice: Currency; const UnitName: WideString);
begin
  RaiseIllegalError;
end;

procedure TCustomReceipt.PrintRecItemRefund(const ADescription: WideString;
  Amount: Currency; Quantity: Double; VatInfo: Integer; UnitAmount: Currency;
  const AUnitName: WideString);
begin
  RaiseIllegalError;
end;

procedure TCustomReceipt.PrintRecItemRefundVoid(const ADescription: WideString;
  Amount: Currency; Quantity: Double; VatInfo: Integer; UnitAmount: Currency;
  const AUnitName: WideString);
begin
  RaiseIllegalError;
end;

procedure TCustomReceipt.PrintNormal(const Text: WideString; Station: Integer);
begin
  RaiseIllegalError;
end;

procedure TCustomReceipt.PrintRecMessage(const Message: WideString);
begin
  RaiseIllegalError;
end;

procedure TCustomReceipt.Print(AVisitor: TObject);
begin

end;

function TCustomReceipt.GetPayment: Currency;
begin
  Result := 0;
end;

function TCustomReceipt.GetTotal: Currency;
begin
  Result := 0;
end;

procedure TCustomReceipt.CheckNotVoided;
begin
  if FIsVoided then
    raiseExtendedError(OPOS_EFPTR_WRONG_STATE);
end;


end.

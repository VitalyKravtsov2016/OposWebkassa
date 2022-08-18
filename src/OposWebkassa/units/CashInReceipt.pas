unit CashInReceipt;

interface

uses
  // VCL
  SysUtils,
  // Opos
  Opos, OposException, OposFptr,
  // This
  CustomReceipt, gnugettext;

type
  { TCashInReceipt }

  TCashInReceipt = class(TCustomReceipt)
  private
    FTotal: Currency;
    FPayment: Currency;
    procedure CheckAmount(Amount: Currency);
  public
    function GetTotal: Currency; override;
    function GetPayment: Currency; override;
    procedure PrintRecCash(Amount: Currency); override;
    procedure PrintRecVoid(const Description: WideString); override;
    procedure EndFiscalReceipt; override;
    procedure PrintRecTotal(Total, Payment: Currency;
      const Description: WideString); override;

    procedure Print(AVisitor: TObject); override;
  end;

function CurrencyToInt64(Value: Currency): Int64;

implementation

uses
  WebkassaImpl;

function CurrencyToInt64(Value: Currency): Int64;
begin
  Result := Trunc(Value * 100); // !!!
end;

{ TCashInReceipt }

procedure TCashInReceipt.CheckAmount(Amount: Currency);
begin
  if Amount < 0 then
    raiseExtendedError(OPOS_EFPTR_BAD_ITEM_AMOUNT, _('Negative amount'));
end;

procedure TCashInReceipt.PrintRecCash(Amount: Currency);
begin
  CheckNotVoided;
  FTotal := FTotal + Amount;
end;

procedure TCashInReceipt.PrintRecVoid(const Description: WideString);
begin
  CheckNotVoided;
  FIsVoided := True;
end;

procedure TCashInReceipt.PrintRecTotal(Total: Currency; Payment: Currency;
  const Description: WideString);
begin
  CheckNotVoided;
  CheckAmount(Total);
  CheckAmount(Payment);
  FPayment := FPayment + Payment;
end;

procedure TCashInReceipt.EndFiscalReceipt;
begin

end;

procedure TCashInReceipt.Print(AVisitor: TObject);
begin
  if FIsVoided then Exit;
  TWebkassaImpl(AVisitor).Print(Self);
end;

function TCashInReceipt.GetPayment: Currency;
begin
  Result := FPayment;
end;

function TCashInReceipt.GetTotal: Currency;
begin
  Result := FTotal;
end;

end.

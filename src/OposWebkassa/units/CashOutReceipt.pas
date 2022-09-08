unit CashOutReceipt;

interface

uses
  // VCL
  SysUtils,
  // Opos
  Opos, OposException, OposFptr,
  // This
  CustomReceipt, WebkassaClient, gnugettext;

type
  { TCashOutReceipt }

  TCashOutReceipt = class(TCustomReceipt)
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

implementation

uses
  WebkassaImpl;

{ TCashOutReceipt }

procedure TCashOutReceipt.CheckAmount(Amount: Currency);
begin
  if Amount < 0 then
    raiseExtendedError(OPOS_EFPTR_BAD_ITEM_AMOUNT, _('Negative amount'));
end;

procedure TCashOutReceipt.PrintRecCash(Amount: Currency);
begin
  CheckNotVoided;
  FTotal := FTotal + Amount;
end;

procedure TCashOutReceipt.PrintRecVoid(const Description: WideString);
begin
  CheckNotVoided;
  FIsVoided := True;
end;

procedure TCashOutReceipt.PrintRecTotal(Total: Currency; Payment: Currency;
  const Description: WideString);
begin
  CheckNotVoided;
  CheckAmount(Total);
  CheckAmount(Payment);

  FAfterTotal := True;
  FPayment := FPayment + Payment;
end;

procedure TCashOutReceipt.EndFiscalReceipt;
begin

end;

procedure TCashOutReceipt.Print(AVisitor: TObject);
begin
  if FIsVoided then Exit;
  TWebkassaImpl(AVisitor).Print(Self);
end;

function TCashOutReceipt.GetPayment: Currency;
begin
  Result := FPayment;
end;

function TCashOutReceipt.GetTotal: Currency;
begin
  Result := FTotal;
end;

end.

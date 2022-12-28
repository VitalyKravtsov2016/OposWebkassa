unit fmuFptrPayType;

interface

uses
  // VCL
  StdCtrls, Controls, ComCtrls, Classes, SysUtils,
  // Tnt
  TntClasses, TntStdCtrls, TntRegistry,
  // This
  FiscalPrinterDevice, PrinterParameters, FptrTypes;

type
  { TfmFptrPayType }

  TfmFptrPayType = class(TFptrPage)
    cbPaymentType2: TComboBox;
    lblPaymentType2: TTntLabel;
    cbPaymentType3: TComboBox;
    lblPaymentType3: TTntLabel;
    cbPaymentType4: TComboBox;
    lblPaymentType4: TTntLabel;
    Label1: TLabel;
    procedure ModifiedClick(Sender: TObject);
  public
    procedure UpdatePage; override;
    procedure UpdateObject; override;
  end;

implementation

{$R *.DFM}

{ TfmFptrPayType }

procedure TfmFptrPayType.UpdatePage;
begin
  cbPaymentType2.ItemIndex := Parameters.PaymentType2;
  cbPaymentType3.ItemIndex := Parameters.PaymentType3;
  cbPaymentType4.ItemIndex := Parameters.PaymentType4;
end;

procedure TfmFptrPayType.UpdateObject;
begin
  Parameters.PaymentType2 := cbPaymentType2.ItemIndex;
  Parameters.PaymentType3 := cbPaymentType3.ItemIndex;
  Parameters.PaymentType4 := cbPaymentType4.ItemIndex;
end;

procedure TfmFptrPayType.ModifiedClick(Sender: TObject);
begin
  Modified;
end;

end.

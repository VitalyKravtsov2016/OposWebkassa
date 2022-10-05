unit fmuFptrMiscParams;

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

  TfmFptrMiscParams = class(TFptrPage)
    cbRoundType: TComboBox;
    lblRoundType: TTntLabel;
    edtVATSeries: TEdit;
    lblVATSeries: TTntLabel;
    edtVATNumber: TEdit;
    lblVATNumber: TTntLabel;
    cbAmountDecimalPlaces: TComboBox;
    lblAmountDecimalPlaces: TTntLabel;
  public
    procedure UpdatePage; override;
    procedure UpdateObject; override;
  end;

implementation

{$R *.DFM}

{ TfmFptrPayType }

procedure TfmFptrMiscParams.UpdatePage;
begin
  cbRoundType.ItemIndex := Parameters.RoundType;
  edtVATSeries.Text := Parameters.VATSeries;
  edtVATNumber.Text := Parameters.VATNumber;
  cbAmountDecimalPlaces.ItemIndex := cbAmountDecimalPlaces.Items.IndexOf(
    IntToStr(Parameters.AmountDecimalPlaces));
end;

procedure TfmFptrMiscParams.UpdateObject;
begin
  Parameters.RoundType := cbRoundType.ItemIndex;
  Parameters.VATSeries := edtVATSeries.Text;
  Parameters.VATNumber := edtVATNumber.Text;
  Parameters.AmountDecimalPlaces := StrToInt(cbAmountDecimalPlaces.Text);
end;

end.

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
    cbRoundType: TTntComboBox;
    lblRoundType: TTntLabel;
    edtVATSeries: TTntEdit;
    lblVATSeries: TTntLabel;
    edtVATNumber: TTntEdit;
    lblVATNumber: TTntLabel;
    cbAmountDecimalPlaces: TTntComboBox;
    lblAmountDecimalPlaces: TTntLabel;
    edtCurrencyName: TTntEdit;
    lblCurrencyName: TTntLabel;
    chbPrintEnabled: TTntCheckBox;
    lblOfflineText: TTntLabel;
    edtOfflineText: TTntEdit;
    procedure ModifiedClick(Sender: TObject);
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
  edtCurrencyName.Text := Parameters.CurrencyName;
  edtOfflineText.Text := Parameters.OfflineText;
  chbPrintEnabled.Checked := Parameters.PrintEnabled;
end;

procedure TfmFptrMiscParams.UpdateObject;
begin
  Parameters.RoundType := cbRoundType.ItemIndex;
  Parameters.VATSeries := edtVATSeries.Text;
  Parameters.VATNumber := edtVATNumber.Text;
  Parameters.AmountDecimalPlaces := StrToInt(cbAmountDecimalPlaces.Text);
  Parameters.CurrencyName := edtCurrencyName.Text;
  Parameters.OfflineText := edtOfflineText.Text;
  Parameters.PrintEnabled := chbPrintEnabled.Checked;
end;

procedure TfmFptrMiscParams.ModifiedClick(Sender: TObject);
begin
  Modified;
end;

end.

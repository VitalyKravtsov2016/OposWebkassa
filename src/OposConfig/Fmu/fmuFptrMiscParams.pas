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
  edtVATSeries.Text := IntToStr(Parameters.VATSeries);
  edtVATNumber.Text := IntToStr(Parameters.VATNumber);
end;

procedure TfmFptrMiscParams.UpdateObject;
begin
  Parameters.RoundType := cbRoundType.ItemIndex;
  Parameters.VATSeries := StrToInt(edtVATSeries.Text);
  Parameters.VATNumber := StrToInt(edtVATNumber.Text);
end;

end.

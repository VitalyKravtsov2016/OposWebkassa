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
end;

procedure TfmFptrMiscParams.UpdateObject;
begin
  Parameters.RoundType := cbRoundType.ItemIndex;
end;

end.

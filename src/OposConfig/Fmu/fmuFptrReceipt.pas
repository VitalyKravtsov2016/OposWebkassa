unit fmuFptrReceipt;

interface

uses
  // VCL
  StdCtrls, Controls, Classes, ComObj, SysUtils, Math,
  // 3'd
  SynMemo, SynEdit, TntStdCtrls,
  // This
  PrinterParameters, FiscalPrinterDevice, Grids, TntGrids;

type
  { TfmTranslation }

  TfmFptrReceipt = class(TFptrPage)
  public
    procedure UpdatePage; override;
    procedure UpdateObject; override;
  end;

implementation

{$R *.DFM}

{ TfmTranslation }

procedure TfmFptrReceipt.UpdatePage;
begin
end;

procedure TfmFptrReceipt.UpdateObject;
begin
end;

end.

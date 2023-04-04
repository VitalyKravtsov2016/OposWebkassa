unit fmuFptrReceipt;

interface

uses
  // VCL
  StdCtrls, Controls, Classes, ComObj, SysUtils, Math,
  // 3'd
  SynMemo, SynEdit, TntStdCtrls,
  // This
  PrinterParameters, FiscalPrinterDevice, Grids, TntGrids, Buttons,
  ToolWin, ComCtrls, SynEditHighlighter, SynHighlighterXML;

type
  { TfmFptrReceipt }

  TfmFptrReceipt = class(TFptrPage)
    SynEdit: TSynEdit;
    SynXMLSyn: TSynXMLSyn;
    ToolBar1: TToolBar;
    SpeedButton1: TSpeedButton;
  public
    procedure UpdatePage; override;
    procedure UpdateObject; override;
  end;

implementation

{$R *.DFM}

{ TfmFptrReceipt }

procedure TfmFptrReceipt.UpdatePage;
begin
  SynEdit.Lines.Text := Parameters.TemplateText;
end;

procedure TfmFptrReceipt.UpdateObject;
begin
  Parameters.TemplateText := SynEdit.Lines.Text;
end;

end.

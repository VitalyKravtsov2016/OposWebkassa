unit fmuTranslation;

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

  TfmTranslation = class(TFptrPage)
    StringGrid: TTntStringGrid;
    procedure ModifiedClick(Sender: TObject);
  public
    procedure UpdatePage; override;
    procedure UpdateObject; override;
  end;

implementation

{$R *.DFM}

{ TfmTranslation }

procedure TfmTranslation.ModifiedClick(Sender: TObject);
begin
  Modified;
end;

procedure TfmTranslation.UpdatePage;
var
  i: Integer;
  RowCount: Integer;
begin
  StringGrid.Cells[0,0] := 'Русский';
  StringGrid.Cells[1,0] := 'Казахский';
  RowCount := Max(Parameters.TranslationRus.Items.Count, Parameters.Translation.Items.Count);
  StringGrid.RowCount := RowCount;
  for i := 0 to Parameters.TranslationRus.Items.Count-1 do
  begin
    StringGrid.Cells[0, i+1] := Parameters.TranslationRus.Items[i];
  end;
  for i := 0 to Parameters.Translation.Items.Count-1 do
  begin
    StringGrid.Cells[1, i+1] := Parameters.Translation.Items[i];
  end;
end;

procedure TfmTranslation.UpdateObject;
var
  i: Integer;
begin
  for i := 0 to Parameters.TranslationRus.Items.Count-1 do
  begin
    Parameters.TranslationRus.Items[i] := StringGrid.Cells[0, i+1];
  end;
  for i := 0 to Parameters.Translation.Items.Count-1 do
  begin
    Parameters.Translation.Items[i] := StringGrid.Cells[1, i + 1];
  end;
end;

end.

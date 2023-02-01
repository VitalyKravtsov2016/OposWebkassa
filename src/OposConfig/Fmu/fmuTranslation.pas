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
    btnAdd: TTntButton;
    chbTranslationEnabled: TCheckBox;
    procedure ModifiedClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
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
  chbTranslationEnabled.Checked := Parameters.TranslationEnabled;
  RowCount := Max(Parameters.TranslationRus.Items.Count, Parameters.Translation.Items.Count);
  StringGrid.RowCount := RowCount + 1;

  StringGrid.Cells[0,0] := '№';
  StringGrid.Cells[1,0] := 'Русский';
  StringGrid.Cells[2,0] := 'Казахский';
  for i := 0 to Parameters.TranslationRus.Items.Count-1 do
  begin
    StringGrid.Cells[0, i+1] := IntToStr(i+1);
    StringGrid.Cells[1, i+1] := Parameters.TranslationRus.Items[i];
  end;
  for i := 0 to Parameters.Translation.Items.Count-1 do
  begin
    StringGrid.Cells[2, i+1] := Parameters.Translation.Items[i];
  end;
end;

procedure TfmTranslation.UpdateObject;
var
  i: Integer;
begin
  Parameters.TranslationEnabled := chbTranslationEnabled.Checked;
  for i := 0 to Parameters.TranslationRus.Items.Count-1 do
  begin
    Parameters.TranslationRus.Items[i] := StringGrid.Cells[1, i+1];
  end;
  for i := 0 to Parameters.Translation.Items.Count-1 do
  begin
    Parameters.Translation.Items[i] := StringGrid.Cells[2, i + 1];
  end;
end;

procedure TfmTranslation.FormResize(Sender: TObject);
var
  ColWidth: Integer;
begin
  ColWidth := (StringGrid.Width - StringGrid.ColWidths[0]) div 2;
  StringGrid.ColWidths[1] := ColWidth;
  StringGrid.ColWidths[2] := StringGrid.Width - StringGrid.ColWidths[0] - ColWidth - 6;
end;

procedure TfmTranslation.btnAddClick(Sender: TObject);
var
  Selection: TGridRect;
begin
  StringGrid.RowCount := StringGrid.RowCount + 1;
  Selection.Left := 0;
  Selection.Right := 0;
  Selection.Top := StringGrid.RowCount-1;
  Selection.Bottom := StringGrid.RowCount-1;
  StringGrid.Selection := Selection;
  StringGrid.Cells[0, StringGrid.RowCount-1] := IntToStr(StringGrid.RowCount-1);
end;

end.

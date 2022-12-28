unit fmuFptrTrailer;

interface

uses
  // VCL
  Windows, StdCtrls, Controls, Classes, SysUtils, Registry, Dialogs, Forms,
  ComCtrls, Buttons, ExtDlgs, ExtCtrls, ComObj,
  // 3'd
  SynMemo, SynEdit,
  // This
  FiscalPrinterDevice, PrinterParameters, FptrTypes,
  TntStdCtrls;

type
  { TfmFptrTrailer }

  TfmFptrTrailer = class(TFptrPage)
    symTrailer: TSynMemo;
    lblNumTrailerLines: TTntLabel;
    cbNumTrailerLines: TTntComboBox;
    procedure ModifiedClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  public
    procedure UpdatePage; override;
    procedure UpdateObject; override;
  end;

implementation

{$R *.DFM}

procedure TfmFptrTrailer.UpdatePage;
begin
  cbNumTrailerLines.ItemIndex := Parameters.NumTrailerLines;
  symTrailer.Text := Parameters.TrailerText;
end;

procedure TfmFptrTrailer.UpdateObject;
begin
  Parameters.TrailerText := symTrailer.Text;
  Parameters.NumTrailerLines := cbNumTrailerLines.ItemIndex;
end;

procedure TfmFptrTrailer.ModifiedClick(Sender: TObject);
begin
  Modified;
end;

procedure TfmFptrTrailer.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  cbNumTrailerLines.Items.BeginUpdate;
  try
    cbNumTrailerLines.Items.Clear;
    for i := MinTrailerLines to MaxTrailerLines do
      cbNumTrailerLines.Items.Add(IntToStr(i));
  finally
    cbNumTrailerLines.Items.EndUpdate;
  end;
end;

end.

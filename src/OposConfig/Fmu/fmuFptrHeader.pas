unit fmuFptrHeader;

interface

uses
  // VCL
  StdCtrls, Controls, Classes, ComObj, SysUtils,
  // 3'd
  SynMemo, SynEdit, TntStdCtrls,
  // This
  PrinterParameters, FiscalPrinterDevice, FptrTypes;

type
  { TfmFiscalPrinter }

  TfmFptrHeader = class(TFptrPage)
    symHeader: TSynMemo;
    lblNumHeaderLines: TTntLabel;
    cbNumHeaderLines: TTntComboBox;
    procedure PageChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  public
    procedure UpdatePage; override;
    procedure UpdateObject; override;
  end;

implementation

{$R *.DFM}

{ TfmFptrHeader }

procedure TfmFptrHeader.PageChange(Sender: TObject);
begin
  Modified;
end;

procedure TfmFptrHeader.UpdatePage;
begin
  cbNumHeaderLines.ItemIndex := Parameters.NumHeaderLines-MinHeaderLines;
  symHeader.Text := Parameters.Header;
end;

procedure TfmFptrHeader.UpdateObject;
begin
  Parameters.Header := symHeader.Text;
  Parameters.NumHeaderLines := cbNumHeaderLines.ItemIndex + MinHeaderLines;
end;

procedure TfmFptrHeader.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  cbNumHeaderLines.Items.BeginUpdate;
  try
    cbNumHeaderLines.Items.Clear;
    for i := MinHeaderLines to MaxHeaderLines do
      cbNumHeaderLines.Items.Add(IntToStr(i));
  finally
    cbNumHeaderLines.Items.EndUpdate;
  end;
end;

end.

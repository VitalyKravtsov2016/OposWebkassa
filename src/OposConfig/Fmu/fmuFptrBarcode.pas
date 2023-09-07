unit fmuFptrBarcode;

interface

uses
  // VCL
  StdCtrls, Controls, Classes, ComObj, SysUtils,
  // 3'd
  SynMemo, SynEdit, TntStdCtrls,
  // This
  PrinterParameters, FiscalPrinterDevice, FptrTypes, ExtCtrls;

type
  { TfmFptrBarcode }

  TfmFptrBarcode = class(TFptrPage)
    rgBarcode: TRadioGroup;
    rbBarcodeESCCommands: TRadioButton;
    rbBarcodeGraphics: TRadioButton;
    rbBarcodeText: TRadioButton;
    rbBarcodeNone: TRadioButton;
    procedure ModifiedClick(Sender: TObject);
  public
    procedure UpdatePage; override;
    procedure UpdateObject; override;
  end;

implementation

{$R *.DFM}

{ TfmFptrBarcode }

procedure TfmFptrBarcode.ModifiedClick(Sender: TObject);
begin
  Modified;
end;

procedure TfmFptrBarcode.UpdatePage;
begin
  rbBarcodeESCCommands.Checked := Parameters.PrintBarcode = PrintBarcodeESCCommands;
  rbBarcodeGraphics.Checked := Parameters.PrintBarcode = PrintBarcodeGraphics;
  rbBarcodeText.Checked := Parameters.PrintBarcode = PrintBarcodeText;
  rbBarcodeNone.Checked := Parameters.PrintBarcode = PrintBarcodeNone;
end;

procedure TfmFptrBarcode.UpdateObject;
begin
  if rbBarcodeESCCommands.Checked  then
    Parameters.PrintBarcode := PrintBarcodeESCCommands;
  if rbBarcodeGraphics.Checked then
    Parameters.PrintBarcode := PrintBarcodeGraphics;
  if rbBarcodeText.Checked then
    Parameters.PrintBarcode := PrintBarcodeText;
  if rbBarcodeNone.Checked then
    Parameters.PrintBarcode := PrintBarcodeNone;
end;

end.

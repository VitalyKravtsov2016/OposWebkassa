unit fmuFptrBarcode;

interface

uses
  // VCL
  StdCtrls, Controls, Classes, ComObj, SysUtils, ExtCtrls,
  // 3'd
  SynMemo, SynEdit,
  // Tnt
  TntStdCtrls, TntExtCtrls,
  // This
  PrinterParameters, FiscalPrinterDevice, FptrTypes;

type
  { TfmFptrBarcode }

  TfmFptrBarcode = class(TFptrPage)
    rgBarcode: TTntRadioGroup;
    rbBarcodeESCCommands: TTntRadioButton;
    rbBarcodeGraphics: TTntRadioButton;
    rbBarcodeText: TTntRadioButton;
    rbBarcodeNone: TTntRadioButton;
    chbReplaceDataMatrixWithQRCode: TTntCheckBox;
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
  chbReplaceDataMatrixWithQRCode.Checked := Parameters.ReplaceDataMatrixWithQRCode;
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
  Parameters.ReplaceDataMatrixWithQRCode := chbReplaceDataMatrixWithQRCode.Checked;
end;

end.




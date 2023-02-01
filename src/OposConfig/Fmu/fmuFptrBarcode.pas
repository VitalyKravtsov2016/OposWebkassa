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
    rgQRCode: TRadioGroup;
    rbQRCodeAsESC: TRadioButton;
    rbQRCodeAsGraphics: TRadioButton;
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
  rbQRCodeAsESC.Checked := Parameters.QRCode = QRCodeESC;
  rbQRCodeAsGraphics.Checked := Parameters.QRCode = QRCodeGraphics;
end;

procedure TfmFptrBarcode.UpdateObject;
begin
  if rbQRCodeAsESC.Checked  then
    Parameters.QRCode := QRCodeESC;
  if rbQRCodeAsGraphics.Checked then
    Parameters.QRCode := QRCodeGraphics;
end;

end.

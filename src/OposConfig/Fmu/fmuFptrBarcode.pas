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
    rbQRCodeESC: TRadioButton;
    rbQRCodeGraphics: TRadioButton;
    rbQRCodeText: TRadioButton;
    rbQRCodeNone: TRadioButton;
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
  rbQRCodeESC.Checked := Parameters.QRCode = QRCodeESC;
  rbQRCodeGraphics.Checked := Parameters.QRCode = QRCodeGraphics;
  rbQRCodeText.Checked := Parameters.QRCode = QRCodeText;
  rbQRCodeNone.Checked := Parameters.QRCode = QRCodeNone;
end;

procedure TfmFptrBarcode.UpdateObject;
begin
  if rbQRCodeESC.Checked  then
    Parameters.QRCode := QRCodeESC;
  if rbQRCodeGraphics.Checked then
    Parameters.QRCode := QRCodeGraphics;
  if rbQRCodeText.Checked then
    Parameters.QRCode := QRCodeText;
  if rbQRCodeNone.Checked then
    Parameters.QRCode := QRCodeNone;
end;

end.

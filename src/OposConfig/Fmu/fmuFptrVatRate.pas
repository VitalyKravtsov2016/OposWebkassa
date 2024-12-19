unit fmuFptrVatRate;

interface

uses
  // VCL
  StdCtrls, Controls, ComCtrls, Classes, SysUtils, Spin, Mask,
  // Tnt
  TntClasses, TntRegistry, TntStdCtrls, TntComCtrls,
  // This
  FiscalPrinterDevice, PrinterParameters, FptrTypes, VatRate;

type
  { TfmFptrVatCode }

  TfmFptrVatRate = class(TFptrPage)
    lblVatCode: TTntLabel;
    lblVatRate: TTntLabel;
    lvVatCodes: TTntListView;
    btnDelete: TTntButton;
    btnAdd: TTntButton;
    seVatCode: TSpinEdit;
    edtVatName: TTntEdit;
    TntLabel1: TTntLabel;
    chbVatCodeEnabled: TTntCheckBox;
    edtVatRate: TTntEdit;
    lblTaxType: TTntLabel;
    cbVatType: TTntComboBox;
    procedure btnAddClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure ModifiedClick(Sender: TObject);
  private
    procedure UpdateItems;
    procedure UpdateVatRate;
  public
    procedure UpdatePage; override;
    procedure UpdateObject; override;
  end;

implementation

{$R *.DFM}

{ TfmFptrVatCode }

procedure TfmFptrVatRate.UpdateItems;
var
  i: Integer;
  Item: TListItem;
begin
  with lvVatCodes do
  begin
    Items.BeginUpdate;
    try
      Items.Clear;
		  for i := 0 to Parameters.VatRates.Count-1 do
      begin
        Item := Items.Add;
        Item.Caption := IntToStr(Parameters.VatRates[i].ID);
        Item.SubItems.Add(Parameters.VatRates[i].VatTypeText);
        Item.SubItems.Add(Format('%.2f', [Parameters.VatRates[i].Rate]));
        Item.SubItems.Add(Parameters.VatRates[i].Name);
        if i = 0 then
        begin
          Item.Focused := True;
          Item.Selected := True;
        end;
      end;
      btnDelete.Enabled := Parameters.VatRates.Count > 0;
    finally
      Items.EndUpdate;
    end;
  end;
end;

procedure TfmFptrVatRate.UpdatePage;
begin
  cbVatType.ItemIndex := VAT_TYPE_ZERO_TAX;
  UpdateItems;
  UpdateVatRate;
  chbVatCodeEnabled.Checked := Parameters.VatRateEnabled;
end;

procedure TfmFptrVatRate.UpdateObject;
begin
  Parameters.VatRateEnabled := chbVatCodeEnabled.Checked;
end;

procedure TfmFptrVatRate.btnAddClick(Sender: TObject);
var
  Item: TListItem;
  VatRate: TVatRateRec;
begin
  VatRate.ID := seVatCode.Value;
  VatRate.VatType := cbVatType.ItemIndex;
  VatRate.Rate := StrToFloat(edtVatRate.Text);
  VatRate.Name := edtVatName.Text;
  Parameters.VatRates.Add(VatRate);

  Item := lvVatCodes.Items.Add;
  Item.Caption := IntToStr(seVatCode.Value);
  Item.SubItems.Add(cbVatType.Text);
  Item.SubItems.Add(edtVatRate.Text);
  Item.SubItems.Add(edtVatName.Text);

  Item.Focused := True;
  Item.Selected := True;
  btnDelete.Enabled := True;
  seVatCode.Value := seVatCode.Value + 1;
  Modified;
end;

procedure TfmFptrVatRate.btnDeleteClick(Sender: TObject);
var
  Index: Integer;
  Item: TListItem;
begin
  Item := lvVatCodes.Selected;
  if Item <> nil then
  begin
    Index := Item.Index;
  	Parameters.VatRates[Index].Free;
    Item.Delete;
    if Index >= lvVatCodes.Items.Count then
      Index := lvVatCodes.Items.Count-1;
    if Index >= 0 then
    begin
      Item := lvVatCodes.Items[Index];
      Item.Focused := True;
      Item.Selected := True;
	  	Modified;
    end;
    btnDelete.Enabled := lvVatCodes.Items.Count > 0;
  end;
end;

procedure TfmFptrVatRate.ModifiedClick(Sender: TObject);
begin
  UpdateVatRate;
  Modified;
end;

procedure TfmFptrVatRate.UpdateVatRate;
begin
  edtVatRate.Enabled := cbVatType.ItemIndex = VAT_TYPE_NORMAL;
  if cbVatType.ItemIndex <> VAT_TYPE_NORMAL then
    edtVatRate.Text := '0';
end;

end.

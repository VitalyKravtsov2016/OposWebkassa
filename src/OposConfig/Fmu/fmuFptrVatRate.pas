unit fmuFptrVatRate;

interface

uses
  // VCL
  StdCtrls, Controls, ComCtrls, Classes, SysUtils,
  // Tnt
  TntClasses, TntStdCtrls, TntRegistry,
  // This
  FiscalPrinterDevice, PrinterParameters, FptrTypes, Spin, Mask;

type
  { TfmFptrVatCode }

  TfmFptrVatRate = class(TFptrPage)
    lblVatCode: TTntLabel;
    lblVatRate: TTntLabel;
    lvVatCodes: TListView;
    btnDelete: TTntButton;
    btnAdd: TTntButton;
    seVatCode: TSpinEdit;
    edtVatName: TEdit;
    TntLabel1: TTntLabel;
    chbVatCodeEnabled: TCheckBox;
    edtVatRate: TEdit;
    procedure btnAddClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure ModifiedClick(Sender: TObject);
  private
    procedure UpdateItems;
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
        Item.Caption := IntToStr(Parameters.VatRates[i].Code);
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
  UpdateItems;
  chbVatCodeEnabled.Checked := Parameters.VatRateEnabled;
end;

procedure TfmFptrVatRate.UpdateObject;
begin
  Parameters.VatRateEnabled := chbVatCodeEnabled.Checked;
end;

procedure TfmFptrVatRate.btnAddClick(Sender: TObject);
var
  Item: TListItem;
begin
  Parameters.VatRates.Add(seVatCode.Value, StrToFloat(edtVatRate.Text),
    edtVatName.Text);

  Item := lvVatCodes.Items.Add;
  Item.Caption := IntToStr(seVatCode.Value);
  Item.SubItems.Add(edtVatRate.Text);
  Item.SubItems.Add(edtVatName.Text);

  Item.Focused := True;
  Item.Selected := True;
  btnDelete.Enabled := True;
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
  Modified;
end;

end.

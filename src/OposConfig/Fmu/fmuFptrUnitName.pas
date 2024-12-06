unit fmuFptrUnitName;

interface

uses
  // VCL
  StdCtrls, Controls, ComCtrls, Classes, SysUtils, Spin, Mask,
  // Tnt
  TntClasses, TntRegistry, TntStdCtrls, TntComCtrls,
  // This
  FiscalPrinterDevice, PrinterParameters, FptrTypes;

type
  { TfmFptrUnitName }

  TfmFptrUnitName = class(TFptrPage)
    lblAppUnitName: TTntLabel;
    lvUnitNames: TTntListView;
    btnDelete: TTntButton;
    btnAdd: TTntButton;
    lblSrvUnitName: TTntLabel;
    edtAppUnitName: TTntEdit;
    cbSrvUnitName: TComboBox;
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

{ TfmFptrUnitName }

procedure TfmFptrUnitName.UpdateItems;
var
  i: Integer;
  Item: TListItem;
begin
  with lvUnitNames do
  begin
    Items.BeginUpdate;
    try
      Items.Clear;
		  for i := 0 to Parameters.UnitNames.Count-1 do
      begin
        Item := Items.Add;
        Item.Caption := Parameters.UnitNames[i].AppUnitName;
        Item.SubItems.Add(Parameters.UnitNames[i].SrvUnitName);
        if i = 0 then
        begin
          Item.Focused := True;
          Item.Selected := True;
        end;
      end;
      btnDelete.Enabled := Parameters.UnitNames.Count > 0;
    finally
      Items.EndUpdate;
    end;
  end;
end;

procedure TfmFptrUnitName.UpdatePage;
begin
  UpdateItems;
end;

procedure TfmFptrUnitName.UpdateObject;
begin
end;

procedure TfmFptrUnitName.btnAddClick(Sender: TObject);
var
  Item: TListItem;
begin
  Parameters.AddUnitName(edtAppUnitName.Text, cbSrvUnitName.Text);

  Item := lvUnitNames.Items.Add;
  Item.Caption := edtAppUnitName.Text;
  Item.SubItems.Add(cbSrvUnitName.Text);

  Item.Focused := True;
  Item.Selected := True;
  btnDelete.Enabled := True;
  Modified;
end;

procedure TfmFptrUnitName.btnDeleteClick(Sender: TObject);
var
  Index: Integer;
  Item: TListItem;
begin
  Item := lvUnitNames.Selected;
  if Item <> nil then
  begin
    Index := Item.Index;
  	Parameters.UnitNames[Index].Free;
    Item.Delete;
    if Index >= lvUnitNames.Items.Count then
      Index := lvUnitNames.Items.Count-1;
    if Index >= 0 then
    begin
      Item := lvUnitNames.Items[Index];
      Item.Focused := True;
      Item.Selected := True;
	  	Modified;
    end;
    btnDelete.Enabled := lvUnitNames.Items.Count > 0;
  end;
end;

procedure TfmFptrUnitName.ModifiedClick(Sender: TObject);
begin
  Modified;
end;

end.

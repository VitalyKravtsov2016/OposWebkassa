unit fmuFptrUnitName;

interface

uses
  // VCL
  StdCtrls, Controls, ComCtrls, Classes, SysUtils, Spin, Mask,
  // Tnt
  TntClasses, TntRegistry, TntStdCtrls, TntComCtrls,
  // This
  FiscalPrinterDevice, PrinterParameters, FptrTypes, WebkassaClient;

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
    btnUpdateSrvUnits: TTntButton;
    procedure btnAddClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure ModifiedClick(Sender: TObject);
    procedure btnUpdateSrvUnitsClick(Sender: TObject);
    procedure lvUnitNamesSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
  private
    procedure UpdateSrvUnits;
    procedure UpdadeSrvNames;
    procedure UpdateListItems;
    function CreateDriver: TWebkassaClient;
  public
    procedure UpdatePage; override;
    procedure UpdateObject; override;
  end;

implementation

{$R *.DFM}

{ TfmFptrUnitName }

function TfmFptrUnitName.CreateDriver: TWebkassaClient;
var
  Driver: TWebkassaClient;
begin
  Driver := TWebkassaClient.Create(Logger);
  Driver.RaiseErrors := True;
  Driver.Login := Parameters.Login;
  Driver.Password := Parameters.Password;
  Driver.Address := Parameters.WebkassaAddress;
  Driver.ConnectTimeout := Parameters.ConnectTimeout;
  Driver.Address := Parameters.WebkassaAddress;

  Result := Driver;
end;

procedure TfmFptrUnitName.UpdateListItems;
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
        Item.Caption := Parameters.UnitNames[i].AppName;
        Item.SubItems.Add(Parameters.UnitNames[i].SrvName);
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

procedure TfmFptrUnitName.UpdadeSrvNames;
var
  S: string;
  i: Integer;
  Item: TUnitItem;
begin
  cbSrvUnitName.Items.BeginUpdate;
  try
    cbSrvUnitName.Items.Clear;
    for i := 0 to Parameters.Units.Count-1 do
    begin
      Item := Parameters.Units[i];
      S := Format('%d, %s', [Item.Code, Item.NameRu]);
      cbSrvUnitName.Items.AddObject(S, Item);
    end;
  finally
    cbSrvUnitName.Items.EndUpdate;
  end;
  if (cbSrvUnitName.Text = '')and(cbSrvUnitName.Items.Count > 0) then
    cbSrvUnitName.ItemIndex := 0;
end;

procedure TfmFptrUnitName.UpdateSrvUnits;
var
  Driver: TWebkassaClient;
  Command: TReadUnitsCommand;
begin
  EnableButtons(False);
  UpdateObject;
  Driver := CreateDriver;
  Command := TReadUnitsCommand.Create;
  try
    Driver.Connect;
    Command.Request.Token := Driver.Token;
    Driver.ReadUnits(Command);
    Parameters.Units.Assign(Command.Data);
  finally
    Driver.Free;
    Command.Free;
    EnableButtons(True);
  end;
end;

procedure TfmFptrUnitName.UpdatePage;
begin
  UpdateListItems;
  UpdadeSrvNames;
  btnAdd.Enabled := (edtAppUnitName.Text <> '')and(cbSrvUnitName.Text <> '');
  btnDelete.Enabled := lvUnitNames.Selected <> nil;
end;

procedure TfmFptrUnitName.UpdateObject;
begin
end;

procedure TfmFptrUnitName.btnAddClick(Sender: TObject);
var
  Item: TListItem;
  SrvCode: Integer;
begin
  SrvCode := TUnitItem(cbSrvUnitName.Items.Objects[cbSrvUnitName.ItemIndex]).Code;
  Parameters.AddUnitName(edtAppUnitName.Text, cbSrvUnitName.Text, SrvCode);

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
  btnAdd.Enabled := (edtAppUnitName.Text <> '')and(cbSrvUnitName.Text <> '');
end;

procedure TfmFptrUnitName.btnUpdateSrvUnitsClick(Sender: TObject);
begin
  UpdateSrvUnits;
  UpdadeSrvNames;
end;

procedure TfmFptrUnitName.lvUnitNamesSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  btnDelete.Enabled := lvUnitNames.Selected <> nil;
end;

end.

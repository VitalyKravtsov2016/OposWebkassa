unit fmuFptrConnection;

interface

uses
  // VCL
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Spin,
  // Tnt
  TntStdCtrls,
  // This
  untUtil, PrinterParameters, FptrTypes, FiscalPrinterDevice, FileUtils,
  WebkassaClient, LogFile;

type
  { TfmFptrConnection }

  TfmFptrConnection = class(TFptrPage)
    gbConenctionParams: TTntGroupBox;
    lblConnectTimeout: TTntLabel;
    lblWebkassaAddress: TTntLabel;
    seConnectTimeout: TSpinEdit;
    edtWebkassaAddress: TEdit;
    lblLogin: TTntLabel;
    edtLogin: TEdit;
    edtPassword: TEdit;
    lblPassword: TTntLabel;
    btnTestConnection: TButton;
    lblCashBoxNumber: TTntLabel;
    cbCashboxNumber: TComboBox;
    btnUpdateCashBoxNumbers: TButton;
    edtResultCode: TEdit;
    lblResultCode: TTntLabel;
    procedure btnTestConnectionClick(Sender: TObject);
    procedure btnUpdateCashBoxNumbersClick(Sender: TObject);
    procedure ModifiedClick(Sender: TObject);
  private
    function CreateDriver: TWebkassaClient;
  public
    procedure UpdatePage; override;
    procedure UpdateObject; override;
  end;

implementation

{$R *.dfm}

{ TfmFptrConnection }

procedure TfmFptrConnection.UpdatePage;
begin
  edtWebkassaAddress.Text := Parameters.WebkassaAddress;
  seConnectTimeout.Value := Parameters.ConnectTimeout;
  edtLogin.Text := Parameters.Login;
  edtPassword.Text := Parameters.Password;
  cbCashboxNumber.Text := Parameters.CashboxNumber;
end;

procedure TfmFptrConnection.UpdateObject;
begin
  Parameters.WebkassaAddress := edtWebkassaAddress.Text;
  Parameters.ConnectTimeout := seConnectTimeout.Value;
  Parameters.Login := edtLogin.Text;
  Parameters.Password := edtPassword.Text;
  Parameters.CashboxNumber := cbCashboxNumber.Text;
end;

function TfmFptrConnection.CreateDriver: TWebkassaClient;
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

procedure TfmFptrConnection.btnTestConnectionClick(Sender: TObject);
var
  Driver: TWebkassaClient;
begin
  EnableButtons(False);
  edtResultCode.Clear;
  UpdateObject;
  Driver := CreateDriver;
  try
    Driver.Connect;
    edtResultCode.Text := 'OK';
  except
    on E: Exception do
    begin
      Logger.Error(E.Message);
      edtResultCode.Text := E.Message;
    end;
  end;
  Driver.Free;
  EnableButtons(True);
end;

procedure TfmFptrConnection.btnUpdateCashBoxNumbersClick(Sender: TObject);
var
  i: Integer;
  Index: Integer;
  Item: TCashbox;
  Command: TCashboxesCommand;
  Driver: TWebkassaClient;
begin
  EnableButtons(False);
  Command := TCashboxesCommand.Create;
  edtResultCode.Clear;
  UpdateObject;
  Driver := CreateDriver;
  try
    Driver.Connect;

    Command.Request.Token := Driver.Token;
    Driver.ReadCashboxes(Command);

    cbCashboxNumber.Items.BeginUpdate;
    try
      cbCashboxNumber.Clear;
      for i := 0 to Command.Data.List.Count-1 do
      begin
        Item := Command.Data.List.Items[i] as TCashbox;
        cbCashboxNumber.Items.Add(Item.UniqueNumber);
      end;
      Index := cbCashboxNumber.Items.IndexOf(Parameters.CashboxNumber);
      if Index = -1 then Index := 0;
      cbCashboxNumber.ItemIndex := Index;
    finally
      cbCashboxNumber.Items.EndUpdate;
    end;

    edtResultCode.Text := 'OK';
  except
    on E: Exception do
    begin
      Logger.Error(E.Message);
      edtResultCode.Text := E.Message;
    end;
  end;
  Command.Free;
  Driver.Free;
  EnableButtons(True);
end;

procedure TfmFptrConnection.ModifiedClick(Sender: TObject);
begin
  Modified;
end;

end.

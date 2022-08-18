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
  private
    FDriver: TWebkassaClient;
    property Driver: TWebkassaClient read FDriver;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure UpdatePage; override;
    procedure UpdateObject; override;
  end;

var
  fmFptrConnection: TfmFptrConnection;

implementation

{$R *.dfm}

{ TfmFptrConnection }

constructor TfmFptrConnection.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDriver := TWebkassaClient.Create(TLogFile.Create);
end;

destructor TfmFptrConnection.Destroy;
begin
  FDriver.Free;
  inherited Destroy;
end;

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

procedure TfmFptrConnection.btnTestConnectionClick(Sender: TObject);
begin
  EnableButtons(False);
  edtResultCode.Clear;
  try
    UpdateObject;
    Driver.RaiseErrors := True;
    Driver.Address := Parameters.WebkassaAddress;
    Driver.Login := Parameters.Login;
    Driver.Password := Parameters.Password;
    Driver.Connect;
    edtResultCode.Text := 'OK';
  except
    on E: Exception do
    begin
      edtResultCode.Text := E.Message;
    end;
  end;
  EnableButtons(True);
end;

procedure TfmFptrConnection.btnUpdateCashBoxNumbersClick(Sender: TObject);
var
  i: Integer;
  Index: Integer;
  Item: TCashboxItem;
  Command: TCashboxesCommand;
begin
  EnableButtons(False);
  Command := TCashboxesCommand.Create;
  edtResultCode.Clear;
  try
    UpdateObject;
    Driver.RaiseErrors := True;
    Driver.Address := Parameters.WebkassaAddress;
    Driver.Login := Parameters.Login;
    Driver.Password := Parameters.Password;
    Driver.Connect;

    Command.Request.Token := Driver.Token;
    Driver.ReadCashboxes(Command);

    cbCashboxNumber.Items.BeginUpdate;
    try
      for i := 0 to Command.Data.List.Count-1 do
      begin
        Item := Command.Data.List.Items[i] as TCashboxItem;
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
      edtResultCode.Text := E.Message;
    end;
  end;
  Command.Free;
  EnableButtons(True);
end;

end.

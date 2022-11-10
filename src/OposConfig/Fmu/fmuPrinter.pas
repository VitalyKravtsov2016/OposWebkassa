unit fmuPrinter;

interface

uses
  // VCL
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Spin, ActiveX, ComObj,
  // Tnt
  TntStdCtrls, TntSysUtils,
  // Opos
  Opos, OposPtr, Oposhi, OposUtils, OposDevice,
  // This
  untUtil, PrinterParameters, FptrTypes, FiscalPrinterDevice, FileUtils,
  RecPrinter, ExtCtrls;

type
  { TfmPrinter }

  TfmPrinter = class(TFptrPage)
    lblPrinterName: TTntLabel;
    cbPrinterName: TTntComboBox;
    memResult: TMemo;
    lblResultCode: TTntLabel;
    btnTestConnection: TButton;
    btnPrintReceipt: TButton;
    lblPrinterType: TTntLabel;
    cbPrinterType: TTntComboBox;
    lblFontName: TTntLabel;
    cbFontName: TTntComboBox;
    pnlNetworkConnection: TPanel;
    lblRemoteHost: TLabel;
    edtRemoteHost: TEdit;
    lblRemotePort: TLabel;
    seRemotePort: TSpinEdit;
    seByteTimeout: TSpinEdit;
    lblByteTimeout: TLabel;
    procedure btnTestConnectionClick(Sender: TObject);
    procedure btnPrintReceiptClick(Sender: TObject);
    procedure cbPrinterTypeChange(Sender: TObject);
    procedure cbPrinterNameChange(Sender: TObject);
  private
    FPrinter: IRecPrinter;
    procedure UpdateFontNames;
    procedure UpdateDeviceNames;
    function GetPrinter: IRecPrinter;
    property Printer: IRecPrinter read GetPrinter;
    procedure UpdateNetworkParams;
  public
    destructor Destroy; override;

    procedure UpdatePage; override;
    procedure UpdateObject; override;
  end;

var
  fmPrinter: TfmPrinter;

implementation

{$R *.dfm}

{ TfmFptrConnection }

destructor TfmPrinter.Destroy;
begin
  FPrinter := nil;
  inherited Destroy;
end;

procedure TfmPrinter.UpdatePage;
begin
  cbPrinterType.ItemIndex := Parameters.PrinterType;
  cbPrinterName.Text := Parameters.PrinterName;
  cbFontName.Text := Parameters.FontName;

  UpdateNetworkParams;
  UpdateDeviceNames;
  UpdateFontNames;
end;

procedure TfmPrinter.UpdateNetworkParams;
var
  IsNetwork: Boolean;
begin
  IsNetwork := Parameters.PrinterType = PrinterTypeEscPrinterNetwork;
  pnlNetworkConnection.Enabled := IsNetwork;
  pnlNetworkConnection.Visible := IsNetwork;
  edtRemoteHost.Text := Parameters.RemoteHost;
  seRemotePort.Value := Parameters.RemotePort;
  seByteTimeout.Value := Parameters.ByteTimeout;
end;

procedure TfmPrinter.UpdateObject;
begin
  Parameters.PrinterType := cbPrinterType.ItemIndex;
  Parameters.PrinterName := cbPrinterName.Text;
  Parameters.FontName := cbFontName.Text;
end;

function TfmPrinter.GetPrinter: IRecPrinter;
begin
  if FPrinter = nil then
  begin
    if cbPrinterType.ItemIndex = PrinterTypePosPrinter then
      FPrinter := TPosPrinter.Create
    else
      FPrinter := TWinPrinter.Create;
  end;
  Result := FPrinter;
end;

procedure TfmPrinter.btnTestConnectionClick(Sender: TObject);
begin
  EnableButtons(False);
  memResult.Clear;
  try
    UpdateObject;
    Printer.DeviceName := Parameters.PrinterName;
    Printer.FontName := Parameters.FontName;
    memResult.Text := Printer.TestConnection;
  except
    on E: Exception do
    begin
      memResult.Text := 'Ошибка: ' + E.Message;
    end;
  end;
  EnableButtons(True);
end;

procedure TfmPrinter.btnPrintReceiptClick(Sender: TObject);
begin
  EnableButtons(False);
  memResult.Clear;
  try
    UpdateObject;
    Printer.DeviceName := Parameters.PrinterName;
    Printer.FontName := Parameters.FontName;
    memResult.Text := Printer.PrintTestReceipt;
  except
    on E: Exception do
    begin
      memResult.Text := 'Ошибка: ' + E.Message;
    end;
  end;
  EnableButtons(True);
end;

procedure TfmPrinter.cbPrinterTypeChange(Sender: TObject);
begin
  FPrinter := nil;
  UpdateDeviceNames;
  UpdateFontNames;
  UpdateNetworkParams;
end;

procedure TfmPrinter.UpdateDeviceNames;
var
  Index: Integer;
begin
  cbPrinterName.Items.BeginUpdate;
  try
    cbPrinterName.Items.Text := Printer.ReadDeviceList;
    Index := cbPrinterName.Items.IndexOf(Parameters.PrinterName);
    if Index = -1 then
      Index := 0;
    cbPrinterName.ItemIndex := Index;
  finally
    cbPrinterName.Items.EndUpdate;
  end;
end;

procedure TfmPrinter.UpdateFontNames;
var
  Index: Integer;
begin
  Printer.DeviceName := cbPrinterName.Text;
  cbFontName.Items.BeginUpdate;
  try
    cbFontName.Items.Text := Printer.GetFontNames;
    Index := cbFontName.Items.IndexOf(Parameters.FontName);
    if Index = -1 then
      Index := 0;
    cbFontName.ItemIndex := Index;
  except
    // !!!
  end;
  cbFontName.Items.EndUpdate;
end;

procedure TfmPrinter.cbPrinterNameChange(Sender: TObject);
begin
  UpdateFontNames;
end;

end.

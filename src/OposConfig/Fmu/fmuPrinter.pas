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
  RecPrinter;

type
  { TfmPrinter }

  TfmPrinter = class(TFptrPage)
    lblDeviceName: TTntLabel;
    cbDeviceName: TTntComboBox;
    memResult: TMemo;
    lblResultCode: TTntLabel;
    btnTestConnection: TButton;
    btnPrintReceipt: TButton;
    lblDeviceType: TTntLabel;
    cbDeviceType: TTntComboBox;
    procedure btnTestConnectionClick(Sender: TObject);
    procedure btnPrintReceiptClick(Sender: TObject);
    procedure cbDeviceTypeChange(Sender: TObject);
  private
    FPrinter: IRecPrinter;
    procedure UpdateDeviceNames;
    function GetPrinter: IRecPrinter;
    property Printer: IRecPrinter read GetPrinter;
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
  UpdateDeviceNames;
  cbDeviceType.ItemIndex := Parameters.PrinterType;
  cbDeviceName.Text := Parameters.PrinterName;
end;

procedure TfmPrinter.UpdateObject;
begin
  Parameters.PrinterType := cbDeviceType.ItemIndex;
  Parameters.PrinterName := cbDeviceName.Text;
end;

function TfmPrinter.GetPrinter: IRecPrinter;
begin
  if FPrinter = nil then
  begin
    //if Parameters.PrinterType = PrinterTypePosPrinter then
      FPrinter := TPosPrinter.Create;
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
    memResult.Text := Printer.PrintTestReceipt;
  except
    on E: Exception do
    begin
      memResult.Text := 'Ошибка: ' + E.Message;
    end;
  end;
  EnableButtons(True);
end;

procedure TfmPrinter.cbDeviceTypeChange(Sender: TObject);
begin
  UpdateDeviceNames;
end;

procedure TfmPrinter.UpdateDeviceNames;
begin
  cbDeviceName.Items.BeginUpdate;
  try
    cbDeviceName.Items.Text := Printer.ReadDeviceList;
    cbDeviceName.Text := Parameters.PrinterName;
  finally
    cbDeviceName.Items.EndUpdate;
  end;
end;

end.

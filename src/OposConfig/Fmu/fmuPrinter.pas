unit fmuPrinter;

interface

uses
  // VCL
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Spin, ActiveX, ComObj, ExtCtrls,
  // Tnt
  TntStdCtrls, TntSysUtils,
  // Opos
  Opos, OposPtr, Oposhi, OposUtils, OposDevice,
  // This
  untUtil, PrinterParameters, FptrTypes, FiscalPrinterDevice, FileUtils,
  WebkassaImpl;

type
  { TfmPrinter }

  TfmPrinter = class(TFptrPage)
    memResult: TMemo;
    lblResultCode: TTntLabel;
    btnTestConnection: TButton;
    btnPrintReceipt: TButton;
    PageControl1: TPageControl;
    tsCommonParams: TTabSheet;
    tsSocketParams: TTabSheet;
    lblRemoteHost: TLabel;
    edtRemoteHost: TEdit;
    seRemotePort: TSpinEdit;
    seByteTimeout: TSpinEdit;
    lblByteTimeout: TLabel;
    lblRemotePort: TLabel;
    lblPrinterName: TTntLabel;
    lblPrinterType: TTntLabel;
    lblFontName: TTntLabel;
    cbPrinterName: TTntComboBox;
    cbPrinterType: TTntComboBox;
    cbFontName: TTntComboBox;
    tsSerialParams: TTabSheet;
    lblPortName: TTntLabel;
    cbPortName: TTntComboBox;
    cbBaudRate: TTntComboBox;
    cbDataBits: TTntComboBox;
    lblDataBits: TTntLabel;
    lblBaudRate: TTntLabel;
    lblStopBits: TTntLabel;
    cbStopBits: TTntComboBox;
    cbParity: TTntComboBox;
    lblParity: TTntLabel;
    lblFlowControl: TTntLabel;
    cbFlowControl: TTntComboBox;
    Label1: TLabel;
    seSerialTimeout: TSpinEdit;
    procedure btnTestConnectionClick(Sender: TObject);
    procedure btnPrintReceiptClick(Sender: TObject);
    procedure cbPrinterTypeChange(Sender: TObject);
    procedure cbPrinterNameChange(Sender: TObject);
  private
    FPrinter: TWebkassaImpl;
    procedure UpdateFontNames;
    procedure UpdateDeviceNames;
    procedure UpdateBaudRates;
    procedure UpdatePortNames;
    procedure UpdateStopBits;
    procedure UpdateDataBits;
    procedure UpdateParity;
    procedure UpdateFlowControl;

    function GetPrinter: TWebkassaImpl;
    property Printer: TWebkassaImpl read GetPrinter;
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
  FPrinter.Free;
  inherited Destroy;
end;

procedure TfmPrinter.UpdatePage;
begin
  cbPrinterType.ItemIndex := Parameters.PrinterType;
  cbPrinterName.Text := Parameters.PrinterName;
  cbFontName.Text := Parameters.FontName;

  UpdateDeviceNames;
  UpdateFontNames;
  UpdatePortNames;
  UpdateBaudRates;
  UpdateDataBits;
  UpdateStopBits;
  UpdateParity;
  UpdateFlowControl;

  edtRemoteHost.Text := Parameters.RemoteHost;
  seRemotePort.Value := Parameters.RemotePort;
  seByteTimeout.Value := Parameters.ByteTimeout;
  seSerialTimeout.Value := Parameters.SerialTimeout;
end;

procedure TfmPrinter.UpdatePortNames;
begin
  cbPortName.Items.BeginUpdate;
  try
    cbPortName.Items.Clear;
    cbPortName.Items.Text := Parameters.SerialPortNames;
    cbPortName.ItemIndex := cbPortName.Items.IndexOf(Parameters.PortName);
  finally
    cbPortName.Items.EndUpdate;
  end;
end;

procedure TfmPrinter.UpdateBaudRates;
var
  i: Integer;
  Index: Integer;
  BaudRate: Integer;
begin
  cbBaudRate.Items.BeginUpdate;
  try
    cbBaudRate.Items.Clear;
    for i := Low(ValidBaudRates) to High(ValidBaudRates)-1 do
    begin
      BaudRate := ValidBaudRates[i];
      cbBaudRate.Items.AddObject(IntToStr(BaudRate), TObject(BaudRate));
    end;
    Index := Parameters.BaudRateIndex(Parameters.BaudRate);
    if Index = -1 then Index := 0;
    cbBaudRate.ItemIndex := Index;
  finally
    cbBaudRate.Items.EndUpdate;
  end;
end;

procedure TfmPrinter.UpdateDataBits;
begin
  cbDataBits.Items.BeginUpdate;
  try
    cbDataBits.Clear;
    cbDataBits.Items.AddObject('8', TObject(DATABITS_8));
    cbDataBits.ItemIndex := cbDataBits.Items.IndexOfObject(
      TObject(Parameters.DataBits));
  finally
    cbDataBits.Items.EndUpdate;
  end;
end;

procedure TfmPrinter.UpdateStopBits;
begin
  cbStopBits.Items.BeginUpdate;
  try
    cbStopBits.Clear;
    cbStopBits.Items.AddObject('1', TObject(STOPBITS_10));
    cbStopBits.Items.AddObject('1.5', TObject(STOPBITS_15));
    cbStopBits.Items.AddObject('2', TObject(STOPBITS_20));
    cbStopBits.ItemIndex := cbStopBits.Items.IndexOfObject(
      TObject(Parameters.StopBits));
  finally
    cbStopBits.Items.EndUpdate;
  end;
end;

procedure TfmPrinter.UpdateParity;
begin
  cbParity.Items.BeginUpdate;
  try
    cbParity.Clear;
    cbParity.Items.AddObject('Нет', TObject(PARITY_NONE));
    cbParity.Items.AddObject('Нечетность', TObject(PARITY_ODD));
    cbParity.Items.AddObject('Четность', TObject(PARITY_EVEN));
    cbParity.Items.AddObject('Установлен', TObject(PARITY_MARK));
    cbParity.Items.AddObject('Сброшен', TObject(PARITY_SPACE));
    cbParity.ItemIndex := cbParity.Items.IndexOfObject(
      TObject(Parameters.Parity));
  finally
    cbParity.Items.EndUpdate;
  end;
end;

procedure TfmPrinter.UpdateFlowControl;
begin
  cbFlowControl.Items.BeginUpdate;
  try
    cbFlowControl.Clear;
    cbFlowControl.Items.Add('XON / XOFF');
    cbFlowControl.Items.Add('Аппаратный');
    cbFlowControl.Items.Add('Нет');
    cbFlowControl.ItemIndex := Parameters.FlowControl;
  finally
    cbFlowControl.Items.EndUpdate;
  end;
end;

procedure TfmPrinter.UpdateObject;
begin
  Parameters.PrinterType := cbPrinterType.ItemIndex;
  Parameters.PrinterName := cbPrinterName.Text;
  Parameters.FontName := cbFontName.Text;
  Parameters.PortName := cbPortName.Text;
  Parameters.BaudRate := Integer(cbBaudRate.Items.Objects[cbBaudRate.ItemIndex]);
  Parameters.DataBits := Integer(cbDataBits.Items.Objects[cbDataBits.ItemIndex]);
  Parameters.StopBits := Integer(cbStopBits.Items.Objects[cbStopBits.ItemIndex]);
  Parameters.Parity := Integer(cbParity.Items.Objects[cbParity.ItemIndex]);
  Parameters.FlowControl := Integer(cbFlowControl.Items.Objects[cbFlowControl.ItemIndex]);
  Printer.Params.Assign(Parameters);
end;

function TfmPrinter.GetPrinter: TWebkassaImpl;
begin
  if FPrinter = nil then
    FPrinter := TWebkassaImpl.Create(nil);
  Result := FPrinter;
end;

procedure TfmPrinter.btnTestConnectionClick(Sender: TObject);
begin
  EnableButtons(False);
  memResult.Clear;
  try
    UpdateObject;
    memResult.Text := Printer.TestPrinterConnection;
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
  FPrinter.Free;
  FPrinter := nil;
  UpdateDeviceNames;
  UpdateFontNames;
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

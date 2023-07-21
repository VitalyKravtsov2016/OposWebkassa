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
  WebkassaImpl, RecPrinter, SerialPort;

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
    lblDevicePollTime: TTntLabel;
    seDevicePollTime: TSpinEdit;
    procedure btnTestConnectionClick(Sender: TObject);
    procedure btnPrintReceiptClick(Sender: TObject);
    procedure cbPrinterTypeChange(Sender: TObject);
    procedure cbPrinterNameChange(Sender: TObject);
    procedure ModifiedClick(Sender: TObject);
  private
    procedure UpdateFontNames;
    procedure UpdateDeviceNames;
    
    procedure UpdateBaudRates;
    procedure UpdatePortNames;
    procedure UpdateStopBits;
    procedure UpdateDataBits;
    procedure UpdateParity;
    procedure UpdateFlowControl;
    function CreatePrinter(PrinterType: Integer): TRecPrinter;
  public
    procedure UpdatePage; override;
    procedure UpdateObject; override;
  end;

implementation

{$R *.dfm}

{ TfmFptrConnection }

procedure TfmPrinter.UpdatePage;
begin
  cbPrinterType.ItemIndex := Parameters.PrinterType;
  cbPrinterName.Text := Parameters.PrinterName;
  cbFontName.Text := Parameters.FontName;

  //UpdateDeviceNames; !!!
  //UpdateFontNames;

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
  seDevicePollTime.Value := Parameters.DevicePollTime;
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
    cbStopBits.Items.AddObject('1', TObject(ONESTOPBIT));
    cbStopBits.Items.AddObject('1.5', TObject(ONE5STOPBITS));
    cbStopBits.Items.AddObject('2', TObject(TWOSTOPBITS));
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
    cbParity.Items.AddObject('Нет', TObject(NOPARITY));
    cbParity.Items.AddObject('Нечетность', TObject(ODDPARITY));
    cbParity.Items.AddObject('Четность', TObject(EVENPARITY));
    cbParity.Items.AddObject('Установлен', TObject(MARKPARITY));
    cbParity.Items.AddObject('Сброшен', TObject(SPACEPARITY));
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
    cbFlowControl.Items.AddObject('XON / XOFF', TObject(FLOW_CONTROL_XON));
    cbFlowControl.Items.AddObject('Аппаратный', TObject(FLOW_CONTROL_HARDWARE));
    cbFlowControl.Items.AddObject('Нет', TObject(FLOW_CONTROL_NONE));
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
  Parameters.DevicePollTime := seDevicePollTime.Value;
  // Serial
  Parameters.BaudRate := Integer(cbBaudRate.Items.Objects[cbBaudRate.ItemIndex]);
  Parameters.DataBits := Integer(cbDataBits.Items.Objects[cbDataBits.ItemIndex]);
  Parameters.StopBits := Integer(cbStopBits.Items.Objects[cbStopBits.ItemIndex]);
  Parameters.Parity := Integer(cbParity.Items.Objects[cbParity.ItemIndex]);
  Parameters.FlowControl := Integer(cbFlowControl.Items.Objects[cbFlowControl.ItemIndex]);
  Parameters.SerialTimeout := seSerialTimeout.Value;
  // Socket
  Parameters.RemoteHost := edtRemoteHost.Text;
  Parameters.RemotePort := seRemotePort.Value;
  Parameters.ByteTimeout := seByteTimeout.Value;
end;

function TfmPrinter.CreatePrinter(PrinterType: Integer): TRecPrinter;
begin
  case PrinterType of
    PrinterTypePosPrinter: Result := TOposPrinter.Create(Parameters);
    PrinterTypeWinPrinter: Result := TWinPrinter.Create(Parameters);
    PrinterTypeEscPrinterSerial: Result := TSerialEscPrinter.Create(Parameters);
    PrinterTypeEscPrinterNetwork: Result := TNetworkEscPrinter.Create(Parameters);
    PrinterTypeEscPrinterWindows: Result := TWindowsEscPrinter.Create(Parameters);
  else
    raise Exception.CreateFmt('Неизвестный тип принтера, %d', [PrinterType]);
  end;
end;

procedure TfmPrinter.btnTestConnectionClick(Sender: TObject);
var
  Printer: TRecPrinter;
begin
  EnableButtons(False);
  memResult.Clear;
  try
    UpdateObject;
    Printer := CreatePrinter(Parameters.PrinterType);
    try
      memResult.Text := Printer.TestConnection;
    finally
      Printer.Free;
    end;
  except
    on E: Exception do
    begin
      memResult.Text := 'Ошибка: ' + E.Message;
    end;
  end;
  EnableButtons(True);
end;

procedure TfmPrinter.btnPrintReceiptClick(Sender: TObject);
var
  Printer: TRecPrinter;
begin
  EnableButtons(False);
  memResult.Clear;
  try
    UpdateObject;
    Printer := CreatePrinter(Parameters.PrinterType);
    try
      memResult.Text := Printer.PrintTestReceipt;
    finally
      Printer.Free;
    end;
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
  UpdateDeviceNames;
  UpdateFontNames;
  Modified;
end;

procedure TfmPrinter.UpdateDeviceNames;
var
  Index: Integer;
  Printer: TRecPrinter;
begin
  try
    cbPrinterName.Items.BeginUpdate;
    Printer := CreatePrinter(cbPrinterType.ItemIndex);
    try
      cbPrinterName.Items.Text := Printer.ReadDeviceList;
      Index := cbPrinterName.Items.IndexOf(Parameters.PrinterName);
      if Index = -1 then
        Index := 0;
      cbPrinterName.ItemIndex := Index;
    finally
      Printer.Free;
      cbPrinterName.Items.EndUpdate;
    end;
  except
    on E: Exception do
      memResult.Text := E.Message;
  end;
end;

procedure TfmPrinter.UpdateFontNames;
var
  Index: Integer;
  Printer: TRecPrinter;
begin
  try
    cbFontName.Items.BeginUpdate;
    Parameters.PrinterName := cbPrinterName.Text;
    Printer := CreatePrinter(cbPrinterType.ItemIndex);
    try
      cbFontName.Items.Text := Printer.GetFontNames;
      Index := cbFontName.Items.IndexOf(Parameters.FontName);
      if Index = -1 then
        Index := 0;
      cbFontName.ItemIndex := Index;
    finally
      Printer.Free;
      cbFontName.Items.EndUpdate;
    end;
  except
    on E: Exception do
      memResult.Text := E.Message;
  end;
end;

procedure TfmPrinter.cbPrinterNameChange(Sender: TObject);
begin
  UpdateFontNames;
  Modified;
end;

procedure TfmPrinter.ModifiedClick(Sender: TObject);
begin
  Modified;
end;

end.

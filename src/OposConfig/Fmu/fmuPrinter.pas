unit fmuPrinter;

interface

uses
  // VCL
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Spin, ActiveX, ComObj, ExtCtrls, Printers,
  // Tnt
  TntStdCtrls, TntSysUtils, TntComCtrls,
  // Opos
  Opos, OposPtr, Oposhi, OposUtils, OposDevice, OposFptrUtils,
  // This
  untUtil, PrinterParameters, FptrTypes, FiscalPrinterDevice, FileUtils,
  WebkassaImpl, OposFiscalPrinter_1_13_Lib_TLB, SerialPort, DirectIOAPI,
  PosPrinterOA48, TntClasses, EscPrinterUtils, UsbPrinterPort;

type
  { TfmPrinter }

  TfmPrinter = class(TFptrPage)
    memResult: TMemo;
    lblResultCode: TTntLabel;
    btnTestConnection: TTntButton;
    btnPrintReceipt: TTntButton;
    PageControl1: TPageControl;
    tsCommonParams: TTntTabSheet;
    tsSocketParams: TTntTabSheet;
    lblRemoteHost: TTntLabel;
    edtRemoteHost: TTntEdit;
    seRemotePort: TSpinEdit;
    seByteTimeout: TSpinEdit;
    lblByteTimeout: TTntLabel;
    lblRemotePort: TTntLabel;
    lblPrinterName: TTntLabel;
    lblPrinterType: TTntLabel;
    lblFontName: TTntLabel;
    cbPrinterName: TTntComboBox;
    cbPrinterType: TTntComboBox;
    cbFontName: TTntComboBox;
    tsSerialParams: TTntTabSheet;
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
    Label1: TTntLabel;
    seSerialTimeout: TSpinEdit;
    lblDevicePollTime: TTntLabel;
    seDevicePollTime: TSpinEdit;
    lblLineSpacing: TTntLabel;
    seLineSpacing: TSpinEdit;
    lblRecLineChars: TTntLabel;
    lblRecLineHeight: TTntLabel;
    seRecLineChars: TSpinEdit;
    seRecLineHeight: TSpinEdit;
    lblEscPrinterType: TTntLabel;
    cbEscPrinterType: TTntComboBox;
    lblPortType: TTntLabel;
    cbPortType: TTntComboBox;
    tsUSBPort: TTabSheet;
    TntLabel1: TTntLabel;
    cbUSBPort: TTntComboBox;
    btnReadUsbDevices: TButton;
    procedure btnTestConnectionClick(Sender: TObject);
    procedure btnPrintReceiptClick(Sender: TObject);
    procedure cbPrinterTypeChange(Sender: TObject);
    procedure cbPrinterNameChange(Sender: TObject);
    procedure ModifiedClick(Sender: TObject);
    procedure cbFontNameChange(Sender: TObject);
    procedure cbEscPrinterTypeChange(Sender: TObject);
    procedure btnReadUsbDevicesClick(Sender: TObject);
  private
    procedure UpdateUsbPort;
    procedure UpdateFontNames;
    procedure UpdateDeviceNames;
    procedure UpdateBaudRates;
    procedure UpdatePortNames;
    procedure UpdateStopBits;
    procedure UpdateDataBits;
    procedure UpdateParity;
    procedure UpdatePortTypes;
    procedure UpdateFlowControl;
    procedure UpdateEscPrinterTypes;
    procedure FptrCheck(Printer: TOPOSFiscalPrinter; Code: Integer);

    function GetPortTypes: string;
    function GetEscPrinterType: string;
    function ReadFontNames(APrinterType: Integer): WideString;
    function ReadPrinterNames(APrinterType: Integer): WideString;
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

  UpdateDeviceNames;
  cbPrinterName.Text := Parameters.PrinterName;
  UpdateFontNames;
  cbFontName.Text := Parameters.FontName;

  UpdateUsbPort;
  UpdatePortNames;
  UpdateBaudRates;
  UpdateDataBits;
  UpdateStopBits;
  UpdateParity;
  UpdateFlowControl;
  UpdateEscPrinterTypes;
  cbEscPrinterType.ItemIndex := Parameters.EscPrinterType;
  UpdatePortTypes;
  cbPortType.ItemIndex := Parameters.PortType;

  edtRemoteHost.Text := Parameters.RemoteHost;
  seRemotePort.Value := Parameters.RemotePort;
  seByteTimeout.Value := Parameters.ByteTimeout;
  seSerialTimeout.Value := Parameters.SerialTimeout;
  seDevicePollTime.Value := Parameters.DevicePollTime;
  seLineSpacing.Value := Parameters.LineSpacing;
  seRecLineChars.Value := Parameters.RecLineChars;
  seRecLineHeight.Value := Parameters.RecLineHeight;
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
  Parameters.PortType := cbPortType.ItemIndex;
  Parameters.EscPrinterType := cbEscPrinterType.ItemIndex;
  Parameters.FontName := cbFontName.Text;
  Parameters.PortName := cbPortName.Text;
  Parameters.DevicePollTime := seDevicePollTime.Value;
  Parameters.LineSpacing := seLineSpacing.Value;
  Parameters.RecLineChars := seRecLineChars.Value;
  Parameters.RecLineHeight := seRecLineHeight.Value;
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
  // Usb
  Parameters.USBPort := cbUSBPort.Text;
end;

procedure TfmPrinter.FptrCheck(Printer: TOPOSFiscalPrinter; Code: Integer);
var
  Text: WideString;
  ResultCode: Integer;
  ErrorString: WideString;
  ResultCodeExtended: Integer;
begin
  if Code <> OPOS_SUCCESS then
  begin
    ResultCode := Printer.ResultCode;
    ResultCodeExtended := Printer.ResultCodeExtended;
    ErrorString := Printer.ErrorString;

    if ResultCode = OPOS_E_EXTENDED then
      Text := Tnt_WideFormat('%d, %d, %s [%s]', [ResultCode, ResultCodeExtended,
      GetResultCodeExtendedText(ResultCodeExtended), ErrorString])
    else
      Text := Tnt_WideFormat('%d, %s [%s]', [ResultCode,
        GetResultCodeText(ResultCode), ErrorString]);

    raise Exception.Create(Text);
  end;
end;

procedure TfmPrinter.btnTestConnectionClick(Sender: TObject);
var
  pData: Integer;
  pString: WideString;
  Printer: TOPOSFiscalPrinter;
begin
  EnableButtons(False);
  memResult.Clear;
  try
    UpdateObject;
    Printer := TOPOSFiscalPrinter.Create(Self);
    try
      FptrCheck(Printer, Printer.Open(DeviceName));
      try
        FptrCheck(Printer, Printer.DirectIO(DIO_READ_PRINTER_PARAMS, pData, pString));
        memResult.Text := pString;
      finally
        Printer.Close;
      end;
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
  pData: Integer;
  pString: WideString;
  Printer: TOPOSFiscalPrinter;
begin
  EnableButtons(False);
  memResult.Clear;
  try
    UpdateObject;
    Printer := TOPOSFiscalPrinter.Create(Self);
    try
      FptrCheck(Printer, Printer.Open(DeviceName));
      try
        FptrCheck(Printer, Printer.DirectIO(DIO_PRINT_TEST_RECEIPT, pData, pString));
        memResult.Text := pString;
      finally
        Printer.Close;
      end;
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
  UpdateEscPrinterTypes;
  UpdatePortTypes;
  UpdateFontNames;
  Modified;
end;

function TfmPrinter.ReadPrinterNames(APrinterType: Integer): WideString;

  function ReadPosPrinterDeviceList: WideString;
  var
    Device: TOposDevice;
    Strings: TTntStrings;
  begin
    Strings := TTntStringList.Create;
    Device := TOposDevice.Create(nil, OPOS_CLASSKEY_PTR, OPOS_CLASSKEY_PTR,
      'Opos.PosPrinter');
    try
      Device.GetDeviceNames(Strings);
      Result := Strings.Text;
    finally
      Device.Free;
      Strings.Free;
    end;
  end;

begin
  Result := '';
  case APrinterType of
    PrinterTypeOPOS: Result := ReadPosPrinterDeviceList;
    PrinterTypeWindows: Result := Printers.Printer.Printers.Text;
    PrinterTypeEscCommands: Result := Printers.Printer.Printers.Text;
  end;
end;

function TfmPrinter.ReadFontNames(APrinterType: Integer): WideString;
const
  FontNames = 'Font A (12x24)'#13#10'Font B (9x17)';
begin
  Result := '';
  case APrinterType of
    PrinterTypeOPOS: Result := '';
    PrinterTypeWindows: Result := GetRasterFonts(Printers.Printer.Handle);
    PrinterTypeEscCommands: Result := FontNames;
  end;
end;

procedure TfmPrinter.UpdateEscPrinterTypes;
var
  EscPrinterType: Integer;
begin
  EscPrinterType := cbEscPrinterType.ItemIndex;
  cbEscPrinterType.Items.BeginUpdate;
  try
    cbEscPrinterType.Items.Text := GetEscPrinterType;
    if (EscPrinterType < 0)or(EscPrinterType >= cbEscPrinterType.Items.Count) then
      EscPrinterType := 0;
    cbEscPrinterType.ItemIndex := EscPrinterType;
  finally
    cbEscPrinterType.Items.EndUpdate;
  end;
end;

function TfmPrinter.GetEscPrinterType: string;
begin
  Result := '';
  if cbPrinterType.ItemIndex  = PrinterTypeEscCommands then
  begin
    Result := 'Rongta' + CRLF + 'OA-48' + CRLF + 'Posiflex';
  end;
end;

procedure TfmPrinter.UpdateDeviceNames;
var
  Index: Integer;
begin
  try
    cbPrinterName.Items.BeginUpdate;
    try
      cbPrinterName.Items.Text := ReadPrinterNames(cbPrinterType.ItemIndex);
      Index := cbPrinterName.Items.IndexOf(Parameters.PrinterName);
      if Index = -1 then
        Index := 0;
      cbPrinterName.ItemIndex := Index;
    finally
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
begin
  try
    cbFontName.Items.BeginUpdate;
    try
      cbFontName.Items.Text := ReadFontNames(cbPrinterType.ItemIndex);
      Index := cbFontName.Items.IndexOf(Parameters.FontName);
      if Index = -1 then Index := 0;
      cbFontName.ItemIndex := Index;
    finally
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

procedure TfmPrinter.cbFontNameChange(Sender: TObject);
var
  FontName: WideString;
begin
  FontName := cbFontName.Text;
  if FontName = FontNameA then
  begin
    seRecLineChars.Value := 48;
    seRecLineHeight.Value := 24;
  end;
  if FontName = FontNameB then
  begin
    seRecLineChars.Value := 64;
    seRecLineHeight.Value := 17;
  end;
  Modified;
end;

procedure TfmPrinter.cbEscPrinterTypeChange(Sender: TObject);
begin
  Parameters.EscPrinterType := cbEscPrinterType.ItemIndex;
  UpdatePortTypes;
  UpdateFontNames;
  Modified;
end;

procedure TfmPrinter.UpdatePortTypes;
var
  PortType: Integer;
begin
  PortType := cbPortType.ItemIndex;
  cbPortType.Items.BeginUpdate;
  try
    cbPortType.Items.Text := GetPortTypes;
    if (PortType < 0)or(PortType >= cbPortType.Items.Count) then
      PortType := 0;
    cbPortType.ItemIndex := PortType;
  finally
    cbPortType.Items.EndUpdate;
  end;
end;

function TfmPrinter.GetPortTypes: string;
begin
  Result := '';
  if cbPrinterType.ItemIndex = PrinterTypeEscCommands then
  begin
    Result := Result + 'Последовательный порт' + CRLF;
    Result := Result + 'Порт принтера Windows' + CRLF;
    Result := Result + 'Сетевое подключение' + CRLF;
    Result := Result + 'USB порт';
  end;
end;

procedure TfmPrinter.btnReadUsbDevicesClick(Sender: TObject);

  function GetPrinterHardwareId: string;
  begin
    case cbEscPrinterType.ItemIndex of
      EscPrinterTypeRongta: Result := RongtaPrinterHardwareId;
      EscPrinterTypeOA48:  Result := OA48PrinterHardwareId;
      EscPrinterTypePosiflex: Result := PosiflexPrinterHardwareId;
    else
      Result := RongtaPrinterHardwareId;
    end;
  end;

var
  i: Integer;
  Device: TUsbDevice;
  Devices: TUsbDevices;
begin
  cbUSBPort.Items.BeginUpdate;
  try
    cbUSBPort.Items.Clear;

    Devices := ReadUsbDevices(GetPrinterHardwareId);
    for i := Low(Devices) to High(Devices) do
    begin
      Device := Devices[i];
      cbUSBPort.Items.Add(Device.Path);
    end;
    if cbUSBPort.Items.Count > 0 then
      cbUSBPort.ItemIndex := 0;
  finally
    cbUSBPort.Items.EndUpdate;
  end;
end;

procedure TfmPrinter.UpdateUsbPort;
begin
  cbUSBPort.Items.BeginUpdate;
  try
    cbUSBPort.Items.Clear;
    cbUSBPort.Items.Add(Parameters.USBPort);
    cbUSBPort.ItemIndex := 0;
  finally
    cbUSBPort.Items.EndUpdate;
  end;
end;

end.



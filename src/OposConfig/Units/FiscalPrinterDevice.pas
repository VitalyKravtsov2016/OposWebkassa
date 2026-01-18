unit FiscalPrinterDevice;

interface

uses
  // Opos
  OposDevice,
  // This
  untPages, FptrTypes, PrinterParameters, PrinterParametersReg, fmuPages,
  LogFile, ReceiptTemplate;

type
  TFptrPage = class;

  TFptrPageClass = class of TFptrPage;

  { TFiscalPrinterDevice }

  TFiscalPrinterDevice = class(TOposDevice)
  private
    FLogger: ILogFile;
    FTemplate: TReceiptTemplate;
    FParameters: TPrinterParameters;

    procedure AddPage(Pages: TfmPages; PageClass: TFptrPageClass);
  public
    constructor CreateDevice(AOwner: TOposDevices);
    destructor Destroy; override;

    procedure SetDefaults; override;
    procedure SaveParams; override;
    procedure ShowDialog; override;
    procedure UpdateObject;

    property Logger: ILogFile read FLogger;
    property Template: TReceiptTemplate read FTemplate;
    property Parameters: TPrinterParameters read FParameters;
  end;

  { TFptrPage }

  TFptrPage = class(TPage)
  private
    FDevice: TFiscalPrinterDevice;
    function GetTemplate: TReceiptTemplate;
  public
    function GetLogger: ILogFile;
    function GetDeviceName: WideString;
    function GetParameters: TPrinterParameters;
  public
    property Logger: ILogFile read GetLogger;
    property DeviceName: WideString read GetDeviceName;
    property Template: TReceiptTemplate read GetTemplate;
    property Parameters: TPrinterParameters read GetParameters;

    property Device: TFiscalPrinterDevice read FDevice write FDevice;
  end;

implementation

uses
  fmuFptrConnection, fmuPrinter, fmuFptrLog, fmuFptrHeader, fmuFptrTrailer,
  fmuFptrVatRate, fmuFptrPayType, fmuFptrMiscParams, fmuTranslation,
  fmuFptrBarcode, fmuFptrReceipt, fmuFptrUnitName;

{ TFiscalPrinterDevice }

constructor TFiscalPrinterDevice.CreateDevice(AOwner: TOposDevices);
begin
  inherited Create(AOwner, 'FiscalPrinter', 'FiscalPrinter', FiscalPrinterProgID);
  FLogger := TLogFile.Create;
  FTemplate := TReceiptTemplate.Create(FLogger);
  FParameters := TPrinterParameters.Create(FLogger);
end;

destructor TFiscalPrinterDevice.Destroy;
begin
  FLogger := nil;
  FTemplate.Free;
  FParameters.Free;
  inherited Destroy;
end;

procedure TFiscalPrinterDevice.SetDefaults;
begin
  Parameters.SetDefaults;
  Template.SetDefaults;
end;

procedure TFiscalPrinterDevice.SaveParams;
begin
  SaveParametersReg(Parameters, DeviceName, Logger);
  Template.Save(DeviceName);
end;

procedure TFiscalPrinterDevice.AddPage(Pages: TfmPages; PageClass: TFptrPageClass);
var
  Page: TFptrPage;
begin
  Page := PageClass.Create(Pages);
  Page.Device := Self;
  Pages.Add(Page);
end;

procedure TFiscalPrinterDevice.ShowDialog;
var
  fm: TfmPages;
begin

  fm := TfmPages.Create(nil);
  try
    fm.Device := Self;
    fm.Caption := 'Fiscal printer';
    LoadParametersReg(Parameters, DeviceName, Logger);
    Template.Load(DeviceName);

    UpdateObject;
    Logger.Debug('LOG START');
    Parameters.WriteLogParameters;
    //
    AddPage(fm, TfmFptrConnection);
    AddPage(fm, TfmPrinter);
    AddPage(fm, TfmFptrLog);
    AddPage(fm, TfmFptrHeader);
    AddPage(fm, TfmFptrTrailer);
    AddPage(fm, TfmFptrPayType);
    AddPage(fm, TfmFptrVatRate);
    AddPage(fm, TfmFptrUnitName);
    AddPage(fm, TfmTranslation);
    AddPage(fm, TfmFptrBarcode);
    AddPage(fm, TfmFptrReceipt);
    AddPage(fm, TfmFptrMiscParams);

    fm.Init;
    fm.UpdatePage;
    fm.btnApply.Enabled := False;
    fm.ShowModal;
  finally
    fm.Free;
  end;
end;

procedure TFiscalPrinterDevice.UpdateObject;
begin
  Logger.MaxCount := Parameters.LogMaxCount;
  Logger.Enabled := Parameters.LogFileEnabled;
  Logger.FilePath := Parameters.LogFilePath;
  Logger.DeviceName := 'OposConfig';
end;

{ TFptrPage }

function TFptrPage.GetDeviceName: WideString;
begin
  Result := FDevice.DeviceName;
end;

function TFptrPage.GetLogger: ILogFile;
begin
  Result := FDevice.Logger;
end;

function TFptrPage.GetParameters: TPrinterParameters;
begin
  Result := FDevice.Parameters;
end;

function TFptrPage.GetTemplate: TReceiptTemplate;
begin
  Result := FDevice.Template;
end;

end.


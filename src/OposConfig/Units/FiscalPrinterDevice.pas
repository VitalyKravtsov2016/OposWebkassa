unit FiscalPrinterDevice;

interface

uses
  // Opos
  OposDevice,
  // This
  untPages, FptrTypes, PrinterParameters, PrinterParametersX,
  fmuPages, LogFile, DriverContext;

type
  TFptrPage = class;

  TFptrPageClass = class of TFptrPage;

  { TFiscalPrinterDevice }

  TFiscalPrinterDevice = class(TOposDevice)
  private
    FContext: TDriverContext;
    procedure AddPage(Pages: TfmPages; PageClass: TFptrPageClass);
    function GetLogger: ILogFile;
    function GetParameters: TPrinterParameters;
  public
    constructor CreateDevice(AOwner: TOposDevices);
    destructor Destroy; override;
    procedure SetDefaults; override;
    procedure SaveParams; override;
    procedure ShowDialog; override;
    property Logger: ILogFile read GetLogger;
    property Parameters: TPrinterParameters read GetParameters;
  end;

  { TFptrPage }

  TFptrPage = class(TPage)
  private
    FDevice: TFiscalPrinterDevice;
  public
    function GetParameters: TPrinterParameters;
    function GetDeviceName: WideString;
    function GetLogger: ILogFile;
  public
    property Logger: ILogFile read GetLogger;
    property DeviceName: WideString read GetDeviceName;
    property Parameters: TPrinterParameters read GetParameters;
    property Device: TFiscalPrinterDevice read FDevice write FDevice;
  end;

implementation

uses
  fmuFptrConnection, fmuPrinter, fmuFptrLog, fmuFptrHeader, fmuFptrTrailer,
  fmuFptrVatRate, fmuFptrPayType, fmuFptrMiscParams, fmuTranslation;

{ TFiscalPrinterDevice }

constructor TFiscalPrinterDevice.CreateDevice(AOwner: TOposDevices);
begin
  inherited Create(AOwner, 'FiscalPrinter', 'FiscalPrinter', FiscalPrinterProgID);
  FContext := TDriverContext.Create;
end;

destructor TFiscalPrinterDevice.Destroy;
begin
  FContext.Free;
  inherited Destroy;
end;

procedure TFiscalPrinterDevice.SetDefaults;
begin
  Parameters.SetDefaults;
end;

procedure TFiscalPrinterDevice.SaveParams;
begin
  SaveParameters(Parameters, DeviceName, Logger);
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
    LoadParameters(Parameters, DeviceName, Logger);
    //
    AddPage(fm, TfmFptrConnection);
    AddPage(fm, TfmPrinter);
    AddPage(fm, TfmFptrLog);
    AddPage(fm, TfmFptrHeader);
    AddPage(fm, TfmFptrTrailer);
    AddPage(fm, TfmFptrPayType);
    AddPage(fm, TfmFptrVatRate);
    AddPage(fm, TfmTranslation);
    AddPage(fm, TfmFptrMiscParams);

    fm.Init;
    fm.UpdatePage;
    fm.btnApply.Enabled := False;
    fm.ShowModal;
  finally
    fm.Free;
  end;
end;

function TFiscalPrinterDevice.GetParameters: TPrinterParameters;
begin
  Result := FContext.Parameters;
end;

function TFiscalPrinterDevice.GetLogger: ILogFile;
begin
  Result := FContext.Logger;
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

end.


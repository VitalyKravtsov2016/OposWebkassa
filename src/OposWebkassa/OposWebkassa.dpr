library OposWebkassa;

uses
  Opos in '..\Opos\Opos.pas',
  Oposhi in '..\Opos\Oposhi.pas',
  OposFptr in '..\Opos\OposFptr.pas',
  OposUtils in '..\Opos\OposUtils.pas',
  OposFptrhi in '..\Opos\OposFptrhi.pas',
  OposException in '..\Opos\OposException.pas',
  WException in '..\Shared\WException.pas',
  oleFiscalPrinter in 'Units\oleFiscalPrinter.pas',
  LogFile in '..\Shared\LogFile.pas',
  OposFptrUtils in '..\Opos\OposFptrUtils.pas',
  WebkassaImpl in 'Units\WebkassaImpl.pas',
  OposWebkassaLib_TLB in 'OposWebkassaLib_TLB.pas',
  OposServiceDevice19 in '..\Opos\OposServiceDevice19.pas',
  OposEvents in '..\Opos\OposEvents.pas',
  OposSemaphore in '..\Opos\OposSemaphore.pas',
  NotifyThread in '..\Shared\NotifyThread.pas',
  VersionInfo in '..\Shared\VersionInfo.pas',
  OposEventsRCS in '..\Opos\OposEventsRCS.pas',
  DebugUtils in '..\Shared\DebugUtils.pas',
  DriverError in '..\Shared\DriverError.pas',
  WebkassaClient in 'Units\WebkassaClient.pas',
  JsonUtils in '..\Shared\JsonUtils.pas',
  FiscalPrinterState in 'units\FiscalPrinterState.pas',
  CustomReceipt in 'units\CustomReceipt.pas',
  TextItem in 'units\TextItem.pas',
  MathUtils in 'units\MathUtils.pas',
  NonfiscalDoc in 'units\NonfiscalDoc.pas',
  ServiceVersion in '..\Shared\ServiceVersion.pas',
  DeviceService in '..\Shared\DeviceService.pas',
  CashOutReceipt in 'units\CashOutReceipt.pas',
  CashInReceipt in 'units\CashInReceipt.pas',
  OposPOSPrinter_CCO_TLB in '..\Opos\OposPOSPrinter_CCO_TLB.pas',
  PrinterParameters in '..\Shared\PrinterParameters.pas',
  FileUtils in '..\Shared\FileUtils.pas',
  PrinterParametersX in '..\Shared\PrinterParametersX.pas',
  PrinterParametersIni in '..\Shared\PrinterParametersIni.pas',
  TntIniFiles in '..\Shared\TntIniFiles.pas',
  SmIniFile in '..\Shared\SmIniFile.pas',
  StringUtils in '..\Shared\StringUtils.pas',
  RegExpr in '..\Shared\RegExpr.pas',
  SalesReceipt in 'units\SalesReceipt.pas',
  ReceiptItem in 'units\ReceiptItem.pas',
  OposPtr in '..\Opos\OposPtr.pas',
  OposEsc in '..\Opos\OposEsc.pas',
  TextDocument in 'units\TextDocument.pas',
  PrinterParametersReg in '..\Shared\PrinterParametersReg.pas',
  PrinterLines in 'units\PrinterLines.pas',
  ComServ in '..\Common\ComServ.pas',
  uLkJSON in '..\Shared\uLkJSON.pas',
  VatRate in '..\Shared\VatRate.pas',
  OposPtrUtils in '..\Opos\OposPtrUtils.pas',
  OposPtrhi in '..\Opos\OposPtrhi.pas',
  OposFiscalPrinter_CCO_TLB in '..\Opos\OposFiscalPrinter_CCO_TLB.pas',
  POSPrinterLog in '..\Opos\POSPrinterLog.pas';

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer;

{$R *.TLB}

{$R *.RES}

begin
end.

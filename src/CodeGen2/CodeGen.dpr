program CodeGen;

uses
  Forms,
  fmuMain in 'Fmu\fmuMain.pas' {fmMain},
  untConvert in 'Units\untConvert.pas',
  DrvFRLib_TLB in 'Units\DrvFRLib_TLB.pas',
  StringUtils in '..\Shared\StringUtils.pas',
  RegExpr in '..\Shared\RegExpr.pas',
  FileUtils in '..\Shared\FileUtils.pas',
  OposPOSPrinter_CCO_TLB in '..\Opos\OposPOSPrinter_CCO_TLB.pas',
  LogFile in '..\Shared\LogFile.pas',
  WException in '..\Shared\WException.pas',
  PosPrinterLogWrap in 'Bin\PosPrinterLogWrap.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.

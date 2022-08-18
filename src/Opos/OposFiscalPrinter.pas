unit OposFiscalPrinter;

interface

uses
  // VCL
  SysUtils, Variants, ComObj, Forms,
  // This
  Opos, OposUtils, OposFiscalPrinter_1_13_Lib_TLB;

const
  FiscalPrinterProgID = 'OposShtrih.FiscalPrinter';


procedure FreeFiscalPrinter;
procedure Check(AResultCode: Integer);
function FiscalPrinter: TOPOSFiscalPrinter;

implementation

procedure Check(AResultCode: Integer);
begin
  if AResultCode <> OPOS_SUCCESS then
  begin
    raise Exception.CreateFmt('%d, %s, %d, %s', [
      AResultCode, GetResultCodeText(AResultCode),
      FiscalPrinter.ResultCodeExtended, FiscalPrinter.ErrorString]);
  end;
end;

var
  FFiscalPrinter: TOPOSFiscalPrinter;

procedure FreeFiscalPrinter;
begin
  if FFiscalPrinter <> nil then
  begin
    FFiscalPrinter.Free;
    FFiscalPrinter := nil;
  end;
end;

function FiscalPrinter: TOPOSFiscalPrinter;
begin
  if  FFiscalPrinter = nil then
  begin
    try
      FFiscalPrinter := TOPOSFiscalPrinter.Create(nil);
    except
      on E: Exception do
      begin
        E.Message := 'Error creating object FiscalPrinter:'#13#10 +
          E.Message;
        raise;
      end;
    end;
  end;
  Result := FFiscalPrinter;
end;

end.

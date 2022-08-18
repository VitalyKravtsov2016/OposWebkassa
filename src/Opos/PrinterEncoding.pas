unit PrinterEncoding;

interface

uses
  // This
  StringUtils, PrinterParameters;

function DecodeText(Encoding: Integer; const Text: WideString): WideString;
function EncodeText(Encoding: Integer; const Text: WideString): WideString;

implementation

function DecodeText(Encoding: Integer; const Text: WideString): WideString;
begin
  Result := Text;
end;

function EncodeText(Encoding: Integer; const Text: WideString): WideString;
begin
  Result := Text;
end;

end.

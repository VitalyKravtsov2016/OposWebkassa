unit DebugUtils;

interface

uses
  // VCL
  Windows;

procedure ODS(const S: WideString);

implementation

procedure ODS(const S: WideString);
begin
  OutputDebugStringW(PWideChar(S));
{$IFDEF DEBUG}
{$ENDIF}
end;

end.




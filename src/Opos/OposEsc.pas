unit OposEsc;

interface

uses
  // VCL
  SysUtils, 
  // This
  RegExpr;

const
  GS = #$1D;
  ESC = #$1B;

  ESC_Bold              = ESC + '|bC';
  ESC_Normal            = ESC + '|1C'; // Prints normal size.
  ESC_DoubleWide        = ESC + '|2C'; // Prints double-wide characters.
  ESC_DoubleHigh        = ESC + '|3C'; // Prints double-high characters.
  ESC_DoubleHighWide    = ESC + '|4C'; // Prints double-high/double-wide characters.


  // Cuts receipt paper. The character ‘#’ is replaced by an
  // ASCII decimal string telling the percentage cut desired. If
  // ‘#’ is omitted, then a full cut is performed. For example:
  // The C string “\x1B|75P” requests a 75% partial cut.

  ESCPaperFullCut = ESC + '|P';
  ESCPaper75Cut = ESC + '|75P';
  ESCPaper50Cut = ESC + '|50P';

function EscGetFontIndex(const Text: string; var FontIndex: Integer): Boolean;

implementation

function EscGetFontIndex(const Text: string; var FontIndex: Integer): Boolean;
const
  RegExprFontIndex = '\'#$1B'\|[0-9]{0,3}fT';
var
  R: TRegExpr;
begin
  R := TRegExpr.Create;
  try
    R.Expression := RegExprFontIndex;
    Result := R.Exec(Text);
    if Result then
    begin
      R.Expression := '[0-9]{0,3}';
      Result := R.Exec(Text);
      if Result then
      begin
        FontIndex := StrToInt(R.Match[0]);
      end;
    end;
  finally
    R.Free;
  end;
end;

end.

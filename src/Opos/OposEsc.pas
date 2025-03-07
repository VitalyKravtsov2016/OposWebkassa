unit OposEsc;

interface

uses
  // VCL
  SysUtils,
  // This
  RegExpr;

type
  { TEscType }

  TEscType = (etSelectFont, etPartialCut);

  { TEscTag }

  TEscTag = record
    TagType: TEscType;
    Number: Integer;
  end;
  TEscTags = array of TEscTag;

const
  GS = #$1D;
  ESC = #$1B;

///////////////////////////////////////////////////////////////////////////////
// Paper cut ESC |#P
//
// Cuts receipt paper. The character ‘#’ is replaced by an
// ASCII decimal string telling the percentage cut desired. If
// ‘#’ is omitted, then a full cut is performed. For example:
// The C string “\x1B|75P” requests a 75% partial cut.

  ESCPaperFullCut = ESC + '|P';
  ESCPaper75Cut   = ESC + '|75P';
  ESCPaper50Cut   = ESC + '|50P';

  EscRegexPaperCut = ESC + '|d+P';

///////////////////////////////////////////////////////////////////////////////
// Feed and Paper cut ESC |#fP
//
// Cuts receipt paper, after feeding the paper by the
// RecLinesToPaperCut lines. The character ‘#’ is defined
// by the “Paper cut” escape sequence.

(*
Feed, Paper cut, and Stamp ESC |#sP
Cuts and stamps receipt paper, after feeding the paper by
the RecLinesToPaperCut lines. The character ‘#’ is
defined by the “Paper cut” escape sequence.
Fire stamp ESC |sL Fires the stamp solenoid, which usually contains a
graphical store emblem.
Print bitmap ESC |#B Prints the pre-stored bitmap. The character ‘#’ is replaced
by the bitmap number. See setBitmap method.
Print top logo ESC |tL Prints the pre-stored top logo.
Print bottom logo ESC |bL Prints the pre-stored bottom logo.
Feed lines ESC |#lF
Feed the paper forward by lines. The character ‘#’ is
replaced by an ASCII decimal string telling the number of
lines to be fed. If ‘#’ is omitted, then one line is fed.
Feed units ESC |#uF
Feed the paper forward by mapping mode units. The
character ‘#’ is replaced by an ASCII decimal string
telling the number of units to be fed. If ‘#’ is omitted, then
one unit is fed.
Feed reverse ESC |#rF
Feed the paper backward. The character ‘#’ is replaced by
an ASCII decimal string telling the number of lines to be
fed. If ‘#’ is omitted, then one line is fed.
Pass through embedded data
(See a
 below.)
a. This escape sequence is only available in Version 1.7 and later.
ESC |#E
Send the following # characters of data through to the
hardware without modifying it. The character '#' is
replaced by an ASCII decimal string telling the number of
bytes following the escape sequence that should be
passed through as-is to the hardware.
Print in-line barcode
(See b below.)
b. This escape sequence is only available in Version 1.10 and later.
ESC |#R
Prints the defined barcode in-line. The character ‘#’ is the
number of characters following the R to use in the
definition of the characteristics of the barcode to be
printed. See details below.
*)

  ESC_Normal            = ESC + '|N';   // Normal font parameters
  ESC_Bold              = ESC + '|bC';
  ESC_NormalSize        = ESC + '|1C';  // Prints normal size.
  ESC_DoubleWide        = ESC + '|2C';  // Prints double-wide characters.
  ESC_DoubleHigh        = ESC + '|3C';  // Prints double-high characters.
  ESC_DoubleHighWide    = ESC + '|4C';  // Prints double-high/double-wide characters.


const
  RegExprFontIndex = '\'#$1B'\|[0-9]{0,3}fT';

function GetEscTags(const Text: string; var Tags: TEscTags): string;
function EscGetFontIndex(const Text: string; var FontIndex: Integer): Boolean;

implementation

function GetEscTags(const Text: string; var Tags: TEscTags): string;
begin

end;

function EscGetFontIndex(const Text: string; var FontIndex: Integer): Boolean;
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

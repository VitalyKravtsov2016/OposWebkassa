unit OposEsc;

interface

uses
  // VCL
  SysUtils,
  // This
  RegExpr, DebugUtils;

type
  { TOposBarcode }

  TOposBarcode = record
    Symbology: Integer;
    Height: Integer;
    Width: Integer;
    Alignment: Integer;
    TextPosition: Integer;
    Data: string;
  end;

  { TTagType }

  TTagType = (
    ttText,
    ttPaperCut,
    ttFeedCut,
    ttFeedCutStamp,
    ttFireStamp,
    ttPrintBitmap,
    ttPrintTLogo,
    ttPrintBLogo,
    ttFeedLines,
    ttFeedUnits,
    ttFeedReverse,
    ttPassThrough,
    ttPrintBarcode,
    ttFontIndex,
    ttBold,
    ttNoBold,
    ttUnderline,
    ttNoUnderline,
    ttItalic,
    ttNoItalic,
    ttSelectColor,
    ttReverseVideo,
    ttNoReverseVideo,
    ttShading,
    ttNormalSize,
    ttDoubleWide,
    ttDoubleHigh,
    ttDoubleHighWide,
    ttScaleHorizontally,
    ttScaleVertically,
    ttAlignCenter,
    ttAlignRight,
    ttAlignLeft,
    ttStrikeThrough,
    ttNoStrikeThrough,
    ttNormal
  );

  { TEscTag }

  TEscTag = record
    Text: string;
    Number: Integer;
    TagType: TTagType;
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
  ESCPaper75Cut = ESC + '|75P';
  ESCPaper50Cut = ESC + '|50P';

  /////////////////////////////////////////////////////////////////////////////
  // Paper cut ESC |#P
  // Cuts receipt paper. The character ‘#’ is replaced by an
  // ASCII decimal string telling the percentage cut desired. If
  // ‘#’ is omitted, then a full cut is performed. For example:
  // The C string “\x1B|75P” requests a 75% partial cut.

  RegExprPaperCut = '\'#$1B'\|[0-9]{0,3}P';

  /////////////////////////////////////////////////////////////////////////////
  // Feed and Paper cut ESC |#fP
  //
  // Cuts receipt paper, after feeding the paper by the
  // RecLinesToPaperCut lines. The character ‘#’ is defined
  // by the “Paper cut” escape sequence.

  RegExprFeedCut = '\'#$1B'\|[0-9]{1,3}fP';

  /////////////////////////////////////////////////////////////////////////////
  // Feed, Paper cut, and Stamp ESC |#sP
  //
  // Cuts and stamps receipt paper, after feeding the paper by
  // the RecLinesToPaperCut lines. The character ‘#’ is
  // defined by the “Paper cut” escape sequence.
  // Fire stamp ESC |sL Fires the stamp solenoid, which usually contains a
  // graphical store emblem.

  RegExprFeedCutStamp = '\'#$1B'\|[0-9]{1,3}sP';

  /////////////////////////////////////////////////////////////////////////////
  // Fire stamp ESC |sL Fires the stamp solenoid,
  // which usually contains a graphical store emblem.

  RegExprFireStamp      = '\'#$1B'\|sL';

  /////////////////////////////////////////////////////////////////////////////
  // Print bitmap ESC |#B
  //
  // Prints the pre-stored bitmap. The character ‘#’ is replaced
  // by the bitmap number. See setBitmap method.
  // Print top logo ESC |tL Prints the pre-stored top logo.
  // Print bottom logo ESC |bL Prints the pre-stored bottom logo.

  RegExprPrintBitmap = '\'#$1B'\|[0-9]{1,2}B';

  /////////////////////////////////////////////////////////////////////////////
  // Print top logo
  // ESC |tL
  // Prints the pre-stored top logo.

  RegExprPrintTLogo     = '\'#$1B'\|tL';

  /////////////////////////////////////////////////////////////////////////////
  // Print bottom logo
  // ESC |bL
  // Prints the pre-stored bottom logo.

  RegExprPrintBLogo    = '\'#$1B'\|bL';

  /////////////////////////////////////////////////////////////////////////////
  // Feed lines ESC |#lF
  //
  // Feed the paper forward by lines. The character ‘#’ is
  // replaced by an ASCII decimal string telling the number of
  // lines to be fed. If ‘#’ is omitted, then one line is fed.

  RegExprFeedLines = '\'#$1B'\|[0-9]{1,2}lF';

  /////////////////////////////////////////////////////////////////////////////
  // Feed units ESC |#uF
  //
  // Feed the paper forward by mapping mode units. The
  // character ‘#’ is replaced by an ASCII decimal string
  // telling the number of units to be fed. If ‘#’ is omitted, then
  // one unit is fed.

  RegExprFeedUnits = '\'#$1B'\|[0-9]{1,2}uF';

  /////////////////////////////////////////////////////////////////////////////
  // Feed reverse ESC |#rF
  // Feed the paper backward. The character ‘#’ is replaced by
  // an ASCII decimal string telling the number of lines to be
  // fed. If ‘#’ is omitted, then one line is fed.

  RegExprFeedReverse = '\'#$1B'\|[0-9]{1,2}rF';

  /////////////////////////////////////////////////////////////////////////////
  // Pass through embedded data
  // ESC |#E
  //
  // Send the following # characters of data through to the
  // hardware without modifying it. The character '#' is
  // replaced by an ASCII decimal string telling the number of
  // bytes following the escape sequence that should be
  // passed through as-is to the hardware.

  RegExprPassThrough = '\'#$1B'\|[0-9]{1,2}E';

  /////////////////////////////////////////////////////////////////////////////
  // Print in-line barcode
  // ESC |#R
  // Prints the defined barcode in-line. The character ‘#’ is the
  // number of characters following the R to use in the
  // definition of the characteristics of the barcode to be
  // printed. See details below.

  RegExprPrintBarcode = '\'#$1B'\|[0-9]{1,2}R';

  /////////////////////////////////////////////////////////////////////////////
  // Font typeface selection ESC |#fT
  // Selects a new typeface for the following
  // data. Values for the character ‘#’ are:
  // 0 = Default typeface.
  // 1 = Select first typeface from the
  // FontTypefaceList property.
  // 2 = Select second typeface from the
  // FontTypefaceList property.
  // And so on.

  RegExprFontIndex = '\'#$1B'\|[0-9]{0,3}fT';

  /////////////////////////////////////////////////////////////////////////////
  // Bold ESC |(!)bC
  // Prints in bold or double-strike.
  // If ‘!’ is specified then bold is disabled

  ESC_Bold = ESC + '|bC';
  ESC_NoBold = ESC + '|\!bC';

  RegExprBold = '\'#$1B'\|bC';
  RegExprNoBold = '\'#$1B'\|\!bC';

  /////////////////////////////////////////////////////////////////////////////
  // Underline ESC |(!)#uC
  // Prints with underline. The character ‘#’ is
  // replaced by an ASCII decimal string telling the
  // thickness of the underline in printer dot units. If
  // ‘#’ is omitted, then a printer-specific default
  // thickness is used. If ‘!’ is specified then
  // underline mode is switched off

  ESC_Underline = ESC + '|uC';
  ESC_NoUnderline = ESC + '|!uC';

  RegExprUnderline = '\'#$1B'\|uC';
  RegExprNoUnderline = '\'#$1B'\|\!uC';

  /////////////////////////////////////////////////////////////////////////////
  // Italic ESC |(!)iC
  // Prints in italics. If ‘!’ is specified then italic is disabled

  ESC_Italic = ESC + '|iC';
  ESC_NoItalic = ESC + '|!iC';

  RegExprItalic = '\'#$1B'\|iC';
  RegExprNoItalic = '\'#$1B'\|\!iC';

  /////////////////////////////////////////////////////////////////////////////
  // Alternate color (Custom)
  // ESC |#rC
  // Prints using an alternate custom color. The
  // character ‘#’ is replaced by an ASCII decimal
  // string indicating the desired color. The value of
  // the decimal string is equal to the value of the
  // cartridge constant used in the printer device
  // properties. If ‘#’ is omitted, then the secondary
  // color (Custom Color 1) is selected. Custom
  // Color 1 is usually red.

  RegExprSelectColor = '\'#$1B'\|[0-9]{1,2}rC';

  /////////////////////////////////////////////////////////////////////////////
  // Reverse video
  // ESC |(!)rvC
  // Prints in a reverse video format. If ‘!’ is
  // specified then reverse video is disabled

  EscReverseVideo = ESC + '|rvC';
  EscNoReverseVideo = ESC + '|!rvC';

  RegExprReverseVideo = '\'#$1B'\|rvC';
  RegExprNoReverseVideo = '\'#$1B'\|\!rvC';

  /////////////////////////////////////////////////////////////////////////////
  // Shading
  // ESC |#sC
  // Prints in a shaded manner. The character ‘#’ is
  // replaced by an ASCII decimal string telling the
  // percentage shading desired. If ‘#’ is omitted,
  // then a printer-specific default level of shading is used.

  RegExprShading = '\'#$1B'\|[0-9]{0,2}sC';

  /////////////////////////////////////////////////////////////////////////////
  // Single high and wide
  // ESC |1C
  // Prints normal size.

  ESC_NormalSize = ESC + '|1C';
  RegExprNormalSize = '\'#$1B'\|1C';

  /////////////////////////////////////////////////////////////////////////////
  // Double wide
  // ESC |2C
  // Prints double-wide characters.

  ESC_DoubleWide = ESC + '|2C';
  RegExprDoubleWide = '\'#$1B'\|2C';

  /////////////////////////////////////////////////////////////////////////////
  // Double high
  // ESC |3C
  // Prints double-high characters.

  ESC_DoubleHigh = ESC + '|3C';
  RegExprDoubleHigh = '\'#$1B'\|3C';

  /////////////////////////////////////////////////////////////////////////////
  // Double high and wide
  // ESC |4C
  // Prints double-high/double-wide characters.

  ESC_DoubleHighWide = ESC + '|4C';
  RegExprDoubleHighWide = '\'#$1B'\|4C';

  /////////////////////////////////////////////////////////////////////////////
  // Scale horizontally
  // ESC |#hC
  // Prints with the width scaled ‘#’ times the
  // normal size, where ‘#’ is replaced by an ASCII decimal string.

  RegExprScaleHorizontally = '\'#$1B'\|[0-9]{1,2}hC';

  /////////////////////////////////////////////////////////////////////////////
  // Scale vertically
  // ESC |#vC
  // Prints with the height scaled ‘#’ times the
  // normal size, where ‘#’ is replaced by an ASCII decimal string.

  RegExprScaleVertically = '\'#$1B'\|[0-9]{1,2}vC';

  /////////////////////////////////////////////////////////////////////////////
  // Center
  // ESC |cA
  // Aligns following text in the center.

  EscAlignCenter = ESC + '|cA';
  RegExprAlignCenter = '\'#$1B'\|cA';

  /////////////////////////////////////////////////////////////////////////////
  // Right justify
  // ESC |rA
  // Aligns following text at the right.

  EscAlignRight = ESC + '|rA';
  RegExprAlignRight = '\'#$1B'\|rA';

  /////////////////////////////////////////////////////////////////////////////
  // Left justify (see a below)
  // ESC |lA
  // Aligns following text at the left.

  EscAlignLeft = ESC + '|lA';
  RegExprAlignLeft = '\'#$1B'\|lA';

  /////////////////////////////////////////////////////////////////////////////
  // Strike-through
  // ESC |(!)#stC
  // Prints in strike-through mode. The character ‘#’ is replaced
  // by an ASCII decimal string telling the thickness of the strike-through in
  // printer dot units. If ‘#’ is omitted, then a printer-specific default
  // thickness is used. If ‘!’ is specified then strike-through mode is
  // switched off.

  RegExprStrikeThrough = '\'#$1B'\|[0-9]{0,2}stC';
  RegExprNoStrikeThrough = '\'#$1B'\|\!stC';

  /////////////////////////////////////////////////////////////////////////////
  // Normal
  // ESC |N
  // Restores printer characteristics to normal condition.

  ESC_Normal = ESC + '|N';
  RegExprNormal = '\'#$1B'\|N';

function GetTagNumber(const S: string): Integer;
function GetEscTags(const Text: string): TEscTags;
function EscGetFontIndex(const Text: string; var FontIndex: Integer): Boolean;
function GetEscTag(var Text: string; var Tag: TEscTag): Boolean;
function ParseOposBarcode(const S: string): TOposBarcode;

implementation

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

function GetEscTags(const Text: string): TEscTags;
const
  EscPrefix = #$1B'|';
var
  S: string;
  P: Integer;
  Tag: TEscTag;
begin
  S := Text;
  SetLength(Result, 0);
  repeat
    P := Pos(EscPrefix, S);
    if P = 0 then
    begin
      Tag.Text := S;
      Tag.Number := 0;
      Tag.TagType := ttText;
      SetLength(Result, Length(Result) + 1);
      Result[Length(Result)-1] := Tag;
      Break;
    end;
    if P > 1 then
    begin
      Tag.Text := Copy(S, 1, P-1);
      Tag.Number := 0;
      Tag.TagType := ttText;

      SetLength(Result, Length(Result) + 1);
      Result[Length(Result)-1] := Tag;
      S := Copy(S, P, Length(S));
    end;
    if GetEscTag(S, Tag) then
    begin
      SetLength(Result, Length(Result) + 1);
      Result[Length(Result)-1] := Tag;
    end else
    begin
      Break;
    end;
  until P = 0;
end;

function GetTagNumber(const S: string): Integer;
const
  RegExprNumber = '[0-9]{0,3}';
var
  R: TRegExpr;
begin
  Result := 0;
  R := TRegExpr.Create;
  try
    R.InputString := S;
    R.Expression := RegExprNumber;
    if R.ExecPos(1) then
      Result := StrToIntDef(R.Match[0], 0);
  finally
    R.Free;
  end;
end;

function GetEscTag(var Text: string; var Tag: TEscTag): Boolean;

const
  RegExprs: array [0..34] of string = (
    RegExprPaperCut,
    RegExprFeedCut,
    RegExprFeedCutStamp,
    RegExprFireStamp,
    RegExprPrintBitmap,
    RegExprPrintTLogo,
    RegExprPrintBLogo,
    RegExprFeedLines,
    RegExprFeedUnits,
    RegExprFeedReverse,
    RegExprPassThrough,
    RegExprPrintBarcode,
    RegExprFontIndex,
    RegExprBold,
    RegExprNoBold,
    RegExprUnderline,
    RegExprNoUnderline,
    RegExprItalic,
    RegExprNoItalic,
    RegExprSelectColor,
    RegExprReverseVideo,
    RegExprNoReverseVideo,
    RegExprShading,
    RegExprNormalSize,
    RegExprDoubleWide,
    RegExprDoubleHigh,
    RegExprDoubleHighWide,
    RegExprScaleHorizontally,
    RegExprScaleVertically,
    RegExprAlignCenter,
    RegExprAlignRight,
    RegExprAlignLeft,
    RegExprStrikeThrough,
    RegExprNoStrikeThrough,
    RegExprNormal
  );

var
  i: Integer;
  R: TRegExpr;
begin
  ODS('GetEscTags: ' + Text);

  R := TRegExpr.Create;
  try
    for i := 0 to Length(RegExprs)-1 do
    begin
      R.Expression := RegExprs[i];
      R.InputString := Text;
      Result := R.ExecPos(1);
      if Result then
      begin
        Result := R.MatchPos[0] = 1;
        if Result then
        begin
          ODS('RegExprs: ' + RegExprs[i]);
          ODS('MatchPos[0]: ' + IntToStr(R.MatchPos[0]));
          ODS('MatchLen[0]: ' + IntToStr(R.MatchLen[0]));


          Tag.Text := '';
          Tag.TagType := TTagType(i + 1);
          Tag.Number := GetTagNumber(Text);
          Text := Copy(Text, R.MatchPos[0] + R.MatchLen[0], Length(Text));
          if Tag.TagType = ttPrintBarcode then
          begin
            Tag.Text := Copy(Text, 1, Tag.Number);
            Text := Copy(Text, Tag.Number+1, Length(Text));
          end;
          Break;
        end;
      end;
    end;
  finally
    R.Free;
  end;
end;

///////////////////////////////////////////////////////////////////////////////
// s symbology
// h height
// w width
// a alignment
// t human readable text position
// d start of data
// e end of sequence

function ParseOposBarcode(const S: string): TOposBarcode;

  function GetInteger(const Prefix: Char; const S: string): Integer;
  var
    i: Integer;
    Tag: string;
    InTag: Boolean;
  begin
    Tag := '';
    Result := 0;
    InTag := False;
    for i := 1 to Length(S) do
    begin
      if S[i] = Prefix then
      begin
        InTag := True;
      end else
      begin
        if InTag then
        begin
          if S[i] in ['-', '0'..'9'] then
          begin
            Tag := Tag + S[i];
          end else
          begin
            Result := StrToIntDef(Tag, 0);
            Break;
          end;
        end;
      end;
    end;
  end;

  function GetBarcodeData(const S: string): string;
  var
    i: Integer;
    Tag: string;
    InTag: Boolean;
  begin
    Tag := '';
    InTag := False;
    for i := 1 to Length(S) do
    begin
      if S[i] = 'd' then
      begin
        InTag := True;
      end else
      begin
        if InTag then
        begin
          Tag := Tag + S[i];
        end;
      end;
    end;
    Result := Copy(Tag, 1, Length(Tag)-1);
  end;

begin
  Result.Symbology := GetInteger('s', S);
  Result.Height := GetInteger('h', S);
  Result.Width := GetInteger('w', S);
  Result.Alignment := GetInteger('a', S);
  Result.TextPosition := GetInteger('t', S);
  Result.Data := GetBarcodeData(S);
end;



end.

unit OposEsc;

interface

uses
  // VCL
  SysUtils,
  // Tnt
  TntSysUtils,
  // This
  RegExpr, DebugUtils, UserError;

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
    Text: WideString;
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

  EscStrPaperCut = '#P';

  /////////////////////////////////////////////////////////////////////////////
  // Feed and Paper cut ESC |#fP
  //
  // Cuts receipt paper, after feeding the paper by the
  // RecLinesToPaperCut lines. The character ‘#’ is defined
  // by the “Paper cut” escape sequence.

  EscStrFeedCut = '#fP';

  /////////////////////////////////////////////////////////////////////////////
  // Feed, Paper cut, and Stamp ESC |#sP
  //
  // Cuts and stamps receipt paper, after feeding the paper by
  // the RecLinesToPaperCut lines. The character ‘#’ is
  // defined by the “Paper cut” escape sequence.
  // Fire stamp ESC |sL Fires the stamp solenoid, which usually contains a
  // graphical store emblem.

  EscStrFeedCutStamp = '#sP';

  /////////////////////////////////////////////////////////////////////////////
  // Fire stamp ESC |sL Fires the stamp solenoid,
  // which usually contains a graphical store emblem.

  EscStrFireStamp      = '#sL';

  /////////////////////////////////////////////////////////////////////////////
  // Print bitmap ESC |#B
  //
  // Prints the pre-stored bitmap. The character ‘#’ is replaced
  // by the bitmap number. See setBitmap method.
  // Print top logo ESC |tL Prints the pre-stored top logo.
  // Print bottom logo ESC |bL Prints the pre-stored bottom logo.

  EscStrPrintBitmap = '#B';

  /////////////////////////////////////////////////////////////////////////////
  // Print top logo
  // ESC |tL
  // Prints the pre-stored top logo.

  EscStrPrintTLogo     = '#tL';

  /////////////////////////////////////////////////////////////////////////////
  // Print bottom logo
  // ESC |bL
  // Prints the pre-stored bottom logo.

  EscStrPrintBLogo    = '#bL';

  /////////////////////////////////////////////////////////////////////////////
  // Feed lines ESC |#lF
  //
  // Feed the paper forward by lines. The character ‘#’ is
  // replaced by an ASCII decimal string telling the number of
  // lines to be fed. If ‘#’ is omitted, then one line is fed.

  EscStrFeedLines = '#lF';

  /////////////////////////////////////////////////////////////////////////////
  // Feed units ESC |#uF
  //
  // Feed the paper forward by mapping mode units. The
  // character ‘#’ is replaced by an ASCII decimal string
  // telling the number of units to be fed. If ‘#’ is omitted, then
  // one unit is fed.

  EscStrFeedUnits = '#uF';

  /////////////////////////////////////////////////////////////////////////////
  // Feed reverse ESC |#rF
  // Feed the paper backward. The character ‘#’ is replaced by
  // an ASCII decimal string telling the number of lines to be
  // fed. If ‘#’ is omitted, then one line is fed.

  EscStrFeedReverse = '#rF';

  /////////////////////////////////////////////////////////////////////////////
  // Pass through embedded data
  // ESC |#E
  //
  // Send the following # characters of data through to the
  // hardware without modifying it. The character '#' is
  // replaced by an ASCII decimal string telling the number of
  // bytes following the escape sequence that should be
  // passed through as-is to the hardware.

  EscStrPassThrough = '#E';

  /////////////////////////////////////////////////////////////////////////////
  // Print in-line barcode
  // ESC |#R
  // Prints the defined barcode in-line. The character ‘#’ is the
  // number of characters following the R to use in the
  // definition of the characteristics of the barcode to be
  // printed. See details below.

  EscStrPrintBarcode = '#R';

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

  EscStrFontIndex = '#fT';

  /////////////////////////////////////////////////////////////////////////////
  // Bold ESC |(!)bC
  // Prints in bold or double-strike.
  // If ‘!’ is specified then bold is disabled

  ESC_Bold = ESC + '|bC';
  ESC_NoBold = ESC + '|\!bC';

  EscStrBold = 'bC';
  EscStrNoBold = '!bC';

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

  EscStrUnderline = 'uC';
  EscStrNoUnderline = '\!uC';

  /////////////////////////////////////////////////////////////////////////////
  // Italic ESC |(!)iC
  // Prints in italics. If ‘!’ is specified then italic is disabled

  ESC_Italic = ESC + '|iC';
  ESC_NoItalic = ESC + '|!iC';

  EscStrItalic = 'iC';
  EscStrNoItalic = '\!iC';

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

  EscStrSelectColor = '#rC';

  /////////////////////////////////////////////////////////////////////////////
  // Reverse video
  // ESC |(!)rvC
  // Prints in a reverse video format. If ‘!’ is
  // specified then reverse video is disabled

  EscReverseVideo = ESC + '|rvC';
  EscNoReverseVideo = ESC + '|!rvC';

  EscStrReverseVideo = 'rvC';
  EscStrNoReverseVideo = '\!rvC';

  /////////////////////////////////////////////////////////////////////////////
  // Shading
  // ESC |#sC
  // Prints in a shaded manner. The character ‘#’ is
  // replaced by an ASCII decimal string telling the
  // percentage shading desired. If ‘#’ is omitted,
  // then a printer-specific default level of shading is used.

  EscStrShading = '[0-9]{0,2}sC';

  /////////////////////////////////////////////////////////////////////////////
  // Single high and wide
  // ESC |1C
  // Prints normal size.

  ESC_NormalSize = ESC + '|1C';
  EscStrNormalSize = '1C';

  /////////////////////////////////////////////////////////////////////////////
  // Double wide
  // ESC |2C
  // Prints double-wide characters.

  ESC_DoubleWide = ESC + '|2C';
  EscStrDoubleWide = '2C';

  /////////////////////////////////////////////////////////////////////////////
  // Double high
  // ESC |3C
  // Prints double-high characters.

  ESC_DoubleHigh = ESC + '|3C';
  EscStrDoubleHigh = '3C';

  /////////////////////////////////////////////////////////////////////////////
  // Double high and wide
  // ESC |4C
  // Prints double-high/double-wide characters.

  ESC_DoubleHighWide = ESC + '|4C';
  EscStrDoubleHighWide = '4C';

  /////////////////////////////////////////////////////////////////////////////
  // Scale horizontally
  // ESC |#hC
  // Prints with the width scaled ‘#’ times the
  // normal size, where ‘#’ is replaced by an ASCII decimal string.

  EscStrScaleHorizontally = '#hC';

  /////////////////////////////////////////////////////////////////////////////
  // Scale vertically
  // ESC |#vC
  // Prints with the height scaled ‘#’ times the
  // normal size, where ‘#’ is replaced by an ASCII decimal string.

  EscStrScaleVertically = '#vC';

  /////////////////////////////////////////////////////////////////////////////
  // Center
  // ESC |cA
  // Aligns following text in the center.

  EscAlignCenter = ESC + '|cA';
  EscStrAlignCenter = 'cA';

  /////////////////////////////////////////////////////////////////////////////
  // Right justify
  // ESC |rA
  // Aligns following text at the right.

  EscAlignRight = ESC + '|rA';
  EscStrAlignRight = 'rA';

  /////////////////////////////////////////////////////////////////////////////
  // Left justify (see a below)
  // ESC |lA
  // Aligns following text at the left.

  EscAlignLeft = ESC + '|lA';
  EscStrAlignLeft = 'lA';

  /////////////////////////////////////////////////////////////////////////////
  // Strike-through
  // ESC |(!)#stC
  // Prints in strike-through mode. The character ‘#’ is replaced
  // by an ASCII decimal string telling the thickness of the strike-through in
  // printer dot units. If ‘#’ is omitted, then a printer-specific default
  // thickness is used. If ‘!’ is specified then strike-through mode is
  // switched off.

  EscStrStrikeThrough = '[0-9]{0,2}stC';
  EscStrNoStrikeThrough = '\!stC';

  /////////////////////////////////////////////////////////////////////////////
  // Normal
  // ESC |N
  // Restores printer characteristics to normal condition.

  ESC_Normal = ESC + '|N';
  EscStrNormal = 'N';

function GetEscTags(const Text: WideString): TEscTags;
function ParseOposBarcode(const S: WideString): TOposBarcode;
function GetEscTag(var Text: WideString; var Tag: TEscTag): Boolean;
function EscGetFontIndex(var Text: WideString; var FontIndex: Integer): Boolean;
function GetTagNumber(var S: WideString; const T: WideString; var N: Integer): Boolean;

implementation

function ReadInteger(var Text: WideString): Integer;
var
  S: string;
begin
  S := '';
  while Length(Text) > 0 do
  begin
    if Text[1] in [WideChar('0')..WideChar('9')] then
    begin
      S := S + Text[1];
      Text := Copy(Text, 2, Length(Text));
    end else
    begin
      Break;
    end;
  end;
  Result := StrToIntDef(S, 0);
end;

function GetTagNumber(var S: WideString; const T: WideString; var N: Integer): Boolean;
var
  SI: Integer;
  TI: Integer;
  SN: string;
begin
  Result := False;
  if Length(T) = 0 then
    raise UserException.Create('Template is empty');

  SI := 1;
  TI := 1;
  SN := '';
  while (SI <= Length(S))and(TI <= Length(T)) do
  begin
    if T[TI] = '#' then
    begin
      if S[SI] in [WideChar('0')..WideChar('9')] then
      begin
        SN := SN + S[SI];
        Inc(SI);
      end else
      begin
        Inc(TI);
        N := StrToIntDef(SN, 0);
      end;
    end else
    begin
      Result := T[TI] = S[SI];
      if not Result then Break;

      Inc(SI);
      if TI = Length(T) then Break;
      Inc(TI);
    end;
  end;
  if Result then
    S := Copy(S, SI, Length(S));
end;

function EscGetFontIndex(var Text: WideString; var FontIndex: Integer): Boolean;
begin
  Result := GetTagNumber(Text, EscStrFontIndex, FontIndex);
end;

function GetEscTag(var Text: WideString; var Tag: TEscTag): Boolean;

const
  EscStrs: array [0..34] of string = (
    EscStrPaperCut,
    EscStrFeedCut,
    EscStrFeedCutStamp,
    EscStrFireStamp,
    EscStrPrintBitmap,
    EscStrPrintTLogo,
    EscStrPrintBLogo,
    EscStrFeedLines,
    EscStrFeedUnits,
    EscStrFeedReverse,
    EscStrPassThrough,
    EscStrPrintBarcode,
    EscStrFontIndex,
    EscStrBold,
    EscStrNoBold,
    EscStrUnderline,
    EscStrNoUnderline,
    EscStrItalic,
    EscStrNoItalic,
    EscStrSelectColor,
    EscStrReverseVideo,
    EscStrNoReverseVideo,
    EscStrShading,
    EscStrNormalSize,
    EscStrDoubleWide,
    EscStrDoubleHigh,
    EscStrDoubleHighWide,
    EscStrScaleHorizontally,
    EscStrScaleVertically,
    EscStrAlignCenter,
    EscStrAlignRight,
    EscStrAlignLeft,
    EscStrStrikeThrough,
    EscStrNoStrikeThrough,
    EscStrNormal
  );

var
  i: Integer;
  N: Integer;
begin
  for i := 0 to Length(EscStrs)-1 do
  begin
    Result := GetTagNumber(Text, EscStrs[i], N);
    if Result then
    begin
      Tag.Text := '';
      Tag.Number := N;
      Tag.TagType := TTagType(i + 1);
      if Tag.TagType = ttPassThrough then
      begin
        Tag.Text := Copy(Text, 1, Tag.Number);
        Text := Copy(Text, Tag.Number+1, Length(Text));
      end;
      if Tag.TagType = ttPrintBarcode then
      begin
        Tag.Text := Copy(Text, 1, Tag.Number);
        Text := Copy(Text, Tag.Number+1, Length(Text));
      end;
      Break;
    end;
  end;
end;

function GetEscTags(const Text: WideString): TEscTags;
const
  EscPrefix = #$1B'|';
var
  P: Integer;
  Tag: TEscTag;
  S: WideString;
begin
  S := Text;
  SetLength(Result, 0);
  repeat
    P := WideTextPos(EscPrefix, S);
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
    if P = 1 then
    begin
      S := Copy(S, 3, Length(S));
      if GetEscTag(S, Tag) then
      begin
        SetLength(Result, Length(Result) + 1);
        Result[Length(Result)-1] := Tag;
      end else
      begin
        Break;
      end;
    end;
  until P = 0;
end;


///////////////////////////////////////////////////////////////////////////////
// s symbology
// h height
// w width
// a alignment
// t human readable text position
// d start of data
// e end of sequence

function ParseOposBarcode(const S: WideString): TOposBarcode;

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

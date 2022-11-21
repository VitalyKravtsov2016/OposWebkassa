unit OposEsc;

interface

const
  GS     = #$1D;
  ESC     = #$1B;

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

implementation

end.

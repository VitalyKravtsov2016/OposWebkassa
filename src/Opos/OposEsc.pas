unit OposEsc;

interface

const
  GS     = #$1D;
  ESC     = #$1B;
  EscBold = ESC + '|bC';
  EscDWDH = ESC + '|4C';

  // Cuts receipt paper. The character ‘#’ is replaced by an
  // ASCII decimal string telling the percentage cut desired. If
  // ‘#’ is omitted, then a full cut is performed. For example:
  // The C string “\x1B|75P” requests a 75% partial cut.

  ESCPaperFullCut = ESC + '|P';
  ESCPaper75Cut = ESC + '|75P';
  ESCPaper50Cut = ESC + '|50P';

implementation

end.

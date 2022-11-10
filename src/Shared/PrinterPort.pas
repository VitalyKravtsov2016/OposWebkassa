unit PrinterPort;

interface

uses
  // VCL
  Windows;

type
  { IPrinterPort }

  IPrinterPort = interface
    procedure Lock;
    procedure Unlock;
    procedure Purge;
    procedure Close;
    procedure Open;
    procedure Write(const Data: AnsiString);
    function ReadChar(var C: Char): Boolean;
    function Read(Count: DWORD): AnsiString;
  end;

implementation

end.

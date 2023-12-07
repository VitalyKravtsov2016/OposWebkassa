unit PrinterPort;

interface

uses
  // VCL
  Windows;

type
  { IPrinterPort }

  IPrinterPort = interface
    procedure Flush;
    procedure Purge;
    procedure Close;
    procedure Open;
    procedure Lock;
    procedure Unlock;
    procedure Write(const Data: AnsiString);
    function Read(Count: DWORD): AnsiString;
    function CapRead: Boolean;
    function GetDescription: WideString;
  end;

implementation

end.

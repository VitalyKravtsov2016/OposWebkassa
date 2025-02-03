unit PrinterPort;

interface

uses
  // VCL
  Windows,
  // This
  WException;

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

  ESerialError = class(WideException);
  ENoPortError = class(ESerialError);
  ETimeoutError = class(ESerialError);

implementation

end.

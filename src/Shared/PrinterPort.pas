unit PrinterPort;

interface

uses
  // VCL
  Windows,
  // This
  UserError;

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
    function ReadByte: Byte;
    function ReadString: AnsiString;
  end;

  ESerialError = class(UserException);
  ENoPortError = class(ESerialError);
  ETimeoutError = class(ESerialError);

implementation

end.

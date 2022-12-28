unit DriverContext;

interface

uses
  // This
  LogFile, PrinterParameters;

type
  { TDriverContext }

  TDriverContext = class
  private
    FLogger: ILogFile;
    FParameters: TPrinterParameters;
  public
    constructor Create;
    destructor Destroy; override;

    property Logger: ILogFile read FLogger;
    property Parameters: TPrinterParameters read FParameters;
  end;

implementation

{ TDriverContext }
                                
constructor TDriverContext.Create;
begin
  inherited Create;
  FLogger := TLogFile.Create;
  FParameters := TPrinterParameters.Create(FLogger);
end;

destructor TDriverContext.Destroy;
begin
  FLogger := nil;
  FParameters.Free;
  inherited Destroy;
end;

end.

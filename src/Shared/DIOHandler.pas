unit DIOHandler;

interface

Uses
  // VCL
  Classes, SysUtils,
  // THis
  WException, LogFile, gnugettext, PrinterParameters;

type
  TDIOHandler = class;

  { TDIOHandlers }

  TDIOHandlers = class
  private
    FList: TList;
    FParams: TPrinterParameters;

    function GetCount: Integer;
    function GetItem(Index: Integer): TDIOHandler;
    procedure InsertItem(AItem: TDIOHandler);
    procedure RemoveItem(AItem: TDIOHandler);
  public
    constructor Create(AParams: TPrinterParameters);
    destructor Destroy; override;

    procedure Clear;
    function findItem(Command: Integer): TDIOHandler;
    function ItemByCommand(Command: Integer): TDIOHandler;

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TDIOHandler read GetItem; default;
    property Params: TPrinterParameters read FParams;
  end;

  { TDIOHandler }

  TDIOHandler = class
  private
    FCommand: Integer;
    FOwner: TDIOHandlers;

    function GetLogger: ILogFile;
    procedure SetOwner(AOwner: TDIOHandlers);
    function GetParams: TPrinterParameters;
  public
    constructor Create(AOwner: TDIOHandlers; ACommand: Integer); virtual;
    destructor Destroy; override;
    function GetCommand: Integer; virtual;
    procedure DirectIO(var pData: Integer; var pString: WideString); virtual; abstract;

    property Logger: ILogFile read GetLogger;
    property Command: Integer read FCommand;
    property Params: TPrinterParameters read GetParams;
  end;

implementation

{ TDIOHandlers }

constructor TDIOHandlers.Create(AParams: TPrinterParameters);
begin
  inherited Create;
  FList := TList.Create;
  FParams := AParams;
end;

destructor TDIOHandlers.Destroy;
begin
  Clear;
  FList.Free;
  inherited Destroy;
end;

procedure TDIOHandlers.Clear;
begin
  while Count > 0 do Items[0].Free;
end;

function TDIOHandlers.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TDIOHandlers.GetItem(Index: Integer): TDIOHandler;
begin
  Result := FList[Index];
end;

procedure TDIOHandlers.InsertItem(AItem: TDIOHandler);
begin
  FList.Add(AItem);
  AItem.FOwner := Self;
end;

procedure TDIOHandlers.RemoveItem(AItem: TDIOHandler);
begin
  AItem.FOwner := nil;
  FList.Remove(AItem);
end;

function TDIOHandlers.findItem(Command: Integer): TDIOHandler;
var
  i: Integer;
begin
  for i := 0 to Count-1 do
  begin
    Result := Items[i];
    if Result.Command = Command then Exit;
  end;
  Result := nil;
end;

function TDIOHandlers.ItemByCommand(Command: Integer): TDIOHandler;
begin
  Result := findItem(Command);
  if Result = nil then
    raiseException(_('Invalid DirectIO command code'));
end;

{ TDIOHandler }

constructor TDIOHandler.Create(AOwner: TDIOHandlers; ACommand: Integer);
begin
  inherited Create;
  SetOwner(AOwner);
  FCommand := ACommand;
end;

destructor TDIOHandler.Destroy;
begin
  SetOwner(nil);
  inherited Destroy;
end;

procedure TDIOHandler.SetOwner(AOwner: TDIOHandlers);
begin
  if AOwner <> FOwner then
  begin
    if FOwner <> nil then FOwner.RemoveItem(Self);
    if AOwner <> nil then AOwner.InsertItem(Self);
  end;
end;

function TDIOHandler.GetCommand: Integer;
begin
  Result := 0;
end;

function TDIOHandler.GetParams: TPrinterParameters;
begin
  Result := FOwner.Params;
end;

function TDIOHandler.GetLogger: ILogFile;
begin
  Result := Params.Logger;
end;

end.

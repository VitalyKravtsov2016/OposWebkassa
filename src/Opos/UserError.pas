unit UserError;

interface

uses
  // VCL
  SysUtils,
  // Tnt
  TntSysUtils;

type
  { UserException }

  UserException = class(Exception)
  private
    FMessage: WideString;
  public
    constructor Create(const AMessage: WideString);
    constructor CreateFmt(const Msg: WideString; const Args: array of const);

    property Message: WideString read FMessage;
  end;

procedure raiseException(const AMessage: WideString);
procedure raiseExceptionFmt(const AFormat: WideString; const Args: array of const);

function GetExceptionMessage(E: Exception): WideString;

implementation

procedure raiseException(const AMessage: WideString);
begin
  raise UserException.Create(AMessage);
end;

procedure raiseExceptionFmt(const AFormat: WideString; const Args: array of const);
begin
  raise UserException.Create(WideFormat(AFormat, Args));
end;

function GetExceptionMessage(E: Exception): WideString;
begin
  Result := E.Message;
  if E is UserException then
    Result := (E as UserException).Message;

  if Result = '' then
    Result := E.ClassName;
end;

{ UserException }

constructor UserException.Create(const AMessage: WideString);
begin
  inherited Create(AMessage);
  FMessage := AMessage;
end;

constructor UserException.CreateFmt(const Msg: WideString; const Args: array of const);
begin
  FMessage := WideFormat(Msg, Args);
end;

end.

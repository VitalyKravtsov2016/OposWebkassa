unit MemoryUtils;

interface

uses
  // VCL
  Windows, SysUtils;

procedure MemCheckStart;
procedure MemCheckStop;

implementation

var
  SavedMM: TMemoryManager;
  HookInstalled: Boolean;
  BlockCount: Integer;

function CountGetMem(Size: Integer): Pointer;
begin
  Result := SavedMM.GetMem(Size);
  if Result <> nil then
    InterlockedIncrement(BlockCount);
end;

function CountFreeMem(P: Pointer): Integer;
begin
  Result := SavedMM.FreeMem(P);
  if Result = 0 then
    InterlockedDecrement(BlockCount);
end;

function CountReallocMem(P: Pointer; Size: Integer): Pointer;
begin
  Result := SavedMM.ReallocMem(P, Size);
end;

procedure MemCheckStart;
var
  MM: TMemoryManager;
begin
  BlockCount := 0;
  if HookInstalled then Exit;

  GetMemoryManager(SavedMM);
  MM.GetMem := CountGetMem;
  MM.FreeMem := CountFreeMem;
  MM.ReallocMem := CountReallocMem;
  SetMemoryManager(MM);
  HookInstalled := True;
end;

procedure MemCheckStop;
var
  Leaked: Integer;
begin
  if not HookInstalled then
    raise Exception.Create('MemCheckStart was not called');

  SetMemoryManager(SavedMM);
  HookInstalled := False;
  Leaked := BlockCount;
  if Leaked > 0 then
    raise Exception.CreateFmt('%d memory block(s) not freed', [Leaked]);
end;

end.

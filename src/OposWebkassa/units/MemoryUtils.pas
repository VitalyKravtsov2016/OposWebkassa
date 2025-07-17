unit MemoryUtils;

interface

uses
  // VCL
  SysUtils, ShareMem;

procedure MemCheckStart;
procedure MemCheckStop;

implementation

var
  MemSize: Integer;
  MemCount: Integer;

procedure MemCheckStart;
begin
  MemCount := GetAllocMemCount;
  MemSize := GetAllocMemSize;
(*
  if MemCount = 0 then
    raise Exception.Create('MemCount = 0');
  if MemSize = 0 then
    raise Exception.Create('MemSize = 0');
*)
end;

procedure MemCheckStop;
var
  AMemCount: Integer;
  AMemSize: Integer;
begin
  if MemCount = 0 then Exit;
  if MemSize = 0 then Exit;

  AMemSize := GetAllocMemSize - MemSize;
  if AMemSize <> 0 then
    raise Exception.CreateFmt('GetAllocMemSize - MemSize <> 0, %d', [AMemSize]);

  AMemCount := GetAllocMemCount - MemCount;
  if AMemCount <> 0 then
    raise Exception.CreateFmt('GetAllocMemCount - MemCount <> 0, %d', [AMemCount]);
end;

end.

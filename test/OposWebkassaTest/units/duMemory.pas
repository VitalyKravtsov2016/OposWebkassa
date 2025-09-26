
unit duMemory;

interface

uses
  // VCL
  SysUtils, ShareMem,
  // DUnit
  TestFramework,
  // This
  WebkassaImpl, MemoryUtils;

type
  { TMemoryTest }

  TMemoryTest = class(TTestCase)
  published
    procedure TestDriver;
    procedure TestDriver2;
    procedure TestMemCheck;
  end;

implementation

{ TMemoryTest }

procedure TMemoryTest.TestDriver;
var
  MemSize: Integer;
  MemCount: Integer;
  Driver: TWebkassaImpl;
begin
  Driver := TWebkassaImpl.Create;
  Driver.Free;

  MemCount := GetAllocMemCount;
  MemSize := GetAllocMemSize;
  if MemCount = 0 then Exit;
  if MemSize = 0 then Exit;

  Driver := TWebkassaImpl.Create;
  Driver.Free;

  CheckEquals(0, GetAllocMemCount - MemCount, 'MemCount.1');
  CheckEquals(0, GetAllocMemSize - MemSize, 'MemSize.1');
end;

procedure TMemoryTest.TestDriver2;
var
  Driver: TWebkassaImpl;
begin
  Driver := TWebkassaImpl.Create;
  Driver.Free;

  MemCheckStart;
  Driver := TWebkassaImpl.Create;
  Driver.Free;
  MemCheckStop;
end;

procedure TMemoryTest.TestMemCheck;
var
  P: Pointer;
begin
  P := nil;
  MemCheckStart;
  GetMem(P, 123);
  try
    try
      MemCheckStop;
      Fail('No exception raised');
    except
      on E: Exception do;
    end;
  finally
    FreeMem(P);
  end;
end;

(*
initialization
  RegisterTest('', TMemoryTest.Suite);
*)  


end.

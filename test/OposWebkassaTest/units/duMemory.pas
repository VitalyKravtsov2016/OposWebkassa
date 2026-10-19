
unit duMemory;

interface

uses
  // VCL
  SysUtils,
  // DUnit
  TestFramework,
  // This
  WebkassaImpl, MemoryUtils;

type
  { TMemoryTest }

  TMemoryTest = class(TTestCase)
  published
    procedure TestDriver;
    procedure TestMemCheck;
    procedure TestMemCheckNoLeak;
  end;

implementation

{ TMemoryTest }

procedure TMemoryTest.TestDriver;
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
  Raised: Boolean;
begin
  P := nil;
  Raised := False;
  MemCheckStart;
  GetMem(P, 123);
  try
    try
      MemCheckStop;
    except
      on E: Exception do
        Raised := True;
    end;
  finally
    FreeMem(P);
  end;
  Check(Raised, 'MemCheckStop did not detect the leak');
end;

procedure TMemoryTest.TestMemCheckNoLeak;
var
  P: Pointer;
begin
  MemCheckStart;
  GetMem(P, 123);
  ReallocMem(P, 456);
  FreeMem(P);
  MemCheckStop;
end;

initialization
  RegisterTest('', TMemoryTest.Suite);

end.

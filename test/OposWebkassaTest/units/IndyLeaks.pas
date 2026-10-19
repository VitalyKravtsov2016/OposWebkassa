unit IndyLeaks;

interface

implementation

uses
  FastMM4, IdGlobal, IdThreadSafe, IdThread, IdStack;

initialization
  // Indy is built without FREE_ON_FINAL and never frees IdThread.GThreadCount
  // and IdStack.GStackCriticalSection, both declared in implementation sections
  RegisterExpectedMemoryLeak(TIdThreadSafeInteger, 1);
  RegisterExpectedMemoryLeak(TIdCriticalSection, 2);
end.

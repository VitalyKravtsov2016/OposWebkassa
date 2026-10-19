unit duMemoryStream;

interface

uses
  // VCL
  SysUtils, Classes,
  // DUnit
  TestFramework;

type
  { TMemoryStreamTest }

  TMemoryStreamTest = class(TTestCase)
  published
    procedure TestEmpty;
    procedure TestWriteRead;
    procedure TestWriteBounds;
    procedure TestSeek;
    procedure TestOverwrite;
    procedure TestReadPastEnd;
    procedure TestSetSize;
    procedure TestClear;
    procedure TestGrow;
    procedure TestLoadSaveStream;
    procedure TestLoadSaveFile;
    procedure TestLoadMissingFile;
    procedure TestCopyFrom;
    procedure TestAllocViaGetMem;
    procedure TestFreeViaFreeMem;
    procedure TestReallocViaReallocMem;
  end;

implementation

const
  { Must match MemoryDelta in Classes.TMemoryStream.Realloc. }
  MemoryDelta = $2000;
  MaxMemEvents = 32;

type
  TMemoryStreamAccess = class(TMemoryStream);

  TAllocEvent = record
    Ptr: Pointer;
    Size: Integer;
  end;

  TReallocEvent = record
    OldPtr: Pointer;
    NewPtr: Pointer;
    Size: Integer;
  end;

var
  SavedMM: TMemoryManager;
  HookInstalled: Boolean;
  AllocOverflow: Boolean;
  FreeOverflow: Boolean;
  ReallocOverflow: Boolean;
  Allocs: array[0..MaxMemEvents - 1] of TAllocEvent;
  AllocCount: Integer;
  Frees: array[0..MaxMemEvents - 1] of Pointer;
  FreeCount: Integer;
  Reallocs: array[0..MaxMemEvents - 1] of TReallocEvent;
  ReallocCount: Integer;

function HookGetMem(Size: Integer): Pointer;
begin
  Result := SavedMM.GetMem(Size);
  if AllocCount >= MaxMemEvents then
  begin
    AllocOverflow := True;
    Exit;
  end;
  Allocs[AllocCount].Ptr := Result;
  Allocs[AllocCount].Size := Size;
  Inc(AllocCount);
end;

function HookFreeMem(P: Pointer): Integer;
begin
  if FreeCount >= MaxMemEvents then
    FreeOverflow := True
  else
  begin
    Frees[FreeCount] := P;
    Inc(FreeCount);
  end;
  Result := SavedMM.FreeMem(P);
end;

function HookReallocMem(P: Pointer; Size: Integer): Pointer;
begin
  Result := SavedMM.ReallocMem(P, Size);
  if ReallocCount >= MaxMemEvents then
  begin
    ReallocOverflow := True;
    Exit;
  end;
  Reallocs[ReallocCount].OldPtr := P;
  Reallocs[ReallocCount].NewPtr := Result;
  Reallocs[ReallocCount].Size := Size;
  Inc(ReallocCount);
end;

procedure InstallMemHook;
var
  MM: TMemoryManager;
begin
  if HookInstalled then
    raise Exception.Create('memory hook already installed');
  AllocCount := 0;
  FreeCount := 0;
  ReallocCount := 0;
  AllocOverflow := False;
  FreeOverflow := False;
  ReallocOverflow := False;
  GetMemoryManager(SavedMM);
  MM := SavedMM;
  MM.GetMem := HookGetMem;
  MM.FreeMem := HookFreeMem;
  MM.ReallocMem := HookReallocMem;
  SetMemoryManager(MM);
  HookInstalled := True;
end;

procedure RemoveMemHook;
begin
  if not HookInstalled then
    Exit;
  SetMemoryManager(SavedMM);
  HookInstalled := False;
end;

function WasAllocated(P: Pointer; Size: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to AllocCount - 1 do
    if (Allocs[I].Ptr = P) and (Allocs[I].Size = Size) then
    begin
      Result := True;
      Exit;
    end;
end;

function AllocCountOfSize(Size: Integer): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to AllocCount - 1 do
    if Allocs[I].Size = Size then
      Inc(Result);
end;

function FreeCountOf(P: Pointer): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FreeCount - 1 do
    if Frees[I] = P then
      Inc(Result);
end;

function FindRealloc(OldPtr: Pointer; Size: Integer; var NewPtr: Pointer): Boolean;
var
  I: Integer;
begin
  Result := False;
  NewPtr := nil;
  for I := 0 to ReallocCount - 1 do
    if (Reallocs[I].OldPtr = OldPtr) and (Reallocs[I].Size = Size) then
    begin
      NewPtr := Reallocs[I].NewPtr;
      Result := True;
      Exit;
    end;
end;

function TempDataFile: string;
var
  Dir: string;
begin
  Dir := GetEnvironmentVariable('TEMP');
  if Dir = '' then
    Dir := ExtractFilePath(ParamStr(0));
  Result := IncludeTrailingBackslash(Dir) + 'duMemoryStream.tmp';
end;

procedure DeleteTempDataFile(const FileName: string);
begin
  if FileExists(FileName) then
    DeleteFile(FileName);
end;

procedure FillPattern(var Data: array of Byte);
var
  I: Integer;
begin
  for I := 0 to High(Data) do
    Data[I] := Byte(I and $FF);
end;

{ TMemoryStreamTest }

procedure TMemoryStreamTest.TestEmpty;
var
  Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  try
    CheckEquals(0, Integer(Stream.Size), 'Size');
    CheckEquals(0, Integer(Stream.Position), 'Position');
    Check(Stream.Memory = nil, 'Memory');
    CheckEquals(0, TMemoryStreamAccess(Stream).Capacity, 'Capacity');
  finally
    Stream.Free;
  end;
end;

procedure TMemoryStreamTest.TestWriteRead;
const
  Text = 'Memory'#0'Stream';
var
  Stream: TMemoryStream;
  Actual: string;
begin
  Stream := TMemoryStream.Create;
  try
    CheckEquals(Length(Text), Stream.Write(Text[1], Length(Text)), 'Write');
    CheckEquals(Length(Text), Integer(Stream.Size), 'Size');
    CheckEquals(Length(Text), Integer(Stream.Position), 'Position');

    Stream.Position := 0;
    SetLength(Actual, Length(Text));
    CheckEquals(Length(Text), Stream.Read(Actual[1], Length(Actual)), 'Read');
    CheckEquals(Text, Actual, 'Data');
    CheckEquals(Length(Text), Integer(Stream.Position), 'Position after read');
  finally
    Stream.Free;
  end;
end;

procedure TMemoryStreamTest.TestWriteBounds;
var
  Stream: TMemoryStream;
  B: Byte;
begin
  B := 1;
  Stream := TMemoryStream.Create;
  try
    CheckEquals(0, Stream.Write(B, 0), 'zero count');
    CheckEquals(0, Integer(Stream.Size), 'size after zero write');
    CheckEquals(0, Stream.Write(B, -1), 'negative count');
    CheckEquals(0, Integer(Stream.Size), 'size after negative write');

    CheckEquals(-5, Stream.Seek(-5, soFromBeginning), 'Seek');
    CheckEquals(0, Stream.Write(B, 1), 'write at negative position');
    CheckEquals(0, Stream.Read(B, 1), 'read at negative position');
    CheckEquals(0, Integer(Stream.Size), 'size stays empty');
  finally
    Stream.Free;
  end;
end;

procedure TMemoryStreamTest.TestSeek;
var
  Stream: TMemoryStream;
  Data: array[0..9] of Byte;
  B: Byte;
  I: Integer;
begin
  for I := 0 to High(Data) do
    Data[I] := I + 1;

  Stream := TMemoryStream.Create;
  try
    Stream.WriteBuffer(Data, SizeOf(Data));
    CheckEquals(0, Stream.Seek(0, soFromBeginning), 'from beginning');
    CheckEquals(4, Stream.Seek(4, soFromCurrent), 'from current');
    CheckEquals(9, Stream.Seek(-1, soFromEnd), 'from end');
    Stream.ReadBuffer(B, 1);
    CheckEquals(10, Integer(B), 'last byte');
    CheckEquals(10, Integer(Stream.Position), 'position at end');

    CheckEquals(2, Stream.Seek(2, soFromBeginning), 'absolute');
    Stream.ReadBuffer(B, 1);
    CheckEquals(3, Integer(B), 'third byte');
    Stream.Position := 0;
    CheckEquals(0, Integer(Stream.Position), 'Position');
  finally
    Stream.Free;
  end;
end;

procedure TMemoryStreamTest.TestOverwrite;
const
  Original = 'AAAA';
  Patch = 'BB';
var
  Stream: TMemoryStream;
  Actual: string;
begin
  Stream := TMemoryStream.Create;
  try
    Stream.WriteBuffer(Original[1], Length(Original));
    Stream.Position := 1;
    CheckEquals(Length(Patch), Stream.Write(Patch[1], Length(Patch)), 'Write');
    CheckEquals(Length(Original), Integer(Stream.Size), 'Size');
    CheckEquals(3, Integer(Stream.Position), 'Position');

    SetLength(Actual, Stream.Size);
    Stream.Position := 0;
    Stream.ReadBuffer(Actual[1], Length(Actual));
    CheckEquals('ABBA', Actual, 'Data');
  finally
    Stream.Free;
  end;
end;

procedure TMemoryStreamTest.TestReadPastEnd;
const
  Text = '1234';
var
  Stream: TMemoryStream;
  B: Byte;
  Buf: array[0..9] of Byte;
begin
  Stream := TMemoryStream.Create;
  try
    Stream.WriteBuffer(Text[1], Length(Text));
    Stream.Position := Stream.Size;
    CheckEquals(0, Stream.Read(B, 1), 'Read at end');
    try
      Stream.ReadBuffer(B, 1);
      Fail('EReadError expected');
    except
      on E: EReadError do
        ;
    end;

    Stream.Position := 2;
    FillChar(Buf, SizeOf(Buf), 0);
    CheckEquals(2, Stream.Read(Buf, SizeOf(Buf)), 'partial Read');
    CheckEquals(Integer(Text[3]), Integer(Buf[0]), 'Buf[0]');
    CheckEquals(Integer(Text[4]), Integer(Buf[1]), 'Buf[1]');
    CheckEquals(4, Integer(Stream.Position), 'Position');
  finally
    Stream.Free;
  end;
end;

procedure TMemoryStreamTest.TestSetSize;
var
  Stream: TMemoryStream;
  B, R: Byte;
begin
  B := $5A;
  Stream := TMemoryStream.Create;
  try
    Stream.WriteBuffer(B, 1);
    Stream.SetSize(100);
    CheckEquals(100, Integer(Stream.Size), 'Size 100');
    CheckEquals(1, Integer(Stream.Position), 'Position');
    CheckEquals(MemoryDelta, TMemoryStreamAccess(Stream).Capacity, 'Capacity');
    Stream.Position := 0;
    Stream.ReadBuffer(R, 1);
    CheckEquals(Integer(B), Integer(R), 'preserved byte');

    Stream.Seek(50, soFromBeginning);
    Stream.SetSize(10);
    CheckEquals(10, Integer(Stream.Size), 'shrunk Size');
    CheckEquals(10, Integer(Stream.Position), 'shrunk Position');
    CheckEquals(MemoryDelta, TMemoryStreamAccess(Stream).Capacity, 'Capacity unchanged');

    Stream.Size := MemoryDelta + 1;
    CheckEquals(MemoryDelta + 1, Integer(Stream.Size), 'grown Size');
    CheckEquals(MemoryDelta * 2, TMemoryStreamAccess(Stream).Capacity, 'grown Capacity');
    CheckEquals(10, Integer(Stream.Position), 'position stays');

    Stream.SetSize(0);
    CheckEquals(0, Integer(Stream.Size), 'zero Size');
    CheckEquals(0, Integer(Stream.Position), 'zero Position');
    CheckEquals(0, TMemoryStreamAccess(Stream).Capacity, 'zero Capacity');
    Check(Stream.Memory = nil, 'Memory');
  finally
    Stream.Free;
  end;
end;

procedure TMemoryStreamTest.TestClear;
const
  First = 'abc';
  Second = 'xy';
var
  Stream, Other: TMemoryStream;
  Actual: string;
begin
  Stream := TMemoryStream.Create;
  Other := TMemoryStream.Create;
  try
    Other.WriteBuffer(First[1], Length(First));
    Stream.WriteBuffer(First[1], Length(First));
    Stream.Position := 2;
    Stream.Clear;

    CheckEquals(0, Integer(Stream.Size), 'Size');
    CheckEquals(0, Integer(Stream.Position), 'Position');
    CheckEquals(0, TMemoryStreamAccess(Stream).Capacity, 'Capacity');
    Check(Stream.Memory = nil, 'Memory');

    Stream.WriteBuffer(Second[1], Length(Second));
    SetLength(Actual, Stream.Size);
    Stream.Position := 0;
    Stream.ReadBuffer(Actual[1], Length(Actual));
    CheckEquals(Second, Actual, 'data after Clear');

    SetLength(Actual, Other.Size);
    Other.Position := 0;
    Other.ReadBuffer(Actual[1], Length(Actual));
    CheckEquals(First, Actual, 'other stream');
  finally
    Other.Free;
    Stream.Free;
  end;
end;

procedure TMemoryStreamTest.TestGrow;
var
  Stream: TMemoryStream;
  Data, Actual: array of Byte;
  Count, I: Integer;
begin
  Count := MemoryDelta + 100;
  SetLength(Data, Count);
  SetLength(Actual, Count);
  for I := 0 to Count - 1 do
    Data[I] := Byte((I * 3) and $FF);

  Stream := TMemoryStream.Create;
  try
    Stream.WriteBuffer(Data[0], Count);
    CheckEquals(Count, Integer(Stream.Size), 'Size');
    CheckEquals(Count, Integer(Stream.Position), 'Position');
    CheckEquals(MemoryDelta * 2, TMemoryStreamAccess(Stream).Capacity, 'Capacity');

    Stream.Position := 0;
    Stream.ReadBuffer(Actual[0], Count);
    Check(CompareMem(@Data[0], @Actual[0], Count), 'Data');
  finally
    Stream.Free;
  end;
end;

procedure TMemoryStreamTest.TestLoadSaveStream;
const
  Text = 'load-save';
var
  Source, Loaded, Saved: TMemoryStream;
  Actual: string;
begin
  Source := TMemoryStream.Create;
  Loaded := TMemoryStream.Create;
  Saved := TMemoryStream.Create;
  try
    Source.WriteBuffer(Text[1], Length(Text));
    Source.Position := 2;
    Loaded.LoadFromStream(Source);

    CheckEquals(Length(Text), Integer(Source.Position), 'source position');
    CheckEquals(Length(Text), Integer(Loaded.Size), 'loaded size');
    CheckEquals(0, Integer(Loaded.Position), 'loaded position');
    SetLength(Actual, Loaded.Size);
    Loaded.ReadBuffer(Actual[1], Length(Actual));
    CheckEquals(Text, Actual, 'loaded data');

    Source.Position := 4;
    Source.SaveToStream(Saved);
    CheckEquals(4, Integer(Source.Position), 'position unchanged');
    CheckEquals(Length(Text), Integer(Saved.Size), 'saved size');
    Saved.Position := 0;
    SetLength(Actual, Saved.Size);
    Saved.ReadBuffer(Actual[1], Length(Actual));
    CheckEquals(Text, Actual, 'saved data');

    Source.Clear;
    Loaded.Clear;
    Loaded.LoadFromStream(Source);
    CheckEquals(0, Integer(Loaded.Size), 'empty load');
    Check(Loaded.Memory = nil, 'empty memory');
  finally
    Saved.Free;
    Loaded.Free;
    Source.Free;
  end;
end;

procedure TMemoryStreamTest.TestLoadSaveFile;
const
  Text = 'file-roundtrip';
var
  Stream: TMemoryStream;
  FileName, Actual: string;
begin
  FileName := TempDataFile;
  DeleteTempDataFile(FileName);
  Stream := TMemoryStream.Create;
  try
    Stream.WriteBuffer(Text[1], Length(Text));
    Stream.SaveToFile(FileName);
    Check(FileExists(FileName), 'file created');

    Stream.Clear;
    Stream.LoadFromFile(FileName);
    CheckEquals(Length(Text), Integer(Stream.Size), 'Size');
    CheckEquals(0, Integer(Stream.Position), 'Position');
    SetLength(Actual, Stream.Size);
    Stream.ReadBuffer(Actual[1], Length(Actual));
    CheckEquals(Text, Actual, 'Data');
  finally
    Stream.Free;
    DeleteTempDataFile(FileName);
  end;
end;

procedure TMemoryStreamTest.TestLoadMissingFile;
var
  Stream: TMemoryStream;
begin
  Stream := TMemoryStream.Create;
  try
    try
      Stream.LoadFromFile('duMemoryStream-missing-file.tmp');
      Fail('EFOpenError expected');
    except
      on E: EFOpenError do
        ;
    end;
    CheckEquals(0, Integer(Stream.Size), 'Size');
  finally
    Stream.Free;
  end;
end;

procedure TMemoryStreamTest.TestCopyFrom;
var
  Source, Dest, Empty: TMemoryStream;
  Data, Actual: array[0..7] of Byte;
  Part: array[0..3] of Byte;
begin
  FillPattern(Data);

  Source := TMemoryStream.Create;
  Dest := TMemoryStream.Create;
  Empty := TMemoryStream.Create;
  try
    Source.WriteBuffer(Data, SizeOf(Data));
    Source.Position := 5;
    CheckEquals(SizeOf(Data), Integer(Dest.CopyFrom(Source, 0)), 'copy all');
    CheckEquals(SizeOf(Data), Integer(Dest.Size), 'dest size');
    CheckEquals(SizeOf(Data), Integer(Dest.Position), 'dest position');
    CheckEquals(SizeOf(Data), Integer(Source.Position), 'source position');

    Dest.Position := 0;
    Dest.ReadBuffer(Actual, SizeOf(Actual));
    Check(CompareMem(@Data, @Actual, SizeOf(Data)), 'copied data');

    Dest.Clear;
    Source.Position := 2;
    CheckEquals(SizeOf(Part), Integer(Dest.CopyFrom(Source, SizeOf(Part))), 'partial');
    Dest.Position := 0;
    Dest.ReadBuffer(Part, SizeOf(Part));
    Check(CompareMem(@Data[2], @Part, SizeOf(Part)), 'partial data');

    Dest.Clear;
    CheckEquals(0, Integer(Dest.CopyFrom(Empty, 0)), 'empty copy');
    CheckEquals(0, Integer(Dest.Size), 'empty size');
  finally
    Empty.Free;
    Dest.Free;
    Source.Free;
  end;
end;

procedure TMemoryStreamTest.TestAllocViaGetMem;
var
  Stream: TMemoryStream;
  Data: array[0..15] of Byte;
  Actual: array[0..31] of Byte;
  Buffer: Pointer;
  Capacity: Integer;
  AllocsBeforeSecondWrite: Integer;
  StreamSize: Integer;
begin
  FillPattern(Data);
  Buffer := nil;

  InstallMemHook;
  try
    Stream := TMemoryStream.Create;
    try
      Stream.WriteBuffer(Data, SizeOf(Data));
      Buffer := Stream.Memory;
      Capacity := TMemoryStreamAccess(Stream).Capacity;
      AllocsBeforeSecondWrite := AllocCount;

      Stream.WriteBuffer(Data, SizeOf(Data));
      StreamSize := Stream.Size;
      Stream.Position := 0;
      Stream.ReadBuffer(Actual, SizeOf(Actual));
    finally
      Stream.Free;
    end;
  finally
    RemoveMemHook;
  end;

  Check(not AllocOverflow, 'alloc overflow');
  Check(not FreeOverflow, 'free overflow');
  Check(not ReallocOverflow, 'realloc overflow');
  CheckEquals(MemoryDelta, Capacity, 'Capacity');
  CheckEquals(SizeOf(Actual), StreamSize, 'Size');
  Check(Buffer <> nil, 'Memory');
  Check(WasAllocated(Buffer, MemoryDelta), 'GetMem');
  CheckEquals(1, AllocCountOfSize(MemoryDelta), 'GetMem count');
  CheckEquals(0, ReallocCount, 'first block is GetMem');
  CheckEquals(AllocsBeforeSecondWrite, AllocCount, 'write inside capacity');
  Check(CompareMem(@Data, @Actual, SizeOf(Data)), 'first bytes');
  Check(CompareMem(@Data, @Actual[SizeOf(Data)], SizeOf(Data)), 'second bytes');
  CheckEquals(1, FreeCountOf(Buffer), 'FreeMem');
end;

procedure TMemoryStreamTest.TestFreeViaFreeMem;
var
  Stream: TMemoryStream;
  B: Byte;
  Obj, First, Second, Third: Pointer;
  FreeCountOnEmpty: Integer;
  MemoryAfterClear: Pointer;
  SizeAfterClear: Integer;
  PosAfterClear: Integer;
  CapAfterClear: Integer;
  FreedOnClear: Boolean;
  MemoryAfterZero: Pointer;
  CapAfterZero: Integer;
  FreedOnSetSize: Boolean;
  FreedOnDestroy: Boolean;
  ObjectFreed: Boolean;
  FreesBefore: Integer;
begin
  First := nil;
  Second := nil;
  Third := nil;
  Obj := nil;
  MemoryAfterClear := nil;
  MemoryAfterZero := nil;

  InstallMemHook;
  try
    Stream := TMemoryStream.Create;
    try
      Stream.Clear;
      Stream.SetSize(0);
      FreeCountOnEmpty := FreeCount;

      B := $11;
      Stream.WriteBuffer(B, 1);
      First := Stream.Memory;
      Stream.Clear;
      MemoryAfterClear := Stream.Memory;
      SizeAfterClear := Stream.Size;
      PosAfterClear := Stream.Position;
      CapAfterClear := TMemoryStreamAccess(Stream).Capacity;
      FreedOnClear := FreeCountOf(First) = 1;

      B := $22;
      Stream.WriteBuffer(B, 1);
      Second := Stream.Memory;
      FreesBefore := FreeCountOf(Second);
      Stream.SetSize(0);
      MemoryAfterZero := Stream.Memory;
      CapAfterZero := TMemoryStreamAccess(Stream).Capacity;
      FreedOnSetSize := FreeCountOf(Second) = FreesBefore + 1;

      B := $33;
      Stream.WriteBuffer(B, 1);
      Third := Stream.Memory;
      FreesBefore := FreeCountOf(Third);
    finally
      Obj := Stream;
      Stream.Free;
    end;
    FreedOnDestroy := FreeCountOf(Third) = FreesBefore + 1;
    ObjectFreed := FreeCountOf(Obj) = 1;
  finally
    RemoveMemHook;
  end;

  Check(not AllocOverflow, 'alloc overflow');
  Check(not FreeOverflow, 'free overflow');
  CheckEquals(0, FreeCountOnEmpty, 'empty stream');
  Check(WasAllocated(First, MemoryDelta), 'GetMem');
  Check(MemoryAfterClear = nil, 'Memory after Clear');
  CheckEquals(0, SizeAfterClear, 'Size after Clear');
  CheckEquals(0, PosAfterClear, 'Position after Clear');
  CheckEquals(0, CapAfterClear, 'Capacity after Clear');
  Check(FreedOnClear, 'FreeMem on Clear');

  Check(WasAllocated(Second, MemoryDelta), 'GetMem after Clear');
  Check(MemoryAfterZero = nil, 'Memory after SetSize(0)');
  CheckEquals(0, CapAfterZero, 'Capacity after SetSize(0)');
  Check(FreedOnSetSize, 'FreeMem on SetSize(0)');

  Check(WasAllocated(Third, MemoryDelta), 'GetMem after SetSize(0)');
  Check(FreedOnDestroy, 'FreeMem on Destroy');
  Check(ObjectFreed, 'object FreeMem');
end;

procedure TMemoryStreamTest.TestReallocViaReallocMem;
var
  Stream: TMemoryStream;
  Data, Actual: array of Byte;
  Total, I: Integer;
  FirstPtr, SecondPtr, ThirdPtr, ReallocPtr, Obj: Pointer;
  Capacity1, Capacity2, Capacity3: Integer;
  Reallocs1, Reallocs2, Reallocs3: Integer;
  FreesBefore: Integer;
  Freed: Boolean;
  FoundSecond, FoundThird: Boolean;
begin
  Total := 1 + MemoryDelta + MemoryDelta;
  SetLength(Data, Total);
  SetLength(Actual, Total);
  for I := 0 to Total - 1 do
    Data[I] := Byte(I and $FF);

  FirstPtr := nil;
  SecondPtr := nil;
  ThirdPtr := nil;
  Obj := nil;
  ReallocPtr := nil;

  InstallMemHook;
  try
    Stream := TMemoryStream.Create;
    try
      Stream.WriteBuffer(Data[0], 1);
      FirstPtr := Stream.Memory;
      Capacity1 := TMemoryStreamAccess(Stream).Capacity;
      Reallocs1 := ReallocCount;

      Stream.WriteBuffer(Data[1], MemoryDelta);
      SecondPtr := Stream.Memory;
      Capacity2 := TMemoryStreamAccess(Stream).Capacity;
      Reallocs2 := ReallocCount;
      FoundSecond := FindRealloc(FirstPtr, MemoryDelta * 2, ReallocPtr);
      if FoundSecond and (ReallocPtr <> SecondPtr) then
        FoundSecond := False;

      Stream.WriteBuffer(Data[1 + MemoryDelta], MemoryDelta);
      ThirdPtr := Stream.Memory;
      Capacity3 := TMemoryStreamAccess(Stream).Capacity;
      Reallocs3 := ReallocCount;
      FoundThird := FindRealloc(SecondPtr, MemoryDelta * 3, ReallocPtr);
      if FoundThird and (ReallocPtr <> ThirdPtr) then
        FoundThird := False;

      Stream.Position := 0;
      Stream.ReadBuffer(Actual[0], Total);
      FreesBefore := FreeCountOf(ThirdPtr);
    finally
      Obj := Stream;
      Stream.Free;
    end;
    Freed := FreeCountOf(ThirdPtr) = FreesBefore + 1;
  finally
    RemoveMemHook;
  end;

  Check(not AllocOverflow, 'alloc overflow');
  Check(not FreeOverflow, 'free overflow');
  Check(not ReallocOverflow, 'realloc overflow');
  CheckEquals(MemoryDelta, Capacity1, 'Capacity 1');
  CheckEquals(MemoryDelta * 2, Capacity2, 'Capacity 2');
  CheckEquals(MemoryDelta * 3, Capacity3, 'Capacity 3');
  Check(WasAllocated(FirstPtr, MemoryDelta), 'GetMem');
  CheckEquals(1, AllocCountOfSize(MemoryDelta), 'GetMem count');
  CheckEquals(0, Reallocs1, 'no ReallocMem for the first block');
  CheckEquals(1, Reallocs2, 'first ReallocMem');
  CheckEquals(2, Reallocs3, 'second ReallocMem');
  Check(FoundSecond, 'ReallocMem to 2 * MemoryDelta');
  Check(FoundThird, 'ReallocMem to 3 * MemoryDelta');
  Check(CompareMem(@Data[0], @Actual[0], Total), 'Data');
  Check(Freed, 'FreeMem');
  Check(FreeCountOf(Obj) = 1, 'object FreeMem');
end;

initialization
  RegisterTest('', TMemoryStreamTest.Suite);

end.

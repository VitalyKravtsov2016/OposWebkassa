{ *************************************************************************** }
{                                                                             }
{ Delphi and Kylix Cross-Platform Visual Component Library                    }
{                                                                             }
{ Copyright (c) 1995, 2001 Borland Software Corporation                       }
{                                                                             }
{ *************************************************************************** }


unit TntIniFiles;

{$R-,T-,H+,X+}

interface

uses
  SysUtils, Classes,
  // Tnt
  TntClasses, TntWideStrUtils, TntSysUtils,
  // This
  UserError;

type
  EIniFileException = class(UserException);

  TCustomIniFile = class(TObject)
  private
    FFileName: WideString;
  public
    constructor Create(const FileName: WideString);
    function SectionExists(const Section: WideString): Boolean;
    function ReadString(const Section, Ident, Default: WideString): WideString; virtual; abstract;
    procedure WriteString(const Section, Ident, Value: WideString); virtual; abstract;
    function ReadInteger(const Section, Ident: WideString; Default: Longint): Longint; virtual;
    procedure WriteInteger(const Section, Ident: WideString; Value: Longint); virtual;
    function ReadBool(const Section, Ident: WideString; Default: Boolean): Boolean; virtual;
    procedure WriteBool(const Section, Ident: WideString; Value: Boolean); virtual;
    function ReadBinaryStream(const Section, Name: WideString; Value: TStream): Integer; virtual;
    function ReadDate(const Section, Name: WideString; Default: TDateTime): TDateTime; virtual;
    function ReadDateTime(const Section, Name: WideString; Default: TDateTime): TDateTime; virtual;
    function ReadFloat(const Section, Name: WideString; Default: Double): Double; virtual;
    function ReadTime(const Section, Name: WideString; Default: TDateTime): TDateTime; virtual;
    procedure WriteBinaryStream(const Section, Name: WideString; Value: TStream); virtual;
    procedure WriteDate(const Section, Name: WideString; Value: TDateTime); virtual;
    procedure WriteDateTime(const Section, Name: WideString; Value: TDateTime); virtual;
    procedure WriteFloat(const Section, Name: WideString; Value: Double); virtual;
    procedure WriteTime(const Section, Name: WideString; Value: TDateTime); virtual;
    procedure ReadSection(const Section: WideString; Strings: TTntStrings); virtual; abstract;
    procedure ReadSections(Strings: TTntStrings); virtual; abstract;
    procedure ReadSectionValues(const Section: WideString; Strings: TTntStrings); virtual; abstract;
    procedure EraseSection(const Section: WideString); virtual; abstract;
    procedure DeleteKey(const Section, Ident: WideString); virtual; abstract;
    procedure UpdateFile; virtual; abstract;
    function ValueExists(const Section, Ident: WideString): Boolean;
    property FileName: WideString read FFileName;
  end;

  { TStringHash - used internally by TMemIniFile to optimize searches. }

  PPHashItem = ^PHashItem;
  PHashItem = ^THashItem;
  THashItem = record
    Next: PHashItem;
    Key: WideString;
    Value: Integer;
  end;

  TStringHash = class
  private
    Buckets: array of PHashItem;
  protected
    function Find(const Key: WideString): PPHashItem;
    function HashOf(const Key: WideString): Cardinal; virtual;
  public
    constructor Create(Size: Cardinal = 256);
    destructor Destroy; override;
    procedure Add(const Key: WideString; Value: Integer);
    procedure Clear;
    procedure Remove(const Key: WideString);
    function Modify(const Key: WideString; Value: Integer): Boolean;
    function ValueOf(const Key: WideString): Integer;
  end;

  { THashedStringList - A TTntStringList that uses TStringHash to improve the
    speed of Find }
  THashedStringList = class(TTntStringList)
  private
    FValueHash: TStringHash;
    FNameHash: TStringHash;
    FValueHashValid: Boolean;
    FNameHashValid: Boolean;
    procedure UpdateValueHash;
    procedure UpdateNameHash;
  protected
    procedure Changed; override;
  public
    destructor Destroy; override;
    function IndexOf(const S: WideString): Integer; override;
    function IndexOfName(const Name: WideString): Integer; override;
  end;

  { TMemIniFile - loads an entire INI file into memory and allows all
    operations to be performed on the memory image.  The image can then
    be written out to the disk file }

  TMemIniFile = class(TCustomIniFile)
  private
    FSections: TTntStringList;
    function AddSection(const Section: WideString): TTntStrings;
    function GetCaseSensitive: Boolean;
    procedure LoadValues;
    procedure SetCaseSensitive(Value: Boolean);
  public
    constructor Create(const FileName: WideString);
    destructor Destroy; override;
    procedure Clear;
    procedure DeleteKey(const Section, Ident: WideString); override;
    procedure EraseSection(const Section: WideString); override;
    procedure GetStrings(List: TTntStrings);
    procedure ReadSection(const Section: WideString; Strings: TTntStrings); override;
    procedure ReadSections(Strings: TTntStrings); override;
    procedure ReadSectionValues(const Section: WideString; Strings: TTntStrings); override;
    function ReadString(const Section, Ident, Default: WideString): WideString; override;
    procedure Rename(const FileName: WideString; Reload: Boolean);
    procedure SetStrings(List: TTntStrings);
    procedure UpdateFile; override;
    procedure WriteString(const Section, Ident, Value: WideString); override;
    property CaseSensitive: Boolean read GetCaseSensitive write SetCaseSensitive;
  end;

{$IFDEF MSWINDOWS}
  { TTntIniFile - Encapsulates the Windows INI file interface
    (Get/SetPrivateProfileXXX functions) }

  TTntIniFile = class(TCustomIniFile)
  public
    destructor Destroy; override;
    function ReadString(const Section, Ident, Default: WideString): WideString; override;
    procedure WriteString(const Section, Ident, Value: WideString); override;
    procedure ReadSection(const Section: WideString; Strings: TTntStrings); override;
    procedure ReadSections(Strings: TTntStrings); override;
    procedure ReadSectionValues(const Section: WideString; Strings: TTntStrings); override;
    procedure EraseSection(const Section: WideString); override;
    procedure DeleteKey(const Section, Ident: WideString); override;
    procedure UpdateFile; override;
  end;
{$ELSE}
    TTntIniFile = class(TMemIniFile)
    public
      destructor Destroy; override;
    end;
{$ENDIF}


implementation

uses RTLConsts
{$IFDEF MSWINDOWS}
  , Windows
{$ENDIF};

{ TCustomIniFile }

constructor TCustomIniFile.Create(const FileName: WideString);
begin
  FFileName := FileName;
end;

function TCustomIniFile.SectionExists(const Section: WideString): Boolean;
var
  S: TTntStrings;
begin
  S := TTntStringList.Create;
  try
    ReadSection(Section, S);
    Result := S.Count > 0;
  finally
    S.Free;
  end;
end;

function TCustomIniFile.ReadInteger(const Section, Ident: WideString;
  Default: Longint): Longint;
var
  IntStr: WideString;
begin
  IntStr := ReadString(Section, Ident, '');
  if (Length(IntStr) > 2) and (IntStr[1] = '0') and
     ((IntStr[2] = 'X') or (IntStr[2] = 'x')) then
    IntStr := '$' + Copy(IntStr, 3, Maxint);
  Result := StrToIntDef(IntStr, Default);
end;

procedure TCustomIniFile.WriteInteger(const Section, Ident: WideString; Value: Longint);
begin
  WriteString(Section, Ident, IntToStr(Value));
end;

function TCustomIniFile.ReadBool(const Section, Ident: WideString;
  Default: Boolean): Boolean;
begin
  Result := ReadInteger(Section, Ident, Ord(Default)) <> 0;
end;

function TCustomIniFile.ReadDate(const Section, Name: WideString; Default: TDateTime): TDateTime;
var
  DateStr: WideString;
begin
  DateStr := ReadString(Section, Name, '');
  Result := Default;
  if DateStr <> '' then
  try
    Result := StrToDate(DateStr);
  except
    on EConvertError do
      // Ignore EConvertError exceptions
    else
      raise;
  end;
end;

function TCustomIniFile.ReadDateTime(const Section, Name: WideString; Default: TDateTime): TDateTime;
var
  DateStr: WideString;
begin
  DateStr := ReadString(Section, Name, '');
  Result := Default;
  if DateStr <> '' then
  try
    Result := StrToDateTime(DateStr);
  except
    on EConvertError do
      // Ignore EConvertError exceptions
    else
      raise;
  end;
end;

function TCustomIniFile.ReadFloat(const Section, Name: WideString; Default: Double): Double;
var
  FloatStr: WideString;
begin
  FloatStr := ReadString(Section, Name, '');
  Result := Default;
  if FloatStr <> '' then
  try
    Result := StrToFloat(FloatStr);
  except
    on EConvertError do
      // Ignore EConvertError exceptions
    else
      raise;
  end;
end;

function TCustomIniFile.ReadTime(const Section, Name: WideString; Default: TDateTime): TDateTime;
var
  TimeStr: WideString;
begin
  TimeStr := ReadString(Section, Name, '');
  Result := Default;
  if TimeStr <> '' then
  try
    Result := StrToTime(TimeStr);
  except
    on EConvertError do
      // Ignore EConvertError exceptions
    else
      raise;
  end;
end;

procedure TCustomIniFile.WriteDate(const Section, Name: WideString; Value: TDateTime);
begin
  WriteString(Section, Name, DateToStr(Value));
end;

procedure TCustomIniFile.WriteDateTime(const Section, Name: WideString; Value: TDateTime);
begin
  WriteString(Section, Name, DateTimeToStr(Value));
end;

procedure TCustomIniFile.WriteFloat(const Section, Name: WideString; Value: Double);
begin
  WriteString(Section, Name, FloatToStr(Value));
end;

procedure TCustomIniFile.WriteTime(const Section, Name: WideString; Value: TDateTime);
begin
  WriteString(Section, Name, TimeToStr(Value));
end;

procedure TCustomIniFile.WriteBool(const Section, Ident: WideString; Value: Boolean);
const
  Values: array[Boolean] of WideString = ('0', '1');
begin
  WriteString(Section, Ident, Values[Value]);
end;

function TCustomIniFile.ValueExists(const Section, Ident: WideString): Boolean;
var
  S: TTntStrings;
begin
  S := TTntStringList.Create;
  try
    ReadSection(Section, S);
    Result := S.IndexOf(Ident) > -1;
  finally
    S.Free;
  end;
end;

function TCustomIniFile.ReadBinaryStream(const Section, Name: WideString;
  Value: TStream): Integer;
var
  Pos: Integer;
  Text: AnsiString;
  Stream: TTntMemoryStream;
begin
  Text := ReadString(Section, Name, '');
  if Text <> '' then
  begin
    if Value is TTntMemoryStream then
      Stream := TTntMemoryStream(Value)
    else
      Stream := TTntMemoryStream.Create;

    try
      Pos := Stream.Position;
      Stream.SetSize(Stream.Size + Length(Text) div 2);
      HexToBin(PChar(Text), PChar(Integer(Stream.Memory) + Stream.Position), Length(Text) div 2);
      Stream.Position := Pos;
      if Value <> Stream then
        Value.CopyFrom(Stream, Length(Text) div 2);
      Result := Stream.Size - Pos;
    finally
      if Value <> Stream then
        Stream.Free;
    end;
  end
  else
    Result := 0;
end;

procedure TCustomIniFile.WriteBinaryStream(const Section, Name: WideString;
  Value: TStream);
var
  Text: AnsiString;
  Stream: TTntMemoryStream;
begin
  SetLength(Text, (Value.Size - Value.Position) * 2);
  if Length(Text) > 0 then
  begin
    if Value is TTntMemoryStream then
      Stream := TTntMemoryStream(Value)
    else
      Stream := TTntMemoryStream.Create;

    try
      if Stream <> Value then
      begin
        Stream.CopyFrom(Value, Value.Size - Value.Position);
        Stream.Position := 0;
      end;
      BinToHex(PChar(Integer(Stream.Memory) + Stream.Position), PChar(Text),
        Stream.Size - Stream.Position);
    finally
      if Value <> Stream then
        Stream.Free;
    end;
  end;
  WriteString(Section, Name, Text);
end;

{ TStringHash }

procedure TStringHash.Add(const Key: WideString; Value: Integer);
var
  Hash: Integer;
  Bucket: PHashItem;
begin
  Hash := HashOf(Key) mod Cardinal(Length(Buckets));
  New(Bucket);
  Bucket^.Key := Key;
  Bucket^.Value := Value;
  Bucket^.Next := Buckets[Hash];
  Buckets[Hash] := Bucket;
end;

procedure TStringHash.Clear;
var
  I: Integer;
  P, N: PHashItem;
begin
  for I := 0 to Length(Buckets) - 1 do
  begin
    P := Buckets[I];
    while P <> nil do
    begin
      N := P^.Next;
      Dispose(P);
      P := N;
    end;
    Buckets[I] := nil;
  end;
end;

constructor TStringHash.Create(Size: Cardinal);
begin
  inherited Create;
  SetLength(Buckets, Size);
end;

destructor TStringHash.Destroy;
begin
  Clear;
  inherited Destroy;
end;

function TStringHash.Find(const Key: WideString): PPHashItem;
var
  Hash: Integer;
begin
  Hash := HashOf(Key) mod Cardinal(Length(Buckets));
  Result := @Buckets[Hash];
  while Result^ <> nil do
  begin
    if Result^.Key = Key then
      Exit
    else
      Result := @Result^.Next;
  end;
end;

function TStringHash.HashOf(const Key: WideString): Cardinal;
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to Length(Key) do
    Result := ((Result shl 2) or (Result shr (SizeOf(Result) * 8 - 2))) xor
      Ord(Key[I]);
end;

function TStringHash.Modify(const Key: WideString; Value: Integer): Boolean;
var
  P: PHashItem;
begin
  P := Find(Key)^;
  if P <> nil then
  begin
    Result := True;
    P^.Value := Value;
  end
  else
    Result := False;
end;

procedure TStringHash.Remove(const Key: WideString);
var
  P: PHashItem;
  Prev: PPHashItem;
begin
  Prev := Find(Key);
  P := Prev^;
  if P <> nil then
  begin
    Prev^ := P^.Next;
    Dispose(P);
  end;
end;

function TStringHash.ValueOf(const Key: WideString): Integer;
var
  P: PHashItem;
begin
  P := Find(Key)^;
  if P <> nil then
    Result := P^.Value
  else
    Result := -1;
end;

{ THashedStringList }

procedure THashedStringList.Changed;
begin
  inherited Changed;
  FValueHashValid := False;
  FNameHashValid := False;
end;

destructor THashedStringList.Destroy;
begin
  FValueHash.Free;
  FNameHash.Free;
  inherited Destroy;
end;

function THashedStringList.IndexOf(const S: WideString): Integer;
begin
  UpdateValueHash;
  if not CaseSensitive then
    Result :=  FValueHash.ValueOf(Tnt_WideUpperCase(S))
  else
    Result :=  FValueHash.ValueOf(S);
end;

function THashedStringList.IndexOfName(const Name: WideString): Integer;
begin
  UpdateNameHash;
  if not CaseSensitive then
    Result := FNameHash.ValueOf(Tnt_WideUpperCase(Name))
  else
    Result := FNameHash.ValueOf(Name);
end;

procedure THashedStringList.UpdateNameHash;
var
  I: Integer;
  P: Integer;
  Key: WideString;
begin
  if FNameHashValid then Exit;
  
  if FNameHash = nil then
    FNameHash := TStringHash.Create
  else
    FNameHash.Clear;
  for I := 0 to Count - 1 do
  begin
    Key := Get(I);
    P := AnsiPos(NameValueSeparator, Key);
    if P <> 0 then
    begin
      if not CaseSensitive then
        Key := Tnt_WideUpperCase(Copy(Key, 1, P - 1))
      else
        Key := Copy(Key, 1, P - 1);
      FNameHash.Add(Key, I);
    end;
  end;
  FNameHashValid := True;
end;

procedure THashedStringList.UpdateValueHash;
var
  I: Integer;
begin
  if FValueHashValid then Exit;
  
  if FValueHash = nil then
    FValueHash := TStringHash.Create
  else
    FValueHash.Clear;
  for I := 0 to Count - 1 do
    if not CaseSensitive then
      FValueHash.Add(Tnt_WideUpperCase(Self[I]), I)
    else
      FValueHash.Add(Self[I], I);
  FValueHashValid := True;
end;

{ TMemIniFile }

constructor TMemIniFile.Create(const FileName: WideString);
begin
  inherited Create(FileName);
  FSections := THashedStringList.Create;
{$IFDEF LINUX}
  FSections.CaseSensitive := True;
{$ENDIF}
  LoadValues;
end;

destructor TMemIniFile.Destroy;
begin
  if FSections <> nil then
    Clear;
  FSections.Free;
  inherited Destroy;
end;

function TMemIniFile.AddSection(const Section: WideString): TTntStrings;
begin
  Result := THashedStringList.Create;
  try
    THashedStringList(Result).CaseSensitive := CaseSensitive;
    FSections.AddObject(Section, Result);
  except
    Result.Free;
    raise;
  end;
end;

procedure TMemIniFile.Clear;
var
  I: Integer;
begin
  for I := 0 to FSections.Count - 1 do
    TObject(FSections.Objects[I]).Free;
  FSections.Clear;
end;

procedure TMemIniFile.DeleteKey(const Section, Ident: WideString);
var
  I, J: Integer;
  Strings: TTntStrings;
begin
  I := FSections.IndexOf(Section);
  if I >= 0 then
  begin
    Strings := TTntStrings(FSections.Objects[I]);
    J := Strings.IndexOfName(Ident);
    if J >= 0 then
      Strings.Delete(J);
  end;
end;

procedure TMemIniFile.EraseSection(const Section: WideString);
var
  I: Integer;
begin
  I := FSections.IndexOf(Section);
  if I >= 0 then
  begin
    TTntStrings(FSections.Objects[I]).Free;
    FSections.Delete(I);
  end;
end;

function TMemIniFile.GetCaseSensitive: Boolean;
begin
  Result := FSections.CaseSensitive;
end;

procedure TMemIniFile.GetStrings(List: TTntStrings);
var
  I, J: Integer;
  Strings: TTntStrings;
begin
  List.BeginUpdate;
  try
    for I := 0 to FSections.Count - 1 do
    begin
      List.Add('[' + FSections[I] + ']');
      Strings := TTntStrings(FSections.Objects[I]);
      for J := 0 to Strings.Count - 1 do List.Add(Strings[J]);
      List.Add('');
    end;
  finally
    List.EndUpdate;
  end;
end;

procedure TMemIniFile.LoadValues;
var
  List: TTntStringList;
begin
  if (FileName <> '') and FileExists(FileName) then
  begin
    List := TTntStringList.Create;
    try
      List.LoadFromFile(FileName);
      SetStrings(List);
    finally
      List.Free;
    end;
  end
  else
    Clear;
end;

procedure TMemIniFile.ReadSection(const Section: WideString;
  Strings: TTntStrings);
var
  I, J: Integer;
  SectionStrings: TTntStrings;
begin
  Strings.BeginUpdate;
  try
    Strings.Clear;
    I := FSections.IndexOf(Section);
    if I >= 0 then
    begin
      SectionStrings := TTntStrings(FSections.Objects[I]);
      for J := 0 to SectionStrings.Count - 1 do
        Strings.Add(SectionStrings.Names[J]);
    end;
  finally
    Strings.EndUpdate;
  end;
end;

procedure TMemIniFile.ReadSections(Strings: TTntStrings);
begin
  Strings.Assign(FSections);
end;

procedure TMemIniFile.ReadSectionValues(const Section: WideString;
  Strings: TTntStrings);
var
  I: Integer;
begin
  Strings.BeginUpdate;
  try
    Strings.Clear;
    I := FSections.IndexOf(Section);
    if I >= 0 then
      Strings.Assign(TTntStrings(FSections.Objects[I]));
  finally
    Strings.EndUpdate;
  end;
end;

function TMemIniFile.ReadString(const Section, Ident,
  Default: WideString): WideString;
var
  I: Integer;
  Strings: TTntStrings;
begin
  I := FSections.IndexOf(Section);
  if I >= 0 then
  begin
    Strings := TTntStrings(FSections.Objects[I]);
    I := Strings.IndexOfName(Ident);
    if I >= 0 then
    begin
      Result := Copy(Strings[I], Length(Ident) + 2, Maxint);
      Exit;
    end;
  end;
  Result := Default;
end;

procedure TMemIniFile.Rename(const FileName: WideString; Reload: Boolean);
begin
  FFileName := FileName;
  if Reload then
    LoadValues;
end;

procedure TMemIniFile.SetCaseSensitive(Value: Boolean);
var
  I: Integer;
begin
  if Value <> FSections.CaseSensitive then
  begin
    FSections.CaseSensitive := Value;
    for I := 0 to FSections.Count - 1 do
      with THashedStringList(FSections.Objects[I]) do
      begin
        CaseSensitive := Value;
        Changed;
      end;
    THashedStringList(FSections).Changed;
  end;
end;

procedure TMemIniFile.SetStrings(List: TTntStrings);
var
  I, J: Integer;
  S: WideString;
  Strings: TTntStrings;
begin
  Clear;
  Strings := nil;
  for I := 0 to List.Count - 1 do
  begin
    S := Trim(List[I]);
    if (S <> '') and (S[1] <> ';') then
      if (S[1] = '[') and (S[Length(S)] = ']') then
      begin
        Delete(S, 1, 1);
        SetLength(S, Length(S)-1);
        Strings := AddSection(Trim(S));
      end
      else
        if Strings <> nil then
        begin
          J := Pos('=', S);
          if J > 0 then // remove spaces before and after '='
            Strings.Add(Trim(Copy(S, 1, J-1)) + '=' + Trim(Copy(S, J+1, MaxInt)) )
          else
            Strings.Add(S);
        end;
  end;
end;

procedure TMemIniFile.UpdateFile;
var
  List: TTntStringList;
begin
  List := TTntStringList.Create;
  try
    GetStrings(List);
    List.SaveToFile(FFileName);
  finally
    List.Free;
  end;
end;

procedure TMemIniFile.WriteString(const Section, Ident, Value: WideString);
var
  I: Integer;
  S: WideString;
  Strings: TTntStrings;
begin
  I := FSections.IndexOf(Section);
  if I >= 0 then
    Strings := TTntStrings(FSections.Objects[I])
  else
    Strings := AddSection(Section);
  S := Ident + '=' + Value;
  I := Strings.IndexOfName(Ident);
  if I >= 0 then
    Strings[I] := S
  else
    Strings.Add(S);
end;

{$IFDEF MSWINDOWS}
{ TTntIniFile }

destructor TTntIniFile.Destroy;
begin
  UpdateFile;         // flush changes to disk
  inherited Destroy;
end;

function TTntIniFile.ReadString(const Section, Ident, Default: WideString): WideString;
var
  Buffer: array[0..2047] of WideChar;
begin
  SetString(Result, Buffer, GetPrivateProfileStringW(PWideChar(Section),
    PWideChar(Ident), PWideChar(Default), Buffer, SizeOf(Buffer), PWideChar(FFileName)));
end;

procedure TTntIniFile.WriteString(const Section, Ident, Value: WideString);
begin
  if not WritePrivateProfileStringW(PWideChar(Section), PWideChar(Ident),
                                   PWideChar(Value), PWideChar(FFileName)) then
    raise EIniFileException.CreateResFmt(@SIniFileWriteError, [FileName]);
end;

procedure TTntIniFile.ReadSections(Strings: TTntStrings);
const
  BufSize = 16384;
var
  Buffer, P: PWideChar;
begin
  GetMem(Buffer, BufSize * Sizeof(WideChar));
  try
    Strings.BeginUpdate;
    try
      Strings.Clear;
      if GetPrivateProfileStringW(nil, nil, nil, Buffer, BufSize,
        PWideChar(FFileName)) <> 0 then
      begin
        P := Buffer;
        while P^ <> #0 do
        begin
          Strings.Add(P);
          Inc(P, WStrLen(P) + 1);
        end;
      end;
    finally
      Strings.EndUpdate;
    end;
  finally
    FreeMem(Buffer, BufSize * Sizeof(WideChar));
  end;
end;

procedure TTntIniFile.ReadSection(const Section: WideString; Strings: TTntStrings);
const
  BufSize = 16384;
var
  Buffer, P: PWideChar;
begin
  GetMem(Buffer, BufSize * Sizeof(WideChar));
  try
    Strings.BeginUpdate;
    try
      Strings.Clear;
      if GetPrivateProfileStringW(PWideChar(Section), nil, nil, Buffer, BufSize,
        PWideChar(FFileName)) <> 0 then
      begin
        P := Buffer;
        while P^ <> #0 do
        begin
          Strings.Add(P);
          Inc(P, WStrLen(P) + 1);
        end;
      end;
    finally
      Strings.EndUpdate;
    end;
  finally
    FreeMem(Buffer, BufSize * Sizeof(WideChar));
  end;
end;

procedure TTntIniFile.ReadSectionValues(const Section: WideString; Strings: TTntStrings);
var
  KeyList: TTntStringList;
  I: Integer;
begin
  KeyList := TTntStringList.Create;
  try
    ReadSection(Section, KeyList);
    Strings.BeginUpdate;
    try
      Strings.Clear;
      for I := 0 to KeyList.Count - 1 do
        Strings.Add(KeyList[I] + '=' + ReadString(Section, KeyList[I], ''))
    finally
      Strings.EndUpdate;
    end;
  finally
    KeyList.Free;
  end;
end;

procedure TTntIniFile.EraseSection(const Section: WideString);
begin
  if not WritePrivateProfileStringW(PWideChar(Section), nil, nil, PWideChar(FFileName)) then
    raise EIniFileException.CreateResFmt(@SIniFileWriteError, [FileName]);
end;

procedure TTntIniFile.DeleteKey(const Section, Ident: WideString);
begin
  WritePrivateProfileStringW(PWideChar(Section), PWideChar(Ident), nil, PWideChar(FFileName));
end;

procedure TTntIniFile.UpdateFile;
begin
  WritePrivateProfileStringW(nil, nil, nil, PWideChar(FFileName));
end;
{$ELSE}

destructor TTntIniFile.Destroy;
begin
  UpdateFile;
  inherited Destroy;
end;

{$ENDIF}

end.

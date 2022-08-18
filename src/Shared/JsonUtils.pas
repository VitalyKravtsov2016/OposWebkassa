unit JsonUtils;

interface

uses
  // VCL
  Windows, Classes, SysUtils, Variants, TypInfo, Types, ObjAuto;

type
  TChars = set of Char;

  { TJsonWriter }

  TJsonWriter = class
  private
    FStream: TStream;
    function WriteProperty(Instance: TPersistent; PropInfo: PPropInfo;
      const Prefix: string): Boolean;
    procedure WriteWideString(const Value: WideString);
    procedure WriteMinStr(const LocaleStr: string;
      const UTF8Str: UTF8String);
    procedure Write(const Buf; Count: Integer);
    procedure WriteStr(Value: string);
    procedure WriteCollection(Value: TCollection; const Prefix: string);
    procedure WriteProperties(Instance: TPersistent; const Prefix: string);
  public
    constructor Create(AStream: TStream);
    procedure WriteObject(Instance: TPersistent);
  end;

  { TJsonReader }

  TJsonReader = class
  private
    FStream: TStream;
    FLevel: Integer;

    function EOF: Boolean;
    function ReadPropName: WideString;
    function ReadWideString: WideString;
    function ReadForChars(Chars: TChars): WideString;
    function ReadForChar(ExpectedChar: Char): WideString;

    procedure ReadProperty(Instance: TPersistent);
    procedure ReadPropValue(Instance: TPersistent; PropInfo: Pointer);
    procedure ReadCollection(Collection: TCollection);
    procedure ReadStrings(Strings: TStrings);
    function ReadChar: Char;
    function NextValue: Char;
    function EndOfClass: Boolean;
    function EndOfCollection: Boolean;
    function ReadWideString2: WideString;
    procedure SkipPropValue;
  public
    constructor Create(AStream: TStream);
    procedure ReadObject(Instance: TPersistent);
    procedure StepBack;
  end;

function ObjectToJson(Instance: TPersistent): string;
procedure JsonToObject(const Text: string; Instance: TPersistent);

implementation

const
  //CRLF = #13#10;
  //Indentation = #9;

  CRLF = '';
  Indentation = '';

function ObjectToJson(Instance: TPersistent): string;
var
  Writer: TJsonWriter;
  Stream: TMemoryStream;
begin
  Result := '';
  Stream := TMemoryStream.Create;
  Writer := TJsonWriter.Create(Stream);
  try
    Writer.WriteObject(Instance);
    SetLength(Result, Stream.Size);
    Move(Stream.Memory^, Result[1], Stream.Size);
  finally
    Writer.Free;
    Stream.Free;
  end;
end;

procedure JsonToObject(const Text: string; Instance: TPersistent);
var
  Reader: TJsonReader;
  Stream: TMemoryStream;
begin
  if Length(Text) = 0 then Exit;

  Stream := TMemoryStream.Create;
  Reader := TJsonReader.Create(Stream);
  try
    Stream.Write(Text[1], Length(Text));
    Stream.Position := 0;

    Reader.ReadObject(Instance);
  finally
    Reader.Free;
    Stream.Free;
  end;
end;


{ TJsonWriter }

constructor TJsonWriter.Create(AStream: TStream);
begin
  inherited Create;
  FStream := AStream;
end;

procedure TJsonWriter.WriteObject(Instance: TPersistent);
begin
  WriteStr('{' + CRLF);
  WriteProperties(Instance, Indentation);
  WriteStr('}');
end;

procedure TJsonWriter.WriteProperties(Instance: TPersistent; const Prefix: string);
var
  I, Count: Integer;
  PropInfo: PPropInfo;
  PropList: PPropList;
begin
  Count := GetTypeData(Instance.ClassInfo)^.PropCount;
  if Count > 0 then
  begin
    GetMem(PropList, Count * SizeOf(Pointer));
    try
      GetPropInfos(Instance.ClassInfo, PropList);
      for I := 0 to Count - 1 do
      begin
        PropInfo := PropList^[I];
        if PropInfo = nil then
          Break;

        if IsStoredProp(Instance, PropInfo) then
        begin
          if (WriteProperty(Instance, PropInfo, Prefix)) then
          begin
            if (i <> (Count-1)) then
            begin
              WriteStr(',' + CRLF);
            end;
          end;
          if (i = (Count-1)) then
          begin
            WriteStr(CRLF);
          end;
        end;
      end;
    finally
      FreeMem(PropList, Count * SizeOf(Pointer));
    end;
  end;
end;

procedure TJsonWriter.Write(const Buf; Count: Longint);
begin
  FStream.Write(Buf, Count);
end;

procedure TJsonWriter.WriteStr(Value: string);
var
  L: Integer;
begin
  L := Length(Value);
  if L > 255 then L := 255;
  Write(Value[1], L);
end;

procedure TJsonWriter.WriteCollection(Value: TCollection; const Prefix: string);
var
  I: Integer;
begin
  if Value.Count = 0 then Exit;

  if Value <> nil then
  begin
    for I := 0 to Value.Count - 1 do
    begin
      WriteStr(Prefix + '{' + CRLF);
      WriteProperties(Value.Items[I], Prefix + Indentation);
      WriteStr(Prefix + '}');
      if i <> (Value.Count - 1) then
      begin
        WriteStr(',');
      end;
      WriteStr(CRLF);
    end;
  end;
end;

procedure TJsonWriter.WriteMinStr(const LocaleStr: string; const UTF8Str: UTF8String);
var
  L: Integer;
begin
  if LocaleStr <> UTF8Str then
  begin
    L := Length(UTF8Str);
    Write(Pointer(UTF8Str)^, L);
  end
  else
  begin
    L := Length(LocaleStr);
    Write(Pointer(LocaleStr)^, L);
  end;
end;

procedure TJsonWriter.WriteWideString(const Value: WideString);
var
  L: Integer;
  Utf8Str: UTF8String;
begin
  Utf8Str := Utf8Encode(Value);
  if Length(Utf8Str) < (Length(Value) * SizeOf(WideChar)) then
    WriteMinStr(Value, Utf8Str)
  else
  begin
    L := Length(Value);
    Write(Pointer(Value)^, L * 2);
  end;
end;

function TJsonWriter.WriteProperty(Instance: TPersistent; PropInfo: PPropInfo;
  const Prefix: string): Boolean;
var
  i: Integer;
  V: Variant;
  Text: WideString;
  Value: TObject;
  Strings: TStrings;
  PropType: PTypeInfo;
  PropName: WideString;
begin
  Result := False;
  PropName := PPropInfo(PropInfo)^.Name;
  if AnsiCompareText(PropName, '_Type') = 0 then
    PropName := 'Type';

  PropType := PropInfo^.PropType^;
  case PropType^.Kind of
    tkString, tkLString, tkWString:
    begin
      WriteStr(Prefix + '"' + PropName + '":');
      Text := GetWideStrProp(Instance, PropInfo);
      WriteWideString('"' + Text + '"');
      Result := True;
    end;

    tkClass:
    begin
      Value := TObject(GetOrdProp(Instance, PropInfo));
      if Value = nil then Exit;

      if Value is TCollection then
      begin
        if TCollection(Value).Count > 0 then
        begin
          WriteStr(Prefix + '"' + PropName + '":[' + CRLF);
          WriteCollection(TCollection(Value), Prefix + Indentation);
          WriteStr(Prefix + ']');
          Result := True;
        end;
      end else
      begin
        if Value is TStrings then
        begin
          Strings :=  Value as TStrings;
          if Strings.Count > 0 then
          begin
            WriteStr(Prefix + '"' + PropName + '":[' + CRLF);
            for i := 0 to Strings.Count-1 do
            begin
              WriteStr(Prefix + Indentation + '"' + Strings[i] + '"');
            end;
            WriteStr(Prefix + ']');
          end;
          Result := True;
        end else
        begin
          if Value is TPersistent then
          begin
            WriteStr(Prefix + '"' + PropName + '":{' + CRLF);
            WriteProperties(TPersistent(Value), Prefix + Indentation);
            WriteStr(Prefix + '}');
            Result := True;
          end;
        end;
      end;
    end;
  else
    WriteStr(Prefix + '"' + PropName + '":');
    V := GetPropValue(Instance, PropInfo);
    WriteWideString(LowerCase(VarToWideStr(V)));
    Result := True;
  end;
end;

{ TJsonReader }

constructor TJsonReader.Create(AStream: TStream);
begin
  inherited Create;
  FStream := AStream;
end;

procedure TJsonReader.ReadObject(Instance: TPersistent);
begin
  FLevel := 0;
  while not EOF do
  begin
    ReadProperty(Instance);
    if FLevel = 0 then Break;
  end;
end;

function TJsonReader.EOF: Boolean;
begin
  Result := FStream.Position = FStream.Size;
end;

function TJsonReader.ReadChar: Char;
begin
  FStream.ReadBuffer(Result, 1);
  if Result = '{' then Inc(FLevel);
  if Result = '}' then Dec(FLevel);
end;

function TJsonReader.ReadForChar(ExpectedChar: Char): WideString;
var
  C: Char;
begin
  Result := '';
  while not EOF do
  begin
    C := ReadChar;
    if C = ExpectedChar then Break;
    Result := Result + C;
  end;
  Result := UTF8Decode(Result);
end;

function TJsonReader.ReadForChars(Chars: TChars): WideString;
var
  C: Char;
begin
  Result := '';
  while not EOF do
  begin
    C := ReadChar;
    if C in Chars then Break;
    Result := Result + C;
  end;
  Result := UTF8Decode(Result);
end;

function TJsonReader.ReadPropName: WideString;
begin
  ReadForChar('"');
  Result := ReadForChar('"');
  ReadForChar(':');

  if AnsiCompareText(Result, 'type') = 0 then
    Result := '_Type';
end;

function TJsonReader.ReadWideString: WideString;
begin
  Result := ReadForChars([',', '}', ']']);
  FStream.Seek(-1, 1);

  Result := Trim(Result);
  if Length(Result) > 0 then
  begin
    if (Result[1] = '"')and(Result[Length(Result)] = '"') then
      Result := Copy(Result, 2, Length(Result)-2);
  end;
end;

function TJsonReader.ReadWideString2: WideString;
var
  C: Char;
  Prev: Char;
begin
  Prev := #0;
  Result := '';

  ReadForChar('"');
  while not EOF do
  begin
    C := ReadChar;
    if C in [#13, #10, '}', ']'] then Break;
    if (C = '"')and(Prev <> '\') then
    begin
      Break;
    end;
    Result := Result + C;
    Prev := C;
  end;
  Result := StringReplace(Result, '\"', '"', [rfReplaceAll, rfIgnoreCase]);
  Result := UTF8Decode(Result);
end;

procedure TJsonReader.SkipPropValue;
var
  C: Char;
  ALevel: Integer;
  NLevel: Integer;
begin
  ALevel := 0;
  NLevel := 0;
  while not EOF do
  begin
    C := ReadChar;
    case C of
      '[': Inc(ALevel);
      ']': Dec(ALevel);
      '{': Inc(NLevel);
      '}': Dec(NLevel);
    end;
    if (ALevel = 0)and(NLevel = 0) then
    begin
      if C = ',' then Break;
      if (C = '}') or (C = ']') then
      begin
        Break;
      end;
    end;
  end;
end;

procedure TJsonReader.StepBack;
begin
  FStream.Seek(-1, 1);
end;

procedure TJsonReader.ReadProperty(Instance: TPersistent);
var
  PropName: string;
  PropInfo: PPropInfo;
begin
  while not EOF do
  begin
    if EndOfClass then Break;
    if EndOfCollection then Break;

    PropName := ReadPropName;
    PropInfo := GetPropInfo(Instance.ClassInfo, PropName);
    if PropInfo <> nil then
    begin
      ReadPropValue(Instance, PropInfo);
    end else
    begin
      SkipPropValue;
    end;
  end;
end;

function TJsonReader.NextValue: Char;
begin
  repeat
    Result := ReadChar;
  until (Result > #$20)and(Result <= #$FF);
  FStream.Seek(-1, 1);
end;

procedure TJsonReader.ReadPropValue(Instance: TPersistent; PropInfo: Pointer);
var
  Item: TObject;
  PropType: PTypeInfo;
begin
  if PPropInfo(PropInfo)^.SetProc = nil then Exit;

  PropType := PPropInfo(PropInfo)^.PropType^;
  case PropType^.Kind of
    tkInteger:
      SetOrdProp(Instance, PropInfo, StrToInt(ReadWideString));
    tkChar:
      SetOrdProp(Instance, PropInfo, Ord(ReadWideString[1]));
    tkEnumeration:
      SetOrdProp(Instance, PropInfo, GetEnumValue(PropType, ReadWideString));
    tkFloat:
      SetFloatProp(Instance, PropInfo, StrToFloat(ReadWideString));
    tkString, tkLString:
      SetStrProp(Instance, PropInfo, ReadWideString2);
    tkWString:
      SetWideStrProp(Instance, PropInfo, ReadWideString2);
    //tkSet:
     // SetOrdProp(Instance, PropInfo, ReadSet(PropType));
    tkInt64:
      SetInt64Prop(Instance, PropInfo, StrToInt64(ReadWideString));
    tkClass:
    begin
      Item := TObject(GetOrdProp(Instance, PropInfo));
      if NextValue = '[' then
      begin
        ReadChar;
        if Item is TCollection then
        begin
          ReadCollection(TCollection(Item));
        end;
        if Item is TStrings then
        begin
          ReadStrings(TStrings(Item));
        end;
      end
      else
        //SetObjectIdent(Instance, PropInfo, ReadIdent);
        ReadProperty(TPersistent(GetOrdProp(Instance, PropInfo)));
      end;
  end;
end;

function TJsonReader.EndOfClass: Boolean;
begin
  Result := NextValue = '}';
  if Result then ReadChar;
end;

function TJsonReader.EndOfCollection: Boolean;
begin
  Result := NextValue = ']';
  if Result then ReadChar;
end;

procedure TJsonReader.ReadCollection(Collection: TCollection);
begin
  Collection.BeginUpdate;
  try
    if not EOF then Collection.Clear;

    while not EOF do
    begin
      if EndOfCollection then Break;
      ReadProperty(Collection.Add);
    end;
  finally
    Collection.EndUpdate;
  end;
end;

procedure TJsonReader.ReadStrings(Strings: TStrings);
begin
  Strings.BeginUpdate;
  try
    if not EOF then Strings.Clear;

    while not EOF do
    begin
      if NextValue = ',' then
        ReadChar;
      if EndOfCollection then Break;

      Strings.Add(ReadWideString2);
    end;
  finally
    Strings.EndUpdate;
  end;
end;

end.

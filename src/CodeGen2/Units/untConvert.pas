unit untConvert;

interface

uses
  // VCL
  Classes, SysUtils,
  // This
  TntClasses, TntStdCtrls, TntRegistry, TntSysUtils,
  StringUtils, FileUtils;

type
  { TCodeGen }

  TCodeGen = class
  public
    procedure Execute(const FileName: string);
  end;

procedure ConvertFile(const FileName: string);

implementation

procedure ConvertFile(const FileName: string);
var
  CodeGen: TCodeGen;
begin
  CodeGen := TCodeGen.Create;
  try
    CodeGen.Execute(FileName);
  finally
    CodeGen.Free;
  end;
end;

{ Вспомогательные функции }

function IsFunction(const Data: string): Boolean;
begin
  Result := Pos('function ', Trim(Data)) = 1;
end;

function IsProcedure(const Data: string): Boolean;
begin
  Result := Pos('procedure ', Trim(Data)) = 1;
end;

function IsProperty(const Data: string): Boolean;
begin
  Result := Pos('property ', Trim(Data)) = 1;
end;

function IsReadProperty(const Data: string): Boolean;
begin
  Result := IsProperty(Data) and (Pos(' read ', Data) <> 0);
end;

function IsWriteProperty(const Data: string): Boolean;
begin
  Result := IsProperty(Data) and (Pos(' write ', Data) <> 0);
end;

function IsMethod(const Data: string): Boolean;
begin
  Result := IsFunction(Data) or IsProcedure(Data);
end;

function IsGetProperty(const Data: string): Boolean;
begin
  Result := IsFunction(Data) and(Pos('Get_', Data) <> 0);
end;

function IsSetProperty(const Data: string): Boolean;
begin
  Result := IsProcedure(Data) and(Pos('Set_', Data) <> 0);
end;

function IsInterfaceDef(const Data: string): Boolean;
begin
  Result := Pos(' = interface(', Data) <> 0;
end;

function IsEnd(const Data: string): Boolean;
begin
  Result := Trim(Data) = 'end;';
end;

(*
  function  ConfigureSlipDocument: Integer; safecall;
  function  Get_Tax2NameOffset: Integer; safecall;
  procedure Set_Tax2NameOffset(Value: Integer); safecall;
  property Tax1RateOffset: Integer read Get_Tax1RateOffset write Set_Tax1RateOffset;
*)

// от пробелов до символов ':' или '('

function GetMethodName(const Data: string): string;
var
  P: Integer;
begin
  Result := Trim(Data);
  P := Pos(' ', Result);
  if P = 0 then Exit;
  Result := Trim(Copy(Result, P+1, Length(Result)));
  // поиск (
  P := Pos('(', Result);
  if P <> 0 then
  begin
    Result := Copy(Result, 1, P-1);
    Exit;
  end;
  // поиск :
  P := Pos(':', Result);
  if P <> 0 then
  begin
    Result := Copy(Result, 1, P-1);
    Exit;
  end;
  // поиск ;
  P := Pos(';', Result);
  if P <> 0 then
  begin
    Result := Copy(Result, 1, P-1);
    Exit;
  end;
end;

// function  ConfigureSlipDocument: Integer; safecall;
// function  Get_Tax2NameOffset: Integer; safecall;
// procedure Set_Tax2NameOffset(Value: Integer); safecall;

// нужно вставить после последнего пробела

function AddClassName(const Data, AClassName: string): string;
var
  C: Char;
  i: Integer;
  WasSpace: Boolean;
begin
  WasSpace := False;
  for i := 1 to Length(Data) do
  begin
    C := Data[i];
    if C = ' ' then
    begin
      WasSpace := True;
    end else
    begin
      if WasSpace then
      begin
        Result := Copy(Data, 1, i-1) + AClassName + '.' + Copy(Data, i, Length(Data));
        Break;
      end;
    end;
  end;
end;

{ До первого пробела }

function GetInterfaceName(const Data: string): string;
var
  P: Integer;
begin
  Result := Trim(Data);
  P := Pos(' ', Result);
  if P > 0 then Result := Copy(Result, 1, P-1);
end;

function IsClassStart(const Data: string): Boolean;
begin
  Result := Pos('class(TOleControl)', Trim(Data)) <> 0;
end;

function IsClassEnd(const Data: string): Boolean;
begin
  Result := Pos(' end;)', Trim(Data)) <> 0;
end;

function GetMethodParams(const S: string): string;
var
  i: Integer;
  IsParamName: Boolean;
begin
  Result := '';
  IsParamName := False;
  for i := 1 to Length(S) do
  begin
    case S[i] of
    ':': IsParamName := False;
    ';': IsParamName := True;
    '(':
    begin
      IsParamName := True;
      Result := Result + '(';
    end;
    ')':
    begin
      Result := Result + ')';
      Break;
    end;
    else
      if IsParamName then
        Result := Result + S[i];
    end;
  end;
  Result := StringReplace(Result, ' var ', ' ', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, ' ', ',', [rfReplaceAll, rfIgnoreCase]);
end;

{ TCodeGen }

procedure TCodeGen.Execute(const FileName: string);
var
  S: string;
  i: Integer;
  Src: TStrings;
  Dst: TStrings;
  Params: string;
  PropertyName: string;
  PropertyType: string;
  MethodName: string;
  FullMethodName: string;
  DstFileName: string;
  InClass: Boolean;
  Line: string;
const
  S_ClassName = 'TPosPrinterLogWrap';
begin
  InClass := False;


  DstFileName := WideIncludeTrailingPathDelimiter(ExtractFilePath(FileName)) + 'PosPrinterLogWrap.pas';
  Src := TStringList.Create;
  Dst := TStringList.Create;
  try
    Src.LoadFromFile(FileName);

    Dst.Add('unit PosPrinterLogWrap;');
    Dst.Add('');
    Dst.Add('interface');
    Dst.Add('');
    Dst.Add('uses');
    Dst.Add('  // VCL');
    Dst.Add('  Classes,');
    Dst.Add('  // Opos');
    Dst.Add('  LogFile, OposPOSPrinter_CCO_TLB;');
    Dst.Add('');
    Dst.Add('type');
    Dst.Add('');
    Dst.Add('  { TPosPrinterLogWrap }');
    Dst.Add('');
    Dst.Add('  TPosPrinterLogWrap = class(TComponent, IOPOSPOSPrinter)');
    Dst.Add('  private');
    Dst.Add('    FLogger: ILogFile;');
    Dst.Add('    FDriver: IOPOSPOSPrinter;');
    Dst.Add('    property Driver: IOPOSPOSPrinter read FDriver;');
    Dst.Add('  public');
    Dst.Add('    constructor Create(ADriver: IOPOSPOSPrinter; ALogger: ILogFile);');
    Dst.Add('    procedure MethodStart(const AMathodName: string; Params: array of Variant);');
    Dst.Add('    procedure MethodEnd(const AMathodName: string; Params: array of Variant);');
    Dst.Add('  public');
    // Get methods
    for i := 0 to Src.Count-1 do
    begin
      S := Trim(Src[i]);
      if IsClassStart(S) then
      begin
        InClass := True;
      end;

      if InClass then
      begin
        if S = 'end;' then Break;
        MethodName := GetMethodName(S);
        if IsProperty(S) then
        begin
          PropertyName := MethodName;
          PropertyType := GetString(S, 3, [' ']);
          Line := Format('    function Get_%s: %s; safecall;', [
              PropertyName, PropertyType]);
          Dst.Add(Line);
        end;
      end;
    end;

    // Set methods
    Dst.Add('  public');
    for i := 0 to Src.Count-1 do
    begin
      S := Trim(Src[i]);
      if IsClassStart(S) then
      begin
        InClass := True;
      end;

      if InClass then
      begin
        if S = 'end;' then Break;
        MethodName := GetMethodName(S);
        if IsWriteProperty(S) then
        begin
          PropertyName := MethodName;
          PropertyType := GetString(S, 3, [' ']);
          Line := Format('    procedure Set_%s(p%s: %s); safecall;', [
              PropertyName, PropertyName, PropertyType]);
          Dst.Add(Line);
        end;
      end;
    end;
    // Methods
    Dst.Add('  public');
    for i := 0 to Src.Count-1 do
    begin
      S := Trim(Src[i]);
      if IsClassStart(S) then
      begin
        InClass := True;
      end;

      if InClass then
      begin
        if S = 'end;' then Break;
        MethodName := GetMethodName(S);
        if IsMethod(S) then
        begin
          Dst.Add('    ' + S);
        end;
      end;
    end;
    // Properties
    Dst.Add('  public');
    for i := 0 to Src.Count-1 do
    begin
      S := Trim(Src[i]);
      if IsClassStart(S) then
      begin
        InClass := True;
      end;

      if InClass then
      begin
        if S = 'end;' then Break;
        MethodName := GetMethodName(S);
        if IsProperty(S) then
        begin
          PropertyName := MethodName;
          PropertyType := GetString(S, 3, [' ']);
          if IsWriteProperty(S) then
          begin
            Line := Format('    property %s: %s read Get_%s write Set_%s;', [
              PropertyName, PropertyType, PropertyName, PropertyName]);
          end else
          begin
            Line := Format('    property %s: %s read Get_%s;', [
              PropertyName, PropertyType, PropertyName]);
          end;
          Dst.Add(Line);
        end;
      end;
    end;

    Dst.Add('end;');
    Dst.Add('');
    Dst.Add('implementation');
    Dst.Add('');
    Dst.Add('');
    Dst.Add('constructor TPosPrinterLogWrap.Create(ADriver: IOPOSPOSPrinter; ALogger: ILogFile);');
    Dst.Add('begin');
    Dst.Add('  FDriver := ADriver;');
    Dst.Add('  FLogger := ALogger;');
    Dst.Add('end;');
    Dst.Add('');
    Dst.Add('procedure TPosPrinterLogWrap.MethodStart(const AMathodName: string; Params: array of Variant);');
    Dst.Add('begin');
    Dst.Add('');
    Dst.Add('end;');
    Dst.Add('');
    Dst.Add('procedure TPosPrinterLogWrap.MethodEnd(const AMathodName: string; Params: array of Variant);');
    Dst.Add('begin');
    Dst.Add('');
    Dst.Add('end;');
    Dst.Add('');

    for i := 0 to Src.Count-1 do
    begin
      S := Trim(Src[i]);
      if IsClassStart(S) then
      begin
        InClass := True;
      end;
      if S = 'implementation' then Break;

      if InClass then
      begin
        if S = 'end;' then Break;
        MethodName := GetMethodName(S);
        if IsProperty(S) then
        begin
          if IsReadProperty(S) then
          begin
            PropertyName := MethodName;
            PropertyType := GetString(S, 3, [' ']);
            FullMethodName := 'Get_' + MethodName;
            Dst.Add('');
            Dst.Add(Format('function %s.%s: %s;', [S_ClassName, FullMethodName, PropertyType]));
            Dst.Add('begin');
            Dst.Add(Format('  MethodStart(''%s'', []);', [FullMethodName]));
            Dst.Add(Format('  Result := Driver.%s;', [PropertyName]));
            Dst.Add(Format('  MethodEnd(''%s'', [Result]);', [FullMethodName]));
            Dst.Add('end;');
          end;
          if IsWriteProperty(S) then
          begin
            PropertyName := MethodName;
            PropertyType := GetString(S, 3, [' ']);
            FullMethodName := 'Set_' + MethodName;
            Dst.Add('');
            Dst.Add(Format('procedure %s.%s(p%s: %s);', [S_ClassName, FullMethodName, PropertyName, PropertyType]));
            Dst.Add('begin');
            Dst.Add(Format('  MethodStart(''%s'', [p%s]);', [FullMethodName, PropertyName]));
            Dst.Add(Format('  Driver.%s := p%s;', [PropertyName, PropertyName]));
            Dst.Add(Format('  MethodEnd(''%s'', []);', [FullMethodName]));
            Dst.Add('end;');
          end;
        end;

        if IsMethod(S) then
        begin
          S := AddClassName(S, S_ClassName);
          Dst.Add('');
          Dst.Add(S);
          Dst.Add('begin');

          Params := GetMethodParams(S);

          if IsFunction(S) then
          begin
            Dst.Add(Format('  MethodStart(''%s'', []);', [MethodName]));
            Dst.Add(Format('  Result := Driver.%s%s;', [MethodName, Params]));
            Dst.Add(Format('  MethodEnd(''%s'', [Result]);', [MethodName]));
          end;
          if IsProcedure(S) then
          begin
            Dst.Add(Format('  MethodStart(''%s'', []);', [MethodName]));
            Dst.Add(Format('  Driver.%s%s;', [MethodName, Params]));
            Dst.Add(Format('  MethodEnd(''%s'', []);', [MethodName]));
          end;
          Dst.Add('end;');
        end;
      end;
    end;
    Dst.Add(' ');
    Dst.Add('end.');
    Dst.SaveToFile(DstFileName);
  finally
    Src.Free;
    Dst.Free;
  end;
end;

end.


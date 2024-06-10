unit duLogFile;

interface

uses
  // VCL
  Windows, SysUtils, Classes, Graphics,
  // Tnt
  TntGraphics, TntClasses, TntSysUtils,
  // DUnit
  TestFramework,
  // This
  LogFile, FileUtils;

type
  { TLogFileTest }

  TLogFileTest = class(TTestCase)
  private
    FLogger: ILogFile;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure WriteUnicode;
    procedure WriteUnicode2;
  end;

implementation

{ TLogFileTest }

procedure TLogFileTest.SetUp;
begin
  FLogger := TLogFile.Create;
  FLogger.Enabled := True;
end;

procedure TLogFileTest.TearDown;
begin
  FLogger := nil;
end;

procedure TLogFileTest.WriteUnicode;
var
  Text: WideString;
  Strings: TTntStrings;
begin
  if FileExists(FLogger.FileName) then
  begin
    if not DeleteFile(FLogger.FileName) then
      RaiseLastOSError;
  end;

  Strings := TTntStringList.Create;
  try
    Strings.LoadFromFile('UnicodeText.txt');

    Text := Strings[0];
    FLogger.Write(Text);
    FLogger.CloseFile;

    Strings.LoadFromFile(FLogger.FileName);
    CheckEquals(Text, Strings[0], 'Strings.Text');
  finally
    Strings.Free;
  end;
end;

procedure TLogFileTest.WriteUnicode2;
var
  Text: WideString;
  Strings: TTntStrings;
begin
  if FileExists(FLogger.FileName) then
  begin
    if not DeleteFile(FLogger.FileName) then
      RaiseLastOSError;
  end;

  Strings := TTntStringList.Create;
  try
    Strings.LoadFromFile('UnicodeText.txt');

    Text := Strings[0];
    FLogger.Debug(Text, [Text]);
    FLogger.CloseFile;

    Strings.LoadFromFile(FLogger.FileName);
    CheckEquals(Text, Copy(Strings[0], 47, 6), 'Strings.Text.0');
    CheckEquals(Text, Copy(Strings[0], 55, 6), 'Strings.Text.1');
  finally
    Strings.Free;
  end;
end;

initialization
  RegisterTest('', TLogFileTest.Suite);

end.

unit Translation;

interface

uses
  // VCL
  Classes, SysUtils, FileUtils,
  // Tnt
  TntClasses, TntSysUtils;

type
  { TTranslation }

  TTranslation = class(TCollectionItem)
  private
    FName: WideString;
    FItems: TTntStringList;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;

    property Name: WideString read FName;
    property Items: TTntStringList read FItems;
  end;

  { TTranslations }

  TTranslations = class(TCollection)
  private
    function GetItem(Index: Integer): TTranslation;
  public
    constructor Create;
    procedure Load;
    procedure Save;
    function Add(const AName: WideString): TTranslation;
    function Find(const Name: WideString): TTranslation;
    property Items[Index: Integer]: TTranslation read GetItem; default;
  end;

implementation

{ TTranslation }

constructor TTranslation.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FItems := TTntStringList.Create;
end;

destructor TTranslation.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

{ TTranslations }

constructor TTranslations.Create;
begin
  inherited Create(TTranslation);
end;

function TTranslations.Add(const AName: WideString): TTranslation;
begin
  Result := TTranslation.Create(Self);
  Result.FName := AName;
end;

function TTranslations.Find(const Name: WideString): TTranslation;
var
  i: Integer;
begin
  for i := 0 to Count-1 do
  begin
    Result := Items[i];
    if CompareText(Result.Name, Name) = 0 then Exit;
  end;
  Result := nil;
end;

function TTranslations.GetItem(Index: Integer): TTranslation;
begin
  Result := inherited Items[Index] as TTranslation;
end;

procedure TTranslations.Load;
var
  i: Integer;
  Text: WideString;
  Path: WideString;
  FileNames: TTntStrings;
  Translation: TTranslation;
begin
  Clear;

  FileNames := TTntStringList.Create;
  try
    Path := IncludeTrailingPathDelimiter(GetModulePath + 'Translation') + '*';
    GetFileNames(Path, FileNames);
    for i := 0 to FileNames.Count-1 do
    begin
      Translation := TTranslation.Create(Self);
      try
        Text := WideExtractFileExt(FileNames[i]);
        Translation.FName := Copy(Text, 2, Length(Text));
        Translation.Items.LoadFromFile(FileNames[i]);
      except
        on E: Exception do
        begin
          Translation.Free;
        end;
      end;
    end;
  finally
    FileNames.Free;
  end;
end;

procedure TTranslations.Save;
var
  i: Integer;
  FileName: WideString;
begin
  for i := 0 to Count-1 do
  begin
    FileName := IncludeTrailingPathDelimiter(GetModulePath + 'Translation') +
      'OposWebkassa.' + Items[i].Name;
    DeleteFile(FileName);
    (*
    if not DeleteFile(FileName) then
      raise Exception.Create('Failed to delete file');
    *)
    Items[i].Items.SaveToFile(FileName);
  end;
end;

end.

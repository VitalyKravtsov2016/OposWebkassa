unit PrinterLines;

interface

uses
  // VCL
  Classes, Math,
  // OPos
  OposException;

type
  TPrinterLine = class;

  { TPrinterLines }

  TPrinterLines = class(TCollection)
  private
    function GetItem(Index: Integer): TPrinterLine;
    procedure CheckLineNumber(Number: Integer);
  public
    function GetText: WideString;
    procedure Init(NewCount: Integer);
    procedure SetText(Value: WideString);
    function GetLine(Number: Integer): TPrinterLine;
    procedure SetLine(Number: Integer; const AText: WideString; ADoubleWidth: Boolean);

    property Items[Index: Integer]: TPrinterLine read GetItem;
  end;

  { TPrinterLine }

  TPrinterLine = class(TCollectionItem)
  private
    FText: WideString;
    FDoubleWidth: Boolean;
  public
    property Text: WideString read FText;
    property DoubleWidth: Boolean read FDoubleWidth;
  end;

implementation

{ TPrinterLines }

function TPrinterLines.GetItem(Index: Integer): TPrinterLine;
begin
  Result := inherited Items[Index] as TPrinterLine;
end;

procedure TPrinterLines.Init(NewCount: Integer);
var
  i: Integer;
begin
  Clear;
  for i := 0 to NewCount-1 do
    Add;
end;

function TPrinterLines.GetText: WideString;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to Count-1 do
  begin
    Result := Result + Items[i].Text;
  end;
end;

procedure TPrinterLines.SetText(Value: WideString);
var
  i: Integer;
  L: Integer;
  Lines: TStrings;
begin
  Lines := TStringList.Create;
  try
    Lines.Text := Value;
    L := Min(Lines.Count, Count);
    for i := 0 to L-1 do
    begin
      Items[i].FText := Lines[i];
    end;
  finally
    Lines.Free;
  end;
end;

procedure TPrinterLines.CheckLineNumber(Number: Integer);
begin
  if (Number <= 0)or(Number > Count) then
    raiseIllegalError('Invalid line number');
end;

function TPrinterLines.GetLine(Number: Integer): TPrinterLine;
begin
  CheckLineNumber(Number);
  Result := Items[Number-1];
end;

procedure TPrinterLines.SetLine(Number: Integer; const AText: WideString;
  ADoubleWidth: Boolean);
begin
  CheckLineNumber(Number);
  Items[Number-1].FText := AText;
  Items[Number-1].FDoubleWidth := ADoubleWidth;
end;

end.

unit PageBuffer;

interface

uses
  // VCL
  Classes;

const
  CR = #13;
  LF = #10;

type
  { TLineStyle }

  TLineStyle = (lsFontB, lsDoubleWidth, lsDoubleHeight, lsBold);
  TLineStyles = set of TLineStyle;

  { TPageLine }

  TPageLine = class(TCollectionItem)
  private
    FText: WideString;
    FStyle: TLineStyles;
    function GetWidth: Integer;
  public
    class function GetCharHeight(AStyle: TLineStyles): Integer;
    class function GetCharWidth(AStyle: TLineStyles): Integer;

    property Text: WideString read FText;
    property Style: TLineStyles read FStyle;
    property Width: Integer read GetWidth;
  end;

  { TPageLines }

  TPageLines = class(TCollection)
  private
    function GetItem(Index: Integer): TPageLine;
  public
    constructor Create;
    function Add(const Text: WideString; Style: TLineStyles): TPageLine;
    property Items[Index: Integer]: TPageLine read GetItem; default;
  end;

  { TPageBuffer }

  TPageBuffer = class
  private
    FLine: WideString;
    FLines: TPageLines;
    FLineWidth: Integer;
    FLineSpacing: Integer;
    procedure SetLineWidth(Value: Integer);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear;
    procedure Print(const Text: WideString; Style: TLineStyles);
    function GetHeight: Integer;

    property Line: WideString read FLine;
    property Lines: TPageLines read FLines;
    property LineWidth: Integer read FLineWidth write SetLineWidth;
    property LineSpacing: Integer read FLineSpacing write FLineSpacing;
  end;


implementation

{ TPageBuffer }

constructor TPageBuffer.Create;
begin
  inherited Create;
  FLines := TPageLines.Create;
end;

destructor TPageBuffer.Destroy;
begin
  FLines.Free;
  inherited Destroy;
end;

procedure TPageBuffer.SetLineWidth(Value: Integer);
begin
  if Value <> FLineWidth then
  begin
    FLineWidth := Value;
    FLines.Clear;
  end;
end;

procedure TPageBuffer.Print(const Text: WideString; Style: TLineStyles);
var
  i: Integer;
begin
  for i := 1 to Length(Text) do
  begin
    case Text[i] of
      LF: ;
      CR:
      begin
        Lines.Add(Line, Style);
        FLine := '';
      end;
    else
      if (TPageLine.GetCharWidth(Style) * (Length(Line)+1)) > LineWidth then
      begin
        Lines.Add(Line, Style);
        FLine := '';
      end;
      FLine := FLine + Text[i];
    end;
  end;
end;

procedure TPageBuffer.Clear;
begin
  FLine := '';
  FLines.Clear;
end;

function TPageBuffer.GetHeight: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Lines.Count-1 do
  begin
    Result := Result + TPageLine.GetCharHeight(Lines[i].Style) + LineSpacing;
  end;
end;

{ TPageLines }

constructor TPageLines.Create;
begin
  inherited Create(TPageLine);
end;

function TPageLines.GetItem(Index: Integer): TPageLine;
begin
  Result := inherited Items[Index] as TPageLine;
end;

function TPageLines.Add(const Text: WideString; Style: TLineStyles): TPageLine;
begin
  Result := TPageLine.Create(Self);
  Result.FText := Text;
  Result.FStyle := Style;
end;

{ TPageLine }

class function TPageLine.GetCharWidth(AStyle: TLineStyles): Integer;
begin
  Result := 12;
  if (lsFontB in AStyle) then
    Result := 9;
  if lsDoubleWidth in AStyle then
    Result := Result * 2;
end;

class function TPageLine.GetCharHeight(AStyle: TLineStyles): Integer;
begin
  Result := 24;
  if (lsFontB in AStyle) then
    Result := 18;
  if lsDoubleHeight in AStyle then
    Result := Result * 2;
end;

function TPageLine.GetWidth: Integer;
begin
  Result := Length(Text) * GetCharWidth(Style);
end;

end.

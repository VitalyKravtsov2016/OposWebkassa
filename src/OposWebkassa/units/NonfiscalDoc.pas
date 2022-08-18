unit NonfiscalDoc;

interface

uses
  // Tnt
  TntClasses, TntSysUtils;

type
  { TNonfiscalDoc }

  TNonfiscalDoc = class
  private
    FLines: TTntStrings;
    FIsCancelled: Boolean;

    function GetText: WideString;
    function GetLineCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;

    procedure BeginNonFiscal;
    procedure Add(Station: Integer; const AText: WideString);
    procedure PrintNormal(Station: Integer; const AText: WideString);

    procedure Clear;
    function HasLine(const Line: WideString): Boolean;

    property Text: WideString read GetText;
    property LineCount: Integer read GetLineCount;
    property IsCancelled: Boolean read FIsCancelled;
  end;

implementation

{ TNonfiscalDoc }

constructor TNonfiscalDoc.Create;
begin
  inherited Create;
  FLines := TTntStringList.Create;
end;

destructor TNonfiscalDoc.Destroy;
begin
  FLines.Free;
  inherited Destroy;
end;

procedure TNonfiscalDoc.Clear;
begin
  FLines.Clear;
end;

procedure TNonfiscalDoc.PrintNormal(Station: Integer; const AText: WideString);
begin
  FLines.AddObject(AText, TObject(Station));
end;

procedure TNonfiscalDoc.Add(Station: Integer; const AText: WideString);
begin
  FLines.AddObject(AText, TObject(Station));
end;

function TNonfiscalDoc.GetText: WideString;
begin
  Result := FLines.Text;
end;

function TNonfiscalDoc.GetLineCount: Integer;
begin
  Result := FLines.Count;
end;

function TNonfiscalDoc.HasLine(const Line: WideString): Boolean;
begin
  Result := WideTextPos(Line, Text) <> 0;
end;

procedure TNonfiscalDoc.BeginNonFiscal;
begin
  FLines.Clear;
  FIsCancelled := False;
end;

end.

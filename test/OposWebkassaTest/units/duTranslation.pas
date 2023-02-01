unit duTranslation;

interface

uses
  // VCL
  Windows, SysUtils, Classes,
  // DUnit
  TestFramework,
  // Tnt
  TntClasses,
  // This
  Translation;

type
  { TTranslationTest }

  TTranslationTest = class(TTestCase)
  private
    FTranslations: TTranslations;
  protected
    procedure Setup; override;
    procedure TearDown; override;
    property Translations: TTranslations read FTranslations;
  published
    procedure CheckLoadSave;
  end;

implementation

{ TTranslationTest }

procedure TTranslationTest.Setup;
begin
  inherited Setup;
  FTranslations := TTranslations.Create;
end;

procedure TTranslationTest.TearDown;
begin
  FTranslations.Free;
  inherited TearDown;
end;

procedure TTranslationTest.CheckLoadSave;
var
  Translation: TTranslation;
begin
  FTranslations.Clear;
  CheckEquals(0, FTranslations.Count, 'Translations.Count');
  FTranslations.Load;
  CheckEquals(2, FTranslations.Count, 'Translations.Count');
  FTranslations.Save;
  FTranslations.Clear;
  CheckEquals(0, FTranslations.Count, 'Translations.Count');
  FTranslations.Load;
  CheckEquals(2, FTranslations.Count, 'Translations.Count');
  Translation := FTranslations.Find('RUS');
  Check(Translation <> nil, 'Translation = nil');
  CheckEquals(15, Translation.Items.Count, 'Translation.Items.Count');
  Translation := FTranslations.Find('KAZ');
  Check(Translation <> nil, 'Translation = nil');
  CheckEquals(15, Translation.Items.Count, 'Translation.Items.Count');
end;

initialization
  RegisterTest('', TTranslationTest.Suite);


end.

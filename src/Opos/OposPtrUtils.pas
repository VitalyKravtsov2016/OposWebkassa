unit OposPtrUtils;

interface

uses
  // VCL
  Types, SysUtils, Classes,
  // Opos
  OposUtils, OposPtr, OposPtrhi;

function PtrPropertyName(const ID: Integer): WideString;
function PtrResultCodeExtendedText(Value: Integer): WideString;
function PtrStatusUpdateEventText(Value: Integer): WideString;
function Is2DBarcode(Symbology: Integer): Boolean;

function MapToDots(Value, MapMode: Integer): Integer; overload;
function MapFromDots(Value, MapMode: Integer): Integer; overload;
function MapToDots(const R: TRect; MapMode: Integer): TRect; overload;
function MapToDots(const R: TPoint; MapMode: Integer): TPoint; overload;
function MapFromDots(const R: TRect; MapMode: Integer): TRect; overload;
function MapFromDots(const R: TPoint; MapMode: Integer): TPoint; overload;
function StringsToCommaSeparatedList(Strings: TStrings): string;
function ArrayToString(const Src: array of Integer): string;
procedure SortArray(Src: array of Integer; var Dst: array of Integer);

implementation

function StringsToCommaSeparatedList(Strings: TStrings): string;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to Strings.Count-1 do
  begin
    if Result <> '' then
      Result := Result + ',';
    Result := Result + Strings[i];
  end;
end;

function PtrPropertyName(const ID: Integer): WideString;
begin
  case ID of
    // POS printer
    PIDXPtr_AsyncMode: Result := 'PIDXPtr_AsyncMode';
    PIDXPtr_CharacterSet: Result := 'PIDXPtr_CharacterSet';
    PIDXPtr_CoverOpen: Result := 'PIDXPtr_CoverOpen';
    PIDXPtr_ErrorStation: Result := 'PIDXPtr_ErrorStation';
    PIDXPtr_FlagWhenIdle: Result := 'PIDXPtr_FlagWhenIdle';
    PIDXPtr_JrnEmpty: Result := 'PIDXPtr_FlagWhenIdle';
    PIDXPtr_JrnLetterQuality: Result := 'PIDXPtr_JrnLetterQuality';
    PIDXPtr_JrnLineChars: Result := 'PIDXPtr_JrnLineChars';
    PIDXPtr_JrnLineHeight: Result := 'PIDXPtr_JrnLineHeight';
    PIDXPtr_JrnLineSpacing: Result := 'PIDXPtr_JrnLineSpacing';
    PIDXPtr_JrnLineWidth: Result := 'PIDXPtr_JrnLineWidth';
    PIDXPtr_JrnNearEnd: Result := 'PIDXPtr_JrnNearEnd';
    PIDXPtr_MapMode: Result := 'PIDXPtr_MapMode';
    PIDXPtr_RecEmpty: Result := 'PIDXPtr_RecEmpty';
    PIDXPtr_RecLetterQuality: Result := 'PIDXPtr_RecLetterQuality';
    PIDXPtr_RecLineChars: Result := 'PIDXPtr_RecLineChars';
    PIDXPtr_RecLineHeight: Result := 'PIDXPtr_RecLineHeight';
    PIDXPtr_RecLineSpacing: Result := 'PIDXPtr_RecLineSpacing';
    PIDXPtr_RecLinesToPaperCut: Result := 'PIDXPtr_RecLinesToPaperCut';
    PIDXPtr_RecLineWidth: Result := 'PIDXPtr_RecLineWidth';
    PIDXPtr_RecNearEnd: Result := 'PIDXPtr_RecNearEnd';
    PIDXPtr_RecSidewaysMaxChars: Result := 'PIDXPtr_RecSidewaysMaxChars';
    PIDXPtr_RecSidewaysMaxLines: Result := 'PIDXPtr_RecSidewaysMaxLines';
    PIDXPtr_SlpEmpty: Result := 'PIDXPtr_SlpEmpty';
    PIDXPtr_SlpLetterQuality: Result := 'PIDXPtr_SlpLetterQuality';
    PIDXPtr_SlpLineChars: Result := 'PIDXPtr_SlpLineChars';
    PIDXPtr_SlpLineHeight: Result := 'PIDXPtr_SlpLineHeight';
    PIDXPtr_SlpLinesNearEndToEnd: Result := 'PIDXPtr_SlpLinesNearEndToEnd';
    PIDXPtr_SlpLineSpacing: Result := 'PIDXPtr_SlpLineSpacing';
    PIDXPtr_SlpLineWidth: Result := 'PIDXPtr_SlpLineWidth';
    PIDXPtr_SlpMaxLines: Result := 'PIDXPtr_SlpMaxLines';
    PIDXPtr_SlpNearEnd: Result := 'PIDXPtr_SlpNearEnd';
    PIDXPtr_SlpSidewaysMaxChars: Result := 'PIDXPtr_SlpSidewaysMaxChars';
    PIDXPtr_SlpSidewaysMaxLines: Result := 'PIDXPtr_SlpSidewaysMaxLines';
    PIDXPtr_ErrorLevel: Result := 'PIDXPtr_ErrorLevel';
    PIDXPtr_RotateSpecial: Result := 'PIDXPtr_RotateSpecial';
    PIDXPtr_CartridgeNotify: Result := 'PIDXPtr_CartridgeNotify';
    PIDXPtr_JrnCartridgeState: Result := 'PIDXPtr_JrnCartridgeState';
    PIDXPtr_JrnCurrentCartridge: Result := 'PIDXPtr_JrnCurrentCartridge';
    PIDXPtr_RecCartridgeState: Result := 'PIDXPtr_RecCartridgeState';
    PIDXPtr_RecCurrentCartridge: Result := 'PIDXPtr_RecCurrentCartridge';
    PIDXPtr_SlpPrintSide: Result := 'PIDXPtr_SlpPrintSide';
    PIDXPtr_SlpCartridgeState: Result := 'PIDXPtr_SlpCartridgeState';
    PIDXPtr_SlpCurrentCartridge: Result := 'PIDXPtr_SlpCurrentCartridge';
    PIDXPtr_MapCharacterSet: Result := 'PIDXPtr_MapCharacterSet';
    PIDXPtr_PageModeDescriptor: Result := 'PIDXPtr_PageModeDescriptor';
    PIDXPtr_PageModeHorizontalPosition: Result := 'PIDXPtr_PageModeHorizontalPosition';
    PIDXPtr_PageModePrintDirection: Result := 'PIDXPtr_PageModePrintDirection';
    PIDXPtr_PageModeStation: Result := 'PIDXPtr_PageModeStation';
    PIDXPtr_PageModeVerticalPosition: Result := 'PIDXPtr_PageModeVerticalPosition';
    PIDXPtr_CapConcurrentJrnRec: Result := 'PIDXPtr_CapConcurrentJrnRec';
    PIDXPtr_CapConcurrentJrnSlp: Result := 'PIDXPtr_CapConcurrentJrnSlp';
    PIDXPtr_CapConcurrentRecSlp: Result := 'PIDXPtr_CapConcurrentRecSlp';
    PIDXPtr_CapCoverSensor: Result := 'PIDXPtr_CapCoverSensor';
    PIDXPtr_CapJrn2Color: Result := 'PIDXPtr_CapJrn2Color';
    PIDXPtr_CapJrnBold: Result := 'PIDXPtr_CapJrnBold';
    PIDXPtr_CapJrnDhigh: Result := 'PIDXPtr_CapJrnDhigh';
    PIDXPtr_CapJrnDwide: Result := 'PIDXPtr_CapJrnDwide';
    PIDXPtr_CapJrnDwideDhigh: Result := 'PIDXPtr_CapJrnDwideDhigh';
    PIDXPtr_CapJrnEmptySensor: Result := 'PIDXPtr_CapJrnEmptySensor';
    PIDXPtr_CapJrnItalic: Result := 'PIDXPtr_CapJrnItalic';
    PIDXPtr_CapJrnNearEndSensor: Result := 'PIDXPtr_CapJrnNearEndSensor';
    PIDXPtr_CapJrnPresent: Result := 'PIDXPtr_CapJrnPresent';
    PIDXPtr_CapJrnUnderline: Result := 'PIDXPtr_CapJrnUnderline';
    PIDXPtr_CapRec2Color: Result := 'PIDXPtr_CapRec2Color';
    PIDXPtr_CapRecBarCode: Result := 'PIDXPtr_CapRecBarCode';
    PIDXPtr_CapRecBitmap: Result := 'PIDXPtr_CapRecBitmap';
    PIDXPtr_CapRecBold: Result := 'PIDXPtr_CapRecBold';
    PIDXPtr_CapRecDhigh: Result := 'PIDXPtr_CapRecDhigh';
    PIDXPtr_CapRecDwide: Result := 'PIDXPtr_CapRecDwide';
    PIDXPtr_CapRecDwideDhigh: Result := 'PIDXPtr_CapRecDwideDhigh';
    PIDXPtr_CapRecEmptySensor: Result := 'PIDXPtr_CapRecEmptySensor';
    PIDXPtr_CapRecItalic: Result := 'PIDXPtr_CapRecItalic';
    PIDXPtr_CapRecLeft90: Result := 'PIDXPtr_CapRecLeft90';
    PIDXPtr_CapRecNearEndSensor: Result := 'PIDXPtr_CapRecNearEndSensor';
    PIDXPtr_CapRecPapercut: Result := 'PIDXPtr_CapRecPapercut';
    PIDXPtr_CapRecPresent: Result := 'PIDXPtr_CapRecPresent';
    PIDXPtr_CapRecRight90: Result := 'PIDXPtr_CapRecRight90';
    PIDXPtr_CapRecRotate180: Result := 'PIDXPtr_CapRecRotate180';
    PIDXPtr_CapRecStamp: Result := 'PIDXPtr_CapRecStamp';
    PIDXPtr_CapRecUnderline: Result := 'PIDXPtr_CapRecUnderline';
    PIDXPtr_CapSlp2Color: Result := 'PIDXPtr_CapSlp2Color';
    PIDXPtr_CapSlpBarCode: Result := 'PIDXPtr_CapSlpBarCode';
    PIDXPtr_CapSlpBitmap: Result := 'PIDXPtr_CapSlpBitmap';
    PIDXPtr_CapSlpBold: Result := 'PIDXPtr_CapSlpBold';
    PIDXPtr_CapSlpDhigh: Result := 'PIDXPtr_CapSlpDhigh';
    PIDXPtr_CapSlpDwide: Result := 'PIDXPtr_CapSlpDwide';
    PIDXPtr_CapSlpDwideDhigh: Result := 'PIDXPtr_CapSlpDwideDhigh';
    PIDXPtr_CapSlpEmptySensor: Result := 'PIDXPtr_CapSlpEmptySensor';
    PIDXPtr_CapSlpFullslip: Result := 'PIDXPtr_CapSlpFullslip';
    PIDXPtr_CapSlpItalic: Result := 'PIDXPtr_CapSlpItalic';
    PIDXPtr_CapSlpLeft90: Result := 'PIDXPtr_CapSlpLeft90';
    PIDXPtr_CapSlpNearEndSensor: Result := 'PIDXPtr_CapSlpNearEndSensor';
    PIDXPtr_CapSlpPresent: Result := 'PIDXPtr_CapSlpPresent';
    PIDXPtr_CapSlpRight90: Result := 'PIDXPtr_CapSlpRight90';
    PIDXPtr_CapSlpRotate180: Result := 'PIDXPtr_CapSlpRotate180';
    PIDXPtr_CapSlpUnderline: Result := 'PIDXPtr_CapSlpUnderline';
    PIDXPtr_CapCharacterSet: Result := 'PIDXPtr_CapSlpUnderline';
    PIDXPtr_CapTransaction: Result := 'PIDXPtr_CapTransaction';
    PIDXPtr_CapJrnCartridgeSensor: Result := 'PIDXPtr_CapJrnCartridgeSensor';
    PIDXPtr_CapJrnColor: Result := 'PIDXPtr_CapJrnColor';
    PIDXPtr_CapRecCartridgeSensor: Result := 'PIDXPtr_CapRecCartridgeSensor';
    PIDXPtr_CapRecColor: Result := 'PIDXPtr_CapRecColor';
    PIDXPtr_CapRecMarkFeed: Result := 'PIDXPtr_CapRecMarkFeed';
    PIDXPtr_CapSlpBothSidesPrint: Result := 'PIDXPtr_CapSlpBothSidesPrint';
    PIDXPtr_CapSlpCartridgeSensor: Result := 'PIDXPtr_CapSlpCartridgeSensor';
    PIDXPtr_CapSlpColor: Result := 'PIDXPtr_CapSlpColor';
    PIDXPtr_CapMapCharacterSet: Result := 'PIDXPtr_CapMapCharacterSet';
    PIDXPtr_CapConcurrentPageMode: Result := 'PIDXPtr_CapConcurrentPageMode';
    PIDXPtr_CapRecPageMode: Result := 'PIDXPtr_CapRecPageMode';
    PIDXPtr_CapSlpPageMode: Result := 'PIDXPtr_CapSlpPageMode';
    PIDXPtr_CharacterSetList: Result := 'PIDXPtr_CharacterSetList';
    PIDXPtr_JrnLineCharsList: Result := 'PIDXPtr_JrnLineCharsList';
    PIDXPtr_RecLineCharsList: Result := 'PIDXPtr_RecLineCharsList';
    PIDXPtr_SlpLineCharsList: Result := 'PIDXPtr_SlpLineCharsList';
    PIDXPtr_ErrorString: Result := 'PIDXPtr_ErrorString';
    PIDXPtr_FontTypefaceList: Result := 'PIDXPtr_FontTypefaceList';
    PIDXPtr_RecBarCodeRotationList: Result := 'PIDXPtr_RecBarCodeRotationList';
    PIDXPtr_SlpBarCodeRotationList: Result := 'PIDXPtr_SlpBarCodeRotationList';
    PIDXPtr_RecBitmapRotationList: Result := 'PIDXPtr_RecBitmapRotationList';
    PIDXPtr_SlpBitmapRotationList: Result := 'PIDXPtr_SlpBitmapRotationList';
    PIDXPtr_PageModeArea: Result := 'PIDXPtr_PageModeArea';
    PIDXPtr_PageModePrintArea: Result := 'PIDXPtr_PageModePrintArea';
  else
    Result := GetCommonPropertyName(ID);
  end;
end;

function PtrResultCodeExtendedText(Value: Integer): WideString;
begin
  case Value of
    OPOS_EPTR_COVER_OPEN            : Result := 'OPOS_EPTR_COVER_OPEN';
    OPOS_EPTR_JRN_EMPTY             : Result := 'OPOS_EPTR_JRN_EMPTY';
    OPOS_EPTR_REC_EMPTY             : Result := 'OPOS_EPTR_REC_EMPTY';
    OPOS_EPTR_SLP_EMPTY             : Result := 'OPOS_EPTR_SLP_EMPTY';
    OPOS_EPTR_SLP_FORM              : Result := 'OPOS_EPTR_SLP_FORM';
    OPOS_EPTR_TOOBIG                : Result := 'OPOS_EPTR_TOOBIG';
    OPOS_EPTR_BADFORMAT             : Result := 'OPOS_EPTR_BADFORMAT';
    OPOS_EPTR_JRN_CARTRIDGE_REMOVED : Result := 'OPOS_EPTR_JRN_CARTRIDGE_REMOVED';
    OPOS_EPTR_JRN_CARTRIDGE_EMPTY   : Result := 'OPOS_EPTR_JRN_CARTRIDGE_EMPTY';
    OPOS_EPTR_JRN_HEAD_CLEANING     : Result := 'OPOS_EPTR_JRN_HEAD_CLEANING';
    OPOS_EPTR_REC_CARTRIDGE_REMOVED : Result := 'OPOS_EPTR_REC_CARTRIDGE_REMOVED';
    OPOS_EPTR_REC_CARTRIDGE_EMPTY   : Result := 'OPOS_EPTR_REC_CARTRIDGE_EMPTY';
    OPOS_EPTR_REC_HEAD_CLEANING     : Result := 'OPOS_EPTR_REC_HEAD_CLEANING';
    OPOS_EPTR_SLP_CARTRIDGE_REMOVED : Result := 'OPOS_EPTR_SLP_CARTRIDGE_REMOVED';
    OPOS_EPTR_SLP_CARTRIDGE_EMPTY   : Result := 'OPOS_EPTR_SLP_CARTRIDGE_EMPTY';
    OPOS_EPTR_SLP_HEAD_CLEANING     : Result := 'OPOS_EPTR_SLP_HEAD_CLEANING';
  else
    Result := IntToStr(Value);
  end;
end;

function PtrStatusUpdateEventText(Value: Integer): WideString;
begin
  case Value of
    PTR_SUE_COVER_OPEN: Result := 'PTR_SUE_COVER_OPEN';
    PTR_SUE_COVER_OK: Result := 'PTR_SUE_COVER_OK';
    PTR_SUE_JRN_COVER_OPEN: Result := 'PTR_SUE_JRN_COVER_OPEN';
    PTR_SUE_JRN_COVER_OK: Result := 'PTR_SUE_JRN_COVER_OK';
    PTR_SUE_REC_COVER_OPEN: Result := 'PTR_SUE_REC_COVER_OPEN';
    PTR_SUE_REC_COVER_OK: Result := 'PTR_SUE_REC_COVER_OK';
    PTR_SUE_SLP_COVER_OPEN: Result := 'PTR_SUE_SLP_COVER_OPEN';
    PTR_SUE_SLP_COVER_OK: Result := 'PTR_SUE_SLP_COVER_OK';
    PTR_SUE_JRN_EMPTY: Result := 'PTR_SUE_JRN_EMPTY';
    PTR_SUE_JRN_NEAREMPTY: Result := 'PTR_SUE_JRN_NEAREMPTY';
    PTR_SUE_JRN_PAPEROK: Result := 'PTR_SUE_JRN_PAPEROK';
    PTR_SUE_REC_EMPTY: Result := 'PTR_SUE_REC_EMPTY';
    PTR_SUE_REC_NEAREMPTY: Result := 'PTR_SUE_REC_NEAREMPTY';
    PTR_SUE_REC_PAPEROK: Result := 'PTR_SUE_REC_PAPEROK';
    PTR_SUE_SLP_EMPTY: Result := 'PTR_SUE_SLP_EMPTY';
    PTR_SUE_SLP_NEAREMPTY: Result := 'PTR_SUE_SLP_NEAREMPTY';
    PTR_SUE_SLP_PAPEROK: Result := 'PTR_SUE_SLP_PAPEROK';
    PTR_SUE_JRN_CARTRIDGE_EMPTY: Result := 'PTR_SUE_JRN_CARTRIDGE_EMPTY';
    PTR_SUE_JRN_CARTRIDGE_NEAREMPTY: Result := 'PTR_SUE_JRN_CARTRIDGE_NEAREMPTY';
    PTR_SUE_JRN_HEAD_CLEANING: Result := 'PTR_SUE_JRN_HEAD_CLEANING';
    PTR_SUE_JRN_CARTRIDGE_OK: Result := 'PTR_SUE_JRN_CARTRIDGE_OK';
    PTR_SUE_REC_CARTRIDGE_EMPTY: Result := 'PTR_SUE_REC_CARTRIDGE_EMPTY';
    PTR_SUE_REC_CARTRIDGE_NEAREMPTY: Result := 'PTR_SUE_REC_CARTRIDGE_NEAREMPTY';
    PTR_SUE_REC_HEAD_CLEANING: Result := 'PTR_SUE_REC_HEAD_CLEANING';
    PTR_SUE_REC_CARTRIDGE_OK: Result := 'PTR_SUE_REC_CARTRIDGE_OK';
    PTR_SUE_SLP_CARTRIDGE_EMPTY: Result := 'PTR_SUE_SLP_CARTRIDGE_EMPTY';
    PTR_SUE_SLP_CARTRIDGE_NEAREMPTY: Result := 'PTR_SUE_SLP_CARTRIDGE_NEAREMPTY';
    PTR_SUE_SLP_HEAD_CLEANING: Result := 'PTR_SUE_SLP_HEAD_CLEANING';
    PTR_SUE_SLP_CARTRIDGE_OK: Result := 'PTR_SUE_SLP_CARTRIDGE_OK';
    PTR_SUE_IDLE: Result := 'PTR_SUE_IDLE';
  else
    Result := GetOPOSStatusUpdateEventText(Value);
  end;
end;

function Is2DBarcode(Symbology: Integer): Boolean;
begin
  Result := False;
  case Symbology of
    PTR_BCS_PDF417,
    PTR_BCS_MAXICODE,
    PTR_BCS_DATAMATRIX,
    PTR_BCS_QRCODE,
    PTR_BCS_UQRCODE,
    PTR_BCS_AZTEC,
    PTR_BCS_UPDF417: Result := True;
  end;
end;

function MapToDots(Value, MapMode: Integer): Integer;
begin
  Result := Value;
  case MapMode of
    PTR_MM_DOTS: Result := Value;
    PTR_MM_TWIPS: Result := Value*7;
    PTR_MM_ENGLISH: Result := Value*5;
    PTR_MM_METRIC: Result := Value*13;
  end;
end;

function MapFromDots(Value, MapMode: Integer): Integer;
begin
  Result := Value;
  case MapMode of
    PTR_MM_DOTS: Result := Value;
    PTR_MM_TWIPS: Result := Value div 7;
    PTR_MM_ENGLISH: Result := Value div 5;
    PTR_MM_METRIC: Result := Value div 13;
  end;
end;

function MapFromDots(const R: TRect; MapMode: Integer): TRect;
begin
  Result.Left := MapFromDots(R.Left, MapMode);
  Result.Top := MapFromDots(R.Top, MapMode);
  Result.Right := MapFromDots(R.Right, MapMode);
  Result.Bottom := MapFromDots(R.Bottom, MapMode);
end;

function MapToDots(const R: TRect; MapMode: Integer): TRect;
begin
  Result.Left := MapToDots(R.Left, MapMode);
  Result.Top := MapToDots(R.Top, MapMode);
  Result.Right := MapToDots(R.Right, MapMode);
  Result.Bottom := MapToDots(R.Bottom, MapMode);
end;

function MapToDots(const R: TPoint; MapMode: Integer): TPoint;
begin
  Result.X := MapToDots(R.X, MapMode);
  Result.Y := MapToDots(R.Y, MapMode);
end;

function MapFromDots(const R: TPoint; MapMode: Integer): TPoint;
begin
  Result.X := MapFromDots(R.X, MapMode);
  Result.Y := MapFromDots(R.Y, MapMode);
end;

function ArrayToString(const Src: array of Integer): string;
var
  i: Integer;
  Dst: array of Integer;
begin
  Result := '';

  SetLength(Dst, Length(Src));
  SortArray(Src, Dst);
  for i := Low(Dst) to High(Dst) do
  begin
    if Result <> '' then
      Result := Result + ',';

    Result := Result + IntToStr(Dst[i]);
  end;
end;

function CompareInt(Item1, Item2: Integer): Integer;
begin
  if Item1 = Item2 then Result := 0 else
  if Item1 > Item2 then Result := 1 else
  Result := -1;
end;

function SortIntProc(Item1, Item2: Pointer): Integer;
begin
  Result := CompareInt(Integer(Item1), Integer(Item2));
end;

procedure SortArray(Src: array of Integer; var Dst: array of Integer);
var
  i: Integer;
  List: TList;
begin
  List := TList.Create;
  try
    for i := Low(Src) to High(Src) do
    begin
      List.Add(Pointer(Src[i]));
    end;
    List.Sort(SortIntProc);
    for i := 0 to List.Count-1 do
    begin
      Dst[i] := Integer(List[i]);
    end;
  finally
    List.Free;
  end;
end;





end.

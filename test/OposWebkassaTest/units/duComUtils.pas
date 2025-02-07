unit duComUtils;

interface

uses
  // VCL
  Windows, SysUtils, Classes, Graphics, ComObj, ActiveX,
  // Tnt
  TntGraphics, TntClasses,
  // DUnit
  TestFramework,
  // 3'd
  Opos, OposPtr, OposPtrUtils, OposPOSPrinter_CCO_TLB,   
  // This
  PosPrinterPosiflex, ComUtils;

type
  { TTestIntfObject }

  TTestIntfObject = class(TInterfacedObject)
  public
    destructor Destroy; override;
  end;

  { TTestIntfObject2 }

  TTestIntfObject2 = class(TDispIntfObject)
  public
    destructor Destroy; override;
  end;

  { TTestIntfObject3 }

  TTestIntfObject3 = class(TPosPrinterPosiflex)
  public
    destructor Destroy; override;
  end;

  { TComUtilsTest }

  TComUtilsTest = class(TTestCase)
  published
    procedure TestDestroy;
    procedure TestDestroy2;
    procedure TestDestroy3;
  end;

implementation

var
  DestroyCalled: boolean = False;

{ TTestIntfObject }

destructor TTestIntfObject.Destroy;
begin
  DestroyCalled := True;
  inherited Destroy;
end;

{ TTestIntfObject2 }

destructor TTestIntfObject2.Destroy;
begin
  DestroyCalled := True;
  inherited Destroy;
end;

{ TTestIntfObject3 }

destructor TTestIntfObject3.Destroy;
begin
  DestroyCalled := True;
  inherited Destroy;
end;


{ TComUtilsTest }

procedure TComUtilsTest.TestDestroy;
var
  Test: IInterface;
begin
  DestroyCalled := False;
  Test := TTestIntfObject.Create;
  Test := nil;
  CheckEquals(True, DestroyCalled, 'DestroyCalled <> True');
end;

procedure TComUtilsTest.TestDestroy2;
var
  Test: IDispatch;
begin
  DestroyCalled := False;
  Test := TTestIntfObject2.Create;
  Test := nil;
  CheckEquals(True, DestroyCalled, 'DestroyCalled <> True');
end;

procedure TComUtilsTest.TestDestroy3;
var
  Test: IOPOSPOSPrinter;
begin
  DestroyCalled := False;
  Test := TTestIntfObject3.Create(nil, nil);
  Test := nil;
  CheckEquals(True, DestroyCalled, 'DestroyCalled <> True');
end;

initialization
  RegisterTest('', TComUtilsTest.Suite);

end.

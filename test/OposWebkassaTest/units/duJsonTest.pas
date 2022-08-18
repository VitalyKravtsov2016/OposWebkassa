unit duJsonTest;

interface

uses
  // VCL
  Windows, SysUtils, Classes,
  // DUnit
  TestFramework,
  // This
  uLkJSON, JsonUtils, WebkassaClient, FileUtils;

type
  { TJSONTest }

  TJSONTest = class(TTestCase)
  public
    procedure TestJsonWriter;
    procedure TestEncodeMoneyOperationCommand;
    procedure TestDecodeMoneyOperationCommand;
  published
    procedure Level1Test;
    procedure Level2Test;
    procedure ArrayTest;
    procedure ParseTest;
    procedure ParseError; 
  end;

{ TMoneyOperation }

  TMoneyOperation = class(TPersistent)
  private
    FToken: WideString;
    FCashboxUniqueNumber: WideString;
  published
    property Token: WideString read FToken write FToken;
    property CashboxUniqueNumber: WideString read FCashboxUniqueNumber  write FCashboxUniqueNumber;
  end;

implementation


{ TJSONTest }

procedure TJSONTest.Level1Test;
var
  Json: TlkJSON;
  Doc: TlkJSONobject;
  Request: WideString;
begin
  Json := TlkJSON.Create;
  Doc := TlkJSONobject.Create;
  try
    Doc.Add('Login', 'login@webkassa.kz');
    Doc.Add('Password', '123');
    Request := Json.GenerateText(Doc);
    CheckEquals('{"Login":"login@webkassa.kz","Password":"123"}', Request);
  finally
    Doc.Free;
    Json.Free;
  end;
end;

procedure TJSONTest.Level2Test;
var
  Json: TlkJSON;
  Doc: TlkJSONobject;
  Request: WideString;
  Positions: TlkJSONobject;
begin
  Json := TlkJSON.Create;
  Doc := TlkJSONobject.Create;
  Positions := TlkJSONobject.Create;
  try
    Doc.Add('Login', 'login@webkassa.kz');
    Doc.Add('Password', '123');
    Doc.Add('Positions', Positions);

    Positions.Add('Position1', '1');
    Positions.Add('Position2', '2');

    Request := Json.GenerateText(Doc);
    CheckEquals('{"Login":"login@webkassa.kz","Password":"123","Positions":{"Position1":"1","Position2":"2"}}', Request);
  finally
    Doc.Free;
    Json.Free;
  end;
end;

procedure TJSONTest.ArrayTest;
var
  Json: TlkJSON;
  Doc: TlkJSONobject;
  Request: WideString;
  Positions: TlkJSONlist;
  Position: TlkJSONobject;
begin
  Json := TlkJSON.Create;
  Doc := TlkJSONobject.Create;
  try
    Doc.Add('Login', 'login@webkassa.kz');
    Doc.Add('Password', '123');

    Positions := TlkJSONlist.Create;
    Doc.Add('Positions', Positions);

    Position := TlkJSONobject.Create;
    Position.Add('Position1', '1');
    Positions.Add(Position);

    Position := TlkJSONobject.Create;
    Position.Add('Position2', '2');
    Positions.Add(Position);

    Request := Json.GenerateText(Doc);
    CheckEquals('{"Login":"login@webkassa.kz","Password":"123","Positions":[{"Position1":"1"},{"Position2":"2"}]}', Request);
  finally
    Doc.Free;
    Json.Free;
  end;
end;


procedure TJSONTest.ParseTest;
var
  Json: TlkJSON;
  Doc: TlkJSONbase;
  Node: TlkJSONbase;
const
  JsonText: WideString =
  '{"Data":{"OfflineMode":true,"CashboxOfflineMode":true,'+
  '"DateTime":"15.02.2018 17:18:29","Sum":56350,"Cashbox":{"UniqueNumber":"SWK0 0013404","RegistrationNumber":"000134040000","IdentityNumber":"561","Address":"ул. Пушкина 17, оф.521","Ofd":{"Name":"АО Казахтелеком","Host":"consumer.oofd.kz","Code":1}}}}';
begin
  Json := TlkJSON.Create;
  try
    Doc := Json.ParseText(Utf8Encode(JsonText));
    Node := Doc.Field['Data'];
    CheckEquals(True, Node.Field['OfflineMode'].Value);
    CheckEquals(True, Node.Field['CashboxOfflineMode'].Value);
    CheckEquals('15.02.2018 17:18:29', Node.Field['DateTime'].Value);
    CheckEquals(56350, Node.Field['Sum'].Value);
    Node := Node.Field['Cashbox'];
    CheckEquals('SWK0 0013404', Node.Field['UniqueNumber'].Value);
    CheckEquals('000134040000', Node.Field['RegistrationNumber'].Value);
    CheckEquals(561, Node.Field['IdentityNumber'].Value);
    CheckEquals('ул. Пушкина 17, оф.521', Node.Field['Address'].Value);
    Node := Node.Field['Ofd'];
    CheckEquals('АО Казахтелеком', Node.Field['Name'].Value);
    CheckEquals('consumer.oofd.kz', Node.Field['Host'].Value);
    CheckEquals(1, Node.Field['Code'].Value);
  finally
    Json.Free;
  end;
end;

procedure TJSONTest.TestJsonWriter;
var
  JsonText: string;
  Item: TMoneyOperation;
begin
  Item := TMoneyOperation.Create;
  try
    Item.Token := 'kdsjhkahsd921873';
    Item.CashboxUniqueNumber := 'sdasdg';
    JsonText := ObjectToJSON(Item);
    CheckEquals('{"Token":"kdsjhkahsd921873","CashboxUniqueNumber":"sdasdg"}', JsonText);
  finally
    Item.Free;
  end;
end;

(*
Пример тела ответа:
{
  "Data": {
    "OfflineMode": true,
    "CashboxOfflineMode": true,
    "DateTime": "15.02.2018 17:18:29",
    "Sum": 56350,
    "Cashbox": {
      "UniqueNuiriber": "SWK0 0013404",
      "RegistrationNumber": "000134040000",
      "IdentityNumber": "561",
      "Address": "ул. Пушкина 17, оф.521",
      "Ofd": {
        "Name": "АО "Казахтелеком"",
        "Host": "consumer.oofd.kz",
        "Code": 1
      }
    }
  }
}
*)


const
  JsonTextExpected =
  '{"Data":{"OfflineMode":true,"CashboxOfflineMode":true,' +
  '"DateTime":"15.02.2018 17:18:29","Sum":56350,' +
  '"Cashbox":{"UniqueNumber":"SWK0 0013404",' +
  '"RegistrationNumber":"000134040000","IdentityNumber":"561",'+
  '"Address":"ул. Пушкина 17, оф.521","Ofd":{"Name":"АО "Казахтелеком"",'+
  '"Host":"consumer.oofd.kz","Code":1}}}}';

procedure TJSONTest.TestEncodeMoneyOperationCommand;
var
  JsonText: string;
  Item: TMoneyOperationCommand;
begin
  Item := TMoneyOperationCommand.Create;
  try
    Item.Data.OfflineMode := True;
    Item.Data.CashboxOfflineMode := True;
    Item.Data.DateTime := '15.02.2018 17:18:29';
    Item.Data.Sum := 56350;
    Item.Data.Cashbox.UniqueNumber := 'SWK0 0013404';
    Item.Data.Cashbox.RegistrationNumber := '000134040000';
    Item.Data.Cashbox.IdentityNumber := '561';
    Item.Data.Cashbox.Address := 'ул. Пушкина 17, оф.521';
    Item.Data.Cashbox.Ofd.Name := 'АО "Казахтелеком"';
    Item.Data.Cashbox.Ofd.Host := 'consumer.oofd.kz';
    Item.Data.Cashbox.Ofd.Code := 1;
    JsonText := ObjectToJson(Item);
    CheckEquals(JsonTextExpected, Utf8Decode(JsonText));
  finally
    Item.Free;
  end;
end;

procedure TJSONTest.TestDecodeMoneyOperationCommand;
var
  Item: TMoneyOperationCommand;
begin
  Item := TMoneyOperationCommand.Create;
  try
    JsonToObject(JsonTextExpected, Item);
    CheckEquals(True, Item.Data.OfflineMode, 'Item.Data.OfflineMode');
    CheckEquals(True, Item.Data.CashboxOfflineMode, 'Item.Data.CashboxOfflineMode');
    CheckEquals('15.02.2018 17:18:29', Item.Data.DateTime, 'Item.Data.DateTime');
    CheckEquals(56350, Item.Data.Sum, 'Item.Data.Sum');
    CheckEquals('SWK0 0013404', Item.Data.Cashbox.UniqueNumber, 'Item.Data.Cashbox.UniqueNumber');
    CheckEquals('000134040000', Item.Data.Cashbox.RegistrationNumber, 'Item.Data.Cashbox.RegistrationNumber');
    CheckEquals('561', Item.Data.Cashbox.IdentityNumber, 'Item.Data.Cashbox.IdentityNumber');
    CheckEquals('ул. Пушкина 17, оф.521', Item.Data.Cashbox.Address, 'Item.Data.Cashbox.Address');
    CheckEquals('АО "Казахтелеком"', Item.Data.Cashbox.Ofd.Name, 'Item.Data.Cashbox.Ofd.Name');
    CheckEquals('consumer.oofd.kz', Item.Data.Cashbox.Ofd.Host, 'Item.Data.Cashbox.Ofd.Host');
    CheckEquals(1, Item.Data.Cashbox.Ofd.Code, 'Item.Data.Cashbox.Ofd.Code');
  finally
    Item.Free;
  end;
end;

procedure TJSONTest.ParseError;
var
  Json: TlkJSON;
  Doc: TlkJSONbase;
  Node: TlkJSONbase;
  Code: Integer;
  Text: WideString;
  JsonText: WideString;
begin
  Json := TlkJSON.Create;
  try
    JsonText := ReadFileData(GetModulePath + 'ErrorCode.txt');
    Doc := Json.ParseText(JsonText);
    Check(Doc <> nil, 'Doc = nil');
    CheckEquals(1, Doc.Count);

    Node := Doc.Field['Errors'];
    Check(Node <> nil, 'Node = nil');
    CheckEquals(1, Node.Count);

    Node := Node.Child[0];
    Code := Node.Field['Code'].Value;
    CheckEquals(1, Code);

    Text := Node.Field['Text'].Value;
    CheckEquals('Неверный логин и/или пароль', Text);
  finally
    Json.Free;
  end;
end;

initialization
  RegisterTest('', TJSONTest.Suite);

end.

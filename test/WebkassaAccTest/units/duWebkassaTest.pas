unit duWebkassaTest;

interface

uses
  // VCL
  Windows, SysUtils, Classes, ActiveX, ComObj,
  // DUnit
  TestFramework, TntClasses,
  // This
  LogFile, WebkassaClient, JsonUtils, FileUtils, PrinterParameters,
  OposWebkassaLib_TLB, StringUtils;

type
  { TWebkassaTest }

  TWebkassaTest = class(TTestCase)
  private
    FLogger: ILogFile;
    FClient: TWebkassaClient;
    FExternalCheckNumber: WideString;
  protected
    procedure SetUp; override;
    procedure TearDown; override;

    procedure TestUploadOrder;
  published
    procedure TestConnect;
    procedure TestAuthenticate;
    procedure TestChangeToken;
    procedure TestAuthenticateError;
    procedure TestReadCashboxes;
    procedure TestCashIn;
    procedure TestCashOut;
    procedure TestZReport;
    procedure TestReadCahiers;
    procedure TestReadUnits;
    procedure TestJournalReport;
    procedure TestReadReceipt;
    procedure TestReadReceiptText;
    procedure TestSendReceipt;
    procedure TestRegistration;
    procedure TestReadCashboxState;
    procedure TestXReport;
    procedure TestXReportExtended;
    procedure TestZReportExtended;
  end;

implementation

const
  CRLF = #13#10;

{ TWebkassaTest }

procedure TWebkassaTest.SetUp;
begin
  FLogger := TLogFile.Create;
  FLogger.MaxCount := 10;
  FLogger.Enabled := True;
  FLogger.FilePath := 'Logs';
  FLogger.DeviceName := 'DeviceName';

  FClient := TWebkassaClient.Create(FLogger);
  FClient.Address := 'https://devkkm.webkassa.kz/';
  FClient.Login := 'webkassa4@softit.kz';
  FClient.Password := 'Kassa123';
  FClient.CashboxNumber := 'SWK00032685';
  FClient.RaiseErrors := True;
end;

procedure TWebkassaTest.TearDown;
begin
  FClient.Free;
end;

procedure TWebkassaTest.TestConnect;
var
  Token1: string;
  Token2: string;
begin
  CheckEquals(False, FClient.Connected, 'FClient.Connected');
  CheckEquals('', FClient.Token, 'FClient.Token not empty');
  FClient.Connect;
  Token1 := FClient.Token;
  CheckEquals(True, FClient.Connected, 'FClient.Connected');
  CheckNotEquals('', FClient.Token, 'FClient.Token is empty');
  FClient.Disconnect;
  FClient.Connect;
  Token2 := FClient.Token;
  CheckEquals(True, FClient.Connected, 'FClient.Connected');
  CheckNotEquals('', FClient.Token, 'FClient.Token is empty');
  CheckNotEquals(Token1, Token2, 'Token1 = Token2');
  FClient.Disconnect;
end;

procedure TWebkassaTest.TestAuthenticate;
var
  Command: TAuthCommand;
begin
  Command := TAuthCommand.Create;
  try
    Command.Request.Login := 'webkassa4@softit.kz';
    Command.Request.Password := 'Kassa123';
    Command.Data.Token := '';
    CheckEquals(True, FClient.Authenticate(Command), 'FClient.Authenticate');
    CheckNotEquals('', Command.Data.Token, 'Command.Data.Token is empty');
    WriteFileData(GetModulePath + 'AuthorizeWithEmployeeInfo.txt', FClient.AnswerJson);
  finally
    Command.Free;
  end;
end;

procedure TWebkassaTest.TestAuthenticateError;
var
  Item: TErrorItem;
  Command: TAuthCommand;
begin
  Command := TAuthCommand.Create;
  try
    Command.Request.Login := '123';
    Command.Request.Password := '123';
    Command.Data.Token := '';
    CheckEquals(False, FClient.Authenticate(Command), 'FClient.Authenticate');
    CheckEquals(1, FClient.ErrorResult.Errors.Count);
    CheckEquals(1, FClient.ErrorResult.Errors.Count);
    Item := FClient.ErrorResult.Errors[0];
    CheckEquals(1, Item.Code);
    CheckEquals('Неверный логин и/или пароль', Item.Text);
  finally
    Command.Free;
  end;
end;

procedure TWebkassaTest.TestReadCashboxes;
var
  Command: TCashboxesCommand;
begin
  Command := TCashboxesCommand.Create;
  try
    FClient.Connect;
    Command.Request.Token := FClient.Token;
    Check(FClient.ReadCashboxes(Command), 'ReadCashboxes');
    Check(Command.Data.List.Count <> 0);
    WriteFileData(GetModulePath + 'ReadCashboxes.txt', FClient.AnswerJson);
  finally
    Command.Free;
  end;
end;

procedure TWebkassaTest.TestChangeToken;
var
  Command: TChangeTokenCommand;
begin
  Command := TChangeTokenCommand.Create;
  try
    FClient.Connect;
    Command.Request.Token := FClient.Token;
    Command.Request.CashboxUniqueNumber := FClient.CashboxNumber;
    Command.Request.OfdToken := 1;

    FClient.ChangeToken(Command);
    WriteFileData(GetModulePath + 'ChangeToken.txt', FClient.AnswerJson);
  finally
    Command.Free;
  end;
end;

procedure TWebkassaTest.TestXReport;
var
  Command: TZXReportCommand;
begin
  Command := TZXReportCommand.Create;
  try
    FClient.Connect;
    Command.Request.Token := FClient.Token;
    Command.Request.CashboxUniqueNumber := FClient.CashboxNumber;
    FClient.XReport(Command);
    WriteFileData(GetModulePath + 'XReport.txt', FClient.AnswerJson);
  finally
    Command.Free;
  end;
end;

procedure TWebkassaTest.TestXReportExtended;
var
  JsonText: WideString;
  Request: TCashboxRequest;
begin
  Request := TCashboxRequest.Create;
  try
    FClient.Connect;
    Request.Token := FClient.Token;
    Request.CashboxUniqueNumber := FClient.CashboxNumber;

    JsonText := ObjectToJson(Request);
    JsonText := FClient.Post(FClient.Address + 'api/xreport/extended', JsonText);
    WriteFileData(GetModulePath + 'XReportExtended.txt', FClient.AnswerJson);
  finally
    Request.Free;
  end;
end;

procedure TWebkassaTest.TestZReportExtended;
var
  JsonText: WideString;
  Request: TCashboxRequest;
begin
  Request := TCashboxRequest.Create;
  try
    FClient.Connect;
    Request.Token := FClient.Token;
    Request.CashboxUniqueNumber := FClient.CashboxNumber;

    JsonText := ObjectToJson(Request);
    JsonText := FClient.Post(FClient.Address + 'api/zreport/extended', JsonText);
    WriteFileData(GetModulePath + 'ZReportExtended.txt', FClient.AnswerJson);
  finally
    Request.Free;
  end;
end;

procedure TWebkassaTest.TestZReport;
var
  Command: TZXReportCommand;
begin
  Command := TZXReportCommand.Create;
  try
    FClient.Connect;
    Command.Request.Token := FClient.Token;
    Command.Request.CashboxUniqueNumber := FClient.CashboxNumber;
    if not FClient.ZReport(Command) then
      FClient.RaiseLastError;

    WriteFileData(GetModulePath + 'ZReport.txt', FClient.AnswerJson);
  finally
    Command.Free;
  end;
end;

procedure TWebkassaTest.TestJournalReport;
var
  Command: TJournalReportCommand;
begin
  Command := TJournalReportCommand.Create;
  try
    FClient.Connect;

    Command.Request.Token := FClient.Token;
    Command.Request.CashboxUniqueNumber := FClient.CashboxNumber;
    Command.Request.ShiftNumber := 148;
    FClient.JournalReport(Command);
    WriteFileData(GetModulePath + 'JournalReport.txt', FClient.AnswerJson);
  finally
    Command.Free;
  end;
end;

procedure TWebkassaTest.TestReadCahiers;
var
  Token1: string;
  Token2: string;
  Command: TCashierCommand;
  ErrorItem: TErrorItem;
  ErrorResult: TErrorResult;
begin
  ErrorResult := TErrorResult.Create;
  Command := TCashierCommand.Create;
  try
    FClient.Connect;
    Token1 := FClient.Token;
    CheckNotEquals('', Token1, 'Token1 is empty');
    Command.Request.Token := FClient.Token;
    ErrorItem := ErrorResult.Errors.Add as TErrorItem;
    ErrorItem.Code := 2;
    ErrorItem.Text := 'Срок действия сессии истек';

    FClient.TestErrorResult := ErrorResult;
    FClient.ReadCashiers(Command);
    WriteFileData(GetModulePath + 'ReadCahiers.txt', FClient.AnswerJson);
    // Token must be changed
    Token2 := FClient.Token;
    CheckNotEquals(Token1, Token2, 'Token1 = Token2');
  finally
    Command.Free;
    ErrorResult.Free;
  end;
end;

procedure TWebkassaTest.TestReadReceipt;
var
  Command: TReceiptCommand;
begin
  Command := TReceiptCommand.Create;
  try
    FClient.Connect;

    Command.Request.Token := FClient.Token;
    Command.Request.CashboxUniqueNumber := FClient.CashboxNumber;
    Command.Request.Number := '923860753030';
    Command.Request.ShiftNumber := 148;

    FClient.ReadReceipt(Command);
    WriteFileData(GetModulePath + 'ReadReceipt.txt', FClient.AnswerJson);
    FExternalCheckNumber := Command.Data.ExternalCheckNumber;
  finally
    Command.Free;
  end;
end;

procedure TWebkassaTest.TestReadReceiptText;
var
  Item: TReceiptTextItem;
  Command: TReceiptTextCommand;
begin
  Command := TReceiptTextCommand.Create;
  try
    FClient.Connect;

    Command.Request.Token := FClient.Token;
    Command.Request.CashboxUniqueNumber := FClient.CashboxNumber;
    //Command.Request.externalCheckNumber := '8f3e76b0-97ed-4467-9c46-1b042e2f933f';
    Command.Request.externalCheckNumber := FExternalCheckNumber;
    Command.Request.isDuplicate := False;
    Command.Request.paperKind := 0;

    FClient.ReadReceiptText(Command);
    WriteFileData(GetModulePath + 'ReadReceiptText.txt', FClient.AnswerJson);
    Check(Command.Data.Lines.Count > 0);



    Item := Command.Data.Lines.Items[0] as TReceiptTextItem;
    CheckEquals(1, Item.Order, 'Item.Order');
    CheckEquals(0, Item._Type, 'Item._Type');
    CheckEquals('             ТОО SOFT IT KAZAKHSTAN             ', Item.Value, 'Item.Value');
    CheckEquals(0, Item.Style, 'Item.Style');

    Item := Command.Data.Lines.Items[27] as TReceiptTextItem;
    CheckEquals(28, Item.Order, 'Item.Order');
    CheckEquals(2, Item._Type, 'Item._Type');
    CheckEquals('http://dev.kofd.kz/consumer?i=923860753030&f=211030200207&s=2055.00&t=20220803T142912', Item.Value, 'Item.Value');
    CheckEquals(0, Item.Style, 'Item.Style');
  finally
    Command.Free;
  end;
end;

procedure TWebkassaTest.TestReadUnits;
var
  Command: TReadUnitsCommand;
begin
  Command := TReadUnitsCommand.Create;
  try
    FClient.Connect;
    Command.Request.token := FClient.Token;

    FClient.ReadUnits(Command);
    WriteFileData(GetModulePath + 'ReadUnits.txt', FClient.AnswerJson);
  finally
    Command.Free;
  end;
end;

procedure TWebkassaTest.TestCashIn;
var
  Command: TMoneyOperationCommand;
begin
  Command := TMoneyOperationCommand.Create;
  try
    FClient.Connect;

    Command.Request.token := FClient.Token;
	  Command.Request.CashboxUniqueNumber := FClient.CashboxNumber;
	  Command.Request.OperationType := OperationTypeCashIn;
	  Command.Request.Sum := 12345.67;
	  Command.Request.ExternalCheckNumber := '';

    FClient.MoneyOperation(Command);
    WriteFileData(GetModulePath + 'CashIn.txt', FClient.AnswerJson);
  finally
    Command.Free;
  end;
end;

procedure TWebkassaTest.TestCashOut;
var
  Command: TMoneyOperationCommand;
begin
  Command := TMoneyOperationCommand.Create;
  try
    FClient.Connect;

    Command.Request.token := FClient.Token;
	  Command.Request.CashboxUniqueNumber := FClient.CashboxNumber;
	  Command.Request.OperationType := OperationTypeCashOut;
	  Command.Request.Sum := 12345.67;
	  Command.Request.ExternalCheckNumber := '';

    FClient.MoneyOperation(Command);
    WriteFileData(GetModulePath + 'CashOut.txt', FClient.AnswerJson);
  finally
    Command.Free;
  end;
end;

procedure TWebkassaTest.TestSendReceipt;
var
  Payment: TPayment;
  Item: TTicketItem;
  Command: TSendReceiptCommand;
begin
  Command := TSendReceiptCommand.Create;
  try
    FClient.Connect;

    Command.Request.CashboxUniqueNumber := FClient.CashboxNumber;
    Command.Request.Token := FClient.Token;
    Command.Request.OperationType := OperationTypeSell;
    Command.Request.Change := 100;
    // Item 1
    Item := Command.Request.Positions.Add as TTicketItem;
    Item.Count := 123.456;
    Item.Price := 123.45;
    Item.TaxPercent := 10;
    Item.Tax := 1385.60;
    Item.TaxType := TaxTypeVAT;
    Item.PositionName := 'Позиция чека 1';
    Item.PositionCode := '1';
    Item.DisplayName := 'Товар номер 1';
    Item.UnitCode := 796;
    Item.Discount := 12;
    Item.Markup := 13;
    Item.WarehouseType := 0;
    // Item 2
    Item := Command.Request.Positions.Add as TTicketItem;
    Item.Count := 12.456;
    Item.Price := 12.45;
    Item.TaxPercent := 20;
    Item.Tax := 26.01;
    Item.TaxType := TaxTypeVAT;
    Item.PositionName := 'Позиция чека 2';
    Item.PositionCode := '1';
    Item.DisplayName := 'Товар номер 2';
    Item.UnitCode := 796;
    Item.Discount := 12;
    Item.Markup := 13;
    Item.WarehouseType := 0;

    Command.Request.RoundType := 0;
    Command.Request.ExternalCheckNumber := CreateGUIDStr;
    FExternalCheckNumber := Command.Request.ExternalCheckNumber;
    Payment := Command.Request.Payments.Add as TPayment;
    Payment.Sum := 900;
    Payment.PaymentType := PaymentTypeCash;

    Payment := Command.Request.Payments.Add as TPayment;
    Payment.Sum := 14397.72;
    Payment.PaymentType := PaymentTypeCard;

    Payment := Command.Request.Payments.Add as TPayment;
    Payment.Sum := 100;
    Payment.PaymentType := PaymentTypeCredit;

    Payment := Command.Request.Payments.Add as TPayment;
    Payment.Sum := 100;
    Payment.PaymentType := PaymentTypeTare;

    FClient.SendReceipt(Command);
    WriteFileData(GetModulePath + 'SendReceipt.txt', FClient.AnswerJson);
(*
    CheckEquals(149, Command.Data.ShiftNumber, 'Command.Data.ShiftNumber');
    CheckEquals('SWK00032685', Command.Data.Cashbox.UniqueNumber, 'Command.Data.Cashbox.UniqueNumber');
    CheckEquals('https://devkkm.webkassa.kz/Ticket?chb=SWK00032685&extnum=8234682763482746', Command.Data.TicketPrintUrl, 'Command.Data.TicketPrintUrl');
*)
  finally
    Command.Free;
  end;
end;

procedure TWebkassaTest.TestUploadOrder;
var
  Item: TOrderItem;
  CommandJson: string;
  Command: TUploadOrderCommand;
begin
  Command := TUploadOrderCommand.Create;
  try
    Command.Request.token := '6a4eaa2e4b744950blelce3312470d3d';
    Command.Request.OrderNumber := '123456789-123';
    Command.Request.CustomerEmail := 'pochta@pochta.com';
	  Command.Request.CustomerPhone := '+77771234455';

    Item := Command.Request.Positions.Add as TOrderItem;
    Item.Count := 1;
    Item.Price := 500;
    Item.TaxPercent := 12;
    Item.TaxType := 100;
    Item.PositionName := 'Печенье';
    Item.PositionCode := '1';
    Item.Discount := 0;
    Item.Markup := 0;
    Item.SectionCode := '1';
    Item.UnitCode := 796;

    Item := Command.Request.Positions.Add as TOrderItem;
    Item.Count := 10;
    Item.Price := 2000;
    Item.TaxPercent := 12;
    Item.TaxType := 100;
    Item.PositionName := 'Конфеты';
    Item.PositionCode := '2';
    Item.Discount := 1000;
    Item.Markup := 0;
    Item.SectionCode := '1';
    Item.UnitCode := 796;

    FClient.TestMode := True;
    FClient.AnswerJson := ReadFileData(GetModulePath + 'UploadOrderAnswer.txt');
    CheckEquals(True, FClient.UploadOrder(Command), 'FClient.UploadOrder');
    CheckEquals(True, Command.Data, 'Command.Data');

    CommandJson := ReadFileData(GetModulePath + 'UploadOrderRequest.txt');
    if CommandJson <> FClient.CommandJson then
      WriteFileData(GetModulePath + 'UploadOrderRequestError.txt', FClient.CommandJson);

    CheckEquals(CommandJson, FClient.CommandJson, 'CommandJson');
  finally
    Command.Free;
  end;
end;

procedure TWebkassaTest.TestRegistration;
var
  GUID: TGUID;
  GUIDStr1: string;
  GUIDStr2: string;
begin
  GUID := ProgIDToClassID(FiscalPrinterProgID);
  GUIDStr1 := GUIDToString(GUID);
  GUIDStr2 := GUIDToString(CLASS_FiscalPrinter);
  CheckEquals(GUIDStr1, GUIDStr2);
end;

procedure TWebkassaTest.TestReadCashboxState;
var
  Request: TCashboxRequest;
begin
  Request := TCashboxRequest.Create;
  try
    FClient.Connect;
    Request.Token := FClient.Token;
    Request.CashboxUniqueNumber := FClient.CashboxNumber;
    FClient.ReadCashboxStatus(Request);
    WriteFileData(GetModulePath + 'ReadCashboxStatus.txt', FClient.AnswerJson);
  finally
    Request.Free;
  end;
end;

initialization
  RegisterTest('', TWebkassaTest.Suite);

end.

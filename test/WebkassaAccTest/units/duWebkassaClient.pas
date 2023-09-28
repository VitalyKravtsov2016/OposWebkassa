unit duWebkassaClient;

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
  { TWebkassaClientTest }

  TWebkassaClientTest = class(TTestCase)
  private
    FLogger: ILogFile;
    FShiftNumber: Integer;
    FClient: TWebkassaClient;
  protected
    procedure SetUp; override;
    procedure TearDown; override;

    procedure TestUploadOrder;
    procedure TestChangeToken;
  published
    procedure TestConnect;
    procedure TestAuthenticate;
    procedure TestAuthenticateError;
    procedure TestReadCashboxes;
    procedure TestCashIn;
    procedure TestCashOut;
    procedure TestZReport;
    procedure TestReadCahiers;
    procedure TestReadUnits;
    procedure TestJournalReport;
    procedure TestRegistration;
    procedure TestReadCashboxState;
    procedure TestXReport;
    procedure TestXReportExtended;
    procedure TestZReportExtended;
    procedure TestSendReceipt;
    procedure TestReadReceipt;
    procedure TestReadReceiptText;
    procedure TestSendReceipt2;

    procedure TestSumInCashbox;
  end;

implementation

const
  CRLF = #13#10;

var
  FReceipt: TSendReceiptCommand;

{ TWebkassaClientTest }

procedure TWebkassaClientTest.SetUp;
begin
  FLogger := TLogFile.Create;
  FLogger.MaxCount := 10;
  FLogger.Enabled := True;
  FLogger.FilePath := 'Logs';
  FLogger.DeviceName := 'DeviceName';

  FClient := TWebkassaClient.Create(FLogger);
  FClient.Address := 'https://devkkm.webkassa.kz';
  //FClient.Address := 'http://localhost:1332';
  FClient.Login := 'webkassa4@softit.kz';
  FClient.Password := 'Kassa123';
  FClient.CashboxNumber := 'SWK00033059';
  FClient.RaiseErrors := True;
end;

procedure TWebkassaClientTest.TearDown;
begin
  FClient.Free;
  FLogger.CloseFile;
end;

procedure TWebkassaClientTest.TestConnect;
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

procedure TWebkassaClientTest.TestAuthenticate;
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

procedure TWebkassaClientTest.TestAuthenticateError;
var
  Item: TErrorItem;
  Command: TAuthCommand;
begin
  Command := TAuthCommand.Create;
  try
    FClient.RaiseErrors := False;
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

procedure TWebkassaClientTest.TestReadCashboxes;
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

procedure TWebkassaClientTest.TestChangeToken;
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

procedure TWebkassaClientTest.TestXReport;
var
  Command: TZXReportCommand;
begin
  Command := TZXReportCommand.Create;
  try
    FClient.Connect;
    Command.Request.Token := FClient.Token;
    Command.Request.CashboxUniqueNumber := FClient.CashboxNumber;
    FClient.XReport(Command);
    WriteFileData(GetModulePath + 'XReportAnswer.txt', FClient.AnswerJson);
    FShiftNumber := Command.Data.ShiftNumber;
  finally
    Command.Free;
  end;
end;

procedure TWebkassaClientTest.TestXReportExtended;
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
    JsonText := FClient.Post(FClient.GetAddress + 'api/xreport/extended', JsonText);
    WriteFileData(GetModulePath + 'XReportExtended.txt', FClient.AnswerJson);
  finally
    Request.Free;
  end;
end;

procedure TWebkassaClientTest.TestZReportExtended;
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
    JsonText := FClient.Post(FClient.GetAddress + 'api/zreport/extended', JsonText);
    WriteFileData(GetModulePath + 'ZReportExtended.txt', FClient.AnswerJson);
  finally
    Request.Free;
  end;
end;

procedure TWebkassaClientTest.TestZReport;
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

procedure TWebkassaClientTest.TestJournalReport;
var
  Command: TJournalReportCommand;
begin
  // Read shift number
  TestXReport;

  Command := TJournalReportCommand.Create;
  try
    FClient.Connect;
    Command.Request.Token := FClient.Token;
    Command.Request.CashboxUniqueNumber := FClient.CashboxNumber;
    Command.Request.ShiftNumber := FShiftNumber;
    FClient.JournalReport(Command);
    WriteFileData(GetModulePath + 'JournalReport.txt', FClient.AnswerJson);
  finally
    Command.Free;
  end;
end;

procedure TWebkassaClientTest.TestReadCahiers;
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

procedure TWebkassaClientTest.TestSendReceipt;
var
  Payment: TPayment;
  Item: TTicketItem;
begin
  FClient.Connect;

  FReceipt.Request.Token := FClient.Token;
  FReceipt.Request.CashboxUniqueNumber := FClient.CashboxNumber;
  FReceipt.Request.ExternalCheckNumber := CreateGUIDStr;
  FReceipt.Request.OperationType := OperationTypeSell;
  // Item 1
  Item := FReceipt.Request.Positions.Add as TTicketItem;
  Item.Count := 123.456;
  Item.Price := 123.45;
  Item.TaxPercent := 12;
  Item.Tax := 1633.03;
  Item.TaxType := TaxTypeVAT;
  Item.PositionName := 'Позиция чека 1';
  Item.PositionCode := '1';
  Item.DisplayName := 'Товар номер 1';
  Item.UnitCode := 796;
  Item.Discount := 12;
  Item.Markup := 13;
  Item.WarehouseType := 0;
  // Item 2
  Item := FReceipt.Request.Positions.Add as TTicketItem;
  Item.Count := 12.456;
  Item.Price := 12.45;
  Item.TaxPercent := 12;
  Item.Tax := 16.72;
  Item.TaxType := TaxTypeVAT;
  Item.PositionName := 'Позиция чека 2';
  Item.PositionCode := '1';
  Item.DisplayName := 'Товар номер 2';
  Item.UnitCode := 796;
  Item.Discount := 12;
  Item.Markup := 13;
  Item.WarehouseType := 0;

  FReceipt.Request.Change := 0;
  FReceipt.Request.RoundType := 0;
  Payment := FReceipt.Request.Payments.Add as TPayment;
  Payment.Sum := 800;
  Payment.PaymentType := PaymentTypeCash;

  Payment := FReceipt.Request.Payments.Add as TPayment;
  Payment.Sum := 14597.72;
  Payment.PaymentType := PaymentTypeCard;

  FClient.SendReceipt(FReceipt);
  WriteFileData(GetModulePath + 'SendReceipt.txt', FClient.AnswerJson);
(*
  CheckEquals(149, FReceipt.Data.ShiftNumber, 'FReceipt.Data.ShiftNumber');
  CheckEquals('SWK00032685', FReceipt.Data.Cashbox.UniqueNumber, 'FReceipt.Data.Cashbox.UniqueNumber');
  CheckEquals('https://devkkm.webkassa.kz/Ticket?chb=SWK00032685&extnum=8234682763482746', FReceipt.Data.TicketPrintUrl, 'FReceipt.Data.TicketPrintUrl');
*)
end;

procedure TWebkassaClientTest.TestSendReceipt2;
var
  Payment: TPayment;
  Item: TTicketItem;
begin
  FClient.Connect;

  FReceipt.Request.Token := FClient.Token;
  FReceipt.Request.CashboxUniqueNumber := FClient.CashboxNumber;
  FReceipt.Request.ExternalCheckNumber := CreateGUIDStr;
  FReceipt.Request.OperationType := OperationTypeSell;
  // Item 1
  Item := FReceipt.Request.Positions.Add as TTicketItem;
  Item.Count := 2;
  Item.Price := 23;
  Item.TaxPercent := 0;
  Item.Tax := 0;
  Item.TaxType := TaxTypeNoTax;
  Item.PositionName := 'Позиция чека 1';
  Item.PositionCode := '1';
  Item.DisplayName := 'Товар номер 1';
  Item.UnitCode := 796;
  Item.Discount := 0;
  Item.Markup := 0;
  Item.WarehouseType := 0;

  FReceipt.Request.Change := 0;
  FReceipt.Request.RoundType := 0;
  Payment := FReceipt.Request.Payments.Add as TPayment;
  Payment.Sum := 46;
  Payment.PaymentType := PaymentTypeCash;

  FClient.SendReceipt(FReceipt);
  WriteFileData(GetModulePath + 'SendReceipt.txt', FClient.AnswerJson);
end;

procedure TWebkassaClientTest.TestReadReceipt;
var
  SrcItem: TTicketItem;
  DstItem: TPositionItem;
  Command: TReceiptCommand;
begin
  Command := TReceiptCommand.Create;
  try
    FClient.Connect;

    Command.Request.Token := FClient.Token;
    Command.Request.CashboxUniqueNumber := FClient.CashboxNumber;
    Command.Request.Number := FReceipt.Data.CheckNumber;
    Command.Request.ShiftNumber := FReceipt.Data.ShiftNumber;

    FClient.ReadReceipt(Command);
    WriteFileData(GetModulePath + 'ReadReceipt.txt', FClient.AnswerJson);

    CheckEquals(FReceipt.Request.CashboxUniqueNumber,
      Command.Data.CashboxUniqueNumber, 'CashboxUniqueNumber');

    CheckEquals(FReceipt.Request.Positions.Count, Command.Data.Positions.Count, 'Positions.Count');

    SrcItem := FReceipt.Request.Positions[0];
    DstItem := Command.Data.Positions[0];
    CheckEquals(SrcItem.Count, DstItem.Count, 'Count');
    CheckEquals(SrcItem.Price, DstItem.Price, 'Price');
    CheckEquals(SrcItem.PositionName, DstItem.PositionName, 'PositionName');
  finally
    Command.Free;
  end;
end;

procedure TWebkassaClientTest.TestReadReceiptText;
var
  Command: TReceiptTextCommand;
begin
  Command := TReceiptTextCommand.Create;
  try
    FClient.Connect;

    Command.Request.Token := FClient.Token;
    Command.Request.CashboxUniqueNumber := FClient.CashboxNumber;
    Command.Request.externalCheckNumber := FReceipt.Request.ExternalCheckNumber;
    Command.Request.isDuplicate := False;
    Command.Request.paperKind := PaperKind80mm;

    FClient.ReadReceiptText(Command);
    WriteFileData(GetModulePath + 'ReadReceiptText.txt', FClient.AnswerJson);
    Check(Command.Data.Lines.Count > 0);
    WriteFileData(GetModulePath + 'ReadReceiptText2.txt', Command.Data.GetText);
  finally
    Command.Free;
  end;
end;

procedure TWebkassaClientTest.TestReadUnits;
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

procedure TWebkassaClientTest.TestCashIn;
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

procedure TWebkassaClientTest.TestCashOut;
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

procedure TWebkassaClientTest.TestUploadOrder;
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

procedure TWebkassaClientTest.TestRegistration;
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

procedure TWebkassaClientTest.TestReadCashboxState;
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

procedure TWebkassaClientTest.TestSumInCashbox;
var
  SumInCashbox: Currency;
  XReport: TZXReportCommand;
  CashCommand: TMoneyOperationCommand;
begin
  XReport := TZXReportCommand.Create;
  CashCommand := TMoneyOperationCommand.Create;
  try
    FClient.Connect;
    XReport.Request.Token := FClient.Token;
    XReport.Request.CashboxUniqueNumber := FClient.CashboxNumber;
    FClient.XReport(XReport);

    SumInCashbox := XReport.Data.SumInCashbox;
    // Cashin
    CashCommand.Request.token := FClient.Token;
	  CashCommand.Request.CashboxUniqueNumber := FClient.CashboxNumber;
	  CashCommand.Request.OperationType := OperationTypeCashIn;
	  CashCommand.Request.Sum := 12345.67;
	  CashCommand.Request.ExternalCheckNumber := '';
    FClient.MoneyOperation(CashCommand);
    SumInCashbox := SumInCashbox + 12345.67;

    XReport.Request.Token := FClient.Token;
    XReport.Request.CashboxUniqueNumber := FClient.CashboxNumber;
    FClient.XReport(XReport);
    CheckEquals(SumInCashbox, XReport.Data.SumInCashbox, 'SumInCashbox 1');
    // Cashout
    CashCommand.Request.token := FClient.Token;
	  CashCommand.Request.CashboxUniqueNumber := FClient.CashboxNumber;
	  CashCommand.Request.OperationType := OperationTypeCashOut;
	  CashCommand.Request.Sum := 12345.67;
	  CashCommand.Request.ExternalCheckNumber := '';
    FClient.MoneyOperation(CashCommand);
    SumInCashbox := SumInCashbox - 12345.67;

    XReport.Request.Token := FClient.Token;
    XReport.Request.CashboxUniqueNumber := FClient.CashboxNumber;
    FClient.XReport(XReport);
    CheckEquals(SumInCashbox, XReport.Data.SumInCashbox, 'SumInCashbox 2');
  finally
    XReport.Free;
    CashCommand.Free;
  end;
end;

initialization
  FReceipt := TSendReceiptCommand.Create;
  RegisterTest('', TWebkassaClientTest.Suite);

finalization
  FReceipt.Free;

end.

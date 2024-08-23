unit duWebkassaClient;

interface

uses
  // VCL
  Windows, SysUtils, Classes,
  // DUnit
  TestFramework, TntClasses,
  // Indy
  IdContext, IdHTTP, IdHTTPServer, IdHeaderList, IdGlobalProtocols,
  IdCustomHTTPServer,
  // This
  LogFile, WebkassaClient, JsonUtils, FileUtils, DebugUtils;

type
  { TWebkassaClientTest }

  TWebkassaClientTest = class(TTestCase)
  private
    FLogger: ILogFile;
    FClient: TWebkassaClient;
    procedure ServerConnect(AContext: TIdContext);
    procedure ServerCreatePostStream(AContext: TIdContext;
      AHeaders: TIdHeaderList; var VPostStream: TStream);
    procedure ServerCommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo);
    procedure ClientHeadersAvailable(Sender: TObject;
      AHeaders: TIdHeaderList; var VContinue: Boolean);
  protected
    procedure SetUp; override;
    procedure TearDown; override;
    // !!!
    procedure TestAlternativeDomainNames;
    procedure TestIdHeaderList;
  published
    procedure TestAuthenticate;
    procedure TestChangeToken;

    procedure TestZReportRequest;
    procedure TestZReportAnswer;
    procedure TestZReportAnswer2;
    procedure TestZReport;
    procedure TestXReport;
    procedure TestJournalReport;
    procedure TestReadCahiers;
    procedure TestReadReceipt;
    procedure TestReadReceiptText;
    procedure TestReadUnits;
    procedure TestUploadOrder;
    procedure TestMoneyOperation;
    procedure TestSendReceipt;
    procedure TestSendReceipt2;
  end;

implementation

const
  CRLF = #13#10;

{ TWebkassaClientTest }

procedure TWebkassaClientTest.SetUp;
begin
  FLogger := TLogFile.Create;
  FClient := TWebkassaClient.Create(FLogger);
  FClient.TestMode := True;
end;

procedure TWebkassaClientTest.TearDown;
begin
  FClient.Free;
end;

procedure TWebkassaClientTest.TestAuthenticate;
var
  CommandJson: string;
  Command: TAuthCommand;
begin
  Command := TAuthCommand.Create;
  try
    Command.Request.Login := 'login@webkassa.kz';
    Command.Request.Password := '123';

    FClient.AnswerJson := ReadFileData(GetModulePath + 'AuthenticateAnswer.txt');
    CheckEquals(True, FClient.Authenticate(Command), 'FClient.Authenticate');
    CheckEquals('0b8557d0139945a582fcfee661ffad49', Command.Data.Token, 'Command.Data.Token');
    CommandJson := ReadFileData(GetModulePath + 'AuthenticateRequest.txt');
    CheckEquals(CommandJson, FClient.CommandJson, 'CommandJson');
  finally
    Command.Free;
  end;
end;

procedure TWebkassaClientTest.TestChangeToken;
var
  CommandJson: string;
  Command: TChangeTokenCommand;
begin
  FClient.Token := '0b8557d0139945a582fcfee661ffad49';
  Command := TChangeTokenCommand.Create;
  try
    Command.Request.CashboxUniqueNumber := 'SWK00000019';
    Command.Request.OfdToken := 12345678;

    FClient.AnswerJson := ReadFileData(GetModulePath + 'ChangeTokenAnswer.txt');
    CheckEquals(True, FClient.ChangeToken(Command), 'FClient.ChangeToken');
    CheckEquals(True, Command.Data, 'Command.Data');
    CommandJson := ReadFileData(GetModulePath + 'ChangeTokenRequest.txt');
    CheckEquals(CommandJson, FClient.CommandJson, 'CommandJson');
  finally
    Command.Free;
  end;
end;

procedure TWebkassaClientTest.TestZReportRequest;
var
  JsonText: string;
  Request: TCashboxRequest;
  ExpectedJsonText: string;
begin
  Request := TCashboxRequest.Create;
  try
    Request.Token := '0b8557d0139945a582fcfee661ffad49';
    Request.CashboxUniqueNumber := 'SWK00000019';
    JsonText := ObjectToJson(Request);
    ExpectedJsonText := ReadFileData(GetModulePath + 'ZXReportRequest.txt');
    if JsonText <> ExpectedJsonText then
      WriteFileData(GetModulePath + 'ZXReportRequestError.txt', JsonText);

    CheckEquals(ExpectedJsonText, JsonText);

    Request.Token := '';
    Request.CashboxUniqueNumber := '';
    JsonToObject(JsonText, Request);
    CheckEquals('0b8557d0139945a582fcfee661ffad49', Request.Token);
    CheckEquals('SWK00000019', Request.CashboxUniqueNumber);
  finally
    Request.Free;
  end;
end;

procedure TWebkassaClientTest.TestZReportAnswer;
var
  JsonText: string;
  ExpectedJsonText: string;
  Command: TZXReportCommand;
begin
  Command := TZXReportCommand.Create;
  try
    ExpectedJsonText := ReadFileData(GetModulePath + 'ZXReportAnswer.txt');
    JsonToObject(ExpectedJsonText, Command);

    CheckEquals(2, Command.Data.ReportNumber, 'Command.Data.ReportNumber');
    CheckEquals('Индивидуальный предприниматель Иванов Иван Иванович',
      Command.Data.TaxPayerName, 'Command.Data.TaxPayerName');
    CheckEquals('111111111111', Command.Data.TaxpayerIN, 'Command.Data.TaxpayerIN');
    CheckEquals(True, Command.Data.TaxPayerVAT, 'Command.Data.TaxPayerVAT');
    CheckEquals('12345', Command.Data.TaxPayerVATSeria, 'Command.Data.TaxPayerVATSeria');
    CheckEquals('1234567', Command.Data.TaxPayerVATNumber, 'Command.Data.TaxPayerVATNumber');
    CheckEquals(7646, Command.Data.CashboxIN, 'Command.Data.CashboxIN');
    CheckEquals('100000000007', Command.Data.CashboxRN, 'Command.Data.CashboxRN');
    CheckEquals('25.05.2016 11:15:11', Command.Data.StartOn, 'Command.Data.StartOn');
    CheckEquals('25.05.2016 11:33:30', Command.Data.ReportOn, 'Command.Data.ReportOn');
    CheckEquals('25.05.2016 11:33:30', Command.Data.CloseOn, 'Command.Data.CloseOn');
    CheckEquals(1, Command.Data.CashierCode, 'Command.Data.CashierCode');
    CheckEquals(21, Command.Data.ShiftNumber, 'Command.Data.ShiftNumber');
    CheckEquals(2, Command.Data.DocumentCount, 'Command.Data.DocumentCount');
    CheckEquals(123.45, Command.Data.PutMoneySum, 0.001, 'Command.Data.PutMoneySum');
    CheckEquals(234.56, Command.Data.TakeMoneySum, 0.001, 'Command.Data.TakeMoneySum');
    CheckEquals(757292213, Command.Data.ControlSum, 0.001, 'Command.Data.ControlSum');
    CheckEquals(False, Command.Data.OfflineMode, 'Command.Data.OfflineMode');
    CheckEquals(False, Command.Data.CashboxOfflineMode, 'Command.Data.CashboxOfflineMode');
    CheckEquals(17500, Command.Data.SumInCashbox, 0.001, 'Command.Data.SumInCashbox');
    CheckEquals(1, Command.Data.Sell.PaymentsByTypesApiModel.Count);
    CheckEquals(1050, Command.Data.Sell.PaymentsByTypesApiModel[0].Sum, 0.001);
    CheckEquals(0, Command.Data.Sell.PaymentsByTypesApiModel[0]._Type, 0.001);
    CheckEquals(0, Command.Data.Sell.Discount, 0.001, 'Command.Data.Sell.Discount');
    CheckEquals(0, Command.Data.Sell.Markup, 0.001, 'Command.Data.Sell.Markup');
    CheckEquals(1050, Command.Data.Sell.Taken, 0.001, 'Command.Data.Sell.Taken');
    CheckEquals(0, Command.Data.Sell.Change, 0.001, 'Command.Data.Sell.Change');
    CheckEquals(1, Command.Data.Sell.Count);
    CheckEquals(0, Command.Data.Sell.VAT, 0.001, 'Command.Data.Sell.VAT');
    CheckEquals(22690, Command.Data.EndNonNullable.Sell, 0.001, 'Command.Data.EndNonNullable.Sell');
    CheckEquals(123, Command.Data.EndNonNullable.Buy, 0.001, 'Command.Data.EndNonNullable.Buy');
    CheckEquals(234, Command.Data.EndNonNullable.ReturnSell, 0.001, 'Command.Data.EndNonNullable.ReturnSell');
    CheckEquals(345, Command.Data.EndNonNullable.ReturnBuy, 0.001, 'Command.Data.EndNonNullable.ReturnBuy');
    CheckEquals(21640, Command.Data.StartNonNullable.Sell, 0.001, 'Command.Data.StartNonNullable.Sell');
    CheckEquals(12, Command.Data.StartNonNullable.Buy, 0.001, 'Command.Data.StartNonNullable.Buy');
    CheckEquals(23, Command.Data.StartNonNullable.ReturnSell, 0.001, 'Command.Data.StartNonNullable.ReturnSell');
    CheckEquals(34, Command.Data.StartNonNullable.ReturnBuy, 0.001, 'Command.Data.StartNonNullable.ReturnBuy');
    CheckEquals('АО Казахтелеком', Command.Data.Ofd.Name);
    CheckEquals('consumer.oofd.kz', Command.Data.Ofd.Host);
    CheckEquals(1, Command.Data.Ofd.Code);

    JsonText := ObjectToJson(Command);
    if JsonText <> ExpectedJsonText then
      WriteFileData(GetModulePath + 'ZXReportAnswerError.txt', JsonText);

    CheckEquals(ExpectedJsonText, JsonText, 'JsonText <> ExpectedJsonText');
  finally
    Command.Free;
  end;
end;

procedure TWebkassaClientTest.TestZReportAnswer2;
var
  ExpectedJsonText: string;
  Command: TZXReportCommand;
begin
  Command := TZXReportCommand.Create;
  try
    ExpectedJsonText := ReadFileData(GetModulePath + 'ZXReportAnswer2.txt');
    JsonToObject(ExpectedJsonText, Command);

    CheckEquals(17, Command.Data.ReportNumber, 'Command.Data.ReportNumber');
  finally
    Command.Free;
  end;
end;

procedure TWebkassaClientTest.TestZReport;
var
  Command: TZXReportCommand;
begin
  Command := TZXReportCommand.Create;
  try
    Command.Request.Token := '0b8557d0139945a582fcfee661ffad49';
    Command.Request.CashboxUniqueNumber := 'SWK00000019';

    FClient.AnswerJson := ReadFileData(GetModulePath + 'ZXReportAnswer.txt');
    CheckEquals(True, FClient.ZReport(Command), 'FClient.ZReport');

    CheckEquals(2, Command.Data.ReportNumber, 'Command.Data.ReportNumber');
    CheckEquals('Индивидуальный предприниматель Иванов Иван Иванович',
      Command.Data.TaxPayerName, 'Command.Data.TaxPayerName');
    CheckEquals('111111111111', Command.Data.TaxpayerIN, 'Command.Data.TaxpayerIN');
    CheckEquals(True, Command.Data.TaxPayerVAT, 'Command.Data.TaxPayerVAT');
    CheckEquals('12345', Command.Data.TaxPayerVATSeria, 'Command.Data.TaxPayerVATSeria');
    CheckEquals('1234567', Command.Data.TaxPayerVATNumber, 'Command.Data.TaxPayerVATNumber');
    CheckEquals(7646, Command.Data.CashboxIN, 'Command.Data.CashboxIN');
    CheckEquals('100000000007', Command.Data.CashboxRN, 'Command.Data.CashboxRN');
    CheckEquals('25.05.2016 11:15:11', Command.Data.StartOn, 'Command.Data.StartOn');
    CheckEquals('25.05.2016 11:33:30', Command.Data.ReportOn, 'Command.Data.ReportOn');
    CheckEquals('25.05.2016 11:33:30', Command.Data.CloseOn, 'Command.Data.CloseOn');
    CheckEquals(1, Command.Data.CashierCode, 'Command.Data.CashierCode');
    CheckEquals(21, Command.Data.ShiftNumber, 'Command.Data.ShiftNumber');
    CheckEquals(2, Command.Data.DocumentCount, 'Command.Data.DocumentCount');
    CheckEquals(123.45, Command.Data.PutMoneySum, 0.001, 'Command.Data.PutMoneySum');
    CheckEquals(234.56, Command.Data.TakeMoneySum, 0.001, 'Command.Data.TakeMoneySum');
    CheckEquals(757292213, Command.Data.ControlSum, 0.001, 'Command.Data.ControlSum');
    CheckEquals(False, Command.Data.OfflineMode, 'Command.Data.OfflineMode');
    CheckEquals(False, Command.Data.CashboxOfflineMode, 'Command.Data.CashboxOfflineMode');
    CheckEquals(17500, Command.Data.SumInCashbox, 0.001, 'Command.Data.SumInCashbox');
    CheckEquals(1, Command.Data.Sell.PaymentsByTypesApiModel.Count);
    CheckEquals(1050, Command.Data.Sell.PaymentsByTypesApiModel[0].Sum, 0.001);
    CheckEquals(0, Command.Data.Sell.PaymentsByTypesApiModel[0]._Type);
    CheckEquals(0, Command.Data.Sell.Discount, 0.001, 'Command.Data.Sell.Discount');
    CheckEquals(0, Command.Data.Sell.Markup, 0.001, 'Command.Data.Sell.Markup');
    CheckEquals(1050, Command.Data.Sell.Taken, 0.001, 'Command.Data.Sell.Taken');
    CheckEquals(0, Command.Data.Sell.Change, 0.001, 'Command.Data.Sell.Change');
    CheckEquals(1, Command.Data.Sell.Count);
    CheckEquals(0, Command.Data.Sell.VAT, 0.001, 'Command.Data.Sell.VAT');
    CheckEquals(22690, Command.Data.EndNonNullable.Sell, 0.001, 'Command.Data.EndNonNullable.Sell');
    CheckEquals(123, Command.Data.EndNonNullable.Buy, 0.001, 'Command.Data.EndNonNullable.Buy');
    CheckEquals(234, Command.Data.EndNonNullable.ReturnSell, 0.001, 'Command.Data.EndNonNullable.ReturnSell');
    CheckEquals(345, Command.Data.EndNonNullable.ReturnBuy, 0.001, 'Command.Data.EndNonNullable.ReturnBuy');
    CheckEquals(21640, Command.Data.StartNonNullable.Sell, 0.001, 'Command.Data.StartNonNullable.Sell');
    CheckEquals(12, Command.Data.StartNonNullable.Buy, 0.001, 'Command.Data.StartNonNullable.Buy');
    CheckEquals(23, Command.Data.StartNonNullable.ReturnSell, 0.001, 'Command.Data.StartNonNullable.ReturnSell');
    CheckEquals(34, Command.Data.StartNonNullable.ReturnBuy, 0.001, 'Command.Data.StartNonNullable.ReturnBuy');
    CheckEquals('АО Казахтелеком', Command.Data.Ofd.Name);
    CheckEquals('consumer.oofd.kz', Command.Data.Ofd.Host);
    CheckEquals(1, Command.Data.Ofd.Code);
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
    Command.Request.Token := '0b8557d0139945a582fcfee661ffad49';
    Command.Request.CashboxUniqueNumber := 'SWK00000019';

    FClient.AnswerJson := ReadFileData(GetModulePath + 'XReport.txt');
    CheckEquals(True, FClient.XReport(Command), 'FClient.ZReport');

    CheckEquals(13, Command.Data.ReportNumber, 'Command.Data.ReportNumber');
    CheckEquals('ТОО SOFT IT KAZAKHSTAN',
      Command.Data.TaxPayerName, 'Command.Data.TaxPayerName');
    CheckEquals('131240010479', Command.Data.TaxpayerIN, 'Command.Data.TaxpayerIN');
    CheckEquals(True, Command.Data.TaxPayerVAT, 'Command.Data.TaxPayerVAT');
    CheckEquals('00000', Command.Data.TaxPayerVATSeria, 'Command.Data.TaxPayerVATSeria');
    CheckEquals('0000000', Command.Data.TaxPayerVATNumber, 'Command.Data.TaxPayerVATNumber');
    CheckEquals(270, Command.Data.CashboxIN, 'Command.Data.CashboxIN');
    CheckEquals('211030200207', Command.Data.CashboxRN, 'Command.Data.CashboxRN');
    CheckEquals('09.08.2022 19:42:40', Command.Data.StartOn, 'Command.Data.StartOn');
    CheckEquals('12.08.2022 16:49:31', Command.Data.ReportOn, 'Command.Data.ReportOn');
    CheckEquals('12.08.2022 01:49:07', Command.Data.CloseOn, 'Command.Data.CloseOn');
    CheckEquals(1, Command.Data.CashierCode, 'Command.Data.CashierCode');
    CheckEquals(154, Command.Data.ShiftNumber, 'Command.Data.ShiftNumber');
    CheckEquals(13, Command.Data.DocumentCount, 'Command.Data.DocumentCount');
    CheckEquals(0, Command.Data.PutMoneySum, 0.001, 'Command.Data.PutMoneySum');
    CheckEquals(0, Command.Data.TakeMoneySum, 0.001, 'Command.Data.TakeMoneySum');
    CheckEquals(1469582357, Command.Data.ControlSum, 0.001, 'Command.Data.ControlSum');

    CheckEquals(False, Command.Data.OfflineMode, 'Command.Data.OfflineMode');
    CheckEquals(False, Command.Data.CashboxOfflineMode, 'Command.Data.CashboxOfflineMode');
    CheckEquals(3670106.06, Command.Data.SumInCashbox, 0.001, 'Command.Data.SumInCashbox');
    CheckEquals(0, Command.Data.Sell.PaymentsByTypesApiModel.Count);
    CheckEquals(0, Command.Data.Sell.Discount, 0.001);
    CheckEquals(0, Command.Data.Sell.Markup, 0.001);
    CheckEquals(0, Command.Data.Sell.Taken, 0.001);
    CheckEquals(0, Command.Data.Sell.Change, 0.001);
    CheckEquals(0, Command.Data.Sell.Count);
    CheckEquals(0, Command.Data.Sell.VAT, 0.001);
    CheckEquals(11957324.06, Command.Data.EndNonNullable.Sell, 0.001);
    CheckEquals(0, Command.Data.EndNonNullable.Buy, 0.001);
    CheckEquals(361690.47, Command.Data.EndNonNullable.ReturnSell, 0.001);
    CheckEquals(0, Command.Data.EndNonNullable.ReturnBuy, 0.001);
    CheckEquals(11956953.71, Command.Data.StartNonNullable.Sell, 0.001);
    CheckEquals(0, Command.Data.StartNonNullable.Buy, 0.001);
    CheckEquals(361690.47, Command.Data.StartNonNullable.ReturnSell, 0.001);
    CheckEquals(0, Command.Data.StartNonNullable.ReturnBuy, 0.001);
    CheckEquals('АО "КазТранском"', Command.Data.Ofd.Name);
    CheckEquals('dev.kofd.kz/consumer', Command.Data.Ofd.Host);
    CheckEquals(3, Command.Data.Ofd.Code);
  finally
    Command.Free;
  end;
end;

procedure TWebkassaClientTest.TestJournalReport;
var
  CommandJson: string;
  Item: TJournalReportItem;
  Command: TJournalReportCommand;
begin
  FClient.Token := '0b8557d0139945a582fcfee661ffad49';
  Command := TJournalReportCommand.Create;
  try
    Command.Request.CashboxUniqueNumber := 'SWK00000019';
    Command.Request.ShiftNumber := 3;
    FClient.AnswerJson := ReadFileData(GetModulePath + 'JournalReportAnswer.txt');
    CheckEquals(True, FClient.JournalReport(Command), 'FClient.JournalReport');

    CommandJson := ReadFileData(GetModulePath + 'JournalReportRequest.txt');
    CheckEquals(CommandJson, FClient.CommandJson, 'CommandJson');
    CheckEquals(3, Command.Data.Count, 'Command.Data.Count');
    // Item 0
    Item := TJournalReportItem(Command.Data.Items[0]);
    CheckEquals('Продажа', Item.OperationTypeText);
    CheckEquals(19500, Item.Sum);
    CheckEquals('01.09.2016 12:50:57', Item.Date);
    CheckEquals(1, Item.EmployeeCode);
    CheckEquals('2883145944', Item.Number);
    CheckEquals(False, Item.IsOffline);
    // Item 1
    Item := TJournalReportItem(Command.Data.Items[1]);
    CheckEquals('Внесение денег в кассу', Item.OperationTypeText);
    CheckEquals(2000, Item.Sum);
    CheckEquals('01.09.2016 12:49:49', Item.Date);
    CheckEquals(1, Item.EmployeeCode);
    CheckEquals('', Item.Number);
    CheckEquals(False, Item.IsOffline);
    CheckEquals('123456789', Item.ExternalOperationld);
  finally
    Command.Free;
  end;
end;

procedure TWebkassaClientTest.TestReadCahiers;
var
  Item: TCashier;
  Command: TCashierCommand;
begin
  Command := TCashierCommand.Create;
  try
    Command.Request.Token := '0b8557d0139945a582fcfee661ffad49';
    FClient.AnswerJson := ReadFileData(GetModulePath + 'ReadCahiersAnswer.txt');
    CheckEquals(True, FClient.ReadCashiers(Command), 'FClient.JournalReport');

    CheckEquals(3, Command.Data.Count, 'Command.Data.Count');
    // Item 0
    Item := Command.Data.Items[0] as TCashier;
    CheckEquals('Пупкин В.С.', Item.FullName, 'Item.FullName');
    CheckEquals('pochta@pochta.com', Item.Email, 'Item.Email');
    CheckEquals(2, Item.Cashboxes.Count, 'Item.Cashboxes.Count');
    CheckEquals('SWK00000019', Item.Cashboxes[0], 'Item.Cashboxes[0]');
    CheckEquals('SWK00000020', Item.Cashboxes[1], 'Item.Cashboxes[1]');
    // Item 1
    Item := Command.Data.Items[1] as TCashier;
    CheckEquals('Сумкин Ф. Б.', Item.FullName, 'Item.FullName');
    CheckEquals('pochtal212@pochta.com', Item.Email, 'Item.Email');
    CheckEquals(1, Item.Cashboxes.Count, 'Item.Cashboxes.Count');
    CheckEquals('SWK00000019', Item.Cashboxes[0], 'Item.Cashboxes[0]');
  finally
    Command.Free;
  end;
end;

procedure TWebkassaClientTest.TestReadReceipt;
var
  Item: TPositionItem;
  Command: TReceiptCommand;
begin
  Command := TReceiptCommand.Create;
  try
    Command.Request.CashboxUniqueNumber := 'SWKO0030586';
    Command.Request.Token := '6a4eaa2e5f764950blelce3712110d3d';
    Command.Request.Number := '445113829';
    Command.Request.ShiftNumber := 16;

    FClient.AnswerJson := ReadFileData(GetModulePath + 'ReadReceiptAnswer.txt');
    CheckEquals(True, FClient.ReadReceipt(Command), 'FClient.ReadReceipt');

    CheckEquals('SWK00030586', Command.Data.CashboxUniqueNumber);
    CheckEquals(True, Command.Data.VATPayer);
    CheckEquals(1, Command.Data.Positions.Count);
    // 0
    Item := Command.Data.Positions.Items[0] as TPositionItem;
    CheckEquals('Позиция', Item.PositionName);
    CheckEquals('1', Item.PositionCode);

  finally
    Command.Free;
  end;
end;

procedure TWebkassaClientTest.TestReadReceiptText;
var
  Item: TReceiptTextItem;
  Command: TReceiptTextCommand;
begin
  Command := TReceiptTextCommand.Create;
  try
    Command.Request.CashboxUniqueNumber := 'SWK00000001';
    Command.Request.externalCheckNumber := '53592270-5a89-4af7-ada7-a71be203e798';
    Command.Request.isDuplicate := True;
    Command.Request.paperKind := 0;
    Command.Request.token := 'a71300b07342468edc4e7dd7aallfa40';

    FClient.AnswerJson := ReadFileData(GetModulePath + 'ReadReceiptTextAnswer.txt');
    CheckEquals(True, FClient.ReadReceiptText(Command), 'FClient.ReadReceiptText');

    CheckEquals(2, Command.Data.Lines.Count, 'Command.Data.Lines.Count');
    Item := Command.Data.Lines.Items[0] as TReceiptTextItem;
    CheckEquals(1, Item.Order, 'Item.Order');
    CheckEquals(0, Item._Type, 'Item._Type');
    CheckEquals('          ДУБЛИКАТ           ', Item.Value, 'Item.Value');
    CheckEquals(1, Item.Style, 'Item.Style');

  finally
    Command.Free;
  end;
end;

procedure TWebkassaClientTest.TestReadUnits;
var
  Item: TUnitItem;
  Command: TReadUnitsCommand;
begin
  Command := TReadUnitsCommand.Create;
  try
    Command.Request.token := 'a71300b07342468edc4e7dd7aallfa40';
    FClient.AnswerJson := ReadFileData(GetModulePath + 'ReadUnitsAnswer.txt');
    CheckEquals(True, FClient.ReadUnits(Command), 'FClient.ReadUnits');
    CheckEquals(2, Command.Data.Count, 'Command.Data.Count');
    // 0
    Item := Command.Data.Items[0] as TUnitItem;
    CheckEquals(796, Item.Code, 'Item.Code');
    CheckEquals('шт', Item.NameRu, 'Item.NameRu');
    CheckEquals('дана', Item.NameKz, 'Item.NameKz');
    CheckEquals('pcs', Item.NameEn, 'Item.NameEn');
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
  FClient.token := '6a4eaa2e4b744950blelce3312470d3d';
  Command := TUploadOrderCommand.Create;
  try
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

procedure TWebkassaClientTest.TestMoneyOperation;
var
  CommandJson: string;
  Command: TMoneyOperationCommand;
begin
  FClient.token := '0b8557d0139945a582fcfee661ffad49';
  Command := TMoneyOperationCommand.Create;
  try
	  Command.Request.CashboxUniqueNumber := 'SWK00000019';
	  Command.Request.OperationType := 1;
	  Command.Request.Sum := 1500;
	  Command.Request.ExternalCheckNumber := '123456789';

    FClient.AnswerJson := ReadFileData(GetModulePath + 'MoneyOperationAnswer.txt');
    CheckEquals(True, FClient.MoneyOperation(Command), 'FClient.MoneyOperation');
    CommandJson := ReadFileData(GetModulePath + 'MoneyOperationRequest.txt');
    if CommandJson <> FClient.CommandJson then
      WriteFileData(GetModulePath + 'MoneyOperationRequestError.txt', FClient.CommandJson);
    CheckEquals(CommandJson, FClient.CommandJson, 'CommandJson');

    CheckEquals(True, Command.Data.OfflineMode, 'Command.Data.OfflineMode');
    CheckEquals(True, Command.Data.CashboxOfflineMode, 'Command.Data.CashboxOfflineMode');
    CheckEquals('15.02.2018 17:18:29', Command.Data.DateTime, 'Command.Data.DateTime');
    CheckEquals(56350, Command.Data.Sum, 'Command.Data.Sum');
    CheckEquals('SWK00013404', Command.Data.Cashbox.UniqueNumber);
    CheckEquals('000134040000', Command.Data.Cashbox.RegistrationNumber);
    CheckEquals('561', Command.Data.Cashbox.IdentityNumber);
    CheckEquals('ул. Пушкина 17, оф.521', Command.Data.Cashbox.Address);
    CheckEquals('АО Казахтелеком', Command.Data.Cashbox.Ofd.Name);
    CheckEquals('consumer.oofd.kz', Command.Data.Cashbox.Ofd.Host);
    CheckEquals(1, Command.Data.Cashbox.Ofd.Code);
  finally
    Command.Free;
  end;
end;

procedure TWebkassaClientTest.TestSendReceipt;
var
  JsonText: string;
  CommandJson: string;
  Command: TSendReceiptCommand;
begin
  Command := TSendReceiptCommand.Create;
  try
    Command.Request.CashboxUniqueNumber := 'SWKO0030586';
    Command.Request.Token := '6a4eaa2e5f764950blelce3712110d3d';
    Command.Request.CustomerXin := '123';

    JsonText := ObjectToJson(Command.Request);
    CommandJson := ReadFileData(GetModulePath + 'SendReceiptRequest.txt');
    if CommandJson <> JsonText then
    begin
      WriteFileData(GetModulePath + 'SendReceiptRequestError.txt', JsonText);
      CheckEquals(CommandJson, JsonText);
    end;
  finally
    Command.Free;
  end;
end;

procedure TWebkassaClientTest.TestSendReceipt2;
var
  JsonText: string;
  CommandJson: string;
  Command: TSendReceiptCommand;
begin
  Command := TSendReceiptCommand.Create;
  try
    Command.Request.CashboxUniqueNumber := 'SWKO0030586';
    Command.Request.Token := '6a4eaa2e5f764950blelce3712110d3d';
    Command.Request.CustomerEmail := 'test@test.com';
    Command.Request.CustomerPhone := '+7934857938457';
    Command.Request.CustomerXin := '';

    JsonText := ObjectToJson(Command.Request);
    CommandJson := ReadFileData(GetModulePath + 'SendReceiptRequest2.txt');
    if CommandJson <> JsonText then
    begin
      WriteFileData(GetModulePath + 'SendReceiptRequestError2.txt', JsonText);
      CheckEquals(CommandJson, JsonText);
    end;
  finally
    Command.Free;
  end;
end;

(*
function TWebkassaClient.CheckForError(const JsonText: WideString): Boolean;
var
  Item: TErrorItem;
  ErrorResult: TErrorResult;
begin
  Result := True;
  ErrorResult := TErrorResult.Create;
  try
    JsonToObject(JsonText, ErrorResult);
    if ErrorResult.Errors.Count > 0 then
    begin
      Item := ErrorResult.Errors.Items[0] as TErrorItem;
      FLastErrorCode := Item.Code;
      FLastErrorText := Item.Text;
      if FRaiseError then
        raise Exception.CreateFmt('%d, %s', [Item.Code, Item.Text]);

      Result := False;
    end;
  finally
    ErrorResult.Free;
  end;
end;

*)


// https://devkkm.webkassa.kz/

procedure TWebkassaClientTest.TestAlternativeDomainNames;
var
  Client: TIdHTTP;
  Server: TIdHTTPServer;
  CommandJson: string;
begin
  ODS('TWebkassaClientTest.TestAlternativeDomainNames.0');
  Client := TIdHTTP.Create;
  Server := TIdHTTPServer.Create;
  try
    Server.Active := True;
    Server.OnConnect := ServerConnect;
    Server.OnCreatePostStream := ServerCreatePostStream;
    Server.OnCommandGet := ServerCommandGet;

    Client.ProtocolVersion := pv1_1;
    Client.Request.BasicAuthentication := False;
    Client.Request.UserAgent := '';
    Client.Request.Accept := 'application/json, */*; q=0.01';
    Client.Request.ContentType := 'application/json; charset=UTF-8';
    Client.Request.CharSet := 'utf-8';
    Client.OnHeadersAvailable := ClientHeadersAvailable;

    CommandJson := ReadFileData(GetModulePath + 'AuthenticateRequest.txt');
    Client.Post('https://127.0.0.1/', CommandJson);
  finally
    Server.Free;
    Client.Free;
    ODS('TWebkassaClientTest.TestAlternativeDomainNames.1');
  end;
end;

procedure TWebkassaClientTest.ClientHeadersAvailable(Sender: TObject;
  AHeaders: TIdHeaderList; var VContinue: Boolean);
begin
  ODS('TWebkassaClientTest.ClientHeadersAvailable');

end;

procedure TWebkassaClientTest.ServerCommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  ODS('TWebkassaClientTest.ServerCommandGet');
  AResponseInfo.ResponseNo := 505;
  AResponseInfo.ResponseText := 'RSHTTPHTTPVersionNotSupported';
  AResponseInfo.RawHeaders.AddValue('AlternativeDomainNames',
    'https://devkkm.webkassa.kz/,https://devkkm.webkassa.com/');
end;

(*
Redirect is a procedure that allows TIdHTTPResponseInfo to redirect the
HTTP client to specific URL. Redirect sets ResponseNo to 302, the HTTP
response code that indicates a temporary redirection has been performed.
To indicate that a resource has been permanently moved, set ResponseNo to 301.
*)

procedure TWebkassaClientTest.ServerCreatePostStream(AContext: TIdContext;
  AHeaders: TIdHeaderList; var VPostStream: TStream);
begin
  ODS('TWebkassaClientTest.ServerCreatePostStream');
  AHeaders.AddValue('AlternativeDomainNames',
    'https://devkkm.webkassa.kz/,https://devkkm.webkassa.com/');
end;

procedure TWebkassaClientTest.ServerConnect(AContext: TIdContext);
begin
  ODS('TWebkassaClientTest.ServerConnect');
end;

procedure TWebkassaClientTest.TestIdHeaderList;
var
  Text: string;
  Lines: TStrings;
  Headers: TIdHeaderList;
const
  AName = 'AlternativeDomainNames';
  AText = 'https://devkkm.webkassa.kz/,https://devkkm.webkassa.com/';
begin
  Lines := TStringList.Create;
  Headers := TIdHeaderList.Create(QuoteHTTP);
  try
    Headers.AddValue(AName, AText);
    Text := Headers.Values[AName];
    CheckEquals(Text, AText);

    Headers.Extract(AName, Lines);
    CheckEquals(1, Lines.Count, 'Lines.Count');
    CheckEquals(AText, Lines[0], 'Lines[0]');
  finally
    Lines.Free;
    Headers.Free;
  end;
end;

initialization
  RegisterTest('', TWebkassaClientTest.Suite);

end.

unit OposEventsAdapter;

interface

uses
  // This
  OposEvents;

type
  TDirectIOEvent = procedure(ASender: TObject; EventNumber: Integer;
    var pData: Integer; var pString: WideString) of object;
  TErrorEvent = procedure(ASender: TObject; ResultCode: Integer;
    ResultCodeExtended: Integer; ErrorLocus: Integer; var pErrorResponse: Integer) of object;
  TOutputCompleteEvent = procedure(ASender: TObject; OutputID: Integer) of object;
  TStatusUpdateEvent = procedure(ASender: TObject; Data: Integer) of object;

  { TOposEventsAdapter }

  TOposEventsAdapter = class(TInterfacedObject, IOposEvents)
  private
    FOnErrorEvent: TErrorEvent;
    FOnDirectIOEvent: TDirectIOEvent;
    FOnStatusUpdateEvent: TStatusUpdateEvent;
    FOnOutputCompleteEvent: TOutputCompleteEvent;
  public
    // IOposEvents
    procedure DataEvent(Status: Integer);
    procedure StatusUpdateEvent(Data: Integer);
    procedure OutputCompleteEvent(OutputID: Integer);
    procedure DirectIOEvent(EventNumber: Integer; var pData: Integer; var pString: WideString);
    procedure ErrorEvent(ResultCode: Integer; ResultCodeExtended: Integer; ErrorLocus: Integer; var pErrorResponse: Integer);

    property OnErrorEvent: TErrorEvent read FOnErrorEvent write FOnErrorEvent;
    property OnDirectIOEvent: TDirectIOEvent read FOnDirectIOEvent write FOnDirectIOEvent;
    property OnStatusUpdateEvent: TStatusUpdateEvent read FOnStatusUpdateEvent write FOnStatusUpdateEvent;
    property OnOutputCompleteEvent: TOutputCompleteEvent read FOnOutputCompleteEvent write FOnOutputCompleteEvent;
  end;

implementation

{ TOposEventsAdapter }

procedure TOposEventsAdapter.DataEvent(Status: Integer);
begin
(*
  if Assigned(FOnDataEvent) then
    FOnDataEvent(Self, Status);
*)
end;

procedure TOposEventsAdapter.DirectIOEvent(EventNumber: Integer;
  var pData: Integer; var pString: WideString);
begin
  if Assigned(FOnDirectIOEvent) then
    FOnDirectIOEvent(Self, EventNumber, pData, pString);
end;

procedure TOposEventsAdapter.ErrorEvent(ResultCode, ResultCodeExtended,
  ErrorLocus: Integer; var pErrorResponse: Integer);
begin
  if Assigned(FOnErrorEvent) then
    FOnErrorEvent(Self, ResultCode, ResultCodeExtended, ErrorLocus, pErrorResponse);
end;

procedure TOposEventsAdapter.OutputCompleteEvent(OutputID: Integer);
begin
  if Assigned(FOnOutputCompleteEvent) then
    FOnOutputCompleteEvent(Self, OutputID);
end;

procedure TOposEventsAdapter.StatusUpdateEvent(Data: Integer);
begin

end;

end.

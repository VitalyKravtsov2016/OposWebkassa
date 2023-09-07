unit PrinterTypes;

interface

type
  { TBarcodeRec }

  TBarcodeRec = record
    Data: WideString; // barcode data
    Text: WideString; // barcode text
    Height: Integer;
    BarcodeType: Integer;
    ModuleWidth: Integer;
    Alignment: Integer;
    Parameter1: Byte;
    Parameter2: Byte;
    Parameter3: Byte;
    Parameter4: Byte;
    Parameter5: Byte;
  end;



implementation

end.

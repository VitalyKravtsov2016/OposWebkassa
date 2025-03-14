unit PtrDirectIO;

interface

const
  /////////////////////////////////////////////////////////////////////////////
  // Check if barcode type can be printed with ESC command
  // It is neccessary for page mode
  // In page mode graphics not supported on Rongta printer

  DIO_PTR_CHECK_BARCODE = 1;
  DIO_PTR_GET_BARCODE_SIZE = 2;

implementation

end.

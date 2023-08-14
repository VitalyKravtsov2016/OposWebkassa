unit ReceiptConst;

interface

const
  CRLF = #13#10;

  /////////////////////////////////////////////////////////////////////////////
  // Template item style

  STYLE_NORMAL        = 0;
  STYLE_BOLD          = 1;
  STYLE_ITALIC        = 2;
  STYLE_DWIDTH        = 3;
  STYLE_DHEIGHT       = 4;
  STYLE_DWIDTH_HEIGHT = 5;
  STYLE_QR_CODE       = 6;
  STYLE_IMAGE         = 7;

  /////////////////////////////////////////////////////////////////////////////
  // Template item types

  TEMPLATE_TYPE_TEXT            = 0;
  TEMPLATE_TYPE_PARAM           = 1;
  TEMPLATE_TYPE_ITEM_FIELD      = 2;
  TEMPLATE_TYPE_JSON_REQ_FIELD  = 3;
  TEMPLATE_TYPE_JSON_ANS_FIELD  = 4;
  TEMPLATE_TYPE_JSON_REC_FIELD  = 5;
  TEMPLATE_TYPE_SEPARATOR       = 6;
  TEMPLATE_TYPE_NEWLINE         = 7;

  /////////////////////////////////////////////////////////////////////////////
  // Alignment constants

  ALIGN_LEFT    = 0;
  ALIGN_CENTER  = 1;
  ALIGN_RIGHT   = 2;

  /////////////////////////////////////////////////////////////////////////////
  // Enabled constants

  TEMPLATE_ITEM_ENABLED             = 0;
  TEMPLATE_ITEM_ENABLED_IF_NOT_ZERO = 1;


implementation

end.

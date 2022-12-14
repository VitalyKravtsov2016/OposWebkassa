unit OposFptr;

/////////////////////////////////////////////////////////////////////
//
// OposFptr.h
//
//   Fiscal Printer header file for OPOS Applications.
//
// Modification history
// ------------------------------------------------------------------
// 1998-03-06 OPOS Release 1.3                                   PDU
// 2001-07-15 OPOS Release 1.6                                   TNN
//   Add values for all 1.6 added properties and method
//   parameters
// 2004-03-22 OPOS Release 1.8                                   CRM
//   Add more values for StatusUpdateEvent.
// 2007-01-30 OPOS Release 1.11                                  CRM
//   Add values for 1.11.
//
/////////////////////////////////////////////////////////////////////

interface

const

/////////////////////////////////////////////////////////////////////
// Fiscal Printer Station Constants
/////////////////////////////////////////////////////////////////////

   FPTR_S_JOURNAL                   = 1;
   FPTR_S_RECEIPT                   = 2;
   FPTR_S_SLIP                      = 4;

   FPTR_S_JOURNAL_RECEIPT           = 3;


/////////////////////////////////////////////////////////////////////
// 'ActualCurrency' Property Constants
/////////////////////////////////////////////////////////////////////

   FPTR_AC_BRC                      =  1;
   FPTR_AC_BGL                      =  2;
   FPTR_AC_EUR                      =  3;
   FPTR_AC_GRD                      =  4;
   FPTR_AC_HUF                      =  5;
   FPTR_AC_ITL                      =  6;
   FPTR_AC_PLZ                      =  7;
   FPTR_AC_ROL                      =  8;
   FPTR_AC_RUR                      =  9;
   FPTR_AC_TRL                      =  10;
   FPTR_AC_CZK                      =  11;  // (added in 1.11)
   FPTR_AC_UAH                      =  12;  // (added in 1.11)
   FPTR_AC_OTHER                    =  200; // (added in 1.11)


/////////////////////////////////////////////////////////////////////
// 'ContractorId' Property Constants
/////////////////////////////////////////////////////////////////////

   FPTR_CID_FIRST                   =  1;
   FPTR_CID_SECOND                  =  2;
   FPTR_CID_SINGLE                  =  3;


/////////////////////////////////////////////////////////////////////
// 'CountryCode' Property Constants
/////////////////////////////////////////////////////////////////////

   FPTR_CC_BRAZIL                   =  $00000001;
   FPTR_CC_GREECE                   =  $00000002;
   FPTR_CC_HUNGARY                  =  $00000004;
   FPTR_CC_ITALY                    =  $00000008;
   FPTR_CC_POLAND                   =  $00000010;
   FPTR_CC_TURKEY                   =  $00000020;
   FPTR_CC_RUSSIA                   =  $00000040;
   FPTR_CC_BULGARIA                 =  $00000080;
   FPTR_CC_ROMANIA                  =  $00000100;
   FPTR_CC_CZECH_REPUBLIC           =  $00000200; // (added in 1.11)
   FPTR_CC_UKRAINE                  =  $00000400; // (added in 1.11)
   FPTR_CC_OTHER                    =  $40000000; // (added in 1.11)


/////////////////////////////////////////////////////////////////////
// 'DateType' Property Constants
/////////////////////////////////////////////////////////////////////

   FPTR_DT_CONF                     =  1;
   FPTR_DT_EOD                      =  2;
   FPTR_DT_RESET                    =  3;
   FPTR_DT_RTC                      =  4;
   FPTR_DT_VAT                      =  5;
   FPTR_DT_START                    =  6; // (added in 1.11)


/////////////////////////////////////////////////////////////////////
// 'ErrorLevel' Property Constants
/////////////////////////////////////////////////////////////////////

   FPTR_EL_NONE                     =  1;
   FPTR_EL_RECOVERABLE              =  2;
   FPTR_EL_FATAL                    =  3;
   FPTR_EL_BLOCKED                  =  4;


/////////////////////////////////////////////////////////////////////
// 'ErrorState', 'PrinterState' Property Constants
/////////////////////////////////////////////////////////////////////

   FPTR_PS_MONITOR                  =  1;
   FPTR_PS_FISCAL_RECEIPT           =  2;
   FPTR_PS_FISCAL_RECEIPT_TOTAL     =  3;
   FPTR_PS_FISCAL_RECEIPT_ENDING    =  4;
   FPTR_PS_FISCAL_DOCUMENT          =  5;
   FPTR_PS_FIXED_OUTPUT             =  6;
   FPTR_PS_ITEM_LIST                =  7;
   FPTR_PS_LOCKED                   =  8;
   FPTR_PS_NONFISCAL                =  9;
   FPTR_PS_REPORT                   = 10;


/////////////////////////////////////////////////////////////////////
// 'FiscalReceiptStation' Property Constants
/////////////////////////////////////////////////////////////////////

   FPTR_RS_RECEIPT                  =  1;
   FPTR_RS_SLIP                     =  2;


/////////////////////////////////////////////////////////////////////
// 'FiscalReceiptType' Property Constants
/////////////////////////////////////////////////////////////////////

   FPTR_RT_CASH_IN                  =  1;
   FPTR_RT_CASH_OUT                 =  2;
   FPTR_RT_GENERIC                  =  3;
   FPTR_RT_SALES                    =  4;
   FPTR_RT_SERVICE                  =  5;
   FPTR_RT_SIMPLE_INVOICE           =  6;
   FPTR_RT_REFUND                   =  7; // (added in 1.11)

/////////////////////////////////////////////////////////////////////
// 'MessageType' Property Constants
/////////////////////////////////////////////////////////////////////

   FPTR_MT_ADVANCE                  =  1;
   FPTR_MT_ADVANCE_PAID             =  2;
   FPTR_MT_AMOUNT_TO_BE_PAID        =  3;
   FPTR_MT_AMOUNT_TO_BE_PAID_BACK   =  4;
   FPTR_MT_CARD                     =  5;
   FPTR_MT_CARD_NUMBER              =  6;
   FPTR_MT_CARD_TYPE                =  7;
   FPTR_MT_CASH                     =  8;
   FPTR_MT_CASHIER                  =  9;
   FPTR_MT_CASH_REGISTER_NUMBER     =  10;
   FPTR_MT_CHANGE                   =  11;
   FPTR_MT_CHEQUE                   =  12;
   FPTR_MT_CLIENT_NUMBER            =  13;
   FPTR_MT_CLIENT_SIGNATURE         =  14;
   FPTR_MT_COUNTER_STATE            =  15;
   FPTR_MT_CREDIT_CARD              =  16;
   FPTR_MT_CURRENCY                 =  17;
   FPTR_MT_CURRENCY_VALUE           =  18;
   FPTR_MT_DEPOSIT                  =  19;
   FPTR_MT_DEPOSIT_RETURNED         =  20;
   FPTR_MT_DOT_LINE                 =  21;
   FPTR_MT_DRIVER_NUMB              =  22;
   FPTR_MT_EMPTY_LINE               =  23;
   FPTR_MT_FREE_TEXT                =  24;
   FPTR_MT_FREE_TEXT_WITH_DAY_LIMIT =  25;
   FPTR_MT_GIVEN_DISCOUNT           =  26;
   FPTR_MT_LOCAL_CREDIT             =  27;
   FPTR_MT_MILEAGE_KM               =  28;
   FPTR_MT_NOTE                     =  29;
   FPTR_MT_PAID                     =  30;
   FPTR_MT_PAY_IN                   =  31;
   FPTR_MT_POINT_GRANTED            =  32;
   FPTR_MT_POINTS_BONUS             =  33;
   FPTR_MT_POINTS_RECEIPT           =  34;
   FPTR_MT_POINTS_TOTAL             =  35;
   FPTR_MT_PROFITED                 =  36;
   FPTR_MT_RATE                     =  37;
   FPTR_MT_REGISTER_NUMB            =  38;
   FPTR_MT_SHIFT_NUMBER             =  39;
   FPTR_MT_STATE_OF_AN_ACCOUNT      =  40;
   FPTR_MT_SUBSCRIPTION             =  41;
   FPTR_MT_TABLE                    =  42;
   FPTR_MT_THANK_YOU_FOR_LOYALTY    =  43;
   FPTR_MT_TRANSACTION_NUMB         =  44;
   FPTR_MT_VALID_TO                 =  45;
   FPTR_MT_VOUCHER                  =  46;
   FPTR_MT_VOUCHER_PAID             =  47;
   FPTR_MT_VOUCHER_VALUE            =  48;
   FPTR_MT_WITH_DISCOUNT            =  49;
   FPTR_MT_WITHOUT_UPLIFT           =  50;


/////////////////////////////////////////////////////////////////////
// 'SlipSelection' Property Constants
/////////////////////////////////////////////////////////////////////

   FPTR_SS_FULL_LENGTH              =  1;
   FPTR_SS_VALIDATION               =  2;


/////////////////////////////////////////////////////////////////////
// 'TotalizerType' Property Constants
/////////////////////////////////////////////////////////////////////

   FPTR_TT_DOCUMENT                 =  1;
   FPTR_TT_DAY                      =  2;
   FPTR_TT_RECEIPT                  =  3;
   FPTR_TT_GRAND                    =  4;


/////////////////////////////////////////////////////////////////////
// 'GetData' Method Constants
/////////////////////////////////////////////////////////////////////

// - 'DataItem' Parameter.
   FPTR_GD_FIRMWARE                 = 10; // 1: IdentificationData.
   FPTR_GD_PRINTER_ID               =  9; // 1: IdentificationData.

   FPTR_GD_CURRENT_TOTAL            =  1; // 2: Total.
   FPTR_GD_DAILY_TOTAL              =  2; // 2: Total.
   FPTR_GD_GRAND_TOTAL              =  8; // 2: Total.
   FPTR_GD_MID_VOID                 =  6; // 2: Total.
   FPTR_GD_NOT_PAID                 =  5; // 2: Total.
   FPTR_GD_RECEIPT_NUMBER           =  3; // 2: Total.
   FPTR_GD_REFUND                   =  4; // 2: Total.
   FPTR_GD_REFUND_VOID              = 12; // 2: Total.

   FPTR_GD_NUMB_CONFIG_BLOCK        = 13; // 3: FiscalMemoryCount.
   FPTR_GD_NUMB_CURRENCY_BLOCK      = 14; // 3: FiscalMemoryCount.
   FPTR_GD_NUMB_HDR_BLOCK           = 15; // 3: FiscalMemoryCount.
   FPTR_GD_NUMB_RESET_BLOCK         = 16; // 3: FiscalMemoryCount.
   FPTR_GD_NUMB_VAT_BLOCK           = 17; // 3: FiscalMemoryCount.

   FPTR_GD_FISCAL_DOC               = 18; // 4: Counter.
   FPTR_GD_FISCAL_DOC_VOID          = 19; // 4: Counter.
   FPTR_GD_FISCAL_REC               = 20; // 4: Counter.
   FPTR_GD_FISCAL_REC_VOID          = 21; // 4: Counter.
   FPTR_GD_NONFISCAL_DOC            = 22; // 4: Counter.
   FPTR_GD_NONFISCAL_DOC_VOID       = 23; // 4: Counter.
   FPTR_GD_NONFISCAL_REC            = 24; // 4: Counter.
   FPTR_GD_RESTART                  = 11; // 4: Counter.
   FPTR_GD_SIMP_INVOICE             = 25; // 4: Counter.
   FPTR_GD_Z_REPORT                 =  7; // 4: Counter.

   FPTR_GD_TENDER                   = 26; // 5: FixedFiscalPrinterText.

   FPTR_GD_LINECOUNT                = 27; // 6: Linecounter.

   FPTR_GD_DESCRIPTION_LENGTH       = 28; // 7: DescriptionLength.

// - 'OptArgs' Parameter, when 'DataItem' is FPTR_GD_TENDER.
   FPTR_PDL_CASH                     =  1;
   FPTR_PDL_CHEQUE                   =  2;
   FPTR_PDL_CHITTY                   =  3;
   FPTR_PDL_COUPON                   =  4;
   FPTR_PDL_CURRENCY                 =  5;
   FPTR_PDL_DRIVEN_OFF               =  6;
   FPTR_PDL_EFT_IMPRINTER            =  7;
   FPTR_PDL_EFT_TERMINAL             =  8;
   FPTR_PDL_TERMINAL_IMPRINTER       =  9;
   FPTR_PDL_FREE_GIFT                = 10;
   FPTR_PDL_GIRO                     = 11;
   FPTR_PDL_HOME                     = 12;
   FPTR_PDL_IMPRINTER_WITH_ISSUER    = 13;
   FPTR_PDL_LOCAL_ACCOUNT            = 14;
   FPTR_PDL_LOCAL_ACCOUNT_CARD       = 15;
   FPTR_PDL_PAY_CARD                 = 16;
   FPTR_PDL_PAY_CARD_MANUAL          = 17;
   FPTR_PDL_PREPAY                   = 18;
   FPTR_PDL_PUMP_TEST                = 19;
   FPTR_PDL_SHORT_CREDIT             = 20;
   FPTR_PDL_STAFF                    = 21;
   FPTR_PDL_VOUCHER                  = 22;

// - 'OptArgs' Parameter, when 'DataItem' is FPTR_GD_LINECOUNT.
   FPTR_LC_ITEM                      =  1;
   FPTR_LC_ITEM_VOID                 =  2;
   FPTR_LC_DISCOUNT                  =  3;
   FPTR_LC_DISCOUNT_VOID             =  4;
   FPTR_LC_SURCHARGE                 =  5;
   FPTR_LC_SURCHARGE_VOID            =  6;
   FPTR_LC_REFUND                    =  7;
   FPTR_LC_REFUND_VOID               =  8;
   FPTR_LC_SUBTOTAL_DISCOUNT         =  9;
   FPTR_LC_SUBTOTAL_DISCOUNT_VOID    = 10;
   FPTR_LC_SUBTOTAL_SURCHARGE        = 11;
   FPTR_LC_SUBTOTAL_SURCHARGE_VOID   = 12;
   FPTR_LC_COMMENT                   = 13;
   FPTR_LC_SUBTOTAL                  = 14;
   FPTR_LC_TOTAL                     = 15;

// - 'OptArgs' Parameter, when 'DataItem' is FPTR_GD_DESCRIPTION_LENGTH.
   FPTR_DL_ITEM                      =  1;
   FPTR_DL_ITEM_ADJUSTMENT           =  2;
   FPTR_DL_ITEM_FUEL                 =  3;
   FPTR_DL_ITEM_FUEL_VOID            =  4;
   FPTR_DL_NOT_PAID                  =  5;
   FPTR_DL_PACKAGE_ADJUSTMENT        =  6;
   FPTR_DL_REFUND                    =  7;
   FPTR_DL_REFUND_VOID               =  8;
   FPTR_DL_SUBTOTAL_ADJUSTMENT       =  9;
   FPTR_DL_TOTAL                     = 10;
   FPTR_DL_VOID                      = 11;
   FPTR_DL_VOID_ITEM                 = 12;


/////////////////////////////////////////////////////////////////////
// 'GetTotalizer' Method Constants
/////////////////////////////////////////////////////////////////////

   FPTR_GT_GROSS                    =  1;
   FPTR_GT_NET                      =  2;
   FPTR_GT_DISCOUNT                 =  3;
   FPTR_GT_DISCOUNT_VOID            =  4;
   FPTR_GT_ITEM                     =  5;
   FPTR_GT_ITEM_VOID                =  6;
   FPTR_GT_NOT_PAID                 =  7;
   FPTR_GT_REFUND                   =  8;
   FPTR_GT_REFUND_VOID              =  9;
   FPTR_GT_SUBTOTAL_DISCOUNT        =  10;
   FPTR_GT_SUBTOTAL_DISCOUNT_VOID   =  11;
   FPTR_GT_SUBTOTAL_SURCHARGES      =  12;
   FPTR_GT_SUBTOTAL_SURCHARGES_VOID =  13;
   FPTR_GT_SURCHARGE                =  14;
   FPTR_GT_SURCHARGE_VOID           =  15;
   FPTR_GT_VAT                      =  16;
   FPTR_GT_VAT_CATEGORY             =  17;


/////////////////////////////////////////////////////////////////////
// 'AdjustmentType' arguments in diverse methods
/////////////////////////////////////////////////////////////////////

   FPTR_AT_AMOUNT_DISCOUNT            =  1;
   FPTR_AT_AMOUNT_SURCHARGE           =  2;
   FPTR_AT_PERCENTAGE_DISCOUNT        =  3;
   FPTR_AT_PERCENTAGE_SURCHARGE       =  4;
   FPTR_AT_COUPON_AMOUNT_DISCOUNT     =  5; // (added in 1.11)
   FPTR_AT_COUPON_PERCENTAGE_DISCOUNT =  6; // (added in 1.11)


/////////////////////////////////////////////////////////////////////
// 'ReportType' argument in 'PrintReport' method
/////////////////////////////////////////////////////////////////////

   FPTR_RT_ORDINAL                  =  1;
   FPTR_RT_DATE                     =  2;
   FPTR_RT_EOD_ORDINAL              =  3; // (added in 1.11)

/////////////////////////////////////////////////////////////////////
// 'NewCurrency' argument in 'SetCurrency' method
/////////////////////////////////////////////////////////////////////

   FPTR_SC_EURO                     =  1;


/////////////////////////////////////////////////////////////////////
// 'StatusUpdateEvent' Event: 'Data' Parameter Constants
/////////////////////////////////////////////////////////////////////

   FPTR_SUE_COVER_OPEN              =  11;
   FPTR_SUE_COVER_OK                =  12;
   FPTR_SUE_JRN_COVER_OPEN          =  60;  // (added in 1.8)
   FPTR_SUE_JRN_COVER_OK            =  61;  // (added in 1.8)
   FPTR_SUE_REC_COVER_OPEN          =  62;  // (added in 1.8)
   FPTR_SUE_REC_COVER_OK            =  63;  // (added in 1.8)
   FPTR_SUE_SLP_COVER_OPEN          =  64;  // (added in 1.8)
   FPTR_SUE_SLP_COVER_OK            =  65;  // (added in 1.8)

   FPTR_SUE_JRN_EMPTY               =  21;
   FPTR_SUE_JRN_NEAREMPTY           =  22;
   FPTR_SUE_JRN_PAPEROK             =  23;

   FPTR_SUE_REC_EMPTY               =  24;
   FPTR_SUE_REC_NEAREMPTY           =  25;
   FPTR_SUE_REC_PAPEROK             =  26;

   FPTR_SUE_SLP_EMPTY               =  27;
   FPTR_SUE_SLP_NEAREMPTY           =  28;
   FPTR_SUE_SLP_PAPEROK             =  29;

   FPTR_SUE_IDLE                    =1001;


/////////////////////////////////////////////////////////////////////
// 'ResultCodeExtended' Property Constants
/////////////////////////////////////////////////////////////////////

   OPOS_EFPTR_COVER_OPEN                 = 201;
   OPOS_EFPTR_JRN_EMPTY                  = 202;
   OPOS_EFPTR_REC_EMPTY                  = 203;
   OPOS_EFPTR_SLP_EMPTY                  = 204;
   OPOS_EFPTR_SLP_FORM                   = 205;
   OPOS_EFPTR_MISSING_DEVICES            = 206;
   OPOS_EFPTR_WRONG_STATE                = 207;
   OPOS_EFPTR_TECHNICAL_ASSISTANCE       = 208;
   OPOS_EFPTR_CLOCK_ERROR                = 209;
   OPOS_EFPTR_FISCAL_MEMORY_FULL         = 210;
   OPOS_EFPTR_FISCAL_MEMORY_DISCONNECTED = 211;
   OPOS_EFPTR_FISCAL_TOTALS_ERROR        = 212;
   OPOS_EFPTR_BAD_ITEM_QUANTITY          = 213;
   OPOS_EFPTR_BAD_ITEM_AMOUNT            = 214;
   OPOS_EFPTR_BAD_ITEM_DESCRIPTION       = 215;
   OPOS_EFPTR_RECEIPT_TOTAL_OVERFLOW     = 216;
   OPOS_EFPTR_BAD_VAT                    = 217;
   OPOS_EFPTR_BAD_PRICE                  = 218;
   OPOS_EFPTR_BAD_DATE                   = 219;
   OPOS_EFPTR_NEGATIVE_TOTAL             = 220;
   OPOS_EFPTR_WORD_NOT_ALLOWED           = 221;
   OPOS_EFPTR_BAD_LENGTH                 = 222;
   OPOS_EFPTR_MISSING_SET_CURRENCY       = 223;
   OPOS_EFPTR_DAY_END_REQUIRED           = 224; // (added in 1.11)


implementation

end.

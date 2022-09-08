unit fmuMain;

interface

uses
  // VCL
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons,
  // This
  untConvert;

type
  TfmMain = class(TForm)
    btnOpen: TBitBtn;
    OpenDialog: TOpenDialog;
    btnClose: TButton;
    procedure btnOpenClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  end;

var
  fmMain: TfmMain;

implementation

{$R *.DFM}

procedure TfmMain.btnOpenClick(Sender: TObject);
begin
  if OpenDialog.Execute then
  begin
    ConvertFile(OpenDialog.FileName);
  end;
end;

procedure TfmMain.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  OpenDialog.InitialDir := ExtractFilePath(ParamStr(0));
end;

end.

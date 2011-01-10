unit frmftp;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, ButtonPanel,
  ftpfs,msgstrings,unitfunc
  ;

type

  { TfrmFTPParam }

  TfrmFTPParam = class(TForm)
    ButtonPanel1: TButtonPanel;
    chkAutoTLS: TCheckBox;
    chkPassive: TCheckBox;
    EditHost: TLabeledEdit;
    EditInitDir: TLabeledEdit;
    EditPass: TLabeledEdit;
    EditPort: TLabeledEdit;
    EditUser: TLabeledEdit;
    GroupFTPparam: TGroupBox;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnTestClick(Sender: TObject);
//    procedure EditPassChange(Sender: TObject);
    procedure EditPassKeyPress(Sender: TObject; var Key: char);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure HelpButtonClick(Sender: TObject);
  private
    { private declarations }
    PassChanged:boolean; // Пароль менялся

  public
    { public declarations }
    FtpServParam:TFtpServParam;
//    RealPass:string; // Реальный пароль
//    procedure SetParam(FtpParam:TFTPServParam); // Заполняет форму переданными параметрами
    procedure FillForm;
    procedure ReadForm;
  end; 

var
  frmFTPParam: TfrmFTPParam;

implementation

{ TfrmFTPParam }

procedure TfrmFTPParam.btnOkClick(Sender: TObject);
begin
  ReadForm;
  ModalResult:=mrOk;
//  Close;
end;

procedure TfrmFTPParam.btnTestClick(Sender: TObject);
var
 ftpFS:TFTPFS;
 str:string;
begin
ReadForm;
ftpfs:=TFTPFS.Create;
ftpfs.RootDir:=FtpServParam.InintialDir;
ftpfs.FTPServParam:=FtpServParam;
if Not ftpfs.Connect then
         begin
         str:= Format(rsFTPConnErr, [FtpServParam.Host, ftpfs.LastError]);
         ShowMessage(str);
         end
      else
         begin
         ShowMessage(rsFTPConnSuc);
         ftpfs.Disconnect;
         end;

end;
{
procedure TfrmFTPParam.EditPassChange(Sender: TObject);
begin
  PassChanged:=true;
  EditPass.EchoMode:=emNormal;
end;
 }
procedure TfrmFTPParam.EditPassKeyPress(Sender: TObject; var Key: char);
begin
  PassChanged:=true;
  EditPass.EchoMode:=emNormal;
end;

procedure TfrmFTPParam.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
 if ModalResult=mrOk then
      begin
      ReadForm;
      end;
CanClose:=true;

end;

procedure TfrmFTPParam.btnCancelClick(Sender: TObject);
begin
  ModalResult:=mrCancel;
//  Close;
end;

procedure TfrmFTPParam.FormCreate(Sender: TObject);
begin
  ButtonPanel1.HelpButton.Caption:=rsTest;
  ButtonPanel1.OKButton.Caption:=rsOk;
  ButtonPanel1.CancelButton.Caption:=rsCancel;
  ButtonPanel1.HelpButton. OnClick:=TNotifyEvent(@HelpButtonClick);
  PassChanged:=false;
  EditPass.EchoMode:=emPassword;
end;

procedure TfrmFTPParam.HelpButtonClick(Sender: TObject);
var
 ftpFS:TFTPFS;
 str:string;
begin
ReadForm;
ftpfs:=TFTPFS.Create;
ftpfs.RootDir:=FtpServParam.InintialDir;
ftpfs.FTPServParam:=FtpServParam;
if Not ftpfs.Connect then
         begin
         str:= Format(rsFTPConnErr, [FtpServParam.Host, ftpfs.LastError]);
         ShowMessage(str);
         end
      else
         begin
         ShowMessage(rsFTPConnSuc);
         ftpfs.Disconnect;
         end;

end;

//------------------------------------------------------
// Заполнение формы
procedure TfrmFTPParam.FillForm;
begin
EditHost.Text:=FtpServParam.Host;
EditPort.Text:=FtpServParam.Port;
EditInitDir.Text:=FtpServParam.InintialDir;
EditUser.Text:=FtpServParam.UserName;
if PassChanged then
        EditPass.Text:=DecryptString(FtpServParam.Password,KeyStrTask)
     else
        begin
        EditPass.Text:='################';
//        RealPass:=FtpServParam.Password;
        end;
chkPassive.Checked:=FtpServParam.PassiveMode;
chkAutoTLS.Checked:=FtpServParam.AutoTLS;
end;
//--------------------------------------------------------
// Чтение формы
procedure TfrmFTPParam.ReadForm;
begin
FtpServParam.Host:=EditHost.Text;
FtpServParam.Port:=EditPort.Text;
FtpServParam.InintialDir:=TFTPFS.InitDirCorrect(EditInitDir.Text);
EditInitDir.Text:=FtpServParam.InintialDir;
FtpServParam.UserName:=EditUser.Text;
if PassChanged then FtpServParam.Password:=EncryptString(EditPass.Text,KeyStrTask);
  //   else FtpServParam.Password:=RealPass;

FtpServParam.PassiveMode:=chkPassive.Checked;
FtpServParam.AutoTLS:=chkAutoTLS.Checked;
end;


initialization
  {$I frmftp.lrs}

end.


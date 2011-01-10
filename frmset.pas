unit frmset;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Spin, Buttons, ExtCtrls, EditBtn, ButtonPanel, StrUtils, msgStrings, windows,
  taskunit, unitfunc,setunit{,idSmtp,idMessage};

type

  { TFormSet }

  TFormSet = class(TForm)
    BitBtn1: TBitBtn;
    butTestSmtp: TButton;
    ButtonPanel1: TButtonPanel;
    CheckSysCopyFunc: TCheckBox;
    CheckGroup2: TCheckGroup;
    BoxLang: TComboBox;
    chkFTPLogEnabled: TCheckBox;
    EditCurProf: TFileNameEdit;
    EditDefProf: TFileNameEdit;
    EditLogFTPNam: TEdit;
    EditProfNam: TEdit;
    EditSubj: TEdit;
    EditBody: TEdit;
    EditArhTmpDir: TDirectoryEdit;
    EditUser: TEdit;
    EditPass: TEdit;
    EditServ: TEdit;
    EditMailFrom: TEdit;
    EditMailTo: TEdit;
    EditLogNam: TEdit;
    GroupProfStart: TGroupBox;
    GroupLog: TGroupBox;
    GroupBox4: TGroupBox;
    GroupLang: TGroupBox;
    GroupEmail: TGroupBox;
    GroupTempArh: TGroupBox;
    GroupLogFtp: TGroupBox;
    LabelLimit: TLabel;
    EditLim: TSpinEdit;
    LabelPass: TLabel;
    LabelSubj: TLabel;
    LabelText: TLabel;
    LabelLimFTp: TLabel;
    LabelKbftp: TLabel;
    LabelKb: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    LabelSmtpSrv: TLabel;
    LabelPort: TLabel;
    LabelMailFrom: TLabel;
    LabelMailTO: TLabel;
    LabelUser: TLabel;
    EditPort: TSpinEdit;
    EditFTPLim: TSpinEdit;
    RadioLastProf: TRadioButton;
    RadioThisProf: TRadioButton;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure butTestSmtpClick(Sender: TObject);
    procedure chkFTPLogEnabled1Change(Sender: TObject);
    procedure EditPassKeyPress(Sender: TObject; var Key: char);
//    procedure EditLogNamKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
//    procedure EditLogNamKeyPress(Sender: TObject; var Key: char);
//    procedure BitOpenPClick(Sender: TObject);
 //   procedure BoxLangChange(Sender: TObject);
//    procedure BtnProfNewClick(Sender: TObject);
//    procedure BtnProfOpenClick(Sender: TObject);
//    procedure BtnProfSaveClick(Sender: TObject);

    procedure FillLangs;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure RadioLastProfChange(Sender: TObject);
    procedure RadioThisProfChange(Sender: TObject);
  private
    { private declarations }
    LangNameList:TStringList;
    LangFileList:TStringList;
    PassChanged:boolean;
  public
    { public declarations }
    procedure FillForm;
    function ReadForm:boolean;
    procedure FillChecks;
    Settings:TSettings; // Настройки
  end; 

var
  FormSet: TFormSet;

implementation
//uses mainform{,sendmailunit};
//========================================================
// Заполнение формы данными
procedure TformSet.FillForm;
//========================================================
begin
EditLogNam.Text:=Settings.logfile;
EditLim.Value:=Settings.loglimit;

chkFTPLogEnabled.Checked:=Settings.LogFtpEnabled;
EditLogFTPNam.Text:=Settings.LogFileFTP;
EditFTPLim.Value:=Settings.LogFTPLimit;
//if MForm.TaskCl.Settings.LogFtpEnabled

RadioLastProf.Checked:=Settings.LoadLastProf;
RadioThisProf.Checked:=Not Settings.LoadLastProf;
if Settings.LoadLastProf then
  begin
  EditDefProf.Text:=Settings.profile;
  EditDefProf.Enabled:=true;
  end
 else
  begin
  EditDefProf.Text:=Settings.DefaultProf;
  EditDefProf.Enabled:=false;
   end;
CheckSysCopyFunc.Checked:=Settings.SysCopyFunc;
EditCurProf.Text:=Settings.profile;
EditDefProf.Enabled:=NOT RadioLastProf.Checked;
EditArhTmpDir.Text:=ShortFileNam(Settings.ArhTmpDir);
//EditArhTmpDir.Text:=ShortFileNam(Settings.ArhTmpDir);
//BtnDefProf.Enabled:=NOT RadioLastProf.Checked;
//CheckStartMin.Enabled:=CheckTray.Checked;
//EditProfNam.Text:=MForm.TaskCl.ProfName;
// почтовые уведомления
{
case MForm.TaskCl.alerttype of
alertNone: rAlertNone.Checked:=true;
AlertErr: rAlertErr.Checked:=true;
AlertAlways: rAlertAlways.Checked:=true;
end;
    }
EditMailTo.Text:=Settings.email;
EditServ.Text:=Settings.smtpserv;
Editport.Value:=Settings.smtpport;
Edituser.Text:=Settings.smtpuser;
if PassChanged then
        Editpass.Text:=DecryptString(Settings.smtppass,KeyStr)
     else
       begin
        Editpass.Text:='################';
       end;
Editmailfrom.Text:=Settings.mailfrom;
EditSubj.Text:=Settings.Subj;
EditBody.TExt:=Settings.Body;
//if not CheckStartMin.Enabled then CheckStartMin.Checked:=false;
FillLangs;
FillChecks;
end;
//======================================================================
procedure TFormSet.FillChecks;
begin
if chkFTPLogEnabled.Checked then
      begin
      EditLogFTPNam.Enabled:=true;
      EditFTPLim.Enabled:=true;
      end
    else
      begin
      EditLogFTPNam.Enabled:=false;
      EditFTPLim.Enabled:=false;
      end;
end;

//======================================================================
function TFormSet.ReadForm:boolean;
var
 str:string;
 ArhTmpDir:string;
begin
Result:=false;
if EditLogNam.Text='' then
 begin
   ShowMessage(rsEnterLogFile);
   exit;
 end;
ArhTmpDir:='';
if (EditArhTmpDir.Text<>'') then
      begin
      ArhTmpDir:=EditArhTmpDir.Text;
      ArhTmpDir:=FullFileNam(ArhTmpDir);
      end;
if (ArhTmpDir<>'') and (Not DirectoryExists(utf8toansi(ArhTmpDir)))  then
 begin
 str:=Format(rsDirNotExsistCreate,[ArhTmpDir]);
 if MessageDlg(str, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
     if ForceDirectories(utf8toansi(ArhTmpDir)) then
        begin
        ShowMessage(rsDirCreated);
        end
       else
         begin
          ShowMessage(rsErrCreateDir);
          exit;
         end;
    end
   else exit;
 end;
if (chkFTPLogEnabled.Checked) and (EditLogFTPNam.Text='') then
     begin
     ShowMessage(rsEnterLogFile);
     exit;
     end;
Result:=true;

Settings.ArhTmpDir:=ArhTmpDir;

Settings.logfile:=EditLogNam.Text;
Settings.loglimit:=EditLim.Value;
Settings.LoadLastProf:=RadioLastProf.Checked;

Settings.DefaultProf:=ShortFileNam(EditDefProf.Text);
Settings.SysCopyFunc:=CheckSysCopyFunc.Checked;

Settings.email:=EditMailTo.Text;
Settings.smtpserv:=EditServ.Text;
Settings.smtpport:=Editport.Value;
Settings.smtpuser:=EditUser.Text;
if PassChanged then Settings.smtppass:=EncryptString(EditPass.Text,KeyStr);

Settings.mailfrom:=EditMailfrom.Text;
Settings.Subj:=EditSubj.Text;
Settings.Body:=EditBody.Text;
Settings.Lang:=LangFileList.Strings[BoxLang.ItemIndex];

// FTP
Settings.LogFtpEnabled:=chkFTPLogEnabled.Checked;
Settings.LogFileFTP:=EditLogFTPNam.Text;
Settings.LogFTPLimit:=EditFTPLim.Value;

//ModalResult:=mrOk;
end;

//======================================================================
procedure TFormSet.BitBtn2Click(Sender: TObject);

begin
if ReadForm then ModalResult:=mrOk;
end;
//Проверка отправки почты
procedure TFormSet.butTestSmtpClick(Sender: TObject);
var
 MsgErr:string;
  str:string;
begin
 // Отсылка почты -----
 if Not ReadForm then exit;




   if TBackup.SendMailEx(Settings,'mBackup test','mBackup test letter','',MsgErr) then
       begin
       ShowMessage(rsAlertTestOk);
       end
     else
      begin // Не успешно
      ShowMessage(msgErr);
       end;






  {

  SendMail:=TSendMAil.Create;
  SendMail.aName:=EditUser.Text;
  SendMail.aPass:=EditPass.Text;
  suc:=SendMail.Send(EditServ.Text,EditPort.Value,EditMailFrom.Text,EditMailTo.Text,'AutoSave test','This is test letter','');
  if suc then
  begin // Успешно
//  str:=rsAlertTestOk;
  ShowMessage(rsAlertTestOk);
  end
  else
  begin // Не успешно
   str:=Format(rsAlertTestErr,[SendMail.LastError]);
   ShowMessage(str);
  end;
  SendMail.Destroy;
  }
end;

procedure TFormSet.chkFTPLogEnabled1Change(Sender: TObject);
begin
  FillChecks;
end;

procedure TFormSet.EditPassKeyPress(Sender: TObject; var Key: char);
begin
  PassChanged:=true;
  EditPass.EchoMode:=emNormal;
end;









{
procedure TFormSet.BitOpenPClick(Sender: TObject);
var
 profil:string;
begin
if OpenDialog1.Execute then
  begin
  profil:=MForm.TaskCl.profile;
  MForm.TaskCl.LoadFromFile(OpenDialog1.FileName);
  MForm.TaskCl.profile:=profil; // сохранение имени старого профиля
  MForm.FillListTask(-1);
  end;
end;
 }

       {
procedure TFormSet.BtnProfNewClick(Sender: TObject);
var
 filenam:string; // имя файла
begin
if SaveDialog1.Execute then
  begin
  filenam:=MForm.TaskCl.ShortFileNam(SaveDialog1.FileName);
  if ExtractFileExt(filenam)='' then filenam:=filenam+'.asc';
//  MForm.TaskCl.SaveToFile(filenam);
//  MForm.TaskCl.LoadFromFile(filenam);
  MForm.TaskCl.Count:=0;
  MForm.FillListTask(-1);
  EditCurProf.Text:=filenam;
  MForm.TaskCl.ProfName:='';
//  MForm.Caption:='AutoSave';
  MForm.TaskCl.SaveToFile(filenam);
//  MForm.TaskCl.LoadFromFile(filenam);
  end;
end;
        }
        {
procedure TFormSet.BtnProfOpenClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
  MForm.TaskCl.Count:=0;
  MForm.TaskCl.LoadFromFile(OpenDialog1.FileName);
  EditCurProf.Text:=MForm.TaskCl.profile;
  EditProfNam.Text:=MForm.TaskCl.ProfName;
  MForm.FillListTask(-1);
  MForm.Caption:='AutoSave '+MForm.TaskCl.ProfName;
  end;
end;
         }
         {
procedure TFormSet.BtnProfSaveClick(Sender: TObject);
var
 filen:string; // имя файла
begin
If SaveDialog1.Execute then
   begin
   filen:=MForm.TaskCl.ShortFileNam(SaveDialog1.FileName);
   if ExtractFileExt(filen)='' then filen:=filen+'.asc';
   MForm.TaskCl.SaveToFile(filen);
   EditCurProf.Text:=filen;
   end;
end;
          }
          
procedure TFormSet.BitBtn1Click(Sender: TObject);
var
 buf: array [0..MaxPChar] of char;
begin
buf:=FullFileNam(Settings.logfile);
ShellExecute(0,nil,buf,nil,nil,SW_SHOWNORMAL);
end;


//========================================================
// Поиск языков
procedure TFormSet.FillLangs;
//========================================================
var
 langshort,rep:string;
 sr:TSearchRec;
 langname:string;
 //CL2:TMemIniFile;
begin
rep:=extractFileDir(application.exeName)+DirectorySeparator+'Lang'+DirectorySeparator;
LangNameList:=TStringList.create;
LangFileList:=TStringList.Create;
BoxLang.Items.Clear;
 // поиск всех файлов lng
LangNameList.Add('English');
BoxLang.Items.Add('English');
LangFileList.Add('en');
BoxLang.ItemIndex:=0; // По умолчанию русский
if findFirst(rep+'mbackupw.??.po',faAnyFile,sr)=0 then
   repeat
   langshort:=RightStr(sr.Name,5);
   langshort:=LeftStr(langshort,2); // Две буквы языка

   if langshort='ru' then
      begin
      langname:='Russian';
      end
     else
       langname:=langshort;

    LangNameList.Add(langname);
    BoxLang.Items.Add(langname);
    LangFileList.Add(langshort);
    if langshort=Settings.Lang then
     begin
     BoxLang.ItemIndex:=LangNameList.Count-1;
     end;
   {
//   CL2:=LoadLangIni(sr.Name);

   langname:=CL2.ReadString('Language','Language','');
   if (langname='') then findNext(sr)
    else
     begin
     LangNameList.Add(langname);
     BoxLang.Items.Add(langname);
     LangFileList.Add(sr.Name);
     end;
   if sr.Name=MForm.TaskCl.LangFile then BoxLang.ItemIndex:=LangNameList.Count-1;
   }
   until findNext(sr)<>0;
//LangNameList.Destroy;

end;

procedure TFormSet.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if ModalResult=mrOk then
       begin
       if ReadForm then CanClose:=true
             else
               CanClose:=false;
       end
     else
       CanClose:=true;
end;

procedure TFormSet.FormCreate(Sender: TObject);
//var
//TC: array[1..1] of TComponent;
begin
ButtonPanel1.CancelButton.Caption:=rsCancel;
ButtonPanel1.OKButton.Caption:=rsOk;
PassChanged:=false;
EditPass.EchoMode:=emPassword;
//FillForm;
end;

procedure TFormSet.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

procedure TFormSet.RadioLastProfChange(Sender: TObject);
begin
  EditDefProf.Enabled:=NOT RadioLastProf.Checked;
end;

procedure TFormSet.RadioThisProfChange(Sender: TObject);
begin
    EditDefProf.Enabled:=NOT RadioLastProf.Checked;
end;



//========================================================

initialization
  {$I frmset.lrs}

end.


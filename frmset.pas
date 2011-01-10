unit frmset;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Spin, Buttons, ExtCtrls, EditBtn, MaskEdit, IniFiles, IniLang, msgStrings,
  windows, taskunit;

type

  { TFormSet }

  TFormSet = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    butTestSmtp: TButton;
    CheckSysCopyFunc: TCheckBox;
    CheckGroup2: TCheckGroup;
    CheckTray: TCheckBox;
    CheckStartMin: TCheckBox;
    CheckAutoRun: TCheckBox;
    CheckGroup1: TCheckGroup;
    BoxLang: TComboBox;
    EditUser: TEdit;
    EditPass: TEdit;
    EditServ: TEdit;
    EditMailFrom: TEdit;
    EditMailTo: TEdit;
    EditProfNam: TEdit;
    EditLogNam: TEdit;
    EditDefProf: TFileNameEdit;
    EditCurProf: TFileNameEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    GroupBox6: TGroupBox;
    Label1: TLabel;
    EditLim: TSpinEdit;
    Label10: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    RadioLastProf: TRadioButton;
    RadioThisProf: TRadioButton;
    EditPort: TSpinEdit;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure butTestSmtpClick(Sender: TObject);
    procedure EditLogNamKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
//    procedure EditLogNamKeyPress(Sender: TObject; var Key: char);
//    procedure BitOpenPClick(Sender: TObject);
 //   procedure BoxLangChange(Sender: TObject);
//    procedure BtnProfNewClick(Sender: TObject);
//    procedure BtnProfOpenClick(Sender: TObject);
//    procedure BtnProfSaveClick(Sender: TObject);
    procedure FillForm;
    procedure FillLangs;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure RadioLastProfChange(Sender: TObject);
    procedure RadioThisProfChange(Sender: TObject);
  private
    { private declarations }
    LangNameList:TStringList;
    LangFileList:TStringList;
  public
    { public declarations }
  end; 

var
  FormSet: TFormSet;

implementation
uses mainform,sendmailunit;
//========================================================
// Заполнение формы данными
procedure TformSet.FillForm;
//========================================================
begin
EditLogNam.Text:=MForm.TaskCl.logfile;
EditLim.Value:=MForm.TaskCl.loglimit;
CheckTray.Checked:=Not(MForm.IsClosing);
CheckAutoRun.Checked:=MForm.AutoOnlyClose;
CheckStartMin.Checked:=MForm.StartMin;
RadioLastProf.Checked:=MForm.TaskCl.LoadLastProf;
RadioThisProf.Checked:=Not MForm.TaskCl.LoadLastProf;
if MForm.TaskCl.LoadLastProf then
  begin
  EditDefProf.Text:=MForm.TaskCl.profile;
  EditDefProf.Enabled:=true;
  end
 else
  begin
  EditDefProf.Text:=MForm.TaskCl.DefaultProf;
  EditDefProf.Enabled:=false;
   end;
CheckSysCopyFunc.Checked:=MForm.TaskCl.SysCopyFunc;
EditCurProf.Text:=MForm.TaskCl.profile;
EditDefProf.Enabled:=NOT RadioLastProf.Checked;
//BtnDefProf.Enabled:=NOT RadioLastProf.Checked;
CheckStartMin.Enabled:=CheckTray.Checked;
//EditProfNam.Text:=MForm.TaskCl.ProfName;
// почтовые уведомления
{
case MForm.TaskCl.alerttype of
alertNone: rAlertNone.Checked:=true;
AlertErr: rAlertErr.Checked:=true;
AlertAlways: rAlertAlways.Checked:=true;
end;
    }
EditMailTo.Text:=MForm.TaskCl.email;
EditServ.Text:=MForm.TaskCl.smtpserv;
Editport.Value:=MForm.TaskCl.smtpport;
Edituser.Text:=MForm.TaskCl.smtpuser;
Editpass.Text:=MForm.TaskCl.smtppass;
Editmailfrom.Text:=MForm.TaskCl.mailfrom;

if not CheckStartMin.Enabled then CheckStartMin.Checked:=false;
FillLangs;
end;
//======================================================================
procedure TFormSet.BitBtn2Click(Sender: TObject);
var
TC: array[1..1] of TComponent;
begin
if EditLogNam.Text='' then
 begin
   ShowMessage(misc(rsEnterLogFile,'rsEnterLogFile'));
   exit;
 end;
MForm.TaskCL.logfile:=EditLogNam.Text;
MForm.TaskCl.loglimit:=EditLim.Value;
//MForm.TrayIcon.MinimizeToTray:=FormSet.CheckTray.Checked ;
//MForm.TrayIcon.IconVisible:=FormSet.CheckTray.Checked;
MForm.IsClosing:=Not (FormSet.CheckTray.Checked);
MForm.AutoOnlyClose:=CheckAutoRun.Checked;
MForm.TaskCl.LoadLastProf:=RadioLastProf.Checked;
//if not MForm.TaskCl.LoadLastProf then
MForm.TaskCl.DefaultProf:=MForm.TaskCl.ShortFileNam(EditDefProf.Text);
MForm.TaskCl.SysCopyFunc:=CheckSysCopyFunc.Checked;

//MForm.TaskCl.ProfName:=EditProfNam.Text;
//MForm.Caption:='AutoSave '+MForm.TaskCl.ProfName;

// чтение уведомлений
{
if rAlertNone.Checked then MForm.TaskCl.alerttype:=alertNone;
if rAlertErr.Checked then MForm.TaskCl.alerttype:=alertErr;
if rAlertAlways.Checked then MForm.TaskCl.alerttype:=alertAlways;
    }
MForm.TaskCl.email:=EditMailTo.Text;
MForm.TaskCl.smtpserv:=EditServ.Text;
MForm.TaskCl.smtpport:=Editport.Value;
MForm.TaskCl.smtpuser:=EditUser.Text;
MForm.TaskCl.smtppass:=EditPass.Text;
MForm.TaskCl.mailfrom:=EditMailfrom.Text;

MForm.TaskCl.LangFile:=LangFileList.Strings[BoxLang.ItemIndex];

// Перевод
CL:=LoadLangIni(MForm.TaskCl.LangFile);
if CL<>nil then
   begin
   TC[1]:=MForm;
   fillProps(TC,CL);
   end;

//MForm.TaskCl.SaveToFile('');
ModalResult:=mrOk;
end;
//Проверка отправки почты
procedure TFormSet.butTestSmtpClick(Sender: TObject);
var
  SendMail:TSendMail;
  suc:boolean;
  str:string;
begin
  SendMail:=TSendMAil.Create;
  SendMail.aName:=EditUser.Text;
  SendMail.aPass:=EditPass.Text;
  suc:=SendMail.Send(EditServ.Text,EditPort.Value,EditMailFrom.Text,EditMailTo.Text,'AutoSave test','This is test letter','');
  if suc then
  begin // Успешно
  str:=misc(rsAlertTestOk,'rsAlertTestOk');
  ShowMessage(str);
  end
  else
  begin // Не успешно
   str:=Format(misc(rsAlertTestErr,'rsAlertTestErr'),[SendMail.LastError]);
   ShowMessage(str);
  end;
  SendMail.Destroy;
end;

procedure TFormSet.EditLogNamKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
  var
TC: array[1..3] of TComponent;
begin
if (Key=VK_F5) then
   begin
   fillcustomini;
   end;
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
buf:=MForm.TaskCl.FullFileNam(MForm.TaskCl.logfile);
ShellExecute(0,nil,buf,nil,nil,SW_SHOWNORMAL);
end;


//========================================================
// Поиск языков
procedure TFormSet.FillLangs;
//========================================================
var
 rep:string;
 sr:TSearchRec;
 langname:string;
 CL2:TMemIniFile;
begin
rep:=extractFileDir(application.exeName)+'\';
LangNameList:=TStringList.create;
LangFileList:=TStringList.Create;
BoxLang.Items.Clear;
 // поиск всех файлов lng
LangNameList.Add('Russian');
BoxLang.Items.Add('Russian');
LangFileList.Add('russian.lng');
BoxLang.ItemIndex:=0; // По умолчанию русский
if findFirst(rep+'*.lng',faAnyFile,sr)=0 then
   repeat
   CL2:=LoadLangIni(sr.Name);

   langname:=CL2.ReadString('Language','Language','');
   if (langname='') then findNext(sr)
    else
     begin
     LangNameList.Add(langname);
     BoxLang.Items.Add(langname);
     LangFileList.Add(sr.Name);
     end;
   if sr.Name=MForm.TaskCl.LangFile then BoxLang.ItemIndex:=LangNameList.Count-1;
   until findNext(sr)<>0;
end;

procedure TFormSet.FormCreate(Sender: TObject);
var
TC: array[1..1] of TComponent;
begin
if CL<>nil then
   begin
   TC[1]:=FormSet;
   fillProps(TC,CL);
   end;
FillForm;
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


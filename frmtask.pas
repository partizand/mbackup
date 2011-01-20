unit FrmTask;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, StdCtrls,
  EditBtn, ExtCtrls, Buttons, MaskEdit, Spin, ComCtrls, ButtonPanel, msgStrings,
  DateUtils, customfs, taskunit, frmftp,unitfunc;


const       // Константы типа задачи
 ttCopy   = 1; // Копирование
  ttZerk   = 2; //Зеркалирование
  ttSync   = 3; //Сихронизирование
  ttArhRar = 5; //Архивирование Rar
  ttArhZip = 4; //Архивирование Zip
  ttArh7Zip =6; //Архивирование 7Zip

type

  { TFormTask }

  TFormTask = class(TForm)
    AfterCheck: TCheckBox;
    AfterName: TFileNameEdit;
    ArhBox: TGroupBox;
    ArhDelBox: TGroupBox;
    BeforeCheck: TCheckBox;
    BeforeName: TFileNameEdit;
    BtnDirAdd: TBitBtn;
    BtnDirDel: TBitBtn;
    ButtonPanel1: TButtonPanel;
    cbAlert: TComboBox;
    CBoxAct: TComboBox;
    CBoxFileMode: TComboBox;
    chkSolid: TCheckBox;
    chkArhOpenFiles: TCheckBox;
    EditAddOpt: TEdit;
    GroupAddOptions: TGroupBox;
    chkEncrypt: TCheckBox;
    chkDelAfterArh: TCheckBox;
    cbCondBefore: TComboBox;
    cbCondAfter: TComboBox;
    cbLevelCompress: TComboBox;
    DelArhCheck: TCheckBox;
    DelZerkCheck: TCheckBox;
    EditArhPass: TEdit;
    EditArhNam: TEdit;
    EditDaysOld: TSpinEdit;
    EditExcDir: TEditButton;
    EditDest: TDirectoryEdit;
    EditDestFTP: TEditButton;
    EditMonthsOld: TSpinEdit;
    EditSorFtp: TEditButton;
    EditSor: TDirectoryEdit;
    EditFileMask: TEdit;
    EditName: TEdit;
    EditYearsOld: TSpinEdit;
    EditZerkOld: TSpinEdit;
    EnabledCheck: TCheckBox;
    FiltDirCheck: TCheckBox;
    FiltFilesCheck: TCheckBox;
    GroupCompress: TGroupBox;
    GroupEncrypt: TGroupBox;
    groupTaskName: TGroupBox;
    GroupOther: TGroupBox;
    groupSource: TGroupBox;
    GroupSourceFilt: TGroupBox;
    GroupExcludeFold: TGroupBox;
    GroupProcFiles: TGroupBox;
    GroupAction: TGroupBox;
    GroupDest: TGroupBox;
    GroupExtProg: TGroupBox;
    GroupNotifi: TGroupBox;
    Image1: TImage;
    LabelAddOpt: TLabel;
    LabelDaily: TLabel;
    LabelDay: TLabel;
    LabelExten: TLabel;
    LabelFor: TLabel;
    LabelDays: TLabel;
    LabelMon: TLabel;
    LabelMonthly: TLabel;
    LabelYear: TLabel;
    LabelYearly: TLabel;
    NTFSCheck: TCheckBox;
    OnceDayCheck: TCheckBox;
    pcMenu: TPageControl;
    radioDestFolder: TRadioButton;
    radioDestFtp: TRadioButton;
    radioSorFolder: TRadioButton;
    radioSorFTP: TRadioButton;
    RecurseCheck: TCheckBox;
    Splitter2: TSplitter;
    SubDirBox: TListBox;
    tabSource: TTabSheet;
    tabArh: TTabSheet;
    tabOther: TTabSheet;
    tabMain: TTabSheet;
    tvMenu: TTreeView;
    ZerkDelBox: TGroupBox;
    procedure AfterCheckChange(Sender: TObject);
    procedure ArhBoxClick(Sender: TObject);
    procedure BeforeCheckChange(Sender: TObject);
    procedure BtnDirAddClick(Sender: TObject);
    procedure BtnDirDelClick(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure ButtonPanel1Click(Sender: TObject);
    procedure CBoxActChange(Sender: TObject);
    procedure chkEncryptChange(Sender: TObject);
    procedure DelArhCheckChange(Sender: TObject);
    procedure DelZerkCheckChange(Sender: TObject);
    procedure EditArhPassKeyPress(Sender: TObject; var Key: char);
    procedure EditDestFTPButtonClick(Sender: TObject);
    procedure EditExcDirButtonClick(Sender: TObject);
    procedure EditSorFtpButtonClick(Sender: TObject);
//    procedure EditNameKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState      );
    procedure EvMinCheckChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);



//    procedure GroupBox9Click(Sender: TObject);
//    procedure pcMenuChange(Sender: TObject);
    procedure radioDestFolderChange(Sender: TObject);
    procedure radioDestFtpChange(Sender: TObject);
    procedure radioSorFolderChange(Sender: TObject);
    procedure radioSorFTPChange(Sender: TObject);

    procedure FiltDirCheckChange(Sender: TObject);
    procedure FiltFilesCheckChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ManualCheckChange(Sender: TObject);
    procedure StartCheckChange(Sender: TObject);
    procedure TimeCheckChange(Sender: TObject);
    procedure tvMenuSelectionChanged(Sender: TObject);
  private
    { private declarations }
    procedure FillSor;
    procedure FillDest;
    function ConvertCBtoCond(index:integer):integer; // Преобразовывает выбранный индекс в условие для выполнения внешней проги
    function ConvertCondtoCB(cond:integer):integer; // Перобразование наоборот
    PassArhChanged:boolean;
  public
    { public declarations }
    procedure FillForm;
    procedure FillChecks;
    function  ReadTaskForm:Boolean;
    function ShowFTPform(Indx:integer):boolean; // Показать форму с фтп параметрами
//    numTask:integer; // Номер добавляемого/редактируемого задания
    Task:TTask; // Редактируемое задание
  end; 

var
  FormTask: TFormTask;

implementation

//uses mainform;
//================================================
// Показать форму с фтп параметрами
// Indx-1 - источник Indx-2 - применик
// Возвращает true если сохранение параметров
function TFormTask.ShowFTPform(Indx:integer):boolean;
begin
//Application.CreateForm(TfrmFTPParam, frmFTPParam); // создание формы
frmFTPParam:=TfrmFTPParam.Create(self);
//FormTask.numTask:=NumEdTask;
if Indx=1 then
    begin
    frmFTPParam.FtpServParam:=Task.SrcFSParam.FtpServParam;
//    frmFTPParam.RealPass:=;
    end
  else
    frmFTPParam.FtpServParam:=Task.DstFSParam.FtpServParam;
frmFTPParam.FillForm;
if frmFTPParam.ShowModal=mrOk then
  begin
  if Indx=1 then
       Task.SrcFSParam.FtpServParam:=frmFTPParam.FtpServParam
    else
       Task.DstFSParam.FtpServParam:=frmFTPParam.FtpServParam;
  FillForm;
  Result:=true;
  end
 else
  begin
  Result:=false;
  end;
frmFTPParam.Free;
end;
//================================================
// Заполнение текста источника
procedure TFormTask.FillSor;
begin
// Источник
if Task.SrcFSParam.FSType=fstFile then
     begin
     EditSor.Text:=Task.SrcFSParam.RootDir;
     EditSorFtp.Text:='';
     radioSorFolder.Checked:=true;
     radioSorFTP.Checked:=false;
     end
   else
     begin
     EditSor.Text:='';
     EditSorFtp.Text:=TBackup.GetNameFS(Task.SrcFSParam);
     radioSorFolder.Checked:=false;
     radioSorFTP.Checked:=true;
     end;

end;

//================================================
// Заполнение текста источника
procedure TFormTask.FillDest;
begin
// Приемник
if Task.DstFSParam.FSType=fstFile then
     begin
     EditDest.Text:=Task.DstFSParam.RootDir;
     EditDestFtp.Text:='';
     radioDestFolder.Checked:=true;
     radioDestFTP.Checked:=false;
     end
   else
     begin
     EditDest.Text:='';
     EditDestFtp.Text:=TBackup.GetNameFS(Task.DstFSParam);
     radioDestFolder.Checked:=false;
     radioDestFTP.Checked:=true;
     end;
end;
//================================================
// Заполнение формы
procedure TFormTask.FillForm;
//================================================
var
  ETime:string;
begin
EnabledCheck.Checked:=Task.Enabled;// Task.Enabled;
EditName.Text:= Task.Name;
// Источник
FillSor;
{
if Task.SrcFSParam.FSType=fstFile then
     begin
     EditSor.Text:=Task.SrcFSParam.RootDir;
     EditSorFtp.Text:='';
     radioSorFolder.Checked:=true;
     radioSorFTP.Checked:=false;
     end
   else
     begin
     EditSor.Text:='';
     EditSorFtp.Text:=TBackup.GetNameFS(Task.SrcFSParam);
     radioSorFolder.Checked:=false;
     radioSorFTP.Checked:=true;
     end;
}
// Приемник
FillDest;
{
if Task.DstFSParam.FSType=fstFile then
     begin
     EditDest.Text:=Task.DstFSParam.RootDir;
     EditDestFtp.Text:='';
     radioDestFolder.Checked:=true;
     radioDestFTP.Checked:=false;
     end
   else
     begin
     EditDest.Text:='';
     EditDestFtp.Text:=TBackup.GetNameFS(Task.DstFSParam);
     radioDestFolder.Checked:=false;
     radioDestFTP.Checked:=true;
     end;
     }
//EditDest.Text:=Task.DestPath;

CBoxAct.ItemIndex:=-1;




CBoxAct.ItemIndex:=Task.Action-1;


// Блок про архивацию
  // Уровень сжатия
  case Task.Arh.LevelCompress of
   lcNone: cbLevelCompress.ItemIndex:=0;
   lcFastest: cbLevelCompress.ItemIndex:=1;
   lcFast: cbLevelCompress.ItemIndex:=2;
   lcNormal: cbLevelCompress.ItemIndex:=3;
   lcMaximum: cbLevelCompress.ItemIndex:=4;
   lcUltra: cbLevelCompress.ItemIndex:=5;
   else
     cbLevelCompress.ItemIndex:=3;
  end;
  EditArhNam.Text:=Task.Arh.Name;
  chkArhOpenFiles.Checked:=Task.Arh.ArhOpenFiles;
  chkSolid.Checked:=Task.Arh.Solid;
  EditAddOpt.Text:=Task.Arh.AddOptions;

  DelArhCheck.Checked:=Task.Arh.DelOldArh;
  chkDelAfterArh.Checked:=Task.Arh.DelAfterArh;
  EditDaysOld.Value:=Task.Arh.DaysOld;
  EditMonthsOld.Value:=Task.Arh.MonthsOld;
  EditYearsOld.Value:=Task.Arh.YearsOld;
  chkEncrypt.Checked:=Task.Arh.EncryptEnabled;
  if PassArhChanged then
       EditArhPass.Text:=DecryptString(Task.Arh.Password,KeyStrTask)
     else
       EditArhPass.Text:='################';
// Хранить файлы

  DelZerkCheck.Checked:=Task.Arh.DelOldArh;
  EditZerkOld.Value:=Task.Arh.DaysOld;
// Уведомления
cbAlert.ItemIndex:=Task.MailAlert;


// расписание

OnceDayCheck.Checked:=Task.Rasp.OnceForDay;
//DateTimeToString(ETime,'HH:MM',Task.Rasp.Time);
//EditTime.Text:=ETime;

//ManualCheck.Checked:=Task.Rasp.Manual;
//TimeCheck.Checked:=Task.Rasp.AtTime;
//StartCheck.Checked:=Task.Rasp.AtStart;

//EvMinCheck.Checked:=Task.Rasp.EvMinutes;
//EditMin.Text:=IntToStr(Task.Rasp.Minutes);

// Запуск внешних программ
BeforeCheck.Checked:=Task.ExtBefore.Enabled;
BeforeName.Text:=Task.ExtBefore.Cmd;
cbCondBefore.ItemIndex:=ConvertCondtoCB(Task.ExtBefore.Condition);
AfterCheck.Checked:=Task.ExtAfter.Enabled;
AfterName.Text:=Task.ExtAfter.Cmd;
cbCondAfter.ItemIndex:=ConvertCondtoCB(Task.ExtAfter.Condition);
// фильтрация источника
RecurseCheck.Checked:=Task.SourceFilt.Recurse;
FiltDirCheck.Checked:=Task.SourceFilt.FiltSubDir;
SubDirBox.Items.DelimitedText:=Task.SourceFilt.SubDirs;
FiltFilesCheck.Checked:=Task.SourceFilt.FiltFiles;
CBoxFileMode.ItemIndex:=Task.SourceFilt.ModeFiltFiles;
EditFileMask.Text:=Task.SourceFilt.FileMask;
// NTFSCopy
NTFSCheck.Checked:=Task.NTFSPerm;
FillChecks;
// FTP источника
//BoxSorType.ItemIndex:=Task.SorType;
//EditFtpUserNam.Text:=Task.FTP.UserName;
//EditFtpPass.Text:=Task.FTP.Pass;
//EditFtpPort.Value:=Task.FTP.Port;
// FTP приемника
//BoxDestType.ItemIndex:=Task.DestType;
//EditFtpNamDest.Text:=Task.DestFTP.UserName;
//EditFtpPassDest.Text:=Task.DestFTP.Pass;
//EditFtpPortDest.Value:=Task.DestFTP.Port;

end;
//================================================
// Преобразовывает выбранный индекс в условие для выполнения внешней проги
function TFormTask.ConvertCBtoCond(index:integer):integer;
begin
case index of
  0: Result:= -1;
  1: Result:= 1;
  2: Result:= 10;
else
  Result:= -1;
end;

end;
//================================================
// Преобразовывает условие в выбранный индекс (для выполнения внешней проги)
function TFormTask.ConvertCondtoCB(cond:integer):integer;
begin
case cond of
  -1: Result:= 0;
  0..9: Result:= 1;
  10..19: Result:= 2;
else
  Result:= 0;
end;

end;
//================================================
// Чтение формы задания
// возвращает при успехе true при неудаче false
function TFormTask.ReadTaskForm:Boolean;
//=================================================
var
 str,SorDir,DestDir:String;

begin
Result:=false;
//MForm.TaskCl.Tasks[MForm.TaskCl.count+1].SorPath:=EditSor1.Text;
//MForm.TaskCl.Tasks[MForm.TaskCl.count+1].DestPath:=EditDest.Text;
//MForm.TaskCl.ReplaceNameDisk(MForm.TaskCl.count+1,true);

// Источник папка
if radioSorFolder.Checked then
   begin
   SorDir:=utf8toAnsi(EditSor.Text);

   if SorDir='' then
       begin
       ShowMessage(rsEnterSource);
       exit;
       end;
   if (Not DirectoryExists(SorDir)) and (Pos('%',SorDir)=0) then // Не существует каталог источника
       begin
       str:=Format(rsLogDirNotFound,[EditSor.Text]);
       ShowMessage(str);
       exit;
       end;
   Task.SrcFSParam.RootDir:=EditSor.Text;
   end;
// Приемник папка
if radioDestFolder.Checked then
   begin
   DestDir:=utf8toAnsi(EditDest.Text);
   if DestDir='' then
        begin
        ShowMessage(rsEnterDest);
        exit;
        end;

   if (Not DirectoryExists(DestDir)) and (Pos('%',DestDir)=0) then // Не задан приемник
        begin
        str:=Format(rsDirNotExsistCreate,[EditDest.Text]);
        if MessageDlg(str, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
        begin
         if ForceDirectories(DestDir) then
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
   Task.DstFSParam.RootDir:=EditDest.Text;
   end;
if CBoxAct.ItemIndex=-1 then // Не задано действие
 begin
 ShowMessage(rsSelectAction);
 exit;
 end;

if (CBoxAct.ItemIndex=ttArhRar-1) or (CBoxAct.ItemIndex=ttArh7zip-1) or (CBoxAct.ItemIndex=ttArhZip-1) then
  begin
  if EditArhNam.Text='' then // Не задано имя архива
   begin
   ShowMessage(rsNoArcName);
   exit;
   end;
  end;

if CBoxAct.ItemIndex=ttArhRar-1 then
 begin
  str:=TBackup.GetFullExePath('rar.exe') ;
//  if Not FileExists(ExtractFileDir(ParamStr(0))+'\rar.exe') then
  if str='' then
   begin
   ShowMessage(rsNoRar);
   exit;
   end;
 end;

if (CBoxAct.ItemIndex=ttArh7zip-1) or (CBoxAct.ItemIndex=ttArhZip-1) then
 begin
  str:=TBackup.GetFullExePath('7za.exe');
  if str=''then str:=TBackup.GetFullExePath('7z.exe');

  if str=''then // Нет файла 7z.exe
   begin
   ShowMessage(rsNo7zip);
   exit;
   end;
 end;

Task.Name:=EditName.Text;

//Task.DestPath:=EditDest.Text;

//Task.SrcFSParam.RootDir:=EditSor.Text;
if radioSorFolder.Checked then Task.SrcFSParam.FSType:=fstFile;
if radioSorFTP.Checked then Task.SrcFSParam.FSType:=fstFTP;

//Task.DstFSParam.RootDir:=EditDest.Text;
if radioDestFolder.Checked then Task.DstFSParam.FSType:=fstFile;
if radioDestFTP.Checked then Task.DstFSParam.FSType:=fstFTP;


Task.Action:=CBoxAct.ItemIndex+1;
// Уведомления
Task.MailAlert:=cbAlert.ItemIndex;
//Task.Rasp.Time:=StrToTime(EditTime.Text);
//Task.Rasp.Time:=RecodeSecond(Task.Rasp.Time,0);
//Task.Rasp.Time:=RecodeMilliSecond(Task.Rasp.Time,0);
// Расписание
Task.Rasp.OnceForDay:=OnceDayCheck.Checked;
//Task.Rasp.Manual:=ManualCheck.Checked;
//Task.Rasp.AtStart:=StartCheck.Checked;
//Task.Rasp.AtTime:=TimeCheck.Checked;

//Task.Rasp.EvMinutes:=EvMinCheck.Checked;

//Task.Rasp.Minutes:=EditMin.Value;

// Архивация
if (CBoxAct.ItemIndex=ttArhZip-1) or (CBoxAct.ItemIndex=ttArh7Zip-1) or (CBoxAct.ItemIndex=ttArhRar-1) then
  begin
  Task.Arh.Name:=EditArhNam.Text;
  Task.Arh.DelOldArh:=DelArhCheck.Checked;
  Task.Arh.DaysOld:=EditDaysOld.Value;
  Task.Arh.MonthsOld:=EditMonthsOld.Value;
  Task.Arh.YearsOld:=EditYearsOld.Value;
  Task.Arh.DelAfterArh:=chkDelAfterArh.Checked;
  Task.Arh.EncryptEnabled:=chkEncrypt.Checked;
  Task.Arh.ArhOpenFiles:=chkArhOpenFiles.Checked;
  Task.Arh.Solid:=chkSolid.Checked;
  Task.Arh.AddOptions:=EditAddOpt.Text;
  // Пароль
  if PassArhChanged then
       Task.Arh.Password:=EncryptString(EditArhPass.Text,KeyStrTask);
  // Уровень сжатия
    case cbLevelCompress.ItemIndex of
      0: Task.Arh.LevelCompress:=lcNone;
      1: Task.Arh.LevelCompress:=lcFastest;
      2: Task.Arh.LevelCompress:=lcFast;
      3: Task.Arh.LevelCompress:=lcNormal;
      4: Task.Arh.LevelCompress:=lcMaximum;
      5: Task.Arh.LevelCompress:=lcUltra;
      else
        Task.Arh.LevelCompress:=lcNormal;
    end;
  end;
// Зеркалирование
if (CBoxAct.ItemIndex=ttZerk-1) then
  begin
  Task.Arh.DelOldArh:=DelZerkCheck.Checked;
  Task.Arh.DaysOld:=EditZerkOld.Value;
  end;
Task.Enabled:=EnabledCheck.Checked;
// Внешние программы
Task.ExtBefore.Enabled:=BeforeCheck.Checked;
Task.ExtBefore.Cmd:=BeforeName.Text;
Task.ExtBefore.Condition:=ConvertCBtoCond(cbCondBefore.ItemIndex);
Task.ExtAfter.Enabled:=AfterCheck.Checked;
Task.ExtAfter.Cmd:=AfterName.Text;
Task.ExtAfter.Condition:=ConvertCBtoCond(cbCondAfter.ItemIndex);
// NTFS
Task.NTFSPerm:=NTFSCheck.Checked;
// Фильтрация источника
Task.SourceFilt.Recurse:=RecurseCheck.Checked;
Task.SourceFilt.FiltSubDir:=FiltDirCheck.Checked;
Task.SourceFilt.SubDirs:=SubDirBox.Items.DelimitedText;
Task.SourceFilt.FiltFiles:=FiltFilesCheck.Checked;
Task.SourceFilt.ModeFiltFiles:=CBoxFileMode.ItemIndex;
Task.SourceFilt.FileMask:=EditFileMask.Text;
Result:=true;
end;
//===================================================================

procedure TFormTask.EvMinCheckChange(Sender: TObject);
begin
  FillChecks;
end;


procedure TFormTask.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
 if ModalResult=mrOk then
      begin
        CanClose:=ReadTaskForm;
      end
   else
     CanClose:=true;
end;


procedure TFormTask.DelArhCheckChange(Sender: TObject);
begin
  FillChecks;
end;

procedure TFormTask.DelZerkCheckChange(Sender: TObject);
begin
  FillChecks;
end;

procedure TFormTask.EditArhPassKeyPress(Sender: TObject; var Key: char);
begin
  PassArhChanged:=true;
  EditArhPass.EchoMode:=emNormal;
end;

procedure TFormTask.EditDestFTPButtonClick(Sender: TObject);
begin
  ShowFTPform(2);
end;
// Выбор каталога для исключения
procedure TFormTask.EditExcDirButtonClick(Sender: TObject);
var
  Dir,RelDir:string;
begin
if EditSor.Text='' then
  begin
   ShowMessage(rsEnterSource);
   Exit;
  end;
if SelectDirectory('',EditSor.Text,Dir) then
 begin
  RelDir:=ExtractRelativePath(EditSor.Text+'\',Dir);
  EditExcDir.Text:=RelDir;
//  SubDirBox.Items.Add(RelDir);
 end;
end;

procedure TFormTask.EditSorFtpButtonClick(Sender: TObject);
begin
  ShowFTPform(1);
end;


procedure TFormTask.BeforeCheckChange(Sender: TObject);
begin
  FillChecks;
end;

procedure TFormTask.BtnDirAddClick(Sender: TObject);
var
  Dir,RelDir:string;
begin
if EditExcDir.Text<>'' then
     begin
     SubDirBox.Items.Add(EditExcDir.Text);
     end;
end;

procedure TFormTask.BtnDirDelClick(Sender: TObject);
begin
  SubDirBox.Items.Delete(SubDirBox.ItemIndex) //SubDirBox.DeleteSelected;
end;

procedure TFormTask.BtnOKClick(Sender: TObject);
begin
  if ReadTaskForm then
  begin
//  MForm.TaskCl.SaveToFile('');
  ModalResult:=mrOk;
  end;
end;

procedure TFormTask.ButtonPanel1Click(Sender: TObject);
begin

end;

procedure TFormTask.CBoxActChange(Sender: TObject);
begin
  FillChecks;
end;

procedure TFormTask.chkEncryptChange(Sender: TObject);
begin
  FillChecks;
end;

procedure TFormTask.AfterCheckChange(Sender: TObject);
begin
  FillChecks;
end;

procedure TFormTask.ArhBoxClick(Sender: TObject);
begin

end;

//=======================================================================
// Включение выключение чеков
procedure TFormTask.FillChecks;
//=====================================================
begin




if Not RecurseCheck.Checked then
 begin
 FiltDirCheck.Checked:=false;
 end;
{
if ManualCheck.Checked then
  begin
    EditTime.Enabled:=false;
    RepeatBox.Enabled:=false;
    EvMinCheck.Enabled:=false;
    EvMinCheck.Checked:=false;
    TimeCheck.Checked:=false;
  end;
if TimeCheck.Checked then
  begin
    TimeCheck.Checked:=true;
    EditTime.Enabled:=true;
    RepeatBox.Enabled:=true;
    EvMinCheck.Enabled:=true;
  end;


if StartCheck.Checked then
  begin
    EditTime.Enabled:=false;
    RepeatBox.Enabled:=false;
    EvMinCheck.Enabled:=false;
    EvMinCheck.Checked:=false;
    TimeCheck.Checked:=false;
  end;
  }
//   ZerkDelBox.Enabled:=false;

//   ArhBox.Enabled:=false;

//   ArhBox.Visible:=false;
//   ArhDelBox.Visible:=false;
//   ZerkDelBox.Visible:=false;
//   GroupEncrypt.Visible:=false;

// EditArhNam.Enabled:=true;
// ArhDelBox.Enabled:=false;


// Копирование, синхронизация или зеркалирование
if (CBoxAct.ItemIndex=ttCopy-1) OR (CBoxAct.ItemIndex=ttSync-1) OR (CBoxAct.ItemIndex=ttZerk-1) then
begin
ArhBox.Enabled:=false;
   ArhDelBox.Enabled:=false;
   EditArhNam.Enabled:=false;
   NTFSCheck.Enabled:=true;

   radioSorFTP.Enabled:=true;
   ArhDelBox.Visible:=false;
   GroupEncrypt.Visible:=false;
   GroupCompress.Visible:=false;
   GroupAddOptions.Visible:=false;
   ArhBox.Visible:=false;
   ZerkDelBox.Visible:=false;
  if (CBoxAct.ItemIndex=ttZerk-1) then // Зеркалирование
  begin
   ZerkDelBox.Visible:=true;
//   DelZerkCheck.Enabled:=false;
   if DelZerkCheck.Checked then
      EditZerkOld.Enabled:=true
     else
      EditZerkOld.Enabled:=false;
  end;
end;
  {
if (CBoxAct.ItemIndex=ttCopy-1) OR (CBoxAct.ItemIndex=ttSync-1) then // Копирование, синхронизация
  begin
   ArhBox.Enabled:=false;
   ArhDelBox.Enabled:=false;
   EditArhNam.Enabled:=false;
   NTFSCheck.Enabled:=true;

   radioSorFTP.Enabled:=true;
   ArhDelBox.Visible:=false;
   GroupEncrypt.Visible:=false;
   GroupCompress.Visible:=false;
   GroupAddOptions.Visible:=false;
   ArhBox.Visible:=false;
   ZerkDelBox.Visible:=false;
  end;
if (CBoxAct.ItemIndex=ttZerk-1) then // Зеркалирование
  begin
   ZerkDelBox.Visible:=true;
   NTFSCheck.Enabled:=true;

  radioSorFTP.Enabled:=true;
  ArhDelBox.Visible:=false;
  GroupEncrypt.Visible:=false;
  GroupCompress.Visible:=false;
  GroupAddOptions.Visible:=false;
  ArhBox.Visible:=false;

   ZerkDelBox.Enabled:=true;
   DelZerkCheck.Enabled:=true;
   if DelZerkCheck.Checked then
      EditZerkOld.Enabled:=true
     else
      EditZerkOld.Enabled:=false;

  end;
  }
if (CBoxAct.ItemIndex>2) then // архивация
 begin
 EditArhPass.Enabled:=chkEncrypt.Checked;
 ArhBox.Visible:=true;
 ArhBox.Enabled:=true;
 EditArhNam.Enabled:=true;

 GroupEncrypt.Visible:=true;
 GroupCompress.Visible:=true;
 GroupAddOptions.Visible:=true;

 ArhDelBox.Enabled:=true;
 ArhDelBox.Visible:=true;
 ZerkDelBox.Visible:=false;

 radioSorFTP.Enabled:=false;
 radioSorFTP.Checked:=false;
 radioSorFolder.Checked:=true;

 if DelArhCheck.Checked then
  begin
   EditDaysOld.Enabled:=true;
   EditMonthsOld.Enabled:=true;
   EditYearsOld.Enabled:=true;
  end
 else
  begin
   EditDaysOld.Enabled:=false;
   EditMonthsOld.Enabled:=false;
   EditYearsOld.Enabled:=false;
  end;

 if CBoxAct.ItemIndex=ttArhZip-1 then
     begin
      LabelExten.Caption:='.zip';
      NTFSCheck.Checked:=false;
      NTFSCheck.Enabled:=false;
      chkDelAfterArh.Enabled:=false;
      chkSolid.Enabled:=false;
      end;
 if CBoxAct.ItemIndex=ttArh7Zip-1 then
     begin
      LabelExten.Caption:='.7z';
      NTFSCheck.Checked:=false;
      NTFSCheck.Enabled:=false;
      chkDelAfterArh.Enabled:=false;
      chkSolid.Enabled:=true;
      end;
  if CBoxAct.ItemIndex=ttArhRar-1 then
     begin
     LabelExten.Caption:='.rar';
     NTFSCheck.Enabled:=true;
     chkDelAfterArh.Enabled:=true;
     chkSolid.Enabled:=true;
     end;

 end;


if radioSorFolder.Checked then // Источник папка
      begin
      Task.SrcFSParam.FSType:=fstFile;
      EditSorFtp.Enabled:=false;
      EditSor.Enabled:=true;
      EditExcDir.Button.Enabled:=true;
      end;
if radioSorFTP.Checked then // Источник FTP
      begin
      Task.SrcFSParam.FSType:=fstFTP;
      EditSor.Enabled:=false;
      EditSorFtp.Enabled:=true;
      EditExcDir.Button.Enabled:=false;
      end;

if radioDestFolder.Checked then // Приемник папка
      begin
      Task.DstFSParam.FSType:=fstFile;
      EditDestFtp.Enabled:=false;
      EditDest.Enabled:=true;
      end;
if radioDestFTP.Checked then // Приемник FTP
      begin
      Task.DstFSParam.FSType:=fstFTP;
      EditDest.Enabled:=false;
      EditDestFtp.Enabled:=true;
      end;

// расписание
{
if EvMinCheck.Checked then
  begin
  EditMin.Enabled:=true;
  end
 else
   begin
   EditMin.Enabled:=false;
   end;
 }
// Внешние программы
if BeforeCheck.Checked then //до
   begin
   BeforeName.Enabled:=true;
   cbCondBefore.Enabled:=true;
   end
  else
   begin
   BeforeName.Enabled:=false;
   cbCondBefore.Enabled:=false;
   end;
if AfterCheck.Checked then //после
   begin
   AfterName.Enabled:=true;
   cbCondAfter.Enabled:=true;
   end
  else
   begin
   AfterName.Enabled:=false;
   cbCondAfter.Enabled:=false;
   end;
// Фильтация источника
if FiltDirCheck.Checked then
 begin
  SubDirBox.Enabled:=true;
  BtnDirAdd.Enabled:=true;
  BtnDirDel.Enabled:=true;
  EditExcDir.Enabled:=true;
  if radioSorFolder.Checked then EditExcDir.Button.Enabled:=true; // Источник папка
  if radioSorFTP.Checked then EditExcDir.Button.Enabled:=false;  // Источник FTP
  //  EditExcDir.Button.Enabled:=true;
 end
 else
  begin
    SubDirBox.Enabled:=false;
    BtnDirAdd.Enabled:=false;
    BtnDirDel.Enabled:=false;
    EditExcDir.Enabled:=false;
    EditExcDir.Button.Enabled:=false;
  end;
if FiltFilesCheck.Checked then
  begin
   CBoxFileMode.Enabled:=true;
   EditFileMask.Enabled:=true;
  end
 else
  begin
   CBoxFileMode.Enabled:=false;
   EditFileMask.Enabled:=false;
  end;

//  NTFSCheck.Enabled:=true;
//  SpeedButton1.Enabled:=true;

end;



procedure TFormTask.radioDestFolderChange(Sender: TObject);
begin
  FillChecks;
  FillDest;
//  FillForm;
end;

procedure TFormTask.radioDestFtpChange(Sender: TObject);
begin
  FillChecks;
  FillDest;
  //FillForm;
end;

procedure TFormTask.radioSorFolderChange(Sender: TObject);
begin
  //Task.SrcFSParam.FSType:=fstFile;
  FillChecks;
  FillSor;
  //FillForm;
end;

procedure TFormTask.radioSorFTPChange(Sender: TObject);
begin
//  Task.SrcFSParam.FSType:=fstFTP;
  FillChecks;
// Источник
FillSor;

end;

procedure TFormTask.FiltDirCheckChange(Sender: TObject);
begin
  FillChecks;
end;

procedure TFormTask.FiltFilesCheckChange(Sender: TObject);
begin
FillChecks;
end;

procedure TFormTask.FormCreate(Sender: TObject);
{
var

TC: array[1..1] of TComponent;
}

begin
PassArhChanged:=false;
EditArhPass.EchoMode:=emPassword;

cbLevelCompress.Clear;
cbLevelCompress.Items.Add(rsNone);
cbLevelCompress.Items.Add(rsFastest);
cbLevelCompress.Items.Add(rsFast);
cbLevelCompress.Items.Add(rsNormal);
cbLevelCompress.Items.Add(rsMaximum);
cbLevelCompress.Items.Add(rsUltra);

CBoxAct.Clear;
CBoxAct.Items.Add(rsCopyng);
CBoxAct.Items.Add(rsMirror);
CBoxAct.Items.Add(rsSync);
CBoxAct.Items.Add(rsArcZip);
CBoxAct.Items.Add(rsArcRar);
CBoxAct.Items.Add(rsArc7Zip);

CBoxFileMode.Clear;
CBoxFileMode.Items.Add(rsExclude);
CBoxFileMode.Items.Add(rsOnlyThese);

cbAlert.Clear;
cbAlert.Items.Add(rsNone);
cbAlert.Items.Add(rsOnlyError);
cbAlert.Items.Add(rsAlways);

cbCondBefore.Clear;
cbCondBefore.Items.Add(rsAlways);
cbCondBefore.Items.Add(rsOk);
cbCondBefore.Items.Add(rsTaskEndError);
cbCondBefore.ItemIndex:=0;

cbCondAfter.Clear;
cbCondAfter.Items.Add(rsAlways);
cbCondAfter.Items.Add(rsOk);
cbCondAfter.Items.Add(rsTaskEndError);
cbCondAfter.ItemIndex:=0;

tvMenu.Items.Clear;
tvMenu.Items.Add(nil,rsTaskSettingsNode1);
tvMenu.Items.Add(nil,rsTaskSettingsNode2);
tvMenu.Items.Add(nil,rsTaskSettingsNode3);
tvMenu.Items.Add(nil,rsOther);

tvMenu.Items[0].Selected:=true;
pcMenu.ActivePageIndex:=0;

ButtonPanel1.CancelButton.Caption:=rsCancel;
ButtonPanel1.OKButton.Caption:=rsOk;

SubDirBox.Items.Delimiter:=';';
end;

procedure TFormTask.FormShow(Sender: TObject);
begin
 // FillForm;
end;

procedure TFormTask.ManualCheckChange(Sender: TObject);
begin
  FillChecks;
end;

procedure TFormTask.StartCheckChange(Sender: TObject);
begin
  FillChecks;
end;

procedure TFormTask.TimeCheckChange(Sender: TObject);
begin
  FillChecks;
end;

procedure TFormTask.tvMenuSelectionChanged(Sender: TObject);
begin
  if tvMenu.Selected<>nil then
   begin
   pcMenu.ActivePageIndex:=tvMenu.Selected.Index;
   end;
end;



initialization
  {$I frmtask.lrs}

end.


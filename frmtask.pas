unit FrmTask;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, StdCtrls,
  EditBtn, ExtCtrls, Buttons, MaskEdit, Spin,{iniLang,}msgStrings,
  DateUtils;


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
    BtnOK: TBitBtn;
    BtnCancel: TBitBtn;
    BtnDirAdd: TBitBtn;
    BtnDirDel: TBitBtn;
    CBoxFileMode: TComboBox;
    CBoxAct: TComboBox;
    BeforeCheck: TCheckBox;
    AfterCheck: TCheckBox;
    cbAlert: TComboBox;
    chkDelAfterArh: TCheckBox;
    DelZerkCheck: TCheckBox;
    Label12: TLabel;
    Label13: TLabel;
    EditZerkOld: TSpinEdit;
    ZerkDelBox: TGroupBox;
    OnceDayCheck: TCheckBox;
    DelArhCheck: TCheckBox;
    EditArhNam: TEdit;
    EvMinCheck: TCheckBox;
    EditDest: TDirectoryEdit;
    BeforeName: TFileNameEdit;
    AfterName: TFileNameEdit;
    GroupBox10: TGroupBox;
    GroupBox6: TGroupBox;
    GroupBox7: TGroupBox;
    GroupBox8: TGroupBox;
    ArhBox: TGroupBox;
    ArhDelBox: TGroupBox;
    GroupBox9: TGroupBox;
    Label11: TLabel;
    Label4: TLabel;
    Label10: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    //EditTime: TMaskEdit;
    RepeatBox: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ManualCheck: TRadioButton;
    EditTime: TMaskEdit;
    NTFSCheck: TCheckBox;
    EditFileMask: TEdit;
    FiltFilesCheck: TCheckBox;
    FiltDirCheck: TCheckBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    RadioGroup1: TRadioGroup;
    EditMin: TSpinEdit;
    EditDaysOld: TSpinEdit;
    EditMonthsOld: TSpinEdit;
    EditYearsOld: TSpinEdit;
    StartCheck: TRadioButton;
    SubDirBox: TListBox;
    RecurseCheck: TCheckBox;
    EditSor: TDirectoryEdit;
    EnabledCheck: TCheckBox;
    EditName: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Image1: TImage;
    TimeCheck: TRadioButton;
    procedure AfterCheckChange(Sender: TObject);
    procedure ArhBoxClick(Sender: TObject);
    procedure BeforeCheckChange(Sender: TObject);
    procedure BtnDirAddClick(Sender: TObject);
    procedure BtnDirDelClick(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
    procedure CBoxActChange(Sender: TObject);
    procedure DelArhCheckChange(Sender: TObject);
    procedure DelZerkCheckChange(Sender: TObject);
//    procedure EditNameKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState      );
    procedure EvMinCheckChange(Sender: TObject);
    procedure FillForm;
    procedure FillChecks;
    procedure GroupBox9Click(Sender: TObject);
    function  ReadTaskForm:Boolean;
    procedure FiltDirCheckChange(Sender: TObject);
    procedure FiltFilesCheckChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ManualCheckChange(Sender: TObject);
    procedure StartCheckChange(Sender: TObject);
    procedure TimeCheckChange(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    numTask:integer; // Номер добавляемого/редактируемого задания
  end; 

var
  FormTask: TFormTask;

implementation

uses mainform;
//================================================
// Заполнение формы
procedure TFormTask.FillForm;
//================================================
var
  ETime:string;
begin
EnabledCheck.Checked:=MForm.TaskCl.Tasks[numTask].Enabled;
EditName.Text:=MForm.TaskCl.Tasks[numTask].Name;
EditSor.Text:=MForm.TaskCl.Tasks[numTask].SorPath;
EditDest.Text:=MForm.TaskCl.Tasks[numTask].DestPath;
CBoxAct.ItemIndex:=-1;




CBoxAct.ItemIndex:=MForm.TaskCl.Tasks[numTask].Action-1;
// Блок про архивацию
if MForm.TaskCl.Tasks[numTask].Action=ttZerk then
  begin
  DelZerkCheck.Checked:=MForm.TaskCl.Tasks[numTask].Arh.DelOldArh;
  EditZerkOld.Text:=IntToStr(MForm.TaskCl.Tasks[numTask].Arh.DaysOld);
  end
 else
 begin
  EditArhNam.Text:=MForm.TaskCl.Tasks[numTask].Arh.Name;
  DelArhCheck.Checked:=MForm.TaskCl.Tasks[numTask].Arh.DelOldArh;
  chkDelAfterArh.Checked:=MForm.TaskCl.Tasks[numTask].Arh.DelAfterArh;
  EditDaysOld.Text:=IntToStr(MForm.TaskCl.Tasks[numTask].Arh.DaysOld);
  EditMonthsOld.Text:=IntToStr(MForm.TaskCl.Tasks[numTask].Arh.MonthsOld);
  EditYearsOld.Text:=IntToStr(MForm.TaskCl.Tasks[numTask].Arh.YearsOld);
 end;
// Уведомления
cbAlert.ItemIndex:=MForm.TaskCl.Tasks[numTask].MailAlert;


// расписание

OnceDayCheck.Checked:=MForm.TaskCl.Tasks[numTask].Rasp.OnceForDay;
//DateTimeToString(ETime,'HH:MM',MForm.TaskCl.Tasks[numTask].Rasp.Time);
//EditTime.Text:=ETime;

//ManualCheck.Checked:=MForm.TaskCl.Tasks[numTask].Rasp.Manual;
//TimeCheck.Checked:=MForm.TaskCl.Tasks[numTask].Rasp.AtTime;
//StartCheck.Checked:=MForm.TaskCl.Tasks[numTask].Rasp.AtStart;

//EvMinCheck.Checked:=MForm.TaskCl.Tasks[numTask].Rasp.EvMinutes;
//EditMin.Text:=IntToStr(MForm.TaskCl.Tasks[numTask].Rasp.Minutes);

// Запуск внешних программ
BeforeCheck.Checked:=MForm.TaskCl.Tasks[numTask].ExtProgs.BeforeStart;
BeforeName.Text:=MForm.TaskCl.Tasks[numTask].ExtProgs.BeforeName;
AfterCheck.Checked:=MForm.TaskCl.Tasks[numTask].ExtProgs.AfterStart;
AfterName.Text:=MForm.TaskCl.Tasks[numTask].ExtProgs.AfterName;
// фильтрация источника
RecurseCheck.Checked:=MForm.TaskCl.Tasks[numTask].SourceFilt.Recurse;
FiltDirCheck.Checked:=MForm.TaskCl.Tasks[numTask].SourceFilt.FiltSubDir;
SubDirBox.Items.Assign(MForm.TaskCl.Tasks[numTask].SourceFilt.SubDirs);
FiltFilesCheck.Checked:=MForm.TaskCl.Tasks[numTask].SourceFilt.FiltFiles;
CBoxFileMode.ItemIndex:=MForm.TaskCl.Tasks[numTask].SourceFilt.ModeFiltFiles;
EditFileMask.Text:=MForm.TaskCl.Tasks[numTask].SourceFilt.FileMask.DelimitedText;
// NTFSCopy
NTFSCheck.Checked:=MForm.TaskCl.Tasks[numTask].NTFSPerm;
FillChecks;
// FTP источника
//BoxSorType.ItemIndex:=MForm.TaskCl.Tasks[numTask].SorType;
//EditFtpUserNam.Text:=MForm.TaskCl.Tasks[numTask].FTP.UserName;
//EditFtpPass.Text:=MForm.TaskCl.Tasks[numTask].FTP.Pass;
//EditFtpPort.Value:=MForm.TaskCl.Tasks[numTask].FTP.Port;
// FTP приемника
//BoxDestType.ItemIndex:=MForm.TaskCl.Tasks[numTask].DestType;
//EditFtpNamDest.Text:=MForm.TaskCl.Tasks[numTask].DestFTP.UserName;
//EditFtpPassDest.Text:=MForm.TaskCl.Tasks[numTask].DestFTP.Pass;
//EditFtpPortDest.Value:=MForm.TaskCl.Tasks[numTask].DestFTP.Port;

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
MForm.TaskCl.Tasks[MForm.TaskCl.count+1].SorPath:=EditSor.Text;
MForm.TaskCl.Tasks[MForm.TaskCl.count+1].DestPath:=EditDest.Text;
MForm.TaskCl.ReplaceNameDisk(MForm.TaskCl.count+1,true);
SorDir:=utf8toAnsi(MForm.TaskCl.Tasks[MForm.TaskCl.count+1].SorPath);
DestDir:=utf8toAnsi(MForm.TaskCl.Tasks[MForm.TaskCl.count+1].DestPath);
if SorDir='' then
 begin
 ShowMessage(rsEnterSource);
 exit;
 end;
if DestDir='' then
 begin
 ShowMessage(rsEnterDest);
 exit;
 end;

if (Not DirectoryExists(SorDir)) and (Pos('%',SorDir)=0) then // Не задан источник
 begin
 str:=Format(rsLogDirNotFound,[EditSor.Text]);
 ShowMessage(str);
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
  if Not FileExists(ExtractFileDir(ParamStr(0))+'\rar.exe') then
   begin
   ShowMessage(rsNoRar);
   exit;
   end;
 end;

if (CBoxAct.ItemIndex=ttArh7zip-1) or (CBoxAct.ItemIndex=ttArhZip-1) then
 begin
  if Not FileExists(ExtractFileDir(ParamStr(0))+'\7za.exe') then // Нет файла 7z.exe
   begin
   ShowMessage(rsNo7zip);
   exit;
   end;
 end;

MForm.TaskCl.Tasks[numTask].Name:=EditName.Text;
MForm.TaskCl.Tasks[numTask].SorPath:=EditSor.Text;
MForm.TaskCl.Tasks[numTask].DestPath:=EditDest.Text;

MForm.TaskCl.Tasks[numTask].Action:=CBoxAct.ItemIndex+1;
// Уведомления
MForm.TaskCl.Tasks[numTask].MailAlert:=cbAlert.ItemIndex;
//MForm.TaskCl.Tasks[numTask].Rasp.Time:=StrToTime(EditTime.Text);
//MForm.TaskCl.Tasks[numTask].Rasp.Time:=RecodeSecond(MForm.TaskCl.Tasks[numTask].Rasp.Time,0);
//MForm.TaskCl.Tasks[numTask].Rasp.Time:=RecodeMilliSecond(MForm.TaskCl.Tasks[numTask].Rasp.Time,0);
// Расписание
MForm.TaskCl.Tasks[numTask].Rasp.OnceForDay:=OnceDayCheck.Checked;
//MForm.TaskCl.Tasks[numTask].Rasp.Manual:=ManualCheck.Checked;
//MForm.TaskCl.Tasks[numTask].Rasp.AtStart:=StartCheck.Checked;
//MForm.TaskCl.Tasks[numTask].Rasp.AtTime:=TimeCheck.Checked;

//MForm.TaskCl.Tasks[numTask].Rasp.EvMinutes:=EvMinCheck.Checked;

//MForm.TaskCl.Tasks[numTask].Rasp.Minutes:=EditMin.Value;

// Архивация
if (CBoxAct.ItemIndex=ttArhZip-1) or (CBoxAct.ItemIndex=ttArh7Zip-1) or (CBoxAct.ItemIndex=ttArhRar-1) then
  begin
  MForm.TaskCl.Tasks[numTask].Arh.Name:=EditArhNam.Text;
  MForm.TaskCl.Tasks[numTask].Arh.DelOldArh:=DelArhCheck.Checked;
  MForm.TaskCl.Tasks[numTask].Arh.DaysOld:=EditDaysOld.Value;
  MForm.TaskCl.Tasks[numTask].Arh.MonthsOld:=EditMonthsOld.Value;
  MForm.TaskCl.Tasks[numTask].Arh.YearsOld:=EditYearsOld.Value;
  MForm.TaskCl.Tasks[numTask].Arh.DelAfterArh:=chkDelAfterArh.Checked;
  end;
// Зеркалирование
if (CBoxAct.ItemIndex=ttZerk-1) then
  begin
  MForm.TaskCl.Tasks[numTask].Arh.DelOldArh:=DelZerkCheck.Checked;
  MForm.TaskCl.Tasks[numTask].Arh.DaysOld:=EditZerkOld.Value;
  end;
MForm.TaskCl.Tasks[numTask].Enabled:=EnabledCheck.Checked;
// Внешние программы
MForm.TaskCl.Tasks[numTask].ExtProgs.BeforeStart:=BeforeCheck.Checked;
MForm.TaskCl.Tasks[numTask].ExtProgs.BeforeName:=BeforeName.Text;
MForm.TaskCl.Tasks[numTask].ExtProgs.AfterStart:=AfterCheck.Checked;
MForm.TaskCl.Tasks[numTask].ExtProgs.AfterName:=AfterName.Text;
// NTFS
MForm.TaskCl.Tasks[numTask].NTFSPerm:=NTFSCheck.Checked;
// Фильтрация источника
MForm.TaskCl.Tasks[numTask].SourceFilt.Recurse:=RecurseCheck.Checked;
MForm.TaskCl.Tasks[numTask].SourceFilt.FiltSubDir:=FiltDirCheck.Checked;
MForm.TaskCl.Tasks[numTask].SourceFilt.SubDirs.Assign(SubDirBox.Items);
MForm.TaskCl.Tasks[numTask].SourceFilt.FiltFiles:=FiltFilesCheck.Checked;
MForm.TaskCl.Tasks[numTask].SourceFilt.ModeFiltFiles:=CBoxFileMode.ItemIndex;
MForm.TaskCl.Tasks[numTask].SourceFilt.FileMask.DelimitedText:=EditFileMask.Text;
Result:=true;
end;
//===================================================================

procedure TFormTask.EvMinCheckChange(Sender: TObject);
begin
  FillChecks;
end;

procedure TFormTask.DelArhCheckChange(Sender: TObject);
begin
  FillChecks;
end;

procedure TFormTask.DelZerkCheckChange(Sender: TObject);
begin
  FillChecks;
end;


procedure TFormTask.BeforeCheckChange(Sender: TObject);
begin
  FillChecks;
end;

procedure TFormTask.BtnDirAddClick(Sender: TObject);
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
  SubDirBox.Items.Add(RelDir);
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
  MForm.TaskCl.SaveToFile('');
  ModalResult:=mrOk;
  end;
end;

procedure TFormTask.CBoxActChange(Sender: TObject);
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
   ZerkDelBox.Enabled:=false;
   DelZerkCheck.Enabled:=false;
   ArhBox.Enabled:=false;
   ArhBox.Visible:=false;
   ZerkDelBox.Visible:=false;
// EditArhNam.Enabled:=true;
 ArhDelBox.Enabled:=false;

if (CBoxAct.ItemIndex=ttCopy-1) OR (CBoxAct.ItemIndex=ttSync-1) then // Копирование, синхронизация
  begin
   ArhBox.Enabled:=false;
   ArhDelBox.Enabled:=false;
   EditArhNam.Enabled:=false;
   NTFSCheck.Enabled:=true;
 //  RepeatBox.Enabled:=true;
 //   EvMinCheck.Enabled:=true;
  end;
if (CBoxAct.ItemIndex=ttZerk-1) then // Зеркалирование
  begin
   ZerkDelBox.Visible:=true;
   //ArhBox.Enabled:=false;
   //ArhDelBox.Enabled:=false;
   //EditArhNam.Enabled:=false;
   NTFSCheck.Enabled:=true;

   ZerkDelBox.Enabled:=true;
   DelZerkCheck.Enabled:=true;
   if DelZerkCheck.Checked then
      EditZerkOld.Enabled:=true
     else
      EditZerkOld.Enabled:=false;

  end;
if (CBoxAct.ItemIndex>2) then // архивация
 begin
 ArhBox.Visible:=true;
 ArhBox.Enabled:=true;
 EditArhNam.Enabled:=true;
 ArhDelBox.Enabled:=true;
// EditMonthsOld.Enabled:=true;
// EditYearsOld.Enabled:=true;
// DelArhCheck.Caption:=misc(rsArcOldCheckName, 'rsArcOldCheckName');

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
      Label10.Caption:='.zip';
      NTFSCheck.Checked:=false;
      NTFSCheck.Enabled:=false;
      chkDelAfterArh.Enabled:=false;
      end;
 if CBoxAct.ItemIndex=ttArh7Zip-1 then
     begin
      Label10.Caption:='.7z';
      NTFSCheck.Checked:=false;
      NTFSCheck.Enabled:=false;
      chkDelAfterArh.Enabled:=false;
      end;
  if CBoxAct.ItemIndex=ttArhRar-1 then
     begin
     Label10.Caption:='.rar';
     NTFSCheck.Enabled:=true;
     chkDelAfterArh.Enabled:=true;
     end;

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
//   BeforeBtn.Enabled:=true;
   end
  else
   begin
   BeforeName.Enabled:=false;
//   BeforeBtn.Enabled:=false;
   end;
if AfterCheck.Checked then //после
   begin
   AfterName.Enabled:=true;
//   AfterBtn.Enabled:=true;
   end
  else
   begin
   AfterName.Enabled:=false;
//   AfterBtn.Enabled:=false;
   end;
// Фильтация источника
if FiltDirCheck.Checked then
 begin
  SubDirBox.Enabled:=true;
  BtnDirAdd.Enabled:=true;
  BtnDirDel.Enabled:=true;
 end
 else
  begin
    SubDirBox.Enabled:=false;
    BtnDirAdd.Enabled:=false;
    BtnDirDel.Enabled:=false;
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

procedure TFormTask.GroupBox9Click(Sender: TObject);
begin

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
{
Copying
Mirroring
Synchronization
Archiving ZIP
Archiving RAR
Archiving 7zip
}
{
if CL<>nil then
   begin
   TC[1]:=FormTask;
   fillProps(TC,CL);
   end;
   }
end;

procedure TFormTask.FormShow(Sender: TObject);
begin
  FillForm;
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



initialization
  {$I frmtask.lrs}

end.


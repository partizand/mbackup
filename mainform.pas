unit MainForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, Menus,
  ActnList, ComCtrls, StdCtrls, ExtCtrls,taskunit,{inifiles,}inilang,msgstrings,
  taskthread,windows;

Type TOnTermEvent = Procedure( Sender: TObject) of object;

type

  { TMForm }

  TMForm = class(TForm)
    ActAdd: TAction;
    ActEdit: TAction;
    ActDel: TAction;
    ActDown: TAction;
    ActAbout: TAction;
    ActAddProfile: TAction;
    ActHelp: TAction;
    ActCopy: TAction;
    ActSaveProf: TAction;
    ActOpenProfile: TAction;
    ActNewProfile: TAction;
    ActSet: TAction;
    ActUp: TAction;
    ActRun: TAction;
    ActionList1: TActionList;
    ImageList1: TImageList;
    ListTask: TListView;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    mnutCopy: TMenuItem;
    mnuSave: TMenuItem;
    mnuHelp: TMenuItem;
    mnuTOpenProfile: TMenuItem;
    mnutAddprofile: TMenuItem;
    mnuTAbout: TMenuItem;
    mnutHelpMain: TMenuItem;
    mnutSet: TMenuItem;
    mnutSetmain: TMenuItem;
    mnutDown: TMenuItem;
    mnutUp: TMenuItem;
    mnutdel: TMenuItem;
    mnutrun: TMenuItem;
    MnuTEdit: TMenuItem;
    //MnuTEdit: TMenuItem;
    MsgMemo: TMemo;
    MnuTAdd: TMenuItem;
    MnuTask: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    Splitter1: TSplitter;
    StatusBar: TStatusBar;
    ToolBar1: TToolBar;
    ButAdd: TToolButton;
    ButEdit: TToolButton;
    ButDel: TToolButton;
//    ToolButton1: TToolButton;
    ButStart: TToolButton;
    ButStop: TToolButton;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ButUp: TToolButton;
    ButDown: TToolButton;
    ToolButton3: TToolButton;
    ButSet: TToolButton;
    ButHelp: TToolButton;
    procedure ActAboutExecute(Sender: TObject);
    procedure ActAddExecute(Sender: TObject);
    procedure ActAddProfileExecute(Sender: TObject);
    procedure ActCopyExecute(Sender: TObject);
    procedure ActDelExecute(Sender: TObject);
    procedure ActDownExecute(Sender: TObject);
    procedure ActEditExecute(Sender: TObject);
    procedure ActHelpExecute(Sender: TObject);
    procedure ActNewProfileExecute(Sender: TObject);
    procedure ActOpenProfileExecute(Sender: TObject);
    procedure ActRunExecute(Sender: TObject);
    procedure ActSaveProfExecute(Sender: TObject);
    procedure ActSetExecute(Sender: TObject);
    procedure ActUpExecute(Sender: TObject);
    procedure ButDownClick(Sender: TObject);
    procedure ButStopClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);

    procedure FormCreate(Sender: TObject);
    procedure ListTaskDblClick(Sender: TObject);
    procedure MsgMemoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
      );
    procedure Splitter1CanResize(Sender: TObject; var NewSize: Integer; var Accept: Boolean);
    // Мои процедуры
//    procedure ReadIni;
//    procedure SaveIni;
    procedure ReadArgvW;
    procedure FillListTask(numTask:integer);
    procedure RunThTask(numT:integer);
    procedure TaskDone(Sender: TObject);
    function ShowTaskForm(NumEdTask:integer):boolean;

  private
    { private declarations }
  public
    { public declarations }
    TaskCl:TTaskCl;
    AutoOnlyClose:boolean; // Автозапуск заданий только с параметром close
    StartMin:boolean; // Сврорачивать при запуске
    IsClosing:boolean; // Закрывать ли форму, для обработки нажатия на крестих формы
//    LoadLastProf:boolean; // Загружать последний открытый профиль
//    DefaultProf:String; // профиль по умолчанию

//    LangFile:String; // Имя файла языка
//    TotGauge:TGauge;
    TotGauge:TProgressBar;
    FormInitialWidth:integer;
//    ParamQ:boolean; // Выход из программы по завершению всех заданий (параметр /q при запуске)
    ParamRun:boolean; // Установлен парметр /r и есть задания на запуск

    taskcount:integer; // Количество запущенных потоков с заданием
    taskth:TTaskThread; // Поток с заданием

  end;

var
  MForm: TMForm;

implementation

uses frmtask,frmset,unitabout;

{ TMForm }


procedure TMForm.Splitter1CanResize(Sender: TObject; var NewSize: Integer;
  var Accept: Boolean);
begin

end;


procedure TMForm.ActAddExecute(Sender: TObject);
begin

if TaskCl.Count=MaxTasks then exit; // Перебор
TaskCl.AddTask;

//FormTask.numTask:=TaskCl.Count;
if Not ShowTaskForm(TaskCl.Count) then
                TaskCl.DelTask(TaskCl.Count);


// FormTask.Showmodal;
end;

procedure TMForm.ActAddProfileExecute(Sender: TObject);
var
 profil:string;
begin
if OpenDialog1.Execute then
  begin
  profil:=TaskCl.profile;
  TaskCl.LoadFromFile(OpenDialog1.FileName);
  TaskCl.profile:=profil; // сохранение имени старого профиля
  FillListTask(-1);
  end;
end;

procedure TMForm.ActCopyExecute(Sender: TObject);
var
 num:integer;
begin
if ListTask.SelCount=0 then exit;
  num:=ListTask.Selected.Index+1;
  if num<1 then exit;
  TaskCl.DublicateTask (num);
  FillListTask(num);
end;

procedure TMForm.ActAboutExecute(Sender: TObject);
begin
Application.CreateForm(TFormAbout, FormAbout); // создание формы
FormAbout.ShowModal;
FormAbout.Destroy;

end;

procedure TMForm.ActDelExecute(Sender: TObject);
var
 num:integer;
 str:string;
begin
ButDel.Down:=false;
if ListTask.SelCount=0 then exit;
num:=ListTask.Selected.Index+1;
if num<1 then exit;
str:=format(misc(rsQuestDeleteTask,'rsQuestDeleteTask'),[TaskCl.Tasks[num].Name]);
if MessageDlg(str,mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
  TaskCl.DelTask(num);
  FillListTask(num-1);
  TaskCl.SaveToFile('');
  end;
//ButDel.Down:=false;
end;

procedure TMForm.ActDownExecute(Sender: TObject);
var
 num:integer;
begin
if ListTask.SelCount=0 then exit;
num:=ListTask.Selected.Index+1;
if num<1 then exit;
TaskCl.DownTask(num);
FillListTask(num-1);
TaskCl.SaveToFile('');
end;

procedure TMForm.ActEditExecute(Sender: TObject);
var
 num:integer;
begin
if ListTask.SelCount=0 then exit;
  num:=ListTask.Selected.Index+1;
  if num<1 then exit;
  ShowTaskForm(num);
end;

procedure TMForm.ActHelpExecute(Sender: TObject);
var
 helpfile2:string;
begin
if CL=nil then
   begin
   helpfile2:='Help-ru.htm';
   end
  else
  helpfile2:=CL.ReadString('Language','HelpFile','Help-ru.htm');
ShellExecute(0,nil,PChar(ExtractFileDir(ParamStr(0))+'\'+helpfile2),nil,nil,SW_SHOWNORMAL);
end;

procedure TMForm.ActNewProfileExecute(Sender: TObject);
var
 filenam:string; // имя файла
begin
if SaveDialog1.Execute then
  begin
  filenam:=MForm.TaskCl.ShortFileNam(SaveDialog1.FileName);
  if ExtractFileExt(filenam)='' then filenam:=filenam+'.xml';
  TaskCl.Clear; //Count:=0;
  FillListTask(-1);
//  TaskCl.ProfName:='';
  TaskCl.SaveToFile(filenam);
  TaskCl.LoadFromFile(filenam);
  MForm.Caption:='AutoSave '+MForm.TaskCl.profile;
  end;
end;

procedure TMForm.ActOpenProfileExecute(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
//  TaskCl.Count:=0;
  TaskCl.LoadFromFile(OpenDialog1.FileName);
//  EditCurProf.Text:=MForm.TaskCl.profile;
//  EditProfNam.Text:=MForm.TaskCl.ProfName;
  FillListTask(-1);
  MForm.Caption:='AutoSave '+MForm.TaskCl.profile;
  end;
end;

procedure TMForm.ActRunExecute(Sender: TObject);
var
 num:integer;
begin
if ListTask.SelCount=0 then exit;
num:=ListTask.Selected.Index+1;
if num<1 then exit;
RunThTask(num);
//ButStart.Down:=false;
end;

procedure TMForm.ActSaveProfExecute(Sender: TObject);
var
 filen:string; // имя файла
begin
If SaveDialog1.Execute then
   begin
   filen:=TaskCl.ShortFileNam(SaveDialog1.FileName);
   if ExtractFileExt(filen)='' then filen:=filen+'.xml';
   TaskCl.SaveToFile(filen);
   //EditCurProf.Text:=filen;
   MForm.Caption:='AutoSave '+MForm.TaskCl.profile;
   end;
end;

procedure TMForm.ActSetExecute(Sender: TObject);
begin
  Application.CreateForm(TFormSet, FormSet); // создание формы
  Application.CreateForm(TFormAbout, FormAbout); // создание формы
  Application.CreateForm(TFormTask, FormTask);
if FormSet.ShowModal=mrOk then
  begin
  TaskCl.SaveIni;
  end;
FormSet.Destroy;
FormAbout.Destroy;
FormTask.Destroy;
end;

procedure TMForm.ActUpExecute(Sender: TObject);
var
 num:integer;
begin
if ListTask.SelCount=0 then exit;
num:=ListTask.Selected.Index+1;
if num<1 then exit;
TaskCl.UpTask(num);
FillListTask(num-1);
TaskCl.SaveToFile('');
end;

procedure TMForm.ButDownClick(Sender: TObject);
begin

end;

procedure TMForm.ButStopClick(Sender: TObject);
begin

end;

procedure TMForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if TaskCl.LoadLastProf then
    begin
     TaskCl.DefaultProf:=TaskCl.profile;
     TaskCl.SaveIni;
    end;
 TaskCl.SaveToFile('');
 TaskCl.Destroy;
end;

procedure TMForm.FormCreate(Sender: TObject);
var
TC: array[1..1] of TComponent;
begin

// Создание прогресс бара
TotGauge:=TProgressBar.Create(StatusBar);
With TotGauge Do
    Begin
       // ForeColor:=clSilver;
        Parent := StatusBar;
        Top := 2;
        Left := StatusBar.Left + StatusBar.Panels.Items[0].Width +
            StatusBar.Panels.Items[1].Width + 2;
        Height := StatusBar.Height - 2;
       // MinValue:=0;
       // MaxValue:=100;
        Width:=150;
        Visible:=false;
      end;

FormInitialWidth := MForm.Width;

TaskCl:=TTaskCl.Create;
TaskCount:=0;
IsClosing:=false;
//TaskCl.ReadIni;
if StartMin then MForm.WindowState:=wsMinimized;

ReadArgvW;

MForm.Caption:='AutoSave '+TaskCl.Profile;

// Перевод
CL:=LoadLangIni(TaskCl.LangFile);
if CL<>nil then
   begin
   TC[1]:=MForm;
   fillProps(TC,CL);
   end;
FillListTask(0);
end;

procedure TMForm.ListTaskDblClick(Sender: TObject);
begin

end;

procedure TMForm.MsgMemoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
  var
TC: array[1..3] of TComponent;
begin
// создание всех форм
Application.CreateForm(TFormTask, FormTask); // создание формы
Application.CreateForm(TFormSet, FormSet);
Application.CreateForm(TFormAbout, FormAbout);
// создание языкового файла
if (Key=VK_F5) then fillcustomini;
FormTask.Destroy;
FormSet.Destroy;
FormAbout.Destroy;
end;


//================================================
// Заполнение списка наборов в ListView
// numTask номер выделяемого задания
// если 0 то ничего не выделяется
// если -1 то выделяется ранее выделенный элемент
procedure TMForm.FillListTask(numTask:integer);
//================================================
var
 i:integer;
 olditem:integer;
 strStatus,strstEnd:string;
 frmTime:string;
begin
//olditem:=ListTask.Selected.Index;  //ListTask.ItemIndex;
ListTask.Items.Clear;
// Запись задач
for i:=1 to TaskCl.Count do
 begin
     ListTask.Items.Add;
     ListTask.Items.Item[i-1].Caption:=TaskCl.Tasks[i].Name;
     //ListTask.Items.Item[i-1].Checked:=true;
     ListTask.Items.Item[i-1].SubItems.Add(TaskCl.Tasks[i].SorPath);
     if TaskCl.Tasks[i].Action=ttCopy then
      ListTask.Items.Item[i-1].SubItems.Add(misc(rsCopyng,'rsCopyng'));
     if TaskCl.Tasks[i].Action=ttZerk then
      ListTask.Items.Item[i-1].SubItems.Add(misc(rsMirror,'rsMirror'));
     if TaskCl.Tasks[i].Action=ttSync then
      ListTask.Items.Item[i-1].SubItems.Add(misc(rsSync,'rsSync'));
     if TaskCl.Tasks[i].Action=ttArhRar then
      ListTask.Items.Item[i-1].SubItems.Add(misc(rsArcRar,'rsArcRar'));
     if TaskCl.Tasks[i].Action=ttArhZip then
      ListTask.Items.Item[i-1].SubItems.Add(misc(rsArcZip,'rsArcZip'));
     if TaskCl.Tasks[i].Action=ttArh7Zip then
      ListTask.Items.Item[i-1].SubItems.Add(misc(rsArc7Zip,'rsArc7Zip'));

     ListTask.Items.Item[i-1].SubItems.Add(TaskCl.Tasks[i].DestPath);
     // Время запуска/состояние
     strStatus:='';
     strstend:='';
     if TaskCl.Tasks[i].Status=stRunning then // задание выполняется
        begin
         strStatus:=misc(rsIsRunning,'rsIsRunning')+' (';
         strstend:=')';
        end;
     if TaskCl.Tasks[i].Status=stWaiting then // задание ожидает выполнения
         strStatus:=misc(rsIsWaiting,'rsIsWaiting')+ ' (';
     if TaskCl.Tasks[i].Enabled then
       begin
       ListTask.Items.Item[i-1].SubItems.Add(strStatus+misc(rsYes,'rsYes')+strstend);
{
        if TaskCl.Tasks[i].Rasp.Manual then
          begin
           ListTask.Items.Item[i-1].SubItems.Add(strStatus+misc(rsManual,'rsManual')+strstend);
          end;
        if TaskCl.Tasks[i].Rasp.AtStart then
          begin
           ListTask.Items.Item[i-1].SubItems.Add(strStatus+misc(rsAtStart,'rsAtStart')+strstend);
          end;
        if TaskCl.Tasks[i].Rasp.AtTime then
          begin
           DateTimeToString(frmTime,'HH:MM',TaskCl.Tasks[i].Rasp.Time);
           ListTask.Items.Item[i-1].SubItems.Add(strStatus+frmTime+strstend);
          end;
}
       end

      else
       begin
       ListTask.Items.Item[i-1].SubItems.Add(strStatus+misc(rsNo,'rsNo')+strstend);
       end;
  // Состояние последнего запуска
  if TaskCl.Tasks[i].LastRunDate=0 then // еще ни разу не запускалась
    begin
     strStatus:=misc(rsTaskNeverRun,'rsTaskNeverRun');
    end
   else
    begin
    if TaskCl.Tasks[i].LastResult=trOk then strStatus:=misc(rsOk,'rsOk');
    if TaskCl.Tasks[i].LastResult=trError then strStatus:=misc(rsTaskError,'rsTaskError');
    if TaskCl.Tasks[i].LastResult=trFileError then strStatus:=misc(rsTaskEndError,'rsTaskEndError');
     DateTimeToString(frmTime,'DD.MM.YY HH:MM',TaskCl.Tasks[i].LastRunDate);
     strStatus:=strStatus+' '+frmTime;
    end;
  ListTask.Items.Item[i-1].SubItems.Add(strStatus);
  end;

 // if ListTask.Selected.Index+1<1 then
//   begin
//   ActionList1.Actions[1]. ActionByName('ActCopy').;
//   end;
{
if numTask<0 then ListTask. ItemFocused item Selected.Index:=oldItem
  else
    ListTask.ItemIndex:=numTask-1;
 }
end;




    {
//=====================================================
// Чтение значений из Ini файла
procedure TMForm.ReadIni;
//===================================================
 var
  SaveIniFile: TIniFile;
  IniName: String;
begin
IniName:=TaskCl.FullFileNam('autosave.ini');// ExtractFileDir(ParamStr(0))+'\'+'autosave.ini';

SaveIniFile := TIniFile.Create(IniName);
TaskCl.logfile:=SaveIniFile.ReadString('log', 'logfile', 'autosave.log');

{if ExtractFileDir(TaskCl.logfile)='' then
   TaskCl.logfile:=ExtractFileDir(ParamStr(0))+'\'+TaskCl.logfile;   // Каталог запуска
 }
TaskCl.loglimit:=SaveIniFile.ReadInteger('log', 'loglimit', 500);
IsClosing:=SaveIniFile.ReadBool('common', 'MinimizeToTray',true);
AutoOnlyClose:=SaveIniFile.ReadBool('common', 'AutoOnlyClose',false);
StartMin:=SaveIniFile.ReadBool('common', 'StartMinimized',false);
// Язык
LangFile:=SaveIniFile.ReadString('Language', 'LangFile', 'english.lng');

// настройка профилией
LoadLastProf:=SaveIniFile.ReadBool('profile', 'LoadLastProf',false); // загружать последний профиль
DefaultProf:=SaveIniFile.ReadString('profile', 'DefaultProf', 'default.xml');
TaskCl.profile:=DefaultProf;

TaskCl.email:=SaveIniFile.ReadString('alerts', 'email', 'pishite@pisma.nam');
TaskCl.alerttype:=SaveIniFile.ReadInteger('alerts', 'alerttype', alertNone);
TaskCl.smtpserv:=SaveIniFile.ReadString('alerts', 'smtpserv', '127.0.0.1');
TaskCl.smtpport:=SaveIniFile.ReadInteger('alerts', 'smtpport', 25);
TaskCl.smtpuser:=SaveIniFile.ReadString('alerts', 'smtpuser', 'pushkin');
TaskCl.smtppass:=TaskCl.DecryptStr(SaveIniFile.ReadString('alerts', 'smtppass', ''));
TaskCl.mailfrom:=SaveIniFile.ReadString('alerts', 'mailfrom', 'ot-lermontova@pisem.net');


//TrayIcon.MinimizeToTray:=IsClosing;
//TrayIcon.IconVisible:=IsClosing;
IsClosing:=Not (IsClosing);
SaveIniFile.Free;
end;
   }
 {
//=====================================================
// Запись значений в Ini файл
procedure TMForm.SaveIni;
 var
  SaveIniFile: TIniFile;
  cr:string;
  IniName,dp: String;
begin
IniName:= ExtractFileDir(ParamStr(0))+'\'+'autosave.ini';
SaveIniFile := TIniFile.Create(IniName);
SaveIniFile.WriteString('log', 'logfile',TaskCl.logfile);
SaveIniFile.WriteInteger('log', 'loglimit',TaskCl.loglimit);
//SaveIniFile.WriteBool('common', 'MinimizeToTray',FormSet.CheckTray.Checked);
//SaveIniFile.WriteBool('common', 'AutoOnlyClose',AutoOnlyClose);
//SaveIniFile.WriteBool('common', 'StartMinimized',FormSet.CheckStartMin.Checked);

SaveIniFile.WriteString('alerts', 'email', TaskCl.email);
SaveIniFile.WriteInteger('alerts', 'alerttype', TaskCl.alerttype);
SaveIniFile.WriteString('alerts', 'smtpserv', TaskCl.smtpserv);
SaveIniFile.WriteInteger('alerts', 'smtpport', TaskCl.smtpport);
SaveIniFile.WriteString('alerts', 'smtpuser', TaskCl.smtpuser);
cr:=TaskCl.CryptStr(TaskCl.smtppass);
SaveIniFile.WriteString('alerts', 'smtppass', TaskCl.CryptStr(TaskCl.smtppass));
SaveIniFile.WriteString('alerts', 'mailfrom', TaskCl.mailfrom);

// Язык
SaveIniFile.WriteString('Language', 'LangFile', LangFile);

SaveIniFile.WriteBool('profile', 'LoadLastProf',LoadLastProf);
dp:=DefaultProf;
if LoadLastProf then dp:=TaskCl.profile;
SaveIniFile.WriteString('profile', 'DefaultProf',dp);
SaveIniFile.Free;
end;
//================================================================
  }



//=======================================================
// Чтение командной строки в GUI
procedure TMForm.ReadArgvW;
//=====================================================
var
 k:integer;
// s,p:string;
 estr:boolean; // Есть параметр /r
// ParamQ2:boolean;
 IsProfile:boolean;
begin
TaskCl.Clear;
estr:=TaskCl.ReadArgv(IsProfile);

// Если есть параметр -r запуск заданий
if estr {or (NOT AutoOnlyClose))} then // автозапуск заданий
    begin
//    if (not (AutoOnlyClose)) Or (SameText(ParamStr(1),'close')) then
        begin
        for k:=1 to TaskCl.Count do
           begin
           // Задание включено                      (и на запуск при запуске)
           if TaskCl.Tasks[k].Enabled  then //and TaskCl.Tasks[k].Rasp.AtStart
              begin
              ParamRun:=true;
              TaskCl.InCmdMode:=true;
              RunThTask(k);
              end;
           end;
         end;
    end; // end if r
end;

{//=======================================================
// Чтение командной строки
procedure TMForm.ReadArgv;
//=====================================================
var
 j,i,k:integer;
 s,p:string;
 alertmes:TStrings;
// est:boolean;
 estp:boolean; // Есть профиль на загрузку
 estr:boolean; // Есть параметр /r
begin
alertmes:=TStringList.Create;
j:=paramcount; // Кол-во параметров командной строки
ParamQ:=false; // Есть параметр закрыть прогу
ParamRun:=false; // Есть задания на запуск
estp:=false;
estr:=false;
TaskCl.Clear; //Count:=0;
for i:=1 to j do // перебор всех параметров
  begin
  s:=ParamStr(i); // s очередной параметр
  if SameText(s,'-r') then // автозапуск заданий
    begin
     estr:=true;
    end; // end if r
  if SameText(s,'-q') then // Выход по завершению заданий
    begin
    ParamQ:=true;
 //   Estp:=true;
    end;
  if SameText(s,'-alert') then // Уведомление о запуске
    begin
    AlertMes.Add(misc(rsAlertRunMes,'rsAlertRunMes'));
//    TaskCl.SendMail(misc(rsAlertRunSubj,'rsAlertRunSubj'),AlertMes);
    end;
  if SameText(s,'-p') then // загрузка профиля
    begin
//    i:=i+1;
    if i+1<=j then p:=ParamStr(i+1)
      else continue;
    TaskCl.Clear; //Count:=0;
    TaskCl.LoadFromFile(p);
    estp:=true;
    end;
  end;

if not estp then // профиля на загрузку нет берем дефолтовый
  begin
  TaskCl.LoadFromFile('');
  end;

//MForm.Caption:='AutoSave '+TaskCl.profile;
// Если есть параметр /r запуск заданий
if estr {or (NOT AutoOnlyClose))} then // автозапуск заданий
    begin
//    if (not (AutoOnlyClose)) Or (SameText(ParamStr(1),'close')) then
        begin
        for k:=1 to TaskCl.Count do
           begin
           // Задание включено                      (и на запуск при запуске)
           if TaskCl.Tasks[k].Enabled  then //and TaskCl.Tasks[k].Rasp.AtStart
              begin
              ParamRun:=true;
              RunThTask(k);
              end;
           end;
         end;
    end; // end if r

alertmes.Free;
end;
  }
//===================================================================
// Создание формы задания и его показ
// numTask- номер редактируемого задания
// Возвращает true если нажали ok, false если cancel
function TMForm.ShowTaskForm(NumEdTask:integer):boolean;
//=====================================================================
begin
Application.CreateForm(TFormTask, FormTask); // создание формы
FormTask.numTask:=NumEdTask;
if FormTask.ShowModal=mrOk then
  begin
  FillListTask(NumEdTask);
  Result:=true;
  end
 else
  begin
  Result:=false;
  end;
FormTask.Destroy;
end;


//========================================================
// Запуск задания в потоке
procedure TMForm.RunThTask(numT:integer);
//var
// num:integer;
// taskth:TTaskThread;
begin
if numt<1 then exit;
if numt>TaskCl.Count then exit;
if taskcount=0 then // нет запущенных потоков
  begin
   taskcount:=1;
   TaskCl.Tasks[numT].Status:=stRunning; // Присваивание заданию статуса выполняется
   //TaskTh:=TTaskThread.Create(TaskCl.Tasks[numt],logfilenam); // Запуск потока
   TaskTh:=TTaskThread.Create(numt); // Запуск потока
//   OnTermEvent:=FOnTerminate; TaskDone;
   TaskTh.OnTerminate:=@TaskDone;
//   TaskDone; // Установка функции на завершение потока
  end
 else // поток запущен
  begin
   TaskCl.Tasks[numT].Status:=stWaiting; // Присваивание заданию статуса в очередь на выполнение
  end;
FillListTask(-1);
end;


//========================================================
// Функция выполняется при завершении потока
procedure TMForm.TaskDone(Sender: TObject);
var
 numRun:integer;
// TaskTh:TTaskThread;
begin
//ButStart.Down:=false;
// Снять статус выполняется
numRun:=TaskCl.FindTaskSt(stRunning);
TaskCl.Tasks[numRun].Status:=stNone;
// Найти есть ли в очереди задания
numRun:=TaskCl.FindTaskSt(stWaiting);
if numRun=-1 then // в очереди ничего нет
  begin
   TaskCount:=0;
   TaskCl.InCmdMode:=false; // Сброс признака запуска из командной строки
   if TaskCl.ParamQ then // если указан параметр автозавершения
     begin
     IsClosing:=true;
     MForm.Close;
     end;

  end
 else  // в очереди есть задание numRun
  begin
   TaskCl.Tasks[numRun].Status:=stRunning; // Присваивание заданию статуса выполняется
 //  TaskTh:=TTaskThread.Create(TaskCl.Tasks[numRun],logfilenam); // Запуск потока
   TaskTh:=TTaskThread.Create(numRun); // Запуск потока
   TaskTh.OnTerminate:=@TaskDone; // Установка функции на завершение потока
  end;
FillListTask(-1);
end;
//=====================================================

initialization
  {$I mainform.lrs}

end.

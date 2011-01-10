unit TaskUnit;

{
// Модуль содержащий класс TTaskCl.
Работа с заданиями


}
{$mode objfpc}{$H+}

interface

uses Windows,SysUtils,DateUtils,Classes, StrUtils,masks,{fileutil,}
 iniLangC,XMLCfg,inifiles;


//uses FileCtrl;

{$IFDEF WINDOWS}
  const slash = '\';
  {$ElSE}
  const slash='/';
{$Endif}

const
  VersionAS = '0.2 beta'; // Версия программы

const
  MaxTasks = 100; // Макс количество заданий
  MaxPChar = 250; // Макс длина строки запуска внешнего приложения


const         // Константы результата выполнения задачи
  trOk=0; // Все ок
  trError=1; // Ошибка запуска задания (недоступен каталог)
  trFileError=2; // Ошибка копирования файла в задании

type TMailAlert=(None=0,OnlyError=1,Enabled=2);

const        // Тип уведомлений по почте
  alertNone=0; // Выключить уведомления
  alertErr=1; // Уведомления только при ошибках
  alertAlways=2; // уведомлять всегда



const         // Константы состояния выполнения задания
  stNone=0; // Не выполняется
  stRunning=1; // Выполняется в данный момент
  stWaiting=2; // Ожидает выполнения

const       // Константы типа задачи
  ttCopy=1; // Копирование
  ttZerk=2; //Зеркалирование
  ttSync=3; //Сихронизирование
  ttArhRar=5; //Архивирование Rar
  ttArhZip=4; //Архивирование Zip

const       // Константы типа сортировки файлов источника
  tsNoMask=0; // Исключая
  tsMask=1; // Только по маске

type // Тип ProgressType для типа события OnProgress
  ProgressType = (NewFile, ProgressUpdate, EndOfBatch, TotalFiles2Process,
    TotalSize2Process, NewExtra, ExtraUpdate,MsgCopy);


   // Процедурный тип  (событие, совпадает с описанием события TZipMaster)

 Type TProgressEvent = Procedure( Sender: TObject; ProgrType: ProgressType; Filename: String; FileSize: int64 ) of object;

 type    // Парметры расписания
   TRasp = record
 //  Time:TDateTime; // Время начала
   Time:TDateTime; // Время начала
   AtTime:Boolean; // Запуск в заданное время
   Manual:Boolean; // Запуск вручную
   AtStart:Boolean; // Запуск при загрузке программы
   EvMinutes:Boolean; // Через каждые Minutes в теч дня
   Minutes:integer; // Через каждые столько минут в течении дня
   end;

  type  //параметры архива
    TArh = record
    Name:string; // имя архива
    DelOldArh:Boolean; //Удалять старые архивы
    DaysOld:integer; // старше дней
    MonthsOld:integer; // страше месяцев
    YearsOld:integer; // страше лет
    end;

  type // Параметры запуска внешних программ до и после задания
    TExtProgs = record
    BeforeStart:Boolean; // Запускать программу до начала задания
    BeforeName:string; // Имя файла для запуска
    AfterStart:Boolean; // Запускать программу после задания
    AfterName:string; // Имя файла для запуска
    end;


  type // Параметры фильтрации файлов и каталогов источника
    TSourceFilt = record
    Recurse:Boolean; // Обрабатывать подкаталоги
    FiltSubDir:Boolean; // За исключением подкаталогов
    SubDirs:TStringList; // список исключаемых каталогов
    FiltFiles:Boolean; // фильтровать файлы по условию
    ModeFiltFiles:integer; //  режим фильтрации Задается константами 0-исключая файлы по маске (ниже), 1-Только файлы по маске
    FileMask:TStringList; // список масок файлов
    end;

  type  // Запись для параметров одного копирования
    TTask = record
//    ProfName:String; // Имя конфигурации
    Enabled:Boolean; // задание разрешено
    Name:String; // Имя задания
    Status:integer; // Статус задания, см константы stNone,stRuning,stWaiting
    LastResult:integer; // Результат последнего выполнения true-ok false-ошибка
    LastRunDate:TDateTime; // Дата и время последнего запуска задания
    SorPath: String; // каталг источник
    DestPath: String; // каталог приемник
    Action:integer; // действие
    MailAlert: integer; // Уведомления по почте
    Rasp:TRasp; // Расписание
    Arh:TArh; // параметры архива
    NTFSPerm:Boolean; // Копировать права NTFS
    ExtProgs:TExtProgs; // Внешние программы
    SourceFilt:TSourceFilt; // условия фильтрации файлов и папок источника
   end;

type
  TTaskCl = class
  Tasks: array[1..MaxTasks] of TTask; //Массив заданий
//  ZipMaster:TZipMaster;
//  procedure OnProgress; // Событие
  procedure AddTask;
  procedure DelTask (numTask:integer);
  procedure LoadFromFile(filenam:string);
  procedure SaveToFile (filenam:string);
  function RunTask(num:integer; countsize:boolean):integer;
  function  FindTaskSt (state:integer):integer;
 // procedure RunThTask(num:integer);
  function SyncFiles(sorfile,destfile:string;NTFSCopy:Boolean;recurse:Boolean):Boolean;
//  procedure SyncFiles(sorfile,destfile:string;NTFSCopy:Boolean);
  function CopyNTFSPerm(sorfile,destfile:string):Boolean;
  function NTSetPrivilege(sPrivilege: string; bEnabled: Boolean): Boolean;
 // function SyncDirs(dir,syncdir:string;TypeSync:Integer;NTFSCopy:Boolean;Recurse:Boolean):boolean;

  function CheckFileMask(FileName:string;NumTask:integer):Boolean;
  function CheckSubDir(SubDir:string;NumTask:integer):Boolean;
  //  procedure SyncDirs(dir,syncdir:string;Sync:Boolean);
  procedure DelDirs(dir:string);
  procedure LogMessage(logmes:string);
  procedure WriteFileStr(filenam,str:string);
  //function ArhDir(sourdir,destdir:string;arhname:string):boolean;
  function ArhRarDir(NumTask:integer):integer;
  function BuildRarFileList(NumTask:integer):string;
  function ArhZipDir(numtask:integer):integer;
  procedure GetFileList(sordir:string;NumTask:integer;var FileList:TStrings;recurse:boolean;ForZip:Boolean);
  function GetArhName(numtask:integer;ext:string):string;
  procedure DelOldArhs(NumTask:integer);
//  procedure DelOldArhs(dir,arhname:string;olddays,oldMonths,OldYears:integer);
//  function WinExecute(CmdLine: string; Wait: Boolean): Boolean;
  function WinExec(const FileName, Param: String; const Wait:boolean; const WinState: Word): boolean;
  procedure DelFile(namef:string);
  //function  GetFileNam(shortnam:String):String;
  procedure DublicateTask(NumTask:integer);
  //procedure TaskCopy(NumTask:integer);
  procedure CopyTask (FromTask,ToTask:integer);
  procedure UpTask (NumTask:integer);
  procedure DownTask (NumTask:integer);  
  function GetSizeDir(dir,syncdir:string;NumTask:integer;Recurse:Boolean):integer;
  procedure ReplaceNameDisk(NumTask:integer;replace:boolean);
  function ShortFileNam(FileName:String):string;
  function FullFileNam(FileName:String):string;
  function CryptStr(Str:string):string;
  function DecryptStr(Str:string):string;


  procedure Clear; // Очистка списка заданий
  procedure ReadIni;
  procedure SaveIni;
  function ReadArgv(var IsProfile:boolean) :Boolean;
  function GetVer:String;

//  procedure SendMail(MesSubject:string;MesBody:TStrings);
//  procedure StrToList (Str:string;var StrList:StringList);
 private
  function CompareFileDate (aDate,bDate:integer):boolean;
  procedure SaveToXMLFile (filenam:string);
  procedure LoadFromXMLFile(filenam:string);
  function HexStrToInt(Str:String;Pos:integer):integer;

  function ReplDate(S:string):string;
  function FindStrVar (S:string):string;
//  function FileInFilenameMasks(const Filename, Masks: string): boolean;
//  function TrimFilename(const AFilename: string): string;
  function CopyDirs(dir,syncdir:string;NumTask:integer;Recurse:Boolean;countsize:boolean):integer;
  TotalSize:int64; // Общий размер файлов при копировании
  TempSorPath,TempDestPath:string; // Временное хранение источника и приемника для перобразования %disk%

 public

  // Эта функция не определяется в этом файле
  OnProgress: TProgressEvent; // Процедура события обновления %
  //----
  // Параметры запуска
  ParamQ:Boolean; // -q  В строке запуска есть команда выхода по окончании
  //---
  Count:integer; //Количество заданий
  //----
  // Настройки из ini файла
  logfile:string; // Имя лог файла короткое
  loglimit:integer; // ограничение лог файла в килобайтах
  LangFile:string; // Имя языкового файла

  LoadLastProf:Boolean; // загружать последний профиль
  DefaultProf:string; // профиль по умолчанию при запуске программы
  profile:string; // имя файла текущего профайла
  // Настройки уведомлений по почте
  email:string; // почтовый ящик на который отсылаются уведомления
//  alerttype:integer; // Тип уведомлений (нет, ошибки, всегда, см константы)
  smtpserv:string; // Адрес smtp сервера
  smtpport:integer; // порт сервера
  smtpuser:string; // Пользователь сервера
  smtppass:string; // Пароль
  mailfrom:string; // Почт адрес от имени которого высылаются уведомления
  //------

//  ProfPath:String; // Текущее имя файла профайла
//  ProfName:String; // Наименование профайла



 end;
{
type Tprob=record
 // begin
  Name:string;
  end;
 }
implementation
uses msgstrings,SendMailUnit ;
//=====================================================
// Возвращает версию программы
function TTaskCl.GetVer:String;
begin
Result:=VersionAS;
end;
//=====================================================
// Чтение настроек программы из Ini файла
procedure TTaskCl.ReadIni;
//===================================================
 var
  SaveIniFile: TIniFile;
  IniName: String;
begin
IniName:=FullFileNam('autosave.ini');// ExtractFileDir(ParamStr(0))+'\'+'autosave.ini';

SaveIniFile := TIniFile.Create(IniName);
logfile:=SaveIniFile.ReadString('log', 'logfile', 'autosave.log');

loglimit:=SaveIniFile.ReadInteger('log', 'loglimit', 500);
//IsClosing:=SaveIniFile.ReadBool('common', 'MinimizeToTray',true);
//AutoOnlyClose:=SaveIniFile.ReadBool('common', 'AutoOnlyClose',false);
//StartMin:=SaveIniFile.ReadBool('common', 'StartMinimized',false);
// Язык
LangFile:=SaveIniFile.ReadString('Language', 'LangFile', 'english.lng');

// настройка профилией
LoadLastProf:=SaveIniFile.ReadBool('profile', 'LoadLastProf',false); // загружать последний профиль
DefaultProf:=SaveIniFile.ReadString('profile', 'DefaultProf', 'default.xml');
profile:=DefaultProf;

email:=SaveIniFile.ReadString('alerts', 'email', 'your@email');
//alerttype:=SaveIniFile.ReadInteger('alerts', 'alerttype', alertNone);
smtpserv:=SaveIniFile.ReadString('alerts', 'smtpserv', 'smtp.server');
smtpport:=SaveIniFile.ReadInteger('alerts', 'smtpport', 25);
//smtpuser:=SaveIniFile.ReadString('alerts', 'smtpuser', 'login');
//smtppass:=DecryptStr(SaveIniFile.ReadString('alerts', 'smtppass', ''));
mailfrom:=SaveIniFile.ReadString('alerts', 'mailfrom', 'from@mail');

//TrayIcon.MinimizeToTray:=IsClosing;
//TrayIcon.IconVisible:=IsClosing;
//IsClosing:=Not (IsClosing);
SaveIniFile.Destroy;// Free;
end;
//=====================================================
// Запись значений в Ini файл
procedure TTaskCl.SaveIni;
 var
  SaveIniFile: TIniFile;
  cr:string;
  IniName,dp: String;
begin
IniName:= ExtractFileDir(ParamStr(0))+slash+'autosave.ini';
SaveIniFile := TIniFile.Create(IniName);
SaveIniFile.WriteString('log', 'logfile',logfile);
SaveIniFile.WriteInteger('log', 'loglimit',loglimit);


SaveIniFile.WriteString('alerts', 'email', email);
//SaveIniFile.WriteInteger('alerts', 'alerttype', alerttype);
SaveIniFile.WriteString('alerts', 'smtpserv', smtpserv);
SaveIniFile.WriteInteger('alerts', 'smtpport', smtpport);
//SaveIniFile.WriteString('alerts', 'smtpuser', smtpuser);
//cr:=CryptStr(smtppass);
//SaveIniFile.WriteString('alerts', 'smtppass', CryptStr(smtppass));
SaveIniFile.WriteString('alerts', 'mailfrom', mailfrom);

// Язык
SaveIniFile.WriteString('Language', 'LangFile', LangFile);

SaveIniFile.WriteBool('profile', 'LoadLastProf',LoadLastProf);
dp:=DefaultProf;
if LoadLastProf then dp:=profile;
SaveIniFile.WriteString('profile', 'DefaultProf',dp);
SaveIniFile.Destroy;// Free;
end;

//=======================================================
// Чтение командной строки
// Загружает нужный профиль и
// Возвращает true если нужно запускать задания из этого профиля
// IsProfile - true-обработка профиля, иначе задача задана из командной строки
function TTaskCl.ReadArgv(var IsProfile:boolean) :Boolean;
//=====================================================
var
 j,i,k:integer;
 s,p:string;
 sour,dest:string; // Источник, получатель
 act:integer; // действие
 recurs:boolean; // Обрабатывать рекурсивно
 alertmes:string;//TStrings;
 SendMail:TSendMail;
// est:boolean;
 estp:boolean; // Есть профиль на загрузку
 estr:boolean; // Есть параметр /r
begin
//alertmes:='';TStringList.Create;
j:=paramcount; // Кол-во параметров командной строки
ParamQ:=false; // Есть параметр закрыть прогу
sour:='';// Источник и приемник не указаны
dest:='';
recurs:=false;
act:=0; // Действие не указано
estp:=false;
IsProfile:=false;
estr:=false;
Clear; //Count:=0;
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
    AlertMes:= misc(rsAlertRunMes,'rsAlertRunMes');
    SendMail:=TSendMail.Create;
    SendMail.Send(smtpserv,smtpport,mailfrom,email,misc(rsAlertRunSubj,'rsAlertRunSubj'),AlertMes,'');
    SendMail.Destroy;
//    TaskCl.SendMail(misc(rsAlertRunSubj,'rsAlertRunSubj'),AlertMes);
    end;
  if SameText(s,'-p') then // загрузка профиля
    begin
//    i:=i+1;
    if i+1<=j then p:=ParamStr(i+1)
      else continue;
    Clear; //Count:=0;
    LoadFromFile(p);
    estp:=true;
    IsProfile:=true;
    end;
  if SameText(s,'-log') then // Указание лог файла
    begin
    if i+1<=j then p:=ParamStr(i+1)
      else continue;
    logfile:=p;
    end;
//--------
  if SameText(s,'-source') then // Указание источника
    begin
    if i+1<=j then p:=ParamStr(i+1)
      else continue;
    sour:=p;
    end;
//--------
  if SameText(s,'-recurse') then // Указание действия copy
    begin
    recurs:=true;
    end;

//--------
  if SameText(s,'-dest') then // Указание получателя
    begin
    if i+1<=j then p:=ParamStr(i+1)
      else continue;
    dest:=p;
    end;
//--------
  if SameText(s,'copy') then // Указание действия copy
    begin
    act:=ttCopy;
    end;
//--------
  if SameText(s,'sync') then // Указание действия sync
    begin
    act:=ttSync;
    end;
//--------
  if SameText(s,'mirr') then // Указание действия mirr
    begin
    act:=ttZerk;
    end;

  end;

if not estp then // профиля на загрузку нет берем дефолтовый
  begin
  if act=0 then // действие не указано берем дефолтовый профиль
     begin
     LoadFromFile('');
     IsProfile:=true;
     end
    else  // строим задание из параметров запуска
     begin
       if (Length(sour)<>0) and (Length(dest)<>0) then
           begin
             Clear;
             AddTask;
             Tasks[1].Name:='Cmd';
             Tasks[1].Action:=act;
             Tasks[1].SorPath:=sour;
             Tasks[1].DestPath:=dest;
             Tasks[1].SourceFilt.Recurse:=recurs;
             estr:=true;
           end;

     end;
  end;

//MForm.Caption:='AutoSave '+TaskCl.profile;
// Если есть параметр /r запуск заданий
{
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
 }
Result:=estr; // Есть ли задания на запуск
//alertmes.Destroy;// Free;
end;



//================================================================
// добавление пустого задания в массив
procedure TTaskCl.AddTask;
begin
// Найти свободный элемент
if count=MaxTasks then exit;
inc(count);
Tasks[count].Name:='';
Tasks[count].SorPath:='';
Tasks[count].DestPath:='';
Tasks[count].Action:=0;
Tasks[count].Arh.Name:='arh%YYMMDD%';
//Tasks[count].Rasp.Time:=GetLocalTime;
Tasks[count].Rasp.Time:=Time;
//GetLocalTime(Tasks[count].Rasp.Time);
Tasks[count].Rasp.EvMinutes:=false;
Tasks[count].Rasp.Minutes:=60;
Tasks[count].Enabled:=true;
Tasks[count].Rasp.Manual:=true;
Tasks[count].Rasp.AtStart:=false;
Tasks[count].Rasp.AtTime:=false;
Tasks[count].Arh.DelOldArh:=false;
Tasks[count].Arh.DaysOld:=7;
Tasks[count].Arh.MonthsOld:=12;
Tasks[count].Arh.YearsOld:=5;
Tasks[count].Enabled:=true;
Tasks[count].Status:=stNone;
Tasks[count].LastRunDate:=0;
Tasks[count].LastResult:=trOk;
Tasks[count].ExtProgs.BeforeStart:=false;
Tasks[count].ExtProgs.BeforeName:='';
Tasks[count].ExtProgs.AfterStart:=false;
Tasks[count].ExtProgs.AfterName:='';
Tasks[count].NTFSPerm:=false;
Tasks[count].MailAlert:=0;

Tasks[count].SourceFilt.Recurse:=true;
Tasks[count].SourceFilt.FiltSubDir:=false;
Tasks[count].SourceFilt.SubDirs:=TStringList.Create;
Tasks[count].SourceFilt.SubDirs.Delimiter:=';';
//Tasks[count].SourceFilt.SubDirs.Clear;
Tasks[count].SourceFilt.FiltFiles:=false;
Tasks[count].SourceFilt.ModeFiltFiles:=0;
Tasks[count].SourceFilt.FileMask:=TStringList.Create;
Tasks[count].SourceFilt.FileMask.Delimiter:=';';
Tasks[count].SourceFilt.FileMask.Add('*.tmp');
Tasks[count].SourceFilt.FileMask.Add('*.bak');
end;
//============================================================
// Очистка списка заданий
procedure TTaskCl.Clear;
var
 i:integer;
begin
for i:=1 to count do
    begin
    Tasks[i].SourceFilt.SubDirs.Destroy;
    Tasks[i].SourceFilt.FileMask.Destroy;
    end;
count:=0;
end;
//=========================================================
// Поиск задания со статусом state, возвращает его номер
// Если не найдено возварщается -1
// Находит первое попавшееся задание с таким статусом
function TTaskCl.FindTaskSt (state:integer):integer;
var
 i:integer;
begin
Result:=-1;
for i:=1 to count do
  begin
   if Tasks[i].Status=state then
     begin
      Result:=i;
      break;
     end;
  end;
end;
//=========================================================
// Удаление из набора задния NumTask
procedure TTaskCl.DelTask (numTask:integer);
var
 i:integer;
begin
if numTask>count then exit;
if numTask<1 then exit;
for i:=numTask+1 to count do
 begin
   CopyTask(i,i-1);

   //Tasks[i-1]:=Tasks[i];
   {
    Tasks[i-1].Enabled:=Tasks[i].Enabled; // задание разрешено
    Tasks[i-1].Name:=Tasks[i].Name;
    Tasks[i-1].Status:=Tasks[i].Status;
    Tasks[i-1].LastResult:=Tasks[i].LastResult;
    Tasks[i-1].LastRunDate:=Tasks[i].LastRunDate;
    Tasks[i-1].SorPath:=Tasks[i].SorPath;
    Tasks[i-1].DestPath:=Tasks[i].DestPath;
    Tasks[i-1].Action:=Tasks[i].Action;
    Tasks[i-1].Rasp:=Tasks[i].Rasp;
    Tasks[i-1].Arh:=Tasks[i].Arh;
    Tasks[i-1].NTFSPerm:=Tasks[i].NTFSPerm;
    Tasks[i-1].ExtProgs:=Tasks[i].ExtProgs;

    Tasks[i-1].SourceFilt.Recurse:=Tasks[i].SourceFilt.Recurse;
    Tasks[i-1].SourceFilt.FiltSubDir:=Tasks[i].SourceFilt.FiltSubDir;
    Tasks[i-1].SourceFilt.FiltFiles:=Tasks[i].SourceFilt.FiltFiles;
    Tasks[i-1].SourceFilt.ModeFiltFiles:=Tasks[i].SourceFilt.ModeFiltFiles;
    Tasks[i-1].SourceFilt.SubDirs.Assign(Tasks[i].SourceFilt.SubDirs);
    Tasks[i-1].SourceFilt.FileMask.Assign(Tasks[i].SourceFilt.FileMask);
    }
 end;
Tasks[count].SourceFilt.SubDirs.Free;
Tasks[count].SourceFilt.FileMask.Free;
dec(count);
end;
//==================================================
//   Копирование задания с номером FromTask в задание с номером ToTask
//--------------------------------------------------------------------
procedure TTaskCl.CopyTask (FromTask,ToTask:integer);
begin
if (FromTask>count) OR (ToTask>count) then exit;
    Tasks[ToTask].Enabled:=Tasks[FromTask].Enabled; // задание разрешено
    Tasks[ToTask].Name:=Tasks[FromTask].Name;
    Tasks[ToTask].Status:=Tasks[FromTask].Status;
    Tasks[ToTask].LastResult:=Tasks[FromTask].LastResult;
    Tasks[ToTask].LastRunDate:=Tasks[FromTask].LastRunDate;
    Tasks[ToTask].SorPath:=Tasks[FromTask].SorPath;
    Tasks[ToTask].DestPath:=Tasks[FromTask].DestPath;
    Tasks[ToTask].Action:=Tasks[FromTask].Action;
    Tasks[ToTask].Rasp:=Tasks[FromTask].Rasp;
    Tasks[ToTask].Arh:=Tasks[FromTask].Arh;
    Tasks[ToTask].NTFSPerm:=Tasks[FromTask].NTFSPerm;
    Tasks[ToTask].ExtProgs:=Tasks[FromTask].ExtProgs;

    Tasks[ToTask].SourceFilt.Recurse:=Tasks[FromTask].SourceFilt.Recurse;
    Tasks[ToTask].SourceFilt.FiltSubDir:=Tasks[FromTask].SourceFilt.FiltSubDir;
    Tasks[ToTask].SourceFilt.FiltFiles:=Tasks[FromTask].SourceFilt.FiltFiles;
    Tasks[ToTask].SourceFilt.ModeFiltFiles:=Tasks[FromTask].SourceFilt.ModeFiltFiles;
    Tasks[ToTask].SourceFilt.SubDirs.Assign(Tasks[FromTask].SourceFilt.SubDirs);
    Tasks[ToTask].SourceFilt.FileMask.Assign(Tasks[FromTask].SourceFilt.FileMask);
end;
//==================================================
//   Поднять задание вверх по списку
//--------------------------------------------------------------------
procedure TTaskCl.UpTask (NumTask:integer);
begin
if NumTask<=1 then exit;
AddTask;
CopyTask (NumTask,count);
CopyTask (NumTask-1,NumTask);
CopyTask (count,NumTask-1);
DelTask(count);
end;
//==================================================
//   Опустить задание вниз по списку
//--------------------------------------------------------------------
procedure TTaskCl.DownTask (NumTask:integer);
begin
if NumTask>count-1 then exit;
AddTask;
CopyTask (NumTask,count);
CopyTask (NumTask+1,NumTask);
CopyTask (count,NumTask+1);
DelTask(count);
end;
//=================================================
// Разбивает строку по ";" на список строк StringList
//procedure TTaskCl.StrToList (Str:string;var StrList:StringList);
//begin
//StrList.
//end;
//=================================================
// Запуск внешнего приложения и ожидание его завершения
// wait =true - ждать, false - не ждать

{
function TTaskCl.WinExecute(CmdLine: string; Wait: Boolean): Boolean;
var
StartupInfo: TStartupInfo;
ProcessInformation: TProcessInformation;
buf: array [0..MaxPChar] of char;

begin
Result := True;
try
FillChar(StartupInfo, SizeOf(StartupInfo), 0);
StartupInfo.cb := SizeOf(StartupInfo);

//CmdLine:=AnsiToUtf8(CmdLine);
buf:=CmdLine; // Для преоборазования к PChar
//PCmdLine:=^CmdLine;
//if not CreateProcess(nil, PChar(CmdLine), nil, nil, True, 0, nil,nil,StartupInfo, ProcessInformation) then RaiseLastWin32Error;
if not CreateProcess(nil, buf, nil, nil, True, 0, nil,nil,StartupInfo, ProcessInformation) then RaiseLastOSError;

if Wait then WaitForSingleObject(ProcessInformation.hProcess,INFINITE);
except
Result := False;
end;
end;
}
//-------------------------------------------------------------------------
{Запуск программы с ожиданием или без
Параметр FileName = Имя внешней программы.
Параметр Params = Параметры, необходимые для запуска внешней программы
Wait - ожидать
Параметр WinState = Указывает - как будет показано окно:
Для этого параметра мы можем так же использовать следующие константы:
SW_HIDE, SW_MAXIMIZE, SW_MINIMIZE, SW_SHOWNORMAL

}
function TTaskCl.WinExec(const FileName, Param: String; const Wait:boolean; const WinState: Word): boolean;
var
  StartInfo: TStartupInfo;
  ProcInfo: TProcessInformation;
  CmdLine: string;
  buf: array [0..MaxPChar] of char;
begin
  { Помещаем имя файла между кавычками, с соблюдением всех пробелов в именах Win9x }
  CmdLine := '"' + Filename + '" ' + Param;
  buf:=CmdLine; // Для преоборазования к PChar
  FillChar(StartInfo, SizeOf(StartInfo), #0);
  with StartInfo do
  begin
    cb := SizeOf(StartInfo);
    dwFlags := STARTF_USESHOWWINDOW;
    wShowWindow := WinState;
  end;
  Result := CreateProcess(nil, PChar(buf), nil, nil, false,
//  Result := CreateProcess(nil, PChar(CmdLine), nil, nil, false,
                          CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil,
                          PChar(ExtractFilePath(Filename)),StartInfo,ProcInfo);
  { Ожидаем завершения приложения }
  if Result and Wait then
  begin
    WaitForSingleObject(ProcInfo.hProcess, INFINITE);
    { Free the Handles }
    CloseHandle(ProcInfo.hProcess);
    CloseHandle(ProcInfo.hThread);
  end;
end;



//==================================================
// Функция запуска задания
function TTaskCl.RunTask(num:integer; countsize:boolean):integer;
var
  AlertMes:string;// TStrings; // Сообщение высылаемое на почту
  str,subj:string;
  AlertType:integer; // Тип уведомлений на почту
  SendMail:TSendMail;
// ShowProc:
//var
// ResName:string;
begin
AlertMes:='';//TStringList.Create;
//ShowProc(1);
Result:=trOk;
if num>count then exit;
if num<1 then exit;
   LogMessage('-');
   LogMessage(misc(rsLogRunTask,'rsLogRunTask')+': '+Tasks[num].Name);
   alertMes:=alertMes+(misc(rsAlert,'rsAlert')+ ' '+Tasks[num].Name)+#13#10;
   ReplaceNameDisk(num,true);
   if Tasks[num].ExtProgs.BeforeStart then // Запуск внешней программы до задания
      begin
      if FileExists(Tasks[num].ExtProgs.BeforeName) then
        begin
         LogMessage(misc(rsLogExtProgRun,'rsLogExtProgRun')+ ' '+Tasks[num].ExtProgs.BeforeName);
         WinExec(Tasks[num].ExtProgs.BeforeName,'', true,SW_SHOWNORMAL);
         LogMessage(misc(rsLogExtProgEnd,'rsLogExtProgEnd'));
        end
       else
        begin // файл с внешней прогой не найден
         str:=format(misc(rsLogExtProgErr,'rsLogExtProgErr'),[Tasks[num].ExtProgs.BeforeName]);
         LogMessage(str);
         AlertMes:=alertMes+str+#13#10;
        end;
      end;

   if Tasks[num].Action=ttCopy then // Копирование
     begin
     str:=Format(misc(rsLogCopy,'rsLogCopy'),[Tasks[num].SorPath,Tasks[num].DestPath]);
     LogMessage(str);
     Result:=CopyDirs(Tasks[num].SorPath,Tasks[num].DestPath,num,false,Countsize);
     //Result:=SyncDirs(Tasks[num].SorPath,Tasks[num].DestPath,0,Tasks[num].NTFSPerm,false);
     Tasks[num].LastResult:=Result;
     Tasks[num].LastRunDate:=Now;
     end;
   if Tasks[num].Action=ttSync then // Синхронизирование
     begin
     str:=Format(misc(rsLogSync,'rsLogSync'),[Tasks[num].SorPath,Tasks[num].DestPath]);
     LogMessage(str);
     Result:=CopyDirs(Tasks[num].SorPath,Tasks[num].DestPath,num,false,Countsize);
     Tasks[num].LastResult:=Result;
     Tasks[num].LastRunDate:=Now;
     end;
   if Tasks[num].Action=ttZerk then // Зеркалирование
     begin
     str:=Format(misc(rsLogMirror,'rsLogMirror'),[Tasks[num].SorPath,Tasks[num].DestPath]);
     LogMessage(str);
     Result:=CopyDirs(Tasks[num].SorPath,Tasks[num].DestPath,num,false,Countsize);
     Tasks[num].LastResult:=Result;
     Tasks[num].LastRunDate:=Now;
     end;
   if Tasks[num].Action=ttArhRar then // Архивирование Rar
     begin
     str:=Format(misc(rsLogArcRar,'rsLogArcRar'),[Tasks[num].SorPath,Tasks[num].DestPath]);
     LogMessage(str);
     Result:=ArhRarDir(num);
     Tasks[num].LastResult:=Result;
     Tasks[num].LastRunDate:=Now;
     end;
   if Tasks[num].Action=ttArhZip then // Архивирование Zip
     begin
     str:=Format(misc(rsLogArcZip,'rsLogArcZip'),[Tasks[num].SorPath,Tasks[num].DestPath]);
     LogMessage(str);
     Result:=ArhZipDir(num);
     end;

   if Tasks[num].ExtProgs.AfterStart then // Запуск внешней программы после задания
      begin
      if FileExists(Tasks[num].ExtProgs.AfterName) then
        begin
         LogMessage(misc(rsLogExtProgRun,'rsLogExtProgRun')+ ' '+Tasks[num].ExtProgs.AfterName);
         WinExec(Tasks[num].ExtProgs.AfterName,'', true,SW_SHOWNORMAL);
         LogMessage(misc(rsLogExtProgEnd,'rsLogExtProgEnd'));
        end
       else
        begin // файл с внешней прогой не найден
         str:=format(misc(rsLogExtProgErr,'rsLogExtProgErr'),[Tasks[num].ExtProgs.AfterName]);
         LogMessage(str);
         AlertMes:=AlertMes+str+#13#10;
        end;
      end;


   Tasks[num].LastResult:=Result;
   Tasks[num].LastRunDate:=Now;
   ReplaceNameDisk(num,false);
   LogMessage(misc(rsLogTaskEnd,'rsLogTaskEnd'));
   if Tasks[num].LastResult=trOk then
       begin
       str:=Format(misc(rsLogTaskEndOk,'rsLogTaskEndOk'),[Tasks[num].Name]);
       AlertMes:=AlertMes+str+#13#10;
       end
     else
       begin
       str:=Format(misc(rsLogTaskEndErr,'rsLogTaskEndErr'),[Tasks[num].Name]);
       AlertMes:=AlertMes+str+#13#10;
       end;
AlertType:=Tasks[num].MailAlert;
if AlertType>0 then
begin
   // Создаем объект

   SendMail:=TSendMail.Create;
   // Создаем тему письма
//   trOk=0; // Все ок
//  trError=1; // Ошибка запуска задания (недоступен каталог)
//  trFileError=2; // Ошибка копирования файла в задании
   case Result of
   trOk:
      subj:=misc(rsAlertSubjOk,'rsAlertSubjOk')+' '+Tasks[num].Name;

   trError:
       subj:=misc(rsAlertSubjErr,'rsAlertSubjErr')+' '+Tasks[num].Name;

   trFileError:
      subj:=misc(rsAlertSubjWarn,'rsAlertSubjWarn')+' '+Tasks[num].Name;

   end;
   if (AlertType=alertErr) and (Result=trOk) then exit;
   SendMail.Send(smtpserv,smtpport,mailfrom,email,subj,AlertMes,'')
   {
   case Alerttype of
   alertErr:
        if NOT Result=trOk then SendMail.Send(smtpserv,smtpport,mailfrom,email,subj,AlertMes,'');
   alertAlways:
        SendMail.Send(smtpserv,smtpport,mailfrom,email,subj,AlertMes,'')
   end;
   }
end;

 //  end;

//AlertMes.Free;
end;
//=========================================================
//Получение имени архива ext-расширение файла (.zip,.rar)
function TTaskCl.GetArhName(numtask:integer;ext:string):string;
var
 ResName:string;
// SorPath,DestPath:String;
begin
//SorPath:=ReplaceNameDisk(Tasks[numtask].SorPath);
//DestPath:=ReplaceNameDisk(Tasks[numtask].DestPath);

//DateTimeToString(ResName,'YYMMDD',Now);
ResName:=ReplDate(Tasks[numtask].Arh.Name); // Замена спец символов на дату
//ResName:=Tasks[numtask].DestPath+slash+Tasks[numtask].Arh.Name+ResName+ext;
ResName:=Tasks[numtask].DestPath+slash+ResName+ext;
{
if FileExists(ResName) then // архивация уже выполнялась в этот день
   begin
   DateTimeToString(ResName,'YYMMDDHHMM',Now);
   ResName:=Tasks[numtask].DestPath+slash+Tasks[numtask].Arh.Name+ResName+ext;
   end;
   }
Result:=ResName;
end;
//------------------------------------------------------------------------
{Замена всяких символов типа %date% в строке на текущую дату}
function TTaskCl.ReplDate(S:string):string;
var
 dt:TDateTime;
 str,str2,strdate:string;
begin
dt:=Now;
str:=FindStrVar (S);
while str<>'' do
begin
str2:='%'+str+'%';
DateTimeToString(strdate,str,dt);
s:=StringReplace(s,str2,strdate,[rfReplaceAll, rfIgnoreCase]);
str:=FindStrVar (S);
end;
Result:=s;
end;
//-----------------------------------------------------------------------
{Поиск в строке первой подстроки типа %yyyy% и возвращение ее содержимого без %%}
function TTaskCl.FindStrVar (S:string):string;
var
 i,j:integer;
begin
Result:='';
if s='' then exit;
i:=Pos('%',S); // Первый символ %
if i=0 then exit;
j:=PosEx('%',S,i+1); // Второй символ %
if j=0 then exit;
Result:=MidStr(S,i+1,j-i-1); // Строка между %
end;
//-----------------------------------------------------------------------

//==========================================================
// Постороение списка файлов для архивации зип
procedure TTaskCl.GetFileList(sordir:string;NumTask:integer;var FileList:TStrings;recurse:boolean;ForZip:Boolean);
var
  sr: TSearchRec;
  FileAttrs: Integer;
begin
if recurse AND Not Tasks[NumTask].SourceFilt.Recurse then exit; // подкаталоги не обрабатывать
if Not Tasks[NumTask].SourceFilt.FiltSubDir AND Not Tasks[NumTask].SourceFilt.FiltFiles then // нет исключений
    begin
    if Tasks[NumTask].SourceFilt.Recurse then
      FileList.Add('>'+Tasks[numtask].SorPath+slash+'*') // рекурсивно
     else
      FileList.Add(Tasks[numtask].SorPath+slash+'*'); // не рекурсивно
    exit;
    end;
FileAttrs := faReadOnly+ faHidden+ faSysFile+ faArchive+ faAnyFile;
// сначала файлы
if FindFirst(sordir+slash+'*', FileAttrs, sr) = 0 then
    begin
      repeat
        begin
      if CheckFileMask(sr.Name,NumTask) then // Проверка файла на маску
        begin
        if ForZip then FileList.Add(sordir+slash+sr.Name);// для зип
        end// if checkfilemask
       else
         if Not ForZip then FileList.Add(sordir+slash+sr.Name); // для рар
        end;
      until FindNext(sr) <> 0;
      FindClose(sr);
    end;
// потом директории
FileAttrs := faDirectory+faReadOnly+ faHidden+ faSysFile+ faArchive;
if FindFirst(sordir+slash+'*', FileAttrs, sr) = 0 then
    begin
      repeat
        if (sr.Attr and faDirectory	) <>0 then
        begin
          if not SameText(sr.Name,'.') and not SameText(sr.Name,'..') then
           begin
           if CheckSubDir(sordir+slash+sr.Name,NumTask) then
              begin
             // if ForZip then
                GetFileList(sordir+slash+sr.Name,NumTask,FileList,true,ForZip);
              end
            // else
            //  if Not ForZip then GetFileList(sordir+'\'+sr.Name,NumTask,FileList,true,ForZip);
           end;
        end;
      until FindNext(sr) <> 0;
      FindClose(sr);
    end;
end;
//===========================================================
// Архивация директории zip
function TTaskCl.ArhZipDir(numtask:integer):integer;
var
 zipfname,str:string;
 FileList:TStrings;
// SorPath,DestPath:String;
// runstr:string;
begin
//SorPath:=ReplaceNameDisk(Tasks[numtask].SorPath);
//DestPath:=ReplaceNameDisk(Tasks[numtask].DestPath);
{
FileList:=TstringList.Create;
// Проверка существования каталогов источника и приемника
if NOT DirectoryExists(Tasks[numtask].SorPath) then
  begin
  str:=Format(misc(rsLogDirNotFound,'rsLogDirNotFound'),[Tasks[numtask].SorPath]);
  LogMessage(str);
  Result:=trError;
  exit;
  end;
if NOT DirectoryExists(Tasks[numtask].DestPath) then // каталог приемник не существует
  begin
  if ForceDirectories(Tasks[numtask].DestPath) then // он успешно создан
    begin
    str:=Format(misc(rsLogDirCreated,'rsLogDirCreated'),[Tasks[numtask].DestPath]);
    LogMessage(str);
    end
   else
    begin
     str:=Format(misc(rsLogDirNotFound,'rsLogDirNotFound'),[Tasks[numtask].DestPath]);
     LogMessage(str);
     Result:=trError;
     exit;
    end;
  end;
//ZipMaster:=TZipMaster.Create(nil);
//ZipMaster.DLLDirectory:='.';
// Загрузка zip dll
try
//ZipMaster.Dll_Load:=true;
//except
//  LogMessage(misc(rsLogNoZipDll,'rsLogNoZipDll'));
//  Result:=trError;
//  exit;
end;
// Построение списка файлов
//---------------------------------------------------
//GetFileList(Tasks[numtask].SorPath,NumTask,FileList,false,True);
//ZipMaster.FSpecArgs.Assign(FileList);
//--------------------------------------------------
ZipMaster.OnProgress:=OnProgress;
//Имена файлов для добавления

zipfname:=GetArhName(numtask,'.zip');
// имя архива
ZipMaster.ZipFileName:=zipfname;
// Параметры архивирования
ZipMaster.AddOptions:=[AddDirNames,AddHiddenFiles];
// Создание списка файлов

// архивирование
FileList.Free;
if ZipMaster.Add=0 then // успешно создан архив
 begin
 str:=Format(misc(rsLogArcCreated,'rsLogArcCreated'),[zipfname]);
 LogMessage(str);
 Result:=trOk;
 end
else
  begin
  str:=Format(misc(rsLogArcErr,'rsLogArcErr'),[zipfname]);
  LogMessage(str);
  Result:=trError;
  end;
ZipMaster.Dll_Load:=false;
ZipMaster.Free;
// Удаление старых архивов
//if Tasks[numtask].Arh.DelOldArh then
DelOldArhs(numtask);
//Result:=true;
}
end;
//==========================================================
// Создание файла исключений, генерация командной строки для архивации rar
function TTaskCl.BuildRarFileList(NumTask:integer):string;
var
 FileList:TStrings;
 tmpfile:string;
 res:string;
 //SorPath, DestPath:String;

 i:integer;
 //  sr: TSearchRec;
//  FileAttrs: Integer;
begin
//SorPath:=ReplaceNameDisk(Tasks[numtask].SorPath);
//DestPath:=ReplaceNameDisk(Tasks[numtask].DestPath);
//if Not Tasks[NumTask].SourceFilt.Recurse then exit; // подкаталоги не обрабатывать
if Not Tasks[NumTask].SourceFilt.FiltSubDir AND Not Tasks[NumTask].SourceFilt.FiltFiles then // нет исключений
    begin
    if Tasks[NumTask].SourceFilt.Recurse then
      Result:=' -r' // рекурсивно
     else
      Result:=''; // не рекурсивно
    exit;
    end;
FileList:=TStringList.Create;
if Tasks[NumTask].SourceFilt.Recurse then
    res:=' -r '
   else
    res:='';
// исключение файлов
if Tasks[NumTask].SourceFilt.FiltFiles then
 begin
  GetFileList(Tasks[numtask].SorPath,NumTask,FileList,false,false);
  tmpfile:=ExtractFileDir(ParamStr(0))+slash+'tmp.txt';
  //tmpfile:='tmp.txt';
  FileList.SaveToFile(tmpfile);
  res:=res+' -x@"'+tmpfile+'" ';
 end;
 // Исключение директорий
if Tasks[NumTask].SourceFilt.FiltSubDir then
 begin
for i:=0 to Tasks[NumTask].SourceFilt.SubDirs.Count-1 do
       begin
        res:=res+' -x\""'+Tasks[numtask].SorPath+slash+Tasks[NumTask].SourceFilt.SubDirs[i]+'"" ';
       end;
 end;
//tmpfile:=ExtractFileDir(ParamStr(0))+'\tmp.txt';
FileList.SaveToFile(tmpfile);
//res:=res+' -r ';
//res:=res+' -r –x\@"'+tmpfile+'" ';
Res:=res+' ';
Result:=res;
FileList.Free;
end;
//=====================================================
// Копирование задания
procedure TTaskCl.DublicateTask(NumTask:integer);
begin
// Найти свободный элемент
if count=MaxTasks then exit;
AddTask;
CopyTask (numtask,count);
Tasks[count].Name:=misc(rsCopyPerfix,'rsCopyPerfix')+ ' '+Tasks[numtask].Name;
end;
//===========================================================
// Архивация Rar директории sourdir в директорию destdir
function TTaskCl.ArhRarDir(NumTask:integer):integer;
var
 rarexe,str:string;
 runstr:string;
 arhname:string;
 //SorPath,DestPath:String;
// tmpstr:TStrings;
begin
//SorPath:=ReplaceNameDisk(Tasks[numtask].SorPath);
//DestPath:=ReplaceNameDisk(Tasks[numtask].DestPath);
// Проверка существования каталогов источника и приемника
if NOT DirectoryExists(Tasks[numtask].SorPath) then
  begin
  str:=Format(misc(rsLogDirNotFound,'rsLogDirNotFound'),[Tasks[numtask].SorPath]);
  LogMessage(str);
  Result:=trError;
  exit;
  end;
if NOT DirectoryExists(Tasks[numtask].DestPath) then // каталог приемник не существует
  begin
  if ForceDirectories(Tasks[numtask].DestPath) then // он успешно создан
    begin
    str:=Format(misc(rsLogDirCreated,'rsLogDirCreated'),[Tasks[numtask].DestPath]);
    LogMessage(str);
    end
   else
    begin
     str:=Format(misc(rsLogDirNotFound,'rsLogDirNotFound'),[Tasks[numtask].DestPath]);
     LogMessage(str);
     Result:=trError;
     exit;
    end;
  end;
Result:=trOk;
arhname:=GetArhName(numtask,'.rar');
//rarexe:=Getfilenam('rar.exe');
rarexe:=ExtractFileDir(ParamStr(0))+slash+'rar.exe';
if not FileExists(rarexe) then
  begin
  LogMessage(misc(rsLogRarNotFound,'rsLogRarNotFound'));
  Result:=trError;
  exit;
  end;
//runstr:=rarexe+' a -agYYMMDD -r -dh -ep1 -f -ibck -OW -y '+destdir+'\'+arhname+'.rar '+destdir;

//rarexe:='"'+rarexe+'"';

//runstr:=rarexe+' a -dh -ep1 -u -ibck -y ';
runstr:='a -dh -ep1 -u -ibck -y ';
runstr:=runstr+BuildRarFileList(numtask)+' ';
if Tasks[numtask].NTFSPerm then runstr:=runstr+' -ow '; // NTFS права
runstr:=runstr+arhname+' '+Tasks[numtask].SorPath+slash+'*';
//runstr:=rarexe+' a -r -dh -ep1 -u -ibck -ow -y '+arhname+' '+Tasks[numtask].SorPath;
// a-добавить файлы в архив
// ag - добавить к имени дату
// r- рекурсивно с поддерикториями
// dh-архивировать открытые файлы
// ep1-не добавлять путь в архив
// u-добавлять только изменившиеся файлы
// ibck-фоновый процесс
// OW-сохранять информацию NTFS
// y-да на все запросы
//ShowMessage ('Запуск '+runstr);
//tmpstr:=TStringList.Create;
//tmpstr.Add(runstr);
//tmpstr.SaveToFile('rartmp.bat');
//tmpstr.Free;
//winexec('rartmp.bat', sw_minimize);

//winexec(Pchar(runstr), sw_minimize);

//WinExecute(runstr, false); // Запуск без ожидания завершения


if WinExec(rarexe,runstr,true,SW_SHOWNormal) then  // Запуск с ожиданием
begin
str:=Format(misc(rsLogArcCreated,'rsLogArcCreated'),[arhname]); // Создан архив
  LogMessage(str);
  Result:=trOk;
//  exit;
end
else // Обшибка
begin
 str:=Format(misc(rsLogArcErr,'rsLogArcErr'),[arhname]); // Ошибка создания архива
  LogMessage(str);
  Result:=trError;
//  exit;

end;

//LogMessage('Создан архив '+arhname);
// Удаление старых архивов
//if Tasks[numtask].Arh.DelOldArh then
DelOldArhs(numtask);
end;
//==========================================================
// Удаление файлов архивов в папке dir с именем arhname
// позднее olddays дней
// позднее oldmonths месяцев
// позднее oldyears лет
//procedure TTaskCl.DelOldArhs(dir,arhname:string;olddays,oldMonths,OldYears:integer);
procedure TTaskCl.DelOldArhs(NumTask:integer);
var
 olddays,oldMonths,OldYears:integer;
 dir,exten:string;
 Day,Month:integer;
 BeforeDate:TDateTime;
 sr: TSearchRec;
  FileAttrs: Integer;
//  filesync:String;
  sordata:TDateTime; // даты файлов источ и приемника

begin
if not Tasks[numtask].Arh.DelOldArh then exit; // Если не задано удаление архивов выход из функции
dir:=Tasks[numtask].DestPath+slash;// каталог приемник где ищутся архивы
//exten:=Tasks[numtask].Arh.Name;
if Tasks[numtask].Action=ttArhZip then
   exten:='*.zip'
 else
   exten:='*.rar';
olddays:=Tasks[numtask].Arh.DaysOld;
oldMonths:=Tasks[numtask].Arh.MonthsOld;
oldYears:=Tasks[numtask].Arh.YearsOld;
FileAttrs := faReadOnly+ faHidden+ faSysFile+ faArchive+ faAnyFile;
if FindFirst(dir+exten, FileAttrs, sr) = 0 then
    begin
      repeat
        begin
        sordata:=FileDateToDateTime(sr.Time); // дата время модификации файла источника
        day:=DayOf(sordata); // день архива
        // YYMMDDHHMM Повторный архив за день
        {
        if sizeof(sr.Name)=sizeof(Tasks[numtask].Arh.Name)+10+4 then // если в имени есть время
            begin
           // sordata:=FileDateToDateTime(sr.Time); // дата время модификации файла источника
           // day:=DayOf(sordata); // день архива
            beforedate:=IncDay(Now, -2); // дата на позавчера
            if CompareDateTime(sordata,beforedate)<0 then // файл раньше даты
                       DelFile(dir+sr.Name);
            end
           else // YYMMDD дневной и тп архив YYMMDD
           }
            begin
         //   sordata:=FileDateToDateTime(sr.Time); // дата время модификации файла источника
         //   day:=DayOf(sordata); // день архива
            if day=1 then // или годовой или месячный
              begin
              month:=MonthOf(sordata); // месяц архива
              if month=1 then // годовой
                begin
                 if oldyears>0 then
                  begin
                  beforedate:=IncYear(Now, -oldyears);
                  if CompareDateTime(sordata,beforedate)<0 then // файл раньше даты
                             DelFile(dir+sr.Name);
                  end;
                end
               else // месячный
                begin
                 if oldmonths>0 then
                  begin
                  beforedate:=IncMonth(Now, -oldmonths);
                  if CompareDateTime(sordata,beforedate)<0 then // файл раньше даты
                            DelFile(dir+sr.Name);
                  end;
                end; // if month=1
              end
             else // дневной
              begin
              if olddays>0 then
                begin
                 beforedate:=IncDay(Now, -olddays);
                 if CompareDateTime(sordata,beforedate)<0 then // файл раньше даты
                             DelFile(dir+sr.Name);
                end;
              end;
        end; // else
        end;
      until FindNext(sr) <> 0;
      FindClose(sr);
    end;
{
// удаление интервальных дневных архивов
if FindFirst(dir+'\'+arhname+'??????????.rar', FileAttrs, sr) = 0 then
    begin
      repeat
        begin
        if sizeof(sr.Name)=sizeof(arhname)+10+4 then // если в имени есть время
            begin
            sordata:=FileDateToDateTime(sr.Time); // дата время модификации файла источника
            day:=DayOf(sordata); // день архива
            beforedate:=IncDay(Now, -2); // дата на позавчера
            if CompareDateTime(sordata,beforedate)<0 then // файл раньше даты
                       DelFile(dir+'\'+sr.Name);
            end;
        end;
      until FindNext(sr) <> 0;
      FindClose(sr);
    end;
    }
end;
// Удаление файла с записью в лог
procedure TTaskCl.DelFile(namef:string);
var
 str:string;
begin
if DeleteFile(namef) then
   begin
   str:=Format(misc(rsLogDelFile,'rsLogDelFile'),[namef]);
   LogMessage(str)
   end
 else
   begin
   str:=Format(misc(rsLogDelFileErr,'rsLogDelFileErr'),[namef]);
   LogMessage(str);
   end;
end;
//=====================================================
// Если replace=true то
//   Если есть в источнике или приемнике %disk%, то замена
//   его на имя диска с которого запущена программа
//   Не измененные значения для восстановления записываются
//   TempSorPath и TempDestPath
// Если replace=false то
//   Восстановление значений
procedure TTaskCl.ReplaceNameDisk(NumTask:integer;replace:boolean);
//var
// RepFlags:TReplaceFlags;
begin
//RepFlags:=rfIgnoreCase;
if replace then  // замена
 begin
  TempSorPath:=Tasks[NumTask].SorPath;
  TempDestPath:=Tasks[NumTask].DestPath;
 if AnsiContainsText(Tasks[NumTask].SorPath,'%disk%') then
   begin
   Tasks[NumTask].SorPath:=StringReplace(Tasks[NumTask].SorPath,'%disk%',ExtractFileDrive(ParamStr(0)),[rfIgnoreCase]);
    end;
 if AnsiContainsText(Tasks[NumTask].DestPath,'%disk%') then
   begin
   Tasks[NumTask].DestPath:=StringReplace(Tasks[NumTask].DestPath,'%disk%',ExtractFileDrive(ParamStr(0)),[rfIgnoreCase]);
   end;
 end
else
 begin
  Tasks[NumTask].SorPath:=TempSorPath;
  Tasks[NumTask].DestPath:=TempDestPath;
 end;
end;
//======================================================
// Получение короткого имени файла
// удалением каталога запуска проги
// если не каталог запуска то длинное имя сохраняется
function TTaskCl.ShortFileNam(FileName:String):string;
var
 FileDir:String;
 RunDir:String;
// test:string;
begin
Filedir:=ExtractFileDir(Filename);
RunDir:=ExtractFileDir(ParamStr(0));
if Filedir=RunDir then
 Result:=ExtractFileName(FileName)
   else
 Result:=FileName;
//Result:=test; 
end;
//======================================================
// Получение полного имени файла добавлением каталога запуска
function TTaskCl.FullFileNam(FileName:String):string;
var
 FileDir:String;
 RunDir:String;
begin
Filedir:=ExtractFileDir(Filename);
RunDir:=ExtractFileDir(ParamStr(0));
if Filedir='' then
 Result:=RunDir+slash+(FileName)
   else
 Result:=FileName;
end;
{
//=====================================================
// плучение полного пути имени файла прибавлением
// или текущей директории или директории запуска
// где файл окажется
function TTaskCl.GetFileNam(shortnam:String):String;
var
 FileDir,FName1,Fname2: String;
begin
Filedir:=ExtractFileDir(shortnam);
FName1:= ExpandFileName(shortnam); // тек каталог
FName2:= ExtractFileDir(ParamStr(0))+'\'+shortnam;   // Каталог запуска
Result:='';
if FileExists(Fname1) then Result:=FName1;
if FileExists(Fname2) then Result:=FName2;
if FileDir<>'' then Result:=shortnam;
end;
}
//==================================================
// Запись строки в logfile
procedure TTaskCl.LogMessage(logmes:string);
var
 dtime,fulLog:string;
begin
fulLog:=FullFileNam(logfile);
//if ExtractFileDir(fulLog)='' then
//   fulLog:=ExtractFileDir(ParamStr(0))+'\'+fulLog;
if logmes='-' then WriteFileStr(fulLog,'-----------------------------------------')
 else
 begin
  dtime:=FormatDateTime('dd.mm.yy hh:mm:ss ',now);
  dtime:=Utf8ToAnsi(dtime+logmes);
  WriteFileStr(fulLog,dtime);
  OnProgress(nil,MsgCopy,logmes,0); // сообщение для обработки потоком
 end;
end;
//=============================================
// Запись строки str в файл с именем filenamfhandle
procedure TTaskCl.WriteFileStr(filenam,str:string);
var
 hfile,i:integer;
 filelen:longint;
 buf:char;
 baklognam:string;
begin
if FileExists(filenam) then
  begin
   hfile:=FileOpen(filenam,fmOpenWrite);
  end
 else
  hfile:=FileCreate(filenam);
FileSeek(hfile,0,2);
for i:=1 to length(str) do
 begin
  buf:=str[i];
  FileWrite(hfile,buf,1);
 end;
buf:=Chr($0d);
FileWrite(hfile,buf,1);
buf:=Chr($0a);
FileWrite(hfile,buf,1);
filelen:=FileSeek(hfile,0,2);
FileClose(hfile);
if (filelen>loglimit*1024) AND (loglimit>0) AND (str='-----------------------------------------') then // файл лога превышает лимит
       begin
//         FileClose(hfile);
//         baklognam:=ExtractFileDir(filenam)+'\autosave1.log'; // Имя файла
         baklognam:=filenam+'.bak'; // Имя файла
         DeleteFile(baklognam);
         RenameFile(filenam,baklognam);
        // hfile:=FileCreate(filenam);
       end;
end;
//================================================================
// Запись массива заданий в XML файл
//----------------------------------------------------------------
procedure TTaskCl.SaveToXMLFile (filenam:string);
var
 i,j,cnt:integer;
 //MailAlert:integer;
 xmldoc:TXMLConfig;
 sec:string;
begin

if filenam='' then filenam:=profile;
profile:=filenam;

//filenam:=FullFileNam(filenam);

xmldoc:=TXMLConfig.Create(nil);
//xmldoc.Filename:=filenam;
xmldoc.StartEmpty:=true;
xmldoc.Filename:=filenam; //'probcfg.xml';
xmldoc.RootName:='AutoSave';
// Версия программы
xmldoc.SetValue('version/value',versionas);
// количество заданий
xmldoc.SetValue('tasks/count/value',count);
for i:=1 to count do
 begin
     // Имя секции с заданием
     sec:='tasks/task'+IntToStr(i)+'/';

     xmldoc.SetValue(sec+'name/value',Tasks[i].Name);
     xmldoc.SetValue(sec+'SorPath/value',Tasks[i].SorPath);
     xmldoc.SetValue(sec+'DestPath/value',Tasks[i].DestPath);
     xmldoc.SetValue(sec+'Action/value',Tasks[i].Action);
     xmldoc.SetValue(sec+'Enabled/value',Tasks[i].Enabled);
     // Сохраняем параметры архива
     xmldoc.SetValue(sec+'Arh/Name/value',Tasks[i].Arh.Name);
     xmldoc.SetValue(sec+'Arh/DelOldArh/value',Tasks[i].Arh.DelOldArh);
     xmldoc.SetValue(sec+'Arh/DaysOld/value',Tasks[i].Arh.DaysOld);
     xmldoc.SetValue(sec+'Arh/MonthsOld/value',Tasks[i].Arh.MonthsOld);
     xmldoc.SetValue(sec+'Arh/YearsOld/value',Tasks[i].Arh.YearsOld);
   {
     TmpStr.Add(BoolToStr(Tasks[i].Rasp.Manual));
     TmpStr.Add(BoolToStr(Tasks[i].Rasp.AtTime));
     TmpStr.Add(BoolToStr(Tasks[i].Rasp.AtStart));

     TmpStr.Add(BoolToStr(Tasks[i].Rasp.EvMinutes));
     TmpStr.Add(IntToStr(Tasks[i].Rasp.Minutes));
     TmpStr.Add(TimeToStr(Tasks[i].Rasp.Time));
     }
     //Параметры запуска внешних программ
    xmldoc.SetValue(sec+'ExtProgs/BeforeStart/value',Tasks[i].ExtProgs.BeforeStart);
    xmldoc.SetValue(sec+'ExtProgs/BeforeName/value',Tasks[i].ExtProgs.BeforeName);
    xmldoc.SetValue(sec+'ExtProgs/AfterStart/value',Tasks[i].ExtProgs.AfterStart);
    xmldoc.SetValue(sec+'ExtProgs/AfterName/value',Tasks[i].ExtProgs.AfterName);
     // Копирование прав
     xmldoc.SetValue(sec+'NTFSPerm/value',Tasks[i].NTFSPerm);
     // Уведомления по почте
     //MailAlert:=Tasks[i].MailAlert;
     xmldoc.SetValue(sec+'MailAlert/value',Tasks[i].MailAlert);
     //xmldoc.SetValue(sec+'MailAlert/value',MailAlert);
     // Результат последнего выполнения задачи
     xmldoc.SetValue(sec+'LastResult/value',Tasks[i].LastResult);
     xmldoc.SetValue(sec+'LastRunDate/value',DateTimeToStr(Tasks[i].LastRunDate));
     // Параметры фильтрации каталогов и файлов источника
     xmldoc.SetValue(sec+'SourceFilt/Recurse/value',Tasks[i].SourceFilt.Recurse);
     xmldoc.SetValue(sec+'SourceFilt/FiltSubDir/value',Tasks[i].SourceFilt.FiltSubDir);
       // список исключаемых директорий
       cnt:=Tasks[i].SourceFilt.SubDirs.Count;
       xmldoc.SetValue(sec+'SourceFilt/SubDirs/count/value',cnt);
       for j:=1 to cnt do
         begin
          xmldoc.SetValue(sec+'SourceFilt/SubDirs/path'+IntToStr(j)+'/value',Tasks[i].SourceFilt.SubDirs.Strings[j-1]);
         end;
     xmldoc.SetValue(sec+'SourceFilt/FiltFiles/value',Tasks[i].SourceFilt.FiltFiles);
     xmldoc.SetValue(sec+'SourceFilt/ModeFiltFiles/value',Tasks[i].SourceFilt.ModeFiltFiles);
     xmldoc.SetValue(sec+'SourceFilt/FileMask/value',Tasks[i].SourceFilt.FileMask.DelimitedText);

 end;
//TmpStr.SaveToFile(filenam);
xmldoc.Flush;
xmldoc.Destroy;
end;
//==========================================================
// Загрузка массива заданий из файла
// старые задания не удаляются, если нужно удалить все то нужно перед
// вызовом функции сделать count=0;
// Возвращает PName - имя профиля загруженного
procedure TTaskCl.LoadFromXMLFile(filenam:string);
var
 i,j,cnt,cntdir:integer;
// TmpStr:TStringList;
// ver:integer;
// i,j,cnt:integer;
 xmldoc:TXMLConfig;
 sec:string;
 strDate:string;
begin
if filenam='' then filenam:=profile;
//filenam:=FullFileNam(filenam);




//filenam:='probcfg.xml';
if Not FileExists(filenam) then exit;

xmldoc:=TXMLConfig.Create(nil);

xmldoc.StartEmpty:=false; //false;
xmldoc.RootName:='AutoSave';
xmldoc.flush;
xmldoc.Filename:=filenam;

 try
 xmldoc.Filename:=filenam;
 finally
  end;
//xmldoc.Flush;
 

//xmldoc.Filename:='probcfg.xml';


// количество заданий
cnt:=xmldoc.GetValue('tasks/count/value',0);
if cnt=0 then exit;
//count:=cnt;
Profile:=ShortFileNam(filenam);

//TmpStr.LoadFromFile(filenam);
//ProfName:='';
//strcount:=1;
Clear;

for i:=1 to cnt  do
//while strcount<TmpStr.Count do
  begin
     // Имя секции с заданием
     sec:='tasks/task'+IntToStr(i)+'/';
   if i>MaxTasks then exit; // вдруг пакостный файл

   Tasks[i].Name:=xmldoc.GetValue(sec+'name/value','');

   Tasks[i].SorPath:=xmldoc.GetValue(sec+'SorPath/value','');  //TmpStr[strcount+1];
   Tasks[i].DestPath:=xmldoc.GetValue(sec+'DestPath/value','');      //TmpStr[strcount+2];
   Tasks[i].Action:=xmldoc.GetValue(sec+'Action/value',0);               //StrToInt(TmpStr[strcount+3]);
   Tasks[i].Enabled:=xmldoc.GetValue(sec+'Enabled/value',false);      //StrToBool(TmpStr[strcount+4]);
   Tasks[i].Status:=stNone;
   // Чтение параметров архива

   Tasks[i].Arh.Name:=xmldoc.GetValue(sec+'Arh/Name/value','');
   Tasks[i].Arh.DelOldArh:=xmldoc.GetValue(sec+'Arh/DelOldArh/value',false);
   Tasks[i].Arh.DaysOld:=xmldoc.GetValue(sec+'Arh/DaysOld/value',0);
   Tasks[i].Arh.MonthsOld:=xmldoc.GetValue(sec+'Arh/MonthsOld/value',0);
   Tasks[i].Arh.YearsOld:=xmldoc.GetValue(sec+'Arh/YearsOld/value',0);



    // Чтение параметров запуска внешних программ
     Tasks[i].ExtProgs.BeforeStart:=xmldoc.GetValue(sec+'ExtProgs/BeforeStart/value',false); //StrToBool(TmpStr[strcount+14]);
     Tasks[i].ExtProgs.BeforeName:=xmldoc.GetValue(sec+'ExtProgs/BeforeName/value','');//TmpStr[strcount+15];
     Tasks[i].ExtProgs.AfterStart:=xmldoc.GetValue(sec+'ExtProgs/AfterStart/value',false); //StrToBool(TmpStr[strcount+16]);
     Tasks[i].ExtProgs.AfterName:=xmldoc.GetValue(sec+'ExtProgs/AfterName/value',''); //TmpStr[strcount+17];
     // Копирование прав
     Tasks[i].NTFSPerm:=xmldoc.GetValue(sec+'NTFSPerm/value',false);//StrToBool(TmpStr[strcount+18]);
          // Уведомления по почте
     Tasks[i].MailAlert:=xmldoc.GetValue(sec+'MailAlert/value',0);
     // Последний результат выполнения задания
     Tasks[i].LastResult:=xmldoc.GetValue(sec+'LastResult/value',0);//StrToInt(TmpStr[strcount+19]);
     strDate:=xmldoc.GetValue(sec+'LastRunDate/value','0');
     Tasks[i].LastRunDate:=StrToDateTime(strDate); // xmldoc.GetValue(sec+'LastRunDate/value',0);//StrToDateTime(TmpStr[strcount+20]);

              // Чтение параметров фильтрации источника
     Tasks[i].SourceFilt.SubDirs:=TStringList.Create;
     Tasks[i].SourceFilt.SubDirs.Delimiter:=';';
     Tasks[i].SourceFilt.FileMask:=TStringList.Create;
     Tasks[i].SourceFilt.FileMask.Delimiter:=';';

     Tasks[i].SourceFilt.Recurse:=xmldoc.GetValue(sec+'SourceFilt/Recurse/value',true);//StrToBool(TmpStr[strcount+21]);
     Tasks[i].SourceFilt.FiltSubDir:=xmldoc.GetValue(sec+'SourceFilt/FiltSubDir/value',false);//StrToBool(TmpStr[strcount+22]);
          // Количество фильтруемых директорий
             cntdir:=xmldoc.GetValue(sec+'SourceFilt/SubDirs/count/value',0);
      for j:=1 to cntdir do // чтение фильтруемых директорий
         begin
          Tasks[i].SourceFilt.SubDirs.Add(xmldoc.GetValue(sec+'SourceFilt/SubDirs/path'+IntToStr(j)+'/value',''));
         end;
     Tasks[i].SourceFilt.FiltFiles:=xmldoc.GetValue(sec+'SourceFilt/FiltFiles/value',false); //StrToBool(TmpStr[strcount+24]);
     Tasks[i].SourceFilt.ModeFiltFiles:=xmldoc.GetValue(sec+'SourceFilt/ModeFiltFiles/value',0);//StrToInt(TmpStr[strcount+25]);
     Tasks[i].SourceFilt.FileMask.DelimitedText:=xmldoc.GetValue(sec+'SourceFilt/FileMask/value','');//TmpStr[strcount+26];
  count:=i;
  end;
//TmpStr.Free;
xmldoc.Destroy;
end;

//=================================================================
// Запись массива заданий в файл
procedure TTaskCl.SaveToFile (filenam:string);
//var
// i:integer;
// TmpStr:TStringList;
// tfile:File of TTask; 
// cfgnam:string;
begin
SaveToXMLFile(filenam);
{
if filenam='' then filenam:=profile;
profile:=filenam;
filenam:=FullFileNam(filenam);
TmpStr:=TStringList.Create;
TmpStr.Add('AutoSave task file ver1.3a');
TmpStr.Add(ProfName);
//len:=Length(ArNabor);
// Запись задач в строку
for i:=1 to count do
 begin
     TmpStr.Add(Tasks[i].Name);
     TmpStr.Add(Tasks[i].SorPath);
     TmpStr.Add(Tasks[i].DestPath);
     TmpStr.Add(IntToStr(Tasks[i].Action));
     TmpStr.Add(BoolToStr(Tasks[i].Enabled));

     TmpStr.Add(Tasks[i].Arh.Name);
     TmpStr.Add(BoolToStr(Tasks[i].Arh.DelOldArh));
     TmpStr.Add(IntToStr(Tasks[i].Arh.DaysOld));
     TmpStr.Add(IntToStr(Tasks[i].Arh.MonthsOld));
     TmpStr.Add(IntToStr(Tasks[i].Arh.YearsOld));

     TmpStr.Add(BoolToStr(Tasks[i].Rasp.Manual));
     TmpStr.Add(BoolToStr(Tasks[i].Rasp.AtTime));
     TmpStr.Add(BoolToStr(Tasks[i].Rasp.AtStart));

     TmpStr.Add(BoolToStr(Tasks[i].Rasp.EvMinutes));
     TmpStr.Add(IntToStr(Tasks[i].Rasp.Minutes));
     TmpStr.Add(TimeToStr(Tasks[i].Rasp.Time));
     //Параметры запуска внешних программ
     TmpStr.Add(BoolToStr(Tasks[i].ExtProgs.BeforeStart));
     TmpStr.Add(Tasks[i].ExtProgs.BeforeName);
     TmpStr.Add(BoolToStr(Tasks[i].ExtProgs.AfterStart));
     TmpStr.Add(Tasks[i].ExtProgs.AfterName);
     // Копирование прав
     TmpStr.Add(BoolToStr(Tasks[i].NTFSPerm));
     // Результат последнего выполнения задачи
     TmpStr.Add(IntToStr(Tasks[i].LastResult));
     TmpStr.Add(DateTimeToStr(Tasks[i].LastRunDate));
     // Параметры фильтрации каталогов и файлов источника

     TmpStr.Add(BoolToStr(Tasks[i].SourceFilt.Recurse));
     TmpStr.Add(BoolToStr(Tasks[i].SourceFilt.FiltSubDir));
     TmpStr.Add(Tasks[i].SourceFilt.SubDirs.DelimitedText);
     TmpStr.Add(BoolToStr(Tasks[i].SourceFilt.FiltFiles));
     TmpStr.Add(IntToStr(Tasks[i].SourceFilt.ModeFiltFiles));
     TmpStr.Add(Tasks[i].SourceFilt.FileMask.DelimitedText);


 end;
TmpStr.SaveToFile(filenam);
 }
end;






//==========================================================
// Загрузка массива заданий из файла
// старые задания не удаляются, если нужно удалить все то нужно перед
// вызовом функции сделать count=0;
// Возвращает PName - имя профиля загруженного
procedure TTaskCl.LoadFromFile(filenam:string);
//var
// i,strcount:integer;
// TmpStr:TStringList;
// ver:integer;
// tstr:string;
 //cfgnam:string;
begin
LoadFromXMLFile(filenam);
{
if filenam='' then filenam:=profile;
filenam:=FullFileNam(filenam);
TmpStr:=TStringList.Create;
if Not FileExists(filenam) then exit;
Profile:=ShortFileNam(filenam);

TmpStr.LoadFromFile(filenam);
ProfName:='';
strcount:=1;
if Not SameText(LeftStr(TmpStr[0],18),'AutoSave task file') then
  exit;
ver:=0;
if SameText(TmpStr[0],'AutoSave task file ver1.3a') then
  begin
  ver:=13;
  ProfName:=TmpStr[strcount];
  Inc(strcount);
  end;
if SameText(TmpStr[0],'AutoSave task file ver1.3') then
  ver:=13;
if SameText(TmpStr[0],'AutoSave task file ver1.2') then
  ver:=12;
if SameText(TmpStr[0],'AutoSave task file ver1.1') then
  ver:=11;
if SameText(TmpStr[0],'AutoSave task file ver1') then
  ver:=10;
if ver=0 then exit;// файл более нового формата

//strcount:=1;
//count:=0;
i:=count+1;
while strcount<TmpStr.Count do
  begin
   if i>MaxTasks then exit; // вдруг пакостный файл
   Tasks[i].Name:=TmpStr[strcount];
   Tasks[i].SorPath:=TmpStr[strcount+1];
   Tasks[i].DestPath:=TmpStr[strcount+2];
   Tasks[i].Action:=StrToInt(TmpStr[strcount+3]);
   if (ver=11) or (ver=10) then // исправление rar
     begin
     if Tasks[i].Action=ttArhZip then Tasks[i].Action:=ttArhRar;
     end;
   Tasks[i].Enabled:=StrToBool(TmpStr[strcount+4]);
   Tasks[i].Status:=stNone;

   Tasks[i].Arh.Name:=TmpStr[strcount+5];
   Tasks[i].Arh.DelOldArh:=StrToBool(TmpStr[strcount+6]);
   Tasks[i].Arh.DaysOld:=StrToInt(TmpStr[strcount+7]);
   Tasks[i].Arh.MonthsOld:=StrToInt(TmpStr[strcount+8]);
   Tasks[i].Arh.YearsOld:=StrToInt(TmpStr[strcount+9]);

   Tasks[i].Rasp.Manual:=StrToBool(TmpStr[strcount+10]);

   if (ver=11) or (ver=12) or (ver=13) then
    begin
     Tasks[i].Rasp.AtTime:=StrToBool(TmpStr[strcount+11]);
     Tasks[i].Rasp.AtStart:=StrToBool(TmpStr[strcount+12]);
     strcount:=strcount+2;
    end
    else
     begin
     Tasks[i].Rasp.AtTime:=Not Tasks[i].Rasp.Manual;
     Tasks[i].Rasp.AtStart:=false;
     end;

   Tasks[i].Rasp.EvMinutes:=StrToBool(TmpStr[strcount+11]);
   Tasks[i].Rasp.Minutes:=StrToInt(TmpStr[strcount+12]);
   Tasks[i].Rasp.Time:=StrToTime(TmpStr[strcount+13]);

   if ver=13 then // Чтение параметров запуска внешних программ
     begin
     Tasks[i].ExtProgs.BeforeStart:=StrToBool(TmpStr[strcount+14]);
     Tasks[i].ExtProgs.BeforeName:=TmpStr[strcount+15];
     Tasks[i].ExtProgs.AfterStart:=StrToBool(TmpStr[strcount+16]);
     Tasks[i].ExtProgs.AfterName:=TmpStr[strcount+17];
     // Копирование прав
     Tasks[i].NTFSPerm:=StrToBool(TmpStr[strcount+18]);
     // Последний результат выполнения задания
     Tasks[i].LastResult:=StrToInt(TmpStr[strcount+19]);
     Tasks[i].LastRunDate:=StrToDateTime(TmpStr[strcount+20]);
//     strcount:=strcount+7;

              // Чтение параметров фильтрации источника
     Tasks[i].SourceFilt.SubDirs:=TStringList.Create;
     Tasks[i].SourceFilt.SubDirs.Delimiter:=';';
     Tasks[i].SourceFilt.FileMask:=TStringList.Create;
     Tasks[i].SourceFilt.FileMask.Delimiter:=';';
     Tasks[i].SourceFilt.Recurse:=StrToBool(TmpStr[strcount+21]);
     Tasks[i].SourceFilt.FiltSubDir:=StrToBool(TmpStr[strcount+22]);
     Tasks[i].SourceFilt.SubDirs.DelimitedText:=TmpStr[strcount+23];
     Tasks[i].SourceFilt.FiltFiles:=StrToBool(TmpStr[strcount+24]);
     Tasks[i].SourceFilt.ModeFiltFiles:=StrToInt(TmpStr[strcount+25]);
     Tasks[i].SourceFilt.FileMask.DelimitedText:=TmpStr[strcount+26];
     strcount:=strcount+13;

     end;

   strcount:=strcount+14;
   inc(i);
   inc(count);

  end;
TmpStr.Free;
 }
end;
//=========================================================
// Отправка сообщения на email
{
procedure TTaskCl.SendMail(MesSubject:string;MesBody:TStrings);
var
    idSMTP1: TIdSMTP;
    Mes: TIdMessage;
begin
  mes:=TIdMessage.Create(nil);
  idSMTP1:=TidSmtp.Create(nil);
  idsmtp1.Host := smtpserv;
  idsmtp1.Port := smtpport;
  idsmtp1.Username := smtpuser;
  idsmtp1.Password := smtppass;
  if smtppass<>'' then  idsmtp1.AuthenticationType :=atLogin ;
  mes.From.Text := mailfrom;
  mes.Recipients.EMailAddresses := email;
  mes.Subject := MesSubject;
  mes.Body := mesbody;
   try
    idsmtp1.Connect();
    idsmtp1.Send(mes);
   finally
    mes.Free;
    idsmtp1.Disconnect;
    idsmtp1.Free;
   end;
//  idsmtp1.Connect();
//  idsmtp1.Send(mes);
// idsmtp1.Disconnect;
//  mes.Free;

end;

 }
//=========================================================
// Копирование/синхронизация файлов
function TTaskCl.SyncFiles(sorfile,destfile:string;NTFSCopy:Boolean;recurse:Boolean):Boolean;
var
 SorDir,DestDir,str:string;
// PSorFile,PDestFile: array [0..MaxPChar] of char;
 SorFile2,DestFile2: array of WideChar;
 PSorFile2,PDestFile2: PWideChar;
 ls,ld:integer; // Длина строк источника и получателя
// PSorFile2,PDestFile2: PWideChar;
begin
Result:=false;
Destdir:=ExtractFileDir(destfile);
if Not DirectoryExists(Destdir) then
    begin
    ForceDirectories(Destdir);
    end;
if NTFSCopy AND recurse then // Права на директорию
     begin
     SorDir:=ExtractFileDir(sorfile);
     CopyNTFSPerm(sordir,destdir);
     end;

ls:=Length(sorfile);
ld:= Length(destfile);
SetLength(SorFile2,ls+1) ;
SetLength(DestFile2,ld+1);
PSorFile2:=@SorFile2[0];
PDestFile2:=@DestFile2[0];
StringToWideChar(sorfile, PSorFile2, ls+1);
StringToWideChar(destfile, PDestFile2, ld+1);

//SorFile2:=sorfile;
//DestFile2:=destfile;
//if CopyFile(PAnsiChar(sorfile),PAnsiChar(destfile),false) then
//if CopyFile(PSorFile,PDestFile,false) then
if CopyFileW(PSorFile2,PDestFile2,false) then
//if CopyFileW(@SorFile2[0],@DestFile2[0],false) then
    begin
    Result:=true;
    if NTFSCopy then CopyNTFSPerm(sorfile,destfile);
    str:=Format(misc(rsLogFileCopied,'rsLogFileCopied'),[sorfile]);
    end
   else
      str:=Format(misc(rsLogFileCopiedErr,'rsLogFileCopiedErr'),[sorfile]);
   LogMessage(str);
end;
//=========================================================
// Получение процессом привелегий
{
SE_CREATE_TOKEN_NAME = ?SeCreateTokenPrivilege?;
  SE_ASSIGNPRIMARYTOKEN_NAME = ?SeAssignPrimaryTokenPrivilege?;
  SE_LOCK_MEMORY_NAME = ?SeLockMemoryPrivilege?;
  SE_INCREASE_QUOTA_NAME = ?SeIncreaseQuotaPrivilege?;
  SE_UNSOLICITED_INPUT_NAME = ?SeUnsolicitedInputPrivilege?;
  SE_MACHINE_ACCOUNT_NAME = ?SeMachineAccountPrivilege?;
  SE_TCB_NAME = ?SeTcbPrivilege?;
  SE_SECURITY_NAME = ?SeSecurityPrivilege?;
  SE_TAKE_OWNERSHIP_NAME = ?SeTakeOwnershipPrivilege?;
  SE_LOAD_DRIVER_NAME = ?SeLoadDriverPrivilege?;
  SE_SYSTEM_PROFILE_NAME = ?SeSystemProfilePrivilege?;
  SE_SYSTEMTIME_NAME = ?SeSystemtimePrivilege?;
  SE_PROF_SINGLE_PROCESS_NAME = ?SeProfileSingleProcessPrivilege?;
  SE_INC_BASE_PRIORITY_NAME = ?SeIncreaseBasePriorityPrivilege?;
  SE_CREATE_PAGEFILE_NAME = ?SeCreatePagefilePrivilege?;
  SE_CREATE_PERMANENT_NAME = ?SeCreatePermanentPrivilege?;
  SE_BACKUP_NAME = ?SeBackupPrivilege?;
  SE_RESTORE_NAME = ?SeRestorePrivilege?;
  SE_SHUTDOWN_NAME = ?SeShutdownPrivilege?;
  SE_DEBUG_NAME = ?SeDebugPrivilege?;
  SE_AUDIT_NAME = ?SeAuditPrivilege?;
  SE_SYSTEM_ENVIRONMENT_NAME = ?SeSystemEnvironmentPrivilege?;
  SE_CHANGE_NOTIFY_NAME = ?SeChangeNotifyPrivilege?;
  SE_REMOTE_SHUTDOWN_NAME = ?SeRemoteShutdownPrivilege?;
  SE_UNDOCK_NAME = ?SeUndockPrivilege?;
  SE_SYNC_AGENT_NAME = ?SeSyncAgentPrivilege?;
  SE_ENABLE_DELEGATION_NAME = ?SeEnableDelegationPrivilege?;
  SE_MANAGE_VOLUME_NAME = ?SeManageVolumePrivilege?;
}
function TTaskCL.NTSetPrivilege(sPrivilege: string; bEnabled: Boolean): Boolean;
var
  hToken: THandle;
  TokenPriv: TOKEN_PRIVILEGES;
  PrevTokenPriv: TOKEN_PRIVILEGES;
  ReturnLength: Cardinal;
  buf: array [0..MaxPChar] of char;
begin
  Result := True;
  // Only for Windows NT/2000/XP and later.
  if not (Win32Platform = VER_PLATFORM_WIN32_NT) then Exit;
  Result := False;

  // obtain the processes token
  if OpenProcessToken(GetCurrentProcess(),
    TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken) then
  begin
    try
      // Get the locally unique identifier (LUID) .
      //if LookupPrivilegeValue(nil, PChar(sPrivilege),
      //  TokenPriv.Privileges[0].Luid) then
      buf:=sPrivilege;
      if LookupPrivilegeValue(nil, buf,
        TokenPriv.Privileges[0].Luid) then

      begin
        TokenPriv.PrivilegeCount := 1; // one privilege to set

        case bEnabled of
          True: TokenPriv.Privileges[0].Attributes  := SE_PRIVILEGE_ENABLED;
          False: TokenPriv.Privileges[0].Attributes := 0;
        end;

        ReturnLength := 0; // replaces a var parameter
        PrevTokenPriv := TokenPriv;

        // enable or disable the privilege

        AdjustTokenPrivileges(hToken, False, TokenPriv, SizeOf(PrevTokenPriv),
          PrevTokenPriv, ReturnLength);
      end;
    finally
      CloseHandle(hToken);
    end;
  end;
  // test the return value of AdjustTokenPrivileges.
  Result := GetLastError = ERROR_SUCCESS;
  if not Result then
    raise Exception.Create(SysErrorMessage(GetLastError));
end;



//==========================================================
// Копирование прав доступа файла или каталога
// sorfile- имя файла источника
// destfile - имя файла приемника
// Возвращает true если все ОК
function TTaskCL.CopyNTFSPerm(sorfile,destfile:string):Boolean;
var
 SecDescr: PSecurityDescriptor;
 SizeNeeded: DWORD; // Буфер для определения размера описателя
// SizeNeeded: LPDWORD; // Буфер для определения размера описателя
 BufferSize:DWORD; // Размер буфера
 psor,pdest: array [0..MaxPChar] of char;
begin
Result:=false; // Пока ничего не сделано
//NTSetPrivilege('SeSecurityPrivilege',true);
GetMem(SecDescr, 1024); // выделение памяти
// Проверка существования источника и приемника
//if (NOT FileExists(sorfile)) or (NOT FileExists(destfile)) then exit;
// Вначале вызов функции для определения размера буфера
//if not GetFileSecurity(PChar(sorfile),OWNER_SECURITY_INFORMATION or GROUP_SECURITY_INFORMATION or DACL_SECURITY_INFORMATION or SACL_SECURITY_INFORMATION,
//                     SecDescr, 1024, SizeNeeded) then Exit;
//if not GetFileSecurity(PChar(sorfile),OWNER_SECURITY_INFORMATION or GROUP_SECURITY_INFORMATION or DACL_SECURITY_INFORMATION or SACL_SECURITY_INFORMATION,SecDescr, 0, SizeNeeded) then
//         begin
         //Exit;
//         end;
psor:=sorfile;
pdest:=destfile;
//GetFileSecurity(PChar(sorfile),OWNER_SECURITY_INFORMATION or GROUP_SECURITY_INFORMATION or DACL_SECURITY_INFORMATION or SACL_SECURITY_INFORMATION,SecDescr, 0, SizeNeeded);
GetFileSecurity(Psor,OWNER_SECURITY_INFORMATION or GROUP_SECURITY_INFORMATION or DACL_SECURITY_INFORMATION or SACL_SECURITY_INFORMATION,SecDescr, 0, LPDWORD(SizeNeeded));
// Теперь в SizeNeeded - размер необходимого буфера
if SizeNeeded=0 then // ничего не надо копировать
  begin
  // LogMessage('0 длина');
   Result:=true;
   exit;
  end;
BufferSize:=SizeNeeded;
FreeMem(SecDescr);// особождение ранее выделенной памяти
GetMem(SecDescr,BufferSize); // выделение памяти по нужному размеру
// снова получение параметров безопасности уже с нужным размером буфера
if not GetFileSecurity(Psor,OWNER_SECURITY_INFORMATION or GROUP_SECURITY_INFORMATION or DACL_SECURITY_INFORMATION or SACL_SECURITY_INFORMATION,
                     SecDescr, BufferSize, LPDWORD(SizeNeeded)) then Exit;
// Перенос полученных параметров на приемник
if not SetFileSecurity(Pdest,OWNER_SECURITY_INFORMATION or GROUP_SECURITY_INFORMATION or DACL_SECURITY_INFORMATION or SACL_SECURITY_INFORMATION,
                     SecDescr) then Exit;
FreeMem(SecDescr);// особождение ранее выделенной памяти
Result:=true;
//LogMessage('Права скопированы: '+sorfile);
end;
//============================================================
// Удаление директории dir со всем ее содержимым
procedure TTaskCl.DelDirs(dir:string);
var
  sr: TSearchRec;
  FileAttrs: Integer;
  //dir2:String;
 // filesync:String;
//  sordata,destdata:TDateTime; // даты файлов источ и приемника
begin
FileAttrs := faReadOnly+ faHidden+ faSysFile+ faArchive+ faAnyFile;
// сначала файлы
if FindFirst(dir+slash+'*', FileAttrs, sr) = 0 then
    begin
      repeat
        begin
        DeleteFile(dir+slash+sr.Name);
        end;
      until FindNext(sr) <> 0;
      FindClose(sr);
    end;
// потом директории
FileAttrs := faDirectory+faReadOnly+ faHidden+ faSysFile+ faArchive;
if FindFirst(dir+slash+'*', FileAttrs, sr) = 0 then
    begin
      repeat
        if (sr.Attr and faDirectory	) <>0 then
        begin
          if not SameText(sr.Name,'.') and not SameText(sr.Name,'..') then
           begin
           DelDirs(dir+slash+sr.Name);
           end;
        end;
      until FindNext(sr) <> 0;
      FindClose(sr);
    end;
RemoveDir(dir);
end;


//=================================================================
// Проверка файла источника на совпадение с маской
// Возвращает true - файл для обработки
//            false - файл обрабатывать не надо
function TTaskCl.CheckFileMask(FileName:string;NumTask:integer):Boolean;
var
 Match:Boolean; // Файл совпадает с маской
 i:integer;
begin
if Tasks[NumTask].SourceFilt.FiltFiles then // Установлен фильтр по файлам
    begin
     Match:=false;
     // Проверка на совпадение файла с маской
     for i:=0 to Tasks[NumTask].SourceFilt.FileMask.Count-1 do
       begin
//        function FileInFilenameMasks(const Filename, Masks: string): boolean;
//         Match:=(Match) OR (FileInFilenameMasks(FileName,Tasks[NumTask].SourceFilt.FileMask[i]));
        Match:=(Match) OR (MatchesMask(FileName,Tasks[NumTask].SourceFilt.FileMask[i]));
       end;
     if Tasks[NumTask].SourceFilt.ModeFiltFiles=tsMask then // Все кроме маски
       Result:=Match
       else
        Result:=Not Match;
    end
  else
   Result:=true; 
end;
//=================================================================
// Проверка каталога на совпадение со списком исключаемых
// Возвращает true - каталог для обработки
//            false - каталог обрабатывать не надо
function TTaskCl.CheckSubDir(SubDir:string;NumTask:integer):Boolean;
var
 Match:Boolean; // Файл совпадает с маской
 i:integer;
 FullPath:string;
begin
if Tasks[NumTask].SourceFilt.FiltSubDir then // Установлен фильтр по каталогам
    begin
     Match:=false;
     // Проверка на совпадение файла с маской
     for i:=0 to Tasks[NumTask].SourceFilt.SubDirs.Count-1 do
       begin
        FullPath:=Tasks[NumTask].SorPath+slash+Tasks[NumTask].SourceFilt.SubDirs[i];
        Match:=(Match) OR (SameText(SubDir,FullPath));
       end;
        Result:=Not Match;
    end
  else
   Result:=true;
end;
//=================================================================
// копирует/синхронизирует директорию dir в/с директорией syncdir
// dir - Источник
// syncdir - Приемник (для рекурсивного вызова их отдельно)
// NumTask - номер задачи в массиве заданий
// Recurse - true - рекурсивный вызов
//           false - первый вызов
// CountSize - Подсчитывать ли общий размер файлов для копирования
//Возвращает true при успехе или false при ошибках
function TTaskCl.CopyDirs(dir,syncdir:string;NumTask:integer;Recurse:Boolean;CountSize:boolean):integer;
var
  sr: TSearchRec;
  FileAttrs: Integer;
//  dir,syncdir:String;
  filesync,str:String;
  NTFSCopy:Boolean;
  TypeSync:integer;
  sordata,destdata:integer; // даты файлов источ и приемника
begin
Result:=trOk;
// trOk=0; // Все ок
//  trError=1; // Ошибка запуска задания (недоступен каталог)
//  trFileError=2; // Ошибка копирования файла в задании
if recurse AND Not Tasks[NumTask].SourceFilt.Recurse then exit; // подкаталоги не обрабатывать
NTFSCopy:=Tasks[NumTask].NTFSPerm;
//dir:=Tasks[NumTask].SorPath; // Источник
//syncdir:=Tasks[NumTask].DestPath;
TypeSync:=Tasks[NumTask].Action;
//  ttCopy=1; // Копирование
//  ttZerk=2; //Зеркалирование
//  ttSync=3; //Сихронизирование
if Not Recurse  then
 begin
 NTSetPrivilege('SeSecurityPrivilege',true);
// dir:=ReplaceNameDisk(dir);
// syncdir:=ReplaceNameDisk(syncdir);
 if not DirectoryExists(dir) then // каталога-источника не существует
    begin
     str:=Format(misc(rsLogDirNotFound,'rsLogDirNotFound'),[dir]);
     LogMessage(str);
     str:=Format(misc(rsLogTaskError,'rsLogTaskError'),[Tasks[NumTask].Name]);
     LogMessage(str);
 //    LogMessage('[Ошибка]: Задние не выполнено, каталог недоступен '+dir);
     Result:=trError;
     exit; // айяй
    end;
 if not DirectoryExists(syncdir) then // каталога-приемника не существует
    begin
     if ForceDirectories(syncdir) then
       begin
       str:=Format(misc(rsLogDirCreated,'rsLogDirCreated'),[syncdir]);
       LogMessage(str) // создаем его
       end
      else
       begin
       str:=Format(misc(rsLogDirNotFound,'rsLogDirNotFound'),[syncdir]);
       LogMessage(str);
       str:=Format(misc(rsLogTaskError,'rsLogTaskError'),[Tasks[NumTask].Name]);
       LogMessage(str);
       Result:=trError;
       OnProgress (nil,EndOfBatch,'',0);
       exit; // айяй
       end;
    end;
  end;
if (NOT recurse) AND (countsize)  then // Определение общего размера файлов
  begin
   GetSizeDir(dir,syncdir,NumTask,false);
   OnProgress (Nil,TotalSize2Process,'',TotalSize); // Вызов события для обработки потоком
  end;
if (recurse) AND (NTFSCopy) then // вызов рекурсивный - копируются права на директорию
   begin;
   ForceDirectories(syncdir);
   CopyNTFSPerm(dir,syncdir);
   end;
FileAttrs := faReadOnly+ faHidden+ faSysFile+ faArchive+ faAnyFile;
// сначала файлы
if FindFirst(dir+slash+'*', FileAttrs, sr) = 0 then
    begin
      repeat
        begin

      if CheckFileMask(sr.Name,NumTask) then // Проверка файла на маску
        begin
        filesync:=syncdir+slash+sr.Name; // Имя файла приемника
        if FileExists(filesync) then // файл в каталоге приемнике уже есть
          begin // Тогда сверяются даты
            //sordata:=FileDateToDateTime(sr.Time); // дата время модификации файла источника
            //destdata:=FileDateToDateTime(FileAge(filesync));// дата файла премника
            sordata:=sr.Time;
            destData:=FileAge(filesync);
       //     if CompareDateTime(sordata,destdata)>0 then // файл источник позже
             if CompareFileDate(sordata,destdata) then
               begin
               OnProgress (Nil,NewFile,sr.Name,sr.Size); // Вызов события для обработки потоком
               if Not SyncFiles(dir+slash+sr.Name,filesync,NTFSCopy,recurse) then Result:=trFileError; // синхронизация файлов
               OnProgress (Nil,ProgressUpdate,'',sr.Size); // Вызов события для обработки потоком
               end;
            if TypeSync=ttSync then // если синхронизация
               begin
//                  if CompareDateTime(destdata,sordata)>0 then // файл источник раньше
                    if CompareFileDate (destdata,sordata) then
                        begin
                      OnProgress (Nil,NewFile,sr.Name,sr.Size);
                      if Not SyncFiles(filesync,dir+slash+sr.Name,NTFSCopy,recurse) then Result:=trFileError; // синхронизация файлов наоборот
                      OnProgress (Nil,ProgressUpdate,'',sr.Size);
                      end;
               end;
           end
          else // файл приемник не существует
           begin
             OnProgress (Nil,NewFile,sr.Name,sr.Size);
             if Not SyncFiles(dir+slash+sr.Name,filesync,NTFSCopy,recurse) then Result:=trFileError; // синхронизация файлов
             OnProgress (Nil,ProgressUpdate,'',sr.Size);
             //LogMessage('Файл скопирован: '+filesync);
           end;
        end;// if checkfilemask
        end;
      until FindNext(sr) <> 0;
      FindClose(sr);
    end;
FileAttrs := faReadOnly+ faHidden+ faSysFile+ faArchive+ faAnyFile+faDirectory;
if (TypeSync=ttSync) OR (TypeSync=ttZerk) then // если синхронизация или зеркалирование
  begin
   if FindFirst(syncdir+slash+'*', FileAttrs, sr) = 0 then
    begin
      repeat
        begin
        filesync:=dir+slash+sr.Name; // Имя файла источника
        if ((sr.Attr and faDirectory) <>0) AND (CheckSubDir(filesync,NumTask)) then // это директория
          begin
           if not directoryexists(filesync) then // директория приемника не существует
             begin
             if TypeSync=ttZerk then // зеркалирование
               begin
               DelDirs(syncdir+slash+sr.Name);
               str:=syncdir+slash+sr.Name;
               str:=Format(misc(rsLogDelDir,'rsLogDelDir'),[str]);
               LogMessage(str);
               end
              else // синхронизирование
               begin
               if CopyDirs(syncdir+slash+sr.Name,filesync,NumTask,true,false)=trFileError then Result:=trFileError; // Синхронизация подкаталогов
//                SyncDirs(syncdir+'\'+sr.Name,filesync,2,NTFSCopy,true); // Синхронизация подкаталогов
               end;
             end;
          end
         else // это файл
          begin
           if CheckFileMask(sr.Name,NumTask) then
           begin
           if not FileExists(filesync) then // файл источник не существует
             begin
             if TypeSync=ttZerk then // зеркалирование
               begin
                 if DeleteFile(syncdir+slash+sr.Name) then
                    begin
                    str:=syncdir+slash+sr.Name;
                    str:=Format(misc(rsLogDelFile,'rsLogDelFile'),[str]);
                    LogMessage(str);
                    end
                   else
                    begin
                    str:=syncdir+slash+sr.Name;
                    str:=Format(misc(rsLogDelFileErr,'rsLogDelFileErr'),[str]);
                    LogMessage(str);
                    end;
               end
              else // синхронизация
               begin
                 OnProgress (Nil,NewFile,sr.Name,sr.Size);
                 if Not SyncFiles(syncdir+slash+sr.Name,filesync,NTFSCopy,recurse) then Result:=trFileError; // синхронизация файлов
                 OnProgress (Nil,ProgressUpdate,'',sr.Size);
               end;
             end;
            end;
          end;
        end;
      until FindNext(sr) <> 0;
      FindClose(sr);
    end;
  end;
// потом директории
FileAttrs := faDirectory+faReadOnly+ faHidden+ faSysFile+ faArchive;
if FindFirst(dir+slash+'*', FileAttrs, sr) = 0 then
    begin
      repeat
        if (sr.Attr and faDirectory	) <>0 then
        begin
          if not SameText(sr.Name,'.') and not SameText(sr.Name,'..') then
           begin
           if CheckSubDir(dir+slash+sr.Name,NumTask) then
             if CopyDirs(dir+slash+sr.Name,syncdir+slash+sr.Name,NumTask,true,false)=trFileError then Result:=trFileError;
//             SyncDirs(dir+'\'+sr.Name,syncdir+'\'+sr.Name,TypeSync,NTFSCopy,true);
           end;
        end;
      until FindNext(sr) <> 0;
      FindClose(sr);
    end;
OnProgress (nil,EndOfBatch,'',0);    
end;
//=====================================================================
// Сврека даты/времени двух файлов
// Возвращает true если aDate>bDate и разница между ними <> ровно 1 час
// true - файл копировать, false - не копироваь
// aDate, bDate - Дата время двух файлов
function TTaskCl.CompareFileDate (aDate,bDate:integer):boolean;
var
 Hourd:Double;
 aaDate,bbDate:TDateTime;
begin
aaDate:=FileDateToDateTime(aDate); // Приводим к нормальному времени
bbDate:=FileDateToDateTime(bDate);
if CompareDateTime(aaDate,bbDate)>0 then // файл источник позже
  begin
     result:=true;
   hourd:=HourSpan(aaDate,bbDate); // разница в часах
   if hourd=1 then
       Result:=false
    else
      Result:=true;
   end
 else Result:=false;
end;
//======================================================================
// Расчет размера копируемой директории
function TTaskCl.GetSizeDir(dir,syncdir:string;NumTask:integer;Recurse:Boolean):integer;
var
  sr: TSearchRec;
  FileAttrs: Integer;
//  dir,syncdir:String;
  filesync:String;
 // NTFSCopy:Boolean;
  TypeSync:integer;
  sordata,destdata:TDateTime; // даты файлов источ и приемника
begin
if recurse AND Not Tasks[NumTask].SourceFilt.Recurse then exit; // подкаталоги не обрабатывать
if NOT recurse then TotalSize:=0;
TypeSync:=Tasks[NumTask].Action;
if Not Recurse  then
 begin
 if not DirectoryExists(dir) then // каталога-источника не существует
    begin
     exit; // айяй
    end;
 end;
FileAttrs := faReadOnly+ faHidden+ faSysFile+ faArchive+ faAnyFile;
// сначала файлы
if FindFirst(dir+slash+'*', FileAttrs, sr) = 0 then
    begin
      repeat
        begin

      if CheckFileMask(sr.Name,NumTask) then // Проверка файла на маску
        begin
        filesync:=syncdir+slash+sr.Name; // Имя файла приемника
        if FileExists(filesync) then // файл в каталоге приемнике уже есть
          begin // Тогда сверяются даты
            sordata:=FileDateToDateTime(sr.Time); // дата время модификации файла источника
            destdata:=FileDateToDateTime(FileAge(filesync));// дата файла премника
            if CompareDateTime(sordata,destdata)>0 then // файл источник позже
               begin
               TotalSize:=TotalSize+sr.size; // Добавляем размер файла
//               if Not SyncFiles(dir+'\'+sr.Name,filesync,NTFSCopy,recurse) then Result:=trFileError; // синхронизация файлов
               end;
            if TypeSync=ttSync then // если синхронизация
               begin
                  if CompareDateTime(destdata,sordata)>0 then // файл источник раньше
                      begin
                      TotalSize:=TotalSize+sr.size; // Добавляем размер файла
       //               if Not SyncFiles(filesync,dir+'\'+sr.Name,NTFSCopy,recurse) then Result:=trFileError; // синхронизация файлов наоборот
                      end;
               end;
           end
          else // файл приемник не существует
           begin
             TotalSize:=TotalSize+sr.size; // Добавляем размер файла
//             if Not SyncFiles(dir+'\'+sr.Name,filesync,NTFSCopy,recurse) then Result:=trFileError; // синхронизация файлов
             //LogMessage('Файл скопирован: '+filesync);
           end;
        end;// if checkfilemask
        end;
      until FindNext(sr) <> 0;
      FindClose(sr);
    end;
FileAttrs := faReadOnly+ faHidden+ faSysFile+ faArchive+ faAnyFile+faDirectory;
if (TypeSync=ttSync) OR (TypeSync=ttZerk) then // если синхронизация или зеркалирование
  begin
   if FindFirst(syncdir+slash+'*', FileAttrs, sr) = 0 then
    begin
      repeat
        begin
        filesync:=dir+slash+sr.Name; // Имя файла источника
        if ((sr.Attr and faDirectory) <>0) AND (CheckSubDir(filesync,NumTask)) then // это директория
          begin
           if not directoryexists(filesync) then // директория приемника не существует
             begin
             if TypeSync=ttZerk then // зеркалирование
               begin
//               DelDirs(syncdir+'\'+sr.Name);
//               LogMessage('Удалена директрория: '+syncdir+'\'+sr.Name);
               end
              else // синхронизирование
               begin
                GetSizeDir(syncdir+slash+sr.Name,filesync,NumTask,true); // Синхронизация подкаталогов
//                SyncDirs(syncdir+'\'+sr.Name,filesync,2,NTFSCopy,true); // Синхронизация подкаталогов
               end;
             end;
          end
         else // это файл
          begin
           if CheckFileMask(sr.Name,NumTask) then
           begin
           if not FileExists(filesync) then // файл источник не существует
             begin
             if TypeSync=ttZerk then // зеркалирование
               begin

               end
              else // синхронизация
               begin
                TotalSize:=TotalSize+sr.size; // Добавляем размер файла
//                 if Not SyncFiles(syncdir+'\'+sr.Name,filesync,NTFSCopy,recurse) then Result:=trFileError; // синхронизация файлов
               end;
             end;
            end;
          end;
        end;
      until FindNext(sr) <> 0;
      FindClose(sr);
    end;
  end;
// потом директории
FileAttrs := faDirectory+faReadOnly+ faHidden+ faSysFile+ faArchive;
if FindFirst(dir+slash+'*', FileAttrs, sr) = 0 then
    begin
      repeat
        if (sr.Attr and faDirectory	) <>0 then
        begin
          if not SameText(sr.Name,'.') and not SameText(sr.Name,'..') then
           begin
           if CheckSubDir(dir+slash+sr.Name,NumTask) then
             GetSizeDir(dir+slash+sr.Name,syncdir+slash+sr.Name,NumTask,true);
//             SyncDirs(dir+'\'+sr.Name,syncdir+'\'+sr.Name,TypeSync,NTFSCopy,true);
           end;
        end;
      until FindNext(sr) <> 0;
      FindClose(sr);
    end;



end;


//================================================================
// Простая шифрация строки

function TTaskCl.CryptStr(Str:string):string;
var
 len,i,intsym:integer;
 crypts:string;
 sym:string;
begin
crypts:='';
len:=Length(Str);
if len=0 then exit;
Randomize;
if len>1 then
   begin
      for i:=1 to len do
       begin;
          if i=len then intsym:=(33 XOR Ord(Str[i]))
            else intsym:=((Ord(Str[i]) XOR Ord(Str[i+1])));
       sym:=IntToHex(intsym,2);
       crypts:=crypts+sym;
       end;
   end
  else
   if len>0 then crypts:=IntToHex((ord(Str[1]) XOR 33),2);
crypts:=IntToHex((len XOR 35),2)+crypts; // добавление длины строки
crypts:=IntToHex(Random(200),2)+crypts; // случайная цифра

for i:=len to 30 do //добавление длины строки случайными цифрами
 begin
 crypts:=crypts+IntToHex(Random(200),2);
 end;

Result:=crypts;
end;
//========================================================================
// Дешифрация строки
function TTaskCl.DecryptStr(Str:string):string;
var
 len,i:integer;
 decrypts:string;
 sym:char;
begin
decrypts:='';
if Str='' then exit;
len:=HexStrToInt(Str,2) XOR 35;
if len>1 then
   begin
      for i:=len downto 1 do
       begin;
          if i=len then sym:=chr(33 XOR (HexStrToInt(Str,i+2)))
            else sym:=chr(HexStrToInt(Str,i+2) XOR ord(decryptS[len-i]));
       decrypts:=decrypts+sym;
       end;
   end
  else
   if len>0 then decrypts:=chr(HexStrToInt(Str,3) XOR 33);

Result:=ReverseString(decrypts);
end;
//===================================================
// Вспомогательная функция для DecryptStr
// Str функция состоящяя из Hex цифр (2 символа на цифру)
// Pos - нужная позиция (в одной позиции по 2 символа)
// Возвращает число из позиции
function TTaskCl.HexStrToInt(Str:String;Pos:integer):integer;
var
 intsym:integer;
 hexstr:string;
begin
 hexstr:='$'+str[pos*2-1]+str[pos*2];
 intsym:=StrToInt(hexstr);
 Result:=intsym;
end;
//===============================================================
// Функция стыбринная из библиотеки LCL
{------------------------------------------------------------------------------
  function FileInFilenameMasks(const Filename, Masks: string): boolean;

  Checks if 'Filename' fits to one of the mask in 'Masks'.
  Note: It checks the whole Filename. So, for example /somewhere/unit1.pas does
  not fit the mask 'unit*.pas', but it will fit '*.pas'.

  Masks is delimited by semicolon.
  Masks allows asterisk (*) for arbitrary text and question mark (?) for one
  arbitrary character.
  Examples:
    '*.pas;*.pp;*.inc'
    '*.tar.*'
    'lazarus*.xpm'
 ------------------------------------------------------------------------------}
{
function TTaskCl.FileInFilenameMasks(const Filename, Masks: string): boolean;
var
  TrimmedFile: String;
  MasksLen: Integer;
  MaskStartPos: Integer;
  MaskEndPos: Integer;
  MaskPos: LongInt;
  FilePos: Integer;
  FileLen: Integer;
  MaskChar: Char;
begin
  Result:=false;
  if (Filename='') or (Masks='') then exit;
  TrimmedFile:=TrimFilename(Filename); // only cleanup, do not expand
  if TrimmedFile='' then exit;
  // try each Mask
  MasksLen:=length(Masks);
  FileLen:=length(TrimmedFile);
  MaskEndPos:=1;
  repeat

    // find next Mask
    MaskStartPos:=MaskEndPos;
    while (MaskStartPos<=MasksLen) and (Masks[MaskStartPos]=';') do
      inc(MaskStartPos);
    if MaskStartPos>MasksLen then exit; // no mask -> end
    MaskEndPos:=MaskStartPos+1;
    while (MaskEndPos<=MasksLen) and (Masks[MaskEndPos]<>';') do
      inc(MaskEndPos);

    // check if mask fits to filename
    MaskPos:=MaskStartPos;
    FilePos:=1;
    while MaskPos<MaskEndPos do begin
      MaskChar:=Masks[MaskPos];
      case MaskChar of

      '?': begin
          // skip one character
          if FilePos>FileLen then break;
          inc(FilePos);
          inc(MaskPos);
        end;

      '*': begin
          // Anything. Will be handled by the 'else' part below
          inc(MaskPos);
          if MaskPos=MaskEndPos then
            FilePos:=FileLen+1;
        end;

      else
        begin
          if FilePos>FileLen then break;
          {$IFDEF WINDOWS}
          if UpperCaseTable[byte(MaskChar)]
            =UpperCaseTable[byte(TrimmedFile[FilePos])] then
          {$ELSE}
          if MaskChar=TrimmedFile[FilePos] then
          {$ENDIF}
          begin
            // character fits
            inc(MaskPos);
            inc(FilePos);
          end else begin
            //character does not fit
            // -> go back to last astersik (*)
            while (MaskPos>MaskStartPos) and (Masks[MaskPos-1]<>'*') do begin
              dec(MaskPos);
              dec(FilePos);
            end;
            if (MaskPos=MaskStartPos) then begin
              // there was no asterisk (*) => the filename does not fit this mask
              break;
            end else begin
              // there is an asterisk (*) => try the next position
              inc(FilePos);
            end;
          end;
        end;
      end;
    end;
    if (MaskPos=MaskEndPos) and (FilePos>FileLen) then begin
      // found
      Result:=true;
      exit;
    end;
  until false;
end;
 }
//------------------------------------------------------------------------------
// Вспомогательная функция для предыдущей функции
{------------------------------------------------------------------------------
  function TrimFilename(const AFilename: string): string;
 ------------------------------------------------------------------------------}
{
function TTaskCl.TrimFilename(const AFilename: string): string;
// trim double path delims, heading and trailing spaces
// and special dirs . and ..

  function FilenameIsTrimmed(const TheFilename: string): boolean;
  var
    l: Integer;
    i: Integer;
  begin
    Result:=false;
    if TheFilename='' then begin
      Result:=true;
      exit;
    end;
    // check heading spaces
    if TheFilename[1]=' ' then exit;
    // check trailing spaces
    l:=length(TheFilename);
    if TheFilename[l]=' ' then exit;
    i:=1;
    while i<=l do begin
      case TheFilename[i] of

      PathDelim:
        // check for double path delimiter
        if (i<l) and (TheFilename[i+1]=PathDelim) then exit;

      '.':
        if (i=1) or (TheFilename[i-1]=PathDelim) then begin
          // check for . directories
          if ((i<l) and (TheFilename[i+1]=PathDelim)) or ((i=l) and (i>1)) then exit;
          // check for .. directories
          if (i<l) and (TheFilename[i+1]='.')
          and ((i+1=l) or ((i+2<=l) and (TheFilename[i+2]=PathDelim))) then exit;
        end;

      end;
      inc(i);
    end;
    Result:=true;
  end;

var SrcPos, DestPos, l, DirStart: integer;
  c: char;
  MacroPos: LongInt;
begin
  Result:=AFilename;
  if FilenameIsTrimmed(Result) then exit;

  l:=length(AFilename);
  SrcPos:=1;
  DestPos:=1;

  // skip trailing spaces
  while (l>=1) and (AFilename[l]=' ') do dec(l);

  // skip heading spaces
  while (SrcPos<=l) and (AFilename[SrcPos]=' ') do inc(SrcPos);

  // trim double path delims and special dirs . and ..
  while (SrcPos<=l) do begin
    c:=AFilename[SrcPos];
    // check for double path delims
    if (c=PathDelim) then begin
      inc(SrcPos);
      {$IFDEF WINDOWS}
      if (DestPos>2)
      {$ELSE}
      if (DestPos>1)
      {$ENDIF}
      and (Result[DestPos-1]=PathDelim) then begin
        // skip second PathDelim
        continue;
      end;
      Result[DestPos]:=c;
      inc(DestPos);
      continue;
    end;
    // check for special dirs . and ..
    if (c='.') then begin
      if (SrcPos<l) then begin
        if (AFilename[SrcPos+1]=PathDelim)
        and ((DestPos=1) or (AFilename[SrcPos-1]=PathDelim)) then begin
          // special dir ./
          // -> skip
          inc(SrcPos,2);
          continue;
        end else if (AFilename[SrcPos+1]='.')
        and (SrcPos+1=l) or (AFilename[SrcPos+2]=PathDelim) then
        begin
          // special dir ..
          //  1. ..      -> keep
          //  2. /..     -> skip .., keep /
          //  3. C:..    -> keep
          //  4. C:\..   -> skip .., keep C:\
          //  5. \\..    -> skip .., keep \\
          //  6. xxx../..   -> keep
          //  7. xxxdir$Macro/..  -> keep
          //  8. xxxdir/..  -> trim dir and skip ..
          if DestPos=1 then begin
            //  1. ..      -> keep
          end else if (DestPos=2) and (Result[1]=PathDelim) then begin
            //  2. /..     -> skip .., keep /
            inc(SrcPos,2);
            continue;
          {$IFDEF WINDOWS}
          end else if (DestPos=3) and (Result[2]=':')
          and (Result[1] in ['a'..'z','A'..'Z']) then begin
            //  3. C:..    -> keep
          end else if (DestPos=4) and (Result[2]=':') and (Result[3]=PathDelim)
          and (Result[1] in ['a'..'z','A'..'Z']) then begin
            //  4. C:\..   -> skip .., keep C:\
            inc(SrcPos,2);
            continue;
          end else if (DestPos=3) and (Result[1]=PathDelim)
          and (Result[2]=PathDelim) then begin
            //  5. \\..    -> skip .., keep \\
            inc(SrcPos,2);
            continue;
          {$ENDIF}
          end else if (DestPos>1) and (Result[DestPos-1]=PathDelim) then begin
            if (DestPos>3)
            and (Result[DestPos-2]='.') and (Result[DestPos-3]='.')
            and ((DestPos=4) or (Result[DestPos-4]=PathDelim)) then begin
              //  6. ../..   -> keep
            end else begin
              //  7. xxxdir/..  -> trim dir and skip ..
              DirStart:=DestPos-2;
              while (DirStart>1) and (Result[DirStart-1]<>PathDelim) do
                dec(DirStart);
              MacroPos:=DirStart;
              while MacroPos<DestPos do begin
                if (Result[MacroPos]='$')
                and (Result[MacroPos+1] in ['(','a'..'z','A'..'Z']) then begin
                  // 8. directory contains a macro -> keep
                  break;
                end;
                inc(MacroPos);
              end;
              if MacroPos=DestPos then begin
                DestPos:=DirStart;
                inc(SrcPos,2);
                continue;
              end;
            end;
          end;
        end;
      end else begin
        // special dir . at end of filename
        if DestPos=1 then begin
          Result:='.';
          exit;
        end else begin
          // skip
          break;
        end;
      end;
    end;
    // copy directory
    repeat
      Result[DestPos]:=c;
      inc(DestPos);
      inc(SrcPos);
      if (SrcPos>l) then break;
      c:=AFilename[SrcPos];
      if c=PathDelim then break;
    until false;
  end;
  // trim result
  if DestPos<=length(AFilename) then
    SetLength(Result,DestPos-1);
end;


 }

end.

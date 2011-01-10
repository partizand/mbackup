unit TaskUnit;

{
// Модуль содержащий класс TTaskCl.
Работа с заданиями


}
{$mode objfpc}{$H+}

interface

uses Windows, SysUtils, DateUtils, Classes, StrUtils, masks, Process,//fileutil,
  {iniLangC,} XMLCfg,{ inifiles,}setunit,gettext,translations,unitfunc,idsmtp,idmessage,{idAttachment,}
  idAttachmentFile;


//uses FileCtrl;

{

{$IFDEF WINDOWS}
const
  slash = '\'; DirectorySeparator
  {$ElSE}
const
  slash = '/';
{$Endif}
 }
const
  VersionAS   = '0.4.0'; // Версия программы
  TempLogName = 'log.txt'; // Имя временного лог файла (отправляемого по почте)

const
   DeletedFilesF='deleted$.xml'; // Файл для хранения сведений об удаленных файлах

const
  MaxTasks = 100; // Макс количество заданий
  MaxPChar = 250;
// Макс длина строки запуска внешнего приложения


const         // Константы результата выполнения задачи
  trOk    = 0; // Все ок
  trFileError = 10; // Ошибка копирования файла в задании
  trError = 20; // Ошибка запуска задания (недоступен каталог)


type
  TMailAlert = (None = 0, OnlyError = 1, Enabled = 2);

const        // Тип уведомлений по почте
  alertNone   = 0; // Выключить уведомления
  alertErr    = 1; // Уведомления только при ошибках
  alertAlways = 2; // уведомлять всегда



const         // Константы состояния выполнения задания
  stNone    = 0; // Не выполняется
  stRunning = 1; // Выполняется в данный момент
  stWaiting = 2; // Ожидает выполнения

const           // Константы типа задачи
  ttCopy   = 1; // Копирование
  ttZerk   = 2; //Зеркалирование
  ttSync   = 3; //Сихронизирование
  ttArhRar = 5; //Архивирование Rar
  ttArhZip = 4; //Архивирование Zip
  ttArh7Zip =6; //Архивирование 7Zip

const       // Константы типа сортировки файлов источника
  tsNoMask = 0; // Исключая
  tsMask   = 1; // Только по маске

type               // Список файлов для обработки удаления старых архивов
    TArhList=record
    NameFile:string;  // Имя файла
    DateFile:TDateTime; // Дата файла
    IsYear:boolean; // Годовой
    IsMonth:boolean; // Месячный
    IsDay:boolean;  // Дневной
    IsStay:boolean; // Не удалять (все вместе, дубляж)
    end;


type // Тип ProgressType для типа события OnProgress
  ProgressType = (NewFile, ProgressUpdate, EndOfBatch, TotalFiles2Process,
    TotalSize2Process, NewExtra, ExtraUpdate, MsgCopy);


// Процедурный тип  (событие, совпадает с описанием события TZipMaster)

type
  TProgressEvent = procedure(Sender: TObject; ProgrType: ProgressType;
    Filename: string; FileSize: int64) of object;

type    // Парметры расписания
  TRasp = record
    //  Time:TDateTime; // Время начала
    OnceForDay: boolean; // Запускать только раз в сутки
    //   Time:TDateTime; // Время начала
    //   AtTime:Boolean; // Запуск в заданное время
    //   Manual:Boolean; // Запуск вручную
    //   AtStart:Boolean; // Запуск при загрузке программы
    //   EvMinutes:Boolean; // Через каждые Minutes в теч дня
    //   Minutes:integer; // Через каждые столько минут в течении дня
  end;

type  //параметры архива
  TArh = record
    Name:      string;  // имя архива
    DelAfterArh:boolean; // Удалять архивы после упаковки (только Rar)
    DelOldArh: boolean; //Удалять старые архивы
    DaysOld:   integer; // старше дней
    MonthsOld: integer; // страше месяцев
    YearsOld:  integer; // страше лет
  end;

type // Параметры запуска внешних программ до и после задания
  TExtProgs = record
    BeforeStart: boolean;
    // Запускать программу до начала задания
    BeforeName:  string; // Имя файла для запуска
    AfterStart:  boolean; // Запускать программу после задания
    AfterName:   string; // Имя файла для запуска
  end;


type // Параметры фильтрации файлов и каталогов источника
  TSourceFilt = record
    Recurse:    boolean;     // Обрабатывать подкаталоги
    FiltSubDir: boolean;     // За исключением подкаталогов
    SubDirs:    TStringList; // список исключаемых каталогов
    FiltFiles:  boolean;     // фильтровать файлы по условию
    ModeFiltFiles: integer;
    //  режим фильтрации Задается константами 0-исключая файлы по маске (ниже), 1-Только файлы по маске
    FileMask:   TStringList; // список масок файлов
  end;

type  // Запись для параметров одного копирования
  TTask = record
    //    ProfName:String; // Имя конфигурации
    Enabled:  boolean; // задание разрешено
    Name:     string; // Имя задания
    Status:   integer;
    // Статус задания, см константы stNone,stRuning,stWaiting
    LastResult: integer;
    // Результат последнего выполнения true-ok false-ошибка
    LastRunDate: TDateTime;
    // Дата и время последнего запуска задания
    SorPath:  string; // каталг источник
    DestPath: string; // каталог приемник
    Action:   integer; // действие
    MailAlert: integer; // Уведомления по почте
    Rasp:     TRasp; // Расписание
    Arh:      TArh; // параметры архива
    NTFSPerm: boolean; // Копировать права NTFS
    ExtProgs: TExtProgs; // Внешние программы
    SourceFilt: TSourceFilt;
    // условия фильтрации файлов и папок источника
  end;
       //--------------------------------------------------------------
// Класс хранения сведений об удаленных файлах
// Массив: Имя файла, дата удаления из источника
type
 TDeletedFiles=class
   constructor Create(RootDirName:string);
   destructor Destroy;
   Count:integer; // Кол-во файлов
   DirName:string; // Каталог, где все происходит
   function GetIndex(FileName:string):integer;
   function GetName(Index:integer):string;
   function GetDate(Index:integer):TDateTime;
   function Add(FileName:string):integer;
   procedure Delete(Index:integer);
   procedure SaveToFile;

 private
   procedure LoadFromFile;
   NameList:TStringList; // Список имен файлов
   DateList:TStringList; // Список дат файлов
  // Delimiter:string; // Разделитель целой и дробной части в float
//   DateArray:array[0..100] of TDateTime; // если файлов не больше 100, используем этот массив
 end;


  //--------------------------------------------------------------
type
  TTaskCl = class
    Tasks: array[1..MaxTasks] of TTask; //Массив заданий
    //  ZipMaster:TZipMaster;
    //  procedure OnProgress; // Событие

    // Типа конструктор
    constructor Create;
    destructor Destroy;

    procedure AddTask;
    procedure DelTask(numTask: integer);
    procedure LoadFromFile(filenam: string);
    procedure SaveToFile(filenam: string);
    function RunTask(num: integer; countsize: boolean): integer;
    function FindTaskSt(state: integer): integer;
    // procedure RunThTask(num:integer);

    //  procedure SyncFiles(sorfile,destfile:string;NTFSCopy:Boolean);
    function CopyNTFSPerm(sorfile, destfile: string): boolean;
    function NTSetPrivilege(sPrivilege: string; bEnabled: boolean): boolean;
    // function SyncDirs(dir,syncdir:string;TypeSync:Integer;NTFSCopy:Boolean;Recurse:Boolean):boolean;

    function CheckFileMask(FileName: string; NumTask: integer): boolean;
    function CheckSubDir(SubDir: string; NumTask: integer): boolean;
    //  procedure SyncDirs(dir,syncdir:string;Sync:Boolean);

    procedure LogMessage(logmes: string);
    procedure LogMessage(MesStrings: TStringList);
    //function ArhDir(sourdir,destdir:string;arhname:string):boolean;
    function ArhRarDir(NumTask: integer): integer;
    //function ArhZipDir(numtask: integer): integer;
    function Arh7zipDir(NumTask: integer): integer;
    function SendMail(Subj:string;Body:string;FileName:string;var MsgError:string):boolean;



    //  procedure DelOldArhs(dir,arhname:string;olddays,oldMonths,OldYears:integer);
    //  function WinExecute(CmdLine: string; Wait: Boolean): Boolean;


    //function  GetFileNam(shortnam:String):String;
    procedure DublicateTask(NumTask: integer);
    //procedure TaskCopy(NumTask:integer);
    procedure CopyTask(FromTask, ToTask: integer);
    procedure UpTask(NumTask: integer);
    procedure DownTask(NumTask: integer);
    function GetSizeDir(dir, syncdir: string; NumTask: integer; Recurse: boolean): integer;
    procedure ReplaceNameDisk(NumTask: integer; replace: boolean);
//    function ShortFileNam(FileName: string): string;
//    function FullFileNam(FileName: string): string;
    function CryptStr(Str: string): string;
    function DecryptStr(Str: string): string;


    procedure Clear; // Очистка списка заданий
   // procedure ReadIni;
//    procedure SaveIni;
    function ReadArgv(var IsProfile: boolean): boolean;
    function GetVer: string;

    //  procedure SendMail(MesSubject:string;MesBody:TStrings);
    //  procedure StrToList (Str:string;var StrList:StringList);
  private
    //procedure CheckFileSize(FileNam:string);
    procedure WriteFileStr(filenam, str: string);
    function DelDirs(dir: string): integer;
    function DelFile(namef: string): integer;
    function ForceDir(DirName: string): boolean;
    function SyncFiles(sorfile, destfile: string; NTFSCopy: boolean; recurse: boolean): boolean;
    // Выполнение внешней программы (платформо независимая)
    function ExecProc(const FileName, Param: string; const Wait: boolean): integer;

    function BuildRarFileList(NumTask: integer): string; // Построение командной строки для архивации RAR

    function Build7zipFileList(NumTask:integer;ArhFileName:string):string; // Построение командной строки для архивации 7zip
    procedure GetFileList(sordir: string; NumTask: integer; var FileList: TStrings; recurse: boolean; ForZip: boolean);
    function GetArhFileName(numtask:integer):string;
//    function GetArhName(numtask: integer;ArhFileName:string): string;
    function GetArhName(numtask: integer;ArhFileName:string;IgnoreTmpDir:boolean;var TmpExist:boolean): string;
    function ReplaceParam(S:string;numtask:integer):string;
    // Выполнение внешней программы (Win)
  //  function WinExec(const FileName, Param: string; const Wait: boolean;const WinState: word): boolean;

    function PathCombine(Path1: string; Path2: string): string;

    Function DosToWin(Const S: String) : String;
    //  function CompareFileDate (aDate,bDate:integer):boolean;
    function CompareFileDate(aFileName, bFileName: string): boolean;

    procedure DelOldArhs(NumTask: integer);
 //   function MinInMonth(ArhList:TArhList;FindDate:TDateTime):integer;
//    function MinInYear(ArhList:TArhList;FindDate:TDateTime):integer;
    function MinInRange(ArhList:array of TArhList;DateBeg,DateEnd:TDateTime):integer;

    procedure SaveToXMLFile(filenam: string);
    procedure LoadFromXMLFile(filenam: string);
    function HexStrToInt(Str: string; Pos: integer): integer;
    function CheckDirs(NumTask: integer): boolean;
    function ReplDate(S: string): string;
    function FindStrVar(S: string): string;
    //  function FileInFilenameMasks(const Filename, Masks: string): boolean;
    //  function TrimFilename(const AFilename: string): string;
    function CopyDirs(dir, syncdir: string; NumTask: integer; Recurse: boolean;
      countsize: boolean): integer;

    function CopyDir(NumTask:integer):integer;
    function SynDir(NumTask:integer):integer;
    function ZerkDir(NumTask:integer):integer;


    function SimpleCopyDirs(SorDir, DestDir: string; NumTask: integer; Recurse: boolean;NTFSCopy:boolean): integer;
    function DelOldFiles(SorDir, DestDir: string; NumTask: integer; Recurse: boolean): integer;

//    function MaxTaskResult(Res1,Res2:integer):integer;

    TotalSize:  int64; // Общий размер файлов при копировании
    TempSorPath, TempDestPath: string;
    // Временное хранение источника и приемника для перобразования %disk%
    LastStdOut: TStringList;
 //   DelFiles:TDeletedFiles;
    // Вывод последнего запущенного процесса
  public
    Settings:TSettings;
    // Эта функция не определяется в этом файле
    OnProgress: TProgressEvent; // Процедура события обновления %
    //----
    // Параметры запуска
    ParamQ:   boolean;
    // -q  В строке запуска есть команда выхода по окончании
    InCmdMode: boolean;
    // Запуск заданий происходит из командной строки (для одно разово дневных заданий)
    Count:    integer; //Количество заданий
     {
    SysCopyFunc: boolean;
    // Использовать системную функцию копирования
    //---

    //----
    // Настройки из ini файла
    logfile:  string; // Имя лог файла короткое
    loglimit: integer; // ограничение лог файла в килобайтах
    LangFile: string; // Имя языкового файла

    LoadLastProf: boolean; // загружать последний профиль
    DefaultProf: string;
    // профиль по умолчанию при запуске программы
    profile:  string; // имя файла текущего профайла
    // Настройки уведомлений по почте
    email:    string;
    // почтовый ящик на который отсылаются уведомления
    //  alerttype:integer; // Тип уведомлений (нет, ошибки, всегда, см константы)
    smtpserv: string;  // Адрес smtp сервера
    smtpport: integer; // порт сервера
    smtpuser: string;  // Пользователь сервера
    smtppass: string;  // Пароль
    mailfrom: string; // Почт адрес от имени которого высылаются уведомления
    }
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

uses msgstrings{, SendMailUnit}{,potranslator};

// Функции класса TDeletedFiles
 //=====================================================
 // Конструктор
constructor TDeletedFiles.Create(RootDirName:string);
//var
begin
  inherited Create;
  Count  := 0;
  NameList := TStringList.Create;
  DateList := TStringList.Create;
  DirName:=RootDirName;
  LoadFromFile;
end;

 // Деструктор
destructor TDeletedFiles.Destroy;
begin
NameList.Destroy;
DateList.Destroy;
inherited Destroy;
end;

// Возвращает индекс файла по его имени
// Если файла нет возвращается -1
function TDeletedFiles.GetIndex(FileName:string):integer;
begin
Result:=NameList.IndexOf(FileName);
end;
// Возвращает имя файла по индексу
function TDeletedFiles.GetName(Index:integer):string;
begin
if Count>Index then
    Result:=NameList[Index]
   else
     Result:='';
end;
// Возвращает дату файла по индексу
function TDeletedFiles.GetDate(Index:integer):TDateTime;
var
 DateFormat:TFormatSettings;
begin
if Count>Index then
    begin

//     GetLocaleFormatSettings(0,DateFormat);
     DateFormat.DateSeparator:='.';
     DateFormat.DecimalSeparator:='.';
//     DateFormat.LongDateFormat:='dd.MM.yyyy';
//     DateFormat.ShortDateFormat:='dd.MM.yyyy';
//     Result:=StrToDateTime(DateList[Index],DateFormat);
     Result:=StrToFloat(DateList[Index],DateFormat)
     end


   else
     Result:=0;
end;
// Добавление данных о файле
function TDeletedFiles.Add(FileName:string):integer;
var
 strDate:string;
 DateFormat:TFormatSettings;
begin
Result:=-1;
if GetIndex(FileName)>-1 then exit;
NameList.Add(FileName);
DateFormat.DateSeparator:='.';
DateFormat.DecimalSeparator:='.';
strDate:= FloatToStr(Now,DateFormat);
DateList.Add(strDate);
Count:=Count+1;
Result:=Count;
end;
// Удаление данных о файле
procedure TDeletedFiles.Delete(Index:integer);
begin
NameList.Delete(Index);
DateList.Delete(Index);
Dec(Count);
end;
// Запись в файл
procedure TDeletedFiles.SaveToFile;
var
  i: integer;
  xmldoc: TXMLConfig;
  sec,SaveFileName: string;
//  Attr:integer;
begin
SaveFileName:=DirName+DirectorySeparator+DeletedFilesF;
if Count>0 then
  begin
//  if FileExists(SaveFileName) then // Сбрасываем атрибут скрытый
//    begin
//    FileSetAttr(SaveFileName, 0);
//    end;
  if Not DirectoryExists(DirName) then exit;
  xmldoc := TXMLConfig.Create(nil);
  xmldoc.StartEmpty := True;
  xmldoc.Filename := SaveFileName; //'probcfg.xml';
  xmldoc.RootName := 'mBackup';
  // Версия программы
//  xmldoc.SetValue('version/value', versionas);
  // количество заданий
  xmldoc.SetValue('deleted/count/value', Count);
  for i := 0 to Count-1 do
  begin
    // Имя секции с заданием
    sec := 'Deleted/File' + IntToStr(i) + '/';

    xmldoc.SetValue(sec + 'name/value', NameList[i]); // Имя файла
    xmldoc.SetValue(sec + 'txtdate/value', DateList[i]); // Текстовая дата файла
   // if i<100 then
   //    xmldoc.SetValue(sec + 'date/value', DateArray[i]); // Нормальная дата файла

  end;
  xmldoc.Flush;
  xmldoc.Destroy;
 // Attr:=faHidden;
  FileSetAttr(SaveFileName, faHidden);


 end
  else
    begin
    if FileExists(SaveFileName) then
          begin
            // Удаляем файл
          try
            SysUtils.DeleteFile(SaveFileName);
          except
          end;
         end;

    end;

end;
// Чтение из файла
procedure TDeletedFiles.LoadFromFile;
var
  i: integer;
  xmldoc:  TXMLConfig;
  sec,SaveFileName:     string;
  //strDate: string;
begin
  SaveFileName:=DirName+DirectorySeparator+DeletedFilesF;
     NameList.Clear;
    DateList.Clear;
    Count:=0;
  if not FileExists(SaveFileName) then
    begin
    exit;
    end;
  FileSetAttr(SaveFileName, 0);
  xmldoc := TXMLConfig.Create(nil);
  //xmldoc := TXMLConfig.Create(SaveFileName);

  xmldoc.StartEmpty := False; //false;
  xmldoc.RootName   := 'mBackup';
  xmldoc. flush;
  xmldoc.Filename := SaveFileName;

  // количество заданий
  Count := xmldoc.GetValue('deleted/count/value', 0);
  if Count = 0 then exit;

  for i := 0 to Count-1 do
  begin
    sec := 'Deleted/File' + IntToStr(i) + '/';
    NameList.Add(xmldoc.GetValue(sec + 'name/value', ''));
    DateList.Add(xmldoc.GetValue(sec + 'txtdate/value', ''));
 //   if i<100 then DateArray[i]:= xmldoc.GetValue(sec + 'date/value', '');
  end;
  xmldoc.Destroy;
end;


// конец функций класса TDeletedFiles
//==============================================================













 //=====================================================
 // Конструктор
constructor TTaskCl.Create;
begin
  inherited Create;
  Count  := 0;
  LastStdOut := TStringList.Create;
 // DelFiles:=TDeletedFiles.Create;
   Settings:=TSettings.Create;


  //TranslateUnitResourceStrings('msgstrings',ansitoutf8(ExtractFileDir(ParamStr(0)))+DirectorySeparator+'Lang'+DirectorySeparator+'msgstrings.'+Settings.Lang+'.po');
  TranslateUnitResourceStrings('msgstrings',ansitoutf8(ExtractFileDir(ParamStr(0)))+DirectorySeparator+'Lang'+DirectorySeparator+'mbackupw.'+Settings.Lang+'.po');

  //ReadIni;
  //CL:=LoadLangIni(LangFile);
end;
 //=====================================================
 // Деструктор
destructor TTaskCl.Destroy;
begin
LastStdOut.Destroy;
Settings.Destroy;
//DelFiles.Destroy;
inherited Destroy;
end;
//==============================================================
Function TTaskCl.DosToWin(Const S: String) : String;
 { Конвертирует строку из кодировки DOS в Win кодировку }
var
  Ch: PChar;
begin
  Ch := StrAlloc(Length(S) + 1);
  OemToAnsi(PChar(S), Ch);
  Result := Ch;
  StrDispose(Ch);
end;
 //=====================================================
 // Возвращает версию программы
function TTaskCl.GetVer: string;
begin
  Result := VersionAS;
end;
  {
 //=====================================================
 // Чтение настроек программы из Ini файла
procedure TTaskCl.ReadIni;
//===================================================
var
  SaveIniFile: TIniFile;
  IniName:     string;
begin
  IniName := FullFileNam('mbackup.ini');// ExtractFileDir(ParamStr(0))+'\'+'autosave.ini';

  SaveIniFile := TIniFile.Create(IniName);
  logfile     := SaveIniFile.ReadString('log', 'logfile', 'autosave.log');

  loglimit := SaveIniFile.ReadInteger('log', 'loglimit', 500);
  //IsClosing:=SaveIniFile.ReadBool('common', 'MinimizeToTray',true);
  //AutoOnlyClose:=SaveIniFile.ReadBool('common', 'AutoOnlyClose',false);
  //StartMin:=SaveIniFile.ReadBool('common', 'StartMinimized',false);
  // Язык
  //LangFile := SaveIniFile.ReadString('Language', 'LangFile', 'english.lng');
  Lang := SaveIniFile.ReadString('Language', 'Lang', '');
  SysCopyFunc := SaveIniFile.ReadBool('settings', 'SysCopyFunc', True);


  // настройка профилией
  LoadLastProf := SaveIniFile.ReadBool('profile', 'LoadLastProf', False);
  // загружать последний профиль
  DefaultProf  := SaveIniFile.ReadString('profile', 'DefaultProf', 'default.xml');
  profile      := DefaultProf;

  email    := SaveIniFile.ReadString('alerts', 'email', 'your@email');
  //alerttype:=SaveIniFile.ReadInteger('alerts', 'alerttype', alertNone);
  smtpserv := SaveIniFile.ReadString('alerts', 'smtpserv', 'smtp.server');
  smtpport := SaveIniFile.ReadInteger('alerts', 'smtpport', 25);
  //smtpuser:=SaveIniFile.ReadString('alerts', 'smtpuser', '');
  //smtppass:=DecryptStr(SaveIniFile.ReadString('alerts', 'smtppass', ''));
  mailfrom := SaveIniFile.ReadString('alerts', 'mailfrom', 'from@mail');

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
  //  cr:string;
  IniName, dp: string;
begin
  IniName     := ExtractFileDir(ParamStr(0)) + slash + 'mbackup.ini';
  SaveIniFile := TIniFile.Create(IniName);
  SaveIniFile.WriteString('log', 'logfile', logfile);
  SaveIniFile.WriteInteger('log', 'loglimit', loglimit);


  SaveIniFile.WriteString('alerts', 'email', email);
  //SaveIniFile.WriteInteger('alerts', 'alerttype', alerttype);
  SaveIniFile.WriteString('alerts', 'smtpserv', smtpserv);
  SaveIniFile.WriteInteger('alerts', 'smtpport', smtpport);
  //SaveIniFile.WriteString('alerts', 'smtpuser', smtpuser);
  //cr:=CryptStr(smtppass);
  //SaveIniFile.WriteString('alerts', 'smtppass', CryptStr(smtppass));
  SaveIniFile.WriteString('alerts', 'mailfrom', mailfrom);

  // Язык
  //SaveIniFile.WriteString('Language', 'LangFile', LangFile);
  SaveIniFile.WriteString('Language', 'Lang', Lang);

  SaveIniFile.WriteBool('settings', 'SysCopyFunc', SysCopyFunc);

  SaveIniFile.WriteBool('profile', 'LoadLastProf', LoadLastProf);
  dp := DefaultProf;
  if LoadLastProf then
    dp := profile;
  SaveIniFile.WriteString('profile', 'DefaultProf', dp);
  SaveIniFile.Destroy;// Free;
end;
 }
 //=======================================================
 // Чтение командной строки
 // Загружает нужный профиль и
// Возвращает true если нужно запускать задания из этого профиля
// IsProfile - true-обработка профиля, иначе задача задана из командной строки
function TTaskCl.ReadArgv(var IsProfile: boolean): boolean;
  //=====================================================
var
  j, i:     integer;
  s, p:     string;
  sour, dest: string; // Источник, получатель
  act:      integer;  // действие
  recurs:   boolean;  // Обрабатывать рекурсивно
  alertmes: string;   //TStrings;
//  SendMail: TSendMail;
  // est:boolean;
  MsgErr:string;
  estp:     boolean; // Есть профиль на загрузку
  estr:     boolean; // Есть параметр /r
begin
  //alertmes:='';TStringList.Create;
  j      := paramcount; // Кол-во параметров командной строки
  ParamQ := False; // Есть параметр закрыть прогу
  sour   := '';    // Источник и приемник не указаны
  dest   := '';
  recurs := False;
  act    := 0; // Действие не указано
  estp   := False;
  IsProfile := False;
  estr   := False;
  Clear; //Count:=0;
  for i := 1 to j do // перебор всех параметров
  begin
    s := ParamStr(i); // s очередной параметр
    if SameText(s, '-r') then // автозапуск заданий
    begin
      estr := True;
    end; // end if r
    if SameText(s, '-q') then // Выход по завершению заданий
    begin
      ParamQ := True;
      //   Estp:=true;
    end;
    if SameText(s, '-alert') then // Уведомление о запуске
    begin
      AlertMes := rsAlertRunMes;
   //   SendMail := TSendMail.Create;
     SendMail(rsAlertRunSubj,AlertMes, '',MsgErr);
//      SendMail.Send(Settings.smtpserv, Settings.smtpport, Settings.mailfrom, Settings.email, rsAlertRunSubj, AlertMes, '');
//      SendMail.Destroy;
      //    TaskCl.SendMail(misc(rsAlertRunSubj,'rsAlertRunSubj'),AlertMes);
    end;
    if SameText(s, '-p') then // загрузка профиля
    begin
      //    i:=i+1;
      if i + 1 <= j then
        p := ParamStr(i + 1)
      else
        continue;
      Clear; //Count:=0;
      LoadFromFile(p);
      estp      := True;
      IsProfile := True;
    end;
    if SameText(s, '-log') then // Указание лог файла
    begin
      if i + 1 <= j then
        p := ParamStr(i + 1)
      else
        continue;
      Settings.logfile := p;
    end;
    //--------
    if SameText(s, '-source') then // Указание источника
    begin
      if i + 1 <= j then
        p := ParamStr(i + 1)
      else
        continue;
      sour := p;
    end;
    //--------
    if SameText(s, '-recurse') then // Указание действия copy
    begin
      recurs := True;
    end;

    //--------
    if SameText(s, '-dest') then // Указание получателя
    begin
      if i + 1 <= j then
        p := ParamStr(i + 1)
      else
        continue;
      dest := p;
    end;
    //--------
    if SameText(s, 'copy') then // Указание действия copy
    begin
      act := ttCopy;
    end;
    //--------
    if SameText(s, 'sync') then // Указание действия sync
    begin
      act := ttSync;
    end;
    //--------
    if SameText(s, 'mirr') then // Указание действия mirr
    begin
      act := ttZerk;
    end;

  end;

  if not estp then
    // профиля на загрузку нет берем дефолтовый
  begin
    if act = 0 then
      // действие не указано берем дефолтовый профиль
    begin
      LoadFromFile('');
      IsProfile := True;
    end
    else  // строим задание из параметров запуска
    begin
      if (Length(sour) <> 0) and (Length(dest) <> 0) then
      begin
        Clear;
        AddTask;
        Tasks[1].Name := 'Cmd';
        Tasks[1].Action := act;
        Tasks[1].SorPath := sour;
        Tasks[1].DestPath := dest;
        Tasks[1].SourceFilt.Recurse := recurs;
        estr := True;
      end;

    end;
  end;


  //InCmdMode:=estr;
  Result := estr; // Есть ли задания на запуск
  //alertmes.Destroy;// Free;
end;



 //================================================================
 // добавление пустого задания в массив
procedure TTaskCl.AddTask;
begin
  // Найти свободный элемент
  if Count = MaxTasks then
    exit;
  Inc(Count);
  Tasks[Count].Name      := '';
  Tasks[Count].SorPath   := '';
  Tasks[Count].DestPath  := '';
  Tasks[Count].Action    := 0;
  Tasks[Count].Arh.Name  := 'arh%YYMMDD%';
  //Tasks[count].Rasp.Time:=GetLocalTime;
  Tasks[Count].Rasp.OnceForDay := False;
  //Tasks[count].Rasp.Time:=Time;
  //GetLocalTime(Tasks[count].Rasp.Time);
  //Tasks[count].Rasp.EvMinutes:=false;
  //Tasks[count].Rasp.Minutes:=60;
  Tasks[Count].Enabled   := True;
  //Tasks[count].Rasp.Manual:=true;
  //Tasks[count].Rasp.AtStart:=false;
  //Tasks[count].Rasp.AtTime:=false;
  Tasks[Count].Arh.DelOldArh := False;
  Tasks[Count].Arh.DelAfterArh := False;
  Tasks[Count].Arh.DaysOld := 7;
  Tasks[Count].Arh.MonthsOld := 12;
  Tasks[Count].Arh.YearsOld := 5;
  Tasks[Count].Enabled   := True;
  Tasks[Count].Status    := stNone;
  Tasks[Count].LastRunDate := 0;
  Tasks[Count].LastResult := trOk;
  Tasks[Count].ExtProgs.BeforeStart := False;
  Tasks[Count].ExtProgs.BeforeName := '';
  Tasks[Count].ExtProgs.AfterStart := False;
  Tasks[Count].ExtProgs.AfterName := '';
  Tasks[Count].NTFSPerm  := False;
  Tasks[Count].MailAlert := 0;

  Tasks[Count].SourceFilt.Recurse    := True;
  Tasks[Count].SourceFilt.FiltSubDir := False;
  Tasks[Count].SourceFilt.SubDirs    := TStringList.Create;
  Tasks[Count].SourceFilt.SubDirs.Delimiter := ';';
  //Tasks[count].SourceFilt.SubDirs.Clear;
  Tasks[Count].SourceFilt.FiltFiles  := False;
  Tasks[Count].SourceFilt.ModeFiltFiles := 0;
  Tasks[Count].SourceFilt.FileMask   := TStringList.Create;
  Tasks[Count].SourceFilt.FileMask.Delimiter := ';';
  Tasks[Count].SourceFilt.FileMask.Add('*.tmp');
  Tasks[Count].SourceFilt.FileMask.Add('*.bak');
end;
 //============================================================
 // Очистка списка заданий
procedure TTaskCl.Clear;
var
  i: integer;
begin
  for i := 1 to Count do
  begin
    Tasks[i].SourceFilt.SubDirs.Destroy;
    Tasks[i].SourceFilt.FileMask.Destroy;
  end;
  Count := 0;
end;
//=========================================================
// Поиск задания со статусом state, возвращает его номер
// Если не найдено возварщается -1
// Находит первое попавшееся задание с таким статусом
function TTaskCl.FindTaskSt(state: integer): integer;
var
  i: integer;
begin
  Result := -1;
  for i := 1 to Count do
  begin
    if Tasks[i].Status = state then
    begin
      Result := i;
      break;
    end;
  end;
end;
 //=========================================================
 // Удаление из набора задния NumTask
procedure TTaskCl.DelTask(numTask: integer);
var
  i: integer;
begin
  if numTask > Count then
    exit;
  if numTask < 1 then
    exit;
  for i := numTask + 1 to Count do
  begin
    CopyTask(i, i - 1);

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
  Tasks[Count].SourceFilt.SubDirs.Free;
  Tasks[Count].SourceFilt.FileMask.Free;
  Dec(Count);
end;
//==================================================
//   Копирование задания с номером FromTask в задание с номером ToTask
//--------------------------------------------------------------------
procedure TTaskCl.CopyTask(FromTask, ToTask: integer);
begin
  if (FromTask > Count) or (ToTask > Count) then
    exit;
  Tasks[ToTask].Enabled  := Tasks[FromTask].Enabled; // задание разрешено
  Tasks[ToTask].Name     := Tasks[FromTask].Name;
  Tasks[ToTask].Status   := Tasks[FromTask].Status;
  Tasks[ToTask].LastResult := Tasks[FromTask].LastResult;
  Tasks[ToTask].LastRunDate := Tasks[FromTask].LastRunDate;
  Tasks[ToTask].SorPath  := Tasks[FromTask].SorPath;
  Tasks[ToTask].DestPath := Tasks[FromTask].DestPath;
  Tasks[ToTask].Action   := Tasks[FromTask].Action;
  Tasks[ToTask].Rasp     := Tasks[FromTask].Rasp;
  Tasks[ToTask].Arh      := Tasks[FromTask].Arh;
  Tasks[ToTask].NTFSPerm := Tasks[FromTask].NTFSPerm;
  Tasks[ToTask].ExtProgs := Tasks[FromTask].ExtProgs;

  Tasks[ToTask].SourceFilt.Recurse    := Tasks[FromTask].SourceFilt.Recurse;
  Tasks[ToTask].SourceFilt.FiltSubDir := Tasks[FromTask].SourceFilt.FiltSubDir;
  Tasks[ToTask].SourceFilt.FiltFiles  := Tasks[FromTask].SourceFilt.FiltFiles;
  Tasks[ToTask].SourceFilt.ModeFiltFiles := Tasks[FromTask].SourceFilt.ModeFiltFiles;
  Tasks[ToTask].SourceFilt.SubDirs.Assign(Tasks[FromTask].SourceFilt.SubDirs);
  Tasks[ToTask].SourceFilt.FileMask.Assign(Tasks[FromTask].SourceFilt.FileMask);
end;
 //==================================================
 //   Поднять задание вверх по списку
 //--------------------------------------------------------------------
procedure TTaskCl.UpTask(NumTask: integer);
begin
  if NumTask <= 1 then
    exit;
  AddTask;
  CopyTask(NumTask, Count);
  CopyTask(NumTask - 1, NumTask);
  CopyTask(Count, NumTask - 1);
  DelTask(Count);
end;
 //==================================================
 //   Опустить задание вниз по списку
 //--------------------------------------------------------------------
procedure TTaskCl.DownTask(NumTask: integer);
begin
  if NumTask > Count - 1 then
    exit;
  AddTask;
  CopyTask(NumTask, Count);
  CopyTask(NumTask + 1, NumTask);
  CopyTask(Count, NumTask + 1);
  DelTask(Count);
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
{
function TTaskCl.WinExec(const FileName, Param: string; const Wait: boolean;
  const WinState: word): boolean;
var
  StartInfo: TStartupInfo;
  ProcInfo: TProcessInformation;
  CmdLine: string;
  buf: array [0..MaxPChar] of char;
begin
  { Помещаем имя файла между кавычками, с соблюдением всех пробелов в именах Win9x }
  CmdLine := '"' + Filename + '" ' + Param;
  buf     := CmdLine; // Для преоборазования к PChar
  FillChar(StartInfo, SizeOf(StartInfo), #0);
  with StartInfo do
  begin
    cb      := SizeOf(StartInfo);
    dwFlags := STARTF_USESHOWWINDOW;
    wShowWindow := WinState;
  end;
  Result := CreateProcess(nil, PChar(buf), nil, nil, False,
    //  Result := CreateProcess(nil, PChar(CmdLine), nil, nil, false,
    CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS,
    nil, PChar(ExtractFilePath(Filename)), StartInfo, ProcInfo);
  { Ожидаем завершения приложения }
  if Result and Wait then
  begin
    WaitForSingleObject(ProcInfo.hProcess, INFINITE);
    { Free the Handles }
    CloseHandle(ProcInfo.hProcess);
    CloseHandle(ProcInfo.hThread);
  end;
end;
}
//==================================================
{Запуск программы с ожиданием или без
Параметр FileName = Имя внешней программы.
Параметр Params = Параметры, необходимые для запуска внешней программы
Wait - ожидать
Параметр WinState = Указывает - как будет показано окно:
Для этого параметра мы можем так же использовать следующие константы:
SW_HIDE, SW_MAXIMIZE, SW_MINIMIZE, SW_SHOWNORMAL

}
function TTaskCl.ExecProc(const FileName, Param: string; const Wait: boolean): integer;
var
  AProcess: TProcess;
  //   AStringList: TStringList;
  CmdLine:  string;
  str:string;
begin
try
  { Помещаем имя файла между кавычками, с соблюдением всех пробелов в именах Win9x }
  CmdLine := '"' + Filename + '" ' + Param;

  AProcess := TProcess.Create(nil);
  //AStringList := TStringList.Create;

  AProcess.CommandLine := CmdLine;
     //AProcess.Options := AProcess.Options + [poUsePipes,poNewConsole,poStderrToOutPut];  // Это для чтения StdOut процесса
     AProcess.Options := AProcess.Options + [poNewConsole,poStderrToOutPut];  // Это для чтения StdOut процесса
     AProcess.ShowWindow:=swoShowNormal;
  if Wait then
    AProcess.Options := AProcess.Options + [poWaitOnExit];


  // Now that AProcess knows what the commandline is
  // we will run it.
  AProcess.Execute;
  if Wait then // Получаем код возврата
  begin
    Result := AProcess.ExitStatus;
  end
  else
  begin
    Result := 0; // Без ожидания, типа успешно запустились
  end;


 // if Wait then // Читаем StdOut
 //    LastStdOut.LoadFromStream(AProcess.Output);

  //   AStringList.Free;
  AProcess.Free;

except
    On E: Exception do
    begin
      str    := ansitoutf8(E.Message);
      str    := Format(rsLogExtProgErrEx, [ansitoutf8(CmdLine), str]);
      LogMessage(str);
    end;
end;
end;
 //==================================================
 // Функция запуска задания
function TTaskCl.RunTask(num: integer; countsize: boolean): integer;
var
  AlertMes:  string;// TStrings; // Сообщение высылаемое на почту
  str, subj,body,MsgErr: string;
  //SorPath,DestPath:string;
  AlertType: integer; // Тип уведомлений на почту
 // SendMail:  TSendMail;
//  idSmtp:TIdSMTP;
//  idMsg:TIdMessage;
//  idAttach:TidAttachment;
//  idAttachFile:TIdAttachmentFile;
  // LastRun:TDateTime;
  lyear, lmonth, lday, cyear, cmonth, cday: word;
  // Год мес день (текущие и из задания)
  ExitCode:  integer;
  // ShowProc:
  //var
  // ResName:string;
begin
  AlertMes := '';//TStringList.Create;
  //ShowProc(1);
  Result   := trOk;
  if num > Count then
    exit;
  if num < 1 then
    exit;
  // Проверка разово дневного задания
  if InCmdMode then
  begin
    if (Tasks[num].Rasp.OnceForDay) and (Tasks[num].LastRunDate <> 0) then
    begin
      // Проверка, что сегодня еще не запускалась
      DecodeDate(Now, cyear, cmonth, cday);
      DecodeDate(Tasks[num].LastRunDate, lyear, lmonth, lday);
      if (cyear = lyear) and (cmonth = lmonth) and (cday = lday) then
        // Сегодня уже было
      begin
        exit;
      end;
    end;

  end;
  //------------------------

  LogMessage('-');
  LogMessage(rsLogRunTask + ': ' + Tasks[num].Name);
  alertMes := alertMes + (rsAlert + ' ' + Tasks[num].Name) + LineEnding;
  ReplaceNameDisk(num, True);

  if Tasks[num].ExtProgs.BeforeStart then
    // Запуск внешней программы до задания
  begin
    if FileExists(Utf8ToAnsi(Tasks[num].ExtProgs.BeforeName)) then
    begin
      LogMessage(rsLogExtProgRun +
        ' ' + Tasks[num].ExtProgs.BeforeName);
      //WinExec(Tasks[num].ExtProgs.BeforeName,'', true,SW_SHOWNORMAL);
      ExitCode := ExecProc(Utf8ToAnsi(Tasks[num].ExtProgs.BeforeName), '', True);
      str      := format(rsLogExtProgEnd, [IntToStr(ExitCode)]);
      LogMessage(str);
    end
    else
    begin // файл с внешней прогой не найден
      str := format(rsLogExtProgErr,[Tasks[num].ExtProgs.BeforeName]);
      LogMessage(str);
      AlertMes := alertMes + str + LineEnding;
    end;
  end;

//  SorPath:=ReplDate(Tasks[num].SorPath);
//  SorPath:=Utf8toansi(SorPath);
//  DestPath:=ReplDate(Tasks[num].DestPath);
//  DestPath:=Utf8toansi(DestPath);

  if Tasks[num].Action = ttCopy then // Копирование
  begin
//    str := Format(misc(rsLogCopy, 'rsLogCopy'), [ReplDate(Tasks[num].SorPath), ReplDate(Tasks[num].DestPath)]);
//    LogMessage(str);

//    Result := CopyDirs(SorPath, DestPath, num, False, Countsize);
    Result := CopyDir(num);

  end;
  if Tasks[num].Action = ttSync then // Синхронизирование
  begin

//    str := Format(misc(rsLogSync, 'rsLogSync'), [ReplDate(Tasks[num].SorPath), ReplDate(Tasks[num].DestPath)]);
//    LogMessage(str);

//    Result := CopyDirs(SorPath, DestPath, num, False, Countsize);

   Result := SynDir(num);

  end;
  if Tasks[num].Action = ttZerk then // Зеркалирование
  begin
//    str := Format(misc(rsLogMirror, 'rsLogMirror'),
//      [ReplDate(Tasks[num].SorPath), ReplDate(Tasks[num].DestPath)]);
//    LogMessage(str);

    //Result := CopyDirs(SorPath, DestPath, num, False, Countsize);
    Result := ZerkDir(num);

  end;
  if Tasks[num].Action = ttArhRar then // Архивирование Rar
  begin
//    str := Format(misc(rsLogArcRar, 'rsLogArcRar'),
//      [ReplDate(Tasks[num].SorPath),ReplDate( Tasks[num].DestPath)]);
//    LogMessage(str);
    Result := ArhRarDir(num);
 //   Tasks[num].LastResult := Result;
 //   Tasks[num].LastRunDate := Now;
  end;
  if Tasks[num].Action = ttArhZip then // Архивирование Zip
  begin
//    str := Format(misc(rsLogArcZip, 'rsLogArcZip'),
//      [ReplDate(Tasks[num].SorPath), ReplDate(Tasks[num].DestPath)]);
//    LogMessage(str);
    Result := Arh7ZipDir(num);
  end;
  if Tasks[num].Action = ttArh7zip then // Архивирование 7zip
  begin
//    str := Format(misc(rsLogArc7Zip, 'rsLogArc7Zip'),
//      [ReplDate(Tasks[num].SorPath), ReplDate(Tasks[num].DestPath)]);
    LogMessage(str);
    Result := Arh7zipDir(num);
  //  Tasks[num].LastResult := Result;
  //  Tasks[num].LastRunDate := Now;
  end;


  if Tasks[num].ExtProgs.AfterStart then
    // Запуск внешней программы после задания
  begin
    if FileExists(Utf8ToAnsi(Tasks[num].ExtProgs.AfterName)) then
    begin
      LogMessage(rsLogExtProgRun +' ' + Tasks[num].ExtProgs.AfterName);
      //WinExec(Tasks[num].ExtProgs.AfterName,'', true,SW_SHOWNORMAL);
      ExecProc(Utf8ToAnsi(Tasks[num].ExtProgs.AfterName), '', True);
      str := format(rsLogExtProgEnd, [IntToStr(ExitCode)]);
      LogMessage(str);
    end
    else
    begin // файл с внешней прогой не найден
      str := format(rsLogExtProgErr,[Tasks[num].ExtProgs.AfterName]);
      LogMessage(str);
      AlertMes := AlertMes + str + LineEnding;
    end;
  end;


  Tasks[num].LastResult  := Result;
  Tasks[num].LastRunDate := Now;
  ReplaceNameDisk(num, False);
  LogMessage(rsLogTaskEnd);
  if Tasks[num].LastResult = trOk then
  begin
    str      := Format(rsLogTaskEndOk, [Tasks[num].Name]);
    AlertMes := AlertMes + str + LineEnding;
  end
  else
  begin
    str      := Format(rsLogTaskEndErr, [Tasks[num].Name]);
    AlertMes := AlertMes + str + LineEnding;
  end;

  // Отсылка почты -----
  AlertType := Tasks[num].MailAlert;
  if AlertType > 0 then
  begin
    if (AlertType = alertErr) and (Result = trOk) then
      exit;
    body:=ReplaceParam(Settings.Body,num);
    subj:=ReplaceParam(Settings.Subj,num);
    str := FullFileNam(TempLogName); // Прикладываемый файл
    if Not SendMail(subj,body,str,MsgErr) then LogMessage(MsgErr);
 //   SendMail.Send(Settings.smtpserv, Settings.smtpport, Settings.mailfrom, Settings.email, subj, AlertMes, str);
    //send mail

  end;


end;
//=========================================================
// Отправка почты
// subj - тема письма
// Body - текст письма
// FileName - имя прикладываемого файла (Если не пусто)
// MsgError - ошибка, если возникла
// Возвращает true если все хорошо
function TTaskCl.SendMail(Subj:string;Body:string;FileName:string;var MsgError:string):boolean;
var
 idSmtp:TIdSMTP;
  idMsg:TIdMessage;
//  idAttach:TidAttachment;
  idAttachFile:TIdAttachmentFile;
  str:string;
  IsAtt:boolean;
begin
// Создаем объект
    Result:=true;
    IsAtt:=false;
    idSmtp:=TIdSmtp.Create;
    idSmtp.Host:=Settings.smtpserv;
    idSmtp.Port:= Settings.smtpport;
    if Settings.smtpuser<>'' then idSmtp.AuthType:=satDefault
      else idSmtp.AuthType:=satNone;
    idSmtp.Username:=Settings.smtpuser;
    idSmtp.Password:=Settings.smtppass;
    idSmtp.ConnectTimeout:=30000;
    idMsg:=TIdMessage.Create;
   idMsg.Subject:=subj;
   idMsg.Body.Add(Body);
   idMsg.From.Address:=Settings.mailfrom;
   idMsg.Recipients.EMailAddresses:=Settings.email;
   str:=utf8toansi(FullFileNam(FileName));
   if (FileName<>'') and (FileExists(str)) then
     begin
     IsAtt:=true;
     idAttachFile:=TIdAttachmentFile.Create(idMsg.MessageParts,str);
     idAttachFile.FileName:=str;
     idAttachFile.ContentType := 'text/plain';
     end;
    //send mail
  try
    try
      idSmtp.Connect;
      idSmtp.Send(idMsg);
      {
      if idSmtp.DidAuthenticate then
            idSmtp.Send(idMsg)
      else
          begin
          MsgError:=rsAlertAuthErr;
//          LogMessage(rsAlertAuthErr);
          Result:=false;
          end;
          }
    except on E:Exception do
      begin
      MsgError:=format(rsAlertTestErr,[E.Message]);
//      LogMessage(MsgError);
      Result:=false;
      end;

    end;
  finally
    if idSmtp.Connected then idSmtp.Disconnect;
  //  idAttach.Destroy;
 //   idAttachFile.Destroy;
    if IsAtt then idAttachFile.Destroy;
    idMsg.Destroy;
    idSmtp.Destroy;
  end;
end;
//=========================================================
// Заменяет все спец параметры в строке, типа %Status%
// Перечень команд:
// %Name% - имя задания
// %Status% - результат выполнения (берется из задания)
// + замена даты/времени

function TTaskCl.ReplaceParam(S:string;numtask:integer):string;
var
  str:string;
begin

   case Tasks[numtask].LastResult of
      trOk:
        str:=rsOk;
      trError:
        str:=rsTaskError;
      trFileError:
         str:=rsTaskEndError;
    end;
    str :=StringReplace(S,'%Status%',str,[rfReplaceAll, rfIgnoreCase]);
    str:=StringReplace(str,'%Name%',Tasks[numtask].Name,[rfReplaceAll, rfIgnoreCase]);
    str:=ReplDate(str);
Result:=str;
end;

//=========================================================
//Получение имени файла архива без директории
function TTaskCl.GetArhFileName(numtask:integer):string;
var
  ResName: string;
  ext:string; // расширение
begin
  ext:='';
  ResName := ReplDate(Tasks[numtask].Arh.Name);
  case Tasks[NumTask].Action of
  ttArhRar: ext:='.rar';
  ttArhZip: ext:='.zip';
  ttArh7zip: ext:='.7z';
  end;
  // Замена спец символов на дату
  ResName := ResName + ext;
  Result  := utf8toansi(ResName);
end;


//=========================================================
//Получение имени файла архива с полным путем
// Если ignoreTmpDir=true - возвращается просто полный путь до приемника
// Иначе
// Если ArhTmpDir не пуста, возвращает полный путь до нее
// Если пуста, то до Destination
// TmpExist - Существует ли временный каталог
function TTaskCl.GetArhName(numtask: integer;ArhFileName:string;IgnoreTmpDir:boolean;var TmpExist:boolean): string;
var
  ResName: string;
  //ext:string; // расширение
  Drive1,Drive2:string;
 // SameDisk:boolean; // tmp каталог находится на том же диске, что и приемник
  // SorPath,DestPath:String;
begin
 if ArhFileName='' then ArhFileName:=GetArhFileName(numtask);
 {
  ext:='';
  ResName := ReplDate(Tasks[numtask].Arh.Name);
  case Tasks[NumTask].Action of
  ttArhRar: ext:='.rar';
  ttArhZip: ext:='.zip';
  ttArh7zip: ext:='.7z';
  end;
  }
Drive1:=ExtractFileDrive(Settings.ArhTmpDir);
Drive2:=ExtractFileDrive(Tasks[numtask].DestPath);
Drive1:=UpperCase(Drive1);
Drive2:=UpperCase(Drive2);

  if (Drive1<>Drive2) and (Settings.ArhTmpDir<>'') then // временный каталог архивов задан
     begin
       if DirectoryExists(utf8toansi(Settings.ArhTmpDir)) then // и он существует
          begin
           TmpExist:=true;
           ResName := Settings.ArhTmpDir+DirectorySeparator+ ArhFileName;
          end
        else   // временный каталог не существует, фигачим напрямую
          begin
          TmpExist:=false;
           LogMessage(format(rsLogDirNotFound,[Settings.ArhTmpDir]));
          ResName := ReplDate(Tasks[numtask].DestPath) + DirectorySeparator + ArhFileName;
          end;
     end
   else // Просто путь до приемника
     begin
     TmpExist:=false;
     ResName := ReplDate(Tasks[numtask].DestPath) + DirectorySeparator + ArhFileName;
     end;
if IgnoreTmpDir then ResName := ReplDate(Tasks[numtask].DestPath) + DirectorySeparator + ArhFileName;


  Result  := utf8toansi(ResName);
end;
//------------------------------------------------------------------------
{Замена всяких символов типа %date% в строке на текущую дату}
function TTaskCl.ReplDate(S: string): string;
var
  dt: TDateTime;
  str, str2, strdate: string;
begin
  dt  := Now;
  str := FindStrVar(S);
  while str <> '' do
  begin
    str2 := '%' + str + '%';
    DateTimeToString(strdate, str, dt);
    s   := StringReplace(s, str2, strdate, [rfReplaceAll, rfIgnoreCase]);
    str := FindStrVar(S);
  end;
  Result := s;
end;
//-----------------------------------------------------------------------
{Поиск в строке первой подстроки типа %yyyy% и возвращение ее содержимого без %%}
function TTaskCl.FindStrVar(S: string): string;
var
  i, j: integer;
begin
  Result := '';
  if s = '' then
    exit;
  i := Pos('%', S); // Первый символ %
  if i = 0 then
    exit;
  j := PosEx('%', S, i + 1); // Второй символ %
  if j = 0 then
    exit;
  Result := MidStr(S, i + 1, j - i - 1); // Строка между %
end;
//-----------------------------------------------------------------------

 //==========================================================
 // Постороение списка файлов для архивации зип
procedure TTaskCl.GetFileList(sordir: string; NumTask: integer;
  var FileList: TStrings; recurse: boolean; ForZip: boolean);
var
  sr: TSearchRec;
  FileAttrs: integer;
begin
  if recurse and not Tasks[NumTask].SourceFilt.Recurse then
    exit; // подкаталоги не обрабатывать
  if not Tasks[NumTask].SourceFilt.FiltSubDir and not
    Tasks[NumTask].SourceFilt.FiltFiles then
    // нет исключений
  begin
    if Tasks[NumTask].SourceFilt.Recurse then
      FileList.Add('>' + Tasks[numtask].SorPath + DirectorySeparator + '*') // рекурсивно
    else
      FileList.Add(Tasks[numtask].SorPath + DirectorySeparator + '*'); // не рекурсивно
    exit;
  end;
  FileAttrs := faReadOnly + faHidden + faSysFile + faArchive + faAnyFile;
  // сначала файлы
  if FindFirst(sordir + DirectorySeparator + '*', FileAttrs, sr) = 0 then
  begin
    repeat
      begin
        if CheckFileMask(sr.Name, NumTask) then
          // Проверка файла на маску
        begin
          if ForZip then
            FileList.Add(sordir + DirectorySeparator + sr.Name);// для зип
        end// if checkfilemask
        else
        if not ForZip then
          FileList.Add(sordir + DirectorySeparator + sr.Name); // для рар
      end;
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;
  // потом директории
  FileAttrs := faDirectory + faReadOnly + faHidden + faSysFile + faArchive;
  if FindFirst(sordir + DirectorySeparator + '*', FileAttrs, sr) = 0 then
  begin
    repeat
      if (sr.Attr and faDirectory) <> 0 then
      begin
        if not SameText(sr.Name, '.') and not SameText(sr.Name, '..') then
        begin
          if CheckSubDir(sordir + DirectorySeparator + sr.Name, NumTask) then
          begin
            // if ForZip then
            GetFileList(sordir + DirectorySeparator + sr.Name, NumTask, FileList, True, ForZip);
          end;
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
{
function TTaskCl.ArhZipDir(numtask: integer): integer;
  //var
  // zipfname,str:string;
  // FileList:TStrings;
  // SorPath,DestPath:String;
  // runstr:string;
begin
  Result := trOk;
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
}

//==========================================================
// Создание файла исключений, генерация командной строки для архивации rar
function TTaskCl.BuildRarFileList(NumTask: integer): string;
var
  FileList: TStrings;
  tmpfile:  string;
  res:      string;
  //SorPath, DestPath:String;

  i: integer;
  //  sr: TSearchRec;
  //  FileAttrs: Integer;
begin
  res:=' ';
    // -df удалить файлы после упаковки
  if Tasks[NumTask].Arh.DelAfterArh then
    begin
    res:=res+' -df '
    end;

// Нет фильтрации источника и приемника
  if (not Tasks[NumTask].SourceFilt.FiltSubDir) and (not Tasks[NumTask].SourceFilt.FiltFiles) then
  begin
         if Tasks[NumTask].SourceFilt.Recurse then
             res :=res+ ' -r ';
         Result:=res;
         exit;
  end;
  FileList := TStringList.Create;
  if Tasks[NumTask].SourceFilt.Recurse then
    res := res+' -r';
  // исключение файлов
  if Tasks[NumTask].SourceFilt.FiltFiles then
  begin
    GetFileList(Tasks[numtask].SorPath, NumTask, FileList, False, False);
    tmpfile := ExtractFileDir(ParamStr(0)) + DirectorySeparator + 'tmp.txt';
    //tmpfile:='tmp.txt';
    FileList.SaveToFile(tmpfile);
    res := res + ' -x@"' + tmpfile + '" ';
  end;
  // Исключение директорий
  if Tasks[NumTask].SourceFilt.FiltSubDir then
  begin
    for i := 0 to Tasks[NumTask].SourceFilt.SubDirs.Count - 1 do
    begin
      res := res + ' -x\""' + Tasks[numtask].SorPath + DirectorySeparator +
        Tasks[NumTask].SourceFilt.SubDirs[i] + '"" ';
    end;
  end;
  //tmpfile:=ExtractFileDir(ParamStr(0))+'\tmp.txt';
  FileList.SaveToFile(tmpfile);
  Res    := res + ' ';
  Result := res;
  FileList.Free;
end;
//==========================================================
// Создание командной строки для архивации 7zip  (без 7z.exe)
// ArhFileName - имя файла архива без пути
function TTaskCl.Build7zipFileList(NumTask: integer;ArhFileName:string): string;
var
  FileList: TStrings;
  tmpfile:  string;
  //res:      string;
  cmdstr: string; // Генерируемая строка
  arhname:string;
  tmpbool:boolean;
  arhsor:string; // Что архивировать
  i: integer;
begin

  arhname := GetArhName(numtask,ArhFileName,false,tmpbool);
  //arhname:=utf8toansi(arhname);


  arhsor:=ReplDate(Tasks[NumTask].SorPath);
  arhsor:=utf8toansi(arhsor)+DirectorySeparator+'*'; // По умолчанию все
  //7z a -tzip archive.zip *.txt -x!temp.*
  cmdstr:='a "'+arhname+'"';
  if Tasks[NumTask].Action=ttArhZip then // архивация zip
   begin
   cmdstr:=cmdstr+' -tzip'; // архивация зип
   end;



  if Tasks[NumTask].SourceFilt.Recurse then // рекурсивно
     begin
      cmdstr:=cmdstr+' -r';
     end
    else         // не рекурсивно
      begin
       cmdstr:=cmdstr+' -r-';
      end;
 {
  if not Tasks[NumTask].SourceFilt.FiltSubDir and not
    Tasks[NumTask].SourceFilt.FiltFiles then
    // нет исключений
  begin
    cmdstr:=cmdstr+' '+utf8toansi(Tasks[NumTask].SorPath)+slash+'*'; // Добавление списка архивируемых файлов
    Result:=cmdstr;
    exit;
  end;
  }

  // Исключение директорий
  if Tasks[NumTask].SourceFilt.FiltSubDir then
  begin
    for i := 0 to Tasks[NumTask].SourceFilt.SubDirs.Count - 1 do
    begin
   //   cmdstr := cmdstr + ' -xr!""' + utf8toansi(Tasks[numtask].SorPath) + slash +
      cmdstr := cmdstr + ' -xr!""' + utf8toansi(Tasks[NumTask].SourceFilt.SubDirs[i])+DirectorySeparator+'*"" ';
    end;
  end;

  // исключение файлов
  if Tasks[NumTask].SourceFilt.FiltFiles then
  begin
    // Если исключать файлы
    if Tasks[NumTask].SourceFilt.ModeFiltFiles=tsNoMask then // Файлы исключаются
      begin
      for i := 0 to Tasks[NumTask].SourceFilt.FileMask.Count - 1 do
        begin
         cmdstr := cmdstr + ' -xr!'+utf8toansi(Tasks[NumTask].SourceFilt.FileMask[i]);
        end;
      end
     else // Обрабатывать только эти файлы
       begin
       if Tasks[NumTask].SourceFilt.FileMask.Count=1 then // в списке только одно исключение
         begin
         arhsor:=utf8toansi(ReplDate(Tasks[NumTask].SorPath))+DirectorySeparator+Tasks[NumTask].SourceFilt.FileMask[0];
         end
        else // в списке несколько исключений, делаем файл со списком файлов
          begin
           tmpfile := ExtractFileDir(ParamStr(0)) + DirectorySeparator + 'tmp.txt';
           FileList := TStringList.Create;
           for i := 0 to Tasks[NumTask].SourceFilt.FileMask.Count - 1 do
               begin
                 FileList.Add(utf8toansi(Tasks[NumTask].SorPath)+DirectorySeparator+utf8toansi(Tasks[NumTask].SourceFilt.FileMask[i]));
               end;
           FileList.SaveToFile(tmpfile);
           FileList.Free;
           arhsor:='@"'+tmpfile+'"';
          end;
       end;
  end;

  cmdstr:=cmdstr+' "'+arhsor+'"'; // Добавление списка архивируемых файлов
  Result:=cmdstr;
end;

 //=====================================================
 // Копирование задания
procedure TTaskCl.DublicateTask(NumTask: integer);
begin
  // Найти свободный элемент
  if Count = MaxTasks then
    exit;
  AddTask;
  CopyTask(numtask, Count);
  Tasks[Count].Name := rsCopyPerfix + ' ' + Tasks[numtask].Name;
  Tasks[Count].LastRunDate:=0;
end;
 //===========================================================
 // Архивация Rar директории sourdir в директорию destdir
function TTaskCl.ArhRarDir(NumTask: integer): integer;
var
  rarexe, str: string;
  runstr:      string;
  arhname:     string;
  SorPath:     string;
  ExitCode:    integer;
  ArhFileName:string;
  arhnamedst:string;
  TmpExist:boolean;
  // tmpstr:TStrings;
begin
     str := Format(rsLogArcRar,[ReplDate(Tasks[NumTask].SorPath),ReplDate( Tasks[NumTask].DestPath)]);
    LogMessage(str);

  SorPath:=ReplDate(Tasks[numtask].SorPath);
  SorPath := utf8toansi(SorPath);
  //DestPath:=utf8toansi(Tasks[numtask].DestPath);

  if not CheckDirs(NumTask) then
    exit; // Проверка существования каталогов
  Result  := trOk;
  ArhFileName:=GetArhFileName(numtask);
  arhname := GetArhName(NumTask,ArhFileName,false,TmpExist);
  //rarexe:=Getfilenam('rar.exe');
  rarexe  := ExtractFileDir(ParamStr(0)) + DirectorySeparator + 'rar.exe';
  if not FileExists(rarexe) then
  begin
    LogMessage(rsLogRarNotFound);
    Result := trError;
    exit;
  end;
  //runstr:=rarexe+' a -agYYMMDD -r -dh -ep1 -f -ibck -OW -y '+destdir+'\'+arhname+'.rar '+destdir;

  //rarexe:='"'+rarexe+'"';

  //runstr:=rarexe+' a -dh -ep1 -u -ibck -y ';
  runstr := 'a -dh -ep1 -u -ibck -y ';
  runstr := runstr + BuildRarFileList(numtask) + ' ';
  if Tasks[numtask].NTFSPerm then
    runstr := runstr + ' -ow '; // NTFS права
  //runstr:=runstr+arhname+' '+Tasks[numtask].SorPath+slash+'*';
  runstr   := runstr + '"'+arhname + '" "' + SorPath+ DirectorySeparator + '*"';

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


  //if WinExec(rarexe,runstr,true,SW_SHOWNormal) then  // Запуск с ожиданием
  ExitCode := ExecProc(rarexe, runstr, True);   // Запуск с ожиданием



  if ExitCode = 0 then // Все хорошо
  begin
    str := Format(rsLogArcCreated, [ansitoutf8(arhname)]);
    // Создан архив
    LogMessage(str);
    Result := trOk;
    //  exit;
  end
  else //
  begin
       if ExitCode = 1 then // Предупреждение
         begin
         str := Format(rsLogArcWarn, [ansitoutf8(arhname)]);
         // Создан архив
         LogMessage(str);
         LogMessage(LastStdOut); // Вывод вывода архиватора

         Result := trFileError;
         //  exit;
         end
        else // Обшибка
         begin
         str := Format(rsLogArcErr, [IntToStr(ExitCode), ansitoutf8(arhname)]);

         // Ошибка создания архива
         LogMessage(str);
         LogMessage(LastStdOut); // Вывод вывода архиватора
         Result := trError;
         //  exit;
         end;
  end;
   if (TmpExist) and ((ExitCode=0) or (ExitCode=1)) then // Копируем архив
        begin
        arhnamedst:=GetArhName(numtask,ArhFileName,true,TmpExist);
        if SyncFiles(arhname,arhnamedst,false,false) then
           DelFile(arhname);
        end;
  //LogMessage('Создан архив '+arhname);
  // Удаление старых архивов
  //if Tasks[numtask].Arh.DelOldArh then
  DelOldArhs(numtask);
end;
 //===========================================================
 // Архивация 7zip
function TTaskCl.Arh7zipDir(NumTask: integer): integer;
var
  cmdexe, str: string;
  runstr:      string;
  arhname:     string; // путь и имя архива временный каталог
  arhnamedst:  string;   // путь и имя архива приемник
  SorPath:     string;
  ExitCode:    integer;
  ArhFilename:string;
  TmpExist:boolean;
  // tmpstr:TStrings;
begin
    if Tasks[NumTask].Action=ttArhZip then
        str := Format(rsLogArcZip,[ReplDate(Tasks[NumTask].SorPath), ReplDate(Tasks[NumTask].DestPath)])
      else
        str := Format(rsLogArc7Zip,[ReplDate(Tasks[NumTask].SorPath), ReplDate(Tasks[NumTask].DestPath)]);

    LogMessage(str);



  SorPath:=ReplDate(Tasks[numtask].SorPath);
  SorPath := utf8toansi(SorPath);
  ArhFileName:=GetArhFileName(numtask);

  arhname:=GetArhName(NumTask,ArhFileName,false,TmpExist);

  if not CheckDirs(NumTask) then
    exit; // Проверка существования каталогов
  Result  := trOk;

  cmdexe  := ExtractFileDir(ParamStr(0)) + DirectorySeparator + '7za.exe';
  if not FileExists(cmdexe) then
  begin
    LogMessage(rsLog7zipNotFound);
    Result := trError;
    exit;
  end;

  runstr := Build7zipFileList(NumTask,ArhFileName); // Параметры запуска

  ExitCode := ExecProc(cmdexe, runstr, True);   // Запуск с ожиданием

       case ExitCode of // Обрабатываем код возврата
       0: // Все хорошо
         begin
         str := Format(rsLogArcCreated, [ansitoutf8(arhname)]);
         // Создан архив
         LogMessage(str);
         Result := trOk;
         end;
       1: // Предупреждение
         begin
         str := Format(rsLogArcWarn, [arhname]);
         // Создан архив
         LogMessage(str);
         LogMessage(LastStdOut); // Вывод вывода архиватора
          Result := trFileError;
         end;
        2: // Fatal error
         begin
         str := Format(rsLogArcErr, [IntToStr(ExitCode), arhname]);
         // Ошибка создания архива
         LogMessage(str);
         LogMessage(LastStdOut); // Вывод вывода архиватора
         Result := trError;
         end;
        7: // Ошибка командной строки
         begin
         str := Format(rsLogArcErrCmd, [arhname]);
         // Ошибка создания архива
         LogMessage(str);
         LogMessage(LastStdOut); // Вывод вывода архиватора
         Result := trError;
         end;
        8: // Недостаточно памяти
         begin
         str := Format(rsLogArcErrMemory, [arhname]);
         // Ошибка создания архива
         LogMessage(str);
         LogMessage(LastStdOut); // Вывод вывода архиватора
         Result := trError;
         end;
      255: // Прервано пользователем
         begin
         str := Format(rsLogArcWarnUserStop, [arhname]);
         // Ошибка создания архива
         LogMessage(str);
         LogMessage(LastStdOut); // Вывод вывода архиватора
         Result := trFileError;
         end;
       else // Неизветсная ошибка
        begin
         str := Format(rsLogArcErr, [IntToStr(ExitCode), arhname]);
         // Ошибка создания архива
         LogMessage(str);
         LogMessage(LastStdOut); // Вывод вывода архиватора
         Result := trError;
        end;

       end;

  if (TmpExist) and ((ExitCode=0) or (ExitCode=1)) then // Копируем архив
        begin
        arhnamedst:=GetArhName(numtask,ArhFileName,true,TmpExist);
        if SyncFiles(arhname,arhnamedst,false,false) then
           DelFile(arhname);
        end;
  DelOldArhs(numtask);
end;






 //==========================================================
 // Удаление файлов архивов в папке dir с именем arhname
 // позднее olddays дней
 // позднее oldmonths месяцев
 // позднее oldyears лет
 //procedure TTaskCl.DelOldArhs(dir,arhname:string;olddays,oldMonths,OldYears:integer);
procedure TTaskCl.DelOldArhs(NumTask: integer);
var
  olddays, oldMonths, OldYears: integer;
  dir, exten: string;
  Col,i,j,Day, Month,year: integer;
  BeforeDate,DateBeg,DateEnd,CurrDate: TDateTime;
  sr:      TSearchRec;
  FileAttrs: integer;

  //  filesync:String;
  //sordata: TDateTime; // даты файлов источ и приемника
  ArhList:array of TArhList;

begin
  if not Tasks[numtask].Arh.DelOldArh then
    exit; // Если не задано удаление архивов выход из функции
  dir := Tasks[numtask].DestPath + DirectorySeparator;
  // каталог приемник где ищутся архивы
  //exten:=Tasks[numtask].Arh.Name;
  if Tasks[numtask].Action = ttArhZip then exten := '*.zip';
  if Tasks[numtask].Action = ttArh7Zip then exten := '*.7z';
  if Tasks[numtask].Action = ttArhRar then exten := '*.rar';
  olddays := Tasks[numtask].Arh.DaysOld;
  oldMonths := Tasks[numtask].Arh.MonthsOld;
  oldYears  := Tasks[numtask].Arh.YearsOld;
  FileAttrs := faReadOnly + faHidden + faSysFile + faArchive + faAnyFile;
// Создаем список всех файлов
  // Подсчет кол-ва файлов
  Col:=0;
  if FindFirst(dir + exten, FileAttrs, sr) = 0 then
  repeat
    begin
    Col:=Col+1;
    end;
  until FindNext(sr) <> 0;
  FindClose(sr);
  // заполение списка
  SetLength (ArhList,Col);
  i:=0;
  if FindFirst(dir + exten, FileAttrs, sr) = 0 then
  repeat
    begin

    ArhList[i].DateFile:=FileDateToDateTime(sr.Time);
    ArhList[i].NameFile:=sr.Name;
    ArhList[i].IsStay:=false;
    i:=i+1;
    end;
  until (FindNext(sr) <> 0) and (i<=Col);
  FindClose(sr);
// Помечаем в списке файлы которые нужно оставить
// Дневные
CurrDate:=Now;
if olddays > 0 then
    begin
    beforedate := IncDay(CurrDate, -olddays);
    // Обходим все файлы ищем те которые позже beforedate
    for i:=0 to Col-1 do
      begin
        if CompareDateTime(ArhList[i].DateFile, beforedate) > -1 then ArhList[i].IsStay:=true;
      end;
    end;
// Ежемесячные
if oldmonths > 0 then
   begin
    for i:=0 to oldmonths do // перебираем все месяцы по порядку
     begin
     beforedate := IncMonth(CurrDate, -i);
     month:=MonthOf(beforedate);
     year:=YearOf(beforedate);
     day:=DaysInMonth(beforedate);
     DateBeg:=EncodeDate(year,month,1); // Диапазон месяц
     DateEnd:=EncodeDate(year,month,day);
     // Ищем файл с мин датой в диапазоне
     j:=MinInRange(ArhList,DateBeg,DateEnd);
     if j>-1 then ArhList[j].IsStay:=true;
     end;
   end;
// Годовые
if oldyears > 0 then
   begin
    for i:=0 to oldyears do // перебираем все года по порядку
     begin
     beforedate := IncYear(CurrDate, -i);
     //month:=MonthOf(beforedate);
     year:=YearOf(beforedate);
     //day:=DaysInMonth(beforedate);
     DateBeg:=EncodeDate(year,1,1); // Диапазон год
     DateEnd:=EncodeDate(year,12,31);
     // Ищем файл с мин датой в диапазоне
     j:=MinInRange(ArhList,DateBeg,DateEnd);
     if j>-1 then ArhList[j].IsStay:=true;
     end;
   end;
// Удаляем не помеченные файлы
for i:=0 to Col-1 do
      begin
        if Not ArhList[i].IsStay then DelFile(dir + ArhList[i].NameFile);
      end;







{

  if FindFirst(dir + exten, FileAttrs, sr) = 0 then
  begin
    repeat
      begin
        sordata := FileDateToDateTime(sr.Time);
        // дата время модификации файла источника
        day     := DayOf(sordata); // день архива
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
          if day = 1 then // или годовой или месячный
          begin
            month := MonthOf(sordata); // месяц архива
            if month = 1 then // годовой
            begin
              if oldyears > 0 then
              begin
                beforedate := IncYear(Now, -oldyears);
                if CompareDateTime(sordata, beforedate) < 0 then
                  // файл раньше даты
                  DelFile(dir + sr.Name);
              end;
            end
            else // месячный
            begin
              if oldmonths > 0 then
              begin
                beforedate := IncMonth(Now, -oldmonths);
                if CompareDateTime(sordata, beforedate) < 0 then
                  // файл раньше даты
                  DelFile(dir + sr.Name);
              end;
            end; // if month=1
          end
          else // дневной
          begin
            if olddays > 0 then
            begin
              beforedate := IncDay(Now, -olddays);
              if CompareDateTime(sordata, beforedate) < 0 then
                // файл раньше даты
                DelFile(dir + sr.Name);
            end;
          end;
        end; // else
      end;
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;
  }
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
//==============================================================
// Поиск файла в списке архивов с минимальной датой из заданного диапазона (края диапазона включаются в поиск)
// Нужна для DelOldArhs
// Возвращает индекс найденного файла, или -1 если ничего не найдено
function TTaskCl.MinInRange(ArhList:array of TArhList;DateBeg,DateEnd:TDateTime):integer;
var
  i,len:integer;
  MinDate:TDateTime;
begin
len:=Length(ArhList);
MinDate:=IncDay(DateEnd,10);
Result:=-1;
for i:=0 to len do
    begin
    if (CompareDateTime(ArhList[i].DateFile,DateBeg)>-1) and (CompareDateTime(ArhList[i].DateFile,DateEnd)<1) then // Дата файла в диапазоне
         begin
          if CompareDateTime(ArhList[i].DateFile,MinDate)<0 then // Дата файла меньше чем текущий мин
             begin
             MinDate:=ArhList[i].DateFile;
             Result:=i;
             end;
         end;
    end;
end;

 //==============================================================
 // Удаление файла с записью в лог
function TTaskCl.DelFile(namef: string): integer;
var
  str:   string;
  Attrs: integer;
  res:   boolean;
begin
Result:=trOk;
  // Если есть атрибут только для чтения, то его убираем
  Attrs := FileGetAttr(namef);
  if Attrs and faReadOnly <> 0 then
    try
      FileSetAttr(namef, Attrs - faReadOnly);
    except
    end;

  // Удаляем файл
  try
    res := SysUtils.DeleteFile(namef);
  except
    On E: Exception do
    begin
      Result := trFileError;
      str    := ansitoutf8(E.Message);
      str    := Format(rsLogDelFileErr, [ansitoutf8(namef), str]);
      LogMessage(str);
    end;
  end;

  if res then
  begin
//    Result := True;
    str    := Format(rsLogDelFile, [ansitoutf8(namef)]);
    LogMessage(str);
  end
  else
  begin
    Result := trFileError;
    str    := ansitoutf8(SysErrorMessage(GetLastError));
    str    := Format(rsLogDelFileErr, [ansitoutf8(namef), str]);
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
procedure TTaskCl.ReplaceNameDisk(NumTask: integer; replace: boolean);
 //var
 // RepFlags:TReplaceFlags;
begin
  //RepFlags:=rfIgnoreCase;
  if replace then  // замена
  begin
    TempSorPath  := Tasks[NumTask].SorPath;
    TempDestPath := Tasks[NumTask].DestPath;
    if AnsiContainsText(Tasks[NumTask].SorPath, '%disk%') then
    begin
      Tasks[NumTask].SorPath := StringReplace(Tasks[NumTask].SorPath,
        '%disk%', ExtractFileDrive(ParamStr(0)), [rfIgnoreCase]);
    end;
    if AnsiContainsText(Tasks[NumTask].DestPath, '%disk%') then
    begin
      Tasks[NumTask].DestPath := StringReplace(Tasks[NumTask].DestPath,
        '%disk%', ExtractFileDrive(ParamStr(0)), [rfIgnoreCase]);
    end;
  end
  else
  begin
    Tasks[NumTask].SorPath  := TempSorPath;
    Tasks[NumTask].DestPath := TempDestPath;
  end;
end;
 //======================================================
 // Объединение двух путей файла (каталог + файл)
 // Возвращает объединенный путь
function TTaskCl.PathCombine(Path1: string; Path2: string): string;
begin
  if IsPathDelimiter(Path1, Length(Path1)) then // Оканчивается на слеш
  begin
    Result := Path1 + Path2;
  end
  else
  begin
    Result := Path1 + DirectorySeparator + Path2;
  end;
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
 // Запись строк в logfile
procedure TTaskCl.LogMessage(MesStrings: TStringList);
var
 str,fulLog,TempLogNameful:string;
 i:integer;
begin
fulLog := FullFileNam(Settings.logfile);
TempLogNameful := FullFileNam(TempLogName);
for i:=0 to  MesStrings.Count-1 do
 begin
    //str := Utf8ToAnsi(MesStrings[i]);
    str := DosToWin(MesStrings[i]);
    WriteFileStr(fulLog, str);
    WriteFileStr(TempLogNameful, str);
 //   OnProgress(nil, MsgCopy, ansitoutf8(str), 0);

 end;
end;

 //==================================================
 // Запись строки в logfile
procedure TTaskCl.LogMessage(logmes: string);
var
  dtime, fulLog, TempLogNameful: string;

begin
  fulLog := FullFileNam(Settings.logfile);
  TempLogNameful := FullFileNam(TempLogName);
  //if ExtractFileDir(fulLog)='' then
  //   fulLog:=ExtractFileDir(ParamStr(0))+'\'+fulLog;
  if logmes = '-' then
  begin
    WriteFileStr(fulLog, '-----------------------------------------');
    DeleteFile(utf8toansi(TempLogNameful)); // Очистка лог файла

  end
  else
  begin
    dtime := FormatDateTime('dd.mm.yy hh:mm:ss ', now);
    dtime := Utf8ToAnsi(dtime + logmes);
    WriteFileStr(fulLog, dtime);
    WriteFileStr(TempLogNameful, dtime);
    OnProgress(nil, MsgCopy, logmes, 0);
    // сообщение для обработки потоком
  end;
end;
 //=============================================
 // Запись строки str в файл с именем filenamfhandle
procedure TTaskCl.WriteFileStr(filenam, str: string);
var
  hfile, i: integer;
  filelen:  longint;
  buf:      char;
  baklognam: string;
begin
  filenam:=utf8toansi(filenam);
  if FileExists(filenam) then
  begin
    hfile := FileOpen(filenam, fmOpenWrite);
  end
  else
    hfile := FileCreate(filenam);
  FileSeek(hfile, 0, 2);
  for i := 1 to length(str) do
  begin
    buf := str[i];
    FileWrite(hfile, buf, 1);
  end;
  buf := Chr($0d);
  FileWrite(hfile, buf, 1);
  buf := Chr($0a);
  FileWrite(hfile, buf, 1);
  filelen := FileSeek(hfile, 0, 2);
  FileClose(hfile);
  //if str='-----------------------------------------' then CheckFileSize(filenam);

  if (filelen > Settings.loglimit * 1024) and (Settings.loglimit > 0) and
    (str = '-----------------------------------------') then
    // файл лога превышает лимит
  begin
    //         FileClose(hfile);
    //         baklognam:=ExtractFileDir(filenam)+'\autosave1.log'; // Имя файла
    baklognam := filenam + '.bak'; // Имя файла
    DeleteFile(baklognam);
    RenameFile(filenam, baklognam);
    // hfile:=FileCreate(filenam);
  end;

end;
//================================================================
// Проверка файла на соответсвие размеру, уменьшение если нужно
 {
procedure TTaskCl.CheckFileSize(FileNam:string);
begin
 if (filelen>loglimit*1024) AND (loglimit>0)  then // файл лога превышает лимит
       begin
         baklognam:=filenam+'.bak'; // Имя файла
         DeleteFile(baklognam);
         RenameFile(filenam,baklognam);
       end;
end;
}
 //================================================================
 // Запись массива заданий в XML файл
 //----------------------------------------------------------------
procedure TTaskCl.SaveToXMLFile(filenam: string);
var
  i, j, cnt: integer;
  //MailAlert:integer;
  xmldoc: TXMLConfig;
  sec: string;
  FrmSet:TFormatSettings;
begin

  if filenam = '' then filenam := Settings.profile;
  Settings.profile   := filenam;
  FrmSet.DecimalSeparator:='.';
  //filenam:=FullFileNam(filenam);

  xmldoc := TXMLConfig.Create(nil);
  //xmldoc.Filename:=filenam;
  xmldoc.StartEmpty := True;
  xmldoc.Filename := utf8toansi(filenam); //'probcfg.xml';
  xmldoc.RootName := 'AutoSave';
  // Версия программы
  xmldoc.SetValue('version/value', versionas);
  // количество заданий
  xmldoc.SetValue('tasks/count/value', Count);
  for i := 1 to Count do
  begin
    // Имя секции с заданием

    sec := 'tasks/task' + IntToStr(i) + '/';

    xmldoc.SetValue(sec + 'name/value', Tasks[i].Name);
    xmldoc.SetValue(sec + 'SorPath/value', Tasks[i].SorPath);
    xmldoc.SetValue(sec + 'DestPath/value', Tasks[i].DestPath);
    xmldoc.SetValue(sec + 'Action/value', Tasks[i].Action);
    xmldoc.SetValue(sec + 'Enabled/value', Tasks[i].Enabled);
    // Сохраняем параметры архива
    xmldoc.SetValue(sec + 'Arh/Name/value', Tasks[i].Arh.Name);
    xmldoc.SetValue(sec + 'Arh/DelOldArh/value', Tasks[i].Arh.DelOldArh);
    xmldoc.SetValue(sec + 'Arh/DaysOld/value', Tasks[i].Arh.DaysOld);
    xmldoc.SetValue(sec + 'Arh/MonthsOld/value', Tasks[i].Arh.MonthsOld);
    xmldoc.SetValue(sec + 'Arh/YearsOld/value', Tasks[i].Arh.YearsOld);
    xmldoc.SetValue(sec + 'Arh/DelAfterArh/value', Tasks[i].Arh.DelAfterArh);
   {
     TmpStr.Add(BoolToStr(Tasks[i].Rasp.Manual));
     TmpStr.Add(BoolToStr(Tasks[i].Rasp.AtTime));
     TmpStr.Add(BoolToStr(Tasks[i].Rasp.AtStart));

     TmpStr.Add(BoolToStr(Tasks[i].Rasp.EvMinutes));
     TmpStr.Add(IntToStr(Tasks[i].Rasp.Minutes));
     TmpStr.Add(TimeToStr(Tasks[i].Rasp.Time));
     }
    //Параметры запуска внешних программ
    xmldoc.SetValue(sec + 'ExtProgs/BeforeStart/value', Tasks[i].ExtProgs.BeforeStart);
    xmldoc.SetValue(sec + 'ExtProgs/BeforeName/value', Tasks[i].ExtProgs.BeforeName);
    xmldoc.SetValue(sec + 'ExtProgs/AfterStart/value', Tasks[i].ExtProgs.AfterStart);
    xmldoc.SetValue(sec + 'ExtProgs/AfterName/value', Tasks[i].ExtProgs.AfterName);
    // Копирование прав
    xmldoc.SetValue(sec + 'NTFSPerm/value', Tasks[i].NTFSPerm);
    // Уведомления по почте
    //MailAlert:=Tasks[i].MailAlert;
    xmldoc.SetValue(sec + 'MailAlert/value', Tasks[i].MailAlert);
    //xmldoc.SetValue(sec+'MailAlert/value',MailAlert);
    // Расписание
    xmldoc.SetValue(sec + 'Rasp/OnceForDay/value', Tasks[i].Rasp.OnceForDay);

    // Результат последнего выполнения задачи
    xmldoc.SetValue(sec + 'LastResult/value', Tasks[i].LastResult);
//    xmldoc.SetValue(sec + 'LastRunDate/value',  DateTimeToStr(Tasks[i].LastRunDate));
    xmldoc.SetValue(sec + 'LastRunDate/value', FloatToStr(Tasks[i].LastRunDate,FrmSet));
    // Параметры фильтрации каталогов и файлов источника
    xmldoc.SetValue(sec + 'SourceFilt/Recurse/value', Tasks[i].SourceFilt.Recurse);
    xmldoc.SetValue(sec + 'SourceFilt/FiltSubDir/value', Tasks[i].SourceFilt.FiltSubDir);
    // список исключаемых директорий
    cnt := Tasks[i].SourceFilt.SubDirs.Count;
    xmldoc.SetValue(sec + 'SourceFilt/SubDirs/count/value', cnt);
    for j := 1 to cnt do
    begin
      xmldoc.SetValue(sec + 'SourceFilt/SubDirs/path' + IntToStr(j) +
        '/value', Tasks[i].SourceFilt.SubDirs.Strings[j - 1]);
    end;
    xmldoc.SetValue(sec + 'SourceFilt/FiltFiles/value', Tasks[i].SourceFilt.FiltFiles);
    xmldoc.SetValue(sec + 'SourceFilt/ModeFiltFiles/value',
      Tasks[i].SourceFilt.ModeFiltFiles);
    xmldoc.SetValue(sec + 'SourceFilt/FileMask/value',
      Tasks[i].SourceFilt.FileMask.DelimitedText);

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
procedure TTaskCl.LoadFromXMLFile(filenam: string);
var
  i, j, cnt, cntdir: integer;
  // TmpStr:TStringList;
  // ver:integer;
  // i,j,cnt:integer;
  xmldoc:  TXMLConfig;
  sec:     string;
  strDate: string;
  FrmSet:TFormatSettings;
begin
  if filenam = '' then    filenam := Settings.profile;
  //filenam:=FullFileNam(filenam);

  FrmSet.DecimalSeparator:='.';


  //filenam:='probcfg.xml';
  if not FileExists(utf8toansi(filenam)) then
    exit;

  xmldoc := TXMLConfig.Create(nil);

  xmldoc.StartEmpty := False; //false;
  xmldoc.RootName   := 'AutoSave';
  xmldoc.flush;
  xmldoc.Filename := utf8toansi(filenam);
//  ver:=xmldoc.GetValue('version/value', '');
{
 try
 xmldoc.Filename:=filenam;
 finally
  end;
  }
  //xmldoc.Flush;


  //xmldoc.Filename:='probcfg.xml';


  // количество заданий
  cnt := xmldoc.GetValue('tasks/count/value', 0);
  if cnt = 0 then
  begin
    Clear;
    exit;
  end;
  //count:=cnt;
  Settings.Profile := ShortFileNam(filenam);

  //TmpStr.LoadFromFile(filenam);
  //ProfName:='';
  //strcount:=1;
  Clear;

  for i := 1 to cnt do
    //while strcount<TmpStr.Count do
  begin
    // Имя секции с заданием
    sec := 'tasks/task' + IntToStr(i) + '/';
    if i > MaxTasks then
      exit; // вдруг пакостный файл

    Tasks[i].Name := xmldoc.GetValue(sec + 'name/value', '');

    Tasks[i].SorPath  := xmldoc.GetValue(sec + 'SorPath/value', '');  //TmpStr[strcount+1];
    Tasks[i].DestPath := xmldoc.GetValue(sec + 'DestPath/value', '');
    //TmpStr[strcount+2];
    Tasks[i].Action   := xmldoc.GetValue(sec + 'Action/value', 0);
    //StrToInt(TmpStr[strcount+3]);
    Tasks[i].Enabled  := xmldoc.GetValue(sec + 'Enabled/value', False);
    //StrToBool(TmpStr[strcount+4]);
    Tasks[i].Status   := stNone;
    // Чтение параметров архива

    Tasks[i].Arh.Name      := xmldoc.GetValue(sec + 'Arh/Name/value', '');
    Tasks[i].Arh.DelOldArh := xmldoc.GetValue(sec + 'Arh/DelOldArh/value', False);
    Tasks[i].Arh.DaysOld   := xmldoc.GetValue(sec + 'Arh/DaysOld/value', 0);
    Tasks[i].Arh.MonthsOld := xmldoc.GetValue(sec + 'Arh/MonthsOld/value', 0);
    Tasks[i].Arh.YearsOld  := xmldoc.GetValue(sec + 'Arh/YearsOld/value', 0);
    Tasks[i].Arh.DelAfterArh:=xmldoc.GetValue(sec + 'Arh/DelAfterArh/value', False);

    // Чтение параметров запуска внешних программ
    Tasks[i].ExtProgs.BeforeStart :=
      xmldoc.GetValue(sec + 'ExtProgs/BeforeStart/value', False);
    //StrToBool(TmpStr[strcount+14]);
    Tasks[i].ExtProgs.BeforeName := xmldoc.GetValue(sec + 'ExtProgs/BeforeName/value', '');
    //TmpStr[strcount+15];
    Tasks[i].ExtProgs.AfterStart :=
      xmldoc.GetValue(sec + 'ExtProgs/AfterStart/value', False);
    //StrToBool(TmpStr[strcount+16]);
    Tasks[i].ExtProgs.AfterName := xmldoc.GetValue(sec + 'ExtProgs/AfterName/value', '');
    //TmpStr[strcount+17];
    // Копирование прав
    Tasks[i].NTFSPerm := xmldoc.GetValue(sec + 'NTFSPerm/value', False);
    //StrToBool(TmpStr[strcount+18]);
    // Уведомления по почте
    Tasks[i].MailAlert := xmldoc.GetValue(sec + 'MailAlert/value', 0);
    // Расписание
    Tasks[i].Rasp.OnceForDay := xmldoc.GetValue(sec + 'Rasp/OnceForDay/value', False);
    // Последний результат выполнения задания
    Tasks[i].LastResult := xmldoc.GetValue(sec + 'LastResult/value', 0);
    //StrToInt(TmpStr[strcount+19]);

    strDate := xmldoc.GetValue(sec + 'LastRunDate/value', '0');
    // Читаем дату последнего запуска в зависимости от версии (последняя float)
    try
     Tasks[i].LastRunDate :=StrToFloat(strDate,FrmSet);
    except
      try
      Tasks[i].LastRunDate := StrToDateTime(strDate);
      finally
      Tasks[i].LastRunDate :=0;
      end;
    end;


    // xmldoc.GetValue(sec+'LastRunDate/value',0);//StrToDateTime(TmpStr[strcount+20]);

    // Чтение параметров фильтрации источника
    Tasks[i].SourceFilt.SubDirs  := TStringList.Create;
    Tasks[i].SourceFilt.SubDirs.Delimiter := ';';
    Tasks[i].SourceFilt.FileMask := TStringList.Create;
    Tasks[i].SourceFilt.FileMask.Delimiter := ';';

    Tasks[i].SourceFilt.Recurse := xmldoc.GetValue(sec + 'SourceFilt/Recurse/value', True);
    //StrToBool(TmpStr[strcount+21]);
    Tasks[i].SourceFilt.FiltSubDir :=
      xmldoc.GetValue(sec + 'SourceFilt/FiltSubDir/value', False);
    //StrToBool(TmpStr[strcount+22]);
    // Количество фильтруемых директорий
    cntdir := xmldoc.GetValue(sec + 'SourceFilt/SubDirs/count/value', 0);
    for j := 1 to cntdir do // чтение фильтруемых директорий
    begin
      Tasks[i].SourceFilt.SubDirs.Add(
        xmldoc.GetValue(sec + 'SourceFilt/SubDirs/path' + IntToStr(j) + '/value', ''));
    end;
    Tasks[i].SourceFilt.FiltFiles :=
      xmldoc.GetValue(sec + 'SourceFilt/FiltFiles/value', False);
    //StrToBool(TmpStr[strcount+24]);
    Tasks[i].SourceFilt.ModeFiltFiles :=
      xmldoc.GetValue(sec + 'SourceFilt/ModeFiltFiles/value', 0);//StrToInt(TmpStr[strcount+25]);
    Tasks[i].SourceFilt.FileMask.DelimitedText :=
      xmldoc.GetValue(sec + 'SourceFilt/FileMask/value', '');//TmpStr[strcount+26];
    Count := i;
  end;
  //TmpStr.Free;
  xmldoc.Destroy;
end;

 //=================================================================
 // Запись массива заданий в файл
procedure TTaskCl.SaveToFile(filenam: string);
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
procedure TTaskCl.LoadFromFile(filenam: string);
 //var
 // i,strcount:integer;
 // TmpStr:TStringList;
 // ver:integer;
 // tstr:string;
 //cfgnam:string;
begin
  LoadFromXMLFile(filenam);
  if filenam <> '' then    Settings.profile := ShortFileNam(filenam);
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
function TTaskCl.SyncFiles(sorfile, destfile: string; NTFSCopy: boolean;
  recurse: boolean): boolean;
var
  //SorDir,
   DestDir, str: string;
  // PSorFile,PDestFile: array [0..MaxPChar] of char;
  //SorFile2,DestFile2: array of WideChar;
  // PSorFile2,PDestFile2: PWideChar;
  // ls,ld:integer; // Длина строк источника и получателя
  S, T:     TStream; // Копирование потоками
  // res,SourSize:Int64;
  res:      boolean;
  restream,ssize: int64;
  err:      string;
  Attrs:    integer;
  AttrChange:boolean;
  // PSorFile2,PDestFile2: PWideChar;
begin
  Result  := False;
  AttrChange:=false;
  Destdir := ExtractFileDir(destfile);
  if not DirectoryExists(Destdir) then
  begin
    if not ForceDir(Destdir) then
      exit;
  end;
//  Attrs:=MAX_PATH;
{
  if NTFSCopy and recurse then // Права на директорию
  begin
    SorDir := ExtractFileDir(sorfile);
    CopyNTFSPerm(sordir, destdir);
  end;

 }
  if FileExists(destfile) then
    // Удаление атрибута только для чтения
  begin
    // Если есть атрибут только для чтения, скрытый или системный, то его убираем
    Attrs := FileGetAttr(destfile);
    if (Attrs and faReadOnly <> 0) or (Attrs and faSysFile <> 0) or (Attrs and faHidden <> 0) then
      begin
      try
        FileSetAttr(destfile, 0);
        AttrChange:=true;
      except
      end;
      end;
  end;
  //-----
  // Копирование системной функцией копирования


  if Settings.SysCopyFunc then
  begin
    try
      res := CopyFile(PChar(sorfile), PChar(destfile), False);
    except
      On E: Exception do
      begin
        err := ansitoutf8(E.Message);
        str := Format(rsLogFileCopiedErr, [ansitoutf8(sorfile), err]);
        LogMessage(str);
      end;
    end;

    //if CopyFile(PSorFile2,PDestFile2,false) then
    if res then
    begin
      Result := True;
      if NTFSCopy then CopyNTFSPerm(sorfile, destfile);
      str := Format(rsLogFileCopied, [ansitoutf8(sorfile)]);
    end
    else
    begin
      str := ansitoutf8(SysErrorMessage(GetLastError));
      str := Format(rsLogFileCopiedErr,[ansitoutf8(sorfile), str]);
    end;

    LogMessage(str);
  end //- конец системного копирования
  else
  begin   // Копирование через потоки
    S := TFileStream.Create(sorfile, fmOpenRead);
    try
      try
        T := TFileStream.Create(destfile, fmOpenWrite or fmCreate);
        try
          ssize:=S.size;
          restream := T.CopyFrom(S, ssize);
          if restream=ssize then
          begin
            Result := True;
            if AttrChange then FileSetAttr(destfile, Attrs); // Возвращаем атрибуты на место
            if NTFSCopy then
              CopyNTFSPerm(sorfile, destfile);
            str := Format(rsLogFileCopied, [ansitoutf8(sorfile)]);
            LogMessage(str);
          end
          else
          begin
            str := ansitoutf8(SysErrorMessage(GetLastError));
            str := Format(rsLogFileCopiedErr,[ansitoutf8(sorfile), str]);
            LogMessage(str);
          end;
          //      FileSetDate(T.Handle, FileGetDate(S.Handle));
          FileSetDate(destfile, FileAge(sorfile));
          if AttrChange then
             begin
             Attrs := FileGetAttr(sorfile);
             FileSetAttr(destfile, Attrs); // Возвращаем атрибуты на место, берем из источника
             end;
        finally
          T.Free;
        end;
      finally
        S.Free;
      end;

    except
      On E: Exception do
      begin
        err := ansitoutf8(E.Message);
        str := Format(rsLogFileCopiedErr, [ansitoutf8(sorfile), err]);
        LogMessage(str);
      end;
    end;

  end;

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
function TTaskCL.NTSetPrivilege(sPrivilege: string; bEnabled: boolean): boolean;
var
  hToken: THandle;
  TokenPriv: TOKEN_PRIVILEGES;
  PrevTokenPriv: TOKEN_PRIVILEGES;
  ReturnLength: cardinal;
  buf: array [0..MaxPChar] of char;
begin
  Result := True;
  // Only for Windows NT/2000/XP and later.
  if not (Win32Platform = VER_PLATFORM_WIN32_NT) then
    Exit;
  Result := False;

  // obtain the processes token
  if OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES or
    TOKEN_QUERY, hToken) then
  begin
    try
      // Get the locally unique identifier (LUID) .
      //if LookupPrivilegeValue(nil, PChar(sPrivilege),
      //  TokenPriv.Privileges[0].Luid) then
      buf := sPrivilege;
      if LookupPrivilegeValue(nil, buf, TokenPriv.Privileges[0].Luid) then

      begin
        TokenPriv.PrivilegeCount := 1; // one privilege to set

        case bEnabled of
          True: TokenPriv.Privileges[0].Attributes  := SE_PRIVILEGE_ENABLED;
          False: TokenPriv.Privileges[0].Attributes := 0;
        end;

        ReturnLength  := 0; // replaces a var parameter
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
//  if not Result then raise Exception.Create(SysErrorMessage(GetLastError));
end;



 //==========================================================
 // Копирование прав доступа файла или каталога
 // sorfile- имя файла источника
 // destfile - имя файла приемника
 // Возвращает true если все ОК
function TTaskCL.CopyNTFSPerm(sorfile, destfile: string): boolean;
var
  SecDescr:    PSecurityDescriptor;
  SizeNeeded:  DWORD;
  // Буфер для определения размера описателя
  // SizeNeeded: LPDWORD; // Буфер для определения размера описателя
  BufferSize:  DWORD; // Размер буфера
  psor, pdest: array [0..MaxPChar] of char;
begin
  Result := False; // Пока ничего не сделано
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
  psor  := sorfile;
  pdest := destfile;
  //GetFileSecurity(PChar(sorfile),OWNER_SECURITY_INFORMATION or GROUP_SECURITY_INFORMATION or DACL_SECURITY_INFORMATION or SACL_SECURITY_INFORMATION,SecDescr, 0, SizeNeeded);
  GetFileSecurity(Psor, OWNER_SECURITY_INFORMATION or GROUP_SECURITY_INFORMATION or
    DACL_SECURITY_INFORMATION or SACL_SECURITY_INFORMATION, SecDescr, 0,
    LPDWORD(SizeNeeded));
  // Теперь в SizeNeeded - размер необходимого буфера
  if SizeNeeded = 0 then // ничего не надо копировать
  begin
    // LogMessage('0 длина');
    Result := True;
    exit;
  end;
  BufferSize := SizeNeeded;
  FreeMem(SecDescr);// особождение ранее выделенной памяти
  GetMem(SecDescr, BufferSize);
  // выделение памяти по нужному размеру
  // снова получение параметров безопасности уже с нужным размером буфера
  if not GetFileSecurity(Psor, OWNER_SECURITY_INFORMATION or
    GROUP_SECURITY_INFORMATION or DACL_SECURITY_INFORMATION or
    SACL_SECURITY_INFORMATION, SecDescr, BufferSize,
    LPDWORD(SizeNeeded)) then
    Exit;
  // Перенос полученных параметров на приемник
  if not SetFileSecurity(Pdest, OWNER_SECURITY_INFORMATION or
    GROUP_SECURITY_INFORMATION or DACL_SECURITY_INFORMATION or
    SACL_SECURITY_INFORMATION, SecDescr) then
    Exit;
  FreeMem(SecDescr);// особождение ранее выделенной памяти
  Result := True;
  //LogMessage('Права скопированы: '+sorfile);
end;
 //============================================================
 // Удаление директории dir со всем ее содержимым
function TTaskCl.DelDirs(dir: string):integer;
var
  sr:  TSearchRec;
  FileAttrs: integer;
  str: string;
  res: boolean;
  //dir2:String;
  // filesync:String;
  //  sordata,destdata:TDateTime; // даты файлов источ и приемника
begin
{
  FileAttrs := faReadOnly + faHidden + faSysFile + faArchive + faAnyFile;
  // сначала файлы
  if FindFirst(PathCombine(dir, '*'), FileAttrs, sr) = 0 then
  begin
    repeat
      begin
        DelFile(PathCombine(dir, sr.Name));
      end;
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;
  }
  // потом директории
  Result:=trOk;
  FileAttrs := faDirectory + faReadOnly + faHidden + faSysFile + faArchive;
  if FindFirst(PathCombine(dir, '*'), FileAttrs, sr) = 0 then
  begin
    repeat
      if (sr.Attr and faDirectory) <> 0 then // Это директория
      begin
        if not SameText(sr.Name, '.') and not SameText(sr.Name, '..') then
        begin
          Result:=Max(Result,DelDirs(PathCombine(dir, sr.Name)));
        end;
      end
      else // Это файл
       begin
        Result:=Max(Result,DelFile(PathCombine(dir, sr.Name)));
       end;
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;
  // Удаляем каталог
  try
    res := SysUtils.RemoveDir(dir);
  except
    On E: Exception do
    begin
      str := ansitoutf8(E.Message);
      str := Format(rsLogDelDirErr, [ansitoutf8(dir), str]);
      LogMessage(str);
      Result := trFileError;
    end;
  end;

  if res then
  begin
    str := Format(rsLogDelDir, [ansitoutf8(dir)]);
    LogMessage(str);
//    Result := True;
  end
  else
  begin
    str := ansitoutf8(SysErrorMessage(GetLastError));
    str := Format(rsLogDelDirErr, [ansitoutf8(dir), str]);
    LogMessage(str);
    Result := trFileError;
  end;
end;


//=================================================================
// Проверка файла источника на совпадение с маской
 // Возвращает true - файл для обработки
 //            false - файл обрабатывать не надо
function TTaskCl.CheckFileMask(FileName: string; NumTask: integer): boolean;
var
  Match: boolean; // Файл совпадает с маской
  i:     integer;
begin
  if Tasks[NumTask].SourceFilt.FiltFiles then
    // Установлен фильтр по файлам
  begin
    Match := False;
    // Проверка на совпадение файла с маской
    for i := 0 to Tasks[NumTask].SourceFilt.FileMask.Count - 1 do
    begin
      //        function FileInFilenameMasks(const Filename, Masks: string): boolean;
      //         Match:=(Match) OR (FileInFilenameMasks(FileName,Tasks[NumTask].SourceFilt.FileMask[i]));
      Match := (Match) or (MatchesMask(FileName, Tasks[NumTask].SourceFilt.FileMask[i]));
    end;
    if Tasks[NumTask].SourceFilt.ModeFiltFiles = tsMask then
      // Все кроме маски
      Result := Match
    else
      Result := not Match;
  end
  else
    Result := True;
end;
//=================================================================
// Проверка каталога на совпадение со списком исключаемых
 // Возвращает true - каталог для обработки
 //            false - каталог обрабатывать не надо
function TTaskCl.CheckSubDir(SubDir: string; NumTask: integer): boolean;
var
  Match: boolean; // Файл совпадает с маской
  i:     integer;
  FullPath: string;
begin
  if Tasks[NumTask].SourceFilt.FiltSubDir then
    // Установлен фильтр по каталогам
  begin
    Match := False;
    // Проверка на совпадение файла с маской
    for i := 0 to Tasks[NumTask].SourceFilt.SubDirs.Count - 1 do
    begin
      FullPath := PathCombine(Tasks[NumTask].SorPath,
        Tasks[NumTask].SourceFilt.SubDirs[i]);
      Match    := (Match) or (SameText(SubDir, FullPath));
    end;
    Result := not Match;
  end
  else
    Result := True;
end;
//====================================================================
// Проверка существования директорий приемника источника, создание при необходимости
 // Логирование ошибки
 // Возвращает true в случае, если все хорошо
function TTaskCl.CheckDirs(NumTask: integer): boolean;
var
  dir, syncdir, dira, syncdira: string;
  str: string;
begin
  dir      := ReplDate(Tasks[NumTask].SorPath);
  syncdir  := ReplDate(Tasks[NumTask].DestPath);
  dira     := Utf8ToAnsi(dir);
  syncdira := Utf8ToAnsi(syncdir);
  if not DirectoryExists(dira) then
    // каталога-источника не существует
  begin
    str := Format(rsLogDirNotFound, [dir]);
    LogMessage(str);
    str := Format(rsLogTaskError, [Tasks[NumTask].Name]);
    LogMessage(str);
    //    LogMessage('[Ошибка]: Задние не выполнено, каталог недоступен '+dir);
    Result := False;
    exit; // айяй
  end;
  if not DirectoryExists(syncdira) then
    // каталога-приемника не существует
  begin
    if ForceDir(syncdira) then
    begin
      str := Format(rsLogDirCreated, [syncdir]);
      LogMessage(str); // создаем его
    end
    else
    begin
      Result := False;
      OnProgress(nil, EndOfBatch, '', 0);
      exit; // айяй
    end;
  end;
  Result := True;

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
// IsStoreDel- зеркалирование с сохранением удаленных файлов
function TTaskCl.CopyDirs(dir, syncdir: string; NumTask: integer;
  Recurse: boolean; CountSize: boolean): integer;
var
  sr: TSearchRec;
  FileAttrs: integer;
  filesync, filesor: string;
  NTFSCopy: boolean;
  TypeSync: integer;
 // DelFiles:TDeletedFiles;
 // IsStoreDel:boolean; // Зеркалирование, да еще и сохранением удаленных файлов
  //  sordata,destdata:integer; // даты файлов источ и приемника
  //  res:boolean;
begin
  Result := trOk;
  //res:=true;
  // trOk=0; // Все ок
  //  trError=1; // Ошибка запуска задания (недоступен каталог)
  //  trFileError=2; // Ошибка копирования файла в задании
  if recurse and not Tasks[NumTask].SourceFilt.Recurse then
    exit; // подкаталоги не обрабатывать
  NTFSCopy := Tasks[NumTask].NTFSPerm;
  TypeSync := Tasks[NumTask].Action;
  //  ttCopy=1; // Копирование
  //  ttZerk=2; //Зеркалирование
  //  ttSync=3; //Сихронизирование
  if not Recurse then
  begin
    NTSetPrivilege('SeSecurityPrivilege', True);
    if not CheckDirs(NumTask) then // Проверка существования каталогов приемника и источника из задания
      begin
      Result:=trError;
      exit;

      end;
  end;
  if (not recurse) and (countsize) then
    // Определение общего размера файлов
  begin
    if not InCmdMode then
      // Если запуск не через командную строку
    begin
      GetSizeDir(dir, syncdir, NumTask, False);
      OnProgress(nil, TotalSize2Process, '', TotalSize);
      // Вызов события для обработки потоком
    end;
  end;
  if (recurse) and (NTFSCopy) then
    // вызов рекурсивный - копируются права на директорию
  begin

    //ForceDir(syncdir);
    CopyNTFSPerm(dir, syncdir);
  end;
  // Если зеркалирование загружаем список удаленных файлов

//  if IsStoreDel then
//   begin
//   DelFiles:=TDeletedFiles.Create;
//   DelFiles.DirName:=syncdir;
//   DelFiles.LoadFromFile;
//   end;

//  FileAttrs := faReadOnly + faHidden + faSysFile + faArchive + faAnyFile;
  FileAttrs := faDirectory + faReadOnly + faHidden + faSysFile + faArchive+faAnyFile;
  // Проходим по файлам и директориям
  if FindFirst(PathCombine(dir, '*'), FileAttrs, sr) = 0 then
  begin
    repeat
      begin

     if (sr.Attr and faDirectory) <> 0 then // Это директория
      begin
        if not SameText(sr.Name, '.') and not SameText(sr.Name, '..') then
        begin
          filesync := PathCombine(dir, sr.Name);
          filesor  := PathCombine(syncdir, sr.Name);
          if CheckSubDir(filesync, NumTask) then
            if CopyDirs(filesync, filesor, NumTask, True, False) = trFileError then
              Result := trFileError;
        end;
      end
     else   // Это файл
      begin

        if (CheckFileMask(sr.Name, NumTask)) AND (Not SameText(sr.Name,DeletedFilesF)) then
          // Проверка файла на маску и что это не файл с данными удаленных файлов
        begin
          filesync := PathCombine(syncdir, sr.Name); // Имя файла приемника
          filesor  := PathCombine(dir, sr.Name); // Имя файла источника
          if FileExists(filesync) then
                // файл в каталоге приемнике уже есть
          begin // Тогда сверяются даты
                // sordata:=sr.Time;
                // destData:=FileAge(filesync);
                //if CompareFileDate(sordata,destdata) then
            if CompareFileDate(filesor, filesync) then
            begin
              OnProgress(nil, NewFile, sr.Name, sr.Size);
              // Вызов события для обработки потоком
              if not SyncFiles(filesor, filesync, NTFSCopy, recurse) then
                Result := trFileError; // синхронизация файлов
              OnProgress(nil, ProgressUpdate, '', sr.Size);
              // Вызов события для обработки потоком
            end;
            if TypeSync = ttSync then // если синхронизация
            begin
              //if CompareFileDate (destdata,sordata) then
              if CompareFileDate(filesync, filesor) then
              begin
                OnProgress(nil, NewFile, sr.Name, sr.Size);
                if not SyncFiles(filesync, filesor, NTFSCopy, recurse) then
                  Result := trFileError; // синхронизация файлов наоборот
                OnProgress(nil, ProgressUpdate, '', sr.Size);
              end;
            end;
          end
          else // файл приемник не существует
          begin
            OnProgress(nil, NewFile, sr.Name, sr.Size);
            if not SyncFiles(filesor, filesync, NTFSCopy, recurse) then
              Result := trFileError; // синхронизация файлов
            OnProgress(nil, ProgressUpdate, '', sr.Size);
          end;
        end;// if checkfilemask
       end;
      end;
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;
  FileAttrs := faReadOnly + faHidden + faSysFile + faArchive + faAnyFile + faDirectory;
  if (TypeSync = ttSync) or (TypeSync = ttZerk) then
    // если синхронизация или зеркалирование
  begin
    if FindFirst(PathCombine(syncdir, '*'), FileAttrs, sr) = 0 then
    begin
      repeat
        begin
          filesync := PathCombine(dir, sr.Name); // Имя файла источника
          filesor  := PathCombine(syncdir, sr.Name);
          if ((sr.Attr and faDirectory) <> 0) and (CheckSubDir(filesync, NumTask)) then
            // это директория
          begin
            if not directoryexists(filesync) then
              // директория приемника не существует
            begin
              if TypeSync = ttZerk then // зеркалирование
              begin
                DelDirs(filesor);
              end
              else // синхронизирование
              begin
                if CopyDirs(filesor, filesync, NumTask, True, False) = trFileError then
                  Result := trFileError; // Синхронизация подкаталогов
              end;
            end;
          end
          else // это файл
          begin
            if CheckFileMask(sr.Name, NumTask) then
            begin
              if not FileExists(filesync) then
                // файл источник не существует
              begin
                if TypeSync = ttZerk then // зеркалирование
                begin
                  DelFile(filesor);
                end
                else // синхронизация
                begin
                  OnProgress(nil, NewFile, sr.Name, sr.Size);
                  if not SyncFiles(filesor, filesync, NTFSCopy, recurse) then
                    Result := trFileError; // синхронизация файлов
                  OnProgress(nil, ProgressUpdate, '', sr.Size);
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
{
  FileAttrs := faDirectory + faReadOnly + faHidden + faSysFile + faArchive;
  if FindFirst(PathCombine(dir, '*'), FileAttrs, sr) = 0 then
  begin
    repeat
      if (sr.Attr and faDirectory) <> 0 then
      begin
        if not SameText(sr.Name, '.') and not SameText(sr.Name, '..') then
        begin
          filesync := PathCombine(dir, sr.Name);
          filesor  := PathCombine(syncdir, sr.Name);
          if CheckSubDir(filesync, NumTask) then
            if CopyDirs(filesync, filesor, NumTask, True, False) = trFileError then
              Result := trFileError;
        end;
      end;
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;
 }
  OnProgress(nil, EndOfBatch, '', 0);
end;
//=================================================================
// Задание копирования директории
function TTaskCl.CopyDir(NumTask:integer):integer;
var
  str:string;
  SorPath,DestPath:string;
begin

  str := Format(rsLogCopy, [ReplDate(Tasks[numTask].SorPath), ReplDate(Tasks[numTask].DestPath)]);
  LogMessage(str);

  SorPath:=ReplDate(Tasks[numTask].SorPath);
  SorPath:=Utf8toansi(SorPath);
  DestPath:=ReplDate(Tasks[numTask].DestPath);
  DestPath:=Utf8toansi(DestPath);

 NTSetPrivilege('SeSecurityPrivilege', True);
    if not CheckDirs(NumTask) then // Проверка существования каталогов приемника и источника из задания
      begin
      Result:=trError;
      exit;
      end;
   if not InCmdMode then  // Если запуск не через командную строку  то считаем общее кол-во файлов
    begin
      GetSizeDir(SorPath, DestPath, NumTask, False);
      OnProgress(nil, TotalSize2Process, '', TotalSize); // Вызов события для обработки потоком
    end;
Result:=SimpleCopyDirs(SorPath,DestPath,NumTask,false,Tasks[NumTask].NTFSPerm);
OnProgress(nil, EndOfBatch, '', 0);
end;
//=================================================================
// Задание синхронизации директории
function TTaskCl.SynDir(NumTask:integer):integer;
var
  EC1,EC2:integer;
  str:string;
  SorPath,DestPath:string;
begin
    str := Format(rsLogSync, [ReplDate(Tasks[NumTask].SorPath), ReplDate(Tasks[NumTask].DestPath)]);
    LogMessage(str);

   SorPath:=ReplDate(Tasks[numTask].SorPath);
  SorPath:=Utf8toansi(SorPath);
  DestPath:=ReplDate(Tasks[numTask].DestPath);
  DestPath:=Utf8toansi(DestPath);


 NTSetPrivilege('SeSecurityPrivilege', True);
    if not CheckDirs(NumTask) then // Проверка существования каталогов приемника и источника из задания
      begin
      Result:=trError;
      exit;
      end;
   if not InCmdMode then  // Если запуск не через командную строку  то считаем общее кол-во файлов
    begin
      GetSizeDir(SorPath, DestPath, NumTask, False);
      OnProgress(nil, TotalSize2Process, '', TotalSize); // Вызов события для обработки потоком
    end;
// SorDir => DestDir
EC1:=SimpleCopyDirs(SorPath,DestPath,NumTask,false,Tasks[NumTask].NTFSPerm);
// DestDir => SorDir
EC2:=SimpleCopyDirs(DestPath,SorPath,NumTask,false,false);
Result:=Max(EC1,EC2);
OnProgress(nil, EndOfBatch, '', 0);
end;




//=================================================================
// Задание зеркалирования директории
function TTaskCl.ZerkDir(NumTask:integer):integer;
var
 ret:integer;
 str:string;
 SorPath,DestPath:string;
begin
   str := Format(rsLogMirror,[ReplDate(Tasks[NumTask].SorPath), ReplDate(Tasks[NumTask].DestPath)]);
    LogMessage(str);

  SorPath:=ReplDate(Tasks[numTask].SorPath);
  SorPath:=Utf8toansi(SorPath);
  DestPath:=ReplDate(Tasks[numTask].DestPath);
  DestPath:=Utf8toansi(DestPath);


 NTSetPrivilege('SeSecurityPrivilege', True);
    if not CheckDirs(NumTask) then // Проверка существования каталогов приемника и источника из задания
      begin
      Result:=trError;
      exit;
      end;
   if not InCmdMode then  // Если запуск не через командную строку  то считаем общее кол-во файлов
    begin
      GetSizeDir(SorPath, DestPath, NumTask, False);
      OnProgress(nil, TotalSize2Process, '', TotalSize); // Вызов события для обработки потоком
    end;
Result:=SimpleCopyDirs(SorPath,DestPath,NumTask,false,Tasks[NumTask].NTFSPerm);
// Удаляем лишние файлы
ret:=DelOldFiles(SorPath, DestPath, NumTask,false);
Result:=Max(Result,ret);
OnProgress(nil, EndOfBatch, '', 0);
end;
//=================================================================
//
// Удаляет из директории DestDir файлы отсутствующие в SorDir
// DestDir - Приемник
 // NumTask - номер задачи в массиве заданий
 // Recurse - true - рекурсивный вызов
 //           false - первый вызов
//Возвращает Код ошибки

function TTaskCl.DelOldFiles(SorDir, DestDir: string; NumTask: integer; Recurse: boolean): integer;
var
  sr: TSearchRec;
  FileAttrs: integer;
  filesync, filesor: string;
//  EmptyDir:boolean;
  DelFiles:TDeletedFiles;
  i:integer;
  beforedate:TDateTime;
  IsSubDir:boolean;

begin
Result:=trOk;
  FileAttrs := faReadOnly + faHidden + faSysFile + faArchive + faAnyFile + faDirectory;
//EmptyDir:=true;
IsSubDir:=false; // Есть подкаталоги
//IsFile:=false; // Есть файлы

    if FindFirst(PathCombine(DestDir, '*'), FileAttrs, sr) = 0 then
    begin
      DelFiles:=TDeletedFiles.Create(DestDir);
      repeat
        begin
          filesync := PathCombine(SorDir, sr.Name); // Имя файла источника
          filesor  := PathCombine(DestDir, sr.Name);
//          EmptyDir:=false;
          if ((sr.Attr and faDirectory) <> 0) then  // это директория
          begin
             if not (SameText(sr.Name, '.')) and not (SameText(sr.Name, '..')) then
                begin
                  IsSubDir:=true;
                  if (CheckSubDir(filesync, NumTask)) then
                     begin
                       if Not Tasks[NumTask].Arh.DelOldArh then // не задано хранение удаленных файлов
                           begin
                              if not directoryexists(filesync) then // директория приемника не существует
                                 begin
                                 Result:=Max(Result,DelDirs(filesor));
                                 end
                               else
                                 Result:=Max(Result,DelOldFiles(filesync,filesor,NumTask,true));
                            end
                              else
                                 Result:=Max(Result,DelOldFiles(filesync,filesor,NumTask,true));

                      end;

                end;
           end
          else // это файл
          begin
            if CheckFileMask(sr.Name, NumTask) AND (Not SameText(sr.Name,DeletedFilesF)) then
            begin
              if Not Tasks[NumTask].Arh.DelOldArh then // не задано хранение удаленных файлов
                 begin
                  if not FileExists(filesync) then // файл источник не существует
                     begin
                     Result:=Max(Result,DelFile(filesor));
                     end;
                 end
                else  // Задано хранение удаленных файлов
                  begin
                   if not FileExists(filesync) then // файл источник не существует
                     begin
                         DelFiles.Add(sr.Name); // Добавляем файл в список
                     end;
                  end;
            end;
          end;
        end;
      until FindNext(sr) <> 0;
      FindClose(sr);

      // Проходим по всем файлам в xml, удаляем устаревшие
      if Tasks[NumTask].Arh.DelOldArh then
          begin
          beforedate := IncDay(Now, -Tasks[NumTask].Arh.DaysOld);
          i:=0;
          while i<DelFiles.Count do
          begin
            filesor:=PathCombine(DestDir,DelFiles.GetName(i));
            filesync:=PathCombine(SorDir,DelFiles.GetName(i));

            if (FileExists(filesync)) or (Not FileExists(filesor)) then DelFiles.Delete(i) // в источнике есть такой файл, или в приемнике нет такого файла
              else
              if CompareDateTime(DelFiles.GetDate(i), beforedate) = -1 then
                  begin
                  Result:=Max(Result,DelFile(filesor));
                  DelFiles.Delete(i);
                  //Dec(i);
                  end
                else
                  Inc(i);
          end;
              {

          for i:=0 to DelFiles.Count-1 do
             begin
             if CompareDateTime(DelFiles.GetDate(i), beforedate) = -1 then
                  begin
                  DelFile(PathCombine(DestDir,DelFiles.GetName(i)));
                  DelFiles.Delete(i);
                  //Dec(i);
                  end;
             end;
             }
          // Если каталог пуст, удаляем
          if Recurse AND (Not IsSubDir) AND (not (directoryexists(SorDir))) And (DelFiles.Count=0) then // директория приемника не существует и все файлы удалены, подкаталогов нет
               begin
               Result:=Max(Result,DelDirs(DestDir));
               end
          end;
  DelFiles.SaveToFile;
  DelFiles.Destroy;
  end;

end;

//=================================================================
//   SorDir => DestDir
// копирует директорию SorDir в DestDir
// DestDir - Приемник
 // NumTask - номер задачи в массиве заданий
 // Recurse - true - рекурсивный вызов
 //           false - первый вызов
 // NTFSCopy - Копировать права NTFS
//Возвращает Код ошибки

function TTaskCl.SimpleCopyDirs(SorDir, DestDir: string; NumTask: integer; Recurse: boolean;NTFSCopy:boolean): integer;
var
  sr: TSearchRec;
  FileAttrs: integer;
  filesync, filesor: string;
  SubSorDir,SubDestDir:string;
 // NTFSCopy: boolean;
//  TypeSync: integer;
 // DelFiles:TDeletedFiles;
 // IsStoreDel:boolean; // Зеркалирование, да еще и сохранением удаленных файлов
  //  sordata,destdata:integer; // даты файлов источ и приемника
  //  res:boolean;
begin
  Result := trOk;
  //res:=true;
  // trOk=0; // Все ок
  //  trError=1; // Ошибка запуска задания (недоступен каталог)
  //  trFileError=2; // Ошибка копирования файла в задании
  if recurse and not Tasks[NumTask].SourceFilt.Recurse then exit; // подкаталоги не обрабатывать
//  NTFSCopy := Tasks[NumTask].NTFSPerm;
   {
  if not Recurse then
  begin
    NTSetPrivilege('SeSecurityPrivilege', True);
    if not CheckDirs(NumTask) then // Проверка существования каталогов приемника и источника из задания
      begin
      Result:=trError;
      exit;

      end;
  end;
  }
  if (recurse) and (NTFSCopy) then     // вызов рекурсивный - копируются права на директорию
  begin
    CopyNTFSPerm(SorDir, DestDir);
  end;
  FileAttrs := faDirectory + faReadOnly + faHidden + faSysFile + faArchive+faAnyFile;
  // Проходим по файлам и директориям
  if FindFirst(PathCombine(SorDir, '*'), FileAttrs, sr) = 0 then
  begin
    repeat
      begin

     if (sr.Attr and faDirectory) <> 0 then // Это директория
      begin
        if not SameText(sr.Name, '.') and not SameText(sr.Name, '..') then
        begin
          SubSorDir := PathCombine(SorDir, sr.Name);
          SubDestDir  := PathCombine(DestDir, sr.Name);
          if CheckSubDir(SubSorDir, NumTask) then
            if SimpleCopyDirs(SubSorDir, SubDestDir, NumTask, True,NTFSCopy) = trFileError then
              Result := trFileError;
        end;
      end
     else   // Это файл
      begin

        if (CheckFileMask(sr.Name, NumTask)) AND (Not SameText(sr.Name,DeletedFilesF)) then
          // Проверка файла на маску и что это не файл с данными удаленных файлов
        begin
          filesync := PathCombine(DestDir, sr.Name); // Имя файла приемника
          filesor  := PathCombine(SorDir, sr.Name); // Имя файла источника
          if FileExists(filesync) then
                // файл в каталоге приемнике уже есть
          begin // Тогда сверяются даты
                // sordata:=sr.Time;
                // destData:=FileAge(filesync);
                //if CompareFileDate(sordata,destdata) then
            if CompareFileDate(filesor, filesync) then
            begin
              OnProgress(nil, NewFile, sr.Name, sr.Size);
              // Вызов события для обработки потоком
              if not SyncFiles(filesor, filesync, NTFSCopy, recurse) then
                Result := trFileError; // синхронизация файлов
              OnProgress(nil, ProgressUpdate, '', sr.Size);
              // Вызов события для обработки потоком
            end;

          end
          else // файл приемник не существует
          begin
            OnProgress(nil, NewFile, sr.Name, sr.Size);
            if not SyncFiles(filesor, filesync, NTFSCopy, recurse) then
              Result := trFileError; // синхронизация файлов
            OnProgress(nil, ProgressUpdate, '', sr.Size);
          end;
        end;// if checkfilemask
       end;
      end;
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;

//  OnProgress(nil, EndOfBatch, '', 0);
end;






 //======================================================================
 // Создание каталога
function TTaskCl.ForceDir(DirName: string): boolean;
var
  str: string;
  res: boolean;
begin
  Result := True;
  if DirectoryExists(DirName) then
    exit;
  // Удаляем файл
  try
    res := ForceDirectories(DirName);
  except
    On E: Exception do
    begin
      Result := False;
      str    := E.Message;
      str    := Format(rsLogDirCreateErr, [ansitoutf8(DirName), str]);
      exit;
    end;
  end;

  if res then
  begin
    Result := True;
  end
  else
  begin
    Result := False;
    str    := SysErrorMessage(GetLastError);
    str    := Format(rsLogDirCreateErr, [ansitoutf8(DirName), str]);
    LogMessage(str);
  end;

end;
 //=====================================================================
 // Сврека даты/времени двух файлов
// Возвращает true если aDate>bDate и разница между ними <> ровно 1 час
 // true - файл копировать, false - не копироваь
 // aDate, bDate - Дата время двух файлов
{
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
}
 //=====================================================================
 // Сврека даты/времени двух файлов
// Возвращает true если aDate>bDate и разница между ними <> ровно 1 час
 // true - файл копировать, false - не копироваь
 // aFileName, bFilename - Полные пути к двум файлам
function TTaskCl.CompareFileDate(aFileName, bFileName: string): boolean;
var
  Hourd: double;
  aaDate, bbDate: TDateTime; // Нормальное время
  aDate, bDate: integer;     // Файловое время
  str:   string;
begin
  try
    aDate := FileAge(aFileName);
    if aDate = -1 then // Ошибка чтения даты
    begin
      Result := True;
      str    := Format(rsLogFileDateErr, [ansitoutf8(aFileName)]);
      LogMessage(str);
      Exit;
    end;
    bDate := FileAge(bFileName);
    if bDate = -1 then // Ошибка чтения даты
    begin
      Result := True;
      str    := Format(rsLogFileDateErr, [ansitoutf8(bFileName)]);
      LogMessage(str);
      Exit;
    end;
    aaDate := FileDateToDateTime(aDate);
    // Приводим к нормальному времени
    bbDate := FileDateToDateTime(bDate);
    if CompareDateTime(aaDate, bbDate) > 0 then // файл источник позже
    begin
      Result := True;
      hourd  := HourSpan(aaDate, bbDate); // разница в часах
      if hourd = 1 then
        Result := False
      else
        Result := True;
    end
    else
      Result := False;

  except
    On E: Exception do
    begin
      Result := True;
      str    := ansitoutf8(E.Message);
      str    := Format(rsLogFileDateErrEx,[ansitoutf8(aFileName), ansitoutf8(bFileName), str]);
      exit;
    end;
  end;
end;
 //======================================================================
 // Расчет размера копируемой директории
function TTaskCl.GetSizeDir(dir, syncdir: string; NumTask: integer; Recurse: boolean): integer;
var
  sr: TSearchRec;
  FileAttrs: integer;
  //  dir,syncdir:String;
  filesync: string;
  // NTFSCopy:Boolean;
  TypeSync: integer;
  sordata, destdata: TDateTime; // даты файлов источ и приемника
begin
  Result := 0;
  if recurse and not Tasks[NumTask].SourceFilt.Recurse then
    exit; // подкаталоги не обрабатывать
  if not recurse then
    TotalSize := 0;
  TypeSync    := Tasks[NumTask].Action;
  if not Recurse then
  begin
    if not DirectoryExists(dir) then
      // каталога-источника не существует
    begin
      exit; // айяй
    end;
  end;
  FileAttrs := faReadOnly + faHidden + faSysFile + faArchive + faAnyFile;
  // сначала файлы
  if FindFirst(dir + DirectorySeparator + '*', FileAttrs, sr) = 0 then
  begin
    repeat
      begin

        if CheckFileMask(sr.Name, NumTask) then
          // Проверка файла на маску
        begin
          filesync := syncdir + DirectorySeparator + sr.Name; // Имя файла приемника
          if FileExists(filesync) then
                // файл в каталоге приемнике уже есть
          begin // Тогда сверяются даты
            sordata  := FileDateToDateTime(sr.Time);
            // дата время модификации файла источника
            destdata := FileDateToDateTime(FileAge(filesync));
            // дата файла премника
            if CompareDateTime(sordata, destdata) > 0 then
              // файл источник позже
            begin
              TotalSize := TotalSize + sr.size;
              // Добавляем размер файла
              //               if Not SyncFiles(dir+'\'+sr.Name,filesync,NTFSCopy,recurse) then Result:=trFileError; // синхронизация файлов
            end;
            if TypeSync = ttSync then // если синхронизация
            begin
              if CompareDateTime(destdata, sordata) > 0 then
                // файл источник раньше
              begin
                TotalSize := TotalSize + sr.size;
                // Добавляем размер файла
                //               if Not SyncFiles(filesync,dir+'\'+sr.Name,NTFSCopy,recurse) then Result:=trFileError; // синхронизация файлов наоборот
              end;
            end;
          end
          else // файл приемник не существует
          begin
            TotalSize := TotalSize + sr.size; // Добавляем размер файла
            //             if Not SyncFiles(dir+'\'+sr.Name,filesync,NTFSCopy,recurse) then Result:=trFileError; // синхронизация файлов
            //LogMessage('Файл скопирован: '+filesync);
          end;
        end;// if checkfilemask
      end;
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;
  FileAttrs := faReadOnly + faHidden + faSysFile + faArchive + faAnyFile + faDirectory;
  if (TypeSync = ttSync) or (TypeSync = ttZerk) then
    // если синхронизация или зеркалирование
  begin
    if FindFirst(syncdir + DirectorySeparator + '*', FileAttrs, sr) = 0 then
    begin
      repeat
        begin
          filesync := dir + DirectorySeparator + sr.Name; // Имя файла источника
          if ((sr.Attr and faDirectory) <> 0) and (CheckSubDir(filesync, NumTask)) then
            // это директория
          begin
            if not directoryexists(filesync) then
              // директория приемника не существует
            begin
              if TypeSync = ttZerk then // зеркалирование
              begin
                //               DelDirs(syncdir+'\'+sr.Name);
                //               LogMessage('Удалена директрория: '+syncdir+'\'+sr.Name);
              end
              else // синхронизирование
              begin
                GetSizeDir(syncdir + DirectorySeparator + sr.Name, filesync, NumTask, True);
                // Синхронизация подкаталогов
                //                SyncDirs(syncdir+'\'+sr.Name,filesync,2,NTFSCopy,true); // Синхронизация подкаталогов
              end;
            end;
          end
          else // это файл
          begin
            if CheckFileMask(sr.Name, NumTask) then
            begin
              if not FileExists(filesync) then
                // файл источник не существует
              begin
                if TypeSync = ttZerk then // зеркалирование
                begin

                end
                else // синхронизация
                begin
                  TotalSize := TotalSize + sr.size;
                  // Добавляем размер файла
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
  FileAttrs := faDirectory + faReadOnly + faHidden + faSysFile + faArchive;
  if FindFirst(dir + DirectorySeparator + '*', FileAttrs, sr) = 0 then
  begin
    repeat
      if (sr.Attr and faDirectory) <> 0 then
      begin
        if not SameText(sr.Name, '.') and not SameText(sr.Name, '..') then
        begin
          if CheckSubDir(dir + DirectorySeparator + sr.Name, NumTask) then
            GetSizeDir(dir + DirectorySeparator + sr.Name, syncdir + DirectorySeparator + sr.Name, NumTask, True);
          //             SyncDirs(dir+'\'+sr.Name,syncdir+'\'+sr.Name,TypeSync,NTFSCopy,true);
        end;
      end;
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;

end;


 //================================================================
 // Простая шифрация строки

function TTaskCl.CryptStr(Str: string): string;
var
  len, i, intsym: integer;
  crypts: string;
  sym:    string;
begin
  crypts := '';
  len    := Length(Str);
  Result := crypts;
  if len = 0 then
    exit;
  Randomize;
  if len > 1 then
  begin
    for i := 1 to len do
    begin
      ;
      if i = len then
        intsym := (33 xor Ord(Str[i]))
      else
        intsym := ((Ord(Str[i]) xor Ord(Str[i + 1])));
      sym := IntToHex(intsym, 2);
      crypts := crypts + sym;
    end;
  end
  else
  if len > 0 then
    crypts := IntToHex((Ord(Str[1]) xor 33), 2);
  crypts   := IntToHex((len xor 35), 2) + crypts; // добавление длины строки
  crypts   := IntToHex(Random(200), 2) + crypts; // случайная цифра

  for i := len to 30 do
    //добавление длины строки случайными цифрами
  begin
    crypts := crypts + IntToHex(Random(200), 2);
  end;

  Result := crypts;
end;
 //========================================================================
 // Дешифрация строки
function TTaskCl.DecryptStr(Str: string): string;
var
  len, i:   integer;
  decrypts: string;
  sym:      char;
begin
  decrypts := '';
  Result   := decrypts;
  if Str = '' then
    exit;
  len := HexStrToInt(Str, 2) xor 35;
  if len > 1 then
  begin
    for i := len downto 1 do
    begin
      ;
      if i = len then
        sym := chr(33 xor (HexStrToInt(Str, i + 2)))
      else
        sym := chr(HexStrToInt(Str, i + 2) xor Ord(decryptS[len - i]));
      decrypts := decrypts + sym;
    end;
  end
  else
  if len > 0 then
    decrypts := chr(HexStrToInt(Str, 3) xor 33);

  Result := ReverseString(decrypts);
end;
 //===================================================
 // Вспомогательная функция для DecryptStr
// Str функция состоящяя из Hex цифр (2 символа на цифру)
 // Pos - нужная позиция (в одной позиции по 2 символа)
 // Возвращает число из позиции
function TTaskCl.HexStrToInt(Str: string; Pos: integer): integer;
var
  intsym: integer;
  hexstr: string;
begin
  hexstr := '$' + str[pos * 2 - 1] + str[pos * 2];
  intsym := StrToInt(hexstr);
  Result := intsym;
end;


end.


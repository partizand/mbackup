unit backup;

{
// Модуль содержащий класс TTaskCl.
Работа с заданиями


}
{$mode objfpc}{$H+}

interface

uses Windows, SysUtils, DateUtils, Classes, StrUtils, masks, Process,//fileutil,
  {iniLangC,} XMLCfg,{ inifiles,}gettext,translations,fileutil,
  setunit,unitfunc,delfiles,customfs,filefs,ftpfs,tasklist,task, // Мои модули
 { idAttachmentFile,idsmtp,idmessage,}{idAttachment,} {,IdExplicitTLSClientServerBase,IdSSLOpenSSL,idiohandler} // Indy10
  smtpsend,mimemess,mimepart,synachar,ssl_openssl,httpsend{, blcksock} //synapse
  ;
//uses FileCtrl;

const
  VersionAS   = '0.5.3'; // Версия программы
  TempLogName = 'log.txt'; // Имя временного лог файла (отправляемого по почте)
  LastVerLnk   = 'http://atsave.narod.ru/autosave/update.html'; // Страничка с номером последней версии
  LastBinLnk   = 'http://atsave.narod.ru/autosave/mbackup.zip'; // Дистрибутив



type  // Запись для передачи параметров для замены в строках (типа %Name%)
 TReplParam=record
    TaskName:string; // Имя задания
    TaskStatus:string; // Результат задания
//    ComputerName:string; // Имя компьютера
//    ProfileName:string; // Имя профайла с заданиями
    AlertProgStatus:string; // Статус alert (started, finished)
    end;



type // Тип ProgressType для типа события OnProgress
  ProgressType = (NewFile, ProgressUpdate, EndOfBatch, TotalFiles2Process,
    TotalSize2Process, NewExtra, ExtraUpdate, MsgCopy);


// Процедурный тип  (событие, совпадает с описанием события TZipMaster)

type
  TProgressEvent = procedure(Sender: TObject; ProgrType: ProgressType;
    Filename: string; FileSize: int64) of object;

       //--------------------------------------------------------------



  //--------------------------------------------------------------
type
  TBackup = class
//    Tasks: array[1..MaxTasks] of TTask; //Массив заданий
    Tasks: array of TTask; //Массив заданий
    //Tasks:TTaskList;
    // Типа конструктор
    constructor Create;
    destructor Destroy; override;

    procedure AddTask;
    procedure DelTask(numTask: integer);
    procedure LoadFromFile(filenam: string);
    procedure SaveToFile(filenam: string);
  //  function RunTask(num: integer; countsize: boolean): integer;

    function RunTask(num: integer; countsize: boolean): integer;

    function FindTaskSt(state: integer): integer;
    // procedure RunThTask(num:integer);

    class function GetNameFS(FSParam:TFSparam):string; // Возвращает отображемое имя задания

    procedure CreateFS(FSParam:TFSParam;var CustomFS:TCustomFS); // Создает объект FS

    //  procedure SyncFiles(sorfile,destfile:string;NTFSCopy:Boolean);
//    function CopyNTFSPerm(sorfile, destfile: string): boolean;
//    function NTSetPrivilege(sPrivilege: string; bEnabled: boolean): boolean;
    // function SyncDirs(dir,syncdir:string;TypeSync:Integer;NTFSCopy:Boolean;Recurse:Boolean):boolean;

    //  procedure SyncDirs(dir,syncdir:string;Sync:Boolean);

    procedure LogMessage(logmes: string);
    procedure LogMessage(MesStrings: TStringList);
    //function ArhDir(sourdir,destdir:string;arhname:string):boolean;
//    function ArhRarDir(NumTask: integer): integer;
    //function ArhZipDir(numtask: integer): integer;
//    function Arh7zipDir(NumTask: integer): integer;

  //  function SendMail(Subj:string;Body:string;FileName:string;var MsgError:string):boolean; //Indy10

    function SendMailS(Subj:string;Body:string;FileName:string;var MsgError:string):boolean; //Synapse
    class function SendMailEx(Settings:TSettings;Subj:string;Body:string;FileName:string;var MsgError:string):boolean; //Synapse
    procedure SendAlert(ProgStatus:string); //  Отправка уведомления о запуске/завершении работы программы на почту
    // Возвращает имя компа
    class function GetHostName:string;
    //  procedure DelOldArhs(dir,arhname:string;olddays,oldMonths,OldYears:integer);
    //  function WinExecute(CmdLine: string; Wait: Boolean): Boolean;


    //function  GetFileNam(shortnam:String):String;
    procedure DublicateTask(NumTask: integer);
    //procedure TaskCopy(NumTask:integer);

    procedure UpTask(NumTask: integer);
    procedure DownTask(NumTask: integer);
    function GetSizeDir(dir, syncdir: string; NumTask: integer; Recurse: boolean): integer;
//    procedure ReplaceNameDisk(NumTask: integer; replace: boolean);
//    function ShortFileNam(FileName: string): string;
//    function FullFileNam(FileName: string): string;
//    function CryptStr(Str: string): string;
//    function DecryptStr(Str: string): string;

   class function GetFullExePath(const Executable: String):string; // Возвращает полный путь для исполняемого файла
    procedure Clear; // Очистка списка заданий
   // procedure ReadIni;
//    procedure SaveIni;
    function ReadArgv(var IsProfile: boolean): boolean;
//    class function CheckNewVer:boolean;
    // Проверка наличия новой версии в интернете (-1 - Не подключились, 0-нет, 1-есть новая версия NewVer)
    class function CheckNewVer(var NewVer:string):integer;
    class function GetVer: string;



    // Скопировать задания (перегружена)
    class procedure CopyTask(var FromTask:TTask;var ToTask:TTask);
    //  procedure SendMail(MesSubject:string;MesBody:TStrings);
    //  procedure StrToList (Str:string;var StrList:StringList);
  private
    //procedure CheckFileSize(FileNam:string);
    // Задание копирования каталогов через FS
    function CopyDirFS(NumTask:integer;var SrcFS:TCustomFS;var DstFS:TCustomFS):integer;
    function SynDirFS(NumTask:integer;var SrcFS:TCustomFS;var DstFS:TCustomFS):integer;
    function ZerkDirFS(NumTask:integer;var SrcFS:TCustomFS;var DstFS:TCustomFS):integer;

    function ArhRarDirFS(NumTask: integer;SrcFS:TCustomFS;DstFS:TCustomFS): integer;
    function BuildRarFileList(NumTask: integer;ArhFullName:string;SrcFS:TCustomFS): string; // Построение командной строки для архивации RAR

    function Arh7zipDirFS(NumTask: integer;var SrcFS:TCustomFS;var DstFS:TCustomFS): integer;
    function Build7zipFileList(NumTask: integer;ArhFileName:string;SrcFS:TCustomFS): string; // Построение командной строки для архивации 7zip

    function CheckFileMask(FileName: string; NumTask: integer): boolean;
    function CheckSubDir(SubDir: string; NumTask: integer): boolean;

    procedure BuildFS(const S:string;var FSParam:TFSParam);
    // Раскусывает строку S на две через разделитель split, если разделителя нет, то Part2 - пустая, а Part1=S
    procedure Split2String(const S:string; const Split:string; var Part1:string;var Part2:string);

    procedure RunExtProg(ExtProg:TExtProg;Cond:integer); // Запуск внешней проги в задании

     // Возвращает значения тэга <TagName>возвращаемое значение</TagName> из строки Content
    function GetTagValue(Content:TStrings;TagName:string):string;


    function SimpleGetSizeDirFS (SorDir,DestDir:string;var SrcFS:TCustomFS;var DstFS:TCustomFS; NumTask: integer; Recurse: boolean): int64;
    function GetSizeDirFS (var SrcFS:TCustomFS;var DstFS:TCustomFS; NumTask: integer): int64;

    procedure WriteFileStr(filenam, str: string);

//    function DelDirs(dir: string): integer;

    function DelDirsFS(dir: string;var CustomFS:TCustomFS): integer;

    function DelFile(namef: string): integer;
    function DelFileFS(ShortFileName: string;CustomFS:TCustomFS):integer;

    function ForceDir(DirName: string): boolean;

    // Поменять задания местами
    procedure SwapTask(NumTask1,NumTask2:integer);

    procedure CopyTask(FromTask, ToTask: integer);

    // Выполнение внешней программы (платформо независимая)
    function ExecProc(const FileName, Param: string; const Wait: boolean): integer;




    procedure GetFileList(sordir: string; NumTask: integer; var FileList: TStrings; recurse: boolean; ForZip: boolean);
    function GetArhFileName(numtask:integer):string;
    function GetArhDir(NumTask:integer;SrcFS,DstFS:TCustomFS;var TmpExist:boolean):string;

//    function CheckSubDirFS(SubDir: string; NumTask: integer;CustomFS:TCustomFS): boolean;


    Function DosToWin(Const S: String) : String;
    function CompareFileDateFS(SorFS,DestFS:TCustomFS; FileName: string): boolean;


    procedure DelOldArhsFS(NumTask: integer;CustomFS:TCustomFS);
    function MinInRange(ArhList:array of TArhList;DateBeg,DateEnd:TDateTime):integer;

    procedure SaveToXMLFile(filenam: string);
    procedure LoadFromXMLFile(filenam: string);
    function ReplDate(S: string): string;
    function ReplaceParam(S:string;numtask:integer):string;
    function ReplaceParamEx(const S:string;RParam:TReplParam):string;

    function ReplDateToMask(S: string): string;
    function FindStrVar(S: string): string;

    function SimpleCopyDirsFS(SorDir, DestDir: string; var SorFS:TCustomFS;var DestFS:TCustomFS; NumTask: integer; Recurse:boolean): integer;

    function CopyFileFS(FromFS,ToFS:TCustomFS;F:TSearchRecFS;CurResult:integer):integer;

    function SimpleCopyFileFS(FromFS,ToFS:TCustomFS;ShortFileName:string):boolean;


    function DelOldFilesFS(SorDir, DestDir: string;var SrcFS:TCustomFS;var DstFS:TCustomFS; NumTask: integer; Recurse: boolean): integer;
    function ClearDelFiles(NumTask:integer;SrcFS,DstFS:TCustomFS;DelFiles:TDeletedFiles):integer;


   Private

    TotalSize:  int64; // Общий размер файлов при копировании

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
    ParamQ:   boolean;  // -q  В строке запуска есть команда выхода по окончании
    InCmdMode: boolean;  // Запуск заданий происходит из командной строки (для одно разово дневных заданий)
    AlertStart:boolean; // -as в командной строке
    AlertFinish:boolean; // -af в командной строке
    Count:    integer; //Количество заданий




  end;







implementation

uses msgstrings{, SendMailUnit}{,potranslator};

 //=====================================================
 // Конструктор
constructor TBackup.Create;
begin
  inherited Create;
  Count  := 0;
  SetLength(Tasks,0);
  //Tasks:=TTaskList.Create;
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
destructor TBackup.Destroy;
begin
LastStdOut.Destroy;
Settings.Destroy;
//DelFiles.Destroy;
inherited Destroy;
end;
//==============================================================
Function TBackup.DosToWin(Const S: String) : String;
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
class function TBackup.GetVer: string;
begin
  Result := VersionAS;
end;
  {
 //=====================================================
 // Чтение настроек программы из Ini файла
procedure TBackup.ReadIni;
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
procedure TBackup.SaveIni;
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
// Проверка наличия новой версии в интернете
// -1 - не удалось подключиться
//  0  - обновлений нет
//  1  - Обновлнеие есть
class function TBackup.CheckNewVer(var NewVer:string):integer;
var
  Lines:TStringList;
  //NewVer:string;
begin
 Lines:=TStringList.Create;
 if (HttpGetText(LastVerLnk,Lines)) then
     begin
     NewVer:=GetTagValue(Lines,'versionas');
     if SameText(NewVer,VersionAS) then
            Result:=0
          else
            Result:=1
     end
    else
     Result:=-1;
 Lines.Free;
end;
//=======================================================
// Возвращает значения тэга <TagName>возвращаемое значение</TagName> из строки Content
function TBackup.GetTagValue(Content:TStrings;TagName:string):string;
var
  i,len:integer;
  strTagStart,strTagEnd:string;
  PosStart,PosEnd:integer;
begin
Result:='';
strTagStart:='<'+TagName+'>';
strTagEnd:='</'+TagName+'>';
for i:=0 to Content.Count-1 do
  begin
   // Ищем начало тэга
  PosStart:=Pos(strTagStart,Content[i]);
  if PosStart=0 then continue;
  PosEnd:=Pos(strTagEnd,Content[i]);
  if PosEnd=0 then continue;
  len:=Length(strTagStart);
  Result:=MidStr(Content[i],PosStart+Len,PosEnd-PosStart-len);
  Result:=Trim(Result);
  exit;
  end;
end;

 //=======================================================
 // Чтение командной строки
 // Загружает нужный профиль и
// Возвращает true если нужно запускать задания из этого профиля
// IsProfile - true-обработка профиля, иначе задача задана из командной строки
function TBackup.ReadArgv(var IsProfile: boolean): boolean;
  //=====================================================
var
  i,StartIndx:     integer;
  s, p:     string;
  sour, dest: string; // Источник, получатель
  act:      integer;  // действие
  recurs:   boolean;  // Обрабатывать рекурсивно
//  alertsubj: string;   //TStrings;
//  alertbody:string;
//  RParam:TReplParam;
//  SendMail: TSendMail;
  // est:boolean;
//  MsgErr:string;
  estp:     boolean; // Есть профиль на загрузку
  estr:     boolean; // Есть параметр /r
begin
  //alertmes:='';TStringList.Create;
//  j      := paramcount; // Кол-во параметров командной строки
  StartIndx:=1; // C какого номера параметров начинать их перебирать
  ParamQ := False; // Есть параметр закрыть прогу
  sour   := '';    // Источник и приемник не указаны
  dest   := '';
  recurs := False;
  act    := 0; // Действие не указано
  estp   := False;
  IsProfile := False;
  estr   := False;
  AlertFinish:=false;
  AlertStart:=false;
//  Clear; //Count:=0;
  if paramcount>=3 then // Пробуем найти действие, источник и получатель
      begin
          if SameText(ParamStr(1), 'copy') then // Указание действия copy
          begin
            act := ttCopy;
          end;
          if SameText(ParamStr(1), 'sync') then // Указание действия sync
          begin
            act := ttSync;
          end;
          if SameText(ParamStr(1), 'mirr') then // Указание действия mirr
          begin
            act := ttZerk;
          end;
         if act<>0 then
             begin
              sour:=ParamStr(2);
              dest:=ParamStr(3);
              StartIndx:=4;
             end;
      end;
  for i := StartIndx to paramcount do // перебор всех параметров
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
    if SameText(s, '-as') then // Уведомление о запуске
    begin
     //SendAlert(rsStarted);
     AlertStart:=true;
    end;

   if SameText(s, '-af') then // Уведомление о завершении
      begin
      AlertFinish:=true;
      end;


    if SameText(s, '-p') then // загрузка профиля
    begin
      //    i:=i+1;
      if i + 1 <= paramcount then
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
      if i + 1 <= paramcount then
        p := ParamStr(i + 1)
      else
        continue;
      Settings.logfile := p;
    end;
    {
    //--------
    if SameText(s, '-source') then // Указание источника
    begin
      if i + 1 <= j then
        p := ParamStr(i + 1)
      else
        continue;
      sour := p;
    end;
    }
    //--------
    if SameText(s, '-recurse') then // Указание рекурсии
    begin
      recurs := True;
    end;
    {
    //--------
    if SameText(s, '-dest') then // Указание получателя
    begin
      if i + 1 <= j then
        p := ParamStr(i + 1)
      else
        continue;
      dest := p;
    end;
    }
    {
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
    }
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
        Tasks[0].Name := 'Cmd';
        Tasks[0].Action := act;
        BuildFS(sour,Tasks[0].SrcFSParam); // читаем источник
        //Tasks[0].SrcFSParam.RootDir:= sour;
        //Tasks[0].SrcFSParam.FSType:=fstFile;
        BuildFS(dest,Tasks[0].DstFSParam); // читаем приемник
        //Tasks[0].DstFSParam.RootDir:= dest;
        //Tasks[0].DstFSParam.FSType:=fstFile;
        Tasks[0].SourceFilt.Recurse := recurs;
        estr := True;
      end;

    end;
  end;


  //InCmdMode:=estr;
  Result := estr; // Есть ли задания на запуск
  //alertmes.Destroy;// Free;
end;
//================================================================
{ Расшифровывает строку S в параметры источника или приемника FSParam
 S - может быть именем каталога, или указанием ftp сервера
 ftp://пользователь:пароль@сервер:порт/папка
 }
procedure TBackup.BuildFS(const S:string;var FSParam:TFSParam);
var
  str:string;
  SrvParam:string;
  i,len:integer;
  Part1,Part2:string;
  strftp,strftps:string;
begin
str:=LeftStr(S,6); // ftp://
strftp:='ftp://';
strftps:='ftps://';
if (Pos(strftp,S)>0) or (Pos(strftps,S)>0) then // SameText(str,'ftp://') then // Это фтп
    begin
    FSParam.FSType:=fstFTP;

    if Pos(strftps,S)>0 then FSParam.FtpServParam.AutoTLS:=true;
    FSParam.FtpServParam.Host:='';
    FSParam.FtpServParam.Port:='21';
    FSParam.FtpServParam.UserName:='anonymous';
    FSParam.FtpServParam.Password:='anonymous@mymail.com';
    FSParam.FtpServParam.PassiveMode:=true;
    if Pos(strftp,S)>0 then  // ftp://
          begin
           FSParam.FtpServParam.AutoTLS:=false;
           SrvParam:=RightStr(S,Length(S)-Length(strftp)); // выкусываем ftp://
          end
        else
          begin    // ftps://
            FSParam.FtpServParam.AutoTLS:=true;
            SrvParam:=RightStr(S,Length(S)-Length(strftps)); // выкусываем ftps://
          end;
//    SrvParam:=RightStr(S,Length(S)-6); // выкусываем ftp://
    // Ищем слэш
    //SrvParam=пользователь:пароль@сервер:порт/папка
    Split2String(SrvParam,'/',Part1,Part2); //Part1=пользователь:пароль@сервер:порт Part2=папка
    FSParam.FtpServParam.InintialDir:='/'+Part2;
    SrvParam:=Part1;   // пользователь:пароль@сервер:порт
    // Ищем @
    Split2String(SrvParam,'@',Part1,Part2);
    if Part2<>'' then
           begin //Part1=пользователь:пароль Part2=сервер:порт
             SrvParam:=Part2;
             // Разделяем Part1=пользователь:пароль
             str:=Part1;
             Split2String(str,':',Part1,Part2);
             FSParam.FtpServParam.UserName:=Part1;
             if Part2<>'' then //Part1=пользователь Part2=пароль
                  begin
                  FSParam.FtpServParam.Password:=EncryptString(Part2,KeyStrTask);
                  end;
           end;
     // Разделяем SrvParam=сервер:порт
     Split2String(SrvParam,':',Part1,Part2);
     FSParam.FtpServParam.Host:=Part1;
     if Part2<>'' then FSParam.FtpServParam.Port:=Part2;
    end
  else
    begin       // Это каталог
    FSParam.FSType:=fstFile;
    FSParam.RootDir:=S;
    end;
end;
//================================================================
// Раскусывает строку S на две через разделитель split, если разделителя нет, то Part2 - пустая, а Part1=S
procedure TBackup.Split2String(const S:string; const Split:string; var Part1:string;var Part2:string);
var
  i:integer;
begin
i:=Pos(Split,S);
    if i=0 then // Разделителя нет
           begin
           Part1:=S;
           Part2:=''
           end
         else
           begin
           Part1:=LeftStr(S,i-1);
           Part2:=RightStr(S,Length(S)-i-Length(Split)+1);
           end;
end;

//================================================================
// Возвращает отображемое имя FS
class function TBackup.GetNameFS(FSParam:TFSparam):string;
begin
Result:='';
if FSParam.FSType=fstFile then
     Result:=FSParam.RootDir;
if FSParam.FSType=fstFTP then
     Result:=TFTPFS.GetFtpName(FSParam.FtpServParam);
end;

 //================================================================
 // добавление пустого задания в массив
procedure TBackup.AddTask;
begin
  // Найти свободный элемент
  if Count = MaxTasks then
    exit;


  SetLength(Tasks,Count+1);

  Tasks[Count].Name      := '';
  Tasks[Count].SrcFSParam.RootDir   := '';
  Tasks[Count].SrcFSParam.FSType:=fstFile;
  Tasks[Count].SrcFSParam.FtpServParam.Port:='21';
  Tasks[Count].DstFSParam.RootDir := '';
  Tasks[Count].DstFSParam.FSType:=fstFile;
  Tasks[Count].DstFSParam.FtpServParam.Port:='21';
  Tasks[Count].Action    := 0;
  Tasks[Count].Arh.Name  := 'arh%YYMMDD%';
  //Tasks[count].Rasp.Time:=GetLocalTime;
  Tasks[Count].Rasp.OnceForDay := False;
  //Tasks[count].Rasp.Time:=Time;
  //GetLocalTime(Tasks[count].Rasp.Time);
  //Tasks[count].Rasp.EvMinutes:=false;
  //Tasks[count].Rasp.Minutes:=60;
  Tasks[Count].Enabled   := True;
  // Архив
  Tasks[Count].Arh.DelOldArh := False;
  Tasks[Count].Arh.DelAfterArh := False;
  Tasks[Count].Arh.DaysOld := 7;
  Tasks[Count].Arh.MonthsOld := 12;
  Tasks[Count].Arh.YearsOld := 5;
  Tasks[Count].Arh.EncryptEnabled:=false;
  Tasks[Count].Arh.LevelCompress:= lcNormal;
  Tasks[Count].Arh.ArhOpenFiles:=false;
  Tasks[Count].Arh.Solid:=false;
  Tasks[Count].Arh.AddOptions:='';

  Tasks[Count].Enabled   := True;
  Tasks[Count].Status    := stNone;
  Tasks[Count].LastRunDate := 0;
  Tasks[Count].LastResult := trOk;
  Tasks[Count].ExtBefore.Enabled:= False;
  Tasks[Count].ExtBefore.Cmd := '';
  Tasks[Count].ExtBefore.Condition:=-1;

  Tasks[Count].ExtAfter.Enabled := False;
  Tasks[Count].ExtAfter.Cmd := '';
  Tasks[Count].ExtAfter.Condition := -1;

  Tasks[Count].NTFSPerm  := False;
  Tasks[Count].MailAlert := 0;

  Tasks[Count].SourceFilt.Recurse    := True;
  Tasks[Count].SourceFilt.FiltSubDir := False;
  Tasks[Count].SourceFilt.SubDirs    := '';//TStringList.Create;
//  Tasks[Count].SourceFilt.SubDirs.Delimiter := ';';
  //Tasks[count].SourceFilt.SubDirs.Clear;
  Tasks[Count].SourceFilt.FiltFiles  := False;
  Tasks[Count].SourceFilt.ModeFiltFiles := 0;
  Tasks[Count].SourceFilt.FileMask   :='*.tmp;*.bak';// TStringList.Create;

  Inc(Count);
end;
 //============================================================
 // Очистка списка заданий
procedure TBackup.Clear;
//var
//  i: integer;
begin
  {
  for i := 1 to Count do
  begin
    Tasks[i].SourceFilt.SubDirs.Destroy;
    Tasks[i].SourceFilt.FileMask.Destroy;
  end;
  }
  SetLength(Tasks,0);
  Count := 0;
end;
//=========================================================
// Поиск задания со статусом state, возвращает его номер
// Если не найдено возварщается -1
// Находит первое попавшееся задание с таким статусом
function TBackup.FindTaskSt(state: integer): integer;
var
  i: integer;
begin
  Result := -1;
  for i := 0 to Count-1 do
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
procedure TBackup.DelTask(numTask: integer);
var
  i: integer;
begin
  if numTask > Count-1 then
    exit;
  if numTask < 0 then
    exit;
  for i := numTask + 1 to Count-1 do
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
//  Tasks[Count].SourceFilt.SubDirs.Free;
//  Tasks[Count].SourceFilt.FileMask.Free;
  Dec(Count);
  SetLength(Tasks,Count);
end;
//==================================================
//   Копирование задания с номером FromTask в задание с номером ToTask
//--------------------------------------------------------------------
procedure TBackup.CopyTask(FromTask, ToTask: integer);
begin
  if (FromTask > Count-1) or (ToTask > Count-1) then
    exit;
 CopyTask(Tasks[FromTask],Tasks[ToTask]);
{
  Tasks[ToTask].Enabled  := Tasks[FromTask].Enabled; // задание разрешено
  Tasks[ToTask].Name     := Tasks[FromTask].Name;
  Tasks[ToTask].Status   := Tasks[FromTask].Status;
  Tasks[ToTask].LastResult := Tasks[FromTask].LastResult;
  Tasks[ToTask].LastRunDate := Tasks[FromTask].LastRunDate;
  Tasks[ToTask].SrcFSParam := Tasks[FromTask].SrcFSParam;
  Tasks[ToTask].DstFSParam := Tasks[FromTask].DstFSParam;
  Tasks[ToTask].Action   := Tasks[FromTask].Action;
  Tasks[ToTask].Rasp     := Tasks[FromTask].Rasp;
  Tasks[ToTask].Arh      := Tasks[FromTask].Arh;
  Tasks[ToTask].NTFSPerm := Tasks[FromTask].NTFSPerm;
  Tasks[ToTask].ExtBefore := Tasks[FromTask].ExtBefore;
  Tasks[ToTask].ExtAfter := Tasks[FromTask].ExtAfter;
  Tasks[ToTask].SourceFilt:= Tasks[FromTask].SourceFilt;
  Tasks[ToTask].MailAlert:= Tasks[FromTask].MailAlert;
}

end;
//=============================================================
// Скопировать задания (перегружена)
class procedure TBackup.CopyTask(var FromTask:TTask;var ToTask:TTask);
begin
  ToTask.Enabled  := FromTask.Enabled; // задание разрешено
  ToTask.Name     := FromTask.Name;
  ToTask.Status   := FromTask.Status;
  ToTask.LastResult := FromTask.LastResult;
  ToTask.LastRunDate := FromTask.LastRunDate;
  ToTask.SrcFSParam := FromTask.SrcFSParam;
  ToTask.DstFSParam := FromTask.DstFSParam;


  ToTask.Action   := FromTask.Action;
  ToTask.Rasp     := FromTask.Rasp;
  ToTask.Arh      := FromTask.Arh;
  ToTask.NTFSPerm := FromTask.NTFSPerm;
  ToTask.ExtBefore := FromTask.ExtBefore;
  ToTask.ExtAfter := FromTask.ExtAfter;

  ToTask.SourceFilt:= FromTask.SourceFilt;

  ToTask.MailAlert:= FromTask.MailAlert;
end;

 //==================================================
 //   Поднять задание вверх по списку
 //--------------------------------------------------------------------
procedure TBackup.UpTask(NumTask: integer);
begin
  if NumTask <= 0 then
    exit;
  SwapTask(NumTask,NumTask-1);
  {
  AddTask;
  CopyTask(NumTask, Count);
  CopyTask(NumTask - 1, NumTask);
  CopyTask(Count, NumTask - 1);
  DelTask(Count);
  }
end;
 //==================================================
 //   Опустить задание вниз по списку
 //--------------------------------------------------------------------
procedure TBackup.DownTask(NumTask: integer);
begin
  if NumTask > Count - 1 then
    exit;
  SwapTask(NumTask,NumTask+1);
  {
  AddTask;
  CopyTask(NumTask, Count);
  CopyTask(NumTask + 1, NumTask);
  CopyTask(Count, NumTask + 1);
  DelTask(Count);
  }
end;
//=================================================================
// Поменять задания местами
procedure TBackup.SwapTask(NumTask1,NumTask2:integer);
var
  Task:TTask;
begin
if (NumTask1 > Count-1) or (NumTask1 > Count-1) then
    exit;
if (NumTask1 < 0) or (NumTask1 < 0 ) then
    exit;
CopyTask(Tasks[NumTask1],Task);
CopyTask(Tasks[NumTask2],Tasks[NumTask1]);
CopyTask(Task,Tasks[NumTask2]);
end;

 //=================================================
 // Разбивает строку по ";" на список строк StringList
 //procedure TBackup.StrToList (Str:string;var StrList:StringList);
 //begin
 //StrList.
 //end;
 //=================================================
// Запуск внешнего приложения и ожидание его завершения
// wait =true - ждать, false - не ждать

{
function TBackup.WinExecute(CmdLine: string; Wait: Boolean): Boolean;
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
function TBackup.WinExec(const FileName, Param: string; const Wait: boolean;
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
может быть только именем файла, тогда будет поиск в каталоге запуска и в path
Параметр Params = Параметры, необходимые для запуска внешней программы
Wait - ожидать
Параметр WinState = Указывает - как будет показано окно:
Для этого параметра мы можем так же использовать следующие константы:
SW_HIDE, SW_MAXIMIZE, SW_MINIMIZE, SW_SHOWNORMAL

}
function TBackup.ExecProc(const FileName, Param: string; const Wait: boolean): integer;
var
  AProcess: TProcess;
  //   AStringList: TStringList;
  CmdLine:  string;
  str:string;
begin
try
  { Помещаем имя файла между кавычками, с соблюдением всех пробелов в именах Win9x }
  if Not FilenameIsAbsolute(Filename) then // Передано только имя файла
     begin
     str:=FileUtil.FindDefaultExecutablePath(FileName);
     if str='' then // Файла нет
         begin
         Result:=-1;
         exit;
         end;
     end
    else
      begin
      str:=FileName;
      end;
  CmdLine := '"' + str + '" ' + Param;

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
// Запуск внешней проги
 procedure TBackup.RunExtProg(ExtProg:TExtProg;Cond:integer);
 var
   ExitCode:integer;
   str:string;
 begin
  if ExtProg.Enabled then  // Запуск внешней программы
  begin
    if (ExtProg.Condition=-1) or (Cond<=ExtProg.Condition) then
       begin
       str:=GetFullExePath(Utf8ToAnsi(ExtProg.Cmd));
       if str<>'' then
       //if FileExists(Utf8ToAnsi(ExtProg.Cmd)) then
          begin
          LogMessage(rsLogExtProgRun +' ' + ExtProg.Cmd);
          ExitCode := ExecProc(str, '', True);
          str:= format(rsLogExtProgEnd, [IntToStr(ExitCode)]);
          LogMessage(str);
          end
         else
          begin // файл с внешней прогой не найден
          str := format(rsLogExtProgErr,[ExtProg.Cmd]);
          LogMessage(str);
          end;
       end;
  end;
 end;
//==================================================
// Возвращает полный путь для исполняемого файла
// Если файл не найден, то возвращается ''
// Executable - может быть полным путем, или только именем файла
// Ищется в каталоге запуска программы или в path
class function TBackup.GetFullExePath(const Executable: String):string;
var
  str:string;
begin
  if ExtractFilePath(Executable)='' then // Передано только имя файла
        begin
        str:=utf8toansi(FullFileNam(Executable));
        if FileExists(str) then
              begin
              Result:=str;
              exit;
              end;
        str:=utf8toansi(FileUtil.FindDefaultExecutablePath(Executable));
        Result:=str;
        exit;
        end
     else
        begin
        str:=Executable;
        if FileExists(str) then
              begin
              Result:=str;
              exit;
              end;
        end;
 Result:='';
end;

//==================================================
// Создает объект FS
procedure TBackup.CreateFS(FSParam:TFSParam;var CustomFS:TCustomFS);
var
  str:string;
begin
if FSParam.FSType=fstFile then // файлы
      begin
      CustomFS:=TFileFs.Create;
      CustomFS.RootDir:=ReplDate(FSParam.RootDir);
      CustomFS.RootDir:=Utf8toAnsi(CustomFS.RootDir);
      end;
  if FSParam.FSType=fstFTP then // ftp
      begin
      CustomFS:=TFtpFs.Create;
      CustomFS.RootDir:=ReplDate(FSParam.FtpServParam.InintialDir);
      (CustomFS as TFtpFs).TempDir:=Settings.TempDir;
      (CustomFS as TFtpFs).LogFtp.Enabled:=Settings.LogFtpEnabled;
      (CustomFS as TFtpFs).LogFtp.logfile:=Settings.LogFileFTP;
      (CustomFS as TFtpFs).LogFtp.loglimit:=Settings.LogFTPLimit;
      (CustomFS as TFtpFs).FTPServParam:=FSParam.FtpServParam;//  .Host:=FSParam.FtpServParam.Host;
//      (CustomFS as TFtpFs).FTPServParam.PassiveMode:=FSParam.FtpServParam.PassiveMode;
//      (CustomFS as TFtpFs).FTPServParam.Port:=FSParam.FtpServParam.Port;
//      (CustomFS as TFtpFs).FTPServParam.UserName:=FSParam.FtpServParam.UserName;
//      (CustomFS as TFtpFs).FTPServParam.Password:=FSParam.FtpServParam.Password;
//      (CustomFS as TFtpFs).FTPServParam.InintialDir:=FSParam.FtpServParam.InintialDir;
      if Not (CustomFS as TFtpFs).Connect then
         begin
         str:= Format(rsFTPConnErr, [FSParam.FtpServParam.Host, CustomFS.LastError]);
         LogMessage(str);
         end;
      end;
end;
 //==================================================
 // Функция запуска задания через FS
function TBackup.RunTask(num: integer; countsize: boolean): integer;
var
  SourceFS,DestFS:TCustomFS;
//  AlertMes:  string; // Сообщение высылаемое на почту
  str, subj,body,MsgErr: string;

  AlertType: integer; // Тип уведомлений на почту
  lyear, lmonth, lday, cyear, cmonth, cday: word;  // Год мес день (текущие и из задания)
//  ExitCode:  integer;
begin
//  AlertMes := '';
  Result   := trOk;
  if num > Count-1 then
    exit;
  if num < 0 then
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

  LogMessage('-');
  LogMessage(rsLogRunTask + ': ' + Tasks[num].Name);
//  alertMes := alertMes + (rsAlert + ' ' + Tasks[num].Name) + LineEnding;
//  ReplaceNameDisk(num, True);
  Result:=trOk;
  //------------------------
  // Создание FS
  CreateFS(Tasks[num].SrcFSParam,SourceFS);
  CreateFS(Tasks[num].DstFSParam,DestFS);
  // Проверка на доступность
  if Not SourceFS.IsAvalible(false) then // Источник не найден
     begin
     LogMessage(SourceFS.LastError);
//     OnProgress(nil, EndOfBatch, '', 0);
     Result:=trError;
     end;
  if Not DestFS.IsAvalible(true) then // Приемник не найден
     begin
     LogMessage(DestFS.LastError);
//     OnProgress(nil, EndOfBatch, '', 0);
     Result:=trError;
     end;

  RunExtProg(Tasks[num].ExtBefore,Result);     // Запуск внешней программы до задания

  // Запуск самих заданий

  if Result=trOk then
       begin
        if Tasks[num].Action = ttCopy then // Копирование
           begin
           Result := CopyDirFS(num,SourceFS,DestFS);
           end;
        if Tasks[num].Action = ttSync then // Синхронизирование
           begin
           Result := SynDirFS(num,SourceFS,DestFS);
           end;
        if Tasks[num].Action = ttZerk then // Зеркалирование
           begin
           Result := ZerkDirFS(num,SourceFS,DestFS);
           end;
        if Tasks[num].Action = ttArhRar then // Архивирование Rar
           begin
           Result := ArhRarDirFS(num,SourceFS,DestFS);
           end;
        if Tasks[num].Action = ttArhZip then // Архивирование Zip
           begin
           Result := Arh7ZipDirFS(num,SourceFS,DestFS);
           end;
        if Tasks[num].Action = ttArh7zip then // Архивирование 7zip
           begin
           Result := Arh7zipDirFS(num,SourceFS,DestFS);
           end;
        end;

  RunExtProg(Tasks[num].ExtAfter,Result);     // Запуск внешней программы после задания



  Tasks[num].LastResult  := Result;
  Tasks[num].LastRunDate := Now;
//  ReplaceNameDisk(num, False);
  LogMessage(rsLogTaskEnd);
  SourceFS.Free;
  DestFS.Free;
 {
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
  }
  // Отсылка почты -----
  AlertType := Tasks[num].MailAlert;
  if AlertType > 0 then
  begin
    if (AlertType = alertErr) and (Result = trOk) then
      exit;
    body:=ReplaceParam(Settings.Body,num);
    subj:=ReplaceParam(Settings.Subj,num);
    str := FullFileNam(TempLogName); // Прикладываемый файл
    if Not SendMailS(subj,body,str,MsgErr) then LogMessage(MsgErr);
  end;
OnProgress(nil, EndOfBatch, '', 0);
end;


 //==================================================
 // Функция запуска задания
{
function TBackup.RunTask(num: integer; countsize: boolean): integer;
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
  Result:=RunTaskFS(num,countsize);
  exit;

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
   // str := TempLogName; // Прикладываемый файл
    if Not SendMailS(subj,body,str,MsgErr) then LogMessage(MsgErr);
 //   SendMail.Send(Settings.smtpserv, Settings.smtpport, Settings.mailfrom, Settings.email, subj, AlertMes, str);
    //send mail

  end;


end;
}
{
procedure TBackup.LInitializeISO(var VHeaderEncoding: Char; var VCharSet: string);
begin
 VHeaderEncoding:='B';
// VCharSet:='utf-8';
VCharSet:='utf-16';
// VCharSet:='windows-1251';

end;
}
//=========================================================
// Отправка почты Synapse
// subj - тема письма
// Body - текст письма
// FileName - имя прикладываемого файла (Если не пусто)
// MsgError - ошибка, если возникла
// Возвращает true если все хорошо
function TBackup.SendMailS(Subj:string;Body:string;FileName:string;var MsgError:string):boolean;
begin
Result:=SendMailEx(Settings,Subj,Body,FileName,MsgError);
end;
//=========================================================
{Отправка почты}
class function TBackup.SendMailEx(Settings:TSettings;Subj:string;Body:string;FileName:string;var MsgError:string):boolean; //Synapse
var
   Msg : TMimeMess; //собщение
   MIMEPart : TMimePart; //части сообщения (на будущее)
   SmtpSnd:TSmtpSend;
   BodyList,MailToList:TStringList;
   str:string;
   i:integer;
begin
Result:=true;
Msg := TMimeMess.Create; //создаем новое сообщение
BodyList := TStringList.Create;
  try
// Добавляем заголовки
   try
    Msg.Header.CharsetCode := synachar.UTF_8;
    Msg.Header.Subject := Subj;//тема сообщения
    Msg.Header.From := Settings.mailfrom; //имя и адрес отправителя
    Msg.Header.ToList.Add(Settings.email); //имя и адрес получателя
// создаем корневой элемент
    MIMEPart := Msg.AddPartMultipart('alternate', nil);
    BodyList.Text:=Body;
//    Msg.AddPartText(BodyList, MIMEPart);
    Msg.AddPartTextEx(BodyList, MIMEPart, UTF_8, false, ME_7BIT);
    str:=utf8toansi(FullFileNam(FileName));
    if (FileName<>'') and (FileExists(str)) then
          Msg.AddPartBinaryFromFile(str,MIMEPart);
//          Msg.AddPartBinaryFromFile('mbackup.ini',MIMEPart);

// Кодируем и отправляем
    Msg.EncodeMessage;

 // Отправка классом
    SmtpSnd:=TSmtpSend.Create;
    SmtpSnd.TargetHost:=Settings.smtpserv;
    SmtpSnd.TargetPort:=IntToStr(Settings.smtpport);
    SmtpSnd.UserName:=Settings.smtpuser;
    SmtpSnd.Password:=DecryptString(Settings.smtppass,KeyStr);
    SmtpSnd.AutoTLS:=true;
    if Not SmtpSnd.Login then
      begin
      Result:=false;
      MsgError:=format(rsSmtpLoginErr,[SmtpSnd.EnhCodeString]);
      //SmtpSnd.Free;
      exit;
      end;
    if not smtpSnd.MailFrom(Settings.mailfrom, Length(Settings.mailfrom)) then
     begin
      Result:=false;
      MsgError:=format(rsSmtpMailFromErr,[SmtpSnd.EnhCodeString]);
      //SmtpSnd.Free;
      exit;
     end;

    // Отправка на множественные адреса
    MailToList:=TStringList.Create;
    MailToList.Delimiter:=';';
    MailToList.DelimitedText:=Settings.email;
    for i:=0 to MailToList.Count-1 do
    begin
    if not smtpSnd.MailTo(MailToList[i]) then

    //if not smtpSnd.MailTo('Andrey.Kapustin@volga.bnk.ru') then
      begin
      Result:=false;
      MsgError:=format(rsSmtpMailToErr,[MailToList[i],SmtpSnd.EnhCodeString]);
      MailToList.Free;
      exit;
      end;
    end;
    MailToList.Free;
    //--конец множественной отправки
    {
    if not smtpSnd.MailTo(Settings.email) then
           begin
      Result:=false;
      MsgError:=format(rsSmtpMailToErr,[SmtpSnd.EnhCodeString]);
      //SmtpSnd.Free;
      exit;
      end;
    }
    if not smtpSnd.MailData(Msg.Lines) then
     begin
      Result:=false;
      MsgError:=format(rsSmtpMailDataErr,[SmtpSnd.EnhCodeString]);
      //SmtpSnd.Free;
      exit;
     end;
    if not smtpSnd.Logout() then
      begin
      Result:=false;
      MsgError:=format(rsSmtpLogoutErr,[SmtpSnd.EnhCodeString]);
      //SmtpSnd.Free;
      exit;
     end;
// Конец отправки классом
   except on E:Exception do
      begin
      MsgError:=format(rsAlertTestErr,[E.Message]);
//      LogMessage(MsgError);
      Result:=false;
      //SmtpSnd.Free;
      end;
   end;
 finally
   Msg.Free;
   BodyList.Free;
   SmtpSnd.Free;
 end;
end;
//=========================================================
// Отправка уведомления о завершении работы программы на почту
// ProgStatus- строка заменяющаяя %ProgStatus% (запущена, остановлена)
procedure TBackup.SendAlert(ProgStatus:string);
var
  AlertSubj:string;
  AlertBody:string;
  RParam:TReplParam;
  MsgErr:string;
begin
RParam.AlertProgStatus:=ProgStatus;
AlertSubj:=ReplaceParamEx(Settings.SubjAlert,RParam);
AlertBody:=ReplaceParamEx(Settings.BodyAlert,RParam);
SendMailS(AlertSubj,AlertBody,'',MsgErr);
end;

//=========================================================
// Возвращает имя компа
class function TBackup.GetHostName:string;
var
  computerNameBuffer: array[0..255] of char;
  sizeBuffer: DWord;
begin
  SizeBuffer := 256;
  getComputerName(computerNameBuffer, sizeBuffer);
  result := string(computerNameBuffer);
end;



  {
//=========================================================
// Отправка почты Indy10
// subj - тема письма
// Body - текст письма
// FileName - имя прикладываемого файла (Если не пусто)
// MsgError - ошибка, если возникла
// Возвращает true если все хорошо
function TBackup.SendMail(Subj:string;Body:string;FileName:string;var MsgError:string):boolean;
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
{

    type
  TIdUseTLS = (
    utNoTLSSupport,
    utUseImplicitTLS, // ssl iohandler req, allways tls
    utUseRequireTLS, // ssl iohandler req, user command only accepted when in tls
    utUseExplicitTLS // < user can choose to use tls
    );

 }
    {
     // Пример
     idSmtp := TIdSMTP.Create(nil);
  try
    idSmtp.IOHandler := nil;
    idSmtp.ManagedIOHandler := true;

    // try to use SSL
    try
      TIdSSLContext.Create.Free;
      idSmtp.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(idSmtp);
      if (smtpSettings.port = 465) then
        idSmtp.UseTLS := utUseImplicitTLS
      else
        idSmtp.UseTLS := utUseExplicitTLS;
    except
      idSmtp.IOHandler.Free;
      idSmtp.IOHandler := nil;
    end;

    if (idSmtp.IOHandler = nil) then
    begin
      idSmtp.IOHandler := TIdIOHandler.MakeDefaultIOHandler(idSmtp);
      idSmtp.UseTLS := utNoTLSSupport;
    end;

    // send message, etc

  finally
    idSmtp.Free;
  end;

    }




    //idSmtp.UseTLS:=utUseImplicitTLS;

    idSmtp.Username:=Settings.smtpuser;
    idSmtp.Password:=Settings.smtppass;
    idSmtp.ConnectTimeout:=30000;
    idMsg:=TIdMessage.Create;
    idMsg.CharSet:='UTF-8';
    //idMsg.ContentTransferEncoding:='base64';
    idMsg.OnInitializeISO:=@LInitializeISO;
   idMsg.Subject:=subj;
   //idMsg.Subject:=utf8toansi('Тест');
   //idMsg.Subject:='Тест';
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
    if IsAtt then idAttachFile.Free;
    idMsg.Free;
    idSmtp.Free;
  end;
end;
}
//=========================================================
// Заменяет все спец параметры в строке, типа %Status%
// Перечень команд:
// %Name% - имя задания
// %Status% - результат выполнения (берется из задания)
// + замена даты/времени

function TBackup.ReplaceParam(S:string;numtask:integer):string;
var
  str:string;
  RParam:TReplParam;
begin

   case Tasks[numtask].LastResult of
      trOk:
        RParam.TaskStatus:=rsOk;
//        str:=rsOk;
      trError:
        RParam.TaskStatus:=rsTaskError;
//        str:=rsTaskError;
      trFileError:
         RParam.TaskStatus:=rsTaskEndError;
//         str:=rsTaskEndError;
    end;
    RParam.TaskName:=Tasks[NumTask].Name;
    str:=ReplaceParamEx(S,RParam);
//    str :=StringReplace(S,'%Status%',str,[rfReplaceAll, rfIgnoreCase]);
//    str:=StringReplace(str,'%Name%',Tasks[numtask].Name,[rfReplaceAll, rfIgnoreCase]);
//    str:=StringReplace(str,'%ComputerName%',GetHostName,[rfReplaceAll, rfIgnoreCase]);
//    str:=StringReplace(str,'%ProfileName%',Settings.profile,[rfReplaceAll, rfIgnoreCase]);
//    str:=ReplDate(str);
Result:=str;
end;
//=========================================================
// Заменяет все спец параметры в строке, типа %Status%
// Перечень команд:
// %Name% - имя задания
// %Status% - результат выполнения (берется из задания)
// + замена даты/времени

function TBackup.ReplaceParamEx(const S:string;RParam:TReplParam):string;
var
  str:string;
begin

    str :=StringReplace(S,'%Status%',RParam.TaskStatus,[rfReplaceAll, rfIgnoreCase]);
    str:=StringReplace(str,'%Name%',RParam.TaskName,[rfReplaceAll, rfIgnoreCase]);
    str:=StringReplace(str,'%ComputerName%',GetHostName,[rfReplaceAll, rfIgnoreCase]);
    str:=StringReplace(str,'%ProfileName%',Settings.profile,[rfReplaceAll, rfIgnoreCase]);
    str:=StringReplace(str,'%ProgStatus%',RParam.AlertProgStatus,[rfReplaceAll, rfIgnoreCase]);
    str:=ReplDate(str);
Result:=str;
end;

//=========================================================
//Получение имени файла архива без директории
function TBackup.GetArhFileName(numtask:integer):string;
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
// Получение каталога в который производится архивация
function TBackup.GetArhDir(NumTask:integer;SrcFS,DstFS:TCustomFS;var TmpExist:boolean):string;
var
  ResName: string;
  //ext:string; // расширение
  Drive1,Drive2:string;
  IsFtp:boolean;
 // SameDisk:boolean; // tmp каталог находится на том же диске, что и приемник
  // SorPath,DestPath:String;
begin
if DstFS is TFileFS then
    IsFtp:=false
   else
    IsFtp:=true;



Drive1:=ExtractFileDrive(Settings.ArhTmpDir);
Drive2:=ExtractFileDrive(DstFS.RootDir);
Drive1:=UpperCase(Drive1);
Drive2:=UpperCase(Drive2);
if IsFtp then Drive2:='';

  if (Drive1<>Drive2) and (Settings.ArhTmpDir<>'') then // временный каталог архивов задан
     begin
       if DirectoryExists(utf8toansi(Settings.ArhTmpDir)) then // и он существует
          begin
           TmpExist:=true;
           ResName := Settings.ArhTmpDir;
          end
        else   // временный каталог не существует, фигачим напрямую
          begin
          TmpExist:=false;
           LogMessage(format(rsLogDirNotFound,[Settings.ArhTmpDir]));
          ResName := DstFS.RootDir;// ReplDate(Tasks[numtask].DestPath) + DirectorySeparator + ArhFileName;
          end;
     end
   else // Просто путь до приемника
     begin
     TmpExist:=false;
     ResName := DstFS.RootDir; // ReplDate(Tasks[numtask].DestPath) + DirectorySeparator + ArhFileName;
     end;
//  if IgnoreTmpDir then ResName := ReplDate(Tasks[numtask].DestPath) + DirectorySeparator + ArhFileName;


  Result  := utf8toansi(ResName);

if IsFtp then // Идет копирование на фтп, временный каталог обязан быть
   begin
   if Not TmpExist then
      Result:='';
   end;
end;

//=========================================================
//Получение имени файла архива с полным путем
// Если ignoreTmpDir=true - возвращается просто полный путь до приемника
// Иначе
// Если ArhTmpDir не пуста, возвращает полный путь до нее
// Если пуста, то до Destination
// TmpExist - Существует ли временный каталог
{
function TBackup.GetArhName(numtask: integer;ArhFileName:string;IgnoreTmpDir:boolean;var TmpExist:boolean): string;
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
}
//------------------------------------------------------------------------
{Замена всяких символов типа %date% в строке на "*". Для маски поиска и удаления старых архивов}
function TBackup.ReplDateToMask(S: string): string;
var
  str, str2: string;
begin
  str := FindStrVar(S);
  while str <> '' do
  begin
    str2 := '%' + str + '%';
    s   := StringReplace(s, str2, '*', [rfReplaceAll, rfIgnoreCase]);
    str := FindStrVar(S);
  end;
  Result := s;
end;

//------------------------------------------------------------------------
{Замена всяких символов типа %date% в строке на текущую дату}
function TBackup.ReplDate(S: string): string;
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
function TBackup.FindStrVar(S: string): string;
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
procedure TBackup.GetFileList(sordir: string; NumTask: integer;
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
      FileList.Add('>' + sordir+ DirectorySeparator + '*') // рекурсивно
    else
      FileList.Add(sordir + DirectorySeparator + '*'); // не рекурсивно
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
function TBackup.ArhZipDir(numtask: integer): integer;
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


 //=====================================================
 // Копирование задания
procedure TBackup.DublicateTask(NumTask: integer);
begin
  // Найти свободный элемент
  if Count = MaxTasks then
    exit;
  AddTask;
  CopyTask(numtask, Count-1);
  Tasks[Count-1].Name := rsCopyPerfix + ' ' + Tasks[numtask].Name;
  Tasks[Count-1].LastRunDate:=0;
end;
 //===========================================================
 // Архивация Rar директории sourdir в директорию destdir
{
function TBackup.ArhRarDir(NumTask: integer): integer;
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

  if not CheckDirs(NumTask) then // Проверка существования каталогов
      begin
      Result:=trError;
      exit;
      end;
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
}
 //===========================================================
 // Архивация 7zip
{
function TBackup.Arh7zipDir(NumTask: integer): integer;
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

  if not CheckDirs(NumTask) then // Проверка существования каталогов
    begin
    Result:=trError;
    exit;
    end;
  Result  := trOk;

  cmdexe  := ExtractFileDir(ParamStr(0)) + DirectorySeparator + '7za.exe';
  if not FileExists(cmdexe) then
  begin
    LogMessage(rsLog7zipNotFound);
    Result := trError;
    exit;
  end;

  runstr := Build7zipFileList(NumTask,ArhFileName,nil); // Параметры запуска

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
}
 //===========================================================
 // Архивация Rar директории sourdir в директорию destdir
function TBackup.ArhRarDirFS(NumTask: integer;SrcFS:TCustomFS;DstFS:TCustomFS): integer;
var
  rarexe, str: string;
  runstr:      string;
//  arhname:     string;
//  SorPath:     string;
  ExitCode:    integer;
  ArhFileName:string;
//  arhnamedst:string;
  ArhDir:string;
  ArhFullName:string;
  TmpExist:boolean;
  // tmpstr:TStrings;
begin
     str := Format(rsLogArcRar,[ansitoutf8(SrcFS.GetName),ansitoutf8(DstFS.GetName)]);
   //  str:=ansitoutf8(str);
    LogMessage(str);

//  SorPath:=ReplDate(Tasks[numtask].SorPath);
//  SorPath := utf8toansi(SorPath);
  //DestPath:=utf8toansi(Tasks[numtask].DestPath);


  Result  := trOk;
  ArhFileName:=GetArhFileName(numtask);
  ArhDir := GetArhDir(NumTask,SrcFS,DstFS,TmpExist);// ArhName(NumTask,ArhFileName,false,TmpExist);
  if ArhDir='' then
     begin
     Result:=trError;
     exit;
     end;
  ArhFullName:=ArhDir+DirectorySeparator+ArhFilename;

//  rarexe  := ExtractFileDir(ParamStr(0)) + DirectorySeparator + 'rar.exe';
  rarexe  := GetFullExePath('rar.exe');
//  if not FileExists(rarexe) then
  if rarexe='' then
  begin
    LogMessage(rsLogRarNotFound);
    Result := trError;
    exit;
  end;
//  runstr := 'a -dh -ep1 -u -ibck -y ';
//  runstr := runstr + BuildRarFileList(numtask) + ' ';
//  runstr   := runstr + '"'+ArhFullName + '" "' + SrcFS.RootDir + DirectorySeparator + '*"';

  runstr := BuildRarFileList(numtask,ArhFullName,SrcFS);


  // Замена пароля звездочками для отображения
  str:=ansitoutf8(runstr);
  if Tasks[NumTask].Arh.EncryptEnabled then  // Пароль
       begin
       str:=StringReplace(str,' -p'+DecryptString(Tasks[NumTask].Arh.Password,KeyStrTask),' -p**********',[rfReplaceAll]);
       end;

//  str := Format(rsRunArhCmd, ['rar.exe '+ansitoutf8(runstr)]);
  str := Format(rsRunArhCmd, ['rar.exe '+str]);
  //str:=ansitoutf8(str);
  LogMessage(str);


  ExitCode := ExecProc(rarexe, runstr, True);   // Запуск с ожиданием



  if ExitCode = 0 then // Все хорошо
  begin
    str := Format(rsLogArcCreated, [ansitoutf8(ArhFileName)]);
    // Создан архив
    LogMessage(str);
    Result := trOk;
    //  exit;
  end
  else //
  begin
       if ExitCode = 1 then // Предупреждение
         begin
         str := Format(rsLogArcWarn, [ansitoutf8(ArhFileName)]);
         // Создан архив
         LogMessage(str);
         LogMessage(LastStdOut); // Вывод вывода архиватора

         Result := trFileError;
         //  exit;
         end
        else // Обшибка
         begin
         str := Format(rsLogArcErr, [IntToStr(ExitCode), ansitoutf8(ArhFileName)]);

         // Ошибка создания архива
         LogMessage(str);
         LogMessage(LastStdOut); // Вывод вывода архиватора
         Result := trError;
         //  exit;
         end;
  end;

// Приводим в порядок FS
SrcFS.ChangeWorkingDir(arhDir);
DstFS.ChangeWorkingDir(DstFS.RootDir);
        if (DstFS is TFTPFS) then // приемник Ftp,
             begin
             if Not (DstFS as TFTPFS).Connected then  //отвалился пока архивировали
                 begin
                 if Not (DstFS as TFTPFS).Connect then // И обратно не цепляется
                     begin
                     Result:=trError;
                     LogMessage(rsFTPLostConnect);
                     exit;
                     end;
                 end;
             end;
// Конец приведения в порядок

   if (TmpExist) and ((ExitCode=0) or (ExitCode=1)) then // Копируем архив
        begin
        if SimpleCopyFileFS(SrcFS,DstFS,ArhFileName) then
            DelFileFS(ArhFileName,SrcFS);
        end;

if Result<=trFileError then DelOldArhsFS(numtask,DstFS);
end;
 //==========================================================
// Создание файла исключений, генерация командной строки для архивации rar
function TBackup.BuildRarFileList(NumTask: integer;ArhFullName:string;SrcFS:TCustomFS): string;
var
  FileList: TStrings;
  tmpfile:  string;
  res:      string;
  i: integer;
  SubDirs:TStringList;
begin
  res:='a -ep1 -u -ibck -y ';

//    runstr := 'a -dh -ep1 -u -ibck -y ';
//  runstr := runstr + BuildRarFileList(numtask) + ' ';
//  runstr   := runstr + '"'+ArhFullName + '" "' + SrcFS.RootDir + DirectorySeparator + '*"';

 if Tasks[NumTask].Arh.ArhOpenFiles then // Архивировать открытые для записи файлы
    begin
    res:=res+' -dh';
    end;

    // -df удалить файлы после упаковки
  if Tasks[NumTask].Arh.DelAfterArh then
    begin
    res:=res+' -df';
    end;
  // непрерывный архив
  if Tasks[NumTask].Arh.Solid then
         res:=res+' -s'
    else
         res:=res+' -s-';

  // Дополнительные опции
  res:=res+' '+Tasks[NumTask].Arh.AddOptions;

  if Tasks[NumTask].Arh.LevelCompress<>lcNormal then // Уровень сжатия
    begin
    case Tasks[NumTask].Arh.LevelCompress of
      lcNone:    i:=0;
      lcFastest: i:=1;
      lcFast:    i:=2;
      lcNormal:  i:=3;
      lcMaximum: i:=4;
      lcUltra:   i:=5;
     else
        i:=3;
    end;
    res:=res+' -m'+IntToStr(i);
    end;


  if Tasks[NumTask].Arh.EncryptEnabled then // Пароль
    begin
    res:=res+' -p'+DecryptString(Tasks[NumTask].Arh.Password,KeyStrTask);
    end;


// Нет фильтрации источника и приемника
  if (not Tasks[NumTask].SourceFilt.FiltSubDir) and (not Tasks[NumTask].SourceFilt.FiltFiles) then
  begin
         if Tasks[NumTask].SourceFilt.Recurse then
             res :=res+ ' -r';
         Result:=res;
         exit;
  end;
  FileList := TStringList.Create;
  if Tasks[NumTask].SourceFilt.Recurse then
    res := res+' -r';
  // исключение файлов
  if Tasks[NumTask].SourceFilt.FiltFiles then
  begin
    GetFileList(SrcFS.RootDir, NumTask, FileList, False, False);
    tmpfile := ExtractFileDir(ParamStr(0)) + DirectorySeparator + 'tmp.txt';
    //tmpfile:='tmp.txt';
    FileList.SaveToFile(tmpfile);
    res := res + ' -x@"' + tmpfile + '" ';
  end;
  // Исключение директорий
  if Tasks[NumTask].SourceFilt.FiltSubDir then
  begin
    SubDirs:=TStringList.Create;
    SubDirs.Delimiter:=';';
    SubDirs.DelimitedText:=Tasks[NumTask].SourceFilt.SubDirs;
    for i := 0 to SubDirs.Count - 1 do
    begin
      res := res + ' -x\"' + SrcFS.RootDir + DirectorySeparator +SubDirs[i] + '" ';
    end;
    SubDirs.Free;
  end;


  res:=res+' "'+ArhFullName + '" "' + SrcFS.RootDir + DirectorySeparator + '*"';

  Result := res;
  FileList.Free;
end;



 //===========================================================
 // Архивация 7zip  FS
function TBackup.Arh7zipDirFS(NumTask: integer;var SrcFS:TCustomFS;var DstFS:TCustomFS): integer;
var
  cmdexe, str: string;
  runstr:      string;
//  arhname:     string; // путь и имя архива временный каталог
//  arhnamedst:  string;   // путь и имя архива приемник
//  SorPath:     string;
  ExitCode:    integer;
  ArhFilename:string;
  ArhDir:string; // Каталог в который производится архивация
  ArhFullName:string; // полное имя архива
  TmpExist:boolean;
  // tmpstr:TStrings;
begin
    if Tasks[NumTask].Action=ttArhZip then
        str := Format(rsLogArcZip,[ansitoutf8(SrcFS.GetName),ansitoutf8(DstFS.GetName)])
      else
        str := Format(rsLogArc7Zip,[ansitoutf8(SrcFS.GetName),ansitoutf8(DstFS.GetName)]);

    LogMessage(str);

if not (SrcFS is TFileFS) then
    begin
    Result:=trError;
    exit;
    end;
//  SorPath:=ReplDate(Tasks[numtask].SorPath);
//  SorPath := utf8toansi(SorPath);
  ArhFileName:=GetArhFileName(numtask);

//  arhname:=GetArhName(NumTask,ArhFileName,false,TmpExist);
  ArhDir:=GetArhDir(NumTask,SrcFS,DstFS,TmpExist);
  if ArhDir='' then
     begin
     Result:=trError;
     exit;
     end;
  Result  := trOk;

  ArhFullName:=ArhDir+DirectorySeparator+ArhFilename;

  //cmdexe  := ExtractFileDir(ParamStr(0)) + DirectorySeparator + '7za.exe';
  cmdexe  := GetFullExePath('7za.exe');
  if cmdexe='' then cmdexe:= GetFullExePath('7z.exe');

  if cmdexe='' then
  begin
    LogMessage(rsLog7zipNotFound);
    Result := trError;
    exit;
  end;

  runstr := Build7zipFileList(NumTask,ArhFullName,SrcFS); // Параметры запуска
  // Замена пароля звездочками для отображения
  str:=ansitoutf8(runstr);
  if Tasks[NumTask].Arh.EncryptEnabled then  // Пароль
       begin
       str:=StringReplace(str,' -p'+DecryptString(Tasks[NumTask].Arh.Password,KeyStrTask),' -p**********',[rfReplaceAll]);
       end;

  //str := Format(rsRunArhCmd, ['7za.exe '+ansitoutf8(runstr)]);
  str := Format(rsRunArhCmd, ['7za.exe '+str]);
  //str:=ansitoutf8(str);
  LogMessage(str);
  ExitCode := ExecProc(cmdexe, runstr, True);   // Запуск с ожиданием

       case ExitCode of // Обрабатываем код возврата
       0: // Все хорошо
         begin
         str := Format(rsLogArcCreated, [ansitoutf8(ArhFilename)]);
         // Создан архив
         LogMessage(str);
         Result := trOk;
         end;
       1: // Предупреждение
         begin
         str := Format(rsLogArcWarn, [ArhFilename]);
         // Создан архив
         LogMessage(str);
         LogMessage(LastStdOut); // Вывод вывода архиватора
          Result := trFileError;
         end;
        2: // Fatal error
         begin
         str := Format(rsLogArcErr, [IntToStr(ExitCode), ArhFilename]);
         // Ошибка создания архива
         LogMessage(str);
         LogMessage(LastStdOut); // Вывод вывода архиватора
         Result := trError;
         end;
        7: // Ошибка командной строки
         begin
         str := Format(rsLogArcErrCmd, [ArhFilename]);
         // Ошибка создания архива
         LogMessage(str);
         LogMessage(LastStdOut); // Вывод вывода архиватора
         Result := trError;
         end;
        8: // Недостаточно памяти
         begin
         str := Format(rsLogArcErrMemory, [ArhFilename]);
         // Ошибка создания архива
         LogMessage(str);
         LogMessage(LastStdOut); // Вывод вывода архиватора
         Result := trError;
         end;
      255: // Прервано пользователем
         begin
         str := Format(rsLogArcWarnUserStop, [ArhFilename]);
         // Ошибка создания архива
         LogMessage(str);
         LogMessage(LastStdOut); // Вывод вывода архиватора
         Result := trFileError;
         end;
       else // Неизветсная ошибка
        begin
         str := Format(rsLogArcErr, [IntToStr(ExitCode), ArhFilename]);
         // Ошибка создания архива
         LogMessage(str);
         LogMessage(LastStdOut); // Вывод вывода архиватора
         Result := trError;
        end;

       end;
// Приводим в порядок FS
SrcFS.ChangeWorkingDir(arhDir);
DstFS.ChangeWorkingDir(DstFS.RootDir);
        if (DstFS is TFTPFS) then // приемник Ftp,
             begin
             if Not (DstFS as TFTPFS).Connected then  //отвалился пока архивировали
                 begin
                 if Not (DstFS as TFTPFS).Connect then // И обратно не цепляется
                     begin
                     Result:=trError;
                     LogMessage(rsFTPLostConnect);
                     exit;
                     end;
                 end;
             end;
// Конец приведения в порядок

  if (TmpExist) and ((ExitCode=0) or (ExitCode=1)) and (Result<=trFileError) then // Копируем архив
        begin

        if SimpleCopyFileFS(SrcFS,DstFS,ArhFileName) then
            DelFileFS(ArhFileName,SrcFS);
        end;
// Удаление старых архивов
if Result<=trFileError then
        begin

        DelOldArhsFS(numtask,DstFS);
        end;
end;
//==========================================================
// Создание командной строки для архивации 7zip  (без 7z.exe)
// ArhFileName - имя файла архива без пути
function TBackup.Build7zipFileList(NumTask: integer;ArhFileName:string;SrcFS:TCustomFS): string;
var
  FileList: TStrings;
  tmpfile:  string;
  //res:      string;
  cmdstr: string; // Генерируемая строка
//  arhname:string;
//  tmpbool:boolean;
  arhsor:string; // Что архивировать
  i: integer;
  SubDirs,FileMask:TStringList;
begin

  //arhname := GetArhName(numtask,ArhFileName,false,tmpbool);
  //arhname:=utf8toansi(arhname);


  arhsor:=SrcFS.RootDir;// ReplDate(Tasks[NumTask].SrcFSParam.RootDir SorPath);

  //arhsor:=utf8toansi(arhsor)+DirectorySeparator+'*'; // По умолчанию все
  arhsor:=SrcFS.RootDir+DirectorySeparator+'*'; // По умолчанию все
  //7z a -tzip archive.zip *.txt -x!temp.*
  cmdstr:='a "'+ArhFileName+'" -y';            // -y - yes на все вопросы

  if Tasks[NumTask].Arh.ArhOpenFiles then // архивировать открытые файлы
   begin
   cmdstr:=cmdstr+' -ssw';
   end;

  // Непрерывный архив
  if Tasks[NumTask].Action=ttArh7Zip then
      begin
      if Tasks[NumTask].Arh.Solid then
         cmdstr:=cmdstr+' -ms'

       else
         cmdstr:=cmdstr+' -ms=off';

      end;

  if Tasks[NumTask].Action=ttArhZip then // архивация zip
   begin
   cmdstr:=cmdstr+' -tzip'; // архивация зип
   end;

  cmdstr:=cmdstr+' '+ Tasks[NumTask].Arh.AddOptions;

  if Tasks[NumTask].Arh.EncryptEnabled then  // Пароль
       begin
       cmdstr:=cmdstr+' -p'+DecryptString(Tasks[NumTask].Arh.Password,KeyStrTask);
       end;

  if Tasks[NumTask].Arh.LevelCompress<>lcNormal then  // Уровень сжатия
       begin
       cmdstr:=cmdstr+' -mx'+IntToStr(Integer(Tasks[NumTask].Arh.LevelCompress));
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
    SubDirs:=TStringList.Create;
    SubDirs.Delimiter:=';';
    SubDirs.DelimitedText:=Tasks[NumTask].SourceFilt.SubDirs;
    for i := 0 to SubDirs.Count - 1 do
    begin
      cmdstr := cmdstr + ' -xr!"' + utf8toansi(SubDirs[i])+DirectorySeparator+'*" ';
    end;
    SubDirs.Free;
  end;

  // исключение файлов
  if Tasks[NumTask].SourceFilt.FiltFiles then
  begin
    FileMask:=TStringList.Create;
    FileMask.Delimiter:=';';
    FileMask.DelimitedText:=Tasks[NumTask].SourceFilt.FileMask;
    // Если исключать файлы
    if Tasks[NumTask].SourceFilt.ModeFiltFiles=tsNoMask then // Файлы исключаются
      begin
      for i := 0 to FileMask.Count - 1 do
        begin
         cmdstr := cmdstr + ' -xr!'+utf8toansi(FileMask[i]);
        end;
      end
     else // Обрабатывать только эти файлы
       begin
       if FileMask.Count=1 then // в списке только одно исключение
         begin
         arhsor:=utf8toansi(SrcFS.RootDir)+DirectorySeparator+FileMask[0];
         end
        else // в списке несколько исключений, делаем файл со списком файлов
          begin
           tmpfile := ExtractFileDir(ParamStr(0)) + DirectorySeparator + 'tmp.txt';
           FileList := TStringList.Create;
           for i := 0 to FileMask.Count - 1 do
               begin
                 FileList.Add(utf8toansi(SrcFS.RootDir)+DirectorySeparator+utf8toansi(FileMask[i]));
               end;
           FileList.SaveToFile(tmpfile);
           FileList.Free;
           arhsor:='@"'+tmpfile+'"';
          end;
       end;
     FileMask.Free;
  end;

  cmdstr:=cmdstr+' "'+arhsor+'"'; // Добавление списка архивируемых файлов
  Result:=cmdstr;
end;



 //==========================================================
 // Удаление файлов архивов в папке dir с именем arhname     FS
 // позднее olddays дней
 // позднее oldmonths месяцев
 // позднее oldyears лет
 //procedure TBackup.DelOldArhs(dir,arhname:string;olddays,oldMonths,OldYears:integer);
procedure TBackup.DelOldArhsFS(NumTask: integer;CustomFS:TCustomFS);
var
  olddays, oldMonths, OldYears: integer;
  exten: string;
  Col,i,j,Day, Month,year: integer;
  BeforeDate,DateBeg,DateEnd,CurrDate: TDateTime;
  sr:      TSearchRecFS;
//  FileAttrs: integer;

  //  filesync:String;
  //sordata: TDateTime; // даты файлов источ и приемника
  ArhList:array of TArhList;
  test:string;
begin
  if not Tasks[numtask].Arh.DelOldArh then  exit; // Если не задано удаление архивов выход из функции
//  dir := CustomFS.RootDir;// Tasks[numtask]. DestPath + DirectorySeparator;
  // каталог приемник где ищутся архивы
  //exten:=Tasks[numtask].Arh.Name;
  test:=CustomFS.WorkingDir;
  exten:=ReplDateToMask(Tasks[numtask].Arh.Name); // Заменяем %% на *
  if Tasks[numtask].Action = ttArhZip then exten := exten+'.zip';
  if Tasks[numtask].Action = ttArh7Zip then exten :=exten+'.7z';
  if Tasks[numtask].Action = ttArhRar then exten := exten+'.rar';
  olddays := Tasks[numtask].Arh.DaysOld;
  oldMonths := Tasks[numtask].Arh.MonthsOld;
  oldYears  := Tasks[numtask].Arh.YearsOld;
//  FileAttrs := faReadOnly + faHidden + faSysFile + faArchive + faAnyFile;
// Создаем список всех файлов
  // Подсчет кол-ва файлов
  Col:=0;
  sr:=TSearchRecFS.Create;
  if CustomFS.FindFirstFS(sr) = 0 then
      begin
      repeat
        begin
        test:=sr.sr.Name;
        if MatchesMask(sr.sr.Name, exten) then  Inc(Col); //:=Col+1;
        end;
      until CustomFS.FindNextFS(sr) <> 0;
      CustomFS.FindCloseFS(sr);
      end;
  // заполение списка
  if Col=0 then exit; // Ничего нету
  SetLength (ArhList,Col);
  i:=0;
  if CustomFS.FindFirstFS( sr) = 0 then
        begin
        repeat
          begin
          if MatchesMask(sr.sr.Name, exten) then
               begin
               ArhList[i].DateFile:=CustomFS.GetFileDateFS(sr.sr.Name);
               ArhList[i].NameFile:=sr.sr.Name;
               ArhList[i].IsStay:=false;
               i:=i+1;
               end;
          end;
        until (CustomFS.FindNextFS(sr) <> 0) and (i<=Col);
        CustomFS.FindCloseFS(sr);
        end;
  sr.Free;
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
        if Not ArhList[i].IsStay then DelFileFS(ArhList[i].NameFile,CustomFS); //  (dir + ArhList[i].NameFile);
      end;

end;





 //==========================================================
 // Удаление файлов архивов в папке dir с именем arhname
 // позднее olddays дней
 // позднее oldmonths месяцев
 // позднее oldyears лет
 //procedure TBackup.DelOldArhs(dir,arhname:string;olddays,oldMonths,OldYears:integer);
{
procedure TBackup.DelOldArhs(NumTask: integer);
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
}
//==============================================================
// Поиск файла в списке архивов с минимальной датой из заданного диапазона (края диапазона включаются в поиск)
// Нужна для DelOldArhs
// Возвращает индекс найденного файла, или -1 если ничего не найдено
function TBackup.MinInRange(ArhList:array of TArhList;DateBeg,DateEnd:TDateTime):integer;
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
// Удаление файла с записью в лог FS
function TBackup.DelFileFS(ShortFileName: string;CustomFS:TCustomFS):integer;
var
//  str:   string;
//  Attrs: integer;
  res:   boolean;
begin
Result:=trOk;
  // Удаляем файл

    res := CustomFS.DeleteFileFS(ShortFileName);
    LogMessage(CustomFS.LastError);
{
  if res then
  begin
    str    := Format(rsLogDelFile, [ansitoutf8(ShortFileName)]);
    LogMessage(str);
  end
  else
  begin
    Result := trFileError;
    str    := CustomFS.LastError;
    str    := Format(rsLogDelFileErr, [ansitoutf8(ShortFileName), str]);
    LogMessage(str);
  end;
  }
end;
 //==============================================================
 // Удаление файла с записью в лог
function TBackup.DelFile(namef: string): integer;
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
{
procedure TBackup.ReplaceNameDisk(NumTask: integer; replace: boolean);
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
}
 //======================================================
 // Объединение двух путей файла (каталог + файл)
 // Возвращает объединенный путь
{
function TBackup.PathCombine(Path1: string; Path2: string): string;
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
 }
 //======================================================
 // Объединение двух путей файла (каталог + файл)
 // Возвращает объединенный путь
{
function TBackup.PathCombine(Path1: string; Path2: string): string;
var
  Path2s,Path1s:string;
begin
  Path1s:=Path1;
  Path2s:=Path2;
  if Length(Path2)>0 then
       begin
        if IsDelimiter('\/',Path2, 1) then // Начинается на слеш
        begin
          Path2s := RightStr(Path2,Length(Path2)-1); // Убираем его
        end;
        end;

  if Length(Path1)>0 then
  begin
          if IsDelimiter('\/',Path1, Length(Path1)) then // Оканчивается на слеш
          begin
            Path1s:=LeftStr(Path1,Length(Path1)-1); // Убираем его
          end;

  end;
  Result:=Path1s+DirSep+Path2s;
end;

}



{
//=====================================================
// плучение полного пути имени файла прибавлением
// или текущей директории или директории запуска
// где файл окажется
function TBackup.GetFileNam(shortnam:String):String;
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
procedure TBackup.LogMessage(MesStrings: TStringList);
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
procedure TBackup.LogMessage(logmes: string);
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
procedure TBackup.WriteFileStr(filenam, str: string);
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
procedure TBackup.CheckFileSize(FileNam:string);
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
procedure TBackup.SaveToXMLFile(filenam: string);
var
  i: integer;
  //MailAlert:integer;
  xmldoc: TXMLConfig;
  sec: string;
  FrmSet:TFormatSettings;
  //cr:string;
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
  for i := 0 to Count-1 do
  begin
    // Имя секции с заданием

    sec := 'tasks/task' + IntToStr(i+1) + '/';

    xmldoc.SetValue(sec + 'name/value', Tasks[i].Name);
    // Источник
//    xmldoc.SetValue(sec + 'SorPath/value', Tasks[i].SrcFSParam.RootDir);
    xmldoc.SetValue(sec + 'SrcFSParam/RootDir/value', Tasks[i].SrcFSParam.RootDir);
    xmldoc.SetValue(sec + 'SrcFSParam/FSType/value',integer(Tasks[i].SrcFSParam.FSType));
    xmldoc.SetValue(sec + 'SrcFSParam/FtpServParam/Host/value', Tasks[i].SrcFSParam.FtpServParam.Host);
    xmldoc.SetValue(sec + 'SrcFSParam/FtpServParam/Port/value', Tasks[i].SrcFSParam.FtpServParam.Port);
    xmldoc.SetValue(sec + 'SrcFSParam/FtpServParam/InintialDir/value', Tasks[i].SrcFSParam.FtpServParam.InintialDir);
    xmldoc.SetValue(sec + 'SrcFSParam/FtpServParam/UserName/value', Tasks[i].SrcFSParam.FtpServParam.UserName);
    xmldoc.SetValue(sec + 'SrcFSParam/FtpServParam/Password/value', Tasks[i].SrcFSParam.FtpServParam.Password);
{
    cr:=EncryptString(Tasks[i].SrcFSParam.FtpServParam.Password,KeyStrTask);
    xmldoc.SetValue(sec + 'SrcFSParam/FtpServParam/PasswordCrypt/value', cr);
}
    xmldoc.SetValue(sec + 'SrcFSParam/FtpServParam/PassiveMode/value', Tasks[i].SrcFSParam.FtpServParam.PassiveMode);
    xmldoc.SetValue(sec + 'SrcFSParam/FtpServParam/AutoTLS/value', Tasks[i].SrcFSParam.FtpServParam.AutoTLS);
    // Приемник
//    xmldoc.SetValue(sec + 'DestPath/value', Tasks[i].DstFSParam.RootDir);
    xmldoc.SetValue(sec + 'DstFSParam/RootDir/value', Tasks[i].DstFSParam.RootDir);
    xmldoc.SetValue(sec + 'DstFSParam/FSType/value', integer(Tasks[i].DstFSParam.FSType));
    xmldoc.SetValue(sec + 'DstFSParam/FtpServParam/Host/value', Tasks[i].DstFSParam.FtpServParam.Host);
    xmldoc.SetValue(sec + 'DstFSParam/FtpServParam/Port/value', Tasks[i].DstFSParam.FtpServParam.Port);
    xmldoc.SetValue(sec + 'DstFSParam/FtpServParam/InintialDir/value', Tasks[i].DstFSParam.FtpServParam.InintialDir);
    xmldoc.SetValue(sec + 'DstFSParam/FtpServParam/UserName/value', Tasks[i].DstFSParam.FtpServParam.UserName);
    xmldoc.SetValue(sec + 'DstFSParam/FtpServParam/Password/value', Tasks[i].DstFSParam.FtpServParam.Password);
{
    cr:=EncryptString(Tasks[i].DstFSParam.FtpServParam.Password,KeyStrTask);
    xmldoc.SetValue(sec + 'DstFSParam/FtpServParam/PasswordCrypt/value', cr);
}
    xmldoc.SetValue(sec + 'DstFSParam/FtpServParam/PassiveMode/value', Tasks[i].DstFSParam.FtpServParam.PassiveMode);
    xmldoc.SetValue(sec + 'DstFSParam/FtpServParam/AutoTLS/value', Tasks[i].DstFSParam.FtpServParam.AutoTLS);


    xmldoc.SetValue(sec + 'Action/value', Tasks[i].Action);
    xmldoc.SetValue(sec + 'Enabled/value', Tasks[i].Enabled);
    // Сохраняем параметры архива
    xmldoc.SetValue(sec + 'Arh/Name/value', Tasks[i].Arh.Name);
    xmldoc.SetValue(sec + 'Arh/DelOldArh/value', Tasks[i].Arh.DelOldArh);
    xmldoc.SetValue(sec + 'Arh/DaysOld/value', Tasks[i].Arh.DaysOld);
    xmldoc.SetValue(sec + 'Arh/MonthsOld/value', Tasks[i].Arh.MonthsOld);
    xmldoc.SetValue(sec + 'Arh/YearsOld/value', Tasks[i].Arh.YearsOld);
    xmldoc.SetValue(sec + 'Arh/DelAfterArh/value', Tasks[i].Arh.DelAfterArh);
    xmldoc.SetValue(sec + 'Arh/EncryptEnabled/value', Tasks[i].Arh.EncryptEnabled);
    xmldoc.SetValue(sec + 'Arh/Password/value', Tasks[i].Arh.Password);
    xmldoc.SetValue(sec + 'Arh/LevelCompress/value', integer(Tasks[i].Arh.LevelCompress));
    xmldoc.SetValue(sec + 'Arh/ArhOpenFiles/value', Tasks[i].Arh.ArhOpenFiles);
    xmldoc.SetValue(sec + 'Arh/Solid/value', Tasks[i].Arh.Solid);
    xmldoc.SetValue(sec + 'Arh/AddOptions/value', Tasks[i].Arh.AddOptions);

   {
     TmpStr.Add(BoolToStr(Tasks[i].Rasp.Manual));
     TmpStr.Add(BoolToStr(Tasks[i].Rasp.AtTime));
     TmpStr.Add(BoolToStr(Tasks[i].Rasp.AtStart));

     TmpStr.Add(BoolToStr(Tasks[i].Rasp.EvMinutes));
     TmpStr.Add(IntToStr(Tasks[i].Rasp.Minutes));
     TmpStr.Add(TimeToStr(Tasks[i].Rasp.Time));
     }
    //Параметры запуска внешних программ
    // before
    xmldoc.SetValue(sec + 'ExtProgs/ExtBefore/Enabled/value', Tasks[i].ExtBefore.Enabled);
    xmldoc.SetValue(sec + 'ExtProgs/ExtBefore/Cmd/value', Tasks[i].ExtBefore.Cmd);
    xmldoc.SetValue(sec + 'ExtProgs/ExtBefore/Condition/value', Tasks[i].ExtBefore.Condition);

    xmldoc.SetValue(sec + 'ExtProgs/ExtAfter/Enabled/value', Tasks[i].ExtAfter.Enabled);
    xmldoc.SetValue(sec + 'ExtProgs/ExtAfter/Cmd/value', Tasks[i].ExtAfter.Cmd);
    xmldoc.SetValue(sec + 'ExtProgs/ExtAfter/Condition/value', Tasks[i].ExtAfter.Condition);
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
    xmldoc.SetValue(sec + 'SourceFilt/SubDirs/value',Tasks[i].SourceFilt.SubDirs);
//    cnt := Tasks[i].SourceFilt.SubDirs.Count;
//    xmldoc.SetValue(sec + 'SourceFilt/SubDirs/count/value', cnt);
//    for j := 1 to cnt do
//    begin
//      xmldoc.SetValue(sec + 'SourceFilt/SubDirs/path' + IntToStr(j) +'/value', Tasks[i].SourceFilt.SubDirs.Strings[j - 1]);
//    end;
    xmldoc.SetValue(sec + 'SourceFilt/FiltFiles/value', Tasks[i].SourceFilt.FiltFiles);
    xmldoc.SetValue(sec + 'SourceFilt/ModeFiltFiles/value',      Tasks[i].SourceFilt.ModeFiltFiles);
    xmldoc.SetValue(sec + 'SourceFilt/FileMask/value',Tasks[i].SourceFilt.FileMask);

  end;

  //TmpStr.SaveToFile(filenam);
  xmldoc.Flush;
  xmldoc.Free;
end;
 //==========================================================
 // Загрузка массива заданий из файла
// старые задания не удаляются, если нужно удалить все то нужно перед
 // вызовом функции сделать count=0;
 // Возвращает PName - имя профиля загруженного
procedure TBackup.LoadFromXMLFile(filenam: string);
var
  i, cnt: integer;
  // TmpStr:TStringList;
  // ver:integer;
  // i,j,cnt:integer;
  xmldoc:  TXMLConfig;
  sec:     string;
  strDate: string;
  FrmSet:TFormatSettings;
  tmpint:integer;
  //cr:string;
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
  xmldoc.Filename := utf8toansi(filenam);
  xmldoc.flush;
  // количество заданий
  cnt := xmldoc.GetValue('tasks/count/value', 0);
  if cnt = 0 then
  begin
    Clear;
    exit;
  end;
  //count:=cnt;
  Settings.Profile := ShortFileNam(filenam);



  SetLength(Tasks,cnt);
//  Count:=cnt
  for i := 0 to cnt-1 do
    //while strcount<TmpStr.Count do
  begin
    // Имя секции с заданием
    sec := 'tasks/task' + IntToStr(i+1) + '/';
    if i > MaxTasks then
      exit; // вдруг пакостный файл

    Tasks[i].Name := xmldoc.GetValue(sec + 'name/value', '');
    // Источник
    //Tasks[i].SorPath  := xmldoc.GetValue(sec + 'SorPath/value', '');  //TmpStr[strcount+1];
    //tmpstr:=xmldoc.GetValue(sec + 'SorPath/value', '');
    Tasks[i].SrcFSParam.RootDir:=xmldoc.GetValue(sec + 'SrcFSParam/RootDir/value','');

    tmpint:=xmldoc.GetValue(sec + 'SrcFSParam/FSType/value',integer(fstFile));
    Tasks[i].SrcFSParam.FSType:=TFSType(tmpint);
    Tasks[i].SrcFSParam.FtpServParam.Host:=xmldoc.GetValue(sec + 'SrcFSParam/FtpServParam/Host/value','');
    Tasks[i].SrcFSParam.FtpServParam.Port:=xmldoc.GetValue(sec + 'SrcFSParam/FtpServParam/Port/value','' );
    Tasks[i].SrcFSParam.FtpServParam.InintialDir:=xmldoc.GetValue(sec + 'SrcFSParam/FtpServParam/InintialDir/value','');
    Tasks[i].SrcFSParam.FtpServParam.UserName:=xmldoc.GetValue(sec + 'SrcFSParam/FtpServParam/UserName/value', '');
    Tasks[i].SrcFSParam.FtpServParam.Password:=xmldoc.GetValue(sec + 'SrcFSParam/FtpServParam/Password/value', '');
{
    cr:=xmldoc.GetValue(sec + 'SrcFSParam/FtpServParam/PasswordCrypt/value', '');
    if cr='' then  Tasks[i].SrcFSParam.FtpServParam.Password:=''
          else
          Tasks[i].SrcFSParam.FtpServParam.Password:=DecryptString(cr,KeyStrTask);
}
//    Tasks[i].SrcFSParam.FtpServParam.Password:=xmldoc.GetValue(sec + 'SrcFSParam/FtpServParam/Password/value', '');

    Tasks[i].SrcFSParam.FtpServParam.PassiveMode:=xmldoc.GetValue(sec + 'SrcFSParam/FtpServParam/PassiveMode/value', false);
    Tasks[i].SrcFSParam.FtpServParam.AutoTLS:=xmldoc.GetValue(sec + 'SrcFSParam/FtpServParam/AutoTLS/value', false);

     if (Tasks[i].SrcFSParam.RootDir='') and (Tasks[i].SrcFSParam.FSType=fstFile) then
        Tasks[i].SrcFSParam.RootDir:=xmldoc.GetValue(sec + 'SorPath/value','');



    // Приемник
//    Tasks[i].DestPath := xmldoc.GetValue(sec + 'DestPath/value', '');

    Tasks[i].DstFSParam.RootDir:=xmldoc.GetValue(sec + 'DstFSParam/RootDir/value','');
    tmpint:=xmldoc.GetValue(sec + 'DstFSParam/FSType/value', integer(fstFile));
    Tasks[i].DstFSParam.FSType :=TFSType(tmpint);
    Tasks[i].DstFSParam.FtpServParam.Host:=xmldoc.GetValue(sec + 'DstFSParam/FtpServParam/Host/value','' );
    Tasks[i].DstFSParam.FtpServParam.Port:=xmldoc.GetValue(sec + 'DstFSParam/FtpServParam/Port/value','' );
    Tasks[i].DstFSParam.FtpServParam.InintialDir:=xmldoc.GetValue(sec + 'DstFSParam/FtpServParam/InintialDir/value','');
    Tasks[i].DstFSParam.FtpServParam.UserName:=xmldoc.GetValue(sec + 'DstFSParam/FtpServParam/UserName/value','' );
{
    cr:=xmldoc.GetValue(sec + 'DstFSParam/FtpServParam/PasswordCrypt/value','' );
    if cr='' then  Tasks[i].DstFSParam.FtpServParam.Password:=''
          else
          Tasks[i].DstFSParam.FtpServParam.Password:=DecryptString(cr,KeyStrTask);
}
    Tasks[i].DstFSParam.FtpServParam.Password:=xmldoc.GetValue(sec + 'DstFSParam/FtpServParam/Password/value','' );

    Tasks[i].DstFSParam.FtpServParam.PassiveMode:=xmldoc.GetValue(sec + 'DstFSParam/FtpServParam/PassiveMode/value',false );
    Tasks[i].DstFSParam.FtpServParam.AutoTLS:=xmldoc.GetValue(sec + 'DstFSParam/FtpServParam/AutoTLS/value',false );
    if (Tasks[i].DstFSParam.RootDir='') and (Tasks[i].DstFSParam.FSType=fstFile) then
        Tasks[i].DstFSParam.RootDir:=xmldoc.GetValue(sec + 'DestPath/value','');


    Tasks[i].Action   := xmldoc.GetValue(sec + 'Action/value', 0);
    Tasks[i].Enabled  := xmldoc.GetValue(sec + 'Enabled/value', False);

    Tasks[i].Status   := stNone;
    // Чтение параметров архива

    Tasks[i].Arh.Name      := xmldoc.GetValue(sec + 'Arh/Name/value', '');
    Tasks[i].Arh.DelOldArh := xmldoc.GetValue(sec + 'Arh/DelOldArh/value', False);
    Tasks[i].Arh.DaysOld   := xmldoc.GetValue(sec + 'Arh/DaysOld/value', 0);
    Tasks[i].Arh.MonthsOld := xmldoc.GetValue(sec + 'Arh/MonthsOld/value', 0);
    Tasks[i].Arh.YearsOld  := xmldoc.GetValue(sec + 'Arh/YearsOld/value', 0);
    Tasks[i].Arh.DelAfterArh:=xmldoc.GetValue(sec + 'Arh/DelAfterArh/value', False);
    Tasks[i].Arh.ArhOpenFiles:=xmldoc.GetValue(sec + 'Arh/ArhOpenFiles/value', False);
    Tasks[i].Arh.Solid:=xmldoc.GetValue(sec + 'Arh/Solid/value', true);
    Tasks[i].Arh.AddOptions:=xmldoc.GetValue(sec + 'Arh/AddOptions/value', '');

    Tasks[i].Arh.EncryptEnabled:=xmldoc.GetValue(sec + 'Arh/EncryptEnabled/value', False);
    Tasks[i].Arh.Password:=xmldoc.GetValue(sec + 'Arh/Password/value', '');
    Tasks[i].Arh.LevelCompress:=TLevelCompress(xmldoc.GetValue(sec + 'Arh/LevelCompress/value',integer(lcNormal)));
//    Tasks[i].Arh.LevelCompress:=k;

    // Чтение параметров запуска внешних программ
    Tasks[i].ExtBefore.Enabled :=xmldoc.GetValue(sec + 'ExtProgs/ExtBefore/Enabled/value', False);
    Tasks[i].ExtBefore.Cmd := xmldoc.GetValue(sec + 'ExtProgs/ExtBefore/Cmd/value', '');
    Tasks[i].ExtBefore.Condition := xmldoc.GetValue(sec + 'ExtProgs/ExtBefore/Condition/value', -1);

    Tasks[i].ExtAfter.Enabled :=xmldoc.GetValue(sec + 'ExtProgs/ExtAfter/Enabled/value', False);
    Tasks[i].ExtAfter.Cmd := xmldoc.GetValue(sec + 'ExtProgs/ExtAfter/Cmd/value', '');
    Tasks[i].ExtAfter.Condition := xmldoc.GetValue(sec + 'ExtProgs/ExtAfter/Condition/value', -1);

    // Копирование прав
    Tasks[i].NTFSPerm := xmldoc.GetValue(sec + 'NTFSPerm/value', False);
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
//    Tasks[i].SourceFilt.SubDirs  := TStringList.Create;
//    Tasks[i].SourceFilt.SubDirs.Delimiter := ';';
//    Tasks[i].SourceFilt.FileMask := TStringList.Create;
//    Tasks[i].SourceFilt.FileMask.Delimiter := ';';

    Tasks[i].SourceFilt.Recurse := xmldoc.GetValue(sec + 'SourceFilt/Recurse/value', True);
    //StrToBool(TmpStr[strcount+21]);
    Tasks[i].SourceFilt.FiltSubDir :=
      xmldoc.GetValue(sec + 'SourceFilt/FiltSubDir/value', False);
    //StrToBool(TmpStr[strcount+22]);
    Tasks[i].SourceFilt.SubDirs:=xmldoc.GetValue(sec + 'SourceFilt/SubDirs/value', '');
    // Количество фильтруемых директорий
    {
    cntdir := xmldoc.GetValue(sec + 'SourceFilt/SubDirs/count/value', 0);
    for j := 1 to cntdir do // чтение фильтруемых директорий
    begin
      Tasks[i].SourceFilt.SubDirs.Add(
        xmldoc.GetValue(sec + 'SourceFilt/SubDirs/path' + IntToStr(j) + '/value', ''));
    end;
    }
    Tasks[i].SourceFilt.FiltFiles :=xmldoc.GetValue(sec + 'SourceFilt/FiltFiles/value', False);
    Tasks[i].SourceFilt.ModeFiltFiles:=xmldoc.GetValue(sec + 'SourceFilt/ModeFiltFiles/value', 0);
    Tasks[i].SourceFilt.FileMask:=xmldoc.GetValue(sec + 'SourceFilt/FileMask/value', '');
    Count := i+1;
  end;
  xmldoc.Free;
end;

 //=================================================================
 // Запись массива заданий в файл
procedure TBackup.SaveToFile(filenam: string);

begin
  SaveToXMLFile(filenam);

end;




 //==========================================================
 // Загрузка массива заданий из файла
// старые задания не удаляются, если нужно удалить все то нужно перед
 // вызовом функции сделать count=0;
 // Возвращает PName - имя профиля загруженного
procedure TBackup.LoadFromFile(filenam: string);
 //var
 // i,strcount:integer;
 // TmpStr:TStringList;
 // ver:integer;
 // tstr:string;
 //cfgnam:string;
begin
  LoadFromXMLFile(filenam);
  if filenam <> '' then    Settings.profile := ShortFileNam(filenam);

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
{
function TBackup.NTSetPrivilege(sPrivilege: string; bEnabled: boolean): boolean;
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
}


 //==========================================================
 // Копирование прав доступа файла или каталога
 // sorfile- имя файла источника
 // destfile - имя файла приемника
 // Возвращает true если все ОК
{
function TBackup.CopyNTFSPerm(sorfile, destfile: string): boolean;
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
}
//============================================================
// Удаление директории dir со всем ее содержимым FS
function TBackup.DelDirsFS(dir: string;var CustomFS:TCustomFS): integer;
var
  sr:  TSearchRecFS;
//  FileAttrs: integer;
  str: string;
  res: boolean;
  SavDir:string;
  //dir2:String;
  // filesync:String;
  //  sordata,destdata:TDateTime; // даты файлов источ и приемника
begin
  // потом директории
  Result:=trOk;
  sr:=TSearchRecFS.Create;
  SavDir:=CustomFS.WorkingDir;
  CustomFS.ChangeWorkingDir(dir);
  if CustomFS.FindFirstFS(sr) = 0 then
  begin
    repeat
      begin
      if Not sr.IsDir then   // Это файл
          begin
            Result:=Max(Result,DelFileFS(sr.sr.Name,CustomFS));
          end
        else
           begin        // Это каталог
            if not SameText(sr.sr.Name, '.') and not SameText(sr.sr.Name, '..') then
        begin
          Result:=Max(Result,DelDirsFS(CustomFS.PathCombine(dir, sr.sr.Name),CustomFS));
        end;
           end;
       end;
    until CustomFS.FindNextFS(sr) <> 0;
    CustomFS.FindCloseFS(sr);
    sr.Free;
  end;
  // Удаляем каталог
    res := CustomFS.DeleteDirFS(dir);
  if res then
  begin
    str := Format(rsLogDelDir, [ansitoutf8(dir)]);
    LogMessage(str);
  end
  else
  begin
    str := CustomFS.LastError;
    str := Format(rsLogDelDirErr, [ansitoutf8(dir), str]);
    LogMessage(str);
    Result := trFileError;
  end;
CustomFS.ChangeWorkingDir(SavDir);
end;

 //============================================================
 // Удаление директории dir со всем ее содержимым
{
function TBackup.DelDirs(dir: string):integer;
var
  sr:  TSearchRec;
  FileAttrs: integer;
  str: string;
  res: boolean;
  //dir2:String;
  // filesync:String;
  //  sordata,destdata:TDateTime; // даты файлов источ и приемника
begin
  // потом директории
  Result:=trOk;
  FileAttrs := faDirectory + faReadOnly + faHidden + faSysFile + faArchive;
  if FindFirst(TCustomFS.PathCombineEx(dir, '*',DirectorySeparator), FileAttrs, sr) = 0 then
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
}

//=================================================================
// Проверка файла источника на совпадение с маской
 // Возвращает true - файл для обработки
 //            false - файл обрабатывать не надо
function TBackup.CheckFileMask(FileName: string; NumTask: integer): boolean;
var
  Match: boolean; // Файл совпадает с маской
  i:     integer;
  FileMask:TStringList;
begin
  if Tasks[NumTask].SourceFilt.FiltFiles then
    // Установлен фильтр по файлам
  begin
    FileMask:=TStringList.Create;
    FileMask.Delimiter:=';';
    FileMask.DelimitedText:=utf8toSys(Tasks[NumTask].SourceFilt.FileMask);
    Match := False;
    // Проверка на совпадение файла с маской
    for i := 0 to FileMask.Count - 1 do
    begin
      Match := (Match) or (MatchesMask(FileName, FileMask[i]));
    end;
    if Tasks[NumTask].SourceFilt.ModeFiltFiles = tsMask then
      // Все кроме маски
      Result := Match
    else
      Result := not Match;
    FileMask.Free;
  end
  else
    Result := True;
end;
//=================================================================
// Проверка каталога на совпадение со списком исключаемых
 // Возвращает true - каталог для обработки
 //            false - каталог обрабатывать не надо
function TBackup.CheckSubDir(SubDir: string; NumTask: integer): boolean;
var
  Match: boolean; // Файл совпадает с маской
  i:     integer;
  FullPath: string;
  CustFS:TCustomFS;
  SubDirSep:string;//SubDir c нужными разделителями
  SubDirs:TStringList;
begin
  if Tasks[NumTask].SourceFilt.FiltSubDir then
    // Установлен фильтр по каталогам
  begin
    Match := False;
    CreateFS(Tasks[NumTask].SrcFSParam,CustFS);
    SubDirs:=TStringList.Create;
    SubDirs.Delimiter:=';';
    SubDirs.DelimitedText:=utf8toSys(Tasks[NumTask].SourceFilt.SubDirs);
    // Проверка на совпадение файла с маской
    for i := 0 to SubDirs.Count - 1 do
    begin
      FullPath := CustFS.PathCombine(CustFS.RootDir,SubDirs[i]);
      FullPath:=StringReplace(FullPath,'\','/',[rfReplaceAll]);
      SubDirSep:=StringReplace(SubDir,'\','/',[rfReplaceAll]);
      Match    := (Match) or (SameText(SubDirSep, FullPath));
    end;
    CustFS.Free;
    Result := not Match;
    SubDirs.Free;
  end
  else
    Result := True;
end;
//====================================================================
// Проверка существования директорий приемника источника, создание при необходимости
 // Логирование ошибки
 // Возвращает true в случае, если все хорошо
{
function TBackup.CheckDirs(NumTask: integer): boolean;
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
}

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
{
function TBackup.CopyDirs(dir, syncdir: string; NumTask: integer;
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
}
//=================================================================
// Задание копирования директории
{
function TBackup.CopyDir(NumTask:integer):integer;
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
}
//=================================================================
// Задание копирования директории через FS
function TBackup.CopyDirFS(NumTask:integer;var SrcFS:TCustomFS;var DstFS:TCustomFS):integer;
var
  str:string;
//  SorPath,DestPath:string;
  TotalSizeFiles:int64;
begin
  str := Format(rsLogCopy, [ansitoutf8(SrcFS.GetName),ansitoutf8(DstFS.GetName)]);
  LogMessage(str);
// Общее кол-во файлов
  if not InCmdMode then  // Если запуск не через командную строку  то считаем общее кол-во файлов
    begin
//    GetSizeDir(SrcFS.RootDir, DstFS.RootDir, NumTask, False);
      TotalSizeFiles:=GetSizeDirFS(SrcFS, DstFS, NumTask);
      OnProgress(nil, TotalSize2Process, '', TotalSizeFiles); // Вызов события для обработки потоком
    end;

Result:=SimpleCopyDirsFS(SrcFS.RootDir,DstFS.RootDir,SrcFS,DstFS, NumTask,false);
OnProgress(nil, EndOfBatch, '', 0);
end;
//=================================================================
// Задание синхронизации директории FS
function TBackup.SynDirFS(NumTask:integer;var SrcFS:TCustomFS;var DstFS:TCustomFS):integer;
var
  str:string;
  EC1,EC2:integer;
  TotalSizeFiles:int64;
begin
  str := Format(rsLogSync, [ansitoutf8(SrcFS.GetName),ansitoutf8(DstFS.GetName)]);
  LogMessage(str);
// Общее кол-во файлов
  if not InCmdMode then  // Если запуск не через командную строку  то считаем общее кол-во файлов
    begin
//      GetSizeDir(SrcFS.RootDir, DstFS.RootDir, NumTask, False);
        TotalSizeFiles:=GetSizeDirFS(SrcFS, DstFS, NumTask);
        OnProgress(nil, TotalSize2Process, '', TotalSizeFiles); // Вызов события для обработки потоком
    end;

EC1:=SimpleCopyDirsFS(SrcFS.RootDir,DstFS.RootDir,SrcFS,DstFS, NumTask,false);
EC2:=SimpleCopyDirsFS(DstFS.RootDir,SrcFS.RootDir,DstFS,SrcFS, NumTask,false);
Result:=Max(EC1,EC2);
OnProgress(nil, EndOfBatch, '', 0);
end;

//=================================================================
// Задание синхронизации директории
{
function TBackup.SynDir(NumTask:integer):integer;
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
}
//=================================================================
// Задание зеркалирования директории FS
function TBackup.ZerkDirFS(NumTask:integer;var SrcFS:TCustomFS;var DstFS:TCustomFS):integer;
var
 ret:integer;
 str:string;
// SorPath,DestPath:string;
 TotalSizeFiles:int64;
begin
   str := Format(rsLogMirror, [ansitoutf8(SrcFS.GetName),ansitoutf8(DstFS.GetName)]);
    LogMessage(str);

   if not InCmdMode then  // Если запуск не через командную строку  то считаем общее кол-во файлов
    begin
      TotalSizeFiles:=GetSizeDirFS(SrcFS, DstFS, NumTask);
      OnProgress(nil, TotalSize2Process, '', TotalSizeFiles); // Вызов события для обработки потоком
    end;
Result:=SimpleCopyDirsFS(SrcFS.RootDir,DstFS.RootDir,SrcFS,DstFS, NumTask,false);
// Удаляем лишние файлы
ret:=DelOldFilesFS(SrcFS.RootDir,DstFS.RootDir,SrcFS,DstFS, NumTask,false);
Result:=Max(Result,ret);
OnProgress(nil, EndOfBatch, '', 0);
end;




//=================================================================
// Задание зеркалирования директории
{
function TBackup.ZerkDir(NumTask:integer):integer;
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
//ret:=DelOldFiles(SorPath, DestPath, NumTask,false);
Result:=Max(Result,ret);
OnProgress(nil, EndOfBatch, '', 0);
end;
}
//=================================================================
//
// Удаляет из директории DestDir файлы отсутствующие в SorDir  FS
// DestDir - Приемник
 // NumTask - номер задачи в массиве заданий
 // Recurse - true - рекурсивный вызов
 //           false - первый вызов
//Возвращает Код ошибки
function TBackup.DelOldFilesFS(SorDir, DestDir: string;var SrcFS:TCustomFS;var DstFS:TCustomFS; NumTask: integer; Recurse: boolean): integer;
var
  sr: TSearchRecFS;
  srSour:TSearchRecFS;
//  FileAttrs: integer;
//  filesync, filesor: string;
  FullSor,FullDest:string;
  DelFiles:TDeletedFiles;
  //i:integer;
  //beforedate:TDateTime;
//  IsSubDir:boolean;
  isrSor:integer;
//  WasDelFiles:boolean;
begin
Result:=trOk;
//FileAttrs := faReadOnly + faHidden + faSysFile + faArchive + faAnyFile + faDirectory;
//IsSubDir:=false; // Есть подкаталоги
//WasDelFiles:=true; // Очищали каталог по DelFiles
sr:=TSearchRecFS.Create;
srSour:=TSearchRecFS.Create;
SrcFS.ChangeWorkingDir(SorDir);
DstFS.ChangeWorkingDir(DestDir);
isrSor:=SrcFS.FindFirstFS(srSour);
 if DstFS.FindFirstFS(sr) = 0 then
    begin
      DelFiles:=TDeletedFiles.Create(DstFS);
      //WasDelFiles:=false;
      repeat
        begin
//          filesync := PathCombine(SorDir, sr.sr.Name); // Имя файла источника
//          filesor  := PathCombine(DestDir, sr.sr.Name);
          FullSor:=SrcFS.PathCombine(SorDir,sr.sr.Name);
          FullDest:=DstFS.PathCombine(DestDir,sr.sr.Name);
          if not sr.IsDir then // Это файл
               begin
                  if CheckFileMask(sr.sr.Name, NumTask) AND (Not SameText(sr.sr.Name,DeletedFilesF)) then
                       begin
                       if Not Tasks[NumTask].Arh.DelOldArh then // не задано хранение удаленных файлов
                             begin
                             if not SrcFS.FileExistsFS(sr.sr.Name) then // файл источник не существует
                                    begin
                                    Result:=Max(Result,DelFileFS(sr.sr.Name,DstFS));
                                    end;
                              end
                           else  // Задано хранение удаленных файлов
                              begin
                              if not SrcFS.FileExistsFS(sr.sr.Name) then // файл источник не существует
                                     begin
                                     DelFiles.Add(sr.sr.Name); // Добавляем файл в список
                                     end;
                               end;
                        end;
               end
              else             // Это каталог
                begin
                 if DelFiles<>nil then
                       begin
                       ClearDelFiles(NumTask,SrcFS,DstFS,DelFiles);
                       DelFiles.Free;
                       DelFiles:=nil;
                       //WasDelFiles:=true;
                       end;
                   if not (SameText(sr.sr.Name, '.')) and not (SameText(sr.sr.Name, '..')) then
                begin
//                  IsSubDir:=true;
                  if (CheckSubDir(FullSor, NumTask)) then
                     begin
                       if Not Tasks[NumTask].Arh.DelOldArh then // не задано хранение удаленных файлов
                           begin
                              if not SrcFS.DirectoryExistsFS(sr.sr.Name,srSour) then // директория приемника не существует
                                 begin
                                 Result:=Max(Result,DelDirsFS(FullDest,DstFS));
                                 end
                               else
                                 Result:=Max(Result,DelOldFilesFS(FullSor,FullDest,SrcFS,DstFS,NumTask,true));
                            end
                              else
                                 Result:=Max(Result,DelOldFilesFS(FullSor,FullDest,SrcFS,DstFS,NumTask,true));

                      end;

                end;
                end;



        end;
      until DstFS.FindNextFS(sr) <> 0;
     DstFS.FindCloseFS(sr);
//     SrcFS.FindCloseFS(srSour);

//     srSour.Free;
       if DelFiles<>nil then // Каталогов не было
                       begin
                       ClearDelFiles(NumTask,SrcFS,DstFS,DelFiles);
                       DelFiles.Free;
                       DelFiles:=nil;
                      // WasDelFiles:=true;
                       end;




      {

          // Если каталог пуст, удаляем
          if Recurse AND (Not IsSubDir) AND (not (directoryexists(SorDir))) And (DelFiles.Count=0) then // директория приемника не существует и все файлы удалены, подкаталогов нет
               begin
               Result:=Max(Result,DelDirs(DestDir));
               end
          end;
          }
  //DelFiles.SaveToFile;
//  DelFiles.Free;
  end;
sr.Free;
if isrSor=0 then
      begin
      SrcFS.FindCloseFS(srSour);
      srSour.Free;
      end;
end;
//=================================================================
//   Проходим по всем файлам в xml, удаляем устаревшие
function TBackup.ClearDelFiles(NumTask:integer;SrcFS,DstFS:TCustomFS;DelFiles:TDeletedFiles):integer;
var
  ShortFileName:string;
  i:integer;
  beforedate:TDateTime;
begin
Result:=trOk;
// Проходим по всем файлам в xml, удаляем устаревшие
      if Tasks[NumTask].Arh.DelOldArh then
          begin
          beforedate := IncDay(Now, -Tasks[NumTask].Arh.DaysOld);
          i:=0;
          while i<DelFiles.Count do
          begin
            ShortFileName:=DelFiles.GetName(i);
//            filesor:=PathCombine(DestDir,DelFiles.GetName(i));
//            filesync:=PathCombine(SorDir,DelFiles.GetName(i));

            if (SrcFS.FileExistsFS(ShortFileName)) or (Not DstFs.FileExistsFS(ShortFileName)) then
                  DelFiles.Delete(i) // в источнике есть такой файл, или в приемнике нет такого файла
              else
              if CompareDateTime(DelFiles.GetDate(i), beforedate) = -1 then
                  begin
                  Result:=Max(Result,DelFileFS(ShortFileName, DstFS));
                  DelFiles.Delete(i);
                  //Dec(i);
                  end
                else
                  Inc(i);
          end;
           DelFiles.SaveToFile(DstFS);
          end;

end;

//=================================================================
//
// Удаляет из директории DestDir файлы отсутствующие в SorDir
// DestDir - Приемник
 // NumTask - номер задачи в массиве заданий
 // Recurse - true - рекурсивный вызов
 //           false - первый вызов
//Возвращает Код ошибки
{
function TBackup.DelOldFiles(SorDir, DestDir: string; NumTask: integer; Recurse: boolean): integer;
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
  DelFiles.Free;
  end;

end;
}
//=================================================================
//   SorDir => DestDir FS
// копирует директорию SorDir в DestDir
// DestDir - Приемник
 // NumTask - номер задачи в массиве заданий
 // Recurse - true - рекурсивный вызов
 //           false - первый вызов
 //
//Возвращает Код ошибки

function TBackup.SimpleCopyDirsFS(SorDir, DestDir: string; var SorFS:TCustomFS;var DestFS:TCustomFS; NumTask: integer; Recurse:boolean): integer;
var
  sr: TSearchRecFS;
  SubSorDir,SubDestDir:string;
begin
  Result := trOk;
  if recurse and not Tasks[NumTask].SourceFilt.Recurse then exit; // подкаталоги не обрабатывать
  // Устанавливаем текущие каталоги
  SorFs.ChangeWorkingDir(SorDir);
  DestFS.ChangeWorkingDir(DestDir);
  sr:=TSearchRecFS.Create;
  // Проходим по файлам и директориям источника
  if SorFs.FindFirstFS(sr) = 0 then
  begin
    repeat
      begin
    //-------
     if Not sr.IsDir then // Это файл
      begin

        if (CheckFileMask(sr.sr.Name, NumTask)) AND (Not SameText(sr.sr.Name,DeletedFilesF)) then
          // Проверка файла на маску и что это не файл с данными удаленных файлов
        begin
//          filesync := PathCombine(DestDir, sr.sr.Name); // Имя файла приемника
//          filesor  := PathCombine(SorDir, sr.sr.Name); // Имя файла источника
          if DestFs.FileExistsFS(sr.sr.Name) then
                // файл в каталоге приемнике уже есть
          begin // Тогда сверяются даты
            if CompareFileDateFS(SorFS,DestFS, sr.sr.Name) then
            begin
              Result:=CopyFileFS(SorFS,DestFS,sr,Result);
            end;

          end
          else // файл приемник не существует
          begin
              Result:=CopyFileFS(SorFS,DestFS,sr,Result);
          end;
        end;// if checkfilemask
      end
     else   // Это директория
      begin
        if not SameText(sr.sr.Name, '.') and not SameText(sr.sr.Name, '..') then
        begin
          SubSorDir := SorFS.PathCombine(SorDir, sr.sr.Name);
          SubDestDir  :=DestFS.PathCombine(DestDir, sr.sr.Name);
          if CheckSubDir(SubSorDir, NumTask) then
            if SimpleCopyDirsFS(SubSorDir, SubDestDir,SorFS,DestFS,NumTask, True) = trFileError then
              Result := trFileError;
         end;
       end;
      end;
    until SorFS.FindNextFS(sr) <> 0;
    SorFS.FindCloseFS(sr);

  end;
  sr.Free;
end;
//=================================================================
{
Копирование файла с использованием ФС
Логирование результата
CurResult - результат выполнения задания до копирования (trOk,trError,...)
Возвращает результат выполнения задания после копирования
}
function TBackup.CopyFileFS(FromFS,ToFS:TCustomFS;F:TSearchRecFS;CurResult:integer):integer;
begin
OnProgress(nil, NewFile, F.sr.Name, F.sr.Size);  // Вызов события для обработки потоком
if not SimpleCopyFileFS(FromFS,ToFS,F.sr.Name) then
     Result := trFileError
   else
     Result:=CurResult;
OnProgress(nil, ProgressUpdate, '', F.sr.Size);
end;
//=================================================================
{
Копирование файла с использованием ФС
Логирование результата
}
function TBackup.SimpleCopyFileFS(FromFS,ToFS:TCustomFS;ShortFileName:string):boolean;
var
  FullSorFile,FullDestFile:string;
//  DestDir:string;
begin
FullSorFile:=FromFS.PathCombine(FromFS.WorkingDir,ShortFileName);
FullDestFile:=ToFS.PathCombine(ToFS.WorkingDir,ShortFileName);
Result:=false;
// File -> File
if (FromFS is TFileFS) and (ToFS is TFileFS) then
     begin
     Result:=(FromFS as TFileFS).CopyFileFS(FullSorFile,FullDestFile);
     LogMessage(FromFS.LastError);
     end;
// File -> FTP
if (FromFS is TFileFS) and (ToFS is TFTPFS) then
     begin
     // Сохранить файл на фтп
     Result:=(ToFS as TFTPFS).StoreFile(ShortFileName,FullSorFile);
     LogMessage(ToFS.LastError);
     end;
// FTP -> File
if (FromFS is TFTPFS) and (ToFS is TFileFS) then
     begin
     // Закачать файл c фтп
     // Проверка существования каталога, создание при необходимости
     if not SysUtils.DirectoryExists(ToFS.WorkingDir) then
      begin
         if not ForceDir(ToFS.WorkingDir) then
              begin
              Result:=false;
              exit;
              end;
      end;

     Result:=(FromFS as TFTPFS).GetFile(ShortFileName,FullDestFile);
     LogMessage(FromFS.LastError);
     end;
// FTP -> FTP
if (FromFS is TFTPFS) and (ToFS is TFTPFS) then
     begin
     // Закачать файл c фтп во временный каталог
     FullDestFile:=TCustomFS.PathCombineEx(Settings.TempDir,ShortFileName,DirectorySeparator);
     Result:=(FromFS as TFTPFS).GetFile(ShortFileName,FullDestFile);
     LogMessage(FromFS.LastError);
     // Сохранить файл на фтп
     Result:=(ToFS as TFTPFS).StoreFile(ShortFileName,FullDestFile);
     LogMessage(ToFS.LastError);
     // Удалить временный файл
     DelFile(FullDestFile);
     end;

//Result:=ToFS.CopyFile(FromFS,ShortFileName);
//LogMessage(ToFS.LastError);
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
{
function TBackup.SimpleCopyDirs(SorDir, DestDir: string; NumTask: integer; Recurse: boolean;NTFSCopy:boolean): integer;
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

}




 //======================================================================
 // Создание каталога
function TBackup.ForceDir(DirName: string): boolean;
var
  str: string;
  res: boolean;
begin
  Result := True;
  if DirectoryExists(DirName) then
    exit;
  // Создаем катаог
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
function TBackup.CompareFileDate (aDate,bDate:integer):boolean;
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
// Возвращает true если SrcFS Date> DstFS Date и разница между ними <> ровно 1 час
 // true - файл копировать, false - не копироваь
 // Filename - короткое имя файла
function TBackup.CompareFileDateFS(SorFS,DestFS:TCustomFS; FileName: string): boolean;
var
  Hourd: double;
  aaDate, bbDate: TDateTime; // Нормальное время
//  aDate, bDate: integer;     // Файловое время
  str:   string;
begin
  try
    aaDate:=SorFS.GetFileDateFS(FileName);
    if aaDate = 0 then // Ошибка чтения даты
    begin
      Result := True;
      str    := Format(rsLogFileDateErr, [ansitoutf8(FileName)]);
      LogMessage(str);
      Exit;
    end;
    bbDate :=DestFS.GetFileDateFS(FileName);
    if bbDate = 0 then // Ошибка чтения даты
    begin
      Result := True;
      str    := Format(rsLogFileDateErr, [ansitoutf8(FileName)]);
      LogMessage(str);
      Exit;
    end;
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
      str    := Format(rsLogFileDateErrEx,[ansitoutf8(FileName), ansitoutf8(FileName), str]);
      exit;
    end;
  end;
end;

 //=====================================================================
 // Сврека даты/времени двух файлов
// Возвращает true если aDate>bDate и разница между ними <> ровно 1 час
 // true - файл копировать, false - не копироваь
 // aFileName, bFilename - Полные пути к двум файлам
{
function TBackup.CompareFileDate(aFileName, bFileName: string): boolean;
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
}
//======================================================================
// Расчет размера копируемой директории FS
function TBackup.GetSizeDirFS (var SrcFS:TCustomFS;var DstFS:TCustomFS; NumTask: integer): int64;
//var
//  Total:int64;
begin
if (SrcFS is TFileFS) and (DstFS is TFileFS) then
              begin
               Result:=SimpleGetSizeDirFS(SrcFS.RootDir,DstFS.RootDir,SrcFS,DstFS,NumTask,false);
               if Tasks[NumTask].Action=ttSync then
                 Result:=Result+SimpleGetSizeDirFS(DstFS.RootDir,SrcFS.RootDir,DstFS,SrcFS,NumTask,false);
              end
          else Result:=0;
end;

//======================================================================
// Расчет размера копируемой директории FS
function TBackup.SimpleGetSizeDirFS (SorDir,DestDir:string;var SrcFS:TCustomFS;var DstFS:TCustomFS; NumTask: integer; Recurse: boolean): int64;
var
  sr: TSearchRecFS;
//  FileAttrs: integer;
//  filesync: string;
//  TypeSync: integer;
//  sordata, destdata: TDateTime; // даты файлов источ и приемника
begin
  Result := 0;
  if recurse and not Tasks[NumTask].SourceFilt.Recurse then
    exit; // подкаталоги не обрабатывать
//  if not recurse then TotalSize := 0;
//  TypeSync    := Tasks[NumTask].Action;
  if not Recurse then
  begin
    if not SrcFS.IsAvalible(false) then // каталога-источника не существует
    begin
      exit; // айяй
    end;
  end;
  // сначала файлы
  SrcFS.ChangeWorkingDir(SorDir);
  DstFS.ChangeWorkingDir(DestDir);
  sr:=TSearchRecFS.Create;
  if SrcFS.FindFirstFS(sr) = 0 then
  begin
    repeat
      begin
        if not sr.IsDir then // Файл
        begin
        if CheckFileMask(sr.sr.Name, NumTask) then // Проверка файла на маску
        begin
          if DstFS.FileExistsFS(sr.sr.Name) then  // файл в каталоге приемнике уже есть
          begin // Тогда сверяются даты
            if CompareFileDateFS(SrcFS,DstFS,sr.sr.Name)  then    // файл источник позже
            begin
              Result:=Result + sr.sr.size;  // Добавляем размер файла
            end;
             {
            if TypeSync = ttSync then // если синхронизация
            begin
              if CompareFileDateFS(DstFS,SrcFS,sr.sr.Name)  then // файл источник раньше
              begin
                Result := Result + sr.sr.size;
              end;
            end;
            }
          end
          else // файл приемник не существует
          begin
            Result := Result + sr.sr.size; // Добавляем размер файла
          end;
        end;// if checkfilemask
      end
      else  // Каталог
         begin
           if not SameText(sr.sr.Name, '.') and not SameText(sr.sr.Name, '..') then
                begin
                 if CheckSubDir(SrcFS.PathCombine(SorDir,sr.sr.Name), NumTask) then
                       Result:=Result+SimpleGetSizeDirFS(SrcFS.PathCombine(SorDir,sr.sr.Name),DstFS.PathCombine(DestDir,sr.sr.Name),SrcFS,DstFS, NumTask, True);
                end;
         end;
      end;
    until SrcFS.FindNextFS(sr) <> 0;
    SrcFS.FindCloseFS(sr);
    sr.Free;
  end;



end;



//======================================================================
// Расчет размера копируемой директории
function TBackup.GetSizeDir(dir, syncdir: string; NumTask: integer; Recurse: boolean): integer;
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
{
function TBackup.CryptStr(Str: string): string;
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
}
 //========================================================================
 // Дешифрация строки
{
function TBackup.DecryptStr(Str: string): string;
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
}
 //===================================================
 // Вспомогательная функция для DecryptStr
// Str функция состоящяя из Hex цифр (2 символа на цифру)
 // Pos - нужная позиция (в одной позиции по 2 символа)
 // Возвращает число из позиции
{
function TBackup.HexStrToInt(Str: string; Pos: integer): integer;
var
  intsym: integer;
  hexstr: string;
begin
  hexstr := '$' + str[pos * 2 - 1] + str[pos * 2];
  intsym := StrToInt(hexstr);
  Result := intsym;
end;
}

end.


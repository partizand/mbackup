{
Класс одного задания
}

unit task;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,XMLCfg,filter,customfs,FtpFS;

{
type // Константы результата выполнения задачи
  TTaskResult=(trOk= 0,trFileError = 10,trError = 20);
 }

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


type    // Парметры расписания
      TRasp = record
        //  Time:TDateTime; // Время начала
        OnceForDay: boolean; // Запускать только раз в сутки
    //    DelFilesEnabled:boolean; // Хранение удаленных файлов для зеркалирования включено
    //   DelFilesDays:integer; // Сколько дней хранить удаленные файлы

        //   Time:TDateTime; // Время начала
        //   AtTime:Boolean; // Запуск в заданное время
        //   Manual:Boolean; // Запуск вручную
        //   AtStart:Boolean; // Запуск при загрузке программы
        //   EvMinutes:Boolean; // Через каждые Minutes в теч дня
        //   Minutes:integer; // Через каждые столько минут в течении дня
      end;

    // Степень сжатия архива
    type
      TLevelCompress=(lcNone=0,lcFastest=1,lcFast=3,lcNormal=5,lcMaximum=7,lcUltra=9); // Совпадает с 7-zip (zip - тоже самое, но нет 0)


    type  //параметры архива
      TArh = record
        Name:      string;  // имя архива
        LevelCompress:TLevelCompress;
        DelAfterArh:boolean; // Удалять архивы после упаковки (только Rar)
        EncryptEnabled:boolean; // Устанавливать пароль на архив
        Password:string; // Пароль на архив
        PasswordArh:string; // Пароль на архив
        ArhOpenFiles:boolean; // Архивировать файлы открытые для записи
        Solid:boolean; // непрерывный архив
        AddOptions:string; // Дополнительные опции архивирования
        DelOldArh: boolean; //Удалять старые архивы
        DaysOld:   integer; // старше дней
        MonthsOld: integer; // страше месяцев
        YearsOld:  integer; // страше лет
      end;

    // Параметры приемника или источника
    type
       TFSParam =record
       FSType:TFSType; // Тип (файловая или ftp)
       RootDir:string; // Каталог
       FtpServParam:TFtpServParam; // Параметры ftp сервера
       end;
    {
    type // Параметры запуска внешних программ до и после задания
      TExtProgs = record
        BeforeStart: boolean;
        // Запускать программу до начала задания
        BeforeName:  string; // Имя файла для запуска
        AfterStart:  boolean; // Запускать программу после задания
        AfterName:   string; // Имя файла для запуска
      end;
     }
    type
      TExtProg=record
      Enabled:boolean; // Запускать
      Condition:integer; // Условие запуска (-1 Всегда, или если результат выплнения задания меньше заданного)
      Cmd:string; // Имя файла для запуска
      end;

    type // Параметры фильтрации файлов и каталогов источника
      TSourceFilt = record
        Recurse:    boolean;     // Обрабатывать подкаталоги
        FiltSubDir: boolean;     // За исключением подкаталогов
        SubDirs:string;//список исключаемых каталогов через ;    TStringList; // список исключаемых каталогов
        FiltFiles:  boolean;     // фильтровать файлы по условию
        ModeFiltFiles: integer;
        //  режим фильтрации Задается константами 0-исключая файлы по маске (ниже), 1-Только файлы по маске
        FileMask:  string;//список масок файлов через ; TStringList; // список масок файлов
      end;

    type  // Запись для параметров одного копирования
      TTask = class

        public
          constructor Create;
          constructor Create(Task:TTask); // Создание копированием
          constructor Create(var XMLDoc:TXMLConfig;Section:string); // Создание чтением из файла
          destructor Destroy; override;
          procedure Assign(STask:TTask); // Копирование из существующего задания
          procedure LoadFromFile(var XMLDoc:TXMLConfig;Sec:string);
          procedure SaveToFile(var XMLDoc:TXMLConfig;Sec:string);
      public
        //    ProfName:String; // Имя конфигурации
        Enabled:  boolean; // задание разрешено
        Name:     string; // Имя задания
        NameTask:string;
        Status:   integer;  // Статус задания, см константы stNone,stRuning,stWaiting
        LastResult: integer;// Результат последнего выполнения
        LastRunDate: TDateTime; // Дата и время последнего запуска задания
        SrcFSParam:TFSParam; // Источник
        DstFSParam:TFSParam; // Приемник
    //    SorPath:  string; // каталг источник
    //    DestPath: string; // каталог приемник
        Action:   integer; // действие
        MailAlert: integer; // Уведомления по почте
        Rasp:     TRasp; // Расписание
        Arh:      TArh; // параметры архива
        NTFSPerm: boolean; // Копировать права NTFS
    //    ExtProgs: TExtProgs; // Внешние программы
        ExtBefore:TExtProg; // Запускать перед
        ExtAfter:TExtProg; // Запускать после
        SourceFilt: TSourceFilt; // условия фильтрации файлов и папок источника
        Filter:TFilter; // Фильтр
      end;

// Указатель на TTask
 type
  PTTask=^TTask;

implementation
//------------------------------------------------------------------------------
constructor TTask.Create;
begin
  inherited Create;
  // Создаем объекты
  Filter:=TFilter.Create('');

  // Заполняем значения по умолчанию
  self.Name      := '';
 SrcFSParam.RootDir   := '';
  SrcFSParam.FSType:=fstFile;
  SrcFSParam.FtpServParam.Port:='21';
  DstFSParam.RootDir := '';
  DstFSParam.FSType:=fstFile;
  DstFSParam.FtpServParam.Port:='21';
  Action    := 0;
  Arh.Name  := 'arh%YYMMDD%';

  Rasp.OnceForDay := False;

  Enabled   := True;
  // Архив
  Arh.DelOldArh := False;
  Arh.DelAfterArh := False;
  Arh.DaysOld := 7;
  Arh.MonthsOld := 12;
  Arh.YearsOld := 5;
  Arh.EncryptEnabled:=false;
  Arh.LevelCompress:= lcNormal;
  Arh.ArhOpenFiles:=false;
  Arh.Solid:=false;
  Arh.AddOptions:='';
  Arh.Password:='';

  Status    := stNone;
  LastRunDate := 0;
  LastResult := trOk;
  ExtBefore.Enabled:= False;
  ExtBefore.Cmd := '';
  ExtBefore.Condition:=-1;

  ExtAfter.Enabled := False;
  ExtAfter.Cmd := '';
  ExtAfter.Condition := -1;

  NTFSPerm  := False;
  MailAlert := 0;

  SourceFilt.Recurse    := True;
  SourceFilt.FiltSubDir := False;
  SourceFilt.SubDirs    := '';//TStringList.Create;

  SourceFilt.FiltFiles  := False;
  SourceFilt.ModeFiltFiles := 0;
  SourceFilt.FileMask   :='*.tmp;*.bak';// TStringList.Create;
end;
//------------------------------------------------------------------------------
// Создание копированием
constructor TTask.Create(Task:TTask);
begin
 inherited Create;
   // Создаем объекты
   Filter:=TFilter.Create('');
   self.Assign(Task); // Копируем
end;
//------------------------------------------------------------------------------
// Создание чтением из файла
constructor TTask.Create(var XMLDoc:TXMLConfig;Section:string);
begin
 inherited Create;
   // Создаем объекты
   Filter:=TFilter.Create('');
   self.LoadFromFile(XMLDoc,Section); // Загружаем из файла
end;

//------------------------------------------------------------------------------
destructor TTask.Destroy;
begin
  // Удаляем объекты
  Filter.Free;

  inherited Destroy;
end;
//------------------------------------------------------------------------------
procedure TTask.LoadFromFile(var XMLDoc:TXMLConfig;Sec:string);
var
  i, cnt: integer;
//  sec:     string;
  strDate: string;
  FrmSet:TFormatSettings;
  tmpint:integer;
  //cr:string;
begin
    // Имя секции с заданием
//    sec := 'tasks/task' + IntToStr(i+1) + '/';
    Name := xmldoc.GetValue(sec + 'name/value', '');
    // Источник
    SrcFSParam.RootDir:=xmldoc.GetValue(sec + 'SrcFSParam/RootDir/value','');

    tmpint:=xmldoc.GetValue(sec + 'SrcFSParam/FSType/value',integer(fstFile));
    SrcFSParam.FSType:=TFSType(tmpint);
    SrcFSParam.FtpServParam.Host:=xmldoc.GetValue(sec + 'SrcFSParam/FtpServParam/Host/value','');
    SrcFSParam.FtpServParam.Port:=xmldoc.GetValue(sec + 'SrcFSParam/FtpServParam/Port/value','' );
    SrcFSParam.FtpServParam.InintialDir:=xmldoc.GetValue(sec + 'SrcFSParam/FtpServParam/InintialDir/value','');
    SrcFSParam.FtpServParam.UserName:=xmldoc.GetValue(sec + 'SrcFSParam/FtpServParam/UserName/value', '');
    SrcFSParam.FtpServParam.Password:=xmldoc.GetValue(sec + 'SrcFSParam/FtpServParam/Password/value', '');
    SrcFSParam.FtpServParam.PassiveMode:=xmldoc.GetValue(sec + 'SrcFSParam/FtpServParam/PassiveMode/value', false);
    SrcFSParam.FtpServParam.AutoTLS:=xmldoc.GetValue(sec + 'SrcFSParam/FtpServParam/AutoTLS/value', false);

     if (SrcFSParam.RootDir='') and (SrcFSParam.FSType=fstFile) then
        SrcFSParam.RootDir:=xmldoc.GetValue(sec + 'SorPath/value','');



    // Приемник
    DstFSParam.RootDir:=xmldoc.GetValue(sec + 'DstFSParam/RootDir/value','');
    tmpint:=xmldoc.GetValue(sec + 'DstFSParam/FSType/value', integer(fstFile));
    DstFSParam.FSType :=TFSType(tmpint);
    DstFSParam.FtpServParam.Host:=xmldoc.GetValue(sec + 'DstFSParam/FtpServParam/Host/value','' );
    DstFSParam.FtpServParam.Port:=xmldoc.GetValue(sec + 'DstFSParam/FtpServParam/Port/value','' );
    DstFSParam.FtpServParam.InintialDir:=xmldoc.GetValue(sec + 'DstFSParam/FtpServParam/InintialDir/value','');
    DstFSParam.FtpServParam.UserName:=xmldoc.GetValue(sec + 'DstFSParam/FtpServParam/UserName/value','' );
    DstFSParam.FtpServParam.Password:=xmldoc.GetValue(sec + 'DstFSParam/FtpServParam/Password/value','' );

    DstFSParam.FtpServParam.PassiveMode:=xmldoc.GetValue(sec + 'DstFSParam/FtpServParam/PassiveMode/value',false );
    DstFSParam.FtpServParam.AutoTLS:=xmldoc.GetValue(sec + 'DstFSParam/FtpServParam/AutoTLS/value',false );
    if (DstFSParam.RootDir='') and (DstFSParam.FSType=fstFile) then
        DstFSParam.RootDir:=xmldoc.GetValue(sec + 'DestPath/value','');


    Action   := xmldoc.GetValue(sec + 'Action/value', 0);
    Enabled  := xmldoc.GetValue(sec + 'Enabled/value', False);

    Status   := stNone;
    // Чтение параметров архива

    Arh.Name      := xmldoc.GetValue(sec + 'Arh/Name/value', '');
    Arh.DelOldArh := xmldoc.GetValue(sec + 'Arh/DelOldArh/value', False);
    Arh.DaysOld   := xmldoc.GetValue(sec + 'Arh/DaysOld/value', 0);
    Arh.MonthsOld := xmldoc.GetValue(sec + 'Arh/MonthsOld/value', 0);
    Arh.YearsOld  := xmldoc.GetValue(sec + 'Arh/YearsOld/value', 0);
    Arh.DelAfterArh:=xmldoc.GetValue(sec + 'Arh/DelAfterArh/value', False);
    Arh.ArhOpenFiles:=xmldoc.GetValue(sec + 'Arh/ArhOpenFiles/value', False);
    Arh.Solid:=xmldoc.GetValue(sec + 'Arh/Solid/value', true);
    Arh.AddOptions:=xmldoc.GetValue(sec + 'Arh/AddOptions/value', '');

    Arh.EncryptEnabled:=xmldoc.GetValue(sec + 'Arh/EncryptEnabled/value', False);
    Arh.Password:=xmldoc.GetValue(sec + 'Arh/Password/value', '');
    Arh.LevelCompress:=TLevelCompress(xmldoc.GetValue(sec + 'Arh/LevelCompress/value',integer(lcNormal)));


    // Чтение параметров запуска внешних программ
    ExtBefore.Enabled :=xmldoc.GetValue(sec + 'ExtProgs/ExtBefore/Enabled/value', False);
    ExtBefore.Cmd := xmldoc.GetValue(sec + 'ExtProgs/ExtBefore/Cmd/value', '');
    ExtBefore.Condition := xmldoc.GetValue(sec + 'ExtProgs/ExtBefore/Condition/value', -1);

    ExtAfter.Enabled :=xmldoc.GetValue(sec + 'ExtProgs/ExtAfter/Enabled/value', False);
    ExtAfter.Cmd := xmldoc.GetValue(sec + 'ExtProgs/ExtAfter/Cmd/value', '');
    ExtAfter.Condition := xmldoc.GetValue(sec + 'ExtProgs/ExtAfter/Condition/value', -1);

    // Копирование прав
    NTFSPerm := xmldoc.GetValue(sec + 'NTFSPerm/value', False);
    // Уведомления по почте
    MailAlert := xmldoc.GetValue(sec + 'MailAlert/value', 0);
    // Расписание
    Rasp.OnceForDay := xmldoc.GetValue(sec + 'Rasp/OnceForDay/value', False);
    // Последний результат выполнения задания
    LastResult := xmldoc.GetValue(sec + 'LastResult/value', 0);
    strDate := xmldoc.GetValue(sec + 'LastRunDate/value', '0');
    // Читаем дату последнего запуска в зависимости от версии (последняя float)
    try
     LastRunDate :=StrToFloat(strDate,FrmSet);
    except
      try
      LastRunDate := StrToDateTime(strDate);
      finally
      LastRunDate :=0;
      end;
    end;

    SourceFilt.Recurse := xmldoc.GetValue(sec + 'SourceFilt/Recurse/value', True);

    SourceFilt.FiltSubDir :=
      xmldoc.GetValue(sec + 'SourceFilt/FiltSubDir/value', False);

    SourceFilt.SubDirs:=xmldoc.GetValue(sec + 'SourceFilt/SubDirs/value', '');
    // Количество фильтруемых директорий
    SourceFilt.FiltFiles :=xmldoc.GetValue(sec + 'SourceFilt/FiltFiles/value', False);
    SourceFilt.ModeFiltFiles:=xmldoc.GetValue(sec + 'SourceFilt/ModeFiltFiles/value', 0);
    SourceFilt.FileMask:=xmldoc.GetValue(sec + 'SourceFilt/FileMask/value', '');
    //Count := i+1;
    Filter.LoadFromFile(XMLDoc,sec);


end;
//------------------------------------------------------------------------------
procedure TTask.SaveToFile(var XMLDoc:TXMLConfig;Sec:string);
var
  i: integer;
  FrmSet:TFormatSettings;
begin

 FrmSet.DecimalSeparator:='.';
    xmldoc.SetValue(sec + 'name/value', NameTask);
    // Источник
    xmldoc.SetValue(sec + 'SrcFSParam/RootDir/value', SrcFSParam.RootDir);
    xmldoc.SetValue(sec + 'SrcFSParam/FSType/value',integer(SrcFSParam.FSType));
    xmldoc.SetValue(sec + 'SrcFSParam/FtpServParam/Host/value', SrcFSParam.FtpServParam.Host);
    xmldoc.SetValue(sec + 'SrcFSParam/FtpServParam/Port/value', SrcFSParam.FtpServParam.Port);
    xmldoc.SetValue(sec + 'SrcFSParam/FtpServParam/InintialDir/value', SrcFSParam.FtpServParam.InintialDir);
    xmldoc.SetValue(sec + 'SrcFSParam/FtpServParam/UserName/value', SrcFSParam.FtpServParam.UserName);
    xmldoc.SetValue(sec + 'SrcFSParam/FtpServParam/Password/value', SrcFSParam.FtpServParam.Password);
    xmldoc.SetValue(sec + 'SrcFSParam/FtpServParam/PassiveMode/value', SrcFSParam.FtpServParam.PassiveMode);
    xmldoc.SetValue(sec + 'SrcFSParam/FtpServParam/AutoTLS/value', SrcFSParam.FtpServParam.AutoTLS);
    // Приемник
    xmldoc.SetValue(sec + 'DstFSParam/RootDir/value', DstFSParam.RootDir);
    xmldoc.SetValue(sec + 'DstFSParam/FSType/value', integer(DstFSParam.FSType));
    xmldoc.SetValue(sec + 'DstFSParam/FtpServParam/Host/value', DstFSParam.FtpServParam.Host);
    xmldoc.SetValue(sec + 'DstFSParam/FtpServParam/Port/value', DstFSParam.FtpServParam.Port);
    xmldoc.SetValue(sec + 'DstFSParam/FtpServParam/InintialDir/value', DstFSParam.FtpServParam.InintialDir);
    xmldoc.SetValue(sec + 'DstFSParam/FtpServParam/UserName/value', DstFSParam.FtpServParam.UserName);
    xmldoc.SetValue(sec + 'DstFSParam/FtpServParam/Password/value', DstFSParam.FtpServParam.Password);
    xmldoc.SetValue(sec + 'DstFSParam/FtpServParam/PassiveMode/value', DstFSParam.FtpServParam.PassiveMode);
    xmldoc.SetValue(sec + 'DstFSParam/FtpServParam/AutoTLS/value', DstFSParam.FtpServParam.AutoTLS);


    xmldoc.SetValue(sec + 'Action/value', Action);
    xmldoc.SetValue(sec + 'Enabled/value', Enabled);
    // Сохраняем параметры архива
    xmldoc.SetValue(sec + 'Arh/Name/value', Arh.Name);
    xmldoc.SetValue(sec + 'Arh/DelOldArh/value', Arh.DelOldArh);
    xmldoc.SetValue(sec + 'Arh/DaysOld/value', Arh.DaysOld);
    xmldoc.SetValue(sec + 'Arh/MonthsOld/value', Arh.MonthsOld);
    xmldoc.SetValue(sec + 'Arh/YearsOld/value', Arh.YearsOld);
    xmldoc.SetValue(sec + 'Arh/DelAfterArh/value', Arh.DelAfterArh);
    xmldoc.SetValue(sec + 'Arh/EncryptEnabled/value', Arh.EncryptEnabled);
    xmldoc.SetValue(sec + 'Arh/Password/value', Arh.Password);  // Исключение
    xmldoc.SetValue(sec + 'Arh/LevelCompress/value', integer(Arh.LevelCompress));
    xmldoc.SetValue(sec + 'Arh/ArhOpenFiles/value', Arh.ArhOpenFiles);
    xmldoc.SetValue(sec + 'Arh/Solid/value', Arh.Solid);
    xmldoc.SetValue(sec + 'Arh/AddOptions/value', Arh.AddOptions);

    //Параметры запуска внешних программ
    // before
    xmldoc.SetValue(sec + 'ExtProgs/ExtBefore/Enabled/value', ExtBefore.Enabled);
    xmldoc.SetValue(sec + 'ExtProgs/ExtBefore/Cmd/value', ExtBefore.Cmd);
    xmldoc.SetValue(sec + 'ExtProgs/ExtBefore/Condition/value', ExtBefore.Condition);

    xmldoc.SetValue(sec + 'ExtProgs/ExtAfter/Enabled/value', ExtAfter.Enabled);
    xmldoc.SetValue(sec + 'ExtProgs/ExtAfter/Cmd/value', ExtAfter.Cmd);
    xmldoc.SetValue(sec + 'ExtProgs/ExtAfter/Condition/value', ExtAfter.Condition);
    // Копирование прав
    xmldoc.SetValue(sec + 'NTFSPerm/value', NTFSPerm);
    // Уведомления по почте
    xmldoc.SetValue(sec + 'MailAlert/value', MailAlert);
    // Расписание
    xmldoc.SetValue(sec + 'Rasp/OnceForDay/value', Rasp.OnceForDay);

    // Результат последнего выполнения задачи
    xmldoc.SetValue(sec + 'LastResult/value', LastResult);
    xmldoc.SetValue(sec + 'LastRunDate/value', FloatToStr(LastRunDate,FrmSet));
    // Параметры фильтрации каталогов и файлов источника
    xmldoc.SetValue(sec + 'SourceFilt/Recurse/value', SourceFilt.Recurse);
    xmldoc.SetValue(sec + 'SourceFilt/FiltSubDir/value', SourceFilt.FiltSubDir);
    // список исключаемых директорий
    xmldoc.SetValue(sec + 'SourceFilt/SubDirs/value',SourceFilt.SubDirs);
    xmldoc.SetValue(sec + 'SourceFilt/FiltFiles/value', SourceFilt.FiltFiles);
    xmldoc.SetValue(sec + 'SourceFilt/ModeFiltFiles/value',      SourceFilt.ModeFiltFiles);
    xmldoc.SetValue(sec + 'SourceFilt/FileMask/value',SourceFilt.FileMask);

    Filter.SaveToFile(XMLDoc,sec);


end;

//------------------------------------------------------------------------------
procedure TTask.Assign(STask:TTask); // Копирование из существующего задания
begin
Enabled:=STask.Enabled;
Name:=STask.Name;
 Status:=STask.Status;
 LastResult:=STask.LastResult;
 LastRunDate:=STask.LastRunDate;
 SrcFSParam:=STask.SrcFSParam;
 DstFSParam:=STask.DstFSParam; // Приемник
 Action:=STask.Action; // действие
 MailAlert:=STask.MailAlert;
 Rasp:=STask.Rasp;
 Arh:=STask.Arh;
 NTFSPerm:=STask.NTFSPerm;
 ExtBefore:=STask.ExtBefore;
 ExtAfter:=STask.ExtAfter;
 SourceFilt:=STask.SourceFilt;
 Filter.Assign(STask.Filter);
end;

end.


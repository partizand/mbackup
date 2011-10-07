{
Класс одного задания
}

unit task;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,filter,customfs,FtpFS;

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
          destructor Destroy; override;

      public
        //    ProfName:String; // Имя конфигурации
        Enabled:  boolean; // задание разрешено
        Name:     string; // Имя задания
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

implementation
//------------------------------------------------------------------------------
constructor TTask.Create;
begin
  inherited Create;
  // Создаем объекты
  Filter:=TFilter.Create('');
  LastResult:=trOk;
end;
//------------------------------------------------------------------------------
destructor TTask.Destroy;
begin
  // Удаляем объекты
  Filter.Free;

  inherited Destroy;
end;


end.


unit ftpfs;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,customfs,logunit,unitfunc,ftpsend,blcksock,ssl_openssl,msgstrings;


const
  KeyStrTask='a2JH380oUtkI67B345d3OF2yeKMXHfD8q670z26007tJcdg1oy'; // Ключ шифрования

 // Структура настроек ftp сервера
type
  TFtpServParam=record
    Host:string;
    Port:string;
    InintialDir:string;
    UserName:string;
    Password:string;
    PassiveMode:boolean;
    AutoTLS:boolean;
  end;

type
  TFTPFS=class (TCustomFS)
    public
      FTPServParam:TFtpServParam;
      FtpSend:TFtpSend;
      Connected:boolean; // Подключены к серверу
      TempDir:string; //  Временный каталог на компьютере
//      EnableLog:boolean; // Вести лог работы с фтп сервером
     constructor Create;
     destructor Destroy; override;
     // Подключение к ftp серверу
     function Connect:boolean;
     function Disconnect:boolean;
     // Работа с файловой системой
    // FS в порядке и доступна
    // TryCreate - true - если не в порядке, попробвать привести в порядок (создать каталог RootDir)
    function IsAvalible(TryCreate:boolean):boolean; override;
    function GetName:string;  override; // Возвращает имя ФС для отображения в логе
    class function GetFtpName(FtpParam:TFtpServParam):string; // Возвращает текстовое отображение ftp сервера
    class function GetSrvName(FtpParam:TFtpServParam):string; // Возвращает текстовое отображение ftp сервера без корневого каталога
    class function InitDirCorrect(const InitDir:string):string; // Исправляет стартовый каталог для ftp (добавляет / в начале)
    function ChangeWorkingDir(const Directory: string): Boolean; override;
      // Поиск
    function FindFirstFS(var F: TSearchRecFS): Integer; override;
    function FindNextFS(var F: TSearchRecFS): Integer; override;
    procedure FindCloseFS(var F: TSearchRecFS); override;
    // Файлы
     function FileExistsFS(const FileName: string): Boolean; override; // Только имя файла, в тек каталоге
     function GetFileDateFS(const FileName: string):TDateTime; override; // Только имя файла, в тек каталоге
     function DeleteFileFS(const FileName: string): Boolean; override;// Только имя файла, в тек каталоге
     // Копирование файла
//     function CopyFile(CustomFS:TCustomFS;FileName:string):boolean; override;
     // Закачать файл с ftp (RemoteFileName - короткое имя файла из текущей директории, LocalFileName - полное имя файла)
     function GetFile(const RemoteFileName: string;const LocalFileName: string):boolean;
     // Положить файл на ftp (RemoteFileName - короткое имя файла из текущей директории, LocalFileName - полное имя файла)
     function StoreFile(const RemoteFileName: string;const LocalFileName: string):boolean;
     // Каталоги
     function DirectoryExistsFS(const Dir: string;F: TSearchRecFS): Boolean; override;
     function CreateDirFS(const Dir: string): Boolean; override;
     function DeleteDirFS(const Dir: string): Boolean; override;
     function ForceDirectoriesFS(Dir: string): Boolean; override;
     // Для TDelFiles
     function GetDelFileName:string; override;
     procedure SetDelFileName(DelFileName:string); override;
     procedure RemoveDelFileName(DelFileName:string);  override;
     // Логирование
     LogFtp:TLog;
    private
     function FindNextFTP(var F: TSearchRecFS):integer;
     function GetFileIndex(const FileName: string):integer; // Индекс файла в FtpList по имени
     procedure MonitorConn (Sender: TObject; Reason: THookSocketReason; const Value: String); // Отслеживание состояния соединения
     WorkingDirExists:boolean; // Текущая директория существует на ftp
    // function GetSrvName:string; // Возвращает имя сервера, без корневого каталога
  end;

implementation


//---------------------------------------------------------
class function TFTPFS.InitDirCorrect(const InitDir:string):string;
begin
if InitDir='' then
      begin
      Result:='/';
      end
    else
      begin
      if InitDir[1]<>'/' then
            Result:='/'+InitDir
          else
            Result:=InitDir;
      end;

end;

//---------------------------------------------------------
// Возвращает имя файла для DelFiles на диске, для текущего каталога на ftp
function TFTPFS.GetDelFileName:string;
var
  FullFileName:string;
begin
// Нужно закачать во временный каталог
FullFileName:=TCustomFS.PathCombineEx(TempDir,DeletedFilesF,DirectorySeparator);
if FileExistsFS(DeletedFilesF) then GetFile(DeletedFilesF,FullFileName);
Result:=FullFileName;
end;
//---------------------------------------------------------
// Сохраняет файл TDelFile с диска на фтп
procedure TFTPFS.SetDelFileName(DelFileName:string);
begin
if FileExists(DelFileName) then
    begin
    // Закачиваем
    StoreFile(DeletedFilesF,DelFileName);
     try
     DeleteFile(DelFileName); // Удаляем с диска
     finally
     end;
    end
  else
    begin
    if FileExistsFS(DelFileName) then DeleteFileFS(DelFileName);
    end;
end;
//---------------------------------------------------------
procedure TFTPFS.RemoveDelFileName(DelFileName:string);
begin
if FileExistsFS(DeletedFilesF) then DeleteFileFS(DeletedFilesF); // Удаляем с ftp
if FileExists(DelFileName) then
    begin
     try
     DeleteFile(DelFileName); // Удаляем с диска
     finally
     end;
    end
end;
//---------------------------------------------------------
// Возвращает имя ФС для отображения в логе
function TFTPFS.GetName:string;
begin
Result:=GetFtpName(FTPServParam);
end;
//--------------------------------------------------
// Возвращает текстовое отображение ftp сервера
class function TFTPFS.GetFtpName(FtpParam:TFtpServParam):string;
begin
Result:=GetSrvName(FtpParam)+FtpParam.InintialDir;
end;
//--------------------------------------------------
// Возвращает имя сервера, без корневого каталога
class function TFTPFS.GetSrvName(FtpParam:TFtpServParam):string;
var
  strport:string;
begin
strport:='';
if FtpParam.Port<>'21' then strport:=FtpParam.Port+':';
Result:='ftp://'+FtpParam.Host+strport;
end;
//--------------------------------------------------
function TFTPFS.IsAvalible(TryCreate:boolean):boolean;
var
  str:string;
begin
if Connected then
    begin
    str:=Format(rsFTPChangeWorkDir,[FTPServParam.InintialDir]);
    LogFtp.LogMessage(str);
    Result:=ftpsend.ChangeWorkingDir(FTPServParam.InintialDir); // Переходим в корневой каталог
    //WorkingDir:=Directory;
    LogFtp.LogMessage(ftpsend.FullResult);
    if not Result then
         begin
            if TryCreate then
                  begin
                   Result:=CreateDirFS(FTPServParam.InintialDir);
                  end
                else
                  Result:=false;
         end;
    end
  else
    Result:=false;
end;

//--------------------------------------------------
// Получение файла с ftp
function TFTPFS.GetFile(const RemoteFileName: string;const LocalFileName: string):boolean;
var
  str:string;
begin
if Not Connected then
     begin
     Result:=false;
     str:=GetSrvName(FTPServParam)+PathCombine(WorkingDir,RemoteFileName);
     str:=ansitoutf8(str);
     str:=format(rsFTPGetFileError,[str,rsFTPNotConnected]);
     LogFtp.LogMessage(str);
     LastError:=str;
     Exit;
     end;
ftpsend.DirectFileName:=LocalFileName;
str:=Format(rsFTPGetFileStart,[RemoteFileName]);
LogFtp.LogMessage(str);
Result:=ftpsend.RetrieveFile(RemoteFileName,false);
str:=GetSrvName(FTPServParam)+PathCombine(WorkingDir,RemoteFileName);
str:=ansitoutf8(str);
if Result then // Успешно получили
    begin
    LastError:=format(rsFTPGetFile,[str]);
    end
  else         // Ошибка
    begin
    LastError:=format(rsFTPGetFileError,[str,ftpsend.ResultString]);
    end;
//   LastError:=ftpsend.ResultString;
LogFtp.LogMessage(ftpsend.FullResult);
end;
//--------------------------------------------------
// Загрузка файла на ftp
function TFTPFS.StoreFile(const RemoteFileName: string;const LocalFileName: string):boolean;
var
  str:string;
begin
if Not Connected then
     begin
     Result:=false;
     str:=format(rsFTPUploadFileError,[ansitoutf8(LocalFileName),rsFTPNotConnected]);
     LogFtp.LogMessage(str);
     LastError:=str;
     Exit;
     end;
ftpsend.DirectFileName:=LocalFileName;
// Проверка существования каталога на фтп
if not WorkingDirExists then
       begin
       if CreateDirFS(WorkingDir) then  // Каталог создался
             begin
             ChangeWorkingDir(WorkingDir); // Переходим в него
             end
           else   // Ошибка создания каталога на фтп
             begin
             Result:=false;
             exit;
             end;
       end;
str:=Format(rsFTPUploadFileStart,[LocalFileName]);
LogFtp.LogMessage(str);
Result:=ftpsend.StoreFile(RemoteFileName,false);
//str:=GetSrvName(FTPServParam)+PathCombine(WorkingDir,RemoteFileName);
//str:=ansitoutf8(str);
if Result then // Успешно закачали
    begin
    LastError:=format(rsFTPUploadFile,[ansitoutf8(LocalFileName)]);
    end
  else         // Ошибка
    begin
    LastError:=format(rsFTPUploadFileError,[ansitoutf8(LocalFileName),ftpsend.ResultString]);
    end;
//LastError:=ftpsend.ResultString;
LogFtp.LogMessage(ftpsend.FullResult);
end;



//--------------------------------------------------
// Проверка существования каталога
// Имя каталога короткое
function TFTPFS.DirectoryExistsFS(const Dir: string;F: TSearchRecFS): Boolean;
var
  i:integer;
begin
for i:=0 to F.DirList.Count-1 do
  begin
     if  SameText(F.DirList[i],Dir) then
       begin
       Result:=true;
       exit;
       end;
  end;
Result:=false;
end;
//--------------------------------------------------
// Получение даты файла
function TFTPFS.GetFileDateFS(const FileName: string):TDateTime;
var
  i:integer;
begin
i:=GetFileIndex(FileName);
if i<>-1 then
  begin
  Result:=ftpsend.FtpList.Items[i].FileTime;
  end
 else
  Result:=0;
end;

//--------------------------------------------------
// Проверяет существование файла (только наличие в  FtpList)
function TFTPFS.FileExistsFS(const FileName: string): Boolean;
begin
if GetFileIndex(FileName)=-1 then
  begin
  Result:=false;
  end
 else
  Result:=true;
end;

//--------------------------------------------------
// Индекс файла в FtpList по имени
// -1 если не найден
function TFTPFS.GetFileIndex(const FileName: string):integer;
var
  i:integer;
begin
for i:=0 to ftpsend.FtpList.Count-1 do
  begin
  if not ftpsend.FtpList.Items[i].Directory then
    if  SameText(ftpsend.FtpList.Items[i].FileName,FileName) then
       begin
       Result:=i;
       exit;
       end;
  end;
Result:=-1;
end;

//--------------------------------------------------
// Смена рабочей директории
function TFTPFS.ChangeWorkingDir(const Directory: string): Boolean;
var
  str:string;
begin
if Not Connected then
     begin
     Result:=false;
     str:=format(rsFTPChangeDirError,[ansitoutf8(Directory),rsFTPNotConnected]);
     LogFtp.LogMessage(str);
     LastError:=str;
     Exit;
     end;
str:=Format(rsFTPChangeWorkDir,[Directory]);
LogFtp.LogMessage(str);
Result:=ftpsend.ChangeWorkingDir(Directory);
WorkingDir:=Directory;
LogFtp.LogMessage(ftpsend.FullResult);

if Result then
   begin
   WorkingDirExists:=true;
// Строим список файлов
   ftpsend.FtpList.Clear;
   LogFtp.LogMessage(rsFTPList);
   if Not ftpsend.List('',false) then
        begin
        LastError:=ftpsend.ResultString;
        end;
   LogFtp.LogMessage(ftpsend.FullResult);

   end

  else
   begin
    // Каталог не существует, пробуем создать
    Result:=CreateDirFS(Directory);
    if Result then
          begin
          str:=Format(rsFTPChangeWorkDir,[Directory]);
          LogFtp.LogMessage(str);
          Result:=ftpsend.ChangeWorkingDir(Directory);
          LogFtp.LogMessage(ftpsend.FullResult);
          end
       else
          begin
          WorkingDirExists:=false;
          LastError:=format(rsFTPChangeDirError,[Directory,FtpSend.ResultString]);
          end;
   end;
end;
//--------------------------------------------------
function TFTPFS.FindFirstFS(var F: TSearchRecFS): Integer;
var
  i:integer;
begin
//ftpsend.List(Path,false);

F.CurIndex:=0;
F.IsDir:=false;
F.Directory:=WorkingDir;
if Not Connected then
     begin
     Result:=-1;
     Exit;
     end;
// Строим список файлов   (Команда list)
{
   LogFtp.LogMessage(rsFTPList);
   if Not ftpsend.List('',false) then
        begin
        LastError:=format(rsFTPListError,[WorkingDir,ftpsend.ResultString]);
        LogFtp.LogMessage(ftpsend.FullResult);
        Result:=1;
        exit;
        end;
   LogFtp.LogMessage(ftpsend.FullResult);
 }

// Заполнить список каталогов
F.DirList:=TStringList.Create;
//if ftpsend.FtpList.Count>0 then F.DirList:=TStringList.Create;
for i:=0 to ftpsend.FtpList.Count-1 do
  begin
  if ftpsend.FtpList.Items[i].Directory then
         F.DirList.Add(ftpsend.FtpList.Items[i].FileName);
  end;
Result:=FindNextFTP(F);
end;
//--------------------------------------------------
function TFTPFS.FindNextFS(var F: TSearchRecFS): Integer;
begin
Inc(F.CurIndex);
Result:=FindNextFTP(F);
end;
//--------------------------------------------------
procedure TFTPFS.FindCloseFS(var F: TSearchRecFS);
begin
F.DirList.Free;
end;

//--------------------------------------------------
// поиск следующего файла или каталога
// Команда list уже должна быть выполнена
// Сначала возвращаются файлы, потом каталоги
function TFTPFS.FindNextFTP(var F: TSearchRecFS):integer;
var
  i:integer;
begin
//i:=F.CurIndex;
//Inc(i); // Следующий элемент
if Not Connected then
     begin
     Result:=-1;
     Exit;
     end;
if Not F.IsDir then // Идет перебор файлов
  begin
  i:=F.CurIndex;
  while ftpsend.FtpList.Count>i do // Еще есть что перебирать
   begin
     if ftpsend.FtpList.Items[i].Directory then
           Inc(i) // Это каталог, идем дальше
         else
           begin // Нашелся файл
           F.CurIndex:=i;
           F.sr.Name:=ftpsend.FtpList.Items[i].FileName;
           F.sr.Size:=ftpsend.FtpList.Items[i].FileSize;
           Result:=0;
           exit;
           end;

   end;
   // i=count - ниче не нашли
   F.CurIndex:=0;
   F.IsDir:=true;
  end;
if F.IsDir then // Идет перебор каталогов
   begin
// Ищем каталог
  i:=F.CurIndex;
  if F.DirList.Count>i then
     begin
     F.sr.Name:=F.DirList[i];//  ftpsend.FtpList.Items[i].FileName;
     F.sr.Size:=0; // ftpsend.FtpList.Items[i].FileSize;
     Result:=0;
     end
   else
     begin
     Result:=1;
     end;
   end;
end;
//--------------------------------------------------
// Отслеживание состояния соединения
procedure TFTPFS.MonitorConn (Sender: TObject; Reason: THookSocketReason; const Value: String);
begin
if Reason=HR_SocketClose then Connected:=false;
if Reason=HR_Error then
    begin
    Connected:=false;
    LogFtp.LogMessage(rsFTPLostConnect);
    end;
end;

//--------------------------------------------------
constructor TFTPFS.Create;
begin
inherited Create;
ftpsend:=TFtpSend.Create;
ftpsend.DirectFile:=true; // Работать напрямую с файлами, без потоков
ftpsend.Sock.OnStatus:=@MonitorConn; // мониторинг состояния
//ftpsend.AutoTLS:=true; //FTPServParam.AutoTLS;
//ftpsend.FullSSL:=true;
//ftpsend.Sock.SSL.SSLType:=LT_all;
DirSep:='/';
//TempDir:=
LogFtp:=TLog.Create;
LogFtp.Enabled:=false;
LogFtp.logfile:='ftp.log';
LogFtp.TempLogEnabled:=false;
end;
//--------------------------------------------------
destructor TFTPFS.Destroy;
begin
Disconnect;
ftpsend.Free;
LogFtp.Free;
inherited Destroy;
end;
//--------------------------------------------------
// Подключение к серверу
function TFTPFS.Connect:boolean;
var
  str:string;
begin
FTPServParam.InintialDir:=InitDirCorrect(FTPServParam.InintialDir);
ftpsend.TargetHost:=FTPServParam.Host;
ftpsend.TargetPort:=FTPServParam.Port;
ftpsend.UserName:=FTPServParam.UserName;
ftpsend.Password:=DecryptString(FTPServParam.Password,KeyStrTask);
ftpsend.PassiveMode:=FTPServParam.PassiveMode;
ftpsend.AutoTLS:=FTPServParam.AutoTLS;
LogFtp.LogMessage('-');
str:=format(rsFTPConnect,[GetSrvName(FTPServParam)]);
LogFtp.LogMessage(str);
Result:=ftpsend.Login;
Connected:=Result;
ftpsend.Password:=''; // Обнуление от хакеров
LastError:=ftpsend.ResultString;
LogFtp.LogMessage(ftpsend.FullResult);
end;
//--------------------------------------------------
// Отключение от серврера
function TFTPFS.Disconnect:boolean;
begin
LogFtp.LogMessage(rsFTPDisconnect);
Result:=ftpsend.Logout;
LogFtp.LogMessage(ftpsend.FullResult);
Connected:=false;
end;
//--------------------------------------------------
// Удаление файла
function TFTPFS.DeleteFileFS(const FileName: string): Boolean;
var
 str:string;
begin
if Not Connected then
     begin
     Result:=false;
     str:=format(rsLogDelFileErr,[ansitoutf8(FileName),rsFTPNotConnected]);
     LogFtp.LogMessage(str);
     LastError:=str;
     Exit;
     end;
str:=Format(rsFTPDeleteFile,[FileName]);
LogFtp.LogMessage(str);
Result:=ftpsend.DeleteFile(FileName);
str:=GetSrvName(FTPServParam)+PathCombine(WorkingDir,FileName);
str:=ansitoutf8(str);
if Result then // Успешно удалился файлs
    begin
    LastError:=format(rsLogDelFile,[str]);
    end
  else         // Ошибка
    begin
    LastError:=format(rsLogDelFileErr,[str,ftpsend.ResultString]);
    end;

//LastError:=ftpsend.ResultString;
LogFtp.LogMessage(ftpsend.FullResult);
end;
//--------------------------------------------------
// Создание каталога
function TFTPFS.CreateDirFS(const Dir: string): Boolean;
var
 str:string;
begin
if Not Connected then
     begin
     Result:=false;
     str:=format(rsFTPCreateDirError,[ansitoutf8(Dir),rsFTPNotConnected]);
     LogFtp.LogMessage(str);
     LastError:=str;
     Exit;
     end;
str:=Format(rsFTPCreateDirStart,[Dir]);
LogFtp.LogMessage(str);
Result:=ftpsend.CreateDir(Dir);

if Result then // Успешно создался каталог
    begin
    LastError:=format(rsFTPCreateDir,[ansitoutf8(Dir)]);
    end
  else         // Ошибка
    begin
    LastError:=format(rsFTPCreateDirError,[ansitoutf8(Dir),ftpsend.ResultString]);
    end;

//LastError:=ftpsend.ResultString;
LogFtp.LogMessage(ftpsend.FullResult);
end;
//--------------------------------------------------
// Создание каталога force
function TFTPFS.ForceDirectoriesFS(Dir: string): Boolean;
begin
Result:=CreateDirFS (Dir);
end;

//--------------------------------------------------
// Удаление каталога
function TFTPFS.DeleteDirFS(const Dir: string): Boolean;
var
 str:string;
begin
if Not Connected then
     begin
     Result:=false;
     str:=format(rsFTPDeleteDirError,[ansitoutf8(Dir),rsFTPNotConnected]);
     LogFtp.LogMessage(str);
     LastError:=str;
     Exit;
     end;
str:=Format(rsFTPDeleteDirStart,[Dir]);
LogFtp.LogMessage(str);
Result:=ftpsend.DeleteDir(Dir);
if Result then // Успешно удалился каталог
    begin
    LastError:=format(rsFTPDeleteDir,[ansitoutf8(Dir)]);
    end
  else         // Ошибка
    begin
    LastError:=format(rsFTPDeleteDirError,[ansitoutf8(Dir),ftpsend.ResultString]);
    end;
//LastError:=ftpsend.ResultString;
LogFtp.LogMessage(ftpsend.FullResult);
end;

end.


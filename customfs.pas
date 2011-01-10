unit customfs;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

const
   DeletedFilesF='deleted$.xml'; // Файл для хранения сведений об удаленных файлах

// Типы FS
type
  TFSType=(fstFile=1,fstFTP=2);

  // Класс для поиска файлов
type
  TSearchRecFS=class
  public
     sr:TSearchRec; // Результаты поиска
     IsDir:boolean; // Это каталог
     IsClosed:boolean; // Поиск закрыт
     DirList:TStringList; // Список под-каталогов (ftp)
     Directory:string; // Каталог для которого выполняется поиск
     CurIndex:integer; // Текущий индекс найденного файла
   private
  end;




// Класс виртуальной файловой системы

type
  TCustomFS=class
  public
    RootDir:string; // Корневая директория
    WorkingDir:string; // Текущая директория
    LastError:string; // Текст последней ошибки
    DirSep :string; // Символ разделитель каталоговs
    // Функции
    // FS в порядке и доступна
    // TryCreate - true - если не в порядке, попробвать привести в порядок (создать каталог RootDir)
    function IsAvalible(TryCreate:boolean):boolean; virtual; abstract;
    function GetName:string; virtual; abstract; // Возвращает имя ФС для отображения в логе
    function PathCombine(const Path1: string;const Path2: string): string; // Объединение двух путей
    class function PathCombineEx(const Path1: string;const Path2: string;const Delimiter:string): string; // Объединение двух путей c указанием разделителя
    // Сменить текущую директорию
    function ChangeWorkingDir(const Directory: string): Boolean; virtual; abstract;
    // Поиск
    function FindFirstFS(var F: TSearchRecFS): Integer; virtual; abstract; // Поиск в текущей директории
    function FindNextFS(var F: TSearchRecFS): Integer; virtual; abstract;
    procedure FindCloseFS(var F: TSearchRecFS); virtual; abstract;
    // Файлы
    function FileExistsFS(const FileName: string): Boolean; virtual; abstract; // Только имя файла, в тек каталоге
    function GetFileDateFS(const FileName: string):TDateTime; virtual; abstract; // Только имя файла, в тек каталоге
    function DeleteFileFS(const FileName: string): Boolean; virtual; abstract; // Только имя файла, в тек каталоге
    // Каталоги
    function DirectoryExistsFS(const Dir: string;F: TSearchRecFS): Boolean;virtual; abstract; // Только имя каталога, в каталоге F
    function DeleteDirFS(const Dir: string): Boolean; virtual; abstract; // Полный путь
    function CreateDirFS(const Dir: string): Boolean; virtual; abstract;
    function ForceDirectoriesFS(Dir: string): Boolean; virtual; abstract;
    // Копирование файла
//    function CopyFile(CustomFS:TCustomFS;FileName:string):boolean; virtual; abstract;
    // Для TDelFiles
    function GetDelFileName:string; virtual; abstract; // Имя файла относительно текущего каталога
    procedure SetDelFileName(DelFileName:string); virtual; abstract;
    procedure RemoveDelFileName(DelFileName:string);  virtual; abstract;
  private

  end;

implementation



 //======================================================
 // Объединение двух путей файла (каталог + файл)
 // Возвращает объединенный путь
function TCustomFS.PathCombine(const Path1: string;const  Path2: string): string;
begin
  Result:=PathCombineEx(Path1,Path2,DirSep);
end;
//======================================================
 // Объединение двух путей файла (каталог + файл)
 // Возвращает объединенный путь через Delimiter
class function TCustomFS.PathCombineEx(const Path1: string;const Path2: string;const Delimiter:string): string; // Объединение двух путей c указанием разделителя
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
  Result:=Path1s+Delimiter+Path2s;
end;

end.


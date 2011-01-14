unit filefs;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,customfs,fileutil,msgstrings,Windows;

// Объект файловая система

type
  TFileFS=class (TCustomFS)
    public
      constructor Create;
      function IsAvalible(TryCreate:boolean):boolean; override;
      function GetName:string; override; // Возвращает имя ФС для отображения в логе
      function ChangeWorkingDir(const Directory: string): Boolean; override;
      function FindFirstFS(var F: TSearchRecFS): Integer; override;
      function FindNextFS(var F: TSearchRecFS): Integer; override;
      procedure FindCloseFS(var F: TSearchRecFS); override;
      // Файлы
      function FileExistsFS(const FileName: string): Boolean; override; // Короткое имя файла в тек директории
      function GetFileDateFS(const FileName: string):TDateTime; override; // Только имя файла, в тек каталоге
      function DeleteFileFS(const FileName: string): Boolean; override; // Короткое имя файла в тек директории
      // Каталоги
      function DirectoryExistsFS(const Dir: string;F: TSearchRecFS): Boolean;override; // Короткое имя каталога, относительно F
      function DeleteDirFS(const Dir: string): Boolean; override;
      function CreateDirFS(const Dir: string): Boolean; override;
      function ForceDirectoriesFS(Dir: string): Boolean; override;
      // Копирование файла
      function CopyFileFS(SourFile,DestFile:string):boolean; // Копирование файла пути полные
//      function CopyFile(CustomFS:TCustomFS;FileName:string):boolean; override;
      // Для TDelFiles
      function GetDelFileName:string; override;
      procedure SetDelFileName(DelFileName:string); override;
      procedure RemoveDelFileName(DelFileName:string);  override;
    private
      function ForceDir(DirName: string): boolean;
//      function SimpleCopyFile(SourFile,DestFile:string):boolean; // Копирование файла пути полные
      function FindDirFirst(var F: TSearchRecFS):integer;
      function FindDirNext(var F: TSearchRecFS):integer;
      function FindFileFirst(var F: TSearchRecFS):integer;
      function FindFileNext(var F: TSearchRecFS):integer;

//      IsClosed:boolean; // Поиск закрыт
//      IntSR:TSearchRec; // Для внутреннего поиска

  end;

implementation
//---------------------------------------------------------
// Возвращает имя файла хранящего сведения об удаленных файлах в каталоге
function TFileFS.GetDelFileName:string;
begin
Result:=WorkingDir+DirectorySeparator+DeletedFilesF;
//if Not SysUtils.FileExists(Result) then Result:='';
end;
//---------------------------------------------------------
// Записывает файл хранящий сведения об удаленных файлах в каталоге
procedure TFileFS.SetDelFileName(DelFileName:string);
begin

end;
//---------------------------------------------------------
// Удаляет файл хранящий сведения об удаленных файлах в каталоге
procedure TFileFS.RemoveDelFileName(DelFileName:string);
var
   SaveFileName:string;
begin
SaveFileName:=DelFileName; //WorkingDir+DirectorySeparator+DeletedFilesF;
if FileExists(SaveFileName) then
          begin
            // Удаляем файл
          try
            SysUtils.DeleteFile(SaveFileName);
          except
          end;
         end;
end;

//---------------------------------------------------------
// Возвращает имя ФС для отображения в логе
function TFileFS.GetName:string;
begin
Result:=RootDir;
end;
//---------------------------------------------------------
constructor TFileFS.Create;
begin
DirSep:=DirectorySeparator;
end;

//---------------------------------------------------------
// FS в порядке и доступна
// TryCreate - true - если не в порядке, попробвать привести в порядок (создать каталог RootDir)
function TFileFS.IsAvalible(TryCreate:boolean):boolean;
begin
if SysUtils.DirectoryExists(RootDir) then
     Result:=true
  else
     begin
     if TryCreate then
         begin
           Result:=ForceDir(RootDir);
           if  Result then LastError:= Format(rsLogDirCreated, [RootDir]);
         end
       else
          begin
          LastError := Format(rsLogDirNotFound, [RootDir]);
          Result:=false;
          end;
     end;
end;
//---------------------------------------------------------
// Простое копирование файла
function TFileFS.CopyFileFS(SourFile,DestFile:string):boolean;
var
   DestDir, str: string;
//  S, T:     TStream; // Копирование потоками
  res:      boolean;
//  restream,ssize: int64;
  err:      string;
  Attrs:    integer;
  AttrChange:boolean;
begin
 Result  := False;
  AttrChange:=false;
  Destdir := ExtractFileDir(destfile);
  if not SysUtils.DirectoryExists(Destdir) then
      begin
         if not ForceDir(Destdir) then
            exit;
      end;
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
// Копирование системной функцией копирования
try
      res :=CopyFile(PChar(SourFile), PChar(DestFile), False);
//      res := FileUtil.CopyFile(ansitoutf8(SourFile),ansitoutf8(DestFile),true);
    except
      On E: Exception do
      begin
        err := ansitoutf8(E.Message);
        str := Format(rsLogFileCopiedErr, [ansitoutf8(SourFile), err]);
        LastError:=str;
      end;
    end;

    //if CopyFile(PSorFile2,PDestFile2,false) then
    if res then
    begin
      Result := True;
     // if NTFSCopy then CopyNTFSPerm(sorfile, destfile);
      str := Format(rsLogFileCopied, [ansitoutf8(SourFile)]);
    end
    else
    begin
      str := ansitoutf8(SysErrorMessage(GetLastOSError));
      str := Format(rsLogFileCopiedErr,[ansitoutf8(SourFile), str]);
    end;

    LastError:=str;
try
if AttrChange then
       begin
//       Attrs := FileGetAttr(SourFile);
       FileSetAttr(destfile, Attrs); // Возвращаем атрибуты на место, берем из источника
       end;
finally
end;
end;

//---------------------------------------------------------
// Смена текущей папки
function TFileFS.ChangeWorkingDir(const Directory: string): Boolean;
begin
WorkingDir:=Directory;
Result:=SysUtils.DirectoryExists(Directory);
end;

//---------------------------------------------------------
// Начало поиска файла

function TFileFS.FindFirstFS(var F: TSearchRecFS): Integer;
var
//  FileAttrs: integer;
  Path2:string;
//  res:boolean;
begin
Path2:=WorkingDir;
F.Directory:=Path2;
F.CurIndex:=0;
F.IsDir:=false;
//F.IsClosed:=true;
Result:=FindFileFirst(F);
if Result<>0 then // Файл не найден
   begin
   F.IsDir:=true;
   Result:=FindDirFirst(F); // Ищем каталог
   end;
end;
{
  FileAttrs :=faAnyFile; //faDirectory + faReadOnly + faHidden + faSysFile + faArchive+faAnyFile;
  if Path='' then
     Path2:=WorkingDir
    else
     Path2:=Path;
  Res:=SysUtils.FindFirst(Path2+DirectorySeparator+'*', FileAttrs,F.sr);
  F.Directory:=Path2;
  F.CurIndex:=0;

  while res=0 do
     begin
       if (F.sr.Attr and faDirectory) <> 0 then // Это директория
            res:=SysUtils.FindNext(F.sr);
     end;


  if Result=0 then
      if (F.sr.Attr and faDirectory) <> 0 then // Это директория
            SysUtils.FindNext(F.sr);

            F.IsDir:=true
          else
            F.IsDir:=false;
end;
}
//---------------------------------------------------------------
function TFileFS.FindNextFS(var F: TSearchRecFS): Integer;
begin
if Not F.IsDir then // Ищем файлы
   begin
    Result:=FindFileNext(F);
    if Result<>0 then // Файлы кончились
       begin
       F.IsDir:=true;
       Result:=FindDirFirst(F);
       end;
   end
 else   // Ищем каталоги
   begin
   Result:=FindDirNext(F);
   end;
end;
//---------------------------------------------------------------
procedure TFileFS.FindCloseFS(var F: TSearchRecFS);
begin
if Not F.IsClosed then SysUtils.FindClose(F.sr);
end;
//---------------------------------------------------------------
// Найти файл
//
function TFileFS.FindFileFirst(var F: TSearchRecFS):integer;
//var
//  IsFound:boolean;
begin
//IsFound:=false;
Result:=SysUtils.FindFirst(F.Directory+DirectorySeparator+'*',faAnyFile,F.sr); //+faReadOnly+faHidden+faSysFile+faDirectory+faArchive
if Result<>0 then // ничего не найдено
     begin
     F.IsClosed:=true;
//     F.IsDir:=true;
     exit
     end;
//F.IsClosed:=false;
 // Перебираем пока не найдем файл
 repeat
    begin
    F.IsClosed:=false;
      if (F.sr.Attr and faDirectory) = 0 then // Это файл
            begin
                 if (F.sr.Name<>'.') and (F.sr.Name<>'..') then // Точки на faDirectory не проверяются!
                      begin
                      Result:=0;
                      exit;
                      end;
            end;
    end;
  until SysUtils.FindNext(F.sr)<>0;
// Здесь только каталоги
SysUtils.FindClose (F.sr);
F.IsClosed:=true;
//F.IsClosed:=true;
//F.IsDir:=true;
Result:=-1;
end;
//---------------------------------------------------------------
// Продолжить поиск файла
function TFileFS.FindFileNext(var F: TSearchRecFS):integer;
begin
Result:=SysUtils.FindNext(F.sr);
if Result<>0 then // ничего не найдено
     begin
//     F.IsDir:=true;
     SysUtils.FindClose (F.sr);
     F.IsClosed:=true;
     exit
     end;
// Перебираем пока не найдем файл
 repeat
    begin
      if (F.sr.Attr and faDirectory) = 0 then // Это файл
            begin
                 if (F.sr.Name<>'.') and (F.sr.Name<>'..') then // Точки на faDirectory не проверяются!
                      begin
                      Result:=0;
                      exit;
                      end;
            end;
    end;
  until SysUtils.FindNext(F.sr)<>0;
// Здесь только каталоги
SysUtils.FindClose (F.sr);
F.IsClosed:=true;
//F.IsDir:=true;
Result:=-1;

end;
//---------------------------------------------------------------
// Найти каталог First
function TFileFS.FindDirFirst(var F: TSearchRecFS):integer;
//var
//  IsFound:boolean;
begin
//IsFound:=false;
Result:=SysUtils.FindFirst(F.Directory+DirectorySeparator+'*',faAnyFile,F.sr);//+faReadOnly+faHidden+faSysFile+faDirectory+faArchive
if Result<>0 then // ничего не найдено
     begin
     F.IsClosed:=true;
     exit;
     end;
// Перебираем пока не найдем каталог
 repeat
    begin
      F.IsClosed:=false;
      if (F.sr.Attr and faDirectory) <> 0 then // Это каталог
            begin
                 if (F.sr.Name<>'.') and (F.sr.Name<>'..') then // Точки на faDirectory не проверяются!
                      begin
                      Result:=0;
                      exit;
                      end;
            end;
    end;
  until SysUtils.FindNext(F.sr)<>0;
// Здесь только файлы
SysUtils.FindClose (F.sr);
F.IsClosed:=true;
Result:=-1;


end;
//---------------------------------------------------------------
// Продолжить поиск каталога
function TFileFS.FindDirNext(var F: TSearchRecFS):integer;
begin
Result:=SysUtils.FindNext(F.sr);
 if Result<>0 then // ничего не найдено
     begin
     SysUtils.FindClose (F.sr);
     F.IsClosed:=true;
     exit;
     end;
// Перебираем пока не найдем каталог
 repeat
    begin
      if (F.sr.Attr and faDirectory) <> 0 then // Это каталог
            begin
                 if (F.sr.Name<>'.') and (F.sr.Name<>'..') then // Точки на faDirectory не проверяются!
                      begin
                      Result:=0;
                      exit;
                      end;
            end;
    end;
  until SysUtils.FindNext(F.sr)<>0;
// Здесь только файлы
SysUtils.FindClose (F.sr);
Result:=-1;
F.IsClosed:=true;
end;
//---------------------------------------------------------------
// Существует ли файл. Короткое имя в текущей директории
function TFileFS.FileExistsFS(const FileName: string): Boolean;
begin
Result:=SysUtils.FileExists(PathCombine(WorkingDir,FileName));
end;
//---------------------------------------------------------------
// Получить дату файла
// Имя файла короткое, в текущей директории
function TFileFS.GetFileDateFS(const FileName: string):TDateTime;
var
 aDate:integer;
begin
aDate := FileAge(PathCombine(WorkingDir,FileName));
    if aDate = -1 then // Ошибка чтения даты
    begin
      Result := 0;
      Exit;
    end;
Result := FileDateToDateTime(aDate);
end;
//---------------------------------------------------------------
// Удалить файл, имя файла короткое, в текущей директории
function TFileFS.DeleteFileFS(const FileName: string): Boolean;
var
 namef:string;
 str:string;
 Attrs:integer;
 res:boolean;
begin
namef:=PathCombine(WorkingDir,FileName);
//Result:=SysUtils.DeleteFile(ToDel);


  // Если есть атрибут только для чтения, то его убираем
  Attrs := FileGetAttr(namef);
  if (Attrs and faReadOnly <> 0) or (Attrs and faSysFile <> 0) or (Attrs and faHidden <> 0) then
    try
      FileSetAttr(namef, 0);
    except
    end;

  // Удаляем файл
  try
    res := SysUtils.DeleteFile(namef);
  except
    On E: Exception do
    begin
      Result := false;
      str    := ansitoutf8(E.Message);
      str    := Format(rsLogDelFileErr, [ansitoutf8(namef), str]);
      LastError:=str;
    end;
  end;

  if res then
  begin
//    Result := True;
    str    := Format(rsLogDelFile, [ansitoutf8(namef)]);
    LastError:=str;
  end
  else
  begin
    Result := false;
    str    := ansitoutf8(SysErrorMessage(GetLastOSError));
    str    := Format(rsLogDelFileErr, [ansitoutf8(namef), str]);
    LastError:=str;
  end;
end;
//---------------------------------------------------------------
function TFileFS.DirectoryExistsFS(const Dir: string;F: TSearchRecFS): Boolean;
var
  tmpDir:string;
begin
tmpDir:=PathCombine(F.Directory,Dir);
Result:=SysUtils.DirectoryExists(tmpDir);
end;

//---------------------------------------------------------------
function TFileFS.DeleteDirFS(const Dir: string): Boolean;
begin
Result:=SysUtils.RemoveDir(Dir);
end;
//---------------------------------------------------------------
function TFileFS.CreateDirFS(const Dir: string): Boolean;
begin
Result:=SysUtils.CreateDir(Dir);
end;

//---------------------------------------------------------------
function TFileFS.ForceDirectoriesFS(Dir: string): Boolean;
begin
Result:=SysUtils.ForceDirectories(Dir);
end;
//======================================================================
 // Создание каталога по полному пути
function TFileFS.ForceDir(DirName: string): boolean;
var
  str: string;
  res: boolean;
begin
  Result := True;
  if SysUtils.DirectoryExists(DirName) then
    exit;
  try
    res := ForceDirectories(DirName);
  except
    On E: Exception do
    begin
      Result := False;
      str    := E.Message;
      LastError    := Format(rsLogDirCreateErr, [ansitoutf8(DirName), str]);
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
    str    := SysUtils.SysErrorMessage(SysUtils.GetLastOSError);
    LastError    := Format(rsLogDirCreateErr, [ansitoutf8(DirName), str]);
  end;
end;

//---------------------------------------------------------------
//---------------------------------------------------------------
end.


unit filterprop;

{
Фильтрация источника

Включить:
Каталог
Файл
Маску

// В будущей версии
Файлы больше чем
Файлы меньше чем
Файлы старее чем
Файлы новее чем

Исключить
Тоже самое
}

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,XMLCfg,CustomFS;


//type
//  TFilterEntry = (Directory = 1, FileName = 2, MaskName = 3);

// Тип фильтра
type
  TFilterType = (ftInclude = 1, ftExclude = 2); // Включение, исключение


// Параметры фильтрации

{
Все каталоги и файлы задаются относительно источника
Направление слэшей всегда вправо /
}
type
   TFiltProp=class
   public
     constructor TFiltProp(FilterType:TFilterType;RootDir:string);
     function IsDirInRange(DirName:string):boolean; // Попадает ли каталог в фильтр
     procedure Clear; // Очистить
     function IsEmpty:boolean; // Фильтр пуст
     function GetType:TFilterType; // Возвращает тип фильтра
     procedure AddDir(DirName:string); // Добавить каталог, относительно источника
     procedure RemoveDir(DirName:string);
     procedure RemoveDir(Index:integer);
     procedure AddFile(FileName:string);
     procedure RemoveFile(FileName:string);
     procedure RemoveFile(Index:integer);
     procedure AddMask(MaskName:string);
     procedure RemoveMask(MaskName:string);
     procedure RemoveMask(Index:integer);
     procedure LoadFromFile(XMLConf:TXMLConfig;Section:string);
     procedure SaveToFile(XMLConf:TXMLConfig;Section:string);
   public

     //property Dirs:TStringList read GetDirs;
     //Dirs:TStringList;
     //Files:TStringList;
     //Masks:TStringList;
   private
     procedure RemoveByIndex(List:TStringList;Index:integer); // Удалить по индексу
     procedure RemoveByName(List:TStringList;EntryName:string); // Удалить по имени
     function GetEmpty:boolean; // Высчитывает _isEmpty, возвращает его значение


   private
     Dirs:TStringList;
     Files:TStringList;
     Masks:TStringList;
     _RootDir:string; // Корневой каталог для фильтра
     _isEmpty:boolean; // Кэшированное значение IsEmpty
     _isChanged:boolean; // Фильтр менялся, Если false то кэшированное значение верно
     _FilterType:TFilterType; // Тип фильтра
   end;





implementation
//------------------------------------------------------------------------------
// Попадает ли каталог в фильтр
function IsDirInRange(DirName:string):boolean;
var
 i:integer;
 fullPath,uDirName:string;
begin
// Перебираем все каталоги, ищем совпадения
uDirName:=TCustomFS.ToUnixSep(DirName);
for i:=1 to Dirs.Count do
 begin
 fullPath:=TCustomFS.PathCombine(_RootDir,Dirs[i]);
 Same;
 end;
end;

//------------------------------------------------------------------------------
constructor TFiltProp.TFiltProp(FilterType:TFilterType;RootDir:string);
begin
_isEmpty:=true;
_isChanged:=false;
_FilterType:=FilterType;
_RootDir:=TCustomFS.ToUnixSep(RootDir);
end;
//------------------------------------------------------------------------------
function TFiltProp.GetType:TFilterType; // Возвращает тип фильтра
begin
Result:=_FilterType;
end;

//------------------------------------------------------------------------------
// Фильтр пуст
function TFiltProp.IsEmpty:boolean;
begin
  if _isChanged=false then
     begin
     Result:=_isEmpty

     end
    else
     begin
     Result:=GetEmpty;
     end;
end;
//------------------------------------------------------------------------------
// Высчитывает _isEmpty, возвращает его значение
function TFiltProp.GetEmpty:boolean;
var
 i:integer;
begin
  i:=Dirs.Count+Files.Count+Masks.Count;
  if i=0 then
      _isEmpty:=true
    else
      _isEmpty:=false;
  Result:=_isEmpty;
  _isChanged:=false;
end;

//------------------------------------------------------------------------------
// Записать в файл
procedure TFiltProp.SaveToFile(XMLConf:TXMLConfig;Section:string);
var
  i:integer;
  sec,str:string;
begin
  // Запись каталогов
  XMLConf.SetValue(Section + 'Dirs/count/value',Dirs.Count);
  for i:=0 to Dirs.Count-1 do
  begin
   sec := Section + 'Dirs/Dir'+ IntToStr(i+1) + '/';
   XMLConf.SetValue(sec + 'value',Dirs[i]);
  end;
  // Запись файлов
  XMLConf.SetValue(Section + 'Files/count/value',Files.Count);
  for i:=0 to Files.Count-1 do
  begin
   sec := Section + 'Files/Dir'+ IntToStr(i+1) + '/';
   XMLConf.SetValue(sec + 'value',Files[i]);
  end;
  // Запись масок
  XMLConf.SetValue(Section + 'Masks/count/value',Masks.Count);
  for i:=0 to Masks.Count-1 do
  begin
   sec := Section + 'Masks'+ IntToStr(i+1) + '/';
   XMLConf.SetValue(sec + 'value',Masks[i]);
  end;

end;

//------------------------------------------------------------------------------
// Прочитать из файла
procedure TFiltProp.LoadFromFile(XMLConf:TXMLConfig;Section:string);
var
  i,cnt:integer;
  sec,str:string;
begin
  Clear;
  // Чтение каталогов
  cnt:=XMLConf.GetValue(Section + 'Dirs/count/value',0);
  for i:=0 to cnt-1 do
  begin
   sec := Section + 'Dirs/Dir'+ IntToStr(i+1) + '/';
   str:=XMLConf.GetValue(sec + 'value','');
   AddDir(str);
  end;
  // Чтение файлов
  cnt:=XMLConf.GetValue(Section + 'Files/count/value',0);
  for i:=0 to cnt-1 do
  begin
   sec := Section + 'Files/File'+ IntToStr(i+1) + '/';
   str:=XMLConf.GetValue(sec + 'value','');
   AddFile(str);
  end;
  // Чтение масок
  cnt:=XMLConf.GetValue(Section + 'Masks/count/value',0);
  for i:=0 to cnt-1 do
  begin
   sec := Section + 'Masks/Mask'+ IntToStr(i+1) + '/';
   str:=XMLConf.GetValue(sec + 'value','');
   AddMask(str);
  end;
_isChanged:=true;
end;

//------------------------------------------------------------------------------
// Очистить
procedure TFiltProp.Clear;
begin
Dirs.Clear;
Files.Clear;
Masks.Clear;
_isChanged:=false;
_isEmpty:=true;;
end;
//------------------------------------------------------------------------------
// Добавить каталог
procedure TFiltProp.AddDir(DirName:string);
var
 strtmp:string;
begin
  if DirName='' then exit;
  strtmp:=TCustomFS.ToUnixSep(DirName);
  Dirs.Add(strtmp);
  _isChanged:=true;
end;
//------------------------------------------------------------------------------
// Добавить файл
procedure TFiltProp.AddFile(FileName:string);
var
 strtmp:string;
begin
  if FileName='' then exit;
  strtmp:=TCustomFS.ToUnixSep(FileName);
  Files.Add(strtmp);
  _isChanged:=true;
end;
//------------------------------------------------------------------------------
// Добавить маску
procedure TFiltProp.AddMask(MaskName:string);
begin
  if MaskName='' then exit;
  Masks.Add(MaskName);
  _isChanged:=true;
end;
//------------------------------------------------------------------------------
// Удалить каталог по имени
procedure TFiltProp.RemoveDir(DirName:string);
begin
RemoveByName(Dirs,DirName);
end;
//------------------------------------------------------------------------------
// Удалить файл по имени
procedure TFiltProp.RemoveFile(FileName:string);
begin
RemoveByName(Files,FileName);
end;
//------------------------------------------------------------------------------
// Удалить маску по имени
procedure TFiltProp.RemoveMask(MaskName:string);
begin
RemoveByName(Masks,MaskName);
end;
//------------------------------------------------------------------------------
// Удалить каталог по индексу
procedure TFiltProp.RemoveDir(Index:integer);
begin
  RemoveByIndex(Dirs,Index);
end;
//------------------------------------------------------------------------------
// Удалить файл по индексу
procedure TFiltProp.RemoveFile(Index:integer);
begin
RemoveByIndex(Files,Index);
end;
//------------------------------------------------------------------------------
// Удалить маску по индексу
procedure TFiltProp.RemoveMask(Index:integer);
begin
RemoveByIndex(Masks,Index);
end;
//------------------------------------------------------------------------------
// Удалить по имени
procedure TFiltProp.RemoveByName(List:TStringList;EntryName:string);
var
 strtmp:string;
 Index:integer;
begin
strtmp:=TCustomFS.ToUnixSep(EntryName);
List.Find(strtmp,Index);
if Index>-1 then RemoveByIndex(List,Index);
end;
//------------------------------------------------------------------------------
// Удалить по индексу
procedure TFiltProp.RemoveByIndex(List:TStringList;Index:integer);
begin
  if Index>List.Count then exit;
  List.Delete(Index);
  _isChanged:=true;
end;
end.


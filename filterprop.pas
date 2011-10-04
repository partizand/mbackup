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

// Параметры фильтрации

{
Все каталоги и файлы задаются относительно источника
Направление слэшей всегда вправо /
}
type
   TFiltProp=class
   public
     procedure Clear; // Очистить
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
   public

     Dirs:TStringList;
     Files:TStringList;
     Masks:TStringList;
   private
     procedure RemoveByIndex(List:TStringList;Index:integer); // Удалить по индексу
     procedure RemoveByName(List:TStringList;EntryName:integer); // Удалить по имени
   end;





implementation

//------------------------------------------------------------------------------
procedure TFiltProp.LoadFromFile(XMLConf:TXMLConfig;Section:string);
begin
  Clear;
  Tasks[i].SrcFSParam.RootDir:=XMLConf.GetValue(Section + 'SrcFSParam/RootDir/value','');
end;

//------------------------------------------------------------------------------
// Очистить
procedure TFiltProp.Clear;
begin
Dirs.Clear;
Files.Clear;
Masks.Clear;
end;
//------------------------------------------------------------------------------
// Добавить каталог
procedure TFiltProp.AddDir(DirName:string);
var
 strtmp:string;
begin
  strtmp:=TCustomFS.ToUnixSep(DirName);
  Dirs.Add(strtmp);
end;
//------------------------------------------------------------------------------
// Добавить файл
procedure TFiltProp.AddFile(FileName:string);
var
 strtmp:string;
begin
  strtmp:=TCustomFS.ToUnixSep(FileName);
  Files.Add(strtmp);
end;
//------------------------------------------------------------------------------
// Добавить маску
procedure TFiltProp.AddMask(MaskName:string);
begin
  Masks.Add(MaskName);
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
procedure TFiltProp.RemoveByName(List:TStringList;EntryName:integer);
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
end;
end.


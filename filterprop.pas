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
     procedure SaveToFile(XMLConf:TXMLConfig;Section:string);
   public

     Dirs:TStringList;
     Files:TStringList;
     Masks:TStringList;
   private
     procedure RemoveByIndex(List:TStringList;Index:integer); // Удалить по индексу
     procedure RemoveByName(List:TStringList;EntryName:string); // Удалить по имени
   end;





implementation

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
  if DirName='' then exit;
  strtmp:=TCustomFS.ToUnixSep(DirName);
  Dirs.Add(strtmp);
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
end;
//------------------------------------------------------------------------------
// Добавить маску
procedure TFiltProp.AddMask(MaskName:string);
begin
  if MaskName='' then exit;
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
end;
end.


unit unitfunc;
// Общие функции использующиеся в проекте

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils; 

function ShortFileNam(FileName: string): string;
function FullFileNam(FileName: string): string;

implementation

 //======================================================
 // Получение короткого имени файла
 // удалением каталога запуска проги
// если не каталог запуска то длинное имя сохраняется
function ShortFileNam(FileName: string): string;
var
  FileDir: string;
  RunDir:  string;
  // test:string;
begin
  Filedir := ExtractFileDir(Filename);
  RunDir  := ansitoutf8(ExtractFileDir(ParamStr(0)));
//  if utf8toansi(UpperCase(Filedir)) = UpperCase(RunDir) then
  if UpperCase(Filedir) = UpperCase(RunDir) then

    Result := ExtractFileName(FileName)
  else
    Result := FileName;
  //Result:=test;
end;
//======================================================
// Получение полного имени файла добавлением каталога запуска
function FullFileNam(FileName: string): string;
var
  FileDir: string;
  RunDir:  string;
begin
  Filedir := ExtractFileDir(Filename);
  RunDir  := ansitoutf8(ExtractFileDir(ParamStr(0)));
  if Filedir = '' then
    Result := RunDir + DirectorySeparator+ (FileName)
  else
    Result :=FileName;
end;

end.


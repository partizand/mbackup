unit unitfunc;
// Общие функции использующиеся в проекте

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,dcprijndael,dcpsha1;

const
  KeyStrTask='a2JH380oUtkI67B345d3OF2yeKMXHfD8q670z26007tJcdg1oy'; // Ключ шифрования в задании

function ShortFileNam(FileName: string): string;
function FullFileNam(FileName: string): string;
function EncryptString(Str:string;KeyStr:string):string; // Шифрование строки
function DecryptString(Str:string;KeyStr:string):string; // Расшифрование строки

implementation

//======================================================
// Шифрование строки
function EncryptString(Str:string;KeyStr:string):string;
var
   Cipher: TDCP_rijndael;
begin
  Cipher:= TDCP_rijndael.Create(nil);
  Cipher.InitStr(KeyStr,TDCP_sha1);         // initialize the cipher with a hash of the passphrase
  Result:=Cipher.EncryptString(Str);
  Cipher.Burn;
  Cipher.Free;
end;
//======================================================
// Расшифрование строки
function DecryptString(Str:string;KeyStr:string):string;
var
   Cipher: TDCP_rijndael;
begin
  Cipher:= TDCP_rijndael.Create(nil);
  Cipher.InitStr(KeyStr,TDCP_sha1);         // initialize the cipher with a hash of the passphrase
  Result:=Cipher.DecryptString(Str);
  Cipher.Burn;
  Cipher.Free;
end;

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


unit delfiles;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,XMLCfg;

  const
   DeletedFilesF='deleted$.xml'; // Файл для хранения сведений об удаленных файлах

// Класс хранения сведений об удаленных файлах
// Массив: Имя файла, дата удаления из источника
type
 TDeletedFiles=class
   constructor Create(RootDirName:string);
   destructor Destroy;
   Count:integer; // Кол-во файлов
   DirName:string; // Каталог, где все происходит
   function GetIndex(FileName:string):integer;
   function GetName(Index:integer):string;
   function GetDate(Index:integer):TDateTime;
   function Add(FileName:string):integer;
   procedure Delete(Index:integer);
   procedure SaveToFile;

 private
   procedure LoadFromFile;
   NameList:TStringList; // Список имен файлов
   DateList:TStringList; // Список дат файлов
  // Delimiter:string; // Разделитель целой и дробной части в float
//   DateArray:array[0..100] of TDateTime; // если файлов не больше 100, используем этот массив
 end;

implementation

// Функции класса TDeletedFiles
 //=====================================================
 // Конструктор
constructor TDeletedFiles.Create(RootDirName:string);
//var
begin
  inherited Create;
  Count  := 0;
  NameList := TStringList.Create;
  DateList := TStringList.Create;
  DirName:=RootDirName;
  LoadFromFile;
end;

 // Деструктор
destructor TDeletedFiles.Destroy;
begin
NameList.Destroy;
DateList.Destroy;
inherited Destroy;
end;

// Возвращает индекс файла по его имени
// Если файла нет возвращается -1
function TDeletedFiles.GetIndex(FileName:string):integer;
begin
Result:=NameList.IndexOf(FileName);
end;
// Возвращает имя файла по индексу
function TDeletedFiles.GetName(Index:integer):string;
begin
if Count>Index then
    Result:=NameList[Index]
   else
     Result:='';
end;
// Возвращает дату файла по индексу
function TDeletedFiles.GetDate(Index:integer):TDateTime;
var
 DateFormat:TFormatSettings;
begin
if Count>Index then
    begin

//     GetLocaleFormatSettings(0,DateFormat);
     DateFormat.DateSeparator:='.';
     DateFormat.DecimalSeparator:='.';
//     DateFormat.LongDateFormat:='dd.MM.yyyy';
//     DateFormat.ShortDateFormat:='dd.MM.yyyy';
//     Result:=StrToDateTime(DateList[Index],DateFormat);
     Result:=StrToFloat(DateList[Index],DateFormat)
     end


   else
     Result:=0;
end;
// Добавление данных о файле
function TDeletedFiles.Add(FileName:string):integer;
var
 strDate:string;
 DateFormat:TFormatSettings;
begin
Result:=-1;
if GetIndex(FileName)>-1 then exit;
NameList.Add(FileName);
DateFormat.DateSeparator:='.';
DateFormat.DecimalSeparator:='.';
strDate:= FloatToStr(Now,DateFormat);
DateList.Add(strDate);
Count:=Count+1;
Result:=Count;
end;
// Удаление данных о файле
procedure TDeletedFiles.Delete(Index:integer);
begin
NameList.Delete(Index);
DateList.Delete(Index);
Dec(Count);
end;
// Запись в файл
procedure TDeletedFiles.SaveToFile;
var
  i: integer;
  xmldoc: TXMLConfig;
  sec,SaveFileName: string;
//  Attr:integer;
begin
SaveFileName:=DirName+DirectorySeparator+DeletedFilesF;
if Count>0 then
  begin
//  if FileExists(SaveFileName) then // Сбрасываем атрибут скрытый
//    begin
//    FileSetAttr(SaveFileName, 0);
//    end;
  if Not DirectoryExists(DirName) then exit;
  xmldoc := TXMLConfig.Create(nil);
  xmldoc.StartEmpty := True;
  xmldoc.Filename := SaveFileName; //'probcfg.xml';
  xmldoc.RootName := 'mBackup';
  // Версия программы
//  xmldoc.SetValue('version/value', versionas);
  // количество заданий
  xmldoc.SetValue('deleted/count/value', Count);
  for i := 0 to Count-1 do
  begin
    // Имя секции с заданием
    sec := 'Deleted/File' + IntToStr(i) + '/';

    xmldoc.SetValue(sec + 'name/value', NameList[i]); // Имя файла
    xmldoc.SetValue(sec + 'txtdate/value', DateList[i]); // Текстовая дата файла
   // if i<100 then
   //    xmldoc.SetValue(sec + 'date/value', DateArray[i]); // Нормальная дата файла

  end;
  xmldoc.Flush;
  xmldoc.Destroy;
 // Attr:=faHidden;
  FileSetAttr(SaveFileName, faHidden);


 end
  else
    begin
    if FileExists(SaveFileName) then
          begin
            // Удаляем файл
          try
            SysUtils.DeleteFile(SaveFileName);
          except
          end;
         end;

    end;

end;
// Чтение из файла
procedure TDeletedFiles.LoadFromFile;
var
  i: integer;
  xmldoc:  TXMLConfig;
  sec,SaveFileName:     string;
  //strDate: string;
begin
  SaveFileName:=DirName+DirectorySeparator+DeletedFilesF;
     NameList.Clear;
    DateList.Clear;
    Count:=0;
  if not FileExists(SaveFileName) then
    begin
    exit;
    end;
  FileSetAttr(SaveFileName, 0);
  xmldoc := TXMLConfig.Create(nil);
  //xmldoc := TXMLConfig.Create(SaveFileName);

  xmldoc.StartEmpty := False; //false;
  xmldoc.RootName   := 'mBackup';
  xmldoc. flush;
  xmldoc.Filename := SaveFileName;

  // количество заданий
  Count := xmldoc.GetValue('deleted/count/value', 0);
  if Count = 0 then exit;

  for i := 0 to Count-1 do
  begin
    sec := 'Deleted/File' + IntToStr(i) + '/';
    NameList.Add(xmldoc.GetValue(sec + 'name/value', ''));
    DateList.Add(xmldoc.GetValue(sec + 'txtdate/value', ''));
 //   if i<100 then DateArray[i]:= xmldoc.GetValue(sec + 'date/value', '');
  end;
  xmldoc.Destroy;
end;


// конец функций класса TDeletedFiles
//==============================================================

end.


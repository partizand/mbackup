unit logunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils; 

const
TempLogName = 'log.txt';

type
  TLog=class
  public
     logfile:  string; // Имя лог файла короткое
     loglimit: integer; // ограничение лог файла в килобайтах, 0-без ограничений
     FormatToDate:string; // Формат представления даты времени в лог файле
     TempLogFileName:string; // Имя временного лог файла
     TempLogEnabled:boolean; // Вести лог дополнительно во временный лог файл
     Enabled:boolean; // Вести ли лог вообще
     constructor Create;
     procedure LogMessage(logmes: string);
     procedure LogMessage(MesStrings: TStringList);
  private
     procedure WriteFileStr(filenam, str: string);
  end;

implementation

constructor TLog.Create;
begin
// Задаем значения по умолчанию
loglimit:=0;
TempLogEnabled:=false;
FormatToDate:='dd.mm.yy hh:mm:ss ';
TempLogFileName:=TempLogName;
Enabled:=true;
end;

//==================================================
 // Запись строки в logfile
procedure TLog.LogMessage(logmes: string);
var
  dtime, fulLog, TempLogNameful: string;

begin
  if Enabled then
     begin

          fulLog := logfile;
          if ExtractFileDir(fulLog)='' then
             fulLog:=ExtractFileDir(ParamStr(0))+DirectorySeparator+fulLog;
          TempLogNameful := TempLogFileName;
          if ExtractFileDir(TempLogNameful)='' then
             TempLogNameful:=ExtractFileDir(ParamStr(0))+DirectorySeparator+TempLogNameful;

          if logmes = '-' then
          begin
            WriteFileStr(fulLog, '-----------------------------------------');
            DeleteFile(utf8toansi(TempLogNameful)); // Очистка лог файла

          end
          else
          begin
            dtime := FormatDateTime(FormatToDate, now);
            dtime := Utf8ToAnsi(dtime + logmes);
            WriteFileStr(fulLog, dtime);
            if TempLogEnabled then WriteFileStr(TempLogNameful, dtime);
        //    OnProgress(nil, MsgCopy, logmes, 0);
            // сообщение для обработки потоком
          end;

     end;
end;
 //=============================================
 // Запись строки str в файл с именем filenamfhandle
procedure TLog.WriteFileStr(filenam, str: string);
var
  hfile, i: integer;
  filelen:  longint;
  buf:      char;
  baklognam: string;
begin
  try
//  filenam:=utf8toansi(filenam);
  if SysUtils.FileExists(filenam) then
  begin
    hfile := FileOpen(filenam, fmOpenWrite);
  end
  else
    hfile := FileCreate(filenam);
  FileSeek(hfile, 0, 2);
  for i := 1 to length(str) do
  begin
    buf := str[i];
    FileWrite(hfile, buf, 1);
  end;
  buf := Chr($0d);
  FileWrite(hfile, buf, 1);
  buf := Chr($0a);
  FileWrite(hfile, buf, 1);
  filelen := FileSeek(hfile, 0, 2);
  FileClose(hfile);
  //if str='-----------------------------------------' then CheckFileSize(filenam);

  if (loglimit > 0) and (filelen > loglimit * 1024) and
    (str = '-----------------------------------------') then
    // файл лога превышает лимит
  begin
    //         FileClose(hfile);
    //         baklognam:=ExtractFileDir(filenam)+'\autosave1.log'; // Имя файла
    baklognam := filenam + '.bak'; // Имя файла
    DeleteFile(baklognam);
    RenameFile(filenam, baklognam);
    // hfile:=FileCreate(filenam);
  end;
  finally
  end;
end;

 //==================================================
 // Запись строк в logfile
procedure TLog.LogMessage(MesStrings: TStringList);
var
// str,fulLog,TempLogNameful:string;
 i:integer;
begin
if Enabled then
      begin
//      fulLog := FullFileNam(Settings.logfile);
//      TempLogNameful := FullFileNam(TempLogName);
      for i:=0 to  MesStrings.Count-1 do
       begin
          //str := Utf8ToAnsi(MesStrings[i]);
          LogMessage(MesStrings[i]);

//          str := DosToWin(MesStrings[i]);
//          WriteFileStr(fulLog, str);
//          WriteFileStr(TempLogNameful, str);


       end;
      end;
end;

end.


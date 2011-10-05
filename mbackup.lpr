program mbackup;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp, TaskUnit, Windows, MsgStrings,
filterprop, filter//,ShellApi
  { you can add units after this };


type

  { TASCons }

  TASCons = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
    procedure UsageInfo;
    procedure PrintStartInfo;
    Function WinToDos(Const S: String) : String;
    // Событие
    procedure OnProgress(Sender: TObject; ProgrType: ProgressType; Filename: String; FileSize: Int64);
    //--------------- переменные
   public
    Backup:TBackup;
  end;

{ TASCons }

procedure TASCons.DoRun;
var
//  ErrorMsg: String;
  estr:Boolean; // Есть задания на запуск
  k:integer;
  IsProfile:boolean; // Запускается профиль
begin
//Backup.ReadIni;
//CL:=LoadLangIni(Backup.LangFile);
estr:=Backup.ReadArgv(IsProfile);

PrintStartInfo;
//AConsole.UsageInfo;
if estr  then // автозапуск заданий
    begin
    Backup.InCmdMode:=true;
    if Backup.AlertStart then Backup.SendAlert(rsStarted);
        for k:=0 to Backup.Count-1 do
           begin
           // Задание включено                      (и на запуск при запуске)
           if Backup.Tasks[k].Enabled  then //and Backup.Tasks[k].Rasp.AtStart
              begin
              Backup.RunTask(k,false);
              end;
           end;
         if IsProfile then Backup.SaveToFile(''); // Результаты работы
    if Backup.AlertFinish then Backup.SendAlert(rsFinished);
    end // end if r
  else
    begin
    UsageInfo;
    end;





  // parse parameters
{  if HasOption('h','help') then begin
    WriteHelp;
    Halt;
  end;
 }
  { add your program here }

  // stop program loop
  Terminate;
end;

constructor TASCons.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
  Backup:=TBackup.Create;
  Backup.OnProgress:=@OnProgress;
end;

destructor TASCons.Destroy;
begin
  Backup.Destroy;
  inherited Destroy;
end;

procedure TASCons.WriteHelp;
begin
  { add your help code here }
  writeln('Usage: ',ExeName,' -h');
end;
//===========================================================
// Функция вызываемая при наступлении события при копировании
procedure TASCons.OnProgress(Sender: TObject; ProgrType: ProgressType; Filename: String; FileSize: Int64);
var
   str:string;
begin
//writeln('On progress');
    Case ProgrType Of
            MsgCopy:
            Begin
                 str:=Utf8toAnsi(Filename);
                 str:=WinToDos(str);
                 writeln(str);
            End;
     end;

end;
//=============================================================
// Вывод начальной информации при запуске программы
procedure TASCons.PrintStartInfo;
begin
writeln('mBackup ver '+versionAs);
writeln('Utility for copy/sync/arh directories');
writeln('');
end;
//==============================================================
Function TASCons.WinToDos(Const S: String) : String;
 { Конвертирует строку из кодировки Windows в DOS кодировку }
begin
 SetLength(Result,Length(S));
 if  Length(S) <> 0  then
   CharToOem(pChar(S),pChar(Result));
end;
//==============================================================
{ Вывод справки }
procedure TASCons.UsageInfo;
begin
writeln('Usage: mbackup -r [-p profile_name] [-log logfile] [-as] [-af]');
writeln(' or');
writeln('mbackup <command> <Source> <Destination> [-recurse] [-log logfile] [-as] [-af]');
writeln('-r :Start enabled tasks in profile');
writeln('-p profile_name: Profile to start, else takes from autosave.ini');
writeln('<command>');
writeln('copy       Simple copy dirs');
writeln('mirr       Copy source to destination, delete other files from destination (Mirror)');
writeln('sync       Syncs sourse and destination');
writeln('');
writeln('<Source>: Path to source directory or ftp server');
writeln('<Destination>: Path to destination directory or ftp server');
writeln(' ftp server string: ftp[s]://[Username:password@]Server[:port][/Directory]');
writeln('                     default port: 21, default Username: anonymous');
writeln('                     Passive mode always enabled');
writeln('-recurse: Work with paths recurse. Without this switch not recurse');
writeln('-log log_file :Logfile name, if not set then takes from mbackup.ini settings');
writeln('-as: Send email alert about start program (alert start)');
writeln('-af: Send email alert about finish program (alert finished)');
end;



var
  Application: TASCons;
begin
  Application:=TASCons.Create(nil);
  Application.Run;
  Application.Free;
end.




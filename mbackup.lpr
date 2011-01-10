program mbackup;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp,{iniLangC,}TaskUnit,Windows//,ShellApi
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
        for k:=1 to Backup.Count do
           begin
           // Задание включено                      (и на запуск при запуске)
           if Backup.Tasks[k].Enabled  then //and Backup.Tasks[k].Rasp.AtStart
              begin
              Backup.RunTask(k,false);
              end;
           end;
         if IsProfile then Backup.SaveToFile(''); // Результаты работы
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
writeln('Usage: mbackup -r [-p profile_name] [-log logfile] [-alert]');
writeln(' or');
writeln('mbackup <command> -source source_path -dest dest_path [-recurse] [-log logfile] [-alert]');
writeln('-r :Start enabled tasks in profile');
writeln('-p profile_name: Profile to start, else takes from autosave.ini');
writeln('<command>');
writeln('copy       Simple copy dirs');
writeln('mirr       Copy source to destination, delete other files from destination (Mirror)');
writeln('sync       Syncs sourse and destination');
writeln('');
writeln('-source source_path: Path to source');
writeln('-dest dest_path: Path to destination');
writeln('-recurse: Work with paths recurse');
writeln('-log log_file :Logfile name, if not set then takes from mbackup.ini settings');
writeln('-alert: Send email alert about start program');
end;



var
  Application: TASCons;
begin
  Application:=TASCons.Create(nil);
  Application.Title:='mBackup';
  Application.Run;
  Application.Free;
end.




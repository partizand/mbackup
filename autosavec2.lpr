program autosavec;

// Консольная версия Autosave

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
//    Interfaces, // this includes the LCL widgetset
  Classes,
  { add your units here }
  TaskUnit,inilangC;

// класс консольного AutoSave, сделан для сопоставления события
// OnProgress, по другому не получилось
type
 TAConsole=class
 public
 TaskCl:TTaskCl;
 procedure OnProgress(Sender: TObject; ProgrType: ProgressType; Filename: ShortString; FileSize: Int64);
 procedure PrintStartInfo;
 procedure UsageInfo;
 constructor Create;
end;
//===========================================================
// Функция вызываемая при наступлении события при копировании
procedure TAConsole.OnProgress(Sender: TObject; ProgrType: ProgressType; Filename: ShortString; FileSize: Int64);
begin
//writeln('On progress');
    Case ProgrType Of
            MsgCopy:
            Begin
                 writeln(Filename);
            End;
     end;

end;
//=============================================================
// Вывод начальной информации при запуске программы
procedure TAConsole.PrintStartInfo;
begin
writeln('AutoSave ver '+versionAs);
writeln('Utility for copy/sync directories');
writeln('');
end;
//==============================================================
procedure TAConsole.UsageInfo;
begin
writeln('Usage: autosavec -r [-p profile_name] [-log logfile]');
writeln(' or');
writeln('autosavec <command> -source source_path -dest dest_path [-recurse] [-log logfile]');
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
writeln('-log log_file :Logfile name, if not set then takes from autosave.ini settings');

end;

constructor TAConsole.Create;
begin
  TaskCl:=TTaskCl.Create;
  TaskCl.OnProgress:=@OnProgress;
//  FreeOnTerminate := True;
//  inherited Create(False);
end;


var
// TaskCl:TTaskCl;
 estr:Boolean; // Есть задания на запуск
 AConsole:TAConsole;
 k:integer;
begin
AConsole:=TAConsole.Create;

AConsole.TaskCl.ReadIni;
CL:=LoadLangIni(AConsole.TaskCl.LangFile);
estr:=AConsole.TaskCl.ReadArgv;

AConsole.PrintStartInfo;
//AConsole.UsageInfo;
if estr  then // автозапуск заданий
    begin
        for k:=1 to AConsole.TaskCl.Count do
           begin
           // Задание включено                      (и на запуск при запуске)
           if AConsole.TaskCl.Tasks[k].Enabled  then //and TaskCl.Tasks[k].Rasp.AtStart
              begin
              AConsole.TaskCl.RunTask(k,false);
              end;
           end;
    end // end if r
  else
    begin
    AConsole.UsageInfo;
    end;
// end;
end.


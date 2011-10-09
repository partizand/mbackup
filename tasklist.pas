// Список параметров заданий

unit tasklist;

{$mode objfpc}{$H+}




interface

uses
  Classes, SysUtils,XMLCfg,task,MsgStrings;

const
  MaxTasks = 100; // Макс количество заданий
  MaxPChar = 250;
// Макс длина строки запуска внешнего приложения

// Список заданий как объектов
type
  TTaskList=class
   private
     FTasks:TList; // Список ссылок на объекты заданий

//     FCount:integer; // Счетчик
     function GetItem (Index:Integer):TTask;
     function GetCount:Integer;
  public
     constructor Create;
     destructor Destroy; override;
     procedure LoadFromFile(XMLDoc:TXMLConfig;Section:string);
     procedure SaveToFile(XMLDoc:TXMLConfig;Section:string);
     // Очистить список заданий
     procedure Clear;
     // Удалить задание
     procedure Delete(Index:integer);
     // Добавить задание
     function Add(Task:TTask=nil):integer;
     // Создать дубль задания
     function Dublicate(Index:integer):integer;
     // Поменять задания местами
     procedure Exchange(Index1,Index2:integer);
     // Поднять задание вверх
     procedure Up(Index:integer);
     // Задание вниз
     procedure Down(Index:integer);
     //procedure SetItem (Index:Integer;Value:PTTask); // Не имеет смысла

     property Items[Index: Integer]: TTask read GetItem; default;
     property Count:Integer read GetCount;


  end;


implementation
//------------------------------------------------------------------------------
constructor TTaskList.Create;
begin
inherited Create;
FTasks.Create;
//_Count:=0;
end;
//------------------------------------------------------------------------------
procedure TTaskList.LoadFromFile(XMLDoc:TXMLConfig;Section:string);
var
  i, cnt: integer;
  sec: string;
  Task:TTask;
  //cr:string;
begin
  Task:=TTask.Create;
  // количество заданий
  cnt := xmldoc.GetValue(Section+'tasks/count/value', 0);
  for i := 0 to cnt-1 do
  begin
    // Имя секции с заданием
    sec := Section+'tasks/task' + IntToStr(i+1) + '/';
    Task.LoadFromFile(XMLDoc,sec);
    Add(Task); // Добавление копированием
  end;

end;
//------------------------------------------------------------------------------
procedure TTaskList.SaveToFile(XMLDoc:TXMLConfig;Section:string);
var
  i, cnt: integer;
  sec: string;
  PTask:PTTask;
  //cr:string;
begin
  // количество заданий
  cnt := xmldoc.GetValue(Section+'tasks/count/value', 0);
  // количество заданий
  xmldoc.SetValue(Section+'tasks/count/value', FTasks.Count);
  for i := 0 to FTasks.Count-1 do
  begin
    // Имя секции с заданием
    sec := Section+'tasks/task' + IntToStr(i+1) + '/';
    PTask:=FTasks[i];
    PTask^.SaveToFile(XMLDoc,sec);
  end;

end;
//------------------------------------------------------------------------------
// Удалить задание
procedure TTaskList.Delete(Index:integer);
var
  PTask:PTTask;
begin
  PTask:=FTasks[Index];
  PTask^.Free;
  FTasks.Delete(Index);
end;
//------------------------------------------------------------------------------
// Добавить задание копированием
function TTaskList.Add(Task:TTask):integer;
var
  tmpTask:TTask;
begin
tmpTask.Create;
if Assigned(Task) then tmpTask.Assign(Task); // Копируем если не nil
Result:=FTasks.Add(tmpTask);
end;
//------------------------------------------------------------------------------
// Создать дубль задания
function TTaskList.Dublicate(Index:integer):integer;
var
  tmpTask:TTask;
  PTask:PTTask;
begin
tmpTask.Create;
PTask:=FTasks[Index];
tmpTask.Assign(PTask^); // Копируем
tmpTask.Name:=rsCopyPerfix + ' '+tmpTask.Name;
tmpTask.LastRunDate:=0;
Result:=FTasks.Add(tmpTask);
end;
//------------------------------------------------------------------------------
// Поднять задание вверх
procedure TTaskList.Up(Index:integer);
begin
if Index<1 then exit; // Уже и так высоко
Exchange(Index,Index-1);
end;
//------------------------------------------------------------------------------
// Задание вниз
procedure TTaskList.Down(Index:integer);
begin
if Index>FTasks.Count-2 then exit; // Ниже некуда
Exchange(Index,Index+1);
end;

//------------------------------------------------------------------------------
// Поменять задания местами
procedure TTaskList.Exchange(Index1,Index2:integer);
begin
FTasks.Exchange(Index1,Index2);
end;
//------------------------------------------------------------------------------
// Очистить список заданий
procedure TTaskList.Clear;
var
  i:integer;
  PTask:PTTask;
begin
// Удаляем все объекты
for i:=0 to FTasks.Count-1 do
    begin
    PTask:=FTasks[i];
    PTask^.Free;
    end;
FTasks.Clear;
end;

//------------------------------------------------------------------------------
destructor TTaskList.Destroy;
var
  i:integer;
  PTask:PTTask;
begin
// Удаляем все объекты
for i:=0 to FTasks.Count-1 do
    begin
    PTask:=FTasks[i];
    PTask^.Free;
    end;
FTasks.Free;
inherited Destroy;
end;
//------------------------------------------------------------------------------
function TTaskList.GetItem (Index:Integer):TTask;
var
  PTask:PTTask;
begin
//  Result:=nil;
//  if Index<_Count then
PTask:=FTasks[Index];
Result:=PTask^;
//Result:=(FTasks[Index]^);
end;
//------------------------------------------------------------------------------
function TTaskList.GetCount:Integer;
begin
Result:=FTasks.Count;
end;

//------------------------------------------------------------------------------
{
procedure TTaskList.SetItem (Index:Integer;Value:PTTask);
begin

     _Tasks.Items[Index]. Assign(Value);
end;
 }
end.


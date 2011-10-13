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
     procedure LoadFromFile(var XMLDoc:TXMLConfig;Section:string);
     procedure SaveToFile(var XMLDoc:TXMLConfig;Section:string);
     // Очистить список заданий
     procedure Clear;
     // Удалить задание
     procedure Delete(Index:integer);
     // Добавить задание копированием
     function Add(Task:TTask=nil):integer;
     // Добавить задание из файла
     function Add(XMLDoc:TXMLConfig;Section:string):integer;
     // Добавить задание ссылкой
     function AddLink(Task:TTask):integer;
     // Создать дубль задания
     function Dublicate(Index:integer):integer;
     // Поменять задания местами
     procedure Exchange(Index1,Index2:integer);
     // Поднять задание вверх
     procedure Up(Index:integer);
     // Задание вниз
     procedure Down(Index:integer);
     // Поиск задания со статусом state, возвращает его номер
     function FindTaskSt(state: integer): integer;
     //procedure SetItem (Index:Integer;Value:PTTask); // Не имеет смысла

     property Items[Index: Integer]: TTask read GetItem; default;
     property Count:Integer read GetCount;


  end;


implementation
//------------------------------------------------------------------------------
constructor TTaskList.Create;
begin
inherited Create;
FTasks:=TList.Create;
//_Count:=0;
end;
//------------------------------------------------------------------------------
procedure TTaskList.LoadFromFile(var XMLDoc:TXMLConfig;Section:string);
var
  i, cnt: integer;
  sec: string;
//  Task:TTask;
begin
//  Task:=TTask.Create;
  // количество заданий
  cnt := xmldoc.GetValue(Section+'count/value', 0);
  for i := 0 to cnt-1 do
  begin
    // Имя секции с заданием
    sec := Section+'task' + IntToStr(i+1) + '/';
//    Task.LoadFromFile(XMLDoc,sec);
    Add(XMLDoc,sec); // Добавление из файла
    //Add(Task); // Добавление копированием
  end;
//  Task.Free;
end;
//------------------------------------------------------------------------------
procedure TTaskList.SaveToFile(var XMLDoc:TXMLConfig;Section:string);
var
  i: integer;
  sec: string;
  PTask:PTTask;
begin

  // количество заданий
  xmldoc.SetValue(Section+'count/value', FTasks.Count);
  for i := 0 to FTasks.Count-1 do
  begin
    // Имя секции с заданием
    sec := Section+'task' + IntToStr(i+1) + '/';
    PTask:=FTasks[i];
    (PTask^).SaveToFile(XMLDoc,sec);
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
if Assigned(Task) then
     begin
     tmpTask:=TTask.Create(Task); // Создание копированием
     end
  else
     begin
     tmpTask:=TTask.Create;
     end;
Result:=FTasks.Add(tmpTask);
end;
//------------------------------------------------------------------------------
// Добавить задание из файла
function TTaskList.Add(XMLDoc:TXMLConfig;Section:string):integer;
var
  tmpTask:TTask;
begin
tmpTask:=TTask.Create(XMLDoc,Section);
Result:=AddLink(tmpTask);
end;

//------------------------------------------------------------------------------
// Добавить задание ссылкой
function TTaskList.AddLink(Task:TTask):integer;
begin
Result:=FTasks.Add(Task);
end;
//------------------------------------------------------------------------------
// Создать дубль задания
function TTaskList.Dublicate(Index:integer):integer;
var
  tmpTask:TTask;
  PTask:PTTask;
begin
tmpTask:=TTask.Create;
PTask:=FTasks[Index];
tmpTask.Assign(PTask^); // Копируем
tmpTask.Name:=rsCopyPerfix + ' '+tmpTask.Name;
tmpTask.LastRunDate:=0;
Result:=FTasks.Add(tmpTask);
//tmpTask.Free;
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
//=========================================================
// Поиск задания со статусом state, возвращает его номер
// Если не найдено возварщается -1
// Находит первое попавшееся задание с таким статусом
function TTaskList.FindTaskSt(state: integer): integer;
var
  i: integer;
  PTask:PTTask;
begin
  Result := -1;
  for i := 0 to FTasks.Count-1 do
  begin
    PTask:=FTasks[i];
    if PTask^.Status = state then
    begin
      Result := i;
      break;
    end;
  end;
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


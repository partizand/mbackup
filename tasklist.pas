// Список параметров заданий

unit tasklist;

{$mode objfpc}{$H+}




interface

uses
  Classes, SysUtils,task;

const
  MaxTasks = 100; // Макс количество заданий
  MaxPChar = 250;
// Макс длина строки запуска внешнего приложения

// Список заданий как объектов
type
  TTaskList=class
   public
     constructor Create;
     destructor Destroy; override;

   private
     _Tasks:TList; // Список заданий
     _Count:integer; // Счетчик
   private
     function GetItem (Index:Integer):PTTask;
     //procedure SetItem (Index:Integer;Value:PTTask); // Не имеет смысла
   public
     property Items[Index: Integer]: PTTask read GetItem; default;
     property Count:Integer read _Count;


  end;


implementation
//------------------------------------------------------------------------------
constructor TTaskList.Create;
begin
inherited Create;
_Tasks.Create;
_Count:=0;
end;
//------------------------------------------------------------------------------
destructor TTaskList.Destroy;
begin
_Tasks.Free;
inherited Destroy;
end;
//------------------------------------------------------------------------------
function TTaskList.GetItem (Index:Integer):PTTask;
begin
  Result:=nil;
  if Index<_Count then
   Result:=(_Tasks[Index]);
end;
//------------------------------------------------------------------------------
{
procedure TTaskList.SetItem (Index:Integer;Value:PTTask);
begin

     _Tasks.Items[Index]. Assign(Value);
end;
 }
end.


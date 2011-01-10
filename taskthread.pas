unit taskthread;

interface

uses
  Classes,TaskUnit, Sysutils,iniLang;

 //Type TProgressEvent = Procedure( Sender: TObject; ProgrType: ProgressType; Filename: String; FileSize: int64 ) of object;

type
  TTaskThread = class(TThread)
  private

    TaskCl:TTaskCl;
    procedure UpdateSatus;
    procedure UpdateTotalGauge;
    procedure UpdateMsgMemo;
    procedure ReadTaskCl;
    procedure SaveTaskCl;

    { Private declarations }

  protected
    procedure Execute; override;
  public
  MaxVal:int64; // Общий размер файлов
  CurPos:int64; // Текущий размер сделанных файлов
  ProgressGauge:integer; // Прогресс gauge периведенный с int64 к integer
 // TotalSize1,TotalSize2,TotalProgress2,TotalProgress1:integer;
  numT:integer; // Номер задания на запуск
  TotGaugeVis:boolean; // Видимость прогресса gauge
  status,stmemo,stfile:string;
 // prog2pos:integer; //положение прогрессбара
  procedure ShowProc(Sender: TObject; ProgrType: ProgressType; Filename: String; FileSize: Int64);
  //  constructor Create(newtask:TTask;logfile:string);
  constructor Create(numTask:integer);
  end;

implementation
uses MainForm,msgstrings;
{ Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure TTaskThread.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{ TTaskThread }
procedure TTaskThread.ShowProc(Sender: TObject; ProgrType: ProgressType; Filename: String; FileSize: Int64);
//Var
//    Step: Integer;
Begin
    Case ProgrType Of
        TotalSize2Process:
            Begin
                If Filename = '' Then
                Begin
                    //MsgForm.StatusBar1.Panels.Items[0].Text := 'Total size: ' + IntToStr(FileSize Div 1024) + ' Kb';
                   // prog2pos:=0;
                    CurPos:=0;
                    ProgressGauge:=0;
                    MaxVal:=FileSize;
                    TotGaugeVis:=true;
                    Synchronize(@UpdateTotalGauge);
                   // Synchronize(UpdateProgress);
                   // status:='Сообщение: общий размер: '+IntToStr(FileSize);
                   // Synchronize(UpdateMsgMemo);
                    //Form1.ProgressBar2.Position := 1;
                    //MsgForm.ProgressBar1.Max := 10001;
                   // TotalSize2 := FileSize;
                   // TotalProgress2 := 0;
                End
                Else
                Begin
               //     stmemo:='Файл '+FileName;
                //    Synchronize(UpdateMsgMemo);
                //    stFile:=FileName;
                //    Synchronize(UpdateSatus);
                    //MsgForm.FileBeingZipped.Caption := Filename;
                    //MsgForm.ProgressBar1.Position := 1;
                    //MsgForm.ProgressBar1.Max := FileSize;
                End;
            End;
        TotalFiles2Process:
            Begin
                // ZipMaster1Message( self, 0, 'in OnProgress type TotalFiles, files= ' + IntToStr( FileSize ) );
                If Filename = '' Then
                  begin;
                   // status:='Сообщение: всего файлов для архивации: '+IntToStr(FileSize);
                   // Synchronize(UpdateMsgMemo);

                 //MsgForm.StatusBar1.Panels.Items[1].Text := IntToStr(FileSize) + ' files';
                  end;

            End;
        MsgCopy:
            Begin
                 stmemo:=FileName;
                 Synchronize(@UpdateMsgMemo);
                // stFile:=FileName;
                // Synchronize(UpdateSatus);

            End;

        NewFile:
            Begin
             //   MsgForm.FileBeingZipped.Caption := Filename;
              //  MsgForm.ProgressBar1.Position := 1; // Current position of bar.
            //    TotalSize1 := FileSize;
            //    TotalProgress1 := 0;
             //    stmemo:='Копирование файла '+FileName+' ...';
            //     Synchronize(UpdateMsgMemo);
                 stFile:=FileName;
                 Synchronize(@UpdateSatus);

            End;
        ProgressUpdate:
            Begin
                If Filename = '' Then
                Begin
                //status:='Сообщение: ProgressUpdate FileName=null '+' FileSize='+IntToStr(FileSize);
                //Synchronize(UpdateMsgMemo);
                CurPos:=CurPos+FileSize;
                if (CurPos>0) then
                  begin
                    try
                     ProgressGauge:=Round(CurPos/MaxVal*1000);
                    Except
                     ProgressGauge:=1000;
                     end;
                  end;
                Synchronize(@UpdateTotalGauge);
              End;
            End;
        EndOfBatch:                     // Reset the progress bar and filename.
            Begin
             // stMemo:='Сообщение: конец обработки';
             // Synchronize(UpdateMsgMemo);
             stFile:='';
             Synchronize(@UpdateSatus);
               // ZipMaster1Message( self, 0, 'in OnProgress type EndOfBatch' );
      //          MsgForm.FileBeingZipped.Caption := '';
      //          MsgForm.ProgressBar1.Position := 1;
      //          MsgForm.StatusBar1.Panels[0].Text := '';
      //          MsgForm.StatusBar1.Panels[1].Text := '';
      //          MsgForm.ProgressBar2.Position := 1;
            End;
    End;                                // EOF Case
End;


procedure TTaskThread.UpdateSatus;
begin
 MForm.StatusBar.Panels[0].Text:=status;
 MForm.StatusBar.Panels[1].Text:=stfile;
end;
// Обновление ProgressBar
{procedure TTaskThread.UpdateProgress;
begin
// Form1.ProgressBar2.Position:=prog2pos;
end;
 }
// Обновление TotalGauge
procedure TTaskThread.UpdateTotalGauge;
begin
// MForm.TotGauge.MaxValue:=1000;
// MForm.TotGauge.Progress:=ProgressGauge;
 MForm.TotGauge.Visible:=TotGaugeVis;
end;

// Сообщение status в область сообщений
procedure TTaskThread.UpdateMsgMemo;
begin
 if (stMemo='') then MForm.MsgMemo.Lines.Clear
   else MForm.MsgMemo.Lines.Add(stmemo);
end;


// Безопасное чтение параметров Task
procedure TTaskThread.ReadTaskCl;
begin
//  TaskCl:=TTaskCl.Create;
  TaskCl.Count:=1;
  TaskCl.Tasks[1]:=MForm.TaskCl.Tasks[numt];
  TaskCl.Count:=1;
  TaskCl.logfile:=MForm.TaskCl.logfile;
  TaskCl.loglimit:=MForm.TaskCl.loglimit;

//  TaskCl.alerttype:=MForm.TaskCl.alerttype;
  TaskCl.smtpserv:=MForm.TaskCl.smtpserv;
  TaskCl.smtpport:=MForm.TaskCl.smtpport;
  TaskCl.smtpuser:=MForm.TaskCl.smtpuser;
  TaskCl.smtppass:=MForm.TaskCl.smtppass;
  TaskCl.email:=MForm.TaskCl.email;
  TaskCl.mailfrom:=MForm.TaskCl.mailfrom;
  
end;
// Безопасная запись параметров Task
procedure TTaskThread.SaveTaskCl;
var
 i:integer;
begin
  i:=MForm.TaskCl.FindTaskSt(stRunning);
  MForm.TaskCl.Tasks[i].LastResult:=TaskCl.Tasks[1].LastResult;
  MForm.TaskCl.Tasks[i].LastRunDate:=TaskCl.Tasks[1].LastRunDate;
end;



// Создание объекта потока
constructor TTaskThread.Create(numtask:integer);
begin
  numT:=numtask;
  TaskCl:=TTaskCl.Create;
  Synchronize(@ReadTaskCl);
  TaskCl.OnProgress:=@ShowProc;
//  TaskCl.Tasks[1]:=newtask;

//  TaskCl.logfile:=logfile;
//  TaskCl.loglimit:=loglimit;
  FreeOnTerminate := True;
  inherited Create(False);
end;



procedure TTaskThread.Execute;
//type ShowProgress
var
// nam:string;
 res:integer;//
// sp:ShowProgress;
begin

//sp:=TTaskThread.ShowProc;
//ShowProgress:=ShowProc;
status:=Format(misc(rsTaskIsRunning,'rsTaskIsRunning'),[TaskCl.Tasks[1].Name]);
//status:='Выполняется задача "'+TaskCl.Tasks[1].Name+'"';
stfile:='';
Synchronize(@UpdateSatus);
stMemo:='';
Synchronize(@UpdateMsgMemo);
//MForm.MsgMemo.Lines.Clear;
res:=TaskCl.RunTask(1,true);
Synchronize(@SaveTaskCl);
//nam:=MForm.TaskCl.Name;
//res:=TaskCl.RunTask(1);
if res=trOk then
 begin
 // status:=Format(misc(
  status:=Format(misc(rsLogTaskEndOk,'rsLogTaskEndOk'),[TaskCl.Tasks[1].Name]);
 // status:='Задача "'+TaskCl.Tasks[1].Name+'" выполнена успешно';
 end;
if res=trError then
 begin
  status:=Format(misc(rsLogTaskError,'rsLogTaskError'),[TaskCl.Tasks[1].Name]);
 // status:='Задача "'+TaskCl.Tasks[1].Name+'" не выполнена';
 end;
if res=trFileError then
 begin
  status:=Format(misc(rsLogTaskEndErr,'rsLogTaskEndErr'),[TaskCl.Tasks[1].Name]);
//  status:='Задача "'+TaskCl.Tasks[1].Name+'" выполнена с ошибками';
 end;

//  RunTask(Task);
Synchronize(@UpdateSatus);
TotGaugeVis:=false;
Synchronize(@UpdateTotalGauge);
  { Place thread code here }
end;

end.

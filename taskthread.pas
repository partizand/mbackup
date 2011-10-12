unit taskthread;

interface

uses
  Classes,backup,task, Sysutils{,iniLang};

 //Type TProgressEvent = Procedure( Sender: TObject; ProgrType: ProgressType; Filename: String; FileSize: int64 ) of object;

type
  TTaskThread = class(TThread)
  private

    Backup:TBackup;
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
  Task:TTask; // Выполняемое задание
 // prog2pos:integer; //положение прогрессбара
  procedure ShowProc(Sender: TObject; ProgrType: ProgressType; Filename: String; FileSize: Int64);
  //  constructor Create(newtask:TTask;logfile:string);
  constructor Create(numTask:integer);
//  constructor Create(TaskToRun:TTask);
  destructor Destroy;override;
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
                End
                Else
                Begin

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

            End;

        NewFile:
            Begin
                 stFile:=FileName;
                 Synchronize(@UpdateSatus);

            End;
        ProgressUpdate:
            Begin
                If (Filename = '') and (MaxVal>0) Then
                Begin
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
            End;
    End;                                // EOF Case
End;


procedure TTaskThread.UpdateSatus;
begin
 MForm.StatusBar.Panels[0].Text:=status;
 MForm.StatusBar.Panels[1].Text:=ansitoutf8(stfile);
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
 MForm.TotGauge.Max:=1000;
 MForm.TotGauge.Position:=ProgressGauge;
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
//  Backup:=TBackup.Create;
//  Backup.Count:=1;
//  SetLength(Backup.Tasks,1);
  Backup.Tasks.Add(MForm.Backup.Tasks[numt]);
//  Backup.CopyTask(MForm.Backup.Tasks[numt],Backup.Tasks[0]);
  //Backup.Tasks[1]:=MForm.Backup.Tasks[numt];
  {
  Backup.Settings.logfile:=MForm.Backup.Settings.logfile;
  Backup.Settings.loglimit:=MForm.Backup.Settings.loglimit;
    Backup.Settings.smtpserv:=MForm.Backup.Settings.smtpserv;
  Backup.Settings.smtpport:=MForm.Backup.Settings.smtpport;
  Backup.Settings.smtpuser:=MForm.Backup.Settings.smtpuser;
  Backup.Settings.smtppass:=MForm.Backup.Settings.smtppass;
  Backup.Settings.email:=MForm.Backup.Settings.email;
  Backup.Settings.mailfrom:=MForm.Backup.Settings.mailfrom;
  }
end;
// Безопасная запись параметров Task
procedure TTaskThread.SaveTaskCl;
var
 i:integer;
begin
  i:=MForm.Backup.Tasks.FindTaskSt(stRunning);
  MForm.Backup.Tasks[i].LastResult:=Backup.Tasks[0].LastResult;
  MForm.Backup.Tasks[i].LastRunDate:=Backup.Tasks[0].LastRunDate;
end;



// Создание объекта потока
constructor TTaskThread.Create(numtask:integer);
//constructor TTaskThread.Create(TaskToRun:TTask);
begin
  Backup:=TBackup.Create;
  NumT:=numtask;
//  Backup.Count:=1;
//  SetLength(Backup.Tasks,1);
//  Backup.CopyTask(TaskToRun,Backup.Tasks[0]);
  Synchronize(@ReadTaskCl);
  Backup.OnProgress:=@ShowProc;
//  Backup.Tasks[1]:=newtask;

//  Backup.logfile:=logfile;
//  Backup.loglimit:=loglimit;
  FreeOnTerminate := True;
  inherited Create(False);
end;
destructor TTaskThread.Destroy;
begin
  Backup.Destroy;
  inherited Destroy;
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
status:=Format(rsTaskIsRunning,[Backup.Tasks[0].Name]);
//status:='Выполняется задача "'+Backup.Tasks[1].Name+'"';
stfile:='';
Synchronize(@UpdateSatus);
stMemo:='';
Synchronize(@UpdateMsgMemo);
//MForm.MsgMemo.Lines.Clear;
res:=Backup.RunTask(0,true);
Synchronize(@SaveTaskCl);
//nam:=MForm.Backup.Name;
//res:=Backup.RunTask(1);
if res=trOk then
 begin
 // status:=Format(misc(
  status:=Format(rsLogTaskEndOk,[Backup.Tasks[0].Name]);
 // status:='Задача "'+Backup.Tasks[1].Name+'" выполнена успешно';
 end;
if res=trError then
 begin
  status:=Format(rsLogTaskError,[Backup.Tasks[0].Name]);
 // status:='Задача "'+Backup.Tasks[1].Name+'" не выполнена';
 end;
if res=trFileError then
 begin
  status:=Format(rsLogTaskEndErr,[Backup.Tasks[0].Name]);
//  status:='Задача "'+Backup.Tasks[1].Name+'" выполнена с ошибками';
 end;

//  RunTask(Task);
Synchronize(@UpdateSatus);
TotGaugeVis:=false;
Synchronize(@UpdateTotalGauge);
  { Place thread code here }
end;

end.

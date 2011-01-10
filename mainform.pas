unit MainForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, Menus,
  ActnList, ComCtrls, StdCtrls, ExtCtrls,taskunit,unitfunc,{inifiles,inilang,}msgstrings,
  taskthread,windows;

Type TOnTermEvent = Procedure( Sender: TObject) of object;

type

  { TMForm }

  TMForm = class(TForm)
    ActAdd: TAction;
    ActEdit: TAction;
    ActDel: TAction;
    ActDown: TAction;
    ActAbout: TAction;
    ActAddProfile: TAction;
    ActHelp: TAction;
    ActCopy: TAction;
    ActRunAll: TAction;
    ActSaveProf: TAction;
    ActOpenProfile: TAction;
    ActNewProfile: TAction;
    ActSet: TAction;
    ActUp: TAction;
    ActRun: TAction;
    ActionList1: TActionList;
    ImageList1: TImageList;
    ListTask: TListView;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    mnutRunAll: TMenuItem;
    mnutCopy: TMenuItem;
    mnuSave: TMenuItem;
    mnuHelp: TMenuItem;
    mnuTOpenProfile: TMenuItem;
    mnutAddprofile: TMenuItem;
    mnuTAbout: TMenuItem;
    mnutHelpMain: TMenuItem;
    mnutSet: TMenuItem;
    mnutSetmain: TMenuItem;
    mnutDown: TMenuItem;
    mnutUp: TMenuItem;
    mnutdel: TMenuItem;
    mnutrun: TMenuItem;
    MnuTEdit: TMenuItem;
    //MnuTEdit: TMenuItem;
    MsgMemo: TMemo;
    MnuTAdd: TMenuItem;
    MnuTask: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    Splitter1: TSplitter;
    StatusBar: TStatusBar;
    ToolBar1: TToolBar;
    ButAdd: TToolButton;
    ButEdit: TToolButton;
    ButDel: TToolButton;
//    ToolButton1: TToolButton;
    ButStart: TToolButton;
    ButStop: TToolButton;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ButUp: TToolButton;
    ButDown: TToolButton;
    ToolButton3: TToolButton;
    ButSet: TToolButton;
    ButHelp: TToolButton;
    procedure ActAboutExecute(Sender: TObject);
    procedure ActAddExecute(Sender: TObject);
    procedure ActAddProfileExecute(Sender: TObject);
    procedure ActCopyExecute(Sender: TObject);
    procedure ActDelExecute(Sender: TObject);
    procedure ActDownExecute(Sender: TObject);
    procedure ActEditExecute(Sender: TObject);
    procedure ActHelpExecute(Sender: TObject);
    procedure ActNewProfileExecute(Sender: TObject);
    procedure ActOpenProfileExecute(Sender: TObject);
    procedure ActRunAllExecute(Sender: TObject);
    procedure ActRunExecute(Sender: TObject);
    procedure ActSaveProfExecute(Sender: TObject);
    procedure ActSetExecute(Sender: TObject);
    procedure ActUpExecute(Sender: TObject);
    procedure ButDownClick(Sender: TObject);
    procedure ButStopClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);

    procedure FormCreate(Sender: TObject);
    procedure ListTaskDblClick(Sender: TObject);
    procedure MsgMemoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
      );
//    procedure Splitter1CanResize(Sender: TObject; var NewSize: Integer; var Accept: Boolean);
    // ��� ���������
//    procedure ReadIni;
//    procedure SaveIni;
    procedure ReadArgvW;
    procedure FillListTask(numTask:integer);
    procedure RunThTask(numT:integer);
    procedure TaskDone(Sender: TObject);
    function ShowTaskForm(NumEdTask:integer):boolean;
    function RunAllTasks:boolean;
  private
    { private declarations }
  public
    { public declarations }
    Backup:TBackup;
    AutoOnlyClose:boolean; // ���������� ������� ������ � ���������� close
    StartMin:boolean; // ������������ ��� �������
    IsClosing:boolean; // ��������� �� �����, ��� ��������� ������� �� ������� �����
//    LoadLastProf:boolean; // ��������� ��������� �������� �������
//    DefaultProf:String; // ������� �� ���������

//    LangFile:String; // ��� ����� �����
//    TotGauge:TGauge;
    TotGauge:TProgressBar;
    FormInitialWidth:integer;
//    ParamQ:boolean; // ����� �� ��������� �� ���������� ���� ������� (�������� /q ��� �������)
    ParamRun:boolean; // ���������� ������� /r � ���� ������� �� ������

    taskcount:integer; // ���������� ���������� ������� � ��������
    taskth:TTaskThread; // ����� � ��������

  end;

var
  MForm: TMForm;

implementation

uses frmtask,frmset,unitabout;

{ TMForm }





procedure TMForm.ActAddExecute(Sender: TObject);
begin

if Backup.Count=MaxTasks then exit; // �������
Backup.AddTask;

//FormTask.numTask:=Backup.Count;
if Not ShowTaskForm(Backup.Count-1) then
                Backup.DelTask(Backup.Count-1);


// FormTask.Showmodal;
end;

procedure TMForm.ActAddProfileExecute(Sender: TObject);
var
 profil:string;
begin
if OpenDialog1.Execute then
  begin
  profil:=Backup.Settings.profile;
  Backup.LoadFromFile(OpenDialog1.FileName);
  Backup.Settings.profile:=profil; // ���������� ����� ������� �������
  FillListTask(-1);
  end;
end;

procedure TMForm.ActCopyExecute(Sender: TObject);
var
 num:integer;
begin
if ListTask.SelCount=0 then exit;
  num:=ListTask.Selected.Index;
  if num<0 then exit;
  Backup.DublicateTask (num);
  FillListTask(num);
end;

procedure TMForm.ActAboutExecute(Sender: TObject);
begin
Application.CreateForm(TFormAbout, FormAbout); // �������� �����
FormAbout.ShowModal;
FormAbout.Free;

end;

procedure TMForm.ActDelExecute(Sender: TObject);
var
 num:integer;
 str:string;
begin
ButDel.Down:=false;
if ListTask.SelCount=0 then exit;
num:=ListTask.Selected.Index+1;
if num<1 then exit;
str:=format(rsQuestDeleteTask,[Backup.Tasks[num].Name]);
if MessageDlg(str,mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
  Backup.DelTask(num);
  FillListTask(num-1);
  Backup.SaveToFile('');
  end;
//ButDel.Down:=false;
end;

procedure TMForm.ActDownExecute(Sender: TObject);
var
 num:integer;
begin
if ListTask.SelCount=0 then exit;
num:=ListTask.Selected.Index;
if num>Backup.Count-2 then exit;
Backup.DownTask(num);
FillListTask(num+1);
Backup.SaveToFile('');
end;

procedure TMForm.ActEditExecute(Sender: TObject);
var
 num:integer;
begin
if ListTask.SelCount=0 then exit;
  num:=ListTask.Selected.Index;
  if num<0 then exit;
  ShowTaskForm(num);
end;

procedure TMForm.ActHelpExecute(Sender: TObject);
var
 helpfile2:string;
begin
helpfile2:='help.'+Backup.Settings.Lang+'.htm';
{
if CL=nil then
   begin
   helpfile2:='Help-ru.htm';
   end
  else
  helpfile2:=CL.ReadString('Language','HelpFile','Help-ru.htm');
  }
ShellExecute(0,nil,PChar(ExtractFileDir(ParamStr(0))+DirectorySeparator+helpfile2),nil,nil,SW_SHOWNORMAL);
end;

procedure TMForm.ActNewProfileExecute(Sender: TObject);
var
 filenam:string; // ��� �����
begin
if SaveDialog1.Execute then
  begin
  filenam:=ShortFileNam(SaveDialog1.FileName);
  if ExtractFileExt(filenam)='' then filenam:=filenam+'.xml';
  Backup.Clear; //Count:=0;
  FillListTask(-1);
//  Backup.ProfName:='';
  Backup.SaveToFile(filenam);
  Backup.LoadFromFile(filenam);
  MForm.Caption:='AutoSave '+MForm.Backup.Settings.profile;
  end;
end;

procedure TMForm.ActOpenProfileExecute(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
//  Backup.Count:=0;
  Backup.LoadFromFile(OpenDialog1.FileName);
//  EditCurProf.Text:=MForm.Backup.profile;
//  EditProfNam.Text:=MForm.Backup.ProfName;
  FillListTask(-1);
  MForm.Caption:='mBackup '+MForm.Backup.Settings.profile;
  end;
end;

procedure TMForm.ActRunAllExecute(Sender: TObject);
begin
  RunAllTasks;
end;

procedure TMForm.ActRunExecute(Sender: TObject);
var
 num:integer;
begin
if ListTask.SelCount=0 then exit;
num:=ListTask.Selected.Index;
if num<0 then exit;
RunThTask(num);
//ButStart.Down:=false;
end;

procedure TMForm.ActSaveProfExecute(Sender: TObject);
var
 filen:string; // ��� �����
begin
If SaveDialog1.Execute then
   begin
   filen:=ShortFileNam(SaveDialog1.FileName);
   if ExtractFileExt(filen)='' then filen:=filen+'.xml';
   Backup.SaveToFile(filen);
   //EditCurProf.Text:=filen;
   MForm.Caption:='mBackup '+MForm.Backup.Settings.profile;
   end;
end;

procedure TMForm.ActSetExecute(Sender: TObject);
begin
  Application.CreateForm(TFormSet, FormSet); // �������� �����
  FormSet.Settings:=Backup.Settings;
  FormSet.FillForm;
if FormSet.ShowModal=mrOk then
  begin
  Backup.Settings:=FormSet.Settings;
  Backup.Settings.SaveIni;
  end;
FormSet.Free;
end;

procedure TMForm.ActUpExecute(Sender: TObject);
var
 num:integer;
begin
if ListTask.SelCount=0 then exit;
num:=ListTask.Selected.Index;
if num<1 then exit;
Backup.UpTask(num);
FillListTask(num-1);
Backup.SaveToFile('');
end;

procedure TMForm.ButDownClick(Sender: TObject);
begin

end;

procedure TMForm.ButStopClick(Sender: TObject);
begin

end;

procedure TMForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if Backup.Settings.LoadLastProf then
    begin
     Backup.Settings.DefaultProf:=Backup.Settings.profile;
     Backup.Settings.SaveIni;
    end;
 Backup.SaveToFile('');
 Backup.Free;
end;

procedure TMForm.FormCreate(Sender: TObject);
//var
//TC: array[1..1] of TComponent;
begin

// �������� �������� ����
TotGauge:=TProgressBar.Create(StatusBar);
With TotGauge Do
    Begin
       // ForeColor:=clSilver;
        Parent := StatusBar;
        Top := 2;
        Left := StatusBar.Left + StatusBar.Panels.Items[0].Width +
            StatusBar.Panels.Items[1].Width + 2;
        Height := StatusBar.Height - 2;
       // MinValue:=0;
       // MaxValue:=100;
        Width:=150;
        Visible:=false;
      end;

FormInitialWidth := MForm.Width;

Backup:=TBackup.Create;
TaskCount:=0;
IsClosing:=false;
//Backup.ReadIni;
if StartMin then MForm.WindowState:=wsMinimized;

ReadArgvW;

MForm.Caption:='mBackup '+Backup.Settings.Profile;

//TranslateUnitResourceStrings('msgstrings',(ExtractFileDir(ParamStr(0)))+DirectorySeparator+'Lang'+DirectorySeparator+'msgstrings.'+Backup.Settings.Lang+'.po');
//Lang:='ru';
// �������
{
CL:=LoadLangIni(Backup.LangFile);
if CL<>nil then
   begin
   TC[1]:=MForm;
   fillProps(TC,CL);
   end;
   }
FillListTask(0);
end;

procedure TMForm.ListTaskDblClick(Sender: TObject);
begin

end;

procedure TMForm.MsgMemoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
//  var
//TC: array[1..3] of TComponent;
begin
// �������� ���� ����
{
Application.CreateForm(TFormTask, FormTask); // �������� �����
Application.CreateForm(TFormSet, FormSet);
Application.CreateForm(TFormAbout, FormAbout);
// �������� ��������� �����
if (Key=VK_F5) then fillcustomini;
FormTask.Destroy;
FormSet.Destroy;
FormAbout.Destroy;
}
end;


//================================================
// ���������� ������ ������� � ListView
// numTask ����� ����������� �������
// ���� 0 �� ������ �� ����������
// ���� -1 �� ���������� ����� ���������� �������
procedure TMForm.FillListTask(numTask:integer);
//================================================
var
 i:integer;
 olditem:integer;
 strStatus,strstEnd:string;
 frmTime:string;
begin
if ListTask.SelCount>0 then
    olditem:=ListTask.Selected.Index  //ListTask.ItemIndex;
  else
    olditem:=-1;
ListTask.Items.Clear;
// ������ �����
for i:=0 to Backup.Count-1 do
 begin
     ListTask.Items.Add;
     ListTask.Items.Item[i].Caption:=Backup.Tasks[i].Name;
     //ListTask.Items.Item[i-1].Checked:=true;
     ListTask.Items.Item[i].SubItems.Add(Backup.GetNameFS(Backup.Tasks[i].SrcFSParam));
     if Backup.Tasks[i].Action=ttCopy then
      ListTask.Items.Item[i].SubItems.Add(rsCopyng);
     if Backup.Tasks[i].Action=ttZerk then
      ListTask.Items.Item[i].SubItems.Add(rsMirror);
     if Backup.Tasks[i].Action=ttSync then
      ListTask.Items.Item[i].SubItems.Add(rsSync);
     if Backup.Tasks[i].Action=ttArhRar then
      ListTask.Items.Item[i].SubItems.Add(rsArcRar);
     if Backup.Tasks[i].Action=ttArhZip then
      ListTask.Items.Item[i].SubItems.Add(rsArcZip);
     if Backup.Tasks[i].Action=ttArh7Zip then
      ListTask.Items.Item[i].SubItems.Add(rsArc7Zip);

     ListTask.Items.Item[i].SubItems.Add(Backup.GetNameFS(Backup.Tasks[i].DstFSParam));
     // ����� �������/���������
     strStatus:='';
     strstend:='';
     if Backup.Tasks[i].Status=stRunning then // ������� �����������
        begin
         strStatus:=rsIsRunning+' (';
         strstend:=')';
        end;
     if Backup.Tasks[i].Status=stWaiting then // ������� ������� ����������
         strStatus:=rsIsWaiting+ ' (';
     if Backup.Tasks[i].Enabled then
       begin
       ListTask.Items.Item[i].SubItems.Add(strStatus+rsYes+strstend);
{
        if Backup.Tasks[i].Rasp.Manual then
          begin
           ListTask.Items.Item[i-1].SubItems.Add(strStatus+misc(rsManual,'rsManual')+strstend);
          end;
        if Backup.Tasks[i].Rasp.AtStart then
          begin
           ListTask.Items.Item[i-1].SubItems.Add(strStatus+misc(rsAtStart,'rsAtStart')+strstend);
          end;
        if Backup.Tasks[i].Rasp.AtTime then
          begin
           DateTimeToString(frmTime,'HH:MM',Backup.Tasks[i].Rasp.Time);
           ListTask.Items.Item[i-1].SubItems.Add(strStatus+frmTime+strstend);
          end;
}
       end

      else
       begin
       ListTask.Items.Item[i].SubItems.Add(strStatus+rsNo+strstend);
       end;
  // ��������� ���������� �������
  if Backup.Tasks[i].LastRunDate=0 then // ��� �� ���� �� �����������
    begin
     strStatus:=rsTaskNeverRun;
    end
   else
    begin
    if Backup.Tasks[i].LastResult=trOk then strStatus:=rsOk;
    if Backup.Tasks[i].LastResult=trError then strStatus:=rsTaskError;
    if Backup.Tasks[i].LastResult=trFileError then strStatus:=rsTaskEndError;
     DateTimeToString(frmTime,'DD.MM.YY HH:MM',Backup.Tasks[i].LastRunDate);
     strStatus:=strStatus+' '+frmTime;
    end;
  ListTask.Items.Item[i].SubItems.Add(strStatus);
  end;

 // if ListTask.Selected.Index+1<1 then
//   begin
//   ActionList1.Actions[1]. ActionByName('ActCopy').;
//   end;

if numTask<0 then
    begin
    if (oldItem>=0) and (oldItem<ListTask.Items.Count) then
          ListTask.Items[oldItem].Selected:=true;// ItemFocused item Selected.Index:=oldItem

    end
  else
    begin
    if (numTask>=0) and (numTask<=ListTask.Items.Count-1) then
        ListTask.Items[numTask].Selected:=true;// ItemIndex:=numTask-1;

    end;
end;




    {
//=====================================================
// ������ �������� �� Ini �����
procedure TMForm.ReadIni;
//===================================================
 var
  SaveIniFile: TIniFile;
  IniName: String;
begin
IniName:=Backup.FullFileNam('autosave.ini');// ExtractFileDir(ParamStr(0))+'\'+'autosave.ini';

SaveIniFile := TIniFile.Create(IniName);
Backup.logfile:=SaveIniFile.ReadString('log', 'logfile', 'autosave.log');

{if ExtractFileDir(Backup.logfile)='' then
   Backup.logfile:=ExtractFileDir(ParamStr(0))+'\'+Backup.logfile;   // ������� �������
 }
Backup.loglimit:=SaveIniFile.ReadInteger('log', 'loglimit', 500);
IsClosing:=SaveIniFile.ReadBool('common', 'MinimizeToTray',true);
AutoOnlyClose:=SaveIniFile.ReadBool('common', 'AutoOnlyClose',false);
StartMin:=SaveIniFile.ReadBool('common', 'StartMinimized',false);
// ����
LangFile:=SaveIniFile.ReadString('Language', 'LangFile', 'english.lng');

// ��������� ���������
LoadLastProf:=SaveIniFile.ReadBool('profile', 'LoadLastProf',false); // ��������� ��������� �������
DefaultProf:=SaveIniFile.ReadString('profile', 'DefaultProf', 'default.xml');
Backup.profile:=DefaultProf;

Backup.email:=SaveIniFile.ReadString('alerts', 'email', 'pishite@pisma.nam');
Backup.alerttype:=SaveIniFile.ReadInteger('alerts', 'alerttype', alertNone);
Backup.smtpserv:=SaveIniFile.ReadString('alerts', 'smtpserv', '127.0.0.1');
Backup.smtpport:=SaveIniFile.ReadInteger('alerts', 'smtpport', 25);
Backup.smtpuser:=SaveIniFile.ReadString('alerts', 'smtpuser', 'pushkin');
Backup.smtppass:=Backup.DecryptStr(SaveIniFile.ReadString('alerts', 'smtppass', ''));
Backup.mailfrom:=SaveIniFile.ReadString('alerts', 'mailfrom', 'ot-lermontova@pisem.net');


//TrayIcon.MinimizeToTray:=IsClosing;
//TrayIcon.IconVisible:=IsClosing;
IsClosing:=Not (IsClosing);
SaveIniFile.Free;
end;
   }
 {
//=====================================================
// ������ �������� � Ini ����
procedure TMForm.SaveIni;
 var
  SaveIniFile: TIniFile;
  cr:string;
  IniName,dp: String;
begin
IniName:= ExtractFileDir(ParamStr(0))+'\'+'autosave.ini';
SaveIniFile := TIniFile.Create(IniName);
SaveIniFile.WriteString('log', 'logfile',Backup.logfile);
SaveIniFile.WriteInteger('log', 'loglimit',Backup.loglimit);
//SaveIniFile.WriteBool('common', 'MinimizeToTray',FormSet.CheckTray.Checked);
//SaveIniFile.WriteBool('common', 'AutoOnlyClose',AutoOnlyClose);
//SaveIniFile.WriteBool('common', 'StartMinimized',FormSet.CheckStartMin.Checked);

SaveIniFile.WriteString('alerts', 'email', Backup.email);
SaveIniFile.WriteInteger('alerts', 'alerttype', Backup.alerttype);
SaveIniFile.WriteString('alerts', 'smtpserv', Backup.smtpserv);
SaveIniFile.WriteInteger('alerts', 'smtpport', Backup.smtpport);
SaveIniFile.WriteString('alerts', 'smtpuser', Backup.smtpuser);
cr:=Backup.CryptStr(Backup.smtppass);
SaveIniFile.WriteString('alerts', 'smtppass', Backup.CryptStr(Backup.smtppass));
SaveIniFile.WriteString('alerts', 'mailfrom', Backup.mailfrom);

// ����
SaveIniFile.WriteString('Language', 'LangFile', LangFile);

SaveIniFile.WriteBool('profile', 'LoadLastProf',LoadLastProf);
dp:=DefaultProf;
if LoadLastProf then dp:=Backup.profile;
SaveIniFile.WriteString('profile', 'DefaultProf',dp);
SaveIniFile.Free;
end;
//================================================================
  }



//=======================================================
// ������ ��������� ������ � GUI
procedure TMForm.ReadArgvW;
//=====================================================
var
 k:integer;
// s,p:string;
 estr:boolean; // ���� �������� /r
// ParamQ2:boolean;
 IsProfile:boolean;
begin
Backup.Clear;
estr:=Backup.ReadArgv(IsProfile);

// ���� ���� �������� -r ������ �������
if estr {or (NOT AutoOnlyClose))} then // ���������� �������
    begin
      if Backup.AlertStart then Backup.SendAlert(rsStarted);
      if RunAllTasks then
        begin
        ParamRun:=true;
        Backup.InCmdMode:=true;
        end;
{
        for k:=1 to Backup.Count do
           begin
           // ������� ��������                      (� �� ������ ��� �������)
           if Backup.Tasks[k].Enabled  then //and Backup.Tasks[k].Rasp.AtStart
              begin
              ParamRun:=true;
              Backup.InCmdMode:=true;
              RunThTask(k);
              end;
           end;
 }
    end; // end if r
end;
//=======================================================
// ������ ���� ����������� �������, ���������� true ���� ���� ���� ������� ��������
function TMForm.RunAllTasks:boolean;
var
  k:integer;
begin
Result:=false;
  for k:=0 to Backup.Count-1 do
           begin
           // ������� ��������                      (� �� ������ ��� �������)
           if Backup.Tasks[k].Enabled  then //and Backup.Tasks[k].Rasp.AtStart
              begin
              RunThTask(k);
              Result:=true;
              end;
           end;
end;

{//=======================================================
// ������ ��������� ������
procedure TMForm.ReadArgv;
//=====================================================
var
 j,i,k:integer;
 s,p:string;
 alertmes:TStrings;
// est:boolean;
 estp:boolean; // ���� ������� �� ��������
 estr:boolean; // ���� �������� /r
begin
alertmes:=TStringList.Create;
j:=paramcount; // ���-�� ���������� ��������� ������
ParamQ:=false; // ���� �������� ������� �����
ParamRun:=false; // ���� ������� �� ������
estp:=false;
estr:=false;
Backup.Clear; //Count:=0;
for i:=1 to j do // ������� ���� ����������
  begin
  s:=ParamStr(i); // s ��������� ��������
  if SameText(s,'-r') then // ���������� �������
    begin
     estr:=true;
    end; // end if r
  if SameText(s,'-q') then // ����� �� ���������� �������
    begin
    ParamQ:=true;
 //   Estp:=true;
    end;
  if SameText(s,'-alert') then // ����������� � �������
    begin
    AlertMes.Add(misc(rsAlertRunMes,'rsAlertRunMes'));
//    Backup.SendMail(misc(rsAlertRunSubj,'rsAlertRunSubj'),AlertMes);
    end;
  if SameText(s,'-p') then // �������� �������
    begin
//    i:=i+1;
    if i+1<=j then p:=ParamStr(i+1)
      else continue;
    Backup.Clear; //Count:=0;
    Backup.LoadFromFile(p);
    estp:=true;
    end;
  end;

if not estp then // ������� �� �������� ��� ����� ����������
  begin
  Backup.LoadFromFile('');
  end;

//MForm.Caption:='AutoSave '+Backup.profile;
// ���� ���� �������� /r ������ �������
if estr {or (NOT AutoOnlyClose))} then // ���������� �������
    begin
//    if (not (AutoOnlyClose)) Or (SameText(ParamStr(1),'close')) then
        begin
        for k:=1 to Backup.Count do
           begin
           // ������� ��������                      (� �� ������ ��� �������)
           if Backup.Tasks[k].Enabled  then //and Backup.Tasks[k].Rasp.AtStart
              begin
              ParamRun:=true;
              RunThTask(k);
              end;
           end;
         end;
    end; // end if r

alertmes.Free;
end;
  }
//===================================================================
// �������� ����� ������� � ��� �����
// numTask- ����� �������������� �������
// ���������� true ���� ������ ok, false ���� cancel
function TMForm.ShowTaskForm(NumEdTask:integer):boolean;
//=====================================================================
begin
Application.CreateForm(TFormTask, FormTask); // �������� �����
//FormTask.numTask:=NumEdTask;
FormTask.Task:=Backup.Tasks[NumEdTask];
//FormTask.Task.Arh:=Backup.Tasks[NumEdTask].Arh;
FormTask.FillForm;
if FormTask.ShowModal=mrOk then
  begin
  Backup.Tasks[NumEdTask]:=FormTask.Task;
  Backup.SaveToFile('');
  FillListTask(NumEdTask);
  Result:=true;
  end
 else
  begin
  Result:=false;
  end;
FormTask.Free;
end;


//========================================================
// ������ ������� � ������
procedure TMForm.RunThTask(numT:integer);
//var
// num:integer;
// taskth:TTaskThread;
begin
if numt<0 then exit;
if numt>Backup.Count-1 then exit;
if taskcount=0 then // ��� ���������� �������
  begin
   taskcount:=1;
   Backup.Tasks[numT].Status:=stRunning; // ������������ ������� ������� �����������
   //TaskTh:=TTaskThread.Create(Backup.Tasks[numt],logfilenam); // ������ ������
   TaskTh:=TTaskThread.Create(numt); // ������ ������
//   OnTermEvent:=FOnTerminate; TaskDone;
   TaskTh.OnTerminate:=@TaskDone;
//   TaskDone; // ��������� ������� �� ���������� ������
  end
 else // ����� �������
  begin
   Backup.Tasks[numT].Status:=stWaiting; // ������������ ������� ������� � ������� �� ����������
  end;
FillListTask(-1);
end;


//========================================================
// ������� ����������� ��� ���������� ������
procedure TMForm.TaskDone(Sender: TObject);
var
 numRun:integer;
// TaskTh:TTaskThread;
begin
//ButStart.Down:=false;
// ����� ������ �����������
numRun:=Backup.FindTaskSt(stRunning);
Backup.Tasks[numRun].Status:=stNone;
// ����� ���� �� � ������� �������
numRun:=Backup.FindTaskSt(stWaiting);
if numRun=-1 then // � ������� ������ ���
  begin
   TaskCount:=0;
   Backup.InCmdMode:=false; // ����� �������� ������� �� ��������� ������
   if Backup.ParamQ then // ���� ������ �������� ��������������
     begin
     IsClosing:=true;
       if Backup.AlertFinish then // ����������� � ����������
          begin
          Backup.SendAlert(rsFinished);
          end;
     MForm.Close;
     end;

  end
 else  // � ������� ���� ������� numRun
  begin
   Backup.Tasks[numRun].Status:=stRunning; // ������������ ������� ������� �����������
 //  TaskTh:=TTaskThread.Create(Backup.Tasks[numRun],logfilenam); // ������ ������
   TaskTh:=TTaskThread.Create(numRun); // ������ ������
   TaskTh.OnTerminate:=@TaskDone; // ��������� ������� �� ���������� ������
  end;
FillListTask(-1);
end;
//=====================================================

initialization
  {$I mainform.lrs}

end.

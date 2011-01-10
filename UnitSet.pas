unit UnitSet;

{$MODE Delphi}

interface

uses
  LCLIntf, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, {Mask,} Spin,ShellAPI, LResources;

type
  TFormSet = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    EditLogNam: TEdit;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Label2: TLabel;
    EditLim: TSpinEdit;
    Label3: TLabel;
    BitBtn3: TBitBtn;
    GroupBox2: TGroupBox;
    CheckTray: TCheckBox;
    CheckAutoRun: TCheckBox;
    Label4: TLabel;
    CheckStartMin: TCheckBox;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure CheckTrayClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormSet: TFormSet;

implementation

uses Unit1;


procedure TFormSet.BitBtn1Click(Sender: TObject);
begin
if EditLogNam.Text='' then
 begin
   ShowMessage('Введите имя log-файла');
   exit;
 end;
//if ExtractFileDir(EditLogNam.Text)='' then
//   Form1.TaskCl.logfile:=ExtractFileDir(ParamStr(0))+'\'+EditLogNam.Text   // Каталог запуска
// else
   Form1.TaskCL.logfile:=EditLogNam.Text;
Form1.TaskCl.loglimit:=EditLim.Value;
Form1.TrayIcon.MinimizeToTray:=FormSet.CheckTray.Checked ;
Form1.TrayIcon.IconVisible:=FormSet.CheckTray.Checked;
Form1.IsClosing:=Not (FormSet.CheckTray.Checked);
Form1.AutoOnlyClose:=CheckAutoRun.Checked;

ModalResult:=mrOk;
end;

procedure TFormSet.BitBtn3Click(Sender: TObject);
begin
ShellExecute(0,nil,PChar(Form1.TaskCl.logfile),nil,nil,SW_SHOWNORMAL);
end;

procedure TFormSet.CheckTrayClick(Sender: TObject);
begin
CheckStartMin.Enabled:=CheckTray.Checked;
if not CheckStartMin.Enabled then CheckStartMin.Checked:=false;
end;

initialization
  {$i UnitSet.lrs}
  {$i UnitSet.lrs}
  {$i UnitSet.lrs}
  {$i UnitSet.lrs}
  {$i UnitSet.lrs}
  {$i UnitSet.lrs}

end.

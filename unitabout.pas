unit UnitAbout;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons,{inilang,}shellapi,Windows,
  gettext,translations
  ;
  {Прежде всего добавьте модули "gettext" и "translations"}

type

  { TFormAbout }

  TFormAbout = class(TForm)
    BitBtn1: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Label4Click(Sender: TObject);
    procedure Label5Click(Sender: TObject);


  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  FormAbout: TFormAbout;

implementation
uses mainform;
{ TFormAbout }


procedure TFormAbout.FormCreate(Sender: TObject);
var
//TC: array[1..1] of TComponent;
PODirectory, Lang, FallbackLang: String;

begin
{
if CL<>nil then
   begin
   TC[1]:=FormAbout;
   fillProps(TC,CL);
   end;
   }
// Версия программы
Label1.Caption:='mBackup ver '+MForm.TaskCl.GetVer;

PODirectory := 'D:\temp\lang\';
GetLanguageIDs(Lang, FallbackLang); // определено в модуле gettext
TranslateUnitResourceStrings('unitabout', PODirectory + 'mbackupw.%s.po', Lang, FallbackLang);

end;

procedure TFormAbout.Label4Click(Sender: TObject);
begin
ShellExecute(Handle,'open','mailto:atsave@narod.ru',nil,nil,SW_Normal);
end;

procedure TFormAbout.Label5Click(Sender: TObject);
begin
  // Ссылка на сайт
//OpenURL('sdf');
ShellExecute(Handle,'open','http://atsave.narod.ru',nil,nil,SW_Normal);
//  SysUtils.ExecuteProcess('/full/path/to/binary',['arg1','arg2']);
end;


initialization
  {$I unitabout.lrs}
 {

  Lang     := ReadLang;
if (FileExists('D:\temp\lang\mbackupw.'+Lang+'.po')) then
 LRSTranslator:=TPoTranslator.Create('D:\temp\lang\mbackupw.'+Lang+'.po');
  }
end.


unit UnitAbout;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons,{inilang,}shellapi,Windows,
  gettext,translations,taskunit
  ;
  {Прежде всего добавьте модули "gettext" и "translations"}

type

  { TFormAbout }

  TFormAbout = class(TForm)
    btnOk: TBitBtn;
    LabelProgName: TLabel;
    LabelDesr: TLabel;
    LabelLic: TLabel;
    LabelMail: TLabel;
    LabelSite: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure LabelMailClick(Sender: TObject);
    procedure LabelSiteClick(Sender: TObject);


  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  FormAbout: TFormAbout;

implementation
//uses mainform;
{ TFormAbout }


procedure TFormAbout.FormCreate(Sender: TObject);
//var
//TC: array[1..1] of TComponent;
//PODirectory, Lang, FallbackLang: String;

begin
{
if CL<>nil then
   begin
   TC[1]:=FormAbout;
   fillProps(TC,CL);
   end;
   }
// Версия программы
LabelProgName.Caption:='mBackup ver '+TBackup.GetVer;

//PODirectory := 'D:\temp\lang\';
//GetLanguageIDs(Lang, FallbackLang); // определено в модуле gettext
//TranslateUnitResourceStrings('unitabout', PODirectory + 'mbackupw.%s.po', Lang, FallbackLang);

end;

procedure TFormAbout.LabelMailClick(Sender: TObject);
begin
ShellExecute(Handle,'open','mailto:atsave@narod.ru',nil,nil,SW_Normal);
end;

procedure TFormAbout.LabelSiteClick(Sender: TObject);
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


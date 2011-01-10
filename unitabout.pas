unit UnitAbout;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons,inilang;

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
TC: array[1..1] of TComponent;
begin
if CL<>nil then
   begin
   TC[1]:=FormAbout;
   fillProps(TC,CL);
   end;
// Версия программы
Label1.Caption:='AutoSave ver '+MForm.TaskCl.GetVer;
end;


initialization
  {$I unitabout.lrs}

end.


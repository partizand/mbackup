program AutoSave;

{$mode objfpc}{$H+}

uses
//  {$IFDEF UNIX}{$IFDEF UseCThreads}
//  cthreads,
//  {$ENDIF}{$ENDIF}
 Interfaces, // this includes the LCL widgetset
  Forms, LResources
  { add your units here }, mainform, taskunit, inilang, taskthread, frmtask,
  frmset, UnitAbout, SendMailUnit, lnetbase;

{$R AutoSave.res}

{$IFDEF WINDOWS}{$R AutoSave.rc}{$ENDIF}

begin
  {$I AutoSave.lrs}
  Application.Title:='AutoSave';
  Application.Initialize;
  Application.CreateForm(TMForm, MForm);
//  Application.CreateForm(TFormSet, FormSet);
//  Application.CreateForm(TFormTask, FormTask);
  Application.Run;
end.


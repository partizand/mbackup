program mbackupw;

{$mode objfpc}{$H+}

uses
//  {$IFDEF UNIX}{$IFDEF UseCThreads}
//  cthreads,
//  {$ENDIF}{$ENDIF}
 Interfaces, // this includes the LCL widgetset
  Forms, LResources
  { add your units here }, mainform,PoTranslator, taskunit{, taskthread, frmtask, frmset,}
  {UnitAbout, , setunit, unitfunc}
  {msgstrings, delfiles, customfs, filefs, ftpfs, logunit}{, frmftp};

{$R mbackupw.res}

{$IFDEF WINDOWS}{$R mbackupw.rc}{$ENDIF}

begin
  {$I mbackupw.lrs}
  Application.Initialize;
  Application.CreateForm(TMForm, MForm);
//  Application.CreateForm(TFormSet, FormSet);
//  Application.CreateForm(TFormTask, FormTask);
  Application.Run;
end.


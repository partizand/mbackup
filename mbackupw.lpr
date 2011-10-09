program mbackupw;

{$mode objfpc}{$H+}

uses
//  {$IFDEF UNIX}{$IFDEF UseCThreads}
//  cthreads,
//  {$ENDIF}{$ENDIF}
 Interfaces, // this includes the LCL widgetset
  Forms, mainform,PoTranslator, backup;

//{$R mbackupw.res}

{$IFDEF WINDOWS}{$R mbackupw.rc}{$ENDIF}

//{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMForm, MForm);
//  Application.CreateForm(TFormSet, FormSet);
//  Application.CreateForm(TFormTask, FormTask);
  Application.Run;
end.


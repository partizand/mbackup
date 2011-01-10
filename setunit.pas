unit setunit;

{$mode objfpc}{$H+}

// Класс настроек
interface

uses
  Classes, SysUtils,IniFiles,gettext,unitfunc;

type
  TSettings = class

  public
   constructor Create;
   destructor Destroy;
  logfile:  string; // Имя лог файла короткое
    loglimit: integer; // ограничение лог файла в килобайтах
   Lang: string; // Имя языкового файла

    LoadLastProf: boolean; // загружать последний профиль
    DefaultProf: string; // профиль по умолчанию при запуске программы
    profile:  string; // имя файла текущего профайла

    ArhTmpDir:string; // Каталог для создания временных архивов
    AppDir:string; // Каталог запуска программы
    // Настройки уведомлений по почте
    email:    string; // почтовый ящик на который отсылаются уведомления
    //  alerttype:integer; // Тип уведомлений (нет, ошибки, всегда, см константы)
    smtpserv: string;  // Адрес smtp сервера
    smtpport: integer; // порт сервера
    smtpuser: string;  // Пользователь сервера
    smtppass: string;  // Пароль
    mailfrom: string;
    Subj:string; // Тема письма
    Body:string; // Текст письма
    SysCopyFunc: boolean; // Использовать системную функцию копирования

    procedure ReadIni;
    procedure SaveIni;

  end;


implementation

constructor TSettings.Create;
begin
  inherited Create;
  ReadIni;
end;

destructor TSettings.Destroy;
begin
inherited Destroy;
end;

 //=====================================================
 // Чтение настроек программы из Ini файла
procedure TSettings.ReadIni;
//===================================================
var
  SaveIniFile: TIniFile;
  IniName:     string;
  Lang2:string;
begin
  IniName :=  ExtractFileDir(ParamStr(0))+DirectorySeparator+ 'mbackup.ini';// ExtractFileDir(ParamStr(0))+'\'+'autosave.ini';

  SaveIniFile := TIniFile.Create(IniName);
  logfile     := SaveIniFile.ReadString('log', 'logfile', 'mbackup.log');

  loglimit := SaveIniFile.ReadInteger('log', 'loglimit', 500);
  //IsClosing:=SaveIniFile.ReadBool('common', 'MinimizeToTray',true);
  //AutoOnlyClose:=SaveIniFile.ReadBool('common', 'AutoOnlyClose',false);
  //StartMin:=SaveIniFile.ReadBool('common', 'StartMinimized',false);
  // Язык
  //LangFile := SaveIniFile.ReadString('Language', 'LangFile', 'english.lng');
  Lang := SaveIniFile.ReadString('Language', 'Lang', '');

  if Lang='' then // язык не заполнен, типа автоопределяем
     begin
     GetLanguageIDs(Lang2, Lang);
     end;

  SysCopyFunc := SaveIniFile.ReadBool('settings', 'SysCopyFunc', True);
  ArhTmpDir:=SaveIniFile.ReadString('settings', 'ArhTmpDir', 'tmp');
  if ArhTmpDir<>'' then
     begin
     ArhTmpDir:=FullFileNam(ArhTmpDir);
     if (Not DirectoryExists(utf8toansi(ArhTmpDir)))  then
                 ForceDirectories(utf8toansi(ArhTmpDir));
     end;
  // настройка профилией
  LoadLastProf := SaveIniFile.ReadBool('profile', 'LoadLastProf', False);
  // загружать последний профиль
  DefaultProf  := SaveIniFile.ReadString('profile', 'DefaultProf', 'default.xml');
  profile      := DefaultProf;

  email    := SaveIniFile.ReadString('alerts', 'email', 'your@email');
  //alerttype:=SaveIniFile.ReadInteger('alerts', 'alerttype', alertNone);
  smtpserv := SaveIniFile.ReadString('alerts', 'smtpserv', 'smtp.server');
  smtpport := SaveIniFile.ReadInteger('alerts', 'smtpport', 25);
  smtpuser:=SaveIniFile.ReadString('alerts', 'smtpuser', '');
  smtppass:=SaveIniFile.ReadString('alerts', 'smtppass', '');
  mailfrom := SaveIniFile.ReadString('alerts', 'mailfrom', 'from@mail');
  subj := SaveIniFile.ReadString('alerts', 'subj', 'mBackup %Status% %Name%');
  Body:=SaveIniFile.ReadString('alerts', 'body', 'Task %Name% is %Status%');
  //TrayIcon.MinimizeToTray:=IsClosing;
  //TrayIcon.IconVisible:=IsClosing;
  //IsClosing:=Not (IsClosing);
  SaveIniFile.Destroy;// Free;
end;
 //=====================================================
 // Запись значений в Ini файл
procedure TSettings.SaveIni;
var
  SaveIniFile: TIniFile;
  //  cr:string;
  IniName, dp: string;
begin
  IniName     := ExtractFileDir(ParamStr(0)) + DirectorySeparator + 'mbackup.ini';
  SaveIniFile := TIniFile.Create(IniName);
  SaveIniFile.WriteString('log', 'logfile', logfile);
  SaveIniFile.WriteInteger('log', 'loglimit', loglimit);



  SaveIniFile.WriteString('alerts', 'email', email);
  //SaveIniFile.WriteInteger('alerts', 'alerttype', alerttype);
  SaveIniFile.WriteString('alerts', 'smtpserv', smtpserv);
  SaveIniFile.WriteInteger('alerts', 'smtpport', smtpport);
  SaveIniFile.WriteString('alerts', 'smtpuser', smtpuser);
  //cr:=CryptStr(smtppass);
  SaveIniFile.WriteString('alerts', 'smtppass', smtppass);
  SaveIniFile.WriteString('alerts', 'mailfrom', mailfrom);
  SaveIniFile.WriteString('alerts', 'subj', subj);
  SaveIniFile.WriteString('alerts', 'body', Body);
  // Язык
  //SaveIniFile.WriteString('Language', 'LangFile', LangFile);
  SaveIniFile.WriteString('Language', 'Lang', Lang);

  SaveIniFile.WriteBool('settings', 'SysCopyFunc', SysCopyFunc);
  SaveIniFile.WriteString('settings', 'ArhTmpDir',ShortFileNam(ArhTmpDir));

  SaveIniFile.WriteBool('profile', 'LoadLastProf', LoadLastProf);
  dp := DefaultProf;
  if LoadLastProf then
    dp := profile;
  SaveIniFile.WriteString('profile', 'DefaultProf', dp);
  SaveIniFile.Destroy;// Free;
end;

 //=======================================================

end.


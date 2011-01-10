unit PoTranslator;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, typinfo, Translations,IniFiles,gettext;



function ReadLang:string;


type

 { TPoTranslator }

 TPoTranslator=class(TAbstractTranslator)
 private
  FPOFile:TPOFile;
 public
  constructor Create(POFileName:string);
  destructor Destroy;override;
  procedure TranslateStringProperty(Sender:TObject;
    const Instance: TPersistent; PropInfo: PPropInfo; var Content:string);override;
 end;

implementation

{ TPoTranslator }

constructor TPoTranslator.Create(POFileName: string);
begin
  inherited Create;
  FPOFile:=TPOFile.Create(POFileName);
end;

destructor TPoTranslator.Destroy;
begin
  FPOFile.Free;
  inherited Destroy;
end;

procedure TPoTranslator.TranslateStringProperty(Sender: TObject;
  const Instance: TPersistent; PropInfo: PPropInfo; var Content: string);
var
  s: String;
begin
  if not Assigned(FPOFile) then exit;
  if not Assigned(PropInfo) then exit;
{Нужно ли нам это?}
  if Instance is TComponent then
   if csDesigning in (Instance as TComponent).ComponentState then exit;
{:)}
  if (AnsiUpperCase(PropInfo^.PropType^.Name)<>'TTRANSLATESTRING') then exit;
  s:=FPOFile.Translate(Content, Content);
  if s<>'' then Content:=s;
end;

function ReadLang:string;
var
SaveIniFile: TIniFile;
  IniName:     string;
  LangFile:string;
  Lang2:string;
  Lang:string; // Текущий язык
begin
  IniName := ExtractFileDir(ParamStr(0))+DirectorySeparator+ 'mbackup.ini';// ExtractFileDir(ParamStr(0))+'\'+'autosave.ini';

  SaveIniFile := TIniFile.Create(IniName);
  Lang:= SaveIniFile.ReadString('Language', 'Lang', '');
  SaveIniFile.Destroy;
  if Lang='' then // язык не заполнен, типа автоопределяем
     begin
     GetLanguageIDs(Lang2, Lang);
     end;
  // Ищем файл с переводами форм
  Lang2:=ExtractFileDir(ParamStr(0))+DirectorySeparator+'Lang'+DirectorySeparator+'mbackupw.'+Lang+'.po';
  if FileExists(Lang2) then
     LRSTranslator:=TPoTranslator.Create(ansitoutf8(ExtractFileDir(ParamStr(0)))+DirectorySeparator+'Lang'+DirectorySeparator+'mbackupw.'+Lang+'.po');
  // Ищем файл с переводами сообщений
 // Lang2:=ExtractFileDir(ParamStr(0))+DirectorySeparator+'Lang'+DirectorySeparator+'msgstrings.'+Lang+'.po';
//  if FileExists(Lang2) then
    // TranslateUnitResourceString ('msgstrings', Lang2);
     //TranslateUnitResourceString ('msgstrings', PODirectory + 'mbackupw.%s.po', Lang, FallbackLang);

end;

initialization
  {$I unitabout.lrs}
ReadLang;
{
  Lang     := ReadLang;
if (FileExists(ExtractFileDir(ParamStr(0))+DirectorySeparator+'Language'+DirectorySeparator+'mbackupw.'+Lang+'.po')) then
//if (FileExists('D:\temp\lang\mbackupw.'+Lang+'.po')) then
 LRSTranslator:=TPoTranslator.Create(ansitoutf8(ExtractFileDir(ParamStr(0)))+DirectorySeparator+'Language'+DirectorySeparator+'mbackupw.'+Lang+'.po');
 }
end.

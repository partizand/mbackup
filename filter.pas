unit filter;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,XMLCfg,filterprop;

type
  TFilter=class
    public
      constructor Create(RootDir:string);
      destructor Destroy; override;
      // Каталог необходимо обрабатывать, имя каталога полное
      function DirInRange(DirName:string):boolean;
      // Файл необходимо обрабатывать, имя каталога полное
      function FileInRange(FileName:string):boolean;
      procedure LoadFromFile(XMLConf:TXMLConfig;Section:string);
      procedure SaveToFile(XMLConf:TXMLConfig;Section:string);
      procedure Assign(SFilter:TFilter);
    private
      procedure SetRootDir(RootDir:string); // Установить корневой каталог


    private
      fpInclude:TFiltProp; // Фильтр включения
      fpExclude:TFiltProp; // Фильтр исключения
      _rootDir:string; // Корневой каталог фильтра
    public
      property RootDir:string read _rootDir write SetRootDir;

  end;

implementation
//------------------------------------------------------------------------------
constructor TFilter.Create(RootDir:string);
begin
inherited Create;
fpInclude:=TFiltProp.Create(RootDir);
fpExclude:=TFiltProp.Create(RootDir);
_rootDir:=RootDir;
end;
//------------------------------------------------------------------------------
destructor TFilter.Destroy;
begin
fpInclude.Free;
fpExclude.Free;
inherited Destroy;
end;
//------------------------------------------------------------------------------
procedure TFilter.Assign(SFilter:TFilter);
begin
fpInclude.Assign(SFilter.fpInclude);
fpExclude.Assign(SFilter.fpExclude);
_rootDir:=SFilter.RootDir;
end;

//------------------------------------------------------------------------------
// Каталог необходимо обрабатывать, имя каталога полное
function TFilter.DirInRange(DirName:string):boolean;
var
  InclMatch,ExclMatch:boolean;
begin
InclMatch:=(fpInclude.IsDirInRange(DirName)) or (fpInclude.IsEmpty);
ExclMatch:=fpExclude.IsDirInRange(DirName);
Result:=(InclMatch) AND (Not ExclMatch);
end;
//------------------------------------------------------------------------------
// Файл необходимо обрабатывать, имя файла полное
function TFilter.FileInRange(FileName:string):boolean;
var
  InclMatch,ExclMatch:boolean;
begin
InclMatch:=(fpInclude.IsFileInRange(FileName)) or (fpInclude.IsEmpty);
ExclMatch:=fpExclude.IsFileInRange(FileName);
Result:=(InclMatch) AND (Not ExclMatch);

end;
//------------------------------------------------------------------------------
// Прочитать из файла
procedure TFilter.LoadFromFile(XMLConf:TXMLConfig;Section:string);
var
  Sect:string;
begin
Sect:=Section+'/Filter/Include/';
fpInclude.LoadFromFile(XMLConf,Sect);
Sect:=Section+'/Filter/Exclude/';
fpExclude.LoadFromFile(XMLConf,Sect);
end;

//------------------------------------------------------------------------------
// Записать в файл
procedure TFilter.SaveToFile(XMLConf:TXMLConfig;Section:string);
var
  Sect:string;
begin
Sect:=Section+'/Filter/Include/';
fpInclude.SaveToFile(XMLConf,Sect);
Sect:=Section+'/Filter/Exclude/';
fpExclude.SaveToFile(XMLConf,Sect);
end;

//------------------------------------------------------------------------------
// Установить корневой каталог
procedure TFilter.SetRootDir(RootDir:string);
begin
fpInclude.RootDir:=RootDir;
fpExclude.RootDir:=RootDir;
_rootDir:=RootDir;
end;

end.


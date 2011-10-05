unit filter;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,filterprop;

type
  TFilter=class
    public
      constructor Create(RootDir:string);
      destructor Destroy; override;
      // Каталог необходимо обрабатывать, имя каталога полное
      function DirInRange(DirName:string):boolean;
      // Файл необходимо обрабатывать, имя каталога полное
      function FileInRange(FileName:string):boolean;
    private
      fpInclude:TFiltProp; // Фильтр включения
      fpExclude:TFiltProp; // Фильтр исключения
      _rootDir:string; // Корневой каталог фильтра
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

end.


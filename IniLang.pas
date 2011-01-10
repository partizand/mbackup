{IniLang v 0.9
Freeware unit for Delphi 4 projects, provided 'As Is'
Frédéric Sigonneau <aFas member> 24/04/1999
e-mail : frederic.sigonneau@wanadoo.fr

Since 0.9.1 contributed by Serge Korzhinski - www.snkey.net
v 0.9.1 - Support for TListView's Caption. Delphi 6+ support.
//v 0.9.2 - Support for DXbars, new Languages names.
v 0.9.3 - Support for dxfColorButton.
v.0.9.4 - Support for TListBox

IniLang can help you to build at design-time, in a single pass, a .ini file
filled with all properties and messages you have to localize for a
multilingual distribution based on ini files.
Useful for large projects including many forms and lot of messages
(and, you know, a little project grows very quickly!).
At run-time, allows you to change your interface localization 'on the fly', as
long as you translated the .ini file created with IniLang in as many languages
you want to be available. Yet, that's the only ::)))) job you have to do
by yourself.

I wrote that unit because the components or units written by Serge Sushko,
Aldo Ghigliano or José Maria Gías didn't exactly do what I needed  (ie less
work as possible!), but their ideas and their code helped me several times
to turn off some problems. So, thanks to all of them, they have their part in
that work.

Finally, please, read commentaries before use. Then try, there is no danger !
If you use and improve this unit, just send me a copy if possible. Thanks. FS}

{Copy this file in the directory of your project and add IniLang to
the 'uses' implementation clause of units which use it, as usual}
unit IniLang;

interface

uses SysUtils, Classes, Forms, stdCtrls, typInfo,
  extCtrls, iniFiles, Controls, comctrls;

const
 sep='*|*';   //separator for multiline messages
 FRA='French.ini';   FRENCH=2;
 ENG='English.ini';  ENGLISH=0;
 SPA='Spanish.ini';  SPANISH=1;
 CUS='Custom.ini';   CUSTOM=3;
 RUS='Russian.ini';  RUSSIAN=4;
 GER='German.ini';   GERMAN=5;
 UKR='Ukrainian.ini';UKRAINIAN=6;
 ITA='Italian.ini';  ITALIAN=7;

 //add what you want

var
  CL:TMemIniFile;   //Global variable for current language
   //must be inited in the onShow event of your main form.
   // Synthax : CL:=loadIni(XX);
   //where XX is the const name of the ini file you want to load.
   //You can use either a string or an integer const to load a language file.

//user procs
function loadLangIni(nom:string):TMemIniFile;overload;
function loadLangIni(ID:integer):TMemIniFile;overload;
procedure fillCustomIni;
procedure fillProps(TC:array of TComponent;ini:TMemIniFile);
function misc(VAL,KEY:string):string;

//utilities
procedure searchStr(var ini:TIniFile);
function getProp(comp:TComponent;prop:string):string;
procedure setProp(comp:TComponent;{const }prop,value:string);
function HasProperty(comp:TComponent;prop:string):boolean;
function str2IntID(s:string):integer;
function intID2Str(ID:integer):string;

implementation

function loadLangIni(nom:string):TMemIniFile;
var
 chemin:string;
begin
 chemin:=extractFileDir(application.exeName)+'\'+nom;
 if not fileExists(chemin) then Result:=nil
   else Result:=TMemIniFile.create(chemin);
end;

//other way for the same result
function loadLangIni(ID:integer):TMemIniFile;overload;
var
 chemin,nom:string;
begin
 case ID of
   -1:nom:='';
   FRENCH:   nom:=FRA;
   ENGLISH:  nom:=ENG;
   SPANISH:  nom:=SPA;
   CUSTOM:   nom:=CUS;
   RUSSIAN:  nom:=RUS;
   GERMAN:   nom:=GER;
   UKRAINIAN:nom:=UKR;
   ITALIAN:  nom:=ITA;
 end;
 chemin:=extractFileDir(application.exeName)+'\'+nom;
 if not fileExists(chemin) then
   Result:=nil
 else Result:=TMemIniFile.create(chemin);
end;

{Creates the original iniFile 'Custom.ini' and fills it first
with string properties and their values (captions, hints,
items -TRadioGroup and TComboBox-
and lines -TMemo and TRichEdit-  values).
One section for each form in the project.
Then fills a 'Misc' section with strings declared with 'const' or
'resourcestring' keywords (customized messages to inform your users or
properties dynamically renamed in your code).
Call 'fillCustomIni' from the onCreate event of the last created form
in your project.
At this time, ALL FORMS MUST BE IN THE 'AUTOMATICALLY
CREATED FORMS' list of your Project\Options\Forms tab .
Then just run form IDE (F9) and close your project, and it's done !}

procedure fillCustomIni;
var
 ini:TIniFile;
 i,j,k,l,m:integer;
 fiche,cmpt:TComponent;
 val,comp,nomComp,s:string;
begin
 ini:=TIniFile.create(extractFileDir(application.exeName)+'\'+CUS);
 // ñîçäàåì ôîðìû


 {First search the properties that will be translated}
 for i := 0 to application.ComponentCount - 1 do begin
   fiche:=application.Components[i];
   nomComp:=fiche.Name;
   if HasProperty(fiche,'Caption') and
      not (nomComp=getProp(fiche,'Caption')) then
      ini.writeString(nomComp,nomComp+'.Caption',getProp(fiche,'Caption'));
      for j:=0 to fiche.componentCount-1 do begin
      	cmpt:=fiche.Components[j];
        nomComp:=cmpt.name;
        //use a 'out' prefixed name if you want the component won't appear
        //in the list (ie : outLabel6:TLabel) so as the list won't be too big
        if copy(nomComp,1,3)='out' then continue;
{
      	if (cmpt is TdxfColorButton) then begin
          for k:=0 to TdxfColorButton(cmpt).Caption.count-1 do begin
            val:=TdxfColorButton(cmpt).Caption[k];
            if val=nomComp then break;
            comp:=nomComp+'.Lines['+intToStr(k)+']';
            ini.writeString(fiche.Name,fiche.Name+'.'+comp,val);
          end;
          continue;
        end;  }

        if HasProperty(cmpt,'Caption') and
          not (nomComp=getProp(cmpt,'Caption')) and
          not (getProp(cmpt,'Caption')='-') and
          not (getProp(cmpt,'Caption')='') then begin
            s:=getProp(cmpt,'Caption');
            if s[1]=' ' then begin
              s:=''''+s;
            end;
            if s[length(s)]=' ' then begin
              s:=s+'''';
            end;
  	    ini.writeString(fiche.Name,fiche.Name+'.'+nomComp+'.Caption',s);
          end;

        if HasProperty(cmpt,'Hint') and (getProp(cmpt,'Hint')<>'') then
          ini.writeString(fiche.Name,fiche.Name+'.'+nomComp+'.Hint',getProp(cmpt,'Hint'));

      	if (cmpt is TCustomMemo) then
          for k:=0 to TCustomMemo(cmpt).Lines.count-1 do begin
            val:=TCustomMemo(cmpt).Lines[k];
            if val=nomComp then break;
            comp:=nomComp+'.Lines['+intToStr(k)+']';
            ini.writeString(fiche.Name,fiche.Name+'.'+comp,val);
          end;

        if (cmpt is TRadioGroup) then
          for l:= 0 to TRadioGroup(cmpt).Items.Count-1 do begin
            val:=TRadioGroup(cmpt).Items[l];
            comp:=nomComp+'.Items['+IntToStr(l)+']';
            ini.writeString(fiche.Name,fiche.Name+'.'+comp,val);
          end;

        if (cmpt is TListView) then
          for m:=0 to TListView(cmpt).Columns.Count-1 do begin
            val:=TListView(cmpt).Columns[m].Caption;
            comp:=nomComp+'.Columns['+IntToStr(m)+'].Caption';
            ini.writeString(fiche.Name,fiche.Name+'.'+comp,val);
          end;

        if (cmpt is TComboBox) then
          for m:=0 to TComboBox(cmpt).Items.Count-1 do begin
            val:=TComboBox(cmpt).Items[m];
            comp:=nomComp+'.Items['+IntToStr(m)+']';
            ini.writeString(fiche.Name,fiche.Name+'.'+comp,val);
          end;
      end; //for
   end;
   {search for error or information messages stored as
   const or resourcestring - see below}
   searchStr(ini);
   ini.free;
end;

{Translates the forms you choose in the language called in ini.
Only created forms are translated with fillProps. Call it in the onShow
event of your main form whith names of all automatically created forms
at the start-up of your application in the TC parameter.
In runtime, call it when you create dynamically a form.
See demo for a sample}
procedure fillProps(TC:array of TComponent;ini:TMemIniFile);
var
   i,i2,i3,i4,tab:integer;
   comp,fiche:TComponent;
   s,s1,s2,s3,s4,s5:string;
begin
   with ini do
   for tab:=0 to high(TC) do
   begin
   	fiche:=TC[tab];
   	if fiche=nil then continue;
      s:=readString(fiche.name,fiche.name+'.Caption','');
      if s<>'' then begin
        if s[1]='"' then delete(s,1,1);
        if s[length(s)]='"' then delete(s,length(s),1);
        TForm(fiche).caption:=s;
      end;
      for i:=0 to fiche.componentCount-1 do
      begin
   		comp:=fiche.Components[i];

         s1:=readString(fiche.name,fiche.name+'.'+comp.name+'.Caption','');
         if s1<>'' then setProp(comp,'Caption',s1);

         s2:=readString(fiche.name,fiche.name+'.'+comp.name+'.Hint','');
         if s2<>'' then setProp(comp,'Hint',s2);

         if comp is TCustomMemo then
         	for i2:=0 to TCustomMemo(comp).lines.count-1 do
            begin
            	s3:=readString(fiche.name,
                  fiche.name+'.'+comp.name+'.lines['+intToStr(i2)+']','fsdef');
               //in TMemo or TRichEdit, you may have to leave some lines empty
               if s3<>'fsdef' then TCustomMemo(comp).lines[i2]:=s3;
            end;
{
         if comp is TdxfColorButton then
         	for i2:=0 to TdxfColorButton(comp).caption.count-1 do
            begin
            	s3:=readString(fiche.name,
                  fiche.name+'.'+comp.name+'.lines['+intToStr(i2)+']','fsdef');
               if s3<>'fsdef' then TdxfColorButton(comp).caption[i2]:=s3;
            end;
 }
         if comp is TRadioGroup then
         	for i3:=0 to TRadioGroup(comp).items.count-1 do
            begin
            	s4:=readString(fiche.name,
                  fiche.name+'.'+comp.name+'.items['+intToStr(i3)+']','');
               if s4<>'' then TRadioGroup(comp).items[i3]:=s4;
            end;

      	if comp is TComboBox then
         	for i4:=0 to TComboBox(comp).items.count-1 do
            begin
            	s5:=readString(fiche.name,
               	fiche.name+'.'+comp.name+'.items['+IntToStr(i4)+']','');
            	if s5<>'' then TComboBox(comp).items[i4]:=s5;
            end;

      	if comp is TListBox then
         	for i4:=0 to TListBox(comp).items.count-1 do
            begin
            	s5:=readString(fiche.name,
               	fiche.name+'.'+comp.name+'.items['+IntToStr(i4)+']','');
            	if s5<>'' then TListBox(comp).items[i4]:=s5;
            end;

      	if comp is TListView then
         	for i4:=0 to TListView(comp).Columns.count-1 do
            begin
            	s5:=readString(fiche.name,
               	fiche.name+'.'+comp.name+'.Columns['+IntToStr(i4)+'].Caption','');
            	if s5<>'' then TListView(comp).Columns[i4].Caption:=s5;
            end;
        end;
   end;
end;

{Translates a miscellaneous message in the current language.
The VAL parameter is the identification name of your string in a const or
resourcestring section in any file of your project.
The KEY parameter is the keyname of your string in the 'Misc' ini file section.
VAL value is used if no ini language file is present or loaded
ie it's your design-time language).
KEY is used otherwise to display the message in the current ini language.
Synthax : showMessage(misc(Msg21,'Msg21'));
This function uses the separator *|* to restore multiline messages}

function misc(VAL,KEY:string):string;
var
	res,tempRes:string;
   TS:array of string;
   x:integer;
begin
	if CL=nil then
   begin
   	result:=VAL;
      exit;
   end;

   res:=CL.readString('Misc',KEY,'');
   if res='' then
     begin
     result:=Val;
     exit;
     end;
   if pos(sep,res)=0 then  //single line text
   	result:=res
   else
   begin
      setLength(TS,15);  //increase this value if necessary for you
   	x:=low(TS);
      tempRes:='';
      repeat
      	TS[x]:=copy(res,1,pos(sep,res)-1);
         if tempRes='' then tempRes:=TS[x]
         //else tempRes:=tempRes+#13#10+TS[x];
         else tempRes:=tempRes+TS[x];
         res:=copy(res,pos(sep,res)+3,length(res));
      until pos(sep,res)=0;
      TS:=nil;
      //tempRes:=tempRes+#13#10+res;
      tempRes:=tempRes+res;
      //tempRes:= AnsiToUtf8(tempRes);
      //tempRes:= Utf8ToAnsi(tempRes);
      //result:=Utf8ToAnsi(tempRes);
      result:=tempRes;
   end;
end;

{Your text strings must be stored in 'const' or 'resourcestring' sections
in your source files to be found by this procedure and saved in the ini file.
Prepare a little bit your code to make the job easier. For instance don't
write : 'if edit1.text='' then'
but : 'if edit.text= '' then' (with a space between = and the first ')
Strings with CR/LF (#13#10) will be saved in a unique key value, the different
lines of the message being separated by a *|* sequence}

procedure searchStr(var ini:TIniFile);
var
	rep:string;
	sr:TSearchRec;
   F:TextFile;
   line,ligne,temp,tempL:string;
   strList:TStringList;
   x,y:integer;
begin
	rep:=extractFileDir(application.exeName)+'\';
   strList:=TStringList.create;

   {Search string resources in pas files}
	if findFirst(rep+'msgstrings.pas',faAnyFile,sr)=0 then
   	repeat
      	if (sr.name='IniLang.pas') then findNext(sr);
      	assignFile(F,sr.name);
         reset(F);
			while not eof(F) do
         begin
         	readln(F,line);
            line:=trim(line);
            //look for string resources ie =' sequences
            if pos('=''',line)>0 then strList.add(line);
            //look if the line is a part of a multiline message
            //ie ' (single quote), + or # at the beginning of the line.
            //add what you want if I forgot something you need for.
            //put a {} sequence at the beginning of a line you don't
            //want to be added in the file.
            if (pos('''',line)=1) or (pos('+',line)=1) or
            	(pos('#',line)=1) then
               strList.add('bis'+line); //'bis'-->temporary prefix for
         end;                           //multiline strings
         closeFile(F);
         fileClose(sr.findHandle);
      until findNext(sr)<>0;
   findClose(sr);

   //copy multiline messages on a unique key value
   for x:=strList.count-1 downto 0 do
      if pos('bis',strList[x])=1 then
      begin
      	tempL:=strList[x];
      	tempL:=strList[x-1]+copy(tempL,4,length(tempL));
         strList[x-1]:=tempL;
         strList.delete(x);
         continue;
      end;

   {Deletes useless caracters in ini string format --> ; ' ''
   Also separates multilines messages with the *|* separator}
   for x:=0 to strList.count-1 do
   begin
   	ligne:=strList[x];
      delete(ligne,length(ligne)-1,2);
      delete(ligne,pos('=',ligne)+1,1);
      if pos('''''',ligne)>0 then
      	repeat
      		delete(ligne,pos('''''',ligne),1);
         until pos('''''',ligne)=0;
      strList[x]:=ligne;
      temp:=strList.values[strList.names[x]];
      if pos('''+',temp)=0 then
      	ini.writeString('Misc',strList.names[x],temp)
      else
      begin
      	repeat
      		y:=pos('''+',temp);
         		repeat
            		delete(temp,y,1);
            	until temp[y]='''';
         	temp:=copy(temp,1,y-1)+sep+copy(temp,y+1,length(temp));
      	until pos('''+',temp)=0;
      	ini.writeString('Misc',strList.names[x],temp);
   	end;
   end;

   strList.free;
end;

//Backs up the prop property value of the comp component
function getProp(comp:TComponent;prop:string):string;
var
 ppi:PPropInfo;
begin
 ppi:=getPropInfo(comp.classInfo,prop);
 if ppi<>nil then Result:=getStrProp(comp,ppi)
   else Result:='';
end;

//Assign the value value to prop property of comp component
procedure setProp(comp:TComponent;{const }prop,value:string);
var
 ppi:PPropInfo;
begin
 if value<>'' then begin
   ppi:=getPropInfo(comp.classInfo,prop);
   if ppi<>nil then begin
     if value[1]='"' then delete(value,1,1);
     if value[length(value)]='"' then delete(value,length(value),1);
     setStrProp(comp,ppi,value);
   end;
 end;
end;

//True if prop property exists for comp component
function HasProperty(comp:TComponent;prop:string):boolean;
begin
 result:=(getPropInfo(comp.classInfo,prop)<>nil) and (comp.name<>'');
end;

//Converts a const string language name into a const integer language name
function str2IntID(s:string):integer;
begin
 Result:=-1;
 if s=ENG then Result:=ENGLISH       //0
 else if s=SPA then Result:=SPANISH  //1
 else if s=FRA then Result:=FRENCH   //2
 else if s=CUS then Result:=CUSTOM   //3
 else if s=RUS then Result:=RUSSIAN  //4
 else if s=GER then Result:=GERMAN   //5
 else if s=UKR then Result:=UKRAINIAN//6
 else if s=ITA then Result:=ITALIAN  //7
end;

//Converts a const integer language name into a const string language name
function intID2Str(ID:integer):string;
begin
 Result:='';
 if ID=0 then Result:=ENG
 else if ID=1 then Result:=SPA
 else if ID=2 then Result:=FRA
 else if ID=3 then Result:=CUS
 else if ID=4 then Result:=RUS
 else if ID=5 then Result:=GER
 else if ID=6 then Result:=UKR
 else if ID=7 then Result:=ITA
end;

end.

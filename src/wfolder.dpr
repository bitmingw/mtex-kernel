{$APPTYPE CONSOLE}
uses windows,messages,kol,shellapi;{$I w32.pas}
const usage='��;����ȡϵͳ�����ļ��е�·���������˳�򱣴����ļ�wfolder.sav��'+CR
	+'��ʽ: WFOLDER [path1] [path2] ...'+CR
	+'ÿ��·������$Desktop,$SendTo,$Programs,$Startup,$Start Menu�ȿ�ͷ��';
var res,s:string;i:integer;


function Expand_Dir(s:string):string;
var d,r:string;i:integer;
begin;
Result:=s;
if pos('$',s)=1 then 
  begin;
  i:=pos('\',s);
  if i<1 then i:=Length(s)+2;
  if i>2 then 
	begin;
    d:=copy(s,2,i-2);
    delete(s,1,i-1);
    r:=GetSysDir(d);
    Result:=FileShortPath(r)+s;
    end;
  end;
end;
	
begin;
if ParamCount=0 then begin;msgok(usage);Halt(1);end;
res:='';s:='';
for i:=1 to ParamCount do begin;s:=ParamStr(i);res:=res+Expand_Dir(s)+CR;end;
StrSaveToFile('wfolder.sav',res);
write(res);
end.

uses
  windows,messages,kol,shellapi;{$I w32.pas}
var h:HWnd;param:Longint;i:integer;f:string;fs:PStrList;
const 
usage='������[mhb]��Windows�����ļ������ڴ档'+CR
+'��ʽ1��WFont �����ļ��� [�����ļ�Ŀ¼]'+CR
+'��ʽ2��WFont @�����б��ļ� [�����ļ�Ŀ¼]';

procedure Help;
begin;
msgOK(usage);halt(0);
end;

procedure AddFont(f:PChar);
begin;
  AddFontResource(f);
  SendMessage (HWND_BROADCAST, WM_FONTCHANGE, 0, 0);
end;

begin;
  fs:=NewStrList;
  if ParamCount=0 then Help;

  if ParamCount=2 then ChDir(ParamStr(2));
  f:=ParamStr(1);
  if not (f[1]='@') then fs.Add(f) else begin;Delete(f,1,1);fs.LoadFromFile(f);end;
  for i:=0 to fs.Count do 
	  begin;f:=fs.Items[i];AddFont(PChar(f));end;
end.
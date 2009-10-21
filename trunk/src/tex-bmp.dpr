{
v0.98: ʹ��ϵͳĬ������
v0.97: ʹ���°�cct��֧�����ģ���״̬����Ĭ��ģ���������Ϊ��Դ����ѧ���ż���TMac
v0.95: ֧��ͨ�������ļ��޸������С������
v0.90:�����Խ��棬��ͨ�������ļ��޸Ľ������ԣ�ini�ļ���ʽ�ı䣬��ʹ������
v0.85:XP����������ɴӻ�������ETCָ����Ŀ¼�������ļ�������dvipng֧��??
v0.80:��������������ʱ�Ĺ�ʽ��ʾ����Ĳ�������ʾ�����ӵ�����ʾ�����ݡ�
v0.75:��������ɫ���ܣ���ʱ�ļ���Ϊ��ʱĿ¼�����ɡ�
}
{$D SMALLEST_CODE} //{$R MTeX.res}
program tex_bmp;
{$R tex-bmp.res}
uses
  windows,messages,kol,xptheme,CommCtrl,shellapi;

{$I w32.pas}

resourcestring
  DefTex2ps='@echo off'+CR  
    +'if exist %1.ctx        cct %1.ctx'+CR
    +'if exist %1.ty         tyc -d%_Res%  %1.ty'+CR
    +'call %_Cmd% %1'+CR
    +'if not exist %1.dvi    goto END'+CR
    +'if exist %1.ty         pkttf -d%_Res%'+CR
    +'if not exist %1.ctx    goto next'+CR
    +'copy %1.dvi ~tmp.dvi'+CR
    +'patchdvi ~tmp.dvi %1.dvi -r%_Res% -y'+CR
    +'rem or: cdvia  ~tmp.dvi %1.dvi -P %PKDIR% -r %_Res%'+CR
    +'del ~tmp.dvi'+CR
    +':next'+CR
    +'call makepk %1.dvi -r%_Res%'+CR
    +'if %_Bmp%==bmpmono       call dvi2bmp %1 %1.bmp /r%_Res%'+CR
    +'if not exist %1.bmp      call dvips -D %_Res% -E %1'+CR
    +':END';
	
  DefTemplate=
    '\documentclass{article}\pagestyle{empty}'+CR
    +'\usepackage{latexsym,amssymb,amsmath,amsbsy,amsopn,amstext,color}'+CR
	+'\b'+'egin{document}'+CR+CR
	+'\e'+'nd{document}'+CR;

const
  CS=#12;fn='_tex_bmp';fn_ini='tex-bmp.ini';
  f_tmp='_tex_tmp.bat';latexmac='tmac.exe';  
  ctex='\ctex\texmf\miktex\bin';emtex='\emtex';
  DefPaths=ctex+';'+emtex;


var 
  App,W,P1,M1,M2,B_1,B_2,B_3,B_4,B_5,B_6,CB3,B_7,B_8,B_9,B_10,B_11,CB1,CB2,CB4,C1,C2,C3,C4,L0,L1,L2,B1,B3,B2,B4,PB:PControl;
  OpenDialog1,SaveDialog1,OpenDialog2: TOpenSaveDialog;
  ColorDialog1: TColorDialog;
  exepath,tmp,comspec,ext,template,cmd,tex2ps,paths,editor,f_ini: string;
  idx: integer;
  TeXList,codes:TStrList;
  Image1,Image2:PBitmap;
  Ini:PIniFile;
  TT:HWND;ti: TOOLINFO;hint:string;TipVisible:boolean;


procedure ReadIni;
var s_ini,s_nam,s_sec,s_key,s_val:string;
begin;
  s_ini:=StrLoadFromFile(f_ini);ParseIniHead(s_ini);
  repeat 
    ParseIniSec(s_ini,s_nam,s_sec);//msgok(s_nam);msgok(s_sec);
	if s_nam='tex2ps' then tex2ps:=s_sec
	else if s_nam='Template' then template:=s_sec
	else if s_nam='Settings' then
		repeat 
			ParseIniStr(s_sec,s_key,s_val);
			if s_key='Comspec' then comspec:=s_val
			else if s_key='Res' then CB2.Text:=s_val
			else if s_key='Format' then CB3.Text:=s_val
			else if s_key='Paths' then paths:=s_val
			else if s_key='Editor' then editor:=s_val;
		until s_sec='';
  until s_ini='';
end;

procedure WriteIni;
var s:string;
begin;
  s:='[Settings]'+CR
+'Res='+CB2.Text+CR
+'Format='+CB3.Text+CR
+'Paths='+paths+CR
+'Editor='+editor+CR
+'[tex2ps]'+CR
+tex2ps+CR
+'[Template]'+CR
+template{+CR};
StrSaveToFile(f_ini,s);
{
  SetIniStr(f_ini,'Settings','Res',CB2.Text);
  SetIniStr(f_ini,'Settings','Format',CB3.Text);
  SetIniStr(f_ini,'Settings','Paths',paths);
  SetIniStr(f_ini,'Settings','Editor',editor);
  SetIniSec(f_ini,'tex2ps',tex2ps);
  SetIniSec(f_ini,'Template',template+CR);
}
end;			

function MikPaths(i:integer):string;
var k:HKEY;
begin;
  k:=RegKeyOpenRead(HKEY_LOCAL_MACHINE,'SOFTWARE\MiK\MiKTeX\CurrentVersion\MiKTeX');
  Result:=RegKeyGetStrEx(k,'Install Root');
  if (Length(Result)=0) or (i=0) then Exit;
  if i=1 then Result:=Result+'\miktex\bin';
end;

  
procedure B_MouseMove(dummy:Pointer;Sender: PControl;var Mouse: TMouseEventData);
var  P:TPoint;i,dy:integer;
begin
  W.SimpleStatusText:=PChar(Sender.CustomData);
end;
  


procedure B_11Click(Dummy:Pointer; Sender: PControl);
begin;
  WriteIni;
end;



procedure GetBBox(s:string;var b1,b2,b3,b4:integer);
const boundbox='%%BoundingBox:';
var i:word;
begin
b1:=-1;
i:=pos(boundbox,s);
if i=0 then ShowMessage('û�ҵ� bounding box.'
  +' ��������TeX���롢�������Tex2ps����(����dvipsʱ�����ѡ�� -E)��·������(gswin32c).');
if i=0 then exit;
i:=i+ length(boundbox)+1;
b1:=get_num(s,i);
b2:=get_num(s,i);
b3:=get_num(s,i);
b4:=get_num(s,i);
//ShowMessage(Format('%d,%d,%d,%d',[b1,b2,b3,b4]));
end;

procedure CleanFiles;
begin;
    DeleteFile(f_tmp);
    DeleteFile(PChar(fn+'.bmp'));
    DeleteFile(PChar(fn+'.tex'));
    DeleteFile(PChar(fn+'.aux'));
    DeleteFile(PChar(fn+'.log'));
    DeleteFile(PChar(fn+'.dvi'));
    DeleteFile(PChar(fn+'.ctx'));
    DeleteFile(PChar(fn+'.ty'));
    DeleteFile(PChar(fn+'.ps'));
    DeleteFile(PChar(fn+'.bb'));
end;

procedure MakeBmp;
var
  fac:real;s:string;
  b1,b2,b3,b4:integer;
begin
  ChDir(tmp);  
  CleanFiles;
  if C2.Checked then ShowMessage('�����ļ��У�'+tmp);
  if C2.Checked then ShowMessage('��ִ���ļ�����·��Ϊ��'+GetEnv('PATH'));
  if (Pos('{cct',M1.Items[0])>0) and (Pos('CJK',M1.Items[0])=0) then ext:='.ctx' 
  else if Pos('\input tyinput',M1.Text)>0 then ext:='.ty'
  else ext:='.tex';
  StrSaveToFile(fn+ext,M1.Text);
  if Pos('\b'+'egin{document}',M1.Text)=0 then cmd:='tex' else cmd:='latex';
  s:='@set _Res='+CB2.Text+CR
    +'@set _Bmp='+CB3.Text+CR
    +'@set _Cmd='+cmd+CR
    +tex2ps+CR
    +'if exist %1.ps  '+'gswin32c.exe -dNOPAUSE -dBATCH -sDEVICE=bbox -sOutputFile=- %1.ps > %1.bb'+CR;
  StrSaveToFile(f_tmp,s);
  if C2.Checked then ShowMessage('�������������['+comspec+' '+f_tmp+' '+fn+']'+CR+s);
//  WinExec(PChar(comspec+' ' +f_tmp+' '+fn),SW_SHOW);Sleep(2000);
  Shell(comspec+' ' +f_tmp+' '+fn,SW_SHOW,true);
  //ExecuteWait('',comspec+' ' +f_tmp+' '+fn,'',SW_SHOW,INFINITE,nil);
  if FileExists(fn+'.bmp') then exit
  else if C2.Checked then ShowMessage('û�з����ļ� '+fn+'.bmp��');
  s:=StrLoadFromFile(fn+'.bb')+StrLoadFromFile(fn+'.ps');
  GetBBox(s,b1,b2,b3,b4);//Inc(b3,8);//Inc(b4,4);
  if b1>=0 then 
    begin;
    fac:=4.167*Str2Double(CB2.Text)/300.0;
    cmd:='gswin32c  -q -dNOPAUSE -dBATCH'+
      ' -sDEVICE='+CB3.Text
      +' -r'+CB2.Text
      +' -sOutputFile='+fn+'.bmp '
      +' -g'+Int2Str(round((b3-b1)*fac))+'x'+Int2Str(round((b4-b2)*fac))
      +' -c -'+Int2Str(b1)+' -'+Int2Str(b2)+' translate  -q '
      +fn+'.ps';
    if C2.Checked then begin;ShowMessage('�������������['+comspec+' '+cmd+']'+CR+s);end;
    ExecuteWait('',comspec+' ' +cmd,'',SW_SHOWMINIMIZED,INFINITE,nil);
    end;
end;

procedure TransBmp;
var i,j:integer;c:TColor;dc:HDC;
begin;Image2.Assign(Image1);
if C3.Checked then
with Image1^ do
  begin
  //Image2.Width:=Width;Image2.Height:=Height;Image2.PixelFormat:=PixelFormat;
  c:=DIBPixels[0,0];Image2.PixelFormat:=pf24bit;
  for i:=0 to Width-1 do
    for j:=0 to Height-1 do
      if DIBPixels[i,j]=c then Image2.DIBPixels[i,j]:=L0.Color
      else Image2.DIBPixels[i,j]:=L0.Font.Color;
  end;
end;




procedure ChooseTEX(i:integer);
begin;
	M1.Text:=Trim(TeXList.Items[i-1]);
	CB1.Text:=Int2Str(i);
end;



procedure DrawBmp;
begin;
  if Image1.Empty then exit;
  TransBmp;Image2.CopyToClipboard;
  PB.Width:=Image2.Width;
  PB.Height:=Image2.Height;
  PB.Visible:=true;
//  PB.Canvas.CopyRect(PB.ControlRect,W.Canvas,B1.ControlRect);
//	W.Canvas.CopyRect(PB.ControlRect,W.Canvas,B1.ControlRect);

end;

procedure paint(dummy:pointer;sender:pcontrol;DC:HDC);
var r:TRect;
begin
  //r:=Image2.BoundsRect;Image2.StretchDraw(DC,PB.BoundsRect);//PB.Canvas.CopyToClipboard;
  if Image2.Width>0 then Image2.Draw(DC,0,0);//  Image1.StretchDraw(DC,B1.BoundsRect);
end;



procedure B_1Click(Dummy:Pointer; Sender: PControl);
begin;
  if M2.Visible then 
    begin 
    B_10.Caption:='�趨����'; M2.Visible:=false;
    if ShowMsg('�������޸��˵�ǰ����,Ӧ�ò����浱ǰ����?', MB_YESNO)=ID_YES then
       begin tex2ps:=M2.Text;B_11Click(Dummy,Sender);end
    end;
  MakeBmp;
  if FileExists(fn+'.bmp') then
    begin;
    Image1.Dormant;Image2.Dormant;
    Image1.LoadFromFile(fn+'.bmp');
    DrawBmp;// msgok('xx');  
    TeXList.Add(M1.Text+CS);
    idx:=TeXList.Count;
    CB1.Add(Int2Str(idx));
    CB1.Text:=Int2Str(idx);
    if CB4.Text<>'' then SendTo(CB4.Text);
    end;
  if not C2.Checked  then CleanFiles;
end;

procedure B_2Click(Dummy:Pointer; Sender: PControl);
begin
M1.Text:=template;
//M1.CaretPos:=Point(0,3);
M1.Focused:=true;
Image1.Width:=0;
end;

procedure B_3Click(Dummy:Pointer; Sender: PControl);
begin
template:=M1.Text;
end;


procedure B_4Click(Dummy:Pointer; Sender: PControl);
begin
idx:=idx-1;if idx<1 then idx:=TeXList.Count;
ChooseTEX(idx);Image1.Clear;
end;


procedure S_Split(var L:TStrList;s:string);
var i1,i2:integer;
begin;
i1:=1;i2:=1;idx:=1;L.Clear;CB1.Clear;
repeat
  i2:=PosEx(CS,s,i1);if i2=0 then break;
  L.Add(Copy(s,i1,i2-i1+1));
  CB1.Add(Int2Str(idx));
  Inc(idx);  i1:=i2+1;
until false;
end;

procedure B_5Click(Dummy:Pointer; Sender: PControl);
begin
SaveDialog1.Title:='���Ϊ��';
SaveDialog1.DefExtension:='txl';
if SaveDialog1.Execute then
  if pos('.txl',SaveDialog1.FileName)=0 then
    StrSaveToFile(SaveDialog1.FileName,M1.Text)
  else
    StrSaveToFile(SaveDialog1.FileName,TeXlist.Text);
//DrawBmp;
end;


procedure B_6Click(Dummy:Pointer; Sender: PControl);
var i1,i2:integer; s:string;
begin
OpenDialog1.Title:='�򿪣�';
if OpenDialog1.Execute then
  if pos('.txl',OpenDialog1.FileName)=0 then
    M1.Text:=StrLoadFromFile(OpenDialog1.FileName,)
  else
    begin;s:=StrLoadFromFile(OpenDialog1.FileName);
    S_Split(TeXList,s);ChooseTeX(1);end;
//DrawBmp;   
end;

procedure CB1Change(Dummy:Pointer; Sender: PControl);
begin
ChooseTEX(Str2Int(CB1.Text));
end;




function SearchTreeForFile(RootPath,InputPathName,OutputPathBuffer:PChar):BOOL;stdcall;external 'imagehlp.dll';

function SearchFile(f,d:string):string;
var buf:LPSTR;
begin
buf:=AllocMem(255);
SearchTreeForFile(PChar(d),PChar(f),buf);
Result:=buf;FreeMem(buf);
end;

function GetDir(f:string;search:boolean):string;
begin{
if search then
  begin
  //Result:=SearchFile(f,'c:\');
  //if Result='' then Result:=SearchFile(f,'d:\');
  end
else}
  with OpenDialog2 do
  begin
  Title:='��ѡ���ļ��У�';
  Filter:='��ִ���ļ�('+f+')|'+f;Filename:=f;
  if Execute then Result:=Filename;
  end;
Result:=ExtractFilePath(Result);
end;


procedure B_9Click(Dummy:Pointer; Sender: PControl);
var s:string;
begin
  msgOk('�������Ҫ�õ�latex��dvips��gswin32c�������ֱ�ָ����·����');
  s:=GetDir('gswin32*.exe',false)+';'
    +GetDir('tex*.exe',false)+';'
    +GetDir('dvips*.exe',false);
if ShowMsg('�������н�ʹ������·����'+s+CR, MB_YESNO)=ID_YES then
  begin;paths:=s;SetEnvironmentVariable('PATH',PChar(s+';'+GetEnv('Path')));end
end;

procedure B_10Click(Dummy:Pointer; Sender: PControl);
begin
M2.Visible:=not M2.Visible;
if M2.Visible then
  begin B_10.Caption:='Ӧ��';M2.Text:=tex2ps;end
else
  begin B_10.Caption:='�趨����';tex2ps:=M2.Text;end
end;


procedure B_7Click(Dummy:Pointer; Sender: PControl);
begin
ShowMessage(
'���������ΪTexPoint�����Ʒ�������÷�Χ���㷺��'
+'��ʹ����LaTeX/TeXǿ����Ű湦�ܣ��ر�����ѧ��ʽ���������ڸ����ĵ���'
+'TexPointʹ�ñȽϷ��㣬��ֻ����Office2000�д���PowerPointʹ�ã�'
+'����ǰ����Ҫ��ϵͳװ��VBA��'
+'�������������κ�֧��ͼƬճ���������ϣ���Ȼ����'
+'д�ְ�/Word/Excel/PowerPoint/WpsOffice/CCED2000/FrontPage/Maple/���������ڻ�����:)'+CR+CR

+'���б����ֻ��װ��LaTeX,dvips��GhostScript����Щ������CTEX��װ���ˣ���'
+'����ҪVBA��֧�֣�����������е�Office97����棨������ȫ��ֻռ��20���״��̿ռ䣩�������ִ�������ﶼ��������LaTeX�ˣ��Ǻǡ�����'
+'�����ͬʱ֧��CJK��CCT����Ԫ����������LaTeX������TexPoint�������ġ�'
+'˳����һ�䣬��TexPoint�����Ļõ�Ƭ�ļ��Ƚϴ󣬶��ñ����������ñȽ�С��'
+'�����Ϊ��ɫ���������Ҫ��װ�������С����ֱ�����С�'
+'���⣬����������������LaTeX macros��������ʹ�ã�'+CR+CR

+'��һ��ʹ��ʱ���ǵ�Ҫ������Щ��Ҫ���趨Ӵ��'
+'���latex,dvips,gswin32c�⼸�������ϵͳ������·�����ˣ����Ե� [�趨·��] ����һ�£�'
+'�������У�����Ҫ�ٵ� [�趨����] ��һ���趨һ����ô��.tex�ļ�ת����.ps�ļ��'
+'�������˵� [Ӧ��] ʹ������Ч����'
+'���úú�û������Ļ������ű�������Ӵ��'+CR+CR

+'����ʹ�ã�̫������'
+'���ұߵĿ��ｫ���LaTeX����ճ����������ֱ���ý�ȥ����'
+'Ȼ��� [�����λͼ] ����Щ���뽫���Զ����룬'
+'û�д���Ļ����Զ�����һ��ͼƬ����������Ԥ�����������ڼ������'
+'�������������ֻҪճ��һ�£�һ�㰴Ctrl+V�Ϳ��ԣ������ˣ�'
+'�������鷳��ѡ��������ĳ����б��Ϳ����Զ���ͼƬ������Ӧ�ĳ���'
+CR+CR

+'��������ɫ����������ȷ�Ϲ���[��ɫ]ѡ�Ȼ��ֱ������������Ҽ���� [abc]����ʲôЧ��������������һ�аɣ�'
+'��document���������룺\pagecolor{blue}\color{red}$\sqrt{2}=?$�����Կ��õ���ʲô����'+CR+CR

+'��������ĸ��ȥ���Ǿ͵��[��/Ӣ]����ʱ���Ϳ���ʹ�������ˣ��������롰\kaishu ���ġ�����Ч���� '
+CR+CR

+'���˻��ʣ�����ǰ���ɵ�λͼ�����ٴα༭��û���⣡'
+'����������һ���õ�Ƭ����Ҫ�ܶ���ѧ��ʽ�����Ƕ��ɱ�������ɣ�'
+'Ȼ���ַ����еĹ�ʽ��Ҫ���޸ģ���ô�죿'
+'���ϵ� [����] ����������б���ֱ��ѡ��ʽ�ı�ţ��Ϳ����ҵ�����Ҫ�Ĺ�ʽ�ˣ�'
+'���±༭���ٴα���Ϳ����ˣ���Ȼ�Ժ������������Щ��ʽ��'
+'�����˵� [��Ϊ] �����Ǵ��̣��Ժ󻹿ɵ�����������Ǻ�ϰ�߰���'+CR+CR

+'�����Ĺ��ܣ��Լ���Ħ�ɣ�ʵ�ڲ������ĸ���ť��ʲô�ã������������ͣ��һ�ᣬ���и���̵Ĺ�����ʾӴ��'+CR+CR
);
end;


procedure B_8Click(Dummy:Pointer; Sender: PControl);
begin
ShowMessage(
 'TeXλͼ���� version 0.98'+CR+CR
+'��ӭ���LaTeX/TeX�û����ʹ�á�'+CR+CR
+'��Ȩ���� 2004--2008 ������'+CR
+'     '+CR
+'���߱����Ա����������Ȩ����'+CR
+'����������飬�뵽MTeX-suite��̳���ۡ�'+CR
+'E-mail: mtex-suite@googlegroups.com'+CR
);
end;



procedure C1Click(Dummy:Pointer; Sender: PControl);
begin
W.StayOnTop:=C1.Checked;
end;

procedure FormResize(Dummy:Pointer; Sender: PControl);
begin
M1.Width:=W.Width-M1.Left-2;
M2.Width:=M1.Width;
M2.Height:=W.Height-M2.Top-10;
DrawBmp;
end;



procedure L0MouseDown( Dummy : Pointer; Sender : PControl; var Mouse : TMouseEventData );
begin
if Mouse.Button=mbLeft then
  begin
  ColorDialog1.Color:=L0.Color;
  if ColorDialog1.Execute then L0.Color:=ColorDialog1.Color;
  end
else
  begin
  ColorDialog1.Color:=L0.Font.Color;
  if ColorDialog1.Execute then L0.Font.Color:=ColorDialog1.Color;
  end;
DrawBmp;
end;

procedure B3MouseDown( Dummy : Pointer; Sender : PControl; var Mouse : TMouseEventData );
begin
if Mouse.Button=mbLeft then
  begin
  StrSaveToFile(fn+'.tex',M1.Text);
  shell(editor+' '+fn+'.tex',SW_SHOW,true);
  M1.Text:=StrLoadFromFile(fn+'.tex');
  end
else
  begin
  OpenDialog2.Filter:='��ִ���ļ�(*.exe;*.com;*.bat;*.cmd)|*.exe;*.com;*.bat;*.cmd';
  if OpenDialog2.Execute then editor:=OpenDialog2.FileName;
  end;
//DrawBmp;
end;

Function EnumWindowsProc (Wnd: HWND; LParam: LPARAM): BOOL; stdcall;
begin
Result := True;
if (IsWindowVisible(Wnd) or IsIconic(wnd)) and
((GetWindowLong(Wnd, GWL_HWNDPARENT) = 0) or
(GetWindowLong(Wnd, GWL_HWNDPARENT) = GetDesktopWindow)) and
(GetWindowLong(Wnd, GWL_EXSTYLE) and WS_EX_TOOLWINDOW = 0) then
CB4.add(GetText(Wnd));
end;
  
  

procedure B1Click(Dummy:Pointer; Sender: PControl);
var
Param : Longint;
begin
CB4.Clear;CB4.Add('');
EnumWindows(@EnumWindowsProc , Param);
end;

procedure B2Click(Dummy:Pointer; Sender: PControl);
begin;WinExec(latexmac,SW_SHOW);end;

procedure B4Click(Dummy:Pointer; Sender: PControl);
const _c='[CJK]{cctart}';_e='{article}';var s:string;
begin;//M1.Items[0]:='\documentclass{cctart}\pagestyle{empty}'+CR;
s:=M1.Items[0];
if StrReplace(s,_e,_c) then M1.Items[0]:=s+CR
else if StrReplace(s,_c,_e) then M1.Items[0]:=s+CR;
end;


procedure CB4Change(Dummy:Pointer; Sender: PControl);
begin
if CB4.Text<>'' then SendTo(CB4.Text);
end;


procedure InitObjs;
begin;
  //App := NewApplet( 'TeX_Bmp' ); App.IconLoad(0,'TeX_bmp');

  W := NewForm( nil, 'TeXλͼ [mhb]' );//W.Icon:=App.Icon;//Load(0,'TeX_bmp');
  if not JustOne(W,fn) then Halt(0);
  //SetFont(W.Font,'����,12');
  W.font.releasehandle;//[qhs]
  W.Font.AssignHandle(GetStockObject(DEFAULT_GUI_FONT));//[qhs]
  B_1:=NewButton(W,'�����λͼ').PlaceUnder.SetSize(140,0);
  B_2:=NewButton(W,'�µ�TeXλͼ').PlaceUnder.SetSize(140,0);
  B_3:=NewButton(W,'��Ϊ�µ�TeXģ��').PlaceUnder.SetSize(140,0);

  B_4:=NewButton(W,'����').PlaceUnder.SetSize(45,0);
  B_5:=NewButton(W,'��Ϊ��').PlaceRight.SetSize(45,0);
  B_6:=NewButton(W,'�򿪡�').PlaceRight.SetSize(45,0);
  CB1:=NewCombobox(W,[]).PlaceDown.SetSize(45,0);
  CB1.DropDownCount:=20;
  B_7:=NewButton(W,'����').AlignLeft(B_5).PlaceRight.SetSize(45,0);
  B_8:=NewButton(W,'���ڡ�').PlaceRight.SetSize(45,0);
  CB1.Shift(0,-2);

  P1:=NewPanel(W,esLowered).PlaceDown.SetSize(140,100);
  B2:=NewButton(P1,'�С�').PlaceRight.SetSize(45,0);
  B3:=NewButton(P1,'�༭��').PlaceRight.SetSize(45,0);
  B4:=NewButton(P1,'��/Ӣ').PlaceRight.SetSize(45,0);
  C1:=NewCheckbox(P1,'������').PlaceDown.SetSize(65,0);
  C2:=NewCheckbox(P1,'����').PlaceRight.SetSize(65,0);
  C3:=NewCheckbox(P1,'��ɫ').PlaceDown.SetSize(65,0);
  L0:=NewLabel(P1,'abc').PlaceRight.SetSize(40,0);
  L0.Color:=clWhite;

  L1:=NewLabel(P1,'�ֱ���').PlaceDown.SetSize(65,0);
  CB2:=NewCombobox(P1,[]).PlaceRight.SetSize(65,0);
  CB2.DropDownCount:=20;
  L2:=NewLabel(P1,'λͼ��ʽ').PlaceDown.SetSize(65,0);
  CB3:=NewCombobox(P1,[]).PlaceRight.SetSize(65,0).ResizeParent;
  CB3.DropDownCount:=20;

  B_9:=NewButton(W,'�趨·��').PlaceDown.SetSize(70,0);
  B_10:=NewButton(W,'�趨����').PlaceRight.SetSize(70,0);
  B_11:=NewButton(W,'����TeXģ����趨').PlaceDown.SetSize(140,0).ResizeParent;

  B1:=NewButton(W,'ˢ��').PlaceRight.AlignTop(B_1).SetSize(60,0);
  CB4:=NewCombobox(W,[coReadOnly]).PlaceRight.SetSize(340,0);
  CB4.DropDownCount:=20;
  M1:=NewEditbox(W,[eoMultiline]).PlaceUnder.AlignLeft(B1).SetSize(450,200);
  M2:=NewEditbox(W,[eoMultiline]).PlaceUnder.AlignLeft(B1).SetSize(450,70).ResizeParent;
  M2.Visible:=false;
  PB:=NewPaintbox(W).PlaceUnder.AlignTop(M2).AlignLeft(B1);
  PB.Visible:=false;
  with CB2^ do begin;Add('300');Add('600');Add('1200');end;
  CB2.Text:='600';
  with CB3^ do begin;Add('bmpmono');Add('bmpgray');Add('bmp16');Add('bmp256');Add('bmp16m');end;
  Image1:=NewBitmap(0,0);//M2.Width,M2.Height);
  Image2:=NewBitmap(0,0);
  OpenDialog1.Filter:='TeX list file(*.txl)|*.txl|TeX file(*.tex;*.ctx)|*.tex;*.ctx';
  SaveDialog1.Filter:=OpenDialog1.Filter;
  
  W.SimpleStatusText:=PChar('������������κ�windows�����ʹ��latexǿ�����ѧ�Ű湦�ܣ��ƶ����鿴ÿ����ť�Ĺ�����ʾ��');
  B_1.CustomData:=PChar('�����ҿ��е�latex����Ϊλͼ��Ȼ�������Ƶ�������������͵���ѡ���Ӧ�ó��򣩡�');
  B_2.CustomData:=PChar('���ҿ�������ΪĬ�ϵ�latexģ�塣');  
  B_3.CustomData:=PChar('���ҿ��е�latex��������ΪĬ�ϵ�latexģ�塣');
  B_4.CustomData:=PChar('�˻ص���һ�α����latex���롣');
  B_5.CustomData:=PChar('��������ʷ�浽txl�ļ��У��Ա��Ժ����µ���ʹ�á�');
  B_6.CustomData:=PChar('��txl�ļ����Ӷ������±������������ù�����ѧ��ʽ��');
  B_7.CustomData:=PChar('��ʾ������򵥵İ�����ʾ��');  
  B_8.CustomData:=PChar('��ʾ������İ�Ȩ��Ϣ��');
  B_9.CustomData:=PChar('�趨�����Ҫ�õ���һЩ����latex��dvips��gswin32c����·����');
  B_10.CustomData:=PChar('�趨���������latex������������е����������');
  B_11.CustomData:=PChar('�����趨��latexģ�塢����·���ͱ�������浽�����ļ�tex-bmp.ini�У�ʹ�´�����ʱ�Զ����롣');
  B1.CustomData:=PChar('ˢ�µ�ǰwindowsӦ�ó����б��Թ���ѡ��');  
  B2.CustomData:=PChar('��ģ�����ѡ�񹤾ߣ�����ѡ�������ѧ���š�');
  B3.CustomData:=PChar('��Ĭ�ϵı༭���򿪵�ǰ��latex���롣');
  B4.CustomData:=PChar('�����ť�����л��Ƿ�ʹ�ҿ��е�latexģ��֧�����ġ�');
  C1.CustomData:=PChar('ѡ�к��ʹ���������������Ӧ�ó��򴰿ڵ��Ϸ���');  
  C2.CustomData:=PChar('ѡ�н������ģʽ�������������ʾ������Ϣ��');
  C3.CustomData:=PChar('ѡ�п�ʹ���ɵ�λͼ����ɫ�ʣ�������ǰ��ɫ�ֱ���������Ҽ���������[abc]�����á�');
  L0.CustomData:=C3.CustomData;
  L1.CustomData:=PChar('�ֱ��ʾ������ɵ�ͼƬ�ķֱ��ʴ�С�Լ�ͼƬ�ķ���������');  
  L2.CustomData:=PChar('Ĭ�ϵ�λͼ��ʽ��͸���ĵ�ɫλͼbmpmono�����ɸĳ�������ʽ������latexɫ��֧�֣�������������ͼƬ���ݵĴ�С��');
  
  exepath:=GetStartDir;
  tmp:=GetEnv('TMP');
  if tmp='' then tmp:=exepath;
  f_ini:=GetEnv('ETC')+'\'+fn_ini;
  if not FileExists(f_ini) then f_ini:=exepath+fn_ini;
  comspec:=exepath+'tex-dos.exe';
  if not FileExists(comspec) then comspec:='command.com /c';
  ext:='.tex';
  paths:=MikPaths(1);
  idx:=0;
  template:=DefTemplate;
  tex2ps:=DefTex2ps;
  editor:='notepad';
  TeXList.Clear;

  if FileExists(f_ini) then ReadIni;
  
  M1.Text:=template;
  SetEnvironmentVariable('PATH',PChar(exepath+';'+paths+';'+GetEnv('Path')));
  //msgOK(GetEnv('Path'));
  DeleteFile(PChar(fn+'.ctx'));
  DeleteFile(PChar(fn+'.tex'));
end;


procedure SetEvents;
begin;
  B_1.OnClick := TOnEvent( MakeMethod( nil, @B_1Click ) );
  B_2.OnClick := TOnEvent( MakeMethod( nil, @B_2Click ) );
  B_3.OnClick := TOnEvent( MakeMethod( nil, @B_3Click ) );
  B_4.OnClick := TOnEvent( MakeMethod( nil, @B_4Click ) );
  B_5.OnClick := TOnEvent( MakeMethod( nil, @B_5Click ) );
  B_6.OnClick := TOnEvent( MakeMethod( nil, @B_6Click ) );
  B_7.OnClick := TOnEvent( MakeMethod( nil, @B_7Click ) );
  B_8.OnClick := TOnEvent( MakeMethod( nil, @B_8Click ) );
  B_9.OnClick := TOnEvent( MakeMethod( nil, @B_9Click ) );
  B_10.OnClick := TOnEvent( MakeMethod( nil, @B_10Click ) );
  B_11.OnClick := TOnEvent( MakeMethod( nil, @B_11Click ) );

  C1.OnClick := TOnEvent( MakeMethod( nil, @C1Click ) );
  CB1.OnChange := TOnEvent( MakeMethod( nil, @CB1Change ) );
  CB4.OnChange := TOnEvent( MakeMethod( nil, @CB4Change ) );

  B1.OnClick := TOnEvent( MakeMethod( nil, @B1Click ) );
  L0.OnMouseDown := TOnMouse( MakeMethod( nil, @L0MouseDown ) );
  B3.OnMouseDown := TOnMouse( MakeMethod( nil, @B3MouseDown ) );
  B2.OnClick := TOnEvent( MakeMethod( nil, @B2Click ) );
  B4.OnClick := TOnEvent( MakeMethod( nil, @B4Click ) );
  W.OnResize := TOnEvent( MakeMethod( nil, @FormResize ) );
  PB.OnPaint := TOnPaint(MakeMethod(nil,@Paint));
  
  B_1.OnMouseMove:=TOnMouse( MakeMethod( nil, @B_MouseMove ) );
  B_2.OnMouseMove:=TOnMouse( MakeMethod( nil, @B_MouseMove ) );
  B_3.OnMouseMove:=TOnMouse( MakeMethod( nil, @B_MouseMove ) );
  B_4.OnMouseMove:=TOnMouse( MakeMethod( nil, @B_MouseMove ) );
  B_5.OnMouseMove:=TOnMouse( MakeMethod( nil, @B_MouseMove ) );
  B_6.OnMouseMove:=TOnMouse( MakeMethod( nil, @B_MouseMove ) );
  B_7.OnMouseMove:=TOnMouse( MakeMethod( nil, @B_MouseMove ) );
  B_8.OnMouseMove:=TOnMouse( MakeMethod( nil, @B_MouseMove ) );
  B_9.OnMouseMove:=TOnMouse( MakeMethod( nil, @B_MouseMove ) );
  B_10.OnMouseMove:=TOnMouse( MakeMethod( nil, @B_MouseMove ) );
  B_11.OnMouseMove:=TOnMouse( MakeMethod( nil, @B_MouseMove ) );
  B1.OnMouseMove:=TOnMouse( MakeMethod( nil, @B_MouseMove ) );
  B2.OnMouseMove:=TOnMouse( MakeMethod( nil, @B_MouseMove ) );
  B3.OnMouseMove:=TOnMouse( MakeMethod( nil, @B_MouseMove ) );
  B4.OnMouseMove:=TOnMouse( MakeMethod( nil, @B_MouseMove ) );
  C1.OnMouseMove:=TOnMouse( MakeMethod( nil, @B_MouseMove ) );
  C2.OnMouseMove:=TOnMouse( MakeMethod( nil, @B_MouseMove ) );
  C3.OnMouseMove:=TOnMouse( MakeMethod( nil, @B_MouseMove ) );
  L1.OnMouseMove:=TOnMouse( MakeMethod( nil, @B_MouseMove ) );
  L2.OnMouseMove:=TOnMouse( MakeMethod( nil, @B_MouseMove ) );
  L0.OnMouseMove:=TOnMouse( MakeMethod( nil, @B_MouseMove ) );
  //B_1.OnMouseMove:=TOnMouse( MakeMethod( nil, @B_MouseMove ) );


end;

begin
  InitObjs;
  SetEvents;
  B1.Click;
  Run(W);
  CleanFiles;
end.


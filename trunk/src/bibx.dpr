{
v0.55: ����һ��������bug������ReadIni���������׸�ʽǰ��?����ʾ������Ϣ��
v0.51: ʹ��ϵͳĬ������
v0.50: �����ֹ��������ܣ����°��Ű�ť�������������߼�������Ź��ܣ����������Զ��򿪰����ļ��������·ݼ�⣻������ӵ��ļ����ܣ�����״̬����ʾ��Ϣ��
v0.40: ֧��ͨ�������ļ��޸������С������
v0.35: ������֧�֣���ͨ�������ļ��޸Ľ������ԣ�
v0.3:�ɴӻ�������ETCָ����Ŀ¼�������ļ���
v0.25:XP�������
v0.2:�Զ�����label
v0.1:��������
}
{$D SMALLEST_CODE} 
//{$R mtex.res}
{$R bibx.res}
uses windows,messages,kol,xptheme,shellapi;{$I w32.pas}

var App,W,B1,B2,B3,B4,B5,B6,B7,B8,B9,E1,E2,E3,E4,E5,CB1,CB2,L1,L2,S1:PControl;PM,PM2:PMenu;Fmts,tmp:TStrList;editing,marking:boolean;f_ini,wname:string;
Dlg1,Dlg2:TOpenSaveDialog;

const ini='bibX.ini';skiplist='art. no. '+CR;
  help='BibX���ο�������ȡ���ߡ� v0.55'+CR+CR
    +'��ӭ����û����ʹ�á�'+CR+CR
    +'��Ȩ���� 2004--2008 ������'+CR
    +'     '+CR
    +'���߱����Ա����������Ȩ����'+CR
    +'����������飬�뵽MTeX-suite��̳���ۡ�'+CR
    +'E-mail: mtex-suite@googlegroups.com'+CR;
  win_title='bibX--�ο�������ȡ���� [mhb]';

  months:array[1..12] of string=('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Oct','Sep','Dec','Nov');
  N_fields=40;
  fields:array[1..N_fields] of string=(
  '#author%s',
  '#title%s',
  '#journal%s',
  '#volume%d',
  '#number%d',
  '#day%d',
  '#month%m',
  '#year%y',
  '#pages%p',
  '#booktitle%s',
  '#address%s',
  '#publisher%s',
  '#editor%s',
  '#series%s',
  '#edition%s',
  '#isbn%s',
  '#issn%s',
  '#organization%s',
  '#institution%s',
  '#school%s',
  '#type%s',
  '#chapter%d',
  '#howpublished',
  '#note%s',
  '#annote%s',
  '#url%s',
  '#source%s',
  '#crossref%s',
  '#abstract%s',
  '#keywords%s',
  '#misc%s',
  '#unknown%s',
  '#university%s',
  '#department%s',
  '#degree%s',
  '#major%s',
  '#supervisor%s',
  '#sn%s',
  '#key%s',
  '#doi%s'
  );
  N_bibtypes=15;
  bibtypes:array[1..N_bibtypes] of string=(
  'article',
  'book',
  'inbook',
  'proceedings',
  'inproceedings',
  'collection',
  'incollection',
  'booklet',
  'manual',
  'techreport',
  'conference',
  'phdthesis',
  'masterthesis',  
  'misc',
  'unpublished'
  );

function DelS(s:string;c1,c2:char):string;
var x:string;i1,i2:integer;
begin;
i1:=Pos(c1,s);i2:=Pos(c2,s);
if i2>i1 then Delete(s,i1,i2-i1+1);
Result:=s;
end;


procedure MenuItemHandler(Dummy:PControl; Sender: PMenu; Item: Integer);
var i:integer;s:string;
begin;
s:=Sender.ItemText[Item];
s:=DelS(s,'[',']');
s:=DelS(s,'<','>');
wname:=s;
W.Caption:=win_title+' ['+s+']';
end;

procedure B2MenuItemHandler(Dummy:PControl; Sender: PMenu; Item: Integer);
var i,j:integer;s,n,s2:string;
begin;
s:=PM2.ItemText[Item];
if E1.SelLength=0 then 
	begin;
	msg_ok('����ѡ��������Ϣ�ж�Ӧ�� '+s+' ���ı�!');
	Exit;
	end;
if not marking then E2.Text:='';
marking:=true;
B1.Enabled:=false;
B4.Enabled:=false;
B5.Enabled:=false;
B7.Enabled:=false;
B8.Enabled:=false;
n:=StrBetween(s,'#','%');
i:=Pos(n+'=',E2.Text);
if i=0 then 
  E2.Text:=E2.Text+n+'={'+E1.Selection+'},'+CR
else 
  begin;s2:=E2.Text;StrBetweenReplace(s2,n+'=',CR,'{'+E1.Selection+'}');E2.Text:=s2;end;

E1.Selection:=s;
end;

Function EnumWindowsProc (Wnd: HWND; LParam: LPARAM): BOOL; stdcall;
begin
Result := True;//h:=0;
if (IsWindowVisible(Wnd) or IsIconic(wnd)) and
((GetWindowLong(Wnd, GWL_HWNDPARENT) = 0) or
(GetWindowLong(Wnd, GWL_HWNDPARENT) = GetDesktopWindow)) and
(GetWindowLong(Wnd, GWL_EXSTYLE) and WS_EX_TOOLWINDOW = 0) then
PM.AddItem(PChar(GetText(Wnd)),TOnMenuItem( MakeMethod( nil,@MenuItemHandler) ),[]);
end;

procedure B7_Click(Dummy:Pointer; Sender: PControl);
var p:TPoint;i:integer;Param : Longint;
begin;
EnumWindows(@EnumWindowsProc , Param);
p.x:=0;p.y:=0;
p:=B7.Client2Screen(p);
PM.Popup(p.x,p.y);
for i:=0 to PM.Count-1 do PM.RemoveSubMenu(i); 
end;





function NonDigits(s:string):integer;
var i:integer;
begin;Result:=0;
  for i:=1 to Length(s) do if not (s[i] in ['0'..'9',' ','-']) then Inc(Result);
end;

function Valid(xdat:string;xtype:char):boolean;
var i:integer;

begin;
  Result:=true;//msgok(Format('%s [%d]',[xdat,NonDigits(xdat)]));
  case Upcase(xtype) of
  'D','N','V','Y':Result:=(NonDigits(xdat)<3);
  'P':Result:=(NonDigits(xdat)<3);
  'M':
      begin;
      for i:=1 to 12 do 
		  if (Pos(UpperCase(months[i]),UpperCase(xdat))>0) or (xdat=Int2Str(i)) 		then exit;
      Result:=false;
      end; 
  end;
end;

{
function SkipStr(var dat:string;s:string):string;
var x,z:string;
begin;
  Result:='';z:=s;
  repeat
    x:=S_before(CR,z);
    if Pos(x,dat)=0 then begin;Result:=x;delete(dat,1,length(x));exit;end;
  until z='';
end;
}

function IsSpace(c:char):boolean;
begin;
  Result:=c in [' ',#9];
end;

function IsPunct(c:char):boolean;
begin;
  Result:=c in [' ',',',':',';','?','{','}','(',')',CR[2],'.',#9];
end;

function ParseField(var sd:string;xsep:string;xtype:char):string;
var xdat:string;i:integer;
begin;
  if Upcase(xtype)='X' then
    for i:=2 to Length(sd) do 
      if (sd[i] in ['0'..'9']) and IsPunct(sd[i-1]) then 
        begin;Result:=Copy(sd,1,i-1);delete(sd,1,i-1);exit;end;   

  xdat:=S_before(xsep,sd);//msgok(xdat+'///'+xsep);
  if not Valid(xdat,xtype) then begin;sd:=xdat+xsep+sd;xdat:='';end;
  Result:=Trim(xdat);
end;

function StrCompact(s:string):string;
var i:integer;
begin;
  if Length(s)=0 then Exit;
  Result:=s[1];
  for i:=2 to length(s) do 
    if (not IsSpace(s[i])) or (IsSpace(s[i]) and not IsPunct(s[i-1])) then
      Result:=Result+s[i];
end;

function SurName(author:string):string;
var s:string;i,j:integer;a:array[1..100] of integer;
begin;
	i:=Pos(',',author);s:=Copy(author,1,i-1);
	if i>0 then begin;Result:=s;Exit;end;
	j:=1;author:=Trim(author);Result:=author;
	if Length(author)=0 then Exit;
	a[1]:=Length(author)+1;
	for i:=Length(author) downto 2 do 
		if (author[i]=' ') and not (author[i-1]=' ') then 
			begin;Inc(j);a[j]:=i;end;
	Result:=Copy(author,a[2]+1,a[1]-1);
	if (Pos('.',Result)>0) or (Length(Result)<3) or (Result=UpperCase(Result)) then
		Result:=Copy(author,1,a[j]-1);
end;
	
function DoAuthor(var xdat:string):string;//,xtyp
var s,w:string;delim:string;i,n:integer;
begin;
	Result:=xdat;s:=xdat;w:='';delim:='';//Exit;
	if Pos('/',xdat)>0 then delim:='/' 
	else if Pos(';',xdat)>0 then delim:=';'; 
	if (delim='') and (Pos(' ',xdat)>0) and (Pos(' ',xdat)<Pos(',',xdat)) then delim:=',';
	w:=StrReplaceAll(xdat,delim,CR);
	xdat:=StrReplaceAll(w,CR,' and ');//msgok(xdat+'~~');
	tmp.Clear;tmp.Text:=w;n:=2;
	//if xtyp=UpperCase(xtyp) then 
		begin;
		//if (xtyp)='A' then n:=2 else n:=30;
		Result:='';
		for i:=0 to min(2,tmp.Count-1) do 
			begin;
			s:=Surname(tmp.Items[i]);//msgok(s);
			if Length(s)>0 then Result:=Result+UpCase(s[1])+LowerCase(Copy(s,2,n));
			end;
		//msgok(xdat+CR+Result+'~~~!');
		end;
end;

function DoYear(var xdat:string):string;//,xtyp
var s:string;i:integer;
begin;
	Result:=xdat;tmp.Clear;tmp.Text:=StrReplaceAll(xdat,' ',CR);
	for i:=0 to tmp.Count-1 do 
		if (Length(tmp.Items[i])=4) and (NonDigits(tmp.Items[i])=0) then
			xdat:=tmp.Items[i];
	//if xtyp='Y' then 
		if Pos('19',xdat)=1 then Result:=Copy(xdat,3,2) else Result:=Copy(xdat,1,4);
end;			

{		
function CiteLabel(xnam:string;var xdat:string;xtyp:string):string;
var nam:string;
begin;
  Result:='';
  if xtyp=LowerCase(xtyp) then Exit;
  nam:=LowerCase(xnam);
  if nam='author' then Result:=DoAuthor(xdat,xtyp)
  else if nam='year' then Result:=DoYear(xdat,xtyp);
//  else if nam='title' then DoTitle(xdat) 
//  else if nam='journal' then DoJournal(xdat) 
//  else if nam='journal' then DoJournal(xdat) 
//  else if nam='journal' then DoJournal(xdat) 
//  else if nam='journal' then DoJournal(xdat) 
//  else if nam='journal' then DoJournal(xdat) 
//  end;  
end;
}
		
function ParseData(data,fmt:string;var flag:integer):string;
var i:integer;sd,sf,bibtype,cite,xname,xsep,xdat,xlab,xnew,skip:string;xtype:char;
begin;
  sd:=data;sf:=fmt;flag:=0;Result:='';cite:='';
  bibtype:=S_before('=',sf);
  xsep:=S_before('#',sf);xlab:='';
  if xsep<>'' then ParseField(sd,xsep,xtype);
  repeat
    xname:=S_before('%',sf);
    xtype:='s';//[mhb] 08/22/09 : fix a bug of crashing
    if Length(sf)>1 then 
      begin;
      xtype:=sf[1];delete(sf,1,1);
      end;
    xsep:=S_before('#',sf);
    sd:=Trim(sd);
    xdat:=ParseField(sd,xsep,xtype);
    //xlab:=CiteLabel(xname,xdat,xtype);
    if xdat='' then flag:=flag+1;
    if xname='cite' then cite:=xdat
    else if xname<>'' then Result:=Result+','+CR+'  '+xname+'={'+Trim(xdat)+'}';
    //if xtype=Upcase(xtype) then cite:=cite+xlab+' ';
  until sf='';
  {
  for i:=1 to Length(cite) do if IsPunct(cite[i]) then cite[i]:='_';
  if (Length(cite)>0) then
		while (cite[1]>='0') or (cite[1]<='9') do
			begin;cite:=Copy(cite,2,Length(cite))+cite[1];end;
  cite:=StrReplaceAll(cite,'_','');
  }
  Result:='@'+bibtype+'{'+cite+Result+CR+'}'+CR;
end;


procedure ReadIni;
var s,n:string;i:integer;P:PStrList;
begin;
  Fmts.Clear;CB1.Clear;CB1.Add('');
  P:=NewStrList;
  P.Clear;P.LoadFromFile(f_ini);
  for i:=0 to P.Count-1 do 
	if (Pos('@',P.Items[i])>0) and (Pos('#',P.Items[i])>1) then 
    begin;
    s:=StrReplaceAll(P.Items[i],'\n',CR);
	Fmts.Add(s);
    n:=S_before('@',s);
    if Pos(n,CB1.Items[CB1.Count-1])=0 then CB1.Add(n);
    end;
  P.Destroy;
end;


procedure B1_Click(Dummy:Pointer; Sender: PControl);
var i,flag,best_i,best_flag:integer;best_s,s,sd,n:string;author,year,cite:string;dbg:boolean;
begin; 
  if E1.Text='' then exit;
  sd:=StrCompact(E1.Text);//msgOk(sd);
  best_s:='';
  best_flag:=1000;best_i:=0;
 for i:=0 to Fmts.Count-1 do
	if (Pos(' '+CB1.Text,' '+Fmts.Items[i])>0)  and (Pos('@'+CB2.Text,' '+Fmts.Items[i])>0) then
      begin;
	  s:=Fmts.Items[i];
      dbg:=Pos('?',s)=1;//[mhb] 08/22/09 : ������׸�ʽ��?��ͷ������ʾ������Ϣ
	  S_before('@',s);
      s:=ParseData(sd,s,flag);
      E2.Text:=s;
	  if flag<best_flag then 
        begin;best_i:=i;best_flag:=flag;best_s:=s;end;
      if dbg then //[mhb] 08/22/09 : ������׸�ʽ��?��ͷ������ʾ������Ϣ
        msgok(sd+CR+CR+Fmts.Items[i]+CR+CR+'==>'+s+CR+'δƥ������Ŀ:'+Int2Str(flag));
      end; 

  if best_flag=1000 then Exit;
  E2.Text:= best_s;
  s:=Fmts.Items[best_i];
  n:=S_before('@',s);
  L1.Text:=Format('%5s<%d:%d>',[n,best_i+1,best_flag]);
  i:=MsgBox('�Ƿ�����author���Զ�����author+year�������ñ�ǣ�',MB_YESNO);
  if i=ID_NO then Exit;
  s:=E2.Text;
  author:=StrBetween(s,'author={','}');
  cite:=DoAuthor(author);
  StrBetweenReplace(s,'author={','}',author);
  E2.Text:=s;
  year:=StrBetween(s,'year={','}');
  cite:=cite+DoYear(year);
  StrBetweenReplace(s,'year={','}',year);
  E2.Text:=s;
  E2.Items[0]:='@'+CB2.Text+'{'+cite+','+CR;
end;

procedure B2_Click(Dummy:Pointer; Sender: PControl);
var p:TPoint;i:integer;s,s0,s1:string;
begin;
  if (E1.SelLength>0) or (not marking) then 
	begin;
	p.x:=0;p.y:=0;
	p:=B2.Client2Screen(p);
	PM2.Popup(p.x,p.y);
	end
  else
	begin;
	i:=MsgBox('�������ֹ����ģʽ�����Ƿ��Ѿ����������bib���������������򣬲�����ߵ������������������˸�ʽ��Ǻ��������ͣ�������ѡ[Yes]�Զ�Ϊ����������bib��Ŀ�����ø�ʽ���뵽�����С�',MB_YESNO);
	if i=ID_NO then Exit;
	marking:=false;
	B1.Enabled:=true;
	B4.Enabled:=true;
	B5.Enabled:=true;
	B7.Enabled:=true;
	B8.Enabled:=true;
	E2.Text:='@'+CB2.Text+'{'+CR+E2.Text+'}'+CR;
	if Length(CB1.Text)=0 then CB1.Text:='User';
	s1:=StrCompact(E1.Text);
	s:=CB1.Text+'@'+CB2.Text+'='+CR+s1;
	i:=MsgBox('�Ƿ񽫸����׶�Ӧ�����¸�ʽ���ü��������ļ���'+CR+s,MB_YESNO);
	if i=ID_NO then Exit;
	s0:=StrLoadFromFile(f_ini);
	s:=CB1.Text+'@'+CB2.Text+'='+StrReplaceAll(s1,CR,'\n');
	if Pos(s,s0)=0 then 
		begin;StrSaveToFile(f_ini,s0+CR+s);Fmts.Add(s);ReadIni;end;
	end;
end;


procedure B3_Click(Dummy:Pointer; Sender: PControl);
begin;
  editing:=not editing;
  if editing then 
	  begin;
      B3.Text:='Ӧ�ò���������';
      E2.Text:=StrLoadFromFile(f_ini);
	  B1.Enabled:=false;
      B4.Enabled:=false;
      B5.Enabled:=false;
      B7.Enabled:=false;
      B8.Enabled:=false;
      end
  else 
	  begin;
      B3.Text:='ֱ�ӱ༭�����ļ�';
      StrSaveToFile(f_ini,E2.Text);
      ReadIni;
      E2.Text:='';
	  B1.Enabled:=true;
      B4.Enabled:=true;
      B5.Enabled:=true;
      B7.Enabled:=true;
      B8.Enabled:=true;  
      end;
end;

procedure B4_Click(Dummy:Pointer; Sender: PControl);
begin;E1.Text:=Clipboard2Text;
end;

procedure B5_Click(Dummy:Pointer; Sender: PControl);
begin;
if editing then exit;
Text2Clipboard(E2.Text);
SendStrTo(Ctrl_V,Find_W(wname));
end;

procedure B6_Click(Dummy:Pointer; Sender: PControl);
var s:string;
begin;
msgOK(help);
s:=GetStartDir+'..\doc\bibx.txt';
if FileExists(s) then WinExec(PChar('notepad.exe '+s),SW_SHOW);
end;

procedure B9_Click(Dummy:Pointer; Sender: PControl);
begin;
  if Dlg1.Execute then E3.Text:=Dlg1.FileName;
end;

procedure B8_Click(Dummy:Pointer; Sender: PControl);
var f,s:string;
begin;
  f:=E3.Text;
  if Length(f)=0 then begin;msg_ok('��ѡ��[...]������һ��bib�ļ���!');Exit;end;
  if MsgBox('ȷʵҪ�������bib��Ŀ���ļ�'+f+'?'+CR+E2.Text,MB_OKCANCEL)=ID_CANCEL then Exit;
  if FileExists(f) then s:=StrLoadFromFile(f) else s:='';
  s:=s+CR+E2.Text;
  StrSaveToFile(f,s);
end;


procedure FormResize(Dummy:Pointer; Sender: PControl);
begin
E1.Width:=W.Width;
E2.Width:=W.Width;
E2.Height:=W.Height-E2.Top-10;
end;

procedure B_MouseMove(dummy:Pointer;Sender: PControl;var Mouse: TMouseEventData);
begin
  W.SimpleStatusText:=Sender.CustomData;
end;

procedure SetEvents;
begin;
  B1.OnClick := TOnEvent( MakeMethod( nil, @B1_Click ) );
  B2.OnClick := TOnEvent( MakeMethod( nil, @B2_Click ) );
  B3.OnClick := TOnEvent( MakeMethod( nil, @B3_Click ) );
  B4.OnClick := TOnEvent( MakeMethod( nil, @B4_Click ) );
  B5.OnClick := TOnEvent( MakeMethod( nil, @B5_Click ) );
  B6.OnClick := TOnEvent( MakeMethod( nil, @B6_Click ) );
  B7.OnClick := TOnEvent( MakeMethod( nil, @B7_Click ) );
  B9.OnClick := TOnEvent( MakeMethod( nil, @B9_Click ) );
  B8.OnClick := TOnEvent( MakeMethod( nil, @B8_Click ) );
  W.OnResize := TOnEvent( MakeMethod( nil, @FormResize ) );
  B1.OnMouseMove:=TOnMouse( MakeMethod( nil, @B_MouseMove ) );
  B2.OnMouseMove:=TOnMouse( MakeMethod( nil, @B_MouseMove ) );
  B3.OnMouseMove:=TOnMouse( MakeMethod( nil, @B_MouseMove ) );
  B4.OnMouseMove:=TOnMouse( MakeMethod( nil, @B_MouseMove ) );  
  B5.OnMouseMove:=TOnMouse( MakeMethod( nil, @B_MouseMove ) );
  B6.OnMouseMove:=TOnMouse( MakeMethod( nil, @B_MouseMove ) );
  B7.OnMouseMove:=TOnMouse( MakeMethod( nil, @B_MouseMove ) );
  B8.OnMouseMove:=TOnMouse( MakeMethod( nil, @B_MouseMove ) );
  B9.OnMouseMove:=TOnMouse( MakeMethod( nil, @B_MouseMove ) );
//  B2.OnMouseMove:=TOnMouse( MakeMethod( nil, @B_MouseMove ) );
  
end;

procedure InitObjs;var i:integer;
begin;
  f_ini:=GetEnv('ETC')+'\'+ini;
  if not FileExists(f_ini) then f_ini:=GetStartDir+ini;
  App := NewApplet( 'bibX' ); 
  W := NewForm( App, win_title );
  W.Style:=W.Style and not (WS_MAXIMIZEBOX);
  //if not JustOne(W,fn) then Halt(0);
  W.font.releasehandle;//[qhs]
  W.Font.AssignHandle(GetStockObject(DEFAULT_GUI_FONT));//[qhs]
  //SetFont(W.Font,'����,12');
  
  E1:=NewEditbox(W,[eoMultiline]).PlaceDown.SetSize(600,100).ResizeParent; 

  
//  E1.WordWrap:=true;
//  S1:=NewSplitter(W,100,200);
  B1:=NewButton(W,'��ȡ������Ϣ').PlaceUnder.SetSize(100,0).ResizeParent;
  L1:=NewLabel(W,' ').PlaceRight.SetSize(100,0).ResizeParent;
  B3:=NewButton(W,'ֱ�ӱ༭�����ļ�').PlaceRight.SetSize(100,0).ResizeParent;
  B4:=NewButton(W,'ճ��������Ϣ').PlaceRight.SetSize(100,0).ResizeParent;
  B7:=NewButton(W,'ѡ���ʹ���>>').PlaceRight.Shift(10,0).SetSize(100,0).ResizeParent;
  PM:=NewMenu( B7, 100, [], TOnMenuItem( MakeMethod( nil,@MenuItemHandler) ) );
  B6:=NewButton(W,'��ʾ�򵥰���').PlaceRight.SetSize(100,0).ResizeParent;

  CB1:=NewComboBox(W,[]).PlaceDown.SetSize(100,0).ResizeParent;
  CB1.DropDownCount:=40;
  CB2:=NewComboBox(W,[]).PlaceRight.SetSize(100,0).ResizeParent;
  CB2.DropDownCount:=40;
  for i:=1 to N_bibtypes do CB2.Add(bibtypes[i]);
  //L2:=NewLabel(W,' ').PlaceRight.SetSize(40,0).ResizeParent;
  B2:=NewButton(W,'�ֹ������ѡ��>>').PlaceRight.SetSize(100,0).ResizeParent;
  PM2:=NewMenu( B2, 100, [], TOnMenuItem( MakeMethod( nil,@B2MenuItemHandler) ) );  

  for i:=1 to N_fields do PM2.AddItem(PChar(fields[i]),TOnMenuItem( MakeMethod( nil,@B2MenuItemHandler) ),[]);
  B5:=NewButton(W,'��������bib��Ŀ').PlaceRight.SetSize(100,0).ResizeParent;
  //B7:=NewButton(W,'>').PlaceRight.SetSize(20,0).ResizeParent;
  B8:=NewButton(W,'��ӵ��ļ�').PlaceRight.Shift(10,0).SetSize(100,0).ResizeParent;
  E3:=NewEditbox(W,[]).PlaceRight.SetSize(80,0).ResizeParent;
  B9:=NewButton(W,'...').PlaceRight.SetSize(20,0).ResizeParent;

  Dlg1.Title:='��ѡ���ļ���';
  Dlg1.Filter:='Bib�ļ�(*.bib)|*.bib';

  E1.Color:=clWhite;
  E2:=NewEditbox(W,[eoMultiline]).PlaceDown.SetSize(600,200).ResizeParent;
  E2.Font.FontWeight:=-9;
  
  W.SimpleStatusText:=PChar('���ͣ���ڰ�ť�Ͻ��ڱ�״̬����ʾ��ť���ܵļ���ʾ��');
  B1.CustomData:=PChar('����ð�ť�������Զ���������е��ı���ȡ��bib��Ŀ');
  B2.CustomData:=PChar('����ð�ť�������ֹ����ѡ����ı�Ϊһ��bib����ѡ���Ͽ��е��ı��������ڱ���������������bib��Ŀ');
  B3.CustomData:=PChar('����ð�ť��������ֱ�ӱ༭������������ļ���ʹ������������Ч');
  B4.CustomData:=PChar('����ð�ť���Ѽ������е��ı�ճ�����Ͽ���');
  B5.CustomData:=PChar('����ð�ť������ȡ����bib��Ŀ���¿��е��ı������Ƶ��������У������͵�ָ���ı༭�����ڣ�');
  B6.CustomData:=PChar('����ð�ť��ʾ������ļ򵥰���');
  B7.CustomData:=PChar('����ð�ť����ѡ��һ���༭������');
  B8.CustomData:=PChar('����ð�ť�������ɵ�bib��Ŀֱ����ӵ��ұ߿���ָ����bib�ļ���');
  B9.CustomData:=PChar('����ð�ť��������ֱ��ѡ��һ��bib�ļ�');

  E3.Text:=ParamStr(1);
  
  editing:=false;marking:=false;wname:='';
end;





begin;
  InitObjs;
  ReadIni;
  SetEvents;
  Run(App);
end.

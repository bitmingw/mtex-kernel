{$APPTYPE console}
uses windows,messages,winspool,kol,shellapi;{$I w32.pas}
const 
usage='�÷���IS_PRINTER ��ӡ������ ���������ָ���Ĵ�ӡ���Ƿ����'+CR
	+'����ֵ��1 [YES] ��ӡ�����ֺϷ���2 [NO] ��ӡ�����ַǷ���';
	
	
var h:Cardinal;
begin;
  if ParamCount=0 then 
	  begin;writeln(usage);halt(0);end;
  if OpenPrinter(PChar(ParamStr(1)),h,nil) then 
	  begin;ClosePrinter(h);writeln('YES');halt(1);end 
  else 
	  begin;writeln('NO');halt(2);end;
end.

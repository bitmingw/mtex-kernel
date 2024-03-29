;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        .386
        .model flat, stdcall
        option casemap :none   ; case sensitive
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
include     windows.inc
include     user32.inc
include     kernel32.inc
include     comctl32.inc
include     comdlg32.inc
include     masm32.inc

includelib  user32.lib
includelib  kernel32.lib
includelib  comctl32.lib
includelib  comdlg32.lib
includelib  masm32.lib

include    my.inc
;includelib my.lib
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ICO_MAIN    equ     1000
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        .data?
hInstance   dd  ?
pCmdLine    dd  ?
szRun	    db  256 dup (?)

_ProcDlgMain    PROTO   :DWORD,:DWORD,:DWORD,:DWORD

        .data
;szDlgTitle  db  '�����в�����',0
szCmd	    db 'gswin32c.exe ',32 dup (0)

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        .code


shellx proc lpfilename:DWORD

    LOCAL xc :DWORD         ; exit code

    .data
      st_info STARTUPINFO <0>
      pr_info PROCESS_INFORMATION <0>
      sa_info SECURITY_ATTRIBUTES <0,NULL,TRUE>
    .code

    invoke GetStartupInfo,ADDR st_info
    invoke CreateProcess,NULL,lpfilename,ADDR sa_info,ADDR sa_info,
                         TRUE,NULL,NULL,NULL,   ;CREATE_NEW_CONSOLE
                         ADDR st_info,
                         ADDR pr_info

    invoke WaitForSingleObject,pr_info.hProcess,INFINITE
    cmp eax,WAIT_OBJECT_0
    jne @F
    invoke CloseHandle,pr_info.hProcess
    @@:
    invoke CloseHandle,pr_info.hThread
    ret

shellx endp



GetArgs proc s:DWORD
      mov ebx,s
      mov dl,32 ;' '
      cmp byte ptr [ebx],34 ;'"'
      jne Scan
      mov dl,34 ;'"'
      inc ebx
    Scan:
      mov al,[ebx]
      cmp al,0
      je Done2
      cmp al,dl
      je Done1
      inc ebx
      jmp Scan
    Done1:
      inc ebx
    Done2:
      return ebx
GetArgs endp


start:
    invoke GetModuleHandle, NULL ; provides the instance handle
    mov hInstance, eax

    invoke lstrcpy,ADDR szRun,ADDR szCmd
    invoke GetCommandLine        ; provides the command line address
    mov pCmdLine, eax
    ;invoke MessageBox,0,eax,ADDR szDlgTitle,MB_OK
    invoke GetArgs,pCmdLine
    invoke lstrcat,ADDR szRun,eax
    @@:
    
    ;invoke MessageBox,0,pCmdLine,ADDR szDlgTitle,MB_OK
    ;invoke MessageBox,0,ADDR szRun,ADDR szDlgTitle,MB_OK
    invoke shellx,ADDR szRun

    invoke ExitProcess,eax       ; cleanup & return to operating system
;********************************************************************
        end start


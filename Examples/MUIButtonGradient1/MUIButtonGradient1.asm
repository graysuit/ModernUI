.686
.MMX
.XMM
.model flat,stdcall
option casemap:none

include MUIButtonGradient1.inc

.code

start:

    Invoke GetModuleHandle,NULL
    mov hInstance, eax
    Invoke GetCommandLine
    mov CommandLine, eax
    Invoke InitCommonControls
    mov icc.dwSize, sizeof INITCOMMONCONTROLSEX
    mov icc.dwICC, ICC_COOL_CLASSES or ICC_STANDARD_CLASSES or ICC_WIN95_CLASSES
    Invoke InitCommonControlsEx, offset icc
    
    Invoke WinMain, hInstance, NULL, CommandLine, SW_SHOWDEFAULT
    Invoke ExitProcess, eax

;-------------------------------------------------------------------------------------
; WinMain
;-------------------------------------------------------------------------------------
WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
    LOCAL   wc:WNDCLASSEX
    LOCAL   msg:MSG

    mov     wc.cbSize, sizeof WNDCLASSEX
    mov     wc.style, CS_DROPSHADOW ;CS_HREDRAW or CS_VREDRAW
    mov     wc.lpfnWndProc, offset WndProc
    mov     wc.cbClsExtra, NULL
    mov     wc.cbWndExtra, DLGWINDOWEXTRA
    push    hInst
    pop     wc.hInstance
    mov     wc.hbrBackground, COLOR_BTNFACE+1 ; COLOR_WINDOW+1
    mov     wc.lpszMenuName, NULL ;IDM_MENU
    mov     wc.lpszClassName, offset ClassName
    ;Invoke LoadIcon, NULL, IDI_APPLICATION
    Invoke LoadIcon, hInstance, ICO_MUI ; resource icon for main application icon
    mov hIcoMain, eax ; main application icon
    mov     wc.hIcon, eax
    mov     wc.hIconSm, eax
    Invoke LoadCursor, NULL, IDC_ARROW
    mov     wc.hCursor,eax
    Invoke RegisterClassEx, addr wc
    Invoke CreateDialogParam, hInstance, IDD_DIALOG, NULL, addr WndProc, NULL
    Invoke ShowWindow, hWnd, SW_SHOWNORMAL
    Invoke UpdateWindow, hWnd
    .WHILE TRUE
        invoke GetMessage, addr msg, NULL, 0, 0
      .BREAK .if !eax
        Invoke TranslateMessage, addr msg
        Invoke DispatchMessage, addr msg
    .ENDW
    mov eax, msg.wParam
    ret
WinMain endp


;-------------------------------------------------------------------------------------
; WndProc - Main Window Message Loop
;-------------------------------------------------------------------------------------
WndProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
    
    mov eax, uMsg
    .IF eax == WM_INITDIALOG
        push hWin
        pop hWnd
        
        ; Create CaptionBar control via MUI api
        Invoke MUICaptionBarCreate, hWin, Addr AppName, 32d, IDC_CAPTIONBAR, MUICS_LEFT or MUICS_REDCLOSEBUTTON ; or MUICS_NOCAPTIONTITLETEXT ;or MUICS_NOMAXBUTTON
        mov hCaptionBar, eax
        
        ; Set some properties for our CaptionBar control 
        Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBackColor, MUI_RGBCOLOR(51,51,51)
        Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBtnTxtRollColor, MUI_RGBCOLOR(228,228,228)
        Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBtnBckRollColor, MUI_RGBCOLOR(81,81,81)
        Invoke MUICaptionBarSetProperty, hCaptionBar, @CaptionBarBtnWidth, 36d

        ;-----------------------------------------------------------------------------------------------------
        ; ModernUI_Button Example: Gradient background
        ;-----------------------------------------------------------------------------------------------------
        Invoke MUIButtonCreate, hWin, Addr szButtonGradientText, 20, 100, 250, 38, IDC_BUTTONGRADIENT, WS_CHILD or WS_VISIBLE or MUIBS_HAND or MUIBS_PUSHBUTTON
        mov hBtnGradient, eax
        
        ; Load some images for when user moves mouse over button, or if its selected state changes
        Invoke MUIButtonLoadImages, hBtnGradient, MUIBIT_ICO, ICO_SYSTEM_GREY, ICO_SYSTEM, ICO_SYSTEM, ICO_SYSTEM, ICO_SYSTEM_GREY
        
        Invoke MUIButtonSetProperty, hBtnGradient, @ButtonBackColor, MUI_RGBCOLOR(166,250,146) ; 213,248,205 ; 240,240,240
        Invoke MUIButtonSetProperty, hBtnGradient, @ButtonBackColorTo, MUI_RGBCOLOR(249,193,148) ; 248,233,205 ; 205,219,248
        
        Invoke MUIButtonSetProperty, hBtnGradient, @ButtonBackColorAlt, MUI_RGBCOLOR(240,240,240)
        Invoke MUIButtonSetProperty, hBtnGradient, @ButtonBackColorAltTo, MUI_RGBCOLOR(175,175,175)

    .ELSEIF eax == WM_ERASEBKGND
        mov eax, 1
        ret

    .ELSEIF eax == WM_PAINT
        invoke MUIPaintBackground, hWin, MUI_RGBCOLOR(240,240,240), MUI_RGBCOLOR(51,51,51) ; MUI_RGBCOLOR(255,255,255)
        mov eax, 0
        ret

    .ELSEIF eax == WM_COMMAND
        mov eax, wParam
        and eax, 0FFFFh
        .IF eax == IDM_FILE_EXIT
            Invoke SendMessage,hWin,WM_CLOSE,0,0
            
        .ELSEIF eax == IDM_HELP_ABOUT
            Invoke ShellAbout,hWin,addr AppName,addr AboutMsg,NULL
            
        .ENDIF

    .ELSEIF eax == WM_CLOSE
        Invoke DestroyWindow,hWin
        
    .ELSEIF eax == WM_DESTROY
        Invoke PostQuitMessage,NULL
        
    .ELSE
        Invoke DefWindowProc,hWin,uMsg,wParam,lParam
        ret
    .ENDIF
    xor    eax,eax
    ret
WndProc endp

end start

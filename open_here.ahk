;
; AutoHotkey Version: 1.1
; Language:       English
; Platform:       Win9x/NT
; Author:         Yibo, Hexlord
;
; Script Function:
;	Define the shortcut Ctrl + Alt + T for launching Git bash in current folder in Windows Explorer
;

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#NoTrayIcon

SetTitleMatchMode RegEx
return

; Stuff to do when Windows Explorer is open
;
#IfWinActive ahk_class ExploreWClass|CabinetWClass

    ; open Git Bash in the current directory
    ^!t::
        OpenGbHere()
        return

    ; open VS Code in the current directory
    ^!c::
        OpenVSCodeHere()
        return
        
    return
#IfWinActive

#IfWinActive ahk_class ExploreWClass|CabinetWClass
    
#IfWinActive

GatherFullPath()
{
    ; This is required to get the full path of the file from the address bar
    WinGetText, full_path, A

    ; Split on newline (`n)
    StringSplit, word_array, full_path, `n

    ; Find and take the element from the array that contains address
    Loop, %word_array0%
    {
        IfInString, word_array%A_Index%, Address
        {
            full_path := word_array%A_Index%
            break
        }
    }  

    ; strip to bare address
    full_path := RegExReplace(full_path, "^Address: ", "")

    ; Just in case - remove all carriage returns (`r)
    StringReplace, full_path, full_path, `r, , all

    return full_path
}


; Opens the Git bash shell in the directory browsed in Explorer.
; Note: expecting to be run when the active window is Explorer.
;
OpenGbHere()
{
    full_path := GatherFullPath()
    
    IfInString full_path, \
    {
        Run,  C:\Program Files\Git\git-bash.exe, %full_path%
    }
    else
    {
        Run, C:\Program Files\Git\git-bash.exe --cd-to-home
    }
}

; Opens the VSCode in the directory browsed in Explorer.
; Note: expecting to be run when the active window is Explorer.
;
OpenVSCodeHere()
{
    full_path := GatherFullPath()
    
    IfNotInString full_path, \
    {
        full_path := "~"
    }
    Run, cmd.exe ,, UseErrorLevel, PID
    sleep,100
    ClipSaved := ClipboardAll
    Test := "cd " full_path " && code ." 
    Clipboard := Test
    Send, {rshift down}{insert}{rshift up}{enter}
    sleep,100
    Clipboard := ClipSaved
    sleep,1500
    ;-- close DOS window --
    ;msgbox % PID
    RunWait, taskkill /f /t /PID %PID%,, Hide UserErrorLevel
}
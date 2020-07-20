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

    ; open Git bash in the current directory
    ; Use Ctrl + Alt + T for activation; you can redefine it as, e.g. "#t::" to use Win + T
    ^!t::
        OpenGbHere()
        Send {AppsKey}
        Send s
        return

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
    
    IfInString full_path, \
    {
        run, %comspec% /k ,,,pid1
        ; run, cmd ,,,pid1
        sleep,1000
        ClipSaved := ClipboardAll
        Test := "cd " full_path " & code ." 
        Clipboard := Test
        Send, {rshift down}{insert}{rshift up}{enter}
        sleep,500
        Clipboard := ClipSaved

        sleep,1000
        ;-- close DOS window --
        Process, Close, %pid1%
        Process, WaitClose, %pid1%
    }
    else
    {
        Run, C:\Users\a_knorre\AppData\Local\Programs\Microsoft VS Code\Code.exe --cd-to-home
    }
}
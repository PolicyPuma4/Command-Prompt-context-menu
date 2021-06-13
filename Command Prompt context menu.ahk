; Created by https://github.com/PolicyPuma4
; Official repository https://github.com/PolicyPuma4/Command-Prompt-context-menu

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;@Ahk2Exe-Obey U_bits, = %A_PtrSize% * 8
;@Ahk2Exe-Obey U_type, = "%A_IsUnicode%" ? "Unicode" : "ANSI"
;@Ahk2Exe-ExeName %A_ScriptName~\.[^\.]+$%_%U_type%_%U_bits%

;@Ahk2Exe-SetMainIcon cmd_IDI_APPICON.ico

Argument := A_Args[1]

EnvGet, LOCALAPPDATA, LOCALAPPDATA
AppName := "Command Prompt context menu"
InstallPath := LOCALAPPDATA "\Programs\" AppName
ExecutableName := AppName ".exe"
ExecutablePath := InstallPath "\" ExecutableName


IsSubkey(KeyPath, KeyName)
{
    Loop, Reg, %KeyPath%, K
    {
        if (A_LoopRegName = KeyName)
            return true
    }
}


IsKeyValue(KeyPath, ValueName)
{
    Loop, Reg, KeyPath, V
    {
        if (A_LoopRegName = ValueName)
            return true
    }
}


if not Argument
{
    UninstallMessage := "Hey it looks like you already have this awesome app installed! Uninstall your previous version before attempting to reinstall."

    if FileExist(InstallPath)
    {
        MsgBox % UninstallMessage
        ExitApp
    }

    CheckSubkeys := []
    CheckSubkeys.Push(["HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", AppName])
    CheckSubkeys.Push(["HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\Background\shell", AppName])
    CheckSubkeys.Push(["HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell", AppName])
    CheckSubkeys.Push(["HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\Background\shell", AppName " elevated"])
    CheckSubkeys.Push(["HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell", AppName " elevated"])

    for , Array in CheckSubkeys
    {
        if IsSubkey(Array[1], Array[2])
        {
            MsgBox % UninstallMessage
            ExitApp
        }
    }

    if IsKeyValue("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce", AppName)
    {
        MsgBox % UninstallMessage
        ExitApp
    }

    FileCreateDir % InstallPath
    FileCopy, %A_ScriptFullPath%, %ExecutablePath%

    RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%AppName%, DisplayIcon, %ExecutablePath%
    RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%AppName%, DisplayName, Command Prompt context menu
    RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%AppName%, InstallLocation, %InstallPath%
    RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%AppName%, UninstallString, "%ExecutablePath%" /uninstall
    RegWrite, REG_DWORD, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%AppName%, NoModify, 0x00000001
    RegWrite, REG_DWORD, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%AppName%, NoRepair, 0x00000001

    RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\Background\shell\%AppName%,, Open Command Prompt window here
    RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\Background\shell\%AppName%, Icon, %ExecutablePath%
    RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\Background\shell\%AppName%\command,, "%ExecutablePath%" /cmd "`%V"

    RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell\%AppName%,, Open Command Prompt window here
    RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell\%AppName%, Icon, %ExecutablePath%
    RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell\%AppName%\command,, "%ExecutablePath%" /cmd "`%V"

    RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\Background\shell\%AppName% elevated,, Open elevated Command Prompt window here
    RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\Background\shell\%AppName% elevated, Icon, %ExecutablePath%
    RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\Background\shell\%AppName% elevated, HasLUAShield
    RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\Background\shell\%AppName% elevated\command,, "%ExecutablePath%" /elevatedcmd "`%V"

    RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell\%AppName% elevated,, Open elevated Command Prompt window here
    RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell\%AppName% elevated, Icon, %ExecutablePath%
    RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell\%AppName% elevated, HasLUAShield
    RegWrite, REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell\%AppName% elevated\command,, "%ExecutablePath%" /elevatedcmd "`%V"

    MsgBox Installation complete! you may delete this executable.
}
else if (Argument = "/uninstall")
{
    RegWrite REG_SZ, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce, %AppName%, "C:\Windows\system32\cmd.exe" /c rmdir /q /s "%InstallPath%"

    RegDelete HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\%AppName%

    RegDelete HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\Background\shell\%AppName%

    RegDelete HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell\%AppName%

    RegDelete HKEY_CURRENT_USER\SOFTWARE\Classes\*\shell\%AppName%

    RegDelete HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\Background\shell\%AppName% elevated

    RegDelete HKEY_CURRENT_USER\SOFTWARE\Classes\Directory\shell\%AppName% elevated

    RegDelete HKEY_CURRENT_USER\SOFTWARE\Classes\*\shell\%AppName% elevated

    MsgBox Restart your computer to complete the uninstallation.
}
else if (Argument = "/cmd")
{
    folder := A_Args[2]
    SplitPath, folder, OutFileName, OutDir,,, OutDrive
    if (RTrim(folder, OmitChars := """") = OutDrive)
    {
        folder := "\"
        OutFileName := ""
    }
    CurrentDirectory := A_WorkingDir
    SetWorkingDir, %OutDir%\%OutFileName%
    if ErrorLevel
    {
        if FileExist(A_AppData "\Microsoft\Windows\Start Menu\Programs\System Tools\Command Prompt.lnk")
            Run, *RunAs "%A_AppData%\Microsoft\Windows\Start Menu\Programs\System Tools\Command Prompt.lnk" /k "%OutDrive% && cd %folder%"
        else
            Run, *RunAs "%A_ComSpec%" /k "%OutDrive% && cd %folder%"
    }
    else
    {
        if FileExist(A_AppData "\Microsoft\Windows\Start Menu\Programs\System Tools\Command Prompt.lnk")
            Run, "%A_AppData%\Microsoft\Windows\Start Menu\Programs\System Tools\Command Prompt.lnk" /k "%OutDrive% && cd %folder%"
        else
            Run, "%A_ComSpec%" /k "%OutDrive% && cd %folder%"
    }
}
else if (Argument = "/elevatedcmd")
{
    folder := A_Args[2]
    SplitPath, folder,,,,, OutDrive
    if (RTrim(folder, OmitChars := """") = OutDrive)
        folder := "\"
    if FileExist(A_AppData "\Microsoft\Windows\Start Menu\Programs\System Tools\Command Prompt.lnk")
        Run, *RunAs "%A_AppData%\Microsoft\Windows\Start Menu\Programs\System Tools\Command Prompt.lnk" /k "%OutDrive% && cd %folder%"
    else
        Run, *RunAs "%A_ComSpec%" /k "%OutDrive% && cd %folder%"
}

Option Explicit

Dim shell
Dim fso
Dim scriptDir
Dim ps1Path
Dim command

Set shell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)
ps1Path = fso.BuildPath(scriptDir, "start-cmo-lua-ui.ps1")
command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File " & Chr(34) & ps1Path & Chr(34) & " -Silent"

shell.Run command, 0, False

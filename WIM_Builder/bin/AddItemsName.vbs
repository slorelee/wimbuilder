If Wscript.Arguments.Count < 2 Then
  WSH.Quit(0)
End If

Dim KeepFile
KeepFile = Wscript.Arguments(0)

Const ForReading = 1

Dim objFSO, objFile
Dim i, message
Dim RootPath
RootPath = Wscript.Arguments(1)
If Right(RootPath, 1) <> "\" Then RootPath = RootPath & "\"
set objFSO = CreateObject("Scripting.FileSystemObject")
set objFile = objFSO.OpenTextFile(KeepFile, ForReading)
Do Until objFile.AtEndOfStream
  message = objFile.ReadLine
  If message <> "" And Left(message, 1) <> ";" Then
     OutPrint message
  End if
Loop
objFile.Close
set objFile = Nothing
set objFSO = Nothing

Sub OutPrint(KPath)

  Dim IsDirPath
  IsDirPath = 0
  If Right(KPath, 1) = "\" Then
    IsDirPath = 1
    KPath = Left(KPath, Len(KPath) - 1)
  End If

  Dim Pos, FileParentPath
  Pos = InstrRev(KPath, "\")
  FileParentPath = ""
  If Pos > 0 Then
    FileParentPath = Left(KPath, Pos)
  End If
  If IsDirPath = 1 Then
    WSH.Echo " /S /E """ & RootPath & KPath & """ ""X:\" & KPath & "\"""
  Else
    WSH.Echo """" & RootPath & KPath & """ ""X:\" & FileParentPath & """"
  End If
End Sub

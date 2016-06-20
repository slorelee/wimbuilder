If Wscript.Arguments.Count = 0 Then
  WSH.Quit(0)
End If

Dim KeepFile
KeepFile = Wscript.Arguments(0)

Const ForReading = 1

Dim objFSO, objFile
Dim i, message
Dim RootPath
i = 0
RootPath = ""
set objFSO = CreateObject("Scripting.FileSystemObject")
set objFile = objFSO.OpenTextFile(KeepFile, ForReading)
Do Until objFile.AtEndOfStream
  message = objFile.ReadLine
  If message <> "" And Left(message, 1) <> ";" Then
     i = i + 1
     If i = 1 Then
       RootPath = message
     Else
       OutPrint message
     End If
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
    WSH.Echo """X:\" & RootPath & KPath & """ ""X:\[KEEP_ITEMS]\" & KPath & "\"""
  Else
    WSH.Echo """X:\" & RootPath & KPath & """ ""X:\[KEEP_ITEMS]\" & FileParentPath & """"
  End If
End Sub

If Wscript.Arguments.Count = 0 Then
  WSH.Quit(0)
End If

Dim KeepFile
KeepFile = Wscript.Arguments(0)

Const ForReading = 1

Dim objFSO, objFile
Dim i, message
Dim RootPath
Dim AddSameNameManifests
Dim ExSubFolderPath
i = 0
RootPath = ""
AddSameNameManifests = False
ExSubFolderPath = ""
set objFSO = CreateObject("Scripting.FileSystemObject")
set objFile = objFSO.OpenTextFile(KeepFile, ForReading)
Do Until objFile.AtEndOfStream
  message = objFile.ReadLine
  If message <> "" And Left(message, 1) <> ";" Then
    i = i + 1
    If i = 1 Then
      RootPath = message
      If Right(RootPath, 1) <> "\" Then RootPath = RootPath & "\"
    Else
      If message = "+Manifests" Then
        AddSameNameManifests = True
      ElseIf Left(message, 1) = "=" Then
        ExSubFolderPath = Mid(message, 2)
      Else
        OutPrint message
      End If
    End If
  End if
Loop
objFile.Close
set objFile = Nothing
set objFSO = Nothing

Sub OutPrint(KPath)

  Dim IsDirPath
  IsDirPath = 0
  If objFSO.FolderExists("X:\" & RootPath & KPath) Then
    IsDirPath = 1
  End If

  Dim Pos, FileParentPath
  Pos = InstrRev(KPath, "\")
  FileParentPath = ""
  If Pos > 0 Then
    FileParentPath = Left(KPath, Pos)
  End If

  Dim SubFolderPathWithSlash
  SubFolderPathWithSlash = ""
  If IsDirPath = 1 Then
    WSH.Echo " /S /E ""X:\" & RootPath & KPath & """ ""X:\[KEEP_ITEMS]\" & KPath & "\"""
    If AddSameNameManifests Then
      WSH.Echo """X:\" & RootPath & "Manifests\" & KPath & ".manifest"" " & _
                        """X:\[KEEP_ITEMS]\" & "Manifests\"""
    End If
  Else
    If FileParentPath = "" Then
      SubFolderPathWithSlash = ExSubFolderPath
      If SubFolderPathWithSlash <> "" Then SubFolderPathWithSlash = SubFolderPathWithSlash & "\"
      WSH.Echo """X:\" & RootPath & SubFolderPathWithSlash & KPath & """ ""X:\[KEEP_ITEMS]\" & SubFolderPathWithSlash & """"
    Else
      WSH.Echo """X:\" & RootPath & KPath & """ ""X:\[KEEP_ITEMS]\" & FileParentPath & """"
    End If
  End If
End Sub

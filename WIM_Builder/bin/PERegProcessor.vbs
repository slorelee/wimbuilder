Const OpenAsASCII = 0
Const OpenAsUnicode = -1

Const FailIfExist = 0
Const OverwriteIfExist = -1

Const ForReading = 1
Const ForWriting = 2
Const ForAppending = 8

Dim argCount:argCount = Wscript.Arguments.Count

If argCount = 0 Then
  Wscript.Quit(1)
End If

Dim inFile, outFile, inStream, outStream, inLine, FileSys, WshShell
inFile = Wscript.Arguments(0)
outFile = Wscript.Arguments(0) & "_"

Set WshShell = Wscript.CreateObject("Wscript.Shell")
Set FileSys = CreateObject("Scripting.FileSystemObject")

Set inStream = FileSys.OpenTextFile(inFile, ForReading, FailIfNotExist, OpenAsUnicode)
Set outStream = FileSys.CreateTextFile(outFile, OverwriteIfExist, OpenAsUnicode)

Do
  inLine = inStream.ReadLine
  If Left(inLine, 1) = "[" Then inLine = RegKeyTrans(inLine)
  outStream.WriteLine inLine
Loop Until inStream.AtEndOfStream

inStream.Close
outStream.Close


Function RegKeyTrans(str)
  Dim doneFlag
  Dim preMark
  RegKeyTrans = str
  preMark = "["
  If Left(str, 2) = "[-" Then preMark = "[-"
  RegKeyTrans = RegKeyRePlacer(doneFlag, str, preMark, "HKEY_CLASSES_ROOT\", "HKEY_LOCAL_MACHINE\PE_SOFTWARE\Classes\")
  If doneFlag = 1 Then Exit Function
  RegKeyTrans = RegKeyRePlacer(doneFlag, str, preMark, "HKEY_CURRENT_USER\", "HKEY_LOCAL_MACHINE\PE_DEFAULT\")    'HKEY_LOCAL_MACHINE\PE_NTUSER.DAT\"
  If doneFlag = 1 Then Exit Function
  RegKeyTrans = RegKeyRePlacer(doneFlag, str, preMark, "HKEY_LOCAL_MACHINE\SAM\", "HKEY_LOCAL_MACHINE\PE_SAM\")
  If doneFlag = 1 Then Exit Function
  RegKeyTrans = RegKeyRePlacer(doneFlag, str, preMark, "HKEY_LOCAL_MACHINE\SECURITY\", "HKEY_LOCAL_MACHINE\PE_SECURITY\")
  If doneFlag = 1 Then Exit Function
  RegKeyTrans = RegKeyRePlacer(doneFlag, str, preMark, "HKEY_LOCAL_MACHINE\SOFTWARE\", "HKEY_LOCAL_MACHINE\PE_SOFTWARE\")
  If doneFlag = 1 Then Exit Function
  RegKeyTrans = RegKeyRePlacer(doneFlag, str, preMark, "HKEY_LOCAL_MACHINE\SYSTEM\", "HKEY_LOCAL_MACHINE\PE_SYSTEM\")
  If doneFlag = 1 Then Exit Function
  RegKeyTrans = RegKeyRePlacer(doneFlag, str, preMark, "HKEY_USERS\.DEFAULT\", "HKEY_LOCAL_MACHINE\PE_DEFAULT\")
  If doneFlag = 1 Then Exit Function
End Function

Function RegKeyRePlacer(doneFlag, str, preMark, okey, nkey)
  RegKeyRePlacer = str
  doneFlag = 0
  If InStr(1, str, preMark + okey) = 1 Then
    RegKeyRePlacer = Replace(str, preMark + okey, preMark + nkey, 1, 1)
    doneFlag = 1
  End If
End Function

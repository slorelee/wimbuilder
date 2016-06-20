Dim f, b, n
f = Split("30;31;32;33;34;35;36;37;90;91;92;93;94;95;96;97", ";")
b = Split("40;41;42;43;44;45;46;47;100;101;102;103;104;105;106;107", ";")
n = Split("Black;Red;Green;Yellow;Blue;Magenta;Cyan;Lgray;" + _
          "Dark gray;Lred;Lgreen;Lyellow;Lblue;Lmagenta;Lcyan;White", ";")

WSH.echo "\033[97;104mCMDCOLOR \033[97;105mTABLE"
Dim i, j, k, colorstr
For i = 0 To 15
  For j = 0 To 15
    'colorstr = colorstr & "\033[" & f(i) & ";" & b(j) & "m" & Left("[" & f(i) & ";" & b(j) & "m" & n(i) & " on " & n(j) & Space(30), 30)
    colorstr = colorstr & "\033[" & f(i) & ";" & b(j) & "m" & "test123"
    k = k + 1
    If k mod 16 = 0 Then
      WSH.echo colorstr
      colorstr = ""
    End If
  Next
Next

WSH.echo vbCrLf & "\033[97;101mCOLOR \033[97;104mCODE"

For i = 0 To 15
  For j = 0 To 15
    colorstr = colorstr & "\033[" & f(i) & ";" & b(j) & "m" & Left(f(i) & ";" & b(j) & "m" & Space(10), 7)
    k = k + 1
    If k mod 16 = 0 Then
      WSH.echo colorstr
      colorstr = ""
    End If
  Next
Next






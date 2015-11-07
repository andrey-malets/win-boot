set shell = CreateObject("WScript.Shell")

call shell.Run("diskpart /s c:\boot\attach.txt", 0, True)

for i = 1 to 600
  rv = shell.Run("cmd /c dir /a:s b:", 0, True)
  if rv = 0 then
    Wscript.Quit(0)
  end if
  call shell.Run("diskpart /s c:\boot\assign.txt", 0, True)
  WScript.Sleep(1000)
next

Wscript.Quit(1)

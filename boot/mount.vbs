sub Log(msg)
  WScript.StdOut.WriteLine(DateInfo & Now & " " & msg)
end sub

sub DumpToLog(prefix, stream)
  while not stream.AtEndOfStream
    Log(prefix & stream.ReadLine())
  wend
end sub

function Run(cmd)
  Log("running  """ & cmd & """")
  set shell = CreateObject("WScript.Shell")
  set proc = shell.Exec(cmd)
  do
    Wscript.Sleep 500
  loop until proc.Status = 1
  DumpToLog "stdout: ", proc.StdOut
  DumpToLog "stderr: ", proc.StdErr
  Log("finished """ & cmd & """, exit code: " & proc.ExitCode)
  Run = proc.ExitCode
end function

Log("starting")

for i = 1 to 1200
  Log("checking if already mounted with dir")
  rv = Run("cmd /c dir /a:s b:")
  if rv = 0 then
    Log("dir returned OK, exiting")
    Log("")
    Wscript.Quit(0)
  end if
  Log("dir failed, trying to attach and assign")
  Run("diskpart /s c:\boot\attach.txt")
  Log("done attaching, now assigning")
  Run("diskpart /s c:\boot\assign.txt")
  Log("done assigning, sleeping for 1 second")

  WScript.Sleep(1000)
next

Log("failed waiting")
Log("")
Wscript.Quit(1)

dim gShell, gComputerName
sub Init()
  set gShell = CreateObject("WScript.Shell")
  gComputerName = gShell.ExpandEnvironmentStrings("%COMPUTERNAME%")
end sub

sub Log(msg)
  WScript.StdOut.WriteLine(DateInfo & Now & "  " & gComputerName & "  " & msg)
end sub

function EscapeForLog(rawLine)
  rawLine = Replace(rawLine, Chr(13), "")
  rawLine = Replace(rawLine, Chr(10), "")
  EscapeForLog = Replace(rawLine, Chr(255), " ")
end function

sub DumpToLog(prefix, stream)
  while not stream.AtEndOfStream
    Log(prefix & EscapeForLog(stream.ReadLine()))
  wend
end sub

function Run(cmd)
  Log("running  """ & cmd & """")
  set proc = gShell.Exec(cmd)
  do
    Wscript.Sleep 500
  loop until proc.Status = 1

  DumpToLog " stdout: ", proc.StdOut
  DumpToLog " stderr: ", proc.StdErr
  Log("finished """ & cmd & """, exit code: " & proc.ExitCode)
  Run = proc.ExitCode
end function

function RunDiskPart(cmdFile)
  RunDiskPart = Run("diskpart /s " & cmdFile)
end function

function Main(check, attach, assign, timeout)
  Init()
  Log("starting")

  for i = 1 to timeout
    Log("checking if already mounted")
    rv = Run(check)
    if rv = 0 then
      Log("check returned OK, done")
      Main = True
      exit function
    end if
    Log("check failed, trying to attach and assign")
    RunDiskPart(attach)
    Log("done attaching, now assigning")
    RunDiskPart(assign)
    Log("done assigning, sleeping for 1 second")
    WScript.Sleep(1000)
  next

  Log("failed waiting")
  Main = False
end function

if Main("cmd /c dir /a:s b:", _
        "c:\boot\attach.txt", "c:\boot\assign.txt", 600) then
  Wscript.Quit(0)
else
  Wscript.Quit(1)
end if

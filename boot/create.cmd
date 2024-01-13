del /s /q C:\boot\bootmgr.vhd
diskpart /s c:\boot\create.txt
bootsect /nt60 b: /mbr
bcdboot c:\Windows /s b:

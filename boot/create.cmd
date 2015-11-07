diskpart /s c:\boot\create.txt
bootsect /nt60 b: /mbr
bcdboot c:\Windows /s b:

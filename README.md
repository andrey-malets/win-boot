### Overview

This is a set of scripts and configurations to succesfully install and boot
Windows 7 (and up, probably) from GPT-partitioned drive on a system with BIOS.
This may be convenient if you benefit from GPT features such as partition
labeling, unique GUIDs and raised partition count/size limits.

Windows does not permit this by default, the solution is to create a small
MBR-partitioned virtual drive and place boot-related files to it, so that
Windows will treat this virtual drive as real boot drive and perform all the
boot configuration there. The drive then gets attached automatically at every
boot so all boot-related configuration tasks which are run after installation
(BCD specialization step, updates etc.) complete succesfully.


### Setup procedure

Setup can be accomplished in the following way:

1. Partition your hard drive with GPT using any external tool available. For
  example, using GNU parted this may be like the following:
  ```
  (parted) mklabel gpt
  (parted) mkpart primary 0% 10MB
  (parted) mkpart primary ext4 10MB 210MB
  (parted) mkpart primary ntfs 210MB 100%
  (parted) set 1 bios_grub on
  ```
  This will create small 10MB primary partition at the very beginning with flag
  necessary to install GRUB into GPT drive, and also 200MB ext4 partition
  where GRUB root directory will reside.

  Also here we create third NTFS partition for Windows which spans to the end
  of the drive (change this for your needs).

2. Format and mount your GRUB root partition.

3. Install GRUB to your hard drive using `grub-install` and partition formatted
  in the previous step as boot directory.

4. Install [`grub.cfg`](grub.cfg) and MEMDISK from SysLinux into boot directory.

5. You need Windows PE bootable image with ImageX installed into it (does not
  come by default) and Windows setup DVD. Boot your computer to Windows PE to
  get access to PE command prompt.

6. Format third partition of your hard drive, for example using DiskPart
  (assuming disk #0 is your hard drive):
  ```
  DISKPART> select disk 0
  DISKPART> select partition 3
  DISKPART> format label="Windows 7" quick
  DISKPART> assign letter=c
  ```

7. Install Windows using ImageX (be careful with the letter of your CD/DVD
  here, this assumes D: is your Windows setup DVD):
  ```
  X:\> imagex /apply D:\sources\install.wim 1 c:
  ```

8. Copy [`boot/`](boot/) directory from this repository to C:\boot (for example
  using Samba share).

9. Execute [`C:\boot\create.cmd`](boot/create.cmd). This will create VHD drive
  and place all necessary boot files in it.

10. The next step is crucial for the whole setup. You should reboot your
  machine into new Windows installation and mount the boot VHD drive manually
  **before** Windows starts to specialize BCD which is located on the VHD.
  To do this, wait until "Windows is installing devices" message appears and
  then press `Shift+F10` to get command prompt window. Then type this:
  ```
  > C:\boot\mount.cmd
  ```
  This may take some time as the script waits until the drive actually appears
  as a volume, and keeps trying to assign it for 10 minutes.

  If you get this message: "Windows Setup could not configure Windows to run
  on this computer's hardware", then probably you did this too late and you
  need to repeat the procedure from step 5.

  This has to be done only once during setup. Later we will configure a service
  to mount boot volume automatically at startup.

11. If setup process continues without errors then all went OK and now we need
  to configure the system to mount VHD drive at startup in order to allow it
  correctly handle BCD during updates. You may do this by installing Windows
  Resource Kit Tools (reg files in this repository assume that Windows Server
  2003 Resource Kit Tools are installed). After you install this, you may simply
  add [`bootmgr.reg`](boot/bootmgr.reg) to the registry. This will install the
  service named `bootmgr` via `srvany.exe` utility from the Resource Kit. You
  can then check if this works by starting this service and looking if the
  volume B: appears. If all is OK and B: shows in the Explorer you can check
  if BCD utilities work correctly by e.g. executing `bcdedit` without args in
  elevated command prompt and looking for output (it should dump current
  configuration and not give errors such as "store could not be opened"). If
  all is OK you can reboot now and see if the service succesfully mounts the
  boot volume at system startup.

12. Optionally you may wish to hide drive B: from the Explorer window as there
  is little benefit from it there. Simply merge [`hide.reg`](boot/hide.reg)
  into the registry and reboot (probably relogin will sufficient).


### Thanks and references

1. Big thanks to **wzyboy** and his original post about boot vrom VHD drive
  on reboot.pro (in English: http://reboot.pro/topic/19516-hack-bootmgr-to-boot-windows-in-bios-to-gpt/page-2#entry184489)
  which gives the base idea of booting Windows from VHD with GRUB.
  90% of this code was written using his instructions.
2. SysLinux MEMDISK is described here: http://www.syslinux.org/wiki/index.php/MEMDISK
3. Microsoft's article on creating a User-Defined Service:
  https://support.microsoft.com/en-us/kb/137890
4. An article about building Custom Windows PE Image:
  https://technet.microsoft.com/en-us/library/cc709665(v=ws.10).aspx
5. GNU Parted: http://www.gnu.org/software/parted/
6. GNU GRUB: https://www.gnu.org/software/grub/

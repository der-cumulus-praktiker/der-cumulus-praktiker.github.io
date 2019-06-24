@echo off
:: Virtuelle Maschine in VMware Workstation (Windows) aus Vorlage anlegen und einrichten

:: OVA-Datei herunterladen (vorher auf der Webseite mit Kundenkonto anmelden)
wget.exe http://cumulusfiles.s3.amazonaws.com/CumulusLinux-3.7.4/cumulus-linux-3.7.4-vx-amd64-vmware.ova


:: VM erstellen
"%ProgramFiles(x86)%\VMware\VMware Workstation\OVFTool\ovftool" --name=SW01 cumulus-linux-3.7.4-vx-amd64-vmware.ova c:\vmware\

:: Virtuelle Hardwareversion auf neusten Stand bringen
"%ProgramFiles(x86)%\VMware\VMware VIX\vmrun" -T ws upgradevm c:\VMware\SW01\SW01.vmx

:: VM und GUI starten
"%ProgramFiles(x86)%\VMware\VMware VIX\vmrun" -T ws start c:\VMware\SW01\SW01.vmx

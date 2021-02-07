#!/bin/bash

cd
mkdir tools
cd tools

# nmap & enumeration automation
git clone https://github.com/secforce/sparta.git
git clone https://github.com/Tib3rius/AutoRecon


# linux priv esc
wget https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy32s
wget https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy64s
git clone https://github.com/rebootuser/LinEnum
git clone https://github.com/diego-treitos/linux-smart-enumeration


# powershell
git clone https://github.com/samratashok/nishang


# windows priv esc
wget https://github.com/ohpe/juicy-potato/releases/download/v0.1/JuicyPotato.exe
wget https://github.com/itm4n/PrintSpoofer/releases/download/v1.0/PrintSpoofer64.exe
wget https://github.com/itm4n/PrintSpoofer/releases/download/v1.0/PrintSpoofer32.exe
wget https://download.sysinternals.com/files/AccessChk.zip
wget https://download.sysinternals.com/files/PSTools.zip
git clone https://github.com/411Hall/JAWS
git clone https://github.com/S3cur3Th1sSh1t/WinPwn
wget https://github.com/AlessandroZ/LaZagne/releases/download/2.4.3/lazagne.exe

# windows lateral movement
wget https://the.earth.li/~sgtatham/putty/latest/w64/plink.exe -O plink64.exe
wget https://the.earth.li/~sgtatham/putty/latest/w32/plink.exe -O plink32.exe
git clone https://github.com/jpillora/chisel

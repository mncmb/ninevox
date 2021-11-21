# info
This project is heavily based on https://github.com/Marshall-Hallenbeck/red_team_attack_lab.
Another influence is https://www.aidanmitchell.uk/orchestrating-the-hacklab-part-1/.

# testing autopsy
 - test images: https://digitalcorpora.org/corpora/disk-images 
 - nps-2010-emails is pretty small

## todo rework readme 
so that is useful


## software stack
for included software see 'ansible/roles/windows_forensics/vars/tools.yml'


## forensics
Contains Arsenal Image Mounter, FTK Imager and KAPE. Due to their licenses these are excluded from the repo. Bring your own. For non commercial use, you can download these from the respective links for free.

## TODO
- setting desktop shortcuts for tools, potentially with [install-chocolateyshortcut](https://docs.chocolatey.org/en-us/create/functions/install-chocolateyshortcut)
- set tasklist shortcuts for different applications
- dev share: mounted share from host system for win-dev
- BGI file, config and custom wallpaper


- windows_interactive tools needed on interactive windows systems


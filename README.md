# oot3dhax
This is a 3DS savedata exploit for "The Legend of Zelda: Ocarina of Time 3D". Hence the datetime displayed for the save-slot, this haxx has existed since October 2012. The following regions are supported: USA, EUR, and JPN. Since the gamecard(there's only one "version" of the main CXI used for the gamecard) and eShop versions of the game are basically identical, the exploit can be used with both(if one can get the exploit savedata written to the savedata used by the target game version of course).  

This savegame haxx is the same one referred to here: https://www.3dbrew.org/wiki/5.0.0-11  

For details on the vuln/etc, see source and here: https://www.3dbrew.org/wiki/3DS_Userland_Flaws

### Haxx usage
1. Goto the save-slot select screen
2. Select haxx save-saveslot 
3. Begin loading the save-slot
4. Wait for the game to finish loading
5. Either press A, do anything triggering display of dialogs, or press any button on the touch-screen(the VIEW button, the MAP button, and the buttons for the currently equipped items don't trigger it).  

### 11.0.0.33 support
Currently system-version 11.0.0.33 is not supported, as mentioned here: https://www.3dbrew.org/wiki/11.0.0-33

Once this is updated to use [3ds_ropkit](https://github.com/yellows8/3ds_ropkit), v11.0 will be supported.

### Build methods
There's two build methods:
* Build the savefiles then write those to the savedata FS via other methods (recommended), such as ctrclient-yls8.
* Build the savefiles + generate a save with 3dsfuse then update the AESMAC (see Makefile, requires a tool for actually calculating the AESMAC).  

Make command: 
"make EXECHAX={value} FWVER={value}"
FWVER should be any value >=0x25 for system-version >=v5.0 with EXECHAX=2, value 0x1F otherwise.  
The following option can be added to the end of the above command, to disable calling dsp_shutdown(): "DISABLE_DSPSHUTDOWN=1" Normally this isn't needed. This option *must* *not* be used when this build would be used with a ninjhax2 payload.bin.

EXECHAX values(see also https://www.3dbrew.org/wiki/3DS_System_Flaws):
* 0 for arm9 pxips9hax(fixed with v5.0).
* 1 for arm11code-loading via reading the savefile with fsuser directly to .text(fixed with system-version v4.0).
* 2 for GSP arm11code-loading haxx.
* 3 for arm9hax with AM(fixed with v5.0).

The arm11-code uses gxcmd4 to load "/payload.bin" from the savedata FS to process-address 0x00101000 for execution, see source(filesize can be arbitrary).  
The arm9-code loads a payload from SD card, see source.  

# Installation
The recommended way to install oot3dhax is with either sploit_installer(https://github.com/smealum/sploit_installer), which is included with the homebrew starter-kit(https://smealum.github.io/3ds/), or by writing save-images with a gamecard save dongle for example.

Raw save-images which can be written to the gamecard savedata flash are contained in the oot3dhax release-archive. The "saveimages" directory is for raw 0x20000-byte saveimages, while "saveimages_powersaves" is for Datel Powersaves. Those directories contain two sub-directories, each for a different cardid set. If you don't know what the cardids for your gamecard are(these are included with what are commonly called "gamecard-unique headers"), just try either directory until one of them works without the game triggering a savedata-corruption error at boot. These directories then contain sub-directories for each game region. The saveimage files under those region directories have the same filename as the payload contained in the savedata, you can use the filename from this to determine which saveimage filename to use: https://smealum.github.io/3ds/#otherapp

Before using the "saveimages" directory, you should verify that your savedata backup filesize matches the filesize from the files from that directory.

Instructions for using with Datel Powersaves:
* 1) Backup your gamecard savedata with Powersaves, even if you don't want to keep that savedata.
* 2) In Windows Explorer, goto "C:\Users\YourUsername\Powersaves3DS".
* 3) Copy the saveimage you selected from the saveimages_powersaves directory in the release-archive as described above, to this Powersaves3DS directory.
* 4) Rename your backup save to a different filename.
* 5) Rename the oot3dhax saveimage to the filename which the backup save had originally.
* 6) Use Powersaves to restore the save.

# Credits
* Myria: REing Powersaves for the additional save header(+ this tool https://github.com/Myriachan/Powersaves3DS/blob/master/MakePowersave.py), testing saveimages for the 3 regions(USA+EUR+JPN), and for Powersaves instructions which the above instructions are based on.


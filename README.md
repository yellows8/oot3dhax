# oot3dhax
This is a 3DS savedata exploit for "The Legend of Zelda: Ocarina of Time 3D". Hence the datetime displayed for the save-slot, this haxx has existed since October 2012. The following regions are supported: JPN, USA, EUR, KOR, and CHNTWN(CHN and TWN have the exact same title). Since the gamecard(there's only one "version" of the main CXI used for the gamecard) and eShop versions of the game are basically identical, the exploit can be used with both(if one can get the exploit savedata written to the savedata used by the target game version of course).  

KOR and CHNTWN support is currently broken somehow.

The Nintendo Selects versions of this game are supported.

This savegame haxx is the same one referred to here: https://www.3dbrew.org/wiki/5.0.0-11  

For details on the vuln/etc, see source and here: https://www.3dbrew.org/wiki/3DS_Userland_Flaws

### Haxx usage
1. Goto the save-slot select screen
2. Select haxx save-saveslot 
3. Begin loading the save-slot
4. Wait for the game to finish loading
5. Press A, for triggering dialog handling.  

### 11.0.0.33 support
[11.0.0.33](https://www.3dbrew.org/wiki/11.0.0-33) is supported with the June 26, 2016, oot3dhax release builds.

### Building
The built savefiles should be used with sploit_installer, but other savefile-writing tools could be used too. The built romfs data for sploit_installer is located at "finaloutput_romfs/".

Make command: 
"make EXECHAX={value} FWVER={value}"

EXECHAX values(see also https://www.3dbrew.org/wiki/3DS_System_Flaws):
* 0 for arm9 pxips9hax(fixed with v5.0).
* 1 for arm11code-loading via reading the savefile with fsuser directly to .text(fixed with system-version v4.0).
* 2 for GSP arm11code-loading haxx. This is done with [3ds_ropkit](https://github.com/yellows8/3ds_ropkit).
* 3 for arm9hax with AM(fixed with v5.0).

The arm9-code loads a payload from SD card, see source.  

Note that any EXECHAX type using arm9hax will fail to build the KOR + CHNTWN savefiles, you can ignore this if you aren't using the KOR or CHNTWN savefiles.

# Installation
The recommended way to install oot3dhax is with either sploit_installer(https://github.com/smealum/sploit_installer), which is included with the homebrew starter-kit(https://smealum.github.io/3ds/), or by writing save-images with a gamecard save dongle for example.

The release-archive saveimages doesn't include KOR and CHNTWN because newer save crypto is used with those regions' gamecard. Hence, you have to use sploit_installer to install oot3dhax for those regions(but currently there's no hosted \*hax payloads available for the CHNTWN regions, as of July 29, 2016).

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
* Shakey: Support for KOR + CHNTWN via running oot3dhax_geninc.sh / etc, and the testing for those regions.


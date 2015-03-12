This is a 3DS savedata exploit for "The Legend of Zelda: Ocarina of Time 3D". Hence the datetime displayed for the save-slot, this haxx has existed since October 2012. The following regions are supported: USA, EUR, and JPN.  

Haxx usage: 1) goto the save-slot select screen 2) select haxx save-saveslot 3) begin loading the save-slot 4) wait for the game to finish loading 5) either press A, do anything triggering display of dialogs, or press any button on the touch-screen.  
  
There's two build methods: build the savefiles + generate a save with 3dsfuse then update the AESMAC, or build the savefiles then write those to the savedata FS via other methods, such as ctrclient-yls8.  

Make command: "make {savefiles} EXECHAX={value} FWVER={value} NEW3DS={value}" EXECHAX=2 for GSP arm11code-loading haxx. FWVER should be any value >=0x25 for system-version >=v5.0 with EXECHAX=2, value 0x1F otherwise. NEW3DS=1 on New3DS, 0 otherwise.  
Build oot3d_savetool with the following: gcc -o oot3d_savetool oot3d_savetool.c  

For reading/writing the savefile(this can be any save0X.bin file) with ctrclient-yls8, for gamecard:
* Reading save00.bin: ctrclient-yls8 --serveradr={ipadr} "--customcmd=directfilerw 0x567890B1 0x1 0x1 0x4 0x18 0x1 0x0 2F007300610076006500300030002E00620069006E000000 @out.bin"
* Write save00.bin:   ctrclient-yls8 --serveradr={ipadr} "--customcmd=directfilerw 0x567890B1 0x1 0x1 0x4 0x18 0x7 0x14dc 0x0 2F007300610076006500300030002E00620069006E000000 @input.bin"
* Write payload.bin:  ctrclient-yls8 --serveradr={ipadr} "--customcmd=directfilerw 0x567890B1 0x1 0x1 0x4 0x1a 0x7 0x1800 0x0 2F007000610079006C006F00610064002E00620069006E000000 @payload.bin"
* Read payload.bin:   ctrclient-yls8 --serveradr={ipadr} "--customcmd=directfilerw 0x567890B1 0x1 0x1 0x4 0x1a 0x1 0x0 2F007000610079006C006F00610064002E00620069006E000000 @out.bin"


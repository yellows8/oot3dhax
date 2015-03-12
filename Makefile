ifeq ($(strip $(DEVKITARM)),)
$(error "Please set DEVKITARM in your environment. export DEVKITARM=<path to>devkitARM")
endif

include $(DEVKITARM)/base_rules

ifeq ($(strip $(SAVECMD)),)
	SAVECMD	:=	
endif

ifeq ($(strip $(EXECHAX)),)
$(error "EXECHAX not set.")
endif

ifeq ($(strip $(SD)),)
	SAVECMD	+=	--gamecard
endif

ifeq ($(SD),1)
	SAVECMD	+=	--sdsave
endif

ifeq ($(strip $(FWVER)),)
$(error "FWVER not set.")
endif

SAVETOOL_OPT	:= 

ifneq ($(strip $(OUTPATH)),)
	SAVETOOL_OPT	:= $(OUTPATH)/part_00/save00.bin
endif

ifeq ($(strip $(CARDID)),)
	CARDID	:=	c2fe0090
endif

all:	oot3dhax_E.sav oot3dhax_P.sav oot3dhax_J.sav
savefiles:	save_usa.bin save_eur.bin save_jpn.bin

clean:
	rm -f oot3dhax_usa.elf oot3dhax_eur.elf oot3dhax_jpn.elf save_usa.bin save_eur.bin save_jpn.bin oot3dhax_E.sav oot3dhax_P.sav oot3dhax_J.sav

oot3dhax_E.sav: save_usa.bin
	ctr-savetool --insave=$(OUTPATH)/clean.sav --genxorpad=$(OUTPATH)/xorpad.bin --genmac --writemac --keyY=04c546b165b23e0b$(CARDID)00000000 $(SAVECMD) --saveid=0004000000033500
	cp $(OUTPATH)/output.sav oot3dhax_E.sav

oot3dhax_P.sav: save_eur.bin
	ctr-savetool --insave=$(OUTPATH)/clean.sav --genxorpad=$(OUTPATH)/xorpad.bin --genmac --writemac --keyY=53c6617397623ea4$(CARDID)00000000 $(SAVECMD)
	cp $(OUTPATH)/output.sav oot3dhax_P.sav

oot3dhax_J.sav: save_jpn.bin
	ctr-savetool --insave=$(OUTPATH)/clean.sav --genxorpad=$(OUTPATH)/xorpad.bin --genmac --writemac --keyY=969461b9340ff444$(CARDID)00000000 $(SAVECMD)
	cp $(OUTPATH)/output.sav oot3dhax_J.sav

save_usa.bin: oot3dhax_usa.elf
	$(OBJCOPY) -O binary oot3dhax_usa.elf save_usa.bin
	./oot3d_savetool save_usa.bin $(SAVETOOL_OPT)

save_eur.bin: oot3dhax_eur.elf
	$(OBJCOPY) -O binary oot3dhax_eur.elf save_eur.bin
	./oot3d_savetool save_eur.bin $(SAVETOOL_OPT)

save_jpn.bin: oot3dhax_jpn.elf
	$(OBJCOPY) -O binary oot3dhax_jpn.elf save_jpn.bin
	./oot3d_savetool save_jpn.bin $(SAVETOOL_OPT)

oot3dhax_usa.elf:	oot3dhax.s
	$(CC) -x assembler-with-cpp -nostartfiles -nostdlib -DREGION=1 -DEXECHAX=$(EXECHAX) -DFWVER=$(FWVER) $< -o oot3dhax_usa.elf

oot3dhax_eur.elf:	oot3dhax.s
	$(CC) -x assembler-with-cpp -nostartfiles -nostdlib -DREGION=2 -DEXECHAX=$(EXECHAX) -DFWVER=$(FWVER) $< -o oot3dhax_eur.elf

oot3dhax_jpn.elf:	oot3dhax.s
	$(CC) -x assembler-with-cpp -nostartfiles -nostdlib -DREGION=0 -DEXECHAX=$(EXECHAX) -DFWVER=$(FWVER) $< -o oot3dhax_jpn.elf


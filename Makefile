ifndef DEVKITARM
       $(error "Please set DEVKITARM in your environment. export DEVKITARM=<path to>devkitARM")
endif

## ======================
## Global variables
## ======================

SAVE_FILES	= oot3dhax_jpn.bin oot3dhax_usa.bin oot3dhax_eur.bin oot3dhax_kor.bin oot3dhax_chntwn.bin
REGIONS		= jpn usa eur kor chntwn
TITLEIDS	= 0004000000033400 0004000000033500 0004000000033600 000400000008f800 000400000008f900
ELF_FILES	= $(SAVE_FILES:.bin=.elf)

## ======================
## oot3d_savetool variables
## TODO: Beautiful compilation with .o file.
## ======================

SAVETOOL_NAME	= oot3d_savetool
ST_CFLAGS	= -W -Wall -Wextra -std=c99 -O3
SAVETOOL_SRCS	= oot3d_savetool.c

SAVETOOL_OPT	=

## ======================
## ELF build variables
## ======================

DEFINES	=	

ELF_FLAGS	= -x assembler-with-cpp -nostartfiles -nostdlib -DREGION=$(DREGION) -DEXECHAX=$(EXECHAX) -DFWVER=$(FWVER) $(DEFINES) -include ropinclude/$(DREGION) -I$(ROPKIT_PATH)
ELF_SRCS	= oot3dhax.s

## ======================
## BIN build variables
## ======================

BIN_FLAGS	= -O binary

## ===================================================================
## Targets
## ===================================================================

all: requirements
	@mkdir -p finaloutput_romfs/oot3dhax
	@echo "oot3dhax OoT3D 0x4 0004000000033400 0004000000033500 0004000000033600 000400000008f800 000400000008f900" > finaloutput_romfs/exploitlist_config
	$(MAKE) DREGION=$(word 1,$(subst :, ,$(REGIONS))) TID=$(word 1,$(subst :, ,$(TITLEIDS))) $(word 1,$(subst :, ,$(SAVE_FILES)))
	$(MAKE) DREGION=$(word 2,$(subst :, ,$(REGIONS))) TID=$(word 2,$(subst :, ,$(TITLEIDS))) $(word 2,$(subst :, ,$(SAVE_FILES)))
	$(MAKE) DREGION=$(word 3,$(subst :, ,$(REGIONS))) TID=$(word 3,$(subst :, ,$(TITLEIDS))) $(word 3,$(subst :, ,$(SAVE_FILES)))
	$(MAKE) DREGION=$(word 4,$(subst :, ,$(REGIONS))) TID=$(word 4,$(subst :, ,$(TITLEIDS))) $(word 4,$(subst :, ,$(SAVE_FILES)))
	$(MAKE) DREGION=$(word 5,$(subst :, ,$(REGIONS))) TID=$(word 5,$(subst :, ,$(TITLEIDS))) $(word 5,$(subst :, ,$(SAVE_FILES)))

## ======================
## Check requirements
## ======================

requirements:
ifndef EXECHAX
	$(error "EXECHAX not set.")
endif
ifndef FWVER
	$(error "FWVER not set.")
endif
ifndef ROPKIT_PATH
	$(error "ROPKIT_PATH is not set.")
endif

include $(DEVKITARM)/base_rules

## ======================
## Builds targets
## ======================

%.bin: %.elf $(SAVETOOL_NAME)
	$(OBJCOPY) $(BIN_FLAGS) $< $@
	./$(SAVETOOL_NAME) $(SAVETOOL_OPT) $@
	@mkdir -p finaloutput_romfs/oot3dhax/$(TID)/v1.0/common/save
	@echo "[remaster_versions]\n0000=romfs:/oot3dhax/$(TID)/v1.0@v1.0" > finaloutput_romfs/oot3dhax/$(TID)/config.ini
	@echo "save/$@=/save@!d2.bin" > finaloutput_romfs/oot3dhax/$(TID)/v1.0/common/config.ini
	@cp $@ finaloutput_romfs/oot3dhax/$(TID)/v1.0/common/save/

%.elf:
	$(CC) $(ELF_FLAGS) $(ELF_SRCS) -o $@

$(SAVETOOL_NAME):
	gcc -o $@ $(SAVETOOL_SRCS) $(ST_CFLAGS)

## ======================
## Utils targets
## ======================

clean:
	rm -f $(SAVE_FILES) $(ELF_FILES) $(SAVETOOL_NAME)

re: clean all

.PHONY: clean all re
.PRECIOUS: %.elf %.bin

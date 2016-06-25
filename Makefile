ifndef DEVKITARM
       $(error "Please set DEVKITARM in your environment. export DEVKITARM=<path to>devkitARM")
endif

## ======================
## Global variables
## ======================

SAVE_FILES	= oot3dhax_eur.bin oot3dhax_usa.bin oot3dhax_jpn.bin
REGIONS		= 2 1 0
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
	$(MAKE) DREGION=$(word 1,$(subst :, ,$(REGIONS))) $(word 1,$(subst :, ,$(SAVE_FILES)))
	$(MAKE) DREGION=$(word 2,$(subst :, ,$(REGIONS))) $(word 2,$(subst :, ,$(SAVE_FILES)))
	$(MAKE) DREGION=$(word 3,$(subst :, ,$(REGIONS))) $(word 3,$(subst :, ,$(SAVE_FILES)))

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

PROJECT = Eink-DISCOVERY
BUILDDIR = build
UINCDIR += src

# Enable / disable debugging
USE_OPT += -DENABLE_DEBUG=0

USE_OPT += -Os -g -gdwarf-2 -g3 \
	-fno-omit-frame-pointer -fno-common -std=gnu99

# Base system & bootup
PROJECT_CSRC += src/main.c src/board.c src/debug.c

# Main user interface logic
PROJECT_CSRC += src/main_logic.c

# E-ink display
PROJECT_CSRC +=  src/display.c
USE_OPT += -DEINK_WRITECOUNT=3 -DEINK_NUMBUFFERS=80

# Reading of sensors
PROJECT_CSRC += src/sensor_task.c

# Baselibc
#PROJECT_CSRC += src_common/libc_glue.c
UINCDIR += baselibc/include
ULIBS += baselibc/libc.a -lm -lgcc -nodefaultlibs

# Fixed point math libraries
# PROJECT_CSRC += libfixmath/fix16.c libfixmath/fix16_sqrt.c libfixmath/fix16_trig.c libfixmath/fix16_str.c
# UDEFS += -DFIXMATH_NO_CACHE
# UINCDIR += libfixmath

UADEFS =
ULIBDIR =

include Makefile.chibios
	
deploy: all
	#st-flash write /dev/stlinkv1_3 $(BUILDDIR)/$(PROJECT).bin 0x08000000
	openocd -d0 -f interface/stlink-v1.cfg -f target/stm32lx_stlink.cfg \
		-c init -c targets -c "reset halt" \
		-c "flash write_image erase $(BUILDDIR)/$(PROJECT).elf" \
		-c "reset run" -c shutdown

debug: all
	arm-none-eabi-gdb $(BUILDDIR)/$(PROJECT).elf

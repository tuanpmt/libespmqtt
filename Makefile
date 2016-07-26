# Directory the Makefile is in. Please don't include other Makefiles before this.
THISDIR:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))

#Include mqtt config from lower level, if it exists
-include ../espmqttconfig.mk

#Default options. If you want to change them, please create ../espmqttconfig.mk with the options you want in it.
# defaut MQTT version 3.1.1
PROTOCOL_VER31 ?= 0

#For FreeRTOS
MQTT_STACKSIZE ?= 2048
#Auto-detect ESP32 build if not given.
ifneq (,$(wildcard $(SDK_PATH)/include/esp32))
ESP32 ?= yes
FREERTOS ?= yes
else
ESP32 ?= no
FREERTOS ?= no
endif

# Output directors to store intermediate compiled files
# relative to the project directory
BUILD_BASE	= build

# Base directory for the compiler. Needs a / at the end; if not set it'll use the tools that are in
# the PATH.
XTENSA_TOOLS_ROOT ?=

# base directory of the ESP8266 SDK package, absolute
# Only used for the non-FreeRTOS build
SDK_BASE	?= /tools/esp8266/sdk/ESP8266_NONOS_SDK_V2.0.0_16_07_19

# Base directory of the ESP8266 FreeRTOS SDK package, absolute
# Only used for the FreeRTOS build
SDK_PATH	?= /tool/esp8266/sdk/ESP8266_RTOS_SDK


# name for the target project
LIB		= libespmqtt.a

# which modules (subdirectories) of the project to include in compiling
MODULES		= src
EXTRA_INCDIR	= ./include \
								.


# compiler flags using during compilation of source files
CFLAGS	= -Os -ggdb -std=c99 -Werror -Wpointer-arith -Wundef -Wall -Wno-comment -Wl,-EL -fno-inline-functions \
		-nostdlib -mlongcalls -mtext-section-literals  -D__ets__ -DICACHE_FLASH \
		-Wno-address -DMQTT_STACKSIZE=$(MQTT_STACKSIZE) -DPROTOCOL_NAMEv31

# various paths from the SDK used in this project
SDK_LIBDIR	= lib
SDK_LDDIR	= ld


ifeq ("$(FREERTOS)","yes")
CFLAGS		+= -DFREERTOS -DLWIP_OPEN_SRC -ffunction-sections -fdata-sections
ifeq ("$(ESP32)","yes")
SDK_INCDIR	= include \
			include/esp32 \
			driver_lib/include \
			extra_include \
			third_party/include \
			third_party/include/cjson \
			third_party/include/freertos \
			third_party/include/lwip \
			third_party/include/lwip/ipv4 \
			third_party/include/lwip/ipv6 \
			third_party/include/ssl
CFLAGS		+= -DESP32 -DFREERTOS -DLWIP_OPEN_SRC -ffunction-sections -fdata-sections
else
SDK_INCDIR	= include \
			include/freertos \
			include/espressif/esp8266 \
			include/espressif \
			extra_include \
			include/lwip \
			include/lwip/lwip \
			include/lwip/ipv4 \
			include/lwip/ipv6
CFLAGS		+= -DFREERTOS -DLWIP_OPEN_SRC -ffunction-sections -fdata-sections
endif
SDK_INCDIR	:= $(addprefix -I$(SDK_PATH)/,$(SDK_INCDIR))
else
SDK_INCDIR	= include
SDK_INCDIR	:= $(addprefix -I$(SDK_BASE)/,$(SDK_INCDIR))
endif


ifeq ("$(ESP32)","yes")
TOOLPREFIX=xtensa-esp108-elf-
CFLAGS+=-DESP32
else
TOOLPREFIX=xtensa-lx106-elf-
endif

# select which tools to use as compiler, librarian and linker
CC		:= $(XTENSA_TOOLS_ROOT)$(TOOLPREFIX)gcc
AR		:= $(XTENSA_TOOLS_ROOT)$(TOOLPREFIX)ar
LD		:= $(XTENSA_TOOLS_ROOT)$(TOOLPREFIX)gcc
OBJCOPY	:= $(XTENSA_TOOLS_ROOT)$(TOOLPREFIX)objcopy

####
#### no user configurable options below here
####
SRC_DIR		:= $(MODULES)
BUILD_DIR	:= $(addprefix $(BUILD_BASE)/,$(MODULES))

SRC		:= $(foreach sdir,$(SRC_DIR),$(wildcard $(sdir)/*.c))
OBJ		:= $(patsubst %.c,$(BUILD_BASE)/%.o,$(SRC))

INCDIR	:= $(addprefix -I,$(SRC_DIR))
EXTRA_INCDIR	:= $(addprefix -I,$(EXTRA_INCDIR))
MODULE_INCDIR	:= $(addsuffix /include,$(INCDIR))

V ?= $(VERBOSE)
ifeq ("$(V)","1")
Q :=
vecho := @true
else
Q := @
vecho := @echo
endif


ifneq ("$(FREERTOS)","yes")
ifeq ("$(USE_OPENSDK)","yes")
CFLAGS		+= -DUSE_OPENSDK
else
CFLAGS		+= -D_STDINT_H
endif
endif

ifeq ("$(GZIP_COMPRESSION)","yes")
CFLAGS		+= -DGZIP_COMPRESSION
endif

ifeq ("$(USE_HEATSHRINK)","yes")
CFLAGS		+= -DESPFS_HEATSHRINK
endif

ifeq ("$(HTTPD_WEBSOCKETS)","yes")
CFLAGS		+= -DHTTPD_WEBSOCKETS
endif

vpath %.c $(SRC_DIR)

define compile-objects
$1/%.o: %.c
	$(vecho) "CC $$<"
	$(Q) $(CC) $(INCDIR) $(MODULE_INCDIR) $(EXTRA_INCDIR) $(SDK_INCDIR) $(CFLAGS)  -c $$< -o $$@
endef

.PHONY: all checkdirs clean webpages.espfs submodules

all: checkdirs $(LIB)

$(LIB): $(BUILD_DIR) $(OBJ)
	$(vecho) "AR $@"
	$(Q) $(AR) cru $@ $(OBJ)

checkdirs: $(BUILD_DIR)

$(BUILD_DIR):
	$(Q) mkdir -p $@

clean:
	$(Q) rm -f $(LIB)
	$(Q) find $(BUILD_BASE) -type f | xargs rm -f
	$(Q) rm -rf $(FW_BASE)

$(foreach bdir,$(BUILD_DIR),$(eval $(call compile-objects,$(bdir))))

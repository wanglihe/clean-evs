# GNU Makefile

# Paths
SRC_ENC   = lib_enc lib_com
SRC_DEC   = lib_dec lib_com
BUILD     = build

SRC_DIRS  = $(sort -u $(SRC_ENC) $(SRC_DEC)) 

# Name of CLI binaries
CLI_ENC   = EVS_cod
CLI_DEC   = EVS_dec

# Name of check file
LTRACE_ENC_OUTPUT = ltrace.enc.out
LTRACE_DEC_OUTPUT = ltrace.dec.out
CHECK_INPUT = input.pcm
CHECK_ENCODED = encoded.evs
CHECK_DECODED = decoded.pcm

# Default tool settings
CC        = gcc
RM        = rm -f

# Switches for cross-platform builds (i.e. build 32 bit code on 64 bit platforms)
ifneq "$(TARGET_PLATFORM)" ""
ifeq ("$(TARGET_PLATFORM)", "$(findstring $(TARGET_PLATFORM), i386 i586 i686)")
	CFLAGS  += -m32
	LDFLAGS += -m32
endif

ifeq ("$(TARGET_PLATFORM)", "$(findstring $(TARGET_PLATFORM), x86_64)")
	CFLAGS  += -m64
	LDFLAGS += -m64
endif
endif

ifndef VERBOSE
QUIET_CC  = @echo '   ' Compiling $<;
QUIET_LINK= @echo '   ' Linking $@;
QUIET     = @
endif

# C compiler flags
CFLAGS   += -pedantic -Wcast-qual -Wall -W -Wextra -Wno-long-long     \
            -Wpointer-arith -Wstrict-prototypes -Wmissing-prototypes  \
            -Werror-implicit-function-declaration -std=c99

ifeq "$(RELEASE)" "1"
CFLAGS   += -DRELEASE
DELIVERY  = 1
OPTIM    ?= 2
endif

ifneq "$(DEBUG)" "0"
CFLAGS   += -g3
LDFLAGS  += -g3
endif

ifeq "$(WMOPS)" "1"
CFLAGS   += -DWMOPS=1
endif

OPTIM    ?= 0
CFLAGS   += -O$(OPTIM)

CFLAGS   += $(foreach DIR,$(SRC_DIRS),-I$(DIR))

# Source file search paths
VPATH     = $(SRC_DIRS)

###############################################################################

SRCS_ENC  = $(foreach DIR,$(SRC_ENC),$(patsubst $(DIR)/%,%,$(wildcard $(DIR)/*.c)))
SRCS_DEC  = $(foreach DIR,$(SRC_DEC),$(patsubst $(DIR)/%,%,$(wildcard $(DIR)/*.c)))

OBJS_ENC  = $(addprefix $(BUILD)/,$(SRCS_ENC:.c=.o))
OBJS_DEC  = $(addprefix $(BUILD)/,$(SRCS_DEC:.c=.o))

DEPS      = $(addprefix $(BUILD)/,$(SRCS_ENC:.c=.P) $(SRCS_DEC:.c=.P))

###############################################################################

.PHONY: all clean clean_all check_alloc

all: $(CLI_ENC) $(CLI_DEC)

$(BUILD):
	$(QUIET)mkdir -p $(BUILD)

$(CLI_ENC): $(OBJS_ENC)
	$(QUIET_LINK)$(CC) $(LDFLAGS) $(OBJS_ENC) -lm -o $(CLI_ENC)

$(CLI_DEC): $(OBJS_DEC)
	$(QUIET_LINK)$(CC) $(LDFLAGS) $(OBJS_DEC) -lm -o $(CLI_DEC)

check_alloc: $(CLI_ENC) $(CLI_DEC)
	ltrace -o $(LTRACE_ENC_OUTPUT) ./$(CLI_ENC) -mime 7200 8 $(CHECK_INPUT) $(CHECK_ENCODED)
	ltrace -o $(LTRACE_DEC_OUTPUT) ./$(CLI_DEC) -mime 8 $(CHECK_ENCODED) $(CHECK_DECODED)
run:
	./$(CLI_ENC) -mime 7200 8 $(CHECK_INPUT) $(CHECK_ENCODED)
	./$(CLI_DEC) -mime 8 $(CHECK_ENCODED) $(CHECK_DECODED)


clean:
	$(QUIET)$(RM) $(OBJS_ENC) $(OBJS_DEC) $(DEPS)
	$(QUIET)$(RM) $(DEPS:.P=.d)
	$(QUIET)test ! -d $(BUILD) || rm -rf $(BUILD)

clean_all: clean
	$(QUIET)$(RM) $(CLI_ENC) $(CLI_DEC) $(CHECK_ENCODED) $(CHECK_DECODED) $(LTRACE_ENC_OUTPUT) $(LTRACE_DEC_OUTPUT)

$(BUILD)/%.o : %.c | $(BUILD)
	$(QUIET_CC)$(CC) $(CFLAGS) -c -MD -o $@ $<
	@cp $(BUILD)/$*.d $(BUILD)/$*.P; \
	sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\\$$//' \
	    -e '/^$$/ d' -e 's/$$/ :/' < $(BUILD)/$*.d >> $(BUILD)/$*.P; \
	$(RM) $(BUILD)/$*.d

-include $(DEPS)


ifndef MSEGUI
MSEGUI := mseide-msegui
endif

ifeq ($(OS),Windows_NT)
OS := windows
else
OS := linux
endif

PC := fpc
PFLAGS := -Mobjfpc -Sh
PFLAGS += -Fu$(MSEGUI)/lib/common/*
PFLAGS += -Fu$(MSEGUI)/lib/common/kernel/$(OS)
PFLAGS += -Fupascalaudio/pascalaudioio
PFLAGS += -Fupascalaudio/pascalaudiosuite
PFLAGS += -Fupulseaudio
PFLAGS += -dUSEPULSE
PFLAGS += -FUunits

ifdef DEBUG
#PFLAGS += -dDEBUG
#PFLAGS += -Sa
#PFLAGS += -ghl
#PFLAGS += -vwhilq
else
PFLAGS += -dRELEASE
#PFLAGS += -vm6058
#PFLAGS += -vm4046
#PFLAGS += -vm5062
#PFLAGS += -vm5024
#PFLAGS += -vm5071
PFLAGS += -XX -Xs -CX
endif

PROGRAM := musicplayer
SOURCES := $(filter-out $(PROGRAM).pas,$(wildcard *.pas))

$(PROGRAM): $(PROGRAM).pas $(SOURCES)
	@$(PC) $(PFLAGS) $<

clean:
	rm -fv $(TARGETS) units/*.o units/*.ppu

distclean: clean
	@rm -fv *.bak *.bak? *.sta $(PROGRAM) $(PROGRAM).dbg $(PROGRAM).exe

clone:
	git clone --single-branch --depth 1 https://github.com/andrewd207/PascalAudio.git pascalaudio
	git clone --single-branch --depth 1 https://github.com/andrewd207/fpc-pulseaudio.git pulseaudio

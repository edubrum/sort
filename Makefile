
OSUPPER = $(shell uname -s 2>/dev/null | tr "[:lower:]" "[:upper:]")
OSLOWER = $(shell uname -s 2>/dev/null | tr "[:upper:]" "[:lower:]")

# internal flags
CCFLAGS     :=
LDFLAGS     :=

# Extra user flags
EXTRA_LDFLAGS     ?=
EXTRA_CCFLAGS     ?=


# Debug build flags
ifeq ($(dbg),1)
      NVCCFLAGS += -g -G
      TARGET := debug
else
      TARGET := release
endif

ALL_CCFLAGS :=
ALL_CCFLAGS += $(addprefix -Xcompiler ,$(CCFLAGS))
ALL_CCFLAGS += $(addprefix -Xcompiler ,$(EXTRA_CCFLAGS))

ALL_LDFLAGS :=
ALL_LDFLAGS += $(ALL_CCFLAGS)
ALL_LDFLAGS += $(addprefix -Xlinker ,$(LDFLAGS))
ALL_LDFLAGS += $(addprefix -Xlinker ,$(EXTRA_LDFLAGS))

GCCFLAGS = -g -Wall -Wfatal-errors 
GCC = gcc
ALL = main
#all: app
all: testsdone
	@rm cov
	@rm main.exe
array.o:array.c
	$(GCC) -o $@ -c $<

sort.o:sort.c
	$(GCC) -o $@ -c $<

get_opt.o:get_opt.c
	$(GCC) -o $@ -c $<

main.o:main.c
	$(GCC) -o $@ -c $<

app: array.o sort.o get_opt.o main.o
	$(GCC) $(ALL_LDFLAGS) -o $@ $+ $(LIBRARIES)
	
cov: array.o sort.o get_opt.o main.o 
	@echo " "
	@echo "----------------------------------------------------------"
	@echo " "
	@echo "Runinng GCOV"
	@echo " "	
	$(GCC) $(GCCFLAGS) -fprofile-arcs -ftest-coverage -o $@ $+ $(LIBRARIES)
	@echo " "
	@bash invalid_cov
	@echo " "
	gcov -b main.c
	@echo " "
	@echo "----------------------------------------------------------"
	@echo " "

cppcheck: app
	@echo "Runinng CPPCHECK"
	@echo " "
	cppcheck --enable=all --suppress=missingIncludeSystem main.c
	@echo " "
	@echo "----------------------------------------------------------"
	@echo " "

valgrind: app
	@echo "Runinng Valgrind"
	@echo " "
	$(GCC) $(GCCFLAGS) array.c sort.c get_opt.c main.c -o main.exe
	@echo " "
	@bash invalid_valgrind
	@echo " "
	@echo "----------------------------------------------------------"
	@echo " "

sanitize: app
	@echo "Runinng Sanitize"
	@echo " "
	$(GCC) $(GCCFLAGS) -fsanitize=address array.c sort.c get_opt.c main.c -o main.exe
	@echo " "
	@bash invalid_sanitize	
	@echo " "
	@echo "----------------------------------------------------------"
	@echo " "

testsdone: cov cppcheck valgrind sanitize app

clean:
	rm -f *.o
	rm -f app

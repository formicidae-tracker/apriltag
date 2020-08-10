PREFIX ?= /usr/local

CC = gcc
AR = ar

CFLAGS = -std=gnu99 -fPIC -Wall -Wno-unused-parameter -Wno-unused-function
CFLAGS += -I. -O3 -fno-strict-overflow

APRILTAG_SRCS := $(shell ls *.c common/*.c)
APRILTAG_HEADERS := $(shell ls *.h common/*.h)
APRILTAG_OBJS := $(APRILTAG_SRCS:%.c=%.o)
TARGETS := libapriltag.a libapriltag.so

.PHONY: all
all: $(TARGETS)

.PHONY: install
install: libapriltag.so libapriltag.a
	@chmod +x install.sh
	@./install.sh $(PREFIX)/lib libapriltag.so.3.1.2
	@./install.sh $(PREFIX)/lib libapriltag.so.3
	@./install.sh $(PREFIX)/lib libapriltag.so
	@./install.sh $(PREFIX)/lib libapriltag.a
	@./install.sh $(PREFIX)/include/apriltag $(APRILTAG_HEADERS)


libapriltag.a: $(APRILTAG_OBJS)
	@echo "   [$@]"
	@$(AR) -cq $@ $(APRILTAG_OBJS)

libapriltag.so: $(APRILTAG_OBJS)
	@echo "   [$@]"
	@$(CC) -fPIC -shared -lm -lpthread -Wl,-soname,libapriltag.so.3 -o libapriltag.so.3.1.2 $^
	ln -s libapriltag.so.3.1.2 libapriltag.so.3
	ln -s libapriltag.so.3 libapriltag.so

%.o: %.c
	@echo "   $@"
	@$(CC) -o $@ -c $< $(CFLAGS)

.PHONY: clean
clean:
	@rm -rf *.o common/*.o $(TARGETS)
	@rm libapriltag.so.3 libapriltag.so.3.1.2
	@$(MAKE) -C example clean

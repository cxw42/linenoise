PREFIX = /usr/local
CC = cc
CFLAGS = -Os -Wall -Wextra
#CFLAGS = -O0 -g -pg -Wall -Wextra -DUTF8CCT
#CFLAGS = -O0 -g -Wall -Wextra -DUTF8CCT

SRC = linenoise.c utf8.c
OBJ = $(SRC:.c=.o)
LIB = liblinenoise.a
INC = linenoise.h utf8.h
MAN = linenoise.3

all: $(LIB) example

$(LIB): $(INC)

$(LIB): $(OBJ)
	$(AR) -rcs $@ $(OBJ)

example: example.o $(LIB)
	$(CC) $(CFLAGS) -o $@ example.o $(LIB)

.c.o: $(INC)
	$(CC) $(CFLAGS) -c $<

install: $(LIB) $(INC) $(MAN)
	mkdir -p $(DESTDIR)$(PREFIX)/lib
	cp $(LIB) $(DESTDIR)$(PREFIX)/lib/$(LIB)
	mkdir -p $(DESTDIR)$(PREFIX)/include
	cp $(INC) $(DESTDIR)$(PREFIX)/include/$(INC)
	mkdir -p $(DESTDIR)$(PREFIX)/share/man/man3
	cp $(MAN) $(DESTDIR)$(PREFIX)/share/man/man3/$(MAN)

lib: $(LIB)

clean:
	rm -f $(LIB) example example.o $(OBJ) utf8cct.h

# gperf the combining character table, since calls to isCombiningChar take
# a very long time (per gprof) as the length of the input string increases.
utf8cct.h: utf8.c Makefile
	awk 'BEGIN { print "%{\n#include <string.h>\n%}\n%%\n" } /combiningCharTable\[\]/ {p=1;next} (p && /^}/) { exit } p {print}' utf8.c | sed -E 's/^\s*//;s/,/\n/g' | grep -v '^\s*$$' | sed -E 's/^0x//;s/^0+//' | gperf -L C > utf8cct.h

# utf8 includes utf8cct.h.
utf8.o: utf8cct.h


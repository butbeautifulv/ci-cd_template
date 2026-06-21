CC ?= afl-clang-fast
CFLAGS ?= -g -O1 -fsanitize=address -fno-omit-frame-pointer
LDFLAGS ?= -fsanitize=address

harness: harness.c target.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o harness harness.c target.c

clean:
	rm -rf harness out

.PHONY: clean

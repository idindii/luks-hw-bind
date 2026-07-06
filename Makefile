# Compiler
CC := gcc

# Compiler flags
CFLAGS := -Wall -Wextra -Werror -O2

# Linker flags
LDFLAGS := -lcrypto

# Source files
SRC := src/hmac_check.c

# Output binary
TARGET := hmac_check

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $(SRC) -o $(TARGET) $(LDFLAGS)

clean:
	rm -f $(TARGET)

.PHONY: all clean
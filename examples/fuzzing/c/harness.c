#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <unistd.h>

int parse_buffer(const uint8_t *data, size_t len);

int main(void) {
  uint8_t buf[4096];
  ssize_t n = read(0, buf, sizeof(buf));
  if (n <= 0) {
    return 0;
  }
  parse_buffer(buf, (size_t)n);
  return 0;
}

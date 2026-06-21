#include <stddef.h>
#include <stdint.h>

/* Safe demo target — fuzzing validates the pipeline, not a planted bug. */
int parse_buffer(const uint8_t *data, size_t len) {
  if (len == 0) {
    return 0;
  }
  volatile int sum = 0;
  for (size_t i = 0; i < len && i < 64; i++) {
    sum += data[i];
  }
  return sum & 0xff;
}

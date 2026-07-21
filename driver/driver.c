/*
 * driver.c — Standalone driver for Magma / libFuzzer-style harnesses.
 *
 * Provides main() and feeds one input (from a file argument or stdin)
 * into the harness function LLVMFuzzerTestOneInput().
 *
 * Build (example):
 *   clang -g -O1 -fsanitize=address -c driver.c -o driver.o
 *   # then link driver.o together with the target harness object(s)
 *
 * Usage:
 *   ./harness <input_file> [<input_file> ...]
 *   cat input | ./harness            # read from stdin when no file given
 */

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Harness entry point — defined by the Magma target harness. */
extern int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size);

/* Optional one-time initializer — provided by some harnesses.
 * Declared weak so linking succeeds even if the harness omits it. */
__attribute__((weak))
int LLVMFuzzerInitialize(int *argc, char ***argv);

/* Read an entire stream into a heap buffer. Returns size, sets *out. */
static size_t read_all(FILE *f, uint8_t **out) {
    size_t cap = 64 * 1024;
    size_t len = 0;
    uint8_t *buf = (uint8_t *)malloc(cap);
    if (!buf) {
        fprintf(stderr, "[driver] out of memory\n");
        exit(1);
    }

    for (;;) {
        if (len == cap) {
            cap *= 2;
            uint8_t *nbuf = (uint8_t *)realloc(buf, cap);
            if (!nbuf) {
                fprintf(stderr, "[driver] out of memory\n");
                free(buf);
                exit(1);
            }
            buf = nbuf;
        }
        size_t n = fread(buf + len, 1, cap - len, f);
        len += n;
        if (n == 0) {
            if (feof(f)) break;
            if (ferror(f)) {
                fprintf(stderr, "[driver] read error\n");
                free(buf);
                exit(1);
            }
        }
    }

    *out = buf;
    return len;
}

/* Run one input buffer through the harness. */
static void run_one(const uint8_t *data, size_t size) {
    LLVMFuzzerTestOneInput(data, size);
}

int main(int argc, char **argv) {
    /* Call the optional initializer if the harness defines it. */
    if (LLVMFuzzerInitialize) {
        LLVMFuzzerInitialize(&argc, &argv);
    }

    /* No file arguments -> read a single input from stdin. */
    if (argc < 2) {
        uint8_t *data = NULL;
        size_t size = read_all(stdin, &data);
        run_one(data, size);
        free(data);
        return 0;
    }

    /* Process each file argument as an independent input. */
    for (int i = 1; i < argc; i++) {
        FILE *f = fopen(argv[i], "rb");
        if (!f) {
            fprintf(stderr, "[driver] cannot open '%s'\n", argv[i]);
            continue;
        }

        uint8_t *data = NULL;
        size_t size = read_all(f, &data);
        fclose(f);

        fprintf(stderr, "[driver] running '%s' (%zu bytes)\n", argv[i], size);
        run_one(data, size);
        free(data);
    }

    return 0;
}
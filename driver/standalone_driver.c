/* standalone_driver.c
 *
 * Ersetzt die libFuzzer-Runtime. Liest Eingabedatei(en) und ruft
 * LLVMFuzzerTestOneInput direkt auf. Kompatibel mit ASAN.
 *
 * Nutzung:
 *   ./target_driver <input_file> [<input_file> ...]
 *   ./target_driver -            (liest von stdin)
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

/* Vom Magma-Target bereitgestellte Funktionen (libFuzzer-Interface) */
extern int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size);

/* Optionale Init-Funktion – schwaches Symbol, falls Target sie nicht hat */
__attribute__((weak))
int LLVMFuzzerInitialize(int *argc, char ***argv);

static uint8_t *read_file(const char *path, size_t *out_size) {
    FILE *f;
    uint8_t *buf = NULL;
    size_t cap = 0, len = 0;

    if (strcmp(path, "-") == 0) {
        f = stdin;
    } else {
        f = fopen(path, "rb");
        if (!f) {
            perror(path);
            return NULL;
        }
    }

    /* Streaming-Read, funktioniert auch bei stdin/pipes */
    const size_t CHUNK = 64 * 1024;
    for (;;) {
        if (len + CHUNK > cap) {
            cap = (cap == 0) ? CHUNK * 2 : cap * 2;
            uint8_t *tmp = realloc(buf, cap);
            if (!tmp) {
                free(buf);
                if (f != stdin) fclose(f);
                return NULL;
            }
            buf = tmp;
        }
        size_t n = fread(buf + len, 1, CHUNK, f);
        len += n;
        if (n < CHUNK) break;   /* EOF oder Fehler */
    }

    if (f != stdin) fclose(f);
    *out_size = len;
    return buf;
}

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <input_file> [more_files...] | -\n", argv[0]);
        return 1;
    }

    /* Falls das Target eine Initialisierung braucht */
    if (LLVMFuzzerInitialize) {
        LLVMFuzzerInitialize(&argc, &argv);
    }

    for (int i = 1; i < argc; i++) {
        size_t size = 0;
        uint8_t *data = read_file(argv[i], &size);
        if (!data && size == 0) {
            /* leere Datei ist erlaubt; NULL nur bei Fehler behandeln */
            if (strcmp(argv[i], "-") != 0) {
                fprintf(stderr, "Skip (read error): %s\n", argv[i]);
                continue;
            }
        }

        fprintf(stderr, "[driver] Running: %s (%zu bytes)\n", argv[i], size);
        LLVMFuzzerTestOneInput(data, size);   /* direkter Aufruf */
        free(data);
    }

    return 0;
}
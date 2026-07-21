# Magma Targets with Known Bugs (ASan Build)

This repository provides the [Magma](https://github.com/HexHive/magma) fuzzing
benchmark targets, **pre-built with all known bugs enabled** and compiled with
**AddressSanitizer (ASan)**. It is intended for evaluating custom fuzzers against
a ground-truth set of real, documented vulnerabilities.

> Bug fixes are **disabled** (`MAGMA_ENABLE_FIXES=0`), so every documented
> vulnerability remains present and reachable in the compiled binaries.

## About Magma

Magma is a ground-truth fuzzing benchmark. It takes real-world libraries and
re-inserts previously-fixed, real CVEs/bugs, each guarded by a **canary**
(instrumentation) that reports whether a bug was **reached** or **triggered**.
This makes it possible to objectively compare fuzzers.

- Project: https://github.com/HexHive/magma
- Bug catalogue: https://hexhive.epfl.ch/magma/docs/bugs.html

## Build


You can use the **build_target.sh** script to build the magma targets (bare-metal, ASan, bugs enabled).

 Usage:
 ```bash
   ./build_target.sh all                 # build all targets
   ./build_target.sh libtiff             # build a single target
   ./build_target.sh libtiff poppler     # build multiple targets
   ./build_target.sh --list              # list available targets
   ./build_target.sh clean               # clean all targets
   ./build_target.sh clean libtiff       # clean specific target(s)
```
Artifacts are placed in `out/<target>/`, build logs in `build_logs/<target>.log`.

#### Build Configuration

| Setting | Value |
|---------|-------|
| Compiler | `clang` / `clang++` |
| Sanitizer | AddressSanitizer (`-fsanitize=address`) |
| Optimization | `-O1 -g -fno-omit-frame-pointer` |
| Fixes | Disabled (`MAGMA_ENABLE_FIXES=0`) |
| Output | `out/<target>/` |

## Provided Targets

| Target   | Description                 | # Known Bugs |
|----------|-----------------------------|:------------:|
| libpng   | PNG image library           | 7            |
| libtiff  | TIFF image library          | 14           |
| libxml2  | XML parser                  | 18           |
| poppler  | PDF rendering library       | 22           |
| openssl* | Cryptography / TLS toolkit  | 20           |
| sqlite3  | SQL database engine         | 20           |
| php*     | PHP interpreter             | 16           |
| lua      | Lua interpreter             | 4            |
| **Total**|                             | **121**      |


>Targets marked with an (*) did not build successfully.
---

## Bugs per Target

Each bug has a unique Magma **Bug ID** and (where applicable) a corresponding
**CVE**. The definitive listing is on the
[Magma bug page](https://hexhive.epfl.ch/magma/docs/bugs.html) and in the local
patch files:

```bash

### List all bug IDs for a target

ls targets/<target>/patches/bugs/
```


---


## Running a Target

The harnesses take a single input file (or stdin, depending on the fuzzer
integration):

```bash

### Set a directory for Magma's bug monitor output

export MAGMA_STORAGE=/tmp/magma_monitor

./out/openssl/asn1 <input_file>
```

When a bug is **reached** or **triggered**, Magma records the corresponding
Bug ID under `$MAGMA_STORAGE`.

## Definitions

- **Reached** — the fuzzer executed the vulnerable code location.
- **Triggered** — the fuzzer produced an input that actually satisfies the
  bug condition (ASan / canary fires).

## License

The individual target sources retain their upstream licenses. Magma
instrumentation and patches are distributed under the Magma project license
(see the upstream repository).
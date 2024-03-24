---
title: GNU Compiler Collection (GCC)
breadcrumbs:
- title: Software Engineering
---
{% include header.md %}

An optimizing compiler for C, C++ etc.

The notes below mainly apply to C/C++, unless otherwise stated.

### Related Pages
{:.no_toc}

- [Clang/LLVM](/swd/clang-llvm/)

## Usage

- Compilation (C++): `g++ ${CPPFLAGS} ${CXXFLAGS} -c -o file1.o file1.cpp`
- Linking (C++): `g++ ${LDFLAGS} ${LDLIBS} -o app file1.o file2.o`

## Common Options

- (Note) Flags are typically activated with `-f<name>` and deactivated with `-fno-<name>`.
- Set language standard: `std=<standard>`
    - For specifying C or C++, use the `gcc` or `g++` compiler executables, respectively.
    - For C, use e.g. `std=gnu11`.
    - For C++, use e.g. `std=c++17`.
- Set optimization level with `-O<level>`:
    - `-O0` (default): No optimization (almost). Useful for debugging to produce predictable code.
    - `-O1`/`-O`: Performance optimization. Reduce code sized and execution time.
    - `-O2`: Performance optimization, extends `-O1`.
    - `-O3`: Performance optimization, extends `-O1`.
    - `-Os`: Space optimization, extends `-O2`, but disables flags that increase code size.
    - `-Ofast`: Based on `-O3`, but enables extra non-standards-compliant flags like `-ffast-math` for even better (non-standards-compliant) performance.
    - `-Og`: Optimize for debugging. Gives fast compilation and code for better debugging. Similar to `-O0` and `-01` wrt. optimizing flags, except those that would degrade debugging experience.
- Set architecture to produce code for: `-march=<cpu-type>` (example)
    - Architecture `native` means whatever architecture the current system is using.
    - Supports more generic architectures like `x86-64` as well as more specific ones like `skylake`.
    - Use this to optimize for the specific architecture, e.g. for HPC applications.
    - Do not use this if the executable is supposed to run on systems with other CPU architectures.
    - Implies `-mtune=<cpu-type>`, for tuning the code for the given architecture.
- **TODO**: `-matomic`
- Enable OpenMP support: `-fopenmp`
    - For parallelizing code, using preprocessor directives (`#pragma omp <...>`).
- Position-independent code: `-fpic`
    - This avoids using absolute addresses for jumps etc.
    - Shared libraries should enable this. For other applications, it doesn't matter.
- Vectorize loops: `-ftree-vectorize`
    - Attempt to use AWX instructions to vectorize loops of math operations.
    - Should be used with `-march=native` to make sure AWX is supported.
    - Implied by `-O3` and `-Ofast`.
- Enable fast but non-IEEE-compliant math: `-ffast-math`
    - Enable this if the program doesn't depend on an exact IEEE math implementation to produce correct results.
    - This may significantly improve floating-point performance, due to e.g. the restructuring of calculations which may produce different rounding errors.
    - Implied by `-Ofast`.
- Omit pointer frame: `-fomit-frame-pointer`
    - Avoids storing the pointer frame in a register for functions that don't need it (most functions, especially small ones).
    - Reduces code size and register usage.
    - Makes debugging very hard.
- Disable C++ exceptions (if not wanted): `-fno-exceptions`
    - If you want code without exception support, just disable it. Some people have strong opinions about whether exceptions is a good or bad feature.

### Warning Options

- Enable common warnings: `-Wall -Wextra`
- Enable extra warnings: `-Wextra`
- Enable warnings for strict ISO C/C++ compliance: `-Wpedantic`
- Treat all warnings as errors: `-Werror`
    - Alternatively, treat specific warnings as errors with `-Werror=<warning>` (e.g. `-Werror=switch` for `-Wswitch`).

### Hardening Options

These flags should be used with applications with insafe input. For HPC applications which use trusted input and require maximum performance, most of these flags should be disabled (not specified).

- Add string and memory overflow protection: `-D_FORTIFY_SOURCE=2` (or `1`)
    - Adds compile-time and run-time checks to protect against buffer overflows in memory and string functions.
    - Alternatively, use `-D_FORTIFY_SOURCE=1` to only add compile-time checks.
    - Compile-time checks validate operations on constant-size data.
    - Run-time checks validate operations on variable-size data, mainly by replacing functions like `memcpy` with build-in function `__memcpy_chk`.
- Add extra glibc error checking: `-D_GLIBCXX_ASSERTIONS`
    - Enables precondition assertions for e.g. checking string bounds and checking for null pointers when dereferencing smart pointers.
- Add stack smash protection: `-fstack-protector-strong`
    - Adds run-time checks to protect against stack smashing attacks.
    - `-fstack-protector-strong` adds more protection than `-fstack-protector-all` and `-fstack-protector`.
    - Use for programs with unsafe input (like servers and multiplayer games), disable for e.g. HPC applications which reqire max performance.
- Add stack clash protection: `-fstack-clash-protection`
    - Adds code to prevent stack clash style attacks.
- Add control flow integrity protection: `-fcf-protection`
    - Prevents unexpected jump targets (divergent control flow).
    - For newer Intel processors, this uses Intel Control-flow Enforcement Technology (CET). (Specifying `-mcet` is not required to use this.)
- Detect and reject underlinking: `-Wl,-z,defs` (linker)
- Disable lazy binding: `-Wl,-z,now` (linker)
- Read-only segments after relocation: `-Wl,-z,relro` (linker)
- Enable full address space layout randomization (ASLR): `-fpie -fpic -shared` (compiler) `-Wl,-pie` (linker)
    - This may reqire other options and run-time system features, so look it up if you need it.
- Disable text relocation for shared libraries: `-fpic -shared`
    - Related to ASLR.
    - Use only for shared libraries.

### Undefined Behavior Sanitizer (ubsan) Options

ubsan is a run-time checker for different types of undefined behavior.

**TODO** https://developers.redhat.com/blog/2014/10/16/gcc-undefined-behavior-sanitizer-ubsan

### Debug Options

- Embed debugging info (compiler and linker): `-g`
- Add compiler flags to debug info: `-grecord-gcc-switches`

## Common Libraries

- C math library (`math.h`): `-lm`
    - For C++, it's automatically included with the stdlib.

## Miscellaneous Options

- Use piping instead of temporary files during compilation: `-pipe`
    - Should yield better compilation performance.

{% include footer.md %}

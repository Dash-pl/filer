# filer

A small Nim command-line tool for comparing two files visually. `filer` computes the SHA-256 digest of each file, renders both digests as OpenSSH-style “Drunken Bishop” randomart, highlights matching and differing glyphs, and reports whether the files have identical contents.

> This project is primarily a learning project written in Nim.

## Requirements

- [Nim](https://nim-lang.org/) 2.4.0 or newer
- The `sha256sum` command-line utility available on `PATH`
  - On most Linux systems this is provided by GNU Coreutils.
  - The current implementation invokes `sha256sum` directly, so platform-specific alternatives may require adaptation.

## Installation

Clone the repository and install the Nimble package:

```sh
git clone <repository-url>
cd nim_program
nimble install
```

The package defines the `filer` executable in `nim_program.nimble`. To build it locally without installing:

```sh
nimble build
```

## Usage

Compare two files:

```sh
filer check <file1> <file2>
```

For example:

```sh
filer check original.iso downloaded.iso
```

The output includes:

- The SHA-256 digest and randomart for each file
- A status panel indicating `FILES MATCH` or `CONTENTS DIFFER`
- Glyph similarity across the two 17 × 9 randomart boards

Matching randomart glyphs are shown in green and differing glyphs in red when color is enabled.

### Disable color

Pass `--no-color` after `check`:

```sh
filer check --no-color <file1> <file2>
```

Color can also be disabled by setting the [`NO_COLOR`](https://no-color.org/) environment variable:

```sh
NO_COLOR=1 filer check <file1> <file2>
```

The command exits with status `1` for invalid usage, missing files, or hashing errors. A successful comparison exits with status `0`, regardless of whether the file contents match; inspect the displayed status to distinguish those cases.

## Development

The source code is organized as follows:

```text
src/
├── filer.nim      # CLI entry point
├── check.nim      # File hashing and comparison output
└── randomart.nim  # Drunken Bishop randomart implementation

tests/
└── test_randomart.nim
```

Run the test suite with Nimble:

```sh
nimble test
```

You can also run the randomart tests directly:

```sh
nim c -r tests/test_randomart.nim
```

The tests cover hexadecimal digest parsing, randomart generation, side-by-side rendering, glyph similarity, and color behavior.

## How randomart works

Each two-bit pair in a digest selects one diagonal step on a 17 × 9 board. Visit counts are converted to glyphs, with the starting position marked `S` and the final position marked `E`. When comparing two boards, matching displayed glyphs are highlighted in green and differences in red.

## License

No license has been specified yet. See `nim_program.nimble` for the current package metadata.


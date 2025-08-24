# `findup`

```text
findup 2.0.0
USAGE:
    findup [FLAG] FILE

FLAGS:
    -d, --print-directory Print the parent directory
    -h, --help            Print this help message
    -V, --version         Print version

Finds the FILE. Tested by filename with exact string equality. Starts searching at the current working directory and recurses "up" through parent directories.

The nearest FILE will be printed. If no parent directory contains FILE, nothing is printed and the program exits with an exit code of 1.

If --print-directory (-d) is specified, only the parent directory will be printed, omitting the filename.

https://github.com/so-dang-cool/findup
```

# Installation

[![Packaging status](https://repology.org/badge/vertical-allrepos/findup.svg)](https://repology.org/project/findup/versions)

# Misc

MIT License.
By J.R. Hill (justin (at) so.dang.cool)

import std/cmdline
import check

if paramCount() != 3 or paramStr(1) != "check":
  echo "Usage: main check <file1> <file2>"
  quit(1)

compareFiles(paramStr(2), paramStr(3))

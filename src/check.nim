import std/os
import std/osproc
import std/strutils

proc compareFiles*(file1, file2: string) =
  if not fileExists(file1) or not fileExists(file2):
    echo "Both files must exist."
    quit(1)
  
  let sum1 = execCmdEx("sha256sum " & quoteShell(file1))
  let sum2 = execCmdEx("sha256sum " & quoteShell(file2))
  
  if sum1.exitCode != 0 or sum2.exitCode != 0:
    echo "Could not calculate file checksums."
    quit(1)
  
  if sum1.output.splitWhitespace()[0] == sum2.output.splitWhitespace()[0]:
    echo """
            ██
      ██  ██
        ██
    [OK] Files have the same content"""
  else:
    echo """
    ██  ██
      ██
    ██  ██
    [!!!] File contents are not matching"""
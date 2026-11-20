import std/cmdline
import std/os
import check

const Usage = "Usage: filer check [--no-color] <file1> <file2>"

let arguments = commandLineParams()
if arguments.len < 3 or arguments[0] != "check":
  echo Usage
  quit(1)

var color = getEnv("NO_COLOR").len == 0
var fileIndex = 1
if arguments[fileIndex] == "--no-color":
  color = false
  inc fileIndex

if arguments.len != fileIndex + 2:
  echo Usage
  quit(1)

try:
  compareFiles(arguments[fileIndex], arguments[fileIndex + 1], color)
except CatchableError as error:
  stderr.writeLine(error.msg)
  quit(1)

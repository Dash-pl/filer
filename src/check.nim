import std/[os, osproc, strutils]
import randomart

const
  Red = "\e[31m"
  Green = "\e[32m"
  Reset = "\e[0m"

proc fileSha256(path: string): seq[byte] =
  ## Use the platform sha256sum utility and validate its hexadecimal output.
  let output = execCmdEx("sha256sum " & quoteShell(path))
  if output.exitCode != 0:
    raise newException(OSError, "sha256sum failed for " & path)

  let fields = output.output.splitWhitespace()
  if fields.len == 0:
    raise newException(OSError, "sha256sum returned no digest for " & path)
  parseHexDigest(fields[0])

proc statusPanel(matches: bool): seq[string] =
  ## Twelve lines to align with the hash label and 17x9 randomart frame.
  if matches:
    result = @[
      "                     ",
      "                     ",
      "                 ████",
      "               ████  ",
      "    ████     ████    ",
      "      ████ ████      ",
      "        ████          ",
      "                     ",
      "      FILES MATCH    ",
      "                     ",
      "   Contents are equal",
      "                     "
    ]
  else:
    result = @[
      "                     ",
      "    ████       ████  ",
      "      ████   ████    ",
      "        ██████        ",
      "          ██          ",
      "        ██████        ",
      "      ████   ████    ",
      "    ████       ████  ",
      "                     ",
      "   CONTENTS DIFFER   ",
      "                     ",
      " Files do not match  "
    ]

proc compareFiles*(file1, file2: string; color = true) =
  if not fileExists(file1) or not fileExists(file2):
    raise newException(ValueError, "Both files must exist.")

  let sum1 = fileSha256(file1)
  let sum2 = fileSha256(file2)
  let randomArtLines = renderPair(sum1, sum2, color).splitLines()
  let filesMatch = sum1 == sum2
  let panel = statusPanel(filesMatch)
  let similarity = glyphSimilarity(sum1, sum2)
  let percentage = similarity.matching.float * 100.0 / similarity.total.float
  let similarityLabel = "Glyph similarity: " & formatFloat(percentage, ffDecimal, 1) &
    "% (" & $similarity.matching & "/" & $similarity.total & ")"

  let panelColor = if filesMatch: Green else: Red
  for index, line in randomArtLines:
    let styledPanel = if color: panelColor & panel[index] & Reset else: panel[index]
    echo line & "    " & styledPanel

  let styledSimilarity = if color: panelColor & similarityLabel & Reset else: similarityLabel
  echo repeat(' ', randomArtLines[0].len + 4) & styledSimilarity

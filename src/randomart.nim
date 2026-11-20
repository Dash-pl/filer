## OpenSSH-style "Drunken Bishop" randomart rendering.
##
## Each two-bit pair in a digest selects one diagonal step. The number of
## visits to every board cell determines its glyph, with the first and last
## cells marked as S and E respectively.

import std/strutils

const
  ArtWidth* = 17
  ArtHeight* = 9
  VisitGlyphs = " .o~-=!@#$%^&*<>" ##  .o~-=!@#$%^&*<>
  Red = "\e[31m"
  Green = "\e[32m"
  Reset = "\e[0m"

type
  RandomArt* = object
    ## The raw visit counts are retained so capped cells can still be compared.
    visits*: array[ArtHeight, array[ArtWidth, uint8]]
    endX*, endY*: int

proc drunkenBishop*(digest: openArray[byte]): RandomArt =
  ## Walk an OpenSSH Drunken Bishop board using `digest`.
  var x = ArtWidth div 2
  var y = ArtHeight div 2

  for value in digest:
    var bits = value
    for _ in 0 ..< 4:
      x += (if (bits and 0x01) != 0: 1 else: -1)
      y += (if (bits and 0x02) != 0: 1 else: -1)
      x = clamp(x, 0, ArtWidth - 1)
      y = clamp(y, 0, ArtHeight - 1)
      if result.visits[y][x] < uint8(VisitGlyphs.len - 1):
        inc result.visits[y][x]
      bits = bits shr 2

  result.endX = x
  result.endY = y

proc glyphAt(art: RandomArt; x, y: int): char =
  ## OpenSSH writes S first and E second, so E takes precedence on a walk
  ## whose endpoint is the initial square.
  if x == art.endX and y == art.endY:
    return 'E'
  if x == ArtWidth div 2 and y == ArtHeight div 2:
    return 'S'
  VisitGlyphs[min(int(art.visits[y][x]), VisitGlyphs.high)]

proc differsAt(left, right: RandomArt; x, y: int): bool =
  ## Highlight the cells that differ in the displayed randomart.
  left.glyphAt(x, y) != right.glyphAt(x, y)

proc glyphSimilarity*(leftDigest, rightDigest: openArray[byte]): tuple[matching, total: int] =
  ## Count matching displayed glyphs across the two 17x9 boards.
  let left = drunkenBishop(leftDigest)
  let right = drunkenBishop(rightDigest)
  result.total = ArtWidth * ArtHeight
  for y in 0 ..< ArtHeight:
    for x in 0 ..< ArtWidth:
      if left.glyphAt(x, y) == right.glyphAt(x, y):
        inc result.matching

proc lines*(art: RandomArt): seq[string] =
  ## Render one randomart board without terminal escape sequences.
  result.add("+" & repeat('-', ArtWidth) & "+")
  for y in 0 ..< ArtHeight:
    var row = "|"
    for x in 0 ..< ArtWidth:
      row.add(art.glyphAt(x, y))
    row.add('|')
    result.add(row)
  result.add("+" & repeat('-', ArtWidth) & "+")

proc hexDigest*(digest: openArray[byte]): string =
  ## Return a lowercase hexadecimal representation of `digest`.
  const Hex = "0123456789abcdef"
  result = newStringOfCap(digest.len * 2)
  for value in digest:
    result.add(Hex[int(value shr 4)])
    result.add(Hex[int(value and 0x0f)])

proc parseHexDigest*(value: string): seq[byte] =
  ## Parse an even-length hexadecimal digest or raise ValueError.
  if value.len == 0 or value.len mod 2 != 0:
    raise newException(ValueError, "digest must contain an even number of hexadecimal characters")

  proc nibble(c: char): byte =
    case c
    of '0' .. '9': byte(ord(c) - ord('0'))
    of 'a' .. 'f': byte(ord(c) - ord('a') + 10)
    of 'A' .. 'F': byte(ord(c) - ord('A') + 10)
    else: raise newException(ValueError, "digest contains a non-hexadecimal character")

  result = newSeq[byte](value.len div 2)
  for index in 0 ..< result.len:
    result[index] = (nibble(value[index * 2]) shl 4) or nibble(value[index * 2 + 1])

proc renderPair*(leftDigest, rightDigest: openArray[byte]; color = true): string =
  ## Render two SHA-style digest labels and their randomarts side-by-side.
  ## Matching glyphs are green; glyphs that differ are red on both boards.
  let left = drunkenBishop(leftDigest)
  let right = drunkenBishop(rightDigest)
  let leftLines = left.lines()
  let rightLines = right.lines()

  result.add("SHA256:" & hexDigest(leftDigest) & "    SHA256:" & hexDigest(rightDigest) & '\n')
  for y in 0 ..< leftLines.len:
    if y == 0 or y == leftLines.high:
      result.add(leftLines[y] & "    " & rightLines[y])
    else:
      var leftRow = "|"
      var rightRow = "|"
      let boardY = y - 1
      for x in 0 ..< ArtWidth:
        let leftGlyph = left.glyphAt(x, boardY)
        let rightGlyph = right.glyphAt(x, boardY)
        if color:
          let glyphColor = if left.differsAt(right, x, boardY): Red else: Green
          leftRow.add(glyphColor & $leftGlyph & Reset)
          rightRow.add(glyphColor & $rightGlyph & Reset)
        else:
          leftRow.add(leftGlyph)
          rightRow.add(rightGlyph)
      leftRow.add('|')
      rightRow.add('|')
      result.add(leftRow & "    " & rightRow)
    if y < leftLines.high:
      result.add('\n')

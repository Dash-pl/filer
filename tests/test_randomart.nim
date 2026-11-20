import std/[strutils, unittest]
import randomart

suite "OpenSSH Drunken Bishop randomart":
  test "zero digest follows the lower-bit diagonal walk and marks endpoints":
    let art = drunkenBishop(parseHexDigest(repeat("00", 32)))
    let rendered = art.lines()

    check art.endX == 0
    check art.endY == 0
    check rendered.len == ArtHeight + 2
    check rendered[0] == "+-----------------+"
    check rendered[1].startsWith("|E")
    check rendered[1][1] == 'E'
    check rendered[5][9] == 'S'

  test "hex parsing round-trips and rejects malformed digests":
    let digest = parseHexDigest("00aBff")
    check digest.hexDigest() == "00abff"
    expect ValueError:
      discard parseHexDigest("abc")
    expect ValueError:
      discard parseHexDigest("zz")

  test "side-by-side rendering colors matching and differing glyphs":
    let left = parseHexDigest(repeat("00", 32))
    let right = parseHexDigest(repeat("ff", 32))
    let plain = renderPair(left, right, color = false)
    let colored = renderPair(left, right, color = true)

    check plain.startsWith("SHA256:" & left.hexDigest() & "    SHA256:" & right.hexDigest())
    check plain.splitLines().len == ArtHeight + 3
    check "\e[" notin plain
    check "\e[31m" in colored
    check "\e[32m" in colored

  test "glyph similarity reports all cells for identical digests":
    let digest = parseHexDigest(repeat("12", 32))
    let similarity = glyphSimilarity(digest, digest)
    check similarity.matching == ArtWidth * ArtHeight
    check similarity.total == ArtWidth * ArtHeight

  test "identical walks color every glyph green":
    let digest = parseHexDigest(repeat("12", 32))
    let colored = renderPair(digest, digest, color = true)
    check "\e[32m" in colored
    check "\e[31m" notin colored

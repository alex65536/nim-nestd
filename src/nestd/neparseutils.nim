## .. importdoc:: neunicode.nim

import std/[strformat, unicode]

func decodeHexChar(c: char): int {.inline.} =
  case c
  of '0'..'9': ord(c) - ord('0')
  of 'a'..'f': ord(c) - ord('a') + 10
  of 'A'..'F': ord(c) - ord('A') + 10
  else: raise ValueError.newException(fmt"bad hex char {c}")

func parseEscapedString*(s: openArray[char], res: var string, quote = '"'): int
  {.raises: [ValueError].} =
  ## Parses a string escaped by `escapeUnicode`_ and stores the parsed value in `res`. `quote` is
  ## the quotation mark character in which the escaped string is enclosed. For now, only `'"'` and
  ## `'\''` are valid arguments for `quote`. Result is the number of processed chars or 0 if there
  ## is no escaped string. `ValueError` is raised if the given string has invalid format.
  doAssert quote in {'"', '\''}
  res = ""
  result = 0
  if s.len == 0 or s[0] != quote: return
  inc result
  while result < s.len:
    let c = s[result]
    inc result
    if c == quote: return
    if c == '\\':
      if result >= s.len:
        raise ValueError.newException("unterminated escape sequence")
      let c = s[result]
      inc result
      template decodeHex(size: static int): int =
        if result + size > s.len:
          raise ValueError.newException("unterminated escape sequence")
        var val = 0
        for i in 0..<size:
          val = (val shl 4) or decodeHexChar(s[result+i])
        inc result, size
        val
      case c
      of '\'', '"', '\\': res.add(c)
      of 'a': res.add('\a')
      of 'b': res.add('\b')
      of 't': res.add('\t')
      of 'n': res.add('\n')
      of 'v': res.add('\v')
      of 'f': res.add('\f')
      of 'r': res.add('\r')
      of 'e': res.add('\e')
      of 'x', 'u', 'U':
        let val = if c == 'x': decodeHex(2) elif c == 'u': decodeHex(4) else: decodeHex(8)
        if val >= 0x110000 or (val >= 0xd800 and val < 0xe000):
          raise ValueError.newException(fmt"invalid unicode char {val}")
        let pos = res.len
        fastToUTF8Copy(val.Rune, res, pos, doInc = false)
      else: raise ValueError.newException(fmt"unknown escape sequence \{c}")
    else: res.add(c)
  raise ValueError.newException("unterminated string")

func parseEscapedString*(s: string, res: var string, quote = '"', start = 0): int
  {.raises: [ValueError].} =
  ## Parses a string escaped by `escapeUnicode`_ and stores the parsed value in `res`. For more
  ## details, see `parseEscapedString(s, res, quote)`_.
  parseEscapedString(s.toOpenArray(start, s.high), res, quote)

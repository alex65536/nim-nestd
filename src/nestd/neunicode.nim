from std/unicode import Rune, runes, add

func doReallyEscape(s: var string, r: Rune) {.inline.} =
  let r = r.int
  const hexChars = "0123456789abcdef"
  if r < 0x80:
    s &= r"\x"
    s &= hexChars[(r shr 4) and 15]
    s &= hexChars[r and 15]
  elif r < 0x10000:
    s &= r"\u"
    for i in countdown(12, 0, 4):
      s &= hexChars[(r shr i) and 15]
  else:
    s &= r"\U"
    for i in countdown(28, 0, 4):
      s &= hexChars[(r shr i) and 15]

proc appendEsc(s: var string, r: Rune, shouldEscape: proc(r: Rune): bool, toSlash: set[
    char]) {.inline.} =
  if r.int < 0x80:
    let c = r.char
    case c:
      of '\a': s &= r"\a"
      of '\b': s &= r"\b"
      of '\t': s &= r"\t"
      of '\n': s &= r"\n"
      of '\v': s &= r"\v"
      of '\f': s &= r"\f"
      of '\r': s &= r"\r"
      of '\e': s &= r"\e"
      of '\x00'..'\x06', '\x0e'..'\x1a', '\x1c'..'\x1f', '\x7f': doReallyEscape(s, r)
      of '\x20'..'\x7e':
        if c in toSlash:
          s &= '\\'
        s &= c
      of '\x80'..'\xff': assert false
  elif shouldEscape(r):
    doReallyEscape(s, r)
  else:
    s &= r

type
  EscapeOptions* = enum
    ## Options for `escapeUnicode`_
    eoEscapeSingleQuote ## Replaces `'` by `\'`
    eoEscapeDoubleQuote ## Replaces `"` by `\"`

proc escapeUnicode*(s: string, shouldEscape: proc(r: Rune): bool, prefix = "\"", suffix = "\"",
    options = {eoEscapeDoubleQuote}): string {.inline.} =
  ## Escapes a string `s`.
  ##
  ## .. note:: The escaping scheme is different from `strutils.escape`.
  ##
  ## .. note:: This function has the same behavior as `system.addEscapedChar` if:
  ##   - `options` is set to `{eoEscapeSingleQuote, eoEscapeDoubleQuote}`
  ##   - the string consists of ASCII characters only
  ##
  ## * replaces any ``\`` by `\\`
  ## * replaces any `'` by `\'` (only with `eoEscapeSingleQuote` in `options`)
  ## * replaces any `"` by `\"` (only with `eoEscapeDoubleQuote` in `options`)
  ## * replaces any `'\a'` char by `\a`
  ## * replaces any `'\b'` char by `\b`
  ## * replaces any `'\t'` char by `\t`
  ## * replaces any `'\n'` char by `\n`
  ## * replaces any `'\v'` char by `\v`
  ## * replaces any `'\f'` char by `\f`
  ## * replaces any `'\r'` char by `\r`
  ## * replaces any `'\e'` char by `\e`
  ## * replaces any other character in the set `{\00..\31,\127}` by `\xHH` where `HH` is its
  ##   hexadecimal value
  ## * replaces any rune, for which `r.int >= 128 and shouldEscape(r)` is `true`, by either
  ##   `\uHHHH` or `\UHHHHHHHH`, where `HHHH` and `HHHHHHHH` is the hexadecimal value of `r`.
  ## * any other runes are left intact
  ##
  ## The resulting string is prefixed with `prefix` and suffixed with `suffix`. Both may be empty
  ## strings.
  result = newStringOfCap(s.len + prefix.len + suffix.len + 8)
  result &= prefix
  var toSlash = {'\\'}
  if eoEscapeSingleQuote in options:
    toSlash.incl('\'')
  if eoEscapeDoubleQuote in options:
    toSlash.incl('"')
  for r in s.runes:
    result.appendEsc(r, shouldEscape, toSlash)
  result &= suffix

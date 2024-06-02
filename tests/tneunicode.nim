import unittest
import std/[sugar, unicode]
import nestd/neunicode

test "escape":
  check escapeUnicode("строка", _ => false) == "\"строка\""
  check escapeUnicode("строка", _ => true) == "\"\\u0441\\u0442\\u0440\\u043e\\u043a\\u0430\""
  check escapeUnicode("Строка", r => r != Rune(1057), prefix = "PRE!", suffix = "$SUF") ==
    r"PRE!С\u0442\u0440\u043e\u043a\u0430$SUF"

  check escapeUnicode("\x00\x01\a\b\t\n\v\f\r\e\x7f\\\"\':!@#$%^&*()", _ => false, prefix = "",
                      suffix = "") ==
    r"\x00\x01\a\b\t\n\v\f\r\e\x7f\\\""':!@#$%^&*()"

  check escapeUnicode("\x00\x01\a\b\t\n\v\f\r\e\x7f\\\"\':!@#$%^&*()", _ => false, prefix = "",
                      suffix = "", options = {eoEscapeSingleQuote, eoEscapeDoubleQuote}) ==
    r"\x00\x01\a\b\t\n\v\f\r\e\x7f\\\""\':!@#$%^&*()"

  check escapeUnicode("\x00\x01\a\b\t\n\v\f\r\e\x7f\\\"\':!@#$%^&*()", _ => false, prefix = "",
                      suffix = "", options = {}) ==
    r"\x00\x01\a\b\t\n\v\f\r\e\x7f\\""':!@#$%^&*()"

  check escapeUnicode(":\'\"\\:", _ => false, prefix = "", suffix = "", options = {}) == r":'""\\:"
  check escapeUnicode(":\'\"\\:", _ => false, prefix = "", suffix = "",
                      options = {eoEscapeSingleQuote}) == r":\'""\\:"
  check escapeUnicode(":\'\"\\:", _ => false, prefix = "", suffix = "",
                      options = {eoEscapeDoubleQuote}) == r":'\""\\:"

  check escapeUnicode("\u{1f433}", _ => true, prefix = "", suffix = "") == r"\U0001f433"
  check escapeUnicode("\x00\x7f\u{80}\u{ffff}\u{10000}\u{10ffff}", _ => true, prefix = "",
                      suffix = "") == r"\x00\x7f\u0080\uffff\U00010000\U0010ffff"

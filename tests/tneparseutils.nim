import unittest
import std/sugar
import nestd/[neunicode, neparseutils]

test "parse escaped simple":
  var res: string
  check parseEscapedString("\"hello\" some other data", res) == 7
  check res == "hello"
  check parseEscapedString("\"line\" some other data", res, quote = '"') == 6
  check res == "line"
  check parseEscapedString("'somedata' some other data", res, quote = '\'') == 10
  check res == "somedata"

test "parse escaped tricky":
  var res: string
  for (src, doEsc) in [
    ("строка", true),
    ("строка", false),
    ("\x00\x01\a\b\t\n\v\f\r\e\x7f\\\"\':!@#$%^&*()", true),
    ("\u{1f433}", true),
    ("\x00\x7f\u{80}\u{ffff}\u{10000}\u{10ffff}", true),
  ]:
    let s = escapeUnicode(src, _ => doEsc)
    check parseEscapedString(s, res) == s.len
    check res == src

test "parse escaped double quotes":
  var res: string
  expect ValueError:
    discard parseEscapedString("\"\\\"", res)
  check parseEscapedString("\"\\\"\"", res, quote = '\'') == 0
  check parseEscapedString("\"\\\"\"", res) == 4
  check res == "\""
  check parseEscapedString("\"\\'\"", res) == 4
  check res == "'"
  check parseEscapedString("\"'\"", res) == 3
  check res == "'"

test "parse escaped single quotes":
  var res: string
  expect ValueError:
    discard parseEscapedString("'\\'", res, quote = '\'')
  check parseEscapedString("'\\''", res) == 0
  check parseEscapedString("'\\''", res, quote = '\'') == 4
  check res == "'"
  check parseEscapedString("'\\\"'", res, quote = '\'') == 4
  check res == "\""
  check parseEscapedString("'\"'", res, quote = '\'') == 3
  check res == "\""

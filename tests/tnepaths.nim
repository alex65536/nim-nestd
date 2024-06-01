import unittest
import std/[paths, sequtils, sugar]
import nestd/nepaths

test "$ for Path":
  check $("/a/b/c".Path) == "/a/b/c"

test "hash for Path":
  let paths = map(@[
    "/a/b/c",
    "/a/b/c/..",
    "/a/b/e/d/../../../c",
    "/a/b/c/",
    "/a/b/c/d",
    "a/b/c",
    "a/../..",
    "..",
    ".",
    "",
    "./././.",
    "/",
    "//",
    "///",
    "////",
    "/////",
    "a/b/c/..",
    "/bin/FILE",
    "/bin/File",
    "/bin/file",
    "/bin/ФАЙЛ",
    "/bin/Файл",
    "/bin/файл",
  ], x => x.Path)
  for p1 in paths:
    for p2 in paths:
      let hashesEqual = p1.hash == p2.hash
      let pathsEqual = p1 == p2
      check hashesEqual == pathsEqual

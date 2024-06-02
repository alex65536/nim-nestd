# Package

version       = "0.1.0"
author        = "Alexander Kernozhitsky"
description   = "Everything that should have been in Nim's standard library, but is missing."
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 2.0.4"

taskRequires "test", "nimcrypto ~= 0.6.0"
taskRequires "test", "checksums ~= 0.1.0"

task pretty, "prettifies the sources":
  proc walk(dir: string) =
    for f in dir.listFiles():
      exec("nimpretty --maxLineLen:100 " & f)
    for f in dir.listDirs():
      walk(f)
  walk("src")
  walk("tests")

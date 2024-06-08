# Package

version       = "0.1.1"
author        = "Alexander Kernozhitsky"
description   = "Everything that should have been in Nim's standard library, but is missing."
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 2.0.4"

taskRequires "test", "nimcrypto ~= 0.6.0"
taskRequires "test", "checksums ~= 0.1.0"


# Tasks

task pretty, "Prettify the sources":
  proc walk(dir: string) =
    for f in dir.listFiles:
      if f.endsWith ".nim":
        exec "nimpretty --maxLineLen:100 " & f
    for f in dir.listDirs:
      walk f
  walk "src"
  walk "tests"

task docs, "Generate documentaion":
  proc walk(dir: string) =
    if dir.endsWith "/private":
      return
    for f in dir.listFiles:
      if f.endsWith ".nim":
        exec "nimble doc --project --docroot --outdir:docs --styleCheck:hint " & f
    for f in dir.listDirs:
      walk f
  rmDir "docs"
  walk "src"

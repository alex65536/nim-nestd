import std/paths

when declared(paths.hash):
  export paths.hash
else:
  import std/[strutils, hashes, sugar]

  func hash*(x: Path): Hash =
    ## `hash()` implementation for `Path`.
    ##
    ## Workaround for Nim issue [#23663](https://github.com/nim-lang/Nim/issues/23663), which is fixed in Nim >= 2.1.0.
    let x = x.dup(normalizePath)
    if FileSystemCaseSensitive:
      x.string.hash
    else:
      x.string.toLowerAscii.hash

when declared(paths.`$`):
  export paths.`$`
else:
  func `$`*(x: Path): string {.inline.} =
    ## `\`$\`` for `Path` was added in Nim PR [#23617](https://github.com/nim-lang/Nim/pull/23617) for Nim >= 2.1.0.
    ## This is a workaround for older versions.
    x.string

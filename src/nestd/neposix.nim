import std/posix

var
  AT_FDCWD* {.importc: "AT_FDCWD", header: "<fcntl.h>".}: cint
  AT_SYMLINK_NOFOLLOW* {.importc: "AT_SYMLINK_NOFOLLOW", header: "<fcntl.h>".}: cint

proc utimensat*(dirfd: cint, pathname: cstring, times: ptr array[2, Timespec], flags: cint): int
  {.importc: "utimensat", header: "<sys/time.h>", sideEffect.}

proc rename*(oldname, newname: cstring): cint
  {.importc: "rename", header: "<stdio.h>", sideEffect.}

import std/[times, posix, paths, oserrors]

proc stat*(p: Path): Stat =
  ## Returns file status in a `Stat` structure, with resolving symbolic links.
  if stat(p.cstring, result) != 0:
    raiseOSError(osLastError(), p.string)

proc lstat*(p: Path): Stat =
  ## Returns file status in a `Stat` structure, without resolving symbolic links.
  if lstat(p.cstring, result) != 0:
    raiseOSError(osLastError(), p.string)

proc toTime*(t: Timespec): times.Time =
  ## Converts between `posix.Timespec` and `times.Time`
  fromUnix(t.tv_sec.int64) + nanoseconds(t.tv_nsec)

proc removeEmptyDir*(src: Path) =
  ## Like `removeDir`, but doesn't remove the directory recursively and throws an error if the
  ## directory is non-empty.
  if rmdir(src.string.cstring) < 0: raiseOSError(osLastError(), src.string)

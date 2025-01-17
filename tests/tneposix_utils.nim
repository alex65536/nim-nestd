when defined(posix):
  import unittest
  import std/[times, paths, tempfiles, dirs, files, symlinks]
  import std/posix except Time
  import nestd/neposix_utils

  test "toTime for Timespec":
    let timespec = Timespec(tv_sec: posix.Time(1717268996), tv_nsec: 123456789)
    let time: Time = timespec.toTime
    check time.format("yyyy-MM-dd HH:mm:ss'.'fffffffff", utc()) == "2024-06-01 19:09:56.123456789"

  test "stat and lstat":
    let tempDir = createTempDir("tneposix_", "").Path
    defer: tempDir.removeDir
    let filePath = tempDir / Path("file.txt")
    let linkPath = tempDir / Path("link.txt")
    writeFile(filePath.string, "Hello")
    createSymlink(filePath, linkPath)
    check filePath.stat.st_size == 5
    check (filePath.stat.st_mode.cint and S_IFMT) == S_IFREG
    check linkPath.stat.st_size == 5
    check (linkPath.stat.st_mode.cint and S_IFMT) == S_IFREG
    check filePath.lstat.st_size == 5
    check (filePath.lstat.st_mode.cint and S_IFMT) == S_IFREG
    check linkPath.lstat.st_size == linkPath.string.len
    check (linkPath.lstat.st_mode.cint and S_IFMT) == S_IFLNK

  test "rmdir":
    let tempDir = createTempDir("tneposix_", "").Path
    defer: tempDir.removeDir
    let innerDir = tempDir / Path("dir")
    let innerFile = innerDir / Path("file.txt")
    innerDir.createDir
    innerDir.removeEmptyDir
    check not innerDir.dirExists
    innerDir.createDir
    writeFile(innerFile.string, "Hello")
    expect OSError:
      innerDir.removeEmptyDir
    check innerDir.dirExists
    innerFile.removeFile
    innerDir.removeEmptyDir
    check not innerDir.dirExists

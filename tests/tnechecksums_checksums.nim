import unittest
import std/[tempfiles, paths, files, strutils, streams]
import checksums/sha2
import nestd/[nesystem, nechecksums]
import ./common/checksums_util

test "checksumFile and checksumStream with checksums":
  var data = genData()
  var (f, pStr) = createTempFile("tnechecksums_", "")
  let p = pStr.Path
  defer:
    f.close
    p.removeFile
  doAssert f.writeBytes(data, 0, data.len) == data.len
  f.flushFile
  block:
    var sha = initSha_256()
    check toLowerAscii($p.checksumFile(sha)) == expectedChecksum
  for bufSize in bufSizes:
    var sha = initSha_256()
    check toLowerAscii($p.checksumFile(sha, bufSize = bufSize)) == expectedChecksum
  block:
    var sha = initSha_256()
    let cs = newStringStream(data.arrayToString).checksumStream(sha)
    check toLowerAscii($cs) == expectedChecksum
  for bufSize in bufSizes:
    var sha = initSha_256()
    let cs = newStringStream(data.arrayToString).checksumStream(sha, bufSize = bufSize)
    check toLowerAscii($cs) == expectedChecksum

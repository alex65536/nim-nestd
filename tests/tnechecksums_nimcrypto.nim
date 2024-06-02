import unittest
import std/[tempfiles, paths, files, strutils, streams]
import nimcrypto/sha2
import nestd/[nesystem, nechecksums]
import ./common/checksums_util

test "checksumFile and checksumStream with nimcrypto":
  var data = genData()
  var (f, pStr) = createTempFile("tnechecksums_", "")
  let p = pStr.Path
  defer:
    f.close
    p.removeFile
  doAssert f.writeBytes(data, 0, data.len) == data.len
  f.flushFile
  check toLowerAscii($p.checksumFile(sha256)) == expectedChecksum
  for bufSize in bufSizes:
    check toLowerAscii($p.checksumFile(sha256, bufSize = bufSize)) == expectedChecksum
  block:
    let cs = newStringStream(data.arrayToString).checksumStream(sha256)
    check toLowerAscii($cs) == expectedChecksum
  for bufSize in bufSizes:
    let cs = newStringStream(data.arrayToString).checksumStream(sha256, bufSize = bufSize)
    check toLowerAscii($cs) == expectedChecksum

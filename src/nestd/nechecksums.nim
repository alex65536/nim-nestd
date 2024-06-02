import std/[paths, streams]

const defaultBufSize = 8192

proc checksumStreamImplNimcrypto[Checksum](stream: Stream, c: var Checksum, bufSize: int): auto {.inline.} =
  c.init()
  defer: c.clear()
  var buf = newSeq[byte](bufSize)
  while true:
    let bytesRead = stream.readData(addr buf[0], buf.len)
    if bytesRead == 0:
      break
    c.update(buf[0..<bytesRead])
  return c.finish()

proc checksumStreamImplChecksums[Checksum](stream: Stream, c: var Checksum, bufSize: int): auto {.inline.} =
  var buf = newSeq[char](bufSize)
  while true:
    let bytesRead = stream.readData(addr buf[0], buf.len)
    if bytesRead == 0:
      break
    c.update(buf[0..<bytesRead])
  return c.digest()

proc checksumStream*[Checksum](stream: Stream, c: var Checksum, bufSize: int = defaultBufSize): auto =
  ## Computes a checksum from `stream`, using context `c` of type `Checksum`.
  ##
  ## The context must be freshly created before passing into this function. Otherwise, it is unspecified whether the implementation will reset the context.
  ##
  ## Currently, the implementation works with hashing algorithms provided by either `nimcrypto` or `checksums` package. Otherwise, an adapter should be written to match interface of either `nimcrypto` or `checksums`.
  when compiles(checksumStreamImplNimcrypto(stream, c, bufSize)):
    checksumStreamImplNimcrypto(stream, c, bufSize)
  else:
    checksumStreamImplChecksums(stream, c, bufSize)

proc checksumStream*(stream: Stream, ChecksumType: typedesc, bufSize: int = defaultBufSize): auto =
  ## Computes a checksum from `stream`, using a freshly-created context of type `ChecksumType`.
  ##
  ## Currently, the implementation works with `nimcrypto` package. Otherwise, an adapter should be written to match its interface.
  ##
  ## **Example:**
  ## ```
  ## import nimcrypto/[hash, sha2]
  ## import std/streams
  ## 
  ## let stream = newStringStream("hello\n")
  ## let digest = $stream.checksumStream(sha256)
  ## assert digest.len == 64
  ## assert digest[0..15] == "5891B5B522D5DF08"
  ## ```
  var c: ChecksumType
  stream.checksumStream(c, bufSize)

proc checksumFile*[Checksum](path: Path, c: var Checksum, bufSize: int = defaultBufSize): auto =
  ## Computes a checksum from file located at `path`, using context `c` of type `Checksum`.
  ##
  ## See `checksumStream`_ for more details.
  let stream = newFileStream(path.string, fmRead)
  defer: stream.close()
  stream.checksumStream(c, bufSize)

proc checksumFile*(path: Path, ChecksumType: typedesc, bufSize: int = defaultBufSize): auto =
  ## Computes a checksum from file located at `path`, using a freshly-created context of type `ChecksumType`.
  ##
  ## See `checksumStream`_ for more details.
  var c: ChecksumType
  path.checksumFile(c, bufSize)

import std/bitops

type
  # xoshiro256** random generator, hard-coded for predictable output.
  Xoshiro256ss = object
    s0, s1, s2, s3: uint64

func next(x: var Xoshiro256ss): uint64 =
  func `^=`[T](a: var T, b: T) = a = a xor b
  result = rotateLeftBits(x.s1 * 5, 7) * 9
  let t = x.s1 shl 17
  x.s2 ^= x.s0
  x.s3 ^= x.s1
  x.s1 ^= x.s2
  x.s0 ^= x.s3
  x.s2 ^= t
  x.s3 = rotateLeftBits(x.s3, 45)

func newFixedXoshiro256ss(): Xoshiro256ss =
  const seed = 123456789012345678'u64
  result = Xoshiro256ss(s0: seed, s1: seed, s2: seed, s3: seed)
  for i in 1..10000:
    discard result.next

const
  expectedChecksum* = "e54cd634ebc50280a00da100161b9fb129b37fef56b1096a44b15cac3f3d56c4"
  bufSizes* = [1234, 218107, 654320, 654321, 654322, 1 shl 20]

proc genData*(): seq[byte] =
  result = newSeq[byte](654321)
  var rng = newFixedXoshiro256ss()
  for i in low(result)..high(result):
    result[i] = byte(rng.next and 0xff)

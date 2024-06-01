import unittest
import std/[nre, macros, strutils]
import nestd

type
  ItemKind = enum
    ikFirst, ikSecond, ikThird, ikFourth, ikFifth, ikFirstOther, ikSecondOther

  LargeObj = object
    a: int
    case d1: uint8
    of 0..3:
      b: int32
    else:
      c, d: int32
    case d2: ItemKind
    of ikFirst:
      e: string
      f: bool
    of ikSecond, ikThird:
      discard
    of ikFourth, ikFifth:
      g: char
    else:
      h: string
      i1, i2, i3: uint64
    when true:
      j: int64
    else:
      k: int64
    when true:
      l: string
    when false:
      m: string

addEqForObject(LargeObj)

test "addEqForObject simple":
  let obj1 = LargeObj(a: 5, d1: 2, b: 3, d2: ikFirst, e: "string", f: true, j: 42, l: "test")
  let obj2 = LargeObj(a: 5, d1: 2, b: 3, d2: ikFirst, e: "string", f: true, j: 42, l: "test")
  let obj3 = LargeObj(a: 5, d1: 1, b: 3, d2: ikFirst, e: "string", f: true, j: 42, l: "test")
  let obj4 = LargeObj(a: 5, d1: 2, b: 3, d2: ikFirst, e: "line", f: true, j: 42, l: "test")
  let obj5 = LargeObj(a: 5, d1: 2, b: 3, d2: ikFirst, e: "string", f: true, j: 42, l: "other")
  let obj6 = LargeObj(a: 5, d1: 2, b: 3, d2: ikThird, j: 42, l: "test")
  let obj7 = LargeObj(a: 5, d1: 2, b: 3, d2: ikThird, j: 42, l: "test")
  check obj1 == obj2
  check obj1 != obj3
  check obj1 != obj4
  check obj1 != obj5
  check obj1 != obj6
  check obj1 != obj7
  check obj6 == obj7

test "addEqForObject codegen":
  macro astize(body: typed): string = body.toStrLit
  macro pass: untyped = nnkStmtList.newTree

  let expected = astize:
    proc `==`(srca, srcb: LargeObj): bool =
      if srca.a != srcb.a:
        return false
      if srca.d1 != srcb.d1:
        return false
      case srca.d1
      of 0..3:
        if srca.b != srcb.b:
          return false
      else:
        if srca.c != srcb.c:
          return false
        if srca.d != srcb.d:
          return false
      if srca.d2 != srcb.d2:
        return false
      case srca.d2
      of ikFirst:
        if srca.e != srcb.e:
          return false
        if srca.f != srcb.f:
          return false
      of ikSecond, ikThird:
        pass
      of ikFourth, ikFifth:
        if srca.g != srcb.g:
          return false
      else:
        if srca.h != srcb.h:
          return false
        if srca.i1 != srcb.i1:
          return false
        if srca.i2 != srcb.i2:
          return false
        if srca.i3 != srcb.i3:
          return false
      if srca.j != srcb.j:
        return false
      if srca.l != srcb.l:
        return false
      return true

  let pattern = re"([ab])`gensym[0-9]+([.,:])"
  let got = astize(addEqForObject(LargeObj, mustExport = false))
    .replace(pattern, "src$1$2")
    .strip(leading = true, trailing = false)

  check expected == got

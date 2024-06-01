import std/[macros, strformat]

proc makeFieldCmp(a, b, field: NimNode): NimNode {.compileTime.} =
  quote do:
    if `a`.`field` != `b`.`field`:
      return false

proc makeObjEqBody(objAst, a, b: NimNode): NimNode {.compileTime.} =
  case objAst.kind
    of nnkRecList:
      result = newStmtList()
      for subAst in objAst:
        result.add(makeObjEqBody(subAst, a, b))
    of nnkRecCase:
      objAst.expectMinLen 2
      let selectorDef = objAst[0]
      selectorDef.expectKind nnkIdentDefs
      selectorDef.expectLen 3
      let selector = selectorDef[0]
      selector.expectKind nnkSym
      let selectorCmp = makeFieldCmp(a, b, selector)
      let caseStmt = nnkCaseStmt.newTree(nnkDotExpr.newTree(a, selector))
      for subAst in objAst[1..^1]:
        subAst.expectKind {nnkOfBranch, nnkElse}
        let caseBranch = if subAst.kind == nnkOfBranch:
          subAst.expectMinLen 2
          let branch = nnkOfBranch.newTree
          for condition in subAst[0..^2]:
            branch.add(condition)
          branch
        else:
          subAst.expectLen 1
          nnkElse.newTree
        caseBranch.add(makeObjEqBody(subAst[^1], a, b))
        caseStmt.add(caseBranch)
      result = newStmtList(selectorCmp, caseStmt)
    of nnkIdentDefs:
      objAst.expectLen 3
      let field = objAst[0]
      field.expectKind nnkSym
      result = makeFieldCmp(a, b, field)
    else:
      error fmt"Unexpected node kind {objAst.kind}"

macro objEqImpl(a, b: typed): untyped =
  let objAst = a.getTypeImpl
  if objAst != b.getTypeImpl:
    error fmt"Incompatible types {a.getTypeInst.toStrLit} and {b.getTypeInst.toStrLit}"
  objAst.expectKind nnkObjectTy
  objAst.expectMinLen 2
  objAst[1].expectKind nnkEmpty # Inheritance is not supported for now.
  let body = newStmtList()
  for subAst in objAst[2..^1]:
    body.add(makeObjEqBody(subAst, a, b))
  body.add(nnkReturnStmt.newTree(ident"true"))
  body

template addEqForObject*(t: typedesc, mustExport: bool = true) =
  ## Creates a `\`==\`` operator by traversing an object of type `t` field-by-field.
  ##
  ## To use it with your custom type, just add it somewhere to top level. Set `mustExport` to
  ## `true` if you want the resulting `\`==\`` operator to be exported and to `false` otherwise.
  ##
  ## Usually, this template is not needed, as `\`==\`` operator is generated automatically by the
  ## compiler, but this doesn't work with variant objects. For more details, see Nim issue
  ## [#6676](https://github.com/nim-lang/Nim/issues/6676).
  when mustExport:
    proc `==`*(a, b: t): bool = objEqImpl(a, b)
  else:
    proc `==`(a, b: t): bool = objEqImpl(a, b)

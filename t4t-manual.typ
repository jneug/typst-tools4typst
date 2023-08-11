
// #import "@preview/tidy:0.1.0"
#import "@local/mantys:0.0.3": *

#import "tools4typst.typ"

#let module-scope = (
  is: tools4typst.is,
  def: tools4typst.def,
  alias: tools4typst.alias,
  assert: tools4typst.assert,
  get: tools4typst.get,
  math: tools4typst.math
)


#let test( scope: (:), ..tests ) = {
  for test in tests.pos() {
    let msg = if test.text.starts-with("not ") {
      test.text.slice(4) + " should be false, was true"
    } else {
      test.text + " should be true, was false"
    }
    assert(
      eval(test.text, scope:module-scope + scope),
      message: msg
    )
  }
}

#show: mantys.with(..toml("typst.toml"))

#for name in module-scope.keys() [
  == Module #raw(name, block:false) #label("module-" + name)
  #parse-module(
    read(name + ".typ"),
    name: name,
    scope: module-scope + (test: test)
  )
]


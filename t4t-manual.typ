
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

#let show-module( name ) = module-commands(name)[
  #tidy-module(
    read(name + ".typ"),
    name: name,
    scope: module-scope + (test: test)
  )
]


#show: mantys.with(
  ..toml("typst.toml"),

  subtitle: [Tools For Typst],
  date: datetime.today(),
  abstract: [
    *Tools for Typst* (`t4t` in short) is a utility package for Typst package and template authors. It provides solutions to some recurring tasks in package development.

    The package can be imported or any useful parts of it copied into a project. It is perfectly fine to treat `t4t` as a snippet collection and to pick and choose only some useful functions. For this reason, most functions are implemented without further dependencies.

    Hopefully, this collection will grow over time with *Typst* to provide solutions for common problems.
  ]
)

== Test functions

#codesnippet[```typ
#import "@preview/t4t:0.2.0": is
```]

These functions provide shortcuts to common tests like #cmd(module: "is")[eq]. Some of these are not shorter as writing pure typst code (e.g. `a == b`), but can easily be used in `.any()` or `.find()` calls:

#sourcecode[```typc
// check all values for none
if some-array.any(is-none) {
	...
}

// find first not none value
let x = (none, none, 5, none).find(is.not-none)

// find position of a value
let pos-bar = args.pos().position(is.eq.with("|"))
```]

There are two exceptions: #cmd[is-none] and #cmd[is-auto]. Since keywords can't be used as function names, the #module[is] module can't define a function to do `is.none()`. Therefore the functions #cmd[is-none] and #cmd[is-auto] are provided in the base module of `t4t`:

```js
#import "@preview/t4t:0.2.0": is-none, is-auto
```

The `is` submodule still has these tests, but under different names (#cmd(module:"is")[n] and #cmd(module:"is")[non] for #value(none) and #cmd(module:"is")[a] and #cmd(module:"is")[aut] for #value(auto)).

=== Command reference
#show-module("is")

== Default values

#codesnippet[```typ
#import "@preview/t4t:0.2.0": def
```]

These functions perform a test to decide, if a given `value` is _invalid_. If the test _passes_, the `default` is returned, the `value` otherwise.

Almost all functions support an optional `do` argument, to be set to a function of one argument, that will be applied to the value, if the test fails. For example:
#sourcecode[```typc
// Sets date to a datetime from an optional
// string argument in the format "YYYY-MM-DD"
let date = def.if-none(
	datetime.today(), 	// default
	passed_date, 		// passed in argument
	do: (d) >= {		// post-processor
		d = d.split("-")
		datetime(year=d[0], month=d[1], day=d[2])
	}
)
```]

=== Command reference
#show-module("def")

== Assertions

#codesnippet[```typ
#import "@preview/t4t:0.2.0": assert
```]

This submodule overloads the default #doc("foundations/assert") function and provides more asserts to quickly check if given values are valid. All functions use `assert` in the background.

Since a module in Typst is not callable, the `assert` function is now available as #cmd(module:"assert")[that]. #cmd(module:"assert")[eq] and #cmd(module:"assert")[ne] work as expected.

All assert functions take an optional argument #arg[message] to set the error message for a failed assertion.

=== Command reference
#show-module("assert")


== Element helpers

#codesnippet[```typ
#import "@preview/t4t:0.2.0": get
```]

This submodule is a collection of functions, that mostly deal with content elements and _get_ some information from them. Though some handle other types like dictionaries.

=== Command reference
#show-module("get")


== Math functions

#codesnippet[```typ
#import "@preview/t4t:0.2.0": math
```]

Some functions to complement the native `calc` module.

=== Command reference
#show-module("math")


== Alias functions

#codesnippet[```typ
#import "@preview/t4t:0.2.0": alias
```]

Some of the native Typst function as aliases, to prevent collisions with some common argument namens.

For example using #arg[numbering] as an argument is not possible, if the value is supposed to be passed to the #cmd[numbering] function. To still allow argument names, that are in line with the common Typst names (like `type`, `align` ...), these alias functions can be used:

#sourcecode[```typ
#let excercise( no, numbering: "1)" ) = [
	Exercise #alias.numbering(numbering, no)
]
```]

The following functions have aliases right now:

#columns(3)[
- `numbering`
- `align`
- `type`
- `label`
- `text`
#colbreak()
- `raw`
- `table`
- `list`
- `enum`
#colbreak()
- `terms`
- `grid`
- `stack`
- `columns`
]

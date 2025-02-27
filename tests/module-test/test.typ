
#import "../../src/test.typ": *

#let panic-if-false(t) = if t == false {
  panic("Expected `false`, got `true`.")
}
#let panic-if-true(t) = if t == true {
  panic("Expected `true`, got `false`.")
}

// Test `is-empty()`
#{
  for value in ("", [], (), (:)) {
    panic-if-false(is-empty(value))
  }

  for value in (" ", "a", [ ], [a], ("a",), (1, 2, 3), (a: 1), (a: "1", b: 2)) {
    panic-if-true(is-empty(value))
  }
}

// Test `one-not-none()`
#{
  for value in (
    (false,),
    (none, none, none, 2, "none", none),
    (1, 2, 3, "none"),
  ) {
    panic-if-false(one-not-none(..value))
  }

  for value in (
    (none,),
    (none, none, none),
  ) {
    panic-if-true(one-not-none(..value))
  }
}

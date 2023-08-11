
#import "is.typ": empty

// =================================
//  Get default values
// =================================

/// Returns `default` if `test` is `true`, `value` otherwise.
///
/// If `test` is `false` and `do` is set to a function,
/// `value` is passed to `do`, before being returned.
///
/// // Tests
/// #test(
///   `def.if-true(1 == 1, 2, 3) == 2`,
///   `def.if-true(1 == 2, 2, 3) == 3`,
///   `def.if-true(1 == 2, 2, 3, do: (n) => n+1) == 4`,
///   `def.if-true(1 == 1, 2, 3, do: (n) => n+1) == 2`,
/// )
///
/// - test (boolean): a test result
/// - default (any): default value to return
/// - do (function): postprocessor for `value`
/// - value (any): the valu eto test
#let if-true( test, default, do:none, value ) = if test {
  return default
} else if do == none {
  return value
} else {
  return do(value)
}

/// Returns `default` if `test` is `false`, `value` otherwise.
///
/// If `test` is `true` and `do` is set to a function,
/// `value` is passed to `do`, before being returned.
///
/// // Tests
/// #test(
///   `def.if-false(1 == 1, 2, 3) == 3`,
///   `def.if-false(1 == 2, 2, 3) == 2`,
///   `def.if-false(1 == 1, 2, 3, do: (n) => n+1) == 4`,
///   `def.if-false(1 == 2, 2, 3, do: (n) => n+1) == 2`,
/// )
///
/// - test (boolean): a test result
/// - default (any): default value to return
/// - do (function): postprocessor for `value`
/// - value (any): the valu eto test
#let if-false( test, default, do:none, value ) = if not test {
  return default
} else if do == none {
  return value
} else {
  return do(value)
}

/// Returns `default` if `value` is `none`, `value` otherwise.
///
/// If `value` is not `none` and `do` is set to a function,
/// `value` is passed to `do`, before being returned.
///
/// // Tests
/// #test(
///   `def.if-none(auto, none) == auto`,
///   `def.if-none(auto, 5) == 5`,
///   `def.if-none(auto, none, do: (v) => 1cm) == auto`,
///   `def.if-none(auto, 5, do: (v) => v*1cm) == 5cm`,
/// )
///
/// - default (any): default value to return
/// - do (function): postprocessor for `value`
/// - value (any): the valu eto test
#let if-none( default, do:none, value ) = if value == none {
  return default
} else if do == none {
  return value
} else {
  return do(value)
}

/// Returns `default` if `value` is `auto`, `value` otherwise.
///
/// If `value` is not `auto` and `do` is set to a function,
/// `value` is passed to `do`, before being returned.
///
/// // Tests
/// #test(
///   `def.if-auto(none, auto) == none`,
///   `def.if-auto(1mm, 5) == 5`,
///   `def.if-auto(1mm, auto, do: (v) => 1cm) == 1mm`,
///   `def.if-auto(1mm, 5, do: (v) => v*1cm) == 5cm`,
/// )
///
/// - default (any): default value to return
/// - do (function): postprocessor for `value`
/// - value (any): the valu eto test
#let if-auto( default, do:none, value ) = if value == auto {
  return default
} else if do == none {
  return value
} else {
  return do(value)
}

/// Returns `default` if `value` is equal to any value in `compare`, `value` otherwise.
///
/// ```typ
/// #def.if-any(
///   none, auto,     // ..compare
///   1pt,            // default
///   thickness       // value
/// )
/// ```
///
/// If `value` is in `compare` and `do` is set to a function,
/// `value` is passed to `do`, before being returned.
///
/// // Tests
/// #test(
///   `def.if-any(none, auto, 1pt, none) == 1pt`,
///   `def.if-any(none, auto, 1pt, auto) == 1pt`,
///   `def.if-any(none, auto, 1pt, 2pt) == 2pt`,
///   `def.if-any(none, auto, 1pt, 2pt, do:(v)=>3mm) == 3mm`,
///   `def.if-any(none, auto, 1pt, none, do:(v)=>3mm) == 1pt`,
/// )
///
/// - ..compare (any): list of values to compare `value` to
/// - default (any): default value to return
/// - do (function): postprocessor for `value`
/// - value (any): value to test
#let if-any( ..compare, default, do:none, value ) = if value in compare.pos() {
  return default
} else if do == none {
  return value
} else {
  return do(value)
}

/// Returns `default` if `value` is not equal to any value in `compare`, `value` otherwise.
///
/// ```typ
/// #def.if-not-any(
///   left, right, top, bottom,   // ..compare
///   left,                       // default
///   position                    // value
/// )
/// ```
///
/// If `value` is in `compare` and `do` is set to a function,
/// `value` is passed to `do`, before being returned.
///
/// // Tests
/// #test(
///   `def.if-auto(none, auto) == none`,
///   `def.if-auto(1mm, 5) == 5`,
///   `def.if-auto(1mm, auto, do: (v) => 1cm) == 1mm`,
///   `def.if-auto(1mm, 5, do: (v) => v*1cm) == 5cm`,
/// )
///
/// - ..compare (any): list of values to compare `value` to
/// - default (any): default value to return
/// - do (function): postprocessor for `value`
/// - value (any): value to test
#let if-not-any( ..compare, default, do:none, value ) = if value not in compare.pos() {
  return default
} else if do == none {
  return value
} else {
  return do(value)
}

/// Returns `default` if `value` is empty, `value` otherwise.
///
/// If `value` is not empty and `do` is set to a function,
/// `value` is passed to `do`, before being returned.
///
/// Depends on `is.empty()`. See there for an explanation
/// of _empty_.
///
/// // Tests
/// #test(
///   `def.if-empty("a", "") == "a"`,
///   `def.if-empty("a", none) == "a"`,
///   `def.if-empty("a", ()) == "a"`,
///   `def.if-empty("a", (:)) == "a"`,
/// )
///
/// - default (any): default value to return
/// - do (function): postprocessor for `value`
/// - value (any): value to test
#let if-empty( default, do:none, value ) = if empty(value) {
  return default
} else if do == none {
  return value
} else {
  return do(value)
}

/// Returns `default` if `key` is not an existing key in `args.named()`, `args.named().at(key)` otherwise.
///
/// If `value` is not in `args` and `do` is set to a function,
/// the value is passed to `do`, before being returned.
///
/// // Tests
/// #test(
///   scope: (fun: (..args) => def.if-arg(100%, args, "width")),
///   `fun(a:1, b:2, c:30%) == 100%`,
///   `fun(a:1, b:2, width:30%) == 30%`,
/// )
///
/// - default (any): default value to return
/// - do (function): postprocessor for `value`
/// - args (any): arguments to test
/// - key (any): key to look for
#let if-arg( default, do:none, args, key ) = if key not in args.named() {
  return default
} else if do == none {
  args.named().at(key)
} else {
  do(args.named().at(key))
}

/// Always returns an array containing all `values`.
///
/// Any arrays in `values` will be flattened into the result.
/// This is useful for arguments, that can have one element
/// or an array of elements:
/// ```typ
/// #def.as-arr(author).join(", ")
/// ```
/// // Tests
/// #test(
///   `def.as-arr("a", "b", "c") == ("a", "b", "c")`,
///   `def.as-arr(("a", "b"), "c") == ("a", "b", "c")`,
///   `def.as-arr(("a", "b", "c")) == ("a", "b", "c")`,
///   `def.as-arr(("a"), ("b"), "c") == ("a", "b", "c")`,
///   `def.as-arr(("a"), (("b"), "c")) == ("a", "b", "c")`,
/// )
#let as-arr( ..values ) = (..values.pos(),).flatten()


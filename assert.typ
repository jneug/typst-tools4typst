
#import "alias.typ"

// =================================
//  Asserts
// =================================

/// Asserts that #m.arg[test] is #m.value(true). See #m.doc("foundations/assert")
#let that = assert

/// Asserts that #m.arg[test] is #m.value(false).
///
/// - test (boolean): Assertion to test.
/// - message (str): A message to show if the assert fails.
#let that-not(test, message:"") = assert(not test, message:message)

/// Asserts that two values are equal.
#let eq = assert.eq

/// Asserts that two values are not equal.
#let ne = assert.ne

/// Alias for @@ne()
#let neq = assert.ne

/// Asserts that a value is not #m.value(none)
#let not-none = assert.ne.with(none)

/// Assert that #m.arg[value] is any one of #m.arg[values].
///
/// - ..values (any): A set of values to compare `value` to.
/// - value (any): Value to compare.
/// - message (str): A message to show if the assert fails.
#let any( ..values, value, message:"" ) = assert(value in values.pos(), message:message)

/// Assert that #m.arg[value] is not any one of #m.arg[values].
///
/// // Tests
/// assert.not-any(none, auto, 3)
///
/// - ..values (any): A set of values to compare `value` to.
/// - value (any): Value to compare.
/// - message (str): A message to show if the assert fails.
#let not-any( ..values, value, message:"" ) = assert(value not in values.pos(), message:message)

/// Assert that #m.arg[value]s type is any one of #m.arg[types].
///
/// // Tests
/// #assert.any-type("float", "integer", 3)
/// #assert.any-type("float", "integer", 3.3)
/// #assert.any-type("string", "boolean", true)
/// #assert.any-type("string", "boolean", "foo")
///
/// - ..types (string): A set of types to compare the type of `value` to.
/// - value (any): Value to compare.
/// - message (str): A message to show if the assert fails.
#let any-type( ..types, value, message:"") = assert(type(value) in types.pos(), message:message)

/// Assert that #m.arg[value]s type is not any one of #m.arg[types].
///
/// // Tests
/// #assert.not-any-type("float", "integer", "foo")
/// #assert.not-any-type("string", "boolean", 1%)
///
/// - ..types (string): A set of types to compare the type of `value` to.
/// - value (any): Value to compare.
/// - message (str): A message to show if the assert fails.
#let not-any-type( ..types, value, message:"" ) = assert(type(value) not in types.pos(), message:message)

/// Assert that the types of all #m.arg[values] are equal to #m.arg[t].
///
/// // Tests
/// #assert.all-of-type("string", "a", "b")
/// #assert.all-of-type("length", 1pt, 3em, 4mm)
///
/// - t (string): The type to test against.
/// - ..values (any): Values to test.
/// - message (str): A message to show if the assert fails.
#let all-of-type( t, ..values, message:"") = assert(values.pos().all((v) => alias.type(v) == t), message:message)
#let none-of-type( t, ..values, message:"") = assert(values.pos().all((v) => alias.type(v) != t), message:message)

#let not-empty( value, message:"" ) = {
  if type(value) == "array" {
    assert.ne(value, (), message:message)
  } else if type(value) == "dictionary" {
    assert.ne(value, (:), message:message)
  } else if type(value) == "string" {
    assert.ne(value, "", message:message)
  } else {
    assert.ne(value, none, message:message)
  }
}

/// Creates a new assertion from `test`.
///
/// The new assertion will take a `value` and pass it to `test`. `test` should return a `boolean`.
///
/// - test (function): A test function: #m.lambda("any", ret:true)
#let new( test ) = (v, message:"") => assert(test(v), message:message)

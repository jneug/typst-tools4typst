
#import "is.typ": all-of-type

// =================================
//  Dictionaries
// =================================

/// Create a new dictionary from the passed `values`.
///
/// All named arguments are stored in the new dictionary as is.
/// All positional arguments are grouped in key/value-pairs and inserted into the dictionary:
/// ```typ
/// #get.dict("a", 1, "b", 2, "c", d:4, e:5)
///    // gives (a:1, b:2, c:none, d:4, e:5)
/// ```
///
/// // Tests
/// #test(
///   `get.dict("a", "b", "c") == (a:"b", c:none)`,
///   `get.dict("a", "b", "c", 4) == (a:"b", c:4)`,
///   `get.dict(a:"b", "c", 4) == (a:"b", c:4)`
/// )
#let dict( ..dicts ) = {
  let d = (:)
  for i in range(1, dicts.pos().len(), step:2) {
    d.insert(
      str(dicts.pos().at(i - 1)),
      dicts.pos().at(i)
    )
  }
  if calc.odd(dicts.pos().len()) {
    d.insert(dicts.pos().last(), none)
  }
  for (k, v) in dicts.named() {
    d.insert(k, v)
  }
  return d
}

/// Recursivley merges the passed in dictionaries.
///
/// ```typ
/// #get.dict-merge(
///     (a: 1),
///     (a: (one: 1, two:2)),
///     (a: (two: 4, three:3))
/// )
///    // gives (a:(one:1, two:4, three:3))
/// ```
///
/// // Tests
/// #test(
///   `get.dict-merge(
///     (a: 1),
///     (a: (one: 1, two:2)),
///     (a: (two: 4, three:3))
///   ) == (a:(one:1, two:4, three:3))`
/// )
///
/// Based on work by #{sym.at + "johannes-wolf"} for #link("https://github.com/johannes-wolf/typst-canvas/", "johannes-wolf/typst-canvas").
#let dict-merge( ..dicts ) = {
  if all-of-type("dictionary", ..dicts.pos()) {
    let c = (:)
    for dict in dicts.pos() {
      for (k, v) in dict {
        if k not in c {
          c.insert(k, v)
        } else {
          let d = c.at(k)
          c.insert(k, dict-merge(d, v))
        }
      }
    }
    return c
  } else {
    return dicts.pos().last()
  }
}

/// Creats a function to extract values from an argument sink `args`.
///
/// The resulting function takes any number of positional and
/// named arguments and creates a dictionary with values from
/// `args.named()`. Positional arguments to the function are
/// present in the result, if they are present in `args.named()`.
/// Named arguments are always present, either with their value
/// from `args.named()` or with the provided value.
///
/// A `prefix` can be specified, to extract only specific arguments.
/// The resulting dictionary will have all keys with the prefix removed, though.
///
/// ```typ
/// #let my-func( ..options, title ) = block(
///     ..get.args(options)(
///         "spacing", "above", "below",
///         width:100%
///     )
/// )[
///     #text(..get.args(options, prefix:"text-")(
///         fill:black, size:0.8em
///     ), title)
/// ]
///
/// #my-func(
///     width: 50%,
///     text-fill: red, text-size: 1.2em
/// )[#lorem(5)]
/// ```
///
/// // Tests
/// #test(
///   scope:(
///     fun: (..args) => get.args(args)("a", b:4),
///     fun2: (..args) => get.args(args, prefix:"pre-")("a", b:4)
///   ),
///   `fun(a:1, b:2) == (a:1, b:2)`,
///   `fun(a:1) == (a:1, b:4)`,
///   `fun(b:2) == (b:2)`,
///   `fun2(pre-a:1, pre-b:2) == (a:1, b:2)`,
///   `fun2(pre-a:1, b:2) == (a:1, b:4)`,
///   `fun2(pre-b:2) == (b:2)`
/// )
#let args(
	args,
	prefix: ""
) = (..keys) => {
	let vars = (:)
  for key in keys.pos() {
    let k = prefix + key
    if k in args.named() {
			vars.insert(key, args.named().at(k))
		}
  }
	for (key, value) in keys.named() {
	  let k = prefix + key
		if k in args.named() {
			vars.insert(key, args.named().at(k))
		} else {
			vars.insert(key, value)
		}
	}

	return vars
}

/// Recursively extracts the text content of a content element.
///
/// If present, all child elements are converted to text and joined with `sep`.
///
/// // Tests
/// #test(
///   `get.text([Hello World!]) == "Hello World!"`
/// )
#let text( element, sep: "" ) = {
	if type(element) == "content" {
		if element.has("text") {
			element.text
		} else if element.has("children") {
     element.children.map(text).join(sep)
		} else if element.has("child") {
			text(element.child)
		} else if element.has("body") {
			text(element.body)
		} else {
			""
		}
  } else if type(element) in ("array", "dict") {
    return ""
	} else {
		str(element)
	}
}

#let stroke-paint-regex = regex("\+ ((rgb|cmyk|luma)\(.+\))$")

/// Returns the color of `stroke`.
/// If no thickness information is available, `default` is used.
/// *Deprecated since Typst 0.7.0*: use `stroke.thickness` instead.
///
/// Based on work by #{sym.at + "PgBiel"} for #link("https://github.com/PgBiel/typst-tablex", "PgBiel/typst-tablex").
///
/// // Tests
/// #test(
///   `get.stroke-paint(2pt + green) == green`
/// )
#let stroke-paint( stroke, default: black ) = {
  if type(stroke) in ("length", "relative length") {
    return default
  } else if type(stroke) == "color" {
    return stroke
  } else if type(stroke) == "stroke" {  // 2em + blue
    let s = repr(stroke).find(stroke-paint-regex)

    if s == none { return default }
    else { return eval(s.slice(2)) }
  } else if type(stroke) == "dictionary" and "paint" in stroke {
    return stroke.paint
  } else {
    return default
  }
}

#let stroke-thickness-regex = regex("^\\d+(?:em|pt|cm|in|%)")

/// Returns the thickness of `stroke`.
/// If no thickness information is available, `default` is used.
/// *Deprecated since Typst 0.7.0*: use `stroke.thickness` instead.
///
/// // Tests
/// #test(
///   `get.stroke-thickness(2pt + green) == 2pt`
/// )
#let stroke-thickness( stroke, default: 1pt ) = {
  if type(stroke) in ("length", "relative length") {
    return stroke
  } else if type(stroke) == "color" {
    return 1pt
  } else if type(stroke) == "stroke" {  // 2em + blue
    let s = repr(stroke).find(stroke-thickness-regex)

    if s == none { return default }
    else { return eval(s) }
  } else if type(stroke) == "dictionary" and "thickness" in stroke {
    return stroke.thickness
  } else {
    return default
  }
}

#let stroke-dict( stroke, ..overrides ) = {
  let dict = (
    paint: stroke-paint(stroke),
    thickness: stroke-thickness(stroke),
    dash: "solid",
    cap: "round",
    join: "round"
  )
  if type(stroke) == "dictionary" {
    dict = dict + stroke
  }
  return dict + overrides.named()
}

#let inset-at( direction, inset, default: 0pt ) = {
  direction = repr(direction)   // allows use of alignment values
  if type(inset) == "dictionary" {
    if direction in inset {
      return inset.at(direction)
    } else if direction in ("left", "right") and "x" in inset {
      return inset.x
    } else if direction in ("top", "bottom") and "y" in inset {
      return inset.y
    } else if "rest" in inset {
      return inset.rest
    } else {
      return default
    }
  } else if inset == none {
    return default
  } else {
    return inset
  }
}

#let inset-dict( inset, ..overrides ) = {
  let dict = (
    top: inset-at(top, inset),
    bottom: inset-at(bottom, inset),
    left: inset-at(left, inset),
    right: inset-at(right, inset)
  )
  if type(inset) == "dictionary" {
    dict = dict + inset
  }
  return dict + overrides.named()
}

// {deprecated}
#let x-align( align, default:left ) = {
  if align in (left, right, center) {
    return align
  } else if type(align) == "2d alignment" {
    return eval(repr(align).split().first())
  } else {
    return default
  }
}

// {deprecated}
#let y-align( align, default:top ) = {
  if align in (top, bottom, horizon) {
    return align
  } else if type(align) == "2d alignment" {
    return eval(repr(align).split().last())
  } else {
    return default
  }
}


// Test functions for use in any(), all() or find()
#let eq( compare, value ) = {
  return value == compare
}

#let neq( compare, value ) = {
  return value != compare
}

#let is-none( value ) = {
  return value == none
}

#let not-none( value ) = {
  return value != none
}

#let is-auto( value ) = {
  value == auto
}

#let not-auto( value ) = {
  return value != auto
}

#let is-any( ..compare, value ) = {
  // return compare.pos().any((v) => v == value)
  return value in compare.pos()
}

#let not-is-any( ..compare, value) = {
  // return not compare.pos().any((v) => v == value)
  return not value in compare.pos()
}

// Types
#let is-type( t, value ) = type(value) == t

#let is-dict( value ) = type(value) == "dictionary"

#let is-arr( value ) = type(value) == "array"

#let is-content( value ) = type(value) == "content"

#let is-length( value ) = type(value) == "length"

#let is-ratio( value ) = type(value) == "ratio"

#let is-color( value ) = type(value) == "color"

#let is-num( value ) = type(value) in ("float", "integer")

#let is-any-type( ..types, value ) = {
  return type(value) in types.pos()
}

#let same-type( ..values ) = {
  let t = type(values.pos().first())
  return values.pos().all((v) => type(v) == t)
}

#let all-of-type( t, ..values ) = values.pos().all((v) => type(v) == t)

// Defaults
#let def-if( test, default, value ) = if test {
  return default
} else {
  return value
}

#let def-if-none( default, value ) = if value == none {
  return default
} else {
  return value
}

#let def-if-auto( default, value ) = if value == auto {
  return default
} else {
  return value
}

#let def-if-not( test, default, value ) = if not test {
  return default
} else {
  return value
}

#let def-if-any( ..compare, default, value ) = if value in compare.pos() {
  return default
} else {
  return value
}

#let def-if-not-any( ..compare, default, value ) = if not value in compare.pos() {
  return default
} else {
  return value
}


// Dictionaries
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

// typst-canvas
#let dict-merge( ..dicts ) = {
  if all-of-type("dictionary", ..dicts.pos()) {
    let c = (:)
    for dict in dicts.pos() {
      for (k, v) in dict {
        if not k in c {
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

// Extract arguments from a sink
#let get-args(
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

// Extract text from any element
#let get-text( element, sep: "" ) = {
	if type(element) == "content" {
		if element.has("text") {
			element.text
		} else if element.has("children") {
     element.children.map(get-text).join(sep)
		} else if element.has("child") {
			get-text(element.child)
		} else if element.has("body") {
			get-text(element.body)
		} else {
			""
		}
	} else {
		str(element)
	}
}


// Math
#let minmax( a, b ) = (
  calc.min(a, b),
  calc.max(a, b)
)

// Requires `#same-type()`
#let clamp( min, max, value ) = {
  if type(min) != type(max) or type(min) != type(value) {
		panic("Can't clamp values of different types!")
	}
  // (min, max) = minmax(min, max)
	if value < min { return min }
	else if value > max { return max }
	else { return value }
}

#let lerp( min, max, t ) = {
  if type(min) != type(max) {
		panic("Can't lerp values of different types!")
	}
 // (min, max) = minmax(min, max)
  return min + (max - min) * t
}

#let map( min, max, range-min, range-max, value ) = {
  if type(min) != type(max) {
		panic("Can't map values from ranges of different types!")
	}
  if type(range-min) != type(range-max) {
		panic("Can't map values to ranges of different types!")
	}
  if type(min) != type(value) {
		panic("Can't map values with different types as the initial range!")
	}
  // (min, max) = minmax(min, max)
  // (range-min, range-max) = minmax(range-min, range-max)
	let t = (value - min) / (max - min)
	return range-min + t * (range-max - range-min)
}



// Aliases for some typst functions
// to prevent naming collisions
#let typ-numbering = numbering
#let typ-align = align
#let typ-type = type
#let typ-text = text



// Based on work by @PgBiel for PgBiel/typst-tablex
// See: https://github.com/PgBiel/typst-tablex
#let stroke-paint-regex = regex("\+ ((rgb|cmyk|luma)\(.+\))$")

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

#let x-align( align, default:left ) = {
  if align in (left, right, center) {
    return align
  } else if type(align) == "2d alignment" {
    return eval(repr(align).split().first())
  } else {
    return default
  }
}

#let y-align( align, default:top ) = {
  if align in (top, bottom, horizon) {
    return align
  } else if type(align) == "2d alignment" {
    return eval(repr(align).split().last())
  } else {
    return default
  }
}

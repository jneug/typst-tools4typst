
// =================================
//  Element marks
// =================================

#let mark-as( mark, elem ) = {
  if mark != none and type(mark) != "label" { mark = label(mark) }
  [#elem#mark]
}

#let has-mark( mark, elem ) = {
  if mark != none and type(mark) != "label" { mark = label(mark) }
  return type(elem) == "content" and elem.has("label") and elem.label == mark
}

#let not-has-mark( mark, elem ) = {
  if type(mark) != "label" { mark = label(mark) }
  return type(elem) != "content" or not elem.has("label") or elem.label != mark
}

// =================================
//  Hidden markers
// =================================

#let place-marker( name ) = {
  raw("", lang:"--meta-" + name + "--")
}

#let marker( name ) = selector(raw.where(lang: "--meta-" + name + "--"))

// =================================
//  Hidden meta data
// =================================

#let add( ..args, elem ) = {
  [#elem#hide(box(width:0pt, height:0pt, repr(args.named())))<--meta-data-->]
}

#let rm( elem ) = {
  if type(elem) == "content" and repr(elem.func()) == "sequence" {
    let data = elem.children.filter(has-mark.with(<--meta-data-->))
    if data != none {
      elem = elem.children.find(not-has-mark.with(<--meta-data-->))
    }
  }
  return elem
}

#let get( name:"data", elem ) = {
  if type(elem) == "content" and repr(elem.func()) == "sequence" {
    let data = elem.children.find(has-mark.with(<--meta-data-->))
    if data != none {
      return eval(data.body.body.text)
    }
  }
  return (:)
}

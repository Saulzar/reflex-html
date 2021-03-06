module Builder.Svg.Elements where

import Prelude

import Builder.Element
import Builder.TH

import Data.Text

-- svgNs :: Text
-- svgNs = "http://www.w3.org/2000/svg"
--
-- elem ::  Text -> Elem
-- elem elemName props child = snd <$> makeElem' (Just svgNs) elemName props child
-- {-# INLINE elem #-}
--
-- elem_ ::  Text -> Elem_
-- elem_ elemName props child = fst <$> makeElem' (Just svgNs) elemName props child
-- {-# INLINE elem_ #-}
--
-- child_ ::  Text -> Child_
-- child_ elemName props = fst <$> makeElem' (Just svgNs) elemName props (return ())
-- {-# INLINE child_ #-}
--
-- elem' ::  Text -> Elem'
-- elem' = makeElem' (Just svgNs)
-- {-# INLINE elem' #-}

$(mkElems (Just "http://www.w3.org/2000/svg")
  [ E "a"
  , E "altGlyph"
  , E "altGlyphDef"
  , E "altGlyphItem"
  , E "animate"
  , E "animateColor"
  , E "animateMotion"
  , E "animateTransform"

  , C "circle"
  , E "clipPath"
  , E "color_profile"
  , E "cursor"

  , E "defs"
  , E "desc"
  , E "discard"

  , E "ellipse"

  , C "feBlend"
  , C "feColorMatrix"
  , E "feComponentTransfer"
  , C "feComposite"
  , C "feConvolveMatrix"
  , C "feDiffuseLighting"
  , C "feDisplacementMap"
  , C "feDistantLight"
  , C "feDropShadow"
  , C "feFlood"
  , C "feFuncA"
  , C "feFuncB"
  , C "feFuncG"
  , C "feFuncR"
  , C "feGaussianBlur"
  , C "feImage"
  , E "feMerge"
  , C "feMergeNode"
  , C "feMorphology"
  , C "feOffset"
  , C "fePointLight"
  , C "feSpecularLighting"
  , C "feSpotLight"
  , C "feTile"
  , C "feTurbulence"
  , E "filter"
  , E "font"
  , E "font_face"
  , E "font_face_format"
  , E "font_face_name"
  , E "font_face_src"
  , E "font_face_uri"
  , E "foreignObject"

  , E "g"
  , E "glyph"
  , E "glyphRef"

  , E "hatch"
  , E "hatchpath"
  , E "hkern"

  , C "image"

  , C "line"
  , E "linearGradient"

  , E "marker"
  , E "mask"
  , E "mesh"
  , E "meshgradient"
  , E "meshpatch"
  , E "meshrow"
  , E "metadata"
  , E "missing_glyph"
  , E "mpath"

  , C "path"
  , E "pattern"
  , C "polygon"
  , C "polyline"

  , E "radialGradient"
  , C "rect"

  , E "script"
  , E "set"
  , E "solidcolor"
  , E "stop"
  , C "style"
  , E "svg"
  , E "switch"
  , E "symbol"

  , E "text"
  , E "textPath"
  , E "title"
  , E "tspan"

  , C "use"

  , E "view"
  ])

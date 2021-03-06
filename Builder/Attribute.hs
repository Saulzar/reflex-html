{-# LANGUAGE UndecidableInstances, InstanceSigs #-}

module Builder.Attribute where

import Data.Maybe (catMaybes, fromMaybe)
import Reflex hiding (Value)
import Reflex.Dom (AttributeName(..))

import Data.Functor
import Data.Monoid hiding ((<>))
import Data.Semigroup

import Data.Functor.Contravariant
import Data.Functor.Contravariant.Divisible
import Data.Text as T

import qualified Data.Map.Strict as M
import Data.Map (Map)

import Control.Lens hiding (chosen)

import Reflex.Active
import Data.Coerce

import Linear.V3 (V3(..))

newtype Attribute a
  = Attribute { unAttr :: Map AttributeName (a -> Maybe Text) } deriving (Monoid, Semigroup)

instance Contravariant Attribute where
  contramap f' (Attribute m) = Attribute (fmap (. f') m)

instance Divisible Attribute where
  divide f ab ac = contramap (fst . f) ab <> contramap (snd . f) ac
  conquer = Attribute mempty


instance Decidable Attribute where
  choose f' (Attribute mb) (Attribute mc) = Attribute $ fmap lefts mb <> fmap rights mc  where
    lefts f = (>>= f) . preview _Left . f'
    rights f = (>>= f) . preview _Right . f'

  lose _ =  Attribute mempty

_attrs :: Traversal (Attribute a) (Attribute b) (Map AttributeName (a -> Maybe Text)) (Map AttributeName (b -> Maybe Text))
_attrs = coerced

_attr :: Traversal (Attribute a) (Attribute b) (a -> Maybe Text) (b -> Maybe Text)
_attr = _attrs . traverse

{-# INLINE optional #-}
optional :: Attribute a -> Attribute (Maybe a)
optional = over _attr (\f a -> a >>= f)

{-# INLINE toggles #-}
toggles :: Attribute a -> Attribute b -> Attribute (Either a b)
toggles = chosen

(<+>) :: Divisible f => f a -> f a -> f a
(<+>) = divide (\x -> (x, x))

{-# INLINE applyAttr #-}
applyAttr ::  Attribute a -> a -> Map AttributeName (Maybe Text)
applyAttr (Attribute m) a = M.map ($ a) m

{-# INLINE applyAttr' #-}
applyAttr' ::  Attribute a -> a -> Map AttributeName Text
applyAttr' (Attribute m) a = M.mapMaybe ($ a) m


-- Property values define attributes and modifiers
-- e.g. event filters setters which operate on elements
data Property t where
  AttrProp :: Attribute a -> Active t a -> Property t

{-# INLINE (=:) #-}
(=:) :: Reflex t => Attribute a -> a -> Property t
(=:) k a = k ~: Static a

class Reflex t => ActiveValue v t where
  (~:) :: Attribute a -> v t a -> Property t

instance Reflex t => ActiveValue Active t where
  {-# INLINE (~:) #-}
  (~:) = AttrProp

instance Reflex t => ActiveValue Dynamic t where
  {-# INLINE (~:) #-}
  (~:) k = AttrProp k . Dyn


infixr 0 =:
infixr 0 ~:

{-# INLINE setNs #-}
setNs :: Text -> Attribute a -> Attribute a
setNs ns = over _attrs (M.mapKeys setNs')
  where setNs' (AttributeName _ name) = AttributeName (Just ns) name

{-# INLINE cond #-}
cond :: a -> Attribute a -> Attribute Bool
cond a = over _attr (\f b -> if b then f a else Nothing)

{-# INLINE sepBy #-}
sepBy :: Text -> Attribute a -> Attribute [a]
sepBy sep = over _attr cat where
  cat f xs = case catMaybes (f <$> xs) of
    []  -> Nothing
    strs -> Just $ T.intercalate sep strs

{-# INLINE commaSep #-}
commaSep :: Attribute a -> Attribute [a]
commaSep = sepBy ","

{-# INLINE spaceSep #-}
spaceSep :: Attribute a -> Attribute [a]
spaceSep = sepBy " "

{-# INLINE commaListA #-}
commaListA :: Text -> Attribute [Text]
commaListA = commaSep . strA

{-# INLINE spaceListA #-}
spaceListA :: Text -> Attribute [Text]
spaceListA = spaceSep . strA

{-# INLINE attrWith #-}
attrWith :: AttributeName -> (a -> Maybe Text) -> Attribute a
attrWith name = Attribute . M.singleton name

{-# INLINE strA #-}
strA :: Text -> Attribute Text
strA name = attrWith (AttributeName Nothing name) Just

{-# INLINE showA #-}
showA :: Show a => Text -> Attribute a
showA = contramap (T.pack . show) . strA


{-# INLINE showingA #-}
showingA :: (a -> String) -> Text -> Attribute a
showingA f = contramap (T.pack . f) . strA

{-# INLINE boolA #-}
boolA :: Text -> Attribute Bool
boolA name = attrWith (AttributeName Nothing name) (\b -> if b then Just "" else Nothing)

{-# INLINE intA #-}
intA :: Text -> Attribute Int
intA = showA

{-# INLINE floatA #-}
floatA :: Text -> Attribute Float
floatA = showA

{-# INLINE rgbA #-}
rgbA :: Text -> Attribute (V3 Float)
rgbA = contramap showRgb . strA
   
showRgb :: Show a => V3 a -> Text
showRgb (V3 r g b) = T.pack $ "rgb(" <> show r <> "," <> show g <> "," <> show b <> ")"

{-# INLINE ifA #-}
ifA :: Text -> Text -> Text -> Attribute Bool
ifA t f = contramap fromBool . strA
  where fromBool b = if b then t else f

{-# INLINE styleA #-}
styleA :: Text -> Attribute [(Text, Text)]
styleA name = attrWith (AttributeName Nothing name) toStyle where
  toStyle attrs = Just $ T.concat (pair <$> attrs)
  pair (attr, value) = attr <> ":" <> value <> ";"

{-# LANGUAGE NoImplicitPrelude #-}
-- |
-- Module:       $HEADER$
-- Description:  Lazy function combinator "between" and its variations.
-- Copyright:    (c) 2013-2015, Peter Trško
-- License:      BSD3
--
-- Maintainer:   peter.trsko@gmail.com
-- Stability:    experimental
-- Portability:  NoImplicitPrelude
--
-- Implementation of lazy 'between' combinator and its variations. For
-- introductory documentation see module "Data.Function.Between" and
-- for strict versions import "Data.Function.Between.Strict" module.
--
-- Prior to version 0.10.0.0 functions defined in this module were directly
-- in "Data.Function.Between".
--
-- /Since version 0.10.0.0./
module Data.Function.Between.Lazy
    (
    -- * Between Function Combinator
    --
    -- | Captures common pattern of @\\g -> (f '.' g '.' h)@ where @f@ and @h@
    -- are fixed parameters.
      between
    , (~@~)
    , (~@@~)

    -- ** Derived Combinators
    --
    -- | Combinators that either further parametrise @f@ or @g@ in
    -- @f '.' g '.' h@, or apply '~@~' more then once.
    , (^@~)
    , (~@@^)

    , (^@^)
    , (^@@^)

    , between2l
    , between3l

    -- ** Lifted Combinators
    --
    -- | Combinators based on '~@~', '^@~', '^@^', and their flipped variants,
    -- that use 'fmap' to lift one or more of its arguments to operate in
    -- 'Functor' context.
    , (<~@~>)
    , (<~@@~>)

    , (<~@~)
    , (~@@~>)

    , (~@~>)
    , (<~@@~)

    , (<^@~)
    , (~@@^>)

    , (<^@^>)
    , (<^@@^>)

    , (<^@^)
    , (^@@^>)

    , (^@^>)
    , (<^@@^)

    -- * In-Between Function Application Combinator
    --
    -- | Captures common pattern of @\\f -> (a \`f\` b)@ where @a@ and @b@ are
    -- fixed parameters. It doesn't look impressive untill one thinks about @a@
    -- and @b@ as functions.
    --
    -- /Since version 0.11.0.0./
    , inbetween
    , (~$~)
    , (~$$~)

    , withIn
    , withReIn
    )
  where

import Data.Functor (Functor(fmap))
import Data.Function ((.), flip, id)


-- | Core combinator of this module and we build others on top of. It also has
-- an infix form '~@~' and flipped infix form '~@@~'.
--
-- This function Defined as:
--
-- @
-- 'between' f g -> (f .) . (. g)
-- @
between :: (c -> d) -> (a -> b) -> (b -> c) -> a -> d
between f g = (f .) . (. g)

-- | Infix variant of 'between'.
--
-- Fixity is left associative and set to value 8, which is one less then fixity
-- of function composition ('.').
(~@~) :: (c -> d) -> (a -> b) -> (b -> c) -> a -> d
(~@~) = between
infixl 8 ~@~

-- | Flipped variant of '~@~', i.e. flipped infix variant of 'between'.
--
-- Fixity is right associative and set to value 8, which is one less then
-- fixity of function composition ('.').
(~@@~) :: (a -> b) -> (c -> d) -> (b -> c) -> a -> d
(~@@~) = flip between
infixr 8 ~@@~

-- | As '~@~', but first function is also parametrised with @a@, hence the name
-- '^@~'. Character @^@ indicates which argument is parametrised with
-- additional argument.
--
-- This function is defined as:
--
-- @
-- (f '^@~' g) h a -> (f a '~@~' g) h a
-- @
--
-- Fixity is left associative and set to value 8, which is one less then
-- fixity of function composition ('.').
(^@~) :: (a -> c -> d) -> (a -> b) -> (b -> c) -> a -> d
(f ^@~ g) h a = (f a `between` g) h a
infixl 8 ^@~

-- | Flipped variant of '^@~'.
--
-- Fixity is right associative and set to value 8, which is one less then
-- fixity of function composition ('.').
(~@@^) :: (a -> b) -> (a -> c -> d) -> (b -> c) -> a -> d
(~@@^) = flip (^@~)
infixr 8 ~@@^

-- | Pass additional argument to first two function arguments.
--
-- This function is defined as:
--
-- @
-- (f '^@^' g) h a b -> (f a '~@~' g a) h b
-- @
--
-- See also '^@~' to note the difference, most importantly that '^@~' passes
-- the same argument to all its functional arguments. Function '^@~' can be
-- defined in terms of this one as:
--
-- @
-- (f '^@~' g) h a = (f '^@^' 'Data.Function.const' g) h a a
-- @
--
-- We can do it also the other way around and define '^@^' using '^@~':
--
-- @
-- f '^@^' g =
--     'Data.Tuple.curry' . (f . 'Data.Tuple.snd' '^@~' 'Data.Tuple.uncurry' g)
-- @
--
-- Fixity is set to value 8, which is one less then of function composition
-- ('.').
(^@^) :: (a -> d -> e) -> (a -> b -> c) -> (c -> d) -> a -> b -> e
(f ^@^ g) h a = (f a `between` g a) h
infix 8 ^@^

-- | Flipped variant of '^@^'.
--
-- Fixity is set to value 8, which is one less then of function composition
-- ('.').
(^@@^) :: (a -> b -> c) -> (a -> d -> e) -> (c -> d) -> a -> b -> e
(^@@^) = flip (^@^)
infix 8 ^@@^

-- | Apply function @g@ to each argument of binary function and @f@ to its
-- result. In suffix \"2l\" the number is equal to arity of the function it
-- accepts as a third argument and character \"l\" is for \"left associative\".
--
-- @
-- 'between2l' f g = (f '~@~' g) '~@~' g
-- @
--
-- Interesting observation:
--
-- @
-- (\\f g -> 'between2l' 'Data.Function.id' g f) === 'Data.Function.on'
-- @
between2l :: (c -> d) -> (a -> b) -> (b -> b -> c) -> a -> a -> d
between2l f g = (f `between` g) `between` g

-- | Apply function @g@ to each argument of ternary function and @f@ to its
-- result. In suffix \"3l\" the number is equal to arity of the function it
-- accepts as a third argument and character \"l\" is for \"left associative\".
--
-- This function is defined as:
--
-- @
-- 'between3l' f g = ((f '~@~' g) '~@~' g) '~@~' g
-- @
--
-- Alternatively it can be defined using 'between2l':
--
-- @
-- 'between3l' f g = 'between2l' f g '~@~' g
-- @
between3l :: (c -> d) -> (a -> b) -> (b -> b -> b -> c) -> a -> a -> a -> d
between3l f g = ((f `between` g) `between` g) `between` g

-- | Convenience wrapper for:
--
-- @
-- \\f g -> 'fmap' f '~@~' 'fmap' g
-- @
--
-- Name of '<~@~>' simply says that we apply 'Data.Functor.<$>' ('fmap') to
-- both its arguments and then we apply '~@~'.
--
-- Fixity is left associative and set to value 8, which is one less then
-- of function composition ('.').
(<~@~>)
    :: (Functor f, Functor g)
    => (c -> d) -> (a -> b) -> (f b -> g c) -> f a -> g d
f <~@~> g = fmap f `between` fmap g
infix 8 <~@~>

-- | Flipped variant of '<~@~>'.
--
-- Name of '<~@@~>' simply says that we apply 'Data.Functor.<$>' ('fmap') to
-- both its arguments and then we apply '~@@~'.
--
-- Fixity is set to value 8, which is one less then of function composition
-- ('.').
(<~@@~>)
    :: (Functor f, Functor g)
    => (a -> b) -> (c -> d) -> (f b -> g c) -> f a -> g d
g <~@@~> f = fmap f `between` fmap g
infix 8 <~@@~>

-- | Apply fmap to first argument of '~@~'. Dual to '~@~>' which applies
-- 'fmap' to second argument.
--
-- Defined as:
--
-- @
-- f '<~@~' g = 'fmap' f '~@~' g
-- @
--
-- This function allows us to define lenses mostly for pair of functions that
-- form an isomorphism. See section <#g:3 Constructing Lenses> for details.
--
-- Name of '<~@~' simply says that we apply 'Data.Functor.<$>' ('fmap') to
-- first (left) argument and then we apply '~@~'.
--
-- Fixity is left associative and set to value 8, which is one less then
-- of function composition ('.').
(<~@~) :: Functor f => (c -> d) -> (a -> b) -> (b -> f c) -> a -> f d
(<~@~) = between . fmap
infixl 8 <~@~

-- | Flipped variant of '<~@~'.
--
-- This function allows us to define lenses mostly for pair of functions that
-- form an isomorphism. See section <#g:3 Constructing Lenses> for details.
--
-- Name of '~@@~>' simply says that we apply 'Data.Functor.<$>' ('fmap') to
-- second (right) argument and then we apply '~@@~'.
--
-- Fixity is right associative and set to value 8, which is one less then
-- fixity of function composition ('.').
(~@@~>) :: Functor f => (a -> b) -> (c -> d) -> (b -> f c) -> a -> f d
(~@@~>) = flip (<~@~)
infixr 8 ~@@~>

-- | Apply fmap to second argument of '~@~'. Dual to '<~@~' which applies
-- 'fmap' to first argument.
--
-- Defined as:
--
-- @
-- f '~@~>' g -> f '~@~' 'fmap' g
-- @
--
-- Name of '~@~>' simply says that we apply 'Data.Functor.<$>' ('fmap') to
-- second (right) argument and then we apply '~@~'.
--
-- Fixity is right associative and set to value 8, which is one less then
-- of function composition ('.').
(~@~>) :: Functor f => (c -> d) -> (a -> b) -> (f b -> c) -> f a -> d
(~@~>) f = between f . fmap
infixl 8 ~@~>

-- | Flipped variant of '~@~>'.
--
-- Name of '<~@@~' simply says that we apply 'Data.Functor.<$>' ('fmap') to
-- first (left) argument and then we apply '~@@~'.
--
-- Fixity is left associative and set to value 8, which is one less then
-- fixity of function composition ('.').
(<~@@~) :: Functor f => (a -> b) -> (c -> d) -> (f b -> c) -> f a -> d
(<~@@~) = flip (~@~>)
infixr 8 <~@@~

-- | Convenience wrapper for: @\\f g -> 'fmap' . f '^@~' g@.
--
-- This function has the same functionality as function
--
-- @
-- lens :: (s -> a) -> (s -> b -> t) -> Lens s t a b
-- @
--
-- Which is defined in <http://hackage.haskell.org/package/lens lens package>.
-- Only difference is that arguments of '<^@~' are flipped. See also section
-- <#g:3 Constructing Lenses>.
--
-- Name of '<^@~' simply says that we apply 'Data.Functor.<$>' ('fmap') to
-- first (left) arguments and then we apply '^@~'.
--
-- Fixity is left associative and set to value 8, which is one less then
-- of function composition ('.').
(<^@~)
    :: Functor f
    => (a -> c -> d) -> (a -> b) -> (b -> f c) -> a -> f d
(<^@~) f = (fmap . f ^@~)
infixl 8 <^@~

-- | Flipped variant of '~@^>'.
--
-- This function has the same functionality as function
--
-- @
-- lens :: (s -> a) -> (s -> b -> t) -> Lens s t a b
-- @
--
-- Which is defined in <http://hackage.haskell.org/package/lens lens package>.
-- See also section <#g:3 Constructing Lenses>.
--
-- Name of '~@^>' simply says that we apply 'Data.Functor.<$>' ('fmap') to
-- second (right) arguments and then we apply '~@^>'.
--
-- Fixity is left associative and set to value 8, which is one less then
-- of function composition ('.').
(~@@^>)
    :: Functor f
    => (a -> b) -> (a -> c -> d) -> (b -> f c) -> a -> f d
(~@@^>) = flip (<^@~)
infixl 8 ~@@^>

-- | Convenience wrapper for: @\\f g -> 'fmap' . f '^@^' 'fmap' . g@.
--
-- Name of '<^@^>' simply says that we apply 'Data.Functor.<$>' ('fmap') to
-- both its arguments and then we apply '^@^'.
--
-- Fixity is left associative and set to value 8, which is one less then
-- of function composition ('.').
(<^@^>)
    :: (Functor f, Functor g)
    => (a -> d -> e) -> (a -> b -> c) -> (f c -> g d) -> a -> f b -> g e
(f <^@^> g) h a = (fmap (f a) `between` fmap (g a)) h
infix 8 <^@^>

-- | Flipped variant of '<^@^>'.
--
-- Name of '<^@@^>' simply says that we apply 'Data.Functor.<$>' ('fmap') to
-- both its arguments and then we apply '^@@^'.
--
-- Fixity is set to value 8, which is one less then of function composition
-- ('.').
(<^@@^>)
    :: (Functor f, Functor g)
    => (a -> b -> c) -> (a -> d -> e) -> (f c -> g d) -> a -> f b -> g e
(<^@@^>) = flip (<^@^>)
infix 8 <^@@^>

-- | Convenience wrapper for: @\\f g -> 'fmap' . f '^@^' g@.
--
-- This function allows us to define generic lenses from gettern and setter.
-- See section <#g:3 Constructing Lenses> for details.
--
-- Name of '<^@^' simply says that we apply 'Data.Functor.<$>' ('fmap') to
-- first (left) arguments and then we apply '^@^'.
--
-- Fixity is left associative and set to value 8, which is one less then
-- of function composition ('.').
(<^@^)
    :: Functor f
    => (a -> d -> e) -> (a -> b -> c) -> (c -> f d) -> a -> b -> f e
(f <^@^ g) h a = (fmap (f a) `between` g a) h
infix 8 <^@^

-- | Flipped variant of '<^@^'.
--
-- This function allows us to define generic lenses from gettern and setter.
-- See section <#g:3 Constructing Lenses> for details.
--
-- Name of '^@@^>' simply says that we apply 'Data.Functor.<$>' ('fmap') to
-- second (right) arguments and then we apply '^@@^'.
--
-- Fixity is set to value 8, which is one less then of function composition
-- ('.').
(^@@^>)
    :: Functor f
    => (a -> b -> c) -> (a -> d -> e) -> (c -> f d) -> a -> b -> f e
(^@@^>) = flip (<^@^)
infix 8 ^@@^>

-- | Convenience wrapper for: @\\f g -> f '^@^' 'fmap' . g@.
--
-- Name of '^@^>' simply says that we apply 'Data.Functor.<$>' ('fmap') to
-- second (right) arguments and then we apply '^@^'.
--
-- Fixity is left associative and set to value 8, which is one less then
-- of function composition ('.').
(^@^>)
    :: Functor f
    => (a -> d -> e) -> (a -> b -> c) -> (f c -> d) -> a -> f b -> e
(f ^@^> g) h a = (f a `between` fmap (g a)) h
infix 8 ^@^>

-- | Flipped variant of '^@^>'.
--
-- Name of '<^@@^' simply says that we apply 'Data.Functor.<$>' ('fmap') to
-- first (left) arguments and then we apply '^@@^'.
--
-- Fixity is set to value 8, which is one less then of function composition
-- ('.').
(<^@@^)
    :: Functor f
    => (a -> b -> c) -> (a -> d -> e) -> (f c -> d) -> a -> f b -> e
(<^@@^) = flip (^@^>)
infix 8 <^@@^

-- {{{ In-Between Function Application Combinator -----------------------------

-- | Prefix version of common pattern:
--
-- @
-- \\f -> a \`f\` b
-- @
--
-- Where @a@ and @b@ are fixed parameters. There is also infix version named
-- '~$~'. This function is defined as:
--
-- @
-- 'inbetween' a b f = f a b
-- @
--
-- Based on the above definition one can think of it as a variant function
-- application that deals with two arguments, where in example
-- 'Data.Function.$' only deals with one.
--
-- /Since version 0.11.0.0./
inbetween :: a -> b -> (a -> b -> r) -> r
inbetween a b f = f a b
infix 8 `inbetween`

-- | Infix version of common pattern:
--
-- @
-- \\f -> a \`f\` b
-- @
--
-- Where @a@ and @b@ are fixed parameters. There is also prefix version named
-- 'inbetween'.
--
-- /Since version 0.11.0.0./
(~$~) :: a -> b -> (a -> b -> r) -> r
(~$~) = inbetween
infix 8 ~$~

-- | Infix version of common pattern:
--
-- @
-- \\f -> a \`f\` b     -- Notice the order of \'a\' and \'b\'.
-- @
--
-- /Since version 0.11.0.0./
(~$$~) :: b -> a -> (a -> b -> r) -> r
(b ~$$~ a) f = f a b
infix 8 ~$$~

-- | Construct a function that encodes idiom:
--
-- @
-- \\f -> a \`f\` b     -- Notice the order of \'b\' and \'a\'.
-- @
--
-- Function 'inbetween' can be redefined in terms of 'withIn' as:
--
-- @
-- a ``inbetween`` b = 'withIn' 'Data.Function.$' \\f -> a \`f\` b
-- @
--
-- On one hand you can think of this function as a specialized 'id' function
-- and on the other as a function application 'Data.Function.$'. All the
-- following definitions work:
--
-- @
-- 'withIn' f g = f g
-- 'withIn' = 'id'
-- 'withIn' = ('Data.Function.$')
-- @
--
-- Usage examples:
--
-- @
-- newtype Foo a = Foo a
--
-- inFoo :: ((a -> Foo a) -> (Foo t -> t) -> r) -> r
-- inFoo = 'withIn' '$' \\f ->
--     Foo \`f\` \\(Foo a) -> Foo
-- @
--
-- @
-- data Coords2D = Coords2D {_x :: Int, _y :: Int}
--
-- inX :: ((Int -> Coords2D -> Coords2D) -> (Coords2D -> Int) -> r) -> r
-- inX = 'withIn' '$' \\f ->
--     (\\b s -> s{_x = b}) \`f\` _x
-- @
--
-- /Since version 0.11.0.0./
withIn :: ((a -> b -> r) -> r) -> (a -> b -> r) -> r
withIn = id

-- | Construct a function that encodes idiom:
--
-- @
-- \\f -> b \`f\` a     -- Notice the order of \'b\' and \'a\'.
-- @
--
-- Function '~$$~' can be redefined in terms of 'withReIn' as:
--
-- @
-- b '~$$~' a = 'withReIn' '$' \\f -> b \`f\` a
-- @
--
-- As 'withIn', but the function is flipped before applied. All of the
-- following definitions work:
--
-- @
-- 'withReIn' f g = f ('flip' g)
-- 'withReIn' = ('.' 'flip')
-- @
--
-- Usage examples:
--
-- @
-- newtype Foo a = Foo a
--
-- inFoo :: ((a -> Foo a) -> (Foo t -> t) -> r) -> r
-- inFoo = 'withReIn' '$' \\f ->
--     (\\(Foo a) -> Foo) \`f\` Foo
-- @
--
-- @
-- data Coords2D = Coords2D {_x :: Int, _y :: Int}
--
-- inX :: ((Int -> Coords2D -> Coords2D) -> (Coords2D -> Int) -> r) -> r
-- inX = 'withReIn' '$' \\f ->
--     _x \`f\` \\b s -> s{_x = b}
-- @
--
-- /Since version 0.11.0.0./
withReIn :: ((b -> a -> r) -> r) -> (a -> b -> r) -> r
withReIn = (. flip)

-- }}} In-Between Function Application Combinator -----------------------------

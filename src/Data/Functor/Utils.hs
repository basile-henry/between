{-# LANGUAGE CPP #-}
-- |
-- Module      :  $HEADER$
-- Description :  Utility functions for Functors
-- Copyright   :  (c) 2011, 2013 Peter Trsko
-- License     :  BSD3
--
-- Maintainer  :  peter.trsko@gmail.com
-- Stability   :  provisional
-- Portability :  non-portable (CPP)
--
-- Utility functions for Functors.
module Data.Functor.Utils
    (
#if !MIN_VERSION_base(4,2,0)
      Functor(..)
    , (<$>)
#else
      (<$>)
    , (<$)
#endif
    , (<$$>)
    , ($>)

    , (<#>)
    , (<##>)
    )
    where

-- Module Data.Functor was introduced in base 4.2.0.0.
#if MIN_VERSION_base(4,2,0)
import Data.Functor (Functor(..), (<$>))
#else
import Control.Applicative ((<$), (<$>))
#endif


-- | Flipped version of '<$>', the naming convention comes from
-- "Control.Applicative" where '<**>' is flipped version of '<*>'.
(<$$>) :: (Functor f) => f a -> (a -> b) -> f b
(<$$>) = flip fmap
infixl 4 <$$>
{-# INLINE (<$$>) #-}

-- | Flipped version of '<$'.
($>) :: Functor f => f a -> b -> f b
($>) = flip (<$)
infixl 4 $>
{-# INLINE ($>) #-}

-- | Like @\\ x f -> f '<*>' 'pure' x@, but does not have 'Applicative'
-- constraint. Flipped version of '<#>'.
--
-- Implemented as: @x '<##>' f = ('$' x) '<$>' f@.
(<##>) :: (Functor f) => a -> f (a -> b) -> f b
x <##> f = ($ x) `fmap` f
infixl 4 <##>
{-# INLINE (<##>) #-}

-- | Like @\\ f x -> f '<*>' 'pure' x@, but does not have 'Applicative'
-- constraint.
--
-- Implemented as: @f '<#>' x = ('$' x) '<$>' f@.
--
-- Example:
--
-- >>> Just (+1) <#> 2
-- 3
--
-- For @instance 'Functor' ((->) r)@ this function behaves as 'flip':
--
-- >>> (-) <#> 1 $ 2
-- 1
(<#>) :: (Functor f) => f (a -> b) -> a -> f b
f <#> x = ($ x) `fmap` f
infixl 4 <#>
{-# INLINE (<#>) #-}

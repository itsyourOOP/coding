{-
  This program and its output are public domain.
-}

{-# LANGUAGE ExtendedDefaultRules #-}

module Main where {
  import Prelude ();
  import Prelude.Generalize;

  default (Int, Integer);

  main :: IO ();
  main = putStrLn (
   "const byte unmingle[256] = {" ++ tail (init $ show unmingleTable) ++ "};" ++
   "const byte reverse[256] = {" ++ tail (init $ show reverseTable) ++ "};" );

  zeros128X :: [Int];
  zeros128X = replicate 128 0;

  unmingleTable :: [Int];
  unmingleTable = zipWith (+) (halfUnmingleTable ++ zeros128X) (interleave halfUnmingleTable zeros128X);

  halfUnmingleTable :: [Int];
  halfUnmingleTable = 0 : (zipWith (*) <*> cumSum) (fromEnum . ap (==) (0x55 .&.) <$> [1..127]);

  cumSum :: [Int] -> [Int];
  cumSum [] = [];
  cumSum (h : t) = h : ((h +) <$> cumSum t);

  reverseTable :: [Int];
  reverseTable = sum . (<$> [0..7]) . reverseBit <$> [0..255];

  reverseBit :: Int -> Int -> Int;
  reverseBit x y = fromEnum (testBit x y) * shiftR 128 y;
}

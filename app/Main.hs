{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE TypeOperators #-}

import Data.Array.Accelerate as A
import Data.Array.Accelerate.LLVM.Native as CPU
import Data.Array.Accelerate.LLVM.PTX as GPU

dotp :: (A.Num e, Elt e) => Acc (Vector e) -> Acc (Vector e) -> Acc (Scalar e)
dotp xs ys = A.fold (+) 0 $ A.zipWith (*) xs ys

matmul :: (A.Num e, Elt e) => Acc (Matrix e) -> Acc (Matrix e) -> Acc (Matrix e)
matmul a b =
  let b' = A.transpose b
      Z :. rowsA :. _ = unlift (shape a) :: Z :. Exp Int :. Exp Int
      Z :. _ :. colsB = unlift (shape b) :: Z :. Exp Int :. Exp Int
      aRepl = A.replicate (lift $ Z :. All :. colsB :. All) a
      bRepl = A.replicate (lift $ Z :. rowsA :. All :. All) b'
   in A.fold (+) 0 $ A.zipWith (*) aRepl bRepl

main :: IO ()
main =
  let xs = fromList (Z :. 3 :. 3) [0 ..] :: Matrix Float
      ys = fromList (Z :. 3 :. 3) [1, 3 ..] :: Matrix Float
   in do
        print xs
        print ys
        print $ GPU.run $ matmul (use xs) (use ys)
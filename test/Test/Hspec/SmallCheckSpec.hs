{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE CPP #-}
module Test.Hspec.SmallCheckSpec (main, spec) where

import           Test.Hspec

import           Test.Hspec.SmallCheck ()
import qualified Test.Hspec.Core.Spec as H
import qualified Test.Hspec.Runner as H
import           Test.SmallCheck
import           Test.SmallCheck.Drivers
import           Test.QuickCheck (stdArgs)

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
  describe "evaluateExample" $ do
    context "Property IO" $ do
      it "returns Success if property holds" $ do
        evaluateExample (test True :: Property IO) `shouldReturn` H.Success

      it "returns Fail if property does not hold" $ do
#if MIN_VERSION_hspec_core(2,4,0)
        evaluateExample (test False :: Property IO) `shouldReturn` H.Failure Nothing (H.Reason "condition is false")
#elif MIN_VERSION_hspec_core(2,2,0)
        evaluateExample (test False :: Property IO) `shouldReturn` H.Fail Nothing "condition is false"
#else
        evaluateExample (test False :: Property IO) `shouldReturn` H.Fail "condition is false"
#endif

      it "shows what falsified it" $ do

#if MIN_VERSION_hspec_core(2,4,0)
        evaluateExample (test (/= (2 :: Int)) :: Property IO) `shouldReturn` H.Failure Nothing (H.Reason "there exists 2 such that\n  condition is false")
#elif MIN_VERSION_hspec_core(2,2,0)
        evaluateExample (test (/= (2 :: Int)) :: Property IO) `shouldReturn` H.Fail Nothing "there exists 2 such that\n  condition is false"
#else
        evaluateExample (test (/= (2 :: Int)) :: Property IO) `shouldReturn` H.Fail "there exists 2 such that\n  condition is false"
#endif

      it "propagates exceptions" $ do
        evaluateExample (error "foobar" :: Property IO) `shouldThrow` errorCall "foobar"
  where

    evaluateExample :: (Example a, Arg a ~ ()) => a -> IO H.Result
    evaluateExample e = H.evaluateExample e defaultParams ($ ()) (const $ return ())

    defaultParams :: H.Params
    defaultParams = H.Params stdArgs (H.configSmallCheckDepth H.defaultConfig)

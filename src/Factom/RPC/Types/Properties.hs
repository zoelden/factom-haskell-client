{-# LANGUAGE DeriveGeneric       #-}
{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE RecordWildCards     #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell     #-}
{-# LANGUAGE TypeOperators       #-}

module  Factom.RPC.Types.Properties where

import           Control.Applicative
import           Control.Monad                   (forM_, join, mzero)
import           Data.Aeson                      (FromJSON (..), ToJSON (..),
                                                  Value (..), decode, object,
                                                  pairs, (.:), (.:?), (.=))
import           Data.Aeson.AutoType.Alternative
import qualified Data.ByteString.Lazy.Char8      as BSL
import           Data.Monoid
import           Data.Text                       (Text)
import qualified GHC.Generics
import           System.Environment              (getArgs)
import           System.Exit                     (exitFailure, exitSuccess)
import           System.IO                       (hPutStrLn, stderr)
--------------------------------------------------------------------------------
-- | Workaround for https://github.com/bos/aeson/issues/287.
o .:?? val = fmap join (o .:? val)


data TopLevel = TopLevel {
    topLevelWalletversion    :: Text,
    topLevelWalletapiversion :: Text
  } deriving (Show,Eq,GHC.Generics.Generic)


instance FromJSON TopLevel where
  parseJSON (Object v) =
    TopLevel <$> v .: "walletversion" <*> v .: "walletapiversion"
  parseJSON _ = mzero


instance ToJSON TopLevel where
  toJSON (TopLevel {..}) = object
    [ "walletversion" .= topLevelWalletversion
    , "walletapiversion" .= topLevelWalletapiversion
    ]
  toEncoding (TopLevel {..}) = pairs
    (  "walletversion"
    .= topLevelWalletversion
    <> "walletapiversion"
    .= topLevelWalletapiversion
    )

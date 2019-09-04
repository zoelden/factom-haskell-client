{-# LANGUAGE DataKinds                  #-}
{-# LANGUAGE DeriveGeneric              #-}
{-# LANGUAGE FlexibleInstances          #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE OverloadedStrings          #-}
{-# LANGUAGE ScopedTypeVariables        #-}
{-# LANGUAGE TemplateHaskell            #-}
{-# LANGUAGE TypeFamilies               #-}
{-# LANGUAGE TypeOperators              #-}

module Factom.Api where

import           Control.Applicative
import           Control.Monad
import           Control.Monad.IO.Class
import           Data.Aeson
import qualified Data.ByteString.Char8      as B
import qualified Data.ByteString.Lazy.Char8 as BL
import           Data.Monoid
import           Data.Proxy
import qualified Data.Text                  as T
import           Data.Time
import           Data.Time.Clock.POSIX
import           GHC.Generics
import           Network.HTTP.Client        (Manager, newManager)
import qualified Network.HTTP.Client        as C
import           Network.HTTP.Client.TLS    (tlsManagerSettings)
import           Network.HTTP.Conduit       (simpleHttp)
import qualified Network.HTTP.Simple        as S
import           Servant.API
import           Servant.Client

import           Factom.Types
import           Factom.Utils

--------------------------------------------------------------------------------

endpoint = "http://localhost:8088/v2"

type FactomAPI =

  -- POST /entry
       "entry"
    :> Post '[JSON] [ApiResponse Entry]

  -- POST /entry-ack
  :<|> "entry-block"
    :> Post '[JSON] [ApiResponse EntryBlock]

  -- POST /entry-credit-balance
  :<|> "entry-credit-balance"
    :> Post '[JSON] [ApiResponse EntryCreditBalance]

factomAPI :: Proxy FactomAPI
factomAPI = Proxy

-- Derive call functions for the api
getEntry     :: ClientM [CurrencyPair]
getPersonalInfo      :: Maybe T.Text -> ClientM User
getPersonalStatement :: Maybe T.Text -> T.Text -> T.Text -> T.Text -> ClientM Statement
(     getEntry
 :<|> getEntryBlock
 :<|> getEntryCreditBalance ) = client factomAPI

--------------------------------------------------------------------------------

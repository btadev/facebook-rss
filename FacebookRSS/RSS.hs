module FacebookRSS.RSS (fromFeed, autoLinks) where


import Text.RSS
import Data.Time
import Data.Time.Format (parseTime, defaultTimeLocale)
import Data.Maybe (maybe, fromJust)
import FacebookRSS.Facebook
import Data.List (head)
import Data.List.Split (splitOn)
import Network.URI (parseURI)
import Data.Facebook.Post as Post
import Data.Facebook.Feed as Feed
import Text.AutoLinks


fromFeed :: Feed -> String
fromFeed = showXML . rssToXML . feedToRSS


feedToRSS :: Feed -> RSS
feedToRSS feed =
    RSS
      (Feed.name feed)
      (fromJust . parseURI $ Feed.link feed)
      (Feed.about feed)
      []
      $ map postToRssArticle (Feed.posts feed)
        where
          getFirstLine [] = ""
          getFirstLine x = head . splitOn "\n" $ x
          defaultDate = (read "1970-01-01 00:00:00.000000 UTC")::UTCTime
          parseDate = maybe defaultDate Prelude.id . parseTime defaultTimeLocale "%FT%T%z"
          postToRssArticle post =
            [ Title . getFirstLine . Post.message $ post
            , Link . fromJust . parseURI . Post.link $ post
            , Description . autoLinks . Post.message $ post
            , Guid False . Post.id $ post
            , PubDate . parseDate . Post.createdTime $ post
            ]

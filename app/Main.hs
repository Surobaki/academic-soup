-- {-# LANGUAGE NamedFieldPuns        #-}
{-# LANGUAGE DeriveGeneric         #-}
{-# LANGUAGE DeriveAnyClass        #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE DuplicateRecordFields #-}

module Main where

import           Control.Lens
import           Control.Monad
import           Data.Aeson                 as A
import           Data.Aeson.Lens
import           Data.Time
import           Development.Shake
import           Development.Shake.Classes
import           Development.Shake.Forward
import           Development.Shake.FilePath
import           GHC.Generics               (Generic)
import           Slick

import qualified Data.HashMap.Lazy as HML
import qualified Data.Text                  as T

---Config-----------------------------------------------------------------------

siteMeta :: SiteMeta
siteMeta =
    SiteMeta { siteAuthor = "Olivia Weston"
             , baseUrl = "https://academic-soup.web.app/"
             , siteTitle = "Olivia Weston, academic soup"
             , twitterHandle = Just "suro_baki"
             , githubUser = Just "Surobaki"
             , email = Just "o.weston+acsoup@pm.me"
             , linkedinUser = Just "olivia-h-weston"
             }

outputFolder :: FilePath
outputFolder = "docs/"

--Data models-------------------------------------------------------------------

withSiteMeta :: Value -> Value
withSiteMeta (Object obj) = Object $ HML.union obj siteMetaObj
  where
    Object siteMetaObj = toJSON siteMeta
withSiteMeta _ = error "only add site meta to objects"

data SiteMeta =
    SiteMeta { siteAuthor    :: String
             , baseUrl       :: String -- e.g. https://example.ca
             , siteTitle     :: String
             , twitterHandle :: Maybe String -- Without @
             , githubUser    :: Maybe String
             , email         :: Maybe String
             , linkedinUser  :: Maybe String
             }
    deriving (Generic, Eq, Ord, Show, ToJSON)

-- | Data for the index page
newtype IndexInfo =
  IndexInfo
    { posts :: [Post]
    } deriving (Generic, Show, FromJSON, ToJSON)

type Tag = String

-- | Data for a blog post
data Post =
    Post { title       :: String
         , author      :: String
         , content     :: String
         , url         :: String
         , date        :: String
         , tags        :: [Tag]
         , description :: String
         , image       :: Maybe String
         , altText     :: Maybe String
        }
    deriving (Generic, Eq, Ord, Show, FromJSON, ToJSON, Binary)

data AtomData =
  AtomData { title        :: String
           , domain       :: String
           , author       :: String
           , posts        :: [Post]
           , currentTime  :: String
           , atomUrl      :: String 
        } 
    deriving (Generic, ToJSON, Eq, Ord, Show)

-- | Builds index.html with siteMeta included
buildIndex :: Action ()
buildIndex = do
  indexT <- compileTemplate' "site/templates/index.html"
  let indexHTML = T.unpack $ substitute indexT (toJSON siteMeta)
  writeFile' (outputFolder </> "index.html") indexHTML

buildProjectIndex :: [Post] -> Action ()
buildProjectIndex projects' = do
  indexT <- compileTemplate' "site/templates/projects.html"
  let indexInfo = IndexInfo {posts = projects'}
      indexHTML = T.unpack $ substitute indexT (withSiteMeta $ toJSON indexInfo)
  writeFile' (outputFolder </> "projects.html") indexHTML

buildPostsIndex :: [Post] -> Action ()
buildPostsIndex posts' = do
  indexT <- compileTemplate' "site/templates/blog.html"
  let indexInfo = IndexInfo {posts = posts'}
      indexHTML = T.unpack $ substitute indexT (withSiteMeta $ toJSON indexInfo)
  writeFile' (outputFolder </> "blog.html") indexHTML

-- | Find and build all posts
buildPosts :: Action [Post]
buildPosts = do
  pPaths <- getDirectoryFiles "." ["site/posts//*.md"]
  forP pPaths buildPost

-- | Find and build all projects
buildProjects :: Action [Post]
buildProjects = do
  pPaths <- getDirectoryFiles "." ["/site/projects//*.md"]
  forP pPaths buildProject

-- | Load a post, process metadata, write it to output, then return the post object
-- Detects changes to either post content or template
buildPost :: FilePath -> Action Post
buildPost srcPath = cacheAction ("build" :: T.Text, srcPath) $ do
  liftIO . putStrLn $ "Rebuilding post: " <> srcPath
  postContent <- readFile' srcPath
  -- load post content and metadata as JSON blob
  postData <- markdownToHTML . T.pack $ postContent
  let postUrl = T.pack . dropDirectory1 $ srcPath -<.> "html"
      withPostUrl = _Object . at "url" ?~ String postUrl
  -- Add additional metadata we've been able to compute
  let fullPostData = withSiteMeta . withPostUrl $ postData
  template <- compileTemplate' "site/templates/post-boiler.html"
  writeFile' (outputFolder </> T.unpack postUrl) . T.unpack $ substitute template fullPostData
  convert fullPostData

-- | Load a project, process metadata, write it to output, 
-- then return the project object
-- Detects changes to either post content or template
buildProject :: FilePath -> Action Post
buildProject srcPath = cacheAction ("build" :: T.Text, srcPath) $ do
  liftIO . putStrLn $ "Rebuilding project: " <> srcPath
  projContent <- readFile' srcPath
  -- load project content and metadata as JSON blob
  projData <- markdownToHTML . T.pack $ projContent
  let projUrl = T.pack . dropDirectory1 $ srcPath -<.> "html"
      withProjUrl = _Object . at "url" ?~ String projUrl
  -- Add additional metadata we've been able to compute
  let fullProjData = withSiteMeta . withProjUrl $ projData
  template <- compileTemplate' "site/templates/project-boiler.html"
  writeFile' (outputFolder </> T.unpack projUrl) . T.unpack $ substitute template fullProjData
  convert fullProjData

-- | Copy all static files from the listed folders to their destination
copyStaticFiles :: Action ()
copyStaticFiles = do
    filepaths <- getDirectoryFiles "./site/" ["images//*", "css//*", "js//*", "*.asc", "*.pdf"]
    void $ forP filepaths $ \filepath ->
        copyFileChanged ("site" </> filepath) (outputFolder </> filepath)

formatDate :: String -> String
formatDate humanDate = toIsoDate parsedTime
  where
    parsedTime =
      parseTimeOrError True defaultTimeLocale "%b %e, %Y" humanDate :: UTCTime

rfc3339 :: Maybe String
rfc3339 = Just "%H:%M:SZ"

toIsoDate :: UTCTime -> String
toIsoDate = formatTime defaultTimeLocale (iso8601DateFormat rfc3339)

buildFeed :: [Post] -> Action ()
buildFeed posts' = do
  now <- liftIO getCurrentTime
  let atomData =
        AtomData
          { title = siteTitle siteMeta
          , domain = baseUrl siteMeta
          , author = siteAuthor siteMeta
          , posts = mkAtomPost <$> posts'
          , currentTime = toIsoDate now
          , atomUrl = "/atom.xml"
          }
  atomTempl <- compileTemplate' "site/templates/atom.xml"
  writeFile' (outputFolder </> "atom.xml") . T.unpack $ substitute atomTempl (toJSON atomData)
    where
      mkAtomPost :: Post -> Post
      mkAtomPost p = p { date = formatDate $ date p }

-- | Specific build rules for the Shake system
--   defines workflow to build the website
buildRules :: Action ()
buildRules = do
  allPosts <- buildPosts
  allProjects <- buildProjects
  buildIndex
  buildProjectIndex allProjects
  buildPostsIndex allPosts
  buildFeed allPosts
  copyStaticFiles

main :: IO ()
main = do
  let shOpts = shakeOptions { shakeVerbosity = Chatty, shakeLintInside = ["\\"]}
  shakeArgsForward shOpts buildRules

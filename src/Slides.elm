module Slides exposing (parse)

import Array exposing (Array, empty, push)
import Html exposing (Html)
import Markdown exposing (defaultOptions, toHtmlWith)
import Regex exposing (HowMany(All), regex, split)
import String exposing (dropLeft, indexes, left)


toHtml : String -> Html msg
toHtml s =
    toHtmlWith
        { defaultOptions
            | githubFlavored = Just { tables = True, breaks = False }
            , sanitize = True
        }
        []
        s


dropLeadingHtmlTags : Int -> String -> String
dropLeadingHtmlTags start slides =
    dropLeft start slides


parse : String -> Array (Html msg)
parse raw =
    case indexes "# " raw of
        [] ->
            empty

        hd :: _ ->
            let
                slides =
                    dropLeadingHtmlTags hd raw
            in
                split All (regex "(?:^|\n\n)#\\s") slides
                    |> List.filter (not << String.isEmpty)
                    |> List.map ((++) "# ")
                    |> List.map toHtml
                    |> Array.fromList

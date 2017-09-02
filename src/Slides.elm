module Slides exposing (parse)

import Array exposing (Array, empty, push)
import Html exposing (Html)
import Markdown exposing (defaultOptions, toHtmlWith)
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


rparse : String -> Array (Html msg) -> Array (Html msg)
rparse slides acc =
    case indexes "# " slides of
        [] ->
            push (toHtml slides) acc

        _ :: [] ->
            push (toHtml slides) acc

        _ :: next :: _ ->
            let
                slide =
                    left next slides |> toHtml

                remaining =
                    dropLeft next slides
            in
            rparse
                remaining
                (push slide acc)


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
            rparse
                slides
                empty

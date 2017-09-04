module Main exposing (..)

import Array exposing (Array, fromList, map)
import Css
import Html exposing (Html, button, div, span, text)
import Html.Attributes exposing (class, disabled, style)
import Html.Events exposing (onClick)
import Http exposing (getString)
import Markdown
import Maybe exposing (Maybe, withDefault)
import Slides


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


type alias Model =
    { slides : Array (Html Msg)
    , index : Int
    }


type Msg
    = SlidesNotFound
    | GotSlides (Array (Html Msg))
    | PreviousSlide
    | NextSlide


init : ( Model, Cmd Msg )
init =
    ( Model Array.empty 0, getSlides )


getSlides : Cmd Msg
getSlides =
    Http.send
        (\r ->
            case r of
                Result.Err _ ->
                    SlidesNotFound

                Result.Ok s ->
                    GotSlides <| Slides.parse s
        )
        (Http.getString "/slides.md")


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SlidesNotFound ->
            ( model, Cmd.none )

        GotSlides slides ->
            ( { model | slides = slides }, Cmd.none )

        PreviousSlide ->
            ( { model | index = model.index - 1 }, Cmd.none )

        NextSlide ->
            ( { model | index = model.index + 1 }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


renderControls : Model -> Html Msg
renderControls model =
    div [ class "row controls" ]
        [ div
            [ class "col-md-offset-10" ]
            [ div [ class "pull-right" ]
                [ button
                    [ onClick PreviousSlide
                    , class "btn btn-default glyphicon glyphicon-triangle-left"
                    , disabled (model.index == 0)
                    ]
                    []
                , span [] [ text " " ]
                , button
                    [ onClick NextSlide
                    , class "btn btn-default glyphicon glyphicon-triangle-right"
                    , disabled (model.index == (Array.length model.slides - 1))
                    ]
                    []
                ]
            ]
        ]


renderSlide : Model -> Html Msg
renderSlide model =
    div [ class "row slide" ]
        [ div [ class "row top" ] []
        , div [ class "row" ]
            [ div
                [ class "col-md-offset-1 col-md-11" ]
                [ Maybe.withDefault
                    (Markdown.toHtml [] "# Slide not found")
                    (Array.get
                        model.index
                        model.slides
                    )
                ]
            ]
        ]


view : Model -> Html Msg
view model =
    let
        imports =
            [ "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css"
            , "assets/main.css"
            ]

        stylesheet =
            Css.stylesheet imports []
    in
        div
            [ class "container-fluid"
            , style [ ( "height", "100%" ) ]
            ]
            [ Css.style [ Html.Attributes.scoped True ] stylesheet
            , renderSlide model
            , renderControls model
            ]

import Array exposing (Array, fromList, map)
import Html exposing (Html, button, div, text)
import Html.App as App
import Html.Attributes exposing (disabled, id, style)
import Html.Events exposing (onClick)
import Markdown
import Maybe exposing (Maybe, withDefault)

import Slides

main =
  App.beginnerProgram {
    model = init,
    update = update,
    view = view
  }

type alias Model = {
  slides : Array(Html Msg),
  index : Int
}

type Msg = Previous | Next

init : Model
init = Model (toHtml Slides.all) 0

toHtml : List String -> Array (Html Msg)
toHtml slides =
  Array.map
    (\s -> Markdown.toHtml [] s)
    (Array.fromList slides)

renderSlide : Model -> Html Msg
renderSlide model =
  Maybe.withDefault
    (Markdown.toHtml [] "# Slide not found")
    (Array.get
      model.index
      model.slides)

update : Msg -> Model -> Model
update msg model =
  case msg of
    Previous ->
      { model | index = model.index - 1 }
    Next ->
      { model | index = model.index + 1 }

prevButton model =
  button
    [ onClick Previous,
      disabled (model.index == 0) ]
    [ text "<" ]

nextButton model =
  button
    [ onClick Next,
      disabled (model.index == (Array.length model.slides - 1)) ]
    [ text ">" ]

view : Model -> Html Msg
view model =
  div
    [ style [
      ("width", "100%"),
      ("height", "100%"),
      ("position", "relative") ] ]
    [ div [ id "left", style [
        ("width", "20%"),
        ("height", "100%"),
        ("top", "0px"),
        ("left", "0px"),
        ("position", "absolute") ] ] [],
      div
        [ id "content", style [
          ("width", "60%"),
          ("height", "100%"),
          ("top", "0px"),
          ("left", "20%"),
          ("position", "absolute"),
          ("text-align", "center") ] ]
        [ div
            [ id "slide", style [
              ("float", "left"),
              ("width", "100%"),
              ("height", "80%") ] ]
            [ renderSlide model ],
          div
            [ id "buttons", style [("clear", "both") ] ]
            [ prevButton model, nextButton model ]
        ],
      div [ id "right", style [
        ("width", "20%"),
        ("height", "100%"),
        ("top", "0px"),
        ("right", "0px"),
        ("position", "absolute") ] ] []
    ]

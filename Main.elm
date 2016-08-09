import Array exposing (Array, fromList, map)
import Html exposing (Html, button, div, text)
import Html.App as App
import Html.Attributes exposing (disabled, id, style)
import Html.Events exposing (onClick)
import Markdown
import Maybe exposing (Maybe, withDefault)
import Task
import Window

import Slides

main =
  App.program {
    init = init,
    update = update,
    subscriptions = subscriptions,
    view = view
  }

type alias Model = {
  windowSize : Window.Size,
  slides : Array(Html Msg),
  index : Int
}

type Msg =
  PreviousSlide
  | NextSlide
  | Idle
  | Resize Window.Size

init : (Model, Cmd Msg)
init =
  (Model (Window.Size 0 0) (toHtml Slides.all) 0,
    Task.perform (\_ -> Idle) (\x -> Resize x) Window.size)

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

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    PreviousSlide ->
      ({ model | index = model.index - 1 }, Cmd.none)
    NextSlide ->
      ({ model | index = model.index + 1 }, Cmd.none)
    Resize newSize ->
      ({ model | windowSize = newSize } , Cmd.none)
    Idle ->
      (model, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model =
  Window.resizes Resize

renderButtons model =
  div
    [ id "buttons",
      style [
        ("width", "100px"),
        ("height", "40px"),
        ("bottom", "0px"),
        ("right", "0px"),
        ("padding-top", "20px"),
        ("padding-left", "20px"),
        ("position", "absolute") ] ]
    [ button
        [ onClick PreviousSlide,
          disabled (model.index == 0) ]
        [ text "<" ],
      button
        [ onClick NextSlide,
          disabled (model.index == (Array.length model.slides - 1)) ]
        [ text ">" ] ]

toPx : Int -> String
toPx x =
  (toString x) ++ "px"

view : Model -> Html Msg
view model =
  div
    [ style [
      ("width", toPx model.windowSize.width),
      ("height", toPx model.windowSize.height),
      ("position", "relative") ] ]
    [ renderButtons model,
      div
        [ id "content", style [
          ("font-size", "1.2em"),
          ("top", "0px"),
          ("left", "0px"),
          ("right", "100px"),
          ("bottom", "40px"),
          ("padding-top", "20px"),
          ("padding-left", "40px"),
          ("position", "absolute") ] ]
        [ renderSlide model ] ]

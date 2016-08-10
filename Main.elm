import Array exposing (Array, fromList, map)
import Css
import Html exposing (Html, button, div, text)
import Html.App as App
import Html.Attributes exposing (class, disabled, style)
import Html.Events exposing (onClick)
import Markdown exposing (defaultOptions, toHtmlWith)
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
    (\s ->
      toHtmlWith
        { defaultOptions | githubFlavored = Just { tables = True, breaks = False } }
        [] s)
    (Array.fromList slides)

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
    [ class "buttons" ]
    [ button
        [ onClick PreviousSlide,
          disabled (model.index == 0) ]
        [ text "<" ],
      button
        [ onClick NextSlide,
          disabled (model.index == (Array.length model.slides - 1)) ]
        [ text ">" ] ]

renderSlide : Model -> Html Msg
renderSlide model =
  Maybe.withDefault
    (Markdown.toHtml [] "# Slide not found")
    (Array.get
      model.index
      model.slides)

view : Model -> Html Msg
view model =
  let
    imports = ["assets/main.css"]
    stylesheet = Css.stylesheet imports []
    width = (toString model.windowSize.width) ++ "px"
    height = (toString model.windowSize.height) ++ "px"
  in
    div
      [ class "container",
        style [ ("width", width), ("height", height) ] ]
      [ Css.style [ Html.Attributes.scoped True ] stylesheet,
        renderButtons model,
        div
          [ class "slide" ]
          [ renderSlide model ] ]

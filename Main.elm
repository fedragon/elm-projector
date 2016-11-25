import Array exposing (Array, fromList, map)
import Css
import Html exposing (Html, button, div, text)
import Html.Attributes exposing (class, disabled, style)
import Html.Events exposing (onClick)
import Http exposing (getString)
import Markdown
import Maybe exposing (Maybe, withDefault)
import Task
import Window

import Slides

main =
  Html.program {
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
  SlidesNotFound
  | GotSlides (Array(Html Msg))
  | PreviousSlide
  | NextSlide
  | Resize Window.Size

init : (Model, Cmd Msg)
init =
  (Model (Window.Size 0 0) Array.empty 0,
    Task.perform (\x -> Resize x) Window.size)

getSlides : Cmd Msg
getSlides =
  (Http.send
    (\r ->
      case r of
        Result.Err _ ->
          SlidesNotFound
        Result.Ok s ->
          GotSlides <| Slides.parse s)
    (Http.getString "/slides.md"))

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    SlidesNotFound ->
      (model, Cmd.none)
    GotSlides slides ->
      ({ model | slides = slides}, Cmd.none)
    PreviousSlide ->
      ({ model | index = model.index - 1 }, Cmd.none)
    NextSlide ->
      ({ model | index = model.index + 1 }, Cmd.none)
    Resize newSize ->
      ({ model | windowSize = newSize }, getSlides)

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
  div
    [ class "slide" ]
    [ Maybe.withDefault
        (Markdown.toHtml [] "# Slide not found")
        (Array.get
          model.index
          model.slides) ]

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
        renderSlide model ]

import Array exposing (Array, fromList, map)
import Css
import Html exposing (Html, button, div, text)
import Html.App as App
import Html.Attributes exposing (class, disabled, style)
import Html.Events exposing (onClick)
import Http exposing (getString)
import Markdown exposing (defaultOptions, toHtmlWith)
import Maybe exposing (Maybe, withDefault)
import String exposing (split)
import Task
import Window

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
  SlidesNotFound
  | GotSlides (Array(Html Msg))
  | PreviousSlide
  | NextSlide
  | Idle
  | Resize Window.Size

init : (Model, Cmd Msg)
init =
  (Model (Window.Size 0 0) Array.empty 0,
    Task.perform (\_ -> Idle) (\x -> Resize x) Window.size)

parseR : List Int -> String -> Array(Html Msg) -> Array(Html Msg)
parseR indexes slides acc =
  case indexes of
    [] -> Array.push (toHtml slides) acc
    hd :: tl ->
      let
        slide = String.left hd slides |> toHtml
        remaining = String.dropLeft hd slides
      in
        parseR
          tl
          remaining
          (Array.push slide acc)

parse : String -> Array(Html Msg)
parse raw =
  case (String.indexes "# " raw) of
    [] -> Array.empty
    hd :: tl ->
      let
        slides = String.dropLeft hd raw
      in
        parseR
          (String.indexes "# " slides |> List.drop 1)
          slides
          Array.empty

getSlides : Cmd Msg
getSlides =
  Task.perform
    (\_ -> SlidesNotFound)
    (\s -> GotSlides s)
    (Task.map
      (\slides -> parse slides)
      (Http.getString "/slides.md"))

toHtml : String -> Html Msg
toHtml s =
  toHtmlWith
    { defaultOptions | githubFlavored = Just { tables = True, breaks = False } }
    []
    s

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
    Idle ->
      (model, getSlides)

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

# elm-projector

Present Markdown slides as HTML. Built in [Elm](http://elm-lang.org). Heavily inspired by [reveal.js](http://lab.hakim.se/reveal-js/#/1).

## Add your slides

Slides are expected to be defined in `Slides.elm`.

To add a slide:
- create a multiline string that defines its contents, and
- append the created string to `all`, in the intended position.

Example:

    firstSlide = """
    # My first slide
    """
    secondSlide = """
    # My second slide
    """

    all = [firstSlide, secondSlide]

## Run

    elm reactor -a=localhost

then go to [http://localhost:8000/Main.elm](http://localhost:8000/Main.elm)
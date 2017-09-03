# elm-projector

Present Markdown slides as HTML. Built in [Elm](http://elm-lang.org). Heavily inspired by [reveal.js](http://lab.hakim.se/reveal-js/#/1).

## Add your slides

Write your slides in `slides.md`. Every **Heading 1** (e.g. `# First slide`) found in the file will be considered the beginning of new slide.

## Initial setup

    brew install node yarn
    yarn add webpack webpack-dev-server elm-webpack-loader file-loader style-loader css-loader

## Run

    yarn start

then go to [http://localhost:3000](http://localhost:3000)

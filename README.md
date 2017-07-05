# elm-projector

Present Markdown slides as HTML. Built in [Elm](http://elm-lang.org). Heavily inspired by [reveal.js](http://lab.hakim.se/reveal-js/#/1).

## Add your slides

Slides are expected to be defined in `slides.md`: each slide must start with a **Heading 1** (e.g. `# First slide`).

## Initial setup

    brew install node yarn
    yarn add webpack webpack-dev-server elm-webpack-loader file-loader style-loader css-loader

## Run

    yarn start

then go to [http://localhost:3000](http://localhost:3000)
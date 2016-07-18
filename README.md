# textile_to_markdown.rake

A rake task to convert redmine textile markup to markdown

Prior developing this rake script I was using [akohlbecker/convert_textile_to_markdown.rake](https://github.com/akohlbecker/convert_textile_to_markdown.rake) which is using [Pandoc](http://pandoc.org/) for the actual conversion. Pandoc created a lot of artifacts and was creating markdown which caused redmine 3.3.0 to crash. I order to avoid these problems I decided to take a more direct and simplistic approach.

(This rake script is partially based on https://gist.github.com/d3j/95924df9fccc4d381d75)

## Installation

Copy or symlink the file into the `./lib/tasks/` folder of your redmine installation.

## Execute

In the root of your redmine installation:

    rake -v redmine:textile_to_markdown  RAILS_ENV="production"

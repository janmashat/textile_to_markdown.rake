# textile_to_markdown.rake
A rake task to convert redmine textile markup to markdown

## Installation

Copy or symlink the file into the `./lib/tasks/` folder of your redmine installation.

## Execute

In the root of your redmine installation:

    rake -v redmine:textile_to_markdown  RAILS_ENV="production"
